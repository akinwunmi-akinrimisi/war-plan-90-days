# Directive 10 — Supabase Sync / Tracker Data API (WF10)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Webhook (GET + POST)
**Channel:** HTTP API (called by 90day-tracker.html)

---

## Routes

### Route A — Load (GET)

**URL:** `GET {N8N_URL}/webhook/tracker-data?day={day_num}`

Returns today's daily_log row as JSON for the tracker page.

### Route B — Save (POST)

**URL:** `POST {N8N_URL}/webhook/tracker-save`

Validates PIN → writes full day payload to Supabase.

---

## Save Payload (from skills.md §5)

```json
{
  "pin": "xxxx",
  "day_num": 14,
  "date": "2026-03-19",
  "prayer_s1": true,
  "prayer_s2": false,
  "prayer_note": "...",
  "nt_chapters_read": ["Matthew-1", "Matthew-2"],
  "nt_note": "...",
  "book_title": "$100M Offers",
  "book_pages": 52,
  "book_note": "...",
  "code_hrs": 3.5,
  "code_what": "Built n8n workflow",
  "code_note": "...",
  "proposals_sent": 10,
  "revenue_today": 500,
  "career_done": true,
  "career_win": "First Upwork review",
  "career_note": "...",
  "videos_published": 3,
  "pipeline_running": true,
  "yt_note": "...",
  "day_note": "Solid day..."
}
```

---

## PIN Validation

PIN stored in Supabase `config.tracker_pin`. Never hardcoded.

---

## CORS Headers

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

---

## Error Handling

- GET invalid day → 400: `{ "error": "Invalid day" }`
- POST missing PIN → 401: `{ "error": "PIN required" }`
- POST wrong PIN → 401: `{ "error": "Invalid PIN" }`
- Supabase write fails → 500: `{ "error": "Save failed" }`
