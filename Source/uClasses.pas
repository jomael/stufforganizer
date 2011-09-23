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

unit uClasses;

interface

uses Windows, SysUtils, Graphics, Variants, Classes, IcePack, Dialogs,
  Generics.Collections, RAR, AbBrowse, AbMeter, AbBase, AbZBrows, AbUnzper,
  AbArcTyp, AbUtils, sevenzip, IceXML, SyncObjs, sqlitewrap, Masks;

type
  TPreProcessItem = class;

  TOnProcessChanged = procedure (Sender: TObject; Current, Total: Int64;
    MainCaption, SubCaption: string) of object;

  TProcessEvent = procedure(Sender: TPreProcessItem; StatusCode: integer;
    StatusText: string; Progress: integer) of object;

  PThreadEvent = ^TThreadEvent;
  TThreadEvent = record
    Item: TPreProcessItem;
    StatusCode: integer;
    StatusText: string;
    Progress: integer;
  end;

  PNodeCategory = ^TNodeCategory;
  TNodeCategory = record
    NodeType: integer;
    ID: integer;
    Name: string;
    Path: string;
    ParentID: integer;
    Color: TColor;
    IconIndex: integer;
    Count: integer;
  end;

  PNodeProduct = ^TNodeProduct;
  TNodeProduct = record
    ID: integer;
    Category: integer;
    CategoryName: string;
    CategoryIconIndex: integer;
    Name: string;
    DirName: string;
    SourcePath: string;
    TargetPath: string;
    Tags: string;
    URL: string;
    Description: string;
    Timestamp: TDateTime;
  end;

  TPreProcessItem = class(TObject)
  private
    FLock: TCriticalSection;

    AllFiles: TStrings;

    FInTestCase: boolean;
    FUnPack: boolean;
    FDelSourceDir: boolean;
    FDelNFO: boolean;
    FDescription: string;
    FNewDirPath: string;
    FNewDirName: string;
    FOldDirPath: string;
    FOldDirName: string;
    FDelSFV: boolean;
    FDelDIZ: boolean;
    FTags: string;
    FUnPackISO: boolean;
    FCategoryID: integer;
    FCategoryName: string;
    FSourcePath: string;
    FOnProcessChanged: TOnProcessChanged;
    FOnlyFile: boolean;
    FURL: string;
    FStatus: integer;
    FDirTreeSize: Int64;
    FWasUnpackError: boolean;
    FOnStatusEvent: TProcessEvent;
    FID: integer;

    function GetCategoryID: integer;
    function GetCategoryName: string;
    function GetDelDIZ: boolean;
    function GetDelNFO: boolean;
    function GetDelSFV: boolean;
    function GetDelSourceDir: boolean;
    function GetDescription: string;
    function GetDirTreeSize: Int64;
    function GetNewDirName: string;
    function GetNewDirPath: string;
    function GetOldDirName: string;
    function GetOldDirPath: string;
    function GetOnlyFile: boolean;
    function GetSourcePath: string;
    function GetStatus: integer;
    function GetTags: string;
    function GetUnPack: boolean;
    function GetUnPackISO: boolean;
    function GetURL: string;
    procedure SetID(const Value: integer);
    function GetID: integer;
    procedure SetDelDIZ(const Value: boolean);
    procedure SetDelNFO(const Value: boolean);
    procedure SetDelSFV(const Value: boolean);
    procedure SetDelSourceDir(const Value: boolean);
    procedure SetDescription(const Value: string);
    procedure SetNewDirName(const Value: string);
    procedure SetNewDirPath(const Value: string);
    procedure SetOldDirName(const Value: string);
    procedure SetOldDirPath(const Value: string);
    procedure SetUnPack(const Value: boolean);
    procedure SetTags(const Value: string);
    procedure SetCategoryID(const Value: integer);
    procedure SetUnPackISO(const Value: boolean);
    procedure SetSourcePath(const Value: string);
    procedure SetOnProcessChanged(const Value: TOnProcessChanged);
    procedure SetURL(const Value: string);
    procedure SetStatus(const Value: integer);
    procedure SetDirTreeSize(const Value: Int64);
    procedure SetOnStatusEvent(const Value: TProcessEvent);

    procedure GenerateAutoTags; overload;

    procedure ChangeNewDirName;
    function GetFilesByExt(FileList: TStrings; Extensions: string; SubDir: boolean): TStrings;
  public
    constructor Create(Directory: string; const InTestCase: boolean = false); overload;
    constructor Create(ID, CategoryID: integer; NewDirName, SourcePath, Tags, Description: string ); overload;
    destructor Destroy; override;

    procedure DoStatusEvent(StatusCode: integer; StatusText: string;
      Progress: integer);

    procedure RemoveFromAllFiles(FileName: string);

    function Unpacking(SourceDir: string; TempDir: string; Level: integer): integer;
    function Execute: integer;
    procedure SaveToDB;
    procedure SaveNFOAndImage;
    function UTF8Encode(Name: string): AnsiString;

    procedure SaveTagsToDB; overload;
    class procedure SaveTagsToDB(ID: integer; Tags: string); overload;
    class function GenerateAutoTags(Name: string): string; overload;

    procedure CalcDirSize;

    procedure Lock; inline;
    procedure UnLock; inline;

    procedure ProcessNFO;

    property CategoryName: string read GetCategoryName;
    property OnlyFile: boolean read GetOnlyFile;
  published
    property ID: integer read GetID write SetID;
    property SourcePath: string read GetSourcePath write SetSourcePath;
    property NewDirName: string read GetNewDirName write SetNewDirName;
    property OldDirName: string read GetOldDirName write SetOldDirName;
    property OldDirPath: string read GetOldDirPath write SetOldDirPath;
    property NewDirPath: string read GetNewDirPath write SetNewDirPath;
    property Description: string read GetDescription write SetDescription;
    property Tags: string read GetTags write SetTags;
    property URL: string read GetURL write SetURL;
    property UnPack: boolean read GetUnPack write SetUnPack;
    property UnPackISO: boolean read GetUnPackISO write SetUnPackISO;
    property CategoryID: integer read GetCategoryID write SetCategoryID;
    property DirTreeSize: Int64 read GetDirTreeSize write SetDirTreeSize;
    property DelNFO: boolean read GetDelNFO write SetDelNFO;
    property DelDIZ: boolean read GetDelDIZ write SetDelDIZ;
    property DelSFV: boolean read GetDelSFV write SetDelSFV;
    property DelSourceDir: boolean read GetDelSourceDir write SetDelSourceDir;
    property Status: integer read GetStatus write SetStatus;

    property OnProcessChanged: TOnProcessChanged read FOnProcessChanged write SetOnProcessChanged;
    property OnStatusEvent: TProcessEvent read FOnStatusEvent write SetOnStatusEvent;

  end;

