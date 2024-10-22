rem build release version of fastjet for android
@ECHO OFF
cls
ECHO =================
ECHO Build Air Excursions
ECHO =================
ECHO copy key
copy android\app\excursionsKey\*.jks android\app\
ECHO copy bg
copy lib\assets\excursions\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run flutter_launcher_icons:main -f launch_icons_excursions.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor excursions





