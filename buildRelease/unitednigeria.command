#!/bin/bash
# run below to give exec permission
#  chmod +x ~/Desktop/myscript
echo build united nigeria release

echo do copy
cd StudioProjects/vmba_g
#pwd
#ls
cp  ./lib/assets/unitednigeria/images/bg.png ./lib/assets/images
cp  ./ios/runner/unitednigeria/info.plist ./ios/runner
echo done

flutter pub run  flutter_launcher_icons:main -f launch_icons_unitednigeria.yaml
exit;