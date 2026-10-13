# Supabase Cloud Database Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengintegrasikan backend database Supabase PostgreSQL dengan frontend Web Dashboard GudangPro Apparel, menerapkan database triggers untuk mutasi stok otomatis dan pencegahan over-shipping, realtime subscription, serta arsitektur hybrid offline-first yang menjamin aplikasi tetap beroperasi mulus saat offline.

**Architecture:** Frontend web mengonsumsi adaptor `supabase-client.js` yang mengenkapsulasi komunikasi REST & Realtime dengan Supabase PostgreSQL. Jika koneksi cloud tidak tersedia atau kredensial belum dikonfigurasi, adaptor secara transparan mengalihkan operasi ke engine `localStorage` yang telah ada tanpa mengganggu pengalaman pengguna.

**Tech Stack:** PostgreSQL (Supabase Cloud), SQL Triggers & RLS, Vanilla JavaScript (ES6+), HTML5, CSS3, Python 3.13 (Testing Framework).

**Spec:** `docs/superpowers/specs/2026-10-13-supabase-cloud-database-design.md`

## Global Constraints

- Backend database PostgreSQL menggunakan skema resmi dari `docs/superpowers/specs/2026-10-13-supabase-garment-schema.sql`.
- Frontend web murni Vanilla JavaScript tanpa dependensi build step (Webpack/Vite) atau external bundling framework.
- Zero-freeze policy: Halaman web tidak boleh mengalami freeze/stuck "Memuat..." dalam kondisi apa pun (baik online dengan Supabase, offline, maupun unconfigured).
- Mutasi kuantitas stok dikontrol secara atomik di tingkat database trigger dengan proteksi row-lock (`FOR UPDATE`) dan exception over-shipping.
- Seluruh 5 role staf garmen (`owner`, `supervisor`, `inbound_staff`, `cutting_operator`, `outbound_staff`) diakomodasi dalam hak akses RLS.
- Semua pengujian diotomatisasi menggunakan script pengujian Python (`tests/test_*.py`) dengan assert yang jelas.

---

### Task 1: Verifikasi Validitas Skema SQL & Triggers Database

**Files:**
- Create: `tests/test_supabase_schema.py`
- Test: `tests/test_supabase_schema.py`

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-10-13-supabase-garment-schema.sql`
- Produces: Validasi sintaks struktural DDL, triggers, RLS, dan seed data untuk deployment Supabase.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_supabase_schema.py
import os
import re
import unittest

SCHEMA_PATH = os.path.join(
    os.path.dirname(__file__), "..", "docs", "superpowers", "specs", "2026-10-13-supabase-garment-schema.sql"
)

class TestSupabaseSchema(unittest.TestCase):
    def setUp(self):
        self.assertTrue(os.path.exists(SCHEMA_PATH), f"File schema tidak ditemukan di {SCHEMA_PATH}")
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            self.sql_content = f.read()

    def test_tables_exist(self):
        required_tables = [
            "public.profiles",
            "public.inventory_items",
            "public.inbound_transactions",
            "public.outbound_transactions",
            "public.stock_audits",
        ]
        for table in required_tables:
            pattern = rf"CREATE TABLE IF NOT EXISTS {re.escape(table)}"
            self.assertRegex(
                self.sql_content, pattern, f"Tabel {table} tidak terdefinisi dalam skema SQL"
            )

    def test_triggers_and_functions_exist(self):
        required_functions = [
            "fn_handle_inbound_stock",
            "fn_handle_outbound_stock",
            "fn_handle_audit_stock_sync",
        ]
        for func in required_functions:
            pattern = rf"CREATE OR REPLACE FUNCTION public\.{func}"
            self.assertRegex(self.sql_content, pattern, f"Fungsi {func} tidak terdefinisi")

        required_triggers = [
            "trg_inbound_stock_increment",
            "trg_outbound_stock_deduct",
            "trg_audit_stock_sync",
        ]
        for trg in required_triggers:
            pattern = rf"CREATE TRIGGER {trg}"
            self.assertRegex(self.sql_content, pattern, f"Trigger {trg} tidak terdefinisi")

    def test_anti_overshipping_logic(self):
        self.assertIn("FOR UPDATE", self.sql_content, "Proteksi race condition FOR UPDATE harus ada pada trigger outbound")
        self.assertIn("RAISE EXCEPTION", self.sql_content, "Trigger outbound harus melempar exception saat over-shipping")

    def test_realtime_publication(self):
        tables = ["inventory_items", "inbound_transactions", "outbound_transactions", "stock_audits"]
        for t in tables:
            pattern = rf"ALTER PUBLICATION supabase_realtime ADD TABLE public\.{t};"
            self.assertRegex(self.sql_content, pattern, f"Tabel {t} harus didaftarkan ke realtime publication")

    def test_rls_enabled_and_roles_defined(self):
        tables = ["profiles", "inventory_items", "inbound_transactions", "outbound_transactions", "stock_audits"]
        for t in tables:
            pattern = rf"ALTER TABLE public\.{t} ENABLE ROW LEVEL SECURITY;"
            self.assertRegex(self.sql_content, pattern, f"RLS harus diaktifkan pada {t}")

        roles = ["owner", "supervisor", "inbound_staff", "cutting_operator", "outbound_staff"]
        for r in roles:
            self.assertIn(f"'{r}'", self.sql_content, f"Role {r} harus terdapat dalam constraint profile")

    def test_seed_data(self):
        self.assertIn("INSERT INTO public.inventory_items", self.sql_content)
        self.assertIn("KAN-CMB-01", self.sql_content)
        self.assertIn("BJU-OVR-BLK", self.sql_content)

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python tests/test_supabase_schema.py`
Expected: FAIL (jika file test belum dibuat)

