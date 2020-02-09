# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2020-02-08
### Fixed
* Choco.exe once again installs automatically after TLS 1.2 changes to chocolatey.org (#3)
  * Thanks to @kendr1ck for help with this

## [1.0.2] - 2020-02-02
### Changed
* Choco.exe installed automatically without any user prompts if -Force flag is passed (#1)

## [1.0.1] - 2020-02-09 - The Great Fork
### Added
* Searching/installing/managing multiple Chocolatey sources
* DSC Compatibility, including additional package arguments
* 'Upgrade' packages using the 'latest' required version keyword
  * Thanks to @matthewprenger for help with this

### Changed
* To facilitate readability, broke up main module file into several function files
  * Grouped by 'public' functions used by PackageManagement vs 'private' functions that contain much of the shared logic for interacting with choco.exe
  * Common logic, such as building commands, sending them to choco.exe, and parsing results, are consolidated across multiple PackageManagement cmdlets into a single set of helper functions

### Fixed
* Get-Package no longer lists 'chocolatey' twice
* Improved performance when downloading large packages with embedded installers

### Removed
* With Chocolatey-managed upgrades via the provider now available, the package provider no longer unilaterally upgrades Chocolatey on invocation if already installed
* No longer displays progress bars in order to simplify passing data between functions via the pipeline in a way that's idiomatic to PowerShell
