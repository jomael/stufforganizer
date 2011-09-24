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

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DirectoryEdit, IcePack, ImgList, PngImageList, CoolTrayIcon,
  Generics.Collections, sqlitewrap, ComCtrls, ExtCtrls, VirtualTrees,
  Menus, ShellApi, ActiveX, Gradient, uClasses, ActnList, PngFunctions,
  jpeg, ToolWin, pngimage, JvBaseDlg, JvBrowseFolder, Math, SyncObjs, IceXML,
  Generics.Defaults, W7TaskBar, ShlObj, AbBase, AbBrowse, AbZBrows, AbZipper,
  AbUtils, AbUnzper, SOPluginDefs, uConstans, JvAppInst, IceLanguage;

type

  TMainForm = class(TForm)
    CoolTrayIcon1: TCoolTrayIcon;
    stateImages: TPngImageList;
    ToolbarImages: TPngImageList;
    ListPanel: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    pmCategories: TPopupMenu;
    Deletecategory1: TMenuItem;
    VList: TVirtualStringTree;
    CategoryPanel: TPanel;
    FilterList: TVirtualStringTree;
    DescrPanel: TPanel;
    Splitter2: TSplitter;
    pmList: TPopupMenu;
    Deleteselecteditems1: TMenuItem;
    Modifycategory1: TMenuItem;
    alPopup: TActionList;
    ilMenu: TPngImageList;
    aModifyCategory: TAction;
    aDeleteCategory: TAction;
    aDeleteItems: TAction;
    aOpenDir: TAction;
    Opendirectory1: TMenuItem;
    pmAddStuff: TPopupMenu;
    Addfiless1: TMenuItem;
    Adddirectory1: TMenuItem;
    HeaderPanel: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Panel1: TPanel;
    DescrImagePanel: TPanel;
    Panel4: TPanel;
    eTags: TEdit;
    mProductDescr: TMemo;
    Label1: TLabel;
    lProductName: TLabel;
    ProductImage: TImage;
    Gradient1: TGradient;
    Gradient2: TGradient;
    DescrFuncPanel: TPanel;
    Gradient3: TGradient;
    bShowNFO: TLabel;
    bAddNFO: TLabel;
    Bevel3: TBevel;
    alToolbar: TActionList;
    aAddFile: TAction;
    aAddDirectory: TAction;
    aQueue: TAction;
    aConsistenceCheck: TAction;
    aAddStuff: TAction;
    PictureDialog: TOpenDialog;
    imgNoPicture: TImage;
    OD: TOpenDialog;
    DD: TJvBrowseForFolderDialog;
    lURL: TLabel;
    bChangeURL: TLabel;
    bChangePicture: TLabel;
    Bevel2: TBevel;
    lChnageDirectoryName: TLabel;
    aNewCategory: TAction;
    Addnewcategory1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ilCategories: TPngImageList;
    aAddToWatch: TAction;
    Adddirectorytowatchlist1: TMenuItem;
    spDescrImage: TSplitter;
    Splitter4: TSplitter;
    pmTray: TPopupMenu;
    ilTray: TPngImageList;
    aShowMainForm: TAction;
    aExit: TAction;
    Show1: TMenuItem;
    N3: TMenuItem;
    Exit1: TMenuItem;
    aViewProcessLog: TAction;
    Viewprocesslog1: TMenuItem;
    lGoogleSearch: TLabel;
    aReprocess: TAction;
    Reprocess1: TMenuItem;
    aSettings: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    aDBBackup: TAction;
    aDBRestore: TAction;
    aDBVacuum: TAction;
    pmDBTools: TPopupMenu;
    Databasebackup1: TMenuItem;
    Databaserestore1: TMenuItem;
    N4: TMenuItem;
    Databasevacuum1: TMenuItem;
    aDelSource: TAction;
    Deletesourcefiles1: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    eSearch: TEdit;
    aOpenSourceDir: TAction;
    Opensourcedirectory1: TMenuItem;
    aTargetToClipBoard: TAction;
    Copytargetdirectorytoclipboard1: TMenuItem;
    ools1: TMenuItem;
    ZipBackup: TAbZipper;
    ZipRestore: TAbUnZipper;
    aPlugins: TAction;
    Plugins1: TMenuItem;
    pmiPluginFuncs: TMenuItem;
    N5: TMenuItem;
    aAbout: TAction;
    ToolButton7: TToolButton;
    pmAbout: TPopupMenu;
    aHomepage: TAction;
    aCheckNewVersion: TAction;
    Visithomepage1: TMenuItem;
    Checknewversion1: TMenuItem;
    JvAppInstances1: TJvAppInstances;
    NFODialog: TOpenDialog;
    Lang1: TIceLanguage;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FilterListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure FilterListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure FilterListDrawText(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
    procedure FilterListFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FilterListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure pmCategoriesPopup(Sender: TObject);
    procedure VListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VListGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure FilterListDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure VListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure VListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure VListHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure FilterListDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure VListFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure bShowNFOClick(Sender: TObject);
    procedure FilterListDblClick(Sender: TObject);
    procedure aModifyCategoryExecute(Sender: TObject);
    procedure aDeleteCategoryExecute(Sender: TObject);
    procedure aDeleteItemsExecute(Sender: TObject);
    procedure VListBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure lProductNameClick(Sender: TObject);
    procedure aOpenDirExecute(Sender: TObject);
    procedure eTagsExit(Sender: TObject);
    procedure eTagsKeyPress(Sender: TObject; var Key: Char);
    procedure mProductDescrExit(Sender: TObject);
    procedure aAddDirectoryExecute(Sender: TObject);
    procedure aAddFileExecute(Sender: TObject);
    procedure aQueueExecute(Sender: TObject);
    procedure aConsistenceCheckExecute(Sender: TObject);
    procedure aAddStuffExecute(Sender: TObject);
    procedure bChangePictureClick(Sender: TObject);
    procedure lURLClick(Sender: TObject);
    procedure bChangeURLClick(Sender: TObject);
    procedure lChangeDirectoryNameClick(Sender: TObject);
    procedure mProductDescrKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VListDblClick(Sender: TObject);
    procedure aNewCategoryExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aShowMainFormExecute(Sender: TObject);
    procedure CoolTrayIcon1DblClick(Sender: TObject);
    procedure aViewProcessLogExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lGoogleSearchClick(Sender: TObject);
    procedure aReprocessExecute(Sender: TObject);
    procedure aSettingsExecute(Sender: TObject);
    procedure FilterListCollapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FilterListExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FilterListCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      var Allowed: Boolean);
    procedure pmListPopup(Sender: TObject);
    procedure aDelSourceExecute(Sender: TObject);
    procedure eSearchKeyPress(Sender: TObject; var Key: Char);
    procedure aOpenSourceDirExecute(Sender: TObject);
    procedure aTargetToClipBoardExecute(Sender: TObject);
    procedure EditBoxLostFocus(Sender: TObject);
    procedure EditBoxKeyPress(Sender: TObject; var Key: Char);
    procedure aDBVacuumExecute(Sender: TObject);
    procedure aDBBackupExecute(Sender: TObject);
    procedure aDBRestoreExecute(Sender: TObject);
    procedure aPluginsExecute(Sender: TObject);
    procedure aAboutExecute(Sender: TObject);
    procedure aHomepageExecute(Sender: TObject);
    procedure JvAppInstances1CmdLineReceived(Sender: TObject;
      CmdLine: TStrings);
    procedure aCheckNewVersionExecute(Sender: TObject);
    procedure bAddNFOClick(Sender: TObject);
  private
    //Database methods
    procedure CreateMainDB;
    procedure CreateInfoDB;
    procedure OpenDB;
    procedure CloseDB;
    function HasInDB(Item: TPreProcessItem): boolean;
    procedure VacuumDB;

    procedure BackupDB;
    procedure BackupDBToFile(FileName: string);

    procedure RestoreDB;
    procedure RestoreDBFromFile(FileName: string);

    procedure ShowOptionsForm;

    procedure RunConsistenceCheck;
    procedure bStopClick(Sender: TObject);
    procedure StopProcess(Sender: TObject);

    procedure CategoryOrder(Root: PVirtualNode);
    function GetCategoryNodeByID(Root: PVirtualNode; ID: integer): PVirtualNode;
    function GetCategoryIDs(ParentNode: PVirtualNode): string;

    //ICS methods
    procedure GenerateTagsTableFromDirs;
    procedure GenerateTagCategoryMatrix;
    function ExecuteICS(Tags: string): integer;

    procedure RegenerateTagsFromPath;
    procedure CreateDescriptorMenus;
    procedure DescriptorPluginClick(Sender: TObject);

    function FirstLine(S: string): string;
    procedure LoadImageToProduct(FileName: string; Node: PVirtualNode);
    { Private declarations }
  protected
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
    procedure WMEndSession(var Msg: TWMEndSession); Message WM_QUERYENDSESSION;
    procedure AddItemsFromOtherProcess( var msg : TMessage ); message WM_COPYDATA;

  public
    { Public declarations }
    SelectedProductID: integer;

    DraggedCategory: PNodeCategory;

    //Application methods
    procedure LoadConfigFile;
    procedure LoadConfigState;
    procedure LoadVariablesFromConfig;
    procedure SaveConfig;

    //Queue methods
    procedure LoadUnprocessedItems;
    procedure SaveUnprocessedItems;
    procedure PreparingNewFiles(FileList: TStrings; CategoryID: integer);
    procedure RefreshQueueItemCount;

    //Category methods
    procedure LoadCategoriesFromDB(const NewID: integer = -1);
    procedure AddNewCategory(const ParentID: integer = -1);
    procedure ModifyCategory(Data: PNodeCategory);
    procedure DeleteCategory(Data: PNodeCategory);
    procedure RefreshCategoriesCount;

    //Product methods
    procedure DeleteProduct(ID: integer);
    procedure DeleteSelectedProductNodes;
    procedure LoadProductInfoToNode(Data: TNodeProduct);
    procedure SaveSelectedNodeInfo;
    procedure LoadProductsFromDB(DBRefresh: boolean);

    //Plugin callback methods
    procedure SaveNewProductInfo(ProductInfo: PPluginProductItem);
    procedure SaveNewProductImage(ProductInfo: PPluginProductItem; FileName: string);

    function UTF8Encode(Name: string): AnsiString;
  end;

var
  mutexHandle: THandle;

  MainForm: TMainForm;
  ApplicationTerminating: boolean = false;
  MainDBPath: string;
  InfoDBPath: string;
  PluginPath: string;

implementation

uses
  uPreprocessDirs, uCategories, DateUtils, uProgress, uNFOForm,
  uThreadProcessForm, uProcessThread, uOptionsForm, uPluginClasses,
  uPluginsForm, CodePages, uProcs, JclAppInst, uAboutForm;

{$R *.dfm}

{$R StuffOrganizer.rec}

 {$REGION 'Action methods'}
