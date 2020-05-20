# Returns the packages that are installed.
function Get-InstalledPackage {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Name,

		[Parameter()]
		[string]
		$RequiredVersion,

		[Parameter()]
		[string]
		$MinimumVersion,

		[Parameter()]
		[string]
		$MaximumVersion
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Get-InstalledPackage'))

	Write-Warning $LocalizedData.GetPackageNotSupported -f $script:ProviderName
}
