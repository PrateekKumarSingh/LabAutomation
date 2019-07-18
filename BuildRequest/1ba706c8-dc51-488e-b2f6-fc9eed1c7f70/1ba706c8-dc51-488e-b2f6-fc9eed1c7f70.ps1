$Completed=$false
Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\1ba706c8-dc51-488e-b2f6-fc9eed1c7f70\1ba706c8-dc51-488e-b2f6-fc9eed1c7f70.log"
Import-Module AutomatedLab
New-LabDefinition -Name two -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name mynetwork -AddressSpace 192.168.1.1/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name dc -Memory 2GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName two.com -Processors 1 -IpAddress 192.168.1.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name s1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName two.com -Processors 1 -IpAddress 192.168.1.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name s2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles FileServer -DomainName two.com -Processors 1 -IpAddress 192.168.1.3 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName dc,s1,s2 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName dc,s1,s2 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
Show-LabDeploymentSummary -Detailed
$data = Import-Csv Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\1ba706c8-dc51-488e-b2f6-fc9eed1c7f70\status.txt; $data.Status = 'Completed';$data| Export-csv Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\1ba706c8-dc51-488e-b2f6-fc9eed1c7f70\status.txt
