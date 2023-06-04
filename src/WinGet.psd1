@{
	RootModule = 'WinGet.psm1'
	ModuleVersion = '0.1.0'
	GUID = '468ef37a-2557-4c10-92ec-783ec1e41639'
	Author = 'Ethan Bergstrom'
	Copyright = ''
	Description = 'Package Management (OneGet) provider that facilitates installing WinGet packages from any NuGet repository.'
	# Refuse to load in CoreCLR if PowerShell below 7.0.1 due to regressions with how 7.0 loads PackageManagement DLLs
	# https://github.com/PowerShell/PowerShell/pull/12203
	PowerShellVersion = '7.0.1'
	RequiredModules = @(
		@{
			ModuleName='PackageManagement'
			ModuleVersion='1.1.7.2'
		},
		@{
			ModuleName='Microsoft.WinGet.Client'
			ModuleVersion='0.2.1'
		}
	)
	PrivateData = @{
		PackageManagementProviders = 'WinGet.psm1'
		PSData = @{
			# Tags applied to this module to indicate this is a PackageManagement Provider.
			Tags = @('PackageManagement','Provider','WinGet','PSEdition_Desktop','PSEdition_Core','Windows')

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/ethanbergstrom/WinGet/blob/current/LICENSE.txt'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/ethanbergstrom/WinGet'

			# ReleaseNotes of this module
			ReleaseNotes = 'Please see https://github.com/ethanbergstrom/winget/blob/master/CHANGELOG.md for release notes'
		}
	}
}
