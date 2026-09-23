import os
import re
import unittest

class TestOutboundLogic(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.js_path = os.path.join(os.path.dirname(__file__), "..", "dashboard.js")
        cls.assertTrue(os.path.exists(cls.js_path), f"dashboard.js not found at {cls.js_path}")
        with open(cls.js_path, "r", encoding="utf-8") as f:
            cls.js_content = f.read()

    def test_functions_defined(self):
        """Test that handleOutboundSubmit, renderOutboundLogs, and renderOutboundDropdown are defined."""
        self.assertRegex(
            self.js_content,
            r'function\s+renderOutboundDropdown\s*\(',
            "renderOutboundDropdown function is not defined in dashboard.js"
        )
        self.assertRegex(
            self.js_content,
            r'function\s+renderOutboundLogs\s*\(',
            "renderOutboundLogs function is not defined in dashboard.js"
        )
        self.assertRegex(
            self.js_content,
            r'function\s+handleOutboundSubmit\s*\(',
            "handleOutboundSubmit function is not defined in dashboard.js"
        )

    def test_outbound_dropdown_and_stock_hint(self):
        """Test that renderOutboundDropdown populates #outboundItemSelect and updates #outboundStockHint."""
        self.assertIn(
            "outboundItemSelect",
            self.js_content,
            "#outboundItemSelect element must be referenced in dashboard.js"
        )
        self.assertIn(
            "outboundStockHint",
            self.js_content,
            "#outboundStockHint element must be referenced in dashboard.js"
        )
        self.assertRegex(
            self.js_content,
            r'Stok:\s*[\'"]?\s*\+?\s*item\.qty|item\.qty\s*\+\s*[\'"]\s*(Roll|Pcs|\w+)',
            "renderOutboundDropdown must format option text showing available stock"
        )

    def test_realtime_over_shipping_validation(self):
        """Test real-time validation preventing over-shipping with warnings and button disabling."""
        # Must check if qty exceeds item stock
        self.assertRegex(
            self.js_content,
            r'qty\s*>\s*currentItem\.qty|qty\s*>\s*item\.qty',
            "Real-time validation must compare requested qty against current item stock"
        )
        # Warning text when over-shipping
        self.assertIn(
            "🚨 Stok tidak mencukupi!",
            self.js_content,
            "Must show '🚨 Stok tidak mencukupi!' warning in outboundStockHint"
        )
        # Danger class or styling
        self.assertIn(
            "is-invalid",
            self.js_content,
            "Must apply 'is-invalid' class or styling to #outboundQty on over-shipping"
        )
        # Submit button disable state
        self.assertRegex(
            self.js_content,
            r'disabled\s*=\s*true',
            "Must set disabled = true on submit button when over-shipping is detected"
        )

    def test_outbound_logs_table_rendering(self):
        """Test that renderOutboundLogs populates #outboundTableBody and shows empty state when logs are empty."""
        self.assertIn(
            "outboundTableBody",
            self.js_content,
            "#outboundTableBody element must be referenced in dashboard.js"
        )
        self.assertIn(
            "Belum ada riwayat pengiriman baju jadi.",
            self.js_content,
            "renderOutboundLogs must show empty state text 'Belum ada riwayat pengiriman baju jadi.'"
        )
        self.assertRegex(
            self.js_content,
            r'colspan=[\'"]?7[\'"]?',
            "Empty state row must span 7 columns"
        )

    def test_do_number_generation_and_mutation(self):
        """Test DO number generation (DO-GP-...) and stock deduction logic."""
        # Prefix DO-GP-
        self.assertRegex(
            self.js_content,
            r'DO-GP-',
            "DO generation must use prefix 'DO-GP-'"
        )
        # Stock deduction: item.qty -= qty
        self.assertRegex(
            self.js_content,
            r'item\.qty\s*-=\s*qty|item\.qty\s*=\s*item\.qty\s*-\s*qty',
            "handleOutboundSubmit must deduct qty from item inventory"
        )
        # Anti-overshipping server/submit-level validation error
        self.assertIn(
            "Stok tidak mencukupi untuk pengiriman!",
            self.js_content,
            "Must show toast error 'Stok tidak mencukupi untuk pengiriman!' if qty > stock on submit"
        )

    def test_outbound_storage_and_kpi_persistence(self):
        """Test persistence to gp_apparel_outbound_logs and update of statOutboundToday."""
        self.assertRegex(
            self.js_content,
            r'gp_apparel_outbound_logs.*setItem|setItem.*gp_apparel_outbound_logs',
            "Outbound logs must be saved to localStorage under gp_apparel_outbound_logs"
        )
        self.assertIn(
            "saveInventory",
            self.js_content,
            "saveInventory must be called to persist updated inventory"
        )
        self.assertIn(
            "statOutboundToday",
            self.js_content,
            "statOutboundToday KPI stat must be updated in dashboard.js"
        )

    def test_outbound_event_listener_and_reactivity(self):
        """Test form event listener wiring, view switcher reactivity, and success feedback."""
        self.assertRegex(
            self.js_content,
            r'(?s)outboundForm.*addEventListener\([\'"]submit[\'"].*handleOutboundSubmit|handleOutboundSubmit.*outboundForm',
            "#outboundForm must be wired with handleOutboundSubmit"
        )
        self.assertIn(
            "berhasil diterbitkan! Stok",
            self.js_content,
            "Success toast must contain 'berhasil diterbitkan! Stok'"
        )
        self.assertRegex(
            self.js_content,
            r'(?s)viewOutbound.*renderOutbound|renderOutbound.*viewOutbound',
            "switchView must re-render outbound dropdown/logs when switching to viewOutbound"
        )

if __name__ == "__main__":
    unittest.main()
