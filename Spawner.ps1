Import-Module Gridify
$Dir = 'D:\Workspace\LabAutomation'
$Process = @()
$Process += Start-Process powershell.exe -PassThru "-NoExit -File $(Join-Path $Dir 'Translator.ps1')"
$Process += Start-Process PowerShell.exe -PassThru "-NoExit -File $(Join-Path $Dir 'WebServer.ps1')"
sleep -Seconds 2
Set-GridLayout -Process $Process -Layout Vertical -Verbose