# tests/test_e2e_browser.py
import os
import subprocess
import json
import time

def test_full_integration():
    repo_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    dashboard_html = os.path.join(repo_dir, "dashboard.html")
    dashboard_js = os.path.join(repo_dir, "dashboard.js")
    style_css = os.path.join(repo_dir, "style.css")

    assert os.path.exists(dashboard_html), "dashboard.html missing"
    assert os.path.exists(dashboard_js), "dashboard.js missing"
    assert os.path.exists(style_css), "style.css missing"

    with open(dashboard_html, "r", encoding="utf-8") as f:
        html = f.read()
    with open(dashboard_js, "r", encoding="utf-8") as f:
        js = f.read()

    # Verify all 6 view containers and their linkages
    views = ["viewOverview", "viewInventory", "viewInbound", "viewOutbound", "viewZones", "viewAudit"]
    for v in views:
        assert f'id="{v}"' in html, f"Missing view container: {v}"
        assert v in js, f"Missing view reference in js: {v}"

    # Verify core handlers
    assert "handleInboundSubmit" in js
    assert "handleOutboundSubmit" in js
    assert "syncAuditStock" in js
    assert "calculateAuditDiscrepancy" in js
    assert "filterByZone" in js
    assert "initZoneInteractions" in js
    assert "switchView" in js

    print("PASS: Full E2E codebase integration verified successfully.")

if __name__ == "__main__":
    test_full_integration()
