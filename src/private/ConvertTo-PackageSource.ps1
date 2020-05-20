# Convert the output from WinGet.exe into Software Identities (SWIDs).
# We do this by pattern matching the output for anything that looks like it contains the package we were looking for, and a version.
# WinGet doesn't return source information in its packge output, so we have to inject source information based on what the user requested.
# If a custom source isn't specified, default to using WinGet.org.
function ConvertTo-PackageSource {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[string[]]
		$WinGetOutput,

		[Parameter()]
		[Int32]
		$ArgIndex
	)

	process {
		[PSCustomObject]@{
			Name = $WinGetOutput.Substring(0,$ArgIndex-1).Trim()
			Location = $WinGetOutput.Substring($ArgIndex).Trim()
		}
	}
}
