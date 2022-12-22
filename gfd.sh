#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

show_usage() {
    echo 'Usage: ./gfd.sh repo

Use git fetch to clone repo, since fetch support resume.
'
}

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    show_usage
    exit 0
fi

get_proj_dir() {
    local repo="$1"
    IFS='/' read -ra splited <<< "$repo"
    local proj="${splited[4]}"
    IFS='.' read -ra proj_arr <<< "$proj"
    local dir="${proj_arr[0]}"
    echo "$dir"
}

get_branch() {
    IFS="'" read -ra splited < .git/FETCH_HEAD
    echo "${splited[1]}"
}

fetch_repo() {
    local repo="$1"
    local dir
    dir=$(get_proj_dir "$repo")
    echo "project directory: $dir"

    set -x
    mkdir -p "$dir" && cd "$dir" || exit 2
    [ ! -d .git ] && git init .
    [ -z "$(git remote)" ] && git remote add origin "$repo"
    git fetch --depth 1 origin
    set +x

    local branch
    branch=$(get_branch)
    echo "checkout branch: $branch"
    git checkout "$branch"
}

main() {
    local repo=${1:-}
    if [ -z "$repo" ]
    then
        show_usage
        exit 1
    else
        echo "fetching..."
        fetch_repo "$repo"
    fi
}

main "$@"
