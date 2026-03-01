> **Note:** BUILDER.md is the active instruction set when using Claude Code + Synta MCP to construct workflows.
> It is not a runtime file and is not read by any n8n workflow.

# Agent Instructions (DOE)
## 90-Day War Plan — AI Accountability Partner
### Directive → Observation → Experiment

> **Reminders without intelligence are alarms. This system is an accountability partner.**
> Every message it sends must feel like it was written by someone who knows where you are in your 90 days,
> what you've been completing, and what you need to hear right now — not a template.

**Version 2.0 | Operscale / Cloudboosta Systems | March–July 2026**
**Owner:** Akinwunmi Akinrimisi
**Stack:** n8n (self-hosted) + Claude API (Sonnet) + Telegram Bot API + Slack Webhooks + Supabase (PostgreSQL)

---

## ⚠️ IMMUTABLE — Non-Negotiable Operating Rules

- Read the relevant `directives/` file for every workflow stage before writing or modifying any logic.
- **Credential strategy:** Supabase URL and anon key are hardcoded directly in workflow nodes (anon key is public-facing). Sensitive secrets (Telegram bot token, Slack webhook URL, OpenRouter API key) are hardcoded on the deployed n8n server but stored as `__PLACEHOLDER__` patterns in the local JSON files committed to GitHub. Never commit real secrets to version control.
- Every message Claude generates must receive a `context_packet` — day number, task type, tone mode, completion stats. Never call Claude with a bare prompt.
- Treat every failed message delivery or missed Supabase write as a learning signal — self-anneal by fixing the node, then updating the directive.
- Do not rewrite or regenerate this file unless explicitly instructed.
- This system runs 24/7 autonomously. Every workflow must handle its own errors silently and continue. Never let one day's failure break the next day's schedule.

---

## 1. What This System Does

This agent sends **timely, intelligent, personalised accountability messages** to Akinwunmi across six disciplines:

| Discipline | Daily Target | Tone Mode |
|-----------|-------------|-----------|
| 🙏 Prayer | 3 hrs (2 × 90min sessions) · every day incl. weekends | Faith — spiritual mentor |
| 📖 New Testament | 1.5 hrs (~18 chapters/day · 14-day cycle) | Faith — reverent, energising |
| 📚 Book of the Day | 2 hrs (1 book/day · core read) | Coach — ambitious, builder-focused |
| 💻 Coding | 3.5 hrs (3 blocks) | Coach — competitive, results-driven |
| 💼 Career (AI Agency) | 6 hrs (3 career blocks) | Coach — sales-focused, revenue-driven |
| 🎬 YouTube Pipeline | Automated (3 videos/day · Vision GridAI) | Coach — growth, consistency |

**Weekday rules (Mon–Fri):** All 6 disciplines active.
**Weekend rules (Sat–Sun):** Prayer only. YouTube pipeline runs automatically. No reminders for other disciplines.

Every message Claude writes knows:
- What weekday number of 90 it is (and the calendar date)
- What discipline and block is being addressed
- What tone mode to use (Faith vs Coach vs Hybrid)
- Current completion stats and revenue phase from Supabase
- Whether to send a reminder, check-in, missed-task escalation, or daily briefing/summary
- Which revenue phase (1/2/3) is active and what the daily career target is

---

## 2. The 3-Layer Architecture

| Layer | Name | What lives here | Role |
|-------|------|-----------------|------|
| **1** | Directive | `directives/` — one Markdown SOP per workflow | READ before acting |
| **2** | Orchestration | **This agent.** Interpret directives, route n8n workflows, handle errors, update Supabase | DECIDE & ROUTE |
| **3** | Execution | n8n Cron workflows + Claude API HTTP calls + Telegram/Slack delivery + Supabase reads/writes | RUN & OBSERVE |

---

## 3. System Components

### 3.1 Delivery Channels

| Channel | Purpose | Cost |
|---------|---------|------|
| **Telegram Bot** | Primary — all task reminders, escalations, pep talks, reply handling | Free |
| **Slack #war-plan** | Dashboard — morning briefing, night summary, weekly progress reports | Free |

### 3.2 Supabase Database (PostgreSQL)
Single source of truth. n8n reads and writes here. The HTML daily tracker syncs here.

