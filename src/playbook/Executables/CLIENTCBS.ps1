# Configure Client CBS related entires
# Made by Xyueta

## Set the Client CBS path
$Cbs = "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy"

## Remove 'Get started' and 'Windows Backup' from Start Menu
$Manifest = Join-Path $Cbs 'appxmanifest.xml'
$AtlasManifest = Join-Path $Cbs "appxmanifest.xml.atlas"
if (!(Test-Path $AtlasManifest)) {
    Copy-Item -Path $Manifest -Destination $AtlasManifest -Force
    Get-Acl -Path $Manifest | Set-Acl -Path $AtlasManifest
    Remove-Item $Manifest -Force
}
[xml]$xml = Get-Content -Path "$Cbs\appxmanifest.xml.atlas" -Raw
$applicationNodes = $xml.Package.Applications.Application | Where-Object { $_.Id -eq 'WebExperienceHost' -or $_.Id -eq 'WindowsBackup' }
foreach ($applicationNode in $applicationNodes) { $xml.Package.Applications.RemoveChild($applicationNode) }
$xml.Save($Manifest)

## Remove ads from the 'Accounts' page in Immersive Control Panel
$content = Get-Content -Path "$Cbs\Public\wsxpacks.json"
$pattern = '^\s*"Windows\.Settings\.Account".*'
$modifiedContent = $content -replace $pattern, ''
$modifiedContent = ($modifiedContent | Where-Object { $_.Trim() -ne "" }) -join "`n"
Set-Content -Path "$Cbs\Public\wsxpacks.json" -Value $modifiedContent

## Remove banner from Immersive Control Panel
Rename-Item "$Cbs\SystemSettingsExtensions.dll" -NewName "SystemSettingsExtensions.dll.old" -Force