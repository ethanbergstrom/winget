# This function gets called during Find-Package, Install-Package, Get-PackageSource etc.
# OneGet uses this method to identify which provider can handle the packages from a particular source location.
function Resolve-PackageSource {

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Resolve-PackageSource'))

	# Get sources from WinGet
	Cobalt\Get-WinGetSource | ForEach-Object {
		New-PackageSource -Name $_.Name -Location $_.Arg -Trusted $true -Registered $true
	}
}
