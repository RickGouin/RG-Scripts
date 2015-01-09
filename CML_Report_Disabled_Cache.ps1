###############################
# Powershell Script to Report Disabled CML Cache
# Requires Compellent PSSnapIn
# www.rickgouin.com
# 07/09/2014
###############################
 
# Storage Center User to run script
$user = "Admin"
 
# Storage Center Password
$pass = ConvertTo-SecureString "mmm" -AsPlainText -Force
 
# Storage Center Host Name or IP Address
$schost = "192.168.5.160"
 
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
 
Write-Host " Volumes with Read Cache Disabled: "       
Get-SCVolume -ReadCacheEnabled $false 
 
Write-Host "`n Volumes with Write Cache Disabled: "
Get-SCVolume -WriteCacheEnabled $false
