# =========================================================
# Navigation
# =========================================================

lf() { # zsh follow lf navigation
    tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# =========================================================
# C++
# =========================================================

cr() { # compile & run C++ with the learncpp flags: cr file.cpp | cr folder/
    local src=${1%/} root out rel
    root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    rel=${${src:a}#$root/}
    out="$root/build/${rel:h}/${${rel:t}%.cpp}"
    local -a files
    if [[ -d $src ]]; then files=($src/*.cpp(N)); else files=($src); fi
    (( $#files )) || { echo "cr: no .cpp files in $src"; return 1; }
    local -a cmd=(g++ -std=c++23 -g -pedantic-errors -Wall -Wextra
                  -Wconversion -Wsign-conversion -Werror -o "$out" $files)
    mkdir -p "${out:h}"
    print -r -- "${(j: :)cmd}"
    "${cmd[@]}" && "$out"
}
