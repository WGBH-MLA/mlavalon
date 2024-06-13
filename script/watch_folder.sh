#!/bin/bash

# get em
# all=$(cat /proc/1/environ)
all=$(xargs -0 -L1 -a /proc/1/environ)

# loop through, bash auto splits on whitespace ooh ooh
for var in $all
do
  # export em

  piece2=${var#*=}
  piece1=${var%"$piece2"}

  # counter=0
  # pieces=$(echo $var | tr "=", "\n")
  # for piece in $pieces
  # do
  #   if ((counter == 0));
  #   then
  #     piece1=$piece
  #   else
  #     piece2=$piece
  #   fi
  #   counter=${counter}+1
  # done

  eval 'export $piece1"${piece2//-D/\\\-D}"'
  # eval 'export $piece1"$piece2"'
done

# ooh ah so nice

bundle exec ruby script/watch_folder.rb
