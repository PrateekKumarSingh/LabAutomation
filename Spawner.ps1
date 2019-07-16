Import-Module Gridify
$Process = @()
$Process += Start-Process powershell.exe -PassThru
$Process += Start-Process PowerShell.exe -PassThru
sleep -Seconds 2
Set-GridLayout -Process $Process -Layout Vertical -Verbose