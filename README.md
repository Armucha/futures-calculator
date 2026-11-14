# Futures Calculator

A crypto futures position-size calculator in **one file**: `futures-calculator.html`.
No installs, no external libraries. Dark theme, big numbers, made for phones.
Results update while you type, and it remembers your last inputs.
Live prices for BTC, ETH and SOL come straight from MEXC. They need internet; the calculator itself doesn't.

## How to open it

**Easiest, on any phone or computer:** open **https://armucha.github.io/futures-calculator/**
and bookmark it. On Android, in Chrome: ⋮ menu → **Add to Home screen**, so it opens like an app.
The page is hosted free by GitHub Pages. Your inputs are saved only in that phone's browser.

Or use the file directly:

| Device | What to do |
|---|---|
| **Linux / Mac** | Double-click `futures-calculator.html`. It opens in your browser. |
| **Android** | Copy the file to the phone (USB cable, or send it to yourself by e-mail or a messenger), then open it from the Files app **with Chrome or Firefox**. Don't use a built-in "HTML viewer": it may block JavaScript. |

If your phone doesn't remember the inputs, the browser is blocking storage for
local files. The calculator still works; it just starts empty each time.

## How to use it

1. **Account:** your balance (USDT), how much of it you are willing to lose on this trade (%), and leverage.
   **Size by:** *Risk %* (as above), or *% of available*: a slider (0–100%, plus 25/50/75/100% buttons like
   MEXC) sets margin = Available × % (Balance when Available is empty), and position = margin × leverage. The
   calculator then shows the loss at the stop in USDT and as % of your balance, red above 2%. Near 100% the
   position is trimmed a little so the margin plus the opening fee still fit.
   **Already in a trade?** Two optional boxes:
   - **Available (USDT):** the money not yet used as margin. This trade's margin (and minimum leverage) is
     checked against it. Your risk is still a % of the whole Balance. Empty = use Balance as before.
   - **Risk already open (USDT):** what you'd lose if the stops of your open trades are hit. The results then
     show **total open risk** = that + this trade's loss at the stop, in USDT and as % of Balance.

   Both are remembered, and **Clear trade** leaves them alone.
2. **Trade:** LONG or SHORT, entry, stop loss, take profit (TP 2 and TP 3 are optional).
   Or let the calculator set the take profit for you: tap **1.5R**, **2R**, **3R**, **Custom**
   (type any ratio, e.g. 2.5) or **Ladder 1R / 2R / 3R** (fills TP 1, 2 and 3). The take profit is placed
   so your profit **after fees** is exactly that many times your loss at the stop. It follows entry, stop,
   fee and LONG/SHORT as you change them. Calculated boxes show in blue with a dashed border. Typing
   your own take profit switches back to **Manual** and keeps your number. The choice is remembered.
   **The other way round:** switch *Calculate* to **Stop from TP**, type entry and TP 1, and pick 1.5R, 2R,
   3R or Custom. The calculator then sets the **stop loss**, so the profit at TP 1 after fees is R times the
   loss at the stop after fees. If TP 1 is on the wrong side of entry, or too close to pay the fees, you get
   a red warning instead of a stop. Ladder only exists for take profits, so it is hidden in this mode.
3. **Exchange:** pick the exchange (MEXC for now). The **maker** and **taker** fees load for the coin picked under
   Live price: BTC 0.01% / 0.04%, ETH 0% / 0.02%, SOL 0% / 0.02%, from MEXC's contract data, fetched 2026-11-14.
   **Check your real fee on MEXC.** The API returned different fee numbers on different requests that day, e.g. BTC
   0.01/0.04 or 0/0.02, so the defaults are the highest seen. Type your own; edits are remembered for each coin.
   The **maintenance margin rate** (used for the liquidation estimate) also loads per coin from MEXC's contract data:
   BTC 0.1%, ETH 0.1%, SOL 0.23% (MEXC's first tier, the same on every request; it only rises for positions above
   1,900 BTC). Edits are remembered for each coin. A coin without MEXC data falls back to 0.5%.
