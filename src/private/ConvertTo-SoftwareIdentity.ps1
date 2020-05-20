# Convert the output from WinGet.exe into Software Identities (SWIDs).
# We do this by pattern matching the output for anything that looks like it contains the package we were looking for, and a version.
# WinGet doesn't return source information in its packge output, so we have to inject source information based on what the user requested.
# If a custom source isn't specified, default to using WinGet.org.
function ConvertTo-SoftwareIdentity {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[string[]]
		$WinGetOutput,

		[Parameter()]
		[Int32]
		$IdIndex,

		[Parameter()]
		[Int32]
		$VersionIndex,

		[Parameter()]
		[Int32]
		$MatchedIndex,

		[Parameter()]
		[string]
		$Source = $script:PackageSourceName
	)

	process {
		$Package = $WinGetOutput.Substring($IdIndex,$VersionIndex-$IdIndex).Trim()

		# WinGet doesn't always return a 'Matched' column - not sure why yet
		if ($MatchedIndex -eq -1) {
			$Version = $WinGetOutput.Substring($VersionIndex).Trim()
		} else {
			$Version = $WinGetOutput.Substring($VersionIndex,$MatchedIndex-$VersionIndex).Trim()
		}

		$swid = @{
			FastPackageReference = $Package+"#"+ $Version+"#"+$Source
			Name = $Package
			Version = $Version
			versionScheme = "MultiPartNumeric"
			FromTrustedSource = $true
			Source = $Source
		}
		New-SoftwareIdentity @swid
	}
}
