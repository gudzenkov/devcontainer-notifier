#!/usr/bin/env bash
set -euo pipefail

VSIX_PATH=${1:-}
if [[ -z "$VSIX_PATH" ]]; then
  echo "Usage: $0 <path-to-vsix>" >&2
  exit 1
fi

if [[ ! -f "$VSIX_PATH" ]]; then
  echo "error: VSIX not found at '$VSIX_PATH'. Run 'npm run package' first." >&2
  exit 1
fi

resolve_cli() {
  local candidate="$1"
  if [[ -x "$candidate" ]]; then
    echo "$candidate"
    return 0
  fi
  if command -v "$candidate" >/dev/null 2>&1; then
    command -v "$candidate"
    return 0
  fi
  return 1
}

CANDIDATES=()
if [[ -n "${VSCODE_BIN:-}" ]]; then
  CANDIDATES+=("$VSCODE_BIN")
fi
CANDIDATES+=("code" \
            "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
            "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code")

VSCODE_CLI=""
for candidate in "${CANDIDATES[@]}"; do
  if cli_path=$(resolve_cli "$candidate"); then
    VSCODE_CLI="$cli_path"
    break
  fi
done

if [[ -z "$VSCODE_CLI" ]]; then
  echo "error: Unable to locate VS Code CLI. Set VSCODE_BIN to the binary (e.g. /Applications/Visual Studio Code.app/Contents/Resources/app/bin/code)." >&2
  exit 1
fi

"$VSCODE_CLI" --install-extension "$VSIX_PATH" --force
