#!/usr/bin/env sh
RESULT=`curl -X DELETE ${1}`
echo ${RESULT}
