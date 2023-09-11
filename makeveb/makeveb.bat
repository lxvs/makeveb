@echo off
setlocal

call:SetDefaults
call:SetMetaInfo
call:SetColors
title makeveb %makeveb_version%
if "%~1" == "/?" goto Usage
call:ParseArgs %* || exit /b
call:ValidateWorkdir || exit /b
pushd "%MAKEVEB_WORKSPACE%"
set "MAKEVEB_WORKSPACE=%cd%"
call:ConfigurationStatus
call:IfPrompt && exit /b
call:BuildStart
popd
exit /b %errCode%

:SetDefaults
if not defined MAKEVEB_LOG_FILENAME (set "MAKEVEB_LOG_FILENAME=nul")
if not defined MAKEVEB_PAUSE_WHEN (set "MAKEVEB_PAUSE_WHEN=always")
if not defined MAKEVEB_INTERACTIVE_SHELL (set "MAKEVEB_INTERACTIVE_SHELL=1")
exit /b
::SetDefaults

:SetMetaInfo
set "makeveb_version=2.8.0"
set "makeveb_date=2023-06-21"
set "makeveb_link=https://github.com/lxvs/makeveb"
set "makeveb_tee=%~dp0..\tee.exe"
set "makeveb_tail=%~dp0..\tail.exe"
set "makeveb_envs="
exit /b
::SetMetaInfo

:SetColors
if "%MAKEVEB_COLOR%" == "0" (exit /b)
set "clrRed=[91m"
set "clrGrn=[92m"
set "clrYlw=[93m"
set "clrSuf=[0m"
exit /b
::SetColors

:ParseArgs
if "%~1" == "" exit /b
set "param=%~1"
set "switch=%param:~1%"
if "%param:~0,1%" == "/" (
    if /i "%switch%" == "V" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "VEB=%~2"
    ) else if /i "%switch%" == "M" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "VEB_BUILD_MODULE=%~2"
    ) else if /i "%switch%" == "W" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "MAKEVEB_WORKSPACE=%~2"
    ) else if /i "%switch%" == "L" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "MAKEVEB_LOG_FILENAME=%~2"
    ) else if /i "%switch%" == "T" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "TOOLS_DIR=%~2"
    ) else if /i "%switch%" == "E" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "EWDK_DIR=%~2"
    ) else if /i "%switch%" == "P" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        set "MAKEVEB_PAUSE_WHEN=%~2"
    ) else if /i "%switch%" == "env" (
        if %2. == . (
            >&2 call:Printc r "error: switch `%switch%' requires a value"
            exit /b 1
        )
        call:SetEnv "%~2" || exit /b
    ) else if /i "%switch%" == "nocolor" (
        set "clrRed="
        set "clrGrn="
        set "clrYlw="
        set "clrSuf="
        shift
        goto ParseArgs
    ) else if /i "%switch%" == "color" (
        call:SetColors
        shift
        goto ParseArgs
    ) else if /i "%switch%" == "nointeractive" (
        set MAKEVEB_INTERACTIVE_SHELL=0
        shift
        goto ParseArgs
    ) else if /i "%switch%" == "noninteractive" (
        set MAKEVEB_INTERACTIVE_SHELL=0
        shift
        goto ParseArgs
    ) else if /i "%switch%" == "interactive" (
        set MAKEVEB_INTERACTIVE_SHELL=1
        shift
        goto ParseArgs
    ) else if /i "%switch%" == "help" (
        call:Usage
        exit /b 1
    ) else if /i "%switch%" == "version" (
        call:Version
        exit /b 1
    ) else (
        >&2 call:Printc r "makeveb: error: invalid switch: %param%"
        >&2 call:UsagePrompt
        exit /b 1
    )
    shift
    shift
    goto ParseArgs
) else (
    if "%MAKEVEB_TARGET%" == "" (
        set "MAKEVEB_TARGET=%param%"
        shift
        goto ParseArgs
    ) else (
        >&2 call:Printc r "makeveb: error: invalid argument: %param%"
        >&2 call:UsagePrompt
        exit /b 1
    )
)
exit /b
::ParseArgs

