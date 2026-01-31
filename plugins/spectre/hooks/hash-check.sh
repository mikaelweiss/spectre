#!/bin/bash

SPECS_DIR="specs"
STATE_FILE="specs/.spectre-state.json"

if [ ! -d "$SPECS_DIR" ]; then
    exit 0
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "{}" > "$STATE_FILE"
fi

extract_files_from_spec() {
    local spec_file="$1"
    # Extract files from the Where section (lines between "─── Where" and the next "───" or end of spec)
    awk '
        /─── Where ───/ { in_where = 1; next }
        /^───/ || /^━━━/ { in_where = 0 }
        in_where && /\.(swift|ts|js|py|go|rs|java|kt|rb|cpp|c|h):[0-9]+/ {
            # Extract just the file path (before the colon and line number)
            match($0, /[A-Za-z][A-Za-z0-9_\/.-]*\.(swift|ts|js|py|go|rs|java|kt|rb|cpp|c|h)/)
            if (RSTART > 0) print substr($0, RSTART, RLENGTH)
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

get_stored_hash() {
    local spec_file="$1"
    local file_path="$2"
    local spec_basename=$(basename "$spec_file")

    if command -v jq &> /dev/null; then
        jq -r --arg spec "$spec_basename" --arg file "$file_path" \
            '.[$spec] // {} | to_entries[] | .value.files[$file] // "none"' \
            "$STATE_FILE" 2>/dev/null | head -1
    else
        echo "none"
    fi
}

update_spec_status() {
    local spec_file="$1"
    local has_changes="$2"

    if [ "$has_changes" = "true" ]; then
        sed -i.bak 's/^  ✅ /  🔄 /g' "$spec_file"
        rm -f "${spec_file}.bak"
    fi
}

for spec_file in "$SPECS_DIR"/*.md; do
    [ -f "$spec_file" ] || continue

    files=$(extract_files_from_spec "$spec_file")
    [ -z "$files" ] && continue

    has_changes="false"

    while IFS= read -r file; do
        [ -z "$file" ] && continue

        current_hash=$(hash_file "$file")
        stored_hash=$(get_stored_hash "$spec_file" "$file")

        if [ "$current_hash" != "$stored_hash" ] && [ "$stored_hash" != "none" ]; then
            has_changes="true"
        fi
    done <<< "$files"

    update_spec_status "$spec_file" "$has_changes"
done
