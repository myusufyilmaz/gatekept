# Contributing to gatekept

Thanks for helping improve gatekept. It's a single, dependency-free Bash CLI —
keep it that way.

## Ground rules

- **macOS + Bash only.** No external runtime deps. Use Apple's built-in tools
  (`codesign`, `spctl`, `plutil`, `fdesetup`, etc.).
- **Read-only by default.** Only `optimize --apply` may write, and only to
  regenerable caches. Never delete user data. Never `rm -rf` an app.
- **Never exfiltrate or phone home.** The only network call is the optional,
  user-invoked `gatekept scan` (ClamAV).
- **Never commit real machine data.** Generated reports are git-ignored; the
  banner uses sample data only.

## Before you open a PR

```bash
shellcheck bin/gatekept        # must be clean (severity: warning)
bats test                      # must pass  (brew install bats-core)
bin/gatekept audit             # sanity-run on your machine
```

CI runs ShellCheck (Ubuntu) and bats (macOS) on every push and PR — both must
be green.

## Good contributions

- New fake/cracked-app fingerprints (with the codesign/spctl signal that
  identifies them).
- False-positive fixes — especially for legitimately-signed apps that fail
  `--deep` verification (Electron/Chromium) or non-standard-but-valid signers.
- New persistence vectors (BTM/login items, cron, `at`, login hooks).
- Apple Silicon / Intel and older-macOS edge cases.

## Style

- Functions for logic; keep `main()` a thin dispatcher.
- Quote expansions. Prefer `printf` over `echo` for data.
- Match the existing helper style (`bold`, `flag`, `ok`, `info`).
