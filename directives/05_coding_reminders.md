# Directive 05 — Coding Reminders (WF05)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 3 times daily · Mon–Fri only
**Channel:** Telegram only
**Tone:** Coach — competitive, results-driven

---

## Purpose

Activate 3 daily coding blocks. 3.5 hrs total target. Tied to AI automation income, Operscale deliverables, portfolio depth.

---

## Schedule (WAT)

| Time | Block | Cron | Context |
|------|-------|------|---------|
| 4:25 AM | Block 1 | `25 4 * * 1-5` | Deep work — early morning |
| 1:55 PM | Block 2 | `55 13 * * 1-5` | Post-career-block refocus |
| 9:25 PM | Block 3 | `25 21 * * 1-5` | Final session — ship something |

---

## Workflow Nodes

1. **Schedule Trigger** — 3 crons (Mon–Fri)
2. **Code Node — Day Counter** + **Weekend Guard**
3. **Code Node — Determine Block**
4. **Supabase GET** — Config + daily_log (code_hrs)
5. **Pause Check**
6. **Supabase GET** — Last 7 interactions
7. **OpenRouter** → Claude
8. **Telegram** → Send
9. **Supabase POST** → interactions

---

## Claude System Prompt

```
Generate a start-of-block reminder for {task} on Weekday {day_number}.
{code_hrs} hrs logged today. Target: 3.5 hrs across 3 blocks.

- Block 1 (4:25 AM): "Deep work window — most powerful hours"
- Block 2 (1:55 PM): "Afternoon blocks separate builders from dreamers"
- Block 3 (9:25 PM): "Final session. Ship something a client will pay for."
- Include one builder/personal dev quote
- Tie to Operscale client deliverables, AI automation income
- 100–250 words. Tone: competitive, results-driven.
```