- [ ] **Step 3: Write minimal implementation**

Simpan file `tests/test_supabase_schema.py` dan pastikan file skrip SQL `docs/superpowers/specs/2026-10-13-supabase-garment-schema.sql` telah memenuhi seluruh pengecekan.

- [ ] **Step 4: Run test to verify it passes**

Run: `python tests/test_supabase_schema.py`
Expected: OK (Ran 6 tests in 0.005s - OK)

- [ ] **Step 5: Commit**

```bash
git add tests/test_supabase_schema.py
git commit -m "test(supabase): add comprehensive SQL schema and trigger validation suite"
```

---

### Task 2: Adaptor Klien Hybrid & Fallback Offline (`supabase-client.js`)

**Files:**
- Create: `supabase-client.js`
- Create: `tests/test_supabase_client.py`

**Interfaces:**
- Consumes: Kredensial URL dan Anon Key (opsional via `window.GP_CONFIG`), `localStorage` browser.
- Produces: Objek global `window.gpSupabase` dengan API seragam:
  - `isConfigured()` -> Boolean
  - `fetchInventory()` -> Promise<Array>
  - `createInboundPO(poData)` -> Promise<Object>
  - `createOutboundDO(doData)` -> Promise<Object>
  - `recordAudit(auditData)` -> Promise<Object>

- [ ] **Step 1: Write the failing test**

```python
# tests/test_supabase_client.py
import os
import unittest

CLIENT_PATH = os.path.join(os.path.dirname(__file__), "..", "supabase-client.js")

class TestSupabaseClient(unittest.TestCase):
    def setUp(self):
        self.assertTrue(os.path.exists(CLIENT_PATH), f"File {CLIENT_PATH} tidak ditemukan")
        with open(CLIENT_PATH, "r", encoding="utf-8") as f:
            self.js_content = f.read()

    def test_client_class_and_instance(self):
        self.assertIn("class GudangProSupabaseClient", self.js_content)
        self.assertIn("window.gpSupabase =", self.js_content)

    def test_required_methods(self):
        methods = [
            "isConfigured",
            "fetchInventory",
            "createInboundPO",
            "createOutboundDO",
            "recordAudit",
            "subscribeToRealtime",
        ]
        for m in methods:
            self.assertIn(m, self.js_content, f"Metode {m} harus ada pada GudangProSupabaseClient")

    def test_local_fallback_keys(self):
        keys = [
            "gp_apparel_inventory",
            "gp_apparel_inbound_logs",
            "gp_apparel_outbound_logs",
            "gp_apparel_audit_logs",
        ]
        for k in keys:
            self.assertIn(k, self.js_content, f"Fallback storage key {k} harus ada")

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python tests/test_supabase_client.py`
Expected: FAIL (`AssertionError: False is not true : File .../supabase-client.js tidak ditemukan`)

- [ ] **Step 3: Write minimal implementation**

Tulis file `supabase-client.js` dengan arsitektur hybrid:

