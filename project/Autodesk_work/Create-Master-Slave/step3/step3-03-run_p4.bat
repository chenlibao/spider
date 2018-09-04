echo off

mkdir "E:\jenkins\workspace\03-BuildHeliosLibraries\"

set server="USSCLPDPRFRC003:20300"
set user="shqa_auto_vmware"
set password=Changeme4
set workspace="03-BuildHeliosLibraries--523770561"

set online_directory_1="//EDM/Main/QA/Automations/Helios/..."
set online_directory_2="//EDM/Main/QA/Streams/R22SP1/Automations/..."

echo %password%|p4 -p %server% -u %user% -p %password% -c %workspace% login

p4 -p %server% -u %user% -p %password% -c %workspace% sync -f %online_directory_1%
REM p4 -p %server% -u %user% -p %password% -c %workspace% sync -f %online_directory_2%

exit 0
