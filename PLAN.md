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
   A single comma followed by exactly 3 digits is a thousands separator (`66,783` = 66783, `1,772` = 1772),
   unless the part before it is 0 (`0,025` = 0.025). Several commas, or comma + dot, = thousands (`1,234,567`, `66,783.9`).
   (Fixed 2026-11-14: before, `66,783` was read as 66.783.)
8. Testing: there is no Node.js on this PC, so the math is tested by a
   self-test built into the HTML (open it with `#test` at the end of the
   address). `run-tests.sh` runs it in headless Firefox. The expected numbers
   were computed separately in Python.

## Steps
- [x] 1. Plan + git repo
- [x] 2. Math engine + self-test (test trade from the brief) — 53/53 checks pass
- [x] 3. Full user interface: inputs, outputs, red warnings, live updates, dark phone layout
      (warnings moved here from step 4 — their logic was already in the math engine)
- [x] 4. Remember last inputs + "Clear trade" button + "How the math works" section in the app
- [x] 5. README with formulas in simple words + test results; final check

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
- 2026-11-14 — Screen built. Phone (360/390 px) and desktop (1280 px) screenshots checked in headless Firefox:
  test trade shows 1,771.99 USDT / −13.21 / +25.40 / 1.92 (2.09 before fees). Sticky summary bar on phones.
  Fixed: hidden result boxes still showed (CSS `display:grid` beat `hidden`).
- 2026-11-14 — Inputs saved in the browser (localStorage) on every change. Verified across a real reload in
  headless Firefox (fresh profile → type trade → reopen → trade is back). "Clear trade" empties entry/stop/TPs only.
  In-app "How the math works". Self-test now 54/54 (adds a storage round-trip; restores your saved inputs after).
- 2026-11-14 — README (how to open on Linux/Mac/Android, formulas, worked example, test results, limits).
  Self-test page made readable on phones. Final check: 54/54 pass; 360 px phone layout OK; file has no
  external links (works offline). **All steps done.**

## Feature 2 — Live prices (MEXC futures WebSocket)
Source: MEXC futures WebSocket docs (native endpoint, data-exchange commands, single ticker).
Checked live on 2026-11-14 from a page opened as a local file in Firefox (origin `null`): the server accepts it.

| What | Message |
|---|---|
| Endpoint (JSON, no API key) | `wss://contract.mexc.com/edge` |
| Subscribe | `{"method":"sub.ticker","param":{"symbol":"BTC_USDT"}}` → `{"channel":"rs.sub.ticker","data":"success"}` |
| Price push (~every second) | `{"channel":"push.ticker","data":{"symbol":"BTC_USDT","lastPrice":65459.4,…}}` |
| Keep-alive | `{"method":"ping"}` → `{"channel":"pong",…}`. Docs: ping every 10–20 s, server closes after 60 s without one. We ping every 15 s. |
| Switch coin | `unsub.ticker` old symbol, then `sub.ticker` new one |
| Bad symbol | `{"channel":"rs.error","data":"Contract [X] not exists"}` |

Design:
- Symbol picker: BTC_USDT / ETH_USDT / SOL_USDT (remembered with the other inputs).
- Shows the last price. **"Use live price"** copies it into Entry **only when tapped**; nothing ever writes Entry automatically.
- The button only works while the price is fresh (under 15 s old) and for the coin that is selected.
  When you switch coin, the old price disappears at once so you can't copy the wrong coin's price.
- Status: Connecting → Connected; if it drops: Reconnecting (waits 1, 2, 4, 8 s), then Offline (tries every 30 s,
  and right away when the phone is back online or you return to the tab). No data for 40 s = dead connection → reconnect.
- The live-price code is separate from the math and wrapped in try/catch: if it fails, typing prices by hand works as before.

Steps:
- [x] 6. Live price module + screen + self-tests for message reading and retry timing (65/65 pass)
- [x] 7. Live tests in Firefox: real prices, entry never auto-changed, coin switch, dropped connection, 80 s keep-alive, broken endpoint
- [x] 8. README update + commit

Log:
- 2026-11-14 — Live prices built and tested against the real MEXC feed (page opened as a local file):
  first price 1.7 s; typed entry untouched; "Use live price" copies the shown price; BTC/ETH/SOL switching clears
  the old price; closed connection → reconnected in 1.4 s; silent dead connection noticed after 43 s; offline/online
  events handled; 80 s keep-alive with no drops; unreachable endpoint → Reconnecting 1/2/4/8 s → Offline while the
  calculator keeps working by hand. Fixed a test that passed without really reconnecting (close is asynchronous).

## Feature 3 — GitHub + GitHub Pages (open on the phone)
Decision (2026-11-14): **public** repository + GitHub Pages, free. GitHub Free only allows Pages on public
repositories; a private repo would need GitHub Pro, and the Pages site would still be public.
Link: https://armucha.github.io/futures-calculator/

