@echo off
:: Move to the folder where this script is located
cd /d "%~dp0"
git add . && git commit -m "quick save" && git push
echo Done! Closing in 10 seconds...
timeout 10