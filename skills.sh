#!/bin/bash
# =============================================================================
# skills.sh — Environment Setup & Verification
# 90-Day War Plan · AI Accountability Partner
# Operscale / Cloudboosta Systems · March–July 2026
# =============================================================================
# Run this script once on your n8n server before building any workflows.
# It verifies all dependencies, tests all external connections, and seeds
# the Supabase tables with 90 weekday rows (Mon–Fri, March 2 – July 3, 2026).
#
# Usage:
#   chmod +x skills.sh
#   ./skills.sh
#
# On success: All checks pass, system is ready to build.
# On failure: Each failed check prints the exact fix command.
# =============================================================================

set -e

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

PASS="${GREEN}✓${RESET}"
FAIL="${RED}✗${RESET}"
INFO="${BLUE}→${RESET}"
WARN="${YELLOW}⚠${RESET}"

echo ""
echo -e "${BOLD}=================================================================${RESET}"
echo -e "${BOLD}  90-Day War Plan · AI Accountability Partner · Environment Setup${RESET}"
echo -e "${BOLD}=================================================================${RESET}"
echo ""

ERRORS=0

# ── Load .env if present ─────────────────────────────────────────────────────
if [ -f ".env" ]; then
  echo -e "${INFO} Loading .env file..."
  export $(grep -v '^#' .env | xargs)
  echo -e "${PASS} .env loaded"
else
  echo -e "${WARN}  No .env file found. Using environment variables already set."
  echo -e "    Create a .env file from .env.example if you have one."
fi

echo ""
echo -e "${BOLD}── 1. System Dependencies ──────────────────────────────────────${RESET}"

# Check curl
if command -v curl &> /dev/null; then
  CURL_VER=$(curl --version | head -1 | awk '{print $2}')
  echo -e "${PASS} curl ${CURL_VER}"
else
  echo -e "${FAIL} curl not found"
  echo -e "    Fix: apt-get install -y curl"
  ((ERRORS++))
fi

# Check jq
if command -v jq &> /dev/null; then
  JQ_VER=$(jq --version)
  echo -e "${PASS} jq ${JQ_VER}"
else
  echo -e "${FAIL} jq not found (required for JSON parsing in health checks)"
  echo -e "    Fix: apt-get install -y jq"
  ((ERRORS++))
fi

# Check n8n is accessible
echo ""
echo -e "${BOLD}── 2. n8n Instance ─────────────────────────────────────────────${RESET}"

N8N_URL="${N8N_URL:-https://n8n.srv1297445.hstgr.cloud}"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${N8N_URL}/healthz" 2>/dev/null || echo "000")
if [ "$HTTP_STATUS" = "200" ]; then
  echo -e "${PASS} n8n reachable at ${N8N_URL}"
else
  echo -e "${FAIL} n8n not reachable at ${N8N_URL} (HTTP ${HTTP_STATUS})"
  echo -e "    Check: Is n8n Docker container running? → docker ps | grep n8n"
  echo -e "    Check: Is the URL correct in .env?"
  ((ERRORS++))
fi

# Check n8n API
if [ -n "$N8N_API_KEY" ]; then
  N8N_API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "${N8N_URL}/api/v1/workflows?limit=1" 2>/dev/null || echo "000")
  if [ "$N8N_API_STATUS" = "200" ]; then
    echo -e "${PASS} n8n API key valid"
  else
    echo -e "${FAIL} n8n API key invalid or API not enabled (HTTP ${N8N_API_STATUS})"
    echo -e "    Check: Settings → API → Enable Public API → copy key to .env as N8N_API_KEY"
    ((ERRORS++))
  fi
else
  echo -e "${WARN}  N8N_API_KEY not set in .env — skipping API validation"
fi

echo ""
echo -e "${BOLD}── 3. Telegram Bot ─────────────────────────────────────────────${RESET}"

