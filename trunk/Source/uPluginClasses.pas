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

unit uPluginClasses;

interface

uses
  Windows, SysUtils, Messages, Dialogs, Classes, IcePack, SOPluginDefs;

type
  TFileProcCallBackItem = class;

  TPluginItem = class(TObject)
  private
    FRegisteredFileTypes: TList;
    FInitialized: boolean;
    FFileName: string;
    FPluginInitialize: TPluginInitialize;
    FPluginSetup: TPluginSetup;
    FPluginLoad: TPluginLoadProc;
    FPluginUnLoad: TPluginUnLoadProc;
    FPluginRegUnPackFunctions: TPluginRegUnPackFunctions;
    FPluginGetInfo: TPluginGetInfo;
    FPluginRegDescriptorFunctions: TPluginRegDescriptorFunctions;


    procedure SetFileName(const Value: string);
    procedure SetPluginGetInfo(const Value: TPluginGetInfo);
    procedure SetPluginInitialize(const Value: TPluginInitialize);
    procedure SetPluginLoadProc(const Value: TPluginLoadProc);
    procedure SetPluginRegUnPackFunctions(const Value: TPluginRegUnPackFunctions);
    procedure SetPluginSetup(const Value: TPluginSetup);
    procedure SetPluginUnLoadProc(const Value: TPluginUnLoadProc);
    function CheckPluginExtensionState(Filter: string;
      Plugin: TPluginItem): boolean;
    procedure SetPluginRegDescriptorFunctions(
      const Value: TPluginRegDescriptorFunctions);
  published
  public
    PluginInfo: TPluginInfo;
    property FileName: string read FFileName write SetFileName;
    property PluginLoad: TPluginLoadProc read FPluginLoad write SetPluginLoadProc;
    property PluginUnLoad: TPluginUnLoadProc read FPluginUnLoad write SetPluginUnLoadProc;
    property PluginGetInfo: TPluginGetInfo read FPluginGetInfo write SetPluginGetInfo;
    property PluginSetup: TPluginSetup read FPluginSetup write SetPluginSetup;
    property PluginRegUnPackFunctions: TPluginRegUnPackFunctions read FPluginRegUnPackFunctions write SetPluginRegUnPackFunctions;
    property PluginRegDescriptorFunctions: TPluginRegDescriptorFunctions read FPluginRegDescriptorFunctions write SetPluginRegDescriptorFunctions;
    property PluginInitialize: TPluginInitialize read FPluginInitialize write SetPluginInitialize;

    constructor Create(FileName: string);
    destructor Destroy; override;

    function Initialize: boolean;
    function RegisterFileType(Filter: string; FileProcType: TFileProcType; Proc: TFileProcCallback): TFileProcCallBackItem;
  end;

  TPluginManager = class(TObject)
  private
    FPlugins: TList;
    function GetCount: integer;
    function GetItems(Index: integer): TPluginItem;
  public
    property Count: integer read GetCount;
    property Items[Index: integer]: TPluginItem read GetItems; default;

    constructor Create;
    destructor Destroy; override;

    procedure LoadPlugins;
    procedure UnloadPlugins;

    function GetPluginByName(plgName: string): TPluginItem;
  end;

  TFileProcCallBackItem = class
  public
    FilterType: string;
    FileType: TFileProcType;
    Plugin: TPluginItem;
    CallBack: TFileProcCallback;
    Status: boolean;

    constructor Create(FilterType: string; FileType: TFileProcType; Plugin: TPluginItem; CallBack: TFileProcCallback);
  end;

  TDescriptorCallBackItem = class
  public
    Plugin: TPluginItem;
    Name: string;
    CallBack: TRunDescriptorCallback;

    constructor Create(Plugin: TPluginItem; Name: string; CallBack: TRunDescriptorCallback);
  end;

var
  PluginManager: TPluginManager;
  FileProcCallBackList: TList;
  DescriptorCallBackList: TList;

procedure RegisterFileProcCallBack(Plugin: Pointer; FileExt: PWideChar; FileProcType: integer; ProcCallBack: TFileProcCallback); stdcall;
procedure RegisterDescriptorCallBack(Plugin: Pointer; Name: PWideChar; ProcCallBack: TRunDescriptorCallback); stdcall;

procedure DescriptorSaveProductImage(Plugin: Pointer; ProductInfo: PPluginProductItem; FileName: PWideChar); stdcall;
procedure DescriptorSaveProductInfo(Plugin: Pointer; ProductInfo: PPluginProductItem); stdcall;
function DescriptorUserSelect(Plugin: Pointer; ItemList: PTDescriptorProductInfoArray): integer; stdcall;

implementation

uses
  uMain, uClasses, IceXML, uUserSelectForm;


procedure DescriptorSaveProductInfo(Plugin: Pointer; ProductInfo: PPluginProductItem); stdcall;
begin
  MainForm.SaveNewProductInfo(ProductInfo);
end;

function DescriptorUserSelect(Plugin: Pointer; ItemList: PTDescriptorProductInfoArray): integer; stdcall;
begin
  result := UserSelectList(ItemList);
end;

