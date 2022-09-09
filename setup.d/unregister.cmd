@if not defined _gpss_name (exit /b)
if defined _gpss_noreg (exit /b)
call getreg.cmd "HKCU\Environment" "Path" UserPath
setlocal EnableDelayedExpansion
if defined UserPath (
    if not defined silent (
        if defined _gpss_path_dir (
            setx Path "!UserPath:%_gpss_path_dir%;=!" 1>nul
        ) else (
            >&2 echo warning: no installation found; try to uninstall anyway
        )
        reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%_gpss_name%.exe" /f 1>nul
    ) else (
        if defined _gpss_path_dir (setx Path "!UserPath:%_gpss_path_dir%;=!" 1>nul 2>&1)
        reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%_gpss_name%.exe" /f 1>nul 2>&1
    )
) else (
    if not defined silent (
        >&2 echo error: failed to get user Path
    )
    exit /b 1
)
exit /b 0