if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
  TG_RESPONSE=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" 2>/dev/null)
  TG_OK=$(echo "$TG_RESPONSE" | jq -r '.ok' 2>/dev/null)
  if [ "$TG_OK" = "true" ]; then
    BOT_NAME=$(echo "$TG_RESPONSE" | jq -r '.result.username')
    echo -e "${PASS} Telegram Bot connected → @${BOT_NAME}"
  else
    echo -e "${FAIL} Telegram Bot token invalid"
    echo -e "    Fix: Get token from @BotFather → set TELEGRAM_BOT_TOKEN in .env"
    ((ERRORS++))
  fi
else
  echo -e "${FAIL} TELEGRAM_BOT_TOKEN not set in .env"
  echo -e "    Fix: Message @BotFather on Telegram → /newbot → copy token to .env"
  ((ERRORS++))
fi

if [ -n "$TELEGRAM_CHAT_ID" ]; then
  echo -e "${PASS} Telegram Chat ID set → ${TELEGRAM_CHAT_ID}"
else
  echo -e "${WARN}  TELEGRAM_CHAT_ID not set"
  echo -e "    Fix: Message your bot once, then run:"
  echo -e "    curl https://api.telegram.org/bot\${TELEGRAM_BOT_TOKEN}/getUpdates | jq '.result[0].message.chat.id'"
fi

echo ""
echo -e "${BOLD}── 4. Slack Webhook ────────────────────────────────────────────${RESET}"

if [ -n "$SLACK_WEBHOOK_URL" ]; then
  SLACK_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST -H 'Content-type: application/json' \
    --data '{"text":"[War Plan Setup] Slack connection verified ✓"}' \
    "${SLACK_WEBHOOK_URL}" 2>/dev/null || echo "000")
  if [ "$SLACK_STATUS" = "200" ]; then
    echo -e "${PASS} Slack Webhook valid — test message sent to #war-plan"
  else
    echo -e "${FAIL} Slack Webhook failed (HTTP ${SLACK_STATUS})"
    echo -e "    Fix: Slack → Apps → Incoming Webhooks → Add to #war-plan → copy URL to .env"
    ((ERRORS++))
  fi
else
  echo -e "${FAIL} SLACK_WEBHOOK_URL not set in .env"
  echo -e "    Fix: Slack → Apps → Incoming Webhooks → Add to Workspace → select #war-plan channel"
  ((ERRORS++))
fi

echo ""
echo -e "${BOLD}── 5. Supabase ─────────────────────────────────────────────────${RESET}"

if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_API_KEY" ]; then
  SB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "apikey: ${SUPABASE_API_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_API_KEY}" \
    "${SUPABASE_URL}/rest/v1/" 2>/dev/null || echo "000")
  if [ "$SB_STATUS" = "200" ]; then
    echo -e "${PASS} Supabase connection valid → ${SUPABASE_URL}"
  else
    echo -e "${FAIL} Supabase connection failed (HTTP ${SB_STATUS})"
    echo -e "    Fix: Check SUPABASE_URL and SUPABASE_API_KEY in .env"
    echo -e "    URL format: https://<project-ref>.supabase.co"
    ((ERRORS++))
  fi

  # Check if tables exist
  echo ""
  echo -e "${INFO} Checking Supabase tables..."

  for TABLE in daily_log interactions escalations config; do
    TB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "apikey: ${SUPABASE_API_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_API_KEY}" \
      "${SUPABASE_URL}/rest/v1/${TABLE}?limit=1" 2>/dev/null || echo "000")
    if [ "$TB_STATUS" = "200" ]; then
      echo -e "  ${PASS} Table: ${TABLE}"
    else
      echo -e "  ${FAIL} Table missing: ${TABLE} (HTTP ${TB_STATUS})"
      echo -e "      Fix: Run the schema SQL in Supabase SQL Editor (see skills.md Section 4)"
      ((ERRORS++))
    fi
  done

else
  echo -e "${FAIL} SUPABASE_URL or SUPABASE_API_KEY not set in .env"
  echo -e "    Fix: Create project at supabase.com → Project Settings → API → copy URL and anon key"
  ((ERRORS++))
fi

echo ""
echo -e "${BOLD}── 6. OpenRouter / Claude API ──────────────────────────────────${RESET}"

