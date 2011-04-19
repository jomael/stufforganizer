unit uUserSelectForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Gradient, VirtualTrees, ExtCtrls, SOPluginDefs;

type
  TUserSelectForm = class(TForm)
    Panel1: TPanel;
    DataList: TVirtualStringTree;
    Gradient2: TGradient;
    btnOk: TButton;
    btnCancel: TButton;
    procedure DataListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure DataListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Items: TDescriptorProductInfoArray;
  end;

var
  UserSelectForm: TUserSelectForm = nil;


function UserSelectList(ItemList: PTDescriptorProductInfoArray): integer;


implementation

{$R *.dfm}

uses
  uMain;

function UserSelectList(ItemList: PTDescriptorProductInfoArray): integer;
var
  mrResult: integer;
begin
  if not Assigned(UserSelectForm) then
    UserSelectForm := TUserSelectForm.Create(MainForm);

  UserSelectForm.Items := ItemList^;
  UserSelectForm.DataList.RootNodeCount := Length(UserSelectForm.Items);
  mrResult := UserSelectForm.ShowModal();
  if (mrResult = mrOk) and Assigned(UserSelectForm.DataList.FocusedNode) then
    result := UserSelectForm.DataList.FocusedNode.Index
  else
    result := -1;

  FreeAndNil(UserSelectForm);
end;

procedure TUserSelectForm.DataListDblClick(Sender: TObject);
begin
  if Assigned(DataList.FocusedNode) then
    btnOk.Click;
end;

procedure TUserSelectForm.DataListGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := string(Items[Node.Index].Name);
end;

end.
