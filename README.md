![gatekept — macOS security audit & optimization](assets/banner.png)

# gatekept

**macOS security audit & optimization — catches the threats signature antivirus misses.**

![platform](https://img.shields.io/badge/platform-macOS-black)
![license](https://img.shields.io/badge/license-MIT-blue)
![shell](https://img.shields.io/badge/bash-shellcheck%20clean-green)
![deps](https://img.shields.io/badge/dependencies-none-brightgreen)

> **Why this exists.** During a real cleanup, a planted fake *Adobe Illustrator* — ad-hoc signed, carrying an injected `CoreInject.dylib` loader — was scanned by **ClamAV with 3.6 million signatures** and reported **clean**. Apple's own `codesign --verify` + `spctl` flagged it in **seconds**.
>
> **Signature antivirus does not detect impersonation. Code-signature verification does.** `gatekept` leads with the check that actually works.

---

## What it does

### `gatekept audit` — read-only security audit
- **Hardening posture** — SIP, Gatekeeper, Firewall, FileVault, XProtect version
- **App signature sweep** ⭐ — flags ad-hoc signed apps, dev/sideloaded certs, injector dylibs, and unknown-signer + Gatekeeper-rejected apps — the real fake/cracked-app fingerprint
- **Injector-dylib deep sweep** across `/Applications`
- **Persistence audit** — LaunchAgents & LaunchDaemons
- **Recent installs** + live **CPU / memory / swap** snapshot

### `gatekept optimize` — reclaim space (dry-run by default)
- Reports & (with `--apply`) clears regenerable dev caches: npm, pnpm, pip, Homebrew, Xcode DerivedData, simulator caches
- Deletes only **unavailable** iOS simulators
- Memory-pressure report with actionable guidance

### `gatekept report` — live HTML dashboard
Generates a **self-contained HTML report** and opens it in your browser — security posture, scanned / verified / flagged metrics, a per-app signature table, notarization + hardened-runtime counts, reclaimable caches, and memory pressure. No server, no dependencies; pure local file.

> The generated report contains your real machine/app data — it is written to `$TMPDIR` and **git-ignored**. Never commit it.

### `gatekept scan` — optional ClamAV layer
Known-malware signatures — complements, does not replace, the signature sweep.

---

## Quick start

```bash
# clone
git clone https://github.com/myusufyilmaz/gatekept.git
cd gatekept

# run (safe, read-only)
bin/gatekept audit

# see what could be cleaned (no changes)
bin/gatekept optimize

# actually clean caches
bin/gatekept optimize --apply
```

Optional — put it on your PATH:
```bash
ln -s "$PWD/bin/gatekept" /usr/local/bin/gatekept   # or ~/bin
gatekept full
```

### Use it as a Claude Code skill
```bash
git clone https://github.com/myusufyilmaz/gatekept.git ~/.claude/skills/gatekept
```
Then ask Claude: *"security scan my mac"* or *"optimize my mac"*.

---

## Commands

| Command | Effect | Writes? |
|---|---|---|
| `gatekept audit` | full security audit | ❌ read-only |
| `gatekept report` | HTML dashboard, opens in browser | ❌ read-only |
| `gatekept optimize` | report reclaimable caches | ❌ read-only |
| `gatekept optimize --apply` | clean caches + unused sims | ✅ caches only |
| `gatekept scan` | ClamAV known-malware scan | ❌ read-only |
| `gatekept full` | audit + optimize (dry-run) | ❌ read-only |
| `gatekept --help` / `--version` | help / version | ❌ |

---

## Triaging a flagged app

A real vendor app shows a `Developer ID Application: …` authority **and** a TeamID **and** is Gatekeeper-accepted:

```bash
codesign -dvvv "/Applications/Suspect.app" | grep -E 'Authority|TeamId|adhoc'
spctl -a -t exec -vv "/Applications/Suspect.app"
```

| Signal | Meaning |
|---|---|
| `Signature=adhoc` | self-signed locally — no real certificate |
| `TeamIdentifier=not set` | no vendor team — fake |
| `*Inject*.dylib` in `Contents/MacOS` | code-injection loader (cracked-app pattern) |
| `Apple Development:` cert | sideloaded / repackaged build |
| `codesign-fail` **+** Gatekeeper-rejected | tampered |

**Remove to Trash (reversible) — never `rm -rf`:**
```bash
mv "/Applications/Bad.app" "$HOME/.Trash/Bad.app (untrusted)"
```

---

## Security model

- **Read-only by default.** Only `optimize --apply` writes, and only to regenerable package-manager caches via their own tools (`npm cache clean`, `brew cleanup`, …). It never deletes user files, app data, or documents.
- **No `rm -rf`.** Removal of suspicious apps is your decision, to Trash.
- **Cloud-safe.** The iCloud / Google Drive `CloudStorage` mount is excluded from every scan, so nothing force-downloads your cloud files.
- **No dependencies, no network** (except the optional, user-invoked ClamAV). Pure Bash over Apple's built-in tools.
- **Auditable.** One readable script — `shellcheck`-clean. Read it before you run it.

See [SECURITY.md](SECURITY.md) for reporting.

---

## Limitations

- `audit`'s signature sweep takes ~1–3 min (one `spctl` assessment per app).
- ClamAV is **not** bundled — install separately (`brew install clamav && freshclam`). It catches known-malware hashes, not impersonation.
- Heuristics target the common fake/cracked-app patterns; a sufficiently sophisticated, properly-signed-then-revoked binary can still slip past. This is a strong first line, not a guarantee.

---

## Credits & inspiration

- **[Trail of Bits — Claude Code security skills](https://github.com/trailofbits/skills)** — gold-standard security skills (Mach-O / YARA aware). Complementary for deep binary analysis.
- **[ClamAV](https://www.clamav.net/)** (Cisco Talos) — optional known-malware layer, called as an external binary (not bundled).
- **Apple** `codesign` / `spctl` / `fdesetup` — the verification tools doing the real work.
- Skill-vetting tools worth knowing: [claude-skill-antivirus](https://github.com/claude-world/claude-skill-antivirus), [Repello SkillCheck](https://repello.ai/blog/claude-code-skill-security).

This is **original work** — it orchestrates Apple's built-in tools and credits the ecosystem that informed it; it does not copy code from the above.

---

## Contributing

PRs welcome — especially more fake-app fingerprints, Apple Silicon edge cases, and false-positive tuning for Electron/Chromium apps.

## License

[MIT](LICENSE).
