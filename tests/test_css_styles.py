import os
import re

def test_css_classes():
    css_path = os.path.join(os.path.dirname(__file__), "..", "style.css")
    assert os.path.exists(css_path), f"style.css not found at {css_path}"
    
    with open(css_path, "r", encoding="utf-8") as f:
        css = f.read()

    expected_selectors = [
        ".workspace-view",
        ".transaction-card",
        ".form-grid-2",
        ".discrepancy-pill",
        ".discrepancy-pill.match",
        ".discrepancy-pill.surplus",
        ".discrepancy-pill.deficit",
        ".zone-card.interactive",
        ".stock-status-alert",
        ".stock-preview-badge"
    ]
    for sel in expected_selectors:
        assert sel in css, f"Missing CSS selector: {sel}"

    # Verify curly braces balance
    open_brackets = css.count("{")
    close_brackets = css.count("}")
    assert open_brackets == close_brackets, f"Unbalanced CSS braces: {open_brackets} != {close_brackets}"
    
    print(f"PASS: All {len(expected_selectors)} CSS selectors and balanced braces ({open_brackets} braces) verified.")

if __name__ == "__main__":
    test_css_classes()
