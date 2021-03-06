Start-Transcript -Force -Path "D:\Workspace\LabAutomation\BuildRequest\7938d2e0-e547-4d9d-ae3d-e924c7cb7acc\7938d2e0-e547-4d9d-ae3d-e924c7cb7acc.log"
Import-Module AutomatedLab
New-LabDefinition -Name demo -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name demo1 -AddressSpace 10.2.1.0/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name demodc -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName demo.com -Processors 1 -IpAddress 10.2.1.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name democl1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName demo.com -Processors 1 -IpAddress 10.2.1.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name democl2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -DomainName demo.com -Processors 1 -IpAddress 10.2.1.3
Install-Lab
Install-LabSoftwarePackage -ComputerName demodc -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
Show-LabDeploymentSummary -Detailed
