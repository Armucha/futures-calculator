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
3. **Exchange fees:** taker fee (default 0.02%) and maintenance margin rate (default 0.5%).
   Check your exchange's fee page and fee level. Taker fees on many big exchanges are higher than 0.02%.
4. Read the results. Anything dangerous shows in **red** at the top.

"Clear trade" empties entry, stop and TPs, and keeps balance, risk, leverage and fees.

## Live prices (MEXC futures)

- Pick a coin: **BTC_USDT**, **ETH_USDT** or **SOL_USDT**. The last traded price updates about every second.
- Tap **"Use live price"** to copy it into Entry. Entry is **never** changed automatically.
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

## The formulas, in simple words

*Fee* = price × fee rate. You pay it twice: when you open and when you close.

| What | Formula | In words |
|---|---|---|
| Risk in USDT | balance × risk % | The money you accept to lose. |
| Loss per coin at stop | stop distance + entry fee + exit fee | What 1 coin costs you if the stop is hit, fees included. |
| **Coins** | risk ÷ loss per coin | So the loss at the stop, fees included, is **exactly** your risk. |
| Position size (USDT) | coins × entry | |
| Margin | position ÷ leverage | Leverage does **not** change how much you win or lose. It only changes how much money is locked, and how close liquidation is. |
| Profit at a TP | coins × TP distance − entry fee − exit fee | Shown as if the whole position closes at that TP. |
| Reward-to-risk | profit at TP ÷ loss at stop | "Before fees" = TP distance ÷ stop distance (what you see on a chart). |
| Stop loss from a take profit + ratio R | P = (TP − entry) × d − fee × (entry + TP), L = P ÷ R<br>LONG: (entry × (1 + fee) − L) ÷ (1 − fee)<br>SHORT: (entry × (1 − fee) + L) ÷ (1 + fee) | The reverse of the row below: profit per coin at TP after fees (P), divided by R, is the loss per coin you accept (L). d = +1 LONG, −1 SHORT. Rounded slightly towards entry, in your favour. |
| Take profit from a ratio R | LONG: (entry × (1 + fee) + R × loss per coin) ÷ (1 − fee)<br>SHORT: (entry × (1 − fee) − R × loss per coin) ÷ (1 + fee) | The price where profit after both fees = R × loss at the stop after fees. Shown rounded slightly in your favour, so the ratio is never below the one you picked. |
| Breakeven | LONG: entry × (1 + fee) ÷ (1 − fee)<br>SHORT: entry × (1 − fee) ÷ (1 + fee) | The price where the move exactly pays both fees. |
| Liquidation (approx.) | LONG: entry × (1 − 1/leverage) ÷ (1 − MMR)<br>SHORT: entry × (1 + 1/leverage) ÷ (1 + MMR) | The price where your loss has eaten the margin down to the maintenance margin. Isolated margin, simplified. |
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

To make the calculator size exactly this trade, enter **balance 1321.11** and **risk 1%** (= 13.21 USDT).

## Test results

| Check | You expected | Calculator | |
|---|---|---|---|
| Loss at stop, price move | ≈ 12.5 + fees | 12.50 + 0.71 fees = **13.21** | ✅ |
| Profit at TP, price move | ≈ 26 − fees | 26.11 − 0.70 fees = **25.40** | ✅ |
| Reward-to-risk | ≈ 2.1 | **2.09** before fees · **1.92** after fees | ✅ |
| Position (balance 1321.11, risk 1%) | ≈ 1772 | **1,771.99 USDT** | ✅ |
| Loss at stop incl. fees = chosen risk | exactly | difference **0.000000000** | ✅ |

The self-test has 97 checks in total: your trade, a LONG trade, every warning,
number reading (`66783,9`, `66,783.9`, `1,772` = 1772, `0,025` = 0.025, spaces), remembering inputs, reading MEXC messages
(real samples, plus broken, negative and wrong-coin messages), take profit from a ratio, and stop loss from a
take profit. All pass.

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
- Exchanges round position size to their minimum step, so the real size can be a tiny bit different.
- Funding fees and slippage are not included.
- The live price is the **last traded** price. A market order fills at the best bid or ask,
  which can be slightly different.
- Live prices were tested in Firefox on Linux. Chrome on Android uses the same standard WebSocket,
  but it hasn't been tried on a real phone yet.
- Not financial advice.
