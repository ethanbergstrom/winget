# WinGet
WinGet is Package Management (OneGet) provider that facilitates installing WinGet packages from any repository. The provider is heavily influenced by the work of the [Chocolatier](https://github.com/ethanbergstrom/Chocolatier) project.

## Install WinGet
```PowerShell
Install-PackageProvider WinGet -Force
```

## Sample usages
### Search for a package
```PowerShell
Find-Package -Provider WinGet -Name nodejs

Find-Package -Provider WinGet -Name firefox
```

### Install a package
```PowerShell
Find-Package nodejs -Provider WinGet | Install-Package

Install-Package -Name firefox -Provider WinGet
```

### Manage package sources
```PowerShell
Register-PackageSource privateRepo -Provider WinGet -Location https://somewhere/out/there/api/v2/
Find-Package nodejs -Provider WinGet -Source privateRepo | Install-Package
Unregister-PackageSource privateRepo -Provider WinGet
```

WinGet integrates with WinGet.exe to manage and store source information

## DSC Compatibility
Fully compatible with the PackageManagement DSC resources
```PowerShell
Configuration MyNode {
	Import-DscResource -Name PackageManagement,PackageManagementSource
	PackageManagement WinGet {
		Name = 'WinGet'
		Source = 'PSGallery'
	}
	PackageManagementSource WinGetPrivateRepo {
		Name = 'privateRepo'
		ProviderName = 'WinGet'
		SourceLocation = 'https://somewhere/out/there/api/v2/'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]WinGet'
	}
	PackageManagement NodeJS {
		Name = 'nodejs'
		Source = 'privateRepo'
		DependsOn = '[PackageManagementSource]WinGetPrivateRepo'
	}
}
```

## Known Issues
WinGet is still in a preview period, with many features not implemented that are required for a PackageManagement provider to be properly implemented.

Unsupported features currently include:
* Listing installed packages
* Upgrading installed packages
* Uninstalling packages
* Searching for packages by version range
* Saving packages
* Passing install arguments to packages

## Legal and Licensing
WinGet is licensed under the [MIT license](./LICENSE.txt).
