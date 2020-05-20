# It is required to implement this function for the providers that support UnInstall-Package.
function Uninstall-Package {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FastPackageReference
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Uninstall-Package'))

	Write-Warning $LocalizedData.UninstallPackageNotSupported -f $script:ProviderName
}