```javascript
// supabase-client.js
// GudangPro Apparel — Hybrid Cloud & Local-First Supabase Client Adapter
// Mendukung transisi mulus antara Supabase PostgreSQL Cloud dan fallback localStorage.

(function (window) {
  'use strict';

  class GudangProSupabaseClient {
    constructor() {
      const config = window.GP_CONFIG || {};
      this.supabaseUrl = config.supabaseUrl || '';
      this.supabaseKey = config.supabaseAnonKey || '';
      this.isCloudEnabled = Boolean(this.supabaseUrl && this.supabaseKey);
      this.subscribers = [];
    }

    isConfigured() {
      return this.isCloudEnabled;
    }

    isOnline() {
      return typeof navigator !== 'undefined' ? navigator.onLine : true;
    }

    getStatus() {
      if (this.isConfigured() && this.isOnline()) {
        return { mode: 'cloud', label: '🟢 Cloud Supabase Terhubung', cssClass: 'status-cloud' };
      }
      return { mode: 'local', label: '⚡ Mode Lokal (Offline-Ready)', cssClass: 'status-local' };
    }

    async fetchInventory() {
      if (this.isConfigured() && this.isOnline()) {
        try {
          const res = await fetch(`${this.supabaseUrl}/rest/v1/inventory_items?select=*&order=created_at.asc`, {
            headers: {
              'apikey': this.supabaseKey,
              'Authorization': `Bearer ${this.supabaseKey}`
            }
          });
          if (res.ok) {
            const data = await res.json();
            localStorage.setItem('gp_apparel_inventory', JSON.stringify(data));
            return data;
          }
        } catch (err) {
          console.warn('[GudangPro Cloud] Gagal mengambil data Supabase, fallback ke lokal:', err);
        }
      }
      const local = localStorage.getItem('gp_apparel_inventory');
      return local ? JSON.parse(local) : [];
    }

    async createInboundPO(poData) {
      if (this.isConfigured() && this.isOnline()) {
        try {
          const res = await fetch(`${this.supabaseUrl}/rest/v1/inbound_transactions`, {
            method: 'POST',
            headers: {
              'apikey': this.supabaseKey,
              'Authorization': `Bearer ${this.supabaseKey}`,
              'Content-Type': 'application/json',
              'Prefer': 'return=representation'
            },
            body: JSON.stringify(poData)
          });
          if (res.ok) {
            return await res.json();
          }
          const errData = await res.json();
          throw new Error(errData.message || 'Gagal menyimpan transaksi inbound di cloud');
        } catch (err) {
          console.warn('[GudangPro Cloud] Fallback lokal untuk Inbound PO:', err);
        }
      }
      const existingLogs = JSON.parse(localStorage.getItem('gp_apparel_inbound_logs') || '[]');
      existingLogs.unshift(poData);
      localStorage.setItem('gp_apparel_inbound_logs', JSON.stringify(existingLogs));
      return [poData];
    }

    async createOutboundDO(doData) {
      if (this.isConfigured() && this.isOnline()) {
        try {
          const res = await fetch(`${this.supabaseUrl}/rest/v1/outbound_transactions`, {
            method: 'POST',
            headers: {
              'apikey': this.supabaseKey,
              'Authorization': `Bearer ${this.supabaseKey}`,
              'Content-Type': 'application/json',
              'Prefer': 'return=representation'
            },
            body: JSON.stringify(doData)
          });
          if (res.ok) {
            return await res.json();
          }
          const errData = await res.json();
          throw new Error(errData.message || 'Gagal menyimpan surat jalan DO di cloud');
        } catch (err) {
          if (err.message && err.message.includes('Stok tidak mencukupi')) {
            throw err;
          }
          console.warn('[GudangPro Cloud] Fallback lokal untuk Outbound DO:', err);
        }
      }
      const existingLogs = JSON.parse(localStorage.getItem('gp_apparel_outbound_logs') || '[]');
      existingLogs.unshift(doData);
      localStorage.setItem('gp_apparel_outbound_logs', JSON.stringify(existingLogs));
      return [doData];
    }

    async recordAudit(auditData) {
      if (this.isConfigured() && this.isOnline()) {
        try {
          const res = await fetch(`${this.supabaseUrl}/rest/v1/stock_audits`, {
            method: 'POST',
            headers: {
              'apikey': this.supabaseKey,
              'Authorization': `Bearer ${this.supabaseKey}`,
              'Content-Type': 'application/json',
              'Prefer': 'return=representation'
            },
            body: JSON.stringify(auditData)
          });
          if (res.ok) {
            return await res.json();
          }
        } catch (err) {
          console.warn('[GudangPro Cloud] Fallback lokal untuk Audit Opname:', err);
        }
      }
      const existingLogs = JSON.parse(localStorage.getItem('gp_apparel_audit_logs') || '[]');
      existingLogs.unshift(auditData);
      localStorage.setItem('gp_apparel_audit_logs', JSON.stringify(existingLogs));
      return [auditData];
    }

    subscribeToRealtime(callback) {
      if (typeof callback === 'function') {
        this.subscribers.push(callback);
      }
    }
  }

  window.GudangProSupabaseClient = GudangProSupabaseClient;
  window.gpSupabase = new GudangProSupabaseClient();
})(typeof window !== 'undefined' ? window : this);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python tests/test_supabase_client.py`
Expected: OK (Ran 3 tests in 0.003s - OK)

