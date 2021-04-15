@REM Author:        Johnny Appleseed <liuzhaohui@inspur.com>
@REM Last Update:   2021-04-15

@setlocal
@set rebuild_version=v1.0.0
@title Rebuild %rebuild_version%

@if not defined TOOLS_DIR set TOOLS_DIR=C:\BuildTools_V37
@if not defined EWDK_DIR set EWDK_DIR=C:\EWDK_1703

@pushd %~dp0

@echo rebuilding %~dp0
@(%TOOLS_DIR%\make rebuild)1>build.log 2>&1

@if %errorlevel% EQU 0 (
    @title rebuilding finished
    @echo rebuilding finished
) else (
    @title rebuilding failed
    @echo rebuilding failed: %errorlevel%
    @echo see build.log
)

@pause
