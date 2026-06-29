---
name: gatekept
description: Audit and optimize a macOS machine. Use when the user asks to security-scan, virus-scan, check for fake/cracked/malware apps, harden, clean up, or speed up their Mac. Catches impersonating/tampered apps that signature antivirus misses (via codesign/spctl), audits posture and persistence, and reclaims dev caches. macOS only.
---

# gatekept

End-to-end macOS security audit + optimization. Built because no off-the-shelf
skill covers macOS host hygiene — signature antivirus (ClamAV/Avast) does **not**
catch cracked/impersonating apps; code-signature verification does.

## When to use

Trigger on: "security scan my mac", "check for viruses", "is this app fake",
"find malware", "harden my mac", "clean up / speed up my mac".

## Core principle (do not skip)

**Signature AV ≠ impersonation detection.** A cracked "Adobe" app with an injected
dylib passes ClamAV clean. `codesign --verify` + `spctl` catch it instantly. The
`audit` command's signature sweep is the high-value check — always run it.

## How to run

The CLI lives at `bin/gatekept`. All commands are read-only except
`optimize --apply`.

```bash
bin/gatekept audit            # read-only security audit (default)
bin/gatekept audit --json     # same, machine-readable JSON
bin/gatekept report           # generate + open an HTML dashboard
bin/gatekept optimize         # dry-run: report reclaimable caches
bin/gatekept optimize --apply # clean npm/pnpm/pip/brew caches + unused sims
bin/gatekept scan             # ClamAV known-malware scan (if installed)
bin/gatekept full             # audit + optimize (dry-run)
bin/gatekept --help
```

`audit` covers: hardening posture; a parallel app signature sweep (ad-hoc /
dev-cert / injector-dylib / unknown-signer detection + notarization + hardened
runtime); **deep persistence** (code-signs each LaunchAgent/Daemon target binary,
flags unsigned/ad-hoc/user-writable); and a **shell-config hijack** scan. It
exits **0** clean, **3** when anything is flagged (use this in scripts/CI).

`report` writes a self-contained HTML dashboard (default
`$TMPDIR/gatekept-report.html`) and opens it — posture, scanned/verified/flagged
metrics, per-app signature table, notarization + hardened-runtime counts, caches,
memory. The generated file contains real machine data and is git-ignored; never
commit it.

## Triage workflow (what the agent should do)

1. Run `bin/gatekept audit`. Read the ⚠ lines under "App signature sweep".
2. For each flagged app, confirm before acting:
   ```bash
   codesign -dvvv "/Applications/Name.app" | grep -E 'Authority|TeamId|adhoc'
   spctl -a -t exec -vv "/Applications/Name.app"
   ```
   Legit vendor app = `Developer ID Application: …` authority + a TeamID +
   Gatekeeper-accepted. `adhoc` / dev-cert / injector dylib / unknown-signer +
   rejected = fake or cracked.
3. Remove confirmed-malicious apps — **ASK FIRST**, move to Trash (reversible):
   ```bash
   mv "/Applications/Bad.app" "$HOME/.Trash/Bad.app (untrusted)"
   ```
   Never `rm -rf` user-facing apps. Trash is reversible.
4. Optimize: `bin/gatekept optimize` first (dry-run), then `--apply` if the user agrees.

## Safety rules

- `audit` / `scan` change nothing. `optimize` is dry-run unless `--apply`.
- The iCloud / Google Drive `CloudStorage` mount is excluded from all scans
  (scanning it would force-download every cloud file).
- Confirm before deleting anything. Prefer Trash over `rm`.
- Don't install third-party "security" skills without vetting — that's running
  untrusted code on a machine you're trying to secure.

## Known false-positive handling

`audit` classifies by signing Authority so it does NOT flag: Apple system apps
(`Software Signing`), iOS apps on Apple Silicon (`Apple iPhone OS Application
Signing`), or properly-distributed `Developer ID` apps (whose `--deep` verify
often false-fails on large Electron/Chromium bundles).
