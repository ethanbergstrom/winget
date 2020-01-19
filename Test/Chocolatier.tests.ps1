
$Chocolatier = "Chocolatier"

import-module packagemanagement
Get-Packageprovider -verbose
$provider = Get-PackageProvider -verbose -ListAvailable
if($provider.Name -notcontains $Chocolatier)
{
	$a= Find-PackageProvider -Name $Chocolatier -verbose -ForceBootstrap

	if($a.Name -eq $Chocolatier)
	{
		Install-PackageProvider $Chocolatier -verbose -force
	}
	else
	{
		Write-Error "Fail to find $Chocolatier provider"
	}
}

Import-PackageProvider $Chocolatier -force

Describe "Chocolatier testing" -Tags @('BVT', 'DRT') {
	AfterAll {
		#reset the environment variable
		$env:BootstrapProviderTestfeedUrl=""
	}

	It "get-package" {
		$a=get-package -ProviderName $Chocolatier -verbose
		$a | should not BeNullOrEmpty

		$b=get-package -ProviderName $Chocolatier -name chocolatey -allversions -verbose
		$b | ?{ $_.name -eq "chocolatey" } | should not BeNullOrEmpty
	}

		It "find-package" {

		$a=find-package -ProviderName $Chocolatier -name  cpu-z -ForceBootstrap -force -verbose
		$a | ?{ $_.name -eq "cpu-z" } | should not BeNullOrEmpty

		$b=find-package -ProviderName $Chocolatier -name  cpu-z -allversions -verbose
		$b | ?{ $_.name -eq "cpu-z" } | should not BeNullOrEmpty

		$c=find-package -ProviderName $Chocolatier -name cpu-z -AdditionalArguments --exact -verbose
		$c | ?{ $_.name -eq "cpu-z" } | should not BeNullOrEmpty
	}

	It "find-package with wildcard search" {

		$d=find-package -ProviderName $Chocolatier -name *firefox -Verbose
		$d | ?{ $_.name -eq "firefox" } | should not BeNullOrEmpty

	}

	It "find-install-package cpu-z" {

		$package = "cpu-z"
		$a=find-package $package -verbose -provider $Chocolatier -AdditionalArguments --exact | install-package -force -verbose
		$a.Name -contains $package | Should Be $true

		$b = get-package $package -verbose -provider $Chocolatier
		$b.Name -contains $package | Should Be $true

		$c= Uninstall-package $package -verbose -ProviderName $Chocolatier -AdditionalArguments '-y --remove-dependencies'
		$c.Name -contains $package | Should Be $true
	}

	It "install-package with zip, get-uninstall-package" {

		$package = "7zip"

		$a= install-package -name $package -verbose -ProviderName $Chocolatier -force
		$a.Name -contains $package | Should Be $true

		$a=get-package $package -provider $Chocolatier -verbose | uninstall-package -AdditionalArguments '-y --remove-dependencies' -Verbose
		$a.Name -contains $package | Should Be $true
	}
}

Describe "Chocolatier multi-source testing" -Tags @('BVT', 'DRT') {
	BeforeAll {
		$altSourceName = "LocalChocoSource"
		$altSourceLocation = $PSScriptRoot
		$package = "cpu-z"

		Save-Package $package -Source 'http://chocolatey.org/api/v2' -Path $altSourceLocation
		Unregister-PackageSource -Name $altSourceName -ProviderName $Chocolatier -ErrorAction SilentlyContinue
	}
	AfterAll {
		Remove-item $altSourceLocation\$package* -Force -ErrorAction SilentlyContinue
		Unregister-PackageSource -Name $altSourceName -ProviderName $Chocolatier -ErrorAction SilentlyContinue
	}

	It "refuses to register a source with no location" {
		$a = Register-PackageSource -Name $altSourceName -ProviderName $Chocolatier -Verbose -ErrorAction SilentlyContinue
		$a.Name -eq $altSourceName | Should Be $false
	}

	It "installs and uninstalls from an alternative package source" {

		$a = Register-PackageSource -Name $altSourceName -ProviderName $Chocolatier -Location $altSourceLocation -Verbose
		$a.Name -eq $altSourceName | Should Be $true

		$b=find-package $package -verbose -provider $Chocolatier -source $altSourceName -AdditionalArguments --exact | install-package -force
		$b.Name -contains $package | Should Be $true

		$c = get-package $package -verbose -provider $Chocolatier
		$c.Name -contains $package | Should Be $true

		$d= Uninstall-package $package -verbose -ProviderName $Chocolatier -AdditionalArguments '-y --remove-dependencies'
		$d.Name -contains $package | Should Be $true

		Unregister-PackageSource -Name $altSourceName -ProviderName $Chocolatier
		$e = Get-PackageSource -ProviderName $Chocolatier
		$e.Name -eq $altSourceName | Should Be $false
	}
}

Describe "Chocolatier DSC integration with args/params support" -Tags @('BVT', 'DRT') {
	$package = "sysinternals"

	$argsAndParams = "--paramsglobal --params ""/InstallDir=c:\windows\temp\sysinternals /QuickLaunchShortcut=false"" -y --installargs MaintenanceService=false"

	It "finds, installs and uninstalls packages when given installation arguments parameters that would otherwise cause search to fail" {

		$a = find-package $package -verbose -provider $Chocolatier -AdditionalArguments $argsAndParams
		$a = install-package $a -force -AdditionalArguments $argsAndParams -Verbose
		$a.Name -contains $package | Should Be $true

		$b = get-package $package -verbose -provider $Chocolatier -AdditionalArguments $argsAndParams
		$b.Name -contains $package | Should Be $true

		$c = Uninstall-package $package -verbose -ProviderName $Chocolatier -AdditionalArguments $argsAndParams
		$c.Name -contains $package | Should Be $true

	}
}
Describe "Chocolatier support for 'latest' RequiredVersion value with DSC support" -Tags @('BVT', 'DRT') {

	$package = "curl"
	$version = "7.60.0"

	AfterEach {
		Uninstall-Package -Name $package -Verbose -ProviderName $Chocolatier -Force -ErrorAction SilentlyContinue
	}

	It "does not find the 'latest' locally installed version if an outdated version is installed" {
		$a = install-package -name $package -requiredVersion $version -verbose -ProviderName $Chocolatier -Force
		$a.Name -contains $package | Should Be $true

		$b = get-package $package -requiredVersion 'latest' -verbose -provider $Chocolatier -ErrorAction SilentlyContinue
		$b.Name -contains $package | Should Be $false
	}

	It "finds, installs, and uninstalls the latest version when the 'latest' RequiredVersion value is set" {
		$a = find-package $package -requiredversion 'latest' -verbose -provider $Chocolatier
		$a = install-package $a -force -Verbose
		$a.Name -contains $package | Should Be $true

		$b = get-package $package -requiredversion 'latest' -verbose -provider $Chocolatier
		$b = Uninstall-package $b -verbose
		$b.Name -contains $package | Should Be $true
	}
}
