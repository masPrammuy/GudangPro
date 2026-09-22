import os
import re
import unittest
from html.parser import HTMLParser

class DOMStructureParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.elements_by_id = {}
        self.zone_cards = []

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        elem_id = attrs_dict.get("id")
        if elem_id:
            self.elements_by_id[elem_id] = {
                "tag": tag,
                "attrs": attrs_dict
            }
        
        # Check zone cards with data-zone
        classes = attrs_dict.get("class", "").split()
        if "zone-card" in classes and "interactive" in classes:
            zone = attrs_dict.get("data-zone")
            if zone:
                self.zone_cards.append(zone)

def test_dashboard_views_and_forms():
    dashboard_path = os.path.join(os.path.dirname(__file__), "..", "dashboard.html")
    with open(dashboard_path, "r", encoding="utf-8") as f:
        html = f.read()

    # 1. Expected Workspace Views
    expected_views = [
        "viewOverview", "viewInventory", "viewInbound",
        "viewOutbound", "viewZones", "viewAudit"
    ]
    for v in expected_views:
        assert f'id="{v}"' in html, f"Missing view container: {v}"
        assert f'class="workspace-view' in html, f"Missing class workspace-view on container: {v}"

    # 2. Expected Sidebar Nav IDs
    expected_navs = [
        "navOverview", "navInventory", "navInbound",
        "navOutbound", "navRacks", "navAudit"
    ]
    for n in expected_navs:
        assert f'id="{n}"' in html, f"Missing sidebar nav id: {n}"

    # 3. Expected Inbound elements
    inbound_elems = [
        "inboundForm", "inboundItemSelect", "inboundSupplier",
        "inboundLot", "inboundQty", "inboundDate", "inboundNotes",
        "inboundTable", "inboundTableBody"
    ]
    for elem in inbound_elems:
        assert f'id="{elem}"' in html, f"Missing Inbound element: {elem}"

    # 4. Expected Outbound elements
    outbound_elems = [
        "outboundForm", "outboundItemSelect", "outboundStockHint",
        "outboundRecipient", "outboundCourier", "outboundQty",
        "outboundDate", "btnSubmitOutbound", "outboundTable", "outboundTableBody"
    ]
    for elem in outbound_elems:
        assert f'id="{elem}"' in html, f"Missing Outbound element: {elem}"

    # 5. Expected Zones elements
    zones_elems = [
        "zoneFilterTable", "zoneFilterTableBody", "currentZoneHeading"
    ]
    for elem in zones_elems:
        assert f'id="{elem}"' in html, f"Missing Zones element: {elem}"

    # 6. Expected Audit elements
    audit_elems = [
        "auditItemSelect", "auditSystemStock", "auditPhysicalCount",
        "auditDiscrepancyBadge", "auditReason", "btnSyncAuditStock",
        "auditTable", "auditTableBody"
    ]
    for elem in audit_elems:
        assert f'id="{elem}"' in html, f"Missing Audit element: {elem}"

    # 7. Parse DOM with HTMLParser for deeper checks
    parser = DOMStructureParser()
    parser.feed(html)

    # Verify all expected IDs exist in parsed DOM
    all_required_ids = (
        expected_views + expected_navs + inbound_elems + 
        outbound_elems + zones_elems + audit_elems
    )
    for rid in all_required_ids:
        assert rid in parser.elements_by_id, f"Parsed DOM missing id: {rid}"

    # Verify interactive zone cards for zones A, B, C, D
    for z in ["A", "B", "C", "D"]:
        assert z in parser.zone_cards, f"Missing interactive zone card for zone {z}"

    # Verify viewOverview has active class
    overview_classes = parser.elements_by_id["viewOverview"]["attrs"].get("class", "")
    assert "active" in overview_classes, "viewOverview should have active class"

    print("PASS: All DOM view containers, sidebar navs, and form/table IDs verified successfully.")

if __name__ == "__main__":
    test_dashboard_views_and_forms()
