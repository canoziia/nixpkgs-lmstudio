#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused nix

set -euo pipefail

# Define platforms: "nix_arch remote_platform"
platforms=(
  "aarch64-darwin darwin/arm64" 
  "x86_64-linux linux/x64"
  "aarch64-linux linux/arm64"
)

for system in "${platforms[@]}"; do
  # shellcheck disable=SC2086
  set -- ${system} 

  arch="${1}"
  platform="${2}"

  echo "Updating ${arch}..."

  # Get final URL to extract version
  url=$(curl -ILs -o /dev/null -w %{url_effective} "https://lmstudio.ai/download/latest/${platform}")
  version="$(echo "${url}" | cut -d/ -f6)"
  
  echo "  Found version: ${version}"
  
  # Prefetch and calculate hash
  # nix-prefetch-url returns the hash to stdout
  prefetch_hash=$(nix-prefetch-url "${url}")
  
  # Convert to SRI format
  hash=$(nix --extra-experimental-features nix-command hash convert --hash-algo sha256 "${prefetch_hash}")
  
  echo "  Hash: ${hash}"

  # Update package.nix
  sed -i "s|version_${arch} = \".*\";|version_${arch} = \"${version}\";|" package.nix
  sed -i "s|hash_${arch} = \".*\";|hash_${arch} = \"${hash}\";|" package.nix

done

echo "Update complete."
