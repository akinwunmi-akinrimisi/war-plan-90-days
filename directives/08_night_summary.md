# Directive 08 — Night Summary (WF08)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 11:15 PM WAT · Mon–Fri only
**Channels:** Slack #war-plan + Telegram
**Tone:** Hybrid — honest and warm

---

## Purpose

Close the day with a full assessment. Score, completed vs missed, revenue earned, videos published, one honest word + encouragement.

---

## Score Calculator (from skills.md §11)

| Component | Max | Logic |
|-----------|-----|-------|
| Prayer | 25 | Both: 25. One: 12. None: 0 |
| NT Reading | 20 | chapters_read / total_assigned × 20 |
| Book of Day | 15 | book_pages / 50 × 15 |
| Coding | 20 | code_hrs / 3.5 × 20 |
| Career | 15 | Phase-dependent (see skills.md §11) |
| Journal | 5 | day_note length > 10 chars |
| **Total** | **100** | |

---

## Workflow Nodes

1. **Schedule Trigger** — `15 23 * * 1-5` (Mon–Fri)
2. **Code Node — Day Counter** + Weekend Guard
3. **Supabase GET** — Config (pause, revenue_phase) + today's daily_log
4. **Code Node — Score Calculator** — Full scoring with career phase logic
5. **Supabase PATCH** — Write day_score to daily_log
6. **OpenRouter** → Claude generates summary
7. **Telegram** → Send
8. **Slack Webhook** → Post to #war-plan
9. **Supabase POST** → interactions

---

## Claude System Prompt

```
Generate night summary for Weekday {day_number} (Week {week_num}).

Score: {day_score}/100
Completed: {completed_tasks}
Missed: {missed_tasks}
Prayer: {status}. NT: {chapters_read}/{total}. Book: {book_pages}p.
Code: {code_hrs}h. Proposals: {proposals_sent}. Revenue: ${revenue_today}.
Videos: {videos_published}. Career: {career_status}.

Revenue Phase {phase}: ${weekly_actual} / ${weekly_target} this week.

Rules:
- Open with score — bold and clear
- Name every completed task with affirmation
- Name every missed task honestly
- Revenue progress vs weekly target
- One-sentence honest assessment
- Close with scripture or quote
- Score ≥80: celebrate. 50-79: acknowledge effort. <50: compassionate but real.
- 300–500 words. Max 4096 chars (Telegram limit).
```

---

## Error Handling

- Claude fails → "Day {day} score: {score}/100. {completed} done, {missed} missed. Tomorrow we go again."
