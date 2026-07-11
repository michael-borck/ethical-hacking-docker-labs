@echo off
where bash >nul 2>nul || (echo Install Git for Windows, or use WSL, then run: bash start.sh & pause & exit /b 1)
bash "%~dp0start.sh" %*
