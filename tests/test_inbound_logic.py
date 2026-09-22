import os
import re
import unittest

class TestInboundLogic(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.js_path = os.path.join(os.path.dirname(__file__), "..", "dashboard.js")
        cls.assertTrue(os.path.exists(cls.js_path), f"dashboard.js not found at {cls.js_path}")
        with open(cls.js_path, "r", encoding="utf-8") as f:
            cls.js_content = f.read()

    def test_functions_defined(self):
        """Test that handleInboundSubmit, renderInboundLogs, and renderInboundDropdown are defined."""
        self.assertRegex(
            self.js_content,
            r'function\s+renderInboundDropdown\s*\(',
            "renderInboundDropdown function is not defined in dashboard.js"
        )
        self.assertRegex(
            self.js_content,
            r'function\s+renderInboundLogs\s*\(',
            "renderInboundLogs function is not defined in dashboard.js"
        )
        self.assertRegex(
            self.js_content,
            r'function\s+handleInboundSubmit\s*\(',
            "handleInboundSubmit function is not defined in dashboard.js"
        )

    def test_inbound_dropdown_logic(self):
        """Test that renderInboundDropdown populates #inboundItemSelect with SKU, name, and stock."""
        self.assertIn(
            "inboundItemSelect",
            self.js_content,
            "#inboundItemSelect element should be referenced in dashboard.js"
        )
        # Check that options format contains SKU and Stock indication
        self.assertRegex(
            self.js_content,
            r'Stok:\s*[\'"]?\s*\+?\s*item\.qty|item\.qty\s*\+\s*[\'"]\s*(Roll|Pcs|\w+)',
            "renderInboundDropdown must format option text showing stock quantity and unit"
        )

    def test_inbound_logs_table_rendering(self):
        """Test that renderInboundLogs handles #inboundTableBody with 7 columns and empty state."""
        self.assertIn(
            "inboundTableBody",
            self.js_content,
            "#inboundTableBody must be referenced in dashboard.js"
        )
        # Empty state row verification
        self.assertIn(
            "Belum ada riwayat penerimaan bahan.",
            self.js_content,
            "renderInboundLogs must display empty state message when logs list is empty"
        )
        self.assertRegex(
            self.js_content,
            r'colspan=[\'"]?7[\'"]?',
            "Empty state row must span 7 columns"
        )

    def test_po_number_generation_and_mutation(self):
        """Test auto PO generation pattern (PO-TX-...) and inventory stock mutation."""
        # PO number pattern
        self.assertRegex(
            self.js_content,
            r'PO-TX-',
            "PO generation must use prefix PO-TX-"
        )
        # Stock increment: item.qty += qty
        self.assertRegex(
            self.js_content,
            r'item\.qty\s*\+=\s*qty|item\.qty\s*=\s*item\.qty\s*\+\s*qty',
            "handleInboundSubmit must increment item quantity"
        )
        # Status re-evaluation
        self.assertIn(
            "🚨 Stok Habis",
            self.js_content,
            "Item status re-evaluation must include '🚨 Stok Habis'"
        )
        self.assertIn(
            "⚠️ Stok Minimum!",
            self.js_content,
            "Item status re-evaluation must include '⚠️ Stok Minimum!'"
        )

    def test_inbound_storage_persistence(self):
        """Test that gp_apparel_inbound_logs and gp_apparel_inventory are updated in storage."""
        self.assertRegex(
            self.js_content,
            r'gp_apparel_inbound_logs.*setItem|setItem.*gp_apparel_inbound_logs',
            "Inbound logs must be persisted to localStorage under gp_apparel_inbound_logs"
        )
        self.assertIn(
            "saveInventory",
            self.js_content,
            "saveInventory must be called to persist updated inventory"
        )

    def test_inbound_event_listener_and_reactivity(self):
        """Test form event listener wiring, view switcher reactivity, and success toast message."""
        # Form listener wiring
        self.assertRegex(
            self.js_content,
            r'(?s)inboundForm.*addEventListener\([\'"]submit[\'"].*handleInboundSubmit|handleInboundSubmit.*inboundForm',
            "#inboundForm must be wired with handleInboundSubmit"
        )
        # Success feedback toast
        self.assertIn(
            "Bahan masuk berhasil dicatat! Stok",
            self.js_content,
            "Success toast must contain 'Bahan masuk berhasil dicatat! Stok'"
        )
        # Reactivity in switchView
        self.assertRegex(
            self.js_content,
            r'(?s)viewInbound.*renderInbound|renderInbound.*viewInbound',
            "switchView must re-render inbound dropdown/logs when switching to viewInbound"
        )

if __name__ == "__main__":
    unittest.main()
