# Directive 03 — NT Reading Reminder (WF03)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 2 times daily · Mon–Fri only
**Channel:** Telegram only
**Tone:** Faith — reverent, energising

---

## Purpose

Guide Akinwunmi through the daily NT reading using the 14-day repeating cycle (~18 chapters/day). Names exact books and chapter ranges.

---

## Schedule (WAT)

| Time | Cron | Message Type |
|------|------|-------------|
| 6:25 AM | `25 6 * * 1-5` | Pre-task — names books + chapters |
| 7:15 AM | `15 7 * * 1-5` | Midpoint — encouragement |

---

## NT 14-Day Cycle (from skills.md §10)

**Formula:** `ntDay = ((dayNum - 1) % 14) + 1`

Uses `NT_14DAY` mapping with `{book, from, to}` segments. Total chapters per day varies from ~14 to ~28.

---

## Workflow Nodes

1. **Schedule Trigger** — Mon–Fri
2. **Code Node — Day Counter** + **Weekend Guard**
3. **Code Node — NT Day Calculator** — 14-day cycle → segments, totalChapters, label
4. **Supabase GET** — Config + daily_log
5. **Pause Check**
6. **Supabase GET** — Last 7 interactions
7. **OpenRouter** → Claude
8. **Telegram** → Send
9. **Supabase POST** → interactions

---

## Claude System Prompt

```
Generate a {message_type} for NT reading on Weekday {day_number} (NT Cycle Day {nt_day}).
Today's assignment: {nt_label} (~{totalChapters} chapters)

- Pre-task: Name exact books + chapter ranges. "The Word is alive."
- Midpoint: Encourage + ask a reflection question
- Include scripture on the power of God's Word
- 100–250 words. Tone: reverent, energising.
```
