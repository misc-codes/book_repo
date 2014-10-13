#!/bin/bash

set -e

function GetFileName_json {
    if [ ! -e "$1" ]
    then
        return 0
    fi

    filename=`cat "$1" | jq '.dispname'`
    if [ null = $filename ]
    then
        filename=`cat "$1" | jq '.rawname[0]'`
        if [ null != "`cat "$1" | jq '.rawname[1]'`" ]
        then
            echo "$1" `cat "$1" | jq '.rawname'` >> multi.json
        fi
    fi

    echo $filename
}

function GetFileName_Readme {
    if [ ! -e "$1" ]
    then
        return 0
    fi

    echo $filename
}

for branch_name in `git branch | grep b_`
do
    git checkout $branch_name >> /dev/null
    git checkout .
    content=`tail -n +11 README.md`
    if [ `echo "$content" | wc -l` -gt 2 ]
    then
        echo "$content" >> multi_readme.md
        echo " " >> multi_readme.md
    fi
done

git checkout master
