#define ServicePath "data\flutter_assets\assets\bin\clash-for-flutter-service-windows-amd64.exe"
#define MyAppName "{{DISPLAY_NAME}}"
#define MyAppExeName "{{EXECUTABLE_NAME}}"

[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={#MyAppName}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
CloseApplications=yes
; clash core 会影响检测，原因未知
CloseApplicationsFilter={#MyAppExeName},clash-for-flutter-service-*.exe,*.dll

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation
; file encode 'UTF-8 with BOM'
Name: "chinesesimplified"; MessagesFile: "..\..\windows\packaging\exe\ChineseSimplified.isl"

[CustomMessages]
english.InstallService = Install Service(&S)
english.InstallingService = Installing Service...
english.RemoveingService = Removeing Service...
english.StopingClashForFlutter = Stoping Clash For Flutter...

chinesesimplified.InstallService = 安装服务(&S)
chinesesimplified.InstallingService = 正在安装服务...
chinesesimplified.RemoveingService = 正在移除服务...
chinesesimplified.StopingClashForFlutter = 正在关闭 Clash For Flutter...

[Tasks]
Name: "service"; Description: "{cm:InstallService}"; Flags: checkedonce
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,{#MyAppName}(&A)}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{{SOURCE_DIR}}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: launchAtStartup
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#ServicePath}"; Parameters: "stop uninstall install start"; Flags: runhidden; Tasks: service; StatusMsg: "{cm:InstallingService}"
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{cmd}"; Parameters: "/c taskkill /f /t /im {#MyAppExeName}"; Flags: runhidden; RunOnceId: stopClashForFlutter; StatusMsg: "{cm:StopingClashForFlutter}"
Filename: "{app}\{#ServicePath}"; Parameters: "stop uninstall"; Flags: runhidden; RunOnceId: serviceUnInstall; StatusMsg: "{cm:RemoveingService}"

[UninstallDelete]
Type: dirifempty; Name: "{app}"