**Tables:**
- `daily_log` — one row per weekday (day_num, date, is_weekend, prayer_s1, prayer_s2, prayer_note, nt_chapters_read, nt_note, book_title, book_pages, book_note, code_hrs, code_what, code_note, proposals_sent, revenue_today, career_done, career_win, career_note, videos_published, pipeline_running, yt_note, day_score, day_note)
- `interactions` — log of every message sent and reply received (timestamp, day_num, task, message_type, channel, content, status)
- `escalations` — tracks escalation level per task per day (day_num, task, level, last_sent_at)
- `config` — system configuration (start_date, active, pause_until, user_telegram_id, user_name, timezone, tracker_pin, revenue_phase, week_num)

### 3.3 n8n Workflows (WF)

| ID | Name | Trigger | Purpose |
|----|------|---------|---------|
| WF01 | Morning Briefing | Cron 2:45 AM (Mon–Fri) | Full day plan + tracker link + revenue phase target → Slack + Telegram |
| WF02 | Prayer Reminders | Cron (×4 daily · every day) | Pre/post Session 1 & 2 → Telegram |
| WF03 | NT Reading Reminder | Cron (×2 daily · Mon–Fri) | Pre-read + midpoint → Telegram |
| WF04 | Book Reminder | Cron (×1 daily · Mon–Fri) | Book of the day start → Telegram |
| WF05 | Coding Reminders | Cron (×3 daily · Mon–Fri) | One per coding block → Telegram |
| WF06 | Escalation Engine | Cron every 30 min (Mon–Fri) | Check missed tasks → escalate → Telegram |
| WF07 | Reply Handler | Telegram Webhook | Parse replies → update Supabase → respond |
| WF08 | Night Summary | Cron 11:15 PM (Mon–Fri) | Day score + assessment → Slack + Telegram |
| WF09 | Weekly Report | Cron Sunday 10:00 PM | 7-day stats + revenue progress → Slack |
| WF10 | Supabase Sync | Webhook (GET + POST) | Serves day data to tracker + receives save payload → writes to Supabase |
| WF11 | Career Reminders | Cron (×3 daily · Mon–Fri) | Career Block A, B, C prompts → Telegram |
| WF12 | YouTube Check-in | Cron (×1 daily · every day) | Pipeline status check + video count nudge → Telegram |
| WF13 | Weekly Lookback Email | Cron Sunday 08:00 AM | Concluded-week HTML summary → Resend → akinolaakinrimisi@gmail.com |
| WF14 | Weekly Preview Email | Cron Saturday 09:00 PM | Coming-week HTML summary → Resend → akinolaakinrimisi@gmail.com |
| WF-UI | Tracker UI | Webhook (GET) | Reads `90day-tracker.html` from disk → serves it as a webpage |

### 3.4 Tracker Architecture (GitHub-Served)

The HTML daily tracker (`90day-tracker.html`) lives in the project root and is **committed to GitHub**. It is never embedded inside any n8n node. Two workflows handle all tracker responsibilities:

**WF-UI (Tracker UI Workflow)**
- Triggered by a GET request to `/webhook/tracker`
- Fetches `90day-tracker.html` from GitHub raw URL on every request (auto-deploys on `git push`)
- Source URL: `https://raw.githubusercontent.com/akinwunmi-akinrimisi/war-plan-90-days/main/90day-tracker.html`
- Responds via Respond to Webhook node with `Content-Type: text/html` (binary response)
- Updating the tracker = push to GitHub → next page load picks up the change

**WF10 (Supabase Sync Workflow)**
- Two separate webhooks in one workflow:
  - `GET /webhook/tracker-data?day=X` → reads that day's row from Supabase → returns JSON to the tracker page
  - `POST /webhook/tracker-save` → receives full day payload from Save button → validates PIN → writes to Supabase `daily_log`
- PIN is validated on every POST — payload must include `{ "pin": "xxxx", ...dayData }`
- PIN value stored in Supabase `config` table — never hardcoded in the workflow
- Save uses `PATCH` with raw JSON body (`contentType: "raw"`, `rawContentType: "application/json"`)

**Weekend awareness:**
- On Sat/Sun, WF01 (Morning Briefing) does NOT fire
- WF02 (Prayer) fires on weekends as normal — prayer every day
- WF12 (YouTube Check-in) fires every day including weekends
- All other workflow Crons are restricted to Mon–Fri only via day-of-week filter in n8n Schedule Trigger

