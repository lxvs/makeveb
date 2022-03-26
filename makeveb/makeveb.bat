@echo off
setlocal

call:SetDefaults
call:SetMetaInfo
call:SetColors
title makeveb %version%
if "%~1" == "/?" goto Usage
call:ParseArgs %* || exit /b
call:AssignDefaults
call:ValidateDirs || exit /b
call:ValidateWorkdir || exit /b
pushd "%workdir%"
set "workdir=%cd%"
call:ConfigurationStatus
call:IfPrompt && exit /b
call:BuildStart
popd
exit /b %errCode%

:SetDefaults
if not defined DEFAULT_VEB set "DEFAULT_VEB="
if not defined DEFAULT_VEB_BUILD_MODULE set "DEFAULT_VEB_BUILD_MODULE="
if not defined DEFAULT_WORKDIR set "DEFAULT_WORKDIR=%cd%"
if not defined DEFAULT_LOG_FILE set "DEFAULT_LOG_FILE=build.log"
if not defined DEFAULT_TOOLS_DIR set "DEFAULT_TOOLS_DIR="
if not defined DEFAULT_EWDK_DIR set "DEFAULT_EWDK_DIR=C:\EWDK_1703"
if not defined DEFAULT_PAUSE_WHEN set "DEFAULT_PAUSE_WHEN=always"
exit /b
::SetDefaults

:SetMetaInfo
set "version=2.6.0"
set "lupdate=2022-03-18"
set "ghlink=https://github.com/islzh/makeveb"
set "tee=%~dp0..\tee.exe"
exit /b
::SetMetaInfo