var
  DB: TSqliteDatabase;
  InfoDB: TSqliteDatabase;
  FDBLocker: TCriticalSection;
  NeedPasswordEvent: TEvent;
  UserPassword: string;

  PreparingProducts: TObjectList<TPreProcessItem>;
  Categories: array of TNodeCategory;

  ConfigXML: TIceXML;


procedure UnPackNeedPassword(ProcItem: Pointer; var NewPassword: PWideChar); stdcall;
procedure UnPackProgress(ProcItem: Pointer; StatusText: PWideChar; Current, Total: Int64); stdcall;
procedure UnPackError(ProcItem: Pointer; ErrorCode: integer; ErrorText: PWideChar); stdcall;
procedure RemoveFromAllFiles(ProcItem: Pointer; FileName: PWideChar); stdcall;

procedure LockDB; inline;
procedure UnLockDB; inline;

implementation

uses
  uConstans, uPreProcessDirs, uPasswordForm, uPluginClasses, SOPluginDefs,
  ShellAPI, CodePages;

procedure LockDB;
begin
  FDBLocker.Enter;
end;
procedure UnLockDB;
begin
  FDBLocker.Leave;
end;

constructor TPreProcessItem.Create(ID, CategoryID: integer; NewDirName, SourcePath, Tags, Description: string );
begin
  Create(SourcePath);

  FID := ID;
  Self.CategoryID := CategoryID;
  Self.NewDirName := NewDirName;
  Self.Tags := Tags;
  Self.Description := Description;
  FStatus := ITEM_PASSIVE;
end;

constructor TPreProcessItem.Create(Directory: string; const InTestCase: boolean = false);
begin
  FInTestCase := InTestCase;

  FLock := TCriticalSection.Create;
  FID := -1;
  FWasUnpackError := false;
  FStatus := ITEM_ACTIVE;
  FDirTreeSize := 0;
  FTags := '';
  if (not FInTestCase) then
  begin
    FUnPack := ConfigXML.Root.GetItemValue('PreProcess.DefaultSettings.UnPack', '1') = '1';
    FDelSourceDir := ConfigXML.Root.GetItemValue('PreProcess.DefaultSettings.DeleteSourcePath', '0') = '1';
    FDelNFO := ConfigXML.Root.GetItemValue('PreProcess.DefaultSettings.DeleteNFO', '0') = '1';
    FDelSFV := ConfigXML.Root.GetItemValue('PreProcess.DefaultSettings.DeleteSFV', '1') = '1';
    FDelDIZ := ConfigXML.Root.GetItemValue('PreProcess.DefaultSettings.DeleteDIZ', '1') = '1';
    FUnPackISO := ConfigXML.Root.GetItemValue('PreProcess.DefaultSettings.UnPackISO', '0') = '1';
  end;
  FDescription := '';
  FOnlyFile := false;

  FSourcePath := Directory;
  FOldDirName := ExtractFileName(Directory);
  if FileExists(Directory) then
  begin
    FOnlyFile := true;
    FOldDirPath := ExtractFilePath(Directory);
    NewDirName := ChangeFileExt(FOldDirName, '');
  end
  else
  begin
    FOldDirPath := ExtractFilePath(Directory);
    NewDirName := FOldDirName;
  end;
  FNewDirPath := FOldDirPath + FNewDirName;
end;

destructor TPreProcessItem.Destroy;
begin
  inherited;

  FLock.Free;
end;

procedure TPreProcessItem.DoStatusEvent(StatusCode: integer; StatusText: string;
  Progress: integer);
begin
  if Assigned(OnStatusEvent) then
    OnStatusEvent(Self, StatusCode, StatusText, Progress);
