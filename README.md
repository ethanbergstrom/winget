# WinGet
WinGet is Package Management (OneGet) provider that facilitates installing WinGet packages from any repository. The provider is heavily influenced by the work of [Jianyun](https://github.com/jianyunt) and the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) project.

[![Build status](https://ci.appveyor.com/api/projects/status/14pwjwch40ww0cxd?svg=true)](https://ci.appveyor.com/project/ethanbergstrom/WinGet)

## Install WinGet
```PowerShell
Install-PackageProvider WinGet -Force
```

## Sample usages
### Search for a package
```PowerShell
Find-Package -Provider WinGet -Name nodejs

Find-Package -Provider WinGet -Name firefox*
```

### Install a package
```PowerShell
Find-Package nodejs -Verbose -Provider WinGet -AdditionalArguments --Exact | Install-Package

Install-Package -Name 7zip -Verbose -Provider WinGet
```
### Get list of installed packages
```PowerShell
Get-Package nodejs -Verbose -Provider WinGet
```
### Uninstall a package
```PowerShell
Get-Package nodejs -Provider WinGet -Verbose | Uninstall-Package -Verbose
```

### Manage package sources
```PowerShell
Register-PackageSource privateRepo -Provider WinGet -Location 'https://somewhere/out/there/api/v2/'
Find-Package nodejs -Verbose -Provider WinGet -Source privateRepo -AdditionalArguments --exact | Install-Package
Unregister-PackageSource privateRepo -Provider WinGet
```

WinGet integrates with WinGet.exe to manage and store source information

## Pass in WinGet arguments
If you need to pass in some of WinGet arguments to the Find, Install, Get and Uninstall-Package cmdlets, you can use AdditionalArguments PowerShell property.

```powershell
Install-Package sysinternals -Provider WinGet -AcceptLicense -AdditionalArguments '--paramsglobal --params "/InstallDir=c:\windows\temp\sysinternals /QuickLaunchShortcut=false" -y --installargs MaintenanceService=false' -Verbose
```

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

## Keep packages up to date
A common complaint of PackageManagement/OneGet is it doesn't allow for updating installed packages, while WinGet does.
  In order to reconcile the two, WinGet has a reserved keyword 'latest' that when passed as a Required Version can compare the version of what's currently installed against what's in the repository.
```PowerShell

PS C:\Users\ethan> Find-Package curl -RequiredVersion latest -Provider WinGet

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           7.68.0           WinGet

PS C:\Users\ethan> Install-Package curl -RequiredVersion 7.60.0 -Provider WinGet -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           v7.60.0          WinGet

PS C:\Users\ethan> Get-Package curl -RequiredVersion latest -Provider WinGet
Get-Package : No package found for 'curl'.
At line:1 char:1
+ Get-Package curl -RequiredVersion latest -Provider WinGet
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (Microsoft.Power...lets.GetPackage:GetPackage) [Get-Package], Exception
    + FullyQualifiedErrorId : NoMatchFound,Microsoft.PowerShell.PackageManagement.Cmdlets.GetPackage

PS C:\Users\ethan> Install-Package curl -RequiredVersion latest -Provider WinGet -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           v7.68.0          WinGet

PS C:\Users\ethan> Get-Package curl -RequiredVersion latest -Provider WinGet

Name                           Version          Source                           ProviderName
----                           -------          ------                           ------------
curl                           7.68.0           WinGet                           WinGet

```

This feature can be combined with a PackageManagement-compatible configuration management system (ex: [PowerShell DSC LCM in 'ApplyAndAutoCorrect' mode](https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/metaconfig)) to regularly keep certain packages up to date:
```PowerShell
Configuration MyNode {
	Import-DscResource -Name PackageManagement
	PackageManagement WinGet {
		Name = 'WinGet'
		Source = 'PSGallery'
	}
	PackageManagement SysInternals {
		Name = 'sysinternals'
		RequiredVersion = 'latest'
		ProviderName = 'WinGet'
		DependsOn = '[PackageManagement]WinGet'
	}
}
```

**Please note** - Since WinGet doesn't track source information of installed packages, and since PackageManagement doesn't support passing source information when invoking `Get-Package`, the 'latest' functionality **will not work** if WinGet.org is removed as a source **and** multiple custom sources are defined.

Furthermore, if both WinGet.org and a custom source are configured, the custom source **will be ignored** when the 'latest' required version is used with `Get-Package`.

Example PowerShell DSC configuration using the 'latest' required version with a custom source:

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
	PackageManagementSource WinGetRepo {
		Name = 'WinGet'
		ProviderName = 'WinGet'
		Ensure = 'Absent'
		DependsOn = '[PackageManagement]WinGet'
	}
	# The source information wont actually be used by the Get-Package step of the PackageManagement DSC resource check, but it helps make clear to the reader where the package should come from
	PackageManagement NodeJS {
		Name = 'nodejs'
		Source = 'privateRepo'
		RequiredVersion = 'latest'
		DependsOn = @('[PackageManagementSource]WinGetPrivateRepo', '[PackageManagementSource]WinGetRepo')
	}
}
```

If using the 'latest' functionality, best practice is to either:
* use the default WinGet.org source
* unregister the default WinGet.org source in favor of a **single** custom source

## Experimental features
### API integration
WinGet can invoke WinGet through it's native API rather than through interpreting CLI output, which does not require a local installation of WinGet.exe

The provider's standard battery of tests run about **36% faster** under the native API versus using the CLI interpreter, with operations that don't invoke a package (searching for packages, registering sources, etc.) running about **10x faster**.

By default, WinGet will continue to use CLI output (for now), but native API support can be enabled in PowerShell 5.1 and below sessions before the provider is first invoked:
```PowerShell
$env:WinGet_NATIVEAPI = $true
Find-Package -Provider WinGet -Name nodejs
```

If WinGet.exe is already installed, the Native API will detect the existing WinGet installation path and leverage it for maintaining local package and source metadata.

Invoking the provider with the Native API is the first use of WinGet on your system, the provider will instruct the Native API to align where it extracts its files with the standard used by WinGet.exe (%ProgramData%/WinGet) to avoid diverging locations of package and source metadata.

## Known Issues
### Compatibility
WinGet works with PowerShell for both FullCLR/'Desktop' (ex 5.1) and CoreCLR (ex: 7.0.1), though WinGet itself still requires FullCLR.

When used with CoreCLR, PowerShell 7.0.1 is a minimum requirement due to [a compatibility issue in PowerShell 7.0](https://github.com/PowerShell/PowerShell/pull/12203).

### Save a package
Save-Package is not supported with the WinGet provider, due to WinGet not supporting package downloads without special licensing. If you wish to save NuGet packages, check out the [PackageManagement Nuget provider](https://github.com/OneGet/NuGetProvider).

## Legal and Licensing
WinGet is licensed under the [MIT license](./LICENSE.txt).
