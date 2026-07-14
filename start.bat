@echo off
setlocal
REM Lab launcher for Windows - just double-click this file.
REM Needs: Docker Desktop (installed and running) + Git for Windows.
REM Git for Windows is a free one-time install: https://git-scm.com/download/win

REM --- Find Git Bash at its usual install locations (it is often NOT on PATH) ---
set "BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH if exist "%LocalAppData%\Programs\Git\bin\bash.exe" set "BASH=%LocalAppData%\Programs\Git\bin\bash.exe"
if defined BASH goto :run

REM --- Or any other bash on PATH, except the Windows WSL stub in System32 ---
for /f "delims=" %%B in ('where bash 2^>nul') do (
  echo %%B| findstr /i /c:"System32" >nul || if not defined BASH set "BASH=%%B"
)
if defined BASH goto :run

REM --- Or WSL, but only if a Linux distro is actually installed and working ---
wsl -e true >nul 2>nul
if not errorlevel 1 goto :wsl

echo.
echo  One thing is missing: "Git for Windows" (free, one-time install).
echo  It provides the program this launcher uses to run the lab.
echo.
echo    1. Download it:  https://git-scm.com/download/win
echo    2. Run the installer - clicking "Next" through every screen is fine.
echo    3. When it finishes, double-click start.bat again.
echo.
echo  Also make sure Docker Desktop is installed and shows "running".
echo.
pause
exit /b 1

:wsl
wsl bash -c "cd \"$(wslpath -a '%~dp0.')\" && ./start.sh"
goto :end

:run
"%BASH%" "%~dp0start.sh" %*

:end
if errorlevel 1 (
  echo.
  echo  The lab exited with an error. Read the message above - the most common
  echo  fix is starting Docker Desktop and waiting until it says "running".
  echo.
  pause
)
