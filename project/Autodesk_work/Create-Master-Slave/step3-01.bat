echo off
cd /d %~dp0
Powershell %CD%/step3/step3-01-attach_disk.ps1
Powershell %CD%/step3/step3-02-install_requirements.ps1