end;

procedure TPreProcessItem.SaveTagsToDB;
begin
  SaveTagsToDB(Self.ID, Self.Tags);
end;

class procedure TPreProcessItem.SaveTagsToDB(ID: integer; Tags: string);
var
  TagList: TStringList;
  tag: string;
  I: integer;
begin
  LockDB;
  try
    //Tageket feldolgozni és elmenteni a Tags táblába
    DB.AddParamInt(':id', ID);
    DB.ExecSQL('delete from tags where product_id = :id');

    TagList := TStringList.Create;
    while Length(Tags) > 0 do
    begin
      tag := Trim(CutAt(Tags, ','));
      if TagList.IndexOf(tag) = -1 then
        TagList.Add(tag);
    end;

    for I := 0 to TagList.Count - 1 do
    begin
      DB.AddParamInt(':product_id', ID);
      DB.AddParamText(':tag', UTF8ToString(LowerCase(TagList[I])));
      DB.ExecSQL('insert into Tags (tag, product_id) values (:tag, :product_id)');
    end;
    TagList.Free;

  finally
    UnLockDB;
  end;
end;

procedure TPreProcessItem.SaveToDB;
var
  Table: TSQLiteTable;
  NewID: integer;
begin
  LockDB;
  try
    DoStatusEvent(STATUS_SAVEDB, Lang['Savingtodatabase'], 0);
    if Self.ID = -1 then
    begin
      DB.AddParamText(':path', UTF8Encode(Self.NewDirPath));
      Table := DB.GetTable('select id from Products where targetpath = :path');
      if not Table.EOF then
        Self.ID := Table.FieldAsInteger(0);
      Table.Free;
    end;

    //Paraméterek beállítása
    DB.AddParamInt(':id', Self.ID);
    if Self.CategoryID <> -1 then
      DB.AddParamInt(':category', Self.CategoryID)
    else
      DB.AddParamNull(':category');
    DB.AddParamText(':sourcepath', UTF8Encode(Self.SourcePath));
    DB.AddParamText(':targetdirname', UTF8Encode(Self.NewDirName));
    DB.AddParamText(':name', UTF8Encode(Self.NewDirName));
    DB.AddParamText(':targetpath', UTF8Encode(Self.NewDirPath));
    DB.AddParamText(':tags', UTF8Encode(Self.Tags));
    DB.AddParamText(':url', UTF8Encode(Self.URL));
    DB.AddParamText(':description', UTF8Encode(Self.Description));
    DB.AddParamFloat(':timestamp', Now);
    DB.AddParamInt(':status', iff(Self.Status = ITEM_PASSIVE, 0, 1));

    if Self.ID <> -1 then
    begin
      DB.ExecSQL('update Products set category = :category, name = :name, sourcepath = :sourcepath, targetdirname = :targetdirname, targetpath = :targetpath, tags = :tags, url = :url, description = :description, status = :status, timestamp=:timestamp where id = :id');
    end
    else
    begin
      DB.ExecSQL('insert into Products (category, name, sourcepath, targetdirname, targetpath, tags, url, description, timestamp, status) '+
      ' values (:category, :name, :sourcepath, :targetdirname, :targetpath, :tags, :url, :description, :timestamp, :status)');

      Self.ID := DB.LastInsertRowID;
    end;

    //Tageket feldolgozni és elmenteni a Tags-be
    Self.SaveTagsToDB;

    if Self.Status = ITEM_PROCESSING then
    begin
      SaveNFOAndImage;
    end;
    DoStatusEvent(STATUS_SAVEDB, Lang['Savedtodatabase'], 100);
  finally
    UnLockDB;
  end;
end;

procedure TPreProcessItem.SetCategoryID(const Value: integer);
begin
  Lock;
  FCategoryID := Value;
  ChangeNewDirName;
  UnLock;
end;

procedure TPreProcessItem.SetDelDIZ(const Value: boolean);
begin
  Lock;
  FDelDIZ := Value;
  UnLock;
end;

procedure TPreProcessItem.SetDelNFO(const Value: boolean);
begin
  Lock;
  FDelNFO := Value;
  UnLock;
end;

procedure TPreProcessItem.SetDelSFV(const Value: boolean);
begin
  Lock;
  FDelSFV := Value;
  UnLock;
end;

procedure TPreProcessItem.SetDelSourceDir(const Value: boolean);
begin
  Lock;
  FDelSourceDir := Value;
  UnLock;
end;

procedure TPreProcessItem.SetDescription(const Value: string);
begin
  Lock;
  FDescription := Value;
  UnLock;
end;

procedure TPreProcessItem.SetDirTreeSize(const Value: Int64);
begin
  Lock;
  FDirTreeSize := Value;
  UnLock;
end;

procedure TPreProcessItem.SetID(const Value: integer);
begin
  Lock;
  FID := Value;
  UnLock;
end;

procedure TPreProcessItem.SetNewDirName(const Value: string);
begin
  Lock;
  try
    FNewDirName := Value;

    ChangeNewDirName;
    if FTags = '' then
      GenerateAutoTags;
  finally
    UnLock;
  end;
end;

