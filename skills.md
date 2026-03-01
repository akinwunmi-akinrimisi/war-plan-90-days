# Skills Reference
## 90-Day War Plan — AI Accountability Partner
**Version 2.0 | Operscale / Cloudboosta Systems | March–May 2026**

This document defines what this agent can do, what tools it uses to do it, and how each capability is invoked. Reference this before building any workflow node or writing any Claude prompt.

---

## 1. Message Generation (Claude API via OpenRouter)

**What it does:** Generates all accountability messages — reminders, escalations, pep talks, morning briefings, night summaries. Every message is unique, contextual, and never templated.

**Model:** `anthropic/claude-sonnet-4-5` via OpenRouter
**n8n node:** HTTP Request (POST to `https://openrouter.ai/api/v1/chat/completions`)
**Credential:** n8n credential → `OpenRouter API Key`

**Required inputs (context packet):**
```json
{
  "day_number": 1-90,
  "calendar_date": "YYYY-MM-DD",
  "week_num": 1-18,
  "is_weekend": false,
  "revenue_phase": 1,
  "task": "prayer_session_1 | prayer_session_2 | nt_reading | book_of_day | coding_block_1 | coding_block_2 | coding_block_3 | career_block_a | career_block_b | career_block_c | yt_pipeline | morning_briefing | night_summary",
  "tone_mode": "faith | coach_builder | coach_revenue | coach_growth | hybrid",
  "message_type": "pre_task | mid_task | missed | escalation | pep_talk | briefing | summary",
  "quote_source": "bible_scripture | business_quote | sales_quote | personal_development",
  "user_name": "Akinwunmi",
  "completion_stats": {
    "prayer_sessions_done": 0,
    "nt_chapters_read_total": 0,
    "books_read_total": 0,
    "code_hours_total": 0,
    "proposals_sent_total": 0,
    "revenue_earned_total": 0,
    "weekly_revenue_target": 1000,
    "weekly_revenue_actual": 0,
    "videos_published_total": 0,
    "current_streak_days": 0,
    "day_score_yesterday": 0
  },
  "escalation_level": 0,
  "recent_messages": []
}
```

**Output:** Plain text message (100–250 words for reminders, 300–500 for briefings/summaries)

**Rules:**
- Never use the same quote twice in the same week
- Faith tone: always include a specific Bible reference (book chapter:verse)
- Coach_builder tone: tie to Operscale client builds, coding skills, portfolio depth
- Coach_revenue tone: tie to current phase target ($1K/$5K/$20K/wk), proposals, closing deals — be direct and urgent
- Coach_growth tone: tie to YouTube compounding, Vision GridAI channel growth, automation as social proof
- Hybrid tone: open with scripture, close with revenue vision
- Never generate placeholder text — every message must be ready to send as-is
- Weekend messages: prayer only — do NOT reference work, books, proposals, or coding targets

---

## 2. Telegram Delivery

**What it does:** Sends all primary accountability messages to Akinwunmi's personal Telegram.

**n8n node:** Telegram node (built-in)
**Credential:** n8n credential → `Telegram Bot API`
**Config values (stored in Supabase `config` table):**
- `telegram_bot_token` → set in n8n credential, never hardcoded
- `telegram_chat_id` → Akinwunmi's personal chat ID

**Supported message types:**
- `sendMessage` — standard text messages (all reminders, escalations, replies)
- Markdown formatting supported (bold `*text*`, italic `_text_`, code blocks)

**Error handling:** If Telegram delivery fails, log to `interactions` table with `status: failed` and retry once after 60 seconds. If second attempt fails, send to Slack as fallback.

---

## 3. Slack Delivery

**What it does:** Posts morning briefings, night summaries, and weekly reports to `#war-plan` channel.

**n8n node:** HTTP Request (POST to Slack Incoming Webhook URL)
**Credential:** n8n credential → `Slack Webhook URL`
**Channel:** `#war-plan`

**Message format:** Slack Block Kit JSON for structured layouts (briefings/summaries). Plain text for simple notifications.

**Rules:** Slack is secondary channel. All task reminders go to Telegram only. Only briefings, summaries, and weekly reports go to Slack.

---

## 4. Tracker UI Serving (WF-UI)

**What it does:** Serves `90day-tracker.html` as a live webpage when the Telegram link is opened in a browser.

**n8n nodes (in order):**
1. **Webhook** — Method: GET, Path: `/tracker`, Response Mode: Using Respond to Webhook Node
2. **Read Binary File** — Path: `{{ $env.TRACKER_HTML_PATH }}` (resolves from `.env`)
3. **Respond to Webhook** — Response Code: 200, Response Headers: `Content-Type: text/html`, Body: `{{ $binary.data.toString() }}`

