#!/usr/bin/env zsh

for f in ./flower/**/*.png; do
  name=$f:r
  echo $name
  cp $f "$name.bak"
  name1="$name-1"
  echo $name1
  convert -trim +repage $f $name1
  convert -extent 128x128 -gravity center -background none $name1 $f
done

#for f in ./flower/**/*.abcd; do
#  name=$f:r
#  newName="$name.png"
#  mv $f $newName
#done
