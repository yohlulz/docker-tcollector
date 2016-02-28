#!/bin/bash

function stop_tcollector {
	echo "stopping tcollector..."
	pgrep -f tcollector | xargs kill -9
	exit
}
trap stop_tcollector HUP INT TERM EXIT SIGHUP SIGINT SIGTERM

echo "starting tcollector..."
/opt/tcollector/startstop start &

sleep 60
while pgrep tcollector.py > /dev/null; do sleep 5; done
