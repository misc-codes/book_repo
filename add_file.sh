#!/bin/bash

set -e

CFG_MAX_SIZE_PER_FILE=49000 # KB. 1M = 1000KB. less than 50MB safely

# tested by: 0 1 500 1023 1024 2800 $((2000 * 2000))
function GetSizeInNiceString { # param in: sizeInBytes
    if [ $1 -gt $((1000 * 1000)) ]
    then
        printf "%.1f GB" $(awk "BEGIN{print $1/1024.0/1024.0}")
    elif [ $1 -gt 1000 ]
    then
        printf "%.1f MB" `awk "BEGIN{print $1/1024.0}"`
    else
        printf "%.0f KB" $1
    fi
}

# tested by: "hello world.pdf", "hello world.v1.pdf", "hello world.v1.1.pdf"
function GetFileExt {  # param in: file_name
    echo "$1" | awk 'BEGIN{FS="."} {print $NF}'
}

function AppendReadme {  # md5, file_name, filesize
    # | sequence | md5 | file_name  | Size |
    echo "| $((`git branch | wc -l` - 1)) | $2 | $(GetSizeInNiceString $3) | $1 | " >> README.md
    git add README.md
}

function add_one_file {
    # file / path check
    if [ ! -f "$1" ]  # normal file
    then
        echo "$1" not exist
        return 1
    fi

    file_name=$1
    file_md5=`md5sum -b "$file_name" | awk '{print $1}'`
    repo_file_name=$file_md5\.`GetFileExt "$file_name"`
    file_size=`du "$file_name" | awk '{print $1}'`

    branch_name=b_$file_md5

    # Append BookInfo in Readme only if file exists
    if [ 1 -eq `git branch | grep $branch_name | wc -l` ]
    then
        git checkout $branch_name
        AppendReadme $file_md5 "$file_name" $file_size
        git commit -m"Append file info $file_name: $file_md5"
        git checkout  master # master
        return 0
    fi

    git checkout -b $branch_name start_point

    # file to add
    if [ ! -e $repo_file_name ]
    then
        cp "$file_name" $repo_file_name
    fi

    # split and add
    if [ $file_size -gt $CFG_MAX_SIZE_PER_FILE ]
    then
        # split if bigger than MAX_SIZE_PER_FILE limit
        split_prefix="$repo_file_name"_part_
        rm -f "$split_prefix"*
        split -b "$CFG_MAX_SIZE_PER_FILE"KB "$file_name" "$split_prefix"
        git add "$split_prefix"??
    else
        git add "$repo_file_name"
    fi

    # Append info to README.md and commit
    AppendReadme $file_md5 "$file_name" $file_size
    git commit -m"add book $file_name: $file_md5"
    git checkout  master # master
    AppendReadme $file_md5 "$file_name" $file_size
    git commit -m"add Info of book $file_name: $file_md5"

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
    add_one_file "$i"
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
