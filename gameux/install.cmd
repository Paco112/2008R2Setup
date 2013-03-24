@echo off
xcopy /Y "x64\gameux.dll" "%SystemRoot%\System32">nul
if %errorlevel% NEQ 0 goto error
"%SystemRoot%\System32\regsvr32" /s "%SystemRoot%\System32\gameux.dll"
if %errorlevel% NEQ 0 goto error
xcopy /Y "x86\gameux.dll" "%SystemRoot%\SysWOW64">nul
if %errorlevel% NEQ 0 goto error
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\gameux.dll"
if %errorlevel% NEQ 0 goto error
goto end
:error
echo [-] Installation failed! Are you running the installation as Administrator?
:end