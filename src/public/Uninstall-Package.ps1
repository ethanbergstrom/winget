# It is required to implement this function for the providers that support UnInstall-Package.
function Uninstall-Package {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidOverwritingBuiltInCmdlets', '', Justification='Required by PackageManagement')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$FastPackageReference
	)

	Write-Debug -Message ($LocalizedData.ProviderDebugMessage -f ('Uninstall-Package'))
	Write-Debug -Message ($LocalizedData.FastPackageReference -f $FastPackageReference)

	# If the fast package reference doesnt match the pattern we expect, throw an exception
	if ((-Not ($FastPackageReference -Match $script:FastReferenceRegex)) -Or (-Not ($Matches.name -And $Matches.version))) {
		ThrowError -ExceptionName "System.ArgumentException" `
			-ExceptionMessage ($LocalizedData.FailToUninstall -f $FastPackageReference) `
			-ErrorId 'FailToUninstall' `
			-ErrorCategory InvalidArgument
	}

	$WinGetParams = @{
		ID = $Matches.name
		Version = $Matches.version
		Source = $Matches.source
	}

	Microsoft.WinGet.Client\Uninstall-WinGetPackage @WinGetParams

	# Microsoft.WinGet.Client doesn't return any package data on successful uninstallation, so we have to make up a new SWID to satisfy PackageManagement
	ConvertTo-SoftwareIdentity -InputObject @($WinGetParams)
}
