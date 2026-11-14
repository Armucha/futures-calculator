# PLAN — Crypto Futures Trading Calculator

## Goal
One self-contained file, `futures-calculator.html` (HTML + CSS + JavaScript, no
external libraries, no internet needed). Opens in any browser on Linux, Mac and
Android. Dark theme, big numbers, phone-friendly, live results, remembers inputs.

## Files
| File | What it is |
|---|---|
| `futures-calculator.html` | The calculator. The only file you need. |
| `PLAN.md` | This plan and progress log. |
| `README.md` | How to use it, the formulas in simple words, test results. |
| `run-tests.sh` | Runs the built-in self-test in headless Firefox and prints the results. |

## Inputs
Account balance (USDT) · risk per trade (%) · LONG/SHORT · entry · stop loss ·
take profit 1 (+ optional TP2, TP3) · leverage · taker fee (default 0.02%) ·
maintenance margin rate (default 0.5%).

## Outputs
- Position size in USDT and in coins (sized so loss at stop **including both fees** = chosen risk)
- Margin required at the chosen leverage
- Loss at stop and profit at each TP, including fees
- Reward-to-risk for each TP
- Breakeven price including fees
- Approximate isolated-margin liquidation price
- Minimum leverage if the margin does not fit in the balance

## Red warnings
- Liquidation is reached before the stop loss
- Stop loss on the wrong side of entry
- Reward-to-risk below 1.5
- Risk above 2% per trade
- (extra) Take profit on the wrong side of entry
- (extra) Margin + opening fee larger than the balance

## Decisions / assumptions
1. Fees: the taker fee is paid twice, on entry and on exit, each time on the
   position value at that price.
2. Each TP shows the result **if the whole position is closed at that TP**
   (no partial-close splitting).
3. Reward-to-risk is shown two ways: **after fees** (the real one, used for the
   1.5 warning) and **before fees** (price distance only, what charts show).
4. Liquidation uses the standard simplified isolated-margin formula (first
   maintenance tier, no fees/funding). Labeled "approximate". Real exchanges differ slightly.
5. Minimum leverage is chosen so margin + opening fee fit inside the balance, rounded up to a whole number.
6. Funding fees and slippage are ignored.
7. Number inputs accept both `.` and `,` as the decimal mark (many European phone keyboards type `,`).
8. Testing: there is no Node.js on this PC, so the math is tested by a
   self-test built into the HTML (open it with `#test` at the end of the
   address). `run-tests.sh` runs it in headless Firefox. The expected numbers
   were computed separately in Python.

## Steps
- [x] 1. Plan + git repo
- [x] 2. Math engine + self-test (test trade from the brief) — 53/53 checks pass
- [ ] 3. Full user interface: inputs, outputs, live updates, dark phone layout
- [ ] 4. Warnings + remember last inputs
- [ ] 5. README with formulas in simple words + test results; final check

## Test trade (from the brief)
SHORT · entry 66783.9 · stop 67255 · TP 65800 · leverage 7 · position ≈ 1772 USDT.
Expected: loss ≈ 12.5 USDT + fees, profit ≈ 26 USDT − fees, reward-to-risk ≈ 2.1.

Precomputed in Python (fee 0.02%, MMR 0.5%):
| Value | Expected |
|---|---|
| Loss at stop | 12.50 price + 0.71 fees = **13.21 USDT** |
| Profit at TP | 26.11 gross − 0.70 fees = **25.40 USDT** |
| Reward-to-risk | **2.09** before fees, **1.92** after fees |
| Margin | 253.14 USDT |
| Breakeven | 66,757.19 |
| Liquidation (approx.) | 75,944.73 |

## Log
- 2026-11-14 — Plan written, repo created.
- 2026-11-14 — Math engine + built-in self-test (`#test`) + `run-tests.sh`. 53/53 pass.
  Checked that the test really fails when a formula is broken (removed the exit fee → 7 failures).
