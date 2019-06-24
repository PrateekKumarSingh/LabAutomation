# Start-Transcript -Path .\Translator.log
. .\src\dependencies\Hashtables.ps1

$SleepMins =  0.5
While($true){
    Write-Host "`n[+] Waiting for new builds." -ForegroundColor Yellow
    $BuildScript = @()
    $ProcessedBuilds = Get-Content .\BuildRequest\Processed.txt -ErrorAction SilentlyContinue
    $Files = Get-ChildItem .\BuildRequest\ -Filter *.JSON -Recurse | Where-Object {$_.BaseName -notin $ProcessedBuilds}
    if($Files){
        Write-Host ("`n{0} new build requests found." -f $Files.count) -ForegroundColor Yellow
        Foreach($File in $Files){
            Add-Content .\BuildRequest\Processed.txt -Value $File.BaseName
            Write-Host "[+] Processing Build Request [$($File.BaseName)]" -ForegroundColor Green
            $BuildRequest = Get-Content $File.fullname| ConvertFrom-Json
            $BuildScript += "Import-Module AutomatedLab"
            $BuildScript += "Start-Transcript -Path `"$($File.FullName -replace 'json','log')`""
            $BuildScript += "New-LabDefinition -Name $($BuildRequest.Labname) -DefaultVirtualizationEngine HyperV  -VmPath D:\VHD\"
            $BuildScript += "Add-LabVirtualNetworkDefinition -Name Network1 -AddressSpace $($BuildRequest.NetworkAddressSpace)"
            Write-Host "   [+] Add lab virtual network definition [$($BuildRequest.NetworkAddressSpace)]" -ForegroundColor Green               
            Foreach($Item in $BuildRequest.Request){
                Write-Host "   [+] Adding lab machine defination for $($Item.Name)" -ForegroundColor Green
                $BuildScript += "`$installationCredential = New-Object PSCredential(`"$($Item.adminuser)`", (`"$($Item.adminpass)`" | ConvertTo-SecureString -AsPlainText -Force))"
                if($Item.Roles -like "*RootDC*"){
                    $BuildScript += "Add-LabMachineDefinition -Name {0} -Memory {1}GB -OperatingSystem `'{2}`' -Roles {3} -DomainName {4} -Processors {5} -IpAddress {6}" -f $Item.Name, $Item.Memory, $Item.OS, $($Item.Roles -replace "None ","" -split " " -join ", "), $Item.Domain, $Item.Processor, $Item.ip
                }
                else{
                    $BuildScript += "Add-LabMachineDefinition -Name {0} -Memory {1}GB -OperatingSystem `'{2}`' -Roles {3} -DomainName {4} -Processors {5} -IpAddress {6} -InstallationUserCredential `$installationCredential" -f $Item.Name, $Item.Memory, $Item.OS, $($Item.Roles -replace "None ","" -split " " -join ", "), $Item.Domain, $Item.Processor, $Item.ip
                }
            }
            $BuildScript += "Install-Lab"
            
            if($BuildRequest.Software.SoftwareDeployment -and $BuildRequest.Software.SoftwareDeployServers){
                Foreach($Software in $BuildRequest.Software.SoftwareDeployment){
                    $BuildScript += "Install-LabSoftwarePackage -ComputerName $($BuildRequest.Software.SoftwareDeployServers) -Path $($BuildRequest.LabSources)\SoftwarePackages\$($SoftwarePackageMapping[$Software]['package']) -CommandLine $($SoftwarePackageMapping[$Software]['Commandline']) -AsJob"
                    Write-Host "   [+] Adding post installation software deployment of $($SoftwarePackageMapping[$Software]['package'])" -ForegroundColor Green
                }
                $BuildScript += "Get-Job -Name 'Installation of*' | Wait-Job | Out-Null"
            }
            
            if($BuildRequest.Checkpoint){
                $BuildScript += "Checkpoint-LabVM -All -SnapshotName 1"
                Write-Host "   [+] Adding snapshot creation" -ForegroundColor Green
            }

            $BuildScriptFileName = $File.FullName -replace 'json','ps1'
            $BuildScript | Out-File $BuildScriptFileName
            Start-Process powershell.exe -ArgumentList $BuildScriptFileName
            # "Moving Build Request [$($File.BaseName)] to .\Processed\ Folder"
            # Move-Item $File.FullName .\Processed\
        }
    }
    Start-Sleep -Seconds (60*$SleepMins) -Verbose
}