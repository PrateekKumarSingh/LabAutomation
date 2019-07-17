Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\19e9b6ae-46b4-40b2-a73a-8dd84ac87c4a\19e9b6ae-46b4-40b2-a73a-8dd84ac87c4a.log"
Import-Module AutomatedLab
New-LabDefinition -Name demo -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name vn001 -AddressSpace 10.0.0.0/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabDomainDefinition -Name mydomain.net -AdminUser admin -AdminPassword admin
Set-LabInstallationCredential -User admin -Password admin
Add-LabMachineDefinition -Name dc2 -Memory 4GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName mydomain.net -Processors 4 -IpAddress 10.0.0.1 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name client01 -Memory 4GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName mydomain.net -Processors 4 -IpAddress 10.0.0.3 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name client02 -Memory 4GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles FileServer -DomainName mydomain.net -Processors 4 -IpAddress 10.0.0.2 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName dc2, client01, client02 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName dc2, client01, client02 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
