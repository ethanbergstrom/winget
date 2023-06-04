[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='PSSA does not understand Pester scopes well')]
param()

BeforeAll {
	$WinGet = 'WinGet'
	Import-PackageProvider $WinGet
}

Describe 'basic package search operations' {
	Context 'without additional arguments' {
		BeforeAll {
			$package = 'CPUID.HWMonitor'
			$version = '1.44'
		}

		It 'gets a list of latest installed packages' {
			Get-Package -Provider $WinGet | Where-Object {$_.Source -eq 'winget'} | Should -Not -BeNullOrEmpty
		}
		It 'searches for the latest version of a package' {
			Find-Package -Provider $WinGet -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'returns all available versions of a package' {
			Find-Package -Provider $WinGet -Name $package -AllVersions | Where-Object {$_.Version -eq $version} | Should -Not -BeNullOrEmpty
		}
		It 'searches for all versions of a package' {
			Find-Package -Provider $WinGet -Name $package -AllVersions | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'pipeline-based package installation and uninstallation' {
	Context 'without additional arguments' {
		BeforeAll {
			$package = 'CPUID.HWMonitor'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Provider $WinGet -Name $package | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed' {
			Get-Package -Provider $WinGet -Name $package | Uninstall-Package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'version tests' {
	Context 'without additional arguments' {
		BeforeAll {
			$package = 'CPUID.HWMonitor'
			$minVersion = '1.43'
			$maxVersion = '1.44'
		}

		It 'retrieves and correctly filters versions within a range' {
			Find-Package -Provider $WinGet -Name $package -MaximumVersion $maxVersion -MinimumVersion $minVersion -AllVersions | Where-Object {$_.Name -contains $package} | Should -HaveCount 2
		}
	}
}

Describe "multi-source support" {
	BeforeAll {
		$altSourceName = 'AltWinGetSource'
		$altSourceLocation = 'https://winget.azureedge.net/cache'
		$package = 'CPUID.HWMonitor'
		$version = '1.44'

		Unregister-PackageSource -Name $altSourceName -Provider $WinGet -ErrorAction SilentlyContinue
	}
	AfterAll {
		Unregister-PackageSource -Name $altSourceName -Provider $WinGet -ErrorAction SilentlyContinue
	}

	It 'refuses to register a source with no location' {
		Register-PackageSource -Name $altSourceName -Provider $WinGet -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $altSourceName} | Should -BeNullOrEmpty
	}
	It 'registers an alternative package source' {
		Register-PackageSource -Name $altSourceName -Provider $WinGet -Location $altSourceLocation | Where-Object {$_.Name -eq $altSourceName} | Should -Not -BeNullOrEmpty
	}
	It 'searches for and installs the latest version of a package from an alternate source' {
		Find-Package -Provider $WinGet -Name $package -Source $altSourceName -RequiredVersion $version | Install-Package -Force | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
	}
	It 'unregisters an alternative package source' {
		Unregister-PackageSource -Name $altSourceName -Provider $WinGet
		Get-PackageSource -Provider $WinGet | Where-Object {$_.Name -eq $altSourceName} | Should -BeNullOrEmpty
	}
}