Privacy / secrets check before the first upload:
- No API keys or secrets in any version of any file (MEXC feed needs no key).
- Commit author/committer email replaced in all commits with GitHub's private no-reply address
  (history rewritten before anything was pushed; backup bundle kept outside the repo).
- Removed the mention of the user's country from this plan (all versions).
- Repo-local git config uses the no-reply address, so new commits stay private.

Steps:
- [x] 9. Account + login (done by you), history cleaned, re-scanned
- [x] 10. `index.html` forwarding to the calculator, `.nojekyll`, README phone section; create repo, push, turn on Pages
- [x] 11. Check the live site: page loads, self-test passes, live prices work from github.io

Log:
- 2026-11-14 — Public repo https://github.com/Armucha/futures-calculator created and pushed; Pages built in ~30 s.
  Deployed files byte-identical to local. Short link forwards to the calculator (keeps `#test`); self-test 65/65 on
  github.io; live MEXC prices connect from the github.io origin.

## Feature 4 — Take profit from a reward : risk ratio
Buttons under the TP boxes: Manual · 1.5R · 2R · 3R · Custom (box for any ratio) · Ladder 1R / 2R / 3R.
- TP = price where profit AFTER fees = R × loss at stop AFTER fees (L = lossPerCoin):
  LONG `(entry·(1+fee) + R·L) / (1−fee)`, SHORT `(entry·(1−fee) − R·L) / (1+fee)` → `FuturesMath.takeProfitForR`.
- Recalculated on every edit, so it follows entry, stop, fee, side and "Use live price".
- Typing in TP 1 (or any TP while on Ladder) → Manual, your number kept. Typing TP 2/3 on a single ratio keeps the ratio.
- Ladder → single ratio clears TP 2/3 (Ladder filled them); Ladder → Manual keeps all three.
- Box value rounded in your favour (LONG up, SHORT down; one decimal more than entry/stop, min 2), so a 1.5R TP
  never trips the "below 1.5" warning. No TP when the stop is on the wrong side or a SHORT ratio would need TP ≤ 0.
- Ratio and custom value remembered with the other inputs.

Log:
- 2026-11-14 — Comma fix committed first (70/70). Then ratio TP: self-test 84/84 (your 4 TP values + exact R:R,
  ladder, rounding, no false warning, wrong stop, TP ≤ 0). Clicked through in Firefox: follows entry/fee/side/live
  price, typing switches to Manual, ladder → 3R clears TP 2/3, custom "2,5" works, "abc" turns red, survives reload.
  Fixed: calculated TPs like 68283.92 were cut off in the 3 narrow boxes on phones (smaller font ≤ 440 px).

## Feature 5 — Stop loss from a take profit (the reverse of Feature 4)
- Switch above the ratio buttons: *Calculate:* **TP from stop** | **Stop from TP** (remembered).
- Stop from TP: entry + TP 1 + ratio (1.5R, 2R, 3R, Custom) → stop, so profit at TP 1 after fees = R × loss at stop
  after fees. `FuturesMath.stopForR`: P = (TP − entry)·d − fee·(entry + TP), L = P / R,
  LONG `(entry·(1+fee) − L) / (1−fee)`, SHORT `(entry·(1−fee) + L) / (1+fee)`.
- No stop → red warning (under the buttons and in the warnings box) instead of a stop:
  TP on the wrong side · TP doesn't pay the fees · TP too close for this ratio (even a stop at entry loses more than
  P / R because of the fees — found while checking the formula; without it the "stop" lands on the wrong side) ·
  a LONG would need a stop ≤ 0.
- The calculated box (TP 1 or stop) gets the dashed blue style; typing in it → Manual, number kept.
- Ladder hidden and disabled in Stop from TP; switching there while on Ladder → Manual, numbers kept.
- Stop rounded towards entry (LONG up, SHORT down), so the ratio is never below the one picked.

Log:
- 2026-11-14 — Self-test 97/97 (3 round trips + exact R:R, 5 no-stop cases, rounding, no false warning).
  The first run printed nothing: a duplicated test variable name was a syntax error that stopped the whole page.
  run-tests.sh reported it (exit 2); fixed. Clicked through in Firefox: follows TP 1 / entry / fee, red warnings
  for wrong side / no profit / too close, typing a stop → Manual, Ladder hidden, survives reload; fits at 360 px.

## Feature 6 — Amber cautions (advice, not errors)
- `calculate()` now returns red `warnings` (unchanged) and amber `cautions` separately, so no red-warning
  behaviour or test changed.
