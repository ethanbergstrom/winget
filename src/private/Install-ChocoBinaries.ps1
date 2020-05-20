function Install-WinGetBinaries {
	[CmdletBinding()]
	[OutputType([bool])]

	param (
	)

	# If the user opts not to install WinGet, throw an exception
	if (-not (((Get-ForceProperty) -or (Get-AcceptLicenseProperty)) -or $request.ShouldContinue($LocalizedData.InstallWinGetExeShouldContinueQuery, $LocalizedData.InstallWinGetExeShouldContinueCaption))) {
		ThrowError -ExceptionName 'System.OperationCanceledException' `
			-ExceptionMessage ($LocalizedData.UserDeclined -f "install") `
			-ErrorId 'UserDeclined' `
			-ErrorCategory InvalidOperationException `
			-ExceptionObject $PSEdition
	}

	# install WinGet based on https://WinGet.org/install#before-you-install
	try {
		Write-Verbose 'Installing WinGet'

		# WinGet.org requires TLS 1.2 (or newer) ciphers to establish a connection.
		# Older versions of PowerShell / .NET are opinionated about which ciphers to support, while newer versions default to whatever ciphers the OS supports.
		# If .NET isn't falling back on the OS defaults, explicitly add TLS 1.2 as a supported cipher for this session, otherwise let the OS take care of it.
		# https://docs.microsoft.com/en-us/security/solving-tls1-problem#update-windows-powershell-scripts-or-related-registry-settings
		if (-not ([Net.ServicePointManager]::SecurityProtocol -eq [Net.SecurityProtocolType]::SystemDefault)) {
			[Net.ServicePointManager]::SecurityProtocol = ([Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12)
		}

		Invoke-WebRequest 'https://WinGet.org/install.ps1' -UseBasicParsing | Invoke-Expression > $null
	} catch {
		ThrowError -ExceptionName 'System.OperationCanceledException' `
			-ExceptionMessage $LocalizedData.FailToInstallWinGet `
			-ErrorID 'FailToInstallWinGet' `
			-ErrorCategory InvalidOperation `
			-ExceptionObject $job
	}
	Get-WinGetPath
}
