function Install-ChocoBinaries {
	[CmdletBinding()]
	[OutputType([bool])]

	param (
	)

	if ($PSEdition -Match 'Core') {
		ThrowError -ExceptionName 'System.NotSupportedException' `
			-ExceptionMessage ($LocalizedData.ChocoUnSupportedOnCoreCLR -f $script:ProviderName) `
			-ErrorId 'ChocoUnSupportedOnCoreCLR' `
			-ErrorCategory NotImplemented `
			-ExceptionObject $PSEdition
	}

	# If the user opts not to install Chocolatey, throw an exception
	if (-not ((Get-ForceProperty) -or $request.ShouldContinue($LocalizedData.InstallChocoExeShouldContinueQuery, $LocalizedData.InstallChocoExeShouldContinueCaption))) {
		ThrowError -ExceptionName 'System.OperationCanceledException' `
			-ExceptionMessage ($LocalizedData.UserDeclined -f "install") `
			-ErrorId 'UserDeclined' `
			-ErrorCategory InvalidOperationException `
			-ExceptionObject $PSEdition
	}

	# install choco based on https://chocolatey.org/install#before-you-install
	try {
		Write-Verbose 'Installing Chocolatey'
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
		Invoke-WebRequest 'https://chocolatey.org/install.ps1' -UseBasicParsing | Invoke-Expression > $null
	} catch {
		ThrowError -ExceptionName 'System.OperationCanceledException' `
			-ExceptionMessage $LocalizedData.FailToInstallChoco `
			-ErrorID 'FailToInstallChoco' `
			-ErrorCategory InvalidOperation `
			-ExceptionObject $job
	}

	Get-ChocoPath
}
