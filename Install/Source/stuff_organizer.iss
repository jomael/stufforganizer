[Setup]
SetupIconFile=C:\Work\Project\__D2009Projects__\StuffOrganizer\Source\Images\stuff_organizer_icon_all.ico
AppCopyright=Ice Apps
AppName=Stuff Organizer
AppVerName=v0.5.0.0
DefaultDirName={pf}\Stuff Organizer\
OutputDir=C:\Work\Project\__D2009Projects__\StuffOrganizer\Install\Bin
OutputBaseFilename=setup_stuff_organizer
AppID={{FBE4694D-AA7D-491A-8EE5-53695CDCF921}
DefaultGroupName=Stuff Organizer
AppPublisherURL=http://stufforganizer.sourceforge.net/
AppSupportURL=http://stufforganizer.sourceforge.net/
AppUpdatesURL=http://stufforganizer.sourceforge.net/
VersionInfoVersion=0.5.0.0
VersionInfoCompany=Ice Apps
VersionInfoDescription=Stuff Organizer
VersionInfoTextVersion=v0.5.0.0
VersionInfoCopyright=Ice Apps
VersionInfoProductName=Stuff Organizer
VersionInfoProductVersion=0.5.0.0

[Files]
Source: ..\..\Bin\License; DestDir: {app};
Source: ..\..\Bin\7z.dll; DestDir: {app};
Source: ..\..\Bin\sqlite3.dll; DestDir: {app};
Source: ..\..\Bin\unrar.dll; DestDir: {app};
Source: ..\..\Bin\StuffOrganizer.exe; DestDir: {app};
Source: ..\..\Bin\Plugins\unpack_7z.sop; DestDir: {app}\Plugins; 
Source: ..\..\Bin\Plugins\unpack_rar.sop; DestDir: {app}\Plugins; 
Source: ..\..\Bin\Plugins\unpack_zip.sop; DestDir: {app}\Plugins; 

[Icons]
Name: "{group}\Stuff Organizer"; Filename: {app}\StuffOrganizer.exe; WorkingDir: {app}; IconFilename: {app}\StuffOrganizer.exe;
Name: "{userdesktop}\Stuff Organizer"; Filename: {app}\StuffOrganizer.exe; WorkingDir: {app}; IconFilename: {app}\StuffOrganizer.exe; Tasks: "DesktopIcon"; 

[Run]
Filename: {app}\StuffOrganizer.exe; WorkingDir: {app}; Flags: PostInstall ShellExec; 

[Tasks]
Name: DesktopIcon; Description: "Create a desktop icon"; 

[InnoIDE_Settings]
UseRelativePaths=true
