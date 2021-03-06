Start-Transcript -Force -Path "D:\Workspace\LabAutomation\BuildRequest\2f3814b9-04c0-49a3-80fe-1e94482e38b4\2f3814b9-04c0-49a3-80fe-1e94482e38b4.log"
Import-Module AutomatedLab
if((Get-Lab -List) -eq "mylab"){
Import-Lab -Name mylab -ErrorAction SilentlyContinue
Remove-Lab -Name mylab -Confirm:$false -ErrorAction SilentlyContinue
}
New-LabDefinition -Name mylab -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\
Add-LabVirtualNetworkDefinition -Name mylab01 -AddressSpace 10.2.2.0/24
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name mylabdc1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles RootDC -DomainName mylab01.com -Processors 1 -IpAddress 10.2.2.1
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name mylabcl1 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles WebServer -DomainName mylab01.com -Processors 1 -IpAddress 10.2.2.2 -InstallationUserCredential $installationCredential
$installationCredential = New-Object PSCredential("admin", ("admin" | ConvertTo-SecureString -AsPlainText -Force))
Add-LabMachineDefinition -Name mylabcl2 -Memory 1GB -OperatingSystem 'Windows Server 2016 Standard (Desktop Experience)' -Roles FileServer -DomainName mylab01.com -Processors 1 -IpAddress 10.2.2.3 -InstallationUserCredential $installationCredential
Install-Lab
Install-LabSoftwarePackage -ComputerName mylabdc1, mylabcl1 -Path D:\LabSources\SoftwarePackages\Notepad++.exe -CommandLine /S -AsJob
Install-LabSoftwarePackage -ComputerName mylabdc1, mylabcl1 -Path D:\LabSources\SoftwarePackages\winrar.exe -CommandLine /S -AsJob
Get-Job -Name 'Installation of*' | Wait-Job | Out-Null
Checkpoint-LabVM -All -SnapshotName 1
Show-LabDeploymentSummary -Detailed
