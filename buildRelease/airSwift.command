#!/bin/bash
# run below to give exec permission
#  chmod +x ~/Desktop/myscript
echo build air swift release

echo do copy
#cd StudioProjects/vmba/buildRelease
cd StudioProjects/vmba_g
#pwd
#ls
cp  ./lib/assets/airswift/images/bg.png ./lib/assets/images
echo done

flutter pub run  flutter_launcher_icons:main -f launch_icons_airswift.yaml
exit;