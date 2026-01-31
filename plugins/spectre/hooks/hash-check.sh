#!/bin/bash

SPECS_DIR="specs"
STATE_FILE="specs/.spectre-state.json"

if [ ! -d "$SPECS_DIR" ]; then
    exit 0
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "{}" > "$STATE_FILE"
fi

if ! command -v jq &> /dev/null; then
    exit 0
fi

extract_files_from_spec() {
    local spec_file="$1"
    # Extract files from the Where section
    # Supports both Unicode (─── Where ───) and ASCII (--- Where ---) formats
    awk '
        /^─── Where/ || /^--- Where/ { in_where = 1; next }
        /^───/ || /^━━━/ || /^---/ { if (in_where) in_where = 0 }
        in_where && /\.(swift|ts|js|py|go|rs|java|kt|rb|cpp|c|h):[0-9]/ {
            line = $0
            # Look for common project directory patterns to extract relative path
            # Matches: everhour/, convex/, src/, lib/, app/, etc.
            if (match(line, /(everhour|convex|src|lib|app|test|tests|spec|specs)\/[A-Za-z0-9_\/.-]+\.(swift|ts|js|py|go|rs|java|kt|rb|cpp|c|h)/)) {
                print substr(line, RSTART, RLENGTH)
            }
        }
    ' "$spec_file" 2>/dev/null | sort -u
}

hash_file() {
    local file="$1"
    if [ -f "$file" ]; then
        shasum -a 256 "$file" 2>/dev/null | cut -d' ' -f1
    else
        echo "missing"
    fi
}

extract_spec_ids() {
    local spec_file="$1"
    # Match both formats:
    # Unicode: "  ✅ Spec name" or "  🔄 Spec name"
    # ASCII: "  -  Spec name             PASS 2026-01-31"
    {
        grep -E '^  [✅🔄❌⏸] ' "$spec_file" 2>/dev/null | sed 's/^  [✅🔄❌⏸] //' | sed 's/ *$//'
        grep -E '^  -  .+(PASS|FAIL|STALE|not run)' "$spec_file" 2>/dev/null | sed 's/^  -  //' | sed 's/ *\(PASS\|FAIL\|STALE\|not run\).*//'
    } | sort -u
}

for spec_file in "$SPECS_DIR"/*.md; do
    [ -f "$spec_file" ] || continue

    spec_basename=$(basename "$spec_file")
    files=$(extract_files_from_spec "$spec_file")
    spec_ids=$(extract_spec_ids "$spec_file")

    [ -z "$files" ] && [ -z "$spec_ids" ] && continue

    file_hashes="{}"
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        current_hash=$(hash_file "$file")
        file_hashes=$(echo "$file_hashes" | jq --arg f "$file" --arg h "$current_hash" '. + {($f): $h}')
    done <<< "$files"

    stored_data=$(jq -r --arg spec "$spec_basename" '.[$spec] // {}' "$STATE_FILE" 2>/dev/null)
    stored_hashes=$(echo "$stored_data" | jq -r '.files // {}')

    has_changes="false"
    if [ "$stored_hashes" != "{}" ] && [ "$stored_hashes" != "null" ]; then
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            current_hash=$(echo "$file_hashes" | jq -r --arg f "$file" '.[$f] // "none"')
            stored_hash=$(echo "$stored_hashes" | jq -r --arg f "$file" '.[$f] // "none"')

            if [ "$stored_hash" != "none" ] && [ "$current_hash" != "$stored_hash" ]; then
                has_changes="true"
                break
            fi
        done <<< "$files"
    fi

    if [ "$has_changes" = "true" ]; then
        # Handle both Unicode (✅ → 🔄) and ASCII (PASS → STALE) formats
        sed -i.bak -e 's/^  ✅ /  🔄 /g' -e 's/PASS \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)/STALE \1/g' "$spec_file"
        rm -f "${spec_file}.bak"
    fi

    new_spec_data=$(jq -n --argjson files "$file_hashes" '{"files": $files}')

    tmp_file=$(mktemp)
    jq --arg spec "$spec_basename" --argjson data "$new_spec_data" '.[$spec] = $data' "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
done
