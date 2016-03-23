#!/usr/bin/env bash

cd ${EXIST_DB_FOLDER}
nohup bin/startup.sh &
sleep 30
curl http://127.0.0.1:8080/exist
