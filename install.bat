@echo off
setlocal

set "batchname=%~nx0"
set "batchfolder=%~dp0"
if "%batchfolder:~-1%" == "\" set "batchfolder=%batchfolder:~0,-1%"
set "mv_dir=%batchfolder%\makeveb"
set "mv_bat=makeveb.bat"
set "reg=%SYSTEMROOT%\System32\reg.exe"

pushd %USERPROFILE%
set "conflict="
for /f %%i in ('where makeveb 2^>NUL') do set "conflict=%%~i"
popd

for /f "skip=2 tokens=1,2*" %%a in ('%reg% query "HKCU\Environment" /v "Path" 2^>NUL') do if /i "%%~a" == "path" set "UserPath=%%c"
if not defined UserPath (
    >&2 echo ERROR: failed to get user path.
    pause
    exit /b 1
)

if not defined conflict goto continue
if "%mv_dir%\%mv_bat%" == "%conflict%" (
    echo Makeveb has already been installed.
) else (
    echo Makeveb has already been installed in %conflict%
)
:confirm
set uninst=
set /p "uninst=Do you want to uninstall? [Y/N]: "
if /i "%uninst%" == "n" exit /b
if /i "%uninst%" == "y" goto uninstall
goto confirm

:continue
setx PATH "%mv_dir%;%UserPath%" 1>NUL || (
    pause
    exit /b 1
)

%reg% add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\makeveb.exe" /ve /d "%mv_dir%\%mv_bat%" /f 1>nul
if %ERRORLEVEL% == 0 echo Complete.
pause
exit /b

:uninstall
setlocal EnableDelayedExpansion
set newpath=
set "_path=%USERPATH%"
set "_path=%_path: =#%"
set "_path=%_path:;= %"
set "_path=%_path:(=[%"
set "_path=%_path:)=]%"
set "path_conflict=%conflict:\makeveb.bat=%"
for %%i in (%_path%) do (
    echo %%i | findstr /l "%path_conflict%" 1>nul || set "newpath=!newpath!%%i;"
)
set "newpath=%newpath:#= %"
set "newpath=%newpath:[=(%"
set "newpath=%newpath:]=)%"
setx PATH "%newpath%" 1>nul || (
    pause
    exit /b 1
)
endlocal
echo Uninstallation finished.
pause
exit /b
