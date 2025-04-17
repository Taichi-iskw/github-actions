#!/bin/bash

# 環境変数
# JIT_TOKEN=""
OWNER=""
REPO=""
WORKFLOW_FILE=""
REF=""
POLL_INTERVAL=1

# API ベースURL
BASE_API="https://api.github.com/repos/$OWNER/$REPO"

# ヘッダー共通化
AUTH_HEADER="Authorization: token $JIT_TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github+json"
VERSION_HEADER="X-GitHub-Api-Version: 2022-11-28"
HEADERS=(-H "$AUTH_HEADER" -H "$ACCEPT_HEADER" -H "$VERSION_HEADER")

# Workflow dispatch
echo "Dispatching workflow: $WORKFLOW_FILE on ref: $REF"
curl -s -X POST \
  "${HEADERS[@]}" \
  "$BASE_API/actions/workflows/$WORKFLOW_FILE/dispatches" \
  -d "{\"ref\":\"$REF\"}"

# wait a bit
sleep 2

# Run ID取得
RUN_ID=$(curl -s "${HEADERS[@]}" "$BASE_API/actions/runs" \
  | jq '.workflow_runs[0].id')

echo "Waiting for workflow run $RUN_ID to finish..."

# Polling loop
while true; do
  RESPONSE=$(curl -s "${HEADERS[@]}" "$BASE_API/actions/runs/$RUN_ID")
  STATUS=$(echo "$RESPONSE" | jq -r '.status')
  CONCLUSION=$(echo "$RESPONSE" | jq -r '.conclusion')

  echo "Status: $STATUS, Conclusion: $CONCLUSION"

  if [ "$STATUS" == "completed" ]; then
    if [ "$CONCLUSION" == "success" ]; then
      echo "✅ Workflow succeeded!"
      exit 0
    elif [ "$CONCLUSION" == "failure" ] || [ "$CONCLUSION" == "cancelled" ]; then
      echo "❌ Workflow failed or cancelled!"
      exit 1
    fi
  fi

  sleep "$POLL_INTERVAL"
done
