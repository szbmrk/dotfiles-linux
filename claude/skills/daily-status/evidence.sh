#!/usr/bin/env bash
# Usage: evidence.sh <since YYYY-MM-DD> [until YYYY-MM-DD, exclusive, default today]
set -euo pipefail
since="$1"
until="${2:-$(date +%F)}"
root="${STATUS_REPOS_ROOT:-$HOME/travlrd}"

for repo in "$root"/*/; do
  [ -d "$repo/.git" ] || continue
  log=$(git -C "$repo" log --branches --remotes --no-merges \
    --since="$since 00:00" --until="$until 00:00" \
    --author="$(git -C "$repo" config user.email)" \
    --date=format:'%m-%d %H:%M' --format='%ad%x09%S%x09%s' | sort)
  [ -n "$log" ] || continue
  echo "## commits: $(basename "$repo")"
  echo "$log" | sed -E 's#\trefs/(heads|remotes/origin)/#\t#'
  echo
done

echo "## pull requests touched"
gh search prs --author=@me --owner=travlrd-com --updated=">=$since" --limit 100 \
  --json repository,number,title,state,createdAt,closedAt \
  --jq ".[] | select(.createdAt[0:10] < \"$until\" and (.closedAt == null or .closedAt[0:10] >= \"$since\")) | \"\(.repository.name)#\(.number)\t\(.state)\topened \(.createdAt[0:10])\tclosed \(.closedAt[0:10]? // \"-\")\t\(.title)\""
