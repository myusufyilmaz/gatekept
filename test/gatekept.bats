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
