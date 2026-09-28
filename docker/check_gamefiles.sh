#!/bin/sh
# check_gamefiles.sh [cod1plus.so url] - build-time check of /cod1, with a message that says
# what is missing instead of a server that dies at the first map load.
set -u
ROOT="${COD1_ROOT:-/cod1}"
URL="${1:-}"
missing=""

need() { [ -f "$ROOT/$1" ] || missing="$missing $1"; }
need cod_lnxded
need main/game.mp.i386.so
for p in pak0 pak1 pak2 pak3 pak4 pak5 pak6 pak8 pak9 paka pakb; do
    need "main/$p.pk3"
done

if [ -n "$missing" ]; then
    echo "" >&2
    echo "=== gamefiles/ is incomplete - missing:$missing" >&2
    echo "=== see gamefiles/README.md: copy your Call of Duty 1.5 Linux server files there." >&2
    exit 1
fi

# the game module is looked up in the mod folder first: give PAM the same one
[ -f "$ROOT/__rPAMv115b5/game.mp.i386.so" ] || cp "$ROOT/main/game.mp.i386.so" "$ROOT/__rPAMv115b5/"

if [ ! -f "$ROOT/cod1plus.so" ]; then
    if [ -n "$URL" ] && curl -fsSL -o "$ROOT/cod1plus.so" "$URL"; then
        echo "cod1plus.so downloaded from $URL"
    else
        rm -f "$ROOT/cod1plus.so"
        echo "" >&2
        echo "=== no cod1plus.so: put it in gamefiles/ (or build with --build-arg COD1PLUS_URL=...)" >&2
        exit 1
    fi
fi

chmod +x "$ROOT/cod_lnxded"
file_list=$(cd "$ROOT" && ls main/*.pk3 __rPAMv115b5/*.pk3 2>/dev/null | wc -l)
echo "gamefiles OK: cod_lnxded, game module, cod1plus.so, $file_list pk3"