if [ -n "$OPENROUTER_API_KEY" ]; then
  OR_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"model":"anthropic/claude-sonnet-4-5","max_tokens":10,"messages":[{"role":"user","content":"ping"}]}' \
    "https://openrouter.ai/api/v1/chat/completions" 2>/dev/null || echo "000")
  if [ "$OR_RESPONSE" = "200" ]; then
    echo -e "${PASS} OpenRouter API key valid — Claude Sonnet 4.5 accessible"
  else
    echo -e "${FAIL} OpenRouter API call failed (HTTP ${OR_RESPONSE})"
    echo -e "    Fix: Check key at openrouter.ai/keys → set OPENROUTER_API_KEY in .env"
    ((ERRORS++))
  fi
else
  echo -e "${FAIL} OPENROUTER_API_KEY not set in .env"
  echo -e "    Fix: openrouter.ai → Keys → Create Key → copy to .env"
  ((ERRORS++))
fi

echo ""
echo -e "${BOLD}── 6b. Resend Email API ────────────────────────────────────────${RESET}"

if [ -n "$RESEND_API_KEY" ]; then
  # Validate key by calling the domains endpoint (read-only, no email sent)
  RESEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${RESEND_API_KEY}" \
    "https://api.resend.com/domains" 2>/dev/null || echo "000")
  if [ "$RESEND_STATUS" = "200" ]; then
    echo -e "${PASS} Resend API key valid"

    # Check if a verified sending domain exists
    DOMAINS_JSON=$(curl -s \
      -H "Authorization: Bearer ${RESEND_API_KEY}" \
      "https://api.resend.com/domains" 2>/dev/null)
    VERIFIED_DOMAIN=$(echo "$DOMAINS_JSON" | jq -r \
      '[.data[]? | select(.status=="verified")] | .[0].name // empty' 2>/dev/null)

    if [ -n "$VERIFIED_DOMAIN" ]; then
      echo -e "${PASS} Verified sending domain found → ${VERIFIED_DOMAIN}"
      echo -e "    Set RESEND_FROM_EMAIL in .env as: warplan@${VERIFIED_DOMAIN}"
    else
      echo -e "${WARN}  No verified sending domain found in Resend"
      echo -e "    Fix: resend.com/domains → Add Domain → verify DNS records"
      echo -e "    Until verified, emails will fail with HTTP 403"
    fi
  else
    echo -e "${FAIL} Resend API key invalid or Resend unreachable (HTTP ${RESEND_STATUS})"
    echo -e "    Fix: resend.com → API Keys → Create Key (Send access) → set RESEND_API_KEY in .env"
    ((ERRORS++))
  fi
else
  echo -e "${FAIL} RESEND_API_KEY not set in .env"
  echo -e "    Fix: resend.com → API Keys → Create Key → copy to .env as RESEND_API_KEY"
  echo -e "    Also add: RESEND_FROM_EMAIL=warplan@yourdomain.com"
  ((ERRORS++))
fi

echo ""
echo -e "${BOLD}── 7. Supabase Schema Bootstrap ────────────────────────────────${RESET}"

