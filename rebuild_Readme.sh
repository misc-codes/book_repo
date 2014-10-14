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

function AppendDispName_Json {
    if [ ! -e "$1" ]
    then
        echo file "$1" not exists
        return 0
    fi

    filename=`cat "$1" | jq '.dispname'`
    if [ null = "$filename" ]
    then
        file_md5=`echo "$1" | awk 'BEGIN{FS="."} {print $1}'`
        file_size=`du "$file_md5".pdf | awk '{print $1}'`

        echo "| 0000 | "$dispname".pdf | $(GetSizeInNiceString $filesize) | $file_md5 | " >> README.md
        git add README.md
        git commit -m"Append dispname $dispname"
    fi
}




function AppendName_Json {
    if [ ! -e "$1" ]
    then
        echo file "$1" not exists
        return 0
    fi

    filename=`cat "$1" | jq '.dispname'`
    if [ null = "$filename" ]
    then
        echo "$filename"
    fi

    return 0

    num=$((`cat "$1" | jq '.rawname' | wc -l` - 2 ))
    echo $num

    if [ $num -gt 1 ]
    then
        echo "$1" `cat "$1" | jq '.rawname'` >> multi.json
    fi
}

function FilterMultiLine {
    echo "$content" >> multi_readme.md
    echo " " >> multi_readme.md
}

function RetrieveFirstLine {
    content=`tail -n +11 README.md`
    if [ `echo "$content" | wc -l` -gt 2 ]
    then
        head -11 README.md >> README.md.temp
        mv README.md.temp README.md
        git add README.md
        git commit -m'RetrieveLastLine'
    fi
}



function RetrieveLastLine {
    content=`tail -n +11 README.md`
    if [ `echo "$content" | wc -l` -gt 2 ]
    then
        head -10 README.md >> README.md.temp
        tail -1 README.md >> README.md.temp
        mv README.md.temp README.md
        git add README.md
        git commit -m'RetrieveLastLine'
    fi
}

git stash

i=1
remain=`git branch | wc -l`

for branch_name in `git branch | grep b_`
do
    echo "===== Searching Seq-$i ==== $remain remaining ====="
    git checkout $branch_name >> /dev/null
    git checkout .
    #FilterMultiLine
    # RetrieveLastLine
    # AppendName_Json *.json
    GetFileName_json *.json

    i=$((i + 1 ))
    remain=$((remain - 1 ))
done

git checkout dev_add
# git stash pop
