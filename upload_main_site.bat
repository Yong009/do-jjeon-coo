@echo off
setlocal
chcp 65001 >nul

echo ==========================================
echo       Main Site Auto Deploy Tool
echo ==========================================

:: 1. Git 설치 확인
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git이 설치되어 있지 않습니다.
    pause
    exit /b 1
)

:: 2. 현재 날짜/시간 구하기
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set YEAR=%datetime:~0,4%
set MONTH=%datetime:~4,2%
set DAY=%datetime:~6,2%
set HOUR=%datetime:~8,2%
set MINUTE=%datetime:~10,2%
set SECOND=%datetime:~12,2%
set TIMESTAMP=%YEAR%-%MONTH%-%DAY% %HOUR%:%MINUTE%:%SECOND%

:: 3. 필수 파일 복사 (ads.txt 등)
echo [INFO] 필수 파일 복사 중...
if exist docs\ads.txt (
    copy /Y docs\ads.txt main_site\ads.txt >nul
    echo [OK] ads.txt 복사 완료
) else (
    echo [WARN] docs\ads.txt 파일이 없습니다.
)

:: 4. 메인 사이트 디렉토리로 이동
if not exist main_site (
    echo [ERROR] main_site 디렉토리가 없습니다.
    pause
    exit /b 1
)
cd main_site

:: 5. Git 초기화 및 리모트 설정
if not exist .git (
    echo [INFO] Git 저장소 초기화 중...
    git init
    git branch -M main
    git remote add origin https://github.com/Yong009/Yong009.github.io.git
)

:: 리모트 URL 확인/수정
git remote get-url origin >nul 2>nul
if %errorlevel% neq 0 (
    git remote add origin https://github.com/Yong009/Yong009.github.io.git
)

:: 6. 변경사항 스테이징
echo [INFO] 변경된 파일을 확인하고 있습니다...
git add .

:: 7. 변경사항 확인 후 커밋
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo [INFO] 변경된 내용이 없습니다. 배포를 중단합니다.
    timeout /t 3
    exit /b 0
)

:: 8. 자동 커밋 및 푸시
echo [INFO] 커밋 생성 중: "Main Site Update: %TIMESTAMP%"
git commit -m "Main Site Update: %TIMESTAMP%"

echo [INFO] GitHub로 업로드 중... (Yong009.github.io)
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo [SUCCESS] 메인 사이트 배포가 완료되었습니다!
    echo Visit: https://yong009.github.io/
    echo ==========================================
    echo 3초 후 자동으로 종료됩니다...
    timeout /t 3
) else (
    echo.
    echo [ERROR] 배포 실패. 내용을 확인해주세요.
    pause
)
