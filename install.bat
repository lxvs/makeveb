@echo off
setlocal

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"

pushd %USERPROFILE%
set "conflict="
for /f %%i in ('where makeveb 2^>NUL') do set "conflict=%%~i"

if defined conflict (
    if "%batchfolder%\%batchname%" == "%conflict%" (
        >&2 echo ERROR: this version has already installed.
    ) else (
        >&2 echo ERROR: found a name conflict with %conflict%
    )
    popd
    pause
    exit /b 1
)
popd

for /f "skip=2 tokens=1,2*" %%a in ('%SystemRoot%\System32\reg.exe query "HKCU\Environment" /v "Path" 2^>NUL') do if /i "%%~a" == "path" set "UserPath=%%c"
if not defined UserPath (
    >&2 echo Unknown error.
    pause
    exit /b 1
)

setx PATH "%batchfolder%;%UserPath%" 1>NUL || (
    pause
    exit /b 1
)

%SystemRoot%\System32\reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\makeveb.exe" /ve /d "%batchfolder%\makeveb.bat" /f 1>nul
if %errorlevel% neq 0 pause
