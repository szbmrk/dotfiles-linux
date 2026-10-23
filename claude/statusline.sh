#!/usr/bin/env bash
input=$(cat)
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
branch=""
if [[ -n "$dir" ]]; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
fi

jq -r --arg branch "$branch" '
  def esc: "\u001b[";
  def teal(t): esc + "38;2;148;226;213m" + t + esc + "39m";
  def blue(t): esc + "38;2;137;180;250m" + t + esc + "39m";
  def yellow(t): esc + "38;2;249;226;175m" + t + esc + "39m";
  def red(t): esc + "38;2;243;139;168m" + t + esc + "39m";
  def muted(t): esc + "2m" + t + esc + "22m";
  def left_color(pct; t):
    if pct < 15 then red(t) elif pct < 40 then yellow(t) else t end;
  def left(used): (100 - used) | round;
  def countdown(resets_at):
    ((resets_at - now) / 60 | floor) as $mins
    | if $mins <= 0 then ""
      elif $mins < 60 then " \($mins)m"
      else " \($mins / 60 | floor)h\($mins % 60)m"
      end;
  def window(name; w; show_reset):
    if w == null or w.used_percentage == null then empty
    else (left(w.used_percentage)) as $pct
      | left_color($pct; "\(name) \($pct)%")
        + (if show_reset and w.resets_at != null then muted(countdown(w.resets_at)) else "" end)
    end;

  (.model.display_name // .model.id // "no-model") as $model
  | (if .thinking.enabled == false then "off" else (.effort.level // "on") end) as $level
  | (if $level == "off" then muted($level) else yellow($level) end) as $thinking
  | (.context_window.remaining_percentage) as $remaining
  | [
      teal($model),
      $thinking,
      (if $branch == "" then empty else blue($branch) end),
      (if $remaining == null then empty
       else ($remaining | round) as $pct | left_color($pct; "ctx \($pct)%")
       end),
      window("5h"; .rate_limits.five_hour; true),
      window("7d"; .rate_limits.seven_day; false),
      (if .cost.total_cost_usd == null then empty
       else muted("$" + (.cost.total_cost_usd * 100 | round / 100 | tostring))
       end)
    ]
  | join(muted(" • "))
' <<<"$input"
