function Find-WinGetPackage {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification='Versions may not always be used, but are still required')]
	param (
		[Parameter(Mandatory=$true)]
		[string]
		$Name,

		[Parameter()]
		[string]
		$RequiredVersion,

		[Parameter()]
		[string]
		$MinimumVersion,

		[Parameter()]
		[string]
		$MaximumVersion
	)

	Write-Debug ($LocalizedData.ProviderDebugMessage -f ('Find-WinGetPackage'))

	$options = $request.Options
	[array]$RegisteredPackageSources = Cobalt\Get-WinGetSource

	$selectedSource = $(
		if ($options -And $options.ContainsKey('Source')) {
			# Finding the matched package sources from the registered ones
			if ($RegisteredPackageSources.Name -eq $options['Source']) {
				# Found the matched registered source
				$options['Source']
			} else {
				ThrowError -ExceptionName 'System.ArgumentException' `
				-ExceptionMessage ($LocalizedData.PackageSourceMissing) `
				-ErrorId 'PackageSourceMissing' `
				-ErrorCategory InvalidArgument `
			}
		} else {
			# User did not specify a source. Now what?
			if ($RegisteredPackageSources.Count -eq 1) {
				# If no source name is specified and only one source is available, use that source
				$RegisteredPackageSources[0].Name
			} elseif ($RegisteredPackageSources.Name -eq $script:PackageSource) {
				# If multiple sources are avaiable but none specified, default to using WinGet packages - if present
				$script:PackageSource
			} else {
				# If WinGet's default source is not present and no source specified, we can't guess what the user wants - throw an exception
				ThrowError -ExceptionName 'System.ArgumentException' `
				-ExceptionMessage $LocalizedData.UnspecifiedSource `
				-ErrorId 'UnspecifiedSource' `
				-ErrorCategory InvalidArgument
			}
		}
	)

	Write-Verbose "Source selected: $selectedSource"

	$WinGetParams = @{
		ID = $Name
		Source = $selectedSource
		Exact = $true
	}

	# Convert the PSCustomObject output from Cobalt into PackageManagement SWIDs, then filter results by any version requirements
	# We have to specify the source when converting to SWIDs, because WinGet doesn't return source information when the source is specified
	Cobalt\Find-WinGetPackage @WinGetParams | ForEach-Object {
		# We need to retrieve all versions, perform an additional query to get all available versions, and create a package object for each version
		$package = $_
		$package | Get-WinGetPackageInfo -Versions | Select-Object -Property @{
			Name = 'ID'
			Expression = {$package.ID}
		},@{
			Name = 'Version'
			Expression = {$_}
		},@{
			Name = 'Source'
			Expression = {$package.Source}
		}
	} | ConvertTo-SoftwareIdentity -Source $selectedSource | Where-Object {Test-PackageVersion -Package $_ -RequiredVersion $RequiredVersion -MinimumVersion $MinimumVersion -MaximumVersion $MaximumVersion}
}
