#!/bin/bash
# run below to give exec permission
#  chmod +x ~/Desktop/myscript
echo build blue islands release

echo do copy
cd StudioProjects/vmba_g
#pwd
#ls
cp  ./lib/assets/blueislands/images/bg.png ./lib/assets/images
cp  ./ios/runner/blueislands/info.plist ./ios/runner
echo done

flutter pub run  flutter_launcher_icons:main -f launch_icons_blueislands.yaml
exit;