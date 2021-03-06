Start-Transcript -Force -Path "D:\Workspace\LabAutomation\BuildRequest\76606369-a27a-4182-a4c6-5acc725a1657\76606369-a27a-4182-a4c6-5acc725a1657.log"
Import-Module AutomatedLab
if((Get-Lab -List) -eq "test2"){
Import-Lab -Name test2 -ErrorAction SilentlyContinue
Remove-Lab -Name test2 -Confirm:$false -ErrorAction SilentlyContinue
}
New-LabDefinition -Name test2 -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name net2 -AddressSpace 10.1.0.1/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name dc2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName mydomain.net -Processors 1 -IpAddress 10.1.0.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv3 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName mydomain.net -Processors 1 -IpAddress 10.1.0.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name srv4 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName mydomain.net -Processors 1 -IpAddress 10.1.0.3 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName dc2, srv3 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName dc2, srv3 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
Show-LabDeploymentSummary -Detailed