- TIGHT_STOP: stop distance % < minimum for the coin picked under Live price (default BTC 0.30 / ETH 0.40 /
  SOL 0.60; editable in a collapsed "Caution settings" section, remembered; 0 = off; unreadable → default + red box).
  The % in the text is rounded down, so it never shows the same number as the minimum.
- HIGH_FEES: fees at the stop > 10% of the total loss at the stop.
- HIGH_MARGIN: margin > 50% of the balance — skipped when the margin is more than the balance
  (that is already the red "not enough balance" warning).
- Amber box under the red one; the phone bar counts warnings (red) and cautions (amber) separately.

Log:
- 2026-11-14 — Self-test 119/119 (your 3 cases incl. exact texts, settings override, 0 = off, SOL, no double margin
  warning). Clicked through in Firefox: ETH → 2 cautions, BTC → 1, BTC min 0.5% → 2 naming BTC, "abc" → red box +
  default, red + amber together, settings remembered and collapsed after reload.

## Feature 7 — Already in a trade (Available, Risk already open)
- Optional **Available (USDT)** next to Balance. Balance still sets the risk amount; Available (when filled) is used
  for the margin check and minimum leverage, and the margin tile says "X% of available". Red warning if
  Available > Balance. The amber high-margin caution also uses Available when filled (it is about free money left).
- Optional **Risk already open (USDT)**: total open risk = that + this trade's loss at the stop, in USDT and % of
  Balance, in its own tile (only when filled). Amber caution above 5% of Balance (editable in Caution settings,
  remembered, 0 = off).
- Both boxes remembered; Clear trade leaves them. Filled boxes must be 0 or more, otherwise marked invalid.

Log:
- 2026-11-14 — Self-test 139/139 (your 6 cases + exact texts, risk still from Balance, 99.1% of available, limit
  6% / 0 = off, unreadable Available). Clicked through in Firefox: all 6 cases, 3% limit, Clear trade keeps both
  boxes, everything survives a reload.

