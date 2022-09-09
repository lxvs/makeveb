@if %1. == . (exit /b 0)
set "getreg_path=%~1"
set getreg_key="%~2"
set %3=
set "getreg_name=%~2"
set getregretval=
if /i "%getreg_key%" == "/ve" (
    set getreg_switch=/ve
    set getreg_key=
    set "getreg_name=(Default)"
) else (
    set getreg_switch=/v
)
for /f "skip=2 tokens=1* delims=" %%a in ('reg query "%getreg_path%" %getreg_switch% %getreg_key% 2^>nul') do (
    call:getregparse "%%~a"
)
if defined getregretval (set "%3=%getregretval%")
exit /b

:getregparse
if "%~1" == "" (exit /b 1)
set "getregparse_str=%~1"
set "getregparse_str=%getregparse_str:    =	%
for /f "tokens=1,2* delims=	" %%A in ("%getregparse_str%") do (
    if /i "%getreg_name%" == "%%~A" (set "getregretval=%%~C")
)
exit /b
