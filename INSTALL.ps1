#Requires -Version 5.1
#Requires -RunAsAdministrator

# Script to install and configure JEA-AdmComm
# author: Marco Bellaccini

param(
  [Parameter(Mandatory=$true)]
  [string]$psexec64path,
  [Parameter(Mandatory=$true)]
  [string]$allowedgroupname,
  [Parameter(Mandatory=$true)]
  [String[]]$progpaths,
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

# function to generate functions
function Genfun
{
  param(
    [string]$comNum,
    [string]$tgtexe
  )
  "@{Name= 'Invoke-AdmComm-$comNum'; ScriptBlock = {param(`$SessionID) Start-Process -FilePath `"PSEXEC64`" -ArgumentList `"-accepteula -s -h -i `$SessionID -w `$env:Public ```"$tgtexe```"`" -Verb runAs } }"
} 

# generate function definitions
foreach ($pp in $progpaths) {
  $comNum = [array]::IndexOf($progpaths, $pp)
  $bfundef = Genfun $comNum $pp

  if ($functdefs) {
    $functdefs = "$functdefs, $bfundef"
  }
  else {
    $functdefs = "$bfundef"
  }
}

# get array of paths enclosed in quotation marks
$progpathsen = $progpaths | ForEach-Object -Process {"'$_'"}

# generate comma-separated string of program paths
$progpathcsl = $progpathsen -join ", "

# replace programs and psexec64 tags in psrc file
(Get-Content $psrcf).replace('FUNCTDEFS', $functdefs).replace('TGTEXES', $progpathcsl).replace('PSEXEC64', $psexec64path) | Set-Content $psrcf

# register configuration
Register-PSSessionConfiguration -Path $psscf -Name 'JEA-AdmComm' -Force

# create nice links
foreach ($pp in $progpaths) {
  $comNum = [array]::IndexOf($progpaths, $pp)
  $wShell = New-Object -ComObject WScript.Shell
  $progname = Split-Path $pp -leaf
  $lnk = $wShell.CreateShortcut("$PSScriptRoot\Links\ADM_$progname.lnk")
  $lnk.TargetPath = "`"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe`""
  $lnk.Arguments = "-ExecutionPolicy Bypass -File `"$env:ProgramFiles\WindowsPowerShell\Modules\JEA-AdmComm\runJEACommand.ps1`" $comNum"
  $lnk.IconLocation = "$pp, 0"
  $lnk.Save()
}