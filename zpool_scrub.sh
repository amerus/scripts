#!/bin/bash
# Sergey Motorny, January 2020
# Script to schedule zfs file system scrubs. By default, scrubs execute simultaneously, which creates a significant load on large or numerous file systems.
# The script takes one parameter, which is the execution day. It lists zpools, saves them into an array, and slices the array into balanced portions. 

# Declaring the array to store zpools.
declare -a myZpools

# Populating the array with system zpools.
while read line;
do
  myZpools+=($line)
done <<< "$(/sbin/zpool list | awk -F" " '{print $1}' | grep -v NAME)"

# Length of the array is saved in totalPools variable
totalPools="${#myZpools[@]}"
# Dividing total number of zpools into five portions. The hard-coded denominator can be changed to any desired value. Smaller denominator yields bigger zpool portions to scan.
let portion=$totalPools/5 

# If input parameter is not specified, or if it is outside of boundaries of the array length, set it to the beginning of the array.
if ( [ -z $1 ] || [ $1 -ge $totalPools ] )
then
   day=0
else
   day=$1
fi

# Execute the scrubs.
/sbin/zpool scrub ${myZpools[@]:$day:$portion} &
