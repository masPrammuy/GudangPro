-- ==============================================================================
-- GUDANGPRO APPAREL — SKEMA DATABASE POSTGRESQL (SUPABASE CLOUD)
-- Modul: Manajemen Produksi Pakaian, Stok Roll Kain, Aksesoris & Baju Jadi
-- Tanggal: 2026-10-13
-- Fitur: Database Triggers, Anti-Overshipping, Realtime Publication, & RLS 5 Role
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABEL: PROFILES (Terhubung ke auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('owner', 'supervisor', 'inbound_staff', 'cutting_operator', 'outbound_staff')),
  phone_number TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL: INVENTORY_ITEMS (Master Bahan Kain, Aksesoris & Baju)
CREATE TABLE IF NOT EXISTS public.inventory_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sku TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'Kain & Bahan Baku',
    'Aksesoris Jahit',
    'Pola & Hasil Cutting',
    'Baju Jadi (Siap Kirim)',
    'Packaging & Hangtag'
  )),
  qty INTEGER NOT NULL DEFAULT 0 CHECK (qty >= 0),
  unit TEXT NOT NULL DEFAULT 'Pcs' CHECK (unit IN ('Roll', 'Lusin', 'Pcs', 'Meter', 'Kg', 'Pack', 'Cones')),
  min_stock INTEGER NOT NULL DEFAULT 15 CHECK (min_stock >= 0),
  location TEXT NOT NULL,
  zone TEXT NOT NULL CHECK (zone IN ('A', 'B', 'C', 'D')),
  status TEXT NOT NULL DEFAULT 'Tersedia',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL: INBOUND_TRANSACTIONS (Penerimaan Bahan Kain / Aksesoris Masuk)
CREATE TABLE IF NOT EXISTS public.inbound_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  po_number TEXT UNIQUE NOT NULL,
  item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE RESTRICT,
  qty INTEGER NOT NULL CHECK (qty > 0),
  supplier TEXT NOT NULL,
  lot_number TEXT DEFAULT '-',
  notes TEXT DEFAULT '-',
  status TEXT NOT NULL DEFAULT 'QC Passed',
  received_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  received_at DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABEL: OUTBOUND_TRANSACTIONS (Surat Jalan DO Pengiriman Baju Jadi)
CREATE TABLE IF NOT EXISTS public.outbound_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  do_number TEXT UNIQUE NOT NULL,
  item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE RESTRICT,
  qty INTEGER NOT NULL CHECK (qty > 0),
  recipient TEXT NOT NULL,
  courier TEXT NOT NULL,
  notes TEXT DEFAULT '-',
  status TEXT NOT NULL DEFAULT 'Terkirim',
  dispatched_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  dispatched_at DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TABEL: STOCK_AUDITS (Stock Opname Fisik & Penyesuaian Selisih)
CREATE TABLE IF NOT EXISTS public.stock_audits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  item_id UUID NOT NULL REFERENCES public.inventory_items(id) ON DELETE RESTRICT,
  system_stock INTEGER NOT NULL,
  physical_stock INTEGER NOT NULL CHECK (physical_stock >= 0),
  discrepancy INTEGER NOT NULL,
  reason TEXT NOT NULL DEFAULT 'Penyesuaian hasil audit fisik garmen',
  audited_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  audited_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- LOGIKA DATABASE TRIGGERS (MUTASI OTOMATIS & PROTEKSI OVER-SHIPPING)
-- ==============================================================================

-- A. Trigger Inbound: Otomatis Menambah Stok saat Bahan Masuk
CREATE OR REPLACE FUNCTION public.fn_handle_inbound_stock()
RETURNS TRIGGER AS $$
DECLARE
  v_min_stock INTEGER;
  v_new_qty INTEGER;
BEGIN
  SELECT min_stock INTO v_min_stock FROM public.inventory_items WHERE id = NEW.item_id;

  UPDATE public.inventory_items
  SET 
    qty = qty + NEW.qty,
    status = CASE 
      WHEN (qty + NEW.qty) = 0 THEN '🚨 Stok Habis'
      WHEN (qty + NEW.qty) <= v_min_stock THEN '⚠️ Stok Minimum!'
      ELSE 'Tersedia'
    END,
    updated_at = NOW()
  WHERE id = NEW.item_id
  RETURNING qty INTO v_new_qty;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_inbound_stock_increment ON public.inbound_transactions;