- [ ] **Step 5: Commit**

```bash
git add supabase-client.js tests/test_supabase_client.py
git commit -m "feat(client): implement hybrid Supabase client adapter with offline-first fallback"
```

---

### Task 3: Integrasi Adaptor Cloud & Status Badge ke `dashboard.html` dan `dashboard.js`

**Files:**
- Modify: `dashboard.html`
- Modify: `dashboard.js`
- Modify: `style.css`
- Create: `tests/test_cloud_integration.py`

**Interfaces:**
- Consumes: `window.gpSupabase` dari `supabase-client.js`.
- Produces: Elemen `#cloudStatusBadge` di UI header, pembaruan fungsi mutasi data secara asinkron.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_cloud_integration.py
import os
import unittest

HTML_PATH = os.path.join(os.path.dirname(__file__), "..", "dashboard.html")
JS_PATH = os.path.join(os.path.dirname(__file__), "..", "dashboard.js")
CSS_PATH = os.path.join(os.path.dirname(__file__), "..", "style.css")

class TestCloudIntegration(unittest.TestCase):
    def test_html_includes_script_and_badge(self):
        with open(HTML_PATH, "r", encoding="utf-8") as f:
            html = f.read()
        self.assertIn('src="supabase-client.js"', html, "dashboard.html harus memuat supabase-client.js")
        self.assertIn('id="cloudStatusBadge"', html, "dashboard.html harus memiliki badge status koneksi cloud")

    def test_css_contains_status_badge_styles(self):
        with open(CSS_PATH, "r", encoding="utf-8") as f:
            css = f.read()
        self.assertIn(".cloud-badge", css, "style.css harus memiliki styling .cloud-badge")
        self.assertIn(".status-cloud", css)
        self.assertIn(".status-local", css)

    def test_js_initializes_cloud_status(self):
        with open(JS_PATH, "r", encoding="utf-8") as f:
            js = f.read()
        self.assertIn("renderCloudStatus", js, "dashboard.js harus memiliki fungsi renderCloudStatus")
        self.assertIn("gpSupabase", js, "dashboard.js harus berintegrasi dengan window.gpSupabase")

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python tests/test_cloud_integration.py`
Expected: FAIL (`AssertionError: 'src="supabase-client.js"' not found in dashboard.html`)

- [ ] **Step 3: Write minimal implementation**

1. Tambahkan tag script `<script src="supabase-client.js"></script>` tepat sebelum `dashboard.js` di `dashboard.html`.
2. Tambahkan `<div id="cloudStatusBadge" class="cloud-badge status-local">⚡ Mode Lokal (Offline-Ready)</div>` di header dashboard.
3. Tambahkan styling `.cloud-badge`, `.status-cloud`, dan `.status-local` di `style.css`.
4. Tambahkan fungsi `renderCloudStatus()` di `dashboard.js` yang dipanggil saat `initApp()`.

- [ ] **Step 4: Run test to verify it passes**

Run: `python tests/test_cloud_integration.py`
Expected: OK (Ran 3 tests in 0.004s - OK)

- [ ] **Step 5: Commit**

```bash
git add dashboard.html dashboard.js style.css tests/test_cloud_integration.py
git commit -m "feat(ui): integrate Supabase cloud status badge and adapter wiring in dashboard"
```

---

### Task 4: Realtime Subscription Listener & Sinkronisasi Event Otomatis

**Files:**
- Modify: `supabase-client.js`
- Modify: `dashboard.js`
- Create: `tests/test_realtime_listener.py`

**Interfaces:**
- Consumes: Event broadcast postgres dari Supabase Realtime Channel.
- Produces: UI auto-update pada tabel inventaris, inbound, outbound, dan audit tanpa reload halaman.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_realtime_listener.py
import os
import unittest

CLIENT_PATH = os.path.join(os.path.dirname(__file__), "..", "supabase-client.js")
JS_PATH = os.path.join(os.path.dirname(__file__), "..", "dashboard.js")

class TestRealtimeListener(unittest.TestCase):
    def test_realtime_broadcast_dispatch(self):
        with open(CLIENT_PATH, "r", encoding="utf-8") as f:
            client_js = f.read()
        self.assertIn("dispatchRealtimeEvent", client_js, "Client harus memiliki dispatchRealtimeEvent")
        self.assertIn("initRealtimeChannel", client_js, "Client harus memiliki inisialisasi channel realtime")

    def test_dashboard_listens_to_realtime(self):
        with open(JS_PATH, "r", encoding="utf-8") as f:
            dash_js = f.read()
        self.assertIn("handleRealtimeUpdate", dash_js, "dashboard.js harus menangani event handleRealtimeUpdate")

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python tests/test_realtime_listener.py`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

