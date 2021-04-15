@REM Author:        Johnny Appleseed <liuzhaohui@inspur.com>
@REM Last Update:   2021-04-15

@setlocal
@set version=v1.0.0
@title makeveb %version%

@if "%~1" == "" (
    @set /p "recipe=Enter recipe (e.g. rebuild, build, clean): "
) else @set "recipe=%~1"

@if "%recipe%" == "" (
    @echo makeveb: error: no recipe provided
    @pause
    exit /b 1
)

@if "%~2" == "" (
    @set "logflag=1>build.log 2>&1"
) else (
    if "%~2" == "nolog" (@set "logflag=") else (
        @echo makeveb: error: unexpected argument [%~2]
        @pause
        exit /b 2
    )
)

@if not defined TOOLS_DIR @set TOOLS_DIR=C:\BuildTools_V37
@if not defined EWDK_DIR @set EWDK_DIR=C:\EWDK_1703

@pushd %~dp0

@echo makeveb: using recipe [%recipe%] to make %~dp0

@title makeveb %version% - %recipe% - %~dp0

@if "%recipe%" == "build" @set "recipe="

@(%TOOLS_DIR%\make %recipe%)%logflag%

@echo;
@if %errorlevel% EQU 0 (
    @title makeveb finished
    @echo makeveb: finished successfully
) else (
    @title rebuilding failed
    @echo makeveb: failed: %errorlevel%. See build.log
)

@pause
