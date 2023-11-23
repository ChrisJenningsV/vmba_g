#!/bin/bash
# run below to give exec permission
#  chmod +x ~/Desktop/myscript
echo build buraq release

echo do copy
cd StudioProjects/vmba_g
#pwd
#ls
cp  ./lib/assets/buraq/images/bg.png ./lib/assets/images
cp  ./ios/runner/buraq/info.plist ./ios/runner
echo done

flutter pub run  flutter_launcher_icons:main -f launch_icons_buraq.yaml
exit;