1. Tambahkan fungsi `initRealtimeChannel()` dan `dispatchRealtimeEvent(payload)` pada `GudangProSupabaseClient` di `supabase-client.js`.
2. Daftarkan callback di `dashboard.js` yang menyegarkan tampilan tabel aktif (`renderInventoryTable()`, `renderInboundTable()`, `renderOutboundTable()`, `renderZoneSummary()`) saat payload mutasi tiba.

- [ ] **Step 4: Run test to verify it passes**

Run: `python tests/test_realtime_listener.py`
Expected: OK (Ran 2 tests in 0.003s - OK)

- [ ] **Step 5: Commit**

```bash
git add supabase-client.js dashboard.js tests/test_realtime_listener.py
git commit -m "feat(realtime): add live channel subscription listener and automatic UI table synchronization"
```

---

### Task 5: Panduan Deployment Supabase Cloud & Verifikasi Sistem End-to-End

**Files:**
- Create: `docs/supabase-deployment-guide.md`
- Create: `tests/test_full_regression.py`

**Interfaces:**
- Consumes: Seluruh modul sistem (HTML, CSS, JS, SQL).
- Produces: Verifikasi bebas regresi 100% dan petunjuk deployment bagi pengguna.

- [ ] **Step 1: Write the failing test**

```python
# tests/test_full_regression.py
import subprocess
import sys
import unittest

class TestFullRegression(unittest.TestCase):
    def test_all_suites_pass(self):
        suites = [
            "tests/test_dom_structure.py",
            "tests/test_css_styles.py",
            "tests/test_tab_switcher.py",
            "tests/test_inbound_logic.py",
            "tests/test_outbound_logic.py",
            "tests/test_zones_and_audit.py",
            "tests/test_supabase_schema.py",
            "tests/test_supabase_client.py",
            "tests/test_cloud_integration.py",
            "tests/test_realtime_listener.py",
        ]
        for suite in suites:
            res = subprocess.run([sys.executable, suite], capture_output=True, text=True)
            self.assertEqual(
                res.returncode, 0,
                f"Test suite {suite} gagal:\nSTDOUT: {res.stdout}\nSTDERR: {res.stderr}"
            )

if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python tests/test_full_regression.py`
Expected: FAIL (jika ada task sebelumnya yang belum tuntas)

- [ ] **Step 3: Write minimal implementation**

Tulis dokumentasi deployment di `docs/supabase-deployment-guide.md`:
- Cara membuka project di Supabase Dashboard (gratis).
- Cara menjalankan skrip SQL `docs/superpowers/specs/2026-10-13-supabase-garment-schema.sql` via SQL Editor.
- Cara menyalin Project URL dan Anon Key ke konfigurasi web `dashboard.html`.

- [ ] **Step 4: Run test to verify it passes**

Run: `python tests/test_full_regression.py`
Expected: OK (Ran 1 test in ~0.5s - OK)

- [ ] **Step 5: Commit**

```bash
git add docs/supabase-deployment-guide.md tests/test_full_regression.py
git commit -m "docs(deployment): provide Supabase SQL setup guide and full regression test runner"
```