4. **Order:** **Market** — Entry follows the live price by itself (the **ask** for a LONG, the **bid** for a SHORT)
   and can't be typed in; opening fee = taker. If live prices are down, you can type the entry, and an amber note
   says so. **Limit** — you type the entry; opening fee = maker.
   **❄ Freeze price** (Market): holds Entry at the live price of that moment so the numbers stop moving. Tap
   **Unfreeze**, or change coin, side or order type (or Clear trade) to follow the live price again. While frozen,
   Entry has a bold ice-blue border, its label says "❄ frozen", and the top bar shows "❄ frozen".
   A stop always closes with the taker fee. A take profit closes with the taker fee, or the maker fee if you tick
   **TP as limit order**. The line "Fees used" under the TP boxes shows which fee goes where.
   Check your exchange's fee page and fee level. Taker fees on many big exchanges are higher than 0.02%.
5. Read the results. Anything dangerous shows in **red** at the top.

"Clear trade" empties entry, stop and TPs, and keeps balance, risk, leverage and fees.

## Live prices (MEXC futures)

- Pick a coin: **BTC_USDT**, **ETH_USDT** or **SOL_USDT**. The last traded price updates about every second.
- With a **Market** order, Entry follows the live ask/bid by itself.
- With a **Limit** order, tap **"Use live price"** to copy the last price into Entry. A Limit entry is **never**
  changed automatically.
  You can still type any entry you like.
- The button only works while the price is fresh (less than 15 s old) and for the coin you picked.
  When you switch coin, the old price disappears at once, so you can't copy the wrong coin's price.
- Status, top right of the box:

  | Status | Meaning |
  |---|---|
  | 🟢 Connected | Live prices are coming in. |
  | 🟡 Reconnecting… | The connection dropped. It tries again after 1, 2, 4 and 8 seconds. |
  | 🔴 Offline | No connection. Type prices by hand. It keeps trying every 30 s, and right away when your phone is back online or you return to the tab. |

- It is MEXC's public data feed: no account and no API key. Only the coin name is sent to MEXC,
  never your balance or trade.

