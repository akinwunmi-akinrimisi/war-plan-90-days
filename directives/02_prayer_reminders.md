# Directive 02 — Prayer Reminders (WF02)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 4 times daily · Every day including weekends
**Channel:** Telegram only
**Tone:** Faith — spiritual mentor

---

## Purpose

Guide Akinwunmi into both daily prayer sessions. Prayer never pauses — runs every day including weekends.

---

## Schedule (WAT)

| Time | Session | Cron | Message Type |
|------|---------|------|-------------|
| 2:55 AM | Session 1 | `55 2 * * *` | Pre-task |
| 4:20 AM | Session 1 | `20 4 * * *` | Wrap-up |
| 4:55 PM | Session 2 | `55 16 * * *` | Pre-task |
| 6:25 PM | Session 2 | `25 18 * * *` | Wrap-up |

**Weekend rule:** Same times, same content. Do NOT reference work, books, proposals, coding, or revenue in weekend messages.

---

## Workflow Nodes

1. **Schedule Trigger** — 4 cron expressions (every day `* * *`)
2. **Code Node — Day Counter** — Weekday number + isWeekend flag
3. **Code Node — Determine Session** — Set task + message_type from trigger time
4. **Supabase GET** — Config (pause) + daily_log (prayer status today)
5. **IF Node — Pause Check**
6. **IF Node — Already Done?** — Skip post-task if session complete
7. **Supabase GET** — Last 7 interactions for dedup
8. **HTTP Request — OpenRouter** — Claude generates message (pass isWeekend flag)
9. **Telegram Node** — Send
10. **Supabase POST** — Log to interactions

---

## Claude System Prompt

```
You are the spiritual accountability partner for Akinwunmi's 90-Day War Plan.
Generate a {message_type} for {task} on Day {day_number}.

Rules:
- Always include a Bible scripture (book chapter:verse)
- Themes: perseverance, intercession, seeking God, spiritual warfare
- Pre-task: energise — "The throne room is open"
- Post-task: affirm — "You showed up. God honours that."
- If is_weekend=true: prayer ONLY language. No work references.
- Never repeat a quote from recent_messages
- 100–250 words. Tone: reverent, warm.
```

---

## Error Handling

- Claude fails → "Day {day}. Prayer time. Psalm 63:1 — 'O God, You are my God; early will I seek You.'"
