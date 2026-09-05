#!/usr/bin/env bash

set -euo pipefail

report_dir="${1:-reports}"
results_file="$report_dir/results.tsv"
scenarios_file="$report_dir/scenarios.tsv"
html_file="$report_dir/index.html"

mkdir -p "$report_dir"
touch "$results_file" "$scenarios_file"

escape_html() {
  printf '%s' "$1" | sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\&#39;/g"
}

total=0
passed=0
failed=0
while IFS=$'\t' read -r scenario_id category title status expected actual; do
  [[ -z "$scenario_id" ]] && continue
  total=$((total + 1))
  if [[ "$status" == "PASS" ]]; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi
done < "$scenarios_file"

run_number="${GITHUB_RUN_NUMBER:-local}"
run_sha="${GITHUB_SHA:-local checkout}"
run_ref="${GITHUB_REF_NAME:-local}"
run_date="$(date -u '+%Y-%m-%d %H:%M UTC')"
overall_status="PASS"
overall_class="pass"
if [[ "$failed" -gt 0 || "$total" -eq 0 ]]; then
  overall_status="FAIL"
  overall_class="fail"
fi

cat > "$html_file" <<HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#101827">
  <title>Database Test Report | Run #$(escape_html "$run_number")</title>
  <style>
    :root {
      color-scheme: dark;
      --ink: #edf4ff;
      --muted: #9aabc1;
      --line: rgba(157, 178, 207, .18);
      --panel: rgba(24, 38, 60, .78);
      --cyan: #69e4d0;
      --red: #ff8a8a;
      font-family: "Avenir Next", Avenir, "Segoe UI", sans-serif;
      background: #0b1320;
    }
    * { box-sizing: border-box; }
    body { margin: 0; min-width: 320px; color: var(--ink); background: radial-gradient(circle at 90% 0%, #203b56 0, transparent 38%), linear-gradient(145deg, #0b1320 0%, #111e31 55%, #132b38 100%); }
    main { width: min(1160px, 100%); margin: 0 auto; padding: clamp(24px, 5vw, 70px) clamp(16px, 4vw, 42px) 70px; }
    .eyebrow { margin: 0 0 12px; color: var(--cyan); font-size: .75rem; font-weight: 700; letter-spacing: .18em; text-transform: uppercase; }
    h1 { max-width: 700px; margin: 0; font-size: clamp(2.2rem, 6vw, 4.8rem); line-height: .98; letter-spacing: -.04em; }
    .intro { max-width: 660px; margin: 20px 0 28px; color: var(--muted); font-size: clamp(1rem, 2vw, 1.15rem); line-height: 1.6; }
    .run-meta { display: flex; flex-wrap: wrap; gap: 8px 18px; color: var(--muted); font-size: .86rem; }
    .run-meta code { color: var(--ink); }
    .hero { display: flex; align-items: end; justify-content: space-between; gap: 24px; margin-bottom: 38px; }
    .verdict { flex: 0 0 auto; padding: 18px 22px; border: 1px solid var(--line); border-radius: 16px; background: var(--panel); text-align: center; box-shadow: 0 20px 60px rgba(0,0,0,.22); }
    .verdict strong { display: block; font-size: 1.5rem; letter-spacing: .08em; }
    .verdict span { display: block; margin-top: 5px; color: var(--muted); font-size: .75rem; text-transform: uppercase; }
    .pass { color: var(--cyan); }
    .fail { color: var(--red); }
    .section-label { margin: 0 0 14px; color: var(--muted); font-size: .75rem; font-weight: 700; letter-spacing: .14em; text-transform: uppercase; }
    .metrics { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 42px; }
    .metric { padding: 20px; border: 1px solid var(--line); border-radius: 14px; background: var(--panel); }
    .metric strong { display: block; font-size: clamp(1.8rem, 4vw, 2.5rem); letter-spacing: -.04em; }
    .metric span { color: var(--muted); font-size: .85rem; }
    .scenario-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
    .scenario { position: relative; overflow: hidden; padding: 20px; border: 1px solid var(--line); border-radius: 16px; background: linear-gradient(145deg, rgba(25,40,63,.9), rgba(17,29,46,.78)); }
    .scenario::before { position: absolute; inset: 0 auto 0 0; width: 4px; background: var(--cyan); content: ""; }
    .scenario.is-fail::before { background: var(--red); }
    .scenario-top { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 14px; }
    .scenario-id { color: var(--cyan); font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: .82rem; font-weight: 700; }
    .scenario.is-fail .scenario-id { color: var(--red); }
    .badge { padding: 5px 9px; border: 1px solid currentColor; border-radius: 999px; font-size: .7rem; font-weight: 800; letter-spacing: .08em; }
    .scenario h3 { margin: 0 0 14px; font-size: 1.08rem; }
    .category { margin: 0 0 16px; color: var(--muted); font-size: .8rem; }
    .detail { margin: 0; padding-top: 11px; border-top: 1px solid var(--line); color: var(--muted); font-size: .86rem; line-height: 1.5; }
    .detail + .detail { margin-top: 10px; }
    .detail strong { display: block; margin-bottom: 3px; color: var(--ink); font-size: .7rem; letter-spacing: .1em; text-transform: uppercase; }
    details { margin-top: 34px; border: 1px solid var(--line); border-radius: 14px; background: rgba(11,19,32,.55); }
    summary { padding: 17px 20px; cursor: pointer; color: var(--muted); font-size: .9rem; font-weight: 700; }
    pre { margin: 0; padding: 0 20px 20px; overflow-x: auto; color: #c5d2e5; font: .8rem/1.6 ui-monospace, SFMono-Regular, Menlo, monospace; white-space: pre-wrap; }
    @media (max-width: 700px) {
      .hero { display: block; }
      .verdict { width: 100%; margin-top: 24px; }
      .metrics, .scenario-grid { grid-template-columns: 1fr; }
      .scenario { padding: 18px; }
    }
  </style>
</head>
<body>
<main>
  <section class="hero">
    <div>
      <p class="eyebrow">PostgreSQL quality signal</p>
      <h1>Database test report</h1>
      <p class="intro">A scenario-level view of data validation, business rules, referential integrity, duplicate detection, and reconciliation.</p>
      <div class="run-meta"><span>Run <code>#$(escape_html "$run_number")</code></span><span>Ref <code>$(escape_html "$run_ref")</code></span><span>Commit <code>$(escape_html "${run_sha:0:7}")</code></span><span>$(escape_html "$run_date")</span></div>
    </div>
    <div class="verdict $overall_class"><strong>$overall_status</strong><span>Overall result</span></div>
  </section>
  <p class="section-label">Run summary</p>
  <section class="metrics" aria-label="Run summary">
    <div class="metric"><strong>$total</strong><span>Scenarios evaluated</span></div>
    <div class="metric pass"><strong>$passed</strong><span>Scenarios passed</span></div>
    <div class="metric fail"><strong>$failed</strong><span>Scenarios failed</span></div>
  </section>
  <p class="section-label">Scenario results</p>
  <section class="scenario-grid" aria-label="Scenario results">
HTML

while IFS=$'\t' read -r scenario_id category title status expected actual; do
  [[ -z "$scenario_id" ]] && continue
  status_class="pass"
  [[ "$status" != "PASS" ]] && status_class="fail"
  cat >> "$html_file" <<HTML
    <article class="scenario is-$status_class">
      <div class="scenario-top"><span class="scenario-id">$(escape_html "$scenario_id")</span><span class="badge $status_class">$(escape_html "$status")</span></div>
      <p class="category">$(escape_html "$category")</p>
      <h3>$(escape_html "$title")</h3>
      <p class="detail"><strong>Expected</strong>$(escape_html "$expected")</p>
      <p class="detail"><strong>Observed</strong>$(escape_html "$actual")</p>
    </article>
HTML
done < "$scenarios_file"

cat >> "$html_file" <<'HTML'
  </section>
HTML

for log_file in "$report_dir/assertions.log" "$report_dir/scenarios.log"; do
  if [[ -f "$log_file" && -s "$log_file" ]]; then
    log_name="$(basename "$log_file" .log)"
    {
      printf '  <details><summary>%s output</summary><pre>' "$(escape_html "$log_name")"
      escape_html "$(cat "$log_file")"
      printf '</pre></details>\n'
    } >> "$html_file"
  fi
done

cat >> "$html_file" <<'HTML'
</main>
</body>
</html>
HTML

printf 'Generated %s\n' "$html_file"
