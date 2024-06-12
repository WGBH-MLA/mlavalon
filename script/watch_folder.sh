#!/bin/bash

# get em
all=$(cat /proc/1/environ)
# split em
vars=$(echo $all | tr "\0" "\n")
for var in $vars
do
  # export em
  piece1 =  $(echo $var | tr "=", "\n")[0]
  piece2 =  $(echo $var | tr "=", "\n")[1]
  export `${piece1}=${piece2}`
done

# ooh ah so nice
bundle exec ruby script/watch_folder.rb
