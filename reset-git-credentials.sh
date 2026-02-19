#!/usr/bin/env bash
# reset-git-credentials.sh
# Clears the cached Azure DevOps credentials from macOS Keychain.
# Run this before testing the onboarding workflow from scratch.

set -euo pipefail

echo "Clearing Azure DevOps credentials from macOS Keychain..."

git credential-osxkeychain erase << EOF
protocol=https
host=dev.azure.com
EOF

echo "Done. The next 'git clone' from dev.azure.com will prompt for credentials."
