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

function Get-IIsConfiguration {
    
    Param
    (
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
    )

    Begin {
        $output = ""
        $totalspace = 0
        # Import-Module WebAdministration
    }
    Process {   
        $server_name = $env:COMPUTERNAME
        $erroFile = "./error_log/iisconfig_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        try {
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            $output += "`nWindows Version:" + $WindowsVersion
            $iisversion = (get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring, versionstring ).versionstring
            $output += "`nIIS Version:" + $iisversion
            $features = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') -AND ($_.State -eq 'Enabled') };
            $featuresList = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') -AND ($_.State -eq 'Enabled') } | Select -Property FeatureName; 
            $FTPfeatures = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-FTP*') -AND ($_.State -eq "Enabled") };
            $totalfeatures = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like 'IIS-*') };
            $runningWebservices = ($features.Length - $FTPfeatures.Length).ToString() + " of " + ($totalfeatures.Length).ToString() + " Installed"
            $output += "`n Web Server IIS Role and Sub Features except FTP: $runningWebservices"
            $output += "`n =============================="
            $output += "`n Feature List"
            $output += "`n =============================="
            $featureNames = ''
            $featureDetails = ''
            foreach ($item in $featuresList) {
                # $tempObj = New-Object -TypeName psobject

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
            
            $IisSites = Get-IISSite | Select -Property Name
            $output += "`n IIS Hosted Websites: $IisSites"
            
            $dotNet35 = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "NETFx3") } | select -Property State
            if ($dotNet35.State -like "Enabled") {
                $output += "`n .NET Framework 3.5 including all sub-features are INSTALLED"
            }
            else {
                $output += "`n .NET Framework 3.5 including all sub-features are NOT INSTALLED"
            }

            $dotNet45 = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "NetFx4-*") } | select -Property State
            if ($dotNet45.State -like "Enabled") {
                $output += "`n .NET Framework 4.5 including all sub-features are INSTALLED"
            }
            else {
                $output += "`n .NET Framework 4.5 including all sub-features are NOT INSTALLED"
            }

            $windowsProcessActivationService = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "WAS-WindowsActivationService") } | select -Property State
            if ($windowsProcessActivationService.State -like "Enabled") {
                $output += "`n Windows Process Activation Service is INSTALLED"
            }
            else {
                $output += "`n Windows Process Activation Service is NOT INSTALLED"
            }
            $windowsHostableWebCore = Get-WindowsOptionalFeature -Online | Where-Object { ($_.FeatureName -like "Web-WHC") }
            if ($windowsHostableWebCore.State -like "Enabled") {
                $output += "`n Hostable Web Core is INSTALLED"
            }
            else {
                $output += "`n Hostable Web Core is NOT INSTALLED"
            }

            if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "dynamicTypes").Collection  | Where-Object { $_.mimeType -eq 'application/json' }).Length -eq 1) {
                $output += "`n Value - Application/json configured in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
            }
            else {
                $output += "`n Value - Application/json - is not found in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
            }

            if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "dynamicTypes").Collection  | Where-Object { $_.mimeType -eq 'image/svg+xml' }).Length -eq 1) {
                $output += "`n Value - image/svg+xml configured in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
            }
            else {
                $output += "`n Value - image/svg+xml - is not found in IIS Configuration Editor->System.WebServer/httpCompression/dynamicTypes"
            }

            if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "staticTypes").Collection  | Where-Object { $_.mimeType -eq 'application/json' }).Length -eq 1) {
                $output += "`n Value - Application/json  already configured in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
            }
            else {
                $output += "`n Value - Application/json - is not found in IIS Configuration Editor->System.WebServer/httpCompression/staticType"
            }

            if (((Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/httpCompression" -Name "staticTypes").Collection  | Where-Object { $_.mimeType -eq 'image/svg+xml' }).Length -eq 1) {
                $output += "`n Value - image/svg+xml configured in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
            }
            else {
                $output += "`n Value - image/svg+xml - is not found in IIS Configuration Editor->System.WebServer/httpCompression/staticTypes"
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
        return $output | Format-List
    }
}

Get-IIsConfiguration