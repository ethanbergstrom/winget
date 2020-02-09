@{
	RootModule = 'Chocolatier.psm1'
	ModuleVersion = '1.0.3'
	GUID = 'c1735ed7-8b2f-426a-8cbc-b7feb6b8288d'
	Author = 'Ethan Bergstrom'
	Copyright = ''
	Description = 'Package Management (OneGet) provider that facilitates installing Chocolatey packages from any NuGet repository.'
	PowerShellVersion = '3.0'
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
			Tags = @("PackageManagement","Provider","Chocolatey")

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/PowerShell/PowerShell/blob/master/LICENSE.txt'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/ethanbergstrom/Chocolatier'

			# ReleaseNotes of this module
			ReleaseNotes = 'Choco.exe once again installs automatically after TLS 1.2 changes to chocolatey.org (https://github.com/ethanbergstrom/Chocolatier/issues/3)'
		}
	}
}
