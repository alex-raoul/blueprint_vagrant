#!/bin/sh

BEFORE_NAME=$1
AFTER_NAME=$2
DIFF_NAME=$3

mkdir ${DIFF_NAME}
cd ${DIFF_NAME}

for resource in cron group host package user
do
  cat ../${BEFORE_NAME}/${resource} | tr '\n' ' ' | sed 's/} /}\n/g' > ${BEFORE_NAME}_${resource}
  sort -n ${BEFORE_NAME}_${resource} > ${BEFORE_NAME}_${resource}_sorted

  cat ../${AFTER_NAME}/${resource} | tr '\n' ' ' | sed 's/} /}\n/g' > ${AFTER_NAME}_${resource}
  sort -n ${AFTER_NAME}_${resource} > ${AFTER_NAME}_${resource}_sorted

  comm -3 ${BEFORE_NAME}_${resource}_sorted ${AFTER_NAME}_${resource}_sorted > ${resource}_diff
done
# blueprint diff ${BEFORE_NAME} ${AFTER_NAME} ${DIFF_NAME}
blueprint create ${DIFF_NAME} -d ${BEFORE_NAME} # we do the diff during the creation : blueprint diff command seems buggy
blueprint-show-files ${DIFF_NAME} | while read file ; do puppet resource file $file 2>/dev/null ; done | grep -v type | grep -v ctime | grep -v mtime > file_diff

for resource in cron group host package user file
do
	cat ${resource}_diff >> diff.pp
done

echo "You can do : puppet apply $(pwd)/diff.pp --noop"