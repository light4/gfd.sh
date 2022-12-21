#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./gfd.sh repo

Use git fetch to clone repo, since fetch support resume.

'
    exit
fi

cd "$(dirname "$0")"

get_proj_dir() {
    local repo="$1"
    IFS='/' read -ra splited <<< "$repo"
    local proj="${splited[4]}"
    IFS='.' read -ra proj_arr <<< "$proj"
    local dir="${proj_arr[0]}"
    echo "$dir"
}

checkout_branch() {
    IFS="'" read -ra splited < .git/FETCH_HEAD
    echo "${splited[1]}"
}

fetch_repo() {
    local dir
    dir=$(get_proj_dir "$@")
    echo "Project directory: $dir"

    set -x
    mkdir "$dir" && cd "$dir" || exit 1
    git init .
    git remote add origin "$1"
    git fetch --depth 1 origin
    set +x

    local branch
    branch=$(get_branch)
    echo "checkout branch: $branch"
    git checkout "$branch"
}

main() {
    fetch_repo "$@"
}

main "$@"
