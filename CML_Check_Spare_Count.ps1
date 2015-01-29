###############################
# Script to check Spare Counts
# 
#
# www.rickgouin.com
# 01/28/2014
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


function GetDiskTypes
{
	$colSizes = @();
	$colDisks = @();
	$colOut = @();
	foreach($disk in Get-SCDisk)
	{
	$count = 1;     
    $DiskObject = New-Object System.Object
    $DiskObject | Add-Member -Type NoteProperty -Name "Classification" -Value $disk.classification
    $DiskObject | Add-Member -Type NoteProperty -Name "TotalBlocks" -Value $disk.totalblocks
	$DiskObject | Add-Member -Type NoteProperty -Name "ControlType" -Value $disk.controltype
	$DiskObject | Add-Member -Type NoteProperty -Name "UnAllocatedBlocks" -Value $disk.UnAllocatedBlocks
	$colDisks += $DiskObject;
	}
	#build list of sizes
	foreach ($disk in $colDisks)
	{
		if ($colSizes -notcontains $disk.totalblocks)
		{
			$colSizes += $disk.totalblocks;
		}
	}
	#build quantities	
	foreach ($Size in $colSizes)
	{
		$drivesizeGB = "{0:N2}" -f ((((($Size * 512)/1024)/1024)/1024)*1.073741824);
		$drives = New-Object System.Object
		$drives | Add-Member -Type NoteProperty -Name "DriveSize" -Value $drivesizeGB
		$drives | Add-Member -Type NoteProperty -Name "Classification" -Value ""
		$drives | Add-Member -Type NoteProperty -Name "Count" -Value 0
		$drives | Add-Member -Type NoteProperty -Name "Spares" -Value 0
		$drives | Add-Member -Type NoteProperty -Name "TotalCapacity" -Value 0

		foreach ($disk in $colDisks)
		{
			if ($disk.TotalBlocks -eq $Size)
			{
				$drives.Classification = $disk.classification;
				$drives.Count ++;
				$drives.TotalCapacity += "{0:N2}" -f (((($disk.TotalBlocks * 512)/1024)/1024)/1024);
				if ($disk.ControlType -ilike "ManagedSpare" -or $disk.ControlType -ilike "Spare")
				{
					$drives.Spares ++
				}
			}
		}
		$colOut += $drives;
	}
	$colOut
}
function GetSpares
{
	$disks = GetDiskTypes
	$Output = @();
	foreach ($disk in $disks)
	{
		if ($disk.spares -gt 0)
		{
			$DrivesPerSpare = $disk.Count / $disk.Spares;
		}
		else
		{
			$DrivesPerSpare = 0;
		}
		$dataobj = new-object system.object 
		$dataobj | add-member -type NoteProperty -name DriveType -value $disk.Classification
		$dataobj | add-member -type NoteProperty -name DriveSize -value $disk.DriveSize
		$dataobj | add-member -type NoteProperty -name TotalDrives -value $disk.Count
		$dataobj | add-member -type NoteProperty -name TotalSpares -value $disk.Spares
		$dataobj | add-member -type NoteProperty -name DrivesPerSpare -value $DrivesPerSpare
		$Output += $dataobj
	}
	Write-Host "Spare Drive Information: "  
	$Output
}

GetSpares