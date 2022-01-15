#! /bin/sh
id=clc

for sz in 512 192; do
  npx jdenticon $id -f png -s $sz -o web/icons/clc-$sz.png
  optipng web/icons/clc-$sz.png
  cp web/icons/clc-$sz.png web/icons/clc-maskable-$sz.png
done
npx jdenticon $id -f png -s 16 -o web/favicon.png
optipng web/favicon.png
