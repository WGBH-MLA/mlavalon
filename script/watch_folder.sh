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

# export $(cat v.txt | xargs)
# export $(grep -v '^#' v.txt | xargs -d '\n')
# still doesnt handle JAVA_OPTIONS correctly, but thats ok, since the env vars are correctly loaded in MarsIngestItemJob
export $(grep -v '^#' v.txt | xargs -0)

# ooh ah so nice

bundle exec ruby script/watch_folder.rb
