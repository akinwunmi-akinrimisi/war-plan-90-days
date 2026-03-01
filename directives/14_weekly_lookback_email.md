# Directive 14 — Weekly Lookback Email (WF13)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — Sunday 08:00 AM WAT
**Channel:** Email via Resend → akinolaakinrimisi@gmail.com
**Tone:** Hybrid — honest assessment, faith-grounded, no sugar-coating

---

## Purpose

Concluded-week HTML summary email. Delivered every Sunday morning so Akinwunmi can reflect on the week just completed before the new week preview arrives Saturday evening.

---

## Workflow Nodes

1. **Schedule Trigger** — `0 8 * * 0` (Sunday 08:00, Africa/Lagos)
2. **Code Node — Day Counter** — Current week number, calendar date range (Mon–Fri)
3. **Supabase GET** — Config + last 5 daily_log rows (the concluded week)
4. **Code Node — Weekly Stats** — Aggregate all disciplines + revenue (reuse WF09 logic)
5. **Code Node — Cumulative Stats** — Running totals across all weeks to date
6. **OpenRouter** → Claude generates the email body (HTML)
7. **Code Node — Build HTML Email** — Wrap Claude output in styled HTML template (inline CSS only)
8. **HTTP Request — Resend** — `POST https://api.resend.com/emails`
9. **Code Node — Error Check** — If Resend fails, flag for Telegram fallback
10. **Telegram Fallback** — Send plain-text version if email fails
11. **Supabase POST** → interactions (log sent email)

---

## Email Subject

```
War Plan · Week [N] Concluded — [Score]% average · $[revenue] earned
```

---

## Email Content Sections

1. **Header bar** — Week number, date range (e.g., "Week 3 · March 16–20, 2026")
2. **Revenue phase badge** — Phase 1/2/3 + weekly target vs actual
3. **Day-by-day score grid** — 5 tiles (Mon–Fri) with % score per day, colour-coded
4. **Cumulative stats** — prayer hrs, NT chapters, books read, code hrs, proposals sent, revenue total, videos published
5. **Best day / worst day** — Highest and lowest scoring days with one honest line each
6. **90-day progress** — books (X/90), videos (X/250), revenue ($X/$100K)
7. **Footer** — One closing scripture for reflection

---

## HTML Email Rules

- **Inline CSS only** — no `<style>` blocks, no external fonts (email clients strip them)
- Dark background (`#07090c`) matching war plan aesthetic
- Colour-coded discipline rows: prayer (orange), NT (green), book (purple), code (blue), career (red), YouTube (dark orange)
- Keep total HTML under 100KB
- System font stack: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`

---

## Claude System Prompt

```
Generate the HTML body for a weekly lookback email for Akinwunmi's 90-Day War Plan.

Week: {week_num} ({date_range})
Revenue Phase: {phase} (target: ${weeklyTarget}/wk)
Revenue this week: ${revenue_earned}

Day scores: {day_scores}
Cumulative stats: {cumulative}
Best day: Day {best} ({best_score}%) — Worst day: Day {worst} ({worst_score}%)

Rules:
- Write as a trusted accountability partner — honest, not harsh
- Open with a faith reflection (one scripture reference)
- Be specific about what went well and what didn't
- Name patterns if visible (e.g., "Friday scores consistently drop")
- Revenue: on track / behind / ahead for the phase
- Close with encouragement for the week ahead
- Output clean HTML fragments (no <html>/<head>/<body> tags — just content divs)
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
- Send plain-text fallback to Telegram with key stats
- Never let email failure block the rest of the system
