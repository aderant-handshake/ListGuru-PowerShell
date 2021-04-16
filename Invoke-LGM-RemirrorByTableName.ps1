<# 
	.SYNOPSIS
    Read the information in the Handshake ListGuru Mirror Table for the named MirrorTableName

	.DESCRIPTION

    .EXAMPLE
	.\Invoke-LGM-RemirrorByTableName.ps1 -MirrorTableName Connect_FirmNews -rebuild

#>

PARAM (
# name of the Mirror Table from SPListGuruMirrorInfo
 [Parameter(mandatory=$true)][string]$MirrorTableName 
# Use -rebuild to force a rebuild of any of the LGM Table. Will only do so on the first list
,[switch]$rebuild
)

# get environment specific settings
$cfg = Get-Content ./lgm-utility-config.json | ConvertFrom-Json

function resyncList($list, $forceRebuild) {
	
    try{
        $hsuri = $list.ParentWebFullUrl + "/_layouts/15/Handshake/HSListGuruService.asmx?WSDL"
        $listGuru = New-WebServiceProxy -Uri $hsuri -UseDefaultCredential
        if($listGuru){
			$listGuru.SetMirrorTableName($list.ParentWebFullUrl, $list.listName, $list.MirrorTableName, $list.OnlyPublished) | Out-Null
            $listGuru.CreateOrUpdateMirrorTable2($list.ParentWebFullUrl,$list.listID,$list.MirrorTableName,$forceRebuild, $true) | Out-Null
			Start-Sleep -s 5
			write-host -ForegroundColor green "Rebuild complete..."
        }
        else{
            write-host -ForegroundColor red "Problem getting ListGuru Web Service proxy"
        }
    }
    catch{
		$estr = "Error updating list {0} for site {1}. Error: {2}" -f $list.listID,$list.ParentWebFullUrl,$_.Exception.Message
        write-host -ForegroundColor red $estr 
    }
}

#########################################################################
# Main Processing 														#
#########################################################################

$qstr = @"
select ListName, MirrorTableName, ParentWebUrl, ParentWebFullUrl, ListID, SiteID, OnlyPublished 
FROM $($cfg.LGMTable) where MirrorTableName = '$MirrorTableName'
"@

$LGMSql = @{} 
$LGMSql.Database=$cfg.LGMDatabase
$LGMSql.ServerInstance=$cfg.LGMSQLServer 
$LGMSql.OutputSqlErrors=$true
$LGMSql.Query=$qstr 

if ($cfg.LGMCred) {
	##TODO : Implement use of Windows Credential Manager 
}

$LGMLists = Invoke-Sqlcmd @LGMSql
$count = $LGMLists.count 
$counter = 0 
foreach ($list in $LGMLists) {

	# optional rebuild but only on first pass. 
	if ($rebuild -and ($counter -eq 0)) {
		$force = $true; 
	} else {
		$force = $false; 
	}
	$counter++ 

	write-host "Resync List $($list.listName) | $counter of $count with force=$force"
	resyncList -list $list -forceRebuild $force 
	
}