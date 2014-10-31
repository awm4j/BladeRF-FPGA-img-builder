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

goto downloadScript
:runDownloadScript

echo Downloading...
Powershell.exe -executionpolicy remotesigned -File "Get-WebFile.ps1"

del Get-WebFile.ps1

echo Extracting...

IF NOT EXIST C:\Program^ Files\7-Zip\NUL GOTO ZIP7zNotInstalled
"C:\Program Files\7-Zip\7z" x "master.zip" -y -o"C:\bladeRF"
goto extracted

:ZIP7zNotInstalled
IF NOT EXIST 7za.exe GOTO ZIP7zaEXEDNE
7za.exe x "master.zip" -y -o"C:\bladeRF"
goto extracted

:extracted
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

:downloadScript
echo Writing PowerShell Script

(
	echo Function Get-WebFile 
	echo {
	echo ^<#
	echo .SYNOPSIS
	echo Gets a file off the interwebs.
	echo. 
	echo .DESCRIPTION
	echo Gets the file at the specified URL and saves it to the hard disk. Files can be accessed over an URI including http://, Https://, file://,  ftp://, \\server\folder\file.txt etc.
	echo. 
	echo Specification of the destination filename, and/or directory that file^(s^) will be saved to is supported. 
	echo If no directory is supplied, files downloaded to current directory.
	echo If no filename is specified, files downnloaded with have filenamed based on URL, eg http://live.sysinternals.com/procexp.exe downloaded to proxecp.exe, http://google.com downloaded to google.com
	echo. 
	echo By default if a file already exists at the specified location, an exception will be generated and execution terminated.
	echo Will pass any errors encountered up to caller!
	echo. 
	echo .PARAMETER URL
	echo [Pipeline] The url of the file we want to download. URL must have format like: http://google.com, https://microsoft.com, file://c:\test.txt
	echo. 
	echo .PARAMETER Filename
	echo [Optional] Filename to save file to
	echo. 
	echo .PARAMETER Directory
	echo [Optional] Directory to save the file to
	echo. 
	echo .PARAMETER Credentials
	echo [Optional] Credentials for remote server
	echo. 
	echo .PARAMETER WebProxy
	echo [Optional] Web Proxy to be used, if none supplied, System Proxy settings will be honored
	echo. 
	echo .PARAMETER Headers
	echo [Optional] Used to specify additional headers in HTTP request
	echo. 
	echo .PARAMETER clobber
	echo [SWITCH] [Optional] Do we want to overwrite files? Default is to throw error if file already exists.
	echo. 
	echo .INPUTS
	echo Accepts strings representing URI to files we want to download from pipeline
	echo. 
	echo .OUTPUTS
	echo No output
	echo. 
	echo .EXAMPLE
	echo get-webfile "http://live.sysinternals.com/procexp.exe"
	echo. 
	echo .EXAMPLE
	echo get-webfile "http://live.sysinternals.com/procexp.exe" -filename "pants.exe"
	echo Download file at url but save as pants.exe
	echo. 
	echo .EXAMPLE
	echo gc filelist.txt ^| get-webfile -directory "c:\temp"
	echo Where filelist.txt contains a list of urls to download, files downloaded to c:\temp
	echo. 
	echo .NOTES
	echo NAME: Get-WebFile
	echo AUTHOR: kieran@thekgb.su
	echo LASTEDIT: 2012-10-14 9:15:00
	echo KEYWORDS: webclient, proxy, web, download
	echo. 
	echo .LINK
	echo http://aperturescience.su/
	echo #^>
	echo [CMDLetBinding^(^)]
	echo param
	echo ^(
	echo   [Parameter^(mandatory=$true, valuefrompipeline=$true^)][String] $URL,
	echo   [String] $Filename,
	echo   [String] $Directory,
	echo   [System.Net.ICredentials] $Credentials,
	echo   [System.Net.IWebProxy] $WebProxy,
	echo   [System.Net.WebHeaderCollection] $Headers,
	echo   [switch] $Clobber
	echo ^)
	echo. 
	echo Begin
	echo {
	echo 	#make a webclient object
	echo 	$webclient = New-Object Net.WebClient
	echo. 
	echo 	#set the pass through variables if they are not null
	echo 	if ^($Credentials^) 
	echo 	{
	echo 		$webclient.credentials = $Credentials
	echo 	}
	echo 	if ^($WebProxy^) 
	echo 	{
	echo 		$webclient.proxy = $WebProxy
	echo 	}
	echo 	if ^($Headers^) 
	echo 	{
	echo 		$webclient.headers.add^($Headers^)
	echo 	}
	echo }
	echo. 
	echo Process 
	echo {
	echo 	#destination to download file to
	echo 	$Destination = ""
	echo. 
	echo 	^<#
	echo 		This is a very complicated bit of code, but it handles all of the possibilities for the filename and directory parameters
	echo.
	echo 		1^) If both are specified -^> join the two together
	echo 		2^) If no filename or destination directory is specified -^> the destination is the current directory ^(converted from .^) joined with the "leaf" part of the url
	echo 		3^) If no filename is specified, but a directory is -^> the destination is the specified directory joined with the "leaf" part of the url
	echo 		4^) If filename is specified but a directory is not -^> The destination  is the current directory ^(converted from .^) joined with the specified filename
	echo 	#^>
	echo 	if ^(^($Filename -ne ""^) -and ^($Directory -ne ""^)^) 
	echo 	{
	echo 		$Destination = Join-Path $Directory $Filename
	echo 	} 
	echo  	elseif ^(^(^($Filename -eq $null^) -or ^($Filename -eq ""^)^) -and ^(^($Directory -eq $null^) -or ^($Directory -eq ""^)^)^) 
	echo 	{
	echo 		$Destination = Join-Path ^(Convert-Path "."^) ^(Split-Path $URL -leaf^)
	echo 	} 
	echo 	elseif ^(^(^($Filename -eq $null^) -or ^($Filename -eq ""^)^) -and ^($Directory -ne ""^)^) 
	echo 	{
	echo 		$Destination = Join-Path $Directory ^(Split-Path $URL -leaf^)
	echo 	} 
	echo 	elseif ^(^($Filename -ne ""^) -and ^(^($Directory -eq $null^) -or ^($Directory -eq ""^)^)^) 
	echo 	{
	echo 		$Destination = Join-Path ^(Convert-Path "."^) $Filename
	echo 	}
	echo.
	echo 	^<#
	echo 		If the destination already exists and if clobber parameter is not specified then throw an error as we don't want to overwrite files, 
	echo 		else generate a warning and continue
	echo 	#^>
	echo 	if ^(Test-Path $Destination^) 
	echo 	{
	echo 		if ^($Clobber^) 
	echo 		{
	echo 			Write-Warning "Overwritting file"
	echo 		} 
	echo 		else 
	echo 		{
	echo 			throw "File already exists at destination: $destination, specify -Clobber to overwrite"
	echo 		}
	echo 	}
	echo.
	echo 	#try downloading the file, throw any exceptions
	echo 	try 
	echo 	{
	echo 		Write-Verbose "Downloading $URL to $Destination"
	echo 		$webclient.DownloadFile^($URL, $Destination^)
	echo 	} 
	echo 	catch 
	echo 	{
	echo 		throw $_
	echo 	}
	echo }
	echo. 
	echo }
	echo. 
	echo get-webfile "https://github.com/Nuand/bladeRF/archive/master.zip" -Clobber
) >Get-WebFile.ps1
goto runDownloadScript

:ZIP7zaEXEDNE
echo 7za.exe doesn't exist.
timeout /t 60
goto fin

:exit
echo The bladeRF data is located in C:\bladeRF
:fin
timeout /t 60
