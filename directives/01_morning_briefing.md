# Directive 01 — Morning Briefing (WF01)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 2:45 AM WAT · Mon–Fri only
**Channels:** Slack #war-plan + Telegram
**Tone:** Hybrid (faith opening, coach closing)

---

## Purpose

Deliver the full day plan before the day begins. Includes revenue phase target, NT 14-day cycle assignment, career focus, and tracker link.

---

## Workflow Nodes

1. **Schedule Trigger** — Cron: `45 2 * * 1-5` (Mon–Fri, Africa/Lagos)
2. **Code Node — Day Counter** — Weekday number (1–90), week_num, isWeekend
3. **IF Node — Weekend Guard** — Stop if isWeekend
4. **Code Node — NT Day Calculator** — 14-day cycle → books + chapter ranges
5. **Code Node — Revenue Phase** — `getRevenuePhase(weekNum)` → $1K/$5K/$20K target
6. **Supabase GET** — `config` (pause, revenue_phase) + yesterday's `daily_log`
7. **IF Node — Pause Check**
8. **HTTP Request — OpenRouter** — Claude generates briefing
9. **Telegram Node** — Send
10. **HTTP Request — Slack Webhook** — Post to #war-plan
11. **Supabase POST** — Log to `interactions`

---

## Claude System Prompt

```
You are the AI accountability partner for Akinwunmi's 90-Day War Plan.
Generate a morning briefing for Weekday {day_number} of 90 (Week {week_num}).

Include:
1. Grounding opening — one Bible scripture (book chapter:verse)
2. Today's date, weekday number (of 90), week number (of 18)
3. NT reading: {nt_label} (~{totalChapters} chapters)
4. Full schedule: Prayer S1 → Code B1 → NT → Book → Career A → Career B → Code B2 → Prayer S2 → Career C → Code B3
5. Revenue Phase {revenue_phase}: weekly target ${weekly_target}. Earned: ${weekly_actual}
6. Current streak and yesterday's score
7. One business quote tied to Operscale/Cloudboosta/Vision GridAI
8. Tracker link: {tracker_url}

Tone: Open reverence, close with fire. Building for God and for $100K.
300–500 words.
```

---

## Message Must Include

- Tracker URL: `{N8N_URL}/webhook/tracker`
- Weekday number (1–90) and calendar date
- Week number and revenue phase + target
- NT assignment (books + chapter ranges)
- Full time-blocked schedule (all 6 disciplines)
- One scripture + one business quote

---

## Error Handling

- Claude fails → fallback briefing with dynamic day/date/phase
- Telegram fails → retry once after 60s → log failed
- Slack fails → log warning only
