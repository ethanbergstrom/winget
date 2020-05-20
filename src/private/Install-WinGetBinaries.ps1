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

		# Older versions of PowerShell / .NET are opinionated about which ciphers to support, while newer versions default to whatever ciphers the OS supports.
		# If .NET isn't falling back on the OS defaults, explicitly add TLS 1.2 as a supported cipher for this session, otherwise let the OS take care of it.
		# https://docs.microsoft.com/en-us/security/solving-tls1-problem#update-windows-powershell-scripts-or-related-registry-settings
		if (-not ([Net.ServicePointManager]::SecurityProtocol -eq [Net.SecurityProtocolType]::SystemDefault)) {
			[Net.ServicePointManager]::SecurityProtocol = ([Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12)
		}

		# Get the latest released AppX bundle from GitHub and install it
		Add-AppxPackage -Path (Invoke-WebRequest 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' -UseBasicParsing | Select-Object -ExpandProperty Content | ConvertFrom-Json | Select-Object -ExpandProperty Assets | Select-Object -ExpandProperty browser_download_url)
	} catch {
		ThrowError -ExceptionName 'System.OperationCanceledException' `
			-ExceptionMessage $LocalizedData.FailToInstallWinGet `
			-ErrorID 'FailToInstallWinGet' `
			-ErrorCategory InvalidOperation `
			-ExceptionObject $job
	}
	Get-WinGetPath
}
