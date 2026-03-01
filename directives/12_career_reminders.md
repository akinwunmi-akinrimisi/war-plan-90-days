# Directive 12 — Career Reminders (WF11)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Cron — 3 times daily · Mon–Fri only
**Channel:** Telegram only
**Tone:** Coach — sales-focused, revenue-driven (coach_revenue + coach_growth)

---

## Purpose

Drive the 3 daily career blocks — AI agency prospecting, client management, and YouTube pipeline. Every message adapts to the current revenue phase ($1K → $5K → $20K/week).

---

## Schedule (WAT)

| Time | Block | Cron | Focus |
|------|-------|------|-------|
| 8:55 AM | Career A | `55 8 * * 1-5` | Prospecting / proposals |
| 11:55 AM | Career B | `55 11 * * 1-5` | Portfolio / follow-ups / client work |
| 7:25 PM | Career C | `25 19 * * 1-5` | YouTube pipeline + LinkedIn |

---

## Phase-Aware Messaging

### Phase 1 (Weeks 1–4 · $1K/week target)
| Block | Message Theme |
|-------|--------------|
| A | "10 proposals today — start writing. Upwork, direct outreach, cold DMs." |
| B | "Portfolio building — ship a case study. Free pilot if needed." |
| C | "Check YouTube pipeline — confirm 3 videos queued for tomorrow." |

### Phase 2 (Weeks 5–8 · $5K/week target)
| Block | Message Theme |
|-------|--------------|
| A | "3 qualified proposals only — no budget jobs. $500+ minimum." |
| B | "Follow up every open lead within 24hrs. Retainer pitch ready?" |
| C | "LinkedIn post drafted? 1 post/day builds inbound. Check Vision GridAI analytics." |

### Phase 3 (Weeks 9–18 · $20K/week target)
| Block | Message Theme |
|-------|--------------|
| A | "Book 2 discovery calls today — LinkedIn + referrals." |
| B | "Write today's $10K+ proposal. Position Operscale as premium." |
| C | "Pipeline check + analytics review. Are videos converting to leads?" |

---

## Workflow Nodes

1. **Schedule Trigger** — 3 crons (Mon–Fri)
2. **Code Node — Day Counter** + Weekend Guard
3. **Code Node — Determine Block** — A/B/C from trigger time
4. **Supabase GET** — Config (pause, revenue_phase, week_num) + daily_log (proposals_sent, revenue_today)
5. **Pause Check**
6. **Code Node — Revenue Phase** — Phase-specific message template selection
7. **Supabase GET** — Last 7 interactions for dedup
8. **OpenRouter** → Claude generates message with revenue context
9. **Telegram** → Send
10. **Supabase POST** → interactions

---

## Context Packet

```json
{
  "day_number": "<1-90>",
  "task": "career_block_a | career_block_b | career_block_c",
  "tone_mode": "coach_revenue",
  "revenue_phase": "<1-3>",
  "weekly_revenue_target": "<1000|5000|20000>",
  "weekly_revenue_actual": "<earned this week>",
  "proposals_sent_today": 0,
  "proposals_sent_total": 0,
  "revenue_earned_total": 0,
  "videos_published_total": 0
}
```

---

## Claude System Prompt

```
You are the revenue coach for Akinwunmi's 90-Day War Plan.
Generate a career block reminder for {task} on Weekday {day_number}.

Revenue Phase {revenue_phase}: Weekly target ${weekly_target}. Earned this week: ${weekly_actual}.
Proposals sent today: {proposals_sent_today}. Total: {proposals_sent_total}.
Revenue earned total: ${revenue_earned_total}. Goal: $100K in 90 days.

Phase-specific rules:
- Phase 1: Volume — 10 proposals/day, accept $200+ gigs, build reviews fast
- Phase 2: Quality — 3 qualified proposals, $500+ minimum, pitch retainers
- Phase 3: Premium — discovery calls, $10K+ proposals, Operscale brand positioning

Block A: Prospecting. Block B: Portfolio/follow-up. Block C: YouTube + LinkedIn.
Include one sales/agency quote (Hormozi, Cardone, Dan Kennedy, Chris Voss).
100–250 words. Tone: urgent, revenue-focused, no excuses.
```

---

## Error Handling

- Claude fails → "Day {day}. Career Block {letter}. Phase {phase} — ${target}/week. Go sell."
