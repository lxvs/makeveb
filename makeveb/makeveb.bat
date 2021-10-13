@echo off
setlocal

call:SetDefaults
call:SetMetaInfo
title makeveb %version%
if "%~1" == "/?" goto Usage
call:ParseArgs %* || exit /b
call:AssignDefaults
call:ConfigurationStatus
call:ValidateDirs
pushd "%workdir%"
call:IfPrompt && exit /b
call:BuildStart
popd
exit /b

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
set "version=v2.5.0"
set "lupdate=2021-10-13"
set "ghlink=https://github.com/islzh/makeveb"
set "tee=%~dp0..\tee.exe"
set "clrRed=[91m"
set "clrGrn=[92m"
set "clrYlw=[93m"
set "clrSuf=[0m"
exit /b
::SetMetaInfo

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
    ) else (
        >&2 call:Printc r "makeveb: ERROR: invalid switch: %param%"
        >&2 call:Usage
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
        >&2 call:Printc r "makeveb: ERROR: invalid argument: %param%"
        >&2 call:Usage
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
if not exist "%TOOLS_DIR%" (
    >&2 call:Printc r "makeveb: ERROR: defined TOOLS_DIR does not exist." ^
                      "    TOOLS_DIR = %TOOLS_DIR%"
    >&2 echo;
)
if not exist "%EWDK_DIR%" (
    >&2 call:Printc r "makeveb: ERROR: defined EWDK_DIR does not exist." ^
                      "    EWDK_DIR = %EWDK_DIR%"
    >&2 echo;
)
exit /b
::ValidateDirs

:IfPrompt
if "%make_target%" == "" (
    if defined TOOLS_DIR set "PATH=%TOOLS_DIR%;%TOOLS_DIR%\Bin\Win32;%PATH%"
    title makeveb %version% Command Prompt
    prompt %clrGrn%MAKVEB$S%version%%clrSuf%$S%clrYlw%$P%clrSuf%$_$+$G$S
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
    "%TOOLS_DIR%\make.exe" %make_target%
) else (
    "%TOOLS_DIR%\make.exe" %make_target% 2>&1 | %tee% %log%
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
exit /b
::BuildStart

:ConfigurationStatus
@echo;
@echo   ==========================================================================
@echo   ^| MAKEVEB %version%
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

:Usage
@echo;
@echo     MAKEVEB %version%
@echo     Johnny Appleseed ^<liuzhaohui@inspur.com^>
@echo     Last Update: %lupdate%
@echo     %ghlink%
@echo;
@echo USAGE:
@echo;
@echo makeveb.bat [ ^<make_target^> ]
@echo             [ /V ^<VEB^> ]
@echo             [ /M ^<VEB_BUILD_MODULE^> ]
@echo             [ /W ^<workdir^> ]
@echo             [ /L ^<log^> ]
@echo             [ /T ^<TOOLS_DIR^> ]
@echo             [ /E ^<EWDK_DIR^> ]
@echo             [ /P ^<pause_when^>]
@echo;
@echo ^<make_target^>: Target to make. If not specified, setup build environment only.
@echo;
@echo ^<VEB^>: Specify the veb file ^(without .veb extention^). Can be empty if there is only one.
@echo;
@echo ^<VEB_BUILD_MODULE^>: Specify the module to build. If not specified, build all modules.
@echo;
@echo ^<workdir^>: If not specified, will be current directory.
@echo;
@echo ^<log^>: Build log filename, default is build.log. If 'nul' is specified, only write in console.
@echo;
@echo ^<pause_when^>: Available options: always, never, successful, failed. Default is [always].
@echo;
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
