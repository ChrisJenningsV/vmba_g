rem build release version of LibyanWings for android
@ECHO OFF
cls
ECHO =================
ECHO Build Libyan Wings
ECHO =================
ECHO copy key
copy android\app\LibyanWingsKey\*.jks android\app\
ECHO copy bg
copy lib\assets\LibyanWings\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run flutter_launcher_icons:main -f launch_icons_LibyanWings.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor LibyanWings





