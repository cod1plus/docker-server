#!/bin/sh
# fetch_pam.sh <manifest url> <destination folder>
# Downloads the PAM pk3s listed in cod1pluspam's pam.manifest and checks every sha256.
#   file <name> <size> <sha256> <url>    -> downloaded and verified
#   remove <name>                        -> an old revision: never installed
set -eu

MANIFEST_URL="$1"
DEST="$2"
mkdir -p "$DEST"

manifest=$(curl -fsSL "$MANIFEST_URL") || {
    echo "fetch_pam: cannot download $MANIFEST_URL" >&2
    exit 1
}
echo "$manifest" | grep -E '^(mod|version) ' || true

echo "$manifest" | while read -r kind name size sha url; do
    [ "$kind" = "file" ] || continue
    case "$name" in */*|..*|"") echo "fetch_pam: bad file name '$name'" >&2; exit 1 ;; esac
    echo "fetch_pam: $name ($size bytes)"
    curl -fsSL --retry 3 -o "$DEST/$name" "$url"
    got=$(sha256sum "$DEST/$name" | cut -d' ' -f1)
    if [ "$got" != "$sha" ]; then
        echo "fetch_pam: sha256 mismatch for $name (got $got, want $sha)" >&2
        exit 1
    fi
done
echo "fetch_pam: done, $(ls "$DEST" | grep -c '\.pk3$') pk3 in $DEST"
