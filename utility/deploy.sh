#!/usr/bin/env sh
URL=${1}
LEN=wc -c ${2} | awk '{print $1}'
curl -X PUT -H "Content-Type:application/xquery;Content-Length:${LEN}" -d "@${2}" ${URL}
