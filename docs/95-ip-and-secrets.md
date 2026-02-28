# IP and Secrets — What Never to Commit

## Never commit

- DDR firmware blobs (firmware-imx, etc.)
- BSP vendor packages under restrictive license
- Tokens, API keys, passwords
- Absolute local paths in config files (use variables)
- Real `local.conf` / `bblayers.conf` (commit `.sample` versions only)
- NDA-covered documentation or code extracts

## Where to store vendor blobs locally

```
/opt/vendor-blobs/
├─ nxp/
│  ├─ firmware-imx-8.x/
│  └─ README.md          # URL, version, SHA256
└─ rockchip/
   └─ ...
```

Each blob directory has a `README.md` with:
- Source URL
- Exact version
- SHA256 hash
- Download command

## How to document without storing

In the repo, reference only:
> "Retrieve firmware-imx v8.x from https://www.nxp.com/..., SHA256: abc123..."

The `.gitignore` blocks all binaries by extension.

## Pre-push verification

```bash
# Check for binary files staged for commit
git diff --cached --name-only | xargs file 2>/dev/null | grep -v text

# Check for large files
git diff --cached --stat | awk '$3 > 100 {print "WARNING: large file:", $1, $3}'

# Check for common secrets patterns
git diff --cached -U0 | grep -iE '(password|token|secret|api.key)' || true
```

## Rule of thumb

If you can't explain publicly how to get it, it doesn't go in the repo.
Document the "where" and "how", not the content itself.
