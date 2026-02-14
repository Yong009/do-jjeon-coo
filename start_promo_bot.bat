@echo off
setlocal
chcp 65001 >nul

echo ==========================================
echo       두쫀쿠 홍보 봇 (SNS Content Gen)
echo ==========================================

:: 1. Python 설치 확인
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python이 설치되어 있지 않습니다.
    echo https://www.python.org/downloads/ 에서 설치해주세요.
    pause
    exit /b 1
)

:: 2. 필수 라이브러리 (Pillow) 확인 및 설치
echo [Check] 필수 라이브러리(Pillow) 확인 중...
pip show Pillow >nul 2>&1
if %errorlevel% neq 0 (
    echo [Install] Pillow 설치 중...
    pip install Pillow
    if %errorlevel% neq 0 (
        echo [ERROR] 라이브러리 설치 실패.
        pause
        exit /b 1
    )
) else (
    echo [OK] Pillow가 이미 설치되어 있습니다.
)

:: 3. 봇 실행 Loop
:LOOP
cls
echo ==========================================
echo       [1] 새로운 홍보 콘텐츠 생성
echo       [Q] 종료
echo ==========================================
set /p choice="선택하세요: "

if /i "%choice%"=="Q" goto END
if "%choice%"=="1" (
    echo.
    python tools\promo_bot\promo_gen.py
    echo.
    echo 이미지를 확인하고 SNS에 업로드하세요!
    pause
    goto LOOP
)

goto LOOP

:END
echo 프로그램을 종료합니다.
timeout /t 2
