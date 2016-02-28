#!/bin/bash

PORT=${PORT-8888}
DIRECTORY=${DIRECTORY-"/opt/data/dump"}

function stop_drain {
	echo "stopping tsd drain..."
	pgrep -f tsddrain | xargs kill -9
	exit
}
trap stop_drain HUP INT TERM EXIT SIGHUP SIGINT SIGTERM

echo "starting tsd drain..."
exec /usr/bin/python /opt/tcollector/bin/tsddrain.py ${PORT} ${DIRECTORY}
