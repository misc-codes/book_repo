#!/bin/bash

i=1
remain=`git branch | wc -l`

for branch_name in `git branch | grep b_`
do
    echo "===== pushing Seq-$i ==== $remain remaining ====="
    git push origin $branch_name
    i=$((i + 1 ))
    remain=$((remain - 1 ))
done
