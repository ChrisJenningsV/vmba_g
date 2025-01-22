rem build release version of keylime for android
@ECHO OFF
cls
ECHO =================
ECHO Build keylime
ECHO =================
ECHO copy key
copy android\app\keylimeKey\*.jks android\app\
ECHO copy bg
copy lib\assets\keylime\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run flutter_launcher_icons:main -f launch_icons_keylime.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor keylime





