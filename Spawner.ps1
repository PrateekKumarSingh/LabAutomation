Import-Module Gridify
$Process = @()
$Process += Start-Process powershell.exe -ArgumentList "$PSScriptRoot\WebServer.ps1"
$Process += Start-Process PowerShell.exe -ArgumentList "$PSScriptRoot\Translator.ps1"
Set-GridLayout -Process $Process -Layout Vertical