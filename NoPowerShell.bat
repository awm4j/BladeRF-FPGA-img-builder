@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------


echo.
echo Welcome to the BladeRF compilation script
echo.
pushd %~dp0

echo Extracting...
7za.exe x "master.zip" -y -o"C:\bladeRF"

del master.zip

echo Writing build_bladerf2.sh...
cd "C:\bladeRF\bladeRF-master\hdl\quartus"
echo cd C:/bladeRF/bladeRF-master/hdl/quartus/ > build_bladerf2.sh
echo ./build_bladerf.sh -r hosted -s 40 >> build_bladerf2.sh
timeout /t 3
echo.

IF NOT EXIST C:\altera\NUL GOTO NOALTERADIR

IF NOT EXIST C:\altera\14.0\NUL GOTO NOALTERA140DIR
echo Trying Altera 13.1...
"C:\altera\14.0\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA140DIR
echo Altera 14.0 doesn't exist.
echo Trying Altera 13.1...
IF NOT EXIST C:\altera\13.1\NUL GOTO NOALTERA131DIR
"C:\altera\13.1\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA131DIR
echo Altera 13.1 doesn't exist.
echo Trying Altera 13.0...
IF NOT EXIST C:\altera\13.0\NUL GOTO NOALTERA130DIR
"C:\altera\13.0\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA130DIR
echo Altera 13.0 doesn't exist.
echo Trying Altera 12.1...
IF NOT EXIST C:\altera\12.1\NUL GOTO NOALTERA121DIR
"C:\altera\12.1\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA121DIR
echo Altera 12.1 doesn't exist.
echo Trying Altera 12.0...
IF NOT EXIST C:\altera\12.0\NUL GOTO NOALTERA120DIR
"C:\altera\12.0\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA120DIR
echo Altera 12.0 doesn't exist.
echo Trying Altera 11.1...
IF NOT EXIST C:\altera\11.1\NUL GOTO NOALTERA111DIR
"C:\altera\11.1\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA111DIR
echo Altera 11.1 doesn't exist.
echo Trying Altera 11.0...
IF NOT EXIST C:\altera\11.0\NUL GOTO NOALTERA110DIR
"C:\altera\11.0\nios2eds\Nios II Command Shell.bat" < C:\bladeRF\bladeRF-master\hdl\quartus\build_bladerf2.sh
goto ALTERACOMPLETE

:NOALTERA110DIR
echo Altera 11.0 doesn't exist.
goto NOALTERADIR

:ALTERACOMPLETE
timeout /t 3
echo.
echo.
echo fin
timeout /t 3
goto exit

:NOALTERADIR
echo Altera is not installed.
timeout /t 10
goto exit

:exit
echo The bladeRF data is located in C:\bladeRF
timeout /t 60