How it works: the page opens a WebSocket (a live connection) to `wss://contract.mexc.com/edge`
and sends `{"method":"sub.ticker","param":{"symbol":"BTC_USDT"}}`. MEXC then pushes `push.ticker`
messages with `lastPrice`. Every 15 s the page sends `{"method":"ping"}`, because MEXC closes
connections that stay quiet for 60 s. If nothing arrives for 40 s, the page assumes the
connection is dead and reconnects.
Sources: MEXC futures WebSocket docs for the
[endpoint](https://www.mexc.com/api-docs/futures/websocket-api/native-ws-endpoint),
[ping](https://www.mexc.com/api-docs/futures/websocket-api/command-details-for-data-exchange) and the
[ticker](https://www.mexc.com/api-docs/futures/websocket-api/get-a-single-ticker).

## Custom coins

Next to BTC_USDT / ETH_USDT / SOL_USDT, tap **+ Custom** to add your own MEXC pair (up to 10, saved in this browser).
The form asks for: name (MEXC symbol like XYZ_USDT, uppercased for you), contract size (coins per contract), minimum
volume and volume step (contracts), price step, maker / taker fee %, maintenance margin %, minimum stop distance %
(for the tight-stop caution; 1.0% is only a rough guess) and an optional maximum leverage. Find these numbers in
MEXC's contract details for the pair, or ask Claude Code to fetch them with curl. No real coin's numbers are built in
beyond the three defaults.

- A wrong field gets a red message right under it (letters, digits and _ only; a name can't repeat a built-in or
  saved coin; sizes and steps above 0; fees 0–10; maintenance margin 0–100; min stop above 0; max leverage empty or ≥ 1).
- A selected custom coin works like a built-in one: whole-contract order, minimum order check, fees, maintenance margin
  for liquidation, tight-stop caution, Freeze price. Results name it ("99 contracts = 990 XYZ", "Order on MEXC (XYZ_USDT)").
- Leverage above the coin's maximum → red: "Leverage 20x is above this coin's maximum of 10x on MEXC."
- Live price: a MEXC-style name is tried on the live feed. If MEXC answers with an error or nothing arrives within 10 s:
  "No live price for XYZ_USDT, type prices by hand" — everything else keeps working.
- **Edit** / **Delete** appear under the coin buttons when a custom coin is selected; deleting asks first, in the page.
  Deleting the selected coin switches back to BTC_USDT.

## Red warnings and amber cautions

**Red** = a real problem: stop on the wrong side, liquidation before the stop, margin bigger than your balance
(or than Available), Available bigger than Balance, TP on the wrong side, reward-to-risk below 1.5, risk above 2%.

**Amber** = advice, not an error:

| Caution | When | Message |
|---|---|---|
| Tight stop | stop closer to entry than the minimum for the coin picked under Live price: BTC 0.30%, ETH 0.40%, SOL 0.60% | "Stop is only X% away. ETH often moves that much in minutes, so normal noise could hit it." |
| High fees | fees are more than 10% of the loss at the stop | "Fees are X% of your loss. Tight stops make fees expensive." |
| High margin | margin is more than 50% of your balance (of Available, when filled in) | "This trade uses X% of your balance as margin, leaving little room for other trades." ("…of your available balance…" when Available is used) |
| High total open risk | risk already open + this trade's loss at the stop is more than 5% of your balance (only when "Risk already open" is filled in) | "All your trades together risk X USDT (Y% of your balance) if every stop is hit — more than 5%." |

Change the minimum stop distances under **Caution settings** (collapsed at the bottom of the inputs); they are
remembered. Set one to 0 to turn the tight-stop caution off for that coin. When the margin is more than your whole
balance, you get the red warning instead of the amber one. The 5% open-risk limit is in Caution settings too
(remembered, 0 = off).

The high-total-open-risk caution also shows a **suggested fix** in the same amber box (limit = balance × cap,
room = limit − risk already open), updated as you type:

- **Room left, Risk %:** "Suggested fix: lower this trade's risk to R% (U USDT). Total would be T USDT (P%)." R is the
  largest risk that fits, rounded down to 0.01%. U is what R% risks, the same as the room unless the rounding trims a
  few cents.
- **Room left, % of available:** "Suggested fix: lower the size slider to S%." S = slider × room ÷ this trade's
  loss, rounded down to a whole %.
- Both add: "Or reduce your open risk by D USDT (for example by moving a stop to breakeven)."
  D = open + this trade − limit.
- **No room** (your open trades alone are at or above the limit): "Your open trades alone are already above the
  limit. Suggested fix: skip this trade, or reduce your open risk by D USDT … before adding it."

## The formulas, in simple words

*Fee* = price × fee rate. You pay it twice: when you open and when you close. Opening = taker (Market) or maker
(Limit); closing at the stop = taker; closing at a TP = taker, or maker with "TP as limit order".

| What | Formula | In words |
|---|---|---|
| Risk in USDT | balance × risk % | The money you accept to lose. |
| Loss per coin at stop | stop distance + entry fee + exit fee | What 1 coin costs you if the stop is hit, fees included. |
| **Coins** | risk ÷ loss per coin | So the loss at the stop, fees included, is **exactly** your risk. |
| Position size (USDT) | coins × entry | |
| Size by % of available | margin = Available × %, position = margin × leverage, coins = position ÷ entry | Then the risk is what the stop makes it: loss at stop = coins × loss per coin (shown as % of balance). |
| Order (contracts) | coins ÷ contract size, rounded **down** to MEXC's step | MEXC trades whole contracts (BTC 0.0001, ETH 0.01, SOL 0.1). Rounding down keeps the real risk at or below the plan. **All results** (position, margin, loss, profit, open risk) use this real order; the unrounded plan is a small note under Position size. |
| Margin | position ÷ leverage | Leverage does **not** change how much you win or lose. It only changes how much money is locked, and how close liquidation is. |
| Profit at a TP | coins × TP distance − entry fee − exit fee | Shown as if the whole position closes at that TP. |
| Reward-to-risk | profit at TP ÷ loss at stop | "Before fees" = TP distance ÷ stop distance (what you see on a chart). |
| Stop loss from a take profit + ratio R | P = (TP − entry) × d − entry fee × entry − TP fee × TP, L = P ÷ R<br>LONG: (entry × (1 + entry fee) − L) ÷ (1 − stop fee)<br>SHORT: (entry × (1 − entry fee) + L) ÷ (1 + stop fee) | The reverse of the row below: profit per coin at TP after fees (P), divided by R, is the loss per coin you accept (L). d = +1 LONG, −1 SHORT. Rounded slightly towards entry, in your favour. |
| Take profit from a ratio R | LONG: (entry × (1 + entry fee) + R × loss per coin) ÷ (1 − TP fee)<br>SHORT: (entry × (1 − entry fee) − R × loss per coin) ÷ (1 + TP fee) | The price where profit after both fees = R × loss at the stop after fees. Shown rounded slightly in your favour, so the ratio is never below the one you picked. |
| Breakeven | LONG: entry × (1 + entry fee) ÷ (1 − taker)<br>SHORT: entry × (1 − entry fee) ÷ (1 + taker) | The price where the move exactly pays both fees, if you close with a stop or market order (taker) — like a stop moved to breakeven. |
| Liquidation (approx.) | LONG: entry × (1 − 1/leverage) ÷ (1 − MMR)<br>SHORT: entry × (1 + 1/leverage) ÷ (1 + MMR) | The price where your loss has eaten the margin down to the maintenance margin. Isolated margin, simplified. MMR = the coin's MEXC rate (BTC 0.1%, ETH 0.1%, SOL 0.23%). Example: your SHORT 66783.9 at 7x ≈ 76,248.21 with 0.1% (75,944.73 with the old 0.5%). |
| Minimum leverage | position ÷ (balance − opening fee), rounded up | Shown only when the margin doesn't fit in your balance. |

### Worked example: your test trade

SHORT, entry 66,783.9, stop 67,255, TP 65,800, leverage 7, fee 0.02%, position 1,772 USDT.

1. Coins: 1,772 ÷ 66,783.9 = **0.026533 BTC**
2. Stop distance: 67,255 − 66,783.9 = 471.1 per coin → 0.026533 × 471.1 = **12.50 USDT**
3. Fees at stop: 0.02% × (66,783.9 + 67,255) × 0.026533 = **0.71 USDT** → total loss **13.21 USDT**
4. TP distance: 66,783.9 − 65,800 = 983.9 per coin → 0.026533 × 983.9 = **26.11 USDT**
5. Fees at TP: 0.02% × (66,783.9 + 65,800) × 0.026533 = **0.70 USDT** → net profit **25.40 USDT**
6. Reward-to-risk: 983.9 ÷ 471.1 = **2.09 before fees**; 25.40 ÷ 13.21 = **1.92 after fees**
7. Margin: 1,772 ÷ 7 = **253.14 USDT**
8. Breakeven: 66,783.9 × 0.9998 ÷ 1.0002 = **66,757.19**
9. Liquidation: 66,783.9 × (1 + 1/7) ÷ 1.005 ≈ **75,944.73**, far above the stop, so no warning

Sized from your account instead: with **balance 1000** and **risk 1%** (= 10 USDT) the calculator sizes this trade to
**1,341.29 USDT**. Your 1,772 USDT position corresponds to a risk of 13.21 USDT.

## Test results

| Check | You expected | Calculator | |
|---|---|---|---|
| Loss at stop, price move | ≈ 12.5 + fees | 12.50 + 0.71 fees = **13.21** | ✅ |
| Profit at TP, price move | ≈ 26 − fees | 26.11 − 0.70 fees = **25.40** | ✅ |
| Reward-to-risk | ≈ 2.1 | **2.09** before fees · **1.92** after fees | ✅ |
| Position sized from balance 1000, risk 1% | — | **1,341.29 USDT** (loss at stop exactly 10.00) | ✅ |
| Loss at stop incl. fees = chosen risk | exactly | difference **0.000000000** | ✅ |

The self-test has 253 checks in total: your trade, a LONG trade, every warning,
number reading (`66783,9`, `66,783.9`, `1,772` = 1772, `0,025` = 0.025, spaces), remembering inputs, reading MEXC messages
(real samples, plus broken, negative and wrong-coin messages), take profit from a ratio, stop loss from a
take profit, the amber cautions, being in a trade already (Available, risk already open), and exchange fees
(Market / Limit entry, TP as limit order), the order in whole contracts, sizing by % of available, and the suggested
fix for too much total open risk, and custom coins. All pass.

Custom coins (generic coin, balance 1000, risk 1%, LONG 0.2 / stop 0.19, 10x, Market, maker 0, taker 0.02%, MMR 0.1%):

| Coin | Order | Position | Loss at stop |
|---|---|---|---|
| A: size 10, min 1, step 1 | **99** contracts = 990 coins | 198.00 USDT (margin 19.80) | 9.977 USDT (0.998%) |
| B: size 10, step 5 | **95** contracts = 950 coins | 190.00 USDT | 9.574 USDT |
| C: size 1000 | 0.99 → **0**: red "below minimum", no order | 0 | 0 |

Also checked: max leverage 5 with 10x → red warning; min stop 1.0% with a 0.5% stop → tight-stop caution; name
"btc_usdt" (exists), "my coin" (space) and contract size 0 are rejected; an 11th coin is rejected; two coins saved and
read back are the same, deleting one leaves the other; broken saved data is skipped. All BTC / ETH / SOL tests unchanged.

Suggested fix (balance 1000, cap 5% → limit 50):

| Case | Suggestion |
|---|---|
| Risk % 2% (this 20), open 40 | lower risk to **1.00%** (10.00 USDT), total 50.00 (5.00%); or reduce open risk by 10.00 — at 1% the caution is gone |
| Risk % 2%, open 60 | open trades alone are above the limit: skip, or reduce open risk by **30.00** |
| Risk % 2%, open 20 | no caution, no suggestion |
| % of available 25% (this 63.475), open 0 | lower the slider to **19%** (loss there 48.24, under 50); or reduce open risk by 13.48 |

Exchange fees (balance 1000, risk 1%, LONG 100 / stop 95 / TP 110, maker 0.01%, taker 0.04%):

| Order | Coins | Net profit at TP | Loss at stop |
|---|---|---|---|
| Market, TP taker | 1.969279 | 19.5274 | 10.00 |
| Limit, TP maker | 1.980983 | 19.7682 | 10.00 |

Order in whole MEXC contracts (rounded down; one fee 0.02% unless stated):

| Trade | Before rounding | Order | Actual risk (planned) |
|---|---|---|---|
| BTC SHORT 66783.9 / 67255, balance 1000, risk 1% | 200.84 contracts | **200** = 0.02 BTC = 1,335.68 USDT | 9.96 (10.00) |
| BTC LONG 100 / 95, Market, maker 0.01 / taker 0.04 | 19,692.79 | **19,692** | 9.9996 (10.00) |
| ETH SHORT 1813 / 1820.16, balance 500, risk 2% | 126.80 | **126** = 1.26 ETH | 9.94 (10.00) |
| SOL LONG 100 / 95, balance 100, risk 0.1% | 0.2 | **0** → red: below MEXC's minimum of 1 | 0 (0.10) |

Calculated TP/stop on MEXC's price step: BTC SHORT 2R TP 65761.5753 → **65761.5** (R:R after fees 2.00015, still ≥ 2).

Size by % of available (balance 1000, LONG 100 / stop 95, 10x, Market, taker 0.04%):

| Available, slider | Position | Coins | Loss at stop | |
|---|---|---|---|---|
| 500, 25% | **1,250 USDT** | **12.5** | **63.475 USDT = 6.35%** | red: risk above 2% |
| 500, 5% | 250 USDT | 2.5 | 12.695 USDT = 1.27% | no warning |
| empty (uses Balance), 25% | 2,500 USDT | 25 | 126.95 USDT | |
| 500, 100% | 4,980.08 USDT (trimmed: margin + fee = 500) | 49.80 | 252.89 USDT | no false "not enough" warning |

Cautions (fee 0.02%, MMR 0.5%, default minimums):

| Trade | Tight stop | High fees | High margin |
|---|---|---|---|
| ETH SHORT, balance 500, risk 2%, 7x, 1813 / stop 1820.16 | yes (0.39% < 0.40%) | no (9.2%) | yes (65.7%) |
| BTC LONG, balance 1000, risk 1%, 10x, 1000 / stop 998 | yes (0.20% < 0.30%) | yes (16.7%) | no (41.7%) |
| BTC LONG, balance 1000, risk 1%, 5x, 1000 / stop 980 | no | no | no |

Already in a trade (ETH SHORT 1813 / stop 1820.16 / TP 1796.5, risk 2%, balance 500):

| Case | Result |
|---|---|
| Available empty, 7x | margin 328.40 fits, no warning |
| Available 250, 7x | red: not enough available, minimum leverage **10x** |
| Available 250, 10x | fits (margin 229.88 = 92.0% of available → amber margin caution) |
| Available 600 | red: Available is more than Balance |
| Risk already open 10 | total open risk 20.00 USDT = 4.00%, no caution |
| Risk already open 20 | total open risk 30.00 USDT = 6.00%, amber caution |

Take profit from a ratio (fee 0.02% unless stated). R:R after fees comes out exactly as chosen in every case:

| Trade | Ratio | Take profit | In the box (rounded in your favour) |
|---|---|---|---|
| SHORT 66783.9 / stop 67255 | 1.5R | 66010.4795 | 66010.47 |
| SHORT 66783.9 / stop 67255 | 2R | 65761.5753 | 65761.57 |
| SHORT 66783.9 / stop 67255 | 3R | 65263.7671 | 65263.76 |
| LONG 100 / stop 95, fee 0.1% | 2R | 110.600601 | 110.61 |

Stop loss from a take profit (the same trades backwards). R:R after fees comes out exactly 2 each time:

| Trade | Ratio | Stop loss |
|---|---|---|
| SHORT 66783.9 / TP 65761.5753, fee 0.02% | 2R | 67255.00002 (expected 67255) |
| LONG 100 / TP 110.600601, fee 0.1% | 2R | 94.9999998 (expected 95) |
| SHORT 1830 / TP 1667.8, fee 0.02% | 2R | 1910.0022 |
| LONG 100 / TP 95 (wrong side) | 2R | no stop: red warning |
The expected numbers were computed separately in Python, not by the calculator itself.

Live-price tests, run against the real MEXC feed in Firefox on 2026-11-14, page opened as a local file:

| Test | Result |
|---|---|
| First price after opening | 1.7 s |
| Entry typed as 100 while prices streamed | stayed 100 ✅ |
| "Use live price" | Entry = 65414.3, the price shown ✅ |
| Switch BTC → ETH → SOL | old price cleared at once; ETH and SOL prices arrived ✅ |
| Connection closed | Reconnecting → Connected in 1.4 s, new prices ✅ |
| Connection silently dead (no close) | noticed after 43 s, reconnected ✅ |
| Phone offline → online | Offline, button disabled → Connected again ✅ |
| Kept open 80 s (MEXC cuts at 60 s without ping) | stayed connected, 32 prices ✅ |
| MEXC unreachable | calculator still works by hand; Reconnecting 1/2/4/8 s → Offline ✅ |

**Run the self-test yourself:**
- In any browser, tap **"Run self-test"** at the bottom of the calculator,
  or add `#test` to the end of the address.
- On Linux: `./run-tests.sh` (uses headless Firefox, prints PASS/FAIL, exit code 0 = all passed).

## Limits (be aware)

- Liquidation is an **estimate**: real exchanges use maintenance tiers, fees and funding.
  Keep your stop well before it.
- All results use the real MEXC order (whole contracts, rounded down), so the risk shown is the risk you take;
  the planned size before rounding is a small note under Position size.
- Funding fees and slippage are not included.
- The live price is the **last traded** price. A market order fills at the best bid or ask,
  which can be slightly different.
- Live prices were tested in Firefox on Linux. Chrome on Android uses the same standard WebSocket,
  but it hasn't been tried on a real phone yet.
- Not financial advice.
