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

library unpack_7z;

{$R *.dres}

uses
  Windows,
  SysUtils,
  Classes,
  Graphics,
  sevenzip,
  SOPluginDefs in '..\..\SOPluginDefs.pas';

{$E sop}

{$R *.res}

var
  PNeedPassCallBack: TNeedPassCallBack;
  PUnPackProgressCallBack: TUnPackProcessCallBack;
  PUnPackErrorCallBack: TUnPackErrorCallBack;
  PRemoveFromAllFiles: TRemoveVolumeFromFileListCallBack;
  proc: Pointer;
  maxValue: Int64 = 0;
  Self: Pointer;
  MainIcon: TIcon;

procedure PluginLoad(SelfObject: Pointer); stdcall;
begin
  Self := SelfObject;
  MainIcon := TIcon.Create;
  MainIcon.LoadFromResourceName(hInstance, 'MAIN_32_2');
end;

procedure PluginUnLoad(); stdcall;
begin
  MainIcon.Free;
end;

function PluginGetInfo(): PPluginInfo; stdcall;
begin
  New(result);
  result.Name := 'Un7Z plugin';
  result.PluginType := 1;
  result.Description := 'This is the default un7z plugin. Unpack the *.7z, *.iso files.';
  result.Icon := Pointer(MainIcon.Handle);
  result.Author := 'Ice Apps';
  result.WebPage := 'http://';
  result.Version := '1.0.0.0';
  result.InterfaceVersion := 1;
  result.VersionDate := '2010-04-16';
  result.MinimumVersion := '0.4.2.0';
end;

function PluginSetup(): boolean; stdcall;
begin
  result := true;
end;

function Un7ZGetPassword(sender: Pointer; var password: UnicodeString): HRESULT; stdcall;
var
  newPass: PWideChar;
begin
  newPass := PWideChar(password);
  PNeedPassCallBack(sender, newPass);
  password := PWideChar(newPass);
  result := S_OK;
end;

function Un7ZProgress(sender: Pointer; total: boolean; value: int64): HRESULT; stdcall;
begin
  if total then
    maxValue := value
  else if maxValue > 0 then
    PUnPackProgressCallBack(sender, '', value, maxValue);
  result := S_OK;
end;

function UnPack(ProcItem: Pointer; FileName, TargetDir: PWideChar; ArchiveType: TGUID): integer; stdcall;
var
  SevenZip: I7zInArchive;
begin
  proc := ProcItem;
  SevenZip := CreateInArchive(ArchiveType);
  SevenZip.SetPasswordCallback(proc, Un7ZGetPassword);
  SevenZip.SetProgressCallback(proc, Un7ZProgress);
  SevenZip.OpenFile(FileName);
  SevenZip.ExtractTo(TargetDir);
  SevenZip.Close;
  result := UNPACK_RESULT_SUCCESS;
end;

function UnPack7Z(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;
begin
  result := UnPack(ProcItem, FileName, TargetDir, CLSID_CFormat7z);
end;

function UnPackTAR(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;
begin
  result := UnPack(ProcItem, FileName, TargetDir, CLSID_CFormatTar);
end;

function UnPackISO(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;
begin
  result := UnPack(ProcItem, FileName, TargetDir, CLSID_CFormatIso);
end;

procedure PluginRegUnPackFunctions(PluginCallBacks: PPluginUnPackCallbacks); stdcall;
begin
  PNeedPassCallBack := PluginCallBacks.NeedPassword;
  PUnPackProgressCallBack := PluginCallBacks.UnPackProgress;
  PUnPackErrorCallBack := PluginCallBacks.UnPackError;
  PRemoveFromAllFiles := PluginCallBacks.RemoveFileFromList;

  PluginCallBacks.RegisterFileType(Self, '*.7z',  integer(ptArchive), UnPack7Z);
  PluginCallBacks.RegisterFileType(Self, '*.iso',  integer(ptISO), UnPackISO);
  PluginCallBacks.RegisterFileType(Self, '*.tar',  integer(ptArchive), UnPackTAR);
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
  PluginRegUnPackFunctions,
  PluginInitialize;

begin

end.
