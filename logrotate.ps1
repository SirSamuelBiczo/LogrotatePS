Using Namespace Microsoft.VisualBasic
Add-Type  -AssemblyName  Microsoft.VisualBasic

$ROTATION = 0
$PURGE = 0

# Niveau de compression indiqué ici sur la docs msdn https://docs.microsoft.com/fr-fr/dotnet/api/system.io.compression.compressionlevel?view=net-5.0
$compress = @{
LiteralPath= "C:\Users\SirSamuHell\Desktop\logrotate.d\"
CompressionLevel = "Fastest"
DestinationPath = ""
}
 

$items = Get-ChildItem $compress["LiteralPath"] | Select Name, CreationTime


Write-Output "Compression des logs en cours..."

foreach($item in $items)
{
    # Récupere la date en jours 
    $date = -join($item.CreationTime.Year,"-",$item.CreationTime.Month,"-",$item.CreationTime.Day)
   
    $fileDate = Get-Date $date
    $todayDate = Get-Date
    $days = [DateAndTime]::DateDiff([DateInterval]::Day, $fileDate, $todayDate)

    if($days -ge $ROTATION -and $item.Name -notlike "*.zip") # Compress uniquement si il c'est pas déja zipper et si c'est la date du fichier et plus grand en terme de jours de $ROTATION
    {
        Write-Output "+Compression de $($item.Name) en cours..."
        $compressArchiveNameDate = Get-Date
        $compressArchiveNameDate = -join($compress['LiteralPath'],$item.Name,'.', $compressArchiveNameDate.Day,$compressArchiveNameDate.Month, $compressArchiveNameDate.Year,'.zip')
      
        $compress['DestinationPath'] = $compressArchiveNameDate
        Compress-Archive @compress
        $filepath = -join($compress['LiteralPath'], '\', $item.Name)
        Remove-item -Path $filepath
        
    }
}

Write-Output "Compression des logs OK"
$path = -join($compress["LiteralPath"], "*.zip")

$items = Get-ChildItem $path

Write-Output "Purge en cours..."

foreach($item in $items)
{    
    # Récupere la date en jours 
    $date = -join($item.CreationTime.Year,"-",$item.CreationTime.Month,"-",$item.CreationTime.Day)
   
    $fileDate = Get-Date $date
    $todayDate = Get-Date
    $days = [DateAndTime]::DateDiff([DateInterval]::Day, $fileDate, $todayDate)  

    if($days -ge $PURGE)
    {
         Write-Output "Suppression en cours $($item.Name) ..."
         Remove-Item $item
    }
}

Write-Output "Purge OK"
 

