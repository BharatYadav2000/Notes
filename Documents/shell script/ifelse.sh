#!/bin/bash

a=1100
b=200
c=50

if [[ $a -gt $b && $a -gt $c ]]
then
echo "A is greater"
elif [[ $b -gt $a && $b -gt $c ]]
then
echo "B is greater"
else
echo "C is greater"
fi


