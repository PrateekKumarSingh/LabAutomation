Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\1b696412-f24b-4443-b3d7-bf04e2fbeec4\1b696412-f24b-4443-b3d7-bf04e2fbeec4.log"
Import-Module AutomatedLab
New-LabDefinition -Name test -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name testlab -AddressSpace 10.0.0.0
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabDomainDefinition -Name test.com -AdminUser admin -AdminPassword admin
Set-LabInstallationCredential -User admin -Password admin
Add-LabMachineDefinition -Name dc11 -Memory 4GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName test.com -Processors 2 -IpAddress 10.0.0.1 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv11 -Memory 4GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName test.com -Processors 2 -IpAddress 10.0.0.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv12 -Memory 4GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles FileServer -DomainName test.com -Processors 2 -IpAddress 10.0.0.3 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName dc11,srv11,srv12 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName dc11,srv11,srv12 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
