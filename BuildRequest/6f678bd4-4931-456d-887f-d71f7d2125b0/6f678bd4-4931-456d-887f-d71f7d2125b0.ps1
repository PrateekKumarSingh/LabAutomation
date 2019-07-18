$Completed=$false
Start-Transcript -Path "D:\Workspace\LabAutomation\BuildRequest\6f678bd4-4931-456d-887f-d71f7d2125b0\6f678bd4-4931-456d-887f-d71f7d2125b0.log"
Import-Module AutomatedLab
if((Get-Lab -List) -eq "one"){
Import-Lab -Name one -ErrorAction SilentlyContinue
Remove-Lab -Name one -Confirm:$false -ErrorAction SilentlyContinue
}
New-LabDefinition -Name one -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name vnet1 -AddressSpace 10.0.0.0/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name s2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName one.com -Processors 1 -IpAddress 10.0.0.3
Install-Lab
Install-LabSoftwarePackage -ComputerName s2 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName s2 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
Show-LabDeploymentSummary -Detailed
$data = Import-Csv Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\6f678bd4-4931-456d-887f-d71f7d2125b0\status.txt; $data.Status = 'Completed';$data| Export-csv Microsoft.PowerShell.Core\FileSystem::D:\Workspace\LabAutomation\BuildRequest\6f678bd4-4931-456d-887f-d71f7d2125b0\status.txt
