#!/bin/bash

add_user()
{
user=$1
pass=$2

useradd -m -p $pass $user && echo "successfully added user"
}

add_user yadav redhat@123
