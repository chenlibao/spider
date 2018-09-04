#--Helper Functions--
$LogFile = "C:\GenerateCIBase.log" #Specify location of Log File
Function LogWrite([string]$LogString ,[bool]$IsError = $false, [bool]$Fatal = $false)
{
  $Date = Get-Date -format ""
  $Format = "[" + $Date + "] " + $LogString

  #Add message to log file then print to console
  Add-content $LogFile -value $Format

  #If a Fatal error was printed, the script needs to stop execution.
  if($IsError){
    if(!($Fatal)){
       #Not a fatal Error
       Write-Error $Format
    }else{
       #Fatal Error
       Write-Error $Format -ea "Stop"
    }
  }else{
    #No error
    Write-Host $format
  }
}

# Setup Administrator user and password
function SetupAdminUser{
    LogWrite "Start SetupAdminUser"
    $username = "ads\shqa_auto_vmware"
    $password = "Changeme4"
    if (Get-WmiObject Win32_UserAccount -Filter "LocalAccount='true' and Name='shqa_auto_vmware'") {
      net user $username $password
      wmic useraccount where "Name='$username'" set disabled=false
    } else {
      # net user $username $password /add
      net localgroup Administrators $username /add

    }
    wmic useraccount where "Name='$username'" set PasswordExpires=false

    Write-Host "End SetupAdminUser $(Get-Date)"
}

#Setup user autologon
function SetupAutoLogon{
    LogWrite "Start SetupAutoLogon"
    $RegistryPath='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    Set-ItemProperty $RegistryPath -Name "autoadminlogon" -Value 1
    Set-ItemProperty $RegistryPath -Name "DefaultUserName" -Value "shqa_auto_vmware"
    Set-ItemProperty $RegistryPath -Name "DefaultPassword" -Value "Changeme4"

    Write-Host "End SetupAutoLogon"
}

function CreateBaseImagePrevious{
    SetupAdminUser
    SetupAutoLogon
}

CreateBaseImagePrevious
Restart-Computer -Force
