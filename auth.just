set dotenv-load := true

github_oauth_script := '''
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse
import threading

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)
        code = query.get("code", [""])[0]

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(b"<p>GitHub code extracted. You can close this tab now.</p>")

        print(code, flush=True)
        threading.Thread(target=server.shutdown).start()

    def log_message(self, *args):
        pass

server = HTTPServer(("localhost", 3000), Handler)
server.serve_forever()
'''

# Authorize with GitHub and store the token used by @akashic-notes/astro-collection-loader.
github-staging:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -n "${GITHUB_TOKEN:-}" ]; then
      HTTP_STATUS=$(curl --silent --output /dev/null --write-out "%{http_code}" \
        --header "Authorization: Bearer $GITHUB_TOKEN" \
        https://api.github.com/user) || HTTP_STATUS=000

      case "$HTTP_STATUS" in
        200)
          exit 0
          ;;
        401)
          ;;
        *)
          echo "Failed to validate the existing GITHUB_TOKEN (GitHub returned HTTP $HTTP_STATUS)." >&2
          exit 1
          ;;
      esac
    fi

    CLIENT_ID="${GITHUB_CLIENT_ID:-}"
    if [ -z "$CLIENT_ID" ]; then
      echo "Set GITHUB_CLIENT_ID before running this recipe." >&2
      exit 1
    fi

    REDIRECT_URI="http://localhost:3000"
    LOGIN_WORKER_URL="${GITHUB_LOGIN_WORKER_URL:-https://akashic-login-staging.akhilpai.workers.dev}"
    AUTH_URL="https://github.com/login/oauth/authorize?client_id=${CLIENT_ID}&scope=repo&redirect_uri=${REDIRECT_URI}"

    if command -v wslview >/dev/null 2>&1; then
      wslview "$AUTH_URL" >/dev/null 2>&1
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$AUTH_URL" >/dev/null 2>&1
    elif command -v open >/dev/null 2>&1; then
      open "$AUTH_URL" >/dev/null 2>&1
    else
      echo "Open this URL in your browser: $AUTH_URL" >&2
    fi

    CODE=$(printf '%s\n' '{{github_oauth_script}}' | uv run --quiet python)

    RESPONSE=$(curl -s -X POST "${LOGIN_WORKER_URL}/api/access-token" \
      -H "Content-Type: application/json" \
      -d "{\"code\":\"$CODE\",\"redirect_uri\":\"$REDIRECT_URI\"}")

    TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$TOKEN" ]; then
      echo "Failed to get token. Response: $RESPONSE" >&2
      exit 1
    fi

    touch .env
    if grep -q '^GITHUB_TOKEN=' .env; then
      sed -i "s|^GITHUB_TOKEN=.*|GITHUB_TOKEN=$TOKEN|" .env
    else
      printf '\nGITHUB_TOKEN=%s\n' "$TOKEN" >> .env
    fi