**Why the file is read dynamically:** Every request reads fresh from disk — updating `90day-tracker.html` takes effect immediately on the next page load. No restart, no node edit, no redeployment.

**Directive:** `directives/11_tracker_ui.md`

---

## 5. Tracker Data API (WF10 — Supabase Sync)

**What it does:** Two-route API bridging `90day-tracker.html` and Supabase. Handles loading existing data on page open and saving a full day's entries on Save.

**n8n nodes (in order):**
1. **Webhook** — Method: POST or GET, branched via IF node on method
2. **Route A — Load (GET):** `GET /webhook/tracker-data?day=X` → Supabase read → returns day row as JSON → Respond to Webhook
3. **Route B — Save (POST):** `POST /webhook/tracker-save` → PIN check → Supabase PATCH → Respond `{ "status": "saved" }`

**PIN validation logic (Code node on POST route):**
```javascript
const pin = $json.body.pin;
const storedPin = $json.supabaseConfig.tracker_pin; // read from config table
if (pin !== storedPin) {
  return { valid: false, error: 'Invalid PIN' };
}
return { valid: true };
```

**Full day save payload (what the Save button POSTs):**
```json
{
  "pin": "xxxx",
  "day_num": 14,
  "date": "2026-03-19",
  "prayer_s1": true,
  "prayer_s2": false,
  "prayer_note": "...",
  "nt_chapters_read": ["Matthew-1", "Matthew-2"],
  "nt_note": "...",
  "book_title": "$100M Offers",
  "book_pages": 52,
  "book_note": "...",
  "code_hrs": 3.5,
  "code_what": "Built n8n tax filing workflow for Startup HQ",
  "code_note": "...",
  "proposals_sent": 10,
  "revenue_today": 500,
  "career_done": true,
  "career_win": "First Upwork review received",
  "career_note": "...",
  "videos_published": 3,
  "pipeline_running": true,
  "yt_note": "...",
  "day_note": "Solid day..."
}
```

**Supabase write:** `PATCH /rest/v1/daily_log?day_num=eq.{day_num}` with `Prefer: return=minimal`

**Directive:** `directives/10_supabase_sync.md`

---

## 6. Supabase Read/Write

**What it does:** Reads completion stats to build context packets. Writes completion events, interaction logs, and escalation states.

**n8n node:** HTTP Request (Supabase REST API)
**Credential:** n8n credential → `Supabase API Key`
**Base URL:** `https://<project-ref>.supabase.co/rest/v1/`
**Auth headers:** `apikey: <key>`, `Authorization: Bearer <key>`

**Read operations:**
- `GET /daily_log?day_num=eq.{day}` — get today's completion data
- `GET /config` — get system config (start date, pause state, user ID)
- `GET /interactions?task=eq.{task}&order=created_at.desc&limit=7` — get recent messages for dedup

**Write operations:**
- `PATCH /daily_log?day_num=eq.{day}` — update completion field (e.g., `prayer_s1: true`)
- `POST /interactions` — log sent message or received reply
- `PATCH /escalations?day_num=eq.{day}&task=eq.{task}` — update escalation level
- `PATCH /config` — update pause state

**Rules:**
- Always use `Prefer: return=minimal` header for PATCH/POST to avoid unnecessary response data
- Never write to `daily_log` columns that are human-authored inputs (day_note, book titles) — only update automated tracking fields

---

## 7. Cron Scheduling

**What it does:** Fires all reminder workflows at the correct times throughout the day.

**n8n node:** Schedule Trigger (Cron)
**Timezone:** Africa/Lagos (WAT, UTC+1)
**Weekend restriction:** Most workflows use a day-of-week filter (Mon=1 through Fri=5). WF02 and WF12 run every day including weekends.

**Master schedule (all times WAT):**

| Time | Workflow | Days | Task |
|------|---------|------|------|
| 02:45 | WF01 | Mon–Fri | Morning Briefing → Slack + Telegram |
| 02:55 | WF02 | Every day | Prayer Session 1 — pre-task |
| 04:20 | WF02 | Every day | Prayer Session 1 — wrap-up |
| 04:25 | WF05 | Mon–Fri | Coding Block 1 — start |
| 06:25 | WF03 | Mon–Fri | NT Reading — pre-task |
| 07:15 | WF03 | Mon–Fri | NT Reading — midpoint |
| 07:55 | WF04 | Mon–Fri | Book of the Day — morning start |
| 08:55 | WF11 | Mon–Fri | Career Block A — start |
| 11:55 | WF11 | Mon–Fri | Career Block B — start |
| 13:55 | WF05 | Mon–Fri | Coding Block 2 — start |
| 16:55 | WF02 | Every day | Prayer Session 2 — pre-task |
| 18:25 | WF02 | Every day | Prayer Session 2 — wrap-up |
| 18:25 | WF04 | Mon–Fri | Book of the Day — evening finish + notes |
| 19:25 | WF11 | Mon–Fri | Career Block C — YouTube pipeline check |
| 19:30 | WF12 | Every day | YouTube video count check |
| 21:25 | WF05 | Mon–Fri | Coding Block 3 — start |
| 23:15 | WF08 | Mon–Fri | Night Summary → Slack + Telegram |
| Every 30 min | WF06 | Mon–Fri | Escalation Engine check (03:00–23:30 only) |
| Sunday 22:00 | WF09 | Sunday | Weekly Report → Slack |

