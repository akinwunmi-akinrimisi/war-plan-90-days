# Directive 15 — Weekly Preview Email (WF14)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — Saturday 09:00 PM WAT
**Channel:** Email via Resend → akinolaakinrimisi@gmail.com
**Tone:** Coach — forward-looking, urgent, strategic

---

## Purpose

Coming-week HTML preview email. Delivered every Saturday evening so Akinwunmi enters Monday with a clear plan, correct NT assignments, and the right revenue targets.

---

## Workflow Nodes

1. **Schedule Trigger** — `0 21 * * 6` (Saturday 21:00, Africa/Lagos)
2. **Code Node — Day Counter** — Next week's number, calendar date range (Mon–Fri)
3. **Supabase GET** — Config (current revenue_phase, week_num) + cumulative stats
4. **Code Node — NT Assignments** — Calculate NT cycle days for each weekday of the coming week
5. **Code Node — Phase Targets** — Revenue phase actions for next week's career blocks
6. **OpenRouter** → Claude generates the email body (HTML)
7. **Code Node — Build HTML Email** — Wrap Claude output in styled HTML template (inline CSS only)
8. **HTTP Request — Resend** — `POST https://api.resend.com/emails`
9. **Code Node — Error Check** — If Resend fails, flag for Telegram fallback
10. **Telegram Fallback** — Send plain-text version if email fails
11. **Supabase POST** → interactions (log sent email)

---

## Email Subject

```
War Plan · Week [N+1] Preview — Phase [X] · $[weekly target]/wk target
```

---

## Email Content Sections

1. **Header bar** — Week number, date range (e.g., "Week 4 · March 23–27, 2026")
2. **Revenue phase badge** — Phase + weekly target + cumulative progress toward $100K
3. **NT reading schedule** — Table: each weekday → NT cycle day number → book names + chapter count
4. **Daily discipline targets** — Static row: prayer 3hrs, NT 1.5hrs, book 1/day, code 3.5hrs, career 6hrs
5. **Phase-specific career actions** — What to do each career block this week (proposals/calls/delivery)
6. **YouTube pipeline reminder** — 3 videos/day target, pipeline must be running before Monday
7. **Motivation block** — One scripture + one business/revenue quote
8. **Footer** — Days remaining in the 90-day plan, cumulative snapshot

---

## NT Cycle Calculation

```javascript
// For each weekday of the coming week:
const nextWeekDays = [nextMon, nextTue, nextWed, nextThu, nextFri]; // day_num values
const ntAssignments = nextWeekDays.map(dayNum => {
  const ntDay = ((dayNum - 1) % 14) + 1;
  return { dayNum, ntDay, books: NT_14DAY[ntDay] };
});
```

---

## HTML Email Rules

- **Inline CSS only** — no `<style>` blocks, no external fonts
- Dark background (`#07090c`) matching war plan aesthetic
- Table layout for NT schedule (5 rows, one per weekday)
- Revenue phase highlighted in accent colour
- Keep total HTML under 100KB
- System font stack: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`

---

## Claude System Prompt

```
Generate the HTML body for a weekly preview email for Akinwunmi's 90-Day War Plan.

Coming week: {week_num} ({date_range})
Revenue Phase: {phase} (target: ${weeklyTarget}/wk)
Cumulative revenue: ${total_revenue} of $100K goal
Days remaining: {days_left} of 90

NT reading schedule this week:
{nt_schedule}

Phase {phase} career actions:
{career_actions}

Rules:
- Write as a strategic coach preparing a soldier for the week
- Open with a forward-looking scripture or quote
- Be specific about NT assignments (name the books)
- Tie career actions to the revenue phase target
- Include YouTube pipeline reminder
- Close with urgency — every week counts in a 90-day run
- Output clean HTML fragments (no <html>/<head>/<body> tags)
- 300–500 words
```

---

## Resend API Call

```json
{
  "from": "War Plan <warplan@operscale.cloud>",
  "to": ["akinolaakinrimisi@gmail.com"],
  "subject": "{{ subject }}",
  "html": "{{ fullHtmlEmail }}"
}
```

**Auth:** `Authorization: Bearer __RESEND_API_KEY__`

---

## Error Handling

- If Resend returns non-2xx → log to `interactions` with `status: failed`
- Send plain-text fallback to Telegram with key info
- Never let email failure block the rest of the system
