(*
	  This file is part of Stuff Organizer.

    Copyright (C) 2011  Icebob <icebob.apps@gmail.com>

    Stuff Organizer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
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
  ShellAPI, Generics.Collections, Dialogs, Registry, IdHTTP, Types;



function GetHwnd(Handle : HWND; lParam : LPARAM) : Boolean; stdcall;
procedure SwitchToPrevAppMainWindow(pid: THandle);
procedure SwitchToPrevApp;
procedure OpenURL(site: string);
procedure CheckUpdate(const Silent: boolean = true);

procedure ProcessParameters;
procedure CheckOpenWithKeys;


implementation

uses
  uMain, uConstans, IceXML, uUpdateForm;

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
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;

  reg.OpenKey('*\shell\Add to Stuff Organizer library\command', true);
  reg.WriteString('', Application.ExeName + ' "%1"');
  reg.CloseKey;

  reg.OpenKey('Folder\shell\Add to Stuff Organizer library\command', true);
  reg.WriteString('', Application.ExeName + ' "%1"');
  reg.CloseKey;

  reg.Free;
end;

procedure CheckUpdate(const Silent: boolean = true);
var
  http: TIdHTTP;
  data: string;
  xml: TIceXML;
  Item: TXMLItem;
  SelfVer, updVer: string;
  updateFile: string;
begin
  http := TIdHTTP.Create(nil);
  xml := TIceXML.Create(nil);
  try
    data := '';
    try
      data := http.Get(UPDATE_URL);
      if data <> '' then
      begin
        xml.LoadFromString(data);

        if xml.Root.Name = 'UpdateData' then
        begin
          Item := xml.Root.GetItemEx('Product[MAIN]');
          if Assigned(Item) then
          begin
            updVer := Item.GetItemValue('Version', '');
            if updVer <> '' then
            begin
              SelfVer := IcePack.GetFileVersion();
              if IcePack.CheckVersion(SelfVer, updVer) = GreaterThanValue then
              begin
                if ShowUpdateForm(xml.Root) then
                begin
                  MessageDlg('A friss�t�sek �rv�nyes�t�s�hez, �jra kell ind�tani az alkalmaz�st.', mtInformation, [mbOK], 0);
                  updateFile := IcePack.GetTempDirectory + 'SOUpdater.exe';
                  if FileExists(updateFile) then
                    DeleteFile(PWideChar(updateFile));
                  IcePack.ExtractResource('UPDATE_EXE', updateFile);
                  if FileExists(updateFile) then
                    ShellExecute(0, 'open', PWideChar(updateFile), PWideChar(ExecPath), '', SW_SHOW);

                  Application.Terminate;
                end;
              end
              else if not Silent then
                MessageDlg('Application is up to date.', mtInformation, [mbOK], 0);
            end;
          end;
        end
        else if not Silent then
          MessageDlg('Unknow update file!', mtError, [mbOK], 0);


        //ShowMessage(xml.SaveToString);
      end;
    except
      on E: Exception do
      begin
        if not Silent then
          MessageDlg('Update error! ' + E.Message, mtError, [mbOK], 0);
      end;
    end;
  finally
    http.Free;
    xml.Free;
  end;
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
