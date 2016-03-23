#!/usr/bin/env bash
URL=${1}
RESULT=`curl -s ${URL}`
EXPECTED=${EXIST_DB_VERSION:6}

if [ -z "${RESULT}" ]; then
    echo "Empty result, call failed!"
    exit 1
fi

if [ "${RESULT}" = "<result>${EXPECTED}</result>" ]; then
    echo "${EXPECTED}"
    echo "expected result: ${RESULT}"
    exit 0
fi

echo "Version mismatch! Expected: <result>${EXPECTED}</result> Actual: ${RESULT}"
exit 2
