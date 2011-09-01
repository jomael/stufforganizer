[Setup]
;SetupIconFile=C:\Work\Project\__D2009Projects__\StuffOrganizer\Source\Images\stuff_organizer_icon_all.ico
AppCopyright=Ice Apps
AppName=Stuff Organizer
AppVerName=v0.4.5
DefaultDirName={pf}\Stuff Organizer\
OutputDir=C:\Work\Project\__D2009Projects__\StuffOrganizer\Install\Bin
OutputBaseFilename=setup_stuff_organizer
AppID={{FBE4694D-AA7D-491A-8EE5-53695CDCF921}
DefaultGroupName=Stuff Organizer
AppPublisherURL=http://stufforganizer.sourceforge.net/
AppSupportURL=http://stufforganizer.sourceforge.net/
AppUpdatesURL=http://stufforganizer.sourceforge.net/
VersionInfoVersion=0.4.5
VersionInfoCompany=Ice Apps
VersionInfoDescription=Stuff Organizer
VersionInfoTextVersion=0.4.5
VersionInfoCopyright=Ice Apps
VersionInfoProductName=Stuff Organizer
VersionInfoProductVersion=0.4.5
UninstallDisplayName=Stuff Organizer
AppVersion=0.4.5
;UninstallDisplayIcon={app}\StuffOrganizer.exe
AppPublisher=Ice Apps
MinVersion=,5.1.2600
ShowLanguageDialog=auto
LicenseFile=..\..\Bin\License
WizardSmallImageFile=..\..\Source\Images\stuff_organizer_icon_55.bmp

[Files]
Source: ..\..\Bin\License; DestDir: {app};
Source: ..\..\Bin\7z.dll; DestDir: {app};
Source: ..\..\Bin\sqlite3.dll; DestDir: {app};
Source: ..\..\Bin\unrar.dll; DestDir: {app};
Source: ..\..\Bin\StuffOrganizer.exe; DestDir: {app};
Source: ..\..\Bin\Plugins\unpack_7z.sop; DestDir: {app}\Plugins; 
Source: ..\..\Bin\Plugins\unpack_rar.sop; DestDir: {app}\Plugins; 
Source: ..\..\Bin\Plugins\unpack_zip.sop; DestDir: {app}\Plugins; 
Source: ..\..\Bin\Plugins\allrovi.sop; DestDir: {app}\Plugins; 
Source: ..\..\Source\Homepage.url; DestDir: {group};

[Icons]
Name: "{group}\Stuff Organizer"; Filename: {app}\StuffOrganizer.exe; WorkingDir: {app}; IconFilename: {app}\StuffOrganizer.exe;
;Name: "{group}\Visit homepage"; Filename: {app}\homepage.url;
Name: "{group}\Uninstall Stuff Organizer"; Filename: {uninstallexe};
Name: "{userdesktop}\Stuff Organizer"; Filename: {app}\StuffOrganizer.exe; WorkingDir: {app}; IconFilename: {app}\StuffOrganizer.exe; Tasks: "DesktopIcon"; 

[Run]
Filename: {app}\StuffOrganizer.exe; WorkingDir: {app}; Flags: PostInstall ShellExec; Description: "Run program"; 

[Tasks]
Name: DesktopIcon; Description: "Create a desktop icon"; 

[InnoIDE_Settings]
UseRelativePaths=true

[Registry]
Root: HKCR; SubKey: "*\shell\Add to Stuff Organizer library"; Flags: UninsDeleteKey;
Root: HKCR; SubKey: "*\shell\Add to Stuff Organizer library\command"; ValueType: string; ValueData: """{app}\StuffOrganizer.exe"" ""%1"""; Flags: UninsDeleteKey;
Root: HKCR; SubKey: "Folder\shell\Add to Stuff Organizer library"; Flags: UninsDeleteKey;
Root: HKCR; SubKey: "Folder\shell\Add to Stuff Organizer library\command"; ValueType: string; ValueData: """{app}\StuffOrganizer.exe"" ""%1"""; Flags: UninsDeleteKey;

[UninstallDelete]
Name: {app}\Plugins; Type: filesandordirs;
