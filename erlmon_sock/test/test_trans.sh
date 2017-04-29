#!/bin/bash

NUM_INSTANCES=$1
echo "numinst $NUM_INSTANCES" 
for (( c=1; c<=$NUM_INSTANCES; c++ ))
do
   java -Xbootclasspath/p:jpos-2.0.7-SNAPSHOT.jar Test_java_client_post &
done 

