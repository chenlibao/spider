# Copying Setup files to C:\
net use \\10.49.83.229\Shared QA@autodesk1 /user:ads\itools
net use \\sin-depot.ads.autodesk.com\ISO QA@autodesk1 /user:ads\itools

ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Helios C:\jenkins\Helios\Library /MIR
ROBOCOPY \\10.49.83.229\Shared\VS2012TestAgent C:\jenkins\Helios Remote.testsettings
ROBOCOPY \\10.49.83.229\Shared\JenkinsSlaveKit C:\JenkinsSlaveKit /MIR
ROBOCOPY \\10.49.83.229\Shared\ImageBuilderKit C:\ImageBuilderKit /MIR
ROBOCOPY "\\sin-depot.ads.autodesk.com\ISO\DeveloperTools\Visual Studio 2012\VS2012Agent" C:\InstallVS2012Agent /MIR

write-host 'Finished copy'

# install testcontroller and configure test controller manually( https://wiki.autodesk.com/display/V/3.+Setting+up+Test+Controller+and+Test+Agent )
cmd.exe /c start /wait C:\InstallVS2012Agent\TestController\vstf_testcontroller.exe /q

# install testAgent
cmd.exe /c start /wait C:\InstallVS2012Agent\TestAgent\vstf_testagent.exe /q

write-host 'Finished install TestController and TestAgent'

#copy library to local
ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Library E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Automations\Helios\Library /MIR
# ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Library E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Framework\Library /MIR
# ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Library E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Streams\2015\HeliosVS2012RTM\Automations\Helios\Library /MIR
# ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Library E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Streams\2015\R20RTM\Automations\Helios\Library /MIR
# ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Library E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Streams\2015\R20RTM\Automations\VaultAutomation\Library /MIR
# ROBOCOPY \\10.49.83.229\Shared\Vault_Jenkins\Library E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Streams\R22SP1\Automations\Helios\Library /MIR
ROBOCOPY \\10.49.83.229\Shared\VS2012TestAgent\startController C:\Users\shqa_auto_vmware\Desktop /MIR

write-host 'Finished copy1'

Copy-Item -Path E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Automations -Destination E:\HeliosTest\Automations -Recurse
Copy-Item -Path E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Framework -Destination E:\HeliosTest\Framework -Recurse
Copy-Item -Path E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA\Framework\Library -Destination E:\HeliosTest\Deployment -Recurse

write-host 'Finished copy2'

# map shared folder to local Z:
net use z: \\10.49.83.229\Shared "Changeme4" /user:"ads\shqa_auto_vmware"

# share QA file to network for next step mapping shared folder
cmd /c net share QA=E:\jenkins\workspace\03-BuildHeliosLibraries\EDM\Main\QA

# share HeliosTest file to network for next step mapping shared folder
cmd /c net share HeliosTest=E:\HeliosTest

# map shared folder to local Q:
net use Q: \\10.49.84.161\QA "Changeme4" /user:"ads\shqa_auto_vmware"

exit 0
