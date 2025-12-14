@echo off
cd /d "c:\backend\pulsofsound_backend\src\cloudCode\modules\PlacementTest"
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$f = 'c:\\backend\\pulsofsound_backend\\src\\cloudCode\\modules\\PlacementTest\\functions.ts'
Write-Host 'Checking file...'
$c = Get-Content -Path $f -Raw
if ($c -match '\.name\(\)') {
    Write-Host 'SUCCESS: File contains .name() calls'
} else {
    Write-Host 'Fixing file...'
    $c = $c -replace \"q\.get\('question_image_url'\)\}\", \"q.get('question_image_url')?.name()}\"
    $c = $c -replace \"q\.get\('option_a_image_url'\)\}\", \"q.get('option_a_image_url')?.name()}\"
    $c = $c -replace \"q\.get\('option_b_image_url'\)\}\", \"q.get('option_b_image_url')?.name()}\"
    $c = $c -replace \"q\.get\('option_c_image_url'\)\}\", \"q.get('option_c_image_url')?.name()}\"
    $c = $c -replace \"q\.get\('option_d_image_url'\)\}\", \"q.get('option_d_image_url')?.name()}\"
    $c = $c -replace \"result\.get\('question_image_url'\)\}\", \"result.get('question_image_url')?.name()}\"
    $c = $c -replace \"result\.get\('option_a_image_url'\)\}\", \"result.get('option_a_image_url')?.name()}\"
    $c = $c -replace \"result\.get\('option_b_image_url'\)\}\", \"result.get('option_b_image_url')?.name()}\"
    $c = $c -replace \"result\.get\('option_c_image_url'\)\}\", \"result.get('option_c_image_url')?.name()}\"
    $c = $c -replace \"result\.get\('option_d_image_url'\)\}\", \"result.get('option_d_image_url')?.name()}\"
    Set-Content -Path $f -Value $c
    Write-Host 'File updated successfully'
}
"
