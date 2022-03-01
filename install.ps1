﻿ <#
    .SYNOPSIS
        This script is used to install the Windows Forensic (Win-FOR) VM toolset into a Windows VM
        https://github.com/digitalsleuth/winfor-salt
    .DESCRIPTION
        The Windows Forensic (Win-FOR) VM comes with a multitude of tools for use in conducting digital forensics using a Windows
        Operating System. Many useful tools for malware analysis, reverse engineering, and advanced digital forensics are designed
        to run in Windows. Instead of creating a list for manual download, this installer, as well as the SaltStack state files
        which are part of the package, will allow for an easy, automated install.
        Additionally, the Win-FOR states allow for the automated installation of the Windows Subsystem for Linux v2, and comes with
        the REMnux and SIFT toolsets, making the VM a one-stop shop for forensics!
    .NOTES
        Version        : 2.0.0
        Author         : Corey Forman (https://github.com/digitalsleuth)
        Prerequisites  : Windows 10 1909 or later
                       : Set-ExecutionPolicy must allow for script execution
    .PARAMETER User
        Choose the desired username to configure the installation for.
        If not selected, the currently logged in user will be selected.
    .PARAMETER Mode
        There are two modes to choose from for the installation of the Win-FOR VM:
            addon: Install all of the tools, but don't do any customization. Leaves your config the way it is
            dedicated: Assumes that you want the full meal-deal, and will install all packages, customize the layout, and provide
                       additional reference documents
        If neither option is selected, the addon mode will be selected.
    .PARAMETER Update
        Identifies the current version of the environment and re-installs all states from that version
    .PARAMETER Upgrade
        Identifies the latest version of Win-FOR and will install that version
    .PARAMETER Version
        Print the current version of the installed Win-FOR environment
    .PARAMETER IncludeWsl
        When selected, will install the Windows Subsystem for Linux v2, and will install the SIFT and REMnux toolsets.
        This option assumes you also want the full Win-FOR suite, and will install that first, then WSL last
    .PARAMETER WslOnly
        If you wish to install only WSLv2 with SIFT and REMnux either separately (due to bandwidth / system limitations)
        or you only want that particular feature and nothing else, this option will do just that. It will not install the Win-FOR
        states.
    .Example
        .\install.ps1 -User forensics -Mode dedicated -IncludeWsl
		.\install.ps1 -WslOnly
        .\install.ps1 -Version
        .\install.ps1 -Update
        .\install.ps1 -Upgrade
    #>

param (
  [string]$User = "",
  [string]$Mode = "",
  [switch]$Update,
  [switch]$Upgrade,
  [switch]$Version,
  [switch]$IncludeWsl,
  [switch]$WslOnly
)

[string]$saltstackVersion = '3004-3'
[string]$saltstackFile = 'Salt-Minion-' + $saltstackVersion + '-Py3-AMD64-Setup.exe'
[string]$saltstackHash = "D7B998C2BA5025200D13F55A0D7248DC9001E23949102D8E8A394C7733C1FA6B"
[string]$saltstackUrl = "https://repo.saltproject.io/windows/"
[string]$saltstackSource = $saltstackUrl + $saltstackFile
[string]$gitVersion = '2.35.1'
[string]$gitFile = 'Git-' + $gitVersion + '.2-64-bit.exe'
[string]$gitHash = "77768D0D1B01E84E8570D54264BE87194AA424EC7E527883280B9DA9761F0A2A"
[string]$gitUrl = "https://github.com/git-for-windows/git/releases/download/v" + $gitVersion + ".windows.2/" + $gitFile

function Compare-Hash($FileName, $HashName) {
    $fileHash = (Get-FileHash $FileName -Algorithm SHA256).Hash
    if ($fileHash -eq $HashName) {
        Write-Host "[+] Hashes match, continuing..." -ForegroundColor Green
    } else {
        Write-Host "[+] Hash values do not match, not continuing with install" -ForegroundColor Red
        exit
    }
}

function Test-Saltstack {
    $InstalledSalt = (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName -clike 'Salt Minion*' } | Select-Object DisplayName, DisplayVersion)
    if ($InstalledSalt.DisplayName -eq $null) {
        return $False
    } elseif ($InstalledSalt.DisplayName -clike 'Salt Minion*' -and $InstalledSalt.DisplayVersion -eq $saltstackVersion) {
        return $True
    }
}

