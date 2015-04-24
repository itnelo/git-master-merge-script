#!/usr/bin/env sh

if [ $# -eq 0 ]
then
    echo "argument {branch from} not exists!"
    echo "example: ${0} dev"
    exit 1
fi

if [ ! -f .mergeignore ]
then
    echo "create .mergeignore file! 1 line = 1 path to folder/file which will be ignored before git merge operation"
    exit 1
fi

output=`git merge --no-log --no-ff --no-commit ${1} -X theirs`

if [ "$output" = "Already up-to-date." ]
then
    echo "$output"
    exit 1
fi

declare -a COMMIT_MSG="Merge from '${1}' TO 'master' (dev files excluded!)"

exclude=()
while read line; do
    exclude+=("$line")
done < .mergeignore

for path in "${exclude[@]}"
do
    git checkout master ${path} &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "Prevent changes before merge in (.mergeignore): ${path}"
    else
        git reset master ${path}
        echo "Removing before merge (.mergeignore): ${path}" 
    fi
done

git clean -f -d &> /dev/null
git commit -m "${COMMIT_MSG}"
