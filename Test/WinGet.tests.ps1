$WinGet = 'WinGet'

Import-PackageProvider $WinGet -Force

Describe "basic package search operations" {
	$package = 'rufus'

	It 'searches for the latest version of a package' {
		Find-Package -Provider $WinGet -Name $package | Where-Object {$_.Name -contains $package}  | Should Not BeNullOrEmpty
	}
}

Describe "DSC-compliant package installation and uninstallation" {
	$package = 'rufus'

	It 'searches for the latest version of a package' {
		Find-Package -Provider $WinGet -Name $package | Where-Object {$_.Name -contains $package} | Should Not BeNullOrEmpty
	}
	It 'silently installs the latest version of a package' {
		Install-Package -Provider $WinGet -Name $package -Force | Where-Object {$_.Name -contains $package} | Should Not BeNullOrEmpty
	}
}

Describe "pipline-based package installation and uninstallation" {
	$package = 'rufus'

	It 'searches for and silently installs the latest version of a package' {
		Find-Package -Provider $WinGet -Name $package | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should Not BeNullOrEmpty
	}
}

Describe "multi-source support" {
	BeforeAll {
		$altSourceName = 'AltWinGetSource'
		$altSourceLocation = 'https://winget.azureedge.net/cache'
		$package = 'rufus'

		Unregister-PackageSource -Name $altSourceName -Provider $WinGet -ErrorAction SilentlyContinue
	}
	AfterAll {
		Unregister-PackageSource -Name $altSourceName -Provider $WinGet -ErrorAction SilentlyContinue
	}

	It 'refuses to register a source with no location' {
		Register-PackageSource -Name $altSourceName -Provider $WinGet -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $altSourceName} | Should BeNullOrEmpty
	}
	It 'registers an alternative package source' {
		Register-PackageSource -Name $altSourceName -Provider $WinGet -Location $altSourceLocation | Where-Object {$_.Name -eq $altSourceName} | Should Not BeNullOrEmpty
	}
	It 'searches for and installs the latest version of a package from an alternate source' {
		Find-Package -Provider $WinGet -Name $package -source $altSourceName | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should Not BeNullOrEmpty
	}
	It 'unregisters an alternative package source' {
		Unregister-PackageSource -Name $altSourceName -Provider $WinGet
		Get-PackageSource -Provider $WinGet | Where-Object {$_.Name -eq $altSourceName} | Should BeNullOrEmpty
	}
}