function Get-Saltstack {
    if (-Not (Test-Path C:\Windows\Temp\$saltstackFile)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "[-] Downloading SaltStack v$saltstackVersion" -ForegroundColor Yellow
        Start-BitsTransfer -Source $saltstackSource -Destination "C:\Windows\Temp\$saltstackFile"
        Write-Host "[-] Verifying Download" -ForegroundColor Yellow
        Compare-Hash -FileName C:\Windows\Temp\$saltstackFile -HashName $saltstackHash
        Write-Host "[-] Installing SaltStack v$saltstackVersion" -ForegroundColor Yellow
        Install-Saltstack
    } else {
        Write-Host "[-] Found existing SaltStack installer - validating hash before installing" -ForegroundColor Yellow
        Compare-Hash -FileName C:\Windows\Temp\$saltstackFile -HashName $saltstackHash
        Write-Host "[+] Installing SaltStack v$saltstackVersion" -ForegroundColor Yellow
        Install-Saltstack
    }
}

function Install-Saltstack {
    Start-Process -Wait -FilePath "C:\Windows\Temp\$saltstackFile" -ArgumentList '/S /master=localhost /minion-name=WIN-FOR' -PassThru | Out-Null
    if ($?) {
        Write-Host "[+] SaltStack installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[!] Installation of SaltStack failed. Please re-run the installer to try again" -ForegroundColor Red
        exit
    }
}

function Test-Git {
    $InstalledGit = (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object {$_.DisplayName -clike 'Git*' } | Select-Object DisplayName, DisplayVersion)
    if ($InstalledGit.DisplayName -eq $null) {
        return $False
    } elseif ($InstalledGit.DisplayName -clike 'Git*' -and $InstalledGit.DisplayVersion -clike "$gitVersion*") {
        return $True
    }
}

function Get-Git {
    if (-Not (Test-Path C:\Windows\Temp\$gitFile)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "[-] Downloading Git v$gitVersion" -ForegroundColor Yellow
        Start-BitsTransfer -Source $gitUrl -Destination "C:\Windows\Temp\$gitFile"
        Write-Host "[-] Verifying Download" -ForegroundColor Yellow
        Compare-Hash -FileName C:\Windows\Temp\$gitFile -HashName $gitHash
        Write-Host "[-] Installing Git v$gitVersion" -ForegroundColor Yellow
        Install-Git
    } else {
        Write-Host "[-] Found existing Git installer - validating hash before installing" -ForegroundColor Yellow
        Compare-Hash  -FileName C:\Windows\Temp\$gitFile -HashName $gitHash
        Write-Host "[-] Installing Git v$gitVersion" -ForegroundColor Yellow
        Install-Git
    }
}

function Install-Git {
    Start-Process -Wait -FilePath "C:\Windows\Temp\$gitFile" -ArgumentList '/VERYSILENT /NORESTART /SP- /NOCANCEL /SUPPRESSMSGBOXES' -PassThru | Out-Null
    if ($?) {
        Write-Host "[+] Git installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[!] Installation of Git failed. Please re-run the installer to try again" -ForegroundColor Red
        exit
    }
}
function Get-WinFORRelease($installVersion) {
    $zipFolder = 'winfor-salt-' + $installVersion.Split("v")[-1]
    Write-Host "[-] Downloading and unpacking $installVersion" -ForegroundColor Yellow
    Start-BitsTransfer -Source https://github.com/digitalsleuth/winfor-salt/archive/refs/tags/$installVersion.zip -Destination C:\Windows\Temp
    Start-BitsTransfer -Source https://github.com/digitalsleuth/winfor-salt/releases/download/$installVersion/winfor-salt-$installVersion.zip.sha256 -Destination C:\Windows\Temp
    $releaseHash = (Get-Content C:\Windows\Temp\winfor-salt-$installVersion.zip.sha256).Split(" ")[0]
    Write-Host "[-] Validating hash for release file" -ForegroundColor Yellow
    Compare-Hash -FileName C:\Windows\Temp\$installVersion.zip -HashName $releaseHash
    Expand-Archive -Path C:\Windows\Temp\$installVersion.zip -Destination 'C:\ProgramData\Salt Project\Salt\srv\' -Force
    Move-Item "C:\ProgramData\Salt Project\Salt\srv\$zipFolder" 'C:\ProgramData\Salt Project\Salt\srv\salt' -Force
}

