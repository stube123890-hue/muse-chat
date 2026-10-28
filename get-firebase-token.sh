#!/bin/bash
# get-firebase-token.sh — print a fresh Firebase ID token for muse-chat.
# Signs in with the billota agent account (email/password) via the Identity
# Toolkit REST API and prints the idToken. Tokens last 1 hour; call this
# fresh on every run that talks to the database.
# Credentials live in ~/workspace/muse-chat/.billota-auth (0600, never
# committed) as FB_EMAIL / FB_PASSWORD. The API key is read from index.html.
set -euo pipefail
KEY=$(grep -o 'apiKey: *"[^"]*"' ~/workspace/muse-chat/index.html | sed 's/.*apiKey: *"\([^"]*\)"/\1/')
# shellcheck disable=SC1091
source ~/workspace/muse-chat/.billota-auth
curl -s --max-time 25 "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$KEY" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$FB_EMAIL\",\"password\":\"$FB_PASSWORD\",\"returnSecureToken\":true}" |
  python3 -c "import sys,json; d=json.load(sys.stdin); t=d.get('idToken'); sys.exit('sign-in failed: '+str(d)[:200]) if not t else print(t)"
