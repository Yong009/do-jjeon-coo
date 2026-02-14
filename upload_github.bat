@echo off
setlocal
chcp 65001 >nul

echo ==========================================
echo       Do-Jjeon-Coo Auto Deploy Tool
echo ==========================================

:: 1. Git 설치 확인
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git이 설치되어 있지 않습니다.
    pause
    exit /b 1
)

:: 2. 현재 날짜/시간 구하기 (Locale 독립적)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set YEAR=%datetime:~0,4%
set MONTH=%datetime:~4,2%
set DAY=%datetime:~6,2%
set HOUR=%datetime:~8,2%
set MINUTE=%datetime:~10,2%
set SECOND=%datetime:~12,2%

set TIMESTAMP=%YEAR%-%MONTH%-%DAY% %HOUR%:%MINUTE%:%SECOND%
echo [INFO] 현재 시간: %TIMESTAMP%

:: 3. Git 초기화 확인 및 리모트 설정
if not exist .git (
    echo [INFO] Git 저장소 초기화 중...
    git init
    git branch -M main
    git remote add origin https://github.com/Yong009/do-jjeon-coo.git
)

:: 리모트 URL 확인 (없으면 추가, 다르면 수정)
git remote get-url origin >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] 리모트 저장소 연결 중...
    git remote add origin https://github.com/Yong009/do-jjeon-coo.git
)

:: 4. 변경사항 스테이징
echo [INFO] 변경된 파일을 확인하고 있습니다...
git add .

:: 5. 변경사항 존재 여부 확인 후 커밋
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo [INFO] 변경된 내용이 없습니다. 배포를 중단합니다.
    timeout /t 3
    exit /b 0
)

:: 6. 자동 커밋 (시간 포함)
echo [INFO] 커밋 생성 중: "Auto Update: %TIMESTAMP%"
git commit -m "Auto Update: %TIMESTAMP%"

:: 7. GitHub로 푸시
echo [INFO] GitHub로 업로드 중... (main 브랜치)
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo [SUCCESS] 배포가 성공적으로 완료되었습니다!
    echo ==========================================
    echo 3초 후 자동으로 종료됩니다...
    timeout /t 3
) else (
    echo.
    echo [ERROR] 배포 실패. 내용을 확인해주세요.
    pause
)