procedure DescriptorSaveProductImage(Plugin: Pointer; ProductInfo: PPluginProductItem; FileName: PWideChar); stdcall;
begin
  MainForm.SaveNewProductImage(ProductInfo, string(FileName));
end;

{ TPluginItem }

constructor TPluginItem.Create(FileName: string);
begin
  FRegisteredFileTypes := TList.Create;
  FInitialized := false;
  FFileName := FileName
end;

destructor TPluginItem.Destroy;
begin
  while FRegisteredFileTypes.Count > 0 do
  begin
    TFileProcCallBackItem(FRegisteredFileTypes[0]).Free;
    FRegisteredFileTypes.Delete(0);
  end;

  if FInitialized then
    FPluginUnLoad;

  inherited;
end;

function TPluginItem.Initialize: boolean;
var
  DLLHandle: Cardinal;
  info: PPluginInfo;
begin
  result := false;
  DLLHandle := LoadLibrary(PWideChar(FFileName));
  if DLLHandle <> 0 then
  begin
    FPluginLoad := GetProcAddress(DLLHandle, 'PluginLoad');
    FPluginUnLoad := GetProcAddress(DLLHandle, 'PluginUnLoad');
    FPluginGetInfo := GetProcAddress(DLLHandle, 'PluginGetInfo');
    FPluginSetup := GetProcAddress(DLLHandle, 'PluginSetup');
    FPluginRegUnPackFunctions := GetProcAddress(DLLHandle, 'PluginRegUnPackFunctions');
    FPluginRegDescriptorFunctions := GetProcAddress(DLLHandle, 'PluginRegDescriptorFunctions');
    FPluginInitialize := GetProcAddress(DLLHandle, 'PluginInitialize');

    result := Assigned(FPluginLoad)
      and Assigned(FPluginUnLoad)
      and Assigned(FPluginGetInfo)
      and Assigned(FPluginSetup)
      and (Assigned(FPluginRegUnPackFunctions) or Assigned(FPluginRegDescriptorFunctions))
      and Assigned(FPluginInitialize);

    if result then
    begin
      FPluginLoad(Self);

      info := FPluginGetInfo;
      PluginInfo.Name := info.Name;
      PluginInfo.PluginType := info.PluginType;
      PluginInfo.Version := info.Version;
      PluginInfo.Description := info.Description;
      PluginInfo.Icon := info.Icon;
      PluginInfo.Author := info.Author;
      PluginInfo.WebPage := info.WebPage;
      PluginInfo.InterfaceVersion := info.InterfaceVersion;
      FreeMem(info);

      FInitialized := true;
    end;
  end;
end;

function TPluginItem.RegisterFileType(Filter: string; FileProcType: TFileProcType; Proc: TFileProcCallback): TFileProcCallBackItem;
begin
  result := TFileProcCallBackItem.Create(Filter, FileProcType, Self, Proc);
  result.Status := CheckPluginExtensionState(Filter, Self);
end;

function TPluginItem.CheckPluginExtensionState(Filter: string; Plugin: TPluginItem): boolean;
var
  Item: TXMLItem;
  AList: TList;
  Filters: TXMLItem;
  I: Integer;
  bFoundActive, bFoundSelf: boolean;
begin
  result := false;
  Filters := ConfigXML.Root.GetItemEx('PluginFilters', true);
  AList := Filters.FilterItemList('(extension=' + Filter + ')');
  bFoundSelf := false;
  bFoundActive := false;
  for I := 0 to AList.Count - 1 do
  begin
    Item := TXMLItem(AList[I]);
    if Item.Attr['plugin'] = ExtractFileName(Plugin.FileName) then
    begin
      bFoundSelf := true;
      result := Item.GetParamAsInt('state') = 1;
      break;
    end
    else if Item.GetParamAsInt('state') = 1 then
    begin
      bFoundActive := true;
    end;
  end;
  AList.Free;
  if (not bFoundSelf) then
  begin
    Item := Filters.New('Filter');
    Item.SetParamValue('extension', Filter);
    Item.SetParamValue('plugin', ExtractFileName(Plugin.FileName));
    Item.SetParamValue('state', iff(bFoundActive, 0, 1)); //default active, ha ez a filter máshol még nincs aktiválva
    result := not bFoundActive;
  end;
end;

procedure TPluginItem.SetFileName(const Value: string);
begin
  FFileName := Value;
end;

procedure TPluginItem.SetPluginGetInfo(const Value: TPluginGetInfo);
begin
  FPluginGetInfo := Value;
end;

procedure TPluginItem.SetPluginInitialize(const Value: TPluginInitialize);
begin
  FPluginInitialize := Value;
end;

procedure TPluginItem.SetPluginLoadProc(const Value: TPluginLoadProc);
begin
  FPluginLoad := Value;
end;

procedure TPluginItem.SetPluginRegDescriptorFunctions(
  const Value: TPluginRegDescriptorFunctions);
begin
  FPluginRegDescriptorFunctions := Value;
end;

procedure TPluginItem.SetPluginRegUnPackFunctions(const Value: TPluginRegUnPackFunctions);
begin
  FPluginRegUnPackFunctions := Value;
end;

