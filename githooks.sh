#! /usr/bin/bash

# Generate thumbnails
for entry in "media/hide/experiments/"*.png
do
  filename=$(basename "$entry")
  name=${filename%.*}
  ext=${filename##*.}
  ts=$(stat -c %Y $entry)
  target="media/"$ts""-""$name".thumbnail.png" 
  pattern="media/"*""-""$name".thumbnail.png" 
  files=(`ls $pattern`)
  if [ ${#files[@]} -gt 0 ]
  then
     echo "SKIP $files"
  else
     echo "CREATE $target"
     convert $entry -thumbnail 500x64 -unsharp 0x.5 $target
  fi
done

for entry in "media/hide/experiments/"*.gif
do
  filename=$(basename "$entry")
  name=${filename%.*}
  ext=${filename##*.}
  ts=$(stat -c %Y $entry)
  target="media/"$ts""-""$name".thumbnail.gif" 
  pattern="media/"*""-""$name".thumbnail.gif" 
  files=(`ls $pattern`)
  if [ ${#files[@]} -gt 0 ]
  then
     echo "SKIP $target"
  else
     echo "CREATE $target"
     convert $entry -coalesce temporary.gif
     convert temporary.gif -thumbnail 500x64 $target
  fi  
done

ls -r media > media/screenshots.txt
git add media/screenshots.txt
echo "CREATE SCREENSHOT LIST"

echo "# miscellaneous demos" > README.md
echo "Random ideas and tests, mostly implemented in p5js." >> README.md
for f in `ls media/*.png media/*.gif`
do
   echo "![](https://github.com/alinen/misc/blob/master/$f)" >> README.md
done