**Rules:**
- WF06 (Escalation) only runs Mon–Fri between 03:00 and 23:30
- Check `config.pause_until` at the start of every workflow — if paused, skip execution
- On weekends: WF02 and WF12 fire as normal. All others are suppressed via day-of-week filter in the Schedule Trigger node

---

## 8. Reply Parsing (Telegram Webhook)

**What it does:** Receives and interprets replies from Akinwunmi via Telegram and routes them to the correct action.

**n8n node:** Webhook (listening for Telegram updates)
**URL pattern:** `https://n8n.srv1297445.hstgr.cloud/webhook/telegram-replies`

**Intent recognition (handled by a Code node, no AI needed for this):**
```javascript
const text = message.text.toLowerCase().trim();

if (text.includes('done') || text === '✅')           → markTaskDone()
if (text.match(/^(prayer|bible|book|code|career)\s+done$/)) → markSpecificTaskDone()
if (text.includes('reschedule') || text.includes('move'))   → rescheduleTask()
if (text.includes('pep talk'))                              → generatePepTalk()
if (text.includes('stats') || text.includes('how am i doing')) → sendStats()
if (text.includes('revenue'))                               → sendRevenueStats()
if (text.match(/sent (\d+) proposals?/))                    → updateProposalCount(match[1])
if (text.match(/earned \$?(\d+)/))                          → updateRevenueToday(match[1])
if (text.match(/published (\d+) videos?/))                  → updateVideosPublished(match[1])
if (text.includes('skip today'))                            → skipDay()
if (text.includes('pause'))                                 → pauseSystem()
```

**All replies logged to `interactions` table.**

---

## 9. Day Counter (Weekday Number)

**What it does:** Calculates the current weekday number (1–90) and calendar week number relative to March 2, 2026 start date. Excludes weekends.

**Implementation (Code node):**
```javascript
// Build array of 90 weekday dates starting March 2, 2026 (first Monday)
function getWeekdayDates() {
  const dates = [];
  const d = new Date('2026-03-02T00:00:00+01:00'); // WAT
  while (dates.length < 90) {
    if (d.getDay() !== 0 && d.getDay() !== 6) {
      dates.push(new Date(d));
    }
    d.setDate(d.getDate() + 1);
  }
  return dates;
}

const weekdays = getWeekdayDates();
const now = new Date();
const todayStr = now.toISOString().split('T')[0];

// Find today's weekday index
let dayNum = null;
for (let i = 0; i < weekdays.length; i++) {
  if (weekdays[i].toISOString().split('T')[0] === todayStr) {
    dayNum = i + 1;
    break;
  }
}

const isWeekend = now.getDay() === 0 || now.getDay() === 6;
const weekNum = dayNum ? Math.ceil(dayNum / 5) : null;

return { dayNum, weekNum, isWeekend, todayStr };
```

**Used by:** Every workflow that builds a Claude context packet.
**Weekend behaviour:** If `isWeekend === true`, most workflows skip execution. WF02 and WF12 proceed normally.

---

## 10. NT Day Calculator (14-Day Cycle)

**What it does:** Returns the NT reading assignment (which books and chapter ranges) for any given weekday number.

