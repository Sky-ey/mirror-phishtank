#!/usr/bin/env bash
# shellcheck disable=SC2181
set -e

# cwd to script directory
cd "$(dirname "$0")"

fetch_json_data() {
  for _ in $(seq 1 5); do
    # fetch the JSON data
    data=$(curl -sL https://data.phishtank.com/data/online-valid.json)

    # check if curl was successful
    if [[ $? -ne 0 ]]; then
      echo "JSON curl failed. Retrying..."
      sleep 60
      continue
    fi

    # check if data is non-empty
    if [[ -z "$data" ]]; then
      echo "Received empty JSON response. Retrying..."
      sleep 60
      continue
    fi

    # validate JSON
    if ! echo "$data" | jq empty; then
      echo "Received invalid JSON. Retrying..."
      sleep 60
      continue
    fi

    # clean data - remove null bytes and fix invalid numeric literals
    data=$(echo "$data" | tr -d '\000' | jq -c .)

    return 0
  done

  return 1
}

fetch_csv_data() {
  for _ in $(seq 1 5); do
    # fetch the CSV data
    csv_data=$(curl -sL https://data.phishtank.com/data/online-valid.csv)

    # check if curl was successful
    if [[ $? -ne 0 ]]; then
      echo "CSV curl failed. Retrying..."
      sleep 60
      continue
    fi

    # check if data is non-empty
    if [[ -z "$csv_data" ]]; then
      echo "Received empty CSV response. Retrying..."
      sleep 60
      continue
    fi

    return 0
  done

  return 1
}

echo "Fetching latest JSON data from phishtank..."
if ! fetch_json_data; then
  echo "Failed to fetch JSON data after multiple attempts."
else
  echo "Saving JSON data to hosts.json..."
  echo "$data" > hosts.json
  echo "Done, saved to hosts.json"
fi

echo "Fetching latest CSV data from phishtank..."
if ! fetch_csv_data; then
  echo "Failed to fetch CSV data after multiple attempts."
else
  echo "Saving CSV data to hosts.csv..."
  echo "$csv_data" > hosts.csv
  echo "Done, saved to hosts.csv"
fi
