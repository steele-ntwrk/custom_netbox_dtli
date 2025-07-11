#!/bin/bash
set -e

PLUGIN_REQS="plugin_requirements.txt"
PLUGIN_SRC_DIR="plugins_src"
OFFLINE_DIR="plugins_offline"
BUNDLE_NAME="netbox_plugin_bundle.tgz"

# 1. Clean old output
rm -rf "$OFFLINE_DIR" "$BUNDLE_NAME"
mkdir -p "$OFFLINE_DIR"

echo "[+] Reading plugin requirements from $PLUGIN_REQS"

# 2. Optionally build local plugin wheels from source
if [ -d "$PLUGIN_SRC_DIR" ]; then
  echo "[+] Building local plugin wheels from $PLUGIN_SRC_DIR"
  mkdir -p "$OFFLINE_DIR/plugins"
  for plugin in "$PLUGIN_SRC_DIR"/*; do
    [ -d "$plugin" ] || continue
    echo "  ↳ Building wheel for $(basename "$plugin")"
    python3 -m pip install build >/dev/null 2>&1 || pip install build
    python3 -m build "$plugin" --outdir "$OFFLINE_DIR/plugins"
  done
  echo "[+] Local plugin wheels ready."
fi

# 3. Combine local wheels and requirements for download
echo "[+] Downloading plugin dependencies..."
mkdir -p "$OFFLINE_DIR/vendor"

# If we built wheels locally, include them too
if compgen -G "$OFFLINE_DIR/plugins/*.whl" > /dev/null; then
  for whl in "$OFFLINE_DIR/plugins/"*.whl; do
    echo "  ↳ Resolving deps for $(basename "$whl")"
    pip download "$whl" -d "$OFFLINE_DIR/vendor"
  done
fi

# Download all dependencies for plugin_requirements.txt
python3 -m pip download -r "$PLUGIN_REQS" -d "$OFFLINE_DIR/vendor"

# 4. Archive the bundle
echo "[+] Creating tarball $BUNDLE_NAME"
tar -czf "$BUNDLE_NAME" -C "$OFFLINE_DIR" .

echo "[✓] Bundle ready. Copy $BUNDLE_NAME to your offline NetBox build context."