function Install-WinFOR {
    $apiUri = "https://api.github.com/repos/digitalsleuth/winfor-salt/releases/latest"
    $latestVersion = ((((Invoke-WebRequest $apiUri -UseBasicParsing).Content) | ConvertFrom-Json).zipball_url).Split('/')[-1]
    $installVersion = $latestVersion
    if ($Update) {
       if(-Not (Test-Path $versionFile)) {
           $winforVersion = 'not installed'
           Write-Host "[!] WIN-FOR is not installed. Try running the installer again before choosing the update option." -ForegroundColor Red
           exit
        } else {
           $winforVersion = (Get-Content $versionFile)
        }
        $installVersion = $winforVersion
	} elseif ($Upgrade) {
        if(-Not (Test-Path $versionFile)) {
           $winforVersion = 'not installed'
           Write-Host "[!] WIN-FOR is not installed. Try running the installer again before choosing the upgrade option." -ForegroundColor Red
           exit
       } else {
        $installVersion = $latestVersion
        }
    }
    $saltStatus = Test-Saltstack
    if ($saltStatus -eq $False) {
        Write-Host "[-] SaltStack not installed" -ForegroundColor Yellow
        Get-Saltstack
    } elseif ($saltStatus -eq $True) {
        Write-Host "[+] SaltStack v$saltstackVersion already installed" -ForegroundColor Green
    }
	$gitStatus = Test-Git
    if ($gitStatus -eq $False) {
        Write-Host "[-] Git not installed" -ForegroundColor Yellow
        Get-Git
    } elseif ($gitStatus -eq $True) {
        Write-Host "[+] Git v$gitVersion already installed" -ForegroundColor Green
    }
    Write-Host "[-] Refreshing environment variables" -ForegroundColor Yellow
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $logFile = "C:\winfor-saltstack-$installVersion.log"
    Get-WinFORRelease $installVersion
    Write-Host "[+] The Win-FOR installer command is running, configuring for user $User - this will take a while... please be patient" -ForegroundColor Green
    Start-Process -Wait -FilePath "C:\Program Files\Salt Project\Salt\salt-call.bat" -ArgumentList ("-l debug --local --retcode-passthrough --state-output=mixed state.sls winfor.$Mode pillar=`"{'winfor_user': '$user'}`" --log-file-level=debug --log-file=`"$logFile`" --out-file=`"$logFile`" --out-file-append") | Out-Null
    if (-Not (Test-Path $logFile)) {
        $results=$failures=$errors=$null
	} else {
    $results = (Select-String -Path $logFile -Pattern 'Succeeded:' -Context 1 | ForEach-Object{"[!] " + $_.Line; "[!] " + $_.Context.PostContext} | Out-String).Trim()
    $failures = (Select-String -Path $logFile -Pattern 'Succeeded:' -Context 1 | ForEach-Object{$_.Context.PostContext}).split(':')[1].Trim()
    $errors = (Select-String -Path $logFile -Pattern '          ID:' -Context 0,6 | ForEach-Object{$_.Line; $_.Context.DisplayPostContext + "`r-------------"})
    }
	$errorLogFile = "C:\winfor-errors-$installVersion.log"
    if ($failures -ne 0 -and $failures -ne $null) {
        $errors | Out-File $errorLogFile -Append
        Write-Host $results -ForegroundColor Yellow
        Write-Host "[!] To determine the cause of the failures, review the log file $logFile and search for lines containing [ERROR   ], or review $errorLogFile for a less verbose listing."
    } else {
        Write-Host $results -ForegroundColor Green
        exit
    }
    if ($IncludeWsl) {
        if ($results) {
            $results | Out-File "C:\winfor-results-$installVersion.log" -Append
            }
        Invoke-WSLInstaller
    }
}

