# Update the registered package source(s)
function Update-PackageSources {
	[CmdletBinding()]
	param (
		[string]
		$SourceName
	)

	$WinGetParams = @{
		SourceUpdate = $true
	}

	# WinGet does not support searching by min or max version, so if a user is picky we'll need to pull back the latest and see if it meets the requirements further down
	if ($SourceName) {
		$WinGetParams.Add('SourceName',$SourceName)
	}
	Invoke-WinGet @WinGetParams
}
