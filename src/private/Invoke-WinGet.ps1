# Builds a command optimized for a package provider and sends to winget.exe
function Invoke-WinGet {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true, ParameterSetName='Search')]
		[switch]
		$Search,

		[Parameter(Mandatory=$true, ParameterSetName='Install')]
		[switch]
		$Install,

		[Parameter(Mandatory=$true, ParameterSetName='Uninstall')]
		[switch]
		$Uninstall,

		[Parameter(Mandatory=$true, ParameterSetName='SourceList')]
		[switch]
		$SourceList,

		[Parameter(Mandatory=$true, ParameterSetName='SourceAdd')]
		[switch]
		$SourceAdd,

		[Parameter(Mandatory=$true, ParameterSetName='SourceRemove')]
		[switch]
		$SourceRemove,

		[Parameter(Mandatory=$true, ParameterSetName='SourceUpdate')]
		[switch]
		$SourceUpdate,

		[Parameter(ParameterSetName='Search')]
		[Parameter(Mandatory=$true, ParameterSetName='Install')]
		[Parameter(Mandatory=$true, ParameterSetName='Uninstall')]
		[string]
		$Package,

		[Parameter(ParameterSetName='Search')]
		[Parameter(Mandatory=$true, ParameterSetName='Install')]
		[Parameter(Mandatory=$true, ParameterSetName='Uninstall')]
		[string]
		$Version,

		[Parameter(ParameterSetName='Search')]
		[Parameter(ParameterSetName='Install')]
		[Parameter(Mandatory=$true, ParameterSetName='SourceAdd')]
		[Parameter(Mandatory=$true, ParameterSetName='SourceRemove')]
		[Parameter(ParameterSetName='SourceUpdate')]
		[string]
		$SourceName = $script:PackageSourceName,

		[Parameter(Mandatory=$true, ParameterSetName='SourceAdd')]
		[string]
		$SourceLocation,

		[string]
		$AdditionalArgs = (Get-AdditionalArguments)
	)

	# Split on the first hyphen of each option/switch
	$argSplitRegex = '(?:^|\s)-'
	# Installation parameters/arguments can interfere with non-installation commands (ex: search) and should be filtered out
	$argParamFilterRegex = '\w*(?:param|arg)\w*'
	# ParamGlobal Flag
	$paramGlobalRegex = '\w*-(?:p.+global)\w*'
	# ArgGlobal Flag
	$argGlobalRegex = '\w*-(?:(a|i).+global)\w*'
	# Just parameters
	$paramFilterRegex = '\w*(?:param)\w*'
	# Just parameters
	$argFilterRegex = '\w*(?:arg)\w*'


	$WinGetExePath = Get-WinGetPath

	if ($WinGetExePath) {
		Write-Debug ("WinGet already installed")
	} else {
		$WinGetExePath = Install-WinGetBinaries
	}

	# Source Management
	if ($SourceList -or $SourceAdd -or $SourceRemove -or $SourceUpdate) {
		$cmdString = 'source '
		if ($SourceAdd) {
			$cmdString += "add --name $SourceName --arg $SourceLocation "
		} elseif ($SourceRemove) {
			$cmdString += "remove --name $SourceName "
		} elseif ($SourceUpdate) {
			$cmdString += "update "
			if ($SourceName) {
				$cmdString += "--name $SourceName "
			}
		} elseif ($SourceList) {
			$cmdString += 'list '
		}
	} else {
		# Package Management
		if ($Install) {
			$cmdString = "install --id $Package "
			# Accept all prompts and dont show installation progress percentage - the excess output from WinGet.exe will slow down PowerShell
			$AdditionalArgs += ' --silent '
		} elseif ($Search) {
			$cmdString = 'search '
			if ($Package) {
				$cmdString += "$Package "
			}
		}
		# Uninstall not currently supported

		# Finish constructing package management command string
		if ($Version) {
			$cmdString += "--version $Version "
		}

		$cmdString += "--source $SourceName "
	}

	# Joins the constructed and user-provided arguments together to be soon split as a single array of options passed to WinGet.exe
	$cmdString += $AdditionalArgs
	Write-Debug ("Calling $WinGetExePath $cmdString")
	$cmdString = $cmdString.Split(' ')

	# Save the output to a variable so we can inspect the exit code before submitting the output to the pipeline
	$output = (& $WinGetExePath $cmdString)

	if ($LASTEXITCODE -ne 0) {
		ThrowError -ExceptionName 'System.OperationCanceledException' `
			-ExceptionMessage $($output | Out-String) `
			-ErrorID 'JobFailure' `
			-ErrorCategory InvalidOperation `
			-ExceptionObject $output
	} else {
		if ($Install) {
			$swid = @{
				FastPackageReference = $Package+"#"+$Version+"#"+$SourceName
				Name = $Package
				Version = $Version
				versionScheme = "MultiPartNumeric"
				FromTrustedSource = $true
				Source = $SourceName
			}
			New-SoftwareIdentity @swid
		} elseif ($Search) {
			$swidArgs = @{
				Source = $SourceName
				IdIndex = $output[1].IndexOf('Id')
				VersionIndex = $output[1].IndexOf('Version')
				MatchedIndex = $output[1].IndexOf('Matched')
			}
			# Search returns an extra line of whitespace to skip
			$output | Select-Object -Skip 3 | ConvertTo-SoftwareIdentity @swidArgs
		} elseif ($SourceList) {
			$ArgIndex = $output[0].IndexOf('Arg')
			# Skip the header lines and convert the rest
			$output | Select-Object -Skip 2 | ForEach-Object {
				$packageSource = @{
					Name = $_.Substring(0,$ArgIndex-1).Trim()
					Location = $_.Substring($ArgIndex).Trim()
					Trusted = $True
					Registered = $true
				}
				New-PackageSource @packageSource
			}
		} else {
			$output
		}
	}
}
