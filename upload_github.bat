@echo off
setlocal
echo ==========================================
echo Starting GitHub Upload Process
echo Target: https://github.com/Yong009/do-jjeon-coo.git
echo ==========================================

REM Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Git is not installed or not in the PATH.
    echo Please install Git and try again.
    pause
    exit /b 1
)

REM Initialize Git repository
if not exist .git (
    echo Initializing Git repository...
    git init
) else (
    echo Git repository already exists.
)

REM Add all files
echo Adding files to staging area...
git add .

REM Commit changes
git commit -m "Auto-generated commit by Antigravity: Update for specific remote"

REM Configure Remote
echo Configuring remote origin...
git remote remove origin 2>nul
git remote add origin https://github.com/Yong009/do-jjeon-coo.git
if %errorlevel% neq 0 (
    echo Failed to add remote. It might be invalid.
    pause
    exit /b 1
)

echo Pushing to main branch...
git branch -M main
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo Success! Project uploaded to GitHub.
    echo ==========================================
) else (
    echo.
    echo Push failed. You may need to sign in.
    echo Try running 'gh auth login' or check your credentials.
)

pause
