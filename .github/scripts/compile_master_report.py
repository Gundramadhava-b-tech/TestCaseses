#!/usr/bin/env python3
"""
Master Report & Excel Generator for AeroDiag OSA Diagnostic System CI/CD Pipeline
Analyzes test results, build outputs, and security scans to generate:
- master_report.html
- master_report.xlsx (using openpyxl)
- GITHUB_STEP_SUMMARY Markdown
"""

import json
import os
import sys
import datetime
from pathlib import Path

# Force stdout/stderr to UTF-8 for cross-platform unicode safety
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8')

def parse_flutter_test_json(json_path):
    """Parses Flutter test runner JSON output to extract exact counts and details."""
    total = 0
    passed = 0
    failed = 0
    skipped = 0
    duration_ms = 0
    test_cases = []
    
    if not os.path.exists(json_path):
        return {
            "total": 0, "passed": 0, "failed": 0, "skipped": 0, "duration": "0s",
            "status": "NO_TESTS_FOUND", "cases": []
        }

    tests_map = {}
    
    with open(json_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                data = json.loads(line.strip())
                event_type = data.get("type")
                
                if event_type == "testStart":
                    test_info = data.get("test", {})
                    test_id = test_info.get("id")
                    test_name = test_info.get("name", "Unknown Test")
                    if not test_name.startswith("loading "):
                        tests_map[test_id] = {
                            "id": test_id,
                            "name": test_name,
                            "startTime": data.get("time", 0),
                            "result": "unknown",
                            "error": ""
                        }
                elif event_type == "error":
                    test_id = data.get("testID")
                    if test_id in tests_map:
                        tests_map[test_id]["error"] = data.get("error", "Failed")
                elif event_type == "testDone":
                    test_id = data.get("testID")
                    if test_id in tests_map:
                        res = data.get("result", "success")
                        is_hidden = data.get("hidden", False)
                        if is_hidden:
                            del tests_map[test_id]
                            continue
                        
                        duration = data.get("time", 0) - tests_map[test_id]["startTime"]
                        tests_map[test_id]["duration"] = f"{duration}ms"
                        duration_ms += duration
                        
                        if data.get("skipped", False):
                            tests_map[test_id]["result"] = "SKIPPED"
                            skipped += 1
                        elif res == "success":
                            tests_map[test_id]["result"] = "PASSED"
                            passed += 1
                        else:
                            tests_map[test_id]["result"] = "FAILED"
                            failed += 1
                        total += 1
                        test_cases.append(tests_map[test_id])
            except json.JSONDecodeError:
                continue

    status = "PASSED" if failed == 0 and total > 0 else ("FAILED" if failed > 0 else "SKIPPED")
    return {
        "total": total,
        "passed": passed,
        "failed": failed,
        "skipped": skipped,
        "duration": f"{round(duration_ms / 1000, 2)}s",
        "status": status,
        "cases": test_cases
    }

def generate_excel_report(output_file, test_results, pipeline_jobs):
    """Generates a structured Excel spreadsheet using openpyxl."""
    try:
        import openpyxl
        
        wb = openpyxl.Workbook()
        ws_summary = wb.active
        ws_summary.title = "Pipeline Summary"
        
        ws_summary.append(["AeroDiag CI/CD Master Verification Report"])
        ws_summary.append(["Generated At:", datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")])
        ws_summary.append(["Commit SHA:", os.getenv("GITHUB_SHA", "Local-Run")])
        ws_summary.append(["Branch:", os.getenv("GITHUB_REF_NAME", "main")])
        ws_summary.append([])
        
        ws_summary.append(["Stage / Job Name", "Status", "Details"])
        for job_name, status, details in pipeline_jobs:
            ws_summary.append([job_name, status, details])
            
        ws_cases = wb.create_sheet(title="Test Cases")
        ws_cases.append(["Test ID", "Test Suite", "Test Name", "Platform", "Status", "Duration", "Error Message"])
        
        for case in test_results.get("cases", []):
            ws_cases.append([
                case.get("id"),
                "Flutter Widget/Unit Test",
                case.get("name"),
                "Flutter / Dart",
                case.get("result"),
                case.get("duration", "0ms"),
                case.get("error", "")
            ])
            
        wb.save(output_file)
        print(f"[SUCCESS] Excel report saved to {output_file}")
    except ImportError:
        print("[WARNING] openpyxl not installed. Creating CSV fallback...")
        csv_file = output_file.replace(".xlsx", ".csv")
        with open(csv_file, "w", encoding="utf-8") as f:
            f.write("Stage,Status,Details\n")
            for job_name, status, details in pipeline_jobs:
                f.write(f'"{job_name}","{status}","{details}"\n')
        print(f"[SUCCESS] CSV fallback report saved to {csv_file}")

def generate_html_report(output_file, test_results, pipeline_jobs):
    """Generates a modern, responsive HTML report dashboard."""
    sha = os.getenv("GITHUB_SHA", "Local Execution")[:7]
    ref = os.getenv("GITHUB_REF_NAME", "main")
    run_id = os.getenv("GITHUB_RUN_ID", "N/A")
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    total = test_results["total"]
    passed = test_results["passed"]
    failed = test_results["failed"]
    skipped = test_results["skipped"]
    pass_rate = f"{round((passed / total * 100), 1)}%" if total > 0 else "N/A"

    job_rows = ""
    for name, status, details in pipeline_jobs:
        badge_cls = "status-pass" if status in ["PASSED", "SUCCESS"] else ("status-fail" if status == "FAILED" else "status-warn")
        job_rows += f"""
        <tr>
            <td><strong>{name}</strong></td>
            <td><span class="badge {badge_cls}">{status}</span></td>
            <td>{details}</td>
        </tr>
        """

    case_rows = ""
    for c in test_results.get("cases", []):
        res = c.get("result", "UNKNOWN")
        cls = "status-pass" if res == "PASSED" else ("status-fail" if res == "FAILED" else "status-warn")
        case_rows += f"""
        <tr>
            <td>{c.get('id')}</td>
            <td>{c.get('name')}</td>
            <td><span class="badge {cls}">{res}</span></td>
            <td>{c.get('duration', 'N/A')}</td>
            <td>{c.get('error', '-')}</td>
        </tr>
        """

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AeroDiag CI/CD Master Report</title>
    <style>
        :root {{
            --bg: #0f172a;
            --card-bg: #1e293b;
            --text: #f8fafc;
            --text-muted: #94a3b8;
            --accent: #38bdf8;
            --pass: #22c55e;
            --fail: #ef4444;
            --warn: #eab308;
            --border: #334155;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg);
            color: var(--text);
            margin: 0;
            padding: 30px;
        }}
        .container {{ max-width: 1200px; margin: 0 auto; }}
        header {{ border-bottom: 1px solid var(--border); padding-bottom: 20px; margin-bottom: 30px; }}
        h1 {{ margin: 0 0 10px 0; color: var(--accent); }}
        .meta {{ color: var(--text-muted); font-size: 0.9em; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }}
        .card {{ background: var(--card-bg); border: 1px solid var(--border); padding: 20px; border-radius: 8px; }}
        .card .value {{ font-size: 2em; font-weight: bold; margin-top: 5px; }}
        table {{ width: 100%; border-collapse: collapse; background: var(--card-bg); border-radius: 8px; overflow: hidden; margin-bottom: 30px; }}
        th, td {{ padding: 12px 16px; text-align: left; border-bottom: 1px solid var(--border); }}
        th {{ background: #0f172a; color: var(--text-muted); font-weight: 600; }}
        .badge {{ padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 0.8em; display: inline-block; }}
        .status-pass {{ background: rgba(34, 197, 94, 0.2); color: var(--pass); border: 1px solid var(--pass); }}
        .status-fail {{ background: rgba(239, 68, 68, 0.2); color: var(--fail); border: 1px solid var(--fail); }}
        .status-warn {{ background: rgba(234, 179, 8, 0.2); color: var(--warn); border: 1px solid var(--warn); }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>AeroDiag OSA Diagnostic System — CI/CD Master Report</h1>
            <div class="meta">
                Run ID: #{run_id} | Commit: <code>{sha}</code> | Branch: <code>{ref}</code> | Time: {timestamp}
            </div>
        </header>

        <div class="grid">
            <div class="card">
                <div>Total Unit Tests</div>
                <div class="value">{total}</div>
            </div>
            <div class="card">
                <div>Passed</div>
                <div class="value" style="color: var(--pass);">{passed}</div>
            </div>
            <div class="card">
                <div>Failed</div>
                <div class="value" style="color: var(--fail);">{failed}</div>
            </div>
            <div class="card">
                <div>Pass Rate</div>
                <div class="value" style="color: var(--accent);">{pass_rate}</div>
            </div>
        </div>

        <h2>Pipeline Stage Verification</h2>
        <table>
            <thead>
                <tr>
                    <th>Pipeline Stage</th>
                    <th>Status</th>
                    <th>Execution Details</th>
                </tr>
            </thead>
            <tbody>
                {job_rows}
            </tbody>
        </table>

        {"<h2>Test Suite Case Details</h2>" if case_rows else ""}
        {"<table><thead><tr><th>ID</th><th>Test Name</th><th>Status</th><th>Duration</th><th>Error</th></tr></thead><tbody>" + case_rows + "</tbody></table>" if case_rows else ""}
    </div>
</body>
</html>
"""

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"[SUCCESS] Master HTML report saved to {output_file}")

def main():
    print("[INFO] Compiling Master Verification Reports...")
    
    test_json_path = os.getenv("TEST_RESULTS_JSON", "test_results.json")
    test_results = parse_flutter_test_json(test_json_path)

    pipeline_jobs = [
        ("Static Analysis & Linting", os.getenv("STAGE_ANALYSIS_STATUS", "PASSED"), "flutter analyze & formatting validation"),
        ("Unit & Widget Tests", test_results["status"], f"{test_results['passed']}/{test_results['total']} passed in {test_results['duration']}"),
        ("Flutter Web Build Verification", os.getenv("STAGE_WEB_BUILD_STATUS", "PASSED"), "flutter build web --release"),
        ("Android APK Build Verification", os.getenv("STAGE_APK_BUILD_STATUS", "PASSED"), "flutter build apk --debug"),
        ("Security & Dependency Audit", os.getenv("STAGE_SECURITY_STATUS", "PASSED"), "Dependency audit & secret scanning"),
        ("Deployment Readiness", os.getenv("STAGE_DEPLOY_STATUS", "PASSED"), "Environment & Firebase build config validation"),
    ]

    out_dir = Path("build/reports")
    out_dir.mkdir(parents=True, exist_ok=True)
    
    html_path = out_dir / "master_report.html"
    excel_path = out_dir / "master_report.xlsx"

    generate_html_report(str(html_path), test_results, pipeline_jobs)
    generate_excel_report(str(excel_path), test_results, pipeline_jobs)

    summary_path = os.getenv("GITHUB_STEP_SUMMARY")
    if summary_path:
        markdown_summary = f"""# AeroDiag CI/CD Verification Summary

| Metric | Value |
| :--- | :--- |
| **Total Unit/Widget Tests** | {test_results['total']} |
| **Passed** | {test_results['passed']} |
| **Failed** | {test_results['failed']} |
| **Skipped** | {test_results['skipped']} |
| **Execution Duration** | {test_results['duration']} |

### Pipeline Stage Breakdown
| Stage Name | Status | Details |
| :--- | :---: | :--- |
"""
        for name, status, details in pipeline_jobs:
            badge = "PASSED" if status in ["PASSED", "SUCCESS"] else ("FAILED" if status == "FAILED" else "WARNING")
            markdown_summary += f"| **{name}** | {badge} | {details} |\n"
            
        with open(summary_path, "a", encoding="utf-8") as f:
            f.write(markdown_summary)

if __name__ == "__main__":
    main()
