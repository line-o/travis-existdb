#!/usr/bin/env sh
LENGTH=wc -c ${2} | awk '{print $1}'
HEAD="Content-Type:application/xquery;Content-Length:${LENGTH}"
curl -X PUT -H "${HEAD}" -d "@${2}" ${1}
