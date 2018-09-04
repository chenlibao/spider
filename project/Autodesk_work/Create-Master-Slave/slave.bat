REM script for vault pro
set Vault_V=24.0.0.402_Cont
set Release=R24
set ProductVersion=2019
set Install_path=\\lion\BRE_MASTERS_PSEB\DM


set PROD_VER=%ProductVersion%
set INV_FOLDER=Inventor %PROD_VER%
set ACAD_FOLDER=AutoCAD %PROD_VER%
set VC_FOLDER=Vault Professional %PROD_VER%
set ADMS_FOLDER=ADMS Professional %PROD_VER%
set SERVER_SRC=VP_Server
set CLIENT_SRC=VP
set CLIENT_EXE=Connectivity.VaultPro.exe
set RELEASE=%Release%
set BUILD=%Vault_V%

IF EXIST "C:\Program Files\Autodesk\%ADMS_FOLDER%" (
   goto end
)

ROBOCOPY \\10.49.83.229\Shared\JenkinsInstallerKit C:\ InstallUtil.exe 
set INSTUTIL=%2
if [%INSTUTIL%]==[] set INSTUTIL=c:\installutil.exe

REM get install server
set INST_SERVER=%Install_path%

echo install server = %INST_SERVER%

C:

:RetryQ
net use I: /DELETE
rem ping 10.143.57.247

set UNAME=ads\shqa_auto_vmware
set PASS=Changeme4

net use "%INST_SERVER%" "%PASS%" /USER:%UNAME%

set VC_FOLDER=Vault Professional %PROD_VER%
set ADMS_FOLDER=ADMS Professional %PROD_VER%

net use I: "%INST_SERVER%\%RELEASE%\px86" /PERSISTENT:NO

echo net use i: "%INST_SERVER%\%RELEASE%\px86" /PERSISTENT:NO

echo %ERRORLEVEL%
if %ERRORLEVEL% NEQ 0 goto:RetryQ

rem clean temp folder

%INSTUTIL% /kill AdAppMgr

rem install SQL2012
"I:\%BUILD%\%SERVER_SRC%\3rdParty\Sql2012Express\x64\Setup.exe" /q /ACTION=Install /FEATURES=SQL /IAcceptSQLServerLicenseTerms=True /INSTANCENAME=AutodeskVault /SQLSVCACCOUNT="NT AUTHORITY\Network Service" /SECURITYMODE=SQL /SQLSYSADMINACCOUNTS="NT AUTHORITY\Network Service" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /ERRORREPORTING=0 /HIDECONSOLE /SAPWD="AutodeskVault@26200"


ping 123.45.67.89 -n 1 -w 60000 > nul

REM ==x64 install==================================
:x64Inst
set LOCATION= C:\Program Files

REM Install Server --
title Installing ADMS server...
"I:\%BUILD%\%SERVER_SRC%\Setup.exe" /t /qb /c SERVER:INSTALLDIR="%LOCATION%\Autodesk\%ADMS_FOLDER%\"

REM Running InstallUtil.exe in guest and pass the file to be checked to see if the product is really installed
REM and reset license path as the third argument
%INSTUTIL% /file "%LOCATION%\Autodesk\%ADMS_FOLDER%\ADMS Console\Connectivity.ADMSConsole.exe" /licensefile "%LOCATION%\Autodesk\%ADMS_FOLDER%\LICPATH.LIC" /license SIN-DEPOT

REM ==end of install==================================
:end
