#!/usr/bin/env sh
URL=${1}
RESULT=`curl -s ${URL}`

if [ -z "${RESULT}" ]; then
    exit 1
fi

if [ "${RESULT}" = "<result>${EXIST_DB_VERSION}</result>" ]; then
    echo "expected result: ${RESULT}"
    exit 0
fi

echo "Version mismatch! Expected: ${EXIST_DB_VERSION} Actual: ${RESULT}"

exit 127