if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_API_KEY" ]; then
  echo -e "${INFO} Checking config table for initial seed data..."

  CONFIG_COUNT=$(curl -s \
    -H "apikey: ${SUPABASE_API_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_API_KEY}" \
    "${SUPABASE_URL}/rest/v1/config?select=count" 2>/dev/null | jq -r '.[0].count // "0"' 2>/dev/null || echo "0")

  if [ "$CONFIG_COUNT" -gt 0 ] 2>/dev/null; then
    echo -e "${PASS} Config table has seed data"
  else
    echo -e "${WARN}  Config table is empty — inserting seed row..."
    SEED_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST \
      -H "apikey: ${SUPABASE_API_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_API_KEY}" \
      -H "Content-Type: application/json" \
      -H "Prefer: return=minimal" \
      -d "{
        \"start_date\": \"2026-03-02\",
        \"active\": true,
        \"pause_until\": null,
        \"user_telegram_id\": \"${TELEGRAM_CHAT_ID}\",
        \"user_name\": \"Akinwunmi\",
        \"timezone\": \"Africa/Lagos\",
        \"revenue_phase\": 1,
        \"week_num\": 1
      }" \
      "${SUPABASE_URL}/rest/v1/config" 2>/dev/null || echo "000")

    if [ "$SEED_STATUS" = "201" ] || [ "$SEED_STATUS" = "200" ]; then
      echo -e "${PASS} Config seed row inserted"
    else
      echo -e "${FAIL} Could not seed config table (HTTP ${SEED_STATUS})"
      echo -e "    Fix: Manually insert a row in config table via Supabase dashboard"
      ((ERRORS++))
    fi
  fi

  echo -e "${INFO} Checking daily_log — seeding 90 weekday rows if empty..."
  LOG_COUNT=$(curl -s \
    -H "apikey: ${SUPABASE_API_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_API_KEY}" \
    "${SUPABASE_URL}/rest/v1/daily_log?select=count" 2>/dev/null | jq -r '.[0].count // "0"' 2>/dev/null || echo "0")

  if [ "$LOG_COUNT" -ge 90 ] 2>/dev/null; then
    echo -e "${PASS} daily_log has ${LOG_COUNT} rows (90 weekdays seeded)"
  else
    echo -e "${INFO} Seeding daily_log with 90 weekday rows (March 2 – July 3, 2026)..."
    # Generate weekday dates using Python (more reliable cross-platform than date arithmetic)
    WEEKDAY_DATES=$(python3 -c "
from datetime import date, timedelta
start = date(2026, 3, 2)
d = start
days = []
while len(days) < 90:
    if d.weekday() < 5:  # Mon=0 to Fri=4
        days.append(d.strftime('%Y-%m-%d'))
    d += timedelta(days=1)
print(' '.join(days))
" 2>/dev/null || echo "")

    if [ -z "$WEEKDAY_DATES" ]; then
      echo -e "${FAIL} Python3 not available — cannot generate weekday dates"
      echo -e "    Fix: apt-get install -y python3  OR manually seed daily_log in Supabase dashboard"
      ((ERRORS++))
    else
      SEED_ERRORS=0
      DAY_NUM=1
      for DATE_STR in $WEEKDAY_DATES; do
        ROW_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
          -X POST \
          -H "apikey: ${SUPABASE_API_KEY}" \
          -H "Authorization: Bearer ${SUPABASE_API_KEY}" \
          -H "Content-Type: application/json" \
          -H "Prefer: return=minimal" \
          -d "{
            \"day_num\": ${DAY_NUM},
            \"date\": \"${DATE_STR}\",
            \"is_weekend\": false,
            \"prayer_s1\": false,
            \"prayer_s2\": false,
            \"prayer_note\": \"\",
            \"nt_chapters_read\": [],
            \"nt_note\": \"\",
            \"book_title\": \"\",
            \"book_pages\": 0,
            \"book_note\": \"\",
            \"code_hrs\": 0,
            \"code_what\": \"\",
            \"code_note\": \"\",
            \"proposals_sent\": 0,
            \"revenue_today\": 0,
            \"career_done\": false,
            \"career_win\": \"\",
            \"career_note\": \"\",
            \"videos_published\": 0,
            \"pipeline_running\": false,
            \"yt_note\": \"\",
            \"day_score\": 0,
            \"day_note\": \"\"
          }" \
          "${SUPABASE_URL}/rest/v1/daily_log" 2>/dev/null || echo "000")
        if [ "$ROW_STATUS" != "201" ] && [ "$ROW_STATUS" != "200" ] && [ "$ROW_STATUS" != "409" ]; then
          ((SEED_ERRORS++))
        fi
        DAY_NUM=$((DAY_NUM + 1))
      done

      if [ "$SEED_ERRORS" -eq 0 ]; then
        echo -e "${PASS} daily_log seeded with 90 weekday rows (Day 1–90, March 2 – July 3)"
      else
        echo -e "${WARN}  ${SEED_ERRORS} rows may have failed — check Supabase dashboard. Non-critical if rows already exist."
      fi
    fi
  fi