:SetColors
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
        set "VEB=%~2"
    ) else if /i "%switch%" == "M" (
        set "VEB_BUILD_MODULE=%~2"
    ) else if /i "%switch%" == "W" (
        set "workdir=%~2"
    ) else if /i "%switch%" == "L" (
        set "log=%~2"
    ) else if /i "%switch%" == "T" (
        set "TOOLS_DIR=%~2"
    ) else if /i "%switch%" == "E" (
        set "EWDK_DIR=%~2"
    ) else if /i "%switch%" == "P" (
        set "pause_when=%~2"
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
    if "%make_target%" == "" (
        set "make_target=%param%"
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

:AssignDefaults
if not defined VEB if exist "%workdir%\%DEFAULT_VEB%" set "VEB=%DEFAULT_VEB%"
if not defined VEB_BUILD_MODULE set "VEB_BUILD_MODULE=%DEFAULT_VEB_BUILD_MODULE%"
if not defined workdir set "workdir=%DEFAULT_WORKDIR%"
if not defined log (
    if defined DEFAULT_LOG_FILE (
        set "log=%DEFAULT_LOG_FILE%"
    ) else (
        set "log=build.log"
    )
)
if not defined TOOLS_DIR set "TOOLS_DIR=%DEFAULT_TOOLS_DIR%"
if not defined EWDK_DIR set "EWDK_DIR=%DEFAULT_EWDK_DIR%"
if not defined pause_when set "pause_when=%DEFAULT_PAUSE_WHEN%"
exit /b
::AssignDefaults

:ValidateDirs
if not defined TOOLS_DIR (
    >&2 call:Printc r "makeveb: error: TOOLS_DIR is not defined."
    >&2 call:UsagePrompt
    exit /b 1
) else (
    if not exist "%TOOLS_DIR%" (
        >&2 call:Printc r "makeveb: error: defined TOOLS_DIR does not exist." "    TOOLS_DIR = %TOOLS_DIR%"
        >&2 call:UsagePrompt
        exit /b 1
    )
)
if not defined EWDK_DIR (
    >&2 call:Printc r "makeveb: error: EWDK_DIR is not defined."
    >&2 call:UsagePrompt
    exit /b 1
) else (
    if not exist "%EWDK_DIR%" (
        >&2 call:Printc r "makeveb: error: defined EWDK_DIR does not exist." "    EWDK_DIR = %EWDK_DIR%"
        >&2 call:UsagePrompt
        exit /b 1
    )
)
exit /b 0
::ValidateDirs

:ValidateWorkdir
if exist "%workdir%" exit /b 0
>&2 call:Printc r "makeveb: error: nonexistent working directory: %workdir%"
exit /b 1
::ValidateWorkdir

:IfPrompt
if "%make_target%" == "" (
    if defined TOOLS_DIR set "PATH=%TOOLS_DIR%;%TOOLS_DIR%\Bin\Win32;%PATH%"
    title makeveb %version% Command Prompt
    prompt %clrGrn%MAKEVEB$S%version%%clrSuf%$S%clrYlw%$P%clrSuf%$_$+$G$S
    cmd /k
    popd
    exit /b 0
)
exit /b 1
::IfPrompt

:BuildStart
@call:Printc y "makeveb: target: %make_target%"
title makeveb %version% - %make_target%
if /i "%log%" == "nul" (
    echo;| "%TOOLS_DIR%\make.exe" %make_target%
) else (
    echo;| "%TOOLS_DIR%\make.exe" %make_target% 2>&1 | %tee% %log%
)
set "errCode=%ErrorLevel%"
@echo;
if %errCode% EQU 0 (
    title Finished: makeveb %version% - %make_target%
    if /i "%pause_when%" == "always" (
        pause
    ) else if /i "%pause_when%" == "successful" (
        pause
    )
) else (
    title failed: makeveb %version% - %make_target%
    >&2 call:Printc r "makeveb: failed to make %make_target%"
    >&2 call:Printc r "error code: %errCode%"
    if /i "%pause_when%" == "always" (
        pause
    ) else if /i "%pause_when%" == "failed" (
        pause
    )
)
exit /b %errCode%
::BuildStart

:ConfigurationStatus
@echo;
@echo   ==========================================================================
@echo   ^| makeveb %version%
@echo   ^| Last Update: %lupdate%
@echo   ^| Johnny Appleseed ^<liuzhaohui@inspur.com^>
@echo   ^| %ghlink%
@echo   ==========================================================================
@echo   ^| Current settings:
@echo   ^|     VEB:                %VEB%
@echo   ^|     VEB_BUILD_MODULE:   %VEB_BUILD_MODULE%
@echo   ^|     workdir:            %workdir%
@echo   ^|     log:                %log%
@echo   ^|     TOOLS_DIR:          %TOOLS_DIR%
@echo   ^|     EWDK_DIR:           %EWDK_DIR%
@echo   ^|     pause_when:         %pause_when%
@echo   ==========================================================================
@echo;
exit /b
::ConfigurationStatus

:Version
@echo;
@echo     makeveb %version%
@echo     Last Update: %lupdate%
@echo     Johnny Appleseed ^<liuzhaohui@inspur.com^>
@echo     %ghlink%
exit /b
::Version

:Usage
call:Version
@echo;
@echo usage:
@echo     makeveb.bat /? ^| /help
@echo     makeveb.bat /version
@echo     makeveb.bat [^<make_target^>] [/V ^<VEB^>] [/M ^<VEB_BUILD_MODULE^>] [/W ^<workdir^>] [/L ^<log^>] [/T ^<TOOLS_DIR^>]
@echo                 [/E ^<EWDK_DIR^>] [/P ^<pause_when^>] [/color ^| /nocolor]
@echo;
@echo make_target:
@echo     Target to make. If not specified, setup build environment only.
@echo VEB:
@echo     VEB file ^(without ".veb" extention^).
@echo VEB_BUILD_MODULE:
@echo     Module to build. If not specified, build all modules.
@echo workdir:
@echo     If not specified, will be current directory.
@echo log:
@echo     Build log filename, default is build.log. If 'nul' is specified, only write in console.
@echo pause_when:
@echo     Available options: always, never, successful, failed. Default is "always".
@echo /color:
@echo     Enable colored output, this is the default.
@echo /nocolor:
@echo     Disable colored output.
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
