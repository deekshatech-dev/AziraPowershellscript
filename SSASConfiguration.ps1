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
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
    )

    Begin {
        $output = ""
        $totalspace = 0
        "Get SSAS Configuration Details: Windows Server, Windows Version, SSAS Connection Timeout, SSAS Version, SSAS Server Mode, SSAS Edition and other SSAS details."
    }
    Process {   
        $erroFile = "./error_log/ssasconfig_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        try {
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            $output += "`n `nWindows Server:" + $env:COMPUTERNAME
            $output += "`n `nWindows Version:" + $WindowsVersion
    
            $ssasInstanceName = "localhost"
            $loadAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
            $svr = New-Object Microsoft.AnalysisServices.Server
            $svr.Connect($ssasInstanceName)
            
            $ssasConnectionTimeout = $svr.ConnectionInfo.ConnectTimeout
            $output = "`n ssasConnectionTimeout: $ssasConnectionTimeout"

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
            
            $output += "`n Administrator: $admins"
            
            # $output += "`n Roles: $roles"
            $ssasVersion = $svr.Version
            $output += "`n SSAS Version: $ssasVersion | ssqlVersion: $serverVersion "
            $output += "`nssasVersion: $ssasVersion"
            $ssasServerMode = $svr.ServerMode
            $output += "`nssasServerMode: $ssasServerMode"
            $ssasCollation = $svr.Collation
            $output += "`nssasCollation: $ssasCollation"
            $ssasCubes = $svr.Cubes
            $output += "`nssasCubes: $ssasCubes"
            $ssasEdition = $svr.Edition
            $output += "$ssasEdition"
            $ssasServerMode = $svr.ServerMode
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

Get-SSASConfiguration