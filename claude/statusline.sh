#!/usr/bin/env bash
jq -r '
  def esc: "\u001b[";
  def teal(t): esc + "38;2;148;226;213m" + t + esc + "39m";
  def yellow(t): esc + "38;2;249;226;175m" + t + esc + "39m";
  def red(t): esc + "38;2;243;139;168m" + t + esc + "39m";
  def muted(t): esc + "2m" + t + esc + "22m";
  def left_color(pct; t):
    if pct < 15 then red(t) elif pct < 40 then yellow(t) else t end;
  def left(used): (100 - used) | round;
  def window(name; w):
    if w == null or w.used_percentage == null then empty
    else (left(w.used_percentage)) as $pct | left_color($pct; "\(name) \($pct)%")
    end;

  (.model.display_name // .model.id // "no-model") as $model
  | (if .thinking.enabled == false then "off" else (.effort.level // "on") end) as $level
  | (if $level == "off" then muted($level) else yellow($level) end) as $thinking
  | (.context_window.remaining_percentage) as $remaining
  | [
      teal($model),
      $thinking,
      (if $remaining == null then empty
       else ($remaining | round) as $pct | left_color($pct; "ctx \($pct)%")
       end),
      window("5h"; .rate_limits.five_hour),
      window("7d"; .rate_limits.seven_day)
    ]
  | join(muted(" • "))
'
