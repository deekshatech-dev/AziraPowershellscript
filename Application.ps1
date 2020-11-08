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
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName = $args[0],
        [string]$port = 443
    )

    Begin {
        $output = ""
        $totalspace = 0
    }
    Process {
        $erroFile = "./error_log/application" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString()
        
        try {
            $CPUCore = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
            $UpdateDateObject = (((New-Object -com "Microsoft.Update.AutoUpdate").Results | select -Property LastInstallationSuccessDate).LastInstallationSuccessDate).ToString("MM/dd/yyyy")
            $RAM = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
            $ServerName = $env:COMPUTERNAME
            $drives = Get-WmiObject Win32_LogicalDisk -ComputerName $ServerName | Select -Property Size
            foreach ($drive  in $drives) {
                $drivename = $drive. -split ":"
                if (($drivename -ne "A") -and ($drivename -ne "B")) {
                    $totalspace += [int]($drive.Size / 1GB)
                }
            }
            if($UpdateDateObject -eq "01/01/1601"){
                $UpdateDateObject = "N/A"
            }
            $totalCpuCount = ( Invoke-Sqlcmd -Query "SELECT i.cpu_count from sys.dm_os_sys_info i").cpu_count
          
    
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            $is64BitOS = [System.Environment]::Is64BitOperatingSystem
            $is64BitProcess = [System.Environment]::Is64BitProcess
            $AZISService = Get-Service | Where-Object { $_.Name -eq "AZ IS Scheduler Service" }
            $AZTaskService = Get-Service | Where-Object { $_.Name -eq "AZ Task Scheduler Service" }
            $domain = (Get-WmiObject Win32_ComputerSystem).Domain
    
            $RAMGB = [int]($RAM.Split(' ')[0].Trim() / 1024) 
            

            $connectionTimeout = ( Invoke-Sqlcmd -Query "sp_configure 'Remote Query Timeout'").config_value
           
            
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


            $output += "`nWindows Service [AZ IS Scheduler Service]:" + $AZISService
            $output += "`nWindows Service [AZ Task Scheduler Service]:" + $AZTaskService
            $output += "`nWindows Sever:" + $ServerName
            $output += "`nWorkstation Name : " + $ServerName
            $output += "`nWindows Version:" + $WindowsVersion
            $output += "`nIs 64 Bit OS:" + $is64BitOS
            $output += "`nIs 64 Bit Process:" + $is64BitProcess
            $output += "`nDomain:" + $domain
            $output += "`nTotal Physical Memory:" + $RAMGB + " GB"
            $output += "`nTotal CPU Count $totalCpuCount"
            $output += "`nLast Update Dates $UpdateDateObject"


            $output += "`n================================================"
            $output += "`nClient Security Protocols"
            $output += "`n================================================"
            $output += "`nSecurity [Client SSL 2.0] Is Client SSL 2.0 is " + $ssl2
            $output += "`nSecurity [Client SSL 3.0] Is Client SSL 3.0 is " + $ssl3
            $output += "`nSecurity [Client TLS 1.0] Is Client TLS 1.0 is " + $tls
            $output += "`nSecurity [Client TLS 1.1] Is Client TLS 1.1 is " + $tls11
            $output += "`nSecurity [Client TLS 1.2] Is Client TLS 1.2 is " + $tls12
            $output += "`n================================================"
            $output += "`n================================================"
            $output += "`nServer Security Protocols"
            $output += "`n================================================"
            $output += "`nSecurity [Server SSL 2.0] Is Client SSL 2.0 is " + $ssslv2
            $output += "`nSecurity [Server SSL 3.0] Is Client SSL 3.0 is " + $ssslv3
            $output += "`nSecurity [Server TLS 1.0] Is Client TLS 1.0 is " + $stlsv10
            $output += "`nSecurity [Server TLS 1.1] Is Client TLS 1.1 is " + $stlsv11 
            $output += "`nSecurity [Server TLS 1.2] Is Client TLS 1.2 is " + $stlsv12
            $output += "`n================================================"


            $output += "`nSql Server Connection Timeout: $connectionTimeout"
            $output += "`nRecommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"
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


Get-MachineDetails