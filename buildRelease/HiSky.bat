rem build release version of HiSky for android
@ECHO OFF
cls
ECHO =================
ECHO Build HiSky
ECHO =================
ECHO copy key
copy android\app\hiSkyKey\*.jks android\app\
ECHO copy bg
copy lib\assets\hisky\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run  flutter_launcher_icons:main -f launch_icons_hisky.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor hisky





