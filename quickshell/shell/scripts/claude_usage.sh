#!/usr/bin/env bash

set -euo pipefail

token=$(jq -r '.claudeAiOauth.accessToken' "$HOME/.claude/.credentials.json")

curl -sSf --max-time 10 https://api.anthropic.com/api/oauth/usage \
  -H "Authorization: Bearer $token" \
  -H "anthropic-beta: oauth-2025-04-20" | jq -r '
  def epoch: if . then sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601 else 0 end;
  "\(.five_hour.utilization // 0) \(.five_hour.resets_at | epoch) \(.seven_day.utilization // 0) \(.seven_day.resets_at | epoch)"
'
