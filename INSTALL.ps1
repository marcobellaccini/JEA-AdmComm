#Requires -Version 5.1
#Requires -RunAsAdministrator

# Script to install and configure JEA-AdmComm
# author: Marco Bellaccini

param(
  [Parameter(Mandatory=$true)]
  [string]$allowedgroupname,
  [Parameter(Mandatory=$true)]
  [string]$progpath,
  [Parameter(Mandatory=$true)]
  [string]$psexec64path,
  [switch]$uninstall = $false
)

if ($uninstall) 
{
  Unregister-PSSessionConfiguration -Name 'JEA-AdmComm' -Force
  Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEA-AdmComm" -Recurse -Force
  exit
}

# replace ".\" with "servername\" (when playing with local users)
$allowedgroupname = $allowedgroupname.replace('.\', "$env:computername\")

# copy module directory content
Copy-Item "$PSScriptRoot\Module\JEA-AdmComm" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules" -Recurse -Force

# pssc file
$psscf = "$env:ProgramFiles\WindowsPowerShell\Modules\JEA-AdmComm\JEA-AdmCommEndpoint.pssc"

# psrc file
$psrcf = "$env:ProgramFiles\WindowsPowerShell\Modules\JEA-AdmComm\RoleCapabilities\JEA-AdmComm-Role.psrc"

# replace allowed group tag in pssc file
(Get-Content $psscf).replace('ALLOWEDGROUPNAME', $allowedgroupname) | Set-Content $psscf

# replace program and psexec64 tag in psrc file
(Get-Content $psrcf).replace('TGTEXE', $progpath).replace('PSEXEC64', $psexec64path) | Set-Content $psrcf

# register configuration
Register-PSSessionConfiguration -Path $psscf -Name 'JEA-AdmComm' -Force

# create nice link
$wShell = New-Object -ComObject WScript.Shell
$progname = Split-Path $progpath -leaf
$lnk = $wShell.CreateShortcut("$PSScriptRoot\ADM_$progname.lnk")
$lnk.TargetPath = "`"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe`""
$lnk.Arguments = "-ExecutionPolicy Bypass -File `"$env:ProgramFiles\WindowsPowerShell\Modules\JEA-AdmComm\runJEACommand.ps1`""
$lnk.IconLocation = "$progpath, 0"
$lnk.Save()