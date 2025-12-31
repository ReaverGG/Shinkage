@echo off
:: Move to the folder where this script is located
cd /d "%~dp0"
git add . && git commit -m "Save" && git push
echo Done! Closing in 5 seconds...
timeout 5