function Invoke-WinFORInstaller {
    $versionFile = "C:\ProgramData\Salt Project\Salt\srv\salt\winfor-version"
    $runningUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-Not $runningUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Not running as administrator, please re-run this script as Administrator" -ForegroundColor Red
        exit 1
    }
    if($Version) {
        if(-Not (Test-Path $versionFile)) {
            $winforVersion = 'not installed'
        } else {
            $winforVersion = (Get-Content $versionFile)
        }
        Write-Host "WIN-FOR is $winforVersion" -ForegroundColor Green
        exit
    }
    if ($User -eq "") {
        $User = [System.Environment]::UserName
        }
    if ($Mode -eq "") {
        $Mode = "addon"
        }
    if (($Mode -ne 'addon') -and ($Mode -ne 'dedicated')) {
        Write-Host "[!] The only valid modes are 'addon' or 'dedicated'." -ForegroundColor Red
        exit 1
    }
    Write-Host "[-] Running Win-FOR SaltStack installation" -ForegroundColor Yellow
    Install-WinFOR
}

function Invoke-WSLInstaller {
    if ($User -eq "") {
        $User = [System.Environment]::UserName
    }
    $runningUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $runningUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Not running as administrator, please re-run this script as Administrator" -ForegroundColor Red
        exit 1
    }
    ### UAC and Defender settings based on https://github.com/Disassembler0/Win10-Initial-Setup-Script
    ### Required for unattended WSL setup
    Write-Output "[-] Lowering UAC level..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
    }
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
	    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
    }
    Add-MpPreference -ExclusionPath "C:\standalone\wsl"
    $wslLogFile = "C:\winfor-wsl.log"
    $wslErrorLog = "C:\winfor-wsl-errors.log"
    if (-Not (Test-Path "C:\ProgramData\Salt Project\Salt\srv\salt\winfor")) {
        $apiUri = "https://api.github.com/repos/digitalsleuth/winfor-salt/releases/latest"
        $latestVersion = ((((Invoke-WebRequest $apiUri -UseBasicParsing).Content) | ConvertFrom-Json).zipball_url).Split('/')[-1]
        $installVersion = $latestVersion
        $logFile = "C:\winfor-saltstack-$installVersion.log"
        Get-WinFORRelease $installVersion
    }
    Write-Host "[+] Installing WSLv2 with SIFT and REMnux" -ForegroundColor Green
    Start-Process -Wait -FilePath "C:\Program Files\Salt Project\Salt\salt-call.bat" -ArgumentList ("-l debug --local --retcode-passthrough --state-output=mixed state.sls winfor.repos pillar=`"{'winfor_user': '$User'}`" --log-file-level=debug --log-file=`"$wslLogFile`" --out-file=`"$wslLogFile`" --out-file-append") | Out-Null
    Start-Process -Wait -FilePath "C:\Program Files\Salt Project\Salt\salt-call.bat" -ArgumentList ("-l debug --local --retcode-passthrough --state-output=mixed state.sls winfor.wsl pillar=`"{'winfor_user': '$User'}`" --log-file-level=debug --log-file=`"$wslLogFile`" --out-file=`"$wslLogFile`" --out-file-append") | Out-Null
    $wslErrors = (Select-String -Path $wslLogFile -Pattern '          ID:' -Context 0,6 | ForEach-Object{$_.Line; $_.Context.DisplayPostContext + "`r-------------"})
    $wslErrors | Out-File $wslErrorLog -Append
    Write-Host "[+] Installation finished" -ForegroundColor Green
}
if ($WslOnly) {
    $saltStatus = Test-Saltstack
    $gitStatus = Test-Git
    if ($saltStatus -ne $True) {
        Write-Host "[-] SaltStack not installed" -ForegroundColor Yellow
        Get-Saltstack
    }
    if ($gitStatus -ne $True) {
        Write-Host "[-] Git not installed" -ForegroundColor Yellow
        Get-Git
    }
    Invoke-WSLInstaller
} else {
    Invoke-WinFORInstaller
}
