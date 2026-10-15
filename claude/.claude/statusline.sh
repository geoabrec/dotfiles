#!/usr/bin/env bash
# Claude Code status line, one row:
#   <dir> <os> <git>  <model> · <effort> · ctx Nk/1M · 5h N% · 7d N% · ↻ 5h-reset / 7d-reset
# Reads the session JSON on stdin. Needs jq; uses starship for the dir/git part.

input=$(cat)

# One jq call for every field. Fields are joined with the unit separator
# (0x1f) so that empty ones survive `read`.
IFS=$'\x1f' read -r dir model effort tokens five five_reset week week_reset < <(
  jq -r '[
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (.effort.level // ""),
    # Tokens in the context right now; falls back to percentage × window size.
    (.context_window as $c | $c.current_usage
      | if . then (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
        else ($c.used_percentage // 0) * ($c.context_window_size // 0) / 100 end | floor),
    (.rate_limits.five_hour.used_percentage // "" | if . == "" then . else floor end),
    (.rate_limits.five_hour.resets_at // "" | if . == "" then . else floor end),
    (.rate_limits.seven_day.used_percentage // "" | if . == "" then . else floor end),
    (.rate_limits.seven_day.resets_at // "" | if . == "" then . else floor end)
  ] | map(tostring) | join("\u001f")' <<<"$input" 2>/dev/null
)

reset=$'\e[0m'
dim=$'\e[2m'
sep=" ${dim}·${reset} "

# pct VALUE WARN CRIT -> "VALUE%", yellow from WARN, red from CRIT.
pct() {
  local color=''
  if (($1 >= $3)); then
    color=$'\e[31m'
  elif (($1 >= $2)); then
    color=$'\e[33m'
  fi
  printf '%s%d%%%s' "$color" "$1" "$reset"
}

# ktok TOKENS -> "152k/1M" (out of 1M).
ktok() {
  printf '%dk/1M' $(($1 / 1000))
}

# resets_in EPOCH -> "47m", "2h13m", "21h" or "3d4h"; "-" if unset or past.
resets_in() {
  [[ -n $1 ]] || { printf -- -; return; }
  local left=$(($1 - now))
  ((left > 0)) || { printf -- -; return; }
  if ((left >= 86400)); then
    printf '%dd%dh' $((left / 86400)) $((left % 86400 / 3600))
  elif ((left >= 36000)); then
    printf '%dh' $((left / 3600))
  elif ((left >= 3600)); then
    printf '%dh%02dm' $((left / 3600)) $((left % 3600 / 60))
  else
    printf '%dm' $((left / 60))
  fi
}

now=$(date +%s)
out=''

# Vim mode is left to the built-in "-- INSERT --" indicator: status line updates
# are debounced by 300ms, so a mode letter here would lag behind every switch.

# Directory, OS icon and git info straight from the starship config.
# STARSHIP_SHELL is unset so starship prints plain ANSI, not zsh escapes.
if [[ -n $dir ]]; then
  if command -v starship >/dev/null; then
    for m in directory os git_branch git_status; do
      out+=$(env -u STARSHIP_SHELL starship module "$m" --path "$dir" --logical-path "$dir")
    done
  else
    out+="${dir##*/} "
  fi
  out+=' '
fi

segs=()
[[ -n $model ]] && segs+=("$model")
[[ -n $effort ]] && segs+=("$effort")
segs+=("ctx $(ktok "${tokens:-0}")")

resets=()
if [[ -n $five ]]; then
  segs+=("5h $(pct "$five" 70 90)")
  resets+=("$(resets_in "$five_reset")")
fi
if [[ -n $week ]]; then
  segs+=("7d $(pct "$week" 70 90)")
  resets+=("$(resets_in "$week_reset")")
fi
# One reset segment, in the same order as the limits above: "↻ 43m / 21h".
if ((${#resets[@]} == 2)) && [[ ${resets[*]} != '- -' ]]; then
  segs+=("↻ ${resets[0]} / ${resets[1]}")
elif ((${#resets[@]} == 1)) && [[ ${resets[0]} != - ]]; then
  segs+=("↻ ${resets[0]}")
fi

for i in "${!segs[@]}"; do
  ((i > 0)) && out+=$sep
  out+=${segs[i]}
done

printf '%s\n' "$out"