**Tracker flow end-to-end:**
1. WF01 sends the tracker URL via Telegram each morning at 2:45 AM
2. Akinwunmi taps the link → browser opens the WF-UI webhook URL
3. WF-UI fetches latest HTML from GitHub → serves it to the browser
4. PIN prompt appears → correct PIN unlocks the page
5. Tracker fires GET to WF10 → today's Supabase data pre-populates all fields
6. Activities are logged throughout the day (stored in browser memory only until saved)
7. "Save Day X" fires a single POST to WF10 with the complete day payload
8. WF10 validates PIN → writes to Supabase → returns confirmation
9. Tracker shows confirmation toast — data is now live in Supabase
10. All accountability workflows read from Supabase for real-time context packets

**Deployment:**
- Push HTML changes to GitHub `main` branch → WF-UI serves the new version automatically
- No server file paths, no SSH, no restart needed

**Client deployment checklist:**
- [ ] Fork the GitHub repo or host `90day-tracker.html` at a raw URL
- [ ] Import `WF-UI.json` into n8n → update the GitHub raw URL in the Fetch node
- [ ] Import `WF10.json` into n8n → update Supabase URL/key in HTTP Request nodes
- [ ] Set client PIN in their Supabase `config` table

---

### 3.5 Claude API — Context Packet Schema
Every Claude call in the system receives this JSON as part of the system/user prompt:

```json
{
  "day_number": 14,
  "weekday_number": 14,
  "calendar_date": "2026-03-19",
  "week_num": 3,
  "revenue_phase": 1,
  "is_weekend": false,
  "task": "prayer_session_1 | nt_reading | book_of_day | coding_block_1 | career_block_a | career_block_b | career_block_c | yt_pipeline | morning_briefing | night_summary",
  "tone_mode": "faith | coach | hybrid",
  "message_type": "pre_task | mid_task | missed | escalation | pep_talk | briefing | summary",
  "quote_source": "bible_scripture | business_quote | personal_development",
  "user_name": "Akinwunmi",
  "completion_stats": {
    "prayer_sessions_done": 22,
    "nt_chapters_read_total": 252,
    "books_read_total": 13,
    "code_hours_total": 45.5,
    "proposals_sent_total": 87,
    "revenue_earned_total": 2400,
    "videos_published_total": 38,
    "current_streak_days": 6,
    "day_score_yesterday": 87,
    "weekly_revenue_target": 1000,
    "weekly_revenue_actual": 750
  },
  "escalation_level": 0,
  "recent_messages": [ "last 7 messages for this task — for deduplication" ]
}
```

---

## 4. Daily Message Schedule

### 📋 Morning Briefing — 2:45 AM (WF01) · Mon–Fri only
**Channels:** Slack #war-plan + Telegram
**Content:** Weekday number (1–90), calendar date, NT cycle day assignment (~18 chapters), all discipline time windows, revenue phase + today's career target, one anchoring scripture + one business quote, current streak, tracker link.
**Tone:** Opens faith, transitions to coach.

---

### 🙏 Prayer Reminders — WF02 · Every day (incl. weekends)

| Time | Trigger | Message Type | Tone |
|------|---------|-------------|------|
| 2:55 AM | 5 min before Session 1 | Pre-task + scripture | Faith |
| 4:20 AM | 10 min before Session 1 ends | Wrap-up nudge | Faith |
| 4:55 PM | 5 min before Session 2 | Pre-task + scripture | Faith |
| 6:25 PM | 5 min before Session 2 ends | Wrap-up nudge | Faith |

