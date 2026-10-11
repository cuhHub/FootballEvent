@ECHO off

set use_ssswtool=%1

:: Build addon
cuhkit build

:: SSSWTool integration
if "%use_ssswtool%" == "yes" (
    cmd /C ssswtool build
    rmdir _build /s /q
    cuhkit sync
)