procedure TMainForm.aAboutExecute(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.aAddDirectoryExecute(Sender: TObject);
var
  Data: PNodeCategory;
  Files: TStrings;
begin
  if DD.Execute then
  begin
    if Assigned(FilterList.FocusedNode) then
    begin
      Data := FilterList.GetNodeData(FilterList.FocusedNode);
      Files := TStringList.Create;
      Files.Add(DD.Directory);
      PreparingNewFiles(Files, Data.ID);
      Files.Free;
    end;
  end;
end;

procedure TMainForm.aAddFileExecute(Sender: TObject);
var
  Data: PNodeCategory;
begin
  if OD.Execute then
  begin
    if Assigned(FilterList.FocusedNode) then
    begin
      Data := FilterList.GetNodeData(FilterList.FocusedNode);
      PreparingNewFiles(OD.Files, Data.ID);
    end;
  end;
end;

procedure TMainForm.aAddStuffExecute(Sender: TObject);
begin
  aAddDirectory.Execute;
end;

procedure TMainForm.aCheckNewVersionExecute(Sender: TObject);
begin
  CheckUpdate(false);
end;

procedure TMainForm.aConsistenceCheckExecute(Sender: TObject);
begin
  RunConsistenceCheck;
end;

procedure TMainForm.aDBBackupExecute(Sender: TObject);
begin
  if NowProcessing then
    MessageDlg(Lang['Pleasewaituntiltheprocessingoperationsarecompleted'], mtWarning, [mbOK], 0)
  else
    BackupDB;
end;

procedure TMainForm.aDBRestoreExecute(Sender: TObject);
begin
  if NowProcessing then
    MessageDlg(Lang['Pleasewaituntiltheprocessingoperationsarecompleted'], mtWarning, [mbOK], 0)
  else
    RestoreDB;
end;

procedure TMainForm.aDBVacuumExecute(Sender: TObject);
begin
  if NowProcessing then
    MessageDlg(Lang['Pleasewaituntiltheprocessingoperationsarecompleted'], mtWarning, [mbOK], 0)
  else
    VacuumDB;
end;

procedure TMainForm.aSettingsExecute(Sender: TObject);
begin
  ShowOptionsForm;
end;

procedure TMainForm.aDeleteCategoryExecute(Sender: TObject);
var
  Data: PNodeCategory;
begin
  if Assigned(FilterList.FocusedNode) then
  begin
    Data := FilterList.GetNodeData(FilterList.FocusedNode);
    if Data.NodeType = NODE_FILTER_CATEGORY then
      if MessageDlg(Format(Lang['Doyouwanttodeletethe'], [Data.Name]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        DeleteCategory(Data);
  end;
end;

procedure TMainForm.aDeleteItemsExecute(Sender: TObject);
begin
  if VList.SelectedCount > 0 then
  begin
    if (MessageDlg(Lang['Areyousuredeletetheselecteddirectories'], mtWarning, [mbYes, mbNo], 0) = mrYes) then
      DeleteSelectedProductNodes;
  end;
end;

procedure TMainForm.aDelSourceExecute(Sender: TObject);
var
  Data: PNodeProduct;
begin
  if (VList.SelectedCount = 1) and Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    if (MessageDlg(Format(Lang['AreyousuredeletethesourcefilesPath'], [Data.SourcePath]), mtWarning, [mbYes, mbNo], 0) = mrYes) then
    begin
      IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(Data.SourcePath), '', true, true);
    end;
  end;
end;

procedure TMainForm.aExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.aHomepageExecute(Sender: TObject);
begin
  OpenURL('http://stufforganizer.sourceforge.net/');
end;

procedure TMainForm.aModifyCategoryExecute(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PNodeCategory;
begin
  if Assigned(FilterList.FocusedNode) then
  begin
    Data := FilterList.GetNodeData(FilterList.FocusedNode);
    ModifyCategory(Data);
  end;
end;

procedure TMainForm.aNewCategoryExecute(Sender: TObject);
var
  ParentID: integer;
  Data: PNodeCategory;
begin
  ParentID := -1;
  if Assigned(FilterList.FocusedNode) then
  begin
    Data := FilterList.GetNodeData(FilterList.FocusedNode);
    ParentID := Data.ID;
  end;

  AddNewCategory(ParentID);
end;

procedure TMainForm.aOpenDirExecute(Sender: TObject);
var
  Data: PNodeProduct;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    ShellExecute(Handle, 'OPEN', PWideChar('explorer.exe'), PWideChar('/select, "' + IncludeTrailingBackslash(Data.TargetPath) + '"'), nil, SW_NORMAL) ;
  end;
end;

procedure TMainForm.aOpenSourceDirExecute(Sender: TObject);
var
  Data: PNodeProduct;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    ShellExecute(Handle, 'OPEN', PWideChar('explorer.exe'), PWideChar('/select, "' + IncludeTrailingBackslash(Data.SourcePath) + '"'), nil, SW_NORMAL) ;
  end;
end;

procedure TMainForm.aPluginsExecute(Sender: TObject);
begin
  PluginsForm.Show;
end;

procedure TMainForm.aQueueExecute(Sender: TObject);
begin
  PreProcessForm.Show;
end;

procedure TMainForm.aReprocessExecute(Sender: TObject);
var
  SelectList: TNodeArray;
  I: integer;
  DirList: TStringList;
  Node: PVirtualNode;
  Data: PNodeProduct;
  Item: TPreProcessItem;
begin
  ShowProgressDialog(Lang['Preparing'], Lang['Pleasewait'], bStopClick);
  DirList := TStringList.Create;
  SelectList := VList.GetSortedSelection(true);
  for I := Low(SelectList) to High(SelectList) do
  begin
    if ProgressStopping then
      break;

    Node := SelectList[I];
    Data := VList.GetNodeData(Node);
    ChangeProgressCaption(Format(Lang['Reprocess'], [Data.DirName]));
    if DirectoryExists(Data.TargetPath) then
    begin
      Item := TPreProcessItem.Create(Data.TargetPath);
      Item.CategoryID := Data.Category;
      Item.NewDirName := Data.DirName;
      Item.CalcDirSize;
      PreparingProducts.Add(Item);
    end;
  end;
  SetLength(SelectList, 0);

  if PreparingProducts.Count > 0 then
  begin
    if PreProcessForm.Showing then
    begin
      PreProcessForm.LoadItems;
      PreProcessForm.BringToFront
    end
    else
      PreProcessForm.Show;
  end;
  CloseProgressDialog;
  RefreshQueueItemCount;

end;

procedure TMainForm.aShowMainFormExecute(Sender: TObject);
begin
  MainForm.Show;
  SetForegroundWindow(Application.Handle)
end;


procedure TMainForm.aTargetToClipBoardExecute(Sender: TObject);
var
  Data: PNodeProduct;
  Node: PVirtualNode;
  DirList: TStrings;
begin
  if VList.SelectedCount > 0 then
  begin
    DirList := TStringList.Create;
    Node := VList.GetFirstSelected();
    while Assigned(Node) do
    begin
      Data := VList.GetNodeData(Node);
      if DirectoryExists(Data.TargetPath) then
        DirList.Add(Data.TargetPath);
      Node := VList.GetNextSelected(Node);
    end;
    if DirList.Count > 0 then
      CopyFilesToClipboard(DirList);

    DirList.Free;
  end;
end;

procedure TMainForm.aViewProcessLogExecute(Sender: TObject);
begin
  if ThreadProcessForm.Showing then
    ThreadProcessForm.BringToFront
  else
    ThreadProcessForm.Show;
end;

 {$ENDREGION}

procedure TMainForm.AcceptFiles(var msg: TMessage);
const
  cnMaxFileNameLen = 1000;
var
  i,
  nCount     : integer;
  acFileName : array [0..cnMaxFileNameLen] of char;
  Files: TStrings;
  ctrl: TWinControl;
  Node: PVirtualNode;
  Data: PNodeCategory;
  CategoryID: integer;
  FS: TFileStream;
begin
  CategoryID := -1;
  ctrl := FindVCLWindow(Mouse.CursorPos);
  if Assigned(ctrl) then
  begin

    if (ctrl = FilterList) and Assigned(DraggedCategory) then
      CategoryID := DraggedCategory.ID
    else if (ctrl = VList) and Assigned(FilterList.FocusedNode) then
    begin
      Data := FilterList.GetNodeData(FilterList.FocusedNode);
      CategoryID := Data.ID;
    end;
  end;


  Files := TStringList.Create;
  nCount := DragQueryFile( msg.WParam, $FFFFFFFF, acFileName, cnMaxFileNameLen );

  if (ctrl = DescrImagePanel) and (nCount = 1) and Assigned(FilterList.FocusedNode) then
  begin
    DragQueryFile( msg.WParam, 0, acFileName, cnMaxFileNameLen );
    if Pos(ExtractFileExt(acFileName), GraphicFileMask(TGraphic)) > 0 then
    begin
      //Add image to selected node
      LoadImageToProduct(acFileName, FilterList.FocusedNode);
    end;
  end
  else
  begin
    for i := 0 to nCount-1 do
    begin
      DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );
      Files.Add(acFileName);
    end;
  end;
  DragFinish( msg.WParam );

  Application.BringToFront;
  MainForm.PreparingNewFiles(Files, CategoryID);
  Files.Free;
end;

procedure TMainForm.LoadImageToProduct(FileName: string; Node: PVirtualNode);
var
  Data: PNodeProduct;
  FS: TFileStream;
  count: integer;
begin
  Data := VList.GetNodeData(VList.FocusedNode);
  FS := TFileStream.Create(FileName, fmOpenRead);
  LockDB;
  try
    InfoDB.AddParamInt(':id', Data.ID);
    count := InfoDB.GetTableValue('select count(*) from ProductImage where product_id = :id');

    InfoDB.AddParamInt(':id', Data.ID);
    InfoDB.AddParamText(':filename', UTF8Encode(ExtractFileName(FileName)));
    InfoDB.AddParamBlob(':data', FS);
    if count > 0 then
      InfoDB.ExecSQL('update ProductImage set filename = :filename, data = :data where product_id = :id')
    else
      InfoDB.ExecSQL('insert into ProductImage (product_id, filename, data) values (:id, :filename, :data);');
  finally
    FS.Free;
    UnlockDB;
  end;
  LoadProductInfoToNode(Data^);

end;

procedure TMainForm.AddItemsFromOtherProcess(var msg: TMessage);
var
  ItemList: TStringList;
  cd: TCopyDataStruct;
  s: string;
begin
  cd := PCopyDataStruct(msg.LParam)^;

  if cd.dwData = 1200 then
  begin
    s := string(PWideChar(cd.lpData));
    SetLength(s, cd.cbData div sizeOf(s[1]));
    ShowMessage(s);

    ItemList := TStringList.Create;
    ItemList.Text := S;

    ItemList.Free;
  end;
end;


procedure TMainForm.AddNewCategory(const ParentID: integer = -1);
var
  NewID: integer;
  I: Integer;
begin
  NewID := -1;
  CategoriesForm.Caption := Lang['Addnewcategory'];
  CategoriesForm.eName.Text := '';
  CategoriesForm.ePath.Text := '';
  CategoriesForm.ePath.Enabled := true;
  CategoriesForm.cbColor.Checked := false;
  CategoriesForm.shColor.Brush.Color := clWhite;

  if ParentID <> -1 then
  begin
    for I := Low(Categories) to High(Categories) do
      if Categories[I].ID = ParentID then
      begin
        CategoriesForm.ePath.Text := Categories[I].Path;
        if Categories[I].Color <> clNone then
        begin
          CategoriesForm.shColor.Brush.Color := Categories[I].Color;
          CategoriesForm.cbColor.Checked := true;
        end
        else
          CategoriesForm.shColor.Brush.Color := clWhite;
        CategoriesForm.cbIcons.ItemIndex := Categories[I].IconIndex;
        break;
      end;
  end;

  if CategoriesForm.ShowModal = mrOk then
  begin
    LockDB;
    try
      DB.AddParamText(':name', UTF8Encode(CategoriesForm.eName.Text));
      DB.AddParamText(':path', UTF8Encode(CategoriesForm.ePath.Text));
      DB.AddParamInt(':icon', CategoriesForm.cbIcons.ItemIndex);
      DB.AddParamInt(':parent', ParentID);
      if CategoriesForm.cbColor.Checked then
        DB.AddParamText(':color', ColorToHtml(CategoriesForm.shColor.Brush.Color))
      else
        DB.AddParamNull(':color');
      DB.ExecSQL('insert into Categories (name, path, parent, color, icon) values (:name, :path, :parent, :color, :icon);');
      NewID := DB.LastInsertRowID;
    finally
      UnLockDB;
    end;
    LoadCategoriesFromDB(NewID);
  end;
end;



procedure TMainForm.bAddNFOClick(Sender: TObject);
var
  Data: PNodeProduct;
  FS: TFileStream;
  count: integer;
begin
  NFODialog.FilterIndex := 0;
  if NFODialog.Execute(Application.Handle) then
  begin
    if Assigned(VList.FocusedNode) then
    begin
      Data := VList.GetNodeData(VList.FocusedNode);
      FS := TFileStream.Create(NFODialog.FileName, fmOpenRead);
      LockDB;
      try
        InfoDB.AddParamInt(':id', Data.ID);
        count := InfoDB.GetTableValue('select count(*) from ProductInfo where product_id = :id');

        InfoDB.AddParamInt(':id', Data.ID);
        InfoDB.AddParamBlob(':data', FS);
        if count > 0 then
          InfoDB.ExecSQL('update ProductInfo set nfo = :data where product_id = :id')
        else
          InfoDB.ExecSQL('insert into ProductInfo (product_id, nfo) values (:id, :data);');
      finally
        FS.Free;
        UnlockDB;
      end;
      LoadProductInfoToNode(Data^);
    end;
  end;
end;

procedure TMainForm.bChangePictureClick(Sender: TObject);
var
  Data: PNodeProduct;
  FS: TFileStream;
begin
  PictureDialog.Filter := GraphicFilter(TGraphic);
  if PictureDialog.Execute(Application.Handle) then
  begin
    if Assigned(VList.FocusedNode) then
      LoadImageToProduct(PictureDialog.FileName, VList.FocusedNode);
  end;
end;

procedure TMainForm.bChangeURLClick(Sender: TObject);
var
  Data: PNodeProduct;
  url: string;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    url := Data.URL;
    if InputQuery(Lang['ChangeURL'], Lang['EnterURL'], url) then
    begin
      Data.URL := url;
      SaveSelectedNodeInfo;
      lURL.Caption := url;
    end;
  end;
end;

procedure TMainForm.bShowNFOClick(Sender: TObject);
var
  NFOContent: string;
begin
  if SelectedProductID <> -1 then
  begin
    LockDB;
    try
      NFOContent := InfoDB.GetTableString('select nfo from ProductInfo where product_id = ' + IntToStr(SelectedProductID));
      ShowNFOContent(NFOContent);
    finally
      UnLockDB;
    end;
  end;
end;

 {$REGION 'Form events'}
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Action:=caNone;
  //Hide;
  NeedPasswordEvent.ResetEvent; //Ha esetleg be ragadt volna, le tudjon állni a szál

  if PreparingProducts.Count > 0 then
  begin
    SaveUnprocessedItems;
  end;

  PreparingProducts.Free;
  SetLength(Categories, 0);

  PluginManager.Free;

  SaveConfig;
  ConfigXML.Free;

  CloseDB;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if NowProcessing  then
  begin
    if ProcThread.Terminated then //Ha már másodszor nyomja, akkor kilépünk ha tényleg akarja
    begin
      HideProgressDialog;
      if (MessageDlg(Lang['DoyouwanttocontinuewithclosingmightcauseDATALOSS'], mtWarning, [mbYes, mbNo], 0) = mrNo) then
      begin
        UnHideProgressDialog;
        CanClose := false;
        Exit;
      end;
      UnHideProgressDialog;
    end
    else
    begin
      if (MessageDlg(Lang['SomefoldersarestillbeingprocessedDoyoureallywanttoexit'], mtWarning, [mbYes, mbNo], 0) = mrYes) then
      begin
        CanClose := false;
        ApplicationTerminating := true;
        ThreadProcessForm.ProcessStopping;
        ProcThread.Terminate;
        Exit;
        //WaitForSingleObject(ProcThread.Handle, {5 * 60 * 1000} 10 * 1000);
      end
      else
      begin
        CanClose := false;
        Exit;
      end;
    end;
  end;
  CanClose := true;
  ApplicationTerminating := true;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := APP_TITLE + ' v' + GetFileVersion(Application.ExeName, '%d.%d.%d');
  Application.Title := APP_TITLE;
  CoolTrayIcon1.Hint := Caption;

  Lang.LanguageCode := 'hu-HU';
  Lang.Execute('', Self);

  MainDBPath := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA) + DBPATH + MAINDBFILENAME;
  InfoDBPath := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA) + DBPATH + INFODBFILENAME;
  PluginPath := ExecPath + PLUGIN_DIR;
  ForceDirectories(ExtractFilePath(MainDBPath));
  ForceDirectories(PluginPath);

  PluginManager := TPluginManager.Create;

  ConfigXML := TIceXML.Create(nil);
  ConfigXML.EncodeType := 'UTF-8';
  ConfigXML.UseEncode := True;
  ConfigXML.Filename := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA) + CONFIGPATH + CONFIG_FILENAME;
  ConfigXML.NameParamName := 'id';

  PreparingProducts := TObjectList<TPreProcessItem>.Create(TComparer<TPreProcessItem>.Default);
  SetLength(Categories, 0);

  DraggedCategory := nil;
  DragAcceptFiles( Handle, True );

  OpenDB;

  LoadConfigFile;

  LoadCategoriesFromDB;

  LoadUnprocessedItems;

  //CheckOpenWithKeys; //Installer does it
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  icon: TIcon;
begin
  LoadConfigState;

