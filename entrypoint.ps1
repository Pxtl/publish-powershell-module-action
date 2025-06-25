#!/usr/bin/env pwsh
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# run in diagnostic mode to enable verbose logging
if ($env:ACTIONS_RUNNER_DEBUG) {
    $parsedDebugVal = [bool]::Parse($env:ACTIONS_RUNNER_DEBUG)
    $VerbosePreference = if($parsedDebugVal) {
        [Management.Automation.ActionPreference]::Continue
    } else {
        [Management.Automation.ActionPreference]::SilentlyContinue
    }
}

# get continueIfAlreadyPublished var
$continueIfAlreadyPublished = $false
if ($env:continueIfAlreadyPublished) {
    $continueIfAlreadyPublished = [bool]::Parse($env:INPUT_continueIfAlreadyPublished)
}

$modules = $null
if ([string]::IsNullOrWhiteSpace($env:INPUT_modulePath)) {
    $modules = Get-ChildItem -Recurse -Filter '*.psd1' |
        # PS module .psd1 files must match the name of their parent directory,
        # this filter helps prevent finding non-module .psd1 files.
        Where-Object { $_.Directory.Name -eq [IO.Path]::GetFileNameWithoutExtension($_)} |
        Select-Object -Unique -ExpandProperty Directory
} else {
    $modules = @($env:INPUT_modulePath)
}

$modules | ForEach-Object {
    Write-Host "Publishing '$_' to PowerShell Gallery..."

    try {
        Publish-Module -Path $_ -NuGetApiKey $env:INPUT_NuGetApiKey
        Write-Verbose "'$_' published to PowerShell Gallery."
    } catch {
        $alreadyPublishedErrorMessageRegex = "The module '[A-Za-z0-9_\-]+' with version '[0-9\.]+' cannot be published as the current version '[0-9\.]+' is already available in the repository"
        if ($continueIfAlreadyPublished -and ($_.Message -match $alreadyPublishedErrorMessageRegex)) {
            "::warning::$($_.Message)"
        } else {
            throw
        }
    }
}