fi

echo ""
echo -e "${BOLD}── 8. Tracker HTML (GitHub-Served) ─────────────────────────────${RESET}"

if [ -n "$TRACKER_HTML_PATH" ]; then
  echo -e "${INFO} TRACKER_HTML_PATH set → ${TRACKER_HTML_PATH}"
  if [ -f "$TRACKER_HTML_PATH" ]; then
    FILE_SIZE=$(wc -c < "$TRACKER_HTML_PATH")
    echo -e "${PASS} 90day-tracker.html found (${FILE_SIZE} bytes)"
    # Sanity check — must contain 90-day markers
    if grep -q "wartracker_90day\|90-Day War" "$TRACKER_HTML_PATH" 2>/dev/null; then
      echo -e "${PASS} File is the correct 90-Day War Plan tracker"
    elif grep -q "saveData\|wartracker" "$TRACKER_HTML_PATH" 2>/dev/null; then
      echo -e "${WARN}  File looks like the OLD 30-day tracker — replace with 90day-tracker.html"
    else
      echo -e "${WARN}  File exists but doesn't look like any known War Plan tracker — verify manually"
    fi
  else
    echo -e "${FAIL} 90day-tracker.html NOT found at: ${TRACKER_HTML_PATH}"
    echo -e "    Fix: Copy 90day-tracker.html to that path, or update TRACKER_HTML_PATH in .env"
    echo -e "    Expected: /opt/war-plan-agent/90day-tracker.html"
    ((ERRORS++))
  fi
else
  echo -e "${FAIL} TRACKER_HTML_PATH not set in .env"
  echo -e "    Fix: Add TRACKER_HTML_PATH=/opt/war-plan-agent/90day-tracker.html to .env"
  echo -e "    Note: Path must be ABSOLUTE — not a relative path"
  ((ERRORS++))
fi

# Verify tracker is accessible via WF-UI webhook (only if n8n is up)
if [ -n "$N8N_URL" ] && [ "$HTTP_STATUS" = "200" ]; then
  TRACKER_WH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "${N8N_URL}/webhook/tracker" 2>/dev/null || echo "000")
  if [ "$TRACKER_WH_STATUS" = "200" ]; then
    echo -e "${PASS} WF-UI webhook live → ${N8N_URL}/webhook/tracker"
  elif [ "$TRACKER_WH_STATUS" = "404" ]; then
    echo -e "${WARN}  WF-UI webhook not yet deployed (HTTP 404)"
    echo -e "    This is expected if WF-UI workflow hasn't been imported yet"
    echo -e "    Fix: Import WF-UI_tracker_ui.json into n8n and activate it"
  else
    echo -e "${WARN}  WF-UI webhook returned HTTP ${TRACKER_WH_STATUS}"
    echo -e "    Check: Is WF-UI_tracker_ui.json imported and activated in n8n?"
  fi
fi

echo ""
echo -e "${BOLD}── 9. n8n Timezone Verification ────────────────────────────────${RESET}"

if [ -n "$N8N_API_KEY" ] && [ -n "$N8N_URL" ]; then
  TZ_RESPONSE=$(curl -s \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "${N8N_URL}/api/v1/settings" 2>/dev/null | jq -r '.timezone // "unknown"' 2>/dev/null || echo "unknown")
  if [ "$TZ_RESPONSE" = "Africa/Lagos" ]; then
    echo -e "${PASS} n8n timezone: Africa/Lagos (WAT)"
  else
    echo -e "${WARN}  n8n timezone is '${TZ_RESPONSE}' — should be 'Africa/Lagos'"
    echo -e "    Fix: n8n Settings → Default Timezone → set to Africa/Lagos"
    echo -e "    Or: Add GENERIC_TIMEZONE=Africa/Lagos to your n8n docker-compose .env"
  fi
else
  echo -e "${WARN}  Cannot check n8n timezone — N8N_API_KEY not set"
fi