{  LockDB;
  try
    if DB.GetTableValue('select count(id) from Tags') = 0 then
      GenerateTagsTableFromDirs;
  finally
    UnLockDB;
  end;}

  //For ICS
  if ICS_ENABLED then
    GenerateTagCategoryMatrix;

  //Load plugins
  PluginManager.LoadPlugins;
  CreateDescriptorMenus;

  //Process application parameters
  ProcessParameters;
  CoolTrayIcon1.IconVisible := true;


  if ConfigXML.Root.GetItemParamValue('Main.Update', 'checkAtStart', 'True') = 'True' then
    CheckUpdate;
end;

 {$ENDREGION}

procedure TMainForm.CreateDescriptorMenus;
var
  ItemMenu: TMenuItem;
  descrItem: TDescriptorCallBackItem;
  I: Integer;
begin
  for I := 0 to DescriptorCallBackList.Count - 1 do
  begin
    descrItem := TDescriptorCallBackItem(DescriptorCallBackList[I]);
    ItemMenu := TMenuItem.Create(pmiPluginFuncs);
    ItemMenu.Caption := descrItem.Name;
    ItemMenu.Tag := I;
    ItemMenu.OnClick := DescriptorPluginClick;
    pmiPluginFuncs.Add(ItemMenu);
  end;
end;

procedure TMainForm.DescriptorPluginClick(Sender: TObject);
var
  Index: integer;
  descrItem: TDescriptorCallBackItem;
  Data: PNodeProduct;
  Node: PVirtualNode;
  productInfo: PPluginProductItem;
begin
  if VList.SelectedCount > 0 then
  begin
    Index := TMenuItem(Sender).Tag;
    descrItem := TDescriptorCallBackItem(DescriptorCallBackList[Index]);

    Node := VList.GetFirstSelected;
    while Assigned(Node) do
    begin
      try
        Data := VList.GetNodeData(Node);
        New(productInfo);
        ZeroMemory(productInfo, sizeOf(TPluginProductItem));
        productInfo.ID := Data.ID;
        productInfo.Name := PWideChar(Data.Name);
        productInfo.TargetPath := PWideChar(Data.TargetPath);
        productInfo.CategoryID := Data.Category;
        productInfo.CategoryName := PWideChar(Data.CategoryName);
        productInfo.Description := PWideChar(Data.Description);
        productInfo.Tags := PWideChar(Data.Tags);
        productInfo.URL := PWideChar(Data.URL);
        productInfo.Modified := false;

        descrItem.CallBack(productInfo);
{        if productInfo.Modified then
        begin
          ShowMessage(productInfo.Description);
        end;}
        FreeMem(productInfo);
      except
        on E: Exception do
        begin
          MessageDlg(Format(Lang['Errorduringspluginprocesss'], [ExtractFileName(descrItem.Plugin.FileName), E.Message]), mtWarning, [mbOK], 0);
        end;
      end;
      Node := VList.GetNextSelected(Node);
    end;
    LoadProductsFromDB(true);
  end;
end;


 {$REGION 'ICS methods'}
procedure TMainForm.RegenerateTagsFromPath;
var
  Table: TSQLiteTable;
  Item: TPreProcessItem;
