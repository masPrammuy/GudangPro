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
