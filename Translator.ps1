# Start-Transcript -Path .\Translator.log
. .\src\dependencies\Hashtables.ps1
$flag = $true
$SleepMins = 0.01
While ($true) {
    if($flag){
        Write-Host "`n[+] Waiting for new builds ." -ForegroundColor Yellow -NoNewline
        $flag = $false
    }
    else{
        Write-Host " ." -ForegroundColor Yellow -NoNewline
    }

    $BuildScript = @()
    $ProcessedBuilds = Get-Content .\BuildRequest\Processed.txt -ErrorAction SilentlyContinue
    $Files = Get-ChildItem .\BuildRequest\ -Filter *.JSON -Recurse | Where-Object { $_.BaseName -notin $ProcessedBuilds }
    
    if ($Files) {
        Write-Host ""
        Write-Host ("`n[+] {0} new build request(s) found." -f $Files.count) -ForegroundColor Magenta
        Foreach ($File in $Files) {
            $StatusFile = Join-Path $file.PSParentPath 'status.txt'
            'InProgress' | Out-File $StatusFile -Verbose
            Add-Content .\BuildRequest\Processed.txt -Value $File.BaseName
            Write-Host "`n[+] Processing Build Request [$($File.BaseName)]" -ForegroundColor Green
            $BuildRequest = Get-Content $File.fullname | ConvertFrom-Json
            $BuildScript += "`$ErrorActionPreference = 'Stop'"
            $BuildScript += "try{"
            $BuildScript += "`$Completed=`$false"
            $BuildScript += "Start-Transcript -Path `"$($File.FullName -replace 'json','log')`""
            $BuildScript += "Import-Module AutomatedLab"
            
            if($BuildRequest.Rebuild){
                Write-Host "   [-] Removing and rebuilding lab: $($BuildRequest.Labname)" -ForegroundColor Red
                $BuildScript += "if((Get-Lab -List) -eq `"$($BuildRequest.LabName)`"){"
                $BuildScript += "Import-Lab -Name $($BuildRequest.LabName) -ErrorAction SilentlyContinue"
                $BuildScript += "Remove-Lab -Name $($BuildRequest.LabName) -Confirm:`$false -ErrorAction SilentlyContinue" 
                $BuildScript += "}"
            }
            
            $BuildScript += "New-LabDefinition -Name $($BuildRequest.Labname) -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\"
            
            Write-Host "   [+] Add lab virtual network definition [$($BuildRequest.NetworkAddressSpace)]" -ForegroundColor Green               
            $BuildScript += "Add-LabVirtualNetworkDefinition -Name $($BuildRequest.NetworkName) -AddressSpace $($BuildRequest.NetworkAddressSpace)"
            
            Foreach ($Item in $BuildRequest.Request) {
                Write-Host "   [+] Adding lab machine defination for $($Item.Name)" -ForegroundColor Green
                $BuildScript += "`$installationCredential = New-Object PSCredential(`"$($Item.adminuser)`", (`"$($Item.adminpass)`" | ConvertTo-SecureString -AsPlainText -Force))"
                 
                if ($Item.Roles -like "*RootDC*") {
                    #$BuildScript += "Add-LabDomainDefinition -Name {0} -AdminUser {1} -AdminPassword {2}" -f $Item.Domain, $Item.adminuser, $Item.adminpass
                    #$BuildScript += "Set-LabInstallationCredential -User {0} -Password {1}" -f  $Item.adminuser, $Item.adminpass
                    $BuildScript += "Add-LabMachineDefinition -Name {0} -Memory {1}GB -OperatingSystem `'{2}`' -Roles {3} -DomainName {4} -Processors {5} -IpAddress {6}" -f $Item.Name, $Item.Memory, $OperatingSystemMapping[$Item.OS], $($Item.Roles -replace "None ", "" -split " " -join ", "), $Item.Domain, $Item.Processor, $Item.ip
                }
                elseif ($Item.Roles -like "*None*") {
                    $BuildScript += "Add-LabMachineDefinition -Name {0} -Memory {1}GB -OperatingSystem `'{2}`' -DomainName {3} -Processors {4} -IpAddress {5}" -f $Item.Name, $Item.Memory, $OperatingSystemMapping[$Item.OS], $Item.Domain, $Item.Processor, $Item.ip
                }
                else {
                    $BuildScript += "Add-LabMachineDefinition -Name {0} -Memory {1}GB -OperatingSystem `'{2}`' -Roles {3} -DomainName {4} -Processors {5} -IpAddress {6} -InstallationUserCredential `$installationCredential" -f $Item.Name, $Item.Memory, $OperatingSystemMapping[$Item.OS], $($Item.Roles -replace "None ", "" -split " " -join ", "), $Item.Domain, $Item.Processor, $Item.ip
                }
            }
            $BuildScript += "Install-Lab"
            
            if ($BuildRequest.Software.SoftwareDeployment -and $BuildRequest.Software.SoftwareDeployServers) {
                Foreach ($Software in $BuildRequest.Software.SoftwareDeployment) {
                    $BuildScript += "Install-LabSoftwarePackage -ComputerName $($BuildRequest.Software.SoftwareDeployServers) -Path $($BuildRequest.LabSources)\SoftwarePackages\$($SoftwarePackageMapping[$Software]['package']) -CommandLine $($SoftwarePackageMapping[$Software]['Commandline']) -AsJob"
                    Write-Host "   [+] Adding post installation software deployment of $($SoftwarePackageMapping[$Software]['package'])" -ForegroundColor Green
                }
                $BuildScript += "Get-Job -Name 'Installation of*' | Wait-Job | Out-Null"
            }

            $BuildScript += "Show-LabDeploymentSummary -Detailed"
            
            # take snapshots of the virtual machines
            if ($BuildRequest.Checkpoint) {
                $BuildScript += "Checkpoint-LabVM -All -SnapshotName 1"
                Write-Host "   [+] Adding snapshot creation" -ForegroundColor Green
            }
   
            $BuildScript += "`$Completed=`$true;'Completed'|Out-File $StatusFile"
            $BuildScript += "}"
            $BuildScript += "catch{"
            $BuildScript += "`$_.Exception;'Failed'|Out-File $StatusFile"
            $BuildScript += "}"
            $BuildScript += "finally{"
            $BuildScript += "if(-not `$Completed){'Failed'|Out-File $StatusFile}"
            $BuildScript += "}"

            $BuildScriptFileName = $File.FullName -replace 'json', 'ps1'
            $BuildScript | Out-File $BuildScriptFileName
            Start-Process powershell.exe -ArgumentList $BuildScriptFileName
        }
        $flag = $true
    }
    Start-Sleep -Seconds (60 * $SleepMins) -Verbose
}