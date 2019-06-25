Import-Module AutomatedLab
if((Get-Lab -List) -eq "demo"){
Import-Lab -Name demo -ErrorAction SilentlyContinue
Remove-Lab -Name demo -Confirm:$false -ErrorAction SilentlyContinue
}
Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\c4bec7a0-d352-4768-859e-090b3d6611f2\c4bec7a0-d352-4768-859e-090b3d6611f2.log"
New-LabDefinition -Name demo -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name vnet01 -AddressSpace 10.0.0.0/24
$installationCredential = New-Object PSCredential("admin", ("ADMIN" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name mydc1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName dom.net -Processors 4 -IpAddress 10.0.0.1
$installationCredential = New-Object PSCredential("admin", ("ADMIN" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name client1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Datacenter (Desktop Experience)' -Roles WebServer -DomainName dom.net -Processors 2 -IpAddress 10.0.0.1 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("ADMIN" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name client2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer, FileServer -DomainName dom.net -Processors 4 -IpAddress 10.0.0.1 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName client1 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