echo ""
echo -e "${BOLD}─────────────────────────────────────────────────────────────────${RESET}"

if [ "$ERRORS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}  ✓ ALL CHECKS PASSED — System ready to build.${RESET}"
  echo -e ""
  echo -e "  Next steps:"
  echo -e "  1. Add n8n credentials (Telegram, Slack, Supabase, OpenRouter) via n8n UI"
  echo -e "  2. Import WF-UI_tracker_ui.json — activate it — test tracker URL in browser"
  echo -e "  3. Import WF10_supabase_sync.json — test Save button posts to Supabase correctly"
  echo -e "  4. Import WF01_morning_briefing.json — confirm tracker link + revenue phase in message"
  echo -e "  5. Import WF02_prayer_reminders.json — confirm all 4 triggers, including weekends"
  echo -e "  6. Import WF11_career_reminders.json + WF12_youtube_checkin.json"
  echo -e "  7. Follow Phase 2 → 5 build plan in Agent.md"
  echo ""
else
  echo -e "${RED}${BOLD}  ✗ ${ERRORS} check(s) failed. Fix the above issues before building.${RESET}"
  echo -e "  Each failed check above shows the exact fix command."
  echo ""
fi

echo ""
echo -e "${BOLD}── APPENDIX: Supabase Schema SQL ───────────────────────────────${RESET}"
echo -e "${INFO} Run the following SQL in Supabase SQL Editor if tables don't exist:"
echo ""
cat << 'SCHEMA_EOF'
-- daily_log: one row per weekday (90 rows total)
CREATE TABLE IF NOT EXISTS daily_log (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  day_num         INTEGER UNIQUE NOT NULL,
  date            DATE NOT NULL,
  is_weekend      BOOLEAN DEFAULT false,
  prayer_s1       BOOLEAN DEFAULT false,
  prayer_s2       BOOLEAN DEFAULT false,
  prayer_note     TEXT DEFAULT '',
  nt_chapters_read JSONB DEFAULT '[]',
  nt_note         TEXT DEFAULT '',
  book_title      TEXT DEFAULT '',
  book_pages      INTEGER DEFAULT 0,
  book_note       TEXT DEFAULT '',
  code_hrs        NUMERIC(4,2) DEFAULT 0,
  code_what       TEXT DEFAULT '',
  code_note       TEXT DEFAULT '',
  proposals_sent  INTEGER DEFAULT 0,
  revenue_today   NUMERIC(10,2) DEFAULT 0,
  career_done     BOOLEAN DEFAULT false,
  career_win      TEXT DEFAULT '',
  career_note     TEXT DEFAULT '',
  videos_published INTEGER DEFAULT 0,
  pipeline_running BOOLEAN DEFAULT false,
  yt_note         TEXT DEFAULT '',
  day_score       INTEGER DEFAULT 0,
  day_note        TEXT DEFAULT '',
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- interactions: every message sent and reply received
CREATE TABLE IF NOT EXISTS interactions (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  day_num      INTEGER,
  task         TEXT,
  message_type TEXT,
  channel      TEXT,
  content      TEXT,
  status       TEXT DEFAULT 'sent',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- escalations: escalation state per task per day
CREATE TABLE IF NOT EXISTS escalations (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  day_num      INTEGER,
  task         TEXT,
  level        INTEGER DEFAULT 0,
  last_sent_at TIMESTAMPTZ,
  UNIQUE(day_num, task)
);

-- config: single-row system configuration
CREATE TABLE IF NOT EXISTS config (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  start_date       DATE DEFAULT '2026-03-02',
  active           BOOLEAN DEFAULT true,
  pause_until      DATE,
  user_telegram_id TEXT,
  user_name        TEXT DEFAULT 'Akinwunmi',
  timezone         TEXT DEFAULT 'Africa/Lagos',
  tracker_pin      TEXT DEFAULT '7749',
  revenue_phase    INTEGER DEFAULT 1,
  week_num         INTEGER DEFAULT 1
);
SCHEMA_EOF

echo -e "${BOLD}=================================================================${RESET}"
echo ""

exit $ERRORS
