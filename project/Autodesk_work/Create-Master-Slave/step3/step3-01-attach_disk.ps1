# Set volume online
$volume = Get-Disk | Where-Object IsOffline -EQ $true

if (!$volume) {
  write-host '[FAILED]There is no volume to attach. Please check it in ECS.'
  exit 1
}

$volume | Set-Disk -IsOffline $false

# Initialise the volume
$volume | Initialize-Disk -PartitionStyle MBR

# Create a new partition with the volume
$Partition = $volume | New-Partition -UseMaximumSize -AssignDriveLetter

# Format the new partition
$Partition | Format-Volume -Confirm:$false

# Output the driveLetter of the new partition
$Partition | Select-Object "DriveLetter" | Format-List | Out-File driveLetter.txt
Write-Host "[SUCCESS] Volume has been attched."

# # Add a new administrator account
# $user = 'shqa_auto_vmware'
# net localgroup Administrators $user /add
# Write-Host "[SUCCESS] '$user' has been set as administrator."
#
# # Restart this instance
# Write-Host "[PROCESSING] It will restart."
# Restart-Computer -Force
