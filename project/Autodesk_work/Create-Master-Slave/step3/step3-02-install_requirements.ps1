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


#Install IIS
function InstallIIS{
    LogWrite "Start InstallIIS: $(Get-Date)"
    $Data = Dism /online /Get-FeatureInfo /FeatureName:IIS-WebServerRole
    if($Data -Contains ("State : Disabled")){
        #Enable Internet Information Services
        dism /Online /Enable-Feature /FeatureName:IIS-WebServerRole

        #Enable FTP Server
        dism /Online /Enable-Feature /FeatureName:IIS-FTPServer `
                                     /FeatureName:IIS-FTPSvc `
                                     /FeatureName:IIS-FTPExtensibility

        #Enable Web Management Tools
        dism /Online /Enable-Feature /FeatureName:IIS-WebServerManagementTools `
                                     /FeatureName:IIS-IIS6ManagementCompatibility `
                                     /FeatureName:IIS-ManagementConsole `
                                     /FeatureName:IIS-ManagementScriptingTools `
                                     /FeatureName:IIS-ManagementService `
                                     /FeatureName:IIS-Metabase `
                                     /FeatureName:IIS-LegacySnapIn `
                                     /FeatureName:IIS-HttpErrors `
                                     /FeatureName:IIS-RequestFiltering `
                                     /FeatureName:IIS-ISAPIExtensions `
                                     /FeatureName:IIS-ISAPIFilter `
                                     /FeatureName:IIS-StaticContent `
                                     /FeatureName:IIS-DefaultDocument `
                                     /FeatureName:IIS-DirectoryBrowsing `
                                     /FeatureName:IIS-ASPNET `
                                     /FeatureName:IIS-ASP `
                                     /FeatureName:IIS-CGI `
                                     /FeatureName:IIS-ServerSideIncludes `
                                     /FeatureName:IIS-HttpCompressionStatic

        #Enable World Wide Web Services
        dism /Online /Enable-Feature /FeatureName:IIS-WebServer `
                                     /FeatureName:IIS-ApplicationDevelopment `
                                     /FeatureName:IIS-CommonHttpFeatures `
                                     /FeatureName:IIS-HealthAndDiagnostics `
                                     /FeatureName:IIS-Performance `
                                     /FeatureName:IIS-HttpLogging `
                                     /FeatureName:IIS-Security `
                                     /FeatureName:IIS-NetFxExtensibility `
                                     /FeatureName:IIS-WindowsAuthentication `
                                     /FeatureName:IIS-RequestMonitor
        $changed = $True
    }
    Write-Host "End InstallIIS: $(Get-Date)"
}

#Install Sql Server
Function InstallSQLServer
{
    LogWrite "Start InstallSQLServer: $(Get-Date)"
    if (Test-Path "C:\Program Files\Microsoft SQL Serve"){
        return
    }
    $locationPath=Get-Location
    $tempDir = Join-Path $locationPath "Temp"
    $package = "en_sql_server_2012_enterprise_edition_with_service_pack_2_x64_dvd_4685849.iso"
    $TargetFile=Join-Path "\\sin-depot.ads.autodesk.com\ISO\Servers" $package
    $localFile=Join-Path $tempDir $package
    $SQLSYSADMINACCOUNTS = $env:userdomain + '\' + $env:username

    if (-not (Test-Path $tempDir)){
        New-Item $tempDir -ItemType Directory
    }
    net use "\\sin-depot.ads.autodesk.com\ISO\Servers" QA@autodesk1 /user:ads\itools
    Copy-Item $TargetFile $tempDir -Recurse
    &"7z" x $localFile -o"Temp" *

    Set-Location -Path $tempDir
    &'.\setup.exe' /IACCEPTSQLSERVERLICENSETERMS /Q `
                /SAPWD="AutodeskVault@26200" `
                /SQLSYSADMINACCOUNTS=($SQLSYSADMINACCOUNTS)
    Set-Location -Path $locationPath
    net use "\\sin-depot.ads.autodesk.com\ISO\Servers" /delete /Yes


    #rm -r $tempDir

    Write-Host "End InstallSQLServer: $(Get-Date)"
}

# Setup ASP.NET Impersonation

function SetupASPNet{
    LogWrite "Start SetupASPNet: $(Get-Date)"
    $username = "AutodeskVault"
    $password = "Au1oDSK@26200"
    if (Get-WmiObject Win32_UserAccount -Filter "LocalAccount='true' and Name='AutodeskVault'") {
      net user $username $password
      wmic useraccount where "Name='$username'" set disabled=false
    } else {
      net user $username $password /add
      net localgroup Administrators $username /add
    }
    wmic useraccount where "Name='$username'" set PasswordExpires=false

    #Grant the impersonating user full control to the Temporary ASP.NET Files directory
    $net_dir_86="C:\Windows\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files"
    $net_dir_64="C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Temporary ASP.NET Files"
    $dir_web_services="H:\Server\Web\Services"
    $person = [System.Security.Principal.NTAccount]$username
    $inheritance = [System.Security.AccessControl.InheritanceFlags] "ObjectInherit,ContainerInherit"
    $propagation = [System.Security.AccessControl.PropagationFlags]"None"
    $type = [System.Security.AccessControl.AccessControlType]"Allow"

    if (Test-Path $net_dir_86){
        $acl = (Get-Item $net_dir_86).GetAccessControl('access')
        $access = [System.Security.AccessControl.FileSystemRights]"FullControl"
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule( $person,$access,$inheritance,$propagation,$type)
        $acl.AddAccessRule($rule)
        $acl | Set-Acl $net_dir_86
    }else{
        Write-Host "Cannot find $net_dir_86"
    }

    if (Test-Path $net_dir_64){
        $acl = (Get-Item $net_dir_64).GetAccessControl('access')
        $access = [System.Security.AccessControl.FileSystemRights]"FullControl"
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule( $person,$access,$inheritance,$propagation,$type)
        $acl.AddAccessRule($rule)
        $acl | Set-Acl $net_dir_64
    }else{
        Write-Host "Cannot find $net_dir_64"
    }

    #Grant the impersonating user read access to the Vault Web Services source directory
    if (Test-Path $dir_web_services){
        $acl = (Get-Item $dir_web_services).GetAccessControl('access')
        $access = [System.Security.AccessControl.FileSystemRights]"Read"
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule( $person,$access,$inheritance,$propagation,$type)
        $acl.AddAccessRule($rule)
        $acl | Set-Acl $dir_web_services
    }else{
        Write-Host "Cannot find $dir_web_services"
    }

    Write-Host "End SetupASPNet: $(Get-Date)"
}

#ASP.NET 4.0 registered with IIS
function ASPNETRegistered{
    LogWrite "Start ASPNETRegistered: $(Get-Date)"
    $locationPath=Get-Location
    $commandPath="c:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\"

    Set-Location -Path $commandPath
    ./aspnet_regiis.exe -i
    Set-Location -Path $locationPath
    Write-Host "End ASPNETRegistered: $(Get-Date)"
}


# Install chocolatey
function InstallChocolatey{
    LogWrite "Start InstallChocolatey: $(Get-Date)"
    $chocoPath = $env:chocolateyinstall
    if ($chocoPath -eq $null -or $chocoPath -eq '' -or !(Test-Path($chocoPath))) {
      Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    Write-Host "End InstallChocolatey: $(Get-Date)"
}

# Install 7zip
function Install7zip{
    LogWrite "Start Install7zip: $(Get-Date)"
    $result = clist -lo -e 7zip
    if ("$result" -match ".* (\d+) packages installed.") {
      if ($matches[1] -eq 0) {
        cinst -y 7zip --timeout 0
        $changed = $True
      }
    }

    # Add 7zip to system path
    $path = [environment]::GetEnvironmentvariable("Path","Machine")
    if (-not ($path -match ".*7-Zip")){
        $path = $path + ";C:\Program Files\7-Zip"
        [environment]::SetEnvironmentvariable("Path", $path, "Machine")
    }
    Write-Host "End Install7zip: $(Get-Date)"
}

# Install VC Run Time
function InstallRunTime{
    LogWrite "Start InstallRunTime: $(Get-Date)"
    $vp_server = "\\10.49.83.229\Shared"
    net use $vp_server Changeme4 /user:ads\shqa_auto_vmware
    #VCREDIST2008SP1X64
    $exe_path = $vp_server + "\3rdParty\x64\VCRedist\2008SP1\vcredist_x64.exe"
    $exe_param = "/q /l %temp%\vcredist_x64_2008_SP1.log"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2008SP1X64_6161
    $exe_path = $vp_server + "\3rdParty\x64\VCRedist\2008SP1.6161\vcredist_x64.exe"
    $exe_param = "/q"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2008SP1X86
    $exe_path = $vp_server + "\3rdParty\x86\VCRedist\2008SP1\vcredist_x86.exe"
    $exe_param = "/q /l %temp%\vcredist_x86_2008_SP1.log"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2008SP1X86_6161
    $exe_path = $vp_server + "\3rdParty\x86\VCRedist\2008SP1.6161\vcredist_x86.exe"
    $exe_param = "/q"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2010SP1X86
    $exe_path = $vp_server + "\3rdParty\x86\VCRedist\2010SP1\vcredist_x86.exe"
    $exe_param = "/q /l /norestart %temp%\vcredist_x86_2010_SP1.log"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2010SP1X64
    $exe_path = $vp_server + "\3rdParty\x64\VCRedist\2010SP1\vcredist_x64.exe"
    $exe_param = "/q /l /norestart %temp%\vcredist_x64_2010_SP1.log"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2012X86
    $exe_path = $vp_server + "\3rdParty\x86\VCRedist\2012\vcredist_x86.exe"
    $exe_param = "/install /quiet /norestart"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2012X64
    $exe_path = $vp_server + "\3rdParty\x64\VCRedist\2012\vcredist_x64.exe"
    $exe_param = "/install /quiet /norestart"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2015X86
    $exe_path = $vp_server + "\3rdParty\x86\VCRedist\2015\vcredist_x86.exe"
    $exe_param = "/q /norestart"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2015X64
    $exe_path = $vp_server + "\3rdParty\x64\VCRedist\2015\vcredist_x64.exe"
    $exe_param = "/q /norestart"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2017X86
    $exe_path = $vp_server + "\3rdParty\x86\VCRedist\2017\vc_redist.x86.exe"
    $exe_param = "/install /quiet /norestart"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    #VCREDIST2017X64
    $exe_path = $vp_server + "\3rdParty\x64\VCRedist\2017\vc_redist.x64.exe"
    $exe_param = "/install /quiet /norestart"
    Start-Process -FilePath $exe_path -ArgumentList $exe_param -NoNewWindow -Wait

    net use $vp_server /delete /Yes

    Write-Host "End InstallRunTime: $(Get-Date)"
}


#install VS2012premium
function InstallVS2012premium{
    begin{
        LogWrite "start to Install VS2012premium"

    }
    Process{
        New-Item C:\tmp -Type Directory
		net use "\\sin-depot.ads.autodesk.com\ISO\DeveloperTools\Visual Studio 2012" QA@autodesk1 /user:ads\itools
		Copy-Item "\\sin-depot.ads.autodesk.com\ISO\DeveloperTools\Visual Studio 2012\en_visual_studio_premium_2012_x86_dvd_920758.iso" "C:\tmp" -Recurse

		if (test-path "C:\tmp\en_visual_studio_premium_2012_x86_dvd_920758.iso"){
	    &"7z" x "C:\tmp\en_visual_studio_premium_2012_x86_dvd_920758.iso" -o"C:\tmp" *
		}
		cd C:\tmp
		if (test-path "C:\tmp\vs_premium.exe"){
		cmd.exe /c start /wait C:\tmp\vs_premium.exe /q
		}
    }
    end{
        Write-Host "completed to install VS2012premium"
    }
}



#Install .Net 4.5
function InstallNet4.5{
    begin{
        LogWrite "Istall .Net4.5 Dev Package"
    }
    Process{
        choco install -y "dotnet4.5.1"
    }
    end{
        Write-Host "completed to install .Net4.5"
    }
}

#Install P4v
function Installp4v{
    begin{
        LogWrite "Istall p4v"
    }
    Process{
        choco install -y "p4v"
    }
    end{
        Write-Host "completed to install p4v"
    }
}

#Install Java8
function InstallJava8{
    begin{
        LogWrite "Istall jdk8"
    }
    Process{
        choco install -y "jdk8"
    }
    end{
        Write-Host "completed to install jdk8"
    }
}

#Place psexec.exe under c:\psexec

Function ChocoInstallPackage([string]$package, [string]$version = "", [string]$packageParameters = "") {
    $result = clist -lo -e $package
    if ("$result" -match ".* (\d+) packages installed.") {
      if ($matches[1] -eq 0) {
        if ($version -eq "") {
          choco install -y $package
        } elseif ($packageParameters -eq "") {
          choco install -y $package --version $version
        } else {
          choco install -y $package --version $version  --packageParameters $packageParameters
        }
      }
    }
}

#Install git
function InstallGit{
    begin{
        LogWrite "Install git"
    }
    Process{
        ChocoInstallPackage "git" "2.17.1.2"
    }
    end{
        Write-Host "completed to install git"
    }
}

#Install Python
function InstallPython{
    begin{
        LogWrite "Install Python"
    }
    Process{
        ChocoInstallPackage "Python" "3.6.1"
    }
    end{
        Write-Host "completed to install python"
    }
}

#Set system variables
function SetVariables{
    begin{
        LogWrite "Set system variables"
    }
    Process{
        $PyPath="C:\Python36"
        [Environment]::SetEnvironmentVariable( "VAULT_PYTHON_PATH", $PyPath, "Machine" )
    }
    end{
        Write-Host "completed to set variables"
    }
}

function CreateBaseImage{
    InstallChocolatey
    Install7zip
    InstallIIS
    SetupASPNet
    ASPNETRegistered
    InstallSQLServer
    InstallRunTime
    #InstallPowershell4
    InstallVS2012premium
    InstallNet4.5
	Installp4v
	InstallJava8
    #PlacePSExec
    #InstallSDK8
    #InstallSDK10
    InstallGit
    InstallPython
    #InstallTypemock
    SetVariables
	#SetupJenkins
}

CreateBaseImage

LogWrite "All Done"
