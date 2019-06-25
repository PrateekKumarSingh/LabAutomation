
$SoftwarePackageMapping = @{
    'Notepad++' = @{ package = 'Notepad++.exe'; CommandLine = '/S'}
    'winrar' = @{ package = 'winrar.exe'; CommandLine = '/S'}
}    

$OperatingSystemMapping = @{
    'Windows Server 2016 Standard' = 'Windows Server 2016 Standard (Desktop Experience)'
    'Windows Server 2016 Datacenter' = 'Windows Server 2016 Datacenter (Desktop Experience)'
}