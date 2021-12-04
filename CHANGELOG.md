# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## 0.0.3 - 2021-12-04 - Installed Package Wildcard Search Support
### Added
* Installed packages can now be searched with wildcards, aligning with standard PowerShell behavior

## 0.0.2 - 2021-12-04 - WinGet v1.x support and PowerShell Crescendo
### Added
* Support for WinGet v1.x, which brings several new features
    * List installed packages
    * Upgrade packages
    * Uninstall packages

### Changed
* Merged in structural changes from `ChocolateyGet`
* WinGet CLI interaction now handled via the PowerShell Crescendo module `Cobalt`

## 0.0.1 - 2020-05-20 - Initial Release
### Added
* Forked from Chocolatier and adapted to the current capabilities of WinGet
