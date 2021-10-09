@echo off
setlocal

set "DEFAULT_VEB=Standard"
set "DEFAULT_VEB_BUILD_MODULE="
set "DEFAULT_WORKDIR=%cd%"
set "DEFAULT_LOG_FILE=build.log"
set "DEFAULT_TOOLS_DIR=%TOOLS_V37%"
set "DEFAULT_EWDK_DIR=C:\EWDK_1703"
set "DEFAULT_PAUSE_WHEN=failed"
set "tee=%~dp0..\tee.exe"

set "version=v2.4.0"
set "lupdate=2021-09-05"
title makeveb %version%

set "clrPreRed=[91m"
set "clrPreGrn=[92m"
set "clrPreYlw=[93m"

set "clrSuffix=[0m"

set "make_target=%~1"
if "%make_target:~0,1%" == "/" (
    set "make_target="
    goto paramparse
)

shift

:paramparse
if "%~1" == "" goto endparamparse
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
        >&2 echo makeveb: error: invalid switch [ %param% ]
        >&2 call:Usage
        exit /b 1
    )
    shift
    shift
    goto paramparse
) else (
    if "%make_target%" == "" (
        set "make_target=%param%"
        shift
        goto paramparse
    ) else (
        >&2 echo makeveb: error: invalid argument [%param%]
        >&2 call:Usage
        exit /b 2
    )
)
:endparamparse

if not defined DEFAULT_WORKDIR set "DEFAULT_WORKDIR=%cd%"
if not defined workdir set "workdir=%DEFAULT_WORKDIR%"

if not defined VEB set "VEB=%DEFAULT_VEB%"
if not exist "%workdir%\%VEB%.veb" (
    @echo makeveb: WARNING: couldn't find %workdir%\%VEB%.veb
    set "VEB="
)

if not defined VEB_BUILD_MODULE set "VEB_BUILD_MODULE=%DEFAULT_VEB_BUILD_MODULE%"

if not defined log (
    if defined DEFAULT_LOG_FILE (
        set "log=%DEFAULT_LOG_FILE%"
    ) else (
        set "log=build.log"
    )
)

if not defined TOOLS_DIR set "TOOLS_DIR=%DEFAULT_TOOLS_DIR%"
if not defined EWDK_DIR set "EWDK_DIR=%DEFAULT_EWDK_DIR%"

if not exist %TOOLS_DIR% (
    >&2 echo makeveb: error: defined TOOLS_DIR does not exist.
    >&2 echo     TOOLS_DIR = [ %TOOLS_DIR% ]
    exit /b 3
)
if not exist %EWDK_DIR% (
    >&2 echo makeveb: error: defined EWDK_DIR does not exist.
    >&2 echo     EWDK_DIR = [ %EWDK_DIR% ]
    exit /b 4
)
if not defined pause_when set "pause_when=%DEFAULT_PAUSE_WHEN%"

@echo;
@echo   ==========================================================================
@echo   ^| MAKEVEB %version%
@echo   ^| Johnny Appleseed ^<liuzhaohui@inspur.com^>
@echo   ^| Last Update: %lupdate%
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

pushd %workdir%

setlocal EnableDelayedExpansion
set newpath=
set "_path=%PATH%"
set "_path=%_path: =#%"
set "_path=%_path:;= %"
set "_path=%_path:(=[%"
set "_path=%_path:)=]%"
for %%i in (%_path%) do (
    echo %%i | findstr /i /l "\git\" > nul || set "newpath=!newpath!;%%i"
)
set "newpath=%newpath:#= %"
set "newpath=%newpath:[=(%"
set "newpath=%newpath:]=)%"
set "PATH=%newpath:~1%"
endlocal

if "%make_target%" == "" (
    if defined TOOLS_DIR set "PATH=%TOOLS_DIR%;%TOOLS_DIR%\Bin\Win32;%PATH%"
    title makeveb %version% Command Prompt
    prompt %clrPreGrn%MAKVEB$S%version%%clrSuffix%$S%clrPreYlw%$P%clrSuffix%$_$+$G$S
    cmd /k
    popd
    exit /b
)

@echo MAKEVEB: making [%make_target%]

title makeveb %version% - %make_target%

%TOOLS_DIR%\make %make_target% 2>&1 | %tee% %log%

@echo;
if %errorlevel% EQU 0 (
    title finished: makeveb %version% - %make_target%
    @echo MAKEVEB: finished successfully: [%make_target%]
    if /i "%pause_when%" == "always" (
        pause
    ) else if /i "%pause_when%" == "successful" (
        pause
    )
) else (
    title failed: makeveb %version% - %make_target%
    >&2 echo MAKEVEB: failed to make [%make_target%]
    >&2 echo error code: %errorlevel%
    if /i "%pause_when%" == "always" (
        pause
    ) else if /i "%pause_when%" == "failed" (
        pause
    )
)

popd
exit /b

:Usage
@echo;
@echo     MAKEVEB %version%
@echo     Johnny Appleseed ^<liuzhaohui@inspur.com^>
@echo     Last Update: %lupdate%
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
@echo ^<make_target^>:  Target to make. If not specified, will enter command prompt.
@echo ^<VEB^>: Specify the veb file. Can be empty if there is only one.
@echo ^<VEB_BUILD_MODULE^>: Specify the moudule^(s^) to build. If left empty, build all
@echo                     modules.
@echo ^<workdir^>: If not specified, will be current directory.
@echo ^<log^>: Build log filename, default is build.log
@echo ^<pause_when^>:  Available options: always, never, successful, failed.
@echo                Default is [always].
@echo;
@echo EXAMPLES:
@echo;
@echo makeveb rebuild /V Standard /W C:\exampleproj /L buildlog.txt
@echo         /T C:\BuildTools_37 /E C:\EWDK_1703 /P failed
@echo;
@echo makeveb sdl
