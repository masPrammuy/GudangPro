-- ═══════════════════════════════════════════════════════════════════════
-- GudangPro — Supabase Database & Auth Setup Schema
-- Jalankan skrip ini di: Supabase Dashboard > SQL Editor > New Query
-- ═══════════════════════════════════════════════════════════════════════

-- 1. Buat tabel profiles untuk menyimpan data detail pengguna gudang
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text not null,
  role text default 'Staff Gudang',
  email text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Aktifkan Row Level Security (RLS)
alter table public.profiles enable row level security;

-- 3. Kebijakan RLS (Policy)
-- Setiap pengguna yang terautentikasi dapat melihat daftar profil
create policy "Profil dapat dibaca oleh pengguna terautentikasi"
  on public.profiles for select
  to authenticated
  using (true);

-- Pengguna hanya dapat memperbarui profil milik mereka sendiri
create policy "Pengguna dapat mengubah profil sendiri"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

-- 4. Fungsi & Trigger Otomatis saat Pengguna Mendaftar di Supabase Auth
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Pengguna Gudang'),
    coalesce(new.raw_user_meta_data->>'role', 'Staff Gudang'),
    new.email,
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  );
  return new;
end;
$$;

-- Pasang trigger ke tabel auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Selesai! Tabel profil dan sinkronisasi otomatis registrasi siap digunakan.
