@pushd %~dp0
@del /f %SYSTEMROOT%\makeveb.bat
@mklink %SYSTEMROOT%\makeveb.bat %cd%\makeveb.bat
@if %errorlevel% neq 0 pause
