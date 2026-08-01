@echo off
setlocal EnableDelayedExpansion
REM ===========================================================================
REM Lab launcher for Windows - double-click this file, or run it from a prompt.
REM
REM Needs: Docker Desktop (installed and running) plus a Linux-style shell.
REM The shell can be EITHER Git for Windows (easiest) OR a real WSL Linux
REM distribution. This script finds whichever you have.
REM
REM Note on WSL: Docker Desktop installs its own "docker-desktop" WSL entry.
REM That is NOT a Linux distribution you can run a shell in - it is a minimal
REM appliance with no bash. Testing "does WSL work?" is therefore not enough;
REM we have to test "is there a WSL distribution that actually has bash?",
REM which is what the check below does.
REM ===========================================================================

set "BASH="
set "WSLARGS="

REM --- 1. Git Bash at its usual install locations (often NOT on PATH) --------
call :try_bash "%ProgramFiles%\Git\bin\bash.exe"
call :try_bash "%ProgramW6432%\Git\bin\bash.exe"
call :try_bash "%ProgramFiles(x86)%\Git\bin\bash.exe"
call :try_bash "%LocalAppData%\Programs\Git\bin\bash.exe"
call :try_bash "%UserProfile%\scoop\apps\git\current\bin\bash.exe"
call :try_bash "%ProgramData%\chocolatey\lib\git\tools\bin\bash.exe"
if defined BASH goto :run_gitbash

REM --- 2. Any other real bash on PATH (skip the WSL stub in System32) --------
for /f "delims=" %%B in ('where bash 2^>nul') do (
  if not defined BASH (
    echo %%B | findstr /i /c:"System32" >nul || set "BASH=%%B"
  )
)
if defined BASH goto :run_gitbash

REM --- 3. WSL, but only a distribution that genuinely has bash --------------
REM Test the default distribution first - one call, no output parsing.
wsl -e bash -c "exit 0" >nul 2>nul
if not errorlevel 1 goto :run_wsl

REM Default has no bash (likely docker-desktop). Look for another distribution.
REM WSL_UTF8 stops `wsl -l -q` emitting UTF-16, which cmd renders as garbage.
set "WSL_UTF8=1"
for /f "usebackq delims=" %%D in (`wsl -l -q 2^>nul`) do (
  if not defined WSLARGS if not "%%D"=="" (
    echo %%D | findstr /i /c:"docker-desktop" >nul || (
      wsl -d %%D -e bash -c "exit 0" >nul 2>nul
      if not errorlevel 1 set "WSLARGS=-d %%D"
    )
  )
)
if defined WSLARGS goto :run_wsl
goto :no_shell

REM ==========================================================================
:try_bash
if defined BASH exit /b 0
if exist "%~1" set "BASH=%~1"
exit /b 0

REM ==========================================================================
:run_gitbash
"%BASH%" "%~dp0start.sh" %*
goto :end

REM ==========================================================================
:run_wsl
REM Change to the lab folder FIRST, so WSL inherits and translates it (C:\... ->
REM /mnt/c/...) on its own. That avoids quoting a Windows path through cmd into
REM bash, which breaks on spaces and apostrophes.
pushd "%~dp0"
REM Confirm the folder is actually reachable from inside WSL. If the labs sit on
REM a network share or a drive WSL can't mount, it silently starts in the Linux
REM home directory instead and nothing here would be found.
wsl %WSLARGS% -e test -f ./start.sh >nul 2>nul
if errorlevel 1 goto :not_visible
wsl %WSLARGS% -e bash ./start.sh %*
goto :end

REM ==========================================================================
:not_visible
echo.
echo  Found a WSL Linux distribution, but it cannot see this folder:
echo    %~dp0
echo.
echo  This usually means the labs are on a network drive or a disk WSL does
echo  not mount. Copy the lab folder to your C: drive - somewhere like
echo  C:\Users\%USERNAME%\Documents - and run start.bat from there.
echo.
pause
exit /b 1

REM ==========================================================================
:no_shell
echo.
echo  Almost there. This launcher needs a Linux-style shell, and neither
echo  option is installed yet. Pick either one - A is quicker.
echo.
echo  ---------------------------------------------------------------------
echo   A.  Install Git for Windows   (free, about two minutes)
echo  ---------------------------------------------------------------------
echo       1. Download:  https://git-scm.com/download/win
echo       2. Run the installer - clicking "Next" through every screen is fine.
echo       3. Double-click start.bat again.
echo.
echo  ---------------------------------------------------------------------
echo   B.  Install a WSL Linux distribution   (if you prefer WSL)
echo  ---------------------------------------------------------------------
echo       1. In PowerShell:   wsl --install -d Ubuntu
echo       2. Restart when asked, and let Ubuntu finish first-time setup.
echo       3. In Docker Desktop: Settings ^> Resources ^> WSL Integration,
echo          switch it on for Ubuntu.
echo       4. Double-click start.bat again.
echo.
echo  If you already use WSL and expected this to work: the "docker-desktop"
echo  entry that Docker Desktop creates is not a usable Linux distribution -
echo  it has no shell. You need a real one, such as Ubuntu.
echo.
echo  Docker Desktop must also be installed and showing "running".
echo.
pause
exit /b 1

REM ==========================================================================
:end
popd >nul 2>nul
if errorlevel 1 (
  echo.
  echo  The lab exited with an error. Read the message above - the most common
  echo  fix is starting Docker Desktop and waiting until it says "running".
  echo.
  echo  If you launched via WSL and Docker was not found, enable it in
  echo  Docker Desktop: Settings ^> Resources ^> WSL Integration.
  echo.
  pause
)
