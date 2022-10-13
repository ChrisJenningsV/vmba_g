rem build release version of fastjet for android
@ECHO OFF
cls
ECHO =================
ECHO Build fastjet
ECHO =================
ECHO copy key
copy android\app\fastjetKey\*.jks android\app\
ECHO copy bg
copy lib\assets\fastjet\images\bg.png lib\assets\images
ECHO build store images
call flutter pub run --no-sound-null-safety flutter_launcher_icons:main -f launch_icons_fastjet.yaml
ECHO build bundle
call flutter build appbundle -t lib/main.dart --flavor fastjet





