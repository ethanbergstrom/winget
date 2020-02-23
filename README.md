# Chocolatier
Chocolatier is Package Management (OneGet) provider that facilitates installing Chocolatey packages from any NuGet repository. The provider is heavily influenced by the work of [Jianyun](https://github.com/jianyunt) and the [ChocolateyGet](https://github.com/jianyunt/ChocolateyGet) project.

[![Build status](https://ci.appveyor.com/api/projects/status/14pwjwch40ww0cxd?svg=true)](https://ci.appveyor.com/project/ethanbergstrom/chocolatier)

## Install Chocolatier
```PowerShell
Find-PackageProvider Chocolatier -verbose

Install-PackageProvider Chocolatier -verbose

Import-PackageProvider Chocolatier

# Run Get-PackageProvider to check if the Chocolatier provider is imported
Get-PackageProvider -verbose
```

## Sample usages
### Search for a package
```PowerShell
Find-Package -ProviderName Chocolatier -name  nodejs

Find-Package -ProviderName Chocolatier -name firefox*
```

### Install a package
```PowerShell
Find-Package nodejs -verbose -provider Chocolatier -AdditionalArguments --exact | Install-Package

Install-Package -name 7zip -verbose -ProviderName Chocolatier
```
### Get list of installed packages
```PowerShell
Get-Package nodejs -verbose -provider Chocolatier
```
### Uninstall a package
```PowerShell
Get-Package nodejs -provider Chocolatier -verbose | Uninstall-Package -AdditionalArguments '-y --remove-dependencies' -Verbose
```

### Manage package sources
```PowerShell
Register-PackageSource privateRepo -provider Chocolatier -location 'https://somewhere/out/there/api/v2/'
Find-Package nodejs -verbose -provider Chocolatier -source privateRepo -AdditionalArguments --exact | Install-Package
Unregister-PackageSource privateRepo -provider Chocolatier
```

Chocolatier integrates with Choco.exe to manage and store source information

## Pass in choco arguments
If you need to pass in some of choco arguments to the Find, Install, Get and UnInstall-Package cmdlets, you can use AdditionalArguments PowerShell property.

## DSC Compatibility
Fully compatible with the PackageManagement DSC resources
```PowerShell
Configuration MyNode {
	Import-DscResource -Name PackageManagement,PackageManagementSource 
	PackageManagement Chocolatier {
		Name = 'Chocolatier'
		Source = 'PSGallery'
	}
	PackageManagementSource ChocoPrivateRepo {
		Name = 'privateRepo'
		ProviderName = 'Chocolatier'
		SourceLocation = 'https://somewhere/out/there/api/v2/'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]Chocolatier'
	}
	PackageManagement NodeJS {
		Name = 'nodejs'
		Source = 'privateRepo'
		DependsOn = '[PackageManagementSource]ChocoPrivateRepo'
	}
}
```

## Keep packages up to date
A common complaint of PackageManagement/OneGet is it doesn't allow for updating installed packages, while Chocolatey does.
  In order to reconcile the two, Chocolatier has a reserved keyword 'latest' that when passed as a Required Version can compare the version of what's currently installed against what's in the repository.
```PowerShell

PS C:\Users\ethan> Find-Package curl -RequiredVersion latest -ProviderName chocolatier

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           7.68.0           chocolatey

PS C:\Users\ethan> Install-Package curl -RequiredVersion 7.60.0 -ProviderName chocolatier -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           v7.60.0          chocolatey

PS C:\Users\ethan> Get-Package curl -RequiredVersion latest -ProviderName chocolatier
Get-Package : No package found for 'curl'.
At line:1 char:1
+ Get-Package curl -RequiredVersion latest -ProviderName chocolatier
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (Microsoft.Power...lets.GetPackage:GetPackage) [Get-Package], Exception
    + FullyQualifiedErrorId : NoMatchFound,Microsoft.PowerShell.PackageManagement.Cmdlets.GetPackage

PS C:\Users\ethan> Install-Package curl -RequiredVersion latest -ProviderName chocolatier -Force

Name                           Version          Source           Summary
----                           -------          ------           -------
curl                           v7.68.0          chocolatey

PS C:\Users\ethan> Get-Package curl -RequiredVersion latest -ProviderName chocolatier

Name                           Version          Source                           ProviderName
----                           -------          ------                           ------------
curl                           7.68.0           Chocolatey                       Chocolatier

```

This feature can be combined with a PackageManagement-compatible configuration management system (ex: [PowerShell DSC LCM in 'ApplyAndAutoCorrect' mode](https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/metaconfig)) to regularly keep certain packages up to date:
```PowerShell
Configuration MyNode {
	Import-DscResource -Name PackageManagement
	PackageManagement Chocolatier {
		Name = 'Chocolatier'
		Source = 'PSGallery'
	}
	PackageManagement SysInternals {
		Name = 'sysinternals'
		RequiredVersion = 'latest'
		ProviderName = 'chocolatier'
		DependsOn = '[PackageManagement]Chocolatier'
	}
}
```

**Please note** - Since Chocolatey doesn't track source information of installed packages, and since PackageManagement doesn't support passing source information when invoking `Get-Package`, the 'latest' functionality **will not work** if Chocolatey.org is removed as a source **and** multiple custom sources are defined.

Furthermore, if both Chocolatey.org and a custom source are configured, the custom source **will be ignored** when the 'latest' required version is used with `Get-Package`.

Example PowerShell DSC configuration using the 'latest' required version with a custom source:

```PowerShell
Configuration MyNode {
	Import-DscResource -Name PackageManagement,PackageManagementSource 
	PackageManagement Chocolatier {
		Name = 'Chocolatier'
		Source = 'PSGallery'
	}
	PackageManagementSource ChocoPrivateRepo {
		Name = 'privateRepo'
		ProviderName = 'Chocolatier'
		SourceLocation = 'https://somewhere/out/there/api/v2/'
		InstallationPolicy = 'Trusted'
		DependsOn = '[PackageManagement]Chocolatier'
	}
	PackageManagementSource ChocolateyRepo {
		Name = 'Chocolatey'
		ProviderName = 'Chocolatier'
		Ensure = 'Absent'
		DependsOn = '[PackageManagement]Chocolatier'
	}
	PackageManagement NodeJS {
		Name = 'nodejs'
		Source = 'privateRepo'
		RequiredVersion = 'latest'
		DependsOn = @('[PackageManagementSource]ChocoPrivateRepo', '[PackageManagementSource]ChocolateyRepo')
	}
}
```

If using the 'latest' functionality, best practice is to either:
* use the default Chocolatey.org source
* unregister the default Chocolatey.org source in favor of a **single** custom source

## Known Issues
Currently Chocolatier works on Full CLR.
It is not supported on CoreClr.
This means Chocolatier provider is not supported on Nano server or Linux OSs.
The primarily reason is that the current version of choco.exe does not seem to support on CoreClr yet.

### Save a package
Save-Package is not supported for Chocolatier provider.
It is because Chocolatier is a wrapper of choco.exe which currently does not support downloading packages without special licensing.

## Legal and Licensing
Chocolatier is licensed under the [MIT license](./LICENSE.txt).
