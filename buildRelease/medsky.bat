rem build release version of MedSky for android
@ECHO OFF
cls
ECHO =================
ECHO Build MedSky
ECHO =================
ECHO copy key
copy android\app\MedSkyKey\*.jks android\app\
ECHO copy bg
copy lib\assets\medsky\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run  flutter_launcher_icons:main -f launch_icons_medsky.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor medsky

