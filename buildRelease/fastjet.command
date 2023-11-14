#!/bin/bash
# run below to give exec permission
#  chmod +x ~/Desktop/myscript
echo build fastjet release

echo do copy
cd StudioProjects/vmba_g
#pwd
#ls
cp  ./lib/assets/fastjet/images/bg.png ./lib/assets/images
cp  ./ios/runner/fastjet/info.plist ./ios/runner
echo done

flutter pub run  flutter_launcher_icons:main -f launch_icons_fastjet.yaml
exit;