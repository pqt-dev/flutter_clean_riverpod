#!/usr/bin/env bash
# PreToolUse hook: block edits to generated files, ask before editing pubspec.yaml.
# Fail-open: missing jq or empty input => allow.

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
[ -z "$input" ] && exit 0

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)"
[ -z "$file" ] && exit 0

case "$file" in
  *.g.dart|*.freezed.dart|*.config.dart|*.gen.dart|*.mocks.dart)
    echo "Chặn: '$file' là file generated, không sửa tay. Hãy chạy \`make build_runner\` / \`make l10n\` thay vì sửa tay." >&2
    exit 2
    ;;
  */pubspec.yaml|pubspec.yaml)
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Sửa pubspec.yaml (có thể thêm package): cần user xác nhận theo CLAUDE.md"}}'
    exit 0
    ;;
esac

exit 0
