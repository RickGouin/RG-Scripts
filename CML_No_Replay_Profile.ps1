###############################
# Powershell Script to Report CML Volumes that don't have a replay profile
# Requires Compellent PSSnapIn
# www.rickgouin.com
###############################
 
# Storage Center User to run script
$user = "Admin"
 
# Storage Center Password
$pass = ConvertTo-SecureString "YourPasswordHere" -AsPlainText -Force
 
# Storage Center Host Name or IP Address
$schost = "YourIPAddressHere"
 
#################################
# Nothing to edit below
#################################
 
#grab a list of loaded snapins
$list = Get-PSSnapin
$added = $false
 
#Loop through the list of snapins looking for the Compellent snapin
foreach ($item in $list)            
{            
    if ($item.Name -eq "Compellent.StorageCenter.PSSnapIn")            
    {
    $added = $true
  }            
}  
#No snapin detected, load it.
if ($added -eq $FALSE)            
    {$tmp = Add-PSSnapin Compellent.StorageCenter.PSSnapIn} 
 
#Connect to the SC
$connection = Get-SCConnection -HostName $schost -User $user -Password $pass -Save $schost -Default 
 
Write-Host " Volumes Missing a Replay Profile: "       
get-scvolume | where-object {$_.ReplayProfiles -eq ""}
