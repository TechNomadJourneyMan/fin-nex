#!/usr/bin/env bash
#
# coverage.sh — run `flutter test --coverage` across every package that has a
# test/ directory and merge the per-package lcov.info files into a single
# top-level coverage/lcov.info, then print the aggregate line-coverage percent.
#
# Usage:
#   tools/coverage.sh            # run all packages
#   tools/coverage.sh --quick    # skip packages whose tests are slow (none yet)
#
# Requires: flutter on PATH (or set FLUTTER). lcov's genhtml is optional; the
# summary is computed directly from the merged lcov data with awk so no extra
# tooling is needed.

set -uo pipefail

# Repo root = parent of this script's directory.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER="${FLUTTER:-flutter}"
OUT_DIR="$ROOT/coverage"
MERGED="$OUT_DIR/lcov.info"

mkdir -p "$OUT_DIR"
: > "$MERGED"

# Packages to cover: every dir containing a test/ folder.
PKGS=()
for d in \
  "$ROOT"/packages/core/* \
  "$ROOT"/packages/domain \
  "$ROOT"/packages/data/* \
  "$ROOT"/packages/features/* \
  "$ROOT"/packages/services/* \
  "$ROOT"/apps/pocketflow; do
  [ -d "$d/test" ] && PKGS+=("$d")
done

echo "==> Covering ${#PKGS[@]} packages"

# Per-package wall-clock budget (seconds). A package that exceeds it is killed
# so one hung test file cannot block the whole report. Override via PKG_TIMEOUT.
PKG_TIMEOUT="${PKG_TIMEOUT:-300}"

# Portable timeout: run "$@" and SIGKILL it after PKG_TIMEOUT seconds.
run_with_timeout() {
  "$@" &
  local pid=$!
  ( sleep "$PKG_TIMEOUT"; kill -KILL "$pid" 2>/dev/null ) &
  local watchdog=$!
  wait "$pid"
  local rc=$?
  kill "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null
  return $rc
}

fail=0
for pkg in "${PKGS[@]}"; do
  name="$(basename "$pkg")"
  echo "----------------------------------------------------------------------"
  echo "==> $name"
  ( cd "$pkg" && run_with_timeout "$FLUTTER" test --coverage ) || {
    echo "!! tests failed or timed out in $name (continuing)"
    fail=1
  }

  lcov="$pkg/coverage/lcov.info"
  if [ -f "$lcov" ]; then
    # Rewrite SF: paths to be repo-root-relative so the merged report is
    # coherent across packages.
    rel="${pkg#"$ROOT"/}"
    awk -v prefix="$rel/" '
      /^SF:/ {
        path = substr($0, 4)
        if (path !~ /^\//) path = prefix path
        print "SF:" path
        next
      }
      { print }
    ' "$lcov" >> "$MERGED"
  else
    echo "   (no lcov.info produced for $name)"
  fi
done

echo "======================================================================"
if [ ! -s "$MERGED" ]; then
  echo "No coverage data collected."
  exit 1
fi

# Aggregate line coverage: LF = lines found, LH = lines hit.
awk '
  /^LF:/ { lf += substr($0, 4) }
  /^LH:/ { lh += substr($0, 4) }
  END {
    if (lf == 0) { print "No lines instrumented."; exit }
    printf "Merged lcov: %s\n", "coverage/lcov.info"
    printf "Lines hit : %d / %d\n", lh, lf
    printf "Line coverage: %.2f%%\n", (lh / lf) * 100.0
  }
' "$MERGED"

exit 0