:ValidateWorkdir
if not defined MAKEVEB_WORKSPACE (set "MAKEVEB_WORKSPACE=%cd%")
if exist "%MAKEVEB_WORKSPACE%" (exit /b 0)
>&2 call:Printc r "makeveb: error: MAKEVEB_WORKSPACE does not exists: `%MAKEVEB_WORKSPACE%'"
exit /b 1
::ValidateWorkdir

:IfPrompt
if "%MAKEVEB_TARGET%" == "" (
    if defined TOOLS_DIR set "PATH=%TOOLS_DIR%;%TOOLS_DIR%\Bin\Win32;%PATH%"
    title makeveb %makeveb_version% Command Prompt
    prompt %clrGrn%MAKEVEB$S%makeveb_version%%clrSuf%$S%clrYlw%$P%clrSuf%$_$+$G$S
    cmd /k
    popd
    exit /b 0
)
exit /b 1
::IfPrompt

:BuildStart
@call:Printc y "makeveb: target: %MAKEVEB_TARGET%"
title makeveb %makeveb_version% - %MAKEVEB_TARGET%
if "%MAKEVEB_INTERACTIVE_SHELL%" == "0" (
    if /i "%MAKEVEB_LOG_FILENAME%" == "nul" (
        "%TOOLS_DIR%\make.exe" %MAKEVEB_TARGET%
    ) else (
        "%TOOLS_DIR%\make.exe" %MAKEVEB_TARGET% 2>&1 | %makeveb_tee% %MAKEVEB_LOG_FILENAME%
    )
) else (
    if /i "%MAKEVEB_LOG_FILENAME%" == "nul" (
        echo;| "%TOOLS_DIR%\make.exe" %MAKEVEB_TARGET%
    ) else (
        echo;| "%TOOLS_DIR%\make.exe" %MAKEVEB_TARGET% 2>&1 | %makeveb_tee% %MAKEVEB_LOG_FILENAME%
    )
)
set "errCode=%ErrorLevel%"
@echo;
call:GetResults "%MAKEVEB_LOG_FILENAME%"
call:ShowResults
exit /b
::BuildStart

:GetResults
if /i "%~1" == "nul" exit /b %errCode%
set errCode=1
for /f "delims=" %%i in ('%makeveb_tail% --lines=3 %MAKEVEB_LOG_FILENAME%') do (
    if /i "%%~i" == "All output modules were successfully built." (
        set errCode=0
        exit /b %errCode%
    )
)
exit /b %errCode%
::GetResults

:ShowResults
if %errCode% EQU 0 (
    title Finished: makeveb %makeveb_version% - %MAKEVEB_TARGET%
    if /i "%MAKEVEB_PAUSE_WHEN%" == "always" (
        pause
    ) else if /i "%MAKEVEB_PAUSE_WHEN%" == "successful" (
        pause
    )
) else (
    title failed: makeveb %makeveb_version% - %MAKEVEB_TARGET%
    >&2 call:Printc r "makeveb: failed to make %MAKEVEB_TARGET%"
    >&2 call:Printc r "error code: %errCode%"
    if /i "%MAKEVEB_PAUSE_WHEN%" == "always" (
        pause
    ) else if /i "%MAKEVEB_PAUSE_WHEN%" == "failed" (
        pause
    )
)
exit /b %errCode%
::ShowResults

:ConfigurationStatus
@echo;
@echo   ==========================================================================
@echo   ^| makeveb %makeveb_version% ^(%makeveb_date%^)
@echo   ^| Liu, Zhao-hui ^<liuzhaohui@ieisystem.com^>
@echo   ^| %makeveb_link%
@echo   ==========================================================================
@echo   ^| Current configurations:
@echo   ^|     VEB:                    %VEB%
if defined VEB_BUILD_MODULE (
@echo   ^|     VEB_BUILD_MODULE:       %VEB_BUILD_MODULE%
)
@echo   ^|     TOOLS_DIR:              %TOOLS_DIR%
@echo   ^|     EWDK_DIR:               %EWDK_DIR%
@echo   ^|     MAKEVEB_WORKSPACE:      %MAKEVEB_WORKSPACE%
@echo   ^|     MAKEVEB_LOG_FILENAME:   %MAKEVEB_LOG_FILENAME%
@echo   ^|     MAKEVEB_PAUSE_WHEN:     %MAKEVEB_PAUSE_WHEN%
@echo   ^|     MAKEVEB_INTERACTIVE_SHELL: %MAKEVEB_INTERACTIVE_SHELL%
@echo   ==========================================================================
if defined makeveb_envs (
@echo   ^| Additional environment variables:
:iterate_envs
for /f "tokens=1* delims=|" %%a in ("%makeveb_envs%") do (
@echo   ^|     %%~a
set "makeveb_envs=%%~b"
)
if defined makeveb_envs (goto iterate_envs)
@echo   ==========================================================================
)
@echo;
exit /b
::ConfigurationStatus

