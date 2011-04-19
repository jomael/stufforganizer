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

unit uPreprocessDirs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ToolWin, VirtualTrees, Menus,
  Generics.Collections, ShellAPI, Gradient, uClasses, IceXML;

type
  TPreProcessForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    bOk: TButton;
    SettingsPanel: TPanel;
    cbCategories: TComboBox;
    Label3: TLabel;
    eNewDirName: TLabeledEdit;
    lNewPath: TLabel;
    cbUnpack: TCheckBox;
    cbUnPackISO: TCheckBox;
    cbDelSource: TCheckBox;
    cbDelNFO: TCheckBox;
    cbDelDIZ: TCheckBox;
    cbDelSFV: TCheckBox;
    eTags: TLabeledEdit;
    PopupMenu1: TPopupMenu;
    Deleteselecteditem1: TMenuItem;
    bCancel: TButton;
    lAddCat: TLabel;
    VList: TVirtualStringTree;
    lSaveDefault: TLabel;
    Gradient1: TGradient;
    Gradient2: TGradient;
    N1: TMenuItem;
    Checkall1: TMenuItem;
    Uncheckall1: TMenuItem;
    procedure VListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VListFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure cbUnpackClick(Sender: TObject);
    procedure Deleteselecteditem1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lAddCatClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bCancelClick(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VListGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure cbCategoriesChange(Sender: TObject);
    procedure VListEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure VListCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure VListClick(Sender: TObject);
    procedure eNewDirNameExit(Sender: TObject);
    procedure eTagsExit(Sender: TObject);
    procedure lSaveDefaultClick(Sender: TObject);
    procedure VListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure VListHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
      Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode);
    procedure Checkall1Click(Sender: TObject);
    procedure Uncheckall1Click(Sender: TObject);
    procedure VListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    procedure ProcessSelections;
    procedure LoadCategories;
    function GetCountOfActiveItems: integer;
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
  public
    { Public declarations }
    SelectionList: TList;
    Loading: boolean;
    FirstRun: boolean;

    procedure LoadItems;
    procedure Processing;
    procedure StatusChanged;

    procedure RefreshList;
  end;

var
  PreProcessForm: TPreProcessForm;

implementation

{$R *.dfm}

uses
  uMain, IcePack, uConstans, uProgress, uProcessThread, uThreadProcessForm;

{ TProcessForm }


procedure TPreProcessForm.ProcessSelections;
var
  i: integer;
  Node,PrevNode: PVirtualNode;
begin
  SelectionList.Clear;
  if (VList.SelectedCount = 0) then Exit;

  Node := VList.GetFirstSelected;
  if Assigned(Node) then
  begin
    SelectionList.Add(PreparingProducts[Node.Index]);
    for i := 1 to VList.SelectedCount - 1 do
    begin
      Node := VList.GetNextSelected(Node,false);
      SelectionList.Add(PreparingProducts[Node.Index]);
    end;
  end;
end;

procedure TPreProcessForm.RefreshList;
begin
  LoadItems;
end;

procedure TPreProcessForm.StatusChanged;
var
  c: integer;
  I: Integer;
begin
  c := GetCountOfActiveItems;

  if c = 0 then
  begin
    if NowProcessing then
    begin
      bOk.Caption := 'View log';
      bOk.Enabled := true;
    end
    else
    begin
      bOk.Caption := 'Process';
      bOk.Enabled := false;

    end;
  end
  else
  begin
    bOk.Caption := Format('Process (%d)', [c]);
    bOk.Enabled := true;
  end;

end;

procedure TPreProcessForm.Uncheckall1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to PreparingProducts.Count - 1 do
    if TPreProcessItem(PreparingProducts[I]).Status in [ITEM_ACTIVE, ITEM_PASSIVE] then
      TPreProcessItem(PreparingProducts[I]).Status := ITEM_PASSIVE;
  StatusChanged;
  VList.Invalidate;
end;

procedure TPreProcessForm.AcceptFiles( var msg : TMessage );
const
  cnMaxFileNameLen = 1000;
var
  i,
  nCount     : integer;
  acFileName : array [0..cnMaxFileNameLen] of char;
  Files: TStrings;
