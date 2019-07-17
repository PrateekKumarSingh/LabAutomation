$ErrorActionPreference = 'Stop'
try{
$Completed=$false
Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\fafdc335-f025-4170-a981-536a1b8f2cfc\fafdc335-f025-4170-a981-536a1b8f2cfc.log"
Import-Module AutomatedLab
New-LabDefinition -Name testlab -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name myvnet01 -AddressSpace 10.0.0.0
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name dc1 -Memory 2GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName test.com -Processors 2 -IpAddress 10.0.0.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName test.com -Processors 1 -IpAddress 10.0.0.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles FileServer -DomainName test.com -Processors 1 -IpAddress 10.0.0.3 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName dc1, srv1, srv2 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName dc1, srv1, srv2 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Show-LabDeploymentSummary -Detailed
Checkpoint-LabVM -All -SnapshotName 1
$Completed=$true;'Completed'|Out-File Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\fafdc335-f025-4170-a981-536a1b8f2cfc\status.txt
}
catch{
$_.Exception;'Failed'|Out-File Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\fafdc335-f025-4170-a981-536a1b8f2cfc\status.txt
}
finally{
if(-not $Completed){'Failed'|Out-File Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\fafdc335-f025-4170-a981-536a1b8f2cfc\status.txt}
}
