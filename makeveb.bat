@REM Author:        Johnny Appleseed <liuzhaohui@inspur.com>
@REM Last Update:   2021-04-19

@setlocal
@set version=v1.0.1
@title makeveb %version%

@set "recipe=%~1"
@set "logflag=%~2"

@if "%recipe%" == "" @set /p "recipe=Enter recipe (rebuild, all, clean): "

@if "%recipe%" == "" (
    @echo makeveb: error: no recipe provided
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
        @echo makeveb: error: unexpected argument [%logflag%]
        @pause
        exit /b 2
    )
)

@if not defined TOOLS_DIR @set TOOLS_DIR=C:\BuildTools_V37
@if not defined EWDK_DIR @set EWDK_DIR=C:\EWDK_1703

@pushd %~dp0

@echo makeveb: using recipe [%recipe%] to make %~dp0

@title makeveb %version% - %recipe% - %~dp0

@(%TOOLS_DIR%\make %recipe%)%logflag%

@echo;
@if %errorlevel% EQU 0 (
    @title finished: makeveb %version% - %recipe% - %~dp0
    @echo makeveb: finished successfully: [%recipe%] in %~dp0
) else (
    @title failed: makeveb %version% - %recipe% - %~dp0
    @echo makeveb: failed to make [%recipe%] in %~dp0
    @echo error: %errorlevel%
    @if not "%logflag%" == "" @echo see build.log
)

@pause
