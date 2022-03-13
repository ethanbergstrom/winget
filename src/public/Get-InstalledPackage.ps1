# Returns the packages that are installed.
function Get-InstalledPackage {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification='Version may not always be used, but are still required')]
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

	# If a user wants to check whether the latest version is installed, first check the repo for what the latest version is
	if ($RequiredVersion -eq 'latest') {
		$RequiredVersion = $(Find-WinGetPackage -Name $Name).Version
	}

	# Convert the PSCustomObject output from Cobalt into PackageManagement SWIDs, then filter results by version requirements
	# This provides wildcard search behavior for locally installed packages, which WinGet lacks
	Cobalt\Get-WinGetPackage |
		Where-Object {-Not $Name -Or ($_.ID -Like $Name)} |
			Where-Object {Test-PackageVersion -Package $_ -RequiredVersion $RequiredVersion -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion} |
				ConvertTo-SoftwareIdentity
}
