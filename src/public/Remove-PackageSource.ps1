function Remove-PackageSource {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='ShouldProcess support not required by PackageManagement API spec')]
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Remove-PackageSource'))

	[array]$RegisteredPackageSources = Cobalt\Get-WinGetSource

	# WinGet.exe will not error if the specified source name isn't already registered, so we will do it here instead.
	if (-not ($RegisteredPackageSources.Name -eq $Name)) {
		ThrowError -ExceptionName "System.ArgumentException" `
			-ExceptionMessage ($LocalizedData.PackageSourceNotFound -f $Name) `
			-ErrorId 'PackageSourceNotFound' `
			-ErrorCategory InvalidArgument
	}

	# Cobalt will throw an exception if unregistration fails
	Cobalt\Unregister-WinGetSource -Name $Name
}
