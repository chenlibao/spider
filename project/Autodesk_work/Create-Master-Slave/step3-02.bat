echo off
cd /d %~dp0

%CD%/step3/step3-03-run_p4.bat
Powershell %CD%/step3/step3-04-copy_share.ps1
python %CD%/step3/step3-05-replace_ip.py
