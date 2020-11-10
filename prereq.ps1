# Required Modules to Import
Import-Module SqlServer 
Import-Module SQLPS 
Import-Module dbatools 

Function Get-PrerequiredModules {
    try {
        Import-Module SqlServer 
        Import-Module SQLPS 
        Import-Module dbatools 
    }
    catch {
        "Installing Prerequistic....Please wait"
        Install-Module dbatools -AllowClobber
        Install-Module SqlServer -AllowClobber
    }
}
Get-PrerequiredModules