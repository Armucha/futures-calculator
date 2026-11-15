# CLAUDE.md

## What this is
A crypto futures position-size calculator (MEXC USDT-M perpetuals). It sizes a trade so the loss
at the stop, including fees, equals the chosen risk, and shows margin, R:R, breakeven, approximate
liquidation and warnings. Optional live prices from MEXC's public WebSocket (no API key).
Public on GitHub Pages: https://armucha.github.io/futures-calculator/ (redeploys on every push to main).

## Files
- `futures-calculator.html` — the whole app (HTML + CSS + JS, no libraries). Math is in the `FuturesMath` block;
  the self-test is built in.
- `index.html` — forwards the Pages short link to the calculator. `.nojekyll` — serve files as-is.
- `run-tests.sh` — runs the self-test in headless Firefox.
- `PLAN.md` — **status, decisions and log. Read it first and keep it updated.**
- `README.md` — how to use it, formulas in simple words, test results.

## Self-test
```
TMPDIR=<scratchpad dir> ./run-tests.sh
```
Must end with `SELFTEST RESULT: N/N passed — ALL PASSED`. Or open `futures-calculator.html#test` in a browser.
There is no Node.js here; Firefox is the test runner. Expected numbers for new tests are computed
separately (Python), not copied from the app.

## Working rules
- Small steps: one change at a time.
- Run the self-test after every change.
- Commit after each working step (then push, so the live site updates). Commit with the repo-local
  no-reply email only.
- Explain simply — the owner is not a programmer.
- Never put API keys, passwords or personal data in the repo (it is public). Use round example
  numbers (balance 1000 / 500), never real-looking balances.
- Don't change built-in coin numbers (BTC/ETH/SOL) unless asked; don't invent specs for coins.
