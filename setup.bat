@echo off
setlocal
pushd "%~dp0setup.d" || exit /b
call info.cmd || exit /b
set silent=
set uninstall=
set _exit=
set ec=0
title %_gpss_name% setup

:parseargs
if %1. == . (goto endparseargs)
if /i "%~1" == "--silent" (
    set silent=1
    shift /1
    goto parseargs
)
if /i "%~1" == "--uninstall" (
    set uninstall=1
    shift /1
    goto parseargs
)
if "%~1" == "/?" (goto help)
if "%~1" == "-?" (goto help)
if /i "%~1" == "--help" (goto help)
>&2 echo error: invalid argument `%~1'
set ec=1
goto end
:endparseargs

if defined uninstall (goto uninstall)
if not defined silent (if exist "%_gpss_path_dir%\%_gpss_exec%" (goto installed))

:install
if exist install.pre.cmd (call install.pre.cmd)
call:installfiles || ((set ec=%errorlevel%) & (goto end))
if not defined _gpss_noreg (call register.cmd || ((set ec=%errorlevel%) & goto end))
if exist install.post.cmd (call install.post.cmd)
if exist install.takeover.cmd ((call install.takeover.cmd) & (exit /b))
if not defined silent (echo Install complete.)
goto end

:uninstall
if exist uninstall.pre.cmd (call uninstall.pre.cmd)
call:uninstallfiles || ((set ec=%errorlevel%) & (goto end))
if not defined _gpss_noreg (call unregister.cmd || ((set ec=%errorlevel%) & goto end))
if exist uninstall.post.cmd (call uninstall.post.cmd)
if exist uninstall.takeover.cmd ((call uninstall.takeover.cmd) & (exit /b))
if not defined silent (echo Uninstall complete.)
goto end

:installed
choice /c oiuq /n /m "%_gpss_name% was already installed; would you like to: (O)verwrite, (I)nstall again cleanly, (U)ninstall, or (Q)uit?"
if %ERRORLEVEL% EQU 0 ((set _exit=1) & (goto end))
if %ERRORLEVEL% EQU 1 (goto install)
if %ERRORLEVEL% EQU 2 (call "%~dpnx0" --silent --uninstall & goto install)
if %ERRORLEVEL% EQU 3 (goto uninstall)
if %ERRORLEVEL% EQU 4 ((set _exit=1) & (goto end))
goto end

:installfiles
if not exist f.manifest ((>&2 echo error: unable to find file `f.manifest') & (exit /b 1))
if not exist "%_gpss_target_dir%" (mkdir "%_gpss_target_dir%" || ((set ec=%errorlevel%) & (goto end)))
if exist d.manifest (for /f "delims=" %%a in (d.manifest) do (if not exist "%_gpss_target_dir%\%%~a" (mkdir "%_gpss_target_dir%\%%~a" || exit /b)))
for /f "delims=" %%a in (f.manifest) do (copy /b /y "..\%%~a" "%_gpss_target_dir%\%%~a" 1>nul)
exit /b 0

:uninstallfiles
if not exist f.manifest ((>&2 echo error: unable to find file `f.manifest') & (exit /b 1))
for /f "delims=" %%a in (f.manifest) do (del "%_gpss_target_dir%\%%~a" 2>nul)
if exist d.manifest (for /f "delims=" %%a in (d.manifest) do (rmdir "%_gpss_target_dir%\%%~a" 2>nul))
rmdir "%_gpss_target_dir%" 2>nul
exit /b 0

:help
echo usage: setup
echo    or: setup --silent
echo    or: setup --uninstall
goto end

:pause
if defined silent (exit /b 0)
echo Press any key to exit.
pause >nul
exit /b 0

:end
if not defined _exit (call:pause)
exit /b %ec%
