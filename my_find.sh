#!/bin/bash
set +x
my_file=$1
my_pattern=$2
num=1
IFS=$'\n'
for row in $(cat $my_file); do
#	echo "line ${num}: ${row}"
	if [[ $row =~ $my_pattern ]]; then
		echo "line ${num}: ${row} match with ${my_pattern}"
	else
		echo "line ${num}: ${row}"
	fi	
	num=$((num+1))
done
