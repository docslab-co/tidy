#!/bin/bash
set -e

CONFIG_FILE=".tidyconfig.yml"
FILES="."
IGNORE_ARGS=""
ONLY_CHANGED="true"
BASE_BRANCH="main"

# --- Parse config file ---
if [ -f "$CONFIG_FILE" ]; then
  echo "📑 Found config file: $CONFIG_FILE"

  IGNORES=$(yq -r '.ignore[]?' "$CONFIG_FILE" || true)
  for word in $IGNORES; do
    IGNORE_ARGS="$IGNORE_ARGS --ignore $word"
  done

  FILES=$(yq -r '.paths[]?' "$CONFIG_FILE" | xargs || echo ".")
  CFG_ONLY_CHANGED=$(yq -r '.only_changed // true' "$CONFIG_FILE")
  CFG_BASE_BRANCH=$(yq -r '.base_branch // "main"' "$CONFIG_FILE")

  if [ "$CFG_ONLY_CHANGED" = "false" ]; then
    ONLY_CHANGED="false"
  fi

  BASE_BRANCH="$CFG_BASE_BRANCH"
else
  echo "⚙️  No config file found, using defaults"
fi

# --- Override from workflow inputs ---
if [ "${INPUT_ONLY_CHANGED,,}" = "false" ]; then
  ONLY_CHANGED="false"
fi

if [ -n "$INPUT_BASE_BRANCH" ]; then
  BASE_BRANCH="$INPUT_BASE_BRANCH"
fi

# --- Determine files to check ---
if [ "$ONLY_CHANGED" = "true" ]; then
  echo "🔄 Only checking changed files vs base branch: $BASE_BRANCH"

  # Fetch base branch (in case not present in checkout)
  git fetch origin "$BASE_BRANCH":"refs/remotes/origin/$BASE_BRANCH"

  MERGE_BASE=$(git merge-base "origin/$BASE_BRANCH" HEAD)
  CHANGED_FILES=$(git diff --name-only "$MERGE_BASE"...HEAD -- $FILES)

  if [ -z "$CHANGED_FILES" ]; then
    echo "✅ No changed files to check"
    exit 0
  fi

  FILES="$CHANGED_FILES"
fi

echo "🔍 Running spell check on: $FILES"

# --- Run typos ---
OUTPUT=$(typos $FILES $IGNORE_ARGS --format json || true)

if [ -z "$OUTPUT" ]; then
  echo "✅ No typos found"
  exit 0
fi

# --- Annotations ---
echo "$OUTPUT" | jq -r '.[] | "::error file=\(.path),line=\(.line),col=\(.column)::\(.typo) → \(.corrections | join(", "))"'

exit 1
