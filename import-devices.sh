#!/bin/bash

# Config
CONTAINER_NAME="netbox"
PYTHON_BIN="/opt/dtli/venv/bin/python"
SCRIPT_PATH="/opt/dtli/nb-dt-import.py"
WORKDIR="/opt/dtli"

echo "🔄 Starting device type import from DTLI..."

docker exec -w "$WORKDIR" -it "$CONTAINER_NAME" "$PYTHON_BIN" "$SCRIPT_PATH"

STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "✅ Import completed successfully."
else
    echo "❌ Import failed with exit code $STATUS."
fi
