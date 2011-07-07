unit uUpdateForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, Gradient, ExtCtrls, IcePack, IceXML;

type
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
    lElapsedTime: TLabel;
    lEstimatedTime: TLabel;
    lCurrVersion: TLabel;
    lNewVersion: TLabel;
    procedure DataListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  PNodeData = ^TNodeData;
  TNodeData = record
    Module: string;
    Date: string;
    Version: string;
    XML: TXMLItem;
  end;

var
  UpdateForm: TUpdateForm;

function ShowUpdateForm(Content: TXMLItem): TList;

implementation

{$R *.dfm}

function GetReadableModuleName(name: string): string;
begin
  if name = 'MAIN' then
    Exit('Main module');
end;

function ShowUpdateForm(Content: TXMLItem): TList;
var
  I: Integer;
  Item: TXMLItem;
  Node: PVirtualNode;
  Data: PNodeData;
begin
  with UpdateForm do
  begin
    DataList.BeginUpdate;
    DataList.Clear;
    DataList.NodeDataSize := SizeOf(TNodeData);

    for I := 0 to Content.Count - 1 do
    begin
      Item := Content[I];

      Node := DataList.AddChild(nil);
      Data := DataList.GetNodeData(Node);
      Data.Module := GetReadableModuleName(Item.Attr['name']);
      Data.Date := Item.Attr['date'];
      Data.Version := Item.GetItemValue('Version', '');
      Data.XML := Item;
    end;
    DataList.EndUpdate;
  end;
  UpdateForm.ShowModal;
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
  end;
end;

end.
