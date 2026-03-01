# Directive 13 — YouTube Check-in (WF12)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 1 time daily · Every day including weekends
**Channel:** Telegram only
**Tone:** Coach — growth, consistency (coach_growth)

---

## Purpose

Daily check on the Vision GridAI YouTube pipeline. Target: 3 videos/day automated via AI pipeline. Fires every day including weekends because the pipeline runs 24/7.

---

## Schedule (WAT)

| Time | Cron | Message |
|------|------|---------|
| 7:30 PM | `30 19 * * *` | Video count today vs 3/day target + pipeline status |

---

## Logic

1. Read `videos_published` from today's `daily_log`
2. If `videos_published >= 3` → affirmation: pipeline running strong
3. If `videos_published` is 1–2 → nudge: check pipeline, ensure queue is full
4. If `videos_published` is 0 → escalation: pipeline may be down, check immediately
5. Also check `pipeline_running` boolean

---

## Workflow Nodes

1. **Schedule Trigger** — `30 19 * * *` (every day)
2. **Code Node — Day Counter** — isWeekend flag (for message tone)
3. **Supabase GET** — Config (pause) + daily_log (videos_published, pipeline_running)
4. **Pause Check**
5. **Code Node — Video Status** — Determine message urgency
6. **OpenRouter** → Claude generates check-in (or use static messages based on count)
7. **Telegram** → Send
8. **Supabase POST** → interactions

---

## Claude System Prompt

```
You are the YouTube growth coach for Akinwunmi's 90-Day War Plan.
Generate a pipeline check-in for Day {day_number}.

Videos published today: {videos_published} / 3 target
Pipeline running: {pipeline_running}
Total videos published (90-day): {videos_published_total} / 270 target
Channel: Vision GridAI

Rules:
- If 3+ videos: celebrate consistency. "The compound machine is running."
- If 1-2 videos: nudge. "Pipeline needs attention. Queue tomorrow's batch now."
- If 0 videos: urgent. "Zero output today. Check the pipeline immediately."
- If is_weekend: keep it brief. Pipeline runs automatically — just verify.
- Tie YouTube output to agency social proof (Operscale clients find you through content)
- 80–150 words. Tone: strategic, systems-focused.
```

---

## Error Handling

- Claude fails → "Day {day}. Videos today: {count}/3. {count === 0 ? 'Check pipeline NOW.' : 'Keep it running.'}"
