#!/usr/bin/env bash

set -euo pipefail

echo "🚀 Setting up Mason brick: feature_clean_architecture"

if ! command -v mason >/dev/null 2>&1; then
  echo "📦 mason_cli not found. Installing..."
  dart pub global activate mason_cli
fi

mkdir -p bricks
cd bricks

if [ ! -d "feature_clean_architecture" ]; then
  mason new feature_clean_architecture
  echo "✅ Mason brick created at bricks/feature_clean_architecture"
else
  echo "ℹ️ Brick directory already exists. Skipping creation."
fi

cat <<'EOT'
Next steps:
  1. Copy the prepared template files into bricks/feature_clean_architecture/__brick__/
  2. Run: mason make feature_clean_architecture
EOT


