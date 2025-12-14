$f = 'c:\backend\pulsofsound_backend\src\cloudCode\modules\PlacementTest\functions.ts'
Write-Host "Reading file: $f"
$c = Get-Content -Path $f -Raw
if ($c -match "\.name\(\)") {
    Write-Host "SUCCESS: File already contains .name() calls"
} else {
    Write-Host "INFO: File does NOT contain .name() calls yet"
    Write-Host "Applying fixes..."
    $c = $c -replace "q\.get\('question_image_url'\)\}", "q.get('question_image_url')?.name()}"
    $c = $c -replace "q\.get\('option_a_image_url'\)\}", "q.get('option_a_image_url')?.name()}"
    $c = $c -replace "q\.get\('option_b_image_url'\)\}", "q.get('option_b_image_url')?.name()}"
    $c = $c -replace "q\.get\('option_c_image_url'\)\}", "q.get('option_c_image_url')?.name()}"
    $c = $c -replace "q\.get\('option_d_image_url'\)\}", "q.get('option_d_image_url')?.name()}"
    $c = $c -replace "result\.get\('question_image_url'\)\}", "result.get('question_image_url')?.name()}"
    $c = $c -replace "result\.get\('option_a_image_url'\)\}", "result.get('option_a_image_url')?.name()}"
    $c = $c -replace "result\.get\('option_b_image_url'\)\}", "result.get('option_b_image_url')?.name()}"
    $c = $c -replace "result\.get\('option_c_image_url'\)\}", "result.get('option_c_image_url')?.name()}"
    $c = $c -replace "result\.get\('option_d_image_url'\)\}", "result.get('option_d_image_url')?.name()}"
    Set-Content -Path $f -Value $c
    Write-Host "DONE: File updated with .name() calls"
}
