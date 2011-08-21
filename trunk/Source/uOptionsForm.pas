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

unit uOptionsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Gradient, CheckLst;

type
  TOptionsForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    cbDelToRB: TCheckBox;
    cbHideDialogs: TCheckBox;
    GroupBox2: TGroupBox;
    cbCheckNewVersion: TCheckBox;
    bCheckUpdate: TLabel;
    Gradient1: TGradient;
    Gradient2: TGradient;
    GroupBox3: TGroupBox;
    lbExtensions: TCheckListBox;
    cbICS: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bCheckUpdateClick(Sender: TObject);
  private
    procedure LoadExtensions;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;

implementation

uses
  uPLuginClasses, uClasses, IceXML, IcePack, uProcs, uMain;

{$R *.dfm}

procedure TOptionsForm.bCheckUpdateClick(Sender: TObject);
begin
  CheckUpdate(false);
end;

procedure TOptionsForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TOptionsForm.btnOkClick(Sender: TObject);
var
  I: Integer;
  Item: TXMLItem;
begin
  for I := 0 to lbExtensions.Items.Count - 1 do
  begin
    TFileProcCallBackItem(lbExtensions.Items.Objects[I]).Status := lbExtensions.Checked[I];
    Item := ConfigXML.Root.GetItemEx('PluginFilters', true).FilterItemListFirst(Format('((extension="%s")and(plugin="%s"))', [TFileProcCallBackItem(lbExtensions.Items.Objects[I]).FilterType, ExtractFileName(TFileProcCallBackItem(lbExtensions.Items.Objects[I]).Plugin.FileName)]));
    if Assigned(Item) then
      Item.Attr['state'] := iff(lbExtensions.Checked[I], 1, 0);
  end;

  ConfigXML.Root.SetItemParamValue('Main.Settings', 'deleteToRecycleBin', cbDelToRB.Checked);
  ConfigXML.Root.SetItemParamValue('Main.Settings', 'hideFileDialogs', cbHideDialogs.Checked);
  ConfigXML.Root.SetItemParamValue('Main.Settings', 'ICS', cbICS.Checked);

  ConfigXML.Root.SetItemParamValue('Main.Update', 'checkAtStart', cbCheckNewVersion.Checked);

  ConfigXML.SaveToFile;
  MainForm.LoadVariablesFromConfig;

  Close;
end;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  LoadExtensions;

  cbDelToRB.Checked := ConfigXML.Root.GetItemParamValue('Main.Settings', 'deleteToRecycleBin', 'True') = 'True';
  cbHideDialogs.Checked := ConfigXML.Root.GetItemParamValue('Main.Settings', 'hideFileDialogs', 'True') = 'True';
  cbICS.Checked := ConfigXML.Root.GetItemParamValue('Main.Settings', 'ICS', 'True') = 'True';

  cbCheckNewVersion.Checked := ConfigXML.Root.GetItemParamValue('Main.Update', 'checkAtStart', 'True') = 'True';
end;

procedure TOptionsForm.LoadExtensions;
var
  I: integer;
  Item: TFileProcCallBackItem;
  S, filter, pluginName: string;
begin
  lbExtensions.Items.BeginUpdate;
  lbExtensions.Items.Clear;

  for I := 0 to FileProcCallBackList.Count - 1 do
  begin
    Item := TFileProcCallBackItem(FileProcCallBackList[I]);
    filter := Item.FilterType;
    pluginName := Item.Plugin.PluginInfo.Name;
    S := filter + ' - ' + pluginName;
    lbExtensions.AddItem(S, Item);
    lbExtensions.Checked[lbExtensions.Items.Count - 1] := Item.Status;
  end;

  lbExtensions.Items.EndUpdate;
end;

end.
