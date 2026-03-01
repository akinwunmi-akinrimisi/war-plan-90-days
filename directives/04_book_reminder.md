# Directive 04 — Book Reminder (WF04)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 2 times daily · Mon–Fri only
**Channel:** Telegram only
**Tone:** Coach — ambitious, builder-focused

---

## Purpose

Activate Akinwunmi for the daily book reading. One book per day, 50 pages target, 2 hours total. Morning start + evening finish reminder. Ties reading to Operscale, Cloudboosta, and business building.

---

## Schedule (all times WAT)

| Time | Message Type |
|------|-------------|
| 7:55 AM | Morning start — "Today's book. 50 pages. Go." |
| 6:25 PM | Evening finish — "Wrap up notes tonight" |

---

## Workflow Nodes

1. **Schedule Trigger** — `55 7 * * 1-5`, `25 18 * * 1-5` (Mon–Fri)
2. **Code Node — Day Counter** — Weekday number + isWeekend
3. **IF Node — Weekend Guard**
4. **Supabase GET** — Config (pause) + daily_log (today's book_title, book_pages)
5. **IF Node — Pause Check**
6. **Supabase GET** — Last 7 interactions for dedup
7. **HTTP Request — OpenRouter** — Claude generates message
8. **Telegram Node** — Send
9. **Supabase POST** — Log to interactions

---

## Context Packet

```json
{
  "day_number": "<weekday 1-90>",
  "task": "book_of_day",
  "tone_mode": "coach_builder",
  "message_type": "pre_task",
  "quote_source": "business_quote",
  "user_name": "Akinwunmi",
  "completion_stats": {
    "books_read_total": "<cumulative>",
    "book_pages_today": 0,
    "book_title_today": ""
  }
}
```

---

## Claude System Prompt

```
You are the business coach for Akinwunmi's 90-Day War Plan.
Generate a reminder for book_of_day on Weekday {day_number}.

Rules:
- Morning (pre_task): "One book today. 50 pages. Deep reading builds deep businesses."
- Evening (post_task): "Did you finish today's book notes? Write what you'll apply tomorrow."
- Include one business/personal development quote (Hormozi, Naval, Drucker, Munger, etc.)
- Tie reading to Operscale, Cloudboosta, or AI automation
- If book_title is set from yesterday, ask "What's today's book?"
- Never repeat quotes from recent_messages
- Word count: 100–250 words
- Tone: direct, ambitious — a mentor who reads voraciously
```

---

## Error Handling

- Claude fails → static: "Day {day}. One book. 50 pages. Naval: 'Read what you love until you love to read.' Go."
