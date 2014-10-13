#!/bin/bash

set -e

function add_info {
    # file / path check
    if [ ! -f "$1" ]  # normal file
    then
        echo "$1" not exist
        return 1
    fi

    file_name=$1
    repo_file_name=$(basename "$file_name")
    file_md5=`echo "$repo_file_name" | awk 'BEGIN{FS="."} {print $1}'`

    branch_name=b_$file_md5

    # Append BookInfo in Readme only if file exists
    if [ 0 -eq `git branch | grep $branch_name | wc -l` ]
    then
        return 0
    fi

    git checkout $branch_name

    # file to add
    if [ -e $repo_file_name ]
    then
        return 0
    fi

    cp "$file_name" $repo_file_name
    git add "$repo_file_name"
    git commit -m"add Info File $repo_file_name"

    rm "$file_name"

    return 0
}

# ========= process Start ===========

# param check
if [ $# -lt 1 ];
then
    echo no input file
    exit 1
fi

# workshop backup
cd "$(dirname "$0")"
git stash >> /dev/null
working_branch=`git branch | grep "*" | awk '{print $2}'`

for i in "$@"
do
    add_info "$i"
done

# workshop recovery
if [ "$working_branch" != `git branch | grep "*" | awk '{print $2}'` ]
then
    git checkout "$working_branch" >> /dev/null
fi
git stash pop

# git push origin $branch_name:$branch_name

# NOTICE:
# wrape $1 / $file_name in "" to adopt file_names containing space
