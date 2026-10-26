#!/usr/bin/env bash
input=$(cat)
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
branch=""
if [[ -n "$dir" ]]; then
  branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
fi

jq -r --arg branch "$branch" '
  def esc: "\u001b[";
  def rgb(r; g; b; t): esc + "38;2;\(r);\(g);\(b)m" + t + esc + "39m";
  def bold(t): esc + "1m" + t + esc + "22m";
  def teal(t): rgb(148; 226; 213; t);
  def peach(t): rgb(250; 179; 135; t);
  def blue(t): rgb(137; 180; 250; t);
  def green(t): rgb(166; 227; 161; t);
  def yellow(t): rgb(249; 226; 175; t);
  def red(t): rgb(243; 139; 168; t);
  def sky(t): rgb(137; 220; 235; t);
  def subtle(t): rgb(127; 132; 156; t);
  def faint(t): rgb(88; 91; 112; t);
  def level_color(pct; t):
    if pct < 15 then red(t) elif pct < 40 then yellow(t) else green(t) end;
  def left(used): (100 - used) | round;
  def countdown(resets_at):
    ((resets_at - now) / 60 | floor) as $mins
    | if $mins <= 0 then ""
      elif $mins < 60 then "\($mins)m"
      elif $mins < 1440 then "\($mins / 60 | floor)h\($mins % 60)m"
      else "\($mins / 1440 | floor)d\(($mins % 1440) / 60 | floor)h"
      end;
  def metric(name; pct):
    subtle(name + " ") + level_color(pct; bold("\(pct)%"));
  def window(name; w):
    if w == null or w.used_percentage == null then empty
    else (if w.resets_at == null then "" else countdown(w.resets_at) end) as $reset
      | metric(name; left(w.used_percentage))
        + (if $reset == "" then "" else sky(" " + $reset) end)
    end;
  def tokens(n):
    if n >= 1000000 then "\(n / 100000 | round / 10)M"
    elif n >= 1000 then "\(n / 1000 | round)k"
    else "\(n)" end;
  def context(cw):
    if cw.remaining_percentage == null then empty
    else metric("ctx"; cw.remaining_percentage | round)
      + (if cw.context_window_size == null then ""
         else ((cw.current_usage // {}) as $u
           | (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) as $used
           | subtle(" \(tokens($used))/\(tokens(cw.context_window_size))"))
         end)
    end;
  def money(x):
    (x * 100 | round) as $cents
    | "$\($cents / 100 | floor).\($cents % 100 | tostring | if length < 2 then "0" + . else . end)";

  (.model.display_name // .model.id // "no-model") as $model
  | (if .thinking.enabled == false then "off" else (.effort.level // "on") end) as $level
  | [
      teal($model),
      (if $level == "off" then subtle($level) else peach($level) end),
      (if $branch == "" then empty else blue($branch) end),
      context(.context_window),
      window("5h"; .rate_limits.five_hour),
      window("7d"; .rate_limits.seven_day),
      (if .cost.total_cost_usd == null then empty else yellow(money(.cost.total_cost_usd)) end)
    ]
  | join(faint(" │ "))
' <<<"$input"
