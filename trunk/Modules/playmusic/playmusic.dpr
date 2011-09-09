library playmusic;

{$R *.dres}

uses
  SysUtils,
  Classes,
  Graphics,
  Windows,
  Messages,
  Dialogs,
  IcePack,
  ShellAPI,
  SOPluginDefs in '..\..\Source\SOPluginDefs.pas';

{$E sop}

{$R *.res}

var
  RegisterDescriptor: TRegisterDescriptor;
  Self: Pointer;
  MainIcon: TIcon;

procedure PluginLoad(SelfObject: Pointer); stdcall;
begin
  Self := SelfObject;
  MainIcon := TIcon.Create;
  MainIcon.LoadFromResourceName(hInstance, 'MAIN_32');
end;

procedure PluginUnLoad(); stdcall;
begin
  //
end;

function PluginGetInfo(): PPluginInfo; stdcall;
begin
  New(result);
  result.Name := 'PlayMusic plugin';
  result.PluginType := 2;
  result.Description := 'Plugin makes a playlist file (m3u) and open it with the default player. Supported *.mp3, *.flac, *.wma, *.ogg.';
  result.Icon := Pointer(MainIcon.Handle);
  result.Author := 'Ice Apps';
  result.WebPage := 'http://stufforganizer.sourceforge.net';
  result.Version := '1.0.0.0';
  result.InterfaceVersion := 1;
  result.VersionDate := '2011-09-09';
  result.MinimumVersion := '0.4.5.0';
end;

function PluginSetup(): boolean; stdcall;
begin
  result := true;
end;

procedure Run(ProductInfo: PPluginProductItem); stdcall;
var
  DirName: string;
  PlaylistFileName, Ext: string;
  Files: TStrings;
  I: Integer;
begin
  DirName := IncludeTrailingBackslash(ProductInfo.TargetPath);
  if DirectoryExists(DirName) then
  begin
    Files := IcePack.GetFiles(DirName, '*.*', true);
    TStringList(Files).Sort;
    for I := Files.Count - 1 downto 0 do
    begin
      Ext := ExtractFileExt(Files[I]);
      if not ((Ext = '.mp3') or (Ext = '.wma') or (Ext = '.ogg') or (Ext = '.flac')) then
        Files.Delete(I);
    end;
    if Files.Count > 0 then
    begin
      PlaylistFileName := DirName + 'SO_' + IcePack.Simple(ProductInfo.Name) + '_playlist.m3u';
      Files.SaveToFile(PlaylistFileName);
      if FileExists(PlaylistFileName) then
        ShellExecute(0, 'open', PWideChar(PlaylistFileName), '', nil, SW_SHOW);
    end
    else
      MessageDlg('Not found music files.', mtInformation, [mbOK], 0);
  end
  else
    MessageDlg('The directory doesn''t exists!', mtError, [mbOK], 0);
end;

procedure PluginRegDescriptorFunctions(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;
begin
  RegisterDescriptor := PluginCallBacks.RegisterDescriptor;

  PluginCallBacks.RegisterDescriptor(Self, 'Make playlist and play musics', Run);
end;

function PluginInitialize(): boolean; stdcall;
begin
  result := true;
end;




exports
  PluginLoad,
  PluginUnLoad,
  PluginGetInfo,
  PluginSetup,
  PluginRegDescriptorFunctions,
  PluginInitialize;




begin
end.
