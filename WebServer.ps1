Using module Polaris
Import-Module -Name Polaris, PSHTML
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
    $LabName = $UserInput -match "Labname=" -replace "Labname=", ""
    $NetworkName = $UserInput -match "NetworkName=" -replace "NetworkName=", ""
    $NetworkAddressSpace = $UserInput -match "NetworkAddressSpace=" -replace "NetworkAddressSpace=", ""
    $vEngine = $UserInput -match "vEngine=" -replace "vEngine=", ""
    $Rebuild = $UserInput -match "Rebuild=" -replace "Rebuild=", ""
    $BuildNotify = $UserInput -match "BuildNotify=" -replace "BuildNotify=", ""
    $BuildValidate = $UserInput -match "BuildValidate=" -replace "BuildValidate=", ""
    $SoftwareDeployment = $UserInput -match "SoftwareDeployment=" -replace "SoftwareDeployment=", ""
    $SoftwareDeployServers = $UserInput -match "SoftwareDeployServers=" -replace "SoftwareDeployServers=", ""
    $Software = @{SoftwareDeployServers = $SoftwareDeployServers; SoftwareDeployment = $SoftwareDeployment }
    $Checkpoint = $UserInput -match "Checkpoint=" -replace "Checkpoint=", ""
    $LabSources = 'D:\LabSources'

    $All = 1..9 | ForEach-Object {
        $Data = @{ }
        $UserInput -match "$_=" | ForEach-Object {
            $Key, $Value = $_.split('=')
            $Key = $Key -replace '\d+', ''
            if ($Data.ContainsKey($key)) {
                # input fields with multiple value will be captured as an array
                $Data[$Key] = [Array]($Data[$Key]) + $Value
            }
            else {
                $Data.add($Key, $Value)
            }
        }
    
        # condition to avoid empty JSON entries of input left blank in the form
        if ($Data.count -gt 0) { 
            [PSCustomObject] $Data
        }
    }   
    $Obj = [PSCustomObject]@{
        TimeStamp           = $([datetime]::Now.ToString('dd/MMMM/yyyy hh:mm:ss tt'))
        LabName             = $LabName
        LabSources          = $LabSources
        NetworkName         = $NetworkName
        NetworkAddressSpace = $NetworkAddressSpace
        Checkpoint          = $Checkpoint
        vEngine             = $vEngine
        Rebuild             = $Rebuild
        BuildNotify         = $BuildNotify
        BuildValidate       = $BuildValidate
        Request             = $All
        Software            = $Software
    }
    
    $GUID = [guid]::NewGuid().guid
    $JSON = $Obj | ConvertTo-Json
    mkdir ".\BuildRequest\$GUID"
    $JSON | Out-File $([System.IO.Path]::Combine('.\BuildRequest', $GUID, "$GUID.json"))
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

New-PolarisGetRoute -Path "/status" -Scriptblock {
    $HTML = html {
        head {
            Title "Build Status"
            link -rel "stylesheet" -type "text/css" -href "css/style.css"
            link -rel "stylesheet" -type "text/css" -href "css/bootstrap.min.css"
            meta -httpequiv "refresh" -content "10"
        }
        body {
            br
            ol -class "breadcrumb" -Content {
                li -Class "breadcrumb-item" -Content {
                    a -href "http://localhost:8080" -Content { 'Home' }
                }
                li -Class "breadcrumb-item" -Content {
                    a -href "http://localhost:8080/build/" -Content { 'Build File Server' }
                }
                li -Class "breadcrumb-item" -Content {
                    a -href "http://localhost:8080/status" -Content { 'Build Status' }
                }
            }  
            
            div -style "width:800px; margin:0 auto;" -Content {
                Table {
                    tr -Content {
                        Th -Content "TimeStamp" -class "table-warning dashedBorder" -Style "text-align: center; font-size: 16px; color: black; max-width: 150px"
                        Th -Content "Build-ID" -class "table-warning dashedBorder" -Style "text-align: center; font-size: 16px; color: black; min-width: 380px"
                        Th -Content "Status" -class "table-warning dashedBorder" -Style "text-align: center; font-size: 16px; color: black"
                    }
                    tr -Content {

                        $files = Get-ChildItem .\BuildRequest\ -Filter 'status.txt' -Recurse | sort-object creationtime
                        foreach ($file in $files) {
                            $Status = Get-Content $file.FullName
                            $ParentFolder = $file.PSParentPath
                            $GUID = $ParentFolder -split "\\" | Select-Object -Last 1
                        
                            tr -Content {
                                td -Content {
                                    $CreationTime = Get-ChildItem (Join-Path $ParentFolder "$GUID.json") | ForEach-Object CreationTime
                                    $CreationTime.tostring('dd-MMM-yyyy hh:mm:ss tt')
                                } -Class "dashedborder"
                                td -Content {
                                    a -href "$Url/build/$GUID/" -Content { $GUID }
                                } -Class "dashedborder"
                                if ($Status -eq "InProgress") {
                                    td -Content {
                                        $Status
                                    } -Style "background-color:YELLOW" -Class "dashedborder"
                                }
                                elseif ($Status -eq "Failed") {
                                    td -Content {
                                        $Status
                                    } -Style "background-color:RED" -Class "dashedborder"
                                }
                                elseif ($Status -eq "Completed") {
                                    td -Content {
                                        $Status
                                    } -Style "background-color:GREEN" -Class "dashedborder"
                                }
                                else {
                                    td -Content {
                                        $Status
                                    } -Style "background-color:Gray" -Class "dashedborder"

                                }
                            }
                        }
                    } -Id "customers" -Attributes @{"border" = "1" }
                } -Style "text-align: center; font-size: 14px; color:black" -Class "searchable sortable"
            }
        }
    }
    $Response.SetContentType('text/html')
    $Response.Send($HTML)
}


$Polaris = Start-Polaris -Port 8080
Write-Host "`n[+] Web server listening on : http://localhost:$($Polaris.Port)" -ForegroundColor Yellow
Get-PolarisRoute | Select-Object Path, Method | Sort-Object

# TODO Add input validation and mandatory\required fields
# DONE Implement translation service
# TODO Implement build status page
# DONE Implement Successful status page
# TODO Implement PowerShell Script Download function
# DONE Build type - new \ rebuild
# TODO post installation scripts
# DONE OS hashtable to convert small OS name to Exact OS name