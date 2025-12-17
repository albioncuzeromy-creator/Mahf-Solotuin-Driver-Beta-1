@echo off
REM Mahf Firmware CPU Driver - Manual Installation Script
REM Copyright (c) 2024 Mahf Corporation
REM Version: 2.5.1

echo ================================================================
echo    MAHF FIRMWARE CPU DRIVER - INSTALLATION
echo    Version 2.5.1
echo    Copyright (c) 2024 Mahf Corporation
echo ================================================================
echo.

REM Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires Administrator privileges!
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo [1/8] Checking system requirements...
ver | findstr /i "10\.0\." >nul
if %errorlevel% neq 0 (
    echo ERROR: Windows 10 or later is required!
    pause
    exit /b 1
)
echo     OK - Windows version compatible

echo.
echo [2/8] Checking existing installation...
sc query MahfCPU >nul 2>&1
if %errorlevel% equ 0 (
    echo     WARNING: Driver already installed. Stopping service...
    sc stop MahfCPU
    timeout /t 2 >nul
)

sc query MahfService >nul 2>&1
if %errorlevel% equ 0 (
    echo     Stopping MahfService...
    sc stop MahfService
    timeout /t 2 >nul
)

echo.
echo [3/8] Copying driver files...
if not exist "%SystemRoot%\System32\drivers" (
    echo ERROR: System drivers directory not found!
    pause
    exit /b 1
)

copy /Y "Driver\mahf_core.sys" "%SystemRoot%\System32\drivers\" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy mahf_core.sys
    pause
    exit /b 1
)
echo     mahf_core.sys copied

copy /Y "Bin\mahf_control.dll" "%SystemRoot%\System32\" >nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to copy mahf_control.dll
    pause
    exit /b 1
)
echo     mahf_control.dll copied

if not exist "%ProgramFiles%\Mahf\CPU Driver" mkdir "%ProgramFiles%\Mahf\CPU Driver"
copy /Y "Bin\mahf_service.exe" "%ProgramFiles%\Mahf\CPU Driver\" >nul
copy /Y "Bin\MahfControlPanel.exe" "%ProgramFiles%\Mahf\CPU Driver\" >nul
copy /Y "Bin\mahf_uninstall.exe" "%ProgramFiles%\Mahf\CPU Driver\" >nul
echo     Application files copied

echo.
echo [4/8] Installing driver via pnputil...
pnputil /add-driver "Driver\mahf_cpu.inf" /install
if %errorlevel% neq 0 (
    echo WARNING: pnputil returned error code %errorlevel%
    echo This may be normal if the driver is already installed.
)

echo.
echo [5/8] Creating registry entries...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU" /v ImagePath /t REG_SZ /d "system32\drivers\mahf_core.sys" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU" /v Type /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU" /v Start /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU" /v ErrorControl /t REG_DWORD /d 1 /f >nul
echo     Driver service registry keys created

reg add "HKLM\SOFTWARE\Mahf\CPU" /v Version /t REG_SZ /d "2.5.1" /f >nul
reg add "HKLM\SOFTWARE\Mahf\CPU" /v InstallPath /t REG_SZ /d "%ProgramFiles%\Mahf\CPU Driver" /f >nul
reg add "HKLM\SOFTWARE\Mahf\CPU" /v InstallDate /t REG_SZ /d "%date% %time%" /f >nul
echo     Application registry keys created

reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters" /v PerformanceMode /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters" /v DynamicScaling /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters" /v ThermalThreshold /t REG_DWORD /d 85 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters" /v PowerLimit /t REG_DWORD /d 65 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters" /v BoostEnabled /t REG_DWORD /d 1 /f >nul
echo     Performance parameters configured

echo.
echo [6/8] Creating MahfService...
sc create MahfService binPath= "\"%ProgramFiles%\Mahf\CPU Driver\mahf_service.exe\"" start= auto DisplayName= "Mahf CPU Service" >nul
if %errorlevel% equ 0 (
    sc description MahfService "Mahf CPU Performance and Power Management Service" >nul
    echo     MahfService created successfully
) else (
    echo     WARNING: Service creation failed (may already exist)
)

echo.
echo [7/8] Starting services...
sc start MahfService >nul 2>&1
if %errorlevel% equ 0 (
    echo     MahfService started
) else (
    echo     INFO: Service will start on next boot
)

echo.
echo [8/8] Creating shortcuts...
powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%ProgramData%\Microsoft\Windows\Start Menu\Programs\Mahf CPU Control Panel.lnk'); $SC.TargetPath = '%ProgramFiles%\Mahf\CPU Driver\MahfControlPanel.exe'; $SC.Save()" >nul 2>&1
if %errorlevel% equ 0 (
    echo     Start Menu shortcut created
)

echo.
echo ================================================================
echo    INSTALLATION COMPLETED SUCCESSFULLY!
echo ================================================================
echo.
echo The Mahf Firmware CPU Driver has been installed.
echo.
echo IMPORTANT: A system restart is REQUIRED for the driver to
echo           function properly.
echo.
echo After restart, you can launch the Control Panel from:
echo   - Start Menu ^> Mahf CPU Control Panel
echo   - "%ProgramFiles%\Mahf\CPU Driver\MahfControlPanel.exe"
echo.
echo ================================================================
echo.

choice /C YN /M "Do you want to restart now?"
if %errorlevel% equ 1 (
    echo.
    echo Restarting system in 10 seconds...
    shutdown /r /t 10 /c "Mahf CPU Driver installation requires restart"
) else (
    echo.
    echo Please restart your computer manually to complete installation.
)

echo.
pause