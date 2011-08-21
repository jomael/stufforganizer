(*
	  This file is part of Stuff Organizer.

    Copyright (C) 2011  Ice Apps <so.iceapps@gmail.com>

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

library unpack_zip;

{$R *.dres}

uses
  Windows,
  SysUtils,
  Classes, Graphics,
  IcePack,
  AbBrowse,
  AbMeter,
  AbBase,
  AbZBrows,
  AbUnzper,
  AbArcTyp,
  AbUtils,
  SOPluginDefs in '..\..\Source\SOPluginDefs.pas';

{$E sop}

{$R *.res}

var
  PNeedPassCallBack: TNeedPassCallBack;
  PUnPackProgressCallBack: TUnPackProcessCallBack;
  PUnPackErrorCallBack: TUnPackErrorCallBack;
  PRemoveFromAllFiles: TRemoveVolumeFromFileListCallBack;
  proc: Pointer;
  Self: Pointer;
  MainIcon: TIcon;
type
  TUnPackHelperClass = class(TObject)
  public
    procedure ZipFileArchiveProgress(Sender: TObject; Progress: Byte;
      var Abort: Boolean);
    procedure ZipFileConfirmOverwrite(var Name: string;
      var Confirm: Boolean);
    procedure ZipFileNeedPassword(Sender: TObject;
      var NewPassword: AnsiString);
    procedure ZipFileProcessItemFailure(Sender: TObject;
      Item: TAbArchiveItem; ProcessType: TAbProcessType;
      ErrorClass: TAbErrorClass; ErrorCode: Integer);
  end;

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
  result.Name := 'UnZIP plugin';
  result.PluginType := 1;
  result.Description := 'This is the default unzip plugin. Unpack the *.zip, *.gz, *.tgz *.tar files.';
  result.Icon := Pointer(MainIcon.Handle);
  result.Author := 'Ice Apps';
  result.WebPage := 'http://stufforganizer.sourceforge.net';
  result.Version := '1.0.0.0';
  result.InterfaceVersion := 1;
  result.VersionDate := '2010-04-16';
  result.MinimumVersion := '0.4.5.0';
end;

function PluginSetup(): boolean; stdcall;
begin
  result := true;
end;

procedure TUnPackHelperClass.ZipFileArchiveProgress(Sender: TObject; Progress: Byte;
  var Abort: Boolean);
begin
  PUnPackProgressCallBack(proc, '', Progress, 100);
end;

procedure TUnPackHelperClass.ZipFileConfirmOverwrite(var Name: string;
  var Confirm: Boolean);
begin
  Confirm := true;
end;

procedure TUnPackHelperClass.ZipFileNeedPassword(Sender: TObject;
  var NewPassword: AnsiString);
var
  newPass: PWideChar;
begin
  newPass := PWideChar(WideString(NewPassword));
  PNeedPassCallBack(proc, newPass);
  NewPassword := newPass;
end;

procedure TUnPackHelperClass.ZipFileProcessItemFailure(Sender: TObject;
  Item: TAbArchiveItem; ProcessType: TAbProcessType; ErrorClass: TAbErrorClass;
  ErrorCode: Integer);
begin
  PUnPackErrorCallBack(proc, ErrorCode, 'Unpack error!');
end;

function UnPack(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;
var
  ZipFile: TAbUnZipper;
  helper: TUnPackHelperClass;
  AFile: string;
  Index: integer;
begin
  if Pos('.zip-missing', LowerCase(FileName)) > 0 then
    Exit(UNPACK_RESULT_SUCCESS);

  helper := TUnPackHelperClass.Create;
  proc := ProcItem;
  ZipFile := TAbUnZipper.Create(nil);
  with ZipFile do
  begin
    OnArchiveProgress := helper.ZipFileArchiveProgress;
    OnConfirmOverwrite := helper.ZipFileConfirmOverwrite;
    OnNeedPassword := helper.ZipFileNeedPassword;
    OnProcessItemFailure := helper.ZipFileProcessItemFailure;
  end;

  ZipFile.FileName := FileName;
  ZipFile.BaseDirectory := TargetDir;
  ZipFile.ExtractOptions := [eoCreateDirs, eoRestorePath];
  ZipFile.ExtractFiles('*.*');
  ZipFile.CloseArchive;
  ZipFile.Free;
  helper.Free;

  //Keresni a multi-volume-okat is
  Index := 1;
  AFile := ChangeFileExt(FileName, '.z' + IntToStr0(Index, 2));
  while FileExists(AFile) do
  begin
    PRemoveFromAllFiles(proc, PWideChar(AFile));
    Inc(Index);
    AFile := ChangeFileExt(FileName, '.z' + IntToStr0(Index, 2));
  end;

  result := UNPACK_RESULT_SUCCESS;
end;

procedure PluginRegUnPackFunctions(PluginCallBacks: PPluginUnPackCallbacks); stdcall;
begin
  PNeedPassCallBack := PluginCallBacks.NeedPassword;
  PUnPackProgressCallBack := PluginCallBacks.UnPackProgress;
  PUnPackErrorCallBack := PluginCallBacks.UnPackError;
  PRemoveFromAllFiles := PluginCallBacks.RemoveFileFromList;

  PluginCallBacks.RegisterFileType(Self, '*.zip', integer(ptArchive), UnPack);
  PluginCallBacks.RegisterFileType(Self, '*.gz', integer(ptArchive), UnPack);
  PluginCallBacks.RegisterFileType(Self, '*.tgz', integer(ptArchive), UnPack);
  PluginCallBacks.RegisterFileType(Self, '*.tar', integer(ptArchive), UnPack);
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
