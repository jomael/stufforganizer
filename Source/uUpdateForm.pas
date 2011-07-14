unit uUpdateForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, Gradient, ExtCtrls, IcePack, IceXML,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, ImgList,
  PngImageList;

type
  PNodeData = ^TNodeData;
  TNodeData = record
    Module: string;
    Date: string;
    Version: string;
    XML: TXMLItem;
    WorkCount: Int64;
    WorkMax: Int64;
  end;

  TUpdateForm = class(TForm)
    Panel2: TPanel;
    Gradient2: TGradient;
    btnCancel: TButton;
    btnUpdate: TButton;
    GroupBox1: TGroupBox;
    DataList: TVirtualStringTree;
    Panel1: TPanel;
    Gradient1: TGradient;
    lMainCaption: TLabel;
    http: TIdHTTP;
    stateImages: TPngImageList;
    GroupBox2: TGroupBox;
    mChanges: TMemo;
    procedure DataListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure btnCancelClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure httpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure httpWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure DataListBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure DataListGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure DataListFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
  private
    { Private declarations }
  public
    { Public declarations }
    CurrentDownloadItem: PNodeData;
    Downloading: boolean;
  end;



var
  UpdateForm: TUpdateForm;

function ShowUpdateForm(Content: TList): boolean;

implementation

{$R *.dfm}

function GetReadableModuleName(name: string): string;
begin
  if name = 'MAIN' then
    Exit('Main module')
  else
    Exit(name);
end;

function ShowUpdateForm(Content: TList): boolean;
var
  I: Integer;
  Item: TXMLItem;
  Node: PVirtualNode;
  Data: PNodeData;
begin
  with UpdateForm do
  begin
    Downloading := false;
    btnUpdate.Enabled := true;

    DataList.BeginUpdate;
    DataList.Clear;
    DataList.NodeDataSize := SizeOf(TNodeData);

    for I := 0 to Content.Count - 1 do
    begin
      Item := TXMLItem(Content[I]);

      Node := DataList.AddChild(nil);
      Data := DataList.GetNodeData(Node);
      Data.Module := GetReadableModuleName(Item.Attr['name']);
      Data.Date := Item.GetItemValue('Date', '');
      Data.Version := Item.GetItemValue('Version', '');
      Data.XML := Item;
      Data.WorkCount := 0;
      Data.WorkMax := 0;
      Node.CheckType := ctCheckBox;
      Node.CheckState := csCheckedNormal;
    end;
    DataList.EndUpdate;
  end;
  result := UpdateForm.ShowModal = mrOk;
end;

procedure TUpdateForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TUpdateForm.btnUpdateClick(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PNodeData;
  UpdateDir: string;
  Files: TXMLItem;
  I: integer;
  FS: TFileStream;
begin
  if Downloading then Exit;

  btnUpdate.Enabled := false;
  Downloading := true;
  UpdateDir := ExecPath + 'Update\';
  ForceDirectories(UpdateDir);

  try
    Node := DataList.GetFirstChecked();
    while Assigned(Node) do
    begin
      Data := DataList.GetNodeData(Node);
      CurrentDownloadItem := Data;

      Files := Data.XML.GetItemEx('Files', true);
      for I := 0 to Files.Count - 1 do
      begin
        ForceDirectories(ExtractFilePath(UpdateDir + Files[I].Attr['name']));
        FS := TFileStream.Create(UpdateDir + Files[I].Attr['name'], fmCreate);
        HTTP.Get(Files[I].Text, FS);
        FS.Free;
      end;
      Node := DataList.GetNextChecked(Node);
    end;
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      MessageDlg('Download error: ' + E.Message, mtError, [mbOK], 0);
      ModalResult := mrCancel;
    end;
  end;
  CurrentDownloadItem := nil;
  Downloading := false;
  btnUpdate.Enabled := true;
end;

procedure TUpdateForm.DataListBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  Data: PNodeData;
  Percent: Extended;
  sBarRect: TRect;
begin
  if Column = 3 then
  begin
    Data := DataList.GetNodeData(Node);
    Percent := 0;
    if Data.WorkMax > 0 then
      Percent := Data.WorkCount / Data.WorkMax;

    TargetCanvas.Brush.Color := clBlue;
    TargetCanvas.Pen.Color := clBlack;
    TargetCanvas.Pen.Width := 1;

    sBarRect := Rect(ContentRect.Left, ContentRect.Top + 2, ContentRect.Left + Round((ContentRect.Right - ContentRect.Left) * Percent), ContentRect.Bottom - 2);
    TargetCanvas.FillRect(sBarRect);
  end;
end;

procedure TUpdateForm.DataListFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  Data: PNodeData;
begin
  Data := DataList.GetNodeData(Node);
  mChanges.Lines.Text := Data.XML.GetItemValue('Changes', '');
end;

procedure TUpdateForm.DataListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PNodeData;
begin
  Data := DataList.GetNodeData(Node);
  if (Column = 0) and (Data.WorkMax > 0) then
  begin
    if Data.WorkCount < Data.WorkMax then
      ImageIndex := 6
    else
      ImageIndex := 2
  end;
end;

procedure TUpdateForm.DataListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PNodeData;
begin
  Data := DataList.GetNodeData(Node);
  case Column of
    0: CellText := Data.Module;
    1: CellText := Data.Date;
    2: CellText := Data.Version;
    3: CellText := '';
  end;
end;

procedure TUpdateForm.httpWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if Assigned(CurrentDownloadItem) then
  begin
    CurrentDownloadItem.WorkCount := AWorkCount;
    DataList.Invalidate;
    Application.ProcessMessages;
  end;
end;

procedure TUpdateForm.httpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  if Assigned(CurrentDownloadItem) then
    CurrentDownloadItem.WorkMax := AWorkCountMax;
end;

end.
