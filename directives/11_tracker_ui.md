# Directive 11 — Tracker UI (WF-UI)
## 90-Day War Plan · AI Accountability Partner

**Trigger:** Webhook (GET)
**Channel:** Browser (serves HTML page)

---

## Purpose

Serve `90day-tracker.html` from disk when the tracker URL is opened. Dynamic file read — no caching.

---

## Webhook URL

`GET {N8N_URL}/webhook/tracker`

---

## Workflow Nodes

1. **Webhook** — GET `/tracker`, Response Mode: Using Respond to Webhook
2. **Read Binary File** — `{{ $env.TRACKER_HTML_PATH }}`
3. **Respond to Webhook** — 200, `Content-Type: text/html`, `Cache-Control: no-cache`

---

## File Requirements

- `90day-tracker.html` must exist at `TRACKER_HTML_PATH` before activating
- Path must be absolute (e.g., `/opt/war-plan-agent/90day-tracker.html`)
- Validate with `skills.sh` Section 7 check
- File should contain `wartracker_90day` or `90-Day War` markers

---

## Error Handling

- File not found → n8n throws Read Binary File error. Fix: check TRACKER_HTML_PATH
- Webhook 404 → workflow not imported/activated
