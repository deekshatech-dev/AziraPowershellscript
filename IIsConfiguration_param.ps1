<#
.Synopsis
   Powershell tool for GUI way for getting CPU, Memory and Disk of a machine
.DESCRIPTION
   The tool will ask for file(containing servers name) and folder(where the output will be saved as ServerrInventory.csv.
.EXAMPLE
   It is tool, and has forms and buttons to help you.
.NOTES    
    Author: Prashant kankhara
    Email : prashantkankhara@gmail.com
    Version: 0.1 
    DateCreated: 14th Oct 2020
#>
"IIS Configuration Details: Installed IIS Features count & List, IIS Connection Timeout,  .NET framework details, Compression strategies status, etc."

function Get-IIsConfiguration {
    
    Param
    (
        [Parameter(Mandatory=$false)]
        $showWindowsVersion = $args[0],

        [Parameter(Mandatory=$false)]
        $showIISVersion = $args[1],

        [Parameter(Mandatory=$false)]
        $showHostName = $args[2],

        [Parameter(Mandatory=$false)]
        $showDotNet35Status = $args[3],

        [Parameter(Mandatory=$false)]
        $showDotNet45Status = $args[4],

        [Parameter(Mandatory=$false)]
        $showWebCoreStatus = $args[5],

        [Parameter(Mandatory=$false)]
        $showWindowsProcessActivationService = $args[6],

        [Parameter(Mandatory=$false)]
        $showSSLCertificate = $args[7],

        [Parameter(Mandatory=$false)]
        $showCompressionSettingApplicationStaticTypes = $args[8],

        [Parameter(Mandatory=$false)]
        $showCompressionSettingApplicationDynamicTypes = $args[9],

        [Parameter(Mandatory=$false)]
        $showCompressionSettingImageStaticTypes = $args[10],

        [Parameter(Mandatory=$false)]
        $showCompressionSettingImageDynamicTypes = $args[11]
    )

    Begin {
        $output = ""
        $totalspace = 0
        $outputFolder = "./Output/IISConfiguration"
        $outputFile = "/IISConfiguration_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".csv"
        If (!(Test-Path $outputFolder)) {
            New-Item -Path $outputFolder -ItemType Directory
        }
        If (!(Test-Path "./error_log")) {
            New-Item -Path "./error_log" -ItemType Directory
        }
        try {
            Import-Module SqlServer 
            #           Import-Module SQLPS 
            Import-Module dbatools 
        }
        catch {
            "Installing Prerequistic....Please wait"
            Install-Module dbatools -AllowClobber
            Install-Module SqlServer -AllowClobber
            Import-Module SqlServer 
            #            Import-Module SQLPS 
            Import-Module dbatools 

        }
        if (!$showWindowsVersion) {
            if (($showWindowsVersion -eq 0)) {
                $showWindowsVersion = $false
            } else {
                $showWindowsVersion = $true
            }
        }
        if (!$showIISVersion) {
            if (($showIISVersion -eq 0)) {
                $showIISVersion = $false
            } else {
                $showIISVersion = $true
            }
        }
        if (!$showHostName) {
            if (($showHostName -eq 0)) {
                $showHostName = $false
            } else {
                $showHostName = $true
            }
        }
        if (!$showDotNet35Status) {
            if (($showDotNet35Status -eq 0)) {
                $showDotNet35Status = $false
            } else {
                $showDotNet35Status = $true
            }
        }
        if (!$showDotNet45Status) {
            if (($showDotNet45Status -eq 0)) {
                $showDotNet45Status = $false
            } else {
                $showDotNet45Status = $true
            }
        }
        if (!$showWebCoreStatus) {
            if (($showWebCoreStatus -eq 0)) {
                $showWebCoreStatus = $false
            } else {
                $showWebCoreStatus = $true
            }
        }
        if (!$showWindowsProcessActivationService) {
            if (($showWindowsProcessActivationService -eq 0)) {
                $showWindowsProcessActivationService = $false
            } else {
                $showWindowsProcessActivationService = $true
            }
        }
        if (!$showSSLCertificate) {
            if (($showSSLCertificate -eq 0)) {
                $showSSLCertificate = $false
            } else {
                $showSSLCertificate = $true
            }
        }
        if (!$showCompressionSettingApplicationStaticTypes) {
            if (($showCompressionSettingApplicationStaticTypes -eq 0)) {
                $showCompressionSettingApplicationStaticTypes = $false
            } else {
                $showCompressionSettingApplicationStaticTypes = $true
            }
        }
        if (!$showCompressionSettingApplicationDynamicTypes) {
            if (($showCompressionSettingApplicationDynamicTypes -eq 0)) {
                $showCompressionSettingApplicationDynamicTypes = $false
            } else {
                $showCompressionSettingApplicationDynamicTypes = $true
            }
        }
        if (!$showCompressionSettingImageStaticTypes) {
            if (($showCompressionSettingImageStaticTypes -eq 0)) {
                $showCompressionSettingImageStaticTypes = $false
            } else {
                $showCompressionSettingImageStaticTypes = $true
            }
        }
        if (!$showCompressionSettingImageDynamicTypes) {
            if (($showCompressionSettingImageDynamicTypes -eq 0)) {
                $showCompressionSettingImageDynamicTypes = $false
            } else {
                $showCompressionSettingImageDynamicTypes = $true
            }
        }
    }
    Process {   
        $server_name = $env:COMPUTERNAME
        $erroFile = "./error_log/iisconfig_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        try {
            if ($ShowWindowsVersion) {
                $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
                $output += "`nWindows Version:" + $WindowsVersion
                $ourObject | Add-Member -MemberType NoteProperty -Name "Windows Version" -Value $WindowsVersion
            }

            if ($ShowIISVersion) {
                $iisversion = (get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring,versionstring ).versionstring
                $output += "`nIIS Version:" + $iisversion
                $ourObject | Add-Member -MemberType NoteProperty -Name "IIS Version" -Value $iisversion
            }

            if ($ShowIISFeature) {
                $features = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') -AND ($_.State -eq 'Enabled') };
                $featuresList = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') -AND ($_.State -eq 'Enabled') } | Select -Property FeatureName; 
                $FTPfeatures = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-FTP*') -AND ($_.State -eq "Enabled") };
                $totalfeatures = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') };
                $runningWebservices = ($features.Length - $FTPfeatures.Length).ToString() + " of " + ($totalfeatures.Length).ToString() + " Installed"
                $output += "`n Web Server IIS Role and Sub Features except FTP: $runningWebservices"
                $ourObject | Add-Member -MemberType NoteProperty -Name "Web Server IIS Role and Sub Features except FTP" -Value $runningWebservices
                $output += "`n =============================="
                $output += "`n Feature List"
                $output += "`n =============================="
                $featureNames = ''
                foreach ($item in $featuresList) {
                    $featureName = $item.FeatureName
                    $tempObj = Get-WindowsOptionalFeature -online -FeatureName $item.FeatureName
                    $displayName = $tempObj.DisplayName
                    $description = $tempObj.Description
                    $state = $tempObj.State
                    if ($tempObj.CustomProperties.count -gt 0) {
                        $customProperties = $tempObj.CustomProperties
                    }
                    else {
                        $customProperties = "N/A"
                    }
                    $tempName = "`n ==========================================="
                    $tempName += "`n $featureName Description:"
                    $tempName += "`n ==========================================="
                    $tempName += "`n Feature Name: $featureName"
                    $tempName += "`n Display Name: $displayName"
                    $tempName += "`n State: $state"
                    $tempName += "`n Description: $description"
                    $tempName += "`n Custom Property: $customProperties"
                    $tempName += "`n ==========================================="
                    $featureNames += "`n $tempName"
                }
                
                $output += "`n $featureNames"
                $output += "`n `n =============================="

                $pspath = "MACHINE/WEBROOT/APPHOST"
                $filter = "system.applicationHost/sites/siteDefaults/limits"
                $name = "connectionTimeout"
                $timeoutObj = Get-WebConfigurationProperty -name $name -filter $filter -pspath $pspath 
                $timeout = $timeoutObj.Value.TotalSeconds
                $output += "`n IIS Connection Timeout: $timeout"
                $ourObject | Add-Member -MemberType NoteProperty -Name "IIS Connection Timeout" -Value $timeout
                
                $IisSites = Get-IISSite | Select -Property Name
                $output += "`n ==========================================="
                $output += "`n IIS Hosted Websites:"
                $output += "`n ==========================================="
                $index = 0
                foreach ($item in $IisSites) {
                    $websiteName = $item.Name
                    $output += "`n $websiteName"
                    $index = $index + 1
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Websites " + $index -Value $websiteName
                }
                $output += "`n ==========================================="
                
                # $FTPfeatures = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-FTP*') -AND ($_.State -eq "Enabled") };
                # $totalfeatures = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') };
                # $runningWebservices = ($features.Length - $FTPfeatures.Length).ToString() + " of " + ($totalfeatures.Length).ToString() + " Installed"
                # $output += "`n Web Server IIS Role and Sub Features except FTP: $runningWebservices"
            }

            if ($ShowDotNet35Status) {
                $dotNet35 = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "NETFx3") } | select -Property State
                if ($dotNet35.State -like "Enabled") {
                    $output += "`n .NET Framework 3.5 including all sub-features are INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name ".NET Framework 3.5" -Value ".NET Framework 3.5 including all sub-features are INSTALLED"
                }
                else {
                    $output += "`n .NET Framework 3.5 including all sub-features are NOT INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name ".NET Framework 3.5" -Value ".NET Framework 3.5 including all sub-features are NOT INSTALLED"
                }
            }

            if ($ShowDotNet45Status) {
                $dotNet45 = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "NetFx4-*") } | select -Property State
                if ($dotNet45.State -like "Enabled") {
                    $output += "`n .NET Framework 4.5 including all sub-features are INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name ".NET Framework 4.5" -Value ".NET Framework 4.5 including all sub-features are INSTALLED"
                }
                else {
                    $output += "`n .NET Framework 4.5 including all sub-features are NOT INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name ".NET Framework 4.5" -Value ".NET Framework 4.5 including all sub-features are NOT INSTALLED"
                }
            }
            
            if ($ShowWindowsProcessActivationService) {
                $windowsProcessActivationService = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "WAS-WindowsActivationService") } | select -Property State
                if ($windowsProcessActivationService.State -like "Enabled") {
                    $output += "`n Windows Process Activation Service is INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Windows Activation Service" -Value "Windows Process Activation Service is INSTALLED"
                }
                else {
                    $output += "`n Windows Process Activation Service is NOT INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Windows Activation Service" -Value "Windows Process Activation Service is NOT INSTALLED"
                }
            }

            if ($ShowWebCoreStatus) {
                $windowsHostableWebCore = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "Web-WHC") }
                if ($windowsHostableWebCore.State -like "Enabled") {
                    $output += "`n Hostable Web Core is INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Hostable Web Core" -Value "Hostable Web Core is INSTALLED"
                }
                else {
                    $output += "`n Hostable Web Core is NOT INSTALLED"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Hostable Web Core" -Value "Hostable Web Core is NOT INSTALLED"
                }
            }

            if ($ShowCompressionSettingApplicationDynamicTypes) {
                if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "dynamicTypes").Collection  | Where-Object { $_.mimeType -eq 'application/json' }).Length -eq 1) {
                    $output += "`n Value - Application/json configured in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting Application DyanamicType" -Value "Value - Application/json configured in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                }
                else {
                    $output += "`n Value - Application/json - is not found in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting Application DyanamicType" -Value "Value - Application/json is not found in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                }
            }

            if ($ShowCompressionSettingImageDynamicTypes) {
                if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "dynamicTypes").Collection  | Where-Object { $_.mimeType -eq 'image/svg+xml' }).Length -eq 1) {
                    $output += "`n Value - image/svg+xml configured in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting SVGXML DyanamicType" -Value "Value - image/svg+xml configured in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                }
                else {
                    $output += "`n Value - image/svg+xml - is not found in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting SVGXML DyanamicType" -Value "Value - image/svg+xml - is not found in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
                }
            }

            if ($ShowCompressionSettingApplicationStaticTypes) {
                if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "staticTypes").Collection  | Where-Object { $_.mimeType -eq 'application/json' }).Length -eq 1) {
                    $output += "`n Value - Application/json  already configured in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting Application StaticType" -Value "Value - Application/json already configured in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                }
                else {
                    $output += "`n Value - Application/json - is not found in IIS Configuration Editor->System.WebServer/httpCompression/staticType"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting Application StaticType" -Value "Value - Application/json is not found in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                }
            }

            if ($ShowCompressionSettingImageStaticTypes) {
                if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "staticTypes").Collection  | Where-Object { $_.mimeType -eq 'image/svg+xml' }).Length -eq 1) {
                    $output += "`n Value - image/svg+xml configured in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting SVGXML DyanamicType" -Value "Value - image/svg+xml configured in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                }
                else {
                    $output += "`n Value - image/svg+xml - is not found in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                    $ourObject | Add-Member -MemberType NoteProperty -Name "Compression Setting SVGXML DyanamicType" -Value "Value - image/svg+xml - is not found in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
                }
            }
        }
        catch {
            $err = $_
            $ErrorStackTrace = $_.ScriptStackTrace 
            $ErrorBlock = ($err).ToString() + "`n`nStackTrace: " + ($ErrorStackTrace).ToString()
            Set-Content -Path $erroFile -Value $ErrorBlock
            "Some error occured check " + $erroFile + " for stacktrace"
        }
    }
    End {
        $filePath = $outputFolder + "/" + $outputFile
        $ourObject | Out-File -Append $filePath -Encoding UTF8
        Write-Host "Check the output at File "  $filePath -ForegroundColor Yellow
        return $ourObject
        #return $output | Format-List
    }
}

Get-IIsConfiguration