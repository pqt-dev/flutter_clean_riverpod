#!/usr/bin/env bash
# PostToolUse hook: format edited .dart files (skip generated). Never fails the tool call.

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
[ -z "$input" ] && exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -z "$file" ] && exit 0

case "$file" in
  *.g.dart|*.freezed.dart|*.config.dart|*.gen.dart|*.mocks.dart) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

if command -v fvm >/dev/null 2>&1; then
  fvm dart format "$file" >/dev/null 2>&1
elif command -v dart >/dev/null 2>&1; then
  dart format "$file" >/dev/null 2>&1
fi

exit 0
