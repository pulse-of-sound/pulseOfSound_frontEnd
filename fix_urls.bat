@echo off
setlocal enabledelayedexpansion

set "filePath=c:\backend\pulsofsound_backend\src\cloudCode\modules\PlacementTest\functions.ts"

for /f "delims=" %%A in ('type "%filePath%"') do (
    set "line=%%A"
    set "line=!line:q.get('question_image_url')}=q.get('question_image_url')?.name()}!"
    set "line=!line:q.get('option_a_image_url')}=q.get('option_a_image_url')?.name()}!"
    set "line=!line:q.get('option_b_image_url')}=q.get('option_b_image_url')?.name()}!"
    set "line=!line:q.get('option_c_image_url')}=q.get('option_c_image_url')?.name()}!"
    set "line=!line:q.get('option_d_image_url')}=q.get('option_d_image_url')?.name()}!"
    set "line=!line:result.get('question_image_url')}=result.get('question_image_url')?.name()}!"
    set "line=!line:result.get('option_a_image_url')}=result.get('option_a_image_url')?.name()}!"
    set "line=!line:result.get('option_b_image_url')}=result.get('option_b_image_url')?.name()}!"
    set "line=!line:result.get('option_c_image_url')}=result.get('option_c_image_url')?.name()}!"
    set "line=!line:result.get('option_d_image_url')}=result.get('option_d_image_url')?.name()}!"
    echo !line! >> "%filePath%.tmp"
)

move /Y "%filePath%.tmp" "%filePath%"
echo File updated successfully
