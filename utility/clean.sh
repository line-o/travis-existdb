#!/usr/bin/env bash
RESULT=`curl -X DELETE ${1}`
echo ${RESULT}
