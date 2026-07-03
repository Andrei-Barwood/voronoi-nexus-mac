#!/bin/bash
#
# batch-process.sh
# Advanced example: Process multiple input files with affine-replica
#
# Usage:
#   ./examples/batch-process.sh                    # uses release binary if available
#   ./examples/batch-process.sh --debug            # force debug binary
#   ./examples/batch-process.sh --json-summary     # output machine-readable summary
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Determine which binary to use
BINARY=""
USE_DEBUG=false
JSON_SUMMARY=false

for arg in "$@"; do
    case $arg in
        --debug)
            USE_DEBUG=true
            shift
            ;;
        --json-summary)
            JSON_SUMMARY=true
            shift
            ;;
    esac
done

if [ "$USE_DEBUG" = true ]; then
    BINARY="$PROJECT_ROOT/.build/debug/affine-replica"
else
    if [ -f "$PROJECT_ROOT/.build/release/affine-replica" ]; then
        BINARY="$PROJECT_ROOT/.build/release/affine-replica"
    else
        BINARY="$PROJECT_ROOT/.build/debug/affine-replica"
    fi
fi

if [ ! -f "$BINARY" ]; then
    echo "❌ Binary not found. Build it first:"
    echo "   swift build -c release"
    echo "   or"
    echo "   swift build"
    exit 1
fi

INPUT_DIR="$SCRIPT_DIR/inputs"
TOTAL=0
CRITICAL=0
HIGH=0
MEDIUM=0
CLEAN=0

echo "🚀 Batch Processing with affine-replica"
echo "Binary: $BINARY"
echo "Inputs: $INPUT_DIR"
echo "──────────────────────────────────────────────"

RESULTS=()

for file in "$INPUT_DIR"/*.json; do
    if [ ! -f "$file" ]; then
        continue
    fi

    filename=$(basename "$file")
    echo ""
    echo "▶ Processing: $filename"

    # Run analysis (suppress the mission header for batch)
    output=$($BINARY analyze --input "$file" --json 2>/dev/null || true)

    alerts=$(echo "$output" | jq -r '.data.alerts_count // 0' 2>/dev/null || echo 0)
    status=$(echo "$output" | jq -r '.status // "error"' 2>/dev/null || echo "error")

    TOTAL=$((TOTAL + 1))

    if [ "$alerts" -eq 0 ]; then
        echo "   ✅ Clean (0 alerts)"
        CLEAN=$((CLEAN + 1))
    else
        crit_count=$(echo "$output" | jq '[.data.findings[] | select(.severity == "critical")] | length' 2>/dev/null || echo 0)
        high_count=$(echo "$output" | jq '[.data.findings[] | select(.severity == "high")] | length' 2>/dev/null || echo 0)
        med_count=$(echo "$output" | jq '[.data.findings[] | select(.severity == "medium")] | length' 2>/dev/null || echo 0)

        CRITICAL=$((CRITICAL + crit_count))
        HIGH=$((HIGH + high_count))
        MEDIUM=$((MEDIUM + med_count))

        echo "   ⚠️  $alerts alerts (Critical: $crit_count | High: $high_count | Medium: $med_count)"
    fi

    RESULTS+=("{\"file\":\"$filename\",\"alerts\":$alerts,\"status\":\"$status\"}")
done

echo ""
echo "══════════════════════════════════════════════"
echo "📊 BATCH SUMMARY"
echo "══════════════════════════════════════════════"
echo "Files processed: $TOTAL"
echo "Clean files:     $CLEAN"
echo "Total Critical:  $CRITICAL"
echo "Total High:      $HIGH"
echo "Total Medium:    $MEDIUM"
echo ""

if [ "$JSON_SUMMARY" = true ]; then
    echo "JSON Summary:"
    printf '%s\n' "${RESULTS[@]}" | jq -s '{total: length, summary: {clean: '"$CLEAN"', critical_findings: '"$CRITICAL"', high_findings: '"$HIGH"', medium_findings: '"$MEDIUM"'}, results: .}'
fi

if [ "$CRITICAL" -gt 0 ]; then
    echo "❌ Batch completed with critical findings."
    exit 1
elif [ "$HIGH" -gt 0 ]; then
    echo "⚠️  Batch completed with high-severity findings."
    exit 1
else
    echo "✅ Batch completed cleanly."
    exit 0
fi
