Import-Module -Name Polaris
Add-Type -AssemblyName System.Web
# $Url = "http://localhost:8080/"

New-PolarisStaticRoute -RoutePath "css" -FolderPath "./src/css"

New-PolarisGetRoute -Path "/" -Scriptblock {
    $Response.SetContentType('text/html')
    $Html = Get-Content 'src/home.html' -Raw
    $Response.Send($Html)
} 
New-PolarisPostRoute -Path "/result"  -Scriptblock {

    $Response.SetContentType('text/html')
    $Body = [System.Web.HttpUtility]::UrlDecode($Request.BodyString)
    $Userinput = $Body.split('&') 
    $LabName = $UserInput -match "Labname=" -replace "Labname=",""
    $NetworkAddressSpace = $UserInput -match "NetworkAddressSpace=" -replace "NetworkAddressSpace=",""
    $SoftwareDeployment = $UserInput -match "SoftwareDeployment=" -replace "SoftwareDeployment=",""
    $SoftwareDeployServers = $UserInput -match "SoftwareDeployServers=" -replace "SoftwareDeployServers=",""
    $Software = @{SoftwareDeployServers =  $SoftwareDeployServers;SoftwareDeployment= $SoftwareDeployment }
    $Checkpoint = $UserInput -match "Checkpoint=" -replace "Checkpoint=",""
    $LabSources =  'D:\LabSources'

    $All = 1..9 | ForEach-Object{
        $Data = @{}
        $UserInput -match "$_=" | ForEach-Object {
            $Key, $Value = $_.split('=')
            $Key = $Key -replace '\d+', ''
            if($Data.ContainsKey($key)){ # input fields with multiple value will be captured as an array
                $Data[$Key] = [Array]($Data[$Key]) + $Value
            }
            else {
                $Data.add($Key, $Value)
            }
        }
    
        # condition to avoid empty JSON entries of input left blank in the form
        if($Data.count -gt 0){ 
            [PSCustomObject] $Data
        }
    }   
    $Obj = [PSCustomObject]@{
        TimeStamp = $([datetime]::Now.ToString('dd/MMMM/yyyy hh:mm:ss tt'))
        LabName = $LabName
        LabSources = $LabSources
        NetworkAddressSpace = $NetworkAddressSpace
        Checkpoint = $Checkpoint
        Request = $All
        Software = $Software
    }
    
    $GUID = [guid]::NewGuid().guid
    $JSON = $Obj | ConvertTo-Json
    mkdir ".\BuildRequest\$GUID"
    $JSON | Out-File $([System.IO.Path]::Combine('.\BuildRequest', $GUID,"$GUID.json"))
    $HTML = $obj.Request | Select-Object Name, Domain, OS, Memory, Processor, IP, AdminUser, @{n='Roles';e={$_.roles -join ', '}} | ConvertTo-Html -As Table -Fragment
    $Response.Send($HTML)
}

Start-Polaris -Port 8080

# While($true){
#     Start-Sleep -Seconds 9999
# }

# TODO Add input validation and mandatory\required fields
# TODO Implement translation service
# TODO Implement build status page
# TODO Implement Successful status page
# TODO Implement PowerShell Script Download function
# TODO Build type - new \ rebuild
# TODO post installation scripts
# TODO OS hashtable to convert small OS name to Exact OS name

# $a = "LabName=testlab&name1=sdcvdf&memory1=vfgdv&processor1=1&domain1=vfdv&os1=Windows+Server+2019+Essentials&roles1=None&ip1=fvdvdf&adminuser1=admivfdvdfvn&adminpass1=&name2=&memory2=&processor2=1&domain2=&os2=Windows+Server+2019+Essentials&roles2=None&ip2=&adminuser2=&adminpass2=&name3=&memory3=&processor3=1&domain3=&os3=Windows+Server+2019+Essentials&roles3=None&ip3=&adminuser3=&adminpass3="

# $UserInput = $a -split "&"
# $LabName = $UserInput -match "Labname=" -replace "Labname=",""