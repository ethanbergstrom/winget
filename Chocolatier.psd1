@{
	RootModule = 'Chocolatier.psm1'
	ModuleVersion = '1.0.5'
	GUID = 'c1735ed7-8b2f-426a-8cbc-b7feb6b8288d'
	Author = 'Ethan Bergstrom'
	Copyright = ''
	Description = 'Package Management (OneGet) provider that facilitates installing Chocolatey packages from any NuGet repository.'
	# Refuse to load in CoreCLR if PowerShell below 7.1 due to regressions with how PS7 loads PackageManagement DLLs
	# https://github.com/PowerShell/PowerShell/pull/12203
	PowerShellVersion = if($PSEdition -eq 'Core') {
		'7.1.0'
	} else {
		'3.0'
	}
	RequiredModules = @(
		@{
			ModuleName='PackageManagement';
			ModuleVersion='1.1.7.2'
		}
	)
	PrivateData = @{
		PackageManagementProviders = 'Chocolatier.psm1'
		PSData = @{
			# Tags applied to this module to indicate this is a PackageManagement Provider.
			Tags = @('PackageManagement','Provider','Chocolatey','PSEdition_Desktop','PSEdition_Core','Windows')

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/ethanbergstrom/Chocolatier/blob/current/LICENSE.txt'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/ethanbergstrom/Chocolatier'

			# ReleaseNotes of this module
			ReleaseNotes = 'Please see https://github.com/ethanbergstrom/Chocolatier/blob/current/CHANGELOG.md for release notes'
		}
	}
}
