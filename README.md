[![CI](https://github.com/ethanbergstrom/winget/actions/workflows/CI.yml/badge.svg)](https://github.com/ethanbergstrom/winget/actions/workflows/CI.yml)

# WinGet for PackageManagement
WinGet for PackageManagement facilitates installing WinGet packages from any compatible repository. The provider is heavily influenced by the work of the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) project.

## Requirements
Your machine must have at least Windows 10 1709 or Windows 11, PowerShell 7.0.1+, and the WinGet CLI utility installed. It may be already installed on your machine, but if not, Microsoft's recommended method for installing WinGet is via the Microsoft Store as part of the [App Installer](https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1?activetab=pivot:overviewtab) package.

**The WinGet Package Management Provider does not install the WinGet CLI utility. Please make sure the WinGet CLI utility is functional before attempting to use the WinGet PackageManagement provider!**

## Install WinGet
```PowerShell
Install-PackageProvider WinGet -Force
```
Note: Please do **not** use `Import-Module` with Package Management providers, as they are not meant to be imported in that manner. Either use `Import-PackageProvider` or specify the provider name with the `-Provider` argument to the PackageManagement cmdlets, such as in the examples below:

## Sample usages
### Search for a package
```PowerShell
Find-Package OpenJS.NodeJS -Provider WinGet
```

### Find all available versions of a package
```PowerShell
Find-Package Mozilla.Firefox -Provider WinGet -AllVersions
```

### Install a package
```PowerShell
Find-Package OpenJS.NodeJS -Provider WinGet | Install-Package -Force

Install-Package Git.Git -Provider WinGet -Force
```

### Get list of installed packages (with wildcard search support)
```PowerShell
Get-Package Microsoft.* -Provider WinGet
```

### Uninstall a package
```PowerShell
Get-Package OpenJS.NodeJS -Provider WinGet | Uninstall-Package

Uninstall-Package Git.Git -Provider WinGet
```

### Manage package sources
```PowerShell
Register-PackageSource privateRepo -Provider WinGet -Location 'https://somewhere/out/there/cache'
Find-Package OpenJS.NodeJS -Provider WinGet -Source privateRepo | Install-Package
Unregister-PackageSource privateRepo -Provider WinGet
```

The WinGet PackageManagement provider integrates with WinGet.exe to manage and store package source information.

## DSC Compatibility
Fully compatible with the PackageManagement DSC resources
```PowerShell
Configuration MyNode {
	Import-DscResource PackageManagement,PackageManagementSource
	PackageManagement WinGet {
		Name = 'WinGet'
		Source = 'PSGallery'
	}
	PackageManagementSource WinGetPrivateRepo {
		Name = 'privateRepo'
		ProviderName = 'WinGet'
		SourceLocation = 'https://somewhere/out/there/cache'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]WinGet'
	}
	PackageManagement NodeJS {
		Name = 'OpenJS.NodeJS'
		Source = 'privateRepo'
		DependsOn = '[PackageManagementSource]WinGetPrivateRepo'
	}
}
```

## Keep packages up to date
A common complaint of PackageManagement/OneGet is it doesn't allow for updating installed packages, while WinGet does.
In order to reconcile the two, WinGet has a reserved keyword 'latest' that when passed as a Required Version can compare the version of what's currently installed against what's in the repository.
```PowerShell

PS C:\Users\ethan> Get-Package OpenJS.NodeJS -Provider WinGet

Name                           Version          Source           Summary
----                           -------          ------           -------
OpenJS.NodeJS                  16.0.0           winget

PS C:\Users\ethan> Get-Package OpenJS.NodeJS -Provider WinGet -RequiredVersion latest
Get-Package : No package found for 'OpenJS.NodeJS'.

PS C:\Users\ethan> Install-Package OpenJS.NodeJS -Provider WinGet -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
OpenJS.NodeJS                  17.2.0           winget

PS C:\Users\ethan> Get-Package OpenJS.NodeJS -Provider WinGet -RequiredVersion latest

Name                           Version          Source           Summary
----                           -------          ------           -------
OpenJS.NodeJS                  17.2.0           winget

```

## Known Issues
WinGet is still in a preview period, with many features not implemented that are required for a PackageManagement provider to be fully implemented.

Unsupported features currently include:
* Passing install arguments to packages
* Saving a package

## Legal and Licensing
WinGet is licensed under the [MIT license](./LICENSE.txt).
