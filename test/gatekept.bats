#!/usr/bin/env bats
# Smoke tests for gatekept. Run: bats test

GK="${BATS_TEST_DIRNAME}/../bin/gatekept"

@test "prints version" {
  run "$GK" --version
  [ "$status" -eq 0 ]
  [[ "$output" == gatekept\ * ]]
}

@test "prints help with usage" {
  run "$GK" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: gatekept"* ]]
}

@test "unknown command exits 2" {
  run "$GK" bogus
  [ "$status" -eq 2 ]
}

@test "optimize dry-run is read-only and succeeds" {
  run "$GK" optimize
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY-RUN"* ]]
}

@test "audit --json emits valid JSON" {
  run bash -c "'$GK' audit --json | python3 -m json.tool > /dev/null"
  [ "$status" -eq 0 ]
}

@test "_classify worker emits a TSV record for a real app" {
  app=$(find /Applications -maxdepth 1 -name '*.app' | head -1)
  [ -n "$app" ] || skip "no apps to classify"
  run "$GK" _classify "$app"
  [ "$status" -eq 0 ]
  [[ "$output" == OK*$'\t'* || "$output" == FLAG*$'\t'* ]]
}

@test "audit --json exposes new detection counters" {
  run bash -c "'$GK' audit --json | python3 -c 'import json,sys; s=json.load(sys.stdin)[\"summary\"]; assert all(k in s for k in (\"login_item_flags\",\"staging_flags\",\"persistence_flags\",\"shell_hijack_flags\"))'"
  [ "$status" -eq 0 ]
}

@test "audit text output includes login-items and staging sections" {
  run "$GK" audit
  [[ "$output" == *"Login items"* ]]
  [[ "$output" == *"Malware staging"* ]]
}
