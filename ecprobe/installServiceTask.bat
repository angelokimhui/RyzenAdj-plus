@echo off
NET FILE 1>NUL 2>NUL
if %errorlevel% NEQ 0 (
	echo Installation need be run as Administrator to install a Task
	pause
	exit /B 0
)

cd /D "%~dp0" 
choice /C YN /M "Do you want to install Service based on directory %~dp0? It can not be changed after installation."
if %ERRORLEVEL% NEQ 1 exit /B 1

for %%f in (FanControlServiceTask.xml.template FanControl.ps1 ec-probe.exe Plugins WinRing0x64.sys) do (
   if not exist %%f echo %%f is missing && goto failed
)

powershell -Command "(gc '%~dp0FanControlServiceTask.xml.template') -replace '###SCRIPTPATH###', '%~dp0FanControl.ps1' | Out-File -encoding ASCII '%~dp0FanControlServiceTask.xml'"

SCHTASKS /Create /TN "Maru\FanControl" /XML "%~dp0FanControlServiceTask.xml" /F || goto failed

SCHTASKS /run /TN "Maru\FanControl" || goto failed

timeout /t 2 > NUL

SCHTASKS /query /TN "Maru\FanControl" || goto failed

echo.
echo Installation successfull
pause
exit /B 0

:FAILED
echo Installation failed
pause
exit /B 1