procedure TPreProcessItem.CalcDirSize;
begin
  if FOnlyFile then
    FDirTreeSize := GetFileSize(FSourcePath)
  else
    FDirTreeSize := IcePack.GetDirectorySize(FSourcePath);
end;

procedure TPreProcessItem.ChangeNewDirName;
var
  I: integer;
begin
  if FCategoryID = -1 then
  begin
    FNewDirPath := FOldDirPath + FNewDirName;
    FCategoryName := '';
  end
  else
  begin
    for I := Low(Categories) to High(Categories) do
      if Categories[I].ID = FCategoryID then
      begin
        if Categories[I].Path = '' then
          FNewDirPath := FOldDirPath + FNewDirName
        else
          FNewDirPath := IncludeTrailingBackslash(Categories[I].Path) + FNewDirName;
        FCategoryName := Categories[I].Name;
      end;
  end;
end;

class function TPreProcessItem.GenerateAutoTags(Name: string): string;
var
  s, t, tags: string;
  I: Integer;
begin
  tags := '';
  S := LowerCase(Trim(Name));

  t := '';
  for I := 1 to Length(S) do
  begin
    if IsCharAlphaNumeric(S[I]) then
      t := t + S[I]
    else
    begin
      if length(t) > 2 then
      begin
        if tags <> '' then
          tags := tags + ', ';
        tags := tags + t;
      end;
      t := '';
    end;
  end;
  if length(t) > 2 then
  begin
    if tags <> '' then
      tags := tags + ', ';
    tags := tags + t;
  end;


  result := tags;
end;

procedure TPreProcessItem.GenerateAutoTags;
begin
  FTags := GenerateAutoTags(FNewDirName);
end;

function TPreProcessItem.GetCategoryID: integer;
begin
  Lock;
  result := FCategoryID;
  UnLock;
end;

function TPreProcessItem.GetCategoryName: string;
begin
  Lock;
  result := FCategoryName;
  UnLock;
end;

function TPreProcessItem.GetDelDIZ: boolean;
begin
  Lock;
  result := FDelDIZ;
  UnLock;
end;

function TPreProcessItem.GetDelNFO: boolean;
begin
  Lock;
  result := FDelNFO;
  UnLock;
end;

function TPreProcessItem.GetDelSFV: boolean;
begin
  Lock;
  result := FDelSFV;
  UnLock;
end;

function TPreProcessItem.GetDelSourceDir: boolean;
begin
  Lock;
  result := FDelSourceDir;
  UnLock;
end;

function TPreProcessItem.GetDescription: string;
begin
  Lock;
  result := FDescription;
  UnLock;
end;

function TPreProcessItem.GetDirTreeSize: Int64;
begin
  Lock;
  result := FDirTreeSize;
  UnLock;
end;

function TPreProcessItem.GetID: integer;
begin
  Lock;
  result := FID;
  UnLock;
end;

function TPreProcessItem.GetNewDirName: string;
begin
  Lock;
  result := FNewDirName;
  UnLock;
end;

function TPreProcessItem.GetNewDirPath: string;
begin
  Lock;
  result := FNewDirPath;
  UnLock;
end;

function TPreProcessItem.GetOldDirName: string;
begin
  Lock;
  result := FOldDirName;
  UnLock;
end;

function TPreProcessItem.GetOldDirPath: string;
begin
  Lock;
  result := FOldDirPath;
  UnLock;
end;

function TPreProcessItem.GetOnlyFile: boolean;
begin
  Lock;
  result := FOnlyFile;
  UnLock;
end;

function TPreProcessItem.GetSourcePath: string;
begin
  Lock;
  result := FSourcePath;
  UnLock;
end;

function TPreProcessItem.GetStatus: integer;
begin
  Lock;
  result := FStatus;
  UnLock;
end;

function TPreProcessItem.GetTags: string;
begin
  Lock;
  result := FTags;
  UnLock;
end;

function TPreProcessItem.GetUnPack: boolean;
begin
  Lock;
  result := FUnPack;
  UnLock;
end;

function TPreProcessItem.GetUnPackISO: boolean;
begin
  Lock;
  result := FUnPackISO;
  UnLock;
end;

function TPreProcessItem.GetURL: string;
begin
  Lock;
  result := FURL;
  UnLock;
end;

procedure TPreProcessItem.Lock;
begin
  FLock.Enter;
end;

procedure TPreProcessItem.ProcessNFO;
var
  NFOs: TStrings;
  NFO: TStringList;
  url: string;
  I, C: Integer;
  SimpleText: TStringBuilder;
  Line: string;
  J: Integer;
