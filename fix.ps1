$file = 'c:\backend\pulsofsound_backend\src\cloudCode\modules\PlacementTest\functions.ts'
$content = Get-Content $file -Raw

# Replace all occurrences
$content = $content -replace "q\.get\('question_image_url'\)\}", "q.get('question_image_url')?.name()}"
$content = $content -replace "q\.get\('option_a_image_url'\)\}", "q.get('option_a_image_url')?.name()}"
$content = $content -replace "q\.get\('option_b_image_url'\)\}", "q.get('option_b_image_url')?.name()}"
$content = $content -replace "q\.get\('option_c_image_url'\)\}", "q.get('option_c_image_url')?.name()}"
$content = $content -replace "q\.get\('option_d_image_url'\)\}", "q.get('option_d_image_url')?.name()}"

$content = $content -replace "result\.get\('question_image_url'\)\}", "result.get('question_image_url')?.name()}"
$content = $content -replace "result\.get\('option_a_image_url'\)\}", "result.get('option_a_image_url')?.name()}"
$content = $content -replace "result\.get\('option_b_image_url'\)\}", "result.get('option_b_image_url')?.name()}"
$content = $content -replace "result\.get\('option_c_image_url'\)\}", "result.get('option_c_image_url')?.name()}"
$content = $content -replace "result\.get\('option_d_image_url'\)\}", "result.get('option_d_image_url')?.name()}"

Set-Content -Path $file -Value $content
Write-Host 'Done'