procedure TPluginItem.SetPluginSetup(const Value: TPluginSetup);
begin
  FPluginSetup := Value;
end;

procedure TPluginItem.SetPluginUnLoadProc(const Value: TPluginUnLoadProc);
begin
  FPluginUnLoad := Value;
end;

{ TPluginManager }

constructor TPluginManager.Create;
begin
  FPlugins := TList.Create;
end;

destructor TPluginManager.Destroy;
begin
  UnloadPlugins;
  FPlugins.Free;

  inherited;
end;

function TPluginManager.GetCount: integer;
begin
  result := FPlugins.Count;
end;

function TPluginManager.GetItems(Index: integer): TPluginItem;
begin
  result := FPlugins[Index];
end;

function TPluginManager.GetPluginByName(plgName: string): TPluginItem;
var
  I: Integer;
begin
  result := nil;
  for I := 0 to FPlugins.Count - 1 do
    if LowerCase(ExtractFileName(TPluginItem(FPlugins[I]).FileName)) = LowerCase(plgName + '.sop') then
      Exit(TPluginItem(FPlugins[I]));
end;

procedure TPluginManager.LoadPlugins;
var
  Files: TStrings;
  I: Integer;
  Plugin: TPluginItem;
  recUnPack: PPluginUnPackCallbacks;
  recDescriptor: PPluginDescriptorCallbacks;
begin
  Files := GetFiles(PluginPath, '*.sop', true);
  for I := 0 to Files.Count - 1 do
  begin
    Plugin := TPluginItem.Create(Files[I]);
    if Plugin.Initialize then
      FPlugins.Add(Plugin)
    else
      Plugin.Free;
  end;

  New(recUnPack);
  recUnPack.RegisterFileType := RegisterFileProcCallBack;
  recUnPack.UnPackError := UnPackError;
  recUnPack.NeedPassword := UnPackNeedPassword;
  recUnPack.UnPackProgress := UnPackProgress;
  recUnPack.RemoveFileFromList := RemoveFromAllFiles;

  New(recDescriptor);
  recDescriptor.RegisterDescriptor := RegisterDescriptorCallBack;
  recDescriptor.SaveImageToDB := DescriptorSaveProductImage;
  recDescriptor.SaveProductInfoToDB := DescriptorSaveProductInfo;
  recDescriptor.UserSelect := DescriptorUserSelect;

  //Initialize plugins
  for I := 0 to FPlugins.Count - 1 do
  begin
    Plugin := FPlugins[I];
    if (Plugin.PluginInfo.PluginType = integer(ptUnPack)) and Assigned(Plugin.PluginRegUnPackFunctions) then
    begin
      Plugin.PluginRegUnPackFunctions(recUnPack);
    end
    else if (Plugin.PluginInfo.PluginType = integer(ptDescriptor)) and Assigned(Plugin.PluginRegDescriptorFunctions) then
    begin
      Plugin.PluginRegDescriptorFunctions(recDescriptor);
    end;
    Plugin.PluginInitialize;
  end;
  FreeMem(recUnPack);
  FreeMem(recDescriptor);
end;

procedure TPluginManager.UnloadPlugins;
begin
  while FPlugins.Count > 0 do
  begin
    TPluginItem(FPlugins[0]).Free;
    FPlugins.Delete(0);
  end;
end;

procedure RegisterFileProcCallBack(Plugin: Pointer; FileExt: PWideChar; FileProcType: integer; ProcCallBack: TFileProcCallback);
var
  Item: TFileProcCallBackItem;
  PPlugin: TPluginItem;
begin
  PPlugin := TPluginItem(Plugin);
  Item := PPlugin.RegisterFileType(LowerCase(string(FileExt)), TFileProcType(FileProcType), ProcCallBack);
  FileProcCallBackList.Add(Item);
end;

procedure RegisterDescriptorCallBack(Plugin: Pointer; Name: PWideChar; ProcCallBack: TRunDescriptorCallback); stdcall;
var
  Item: TDescriptorCallBackItem;
  PPlugin: TPluginItem;
begin
  PPlugin := TPluginItem(Plugin);
  Item := TDescriptorCallBackItem.Create(PPlugin, string(Name), ProcCallBack);
  DescriptorCallBackList.Add(Item);
end;

{ TUnPackCallBackItem }

constructor TFileProcCallBackItem.Create(FilterType: string; FileType: TFileProcType; Plugin: TPluginItem;
  CallBack: TFileProcCallback);
begin
  Self.FilterType := FilterType;
  Self.FileType := FileType;
  Self.Plugin := Plugin;
  Self.CallBack := CallBack;
  Self.Status := false;
end;

{ TDescriptorCallBackItem }

constructor TDescriptorCallBackItem.Create(Plugin: TPluginItem; Name: string;
  CallBack: TRunDescriptorCallback);
begin
  Self.Plugin := Plugin;
  Self.Name := Name;
  Self.CallBack := CallBack;
end;

initialization
  FileProcCallBackList := TList.Create;
  DescriptorCallBackList := TList.Create;

finalization
  FileProcCallBackList.Free;
  DescriptorCallBackList.Free;

end.
