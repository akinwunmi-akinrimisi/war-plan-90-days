# Directive 09 — Weekly Report (WF09)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — Sunday 10:00 PM WAT
**Channel:** Slack #war-plan only
**Tone:** Coach — data-driven, forward-looking

---

## Purpose

7-day performance report every Sunday. Revenue progress vs phase target, video count, all discipline stats, and directives for next week. Also updates `config.revenue_phase` and `config.week_num`.

---

## Workflow Nodes

1. **Schedule Trigger** — `0 22 * * 0` (Sunday, Africa/Lagos)
2. **Code Node — Day Counter** — Week number
3. **Supabase GET** — Config + last 5 daily_log rows (Mon–Fri of this week)
4. **Code Node — Weekly Stats** — Aggregate all disciplines + revenue
5. **Code Node — Phase Update** — Check if week_num crosses phase boundary → update config
6. **Supabase PATCH** — Update `config.week_num` and `config.revenue_phase` if changed
7. **OpenRouter** → Claude generates report
8. **Slack Webhook** → Post to #war-plan (Block Kit)
9. **Supabase POST** → interactions

---

## Weekly Stats Aggregation

```javascript
const stats = {
  week_number: weekNum,
  prayer_sessions: logs.reduce((s, d) => s + (d.prayer_s1?1:0) + (d.prayer_s2?1:0), 0),
  nt_chapters: logs.reduce((s, d) => s + (d.nt_chapters_read?.length || 0), 0),
  book_pages: logs.reduce((s, d) => s + (d.book_pages || 0), 0),
  code_hrs: logs.reduce((s, d) => s + parseFloat(d.code_hrs || 0), 0),
  proposals_sent: logs.reduce((s, d) => s + (d.proposals_sent || 0), 0),
  revenue_earned: logs.reduce((s, d) => s + parseFloat(d.revenue_today || 0), 0),
  videos_published: logs.reduce((s, d) => s + (d.videos_published || 0), 0),
  avg_score: Math.round(logs.reduce((s, d) => s + (d.day_score || 0), 0) / logs.length),
  perfect_days: logs.filter(d => (d.day_score || 0) >= 90).length
};
```

---

## Revenue Phase Update Logic

```javascript
function getRevenuePhase(weekNum) {
  if (weekNum <= 4) return { phase: 1, weeklyTarget: 1000 };
  if (weekNum <= 8) return { phase: 2, weeklyTarget: 5000 };
  return { phase: 3, weeklyTarget: 20000 };
}
// PATCH config SET revenue_phase, week_num
```

---

## Claude System Prompt

```
Generate Week {week_num} performance report for Akinwunmi's 90-Day War Plan.

Stats: {stats}
Revenue Phase: {phase} (target: ${weeklyTarget}/wk)
Revenue this week: ${revenue_earned} ({pct}% of target)

Rules:
- Headline: average score + revenue vs target
- Break down each discipline
- Identify strongest + weakest
- Name patterns (e.g., "Afternoon career blocks consistently missed")
- Revenue analysis: on track / behind / ahead
- 2–3 actionable directives for next week
- Include one business quote on compounding/consistency
- 400–600 words. Slack Block Kit formatting.
```
