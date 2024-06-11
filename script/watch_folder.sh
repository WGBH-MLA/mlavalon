#!/bin/bash

# get em
all=$(cat /proc/1/environ)
# split em
vars=$(echo $all | tr "\0" "\n")
for var in $vars
do
  # export em
  export $(echo $var)
done

# ooh ah so nice
bundle exec ruby script/watch_folder.rb
