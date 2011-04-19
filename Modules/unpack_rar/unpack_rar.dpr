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

library unpack_rar;

{$R *.dres}

uses
  Windows,
  SysUtils,
  Classes, Graphics,
  RAR,
  SOPluginDefs in '..\..\SOPluginDefs.pas';

{$E sop}

{$R *.res}

type
  TUnPackHelperClass = class(TObject)
  public
    procedure RarFilePasswordRequired(Sender: TObject;
      const HeaderPassword: boolean; const FileName: WideString;
      out NewPassword: AnsiString; out Cancel: boolean);
    procedure RarFileVolumeChanged(Sender: TObject;
      const NewVolumeName: AnsiString);
    procedure RarFileProgress(Sender: TObject; const FileName: WideString;
      const ArchiveBytesTotal, ArchiveBytesDone, FileBytesTotal,
      FileBytesDone: Int64);
    procedure RarFileError(Sender: TObject; const ErrorCode: Integer;
      const Operation: TRAROperation);
    procedure RarFileReplace(Sender: TObject; const ExistingData,
      NewData: TRARReplaceData; out Action: TRARReplaceAction);
    procedure RarNextVolumeRequired(Sender: TObject; const requiredFileName: AnsiString; out newFileName: AnsiString; out Cancel: boolean);
  end;

var
  PNeedPassCallBack: TNeedPassCallBack;
  PUnPackProgressCallBack: TUnPackProcessCallBack;
  PUnPackErrorCallBack: TUnPackErrorCallBack;
  PRemoveFromAllFiles: TRemoveVolumeFromFileListCallBack;
  proc: Pointer;
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
  MainIcon.Free;
end;

function PluginGetInfo(): PPluginInfo; stdcall;
begin
  New(result);
  result.Name := 'UnRAR plugin';
  result.PluginType := 1;
  result.Description := 'This is the default unrar plugin. Unpack the *.rar, *.partxx.rar files.';
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

function UnPack(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;
var
  RARFile: TRAR;
  helper: TUnPackHelperClass;
begin
  proc := ProcItem;
  helper := TUnPackHelperClass.Create;
  RARFile := TRAR.Create(nil);
  RARFile.ReadMultiVolumeToEnd := true;
  with RARFile do
  begin
    OnError := helper.RarFileError;
    OnProgress := helper.RarFileProgress;
    OnPasswordRequired := helper.RarFilePasswordRequired;
    OnVolumeChanged := helper.RarFileVolumeChanged;
    OnNextVolumeRequired := helper.RarNextVolumeRequired;
    OnReplace := helper.RarFileReplace;
  end;

  RARFile.OpenFile(FileName);
  RARFile.Extract(TargetDir, true, nil);

  RARFile.Free;
  helper.Free;
  result := UNPACK_RESULT_SUCCESS;
end;

procedure PluginRegUnPackFunctions(PluginCallBacks: PPluginUnPackCallbacks); stdcall;
begin
  PNeedPassCallBack := PluginCallBacks.NeedPassword;
  PUnPackProgressCallBack := PluginCallBacks.UnPackProgress;
  PUnPackErrorCallBack := PluginCallBacks.UnPackError;
  PRemoveFromAllFiles := PluginCallBacks.RemoveFileFromList;

  PluginCallBacks.RegisterFileType(Self, '*.part1.rar', integer(ptArchive), UnPack);
  PluginCallBacks.RegisterFileType(Self, '*.part01.rar', integer(ptArchive), UnPack);
  PluginCallBacks.RegisterFileType(Self, '*.part001.rar', integer(ptArchive), UnPack);
  PluginCallBacks.RegisterFileType(Self, '*.rar',  integer(ptArchive), UnPack);
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

{ TUnPackHelperClass }

procedure TUnPackHelperClass.RarFileError(Sender: TObject;
  const ErrorCode: Integer; const Operation: TRAROperation);
begin
  PUnPackErrorCallBack(proc, ErrorCode, 'Unpack error!');
end;

procedure TUnPackHelperClass.RarFileProgress(Sender: TObject;
  const FileName: WideString; const ArchiveBytesTotal, ArchiveBytesDone,
  FileBytesTotal, FileBytesDone: Int64);
begin
  PUnPackProgressCallBack(proc, '', ArchiveBytesDone, ArchiveBytesTotal);
end;

procedure TUnPackHelperClass.RarFileReplace(Sender: TObject; const ExistingData,
  NewData: TRARReplaceData; out Action: TRARReplaceAction);
begin
  Action := rrOverwrite;
end;

procedure TUnPackHelperClass.RarFileVolumeChanged(Sender: TObject;
  const NewVolumeName: AnsiString);
var
  volName: WideString;
begin
  volName := NewVolumeName;
  PRemoveFromAllFiles(proc, PWideChar(volName));
end;

procedure TUnPackHelperClass.RarNextVolumeRequired(Sender: TObject;
  const requiredFileName: AnsiString; out newFileName: AnsiString;
  out Cancel: boolean);
begin
  PUnPackErrorCallBack(proc, 0, PWideChar(Format('Missing volume! File: %s', [requiredFileName])));
  Cancel := true;
end;

procedure TUnPackHelperClass.RarFilePasswordRequired(Sender: TObject;
  const HeaderPassword: boolean; const FileName: WideString;
  out NewPassword: AnsiString; out Cancel: boolean);
var
  newPass: PWideChar;
begin
  newPass := PWideChar(NewPassword);
  PNeedPassCallBack(proc, newPass);
  NewPassword := newPass;
  Cancel := NewPassword = '';
end;

begin

end.
