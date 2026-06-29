# Security Policy

## Scope

`gatekept` is a read-only auditor plus an opt-in cache cleaner. It runs Apple's
built-in tools (`codesign`, `spctl`, `fdesetup`, `find`, `ps`) and, optionally,
ClamAV. It has no dependencies and makes no network calls except the
user-invoked `gatekept scan` (ClamAV).

## What it will never do

- Delete user files, application data, or documents.
- Run `rm -rf` on apps. Removal of flagged apps is left to the user (move to Trash).
- Touch the iCloud / Google Drive `CloudStorage` mount.
- Exfiltrate data or phone home.

Only `gatekept optimize --apply` writes, and only to regenerable package-manager
caches via their own tools.

## Reporting a vulnerability

Open a GitHub issue, or for sensitive reports use GitHub's private
"Report a vulnerability" advisory flow on this repository. Please include:

- macOS version and chip (Intel / Apple Silicon)
- the exact command run
- expected vs actual behavior

## Verifying before you run

This tool is a single readable Bash script. Before running:

```bash
less bin/gatekept            # read it
shellcheck bin/gatekept      # lint it (brew install shellcheck)
```

Treat any third-party "security" tool — including this one — as code to audit,
not to trust blindly.
