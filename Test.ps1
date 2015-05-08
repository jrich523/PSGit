[CmdletBinding()]
param([Switch]$Quiet)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Verbose "Import-Module Pester" -Verbose:!$Quiet
Import-Module $PSScriptRoot\lib\Pester -Force

$PSGit = Import-LocalizedData -BaseDirectory $PSScriptRoot\src -FileName PSGit.psd1
Write-Verbose "TESTING $($PSGit.ModuleVersion) build $ENV:APPVEYOR_BUILD_VERSION" -Verbose:!$Quiet

$Release = Join-Path $PSScriptRoot $PSGit.ModuleVersion

Write-Verbose "Import-Module $Release\PSGit.psd1" -Verbose:!$Quiet
Import-Module $Release\PSGit.psd1

$Results = Invoke-Gherkin $Pwd\test -ExcludeTag wip -CodeCoverage "$Release\*.ps[m1]*" -PassThru -Quiet:$Quiet
if($Results.FailedCount -gt 0) {
    throw "Failed: '$($Results.FailedScenarios.Name -join "', '")'"
}