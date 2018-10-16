# script to run process as SYSTEM using JEA
# author: Marco Bellaccini

# get Windows Session ID
$SessionID = (Get-Process -PID $pid).SessionID

# prepare script block
# variable substitution in a script block is not so trivial:
# https://blogs.technet.microsoft.com/heyscriptingguy/2013/05/22/variable-substitution-in-a-powershell-script-block/
$strScrBlock = "Invoke-AdmComm -SessionID $SessionID"
$ScrBlock = [scriptblock]::Create($strScrBlock)

# invoke command in remote session using JEA
Invoke-Command -ComputerName localhost -ConfigurationName 'JEA-AdmComm' -InDisconnectedSession -ScriptBlock $ScrBlock
