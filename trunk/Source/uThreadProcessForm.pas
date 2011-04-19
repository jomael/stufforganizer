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

unit uThreadProcessForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, VirtualTrees, uConstans, Gradient;

type
  TThreadProcessForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lMainCaption: TLabel;
    pBar: TProgressBar;
    lElapsedTime: TLabel;
    lEstimatedTime: TLabel;
    GroupBox1: TGroupBox;
    LogList: TVirtualStringTree;
    btnHide: TButton;
    btnPause: TButton;
    TimeTimer: TTimer;
    btnStop: TButton;
    Gradient1: TGradient;
    Gradient2: TGradient;
    cbPriority: TComboBox;
    Label1: TLabel;
    procedure LogListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure btnHideClick(Sender: TObject);
    procedure LogListGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure LogListBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure TimeTimerTimer(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStopClick(Sender: TObject);
    procedure cbPriorityChange(Sender: TObject);
  private
    FEventList: TList;

    procedure GetEvents;
    { Private declarations }
  protected
    procedure ThreadEventNotify( var msg : TMessage ); message WM_THREADNOTIFY;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    StartTime: TDateTime;
    ElapsedBytes: Int64;
    FullTreeSize: Int64;

    procedure Clear;
    procedure Start(ItemCount: integer; FullTreeSize: Int64);
    procedure AddNewItems(ItemCount: integer; FullTreeSize: Int64);

    procedure ProcessStopping;
    procedure ThreadFinished;
  end;

var
  ThreadProcessForm: TThreadProcessForm;

implementation

uses
  uMain, uProcessThread, uClasses, IcePack, DateUtils, uPasswordForm,
  uPreprocessDirs, uProgress, W7TaskBar;

{$R *.dfm}

{ TThreadProcessForm }

procedure TThreadProcessForm.btnHideClick(Sender: TObject);
begin
  Close;
end;

procedure TThreadProcessForm.btnPauseClick(Sender: TObject);
begin
  if ProcThread.Suspended then
  begin
    ProcThread.Resume;
    btnPause.Caption := 'Pause';
    SetProgressState(tbpsPaused);
  end
  else
  begin
    ProcThread.Suspend;
    btnPause.Caption := 'Resume';
    SetProgressState(tbpsNormal);
  end;
end;

procedure TThreadProcessForm.btnStopClick(Sender: TObject);
begin
  if (MessageDlg('Are you sure stop the processing?', mtWarning, [mbYes, mbCancel], 0) = mrYes) then
  begin
    ProcessStopping;
  end;
end;

procedure TThreadProcessForm.cbPriorityChange(Sender: TObject);
var
  newPriority: TThreadPriority;
begin
  if NowProcessing and Assigned(ProcThread) then
  begin
    newPriority := ProcThread.Priority;
    case cbPriority.ItemIndex of
      0: newPriority := tpLowest;
      1: newPriority := tpLower;
      2: newPriority := tpNormal;
      3: newPriority := tpHigher;
      4: newPriority := tpHighest;
    end;
    if ProcThread.Priority <> newPriority then
      ProcThread.Priority := newPriority;
  end;
end;

procedure TThreadProcessForm.ProcessStopping;
begin
  if not Showing then //Ha a fõszálból hívódik meg
    Show;
  btnStop.Visible := false;
  btnPause.Enabled := false;
  if ProcThread.Suspended then
    ProcThread.Resume;
  ProcThread.Terminate;
  ShowProgressDialog('Waiting for thread terminate...', 'Please wait');
end;

procedure TThreadProcessForm.Clear;
begin
  LogList.RootNodeCount := 0;
  LogList.NodeDataSize := sizeOf(TThreadEvent);
  lMainCaption.Caption := '';
  lElapsedTime.Caption := '';
  lEstimatedTime.Caption := '';
  pBar.Position := 0;
  btnPause.Caption := 'Pause';
  btnPause.Enabled := true;
  btnHide.Enabled := true;
  btnHide.Caption := 'Hide';
  Caption := 'Processing';
end;

procedure TThreadProcessForm.Start(ItemCount: integer; FullTreeSize: Int64);
begin
  cbPriority.ItemIndex := 2;
  pBar.Max := ItemCount;
  ElapsedBytes := 0;
  Self.FullTreeSize := FullTreeSize;
  StartTime := Now;
  TimeTimer.Enabled := true;
  NowProcessing := true;
  MainForm.aViewProcessLog.Enabled := true;
  btnStop.Visible := true;

  SetProgressState(tbpsNormal);
  SetProgressValue(0, pBar.Max);
end;

procedure TThreadProcessForm.AddNewItems(ItemCount: integer; FullTreeSize: Int64);
begin
  pBar.Max := pBar.Max + ItemCount;
  Self.FullTreeSize := Self.FullTreeSize + FullTreeSize;
end;

procedure TThreadProcessForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle OR WS_EX_APPWINDOW;
end;

procedure TThreadProcessForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if PreparingProducts.Count > 0 then
  begin
    if PreProcessForm.Showing then
    begin
      PreProcessForm.LoadItems;
      PreProcessForm.BringToFront;
    end
    else
      PreProcessForm.Show;
  end
  else
  begin
    PreProcessForm.Hide;
    if Mainform.Showing then
      MainForm.BringToFront;
  end;
end;

procedure TThreadProcessForm.ThreadEventNotify(var msg: TMessage);
begin
  GetEvents;
  msg.Result := 1;
end;

procedure TThreadProcessForm.GetEvents;

  function GetProductNode(Item: TPreProcessItem): PVirtualNode;
  var
    Node: PVirtualNode;
    Data: PThreadEvent;
  begin
    result := nil;
    Node := LogList.GetFirst();
    while Assigned(Node) do
    begin
      Data := LogList.GetNodeData(Node);
      if Data.Item = Item then
      begin
        result := Node;
        break;
      end;

      Node := LogList.GetNextSibling(Node);
    end;
    if not Assigned(Node) then
    begin
      Node := LogList.AddChild(nil);
      Data := LogList.GetNodeData(Node);
      Data.Item := Item;
      Data.StatusCode := 0;
      Data.StatusText := Item.NewDirName;
      Data.Progress := 0;
      LogList.FullExpand(Node);
      result := Node;

      lMainCaption.Caption := Format('Processing %s...', [Item.NewDirName]);
    end;
  end;

var
  AList: TList;
  I: Integer;
  Event: PThreadEvent;
  Node, LastNode: PVirtualNode;
  Data, LastData: PThreadEvent;
  ProductNode: PVirtualNode;
begin
  LogList.BeginUpdate;
  AList := ProcThread.GetEvents;
  for I := 0 to AList.Count - 1 do
  begin
    Event := PThreadEvent(AList[I]);
    ProductNode := GetProductNode(Event.Item);
    LastNode := LogList.GetLast(ProductNode);
    if Assigned(LastNode) then
    begin
      LastData := LogList.GetNodeData(LastNode);
      if (LastData.StatusCode = Event.StatusCode) and (LastData.Progress <= Event.Progress) and (LastData.Progress < 100) and (Event.StatusCode <> STATUS_NEED_PASSWORD)  then
      begin
        LastData.Progress := Event.Progress;
        if Event.StatusText <> '' then
          LastData.StatusText := Event.StatusText;
        continue;
      end
      else if LastData.Progress <> 100 then
        LastData.Progress := 100;

    end;

    if Event.StatusText <> '' then
    begin
      Node := LogList.AddChild(ProductNode);
      Data := LogList.GetNodeData(Node);
      Data.Item := Event.Item;
      Data.StatusCode := Event.StatusCode;
      Data.StatusText := Event.StatusText;
      Data.Progress := Event.Progress;
      LogList.FocusedNode := LogList.GetLast(ProductNode);
      //LogList.TopNode := LogList.FocusedNode;
    end;
    if Event.StatusCode = STATUS_FINISHED then
    begin
      Data := LogList.GetNodeData(ProductNode);
      Data.StatusCode := STATUS_FINISHED;
      Data.Progress := 100;
      LogList.FullCollapse(ProductNode);
      pBar.Position := pBar.Position + 1;
      SetProgressValue(pBar.Position, pBar.Max);
      LogList.FocusedNode := ProductNode;

      ElapsedBytes := ElapsedBytes + Data.Item.DirTreeSize;
    end
    else
      LogList.FullExpand(ProductNode);

    if Event.StatusCode = STATUS_NEED_PASSWORD then
    begin
      UserPassword := ShowPasswordDialog(Data.Item.NewDirName);
    end;
  end;
  LogList.EndUpdate;
  LogList.Invalidate;
  LogList.TopNode := LogList.FocusedNode;

  AList.Free;
end;

procedure TThreadProcessForm.LogListBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  Data: PThreadEvent;
  value, width: integer;
  R: TRect;
begin
  if (Column = 1) and (Node.ChildCount = 0) then
  begin
    Data := LogList.GetNodeData(Node);
    if Data.Progress > 100 then
      value := 100
    else
      value := Data.Progress;

    //Paint custom progressbar
    R := ContentRect;
    InflateRect(R, -6, -3);

    TargetCanvas.Brush.Color := clWhite;
    TargetCanvas.Pen.Color := clBlack;
    TargetCanvas.Pen.Width := 1;
    TargetCanvas.Rectangle(R);

    width := Round( (R.Right - R.Left) * (value/100) );
    TargetCanvas.Brush.Color := $00E9C09E;
    //TargetCanvas.Pen.Color := clBlue;
    TargetCanvas.Pen.Width := 0;
    //InflateRect(R, -1, -1);
    TargetCanvas.Rectangle(R.Left, R.Top, R.Left + width, R.Bottom);
  end;
end;

procedure TThreadProcessForm.LogListGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PThreadEvent;
begin
  if Column = 0 then
  begin
    Data := LogList.GetNodeData(Node);
    case Data.StatusCode of
      STATUS_NONE                 : ImageIndex := 15;

      STATUS_UNPACK               : ImageIndex := 10;
      STATUS_COPYDIR              : ImageIndex := 16;
      STATUS_COPYFILE             : ImageIndex := 16;
      STATUS_EXTRACTISO           : ImageIndex := 10;
      STATUS_MOVEDIR              : ImageIndex := 16;
      STATUS_MOVEFILE             : ImageIndex := 16;
      STATUS_DELETEDIR            : ImageIndex := 14;
      STATUS_DELETEFILE           : ImageIndex := 14;
      STATUS_DELETE_SOURCE        : ImageIndex := 14;
      STATUS_PROCESS_NFO          : ImageIndex := 15;
      STATUS_SAVEDB               : ImageIndex := 9;
      STATUS_SEARCH_ARCHIVE       : ImageIndex := 12;
      STATUS_NEED_PASSWORD        : ImageIndex := 17;
      STATUS_FINISHED             : ImageIndex := 13;

      STATUS_ERROR                : ImageIndex := 11;
    end;
  end;
end;

procedure TThreadProcessForm.LogListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PThreadEvent;
begin
  Data := LogList.GetNodeData(Node);
  case Column of
    0: CellText := Data.StatusText;
    1: CellText := '';//IntToStr(Data.Progress);
  end;
end;

procedure TThreadProcessForm.ThreadFinished;
var
  I: Integer;
begin
  SetProgressState(tbpsNone);

  TimeTimer.Enabled := false;
  pBar.Position := pBar.Max;
  lMainCaption.Caption := 'Finished';
  lElapsedTime.Caption := '';
  lEstimatedTime.Caption := '';
  btnPause.Enabled := false;
  btnHide.Caption := 'Close';

  for I := PreparingProducts.Count - 1 downto 0 do
  begin
    if PreparingProducts[I].Status = ITEM_PROCESS_SUCCESS then
      PreparingProducts.Delete(I)
    else if PreparingProducts[I].Status in [ITEM_PROCESSING, ITEM_WAITING] then
      PreparingProducts[I].Status := ITEM_ACTIVE;
  end;
  PreProcessForm.RefreshList;
  MainForm.RefreshQueueItemCount;
  //Close;
  MainForm.LoadProductsFromDB(true);
  //MainForm.BringToFront;
  NowProcessing := false;
  MainForm.aViewProcessLog.Enabled := false;
  btnStop.Visible := false;
  CloseProgressDialog;

  Caption := 'Finished';

  if ApplicationTerminating then //Ha fõformon kezdeményezték a leállítást
    Application.Terminate;
end;

procedure TThreadProcessForm.TimeTimerTimer(Sender: TObject);
var
  elapsedSec, estimatedSec: integer;

begin
  elapsedSec := SecondsBetween(StartTime, Now);
  lElapsedTime.Caption := Format('Elapsed time: %s', [SecondsToTimeString(elapsedSec)]);

  //calc estimated time from processed bytes
  if (ElapsedBytes > 0) and (FullTreeSize > 0)  then
  begin
    estimatedSec := Round(((FullTreeSize - ElapsedBytes) / ElapsedBytes) * elapsedSec);
    lEstimatedTime.Caption := Format('Estimated time: %s', [SecondsToTimeString(estimatedSec)]);
  end
  else
    lEstimatedTime.Caption := ' - ';
end;

end.
