@echo off
REM Overlay Projector - launch local server and open the app.
REM A server is required because browsers block fetch() of wall.glb over file://

cd /d "%~dp0"

set "PORT=8000"
set "URL=http://localhost:%PORT%/index.html"

REM Pick a Python launcher (py preferred on Windows, then python).
where py >nul 2>nul && (set "PY=py") || (set "PY=python")

echo Starting Overlay Projector on %URL%
echo Press Ctrl+C in this window to stop the server.
echo.

REM Open the browser shortly after the server comes up.
start "" /b cmd /c "timeout /t 1 >nul & start "" "%URL%""

REM Run the static server (this blocks until you Ctrl+C).
%PY% -m http.server %PORT%

REM If Python isn't installed, the line above fails — tell the user.
if errorlevel 1 (
  echo.
  echo Could not start the server. Python was not found.
  echo Install Python from https://www.python.org/downloads/ ^(check "Add to PATH"^),
  echo or run any static server in this folder on port %PORT%.
  pause
)
