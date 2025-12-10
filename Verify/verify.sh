#!/usr/bin/env bash
set -euo pipefail

KEYSERVER="hkps://keyserver.ubuntu.com"

if ! command -v gpg &>/dev/null; then
  echo "Error: gpg not found. Install GnuPG and try again." >&2
  exit 1
fi

usage() {
  cat <<EOF
Usage: $0 <file> <signature.asc | sha512_checksum>
Automatically fetches missing public keys for GPG signatures,
or verifies a SHA512 checksum.
EOF
  exit 1
}

[ $# -eq 2 ] || usage

file="$1"
arg2="$2"

[ -f "$file" ] || { echo "Error: File '$file' not found." >&2; exit 1; }

# Function to verify SHA512 checksum
verify_checksum() {
  local checksum="$1"
  local target="$2"
  
  echo "Verifying SHA512 checksum for '$target'..."
  # format: <checksum>  <filename>
  echo "$checksum  $target" | sha512sum --check --status
  
  if [ $? -eq 0 ]; then
    echo "✅ Checksum matches."
    exit 0
  else
    echo "❌ Checksum verification failed." >&2
    exit 2
  fi
}

# Function to verify GPG signature
verify_gpg() {
  local sig_file="$1"
  local target="$2"

  [ -f "$sig_file" ] || { echo "Error: Signature file '$sig_file' not found." >&2; exit 1; }

  echo "Verifying signature of '$target' with '$sig_file'..."
  gpg --batch --yes \
      --keyserver "$KEYSERVER" \
      --auto-key-retrieve \
      --verify "$sig_file" "$target" 2>&1 | tee /tmp/gpg-verify.log

  # Check result
  if grep -q "Good signature" /tmp/gpg-verify.log; then
    echo "✅ Signature is valid."
    exit 0
  else
    echo "❌ Signature verification failed." >&2
    exit 2
  fi
}

# Determine if arg2 is a file or a checksum
if [ -f "$arg2" ]; then
  # It's a file, assume GPG signature
  verify_gpg "$arg2" "$file"
elif [[ "$arg2" =~ ^[a-fA-F0-9]{128}$ ]]; then
  # It looks like a SHA512 checksum (128 hex characters)
  verify_checksum "$arg2" "$file"
else
  echo "Error: Second argument must be a file (signature) or a valid SHA512 checksum." >&2
  usage
fi
