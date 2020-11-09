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

function Get-SSRSConiguration {
    
    Param
    (
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
    )

    Begin {
        $output = ""
        $v = 14
        $folderName = "/MyReportFolder"

        # Import-Module SQLPS
    }
    Process {   
        
        
        $servername = $env:COMPUTERNAME
        $instanceName = "localhost"
        $erroFile = "./error_log/ssrsconfig_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        try {
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $serverVersion = $server.Information.VersionString
            $folder = $server.Information.MasterDBLogPath
           
            $ssrsConnectionTimeout = $server.ConnectionContext.ConnectTimeout 
            $output += "`n ssrsConnectionTimeout: $ssrsConnectionTimeout"
            $rs = (Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer  -class __Namespace).Name
            $nspace = "root\Microsoft\SQLServer\ReportServer\$rs\v$v\Admin"
            $RSServers = Get-WmiObject -Namespace $nspace -class MSReportServer_ConfigurationSetting -ComputerName $servername -ErrorVariable perror -ErrorAction SilentlyContinue
            $WebPortalUrl
            foreach ($r in $RSServers) {
                $folder = $server.Information.MasterDBLogPath
    
                $ssrsInstanceName = $r.InstanceName
                $output += "`n ssrsInstanceName: $ssrsInstanceName"
                $ssrsVers = $r.version
                $output += "`n ssrsVers: $ssrsVers; SQL Version: $serverVersion"
                $ssrsDB = $r.DatabaseName
                $output += "`n ssrsDB: $ssrsDB"
                $vPath = $r.VirtualDirectoryReportServer
                $urls = $r.ListReservedUrls()
                $urls = $urls.UrlString[0]

                if ( $null -eq $urls) {
                    $WebPortalUrl = $urls.Replace('+', $servername) + "/$vPath"
                    $output += "`n WEB Service URL: $WebPortalUrl"
                }
                else {
                    $WebPortalUrl = "N/A"
                    $output += "`n WEB Service URL: $WebPortalUrl"
                }
                
                $ReportServerUri = $WebPortalUrl + "/ReportService2010.asmx"
                $InheritParent = $true
         
                $rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
                $items = $rsProxy.GetPolicies($folderName, [ref]$InheritParent)
                $contentManagers = ""
                foreach ($item in $items) {
                    if ($item.Roles.Name -eq "Content Manager") {
                        $contentManagers += $item.GroupUserName + ","
                    }
                }
                $output += "`n Content Managers: $contentManagers"
    
                if ($r.VirtualDirectoryReportManager -ne "") {
                    $reportManagerUrl = $urls.Replace('+', $servername) + "/" + $r.VirtualDirectoryReportManager
                }
                else {
                    $reportManagerUrl = $urls.Replace('+', $servername) + "/Reports"
                }
                $output += "`n Report Manager URL: $reportManagerUrl"
                $SecureConnectionLevel = $r.SecureConnectionLevel
                $output += "`n Secure Connection Level: $SecureConnectionLevel"
    
                $SenderEmailAddress = $r.SenderEmailAddress
                if ($SenderEmailAddress -ne "") {
                    $output += "`n E-Mail Setting: $SenderEmailAddress"
                }
                else {
                    $output += "`n E-Mail Setting: N/A"
                }
                $execAccount = $r.UnattendedExecutionAccount
                if ($execAccount -ne "") {
                    $output += "`n Execution Account: $execAccount"
                }
                else {
                    $output += "`n SSRS Excution account is not configured"
                }

                $ssrsDBmdfPath = $folder + "\" + $ssrsDB + ".mdf"
                $output += "`n ssrsDBmdfPath: $ssrsDBmdfPath"
                $ssrsDBmdfSize = (Get-Item $ssrsDBmdfPath).length / 1MB
                $output += "`n ssrsDBmdfSize: $ssrsDBmdfSize" + " MB"

                $ssrsDBldfPath = $folder + "\" + $ssrsDB + "_log.ldf"
                $output += "`n ssrsDBldfPath: $ssrsDBldfPath"
                $ssrsDBldfSize = (Get-Item $ssrsDBldfPath).length / 1MB
                $output += "`n ssrsDBmdfSize: $ssrsDBldfSize" + " MB"
                
                $ssrsTempDBmdfPath = $folder + "\" + $ssrsDB + "TempDB.mdf"
                $output += "`n ssrsTempDBldfPath: $ssrsTempDBmdfPath"
                $ssrsTempDBmdfSize = (Get-Item $ssrsTempDBmdfPath).length / 1MB
                $output += "`n ssrsTempDBmdfSize: $ssrsTempDBmdfSize" + " MB"

                $ssrsTempDBldfPath = $folder + "\" + $ssrsDB + "TempDB_log.ldf"
                $output += "`n ssrsTempDBldfPath: $ssrsTempDBldfPath"
                $ssrsTempDBldfSize = (Get-Item $ssrsTempDBldfPath).length / 1MB
                $output += "`n ssrsTempDBldfSize: $ssrsTempDBldfSize" + " MB"
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

Get-SSRSConiguration