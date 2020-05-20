# Get the WinGet installed path
function Get-WinGetPath {
	[CmdletBinding()]
	[OutputType([string])]

	param (
	)

	# Using Get-Command cmdlet, get the location of WinGet.exe if it is available under $env:PATH.
	Get-Command -Name $script:WinGetExeName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
		Where-Object {
			$_.Path -and
			((Split-Path -Path $_.Path -Leaf) -eq $script:WinGetExeName) -and
			(-not $_.Path.StartsWith($env:windir, [System.StringComparison]::OrdinalIgnoreCase))
		} | Select-Object -First 1
}
