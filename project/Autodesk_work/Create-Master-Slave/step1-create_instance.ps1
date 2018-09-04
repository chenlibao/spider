# Copy Files
$FileSource = "\\10.49.83.229\Shared\JenkinsSlaveKit"
$FileTarget = "C:\JenkinsSlaveKit"

& ROBOCOPY $FileSource $FileTarget /MIR

while(-not (Test-Path "$FileTarget\acp-cli_1.3.1.3.exe"))
{
  Write-Host "[PROCESSING] Waiting for copying files completely."
  sleep 5
}
Write-Host "[SUCCESS] Copied files."

# Imported the ECSCLI Powershell Library.
. $FileTarget\BatchFiles\ECSCLI.ps1
Write-Host "[SUCCESS] Imported the ECSCLI Powershell Library."

# Create instance
$acp = "$FileTarget\acp-cli.exe"
$regionId = '4adbfe5e-b377-4e9a-9304-bf2d36015a6a'
$imageId = '3cd59cbc-8ebc-4ae0-84e4-c47511d330d7'
$InstanceName = 'Jenkins-Slave-Master-Dave-X'
$productId = '43'
$numInstances = '1'
$ak = '-ak:QonfTTseOLjbbD-ukBbNgYxrxEygzkqYFZb_6frnNGiYv8V_NMHaQD4xlCRvX_r4V-UH-9kBaFa6tAmp5Jd33g'
$sk = '-sk:SpgIjFS0C_j7eFHdzZyHfEYSlJvwKLnabTjMVlKF4xYpejM4bEDtu9E9siivVPKtbf5KbkZLIEr9ajP6Tg-qhw'

Write-Host "[PROCESSING] Creating instance."
create-instances $regionId $imageId $InstanceName $productId $numInstances
# the result of the previous line can't be loaded easyly, so use the method get-instances-byName to get InstanceId
# Get instanceId from result of create-instances
$instance = get-instances-byName $instanceName

$i = 0
for(; $i -le $instance.Count ; $i++){
  $tempString = $instance[$i] | Select-String -Pattern "$InstanceName$" -AllMatches
  if($tempString -ne $null){
    break;
  }
}
for(; $i -le $instance.Count ; $i++){
  $tempString = $instance[$i] | Select-String -Pattern 'InstanceId'
  if($tempString -ne $null){
    $returnValue = $instance[$i].Split(':')
    $InstanceId = [String]$returnValue[1].Trim()
    break;
  }
}
if ($instanceId.Length -eq 0) {
  write-host '[FAILED]Instance not found'
  exit 0
}
Write-Host "[SUCCESS] Create instance, InstanceId is $instanceId."

# Creating Volume
Write-Host "[PROCESSING] Creating Volume."
$vname = "New_Volume_Dave"
& $acp create-volumes $vname 500 $regionId $numInstances -attachId:$instanceId $ak $sk

Write-Host "[SUCCESS] Created 500G Volume, and attached this Volume to the instance."