:Version
@echo;
@echo     makeveb %makeveb_version% ^(%makeveb_date%^)
@echo     Liu, Zhao-hui ^<liuzhaohui@ieisystem.com^>
@echo     %makeveb_link%
exit /b
::Version

:Usage
call:Version
@echo;
@echo usage:
@echo     makeveb.bat /? ^| /help
@echo     makeveb.bat /version
@echo     makeveb.bat [^<MAKEVEB_TARGET^>] [^<options^> ...]
@echo;
@echo MAKEVEB_TARGET:
@echo     Target to make. If not specified, setup build environment only.
@echo;
@echo Options:
@echo     /v VEB
@echo         Specify VEB file ^(without `.veb' extention^).
@echo     /m VEB_BUILD_MODULE
@echo         Specify Module to build. If not specified, build all modules.
@echo     /t TOOLS_DIR
@echo         Specify path to TOOLS_DIR.  It'll be added to Path before building.
@echo     /e EWDK_DIR
@echo         Specify path to EWDK_DIR.
@echo     /w MAKEVEB_WORKSPACE
@echo         Specify the path to the source code directory.  If not specified, will be current directory.
@echo     /l MAKEVEB_LOG_FILENAME
@echo         Build log filename, default is `build.log'. If `nul' is specified, only write in console.
@echo          Note that to get a reliable exit code you need to set MAKEVEB_LOG_FILENAME to `nul'.
@echo     /p MAKEVEB_PAUSE_WHEN
@echo         Available options are `always', `never', `successful' and `failed'. Default is `always'.
@echo     /color
@echo         Enable colored output, this is the default.  Can also be specified by setting `MAKEVEB_COLOR' to `1' ^(or any
@echo          non-zero values^).
@echo     /nocolor
@echo         Disable colored output.  Can also be specified by setting `MAKEVEB_COLOR' to `0'.
@echo     /interactive
@echo         Specify current shell is interactive.  In this case, makeveb will positively block keyboard interactions ^(such
@echo          as pauses^) in this mode.  This is the default.  Can also be specified by setting `MAKEVEB_INTERACTIVE_SHELL'
@echo          to `1' ^(or any non-zero values^).
@echo     /nointeractive
@echo         Specify current shell is non-interactive.  Can also be specified by setting `MAKEVEB_INTERACTIVE_SHELL' to `0'.
@echo     /env "<environment_variable>=<value>"
@echo         Specify environment variable.  Can be used multiple times.  No space is permitted at either side of `='.
@echo          Note that the quotation marks are required.
exit /b
::Usage

@REM Print with color
@REM $1: color {r|y|g}
@REM ...: content lines
:Printc
@setlocal
@set clr=
@set "suf=%clrSuf%"
@if "%~1" == "r" (
    set "clr=%clrRed%"
) else if "%~1" == "y" (
    set "clr=%clrYlw%"
) else if "%~1" == "g" (
    set "clr=%clrGrn%"
) else (
    set suf=
)
:printc_line
@if "%~2" == "" exit /b
@echo %clr%%~2%suf%
@shift /2
goto printc_line
::Printc

:UsagePrompt
@echo Try "makeveb /?" for help.
@exit /b
::UsagePrompt

:SetEnv
if "%~1" == "" (exit /b 0)
set "SetEnv_Statement=%~1"
for /f "delims==" %%A in ("%SetEnv_Statement%") do (
    if "%%~A" == "%SetEnv_Statement%" (
        >&2 call:Printc r "error: couldn't find `=' in `%SetEnv_Statement%'"
        >&2 call:Printc y "Did you forget the quotation marks?"
        exit /b 1
    )
)
set "makeveb_envs=%makeveb_envs%%SetEnv_Statement%|"
set "%SetEnv_Statement%"
exit /b
::SetEnv
