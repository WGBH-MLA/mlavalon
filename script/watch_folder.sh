#!/bin/bash

rm -f v.txt

# get em
# all=$(cat /proc/1/environ)
all=$(xargs -0 -L1 -a /proc/1/environ)



# loop through, bash auto splits on whitespace ooh ooh
for var in $all
do
  # # export em
  # piece2=${var#*=}
  # piece1=${var%"$piece2"}
  # eval 'export $piece1"$piece2"'

  echo $var >> v.txt
done

export $(grep -v '^#' v.txt | xargs -d '\n')

# ooh ah so nice

bundle exec ruby script/watch_folder.rb