CREATE TRIGGER trg_inbound_stock_increment
AFTER INSERT ON public.inbound_transactions
FOR EACH ROW EXECUTE FUNCTION public.fn_handle_inbound_stock();


-- B. Trigger Outbound: Validasi Anti Over-Shipping & Potong Stok Otomatis
CREATE OR REPLACE FUNCTION public.fn_handle_outbound_stock()
RETURNS TRIGGER AS $$
DECLARE
  v_current_qty INTEGER;
  v_min_stock INTEGER;
  v_item_name TEXT;
BEGIN
  -- Kunci baris dengan FOR UPDATE agar bebas race condition
  SELECT qty, min_stock, name INTO v_current_qty, v_min_stock, v_item_name
  FROM public.inventory_items
  WHERE id = NEW.item_id
  FOR UPDATE;

  IF v_current_qty IS NULL THEN
    RAISE EXCEPTION 'Item inventaris dengan ID % tidak ditemukan.', NEW.item_id;
  END IF;

  -- Validasi stok tersedia
  IF v_current_qty < NEW.qty THEN
    RAISE EXCEPTION 'Stok tidak mencukupi untuk item "%"! Tersedia hanya % pcs, diminta % pcs.', 
      v_item_name, v_current_qty, NEW.qty;
  END IF;

  -- Potong stok
  UPDATE public.inventory_items
  SET 
    qty = qty - NEW.qty,
    status = CASE 
      WHEN (qty - NEW.qty) = 0 THEN '🚨 Stok Habis'
      WHEN (qty - NEW.qty) <= v_min_stock THEN '⚠️ Stok Minimum!'
      ELSE 'Tersedia'
    END,
    updated_at = NOW()
  WHERE id = NEW.item_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_outbound_stock_deduct ON public.outbound_transactions;
CREATE TRIGGER trg_outbound_stock_deduct
BEFORE INSERT ON public.outbound_transactions
FOR EACH ROW EXECUTE FUNCTION public.fn_handle_outbound_stock();


-- C. Trigger Audit: Sinkronisasi Stok Fisik dengan Stok Master
CREATE OR REPLACE FUNCTION public.fn_handle_audit_stock_sync()
RETURNS TRIGGER AS $$
DECLARE
  v_min_stock INTEGER;
BEGIN
  SELECT min_stock INTO v_min_stock FROM public.inventory_items WHERE id = NEW.item_id;

  UPDATE public.inventory_items
  SET 
    qty = NEW.physical_stock,
    status = CASE 
      WHEN NEW.physical_stock = 0 THEN '🚨 Stok Habis'
      WHEN NEW.physical_stock <= v_min_stock THEN '⚠️ Stok Minimum!'
      ELSE 'Tersedia'
    END,
    updated_at = NOW()
  WHERE id = NEW.item_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_stock_sync ON public.stock_audits;
CREATE TRIGGER trg_audit_stock_sync
AFTER INSERT ON public.stock_audits
FOR EACH ROW EXECUTE FUNCTION public.fn_handle_audit_stock_sync();


-- ==============================================================================
-- SUPABASE REALTIME PUBLICATION
-- ==============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.inventory_items;
ALTER PUBLICATION supabase_realtime ADD TABLE public.inbound_transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.outbound_transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.stock_audits;


-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inbound_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outbound_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_audits ENABLE ROW LEVEL SECURITY;

-- Helper function: membaca role pengguna aktif
CREATE OR REPLACE FUNCTION public.get_current_user_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Policy Profiles: Pengguna bisa melihat profil tim, hanya owner/spv yang bisa ubah role
CREATE POLICY "Semua staf terautentikasi dapat melihat profil" ON public.profiles
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Owner dan SPV dapat mengelola profil pengguna" ON public.profiles
FOR ALL USING (get_current_user_role() IN ('owner', 'supervisor'));

