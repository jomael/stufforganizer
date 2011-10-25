(*
	  This file is part of Stuff Organizer.

    Copyright (C) 2011  Ice Apps <so.iceapps@gmail.com>

    Stuff Organizer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Stuff Organizer is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Stuff Organizer.  If not, see <http://www.gnu.org/licenses/>.
*)

unit uProcs;

interface

uses
  SysUtils, Classes, Windows, Messages, IcePack, ShlObj, tlHelp32, Forms,
  ShellAPI, Generics.Collections, Dialogs, Registry, IdHTTP, Types, IceXML;



function GetHwnd(Handle : HWND; lParam : LPARAM) : Boolean; stdcall;
procedure SwitchToPrevAppMainWindow(pid: THandle);
procedure SwitchToPrevApp;
procedure OpenURL(site: string);
procedure CheckUpdate(const Silent: boolean = true);
function GetDownloadablePluginList: TIceXML;
procedure ExecuteSOUpdater();

function CheckWindowsLanguages: string;
procedure ProcessParameters;
procedure CheckOpenWithKeys;

function Base64Decode(const Text : string): string;

implementation

uses
  uMain, uConstans, uUpdateForm, uPluginClasses,
  IdCoder, IdCoder3to4, IdCoderMIME, gnugettext;

function Base64Decode(const Text : string): string;
var
  Decoder : TIdDecoderMime;
begin
  Decoder := TIdDecoderMime.Create(nil);
  try
    Result := Decoder.DecodeString(Text);
  finally
    FreeAndNil(Decoder)
  end
end;

function CheckWindowsLanguages: string;
var
  s, curLang: string;
  Langs: TStrings;
begin
  Langs := TStringList.Create;
  DefaultInstance.GetListOfLanguages('default', Langs);
  s := GetCurrentLanguage;
  curLang := CutAt(s, '_');
  if Langs.IndexOf(LowerCase(curLang)) = -1 then
    result := 'en'
  else
    result := curLang;
  Langs.Free;
end;

procedure ProcessParameters;
var
  I: Integer;
  S: string;
  ParamList: TStrings;
begin
  ParamList := TStringList.Create;
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if FileExists(S) or DirectoryExists(S) then
    begin
      ParamList.Add(ExcludeTrailingBackslash(S));
    end;
  end;
  if ParamList.Count > 0 then
    MainForm.PreparingNewFiles(ParamList, -1);

  ParamList.Free;
end;

procedure CheckOpenWithKeys;
var
  reg: TRegistry;
  c,S:string;
begin
  try
    try
      reg := TRegistry.Create;
      reg.RootKey := HKEY_CLASSES_ROOT;

      reg.OpenKey('*\shell\Add to Stuff Organizer library\command', true);
      reg.WriteString('', Application.ExeName + ' "%1"');
      reg.CloseKey;

      reg.OpenKey('Folder\shell\Add to Stuff Organizer library\command', true);
      reg.WriteString('', Application.ExeName + ' "%1"');
      reg.CloseKey;

    finally
      reg.Free;
    end;
  except
    //Silent
  end;
end;

function GetPluginVersion(plgName: string): string;
var
  Plugin: TPluginItem;
begin
  result := '';
  Plugin := PluginManager.GetPluginByName(plgName);
  if Assigned(Plugin) then
    result := Plugin.PluginInfo.Version;
end;

function GetDownloadablePluginList: TIceXML;
var
  http: TIdHTTP;
  data: string;
  xml: TIceXML;
  I: Integer;
  Item: TXMLItem;
  Plugin: TPluginItem;
  plgName: string;
begin
  result := nil;
  http := TIdHTTP.Create(nil);
  http.Request.UserAgent := 'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.186 Safari/535.1';
  xml := TIceXML.Create(nil);
  try
    data := '';
    try
      data := http.Get(UPDATE_URL + '?mac=' + IcePack.GetMACAddress); //TODO: if enabled AUS
      if data <> '' then
      begin
        xml.LoadFromString(data);
        if xml.Root.Name = 'UpdateData' then
        begin
          for I := xml.Root.Count - 1 downto 0 do
          begin
            if Pos('PLG_', xml.Root[I].Attr['name']) = 1 then
            begin
              plgName := xml.Root[I].Attr['name'];
              Plugin := PluginManager.GetPluginByName(Copy(plgName, 5, Length(plgName)));
              if Assigned(Plugin) then
                xml.Root[I].Remove;
            end
            else
              xml.Root[I].Remove;
          end;

          result := xml;
        end;
      end
    except
      on E: Exception do
      begin
      end;
    end;
  finally
    http.Free;
  end;
end;


procedure CheckUpdate(const Silent: boolean = true);
var
  http: TIdHTTP;
  data: string;
  xml: TIceXML;
  Item: TXMLItem;
  SelfVer, updVer: string;
  updateFile: string;
  updateList: TList;
  I: Integer;
  plgName: string;
  updateDir: string;
