Import-Module AutomatedLab
Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\e9ba9320-1953-4aed-b5e8-acf489d4ac71\e9ba9320-1953-4aed-b5e8-acf489d4ac71.log"
New-LabDefinition -Name demo -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name Network1 -AddressSpace 192.168.1.1/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name dc1 -Memory 2GB -OperatingSystem 'Windows Server 2016 Standard (desktop experience)' -Roles RootDC -DomainName mydomain.net -Processors 1 -IpAddress 192.168.1.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name s1 -Memory 2GB -OperatingSystem 'Windows Server 2016 Standard (desktop experience)' -Roles WebServer, FileServer -DomainName mydomain.net -Processors 1 -IpAddress 192.168.1.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name s2 -Memory 2GB -OperatingSystem 'Windows Server 2016 Standard (desktop experience)' -Roles FileServer -DomainName mydomain.net -Processors 1 -IpAddress 192.168.1.3 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName s1, s2 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName s1, s2 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1