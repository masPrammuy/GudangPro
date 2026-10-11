import os
import re
import unittest

class TestZonesAndAuditLogic(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.js_path = os.path.join(os.path.dirname(__file__), "..", "dashboard.js")
        cls.assertTrue(os.path.exists(cls.js_path), f"dashboard.js not found at {cls.js_path}")
        with open(cls.js_path, "r", encoding="utf-8") as f:
            cls.js_content = f.read()

    def test_functions_defined(self):
        """Test that all required functions for Zone and Audit are defined in dashboard.js."""
        required_functions = [
            "initZoneInteractions",
            "filterByZone",
            "updateZoneTelemetry",
            "renderAuditDropdown",
            "calculateAuditDiscrepancy",
            "syncAuditStock",
            "renderAuditLogs"
        ]
        for func in required_functions:
            self.assertRegex(
                self.js_content,
                rf'function\s+{func}\s*\(',
                f"{func} function is not defined in dashboard.js"
            )

    def test_zone_interaction_and_card_selection(self):
        """Test that initZoneInteractions attaches click listeners to zone cards and toggles active/selected state."""
        self.assertRegex(
            self.js_content,
            r'querySelectorAll\([\'"].*zone-card.*[\'"]\)',
            "initZoneInteractions must select zone cards"
        )
        self.assertRegex(
            self.js_content,
            r'(classList\.add\([\'"](active|selected)[\'"]\)|classList\.toggle\([\'"](active|selected)[\'"]\))',
            "initZoneInteractions must toggle or add active/selected class to clicked card"
        )
        self.assertRegex(
            self.js_content,
            r'filterByZone\(',
            "initZoneInteractions must call filterByZone when a card is clicked"
        )

    def test_filter_by_zone_logic_and_rendering(self):
        """Test that filterByZone filters inventory by zone key and renders into #zoneFilterTableBody."""
        self.assertIn(
            "zoneFilterTableBody",
            self.js_content,
            "#zoneFilterTableBody element must be referenced in dashboard.js"
        )
        self.assertIn(
            "currentZoneHeading",
            self.js_content,
            "#currentZoneHeading element must be updated in filterByZone"
        )
        self.assertRegex(
            self.js_content,
            r'location.*includes|location.*indexOf|category.*includes|category.*indexOf',
            "filterByZone must match item location or category against zone"
        )
        self.assertRegex(
            self.js_content,
            r'colspan=[\'"]?6[\'"]?',
            "zoneFilterTableBody empty state must span 6 columns"
        )

    def test_zone_telemetry_dynamic_calculation(self):
        """Test that updateZoneTelemetry calculates zone totals and updates meters/bars in #viewOverview and #viewZones."""
        self.assertRegex(
            self.js_content,
            r'(zoneAStockDisplay|zone-bar-fill|zone-meter)',
            "updateZoneTelemetry must update zone capacity displays or bars"
        )
        self.assertRegex(
            self.js_content,
            r'viewOverview|viewZones',
            "updateZoneTelemetry must target zone cards across views"
        )

    def test_render_audit_dropdown_and_item_selection(self):
        """Test that renderAuditDropdown populates #auditItemSelect and updates #auditSystemStock upon selection."""
        self.assertIn(
            "auditItemSelect",
            self.js_content,
            "#auditItemSelect element must be referenced in dashboard.js"
        )
        self.assertIn(
            "auditSystemStock",
            self.js_content,
            "#auditSystemStock element must be referenced in dashboard.js"
        )
        self.assertRegex(
            self.js_content,
            r'auditItemSelect.*addEventListener\([\'"]change[\'"]|auditItemSelect\.onchange',
            "auditItemSelect must have a change event listener wired"
        )

    def test_audit_discrepancy_calculation_and_badges(self):
        """Test calculateAuditDiscrepancy logic for matching, surplus, and deficit states."""
        self.assertIn(
            "auditPhysicalCount",
            self.js_content,
            "#auditPhysicalCount element must be referenced in dashboard.js"
        )
        self.assertIn(
            "auditDiscrepancyBadge",
            self.js_content,
            "#auditDiscrepancyBadge element must be referenced in dashboard.js"
        )
        self.assertIn(
            "btnSyncAuditStock",
            self.js_content,
            "#btnSyncAuditStock element must be referenced in dashboard.js"
        )
        self.assertIn(
            "Masukkan hitungan fisik",
            self.js_content,
            "calculateAuditDiscrepancy must prompt 'Masukkan hitungan fisik' when input is empty"
        )
        self.assertIn(
            "discrepancy-pill match",
            self.js_content,
            "calculateAuditDiscrepancy must use class 'discrepancy-pill match' for zero discrepancy"
        )
        self.assertIn(
            "discrepancy-pill surplus",
            self.js_content,
            "calculateAuditDiscrepancy must use class 'discrepancy-pill surplus' for positive discrepancy"
        )
        self.assertIn(
            "discrepancy-pill deficit",
            self.js_content,
            "calculateAuditDiscrepancy must use class 'discrepancy-pill deficit' for negative discrepancy"
        )

    def test_sync_audit_stock_mutation_and_persistence(self):
        """Test syncAuditStock stock mutation, audit log creation, and localStorage persistence."""
        self.assertRegex(
            self.js_content,
            r'gp_apparel_audit_logs.*setItem|setItem.*gp_apparel_audit_logs',
            "Audit logs must be saved to localStorage under gp_apparel_audit_logs"
        )
        self.assertIn(
            "gp_apparel_inventory",
            self.js_content,
            "Inventory must be updated and saved on audit sync"
        )
        self.assertRegex(
            self.js_content,
            r'item\.qty\s*=\s*(physicalVal|count|physicalStock)',
            "syncAuditStock must update item.qty with physical count value"
        )
        self.assertIn(
            "Audit berhasil! Stok",
            self.js_content,
            "syncAuditStock must show success toast starting with 'Audit berhasil! Stok'"
        )

    def test_render_audit_logs_table(self):
        """Test renderAuditLogs populates #auditTableBody with history and clean empty state."""
        self.assertIn(
            "auditTableBody",
            self.js_content,
            "#auditTableBody element must be referenced in dashboard.js"
        )
        self.assertIn(
            "Belum ada riwayat stock opname.",
            self.js_content,
            "renderAuditLogs must show empty state text 'Belum ada riwayat stock opname.'"
        )
        self.assertRegex(
            self.js_content,
            r'colspan=[\'"]?7[\'"]?',
            "auditTableBody empty state must span 7 columns"
        )

    def test_event_wiring_and_view_reactivity(self):
        """Test event listeners wired in bindEvents and view reactivity in switchView."""
        self.assertRegex(
            self.js_content,
            r'(?s)btnSyncAuditStock.*addEventListener\([\'"]click[\'"].*syncAuditStock|syncAuditStock.*btnSyncAuditStock',
            "#btnSyncAuditStock click event must be wired to syncAuditStock"
        )
        self.assertRegex(
            self.js_content,
            r'(?s)auditPhysicalCount.*addEventListener\([\'"]input[\'"].*calculateAuditDiscrepancy|calculateAuditDiscrepancy.*auditPhysicalCount',
            "#auditPhysicalCount input event must be wired to calculateAuditDiscrepancy"
        )
        self.assertRegex(
            self.js_content,
            r'(?s)viewZones.*(updateZoneTelemetry|filterByZone)|(updateZoneTelemetry|filterByZone).*viewZones',
            "switchView must update zone telemetry/filters when switching to viewZones"
        )
        self.assertRegex(
            self.js_content,
            r'(?s)viewAudit.*(renderAuditDropdown|renderAuditLogs)|(renderAuditDropdown|renderAuditLogs).*viewAudit',
            "switchView must re-render audit dropdown/logs when switching to viewAudit"
        )

if __name__ == "__main__":
    unittest.main()
