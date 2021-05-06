@REM Author:        Johnny Appleseed <liuzhaohui@inspur.com>
@REM Last Update:   2021-05-06

@setlocal
@set version=v1.0.2
@title makeveb %version%

@set "recipe=%~1"
@set "logflag=%~2"

@if "%recipe%" == "" @set /p "recipe=Enter recipe (rebuild, all, clean): "

@if "%recipe%" == "" (
    @echo MAKEVEB: ERROR: no recipe provided
    @pause
    exit /b 1
)

@if "%logflag%" == "" (
    @if "%recipe%" == "rebuild" (
        @set "logflag=1>build.log 2>&1"
    ) else if "%recipe%" == "all" (
        @set "logflag=1>build.log 2>&1"
    )
) else (
    if "%logflag%" == "nolog" (@set "logflag=") else (
        @echo MAKEVEB: ERROR: unexpected argument [%logflag%]
        @pause
        exit /b 2
    )
)

@if not defined TOOLS_DIR @set "TOOLS_DIR=C:\BuildTools_V37"
@if not defined EWDK_DIR @set "EWDK_DIR=C:\EWDK_1703"

@echo MAKEVEB: current settings:
@echo          TOOLS_DIR: %TOOLS_DIR%
@echo          EWDK_DIR:  %EWDK_DIR%

@pushd %~dp0

@echo MAKEVEB: using recipe [%recipe%] to make %~dp0

@title makeveb %version% - %recipe% - %~dp0

@(%TOOLS_DIR%\make %recipe%)%logflag%

@echo;
@if %errorlevel% EQU 0 (
    @title finished: makeveb %version% - %recipe% - %~dp0
    @echo MAKEVEB: finished successfully: [%recipe%] in %~dp0
) else (
    @title failed: makeveb %version% - %recipe% - %~dp0
    @echo MAKEVEB: failed to make [%recipe%] in %~dp0
    @echo error code: %errorlevel%
    @if not "%logflag%" == "" @echo see build.log
)

@pause
