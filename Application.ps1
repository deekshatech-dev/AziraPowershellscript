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
    )

    Begin {
        $output = ""
        $totalspace = 0
    }
    Process {
   
        $CPUCore = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
        $UpdateDateObject = (New-Object -com "Microsoft.Update.AutoUpdate").Results | select -Property LastInstallationSuccessDate
        # foreach ($object  in $UpdateDateObject){
        #     $output += "Date : " + ($object | Select-String 'LastInstallationSuccessDate :') + "`n"
        # }
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
        $totalCpuCount = Invoke-Sqlcmd -Query "SELECT i.cpu_count from sys.dm_os_sys_info i"

        $output += "`n Total CPU Count $totalCpuCount"
        $output += "`n Last Update Dates $UpdateDateObject"

        $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
        $is64BitOS = [System.Environment]::Is64BitOperatingSystem
        $is64BitProcess = [System.Environment]::Is64BitProcess
        $AZISService = Get-Service | Where-Object { $_.Name -eq "AZ IS Scheduler Service" }
        $AZTaskService = Get-Service | Where-Object { $_.Name -eq "AZ Task Scheduler Service" }
        $domain = (Get-WmiObject Win32_ComputerSystem).Domain

        $RAMGB = [int]($RAM.Split(' ')[0].Trim() / 1024) 
        $output += "`nRecommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"
        
        $output += "`nWindows Service [AZ IS Scheduler Service]:" + $AZISService
        $output += "`nWindows Service [AZ Task Scheduler Service]:" + $AZTaskService
        $output += "`nWindows Sever:" + $ServerName
        $output += "`nWindows Version:" + $WindowsVersion
        $output += "`nIs 64 Bit OS:" + $is64BitOS
        $output += "`nIs 64 Bit Process:" + $is64BitProcess
        $output += "`nDomain:" + $domain
        $output += "`nTotal Physical Memory:" + $RAMGB + " GB"

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
        $output += "`nSecurity [Client SSL 2.0] Is Client SSL 2.0 is " + $ssl2
        $output += "`nSecurity [Client SSL 3.0] Is Client SSL 3.0 is " + $ssl3
        $output += "`nSecurity [Client TLS 1.0] Is Client TLS 1.0 is " + $tls
        $output += "`nSecurity [Client TLS 1.1] Is Client TLS 1.1 is " + $tls11
        $output += "`nSecurity [Client TLS 1.2] Is Client TLS 1.2 is " + $tls12
    }
    End {
        return $output | Format-List
    }
}

Function Get-FileName() {  
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Select the file"
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog()
    $OpenFileDialog.filename
}
Get-MachineDetails