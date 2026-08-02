#!/usr/bin/env bash

set -euo pipefail

{
  printf '%s\n' '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"clientInfo":{"name":"shell","title":"Shell","version":"0.1.0"}}}'
  sleep 0.1
  printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"account/rateLimits/read"}'
  sleep 1
} | codex app-server | jq -Rr '
  fromjson? as $msg
  | if $msg == null then empty
    elif $msg.id == 1 and $msg.result then
      "\($msg.result.rateLimits.primary.usedPercent // 0) \($msg.result.rateLimits.primary.resetsAt // 0) \($msg.result.rateLimitResetCredits.availableCount // 0)"
    elif $msg.id == 1 and $msg.error then
      ($msg.error.message
        | capture("(?s)body=(?<body>{.*})$").body
        | fromjson
        | "\(.rate_limit.primary_window.used_percent // 0) \(.rate_limit.primary_window.reset_at // 0)")
    else empty
    end
'
