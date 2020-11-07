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

function Get-SSASConfiguration {
    
    Param
    (
        [Parameter(Mandatory = $false)]
        $showWindowsVersion,
        [Parameter(Mandatory = $false)]
        $showWindowsServer,
        [Parameter(Mandatory = $false)]
        $showssasConnectionTimeout,
        [Parameter(Mandatory = $false)]
        $showAdministrator,
        [Parameter(Mandatory = $false)]
        $showssasVersion,
        [Parameter(Mandatory = $false)]
        $showssasVsSqlVersion,
        [Parameter(Mandatory = $false)]
        $showssasServerMode,
        [Parameter(Mandatory = $false)]
        $showssasCollation,
        [Parameter(Mandatory = $false)]
        $showssasCubes,
        [Parameter(Mandatory = $false)]
        $showssasEdition
        # [Parameter(Mandatory=$false)]
        # $show,
    )

    Begin {
        $output = ""
        $totalspace = 0
        
    }
    Process {   
        $erroFile = "./error_log/ssasconfig_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        try {
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            if ($showWindowsVersion) {
                $output += "`n `nWindows Server:" + $env:COMPUTERNAME
            }
            if ($showshowWindowsServer) {
                $output += "`n `nWindows Version:" + $WindowsVersion 
            }
    
            $ssasInstanceName = "localhost"
            $loadAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
            $svr = New-Object Microsoft.AnalysisServices.Server
            $svr.Connect($ssasInstanceName)
            
            $ssasConnectionTimeout = $svr.ConnectionInfo.ConnectTimeout
            if ($showssasConnectionTimeout) {
                $output = "`n ssasConnectionTimeout: $ssasConnectionTimeout"
            }
            $instanceName = "localhost"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $serverVersion = $server.Information.VersionString
            
            # To create a new DB
            # $svr.databases.add("SSASDB")
            # $DB = $svr.databases.item("SSASDB")
            # $DB.update()
            # $DB.description = "Testing SSAS DB addition"
            # $DB.update()
    
            $databaseRoles = $svr.Databases[0].Roles
            $admins
            foreach ($role in $databaseRoles) {
                if ($role.Name -eq "Administrator") {
                    $admins = $role.Members.ToString()
                }
            }
            if ($showAdministrator) {
                $output += "`n Administrator: $admins"
            }
            # $output += "`n Roles: $roles"
            $ssasVersion = $svr.Version
            if ($showssasVersion) {
                $output += "`nssasVersion: $ssasVersion"
            }
            if ($showshowssasVsSqlVersion) {
                $output += "`n SSAS Version: $ssasVersion | ssqlVersion: $serverVersion"
            }
            $ssasServerMode = $svr.ServerMode
            if ($showssasServerMode) {
                $output += "`nssasServerMode: $ssasServerMode"
            }            
            $ssasCollation = $svr.Collation
            if ($showssasCollation) {
                $output += "`nssasCollation: $ssasCollation"
            }
            $ssasCubes = $svr.Cubes
            if ($showssasCubes) {
                $output += "`nssasCubes: $ssasCubes"
            }
            $ssasEdition = $svr.Edition
            if ($showssasEdition) {
                $output += "`nssasEdition: $ssasEdition"
            }
        }
        catch {
            $err = $_ + $_.ScriptStackTrace 
            Set-Content -Path $erroFile -Value $err 
        }
       

    }
    End {
        return $output | Format-List
    }
}

Get-SSASConfiguration