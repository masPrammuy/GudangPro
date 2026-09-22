import os
import re
import unittest

class TestTabWorkspaceSwitcher(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.js_path = os.path.join(os.path.dirname(__file__), "..", "dashboard.js")
        cls.assertTrue(os.path.exists(cls.js_path), f"dashboard.js not found at {cls.js_path}")
        with open(cls.js_path, "r", encoding="utf-8") as f:
            cls.js_content = f.read()

    def test_switch_view_function_defined(self):
        """Test that switchView function is defined and handles all 6 views and sidebar navs."""
        self.assertRegex(
            self.js_content,
            r'function\s+switchView\s*\(',
            "switchView function is not defined in dashboard.js"
        )
        
        # 6 workspace views must be handled in switchView
        expected_views = [
            "viewOverview", "viewInventory", "viewInbound",
            "viewOutbound", "viewZones", "viewAudit"
        ]
        for v in expected_views:
            self.assertIn(v, self.js_content, f"View container {v} is not referenced in dashboard.js")

        # 6 sidebar navigation IDs must be handled
        expected_navs = [
            "navOverview", "navInventory", "navInbound",
            "navOutbound", "navRacks", "navAudit"
        ]
        for n in expected_navs:
            self.assertIn(n, self.js_content, f"Sidebar navigation id {n} is not referenced in dashboard.js")

    def test_switch_view_reactivity_and_inventory_render(self):
        """Test that switchView toggles active class/display and triggers renderInventoryTable."""
        # Must remove/add active class and manipulate display
        self.assertRegex(
            self.js_content,
            r'classList\.(add|remove)\([\'"]active[\'"]\)',
            "switchView must toggle 'active' class on views/navs"
        )
        self.assertIn(
            "renderInventoryTable",
            self.js_content,
            "renderInventoryTable must be referenced for reactivity"
        )
        # Verify renderInventoryTable is triggered when switching to viewInventory
        self.assertRegex(
            self.js_content,
            r'(?s)viewInventory.*renderInventoryTable|renderInventoryTable.*viewInventory',
            "renderInventoryTable should be called when switching to viewInventory"
        )

    def test_local_storage_initializers_and_seeds(self):
        """Test that all 4 localStorage keys are managed and initialized with realistic seeds."""
        required_keys = [
            "gp_apparel_inventory",
            "gp_apparel_inbound_logs",
            "gp_apparel_outbound_logs",
            "gp_apparel_audit_logs"
        ]
        for key in required_keys:
            self.assertIn(
                key,
                self.js_content,
                f"Required localStorage key '{key}' is missing in dashboard.js"
            )

        # Realistic seed records for Inbound
        self.assertIn("PO-TX-2026-001", self.js_content, "Missing sample PO PO-TX-2026-001 in inbound seed")
        self.assertIn("PT Surya Tekstil Bandung", self.js_content, "Missing sample supplier in inbound seed")
        self.assertIn("QC Passed", self.js_content, "Missing QC Passed status in inbound seed")

        # Realistic seed records for Outbound
        self.assertIn("DO-GP-2026-001", self.js_content, "Missing sample DO DO-GP-2026-001 in outbound seed")
        self.assertIn("Distro Urban Cloth Jakarta", self.js_content, "Missing sample recipient in outbound seed")
        self.assertIn("Terkirim", self.js_content, "Missing Terkirim status in outbound seed")

        # Realistic seed records for Audit
        self.assertRegex(
            self.js_content,
            r'DEFAULT_AUDIT_LOGS|gp_apparel_audit_logs',
            "Audit logs must be initialized in storage"
        )

    def test_no_dummy_sidebar_toast_handlers(self):
        """Test that old dummy toast handlers on sidebar navigation are completely eliminated."""
        dummy_phrases = [
            "Membuka modul Bahan Baku Masuk",
            "Membuka modul Pengiriman Baju",
            "Membuka denah rak",
            "Membuka audit"
        ]
        for phrase in dummy_phrases:
            self.assertNotIn(
                phrase,
                self.js_content,
                f"Old dummy toast handler found in dashboard.js: '{phrase}'"
            )

    def test_navigation_event_listeners_wired_to_switch_view(self):
        """Test that sidebar navs and quick action button are wired to switchView."""
        # Check nav click bindings to switchView
        nav_bindings = [
            ("navOverview", "viewOverview"),
            ("navInventory", "viewInventory"),
            ("navInbound", "viewInbound"),
            ("navOutbound", "viewOutbound"),
            ("navRacks", "viewZones"),
            ("navAudit", "viewAudit")
        ]
        for nav_id, target_view in nav_bindings:
            pattern = rf'{nav_id}.*switchView\([\'"]{target_view}[\'"]\)|switchView\([\'"]{target_view}[\'"]\).*{nav_id}'
            self.assertTrue(
                re.search(pattern, self.js_content, re.DOTALL),
                f"Navigation {nav_id} is not wired to switchView('{target_view}')"
            )

        # Quick action "Lihat di Tabel" in low stock banner must switch to viewInventory
        self.assertRegex(
            self.js_content,
            r'(?s)btnScrollToLowStock.*switchView\([\'"]viewInventory[\'"]\)|switchView\([\'"]viewInventory[\'"]\).*btnScrollToLowStock',
            "btnScrollToLowStock must call switchView('viewInventory')"
        )

if __name__ == "__main__":
    unittest.main()
