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
"Get SSRS Configuration Details: SSRS Connection Timeout, SSRS Instance Name, Version, DB name, Webservice URL, Report Manager URL, Content Manager, Email Settings, Secure Connection,SSRS Database Files and sizes."

function GetParamValue($paramValue) {
    "funinside"
    if (($paramValue -eq 0)) {
        $paramValue = $false
    } else {
        $paramValue = $true
    }
    $paramValue
    "END"
    return $paramValue
}
function Get-SSRSConiguration {
    
    Param
    (
        [Parameter(Mandatory = $false)]
        $showssrsConnectionTimeout = $args[0],
        [Parameter(Mandatory = $false)]
        $showssrsInstanceName = $args[1],
        [Parameter(Mandatory = $false)]
        $showssrsVsSqlVersion = $args[2],
        [Parameter(Mandatory = $false)]
        $showWebPortalUrl = $args[3],
        [Parameter(Mandatory = $false)]
        $showcontentManagers = $args[4],
        [Parameter(Mandatory = $false)]
        $showreportManagerUrl = $args[5],
        [Parameter(Mandatory = $false)]
        $showSecureConnectionLevel = $args[6],
        [Parameter(Mandatory = $false)]
        $showSenderEmailAddress  = $args[7],
        [Parameter(Mandatory = $false)]
        $showexecAccount = $args[8],
        [Parameter(Mandatory = $false)]
        $showssrsDBmdfPath = $args[9],
        [Parameter(Mandatory = $false)]
        $showssrsDBmdfSize = $args[10],
        [Parameter(Mandatory = $false)]
        $showssrsDBldfSize = $args[11],
        [Parameter(Mandatory = $false)]
        $showssrsTempDBmdfSize = $args[12],
        [Parameter(Mandatory = $false)]
        $showssrsTempDBldfPath = $args[13],
        [Parameter(Mandatory = $false)]
        $showssrsTempDBldfSize = $args[14]
    )

    Begin {
        $output = ""
        $outputFolder = "./Output/SSRSConfiguration"
        $outputFile = "./SSRSConfiguration_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".csv"
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
        $folderName = "/"
        if (!$showssrsConnectionTimeout) {
            if (($showssrsConnectionTimeout -eq 0)) {
                $showssrsConnectionTimeout = $false
            } else {
                $showssrsConnectionTimeout = $true
            }
        }
        if (!$showssrsInstanceName) {
            if (($showssrsInstanceName -eq 0)) {
                $showssrsInstanceName = $false
            } else {
                $showssrsInstanceName = $true
            }
        }
        if (!$showssrsVsSqlVersion) {
            if (($showssrsVsSqlVersion -eq 0)) {
                $showssrsVsSqlVersion = $false
            } else {
                $showssrsVsSqlVersion = $true
            }
        }
        if (!$showWebPortalUrl) {
            if (($showWebPortalUrl -eq 0)) {
                $showWebPortalUrl = $false
            } else {
                $showWebPortalUrl = $true
            }
        }
        if (!$showcontentManagers) {
            if (($showcontentManagers -eq 0)) {
                $showcontentManagers = $false
            } else {
                $showcontentManagers = $true
            }
        }
        if (!$showreportManagerUrl) {
            if (($showreportManagerUrl -eq 0)) {
                $showreportManagerUrl = $false
            } else {
                $showreportManagerUrl = $true
            }
        }
        if (!$showSecureConnectionLevel) {
            if (($showSecureConnectionLevel -eq 0)) {
                $showSecureConnectionLevel = $false
            } else {
                $showSecureConnectionLevel = $true
            }
        }
        if (!$showSenderEmailAddress) {
            if (($showSenderEmailAddress -eq 0)) {
                $showSenderEmailAddress = $false
            } else {
                $showSenderEmailAddress = $true
            }
        }
        if (!$showexecAccount) {
            if (($showexecAccount -eq 0)) {
                $showexecAccount = $false
            } else {
                $showexecAccount = $true
            }
        }
        if (!$showssrsDBmdfPath) {
            if (($showssrsDBmdfPath -eq 0)) {
                $showssrsDBmdfPath = $false
            } else {
                $showssrsDBmdfPath = $true
            }
        }
        if (!$showssrsDBmdfSize) {
            if (($showssrsDBmdfSize -eq 0)) {
                $showssrsDBmdfSize = $false
            } else {
                $showssrsDBmdfSize = $true
            }
        }
        if (!$showssrsDBldfSize) {
            if (($showssrsDBldfSize -eq 0)) {
                $showssrsDBldfSize = $false
            } else {
                $showssrsDBldfSize = $true
            }
        }
        if (!$showssrsTempDBmdfSize) {
            if (($showssrsTempDBmdfSize -eq 0)) {
                $showssrsTempDBmdfSize = $false
            } else {
                $showssrsTempDBmdfSize = $true
            }
        }
        if (!$showssrsTempDBldfPath) {
            if (($showssrsTempDBldfPath -eq 0)) {
                $showssrsTempDBldfPath = $false
            } else {
                $showssrsTempDBldfPath = $true
            }
        }
        if (!$showssrsTempDBldfSize) {
            if (($showssrsTempDBldfSize -eq 0)) {
                $showssrsTempDBldfSize = $false
            } else {
                $showssrsTempDBldfSize = $true
            }
        }
    }
    Process {   
        
        $servername = $env:COMPUTERNAME
        $instanceName = "localhost"
        $erroFile = "./error_log/ssrsconfig_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        try {
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $serverVersion = $server.Information.VersionString
            $folder = $server.Information.MasterDBLogPath
           
            $ssrsConnectionTimeout = (Invoke-Sqlcmd -Query "SELECT Value FROM [ReportServer].[dbo].ConfigurationInfo where Name = 'SessionTimeout'" -User $user -Password $pass) | Select-Object -ExpandProperty Value
            if ($showssrsConnectionTimeout) {
                $output += "`n ssrsConnectionTimeout: $ssrsConnectionTimeout"
            }

            $serverVersion = (Invoke-Sqlcmd -Query "select version_major from msdb.dbo.msdb_version" -User $user -Password $pass) | Select-Object -ExpandProperty version_major
            $rs = (Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer  -class __Namespace) | Select-Object -ExpandProperty Name
            $nspace = "root\Microsoft\SQLServer\ReportServer\$rs\v$serverVersion\Admin"
            $RSServers = Get-WmiObject -Namespace $nspace -class MSReportServer_ConfigurationSetting -ComputerName $servername -ErrorVariable perror -ErrorAction SilentlyContinue
            #$WebPortalUrl
            foreach ($r in $RSServers) {
                $folder = $server.Information.MasterDBLogPath
    
                $ssrsInstanceName = $r.InstanceName
                if ($showssrsInstanceName) {
                    $output += "`n ssrsInstanceName: $ssrsInstanceName"
                }
                
                $ssrsVers = $r.version
                if ($showssrsVsSqlVersion) {
                    $output += "`n ssrsVers: $ssrsVers; SQL Version: $serverVersion"
                }
                $ssrsDB = $r.DatabaseName
                # $output += "`n ssrsDB: $ssrsDB"
                $vPath = $r.VirtualDirectoryReportServer
                $urls = $r.ListReservedUrls()
                $urls = $urls.UrlString[0]
                $WebPortalUrl = $urls.Replace('+', $servername) + "/$vPath"
                if ($showWebPortalUrl) {
                    $output += "`n WEB Service URL: $WebPortalUrl"
                }
                $ReportServerUri = $WebPortalUrl + "/ReportService2010.asmx"
                $InheritParent = $true
                #New Code - starts
                # $ReportServerUri
                # $rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
                # #List out all subfolders under the parent directory
                # $items = $rsProxy.ListChildren("/", $true)
                        
                # #Iterate through every folder 		 
                # $contentManagers = ""
                # "333"
                # $items
                # "444"
                # foreach($item in $items)
                # {
                #     $item
                #     $Policies = $rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
                #     foreach ($Policy in $Policies) {
                #         $Policy
                #         if ($Policy.Roles.Name -eq "Content Manager") {
                #             $contentManagers += $Policy.GroupUserName + ","
                #         }
                #     }
                # }
                #New code - ends

                $rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
                $items = $rsProxy.GetPolicies($folderName, [ref]$InheritParent)
                $contentManagers = ""
                foreach ($item in $items) {
                    if ($item.Roles.Name -eq "Content Manager") {
                        $contentManagers += $item.GroupUserName + ","
                    }
                }
                if ($showcontentManagers) {
                    $output += "`n Content Managers: $contentManagers"
                }
    
                if ($r.VirtualDirectoryReportManager -ne "") {
                    $reportManagerUrl = $urls.Replace('+', $servername) + "/" + $r.VirtualDirectoryReportManager
                }
                else {
                    $reportManagerUrl = $urls.Replace('+', $servername) + "/Reports"
                }
                if ($showreportManagerUrl) {
                    $output += "`n Report Manager URL: $reportManagerUrl"
                }
                $SecureConnectionLevel = $r.SecureConnectionLevel
                if ($showSecureConnectionLevel) {
                    $output += "`n Secure Connection Level: $SecureConnectionLevel"
                }
                $SenderEmailAddress = $r.SenderEmailAddress
                if ($showSenderEmailAddress) {
                    if ($SenderEmailAddress -ne "") {
                        $output += "`n E-Mail Setting: $SenderEmailAddress"
                    }
                    else {
                        $output += "`n E-Mail Setting: N/A"
                    }
                }
                if ($showexecAccount) {
                    $execAccount = $r.UnattendedExecutionAccount
                    if ($execAccount -ne "") {
                        $output += "`n Execution Account: $execAccount"
                    }
                    else {
                        $output += "`n SSRS Excution account is not configured"
                    }
                }
                $ssrsDBmdfPath = $folder + "\" + $ssrsDB + ".mdf"
                if ($showssrsDBmdfPath) {
                    $output += "`n ssrsDBmdfPath: $ssrsDBmdfPath"
                }
                $ssrsDBmdfSize = (Get-Item $ssrsDBmdfPath).length / 1MB
                if ($showssrsDBmdfSize) {
                    $output += "`n ssrsDBmdfSize: $ssrsDBmdfSize" + " MB"
                }
                $ssrsDBldfPath = $folder + "\" + $ssrsDB + "_log.ldf"
                if ($showssrsDBldfPath) {
                    $output += "`n ssrsDBldfPath: $ssrsDBldfPath"
                }
                $ssrsDBldfSize = (Get-Item $ssrsDBldfPath).length / 1MB
                if ($showssrsDBldfSize) {
                    $output += "`n ssrsDBldfSize: $ssrsDBldfSize" + " MB"
                }
                $ssrsTempDBmdfPath = $folder + "\" + $ssrsDB + "TempDB.mdf"
                if ($showssrsTempDBmdfPath) {
                    $output += "`n ssrsTempDBldfPath: $ssrsTempDBmdfPath"
                }
                $ssrsTempDBmdfSize = (Get-Item $ssrsTempDBmdfPath).length / 1MB
                if ($showssrsTempDBmdfSize) {
                    $output += "`n ssrsTempDBmdfSize: $ssrsTempDBmdfSize" + " MB"
                }
                $ssrsTempDBldfPath = $folder + "\" + $ssrsDB + "TempDB_log.ldf"
                if ($showssrsTempDBldfPath) {
                    $output += "`n ssrsTempDBldfPath: $ssrsTempDBldfPath"
                }
                $ssrsTempDBldfSize = (Get-Item $ssrsTempDBldfPath).length / 1MB
                if ($showssrsTempDBldfSize) {
                    $output += "`n ssrsTempDBldfSize: $ssrsTempDBldfSize" + " MB"
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
        $output | Out-File -Append $filePath -Encoding UTF8
        Write-Host "Check the output at File "  $filePath -ForegroundColor Yellow
        return $output | Format-List
    }
}

Get-SSRSConiguration