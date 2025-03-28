#!/usr/bin/env bash
# shellcheck disable=SC2181
set -e

# cwd to script directory
cd "$(dirname "$0")"

fetch_data() {
  for _ in $(seq 1 10); do
    # fetch the data
    data=$(curl -sL https://data.phishtank.com/data/online-valid.json)

    # check if curl was successful
    if [[ $? -ne 0 ]]; then
      echo "Curl failed. Retrying..."
      sleep 60
      continue
    fi

    # check if data is non-empty
    if [[ -z "$data" ]]; then
      echo "Received empty response. Retrying..."
      sleep 60
      continue
    fi

    # validate JSON
    if ! echo "$data" | jq empty; then
      echo "Received invalid JSON. Retrying..."
      sleep 60
      continue
    fi

    return 0
  done

  return 1
}

echo "Fetching latest data from phishtank..."
if ! fetch_data; then
  echo "Failed to fetch data after multiple attempts."
  exit 1
fi

echo "Saving data to hosts.json..."
echo "$data" > hosts.json
echo "Done, saved to hosts.json"
