<#
    .SYNOPSIS

    script for showing all office 365 groups created by microsoft teams

    .DESCRIPTION
    


    .EXAMPLE
    no parameters needed 

    .Notes
    connect to exchange online first 
    https://technet.microsoft.com/en-us/library/jj984289(v=exchg.160).aspx
    or see https://blog.it-koehler.com/en/Archive/1589
  
    ---------------------------------------------------------------------------------
                                                                                 
    Script:       get-allteams-withmembers-0-1.ps1                                      
    Author:       A. Koehler; blog.it-koehler.com
    ModifyDate:   18/03/2018                                                        
    Usage:        identify all teams groups in office 365 and get members
    Version:      0.1
                                                                                  
    ---------------------------------------------------------------------------------
#>

#get all groups created with ms teams (filtered ExchangeProvisioningFlag:481)
#raw powershell command: Get-UnifiedGroup | Where-Object {$_.ProvisioningOption -eq "ExchangeProvisioningFlags:481" } | fl
$teamsgroups = (Get-UnifiedGroup | Where-Object {$_.ProvisioningOption -eq "ExchangeProvisioningFlags:481" } | Select-Object DisplayName,Alias,ProvisioningOption,SharePointSiteUrl,SharePointDocumentsUrl,AccessType,Language,ExchangeGuid,ManagedBy) 
#notification for powershell
Write-Host "Getting Office 365 Groups created with MS Teams... " -ForegroundColor Green
#generate array for teamsgroups
$teams = @()
#loop to get information
ForEach ($group in $teamsgroups){
  #get-members of group
  $identity = (($group).ExchangeGuid)
  $members = (Get-UnifiedGroupLinks -Identity "$identity" -LinkType Members | Select-Object PrimarySMTPAddress) 
  $owners = (Get-UnifiedGroupLinks -Identity "$identity" -LinkType Owners | Select-Object PrimarySMTPAddress)   
  $member = (($members).primarySMTPAddress) | Out-String -Width 4096
  $owner = (($owners).primarySMTPAddress) | Out-String
  # Adding pscustomobjets entries to array
  $teams += [pscustomobject]@{
    DisplayName   = ($group).DisplayName
    Alias    = ($group).Alias
    AccessType = ($group).AccessType
    Language = ($group).Language
    Members = ("$member")
    Owner = ("$owner")
  }
}
#out put in GridView (external window)
Write-Host "Display in Grid View Window " -ForegroundColor Green
$teams | Out-GridView -Title "All Office365 Groups created in MS Teams" 
#out put in powershell
#$teams | Format-Table -AutoSize -Wrap  
#erase content of variables
$teams =$null
$member = $null
