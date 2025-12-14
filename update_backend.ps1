
$source = 'c:\Users\LAPTOP KING\Desktop\course flutter\pulse_of_sound\functions.ts'
$dest = 'c:\backend\pulsofsound_backend\src\cloudCode\modules\PlacementTest\functions.ts'

Write-Host "Copying from: $source"
Write-Host "Copying to: $dest"

Copy-Item -Path $source -Destination $dest -Force

$content = Get-Content -Path $dest -Raw
if ($content -match '\.name\(\)') {
    Write-Host "SUCCESS: Backend file updated with .name() calls"
} else {
    Write-Host "ERROR: File still doesn't have .name() calls"
}

Write-Host "Done!"
