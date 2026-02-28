#!/bin/bash
# prepush_check.sh — Verify no binaries, secrets, or large files are staged
# Run before pushing: ./scripts/prepush_check.sh
# Or install as pre-push hook: ln -s ../../scripts/prepush_check.sh .git/hooks/pre-push
set -euo pipefail

ERRORS=0

echo "=== Pre-push checks ==="

# Check for binary files in staged changes
echo -n "Checking for binary files... "
BINARIES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | \
           xargs file 2>/dev/null | grep -v text | grep -v empty || true)
if [ -n "$BINARIES" ]; then
    echo "FAIL"
    echo "Binary files staged for commit:"
    echo "$BINARIES"
    ERRORS=$((ERRORS + 1))
else
    echo "OK"
fi

# Check for common secrets patterns
echo -n "Checking for secrets... "
SECRETS=$(git diff --cached -U0 2>/dev/null | \
          grep -inE '(password|token|secret|api.key|private.key)\s*=' || true)
if [ -n "$SECRETS" ]; then
    echo "WARNING"
    echo "Possible secrets found in diff:"
    echo "$SECRETS"
    ERRORS=$((ERRORS + 1))
else
    echo "OK"
fi

# Check for large files (>1MB)
echo -n "Checking for large files... "
LARGE=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | \
        while read -r f; do
            if [ -f "$f" ]; then
                SIZE=$(stat --format=%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo 0)
                if [ "$SIZE" -gt 1048576 ]; then
                    echo "$f ($(numfmt --to=iec "$SIZE" 2>/dev/null || echo "${SIZE}B"))"
                fi
            fi
        done)
if [ -n "$LARGE" ]; then
    echo "WARNING"
    echo "Large files (>1MB):"
    echo "$LARGE"
    ERRORS=$((ERRORS + 1))
else
    echo "OK"
fi

# Check for vendor blobs
echo -n "Checking for vendor blobs... "
BLOBS=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | \
        grep -iE '\.(imx|fw|blob)$' || true)
if [ -n "$BLOBS" ]; then
    echo "FAIL"
    echo "Vendor blob files:"
    echo "$BLOBS"
    ERRORS=$((ERRORS + 1))
else
    echo "OK"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "=== $ERRORS issue(s) found. Review before pushing. ==="
    exit 1
else
    echo "=== All checks passed ==="
    exit 0
fi