-- Policy Inventory Items: Semua staf bisa membaca, owner/spv bisa modifikasi langsung
CREATE POLICY "Semua staf terautentikasi dapat melihat inventaris" ON public.inventory_items
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Owner dan SPV dapat menambah atau mengubah master barang" ON public.inventory_items
FOR ALL USING (get_current_user_role() IN ('owner', 'supervisor'));

-- Policy Inbound: Semua staf bisa lihat, inbound_staff, owner & spv bisa catat
CREATE POLICY "Semua staf dapat melihat riwayat inbound" ON public.inbound_transactions
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Inbound staff, owner dan spv dapat mencatat bahan masuk" ON public.inbound_transactions
FOR INSERT WITH CHECK (get_current_user_role() IN ('owner', 'supervisor', 'inbound_staff'));

-- Policy Outbound: Semua staf bisa lihat, outbound_staff, owner & spv bisa catat
CREATE POLICY "Semua staf dapat melihat riwayat outbound" ON public.outbound_transactions
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Outbound staff, owner dan spv dapat menerbitkan surat jalan" ON public.outbound_transactions
FOR INSERT WITH CHECK (get_current_user_role() IN ('owner', 'supervisor', 'outbound_staff'));

-- Policy Stock Audits: Semua staf bisa lihat, supervisor & owner bisa mencatat opname
CREATE POLICY "Semua staf dapat melihat riwayat stock opname" ON public.stock_audits
FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Supervisor dan Owner dapat mencatat hasil opname" ON public.stock_audits
FOR INSERT WITH CHECK (get_current_user_role() IN ('owner', 'supervisor'));


-- ==============================================================================
-- DATA BAWAAN AWAL (SEED DEFAULT APPAREL DATA)
-- ==============================================================================
INSERT INTO public.inventory_items (sku, name, category, qty, unit, min_stock, location, zone, status)
VALUES
  ('KAN-CMB-01', 'Kain Katun Combed 30s Hitam Reaktif', 'Kain & Bahan Baku', 45, 'Roll', 15, 'Rak Kain A-01', 'A', 'Tersedia'),
  ('BNG-JHT-08', 'Benang Jahit Spun Polyester Putih Extra (40/2)', 'Aksesoris Jahit', 8, 'Lusin', 20, 'Rak Aksesoris B-02', 'B', '⚠️ Stok Minimum!'),
  ('KNC-KMG-14', 'Kancing Kemeja Lubang Empat 14mm Putih Mutiara', 'Aksesoris Jahit', 450, 'Pcs', 100, 'Rak Aksesoris B-05', 'B', 'Tersedia'),
  ('CUT-KAOS-L', 'Pola Potong Kaos Polos Lengan Pendek Combed (L)', 'Pola & Hasil Cutting', 65, 'Lusin', 25, 'Meja Cutting C-01', 'C', 'Tersedia'),
  ('BJU-OVR-BLK', 'Kaos Polos Oversize Katun 24s Hitam Size L (Siap Kirim)', 'Baju Jadi (Siap Kirim)', 6, 'Pcs', 30, 'Rak Baju D-03', 'D', '⚠️ Stok Minimum!'),
  ('RST-YKK-60', 'Resleting Jaket YKK Metal Open End 60cm Hitam', 'Aksesoris Jahit', 0, 'Pcs', 50, 'Rak Aksesoris B-01', 'B', '🚨 Stok Habis'),
  ('BJU-KMG-FLN', 'Kemeja Pria Flanel Kotak Tartan Lengan Panjang (M)', 'Baju Jadi (Siap Kirim)', 32, 'Pcs', 15, 'Rak Baju D-01', 'D', 'Tersedia'),
  ('PKG-OPP-30', 'Plastik Kemasan Baju OPP Seal Tebal 30x40 cm + Hangtag', 'Packaging & Hangtag', 500, 'Pcs', 150, 'Rak Packing D-05', 'D', 'Tersedia')
ON CONFLICT (sku) DO NOTHING;
