#!/bin/bash

## adapted this from michaelt's answer here: 
#    http://stackoverflow.com/questions/356100/how-to-wait-in-bash-for-several-subprocesses-to-finish-and-return-exit-code-0
#   It's ain't the most perfect answer, but makes a good poor-man's parallel bash

set -o monitor

echo "Starting errorfile on $(date) " > errorfile

i=1
while [ "$i" -le "32" ] ; do 
	if [ ! -d ${i} ] ; then 
		echo "cannot find run directory >>>${i}<<<" > errorfile
	fi
	(cd ${i} && bash Run.bash) &
	##(cd ${i} && echo ${i} && sleep 20) &
	##(echo ${i} && sleep 20) &
i=$((i+1))
done

pids=`jobs -p`

checkpids() {
    for pid in $pids; do
        if kill -0 $pid 2>/dev/null; then
            continue # or # echo $pid is still alive.
        elif wait $pid; then
            continue # or # echo $pid exited with zero exit status.
        else
            echo $pid exited with non-zero exit status. > outputfile
        fi
    done
    sleep 10
    echo
}

trap checkpids CHLD

wait
