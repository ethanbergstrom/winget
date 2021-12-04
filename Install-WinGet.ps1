Install-Module NtObjectManager -Force
Import-Module appx -UseWindowsPowerShell

# GitHub release information
$appxPackageName = 'Microsoft.DesktopAppInstaller'
$msWinGetLatestReleaseURL = 'https://github.com/microsoft/winget-cli/releases/latest'
$msWinGetMSIXBundlePath = ".\$appxPackageName.msixbundle"
$msWinGetLicensePath = ".\$appxPackageName.license.xml"

# Workaround for no Microsoft Store on Windows Server - I dont know a great way to source this information dynamically
$architecture = 'x64'
$msStoreDownloadAPIURL = 'https://store.rg-adguard.net/api/GetFiles'
$msWinGetStoreURL = 'https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1'
$msVCLibPattern = "*Microsoft.VCLibs*UWPDesktop*$architecture*appx*"
$msVCLibDownloadPath = '.\Microsoft.VCLibs.UWPDesktop.appx'
$msWinGetExe = 'winget'
$wingetExecAliasPath = "C:\Windows\System32\$msWinGetExe.exe"

$msWinGetLatestRelease = Invoke-WebRequest -Uri $msWinGetLatestReleaseURL

# Download the latest MSIX bundle and matching license from GitHub
$msWinGetLatestRelease.links |
    Where-Object href -like '*msixbundle' |
        Select-Object -Property @{
            Name = 'URI';
            Expression = {$msWinGetLatestRelease.BaseResponse.headers.Server.Product.Name+$_.href}
        } | ForEach-Object {Invoke-WebRequest -Uri $_.URI -OutFile $msWinGetMSIXBundlePath}

$msWinGetLatestRelease.links |
    Where-Object href -Like '*License*xml' |
        Select-Object -Property @{
            Name = 'URI';
            Expression = {$msWinGetLatestRelease.BaseResponse.headers.Server.Product.Name+$_.href}
        } | ForEach-Object {Invoke-WebRequest -Uri $_.URI -OutFile $msWinGetLicensePath}

# Download the VC++ redistrubable for UWP apps from the Microsoft Store
(Invoke-WebRequest -Uri $msStoreDownloadAPIURL -Method Post -Form @{type='url'; url=$msWinGetStoreURL; ring='Retail'; lang='en-US'}).links |
    Where-Object OuterHTML -Like $msVCLibPattern |
        Sort-Object outerHTML -Descending |
            Select-Object -First 1 -ExpandProperty href |
                ForEach-Object {Invoke-WebRequest -Uri $_ -OutFile $msVCLibDownloadPath}

# Install the WinGet and it's VC++ .msix with the downloaded license file
Add-AppProvisionedPackage -Online -PackagePath $msWinGetMSIXBundlePath -DependencyPackagePath $msVCLibDownloadPath -LicensePath $msWinGetLicensePath

# Force the creation of the execution alias with NtObjectManager, since one isn't generated automatically in the current user session
$appxPackage = Get-AppxPackage Microsoft.DesktopAppInstaller
$wingetTarget = Join-Path -Path $appxPackage.InstallLocation -ChildPath ((Get-AppxPackageManifest $appxPackage).Package.Applications.Application | Where-Object Id -eq $msWinGetExe | Select-Object -ExpandProperty Executable)
NtObjectManager\Set-ExecutionAlias -Path $wingetExecAliasPath -PackageName ($appxPackage.PackageFamilyName) -EntryPoint "$($appxPackage.PackageFamilyName)!$msWinGetExe" -Target $wingetTarget -AppType Desktop -Version 3
