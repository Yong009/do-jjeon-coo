@echo off
setlocal
echo ==========================================
echo Starting Main Site Upload Process
echo Target: https://github.com/Yong009/Yong009.github.io.git
echo ==========================================


REM Copy ads.txt to main_site
copy /Y docs\ads.txt main_site\ads.txt

cd main_site

REM Check if git is initialized
if not exist .git (
    echo Initializing Git repository...
    git init
    git branch -M main
    git remote add origin https://github.com/Yong009/Yong009.github.io.git
)

REM Add all files
echo Adding files...
git add .

REM Commit changes
git commit -m "Update Main User Site"

REM Push changes
echo Pushing to GitHub...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo Success! Main site uploaded.
    echo Visit: https://yong009.github.io/
    echo ==========================================
) else (
    echo.
    echo Push failed. Please check your credentials or if the repo exists.
)

pause
