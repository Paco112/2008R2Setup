@echo off
xcopy /E /I /Y "files\System32" "%SystemRoot%\System32">nul
"%SystemRoot%\System32\regsvr32" /s "%SystemRoot%\System32\dmusic.dll"
"%SystemRoot%\System32\regsvr32" /s "%SystemRoot%\System32\dmloader.dll"
"%SystemRoot%\System32\regsvr32" /s "%SystemRoot%\System32\dmsynth.dll"
"%SystemRoot%\System32\regsvr32" /s "%SystemRoot%\System32\dswave.dll"
xcopy /E /I /Y "files\SysWOW64" "%SystemRoot%\SysWOW64">nul
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmusic.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmband.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmcompos.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmime.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmloader.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmscript.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmstyle.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dmsynth.dll"
"%SystemRoot%\SysWOW64\regsvr32" /s "%SystemRoot%\SysWOW64\dswave.dll"
pushd %windir%\SysWOW64
rundll32 syssetup,SetupInfObjectInstallAction DefaultInstall 132 .\dmusic.inf
del dmusic.inf
if %errorlevel% NEQ 0 goto error
popd
goto end
:error
echo [-] Installation failed! Are you running the installation as Administrator?
:end