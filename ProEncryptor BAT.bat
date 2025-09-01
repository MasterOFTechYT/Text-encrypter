��
cls
@echo off
setlocal

:menu
cls
echo.
echo Press 1 to encrypt.
echo Press 2 to decrypt.
echo.
set /p menu=Enter an option: 

if "%menu%"=="1" goto login
if "%menu%"=="2" goto login_decrypt
goto menu

:login
cls
set /p pas1=Enter Pass1: 
if NOT "%pas1%"=="255083" goto login
goto login2

:login2
cls
set /p pas2=Enter Pass2: 
if NOT "%pas2%"=="165298" goto login2
goto enc

:enc
cls
set /p input=Enter text to encrypt: 
set /p filename=File name (without extension): 

:: Dodaj .txt ako ga korisnik nije unio
if not "%filename:~-4%"==".txt" set filename=%filename%.txt

:: --- Base64 ---
for /f "tokens=* usebackq" %%A in (`powershell -command "[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('%input%'))"`) do (
    set step1=%%A
)

:: --- Hex ---
for /f "tokens=* usebackq" %%B in (`powershell -command "$h=''; [System.Text.Encoding]::UTF8.GetBytes('%step1%') | ForEach-Object { $h += $_.ToString('x2') }; $h"`) do (
    set step2=%%B
)

:: spremanje u C:\
echo %step2%>C:\%filename%

echo.
echo Done! Hash saved to C:\%filename%
pause
goto menu

:login_decrypt
cls
set /p pas1=Enter Pass1: 
if NOT "%pas1%"=="255083" goto login_decrypt
goto login2_decrypt

:login2_decrypt
cls
set /p pas2=Enter Pass2: 
if NOT "%pas2%"=="165298" goto login2_decrypt
goto dec

:dec
cls
echo.
set /p filename=Enter file name (without extension):

:: Dodaj .txt ako ga korisnik nije unio
if not "%filename:~-4%"==".txt" set filename=%filename%.txt

:: provjeri gdje je fajl
if exist "%filename%" set filepath=%filename%
if exist "%userprofile%\Desktop\%filename%" set filepath=%userprofile%\Desktop\%filename%
if exist "C:\%filename%" set filepath=C:\%filename%

:: Ako fajl nije nađen, izbaci poruku i vrati na menu
if not exist "%filepath%" (
    echo File not found!
    pause
    goto menu
)

:: učitaj sadržaj fajla
set /p encoded=<"%filepath%"

:: Hex -> Base64 (ispravno)
for /f "usebackq tokens=*" %%A in (`powershell -command "$hex='%encoded%'; $bytes = for ($i=0; $i -lt $hex.Length; $i+=2) { [Convert]::ToByte($hex.Substring($i,2),16) }; [System.Text.Encoding]::UTF8.GetString($bytes)"`) do (
    set step1=%%A
)

:: Base64 -> original
for /f "usebackq tokens=*" %%B in (`powershell -command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%step1%'))"`) do (
    set step2=%%B
)

echo.
echo Original text: %step2%

:: Spremi originalni tekst u C:\ s istim imenom
echo %step2% > C:\%filename%

echo.
echo Done! Original text saved to C:\%filename%
pause
goto menu
