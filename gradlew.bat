@echo off
set GRADLE_VERSION=8.14.3
set GRADLE_DIR=%USERPROFILE%\.gradle\nauzer-wrapper\gradle-%GRADLE_VERSION%
set GRADLE_BIN=%GRADLE_DIR%\bin\gradle.bat
if exist "%GRADLE_BIN%" goto run
powershell -NoProfile -ExecutionPolicy Bypass -Command "New-Item -ItemType Directory -Force -Path '%USERPROFILE%\.gradle\nauzer-wrapper' | Out-Null; Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip' -OutFile '%GRADLE_DIR%.zip'; Expand-Archive -Force '%GRADLE_DIR%.zip' '%USERPROFILE%\.gradle\nauzer-wrapper'; Rename-Item '%USERPROFILE%\.gradle\nauzer-wrapper\gradle-%GRADLE_VERSION%' 'gradle-%GRADLE_VERSION%' -Force; Remove-Item '%GRADLE_DIR%.zip' -Force"
:run
"%GRADLE_BIN%" %*
