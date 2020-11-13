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

function Get-MachineDetails {
    
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName = $args[0],
        [string]$port = $args[1],
        [Parameter(Mandatory = $false)]
        $showtotalCpuCount = $args[2],
        [Parameter(Mandatory = $false)]
        $showUpdateDateObject = $args[3],
        [Parameter(Mandatory = $false)]
        $showRecommendedCPU = $args[4],
        [Parameter(Mandatory = $false)]
        $showAZISService = $args[5],
        [Parameter(Mandatory = $false)]
        $showAZTaskService = $args[6],
        [Parameter(Mandatory = $false)]
        $showServerName = $args[7],
        [Parameter(Mandatory = $false)]
        $showRam = $args[8],
        [Parameter(Mandatory = $false)]
        $showWindowsVersion = $args[9],
        [Parameter(Mandatory = $false)]
        $showis64BitOS = $args[10],
        [Parameter(Mandatory = $false)]
        $showis64BitProcess = $args[11],
        [Parameter(Mandatory = $false)]
        $showdomain = $args[12],
        [Parameter(Mandatory = $false)]
        $showconnectionTimeout = $args[13],
        [Parameter(Mandatory = $false)]
        $showssl2 = $args[14],
        [Parameter(Mandatory = $false)]
        $showssl3 = $args[15],
        [Parameter(Mandatory = $false)]
        $showtls = $args[16],
        [Parameter(Mandatory = $false)]
        $showtls11 = $args[17],
        [Parameter(Mandatory = $false)]
        $showtls12 = $args[18],
        [Parameter(Mandatory = $false)]
        $showssslv2 = $args[19],
        [Parameter(Mandatory = $false)]
        $showssslv3 = $args[20],
        [Parameter(Mandatory = $false)]
        $showtsls11 = $args[21],
        [Parameter(Mandatory = $false)]
        $showstlsv12 = $args[22],
        [Parameter(Mandatory = $false)]
        $showstlsv10 = $args[23]
        
    )

    Begin {
        $output = ""
        $totalspace = 0
        $outputFolder = "./Output/Application"
        $outputFile = "./Application_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".csv"
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
    }
    Process {
        $erroFile = "./error_log/application" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString()
        
        try {
            $CPUCore = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
            $UpdateDateObject = ((New-Object -com "Microsoft.Update.AutoUpdate").Results | select -Property LastInstallationSuccessDate).LastInstallationSuccessDate
            $RAM = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
            $ServerName = $env:COMPUTERNAME
            $drives = Get-WmiObject Win32_LogicalDisk -ComputerName $ServerName | Select -Property Size
            $output += "Server Name : " + $ServerName
            foreach ($drive  in $drives) {
                $drivename = $drive. -split ":"
                if (($drivename -ne "A") -and ($drivename -ne "B")) {
                    $totalspace += [int]($drive.Size / 1GB)
                }
            }
            $totalCpuCount = ( Invoke-Sqlcmd -Query "SELECT i.cpu_count from sys.dm_os_sys_info i").cpu_count
            if ($showtotalCpuCount) {
                $output += "`nTotal CPU Count $totalCpuCount"
            }
            if ($showUpdateDateObject) {
                $output += "`nLast Update Dates $UpdateDateObject"
            }
    
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            $is64BitOS = [System.Environment]::Is64BitOperatingSystem
            $is64BitProcess = [System.Environment]::Is64BitProcess
            $AZISService = Get-Service | Where-Object { $_.Name -eq "AZ IS Scheduler Service" }
            $AZTaskService = Get-Service | Where-Object { $_.Name -eq "AZ Task Scheduler Service" }
            $domain = (Get-WmiObject Win32_ComputerSystem).Domain
    
            $RAMGB = [int]($RAM.Split(' ')[0].Trim() / 1024) 
            if ($showRecommendedCPU) {
                $output += "`nRecommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"
            }
            if ($showAZISService) {
                $output += "`nWindows Service [AZ IS Scheduler Service]:" + $AZISService
            }
            if ($showAZTaskService) {
                $output += "`nWindows Service [AZ Task Scheduler Service]:" + $AZTaskService
            }
            if ($showServerName) {
                $output += "`nWindows Sever:" + $ServerName
            }
            if ($showWindowsVersion) {
                $output += "`nWindows Version:" + $WindowsVersion
            }
            if ($showis64BitOS) {
                $output += "`nIs 64 Bit OS:" + $is64BitOS
            }
            if ($showis64BitProcess) {
                $output += "`nIs 64 Bit Process:" + $is64BitProcess
            }
            if ($showdomain) {
                $output += "`nDomain:" + $domain
            }
            if ($showRam) {
                $output += "`nTotal Physical Memory:" + $RAMGB + " GB"
            }

            $connectionTimeout = ( Invoke-Sqlcmd -Query "sp_configure 'Remote Query Timeout'").config_value
            if ($showconnectionTimeout) {
                $output += "`n Connection Timeout: $connectionTimeout"
            }
            
            $enabledProtocols = [enum]::GetNames([Net.SecurityProtocolType])
            $ssl2 = "Disabled"
            $ssl3 = "Disabled"
            $tls = "Disabled"
            $tls11 = "Disabled"
            $tls12 = "Disabled"
            if ($enabledProtocols -contains 'Ssl2') {
                $ssl2 = "Enabled"
            }
    
            if ($enabledProtocols -contains 'Ssl3') {
                $ssl3 = "Enabled"
            }
            if ($enabledProtocols -contains 'Tls') {
                $tls = "Enabled"
            }
            if ($enabledProtocols -contains 'Tls11') {
                $tls11 = "Enabled"
            } 
            if ($enabledProtocols -contains 'Tls12') {
                $tls12 = "Enabled"
            } 
            if ($showssl2) {
                $output += "`nSecurity [Client SSL 2.0] Is Client SSL 2.0 is " + $ssl2
            }
            if ($showssl3) {
                $output += "`nSecurity [Client SSL 3.0] Is Client SSL 3.0 is " + $ssl3
            }
            if ($showtls) {
                $output += "`nSecurity [Client TLS 1.0] Is Client TLS 1.0 is " + $tls
            }
            if ($showtls11) {
                $output += "`nSecurity [Client TLS 1.1] Is Client TLS 1.1 is " + $tls11
            }
            if ($showtls12) {
                $output += "`nSecurity [Client TLS 1.2] Is Client TLS 1.2 is " + $tls12
            }

            $erroFile = "./error_log/applicationserverssl" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"

            $RetValue = New-Object psobject -Property @{
                Host          = $HostName
                Port          = $port
                SSLv2         = $false
                SSLv3         = $false
                TLSv1_0       = $false
                TLSv1_1       = $false
                TLSv1_2       = $false
                KeyExhange    = $null
                HashAlgorithm = $null
            }
            "ssl2", "ssl3", "tls", "tls11", "tls12" | % {
                $TcpClient = New-Object Net.Sockets.TcpClient
                $TcpClient.Connect($RetValue.Host, $RetValue.Port)
                $SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream()
                $SslStream.ReadTimeout = 15000
                $SslStream.WriteTimeout = 15000
                try {
                    $SslStream.AuthenticateAsClient($RetValue.Host, $null, $_, $false)
                    $RetValue.KeyExhange = $SslStream.KeyExchangeAlgorithm
                    $RetValue.HashAlgorithm = $SslStream.HashAlgorithm
                    $status = $true
                }
                catch {
                    $status = $false
                }
                switch ($_) {
                    "ssl2" { $RetValue.SSLv2 = $status }    
                    "ssl3" { $RetValue.SSLv3 = $status }    
                    "tls" { $RetValue.TLSv1_0 = $status }    
                    "tls11" { $RetValue.TLSv1_1 = $status }    
                    "tls12" { $RetValue.TLSv1_2 = $status }    
                }
    
            }
            $ssslv2 = If ($RetValue.SSLv2) { "Enabled" } Else { "Disabled" }
            $ssslv3 = If ($RetValue.SSLv3) { "Enabled" } Else { "Disabled" }
            $stlsv10 = If ($RetValue.TLSv1_0) { "Enabled" } Else { "Disabled" }
            $stlsv11 = If ($RetValue.TLSv1_1) { "Enabled" } Else { "Disabled" }
            $stlsv12 = If ($RetValue.TLSv1_2 ) { "Enabled" } Else { "Disabled" }
            if ($showssslv2) {
                $output += "`nSecurity [Server SSL 2.0] Is Client SSL 2.0 is " + $ssslv2
            }
            if ($showssslv3) {
                $output += "`nSecurity [Server SSL 3.0] Is Client SSL 3.0 is " + $ssslv3

            }
            if ($showstlsv10) {
                $output += "`nSecurity [Server TLS 1.0] Is Client TLS 1.0 is " + $stlsv10

            }
            if ($showstlsv11) {
                $output += "`nSecurity [Server TLS 1.1] Is Client TLS 1.1 is " + $stlsv11 
                
            }
            if ($showstlsv12) {
                $output += "`nSecurity [Server TLS 1.2] Is Client TLS 1.2 is " + $stlsv12
            }
            
        }
        catch {
            $err = $_
            Set-Content -Path $erroFile -Value $err 
            $StackTrace = $_.ScriptStackTrace 
            Set-Content -Path $erroFile -Value $StackTrace
        }
       
    }
    End {
        return $output | Format-List
    }
}
function Test-ServerSSLSupport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName = $args[0],
        [string]$port = 443
    )
    process {
        $erroFile = "./error_log/applicationserverssl" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"

        try {
           
            $RetValue = New-Object psobject -Property @{
                Host          = $HostName
                Port          = $port
                SSLv2         = $false
                SSLv3         = $false
                TLSv1_0       = $false
                TLSv1_1       = $false
                TLSv1_2       = $false
                KeyExhange    = $null
                HashAlgorithm = $null
            }
            "ssl2", "ssl3", "tls", "tls11", "tls12" | % {
                $TcpClient = New-Object Net.Sockets.TcpClient
                $TcpClient.Connect($RetValue.Host, $RetValue.Port)
                $SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream()
                $SslStream.ReadTimeout = 15000
                $SslStream.WriteTimeout = 15000
                try {
                    $SslStream.AuthenticateAsClient($RetValue.Host, $null, $_, $false)
                    $RetValue.KeyExhange = $SslStream.KeyExchangeAlgorithm
                    $RetValue.HashAlgorithm = $SslStream.HashAlgorithm
                    $status = $true
                }
                catch {
                    $status = $false
                }
                switch ($_) {
                    "ssl2" { $RetValue.SSLv2 = $status }    
                    "ssl3" { $RetValue.SSLv3 = $status }    
                    "tls" { $RetValue.TLSv1_0 = $status }    
                    "tls11" { $RetValue.TLSv1_1 = $status }    
                    "tls12" { $RetValue.TLSv1_2 = $status }    
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
        
        # $RetValue 
    }
    End {
        #$output | Export-Csv -Path $outpuFile
        $filePath = $outputFolder + "/" + $outputFile
        $output | Out-File -Append $filePath -Encoding UTF8
        Write-Host "Check the output at File "  $filePath -ForegroundColor Yellow
        return $output | Format-List
    }
}


Get-MachineDetails