begin
  NFOs := GetFiles(FNewDirPath, '*.nfo', true);
  if NFOs.Count > 0 then
  begin
    NFO := TStringList.Create;
    NFO.LoadFromFile(NFOs[0]);

    SimpleText := TStringBuilder.Create;
    for I := 0 to NFO.Count - 1 do
    begin
      C := Pos('http://', NFO[I]);
      if C > 0 then
      begin
        url := Trim(copy(NFO[I], C, Length(NFO[I])));
        FURL := CutAt(url, ' ');

      end;

      Line := '';
      for J := 1 to Length(NFO[I]) do
      begin
        if IsCharAlphaNumeric(NFO[I][J]) or (NFO[I][J] in ['.', ',', '?', '!', '-', ':', '/', ' ', #9]) then
          Line := Line + NFO[I][J];
      end;
      Line := Trim(Line);
      if Line <> '' then
        SimpleText.Append(Line + #13#10);
    end;
    FDescription := Trim(SimpleText.ToString);
    SimpleText.Free;
    NFO.Free;
  end;
  NFOs.Free;
end;

procedure TPreProcessItem.SaveNFOAndImage;
var
  I: Integer;
  Files: TStrings;
  FS: TFileStream;
  NFOs: TStrings;
  NFOContent: string;
begin
  LockDB;
  try
    //Find *.nfo to save
    DoStatusEvent(STATUS_SAVEDB, Lang['Findnfoforsave'], 50);
    NFOs := IcePack.GetFiles(Self.NewDirPath, '*.nfo', true);
    if NFOs.Count > 0 then
    begin
      InfoDB.ExecSQL('delete from ProductInfo where product_id = ' + IntToStr(Self.ID));
      DoStatusEvent(STATUS_SAVEDB, Format(Lang['Savesforprocess'], [ExtractFileName(NFOs[0])]), 70);
      NFOContent := IcePack.ReadFromFileS(NFOs[0]);
      InfoDB.AddParamText(':content', UTF8Encode(NFOContent));
      InfoDB.AddParamInt(':id', Self.ID);
      InfoDB.ExecSQL('insert into ProductInfo (product_id, nfo) values (:id, :content);');
    end;
    NFOs.Free;
    //Find image to save
    DoStatusEvent(STATUS_SAVEDB, Lang['Findimageforsave'], 80);
    Files := IcePack.GetFiles(Self.NewDirPath, '*.*', false);
    for I := 0 to Files.Count - 1 do
    begin
      if Pos(ExtractFileExt(Files[I]), GraphicFileMask(TGraphic)) > 0 then
      begin
        FS := TFileStream.Create(Files[I], fmOpenRead);
        try
          DoStatusEvent(STATUS_SAVEDB, Format(Lang['Savesforprocess'], [ExtractFileName(NFOs[0])]), 70);
          InfoDB.ExecSQL('delete from ProductImage where product_id = ' + IntToStr(Self.ID));
          InfoDB.AddParamInt(':id', Self.ID);
          InfoDB.AddParamText(':filename', UTF8Encode(ExtractFileName(Files[I])));
          InfoDB.AddParamBlob(':data', FS);
          InfoDB.ExecSQL('insert into ProductImage (product_id, filename, data) values (:id, :filename, :data);');
        finally
          FS.Free;
        end;
        break; //Only one image per item (currently)
      end;
    end;
    Files.Free;
  finally
    UnLockDB;
  end;
end;

procedure TPreProcessItem.SetNewDirPath(const Value: string);
begin
  Lock;
  FNewDirPath := Value;
  UnLock;
end;

procedure TPreProcessItem.SetOldDirName(const Value: string);
begin
  Lock;
  FOldDirName := Value;
  UnLock;
end;

procedure TPreProcessItem.SetOldDirPath(const Value: string);
begin
  Lock;
  FOldDirPath := Value;
  UnLock;
end;

procedure TPreProcessItem.SetOnProcessChanged(const Value: TOnProcessChanged);
begin
  Lock;
  FOnProcessChanged := Value;
  UnLock;
end;

procedure TPreProcessItem.SetOnStatusEvent(const Value: TProcessEvent);
begin
  Lock;
  FOnStatusEvent := Value;
  UnLock;
end;

procedure TPreProcessItem.SetSourcePath(const Value: string);
begin
  Lock;
  FSourcePath := Value;
  UnLock;
end;

procedure TPreProcessItem.SetStatus(const Value: integer);
begin
  Lock;
  FStatus := Value;
  UnLock;
end;

procedure TPreProcessItem.SetTags(const Value: string);
begin
  Lock;
  FTags := Value;
  UnLock;
end;

procedure TPreProcessItem.SetUnPack(const Value: boolean);
begin
  Lock;
  FUnPack := Value;
  UnLock;
end;

procedure TPreProcessItem.SetUnPackISO(const Value: boolean);
begin
  Lock;
  FUnPackISO := Value;
  UnLock;
end;

procedure TPreProcessItem.SetURL(const Value: string);
begin
  Lock;
  FURL := Value;
  UnLock;
end;

procedure UnPackNeedPassword(ProcItem: Pointer; var NewPassword: PWideChar); stdcall;
begin
  TPreProcessItem(ProcItem).DoStatusEvent(STATUS_NEED_PASSWORD, Lang['Waitingforpassword'], 0);
  NeedPasswordEvent.ResetEvent;
  WaitForSingleObject(NeedPasswordEvent.Handle, 10 * 60 * 1000);
  NewPassword := PWideChar(UserPassword);
end;

procedure UnPackProgress(ProcItem: Pointer; StatusText: PWideChar; Current, Total: Int64); stdcall;
begin
  if Total > 0 then
    TPreProcessItem(ProcItem).DoStatusEvent(STATUS_UNPACK, StatusText, Current * 100 div Total);
end;

procedure UnPackError(ProcItem: Pointer; ErrorCode: integer; ErrorText: PWideChar); stdcall;
begin
  TPreProcessItem(ProcItem).DoStatusEvent(STATUS_ERROR, ErrorText, 100);
  TPreProcessItem(ProcItem).FWasUnpackError := true;
end;

procedure RemoveFromAllFiles(ProcItem: Pointer; FileName: PWideChar); stdcall;
begin
  TPreProcessItem(ProcItem).RemoveFromAllFiles(FileName);
end;

procedure TPreProcessItem.RemoveFromAllFiles(FileName: string);
var
  Index: integer;
begin
  Index := Allfiles.IndexOf(FileName);
  if Index >= 0 then
    AllFiles.Delete(Index);
end;


function TPreProcessItem.Execute: integer;
var
  TempDir1, TempDir2: string;
  SourceDir, TargetDir, TargetPath, RelPath: string;
  Res: integer;
  TempList: TStrings;
  I, J: integer;
  CurrentFile: string;
begin
  Result := RESULT_ERROR;
//  try
    if FOnlyFile then
      SourceDir := ExtractFilePath(FSourcePath)
    else
      SourceDir := IncludeTrailingBackslash(FSourcePath);

    TargetDir := IncludeTrailingBackslash(FNewDirPath);
    ForceDirectories(TargetDir);

    if (TargetDir = SourceDir) and (not Unpack) and (not UnPackISO) then
    begin
      //Ha a cél megegyezik a forrással és nem kell kicsomagolni
      //Akkor csak nyilvántartásba vesszük
      Result := RESULT_COPY;
      Exit;
    end;

    TempDir1 := TargetDir + TARGET_TEMP_DIR + '1\';
    TempDir2 := TargetDir + TARGET_TEMP_DIR + '2\';

    //Ha a célkönyvtár már tartalmaz temp mappát akkor törölni
    if DirectoryExists(TempDir1) then
      IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(TempDir1), '', false, false);
    if DirectoryExists(TempDir2) then
      IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(TempDir2), '', false, false);

    //Ha a forrás könyvtár már tartalmaz temp mappát akkor törölni
    if DirectoryExists(SourceDir + TARGET_TEMP_DIR + '1\') then
      IcePack.IceFileOperation(FO_DELETE, SourceDir + TARGET_TEMP_DIR + '1', '', false, false);
    if DirectoryExists(SourceDir + TARGET_TEMP_DIR + '2\') then
      IcePack.IceFileOperation(FO_DELETE, SourceDir + TARGET_TEMP_DIR + '2', '', false, false);

    //Elsõ szintû kicsomagolás
    Res := Unpacking(SourceDir, TempDir1, 1);
    if Res <> RESULT_ERROR then
    begin
      if Res <> RESULT_COPY then //Ha történt kicsomagolás
      begin
        if FDelSourceDir and (FNewDirPath = FSourcePath) and (not OnlyFile) then
        begin
          //Ha törölni kell a forrást és a cél = forrás akkor most törölhetõ
          DoStatusEvent(STATUS_DELETEFILE, Format(Lang['Deletesourcefiles'], []), 0);
          IcePack.IceFileOperation(FO_DELETE, IncludeTrailingBackslash(FSourcePath) + '*.*', '', false, true);
          DoStatusEvent(STATUS_DELETEFILE, Format(Lang['Deletedsourcefiles'], []), 100);
          TempList := IcePAck.GetDirectories(FSourcePath, false);
          for J := TempList.Count - 1 downto 0 do
          begin
            if IncludeTrailingPathDelimiter(TempList[J]) <> IncludeTrailingPathDelimiter(TempDir1) then //A Temp1 könyvtárt kihagyjuk a törlésbõl, mert lesz második kör is
            begin
              DoStatusEvent(STATUS_DELETEDIR, Format(Lang['Deletesourcedirectorys'], [ExtractFileName(TempList[J])]), (J+1) * 100 div TempList.Count);
              IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(TempList[J]), '', false, true);
            end;
          end;
          DoStatusEvent(STATUS_DELETEDIR, Format(Lang['Deletedsourcefiles'], []), 0);
          TempList.Free;
        end;

        //Második szintû kicsomagolás a Temp1-bõl a Temp2-be
        Res := Unpacking(TempDir1, TempDir2, 2);
        if Res <> RESULT_ERROR then
        begin
          //A Temp2-ben levõ fájlokat átmozgatni
          TempList := IcePack.GetFiles(TempDir2, '*.*', true);
          for J := 0 to TempList.Count - 1 do
          begin
            if ProgressStopping then break;
            CurrentFile := TempList[J];
            RelPath := ExtractRelativePath(TempDir2, ExtractFilePath(CurrentFile));
            TargetPath := TargetDir + RelPath;
            ForceDirectories(TargetPath);
            DoStatusEvent(STATUS_MOVEFILE, Format(Lang['Movestotargetpath'], [ExtractFileName(CurrentFile)]), (J+1) * 100 div TempList.Count);

            if not IcePack.IceFileOperation(FO_MOVE, CurrentFile, IncludeTrailingBackslash(TargetPath), false, false) then
            //if not RenameFile(PWideChar(CurrentFile), PWideChar(TargetPath + ExtractFileName(CurrentFile))) then
              raise Exception.Create(Lang['Filemoveerror'] + CurrentFile);
          end;
          TempList.Free;
          DoStatusEvent(STATUS_DELETEFILE, Format(Lang['Deletetemporarydirectory2'], []), 0);
          IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(TempDir2), '', false, true);
        end;
      end
      else if Res = RESULT_COPY then //Ha a második körben nem történt kicsomagolás
      begin
        //A Temp1-ben levõ fájlokat átmozgatni
        TempList := IcePack.GetFiles(TempDir1, '*.*', true);
        for J := 0 to TempList.Count - 1 do
        begin
          if ProgressStopping then break;
          CurrentFile := TempList[J];
          RelPath := ExtractRelativePath(TempDir1, ExtractFilePath(CurrentFile));
          TargetPath := TargetDir + RelPath;
          ForceDirectories(TargetPath);
          DoStatusEvent(STATUS_MOVEFILE, Format(Lang['Movestotargetpath'], [ExtractFileName(CurrentFile)]), (J+1) * 100 div TempList.Count);
          if not IcePack.IceFileOperation(FO_MOVE, CurrentFile, IncludeTrailingBackslash(TargetPath), false, false) then
          //if not RenameFile(PWideChar(CurrentFile), PWideChar(TargetPath + ExtractFileName(CurrentFile))) then
            raise Exception.Create(Lang['Filemoveerror'] + CurrentFile);
        end;
      end;

      if Res <> RESULT_ERROR then
      begin
        if not DirectoryExists(FNewDirPath) then
          raise Exception.Create(Lang['Targetdirectorydoesntexists']);

        //Temp1 könyvtár törlése
        DoStatusEvent(STATUS_DELETEFILE, Format(Lang['Deletetemporarydirectory1'], []), 0);
        IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(TempDir1), '', false, true);

        //Ha a cél <> forrással és kell törölni, akkor itt
        if FDelSourceDir and (FNewDirPath <> FSourcePath) then
        begin
          if not OnlyFile then
          begin
            DoStatusEvent(STATUS_DELETEDIR, Format(Lang['Deletesourcedirectorys'], [ExtractFileName(FSourcePath)]), 0);
            IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(FSourcePath), '', false, true);
            DoStatusEvent(STATUS_DELETEDIR, Format(Lang['Deletedsourcedirectorys'], [ExtractFileName(FSourcePath)]), 100);
          end
          else if FileExists(FSourcePath) then
          begin
            DoStatusEvent(STATUS_DELETEDIR, Format(Lang['Deletesourcefiles0'], [FSourcePath]), 0);
            IcePack.IceFileOperation(FO_DELETE, FSourcePath, '', false, true);
            DoStatusEvent(STATUS_DELETEDIR, Format(Lang['Deletedsourcefiles0'], [FSourcePath]), 100);
          end;
        end;
        if ProgressStopping then Exit;

        ProcessNFO;

        if FDelNFO then
          IcePack.IceFileOperation(FO_DELETE, IncludeTrailingBackslash(FNewDirPath) + '*.nfo', '', false, true);
        if FDelDIZ then
          IcePack.IceFileOperation(FO_DELETE, IncludeTrailingBackslash(FNewDirPath) + '*.diz', '', false, true);
        if FDelSFV then
        begin
          IcePack.IceFileOperation(FO_DELETE, IncludeTrailingBackslash(FNewDirPath) + '*.sfv', '', false, true);
          IcePack.IceFileOperation(FO_DELETE, IncludeTrailingBackslash(FNewDirPath) + '*.md5', '', false, true);
        end;
        Result := RESULT_UNPACK;
      end;
    end;