## Feature 8 — Exchange profile, order type, contract quantity, sizing mode (3 stages)
Answers to my questions before starting (2026-11-14):
- Fees **per coin** from MEXC's data (BTC 0.01/0.04, ETH 0/0.02, SOL 0/0.01) — the brief's 0.01/0.04 matched BTC only.
- Contract rounding: main results keep the **exact** size; a separate **Order** box shows the rounded order + actual risk.
- Calculated TP/stop rounded to MEXC's **price step** (in your favour).
- "% of available" at 100%: **leave room for the opening fee** (trim only when margin + fee wouldn't fit).

Stage 1 — exchange profile + order type:
- `EXCHANGES` data block (MEXC: per-coin maker/taker, fetched 2026-11-14 with curl from
  `contract.mexc.com/api/v1/contract/detail`). Exchange selector; maker + taker boxes replace the single fee box;
  edits remembered per coin.
- Fee legs: open = taker (Market) / maker (Limit); stop exit = taker; TP exit = taker, or maker with "TP as limit
  order" (default off). All formulas (sizing, TP/stop from ratio, breakeven) use separate entry/exit fees; one fee
  number still means the same fee on every leg, so the earlier tests still check the old behaviour.
- Breakeven assumes closing like a stop (taker exit) — my call, stated in the app.
- Market: Entry = live ask (LONG) / bid (SHORT), locked; no fresh live price → typed entry + amber note.
  Switching coin clears a Market entry (it was the old coin's price).
- Log: self-test 158/158; click-through with fixed live prices: ask/bid follow, Limit typing, TP maker, stale →
  typed fallback, live back → locked again, per-coin fee edits, reload.

Stage 2 — order quantity in contracts:
- MEXC contract details fetched again with curl (2026-11-14 18:01 UTC): contract size BTC 0.0001 / ETH 0.01 / SOL 0.1,
  minimum 1, step 1, price step BTC 0.1 / ETH 0.01 / SOL 0.01 — the same on every request. Stored in the MEXC profile.
- Found: the API's **fee** fields vary between requests (BTC 0.01/0.04 or 0/0.02; SOL taker 0.01 or 0.02). Defaults now
  use the highest seen (SOL taker 0.01 → 0.02); the fee note tells you to check your real fee.
- `orderQuantity`: contracts = coins ÷ contract size, rounded DOWN to the step; coins, USDT, actual risk after rounding.
  Order box under Position/Margin; red ORDER_BELOW_MIN below MEXC's minimum. Main results keep the exact size.
- Calculated TP/stop rounded to the price step in your favour. Fixed on the way: trimming zeros would have turned a
  step-1 price like 65760 into 6576.
- Log: self-test 175/175 (265 / 19692 / 73 contracts, actual risk, below-minimum warning + text, price step, R:R ≥ 2).
  Screen: BTC 261 contracts / 13.17 of 13.21 USDT, ETH 77, SOL 0 + red warning, 2R TP 65741.5.

Stage 3 — sizing mode:
- *Size by:* **Risk %** | **% of available** (remembered). Slider 0–100% + 25/50/75/100 buttons (remembered).
  Margin = Available × % (Balance when Available is empty), position = margin × leverage, coins = position ÷ entry,
  risk = coins × loss per coin → shown in USDT and % of balance; existing red HIGH_RISK above 2%.
- Near 100%: position trimmed only when margin + opening fee wouldn't fit (your answer); 99% and below unchanged.
- Risk % box hidden in this mode (Leverage stays). Order box, cautions, open risk all work as before.
- Log: self-test 192/192 (your case 1250 / 12.5 / 63.475 / 6.35% + HIGH_RISK text; 5%, empty Available, 100% trim,
  99%, 0%, contracts). Screen: switch, slider, buttons, trim note, back to Risk %, reload.

## Feature 9 — Freeze price, rounded order everywhere, MEXC maintenance margin per coin
1. **Freeze price** (Market only): ❄ button next to the Market note; Entry stays at the live ask/bid of that moment
   (also when live prices move or go offline). Unfreezes on tap, or on coin / side / order type change or Clear trade.
   Shown by an ice-blue Entry box + label "❄ frozen", ice-blue note with price and time, "❄ frozen" in the top bar.
   Not remembered after a reload (a frozen price would be stale). Disabled when there is no live price.
   Log: 10-step click-through with fixed prices (freeze, price moves, offline, unfreeze, side, coin, Limit, Clear trade,
   stale) all as expected; self-test unchanged 192/192 (freeze is screen state, checked in the browser).

2. **Rounded order everywhere** (your request — replaces Stage 2's "exact size + Order box"): with contract details
   known, position, margin, loss, TP profit, total open risk, margin checks and cautions all use the whole-contract
   order. The unrounded plan is a small note in the Position tile; the separate Order box is gone. R:R and fee share
   are now computed per coin, so a 0-contract order shows 0 USDT with a sensible R:R instead of 0 ÷ 0. Available-mode
   risk % / HIGH_RISK use the real loss. Log: self-test 202/202 (+10); screen: BTC 261 contracts everywhere, SOL 0
   + red warning; fixed "−0.00" for a zero loss and shortened the Position tile text for phones.

3. **Maintenance margin per coin**: MEXC's contract data has `maintenanceMarginRate` — fetched 5× with curl
   (2026-11-14 18:22 UTC), the same every time: BTC 0.1%, ETH 0.1%, SOL 0.23% (first tier; MEXC raises it only above
   riskBaseVol, e.g. 1,900 BTC). Stored as `mmrPct` in the profile; the MMR box loads it per coin like the fees (edits
   remembered per coin; 0.5% fallback for coins without data). Your SHORT at 7x: liquidation ≈ 76,248.21 (was 75,944.73).
   Log: self-test 205/205; browser: per-coin box values, SOL edit remembered, survives reload.

## Housekeeping — round example balances (2026-11-14)
Test and README balances that looked like real account balances (291.03, and 1321.11 which only existed to reproduce
the 1,772 USDT position) replaced with round numbers: BTC examples balance 1000, ETH examples balance 500; the
"already in a trade" cases use Available 250 / 600 and open risk 10 / 20. All expected values recalculated in Python
(e.g. BTC 1000 @ 1% → 1,341.29 USDT, 200 contracts; ETH 500 @ 2% → 126 contracts; Available 250 → minimum 10x).
The ETH caution results don't depend on the balance and stayed the same. 665.48 / 675.48 were never in the repo.
Self-test 205/205.

## Feature 10 — Suggested fix for too much total open risk (2026-11-14)
- Under the amber "All your trades together…" caution, in the same box: CASE 1 (room left) → lower risk to R%
  (rounded down to 0.01%) or the slider to S% (whole %), plus "or reduce open risk by D"; CASE 2 (open already at or
  above the limit) → skip or reduce open risk by D. `openRiskFix()` in the math, `fixLines()` for the text.
- My calls: U = the USDT at the suggested R% (equals room when room is a whole 0.01%, as in your tests), so "Total
  would be" matches what you'd get. Room smaller than 0.01% (or 1% of the slider) → "skip this trade, or reduce…".
  The caution now ignores rounding noise (1e-9 %), so applying the suggestion really clears it.
- Log: self-test 222/222 (+17: your 4 cases, texts, round trip, slider check at 19% = 48.24). Browser: updates live
  while typing open risk / risk / slider; caution disappears at the suggested values.

## Ideas for later (not built)
- Split the position across TP1/TP2/TP3 (e.g. 50/30/20%) and show the blended result
- Round the coin amount to the exchange's step size
- Maker fee option for limit-order entries