**Implementation (Code node):**
```javascript
const NT_14DAY = {
  1:  [{book:'Matthew',      from:1,  to:28}],
  2:  [{book:'Mark',         from:1,  to:16}, {book:'Luke',         from:1,  to:4}],
  3:  [{book:'Luke',         from:5,  to:24}],
  4:  [{book:'John',         from:1,  to:21}],
  5:  [{book:'Acts',         from:1,  to:14}],
  6:  [{book:'Acts',         from:15, to:28}],
  7:  [{book:'Romans',       from:1,  to:16}],
  8:  [{book:'1 Corinthians',from:1,  to:16}],
  9:  [{book:'2 Corinthians',from:1,  to:13}, {book:'Galatians',    from:1,  to:6}],
  10: [{book:'Ephesians',    from:1,  to:6},  {book:'Philippians',  from:1,  to:4},
      {book:'Colossians',    from:1,  to:4},  {book:'1 Thessalonians',from:1,to:5}],
  11: [{book:'2 Thessalonians',from:1,to:3},  {book:'1 Timothy',    from:1,  to:6},
      {book:'2 Timothy',     from:1,  to:4},  {book:'Titus',        from:1,  to:3},
      {book:'Philemon',      from:1,  to:1}],
  12: [{book:'Hebrews',      from:1,  to:13}, {book:'James',        from:1,  to:5}],
  13: [{book:'1 Peter',      from:1,  to:5},  {book:'2 Peter',      from:1,  to:3},
      {book:'1 John',        from:1,  to:5},  {book:'2 John',       from:1,  to:1},
      {book:'3 John',        from:1,  to:1},  {book:'Jude',         from:1,  to:1}],
  14: [{book:'Revelation',   from:1,  to:22}]
};

const ntDay = ((dayNum - 1) % 14) + 1;
const segments = NT_14DAY[ntDay];
const totalChapters = segments.reduce((a, b) => a + (b.to - b.from + 1), 0);
const label = segments.map(s =>
  s.from === 1 && s.to === (NT_14DAY[ntDay].find(x=>x.book===s.book).to)
    ? s.book
    : `${s.book} ${s.from}–${s.to}`
).join(', ');

return { ntDay, segments, totalChapters, label };
// Example: { ntDay: 2, totalChapters: 20, label: "Mark, Luke 1–4" }
```

---

## 11. Score Calculator

**What it does:** Computes a 0–100 day score from Supabase `daily_log` data.

**Scoring weights (weekdays):**
| Component | Max Points | Logic |
|-----------|-----------|-------|
| Prayer | 25 pts | Both sessions: 25. One session: 12. None: 0. |
| NT Reading | 20 pts | Proportional to chapters_read / total_assigned for today's NT day |
| Book of Day | 15 pts | Proportional to book_pages / 50 (target 50 pages) |
| Coding | 20 pts | Proportional to code_hrs / 3.5 (target 3.5 hrs) |
| Career | 15 pts | Phase 1: proposals_sent / 10. Phase 2: (proposals_sent/3 × 8) + career_done×7. Phase 3: proposal_sent≥1 × 8 + career_done×7 |
| Journal/Notes | 5 pts | day_note length > 10 chars: +5 |
| **Total** | **100 pts** | |

**Weekend scoring:** Only prayer counts on weekends (max 25 pts). All other weights are 0.

**Revenue Phase Calculator:**
```javascript
function getRevenuePhase(weekNum) {
  if (weekNum <= 4)  return { phase: 1, weeklyTarget: 1000 };
  if (weekNum <= 8)  return { phase: 2, weeklyTarget: 5000 };
  return             { phase: 3, weeklyTarget: 20000 };
}
```

**Used by:** WF08 (Night Summary), WF09 (Weekly Report), Claude context packets.

---

## Known Constraints & Gotchas

- **90day-tracker.html must exist on disk before WF-UI is activated** — if the file is missing, the Read Binary File node throws. Run `skills.sh` to verify the file is present at `TRACKER_HTML_PATH` before enabling WF-UI.
- **TRACKER_HTML_PATH in .env must be absolute** — e.g. `/opt/war-plan-agent/90day-tracker.html`, not `./90day-tracker.html`. n8n resolves paths from its own working directory.
- **PIN stored in Supabase `config` table, not `.env`** — can be updated without a restart. Never hardcode in a workflow node.

- **daily_log must be seeded with 90 weekday rows** — `skills.sh` handles this. Dates must match the actual weekday calendar (not 90 consecutive calendar days). If seeding manually, verify the dates are Mon–Fri only.
- **Weekend suppression is per-workflow** — the Schedule Trigger in n8n supports day-of-week filtering. Set WF01, WF03–WF09, WF11 to Mon–Fri only. WF02 and WF12 stay on every day.
- **Revenue phase is stored in `config.revenue_phase`** and updated by WF09 (Weekly Report) every Sunday. This ensures all other workflows read the correct phase without recalculating from the date.
- **OpenRouter rate limits:** Claude Sonnet via OpenRouter — add a 2-second delay between consecutive API calls in the same workflow run.
- **Telegram message length:** Max 4096 characters. Night summaries with revenue + video stats can get long — truncate gracefully.
- **Supabase free tier pauses:** Project pauses after 7 days of inactivity. Since this system hits Supabase multiple times per hour on weekdays, this will never trigger during the 90-day run.
- **n8n Cron precision:** Accurate to the minute with ~30s drift. Account for this in tight scheduling.
- **Timezone:** All Crons must be set to `Africa/Lagos (WAT, UTC+1)`. Verify after every n8n server restart.
- **Hardcoded API keys:** Never. All credentials via n8n credential store.
