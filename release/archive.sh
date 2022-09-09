#!/bin/sh
set -o nounset

archive_cleanup () {
    cd "$scriptdir" || exit
    rm -rf tmp/
}

archive () {
    local fname
    rm -rf tmp/ || return
    mkdir tmp || return
    jg archive --with-submodules --stdout HEAD | tar -xC tmp/ || return
    (
        set +o noglob
        trap archive_cleanup EXIT
        cd "$(ls -d tmp/*)" || return
        fname=$(basename -- "$PWD")
        (
            cd .. || return
            tar -zcf "../$fname.tgz" "$fname" || return
            7za a -mx9 "../$fname.7z" "$fname" || return
        ) || return
        7za a -mx9 "$name.7z" * || return
        cp "../../$name.sfx" . || return
        cmd //c "copy /b $name.sfx + $name.7z $(cygpath -w "../../$(basename $PWD).exe")" || return
    ) || return
}

main () {
    local scriptdir name
    scriptdir=$(cd "$(dirname "$0")" && PWD) || exit
    name=$(basename -- "$(cd "$(git rev-parse --show-toplevel)" && PWD)") || exit
    cd "$scriptdir" || exit
    archive "$@"
}

main "$@"
