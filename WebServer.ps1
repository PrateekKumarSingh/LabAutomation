Using module Polaris
Import-Module -Name Polaris
Add-Type -AssemblyName System.Web
$Url = "http://localhost:8080"

New-PolarisStaticRoute -RoutePath "css/" -FolderPath "./src/css"
New-PolarisStaticRoute -RoutePath "build/" -FolderPath "./BuildRequest"

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
    $NetworkName = $UserInput -match "NetworkName=" -replace "NetworkName=",""
    $NetworkAddressSpace = $UserInput -match "NetworkAddressSpace=" -replace "NetworkAddressSpace=",""
    $vEngine = $UserInput -match "vEngine=" -replace "vEngine=",""
    $Rebuild = $UserInput -match "Rebuild=" -replace "Rebuild=",""
    $BuildNotify = $UserInput -match "BuildNotify=" -replace "BuildNotify=",""
    $BuildValidate = $UserInput -match "BuildValidate=" -replace "BuildValidate=",""
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
        NetworkName = $NetworkName
        NetworkAddressSpace = $NetworkAddressSpace
        Checkpoint = $Checkpoint
        vEngine = $vEngine
        Rebuild = $Rebuild
        BuildNotify = $BuildNotify
        BuildValidate = $BuildValidate
        Request = $All
        Software = $Software
    }
    
    $GUID = [guid]::NewGuid().guid
    $JSON = $Obj | ConvertTo-Json
    mkdir ".\BuildRequest\$GUID"
    $JSON | Out-File $([System.IO.Path]::Combine('.\BuildRequest', $GUID,"$GUID.json"))
    $HTML = @()
    $HTML += @"
    <!DOCTYPE html>
    <html lang="en-US">
    
    <head>
        <title>Build Sheet</title>
        <link rel="stylesheet" type="text/css" href="css/style.css">
        <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="css/radio.css">
    </head>
    <body>
        <center>

        <br>
        <br>
        <ol class="breadcrumb">
  <li class="breadcrumb-item"><a href="http://localhost:8080">Home</a></li>
  <li class="breadcrumb-item active">Result</li>
  <li class="breadcrumb-item active"><a href="http://localhost:8080/build/">Build File Server</a></li>
</ol>

    <div class="card border-success mb-3" style="max-width: 20rem;">
    <div class="card-header"><h5>STATUS</h5></div>
    <div class="card-body">
      <h4 class="card-title">Successfully submitted the build request!</h4>
      <br>
      <p class="card-text">    <h5>Access the logs and deployment script: 
      <a href=`"$Url/build/$GUID/`">$Url/build/$GUID/</a></h5></p>
    </div>
  </div>
"@

    # $HTML += "<br><br><h3 style='font-weight:bold'>Click the following URL to access the logs and deployment script<br><a href=`"$Url/build/$GUID/`">$Url/build/$GUID/</a></h3>"
    $HTML += @"
    </center>
</body>
</html>    
"@    
    $Response.Send($HTML)
}

$Polaris = Start-Polaris -Port 8080
Write-Host "`n[+] Web server listening on : http://localhost:$($Polaris.Port)" -ForegroundColor Yellow
Get-PolarisRoute |Select-Object Path, Method | Sort-Object

# TODO Add input validation and mandatory\required fields
# TODO Implement translation service
# TODO Implement build status page
# TODO Implement Successful status page
# TODO Implement PowerShell Script Download function
# TODO Build type - new \ rebuild
# TODO post installation scripts
# TODO OS hashtable to convert small OS name to Exact OS name