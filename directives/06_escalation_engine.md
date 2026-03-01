# Directive 06 — Escalation Engine (WF06)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — every 30 min · Mon–Fri · 3:00 AM–11:30 PM WAT
**Channel:** Telegram only
**Tone:** Escalates warm → direct → full accountability

---

## Escalation Levels

| Level | Trigger | Tone |
|-------|---------|------|
| 0 | No issue | No message |
| 1 | Task window open, no check-in within 30 min | Warm nudge |
| 2 | 60 min past start, no completion | Firmer |
| 3 | Task window closed, not logged | Direct — names task |
| 4 | 3+ tasks missed in one day | Full accountability — $100K target |

---

## Career-Specific Escalation (phase-aware)

| Phase | Trigger | Level |
|-------|---------|-------|
| 1 | proposals_sent = 0 by 12:00 PM | Level 2 immediately |
| 2 | No calls scheduled by 2:00 PM | Level 1 |
| 3 | No discovery call/proposal by 3:00 PM | Level 2 |

---

## Task Windows

| Task | Start | End |
|------|-------|-----|
| prayer_session_1 | 3:00 | 4:30 |
| coding_block_1 | 4:25 | 6:25 |
| nt_reading | 6:30 | 7:45 |
| book_of_day | 8:00 | 10:00 |
| career_block_a | 9:00 | 11:00 |
| career_block_b | 12:00 | 14:00 |
| coding_block_2 | 14:00 | 16:00 |
| prayer_session_2 | 17:00 | 18:30 |
| career_block_c | 19:30 | 21:00 |
| coding_block_3 | 21:30 | 23:00 |

---

## Workflow Nodes

1. **Schedule Trigger** — `*/30 3-23 * * 1-5` (Mon–Fri)
2. **Supabase GET** — Config (pause, active, revenue_phase)
3. **IF Node — Pause/Weekend Check**
4. **Code Node — Day Counter**
5. **Supabase GET** — Today's daily_log
6. **Code Node — Task Window Checker + Career Escalation Logic**
7. **Supabase GET** — Escalations for today
8. **Code Node — Compare expected vs actual**
9. **IF Node — Any escalation?**
10. **OpenRouter** → Claude
11. **Telegram** → Send
12. **Supabase PATCH** → escalations
13. **Supabase POST** → interactions

---

## Rules

- Never fire 00:00–02:59 (sleep window)
- One escalation per task per level per day
- Career escalation reads revenue_phase from config
