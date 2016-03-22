#!/usr/bin/env sh
echo ${1}
RESULT=`curl -X DELETE ${1}`
echo ${RESULT}
