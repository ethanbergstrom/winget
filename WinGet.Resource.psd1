ConvertFrom-StringData @'
###PSLOC
	ProviderDebugMessage='WinGet': '{0}'.
	FastPackageReference='WinGet': The FastPackageReference is '{0}'.

	SearchingForPackage=Searching for package
	InstallingPackage=Installing package
	FindingLocalPackage=Finding local packages
	UnInstallingPackage=UnInstalling package
	ProcessingPackage=Processing package
	CheckingWinGet=Checking if a newer version of WinGet available
	UpgradingWinGet=Upgrading WinGet
	Complete=Complete

	SearchingEntireRepo=Searching the entire repo is not supported. Please specify package name.
	WinGetUnSupportedOnCoreCLR='{0}': WinGet is not supported on CoreCLR (Nano Server or *nix).

	SearchVersionNotSupported='WinGet': WinGet does not support seaching for a specific version. Returning all versions instead.
	SavePackageNotSupported='WinGet': Save-Package is not supported because WinGet does not support downloading packages.
	GetPackageNotSupported='WinGet': Get-Package is not supported because WinGet does not support listing installed packages.
	UninstallPackageNotSupported='WinGet': Uninstall-Package is not supported because WinGet does not support uninstalling installed packages.

	InstallWinGetExeShouldContinueQuery=WinGet is built on WinGet.exe. Do you want WinGet to install WinGet.exe from 'https://github.com/microsoft/winget-cli' now?
	InstallWinGetExeShouldContinueCaption=WinGet.exe is required to continue
	UserDeclined=User declined to {0} WinGet.

	NotInstalled=Package '{0}' is not installed.
	FailToInstall=Failed to install the package because the fast reference '{0}' is incorrect.
	FailToUninstall=Failed to uninstall the package because the fast reference '{0}' is incorrect.
	FailToInstallWinGet=WinGet installed failed. You may relaunch PowerShell as elevated mode and try again.
	OperationFailed='{0}' '{1}' Failed. You may relaunch PowerShell as elevated mode or try again with -Verbose -Debug to get more information.
	FoundNewerWinGet=Found WinGet version '{0}' is greater than the installed one '{1}'
	InvalidVersionFormat=Version '{0}' does not match the regex '{1}'
	UnexpectedWinGetResponse=Successful output from WinGet.exe for fast reference '{0}' did not match the exepected format. Please review WinGet logs for more information.

	OperationSucceed='{0}' '{1}' Successfully.
	WinGetFound=Found WinGet.exe in '{0}'.
	WinGetNotFound=Unable to find WinGet.exe under $PATH.
	InstallPackageQuery={0} package '{1}'. By {0} you accept licenses for the package(s). The package possibly needs to run 'WinGetInstall.ps1'.
	InstallPackageCaption=Are you sure you want to perform this action?

	NameShouldNotContainWildcardCharacters=The specified name '{0}' should not contain any wildcard characters, please correct it and try again.
	AllVersionsCannotBeUsedWithOtherVersionParameters=You cannot use the parameter AllVersions with RequiredVersion, MinimumVersion or MaximumVersion in the same command.
	VersionRangeAndRequiredVersionCannotBeSpecifiedTogether=You cannot use the parameters RequiredVersion and either MinimumVersion or MaximumVersion in the same command. Specify only one of these parameters in your command.
	RequiredVersionAllowedOnlyWithSingleModuleName=The RequiredVersion parameter is allowed only when a single module name is specified as the value of the Name parameter, without any wildcard characters.
	MinimumVersionIsGreaterThanMaximumVersion=The specified MinimumVersion '{0}' is greater than the specified MaximumVersion '{1}'.
	VersionParametersAreAllowedOnlyWithSingleName=The RequiredVersion, MinimumVersion, MaximumVersion or AllVersions parameters are allowed only when you specify a single name as the value of the Name parameter, without any wildcard characters.

	PackageSourceNameContainsWildCards=The package source name '{0}' should not have wildcards, correct it and try again.
	SourceRegistered=Successfully registered the package source '{0}' with location '{1}'.
	PackageSourceDetails=Package source details, Name = '{0}', Location = '{1}'; IsTrusted = '{2}'; IsRegistered = '{3}'.
	PackageSourceNotFound=No package source with the name '{0}' was found.
	PackageSourceUnregistered=Successfully unregistered the Package source '{0}'.
	SpecifiedSourceName=Using the specified source names: '{0}'.
	NoSourceNameIsSpecified=The Source parameter was not specified. We will use all of the registered package sources.
	UnspecifiedSource=Multiple non-default sources are available, but the default source is not. A source name must be specified.

###PSLOC
'@