begin
  Files := TStringList.Create;
  nCount := DragQueryFile( msg.WParam, $FFFFFFFF, acFileName, cnMaxFileNameLen );

  for i := 0 to nCount-1 do
  begin
    DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );
    Files.Add(acFileName);
  end;
  DragFinish( msg.WParam );

  MainForm.PreparingNewFiles(Files, -1);
  BringToFront;
  Files.Free;
end;

procedure TPreProcessForm.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TPreProcessForm.bOkClick(Sender: TObject);
begin
  Processing;
end;

function TPreProcessForm.GetCountOfActiveItems: integer;
var
  I: integer;
begin
  result := 0;
  for I := 0 to PreparingProducts.Count - 1 do
  begin
    if TPreProcessItem(PreparingProducts[I]).Status = ITEM_ACTIVE then
      Inc(result);
  end;
end;

procedure TPreProcessForm.Processing;



var
  I, J: Integer;
  Item: TPreProcessItem;
  Count: integer;
  SumSize: Int64;
begin
  if GetCountOfActiveItems = 0 then
  begin
    ThreadProcessForm.Show;
    Self.Hide;
    Exit;
  end;

  if NowProcessing then
  begin
    //Ha már folyik egy feldolgozás, akkor adja hozzá
    Count := 0; SumSize := 0;
    for I := 0 to PreparingProducts.Count - 1 do
    begin
      Item := TPreProcessItem(PreparingProducts[I]);
      if Item.Status = ITEM_ACTIVE then
      begin
        ProcThread.AddItem(Item);
        SumSize := SumSize + Item.DirTreeSize;
        Inc(Count);
      end;
    end;

    if Count > 0 then
    begin
      Self.Hide;
      ThreadProcessForm.AddNewItems(Count, SumSize);
      ThreadProcessForm.Show;
      ProcThread.Resume;
    end

  end
  else
  begin
    if not Assigned(ProcThread) then
    begin
      ProcThread := TProcessThread.Create(true);
      ProcThread.Initialize(ThreadProcessForm.Handle);
      ProcThread.Finish := ThreadProcessForm.ThreadFinished;
      ProcThread.ClearItems;
    end;

    Count := 0; SumSize := 0;
    for I := 0 to PreparingProducts.Count - 1 do
    begin
      Item := TPreProcessItem(PreparingProducts[I]);
      if Item.Status = ITEM_ACTIVE then
      begin
        ProcThread.AddItem(Item);
        SumSize := SumSize + Item.DirTreeSize;
        Inc(Count);
      end;
    end;

    if Count > 0 then
    begin
      ThreadProcessForm.Clear;
      Self.Hide;
      ThreadProcessForm.Start(Count, SumSize);
      ThreadProcessForm.Show;
      ProcThread.Resume;
    end
    else
    begin
      ProcThread.Free;
    end;
  end;
end;

