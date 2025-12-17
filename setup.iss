; Mahf Firmware CPU Driver - Installation Script
; Inno Setup Compiler Script
; Copyright (c) 2024 Mahf Corporation

#define MyAppName "Mahf Firmware CPU Driver"
#define MyAppVersion "2.5.1"
#define MyAppPublisher "Mahf Corporation"
#define MyAppURL "https://www.mahfcorp.com/"
#define MyAppExeName "MahfControlPanel.exe"

[Setup]
AppId={{8F9D7A5B-3C2E-4B1F-9A6D-E4C5B7A8D9F0}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Mahf\CPU Driver
DefaultGroupName=Mahf CPU Driver
AllowNoIcons=yes
LicenseFile=LICENSE.txt
OutputDir=Output
OutputBaseFilename=MahfCPUSetup_{#MyAppVersion}
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
MinVersion=10.0.22000
ArchitecturesAllowed=x64 arm64
ArchitecturesInstallIn64BitMode=x64 arm64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "startupservice"; Description: "Start Mahf CPU Service automatically"; GroupDescription: "Service Options:"; Flags: checkedonce

[Files]
; Driver files
Source: "Driver\mahf_core.sys"; DestDir: "{sys}\drivers"; Flags: ignoreversion
Source: "Driver\mahf_cpu.inf"; DestDir: "{app}\Driver"; Flags: ignoreversion
Source: "Driver\mahf_cpu.cat"; DestDir: "{app}\Driver"; Flags: ignoreversion

; Application files
Source: "Bin\mahf_control.dll"; DestDir: "{sys}"; Flags: ignoreversion
Source: "Bin\mahf_service.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Bin\MahfControlPanel.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Bin\mahf_uninstall.exe"; DestDir: "{app}"; Flags: ignoreversion

; Resources
Source: "Resources\*"; DestDir: "{app}\Resources"; Flags: ignoreversion recursesubdirs createallsubdirs

; Documentation
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "TECHNICAL.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Mahf CPU Control Panel"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall Mahf CPU Driver"; Filename: "{uninstallexe}"
Name: "{group}\Documentation"; Filename: "{app}\README.md"
Name: "{autodesktop}\Mahf CPU Control"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; Driver registry keys
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU"; ValueType: string; ValueName: "ImagePath"; ValueData: "system32\drivers\mahf_core.sys"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU"; ValueType: dword; ValueName: "Type"; ValueData: 1
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU"; ValueType: dword; ValueName: "Start"; ValueData: 0
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU"; ValueType: dword; ValueName: "ErrorControl"; ValueData: 1

; Service registry keys
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfService"; ValueType: string; ValueName: "ImagePath"; ValueData: """{app}\mahf_service.exe"""; Flags: uninsdeletekey
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfService"; ValueType: dword; ValueName: "Type"; ValueData: 16
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfService"; ValueType: dword; ValueName: "Start"; ValueData: 2
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfService"; ValueType: dword; ValueName: "ErrorControl"; ValueData: 1

; Application registry keys
Root: HKLM; Subkey: "SOFTWARE\Mahf\CPU"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\Mahf\CPU"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"
Root: HKLM; Subkey: "SOFTWARE\Mahf\CPU"; ValueType: string; ValueName: "ControlPanelPath"; ValueData: "{app}\{#MyAppExeName}"

; Performance parameters (defaults)
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters"; ValueType: dword; ValueName: "PerformanceMode"; ValueData: 1
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters"; ValueType: dword; ValueName: "DynamicScaling"; ValueData: 1
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters"; ValueType: dword; ValueName: "ThermalThreshold"; ValueData: 85

[Run]
; Install driver using pnputil
Filename: "{sys}\pnputil.exe"; Parameters: "/add-driver ""{app}\Driver\mahf_cpu.inf"" /install"; StatusMsg: "Installing Mahf CPU Driver..."; Flags: runhidden waituntilterminated

; Create and start service
Filename: "{sys}\sc.exe"; Parameters: "create MahfService binPath= ""{app}\mahf_service.exe"" start= auto"; StatusMsg: "Creating Mahf Service..."; Flags: runhidden waituntilterminated
Filename: "{sys}\sc.exe"; Parameters: "description MahfService ""Mahf CPU Performance and Power Management Service"""; Flags: runhidden waituntilterminated
Filename: "{sys}\sc.exe"; Parameters: "start MahfService"; StatusMsg: "Starting Mahf Service..."; Flags: runhidden waituntilterminated; Tasks: startupservice

; Launch control panel
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Stop and remove service
Filename: "{sys}\sc.exe"; Parameters: "stop MahfService"; Flags: runhidden waituntilterminated
Filename: "{sys}\sc.exe"; Parameters: "delete MahfService"; Flags: runhidden waituntilterminated

; Remove driver
Filename: "{sys}\pnputil.exe"; Parameters: "/delete-driver mahf_cpu.inf /uninstall /force"; Flags: runhidden waituntilterminated

[Code]
var
  RestartRequired: Boolean;

function InitializeSetup(): Boolean;
var
  Version: TWindowsVersion;
begin
  Result := True;
  GetWindowsVersionEx(Version);
  
  // Check Windows version (Windows 11 or later)
  if Version.Major < 10 then
  begin
    MsgBox('This driver requires Windows 10 (Build 22000) or later.' + #13#10 + 
           'Please upgrade your operating system.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  
  if (Version.Build < 22000) then
  begin
    if MsgBox('This driver is optimized for Windows 11.' + #13#10 + 
              'Your system is running Windows 10. Continue anyway?', 
              mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    RestartRequired := True;
  end;
end;

function NeedRestart(): Boolean;
begin
  Result := RestartRequired;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Clean up any remaining registry keys
    RegDeleteKeyIncludingSubkeys(HKLM, 'SOFTWARE\Mahf');
    RegDeleteKeyIncludingSubkeys(HKLM, 'SYSTEM\CurrentControlSet\Services\MahfCPU');
    RegDeleteKeyIncludingSubkeys(HKLM, 'SYSTEM\CurrentControlSet\Services\MahfService');
  end;
end;