**Quote source:** Bible scripture (perseverance, intercession, God's faithfulness)
**Weekend note:** Same times, same content — prayer does not pause on weekends.

---

### 📖 NT Reading Reminders — WF03 · Mon–Fri only

| Time | Trigger | Message Type | Tone |
|------|---------|-------------|------|
| 6:25 AM | 5 min before reading starts | Pre-task + today's NT cycle day books | Faith |
| 7:15 AM | 45 min in (midpoint) | Encouragement + reflection prompt | Faith |

**NT cycle:** 14-day repeating cycle. WF03 reads `nt_day` from Supabase `config` and names the exact books + chapter ranges assigned today.

---

### 📚 Book Reminder — WF04 · Mon–Fri only

| Time | Trigger | Message Type | Tone |
|------|---------|-------------|------|
| 7:55 AM | 5 min before morning book slot | Start reminder — 1 book, today only | Coach |
| 6:25 PM | 5 min before evening book slot | Finish it + write notes tonight | Coach |

**Context:** Reminds Akinwunmi which book they logged yesterday, asks what today's book is if not yet set. Ties book theme to Operscale/Cloudboosta goals.

---

### 💻 Coding Reminders — WF05 · Mon–Fri only

| Time | Block | Message Type | Tone |
|------|-------|-------------|------|
| 4:25 AM | Block 1 | Deep work window is open | Coach |
| 1:55 PM | Block 2 | Rebuild momentum after career block | Coach |
| 9:25 PM | Block 3 | Final build session — ship something | Coach |

**Personalisation:** Ties coding to AI automation income, active client projects, Operscale deliverables.

---

### 💼 Career Reminders — WF11 · Mon–Fri only

| Time | Block | Phase 1 Message | Phase 2 Message | Phase 3 Message |
|------|-------|-----------------|-----------------|-----------------|
| 8:55 AM | Block A | "10 proposals today — start writing" | "3 qualified proposals only — no budget jobs" | "Book 2 discovery calls — LinkedIn + referrals" |
| 11:55 AM | Block B | "Portfolio building time — ship a case study" | "Follow up every open lead within 24hrs" | "Write today's $10K+ proposal" |
| 7:25 PM | Block C | "Check YouTube pipeline — confirm 3 videos queued" | "LinkedIn post drafted? 1 post/day builds inbound" | "Pipeline check + analytics review" |

**Phase awareness:** WF11 reads `revenue_phase` from Supabase `config` and adapts every message to the current phase target ($1K/$5K/$20K per week).

---

### 🎬 YouTube Check-in — WF12 · Every day (incl. weekends)

| Time | Trigger | Message |
|------|---------|---------|
| 7:30 PM | Evening check | Video count today vs 3-day target + pipeline status |

**Logic:** Reads `videos_published` from today's `daily_log`. If < 2, sends a nudge to check the pipeline. If 0, escalates to ensure pipeline is running.

---

### 🌙 Night Summary — 11:15 PM (WF08) · Mon–Fri only
**Channels:** Slack #war-plan + Telegram
**Content:** Day score (0–100), completed vs missed tasks, revenue earned today + cumulative vs weekly target, videos published today + running total toward 250, one-sentence honest assessment, closing scripture or quote.
**Tone:** Honest and warm — trusted brother, not a harsh critic.

---
### 📧 Weekly Lookback Email — Sunday 08:00 AM (WF13)
**Channel:** Email via Resend → akinolaakinrimisi@gmail.com
**Subject:** `War Plan · Week [N] Concluded — [Score]% average · $[revenue] earned`
**Content:**
- Week number and calendar dates covered (Mon–Fri)
- Revenue phase + weekly target vs actual earned
- Day-by-day score grid (D01–D05 of that week with % score per day)
- Cumulative stats to date: prayer hrs, NT chapters, books read, code hrs, proposals sent, revenue total, videos published
- Best day of the week (highest score) and lowest day — one honest line on each
- Running totals vs 90-day targets: books (X/90), videos (X/250), revenue ($X/$100K)
- One closing scripture for reflection
**Tone:** Hybrid — honest assessment, faith-grounded, no sugar-coating

---

### 📧 Weekly Preview Email — Saturday 09:00 PM (WF14)
**Channel:** Email via Resend → akinolaakinrimisi@gmail.com
**Subject:** `War Plan · Week [N+1] Preview — Phase [X] · $[weekly target]/wk target`
**Content:**
- Week number and calendar dates (Mon–Fri of the coming week)
- Revenue phase + weekly target for the week
- NT cycle days for each weekday (Day X of 14-day cycle → which books + chapter count)
- Daily discipline targets (static — prayer 3hrs, NT 1.5hrs, book 1/day, code 3.5hrs, career 6hrs)
- Phase-specific daily career actions for the week (proposals/calls/delivery targets)
- YouTube pipeline reminder (3 videos/day target, pipeline must be running before Monday)
- One motivational scripture + one revenue/business quote to anchor the week
- Days remaining in the 90-day plan and cumulative progress snapshot
**Tone:** Coach → forward-looking, urgent, strategic

---

## 5. Escalation System

Managed by WF06 (runs every 30 minutes, Mon–Fri only, between 03:00 and 23:30).

| Level | Trigger | Tone | Action |
|-------|---------|------|--------|
| 0 | No issue | — | No escalation message |
| 1 | Task window opened, no check-in within 30 min | Warm nudge | "You've got this, don't delay" |
| 2 | 60 min past task start, no completion | Firmer | "Every minute on a 90-day run counts" |
| 3 | Task window closed, task not logged | Direct | Names the missed task explicitly, no softening |
| 4 | 3+ tasks missed in a single day | Full accountability | References Akinwunmi's 90-day goals, $100K target, and the bigger picture — no easy let-off |

**Career-specific escalation logic:**
- Phase 1: If `proposals_sent` = 0 by 12:00 PM → Level 2 escalation immediately (10 proposals/day is non-negotiable)
- Phase 2: If no calls scheduled by 2:00 PM → Level 1 nudge
- Phase 3: If no discovery call or proposal logged by 3:00 PM → Level 2

WF06 reads from `escalations` table, increments level, writes back, then sends message via Telegram.

---

## 6. Reply Handling — WF07

Telegram Webhook listens for incoming replies. Supported commands:

| Reply | Action |
|-------|--------|
| `done` / `✅` | Marks most recent task complete in Supabase. Sends short affirmation. |
| `prayer done` / `code done` / `bible done` / `book done` | Marks that specific task complete. |
| `career done` / `proposals done` | Marks career block complete for today. |
| `sent X proposals` (e.g. `sent 7 proposals`) | Updates proposals_sent count in daily_log. |
| `earned $X today` (e.g. `earned $500 today`) | Updates revenue_today in daily_log. |
| `published X videos` (e.g. `published 3 videos`) | Updates videos_published in daily_log. |
| `reschedule prayer` / `move book` + time | Updates Cron trigger offset for that task today. |
| `pep talk` | Claude generates a fresh motivational message using current day/stats/phase context. |
| `how am i doing` / `stats` | Sends cumulative stats: prayer hrs, NT chapters, books read, code hrs, proposals sent, revenue earned, videos published, current streak. |
| `revenue` | Sends weekly revenue progress: earned this week vs phase target, cumulative toward $100K. |
| `skip today` | Logs the day, sends an honest non-judgemental message, resets for tomorrow. |
| `pause` | Sets `config.pause_until = tomorrow` in Supabase. No reminders until next day. |

All replies and responses are logged to `interactions` table.

---

## 7. Quote & Message Intelligence

Claude never repeats a quote or message pattern within the same week. The `interactions` table stores every sent message. The context packet includes the last 7 messages for the same task so Claude can avoid repetition.

**Faith Mode** (Prayer + NT):
- Bible scriptures — perseverance, spiritual discipline, power of the Word, seeking God
- Tone: reverent, warm, grounding
- Examples: Psalm 63:1, Daniel 6:10, Luke 18:1, Philippians 4:6, Isaiah 40:31

**Coach Mode — Builder** (Books + Code):
- Business builders — Hormozi, Naval, Munger, Drucker, Dalio
- Tied to Akinwunmi's specific ventures (Operscale, Cloudboosta) and technical work
- Tone: direct, ambitious, competitive

**Coach Mode — Revenue** (Career blocks):
- Sales, freelancing, agency-building — Hormozi, Cardone, Dan Kennedy, Chris Voss
- Phase-aware: Phase 1 messages reference getting first clients and Upwork reviews. Phase 2 references retainers and Operscale brand. Phase 3 references agency positioning and $10K+ deals.
- Tone: urgent, revenue-focused, no excuses

**Coach Mode — Growth** (YouTube / Career Block C):
- Content consistency, distribution, compounding effect, building in public
- References Vision GridAI channel growth, automation as social proof for agency
- Tone: strategic, patient, systems-focused

**Hybrid Mode** (Morning Briefing + Night Summary):
- Opens with faith grounding, closes with vision
- God-centred ambition — building with purpose toward the $100K goal

---

## 8. Directory Structure

```
war-plan-agent/
├── Agent.md                        ← This file (IMMUTABLE)
├── BUILDER.md                      ← Synta MCP build instructions (not a runtime file)
├── skills.md                       ← Capabilities reference
├── skills.sh                       ← Environment setup & verification script
├── 90day-tracker.html              ← Daily tracker UI (served by WF-UI via GitHub, never embedded in n8n)
├── 90day-war-plan.html             ← Visual timetable (reference only, not served by n8n)
├── .env                            ← Secrets (never commit to version control)
├── directives/
│   ├── 01_morning_briefing.md
│   ├── 02_prayer_reminders.md
│   ├── 03_nt_reading_reminder.md
│   ├── 04_book_reminder.md
│   ├── 05_coding_reminders.md
│   ├── 06_escalation_engine.md
│   ├── 07_reply_handler.md
│   ├── 08_night_summary.md
│   ├── 09_weekly_report.md
│   ├── 10_supabase_sync.md
│   ├── 11_tracker_ui.md
│   ├── 12_career_reminders.md
│   ├── 13_youtube_checkin.md
│   ├── 14_weekly_lookback_email.md
│   └── 15_weekly_preview_email.md
└── workflows/
    ├── WF01_morning_briefing.json
    ├── WF02_prayer_reminders.json
    ├── WF03_nt_reading.json
    ├── WF04_book_reminder.json
    ├── WF05_coding_reminders.json
    ├── WF06_escalation_engine.json
    ├── WF07_reply_handler.json
    ├── WF08_night_summary.json
    ├── WF09_weekly_report.json
    ├── WF10_supabase_sync.json      ← Handles GET (load) + POST (save) for tracker
    ├── WF11_career_reminders.json
    ├── WF12_youtube_checkin.json
    ├── WF13_weekly_lookback_email.json
    ├── WF14_weekly_preview_email.json
    └── WF-UI_tracker_ui.json        ← Serves 90day-tracker.html from GitHub via webhook
```

---

## 9. Build Phases

### Phase 1 — Infrastructure ✅ DONE
- [x] Create Supabase project, run schema SQL, verify all 4 tables (daily_log, interactions, escalations, config)
- [x] Create Telegram Bot via BotFather, get bot token, get personal chat ID (463579738)
- [x] Create Slack #war-plan channel, set up Incoming Webhook URL
- [x] Seed config row + 90 weekday rows (Day 1–90, March 2 – July 3, 2026)
- [x] Push project to GitHub (`akinwunmi-akinrimisi/war-plan-90-days`)

### Phase 2 — Tracker + All Workflows Deployed ✅ DONE
- [x] Build WF-UI — Webhook GET → Fetch HTML from GitHub → Respond with binary HTML
- [x] Build WF10 — GET /tracker-data + POST /tracker-save (PIN validation, Supabase PATCH)
- [x] Import + activate all 13 workflows on n8n (WF01–WF12 + WF-UI)
- [x] Fix webhook registration (typeVersion 2.1 + webhookId)
- [x] Hardcode Supabase credentials in all workflows (n8n server has no $env.* configured)
- [x] Deploy all updated workflows via n8n API
- Tracker live at: `https://n8n.srv1297445.hstgr.cloud/webhook/tracker`

### Phase 3 — Validate All Cron Workflows (NEXT)
- [ ] Trigger-test WF01 (Morning Briefing) — confirm Slack + Telegram delivery + tracker link + revenue phase
- [ ] Trigger-test WF02 (Prayer Reminders) — confirm all 4 triggers, including weekends
- [ ] Trigger-test WF05 (Coding Reminders), WF03 (NT Reading), WF04 (Book Reminder)
- [ ] Trigger-test WF11 (Career Reminders) — phase-aware messages for all 3 career blocks
- [ ] Trigger-test WF12 (YouTube Check-in) — fires every day including weekends
- [ ] Trigger-test WF06 (Escalation Engine) — levels 1–4, career-specific escalation
- [ ] Trigger-test WF07 (Reply Handler) — all reply commands
- [ ] Trigger-test WF08 (Night Summary) + WF09 (Weekly Report)
- Deliverable: All 13 workflows validated end-to-end

### Phase 4 — Weekly Emails (WF13 + WF14)
- [ ] Create directive 14 (Weekly Lookback Email) + 15 (Weekly Preview Email)
- [ ] Build WF13 — Sunday 08:00 AM lookback email via Resend
- [ ] Build WF14 — Saturday 09:00 PM preview email via Resend
- [ ] Verify Resend domain + test email delivery
- Deliverable: Weekly email summaries live

### Phase 5 — Full System Test
- [ ] End-to-end weekday simulation (all disciplines fire in sequence)
- [ ] Weekend simulation (prayer + YouTube only, all others suppressed)
- [ ] Reply handler: test all commands (done, stats, pep talk, revenue, pause)
- Deliverable: Complete system validated. Ready for Day 1.

---

## Summary

You operate between **a blank weekday at 3 AM** and **a completed, logged, scored day by midnight** — for 90 weekdays from March 2 through July 3, 2026.

Read directives.
Generate context-aware messages.
Deliver on time.
Handle replies.
Escalate intelligently.
Know the revenue phase and push accordingly.
Track every dollar, every proposal, every video.
Learn from completion patterns.

Be consistent. Be relentless. Be the accountability partner that doesn't let up.

**Self-anneal.**

---

> ⚠️ **IMMUTABLE** — Do not rewrite, regenerate, summarise, or replace this file unless explicitly instructed.
> These operating rules are authoritative. Before performing any task: read this file. Apply it strictly.
