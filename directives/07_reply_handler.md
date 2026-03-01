# Directive 07 — Reply Handler (WF07)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Telegram Webhook (incoming messages)
**Channel:** Telegram (receives + responds)
**Tone:** Varies by intent

---

## Purpose

Receive and interpret replies from Akinwunmi. Route to correct action — mark tasks done, update revenue/proposals/videos, generate pep talks, send stats. Every reply is logged.

---

## Webhook URL

`https://n8n.srv1297445.hstgr.cloud/webhook/telegram-replies`

---

## Intent Recognition (Code Node)

```javascript
const text = message.text.toLowerCase().trim();

if (text.includes('done') || text === '✅')                        → mark_done_generic
if (text.match(/^(prayer|bible|book|code|career)\s+done$/))        → mark_done_specific
if (text.match(/sent (\d+) proposals?/))                           → update_proposals
if (text.match(/earned \$?(\d+)/))                                 → update_revenue
if (text.match(/published (\d+) videos?/))                         → update_videos
if (text.includes('reschedule') || text.includes('move'))          → reschedule
if (text.includes('pep talk'))                                     → pep_talk
if (text.includes('stats') || text.includes('how am i doing'))    → stats
if (text.includes('revenue'))                                      → revenue_stats
if (text.includes('skip today'))                                   → skip_day
if (text.includes('pause'))                                        → pause
→ else: unknown
```

---

## Intent → Action Mapping

| Intent | Supabase Action | Response |
|--------|----------------|----------|
| `mark_done_generic` | Mark most recent pending task | Short affirmation |
| `mark_done_specific` | Mark named task complete | Confirmation |
| `update_proposals` | `PATCH daily_log SET proposals_sent = X` | "Logged {X} proposals" |
| `update_revenue` | `PATCH daily_log SET revenue_today = X` | "Logged ${X} revenue" |
| `update_videos` | `PATCH daily_log SET videos_published = X` | "Logged {X} videos" |
| `pep_talk` | None | Claude generates motivational message with revenue phase context |
| `stats` | Query cumulative stats | Formatted stats: prayer, NT, books, code, proposals, revenue, videos, streak |
| `revenue_stats` | Query weekly revenue | Weekly revenue vs phase target + cumulative toward $100K |
| `skip_day` | Log day as skipped | Honest non-judgemental message |
| `pause` | `PATCH config SET pause_until = tomorrow` | "Paused until tomorrow" |
| `unknown` | None | "Try: done, stats, pep talk, revenue, pause, or skip today" |

---

## Task Mapping for `mark_done_specific`

| Keyword | Supabase field |
|---------|---------------|
| `prayer` | `prayer_s1` or `prayer_s2` (next incomplete) |
| `bible` | `nt_chapters_read` → set to full today's assignment |
| `book` | `book_pages` → set to 50 |
| `code` | `code_hrs` → increment by 1.2 (one block) |
| `career` | `career_done` → true |

---

## Error Handling

- Supabase write fails → "Logged your reply but couldn't update tracker."
- Claude fails (pep talk) → "You're on Day {day} of 90. Keep going."
- Unknown intents → always respond (never leave unacknowledged)