end;


function TPreProcessItem.GetFilesByExt(FileList: TStrings; Extensions: string; SubDir: boolean): TStrings;
var
  ext: string;
  I: Integer;
  temp: string;
begin
  result := TStringList.Create;

  ext := LowerCase(CutAt(Extensions, ';'));
  while Length(ext) > 0 do
  begin
//    ext := StringReplace(ext, '*', '', [rfReplaceAll]);
    //temp := IcePack.GetFiles(SourceDir, ext, SubDir);

    for I := 0 to FileList.Count - 1 do
    begin
      if MatchesMask(LowerCase(ExtractFileName(FileList[I])), ext) then
        result.Add(FileList[I]);

//      temp := Copy(FileList[I], Length(FileList[I]) - Length(ext) + 1, Length(FileList[I]));
//      if LowerCase(temp) = ext then
//        result.Add(FileList[I]);
    end;

    ext := LowerCase(CutAt(Extensions, ';'));
  end;
end;

function TPreProcessItem.Unpacking(SourceDir: string; TempDir: string; Level: integer): integer;
var
  I, J, Index: Integer;
  bHas: boolean;
  AFile, CurrentFile, RelPath, TargetPath: string;
  PackFiles: TStrings;
  TargetDir: string;
  UnPackCB: TFileProcCallBackItem;