begin
  LockDB;
  try
    Table := DB.GetTable('select id, sourcepath from Products where status = 1');
    while not Table.EOF do
    begin
      Item := TPreProcessItem.Create(UTF8ToString(Table.FieldAsString(1)));

      DB.ExecSQL('update Products set tags = ''' + Item.Tags + ''' where id = ' + Table.FieldAsString(0));
      Table.Next;
    end;
    Table.Free;
  finally
    UnLockDB;
  end;
end;

procedure TMainForm.GenerateTagsTableFromDirs;
//Már nincs használva
var
  Table: TSQLiteTable;
  Tags, tag: string;
  ProductID: integer;
  TagList: TStringList;
  I: Integer;
begin
  ShowProgressDialog(Lang['Regeneratetags'], Lang['Pleasewait']);
  LockDB;
  try
    Table := DB.GetTable('select id, tags from Products where status = 1');
    while not Table.EOF do
    begin
      TagList := TStringList.Create;
      ProductID := Table.FieldAsInteger(0);
      Tags := Trim(UTF8ToString(Table.FieldAsString(1)));
      while Length(Tags) > 0 do
      begin
        tag := Trim(CutAt(Tags, ','));
        if TagList.IndexOf(tag) = -1 then
          TagList.Add(tag);
      end;

      DB.AddParamInt(':id', ProductID);
      DB.ExecSQL('delete from Tags where product_id = :id');
      for I := 0 to TagList.Count - 1 do
      begin
        DB.AddParamInt(':product_id', ProductID);
        DB.AddParamText(':tag', UTF8Encode(LowerCase(TagList[I])));
        DB.ExecSQL('insert into Tags (tag, product_id) values (:tag, :product_id)');
      end;
      TagList.Free;
      Table.Next;
    end;
    Table.Free;
  finally
    UnLockDB;
    CloseProgressDialog;
  end;

end;


procedure TMainForm.GenerateTagCategoryMatrix;
var
  Table: TSQLiteTable;
  CategoryID: integer;
  TagIndex, CatIndex: integer;
  I, J, Sum: integer;
  Tag: string;
begin
  ShowProgressDialog(Lang['Generatematrixtointelligentsorter'], Lang['Pleasewait']);

  TagMatrix := nil;
  if not Assigned(TagList) then
    TagList := TStringList.Create;

  LockDB;
  try
    DB.GetTableStrings('select distinct tag from Tags', TagList);

    SetLength(TagMatrix, TagList.Count, Length(Categories));

    SetLength(CatIDArray, Length(Categories));
    for I := Low(Categories) to High(Categories) do
      CatIDArray[I] := Categories[I].ID;

    //Kinullázni
    for I := Low(TagMatrix) to High(TagMatrix) do
      for J := Low(TagMatrix[I]) to High(TagMatrix[I]) do
        TagMatrix[I][J] := 0;

    ChangeProgressCaption(Lang['Calculatingtagsusage']);

    //Elõször feltölteni a mátrixba, hogy melyik tag melyik kategóriába hányszor lett belerakva
    Table := DB.GetTable('select tag, category from Tags inner join Products on product_id = Products.id');
    while not Table.EOF do
    begin
      Tag := UTF8ToString(Table.FieldAsString(0));
      CategoryID := Table.FieldAsInteger(1);

      TagIndex := TagList.IndexOf(Tag);
      CatIndex := -1;
      for I := Low(Categories) to High(Categories) do
        if Categories[I].ID = CategoryID then
        begin
          CatIndex := I;
          break;
        end;

      if (TagIndex <> -1) and (CatIndex <> -1) then
        TagMatrix[TagIndex][CatIndex] := TagMatrix[TagIndex][CatIndex] + 1;

      Table.Next;
    end;
    Table.Free;
  finally
    UnLockDB;
  end;

  //Végimenni a mátrixon és kiszámolni a százalékokat
  for I := Low(TagMatrix) to High(TagMatrix) do
  begin
    Sum := 0;
    for J := Low(TagMatrix[I]) to High(TagMatrix[I]) do
      if TagMatrix[I][J] <> 0 then
        Inc(Sum, Round(TagMatrix[I][J]));

      for J := Low(TagMatrix[I]) to High(TagMatrix[I]) do
        if Sum = 0 then
          TagMatrix[I][J] := 0
        else
          TagMatrix[I][J] := TagMatrix[I][J] / Sum * 100;
  end;

  CloseProgressDialog;
end;

function TMainForm.ExecuteICS(Tags: string): integer;
var
  tag: string;
  aCatPercent: array of Extended;
  FoundCatIndex, TagIndex, I: Integer;
  MaxValue: Extended;
begin
  result := -1;
  if (Trim(Tags) = '') or (Length(CatIDArray) = 0) then Exit;

  SetLength(aCatPercent, Length(CatIDArray));
  for I := Low(aCatPercent) to High(aCatPercent) do
    aCatPercent[I] := 0;

  while Length(Tags) > 0 do
  begin
    tag := LowerCase(Trim(CutAt(Tags, ',')));

    TagIndex := TagList.IndexOf(tag);
    if TagIndex <> -1 then
    begin
      for I := Low(CatIDArray) to High(CatIDArray) do
        aCatPercent[I] := aCatPercent[I] + TagMatrix[TagIndex][I];
    end;
  end;

  //Megkeresem a legnagyobb százalékot
  MaxValue := 0; FoundCatIndex := -1;
  for I := Low(aCatPercent) to High(aCatPercent) do
    if aCatPercent[I] > MaxValue then
    begin
      MaxValue := aCatPercent[I];
      FoundCatIndex := I;
    end;

  //Kikeresni melyik CategoryID az
  if FoundCatIndex <> -1 then
    result := CatIDArray[FoundCatIndex];
end;
 {$ENDREGION}

 {$REGION 'Database methods'}
procedure TMainForm.OpenDB;
begin
  if not FileExists(MAINDBPATH) then
    CreateMainDB;
  if not FileExists(INFODBPATH) then
    CreateInfoDB;

  DB := TSqliteDatabase.Create(MAINDBPATH);
  InfoDB := TSqliteDatabase.Create(INFODBPATH);
end;

procedure TMainForm.CloseDB;
begin
  if Assigned(DB) then
    DB.Free;
  if Assigned(InfoDB) then
    InfoDB.Free;
end;

procedure TMainForm.CreateMainDB;
var
  ScriptFile, Statement: string;
begin
  LockDB;
  try
    ScriptFile := ExtractResource('DB_MAIN');
    if Assigned(DB) then
      FreeAndNil(DB);

    DB := TSqliteDatabase.Create(MAINDBPATH);
    while(Length(ScriptFile) > 0) do
    begin
      Statement := Trim(CutAt(ScriptFile, ';'));
      if Statement <> '' then
        DB.ExecSQL(Statement);
    end;
    FreeAndNil(DB);
  finally
    UnLockDB;
  end;
end;

procedure TMainForm.CreateInfoDB;
var
  ScriptFile, Statement: string;
begin
  LockDB;
  try
    ScriptFile := ExtractResource('DB_INFO');
    if Assigned(InfoDB) then
      FreeAndNil(InfoDB);

    InfoDB := TSqliteDatabase.Create(INFODBPATH);
    while(Length(ScriptFile) > 0) do
    begin
      Statement := Trim(CutAt(ScriptFile, ';'));
      if Statement <> '' then
        InfoDB.ExecSQL(Statement);
    end;
    FreeAndNil(InfoDB);
  finally
    UnLockDB;
  end;
end;

 {$ENDREGION}


procedure TMainForm.pmCategoriesPopup(Sender: TObject);
var
  Data: PNodeCategory;
begin
  Deletecategory1.Enabled := Assigned(FilterList.FocusedNode) and (PNodeCategory(FilterList.GetNodeData(FilterList.FocusedNode)).NodeType = NODE_FILTER_CATEGORY);
end;

procedure TMainForm.pmListPopup(Sender: TObject);
var
  Data: PNodeProduct;
begin
  aOpenSourceDir.Enabled := false;
  aDelSource.Enabled := false;
  pmiPluginFuncs.Enabled := VList.SelectedCount > 0;
  if (VList.SelectedCount = 1) and Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    if FileExists(Data.SourcePath) or DirectoryExists(Data.SourcePath) and (Data.SourcePath <> Data.TargetPath) then
    begin
      aDelSource.Enabled := true;
      aOpenSourceDir.Enabled := true;
    end;
  end;
end;

procedure TMainForm.CategoryOrder(Root: PVirtualNode);
var
  TempNode, Node, ParentNode: PVirtualNode;
  Data: PNodeCategory;
  ParentID: integer;
begin
  Node := FilterList.GetFirstChild(Root);
  while Assigned(Node) do
  begin
    Data := FilterList.GetNodeData(Node);
    ParentID := Data.ParentID;
    if ParentID <> -1 then
    begin
      TempNode := Node;
      Node := FilterList.GetNext(Node);
      ParentNode := GetCategoryNodeByID(Root, ParentID);
      if Assigned(ParentNode) then
      begin
        FilterList.NodeParent[TempNode] := ParentNode;

        if ConfigXML.Root.GetItemValue(Format('Main.FilterList.State.Category[%d]', [Data.ParentID]), 1) = 1 then
          FilterList.Expanded[ParentNode] := true
        else
          FilterList.Expanded[ParentNode] := false
      end;
    end
    else
      Node := FilterList.GetNextSibling(Node);
  end;
end;

procedure TMainForm.CoolTrayIcon1DblClick(Sender: TObject);
begin
  aShowMainForm.Execute;
end;

function TMainForm.GetCategoryNodeByID(Root: PVirtualNode; ID: integer): PVirtualNode;
var
  Node, ParentNode: PVirtualNode;
  Data: PNodeCategory;
  ParentID: integer;
begin
  result := nil;
  Node := FilterList.GetFirstChild(Root);
  while Assigned(Node) do
  begin
    Data := FilterList.GetNodeData(Node);
    if Data.ID = ID then
      Exit(Node);

    Node := FilterList.GetNext(Node);
  end;
end;

procedure TMainForm.LoadCategoriesFromDB(const NewID: integer = -1);
var
  AllNode, Node: PVirtualNode;
  Data: PNodeCategory;
  Table: TSQLiteTable;
  Count: integer;
  FocusedNode: PVirtualNode;
begin
  SetLength(Categories, 0);
  FocusedNode := nil;

  FilterList.BeginUpdate;
  FilterList.Clear;
  FilterList.NodeDataSize := sizeOf(TNodeCategory);

  AllNode := FilterList.AddChild(nil);
  Data := FilterList.GetNodeData(AllNode);
  Data.NodeType := NODE_FILTER_ALL;
  Data.ID := -1;
  Data.Name := Lang['Allproducts'];
  Data.Color := clNone;
  Data.Count := 0;

  LockDB;
  try
    Table := DB.GetTable('select id, name, path, parent, color, icon from Categories order by name');
    while not Table.EOF do
    begin
      Node := FilterList.AddChild(AllNode);
      Data := FilterList.GetNodeData(Node);
      Data.NodeType := NODE_FILTER_CATEGORY;
      Data.ID := Table.FieldAsInteger(0);
      Data.Name := UTF8ToString(Table.FieldAsString(1));
      Data.Path := UTF8ToString(Table.FieldAsString(2));

      if not Table.FieldIsNull(3) then
        Data.ParentID := Table.FieldAsInteger(3)
      else
        Data.ParentID := -1;
      if Table.FieldIsNull(4) then
        Data.Color := clNone
      else
        Data.Color := HtmlToColor(Table.FieldAsString(4), clWhite);
      Data.Count := 0;
      Data.IconIndex := StrToIntDef(Table.FieldAsString(5), 0);


      if Data.ID = NewID then
        FocusedNode := Node;

      SetLength(Categories, Length(Categories) + 1);
      Categories[Length(Categories) - 1] := Data^;
      Table.Next;
    end;
    Table.Free;
  finally
    UnLockDB;
  end;
  FilterList.Expanded[AllNode] := true;

  CategoryOrder(AllNode);

  Node := FilterList.AddChild(AllNode);
  Data := FilterList.GetNodeData(Node);
  Data.NodeType := NODE_FILTER_NEW_CATEGORY;
  Data.ID := -2;
  Data.Name := Lang['Addcategory'];
  Data.Count := 0;

  FilterList.EndUpdate;
  if Assigned(FocusedNode) then
    FilterList.FocusedNode := FocusedNode
  else
    FilterList.FocusedNode := FilterList.GetFirst();
end;

 {$REGION 'Configuration methods'}
procedure TMainForm.LoadConfigFile;
begin
  if FileExists(ConfigXML.Filename) then
    ConfigXML.LoadFromFile
  else
    ConfigXML.Root.Name := 'StuffOrganizerConfig';
end;

procedure TMainForm.LoadConfigState;
var
  Columns, Col: TXMLItem;
  I: integer;
begin
  //Restore column states
  Columns := ConfigXML.Root.GetItemEx('Main.VList.Columns', true);
  for I := 0 to VList.Header.Columns.Count -1 do
  begin
    Col := Columns.GetItemEx(Format('Column[%d]', [VList.Header.Columns[I].ID]));
    if Assigned(Col) then
    begin
      VList.Header.Columns[I].Position := Col.GetParamAsInt('position', VList.Header.Columns[I].Position);
      VList.Header.Columns[I].Width := Col.GetParamAsInt('width', VList.Header.Columns[I].Width);
    end;
    VList.Header.SortColumn := Columns.GetParamAsInt('sortcolumn', VList.Header.SortColumn);
    VList.Header.SortDirection := TSortDirection(Columns.GetParamAsInt('sortdir', integer(VList.Header.SortDirection)));
  end;

  MainForm.Left := ConfigXML.Root.GetItemValue('Main.LastState.Left', MainForm.Left);
  MainForm.Top := ConfigXML.Root.GetItemValue('Main.LastState.Top', MainForm.Top);
  MainForm.Width := ConfigXML.Root.GetItemValue('Main.LastState.Width', MainForm.Width);
  MainForm.Height := ConfigXML.Root.GetItemValue('Main.LastState.Height', MainForm.Height);

  MainForm.CategoryPanel.Width := ConfigXML.Root.GetItemValue('Main.LastState.CategoryPanel', MainForm.CategoryPanel.Width);
  MainForm.DescrPanel.Height := ConfigXML.Root.GetItemValue('Main.LastState.DescrPanel', MainForm.DescrPanel.Height);

  MainForm.DescrImagePanel.Width := ConfigXML.Root.GetItemValue('Main.LastState.DescrImagePanel', MainForm.DescrImagePanel.Width);
  MainForm.DescrFuncPanel.Width := ConfigXML.Root.GetItemValue('Main.LastState.DescrFuncPanel', MainForm.DescrFuncPanel.Width);

  if ConfigXML.Root.GetItemValue('Main.LastState.WindowState', 'normal') = 'maximized' then
    WindowState := wsMaximized
  else
    WindowState := wsNormal;

  LoadVariablesFromConfig;
end;

procedure TMainForm.LoadVariablesFromConfig;
begin
  DELETE_TO_RECBIN := ConfigXML.Root.GetItemParamValue('Main.Settings', 'deleteToRecycleBin', 'True') = 'True';
  HIDE_FILE_DIALOGS := ConfigXML.Root.GetItemParamValue('Main.Settings', 'hideFileDialogs', 'True') = 'True';
  ICS_ENABLED := ConfigXML.Root.GetItemParamValue('Main.Settings', 'ICS', 'True') = 'True';

end;

procedure TMainForm.SaveConfig;
var
  Columns, Col: TXMLItem;
  I: integer;
begin
  ConfigXML.Root.Attr['version'] := GetFileVersion;

  Columns := ConfigXML.Root.GetItemEx('Main.VList.Columns', true);
  Columns.ClearChildrens;
  for I := 0 to VList.Header.Columns.Count -1 do
  begin
    Col := Columns.New('Column');
    Col.Attr['id'] := VList.Header.Columns[I].ID;
    Col.Attr['position'] := VList.Header.Columns[I].Position;
    Col.Attr['width'] := VList.Header.Columns[I].Width;
  end;
  Columns.SetParamValue('sortcolumn', VList.Header.SortColumn);
  Columns.SetParamValue('sortdir', integer(VList.Header.SortDirection));

  if WindowState = wsMaximized then
    ConfigXML.Root.SetItemValue('Main.LastState.WindowState', 'maximized')
  else
  begin
    ConfigXML.Root.SetItemValue('Main.LastState.Left', MainForm.Left);
    ConfigXML.Root.SetItemValue('Main.LastState.Top', MainForm.Top);
    ConfigXML.Root.SetItemValue('Main.LastState.Width', MainForm.Width);
    ConfigXML.Root.SetItemValue('Main.LastState.Height', MainForm.Height);
    ConfigXML.Root.SetItemValue('Main.LastState.WindowState', 'normal');
  end;

  ConfigXML.Root.SetItemValue('Main.LastState.CategoryPanel', MainForm.CategoryPanel.Width);
  ConfigXML.Root.SetItemValue('Main.LastState.DescrPanel', MainForm.DescrPanel.Height);
  ConfigXML.Root.SetItemValue('Main.LastState.DescrImagePanel', MainForm.DescrImagePanel.Width);
  ConfigXML.Root.SetItemValue('Main.LastState.DescrFuncPanel', MainForm.DescrFuncPanel.Width);


  ConfigXML.SaveToFile;
end;

{$ENDREGION}

procedure TMainForm.RefreshCategoriesCount;
var
  AllNode, Node: PVirtualNode;
  DAta: PNodeCategory;
  CategoryFilter: string;
begin
  LockDB;
  try
    AllNode := FilterList.GetFirst();
    Data := FilterList.GetNodeData(AllNode);
    Data.Count := DB.GetTableValue('select count(*) from Products where status = 1');

    Node := FilterList.GetFirstChild(AllNode);
    while Assigned(Node) do
    begin
      Data := FilterList.GetNodeData(Node);

      CategoryFilter := '';
      if Data.ID <> -1 then
        CategoryFilter := Format('(category in (%s)) and', [GetCategoryIDs(Node)]);

      Data.Count := DB.GetTableValue(Format('select count(*) from Products where %s (status = 1)', [CategoryFilter]));

      Node := FilterList.GetNext(Node);
    end;
  finally
    UnLockDB;
  end;

  FilterList.Invalidate;
end;


procedure TMainForm.RefreshQueueItemCount;
begin
  if PreparingProducts.Count > 0 then
    aQueue.Caption := Format(Lang['Queued'], [PreparingProducts.Count])
  else
    aQueue.Caption := Lang['Queue'];
end;

function TMainForm.HasInDB(Item: TPreProcessItem): boolean;
var
  Table: TSQLiteTable;
begin
  result := false;
  LockDB;
  try
    DB.AddParamText(':path', UTF8Encode(Item.SourcePath));
    result := DB.GetTableValue('select count(id) from Products where sourcepath = :path') <> 0;
  finally
    UnLockDB;
  end;
end;

procedure TMainForm.JvAppInstances1CmdLineReceived(Sender: TObject;
  CmdLine: TStrings);
var
  I: Integer;
  S: string;
  ParamList: TStrings;
begin
  if JvAppInstances1.AppInstances.InstanceIndex[GetCurrentProcessId] <> 0 then Exit;

  ParamList := TStringList.Create;
  for I := 0 to CmdLine.Count - 1 do
  begin
    S := CmdLine[I];
    if FileExists(S) or DirectoryExists(S) then
    begin
      ParamList.Add(ExcludeTrailingBackslash(S));
    end;
  end;
  if ParamList.Count > 0 then
    MainForm.PreparingNewFiles(ParamList, -1);

  ParamList.Free;
end;

procedure TMainForm.lChangeDirectoryNameClick(Sender: TObject);
var
  Data: PNodeProduct;
  path, dir: string;

begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    dir := Data.DirName;
    if InputQuery(Lang['Changedirectoryname'], Lang['Enternewdirectoryname'], dir) then
    begin
      path := ExtractFilePath(Data.TargetPath);
      if RenameFile(PWideChar(Data.TargetPath), PWideChar(path + dir)) then
      begin
        Data.DirName := dir;
        Data.TargetPath := path + dir;

        LockDB;
        try
          DB.AddParamText(':dirname', UTF8Encode(Data.DirName));
          DB.AddParamText(':path', UTF8Encode(Data.TargetPath));
          DB.AddParamInt(':id', Data.ID);

          if MessageDlg(Lang['Wouldyouliketosetdirectorynametoproductname'], mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            DB.AddParamText(':name', UTF8Encode(Data.DirName));
            Data.Name := Data.DirName;
          end
          else
            DB.AddParamText(':name', UTF8Encode(Data.Name));

          DB.ExecSQL('update Products set targetdirname = :dirname, name = :name, targetpath = :path where id = :id');
        finally
          UnLockDB;
        end;

        LoadProductInfoToNode(Data^);
        //SaveSelectedNodeInfo;
      end;
    end;
  end;
end;


procedure TMainForm.lGoogleSearchClick(Sender: TObject);
var
  q: string;
begin
  q := StringReplace(eTags.Text, ',', ' ', [rfReplaceAll]);
  if q <> '' then
    OpenURL('http://google.com/search?q=' + URLEncode(q, true))
  else
    MessageDlg(Lang['Pleaseaddsometagstoproduct'], mtInformation, [mbOK], 0);
end;

procedure TMainForm.RunConsistenceCheck;
var
  Table: TSqliteTable;
  Dir: string;
  Node: PVirtualNode;
  Data: PNodeProduct;
  Item: TPreProcessItem;
  S: WideString;
  SS: AnsiString;
begin
  ProgressStopping := false;
  ShowProgressDialog(Lang['Consistencechecking'], Lang['Pleasewait'], StopProcess);

  LockDB;
  try
{    Table := DB.GetTable('select id, name, sourcepath, targetdirname, targetpath, url, tags, description from Products');
    while not Table.EOF do
    begin
      DB.AddParamInt(':id', Table.FieldAsInteger(0));
      DB.AddParamText(':name', UTF8Encode(Table.FieldAsString(1)));
      DB.AddParamText(':sourcepath', UTF8Encode(Table.FieldAsString(2)));
      DB.AddParamText(':targetdirname', UTF8Encode(Table.FieldAsString(3)));
      DB.AddParamText(':targetpath', UTF8Encode(Table.FieldAsString(4)));
      DB.AddParamText(':url', UTF8Encode(Table.FieldAsString(5)));
      DB.AddParamText(':tags', UTF8Encode(Table.FieldAsString(6)));
      DB.AddParamText(':description', UTF8Encode(Table.FieldAsString(7)));
      DB.ExecSQL('update Products set name = :name, sourcepath = :sourcepath, targetdirname = :targetdirname, targetpath = :targetpath, url = :url, tags = :tags, description = :description where id = :id');

      Table.Next;
    end;
    Table.Free;

    Table := InfoDB.GetTable('select id, nfo from ProductInfo');
    while not Table.EOF do
    begin
      InfoDB.AddParamInt(':id', Table.FieldAsInteger(0));
      InfoDB.AddParamText(':nfo', UTF8Encode(Table.FieldAsString(1)));
      InfoDB.ExecSQL('update ProductInfo set nfo = :nfo where id = :id');

      Table.Next;
    end;
    Table.Free;      }


  {  Table := DB.GetTable('select id, category, targetdirname, targetpath, tags, description, timestamp from Products where status = 1;');
    while not Table.EOF do
    begin
      Dir := UTF8ToString(Table.FieldAsString(3));
      if not DirectoryExists(Dir) then
      begin
        HideProgressDialog;
        case MessageDlg(Format(Lang['Thesdirectorydoesn']t exists. Do you want to delete from library?', [Dir]), mtWarning, [mbYes, mbNo, mbAbort], 0) of
          mrYes:
          begin
            DB.ExecSQL('delete from Products where id = ' + Table.FieldAsString(0));
          end;
          mrAbort: begin ProgressStopping := true; break; end;
        end;
        UnHideProgressDialog;
      end;
      if ProgressStopping then
        break;
      Table.Next;
    end;
    Table.Free;
       }
   { InfoDB.ExecSQL('delete from ProductInfo where product_id = 0');
    InfoDB.ExecSQL('delete from ProductImage where product_id = 0');

    Node := VList.GetFirst;
    while Assigned(Node) do
    begin
      Data := VList.GetNodeData(Node);

      Item := TPreProcessItem.Create(Data.TargetPath);
      Item.ID := Data.ID;
      Item.CategoryID := Data.Category;
      Item.NewDirName := Data.DirName;
      ChangeProgressCaption(Data.DirName);
      Item.SaveNFOAndImage;
      Item.Free;

      Node := VList.GetNext(Node);

      if ProgressStopping then
        break;

    end;  }
  finally
    UnLockDB;
  end;

  CloseProgressDialog;
  MessageDlg(Lang['Consistencecheckfinished'], mtInformation, [mbOK], 0);

  LoadProductsFromDB(true);
end;

procedure TMainForm.StopProcess(Sender: TObject);
begin
  ProgressStopping := true;
end;

function TMainForm.UTF8Encode(Name: string): AnsiString;
begin
  result := CodePages.UTF8Encode(Name);
end;

function TMainForm.GetCategoryIDs(ParentNode: PVirtualNode): string;
var
  Data: PNodeCategory;
  S: string;
  I: Integer;
  Node: PVirtualNode;

begin
  Data := FilterList.GetNodeData(ParentNode);
  if Data.ID >= 0 then
    result := IntToStr(Data.ID);
  Node := FilterList.GetFirstChild(ParentNode);
  while Assigned(Node) do
  begin
    S := GetCategoryIDs(Node);
    if S <> '' then
      result := result + ',' + S;

    Node := FilterList.GetNextSibling(Node);
  end;
end;

procedure TMainForm.LoadProductsFromDB(DBRefresh: boolean);
var
  Node: PVirtualNode;
  Data: PNodeCategory;
  Table: TSQLiteTable;
  Item: PNodeProduct;
  Filter: string;
  CatID: integer;
  TopNodeID, FocusedNodeID: integer;
  TopNode, FocusedNode: PVirtualNode;
begin
  TopNode := nil; FocusedNode := nil;
  if Assigned(VList.TopNode) then
    TopNodeID := PNodeProduct(VList.GetNodeData(VList.TopNode)).ID else TopNodeID := -1;
  if Assigned(VList.FocusedNode) then
    FocusedNodeID := PNodeProduct(VList.GetNodeData(VList.FocusedNode)).ID else FocusedNodeID := -1;

  VList.BeginUpdate;
  VList.Clear;
  VList.NodeDataSize := sizeOf(TNodeProduct);

  LockDB;
  try

    Filter := '';
    if eSearch.Text <> '' then
    begin
      Filter := '((Products.name LIKE :search) or (tags LIKE :search) or (description LIKE :search)) and ';
      DB.AddParamText(':search', UTF8Encode('%' + eSearch.Text + '%'));
    end
    else if Assigned(FilterList.FocusedNode) then
    begin
      Data := FilterList.GetNodeData(FilterList.FocusedNode);
      if Data.ID <> -1 then
        Filter := Format('(category in (%s)) and', [GetCategoryIDs(FilterList.FocusedNode)]);
    end;

    Table := DB.GetTable(Format('select Products.id, category, categories.name, Products.name, targetdirname, targetpath, sourcepath, tags, description, timestamp, url, status, categories.icon '+
        ' from Products LEFT JOIN Categories on Categories.ID = Products.Category where %s (status=1) order by timestamp desc;', [Filter]));
    while not Table.EOF do
    begin
      if not Table.FieldIsNull(8) then
        CatID := Table.FieldAsInteger(1)
      else
        CatID := -1;

//      if (SelectedCategoryID = '-1') or (CatID = SelectedCategoryID) then
      begin
        Node := VList.AddChild(nil);
        Item := VList.GetNodeData(Node);
        Item.ID := Table.FieldAsInteger(0);
        if not Table.FieldIsNull(2) then
        begin
          Item.Category := Table.FieldAsInteger(1);
          Item.CategoryName := UTF8ToString(Table.FieldAsString(2));
          Item.CategoryIconIndex := StrToIntDef(Table.FieldAsString(11), -1);
        end;
        Item.Name := UTF8ToString(Table.FieldAsString(3));
        Item.DirName := UTF8ToString(Table.FieldAsString(4));
        Item.TargetPath := UTF8ToString(Table.FieldAsString(5));
        Item.SourcePath := UTF8ToString(Table.FieldAsString(6));
        Item.Tags := UTF8ToString(Table.FieldAsString(7));
        Item.Description := UTF8ToString(Table.FieldAsString(8));
        Item.Timestamp := Table.FieldAsDouble(9);
        Item.URL := Trim(UTF8ToString(Table.FieldAsString(10)));

        if Item.ID = TopNodeID then TopNode := Node;
        if Item.ID = FocusedNodeID then FocusedNode := Node;
      end;
      Table.Next;
    end;
    Table.Free;
  finally
    UnLockDB;
  end;


  VList.EndUpdate;
  if VList.RootNodeCount > 0 then
  begin
    if Assigned(FocusedNode) then
      VList.FocusedNode := FocusedNode
    else
      VList.FocusedNode := VList.GetFirst();
    VListFocusChanged(VList,  VList.FocusedNode, 0);

    if Assigned(TopNode) then
      VList.TopNode := TopNode;
  end;
  VList.Invalidate;

  RefreshCategoriesCount;
end;

 {$REGION 'DB Tools'}
procedure TMainForm.VacuumDB;
begin
  ShowProgressDialog(Lang['Vacuummaindatabase'], Lang['Pleasewait']);
  DB.ExecSQL('VACUUM');
  ChangeProgressCaption(Lang['Vacuuminfodatabase']);
  InfoDB.ExecSQL('VACUUM');
  CloseProgressDialog;
  MessageDlg(Lang['Vacuumfinished'], mtInformation, [mbOK], 0);
end;

procedure TMainForm.BackupDB;
var
  BackupDialog: TSaveDialog;
begin
  BackupDialog := TSaveDialog.Create(MainForm);
  BackupDialog.InitialDir := IcePack.GetSpecialFolderPath(CSIDL_MYDOCUMENTS);
  BackupDialog.Filter := Lang['Stufforganizerbackupfiles'] + ' (*.backup)|*.backup';
  BackupDialog.FileName := Format('Stuff Organizer backup %s.backup', [FormatDateTime('yyyymmdd', Now)]);
  BackupDialog.DefaultExt := '.backup';
  if BackupDialog.Execute then
  begin
    BackupDBToFile(BackupDialog.FileName);
  end;
  BackupDialog.Free;
end;

procedure TMainForm.BackupDBToFile(FileName: string);
begin
  ShowProgressDialog(Lang['Backup'], Lang['Pleasewait']);
  try
    CloseDB;
    try
      if FileExists(FileName) then
        DeleteFile(FileName);
      ZipBackup.ForceType := true;
      ZipBackup.ArchiveType := atZip;
      ZipBackup.FileName := FileName;
      ZipBackup.AddFiles(ExtractFilePath(MainDBPath) + '*.*', 0);
      ZipBackup.Save;
      ZipBackup.CloseArchive;
    finally
      OpenDB;
    end;
    CloseProgressDialog;
    MessageDlg(Lang['Finished'], mtInformation, [mbOK], 0);
  except
    on E: Exception do
    begin
      CloseProgressDialog;
      MessageDlg(Lang['Errorduringbackup'] + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TMainForm.RestoreDB;
var
  RestoreDialog: TOpenDialog;
begin
  RestoreDialog := TOpenDialog.Create(MainForm);
  RestoreDialog.InitialDir := IcePack.GetSpecialFolderPath(CSIDL_MYDOCUMENTS);
  RestoreDialog.Filter := Lang['Stufforganizerbackupfiles'] + ' (*.backup)|*.backup';
  RestoreDialog.FileName := '';
  RestoreDialog.DefaultExt := '.backup';
  if RestoreDialog.Execute then
  begin
    RestoreDBFromFile(RestoreDialog.FileName);
  end;
  RestoreDialog.Free;
end;

procedure TMainForm.RestoreDBFromFile(FileName: string);
begin
  ShowProgressDialog(Lang['Restore'], Lang['Pleasewait']);
  try
    CloseDB;
    try
      if FileExists(FileName) then
      begin
        ZipRestore.ForceType := true;
        ZipRestore.ArchiveType := atZip;
        ZipRestore.FileName := FileName;
        ZipRestore.BaseDirectory := ExtractFilePath(MainDBPath);
        ZipRestore.ExtractFiles('*.*');
        ZipRestore.CloseArchive;
      end;
    finally
      OpenDB;
    end;
    CloseProgressDialog;
    MessageDlg(Lang['Finished'], mtInformation, [mbOK], 0);
    LoadCategoriesFromDB();
  except
    on E: Exception do
    begin
      CloseProgressDialog;
      MessageDlg(Lang['Errorduringrestore'] + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

 {$ENDREGION}

procedure TMainForm.LoadUnprocessedItems;
var
  Table: TSQLiteTable;
  Item: TPreProcessItem;
begin
  LockDB;
  try
    Table := DB.GetTable('select Products.id, category, Products.name, sourcepath, tags, description '+
        ' from Products LEFT JOIN Categories on Categories.ID = Products.Category where (status = 0);');
    while not Table.EOF do
    begin
      Item := TPreProcessItem.Create(Table.FieldAsInteger(0),
        Table.FieldAsInteger(1), UTF8ToString(Table.FieldAsString(2)), UTF8ToString(Table.FieldAsString(3)),
        UTF8ToString(Table.FieldAsString(4)), UTF8ToString(Table.FieldAsString(5)));
      Item.CalcDirSize;
      PreparingProducts.Add(Item);

{      if not Table.FieldIsNull(8) then
        CatID := Table.FieldAsInteger(1)
      else
        CatID := -1;

      if (SelectedCategoryID = -1) or (CatID = SelectedCategoryID) then
      begin
        Node := VList.AddChild(nil);
        Item := VList.GetNodeData(Node);
        Item.ID := Table.FieldAsInteger(0);
        if not Table.FieldIsNull(2) then
        begin
          Item.Category := Table.FieldAsInteger(1);
          Item.CategoryName := UTF8ToString(Table.FieldAsString(2));
          Item.CategoryIconIndex := StrToIntDef(Table.FieldAsString(11), -1);
        end;
        Item.Name := Table.FieldAsString(3);
        Item.DirName := Table.FieldAsString(4);
        Item.TargetPath := Table.FieldAsString(5);
        Item.Tags := Table.FieldAsString(6);
        Item.Description := Table.FieldAsString(7);
        Item.Timestamp := Table.FieldAsDouble(8);
        Item.URL := Trim(Table.FieldAsString(9));

        if Item.ID = TopNodeID then TopNode := Node;
        if Item.ID = FocusedNodeID then FocusedNode := Node;
      end;   }
      Table.Next;
    end;
    Table.Free;


  finally
    UnLockDB;
  end;
  RefreshQueueItemCount;
end;

procedure TMainForm.lProductNameClick(Sender: TObject);
var
  edit: TEdit;
begin
  edit := TEdit.Create(MainForm);
  edit.Parent := lProductName.Parent;
  edit.BoundsRect := lProductName.BoundsRect;
  edit.BringToFront;
  edit.Text := lProductName.Caption;
  edit.OnExit := EditBoxLostFocus;
  edit.OnKeyPress := EditBoxKeyPress;
  edit.Tag := integer(Pointer(lProductName));
  edit.SetFocus;
  edit.SelectAll;
end;

procedure TMainForm.lURLClick(Sender: TObject);
begin
  if lURL.Caption <> '' then
    OpenURL(lURL.Caption);
end;

procedure TMainForm.EditBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    EditBoxLostFocus(Sender);
  end;
end;


procedure TMainForm.EditBoxLostFocus(Sender: TObject);
var
  cmp: TComponent;
  Data: PNodeProduct;
begin
  cmp := TComponent(Pointer(TEdit(Sender).Tag));
  if cmp is TLabel and (TEdit(Sender).Text <> '') then
  begin
    TLabel(cmp).Caption := TEdit(Sender).Text;

    if Assigned(VList.FocusedNode) then
    begin
      Data := VList.GetNodeData(VList.FocusedNode);
      Data.Name := TEdit(Sender).Text;
      SaveSelectedNodeInfo;
      VList.InvalidateNode(VList.FocusedNode);
    end;
  end;
  TEdit(Sender).Free;
end;

procedure TMainForm.eSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    LoadProductsFromDB(true);
    Key := #0;
  end;
end;

procedure TMainForm.eTagsExit(Sender: TObject);
var
  Data: PNodeProduct;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    Data.Tags := eTags.Text;
    SaveSelectedNodeInfo;
    VList.InvalidateNode(VList.FocusedNode);
  end;
end;

procedure TMainForm.eTagsKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    eTagsExit(Sender);
end;

procedure TMainForm.mProductDescrExit(Sender: TObject);
var
  Data: PNodeProduct;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);
    Data.Description := mProductDescr.Text;
    SaveSelectedNodeInfo;
    VList.InvalidateNode(VList.FocusedNode);
  end;
end;

procedure TMainForm.mProductDescrKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (LowerCase(Chr(Key)) = 'a') then
    TMemo(Sender).SelectAll;

end;

procedure TMainForm.bStopClick(Sender: TObject);
begin
  ProgressStopping := true;
end;


procedure TMainForm.PreparingNewFiles(FileList: TStrings; CategoryID: integer);
var
  I: Integer;
  Item: TPreProcessItem;
  J: Integer;
  bNext: boolean;
  mrRes: integer;
begin
  mrRes := mrNone;
  ShowProgressDialog(Lang['Preparing'], Lang['Pleasewait'], bStopClick);
  for I := 0 to FileList.Count - 1 do
  begin
    Item := nil;
    //Megkeresni nincs-e már benne az az útvonal
    bNext := false;
    for J := 0 to PreparingProducts.Count - 1 do
      if TPreProcessItem(PreparingProducts[J]).SourcePath = FileList[I] then
      begin
        bNext := true;
        //Ha passzivként már benne van akkor aktívra rakjuk
        if TPreProcessItem(PreparingProducts[J]).Status = ITEM_PASSIVE then
          TPreProcessItem(PreparingProducts[J]).Status := ITEM_ACTIVE;
        break;
      end;

    if bNext then
      continue;

    ChangeProgressCaption(Format(Lang['Preparings'], [ExtractFileName(FileList[I])]));
    Item := TPreProcessItem.Create(FileList[I]);
    Item.CategoryID := CategoryID;
    Item.CalcDirSize;
    //Megnézni az adatbázisban, hogy nincs-e már benne
    if HasInDB(Item) then
    begin

      if not (mrRes in [mrYesToAll, mrNoToAll]) then
      begin
        HideProgressDialog;
        mrRes := MessageDlg(Format(Lang['ThespecifiedsourcedirectoryshasbeenprocessedDoyouwanttocontinue'], [Item.SourcePath]), mtWarning, [mbYes, mbNo, mbYesToAll, mbNoToAll], 0);
        UnhideProgressDialog;
      end;

      if mrRes in [mrNo, mrNoToAll] then
      begin
        FreeAndNil(Item);
        continue;
      end;
    end;

    if Item.CategoryID = -1 then
    begin
      //Megnézni a bedobott elem nem-e egy kategória path-járól van bedobva, mert akkor alapba azt a kategóriát adjuk neki
      for J := Low(Categories) to High(Categories) - 1 do
      begin
        if IncludeTrailingBackslash(Categories[J].Path) = Item.OldDirPath then
        begin
          Item.CategoryID := Categories[J].ID;
          break;
        end;
      end;
    end;

    if Item.CategoryID = -1 then
    begin
      if ICS_ENABLED then
      begin
        //Intelligens kategória választót futtatni
        ChangeProgressCaption(Format(Lang['RunningICSons'], [ExtractFileName(FileList[I])]));

        Item.CategoryID := ExecuteICS(Item.Tags);
      end;
    end;


    if Assigned(Item) then
      PreparingProducts.Add(Item);

    if ProgressStopping then
      break;
  end;
  if PreparingProducts.Count > 0 then
  begin
    if PreProcessForm.Showing then
    begin
      PreProcessForm.LoadItems;
      PreProcessForm.BringToFront
    end
    else
      PreProcessForm.Show;
  end;
  CloseProgressDialog;
  RefreshQueueItemCount;
end;

 {$REGION 'VirtualTree events'}

procedure TMainForm.FilterListCollapsed(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PNodeCategory;
begin
  Data := FilterList.GetNodeData(Node);
  ConfigXML.Root.SetItemValue(Format('Main.FilterList.State.Category[%d]', [Data.ID]), 0);
end;

procedure TMainForm.FilterListCollapsing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
begin
  if Node.Parent = FilterList.RootNode then
    Allowed := false;
end;

procedure TMainForm.FilterListDblClick(Sender: TObject);
begin
  Modifycategory1.Click;
end;

procedure TMainForm.FilterListDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  SelectList: TNodeArray;
  Node: PVirtualNode;
  Data: PNodeProduct;

  SourceCat, Cat: PNodeCategory;
  OrigCategoryPath, NewCategoryPath, NewTargetPath: string;
  mResult: integer;
  I: Integer;
begin
  if Assigned(Source) and (Source = VList) then
  begin
    Node := Sender.GetNodeAt(Pt.X, Pt.Y);
    if Assigned(Node) then
    begin
      Cat := FilterList.GetNodeData(Node);
      NewCategoryPath := Cat.Path;
      if Cat.NodeType in [NODE_FILTER_ALL, NODE_FILTER_CATEGORY] then
      begin
        mResult := mrNone;
        VList.BeginUpdate;
        SelectList := VList.GetSortedSelection(false);
        try
          for I := Low(SelectList) to High(SelectList) do
          begin
            Node := SelectList[I];
            Data := VList.GetNodeData(Node);
            if NewCategoryPath <> '' then
            begin
              OrigCategoryPath := ExtractFilePath(Data.TargetPath);
              if IncludeTrailingBackslash(NewCategoryPath) <> OrigCategoryPath then
              begin
                if mResult = mrNone then
                  mResult := MessageDlg(Lang['Wouldyouliketomovedirectoriesaccordingtothenewcategory'], mtConfirmation, [mbYes, mbNo, mbAbort], 0);
                case mResult of
                  mrYes: begin

                    if (Data.TargetPath = IncludeTrailingBackslash(NewCategoryPath) + Data.DirName) or
                      (
                          (IcePack.IceFileOperation(FO_MOVE, ExcludeTrailingBackslash(Data.TargetPath), IncludeTrailingBackslash(IncludeTrailingBackslash(NewCategoryPath) + Data.DirName), true, true))
//                          (MoveDir(Data.TargetPath, IncludeTrailingBackslash(NewCategoryPath) + Data.DirName))
                          and DirectoryExists(IncludeTrailingBackslash(NewCategoryPath) + Data.DirName)
                      ) then
                      Data.TargetPath := IncludeTrailingBackslash(NewCategoryPath) + Data.DirName;
                  end;
                  mrAbort: break;
                end;
              end;
            end;

            LockDB;
            try
              if Cat.ID = -1 then
                DB.AddParamNull(':category')
              else
                DB.AddParamInt(':category', Cat.ID);
              DB.AddParamInt(':id', Data.ID);
              DB.AddParamText(':targetpath', UTF8Encode(Data.TargetPath));
              DB.ExecSQL('update Products set category=:category,targetpath=:targetpath where id = :id');
            finally
              UnLockDB;
            end;
          end;
        finally
          SetLength(SelectList, 0);
          VList.EndUpdate;
          LoadProductsFromDB(true);
        end;
      end;
    end;

  end
  else if Assigned(Source) and (Source = FilterList) then
  begin
    if Assigned(FilterList.DropTargetNode) and Assigned(FilterList.FocusedNode) then
    begin
      Cat := FilterList.GetNodeData(FilterList.DropTargetNode);
      SourceCat := FilterList.GetNodeData(FilterList.FocusedNode);
      if (SourceCat.ID <> Cat.ID) and (SourceCat.ParentID <> Cat.ID) then
      begin
        LockDB;
        try
          DB.AddParamInt(':id', SourceCat.ID);
          DB.AddParamInt(':parent', Cat.ID);
          DB.ExecSQL('update Categories set parent = :parent where id = :id');
        finally
          UnLockDB;
        end;
        LoadCategoriesFromDB(SourceCat.ID);
      end;
    end;
  end;
end;

procedure TMainForm.FilterListDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
  Node: PVirtualNode;
  Data: PNodeCategory;
begin
  if Assigned(Source) and (Source = VList) then
  begin
    Node := Sender.GetNodeAt(Pt.X, Pt.Y);
    if Assigned(Node) then
    begin
      Data := FilterList.GetNodeData(Node);
      Accept := Data.NodeType in [NODE_FILTER_ALL, NODE_FILTER_CATEGORY];
    end;
  end
  else if Assigned(Source) and (Source = FilterList) then
  begin
    if Assigned(FilterList.DropTargetNode) then
    begin
      Data := FilterList.GetNodeData(FilterList.DropTargetNode);
      Accept := (FilterList.DropTargetNode <> FilterList.FocusedNode) and (Data.NodeType in [NODE_FILTER_ALL, NODE_FILTER_CATEGORY]);
    end;
  end
  else if State = dsDragMove then
  begin
    Node := Sender.GetNodeAt(Pt.X, Pt.Y);
    if Assigned(Node) then
      DraggedCategory := Sender.GetNodeData(Node);
  end;
end;

procedure TMainForm.FilterListDrawText(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
var
  Data: PNodeCategory;
begin
  Data := Sender.GetNodeData(Node);
  if Data.NodeType = NODE_FILTER_NEW_CATEGORY then
  begin
    TargetCanvas.Font.Style := [fsItalic];
    TargetCanvas.Font.Color := clGray;
  end
  else if Data.NodeType = NODE_FILTER_ALL then
  begin
    TargetCanvas.Font.Style := [fsBold];
  end;
end;

procedure TMainForm.FilterListExpanded(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PNodeCategory;
begin
  Data := FilterList.GetNodeData(Node);
  ConfigXML.Root.SetItemValue(Format('Main.FilterList.State.Category[%d]', [Data.ID]), 1);
end;

procedure TMainForm.FilterListFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  Data: PNodeCategory;
begin
  Data := Sender.GetNodeData(Node);
  if Data.NodeType = NODE_FILTER_NEW_CATEGORY then
    aNewCategory.Execute
  else
  begin
    eSearch.Text := '';
    LoadProductsFromDB(false);
  end;
end;

procedure TMainForm.FilterListFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PNodeCategory;

begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^);
end;

procedure TMainForm.FilterListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PNodeCategory;
begin
  Data := Sender.GetNodeData(Node);
  case Data.NodeType of
    NODE_FILTER_ALL: ImageIndex := 1;
    NODE_FILTER_CATEGORY: ImageIndex := Data.IconIndex;
    NODE_FILTER_NEW_CATEGORY: ImageIndex := -1;
  end;
end;

procedure TMainForm.FilterListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PNodeCategory;
begin
  Data := Sender.GetNodeData(Node);
  CellText := Data.Name;
  if (Data.Count > 0) and (Data.ID > -2) then
    CellText := CellText + Format(' (%d)', [Data.Count]);

  CellText := CellText + '   ';
end;

function TMainForm.FirstLine(S: string): string;
var
  tmp: string;
begin
  tmp := S;
  result := CutAt(tmp, #13);
end;

procedure TMainForm.VListBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  Data: PNodeProduct;
  I: Integer;

begin
  Data := VList.GetNodeData(Node);
  if Data.Category <> -1 then
  begin
    for I := Low(Categories) to High(Categories) do
      if Data.Category = Categories[I].ID then
        if Categories[I].Color <> clNone then
        begin
          TargetCanvas.Brush.Color := Categories[I].Color;
          TargetCanvas.FillRect(CellRect);
        end;
  end;
end;

procedure TMainForm.VListCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  Data1, Data2: PNodeProduct;
begin
  Data1 := VList.GetNodeData(Node1);
  Data2 := VList.GetNodeData(Node2);
  case Column of
    0: Result := CompareText(Data1.CategoryName, Data2.CategoryName);
    1: Result := CompareText(Data1.Name, Data2.Name);
    2: Result := CompareText(Data1.Description, Data2.Description);
    3: Result := CompareDateTime(Data1.Timestamp, Data2.Timestamp);
    4: Result := CompareText(Data1.TargetPath, Data2.TargetPath);
  end;

  //Result := 0 - Result; //VirtualStringTree bug fix
end;

procedure TMainForm.VListDblClick(Sender: TObject);
begin
  aOpenDir.Execute;
end;

procedure TMainForm.VListFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  Data: TNodeProduct;
begin
  if Assigned(Node) then
  begin
    Data := TNodeProduct(VList.GetNodeData(Node)^);
    LoadProductInfoToNode(Data);
  end;
end;

procedure TMainForm.VListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PNodeProduct;
begin
  if VList.Header.Columns[Column].Position = 0 then
  begin
    Data := VList.GetNodeData(Node);
    ImageIndex := Data.CategoryIconIndex;
  end;
end;

procedure TMainForm.VListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  Data: PNodeProduct;
begin
  Data := VList.GetNodeData(Node);
  case Column of
    0: CellText := Data.CategoryName;
    1: CellText := Data.Name;
    2: CellText := FirstLine(Data.Description);
    3:
    begin
      if DateOf(Data.Timestamp) = DateOf(Now) then
        CellText := TimeToStr(Data.Timestamp)
      else
        CellText := DateToStr(Data.Timestamp);
//      CellText := CellText + ' (' + IcePack.SecondsToTimeString(SecondsBetween(Data.Timestamp,Now)) + ')';
    end;
    4: CellText := Data.TargetPath;
  else
    CellText := '';
  end;
end;

procedure TMainForm.VListHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin

  if (VList.Header.SortColumn = HitInfo.Column) then
    VList.Header.SortDirection := TSortDirection(1 - integer(VList.Header.SortDirection))
  else
  begin
    VList.Header.SortColumn := HitInfo.Column;
    VList.Header.SortDirection := sdAscending;
  end;
end;

procedure TMainForm.VListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
    Deleteselecteditems1.Click;
//  if (Key = Ord('C')) and (ssCtrl in Shift) then
//    aTargetToClipBoard.Execute;
end;

 {$ENDREGION}


procedure TMainForm.WMEndSession(var Msg: TWMEndSession);
begin
  Msg.Result := 1;
  Close;
end;

procedure TMainForm.LoadProductInfoToNode(Data: TNodeProduct);
var
  bHasNFO: boolean;
  count: integer;
  Table: TSqliteTable;
  MS: TMemoryStream;
  FS: TFileStream;
  TempFile: string;
  img: TImage;
begin
  SelectedProductID := Data.ID;
  LockDB;
  try
    count := InfoDB.GetTableValue('select count(id) from ProductInfo where product_id = ' + IntToStr(Data.ID));
    bHasNFO := count > 0;

    lProductName.Caption := Data.Name;
    mProductDescr.Lines.Text := Data.Description;
    eTags.Text := Data.Tags;
    lURL.Caption := Data.URL;
    bShowNFO.Enabled := bHasNFO;

    //Get product image
    InfoDB.AddParamInt(':id', Data.ID);
    Table := InfoDB.GetTable('select filename, data from ProductImage where product_id = :id');
    if not Table.EOF then
    begin
      MS := Table.FieldAsBlob(1);

      TempFile := ChangeFileExt(IcePack.GetTempFile, ExtractFileExt(UTF8ToString(Table.FieldAsString(0))));
      FS := TFileStream.Create(TempFile, fmCreate);
      img := TImage.Create(nil);
      try
        FS.CopyFrom(MS, MS.Size);
        FS.Free;
        ProductImage.Picture.LoadFromFile(TempFile);
        ProductImage.Stretch := true;
      finally
        img.Free;
        MS.Free;
        DeleteFile(TempFile);
      end;
    end
    else
    begin
      ProductImage.Picture.Assign(imgNoPicture.Picture);
      ProductImage.Stretch := false;
    end;
    Table.Free;
  finally
    UnLockDB;
  end;
end;

procedure TMainForm.DeleteCategory(Data: PNodeCategory);
begin
  LockDB;
  try
    DB.ExecSQL('update Categories set parent = -1 where parent = ' + IntToStr(Data.ID));
    DB.ExecSQL('update Products set category = null where category = ' + IntToStr(Data.ID));
    DB.ExecSQL('delete from Categories where id = ' + IntToStr(Data.ID));
  finally
    UnLockDB;
  end;
  LoadCategoriesFromDB;
end;

procedure TMainForm.DeleteSelectedProductNodes;
var
  I: Integer;
  Node: PVirtualNode;
  Data: PNodeProduct;
  SelectList: TNodeArray;
  mrDelHDDAnswer: TModalResult;
begin
  mrDelHDDAnswer := mrNone;
  VList.BeginUpdate;
  try
    ShowProgressDialog(Lang['Deleteitems'], Lang['Pleasewait'], StopProcess);
    SelectList := VList.GetSortedSelection(true);
    for I := Low(SelectList) to High(SelectList) do
    begin
      if ProgressStopping then
        break;
      Node := SelectList[I];
      Data := VList.GetNodeData(Node);
      ChangeProgressCaption(Lang['Delete'] + Data.DirName + '...');
      if DirectoryExists(Data.TargetPath) then
      begin
        if mrDelHDDAnswer = mrNone then
        begin
          HideProgressDialog;
          mrDelHDDAnswer := MessageDlg(Lang['Wouldyouliketodeletethesefoldersonharddisk'], mtWarning, [mbYes, mbNo, mbAbort], 0);
          UnhideProgressDialog;
        end;
        case mrDelHDDAnswer of
          mrYes:
            IcePack.IceFileOperation(FO_DELETE, ExcludeTrailingBackslash(Data.TargetPath), '', true, true);
          mrAbort:
            break;
        end;
      end;
      DeleteProduct(Data.ID);
    end;
    SetLength(SelectList, 0);
  finally
    VList.EndUpdate;
    CloseProgressDialog;
    LoadProductsFromDB(true);
  end;
end;

procedure TMainForm.ModifyCategory(Data: PNodeCategory);
begin
  CategoriesForm.Caption := Lang['Modifycategoryproperties'];
  CategoriesForm.eName.Text := Data.Name;
  CategoriesForm.ePath.Text := Data.Path;
  CategoriesForm.ePath.Enabled := Data.Count = 0;
  CategoriesForm.cbIcons.ItemIndex := Data.IconIndex;
  if Data.Color <> clNone then
  begin
    CategoriesForm.cbColor.Checked := true;
    CategoriesForm.shColor.Brush.Color := Data.Color;
  end
  else
  begin
    CategoriesForm.cbColor.Checked := false;
    CategoriesForm.shColor.Brush.Color := clWhite;
  end;
  if CategoriesForm.ShowModal = mrOk then
  begin
    LockDB;
    try
      DB.AddParamText(':name', UTF8Encode(CategoriesForm.eName.Text));
      if CategoriesForm.cbColor.Checked then
        DB.AddParamText(':color', ColorToHtml(CategoriesForm.shColor.Brush.Color))
      else
        DB.AddParamNull(':color');
      DB.AddParamInt(':id', Data.ID);
      DB.AddParamText(':path', UTF8Encode(CategoriesForm.ePath.Text));
      DB.AddParamInt(':icon', CategoriesForm.cbIcons.ItemIndex);
      DB.ExecSQL('update Categories set name = :name, path = :path, color = :color, icon = :icon where id = :id;');
    finally
      UnLockDB;
    end;
    LoadCategoriesFromDB(Data.ID);
  end;
end;

procedure TMainForm.SaveNewProductImage(ProductInfo: PPluginProductItem;
  FileName: string);
var
  FS: TFileStream;
begin
  if FileExists(FileName) and (Pos(ExtractFileExt(FileName), GraphicFileMask(TGraphic)) > 0) then
  begin
    FS := TFileStream.Create(FileName, fmOpenRead);
    try
      InfoDB.ExecSQL('delete from ProductImage where product_id = ' + IntToStr(ProductInfo.ID));
      InfoDB.AddParamInt(':id', ProductInfo.ID);
      InfoDB.AddParamText(':filename', UTF8Encode(ExtractFileName(FileName)));
      InfoDB.AddParamBlob(':data', FS);
      InfoDB.ExecSQL('insert into ProductImage (product_id, filename, data) values (:id, :filename, :data);');
    finally
      FS.Free;
    end;
  end;
end;

procedure TMainForm.SaveNewProductInfo(ProductInfo: PPluginProductItem);
begin
  LockDB;
  try
    DB.AddParamInt(':id', ProductInfo.ID);
    DB.AddParamText(':name', UTF8Encode(ProductInfo.Name));
    DB.AddParamText(':description', UTF8Encode(ProductInfo.Description));
    DB.AddParamText(':tags', UTF8Encode(ProductInfo.Tags));
    DB.AddParamText(':url', UTF8Encode(ProductInfo.URL));
    DB.ExecSQL('update Products set name = :name, description = :description, tags = :tags, url = :url where id = :id');

    TPreProcessItem.SaveTagsToDB(ProductInfo.ID, ProductInfo.Tags);
  finally
    UnLockDB;
  end;
end;

procedure TMainForm.SaveSelectedNodeInfo;
var
  Data: PNodeProduct;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Data := VList.GetNodeData(VList.FocusedNode);

    LockDB;
    try
      DB.AddParamInt(':id', Data.ID);
      DB.AddParamText(':name', UTF8Encode(Data.Name));
      DB.AddParamText(':description', UTF8Encode(Data.Description));
      DB.AddParamText(':tags', UTF8Encode(Data.Tags));
      DB.AddParamText(':url', UTF8Encode(Data.URL));
      DB.ExecSQL('update Products set name = :name, description = :description, tags = :tags, url = :url where id = :id');

      TPreProcessItem.SaveTagsToDB(Data.ID, Data.Tags);
    finally
      UnLockDB;
    end;
  end;
end;

procedure TMainForm.DeleteProduct(ID: integer);
begin
  LockDB;
  try
    DB.ExecSQL('delete from Products where id = ' + IntToStr(ID));
    DB.ExecSQL('delete from Tags where product_id = ' + IntToStr(ID));
    InfoDB.ExecSQL('delete from ProductInfo where product_id = ' + IntToStr(ID));
    InfoDB.ExecSQL('delete from ProductImage where product_id = ' + IntToStr(ID));
  finally
    UnLockDB;
  end;
end;


procedure TMainForm.SaveUnprocessedItems;
var
  I: Integer;
  Item: TPreProcessItem;
  Table: TSQLiteTable;
  NewID, ID: integer;

begin
  ShowProgressDialog(Lang['Saveunprocesseditems'], Lang['Pleasewait']);
  for I := 0 to PreparingProducts.Count - 1 do
  begin
    Item := PreparingProducts[I];
    if Item.Status in [ITEM_PASSIVE, ITEM_ACTIVE] then
    begin
      Item.Status := ITEM_PASSIVE; //Kilépéskor, ha még nem volt elkezdve feldolgozni akkor passive-ként mentse el
      Item.SaveToDB;
    end;
  end;
  CloseProgressDialog;
end;

procedure TMainForm.ShowOptionsForm;
begin
  OptionsForm.Show;
end;

initialization

finalization

end.
