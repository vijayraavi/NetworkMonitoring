$Old = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'WindowsPowerShell\Modules\AzureCT\'
$New = "D:\git\NetworkMonitoring\AzureCT\PowerShell\AzureCT"

If ((Get-Module -Name AzureCT).Count -gt 0) {Remove-Module AzureCT}
If (Test-Path $Old) {Remove-Item $Old -Recurse}
Copy-Item $New -Destination $Old -Recurse
Import-Module AzureCT
ForEach ($Job in (Get-Job)) {
    Remove-Job $Job
}
Write-Host "Swap Complete" -ForegroundColor Green

