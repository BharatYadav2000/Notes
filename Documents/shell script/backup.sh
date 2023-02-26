#!/bin/bash

src_dir=/home/bharat.yadav/Desktop/fol1
tgt_dir=/home/bharat.yadav/Desktop/fol2

curr_timestamp=$(date "+%y-%m-%d-%H-%M-%S")
backup_file=$tgt_dir/$curr_timestamp.tgz

echo "Taking backup on $curr_timestamp"
echo "$backup_file"
tar czf $backup_file --absolute-names $src_dir

echo "Backup complete"
