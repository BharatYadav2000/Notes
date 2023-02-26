#!/bin/bash

echo "welocome to shell scripting"
echo $bash
name="bharat"
echo "your name is ${name}"
echo "enter your age"
read age
echo "your age is ${age}"
echo "first argument is $1 "

if [ "$1" = "yadav" ]
then
 echo "correct"
else
 echo "wrong"
fi 

