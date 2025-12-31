@echo off
title Git Quick Save
:: Sets window size (columns, lines)
mode con: cols=60 lines=20
:: Sets color (0 = Black background, B = Aqua text)
color 0B

cd /d "%~dp0"
cls

echo ==========================================================
echo                   GIT SAVE ASSISTANT
echo ==========================================================
echo.

:: Ask for input
set /p SaveName="> Enter name for this save: "

:: Fallback if empty
if "%SaveName%"=="" set SaveName=Quick Save

echo.
echo [Status] Saving to Git...
echo ----------------------------------------------------------

:: Run commands
git add . && git commit -m "%SaveName%" && git push

echo.
echo ==========================================================
echo               DONE! Closing shortly...
echo ==========================================================
timeout /t 5 >nul