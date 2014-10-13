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

function FilterMultiLine {
    echo "$content" >> multi_readme.md
    echo " " >> multi_readme.md
}

function RetrieveLastLine {
    content=`tail -n +11 README.md`
    if [ `echo "$content" | wc -l` -gt 2 ]
    then
        head -10 README.md >> README.md.temp
        tail -1 README.md >> README.md.temp
        mv README.md.temp README.md
    fi
}

git stash

for branch_name in `git branch | grep b_`
do
    git checkout $branch_name >> /dev/null
    git checkout .
    content=`tail -n +11 README.md`
    if [ `echo "$content" | wc -l` -gt 2 ]
    then
        #FilterMultiLine
        RetrieveLastLine
        git add README.md
        git commit -m'RetrieveLastLine'
    fi
done

git checkout dev_add
git stash pop