begin
  updateDir := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA) + UPDATEPATH;
  updateList := TList.Create;
  http := TIdHTTP.Create(nil);
  xml := TIceXML.Create(nil);
  try
    data := '';
    try
      data := http.Get(UPDATE_URL + '?mac=' + IcePack.GetMACAddress); //TODO: if enabled AUS
      if data <> '' then
      begin
        xml.LoadFromString(data);

        if xml.Root.Name = 'UpdateData' then
        begin
          for I := 0 to xml.Root.Count - 1 do
          begin
            Item := xml.Root[I];
            if Item.Attr['name'] = 'MAIN' then
            begin
              //Main program update
              updVer := Item.GetItemValue('Version', '');
              if updVer <> '' then
              begin
                SelfVer := IcePack.GetFileVersion();
                if IcePack.CheckVersion(SelfVer, updVer) = GreaterThanValue then
                  updateList.Add(Item);
              end;
            end
            else if Pos('PLG_', Item.Attr['name']) = 1 then
            begin
              //Plugin update
              updVer := Item.GetItemValue('Version', '');
              if updVer <> '' then
              begin
                plgName := Item.Attr['name'];
                SelfVer := GetPluginVersion(Copy(plgName, 5, Length(plgName)));
                if (SelfVer <> '') and (IcePack.CheckVersion(SelfVer, updVer) = GreaterThanValue) then
                  updateList.Add(Item);
              end;
            end;
          end;

          if updateList.Count > 0 then
          begin
            if ShowUpdateForm(updateList) then
            begin
              //MessageDlg(Lang['Applicationexitfortoupdate'], mtInformation, [mbOK], 0);
              ExecuteSOUpdater;
              Application.Terminate;
            end;
          end
          else if not Silent then
            MessageDlg(_('Application is up to date.'), mtInformation, [mbOK], 0);
        end
        else if not Silent then
          MessageDlg(_('Unknow update file!'), mtError, [mbOK], 0);
      end
      else if not Silent then
        MessageDlg(_('Update info not found!'), mtWarning, [mbOK], 0);
    except
      on E: Exception do
      begin
        if not Silent then
          MessageDlg(_('Update error! ') + E.Message, mtError, [mbOK], 0);
      end;
    end;
  finally
    http.Free;
    xml.Free;
    updateList.Free;
  end;
end;

procedure ExecuteSOUpdater();
var
  updateFile: string;
begin
  updateFile := IcePack.GetTempDirectory + 'SOUpdater.exe';
  if FileExists(updateFile) then
    DeleteFile(PWideChar(updateFile));
  IcePack.ExtractResource('UPDATE_EXE', updateFile);
  if FileExists(updateFile) then
  begin
    if CheckWin32Version(6) then //greater or equal than Vista
      RunAsAdmin(Application.Handle, updateFile, '"' + ExecPath + '"')
    else
      ShellExecute(0, 'open', PWideChar(updateFile), PWideChar('"' + ExecPath + '"'), '', SW_SHOW);
  end;

  Application.Terminate;

end;

procedure OpenURL(site: string);
begin
  ShellExecute(Application.Handle, 'open', PChar(site), nil, nil, SW_SHOW)
end;

procedure SwitchToPrevApp;
var
  hSnap: LongWord;
  ProcessEntry: TProcessEntry32;
  Proceed: Boolean;
  SysDir: array[0..MAX_PATH] of WChar;
  filename: string;
begin
  try
    hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0 );
    if hSnap <> 0 then
    begin
      ProcessEntry.dwSize := SizeOf(TProcessEntry32);
      Proceed := Process32First(hSnap, ProcessEntry);
      while Proceed do
      begin
        GetSystemDirectory(@SysDir, SizeOf(SysDir));
        filename := ExtractFileName(LowerCase(Trim(ProcessEntry.szExeFile)));
        if filename = LowerCase(ExtractFileName(Application.ExeName)) then
        begin
          SwitchToPrevAppMainWindow(ProcessEntry.th32ProcessID);
          break;
        end;
        Proceed := Process32Next(hSnap, ProcessEntry);
      end;
      CloseHandle(hSnap);
    end;
  except
    Halt;
  end;
end;

procedure SwitchToPrevAppMainWindow(pid: THandle);
var
  threadID: THandle;
  hThreadSnap: THandle;
  te32: TThreadEntry32;

begin
  hThreadSnap := CreateToolhelp32Snapshot( TH32CS_SNAPTHREAD, 0 );
  if( hThreadSnap = INVALID_HANDLE_VALUE ) then
    Exit;

  te32.dwSize := sizeof(THREADENTRY32);

  if( not Thread32First( hThreadSnap, te32 ) ) then
  begin
    CloseHandle( hThreadSnap );
    exit;
  end;

  repeat
    if( te32.th32OwnerProcessID = pid ) then
    begin
      if EnumThreadWindows(te32.th32ThreadID, @GetHwnd, 0) then
      begin
        break;
      end;
    end;
  until not Thread32Next(hThreadSnap, te32 );

  CloseHandle( hThreadSnap );
end;


function GetHwnd(Handle : HWND; lParam : LPARAM) : Boolean; stdcall;
var
  lTempClass: String;
  len: integer;
  cd : TCopyDataStruct;
  ParamList: TStrings;
  I: Integer;
  S: string;
begin
  SetLength(lTempClass, 255);
  SetLength(lTempClass, GetClassName(Handle, PChar(lTempClass), 255));
  if lTempClass = TMainForm.ClassName then
  begin

    ParamList := TStringList.Create;
    for I := 1 to ParamCount do
    begin
      S := ParamStr(I);
      if (Length(S) > 0) and FileExists(S) or DirectoryExists(S) then
      begin
        ParamList.Add(ExcludeTrailingBackslash(S));
      end;
    end;

    if ParamList.Count > 0 then
    begin
      S := ParamList.Text;
      cd.dwData := 1200;
      cd.cbData := Length(S) * sizeOf(S[1]);
      cd.lpData := PWideChar(S);

      SendMessage(Handle, WM_COPYDATA, Application.Handle, LongInt(@cd));
      ShowWindow(Handle, 1);
      SetForegroundWindow(Handle);
    end;
    ParamList.Free;
  end;
  Result := True;
end;

end.
