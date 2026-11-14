#!/usr/bin/env bash
# Runs the calculator's built-in self-test in headless (invisible) Firefox
# and prints the results in the terminal.
#
# Usage:  ./run-tests.sh
# You can also just open the calculator in a browser with "#test" at the end
# of the address, e.g. file:///home/you/futures-calculator/futures-calculator.html#test
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PROFILE="$(mktemp -d)"            # throw-away Firefox profile, so your own Firefox is untouched
trap 'rm -rf "$PROFILE"' EXIT

cat > "$PROFILE/user.js" <<'EOF'
user_pref("browser.dom.window.dump.enabled", true);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
EOF

OUTPUT="$(timeout 120 firefox --headless --no-remote --profile "$PROFILE" \
  --screenshot "$PROFILE/page.png" --window-size=420,1000 \
  "file://$HERE/futures-calculator.html#test" 2>&1)"

RESULTS="$(printf '%s\n' "$OUTPUT" | grep -E '^(PASS|FAIL|---|SELFTEST RESULT)')"
if [ -z "$RESULTS" ]; then
  echo "Could not read test results from Firefox. Open futures-calculator.html#test in a browser instead."
  exit 2
fi
printf '%s\n' "$RESULTS"
printf '%s\n' "$RESULTS" | grep -q 'ALL PASSED'
