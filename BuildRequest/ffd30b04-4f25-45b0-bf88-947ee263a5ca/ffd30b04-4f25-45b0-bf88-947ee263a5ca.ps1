Start-Transcript -Force -Path "D:\Workspace\LabAutomation\BuildRequest\ffd30b04-4f25-45b0-bf88-947ee263a5ca\ffd30b04-4f25-45b0-bf88-947ee263a5ca.log"
Import-Module AutomatedLab
New-LabDefinition -Name test -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name net1 -AddressSpace 10.0.0.1/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name dc1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName test.com -Processors 1 -IpAddress 10.0.0.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -DomainName test.com -Processors 1 -IpAddress 10.0.0.2
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -DomainName test.com -Processors 1 -IpAddress 10.0.0.3
Install-Lab
Install-LabSoftwarePackage -ComputerName dc1 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName dc1 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
Show-LabDeploymentSummary -Detailed