begin
  result := RESULT_COPY;
  FWasUnpackError := false;
  TargetDir := FNewDirPath + '\';
  ForceDirectories(TempDir);


  if UnPack then
    DoStatusEvent(STATUS_SEARCH_ARCHIVE, Format(Lang['Searcharchives'], []), 0);

  if FOnlyFile and (Level = 1) then
  begin
    AllFiles := TStringList.Create;
    AllFiles.Add(FSourcePath);
  end
  else
    AllFiles := IcePack.GetFiles(SourceDir, '*.*', true);

  //OrigFiles := TStringList.Create;
  //OrigFiles.AddStrings(AllFiles);
  try
    try
      if UnPack then
      begin
        for J := 0 to FileProcCallBackList.Count - 1 do
        begin
          UnPackCB := TFileProcCallBackItem(FileProcCallBackList[J]);
          if (UnPackCB.FileType = ptArchive) and (UnPackCB.Status) then
          begin
            PackFiles := GetFilesByExt(AllFiles, UnPackCB.FilterType, true);
            if (PackFiles.Count > 0) then
            begin
              for I := 0 to PackFiles.Count - 1 do
              begin
                CurrentFile := PackFiles[I];
                DoStatusEvent(STATUS_UNPACK, Format(Lang['Unpacks'], [ExtractFileName(CurrentFile)]), 0);
                RelPath := SysUtils.ExtractRelativePath(SourceDir, ExtractFilePath(CurrentFile));
                ForceDirectories(TempDir + RelPath);
                result := UnPackCB.CallBack(Self, PWideChar(CurrentFile), PWideChar(TempDir + RelPath));
                if FWasUnpackError or (result = UNPACK_RESULT_ERROR) then
                  raise Exception.Create(Lang['Unpackerror']);

                RemoveFromAllFiles(CurrentFile);
              end;
            end;
            PackFiles.Free;
          end;
        end;

      end;

      if UnPackISO then
      begin
        for J := 0 to FileProcCallBackList.Count - 1 do
        begin
          UnPackCB := TFileProcCallBackItem(FileProcCallBackList[J]);
          if (UnPackCB.FileType = ptISO) and (UnPackCB.Status) then
          begin
            PackFiles := GetFilesByExt(AllFiles, UnPackCB.FilterType, true);
            if (PackFiles.Count > 0) then
            begin
              for I := 0 to PackFiles.Count - 1 do
              begin
                CurrentFile := PackFiles[I];
                DoStatusEvent(STATUS_UNPACK, Format(Lang['Extracts'], [ExtractFileName(CurrentFile)]), 0);
                RelPath := SysUtils.ExtractRelativePath(SourceDir, ExtractFilePath(CurrentFile));
                ForceDirectories(TempDir + RelPath);
                result := UnPackCB.CallBack(Self, PWideChar(CurrentFile), PWideChar(TempDir + RelPath));
                if FWasUnpackError or (result = UNPACK_RESULT_ERROR) then
                  raise Exception.Create(Lang['Extracterror']);

                RemoveFromAllFiles(CurrentFile);
              end;
            end;
            PackFiles.Free;
          end;
        end;
      end;

      //Megmaradt fájlokat átmozgatni a {célkönyvtárba} tempbe ha a Level > mint 1 (inter temp)
      for I := 0 to AllFiles.Count - 1 do
      begin
        CurrentFile := AllFiles[I];
        RelPath := SysUtils.ExtractRelativePath(SourceDir, ExtractFilePath(CurrentFile));
        TargetPath := TempDir + RelPath;
        ForceDirectories(TargetPath);

        if (Level > 1) or (FDelSourceDir) or ((result = RESULT_COPY) and (FSourcePath = FNewDirPath)) then
        begin
          //Fájlok mozgatása:
          // 1. Ha már a második szinten vagyunk, akkor mozgassa a tempbõl a cél helyre
          // 2. Ha törölni kell a forrást, akkor a megmaradt fájlokat mozgassa
          // 3. Ha nem történt tömörítés és a célhely megegyezik az új hellyel
          DoStatusEvent(STATUS_MOVEFILE, Format(Lang['Movestotemp'], [ExtractFileName(CurrentFile)]), (I+1) * 100 div AllFiles.Count);
          if not IcePack.IceFileOperation(FO_MOVE, CurrentFile, IncludeTrailingBackslash(TargetPath), false, false) then
            raise Exception.Create(Lang['Filemoveerror'] + CurrentFile);

        end
        else
        begin
          DoStatusEvent(STATUS_COPYFILE, Format(Lang['Copystotemp'], [ExtractFileName(CurrentFile)]), (I+1) * 100 div AllFiles.Count);
          if not CopyFile(PWideChar(CurrentFile), PWideChar(TargetPath + ExtractFileName(CurrentFile)), false) then
            raise Exception.Create(Lang['Filecopyerror'] + CurrentFile);
        end;
      end;

    finally
      AllFiles.Free;
    end;
  except
   on E: Exception do
   begin
     DoStatusEvent(STATUS_ERROR, E.Message, 0);

     result := RESULT_ERROR;
   end;
  end;
end;
function TPreProcessItem.UTF8Encode(Name: string): AnsiString;
begin
  result := CodePages.UTF8Encode(Name);
end;

procedure TPreProcessItem.UnLock;
begin
  FLock.Leave;
end;

initialization
  FDBLocker := TCriticalSection.Create;
  NeedPasswordEvent := TEvent.Create();

finalization
  FDBLocker.Free;
  NeedPasswordEvent.Free;

end.


