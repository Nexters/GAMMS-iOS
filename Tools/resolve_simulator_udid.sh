#!/usr/bin/env bash
set -euo pipefail

xcrun simctl list devices available --json | jq -r '
  .devices
  | to_entries
  | map(select(.key | test("^com\\.apple\\.CoreSimulator\\.SimRuntime\\.iOS-")))
  | map(select(.key | capture("iOS-(?<maj>[0-9]+)-(?<min>[0-9]+)") as $v
      | ($v.maj | tonumber) > 18 or (($v.maj | tonumber) == 18 and ($v.min | tonumber) >= 1)))
  | map(.value[])
  | map(select(.isAvailable == true and (.name | startswith("iPhone"))))
  | (map(select(.name == "iPhone 16")) + .)
  | .[0].udid // empty
'
