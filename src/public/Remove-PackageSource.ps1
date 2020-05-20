function Remove-PackageSource {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name
	)

	Write-Debug ('Remove-PackageSource')

	[array]$RegisteredPackageSources = Get-PackageSources

	# WinGet.exe will not error if the specified source name isn't already registered, so we will do it here instead.
	if (-not ($RegisteredPackageSources.Name -eq $Name)) {
		ThrowError -ExceptionName "System.ArgumentException" `
			-ExceptionMessage ($LocalizedData.PackageSourceNotFound -f $Name) `
			-ErrorId 'PackageSourceNotFound' `
			-ErrorCategory InvalidArgument
	}

	# Invoke-WinGet will throw an exception if unregistration fails
	Invoke-WinGet -SourceRemove -SourceName $Name
}
