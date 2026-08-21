@echo off
setlocal

title Ryder CUP - Subir archivos a GitHub

cd /d "%~dp0"

set "REPO_URL=https://github.com/PanchoM2025/Ryder.git"
set "TEMP_REPO=%TEMP%\RYDER_GITHUB"

echo.
echo ==========================================
echo   Ryder CUP - SUBIR ARCHIVOS A GITHUB
echo ==========================================
echo.

if not exist "Ryder_SUASA.html" (
    echo ERROR: No se encuentra Ryder_SUASA.html en esta carpeta.
    pause
    exit /b 1
)

echo Preparando repositorio...

if exist "%TEMP_REPO%" rmdir /s /q "%TEMP_REPO%"

git clone "%REPO_URL%" "%TEMP_REPO%"
if errorlevel 1 (
    echo.
    echo ERROR al clonar el repositorio.
    pause
    exit /b 1
)

echo.
echo Copiando archivos...

for %%f in ("%~dp0*.*") do (
    if /i not "%%~nxf"=="subir_ryder_a_github.bat" (
        copy /y "%%f" "%TEMP_REPO%\%%~nxf" >nul
        echo   + %%~nxf
    )
)

echo Generando index.html desde Ryder_SUASA.html...
copy /y "%~dp0Ryder_SUASA.html" "%TEMP_REPO%\index.html" >nul
echo   + index.html (copia de Ryder_SUASA.html)

cd /d "%TEMP_REPO%"

git add -A

git diff --cached --quiet
if %errorlevel%==0 (
    echo.
    echo No hay cambios nuevos para subir.
    pause
    exit /b 0
)

git commit -m "Actualizo Ryder CUP"

if errorlevel 1 (
    echo.
    echo ERROR al crear el commit.
    pause
    exit /b 1
)

git push origin main

if errorlevel 1 (
    echo.
    echo ERROR al subir a GitHub.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   ARCHIVOS SUBIDOS CORRECTAMENTE
echo ==========================================
echo.
echo Repositorio:
echo https://github.com/PanchoM2025/Ryder
echo.
echo App (GitHub Pages):
echo https://panchom2025.github.io/Ryder/
echo.
echo Los cambios se publican en 1-2 minutos.
echo.

pause