procedure TPreProcessForm.cbCategoriesChange(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SelectionList.Count - 1 do
  begin
    if TPreProcessItem(SelectionList[I]).Status in [ITEM_ACTIVE, ITEM_PASSIVE] then
    begin
      if cbCategories.ItemIndex > 0 then
        TPreProcessItem(SelectionList[I]).CategoryID := Categories[cbCategories.ItemIndex - 1].ID
      else
        TPreProcessItem(SelectionList[I]).CategoryID := -1;

      lNewPath.Caption := 'New path: ' + TPreProcessItem(SelectionList[I]).NewDirPath;
    end;
  end;

  VList.Invalidate;
end;

procedure TPreProcessForm.cbUnpackClick(Sender: TObject);
var
  I: Integer;
begin
  if Loading then exit;

  for I := 0 to SelectionList.Count - 1 do
  begin
    if TPreProcessItem(SelectionList[I]).Status in [ITEM_ACTIVE, ITEM_PASSIVE] then
    begin
      TPreProcessItem(SelectionList[I]).UnPack := cbUnPack.Checked;
      TPreProcessItem(SelectionList[I]).UnPackISO := cbUnPackISO.Checked;
      TPreProcessItem(SelectionList[I]).DelNFO := cbDelNFO.Checked;
      TPreProcessItem(SelectionList[I]).DelDIZ := cbDelDIZ.Checked;
      TPreProcessItem(SelectionList[I]).DelSFV := cbDelSFV.Checked;
      TPreProcessItem(SelectionList[I]).DelSourceDir := cbDelSource.Checked;
    end;
  end;

  VList.Invalidate;
end;

procedure TPreProcessForm.Checkall1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to PreparingProducts.Count - 1 do
    if TPreProcessItem(PreparingProducts[I]).Status in [ITEM_ACTIVE, ITEM_PASSIVE] then
      TPreProcessItem(PreparingProducts[I]).Status := ITEM_ACTIVE;
  StatusChanged;
  VList.Invalidate;
end;

procedure TPreProcessForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle OR WS_EX_APPWINDOW;
end;

procedure TPreProcessForm.Deleteselecteditem1Click(Sender: TObject);
var
  I, Index: Integer;
  Item: TPreProcessItem;
begin
  if (MessageDlg('Are you sure delete the selected items?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    VList.BeginUpdate;
    for I := SelectionList.Count - 1 downto 0 do
    begin
      if not (TPreProcessItem(SelectionList[I]).Status in [ITEM_PROCESSING, ITEM_WAITING]) then
      begin
        Item := TPreProcessItem(SelectionList[I]);
        if (Item.ID <> -1) then
          MainForm.DeleteProduct(Item.ID);
        PreparingProducts.Delete(PreparingProducts.IndexOf(Item));
        SelectionList.Delete(I);
      end
      else
        MessageDlg(Format('A(z) ''%s'' elem nem törölhetõ!', [(TPreProcessItem(SelectionList[I])).NewDirName]), mtWarning, [mbOK], 0);
    end;

    VList.RootNodeCount := PreparingProducts.Count;
    VList.EndUpdate;

    MainForm.RefreshQueueItemCount;

    if PreparingProducts.Count = 0 then
      Close;
  end;
end;

procedure TPreProcessForm.eNewDirNameExit(Sender: TObject);
var
  I: Integer;
begin
  if Loading then exit;

  for I := 0 to SelectionList.Count - 1 do
  begin
    if TPreProcessItem(SelectionList[I]).Status in [ITEM_ACTIVE, ITEM_PASSIVE] then
    begin
      TPreProcessItem(SelectionList[I]).NewDirName := eNewDirName.Text;
      lNewPath.Caption := 'New path: ' + TPreProcessItem(SelectionList[I]).NewDirPath;
    end;
  end;

  VList.Invalidate;
end;

procedure TPreProcessForm.eTagsExit(Sender: TObject);
var
  I: Integer;
begin
  if Loading then exit;

  for I := 0 to SelectionList.Count - 1 do
    if TPreProcessItem(SelectionList[I]).Status in [ITEM_ACTIVE, ITEM_PASSIVE] then
      TPreProcessItem(SelectionList[I]).Tags := eTags.Text;

  VList.Invalidate;
end;

procedure TPreProcessForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Columns, Col: TXMLItem;
  I: integer;
begin
  if Action = caFree then
  begin
    SelectionList.Free;
  end;

  ConfigXML.Root.SetItemValue('PreProcess.LastState.Left', Left);
  ConfigXML.Root.SetItemValue('PreProcess.LastState.Top', Top);
  ConfigXML.Root.SetItemValue('PreProcess.LastState.Width', Width);
  ConfigXML.Root.SetItemValue('PreProcess.LastState.Height', Height);

  Columns := ConfigXML.Root.GetItemEx('PreProcess.VList.Columns', true);
  Columns.ClearChildrens;
  for I := 0 to VList.Header.Columns.Count -1 do
  begin
    Col := Columns.New('Column');
    Col.Attr['id'] := VList.Header.Columns[I].ID;
    Col.Attr['position'] := VList.Header.Columns[I].Position;
    Col.Attr['width'] := VList.Header.Columns[I].Width;
  end;

  Mainform.BringToFront;
end;

procedure TPreProcessForm.FormCreate(Sender: TObject);
begin
  SelectionList := TList.Create;
  DragAcceptFiles( Handle, True );
  FirstRun := true;
end;

procedure TPreProcessForm.FormShow(Sender: TObject);
var
  Columns, Col: TXMLItem;
  I: integer;
begin
  Loading := false;

  if FirstRun then
  begin
    FirstRun := false;

    Left    := ConfigXML.Root.GetItemValue('PreProcess.LastState.Left', Left);
    Top     := ConfigXML.Root.GetItemValue('PreProcess.LastState.Top', Top);
    Width   := ConfigXML.Root.GetItemValue('PreProcess.LastState.Width', Width);
    Height  := ConfigXML.Root.GetItemValue('PreProcess.LastState.Height', Height);

    //Oszlopok állapotának visszaállítása
    Columns := ConfigXML.Root.GetItemEx('PreProcess.VList.Columns', true);
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
  end;
  LoadCategories;

  LoadItems;
end;

procedure TPreProcessForm.lAddCatClick(Sender: TObject);
begin
  MainForm.AddNewCategory;
  LoadCategories;
end;

procedure TPreProcessForm.LoadCategories;
var
  I: Integer;
begin
  cbCategories.Items.Clear;
  cbCategories.AddItem('<no category>', nil);
  for I := Low(Categories) to High(Categories) do
    cbCategories.AddItem(Categories[I].Name, nil);
  cbCategories.ItemIndex := 0;
end;

procedure TPreProcessForm.LoadItems;
var
  I: Integer;
  Item: TPreProcessItem;
begin
  VList.BeginUpdate;
  try
    VList.RootNodeCount := PreparingProducts.Count;
  finally
    VList.EndUpdate;
  end;
  if (not Assigned(VList.FocusedNode)) and (VList.RootNodeCount > 0) then
  begin
    VList.Selected[VList.GetFirst] := true;
    VList.FocusedNode := VList.GetFirst();
    VListFocusChanged(VList, VList.FocusedNode, VList.FocusedColumn);
//    ProcessSelections();
  end
  else
    ProcessSelections;
  StatusChanged;
end;

procedure TPreProcessForm.lSaveDefaultClick(Sender: TObject);
begin
  ConfigXML.Root.SetItemValue('PreProcess.DefaultSettings.UnPack', iff(cbUnPack.Checked, '1', '0'));
  ConfigXML.Root.SetItemValue('PreProcess.DefaultSettings.UnPackISO', iff(cbUnPackISO.Checked, '1', '0'));
  ConfigXML.Root.SetItemValue('PreProcess.DefaultSettings.DeleteNFO', iff(cbDelNFO.Checked, '1', '0'));
  ConfigXML.Root.SetItemValue('PreProcess.DefaultSettings.DeleteDIZ', iff(cbDelDIZ.Checked, '1', '0'));
  ConfigXML.Root.SetItemValue('PreProcess.DefaultSettings.DeleteSFV', iff(cbDelSFV.Checked, '1', '0'));
  ConfigXML.Root.SetItemValue('PreProcess.DefaultSettings.DeleteSourcePath', iff(cbDelSource.Checked, '1', '0'));
  MainForm.SaveConfig;
  MessageDlg('Settings saved as default.', mtInformation, [mbOK], 0);
end;

procedure TPreProcessForm.VListClick(Sender: TObject);
var
  Item: TPreProcessItem;
begin
  if Assigned(VList.FocusedNode) then
  begin
    Item := PreparingProducts[VList.FocusedNode.Index];
    if not (Item.Status in [ITEM_PROCESSING, ITEM_PROCESS_SUCCESS, ITEM_WAITING]) then
    begin
      case VList.FocusedColumn of
        3: Item.UnPack := not Item.UnPack;
        4: Item.UnPackISO := not Item.UnPackISO;
        5: Item.DelSourceDir := not Item.DelSourceDir;
      end;
      VList.InvalidateNode(VList.FocusedNode);
      cbUnPack.Checked := Item.UnPack;
      cbUnPackISO.Checked := Item.UnPackISO;
      cbDelSource.Checked := Item.DelSourceDir;
    end;
  end;
end;

procedure TPreProcessForm.VListCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  //EditLink.
end;

procedure TPreProcessForm.VListEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := true;
end;

procedure TPreProcessForm.VListFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  Item: TPreProcessItem;
  I: integer;
begin
  if Assigned(Node) then
  begin
    Loading := true;
    ProcessSelections;

    Item := PreparingProducts[Node.Index];
    eNewDirName.Text := Item.NewDirName;

    if Item.CategoryID <> -1 then
    begin
      for I := Low(Categories) to High(Categories) do
        if Categories[I].ID = Item.CategoryID then
        begin
          cbCategories.ItemIndex := I + 1;
          break;
        end;
    end
    else
      cbCategories.ItemIndex := 0;

    eTags.Text := Item.Tags;
    lNewPath.Caption := Item.NewDirPath;

    cbUnPack.Checked := Item.UnPack;
    cbUnPackISO.Checked := Item.UnPackISO;
    cbDelSource.Checked := Item.DelSourceDir;
    cbDelNFO.Checked := Item.DelNFO;
    cbDelDIZ.Checked := Item.DelDIZ;
    cbDelSFV.Checked := Item.DelSFV;

    lNewPath.Caption := 'New path: ' + Item.NewDirPath;

    Loading := false;

    SettingsPanel.Enabled := Item.Status <> ITEM_PROCESSING;


  end;
end;

procedure TPreProcessForm.VListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Item: TPreProcessItem;
begin
  Item := PreparingProducts[Node.Index];
  case Column of
    0:
    begin
      case Item.Status of
        ITEM_PASSIVE: ImageIndex := 1;
        ITEM_ACTIVE : ImageIndex := 2;
        ITEM_PROCESSING: ImageIndex := 15;
        ITEM_PROCESS_SUCCESS: ImageIndex := 13;
        ITEM_PROCESS_ERROR: ImageIndex := 11;
        ITEM_WAITING: ImageIndex := 19;
      end;
    end;
    3: ImageIndex := iff(Item.UnPack, 2, 1);
    4: ImageIndex := iff(Item.UnPackISO, 2, 1);
    5: ImageIndex := iff(Item.DelSourceDir, 2, 1);
  end;
end;

procedure TPreProcessForm.VListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Item: TPreProcessItem;
begin
  Item := PreparingProducts[Node.Index];
  case Column of
    0: CellText := Item.CategoryName;
    1: CellText := Item.NewDirName;
    2: CellText := Item.OldDirName;
    3..5: CellText := '';
    6: CellText := IcePack.ByteToString(Item.DirTreeSize);
  end;
end;

procedure TPreProcessForm.VListHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
  Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
  DropMark: TVTDropMarkMode);
var
  rr: TRect;
  T: string;
begin
  rr := R;
  HeaderCanvas.Brush.Color := $00D8D8D8;
  HeaderCanvas.FillRect(RR);

  HeaderCanvas.Pen.Color := $009D9D9D;
  HeaderCanvas.MoveTo(RR.Right - 1, RR.Top);
  HeaderCanvas.LineTo(RR.Right - 1, RR.Bottom - 1);
  HeaderCanvas.LineTo(RR.Left , RR.Bottom - 1);

  //DrawEdge(HeaderCanvas.Handle, R, BDR_RAISEDINNER, BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_ADJUST or BF_RIGHT);

  InflateRect(rr, -2, -2);
  T := Column.Text;
  HeaderCanvas.TextRect(rr, T, [tfEndEllipsis, tfCenter]);
end;

procedure TPreProcessForm.VListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (VList.SelectedCount > 0) then
  begin
    Deleteselecteditem1.Click;
  end;
end;

procedure TPreProcessForm.VListMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
  Item: TPreProcessItem;
  I: integer;
begin
  if X < 18 then
  begin
    Node := VList.GetNodeAt(X, Y);
    Item := PreparingProducts[Node.Index];
    case VList.FocusedColumn of
      0:
      begin
        Item.Status := iff(Item.Status = ITEM_PASSIVE, ITEM_ACTIVE, ITEM_PASSIVE);
        StatusChanged;
      end;
    end;
  end;
end;

end.




