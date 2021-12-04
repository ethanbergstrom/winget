# Convert the objects returned from Cobalt into Software Identities (SWIDs).
function ConvertTo-SoftwareIdentity {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject,

		[Parameter()]
		[string]
		$Source
	)

	process {
		Write-Debug ($LocalizedData.ProviderDebugMessage -f ('ConvertTo-SoftwareIdentity'))
		foreach ($package in $InputObject) {
			# Return a new SWID based on the output from Cobalt
			$packageSource = $(
				if ($package.source) {
					$package.source
				} elseif ($Source) {
					$Source
				}
			)
			if ($packageSource) {
				Write-Debug "Package identified: $($package.ID), $($package.version), $($packageSource)"
				$swid = @{
					FastPackageReference = $package.ID+"#"+ $package.version+"#"+$packageSource
					Name = $package.ID
					Version = $package.version
					versionScheme = "MultiPartNumeric"
					FromTrustedSource = $true
					Source = $packageSource
				}
				New-SoftwareIdentity @swid
			}
		}
	}
}
