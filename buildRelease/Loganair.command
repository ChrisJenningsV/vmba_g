#!/bin/bash
# run below to give exec permission
#  chmod +x ~/Desktop/myscript
# double click on file in finder to run
echo build LoganAir release

echo do copy
cd StudioProjects/vmba_g
#pwd
#ls
cp  ./lib/assets/loganair/images/bg.png ./lib/assets/images
cp  ./ios/runner/airswift/info.plist ./ios/runner
echo done

flutter pub run flutter_launcher_icons -f launch_icons_loganair.yaml
exit;