# Current script path
[string]$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Definition -Parent

# Define provider related variables
$script:AcceptLicense = "AcceptLicense"
$script:Force = "Force"
$script:PackageSource = "WinGet"
$script:AllVersions = "AllVersions"
$script:Detailed = "Detailed"

# Utility variables
# Fast Package References are passed between cmdlets in the format of '<name>#<version>#<source>'
# See https://github.com/OneGet/oneget/wiki/PackageProvider-Interface for additional details
$script:FastReferenceRegex = "(?<name>[^#]*)#(?<version>[^\s]*)#(?<source>[^#]*)"

Import-LocalizedData LocalizedData -filename "WinGet.Resource.psd1"

# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter '*.ps1' -File | ForEach-Object {
	. $_.FullName
}
# Dot sourcing public function files
Get-ChildItem $ScriptPath/public -Recurse -Filter '*.ps1' -File | ForEach-Object {
	. $_.FullName

	# Find all the functions defined no deeper than the first level deep and export it.
	# This looks ugly but allows us to not keep any uneeded variables from polluting the module.
	([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object {
		Export-ModuleMember $_.Name
	}
}

# Forces PowerShell to interpret output from native commands using UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
