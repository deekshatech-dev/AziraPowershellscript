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
        $showWindowsVersion = $args[0],
        [Parameter(Mandatory = $false)]
        $showWindowsServer = $args[1],
        [Parameter(Mandatory = $false)]
        $showssasConnectionTimeout = $args[2],
        [Parameter(Mandatory = $false)]
        $showAdministrator = $args[3],
        [Parameter(Mandatory = $false)]
        $showssasVersion = $args[4],
        [Parameter(Mandatory = $false)]
        $showssasVsSqlVersion = $args[5],
        [Parameter(Mandatory = $false)]
        $showssasServerMode = $args[6],
        [Parameter(Mandatory = $false)]
        $showssasCollation = $args[7],
        [Parameter(Mandatory = $false)]
        $showssasCubes = $args[8],
        [Parameter(Mandatory = $false)]
        $showssasEdition = $args[9]
        # [Parameter(Mandatory=$false)]
        # $show,
    )

    Begin {
        $output = ""
        $totalspace = 0
        $outputFolder = "./Output/SSASConfiguration"
        $outputFile = "./SSASConfiguration_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".csv"
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
            }
            else {
                $showWindowsVersion = $true
            }
        }
        if (!$showWindowsServer) {
            if (($showWindowsServer -eq 0)) {
                $showWindowsServer = $false
            }
            else {
                $showWindowsServer = $true
            }
        }
        if (!$showssasConnectionTimeout) {
            if (($showssasConnectionTimeout -eq 0)) {
                $showssasConnectionTimeout = $false
            }
            else {
                $showssasConnectionTimeout = $true
            }
        }
        if (!$showAdministrator) {
            if (($showAdministrator -eq 0)) {
                $showAdministrator = $false
            }
            else {
                $showAdministrator = $true
            }
        }
        if (!$showssasVersion) {
            if (($showssasVersion -eq 0)) {
                $showssasVersion = $false
            }
            else {
                $showssasVersion = $true
            }
        }
        if (!$showssasVsSqlVersion) {
            if (($showssasVsSqlVersion -eq 0)) {
                $showssasVsSqlVersion = $false
            }
            else {
                $showssasVsSqlVersion = $true
            }
        }
        if (!$showssasServerMode) {
            if (($showssasServerMode -eq 0)) {
                $showssasServerMode = $false
            }
            else {
                $showssasServerMode = $true
            }
        }
        if (!$showssasCollation) {
            if (($showssasCollation -eq 0)) {
                $showssasCollation = $false
            }
            else {
                $showssasCollation = $true
            }
        }
        if (!$showssasCubes) {
            if (($showssasCubes -eq 0)) {
                $showssasCubes = $false
            }
            else {
                $showssasCubes = $true
            }
        }
        if (!$showssasEdition) {
            if (($showssasEdition -eq 0)) {
                $showssasEdition = $false
            }
            else {
                $showssasEdition = $true
            }
        }
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

Get-SSASConfiguration