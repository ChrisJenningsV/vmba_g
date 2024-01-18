rem build release version of caicos for android
@ECHO OFF
cls
ECHO =================
ECHO Build caicos
ECHO =================
ECHO copy key
copy android\app\fastjetKey\*.jks android\app\
ECHO copy bg
copy lib\assets\caicos\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run flutter_launcher_icons:main -f launch_icons_caicos.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor caicos





