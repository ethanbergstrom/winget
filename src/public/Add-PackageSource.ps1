function Add-PackageSource {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name,

		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Location,

		[Parameter()]
		[bool]
		$Trusted
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Add-PackageSource'))
	Write-Verbose "New package source: $Name, $Location"

	Microsoft.WinGet.Client\Register-WinGetSource -Name $Name -Argument $Location

	# Microsoft.WinGet.Client doesn't return anything after new sources are registered, but PackageManagement expects a response
	$packageSource = @{
		Name = $Name
		Location = $Location.TrimEnd("\")
		Trusted = $Trusted
		Registered = $true
	}

	New-PackageSource @packageSource
}
