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
unit uPluginsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ImgList, PngImageList, Gradient;

type
  TPluginsForm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Panel2: TPanel;
    Splitter1: TSplitter;
    btnOk: TButton;
    PluginList: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lDescr: TLabel;
    lName: TLabel;
    lVersion: TLabel;
    lAuthor: TLabel;
    lWeb: TLabel;
    pluginIcons: TPngImageList;
    Gradient1: TGradient;
    Gradient2: TGradient;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PluginListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PluginListClick(Sender: TObject);
    procedure lWebClick(Sender: TObject);
  {  procedure PluginListDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure PluginListCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);    }
  private
    procedure LoadPluginList;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PluginsForm: TPluginsForm;

implementation

{$R *.dfm}

uses
  uPluginClasses, ShellAPI;

procedure TPluginsForm.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TPluginsForm.LoadPluginList;
var
  I: Integer;
  Plugin: TPluginItem;
begin
  PluginList.Items.BeginUpdate;
  PluginList.Items.Clear;
  for I := 0 to PluginManager.Count - 1 do
  begin
    Plugin := PluginManager.Items[I];
    PluginList.AddItem(Plugin.PluginInfo.Name, Plugin);
  end;
  PluginList.Items.EndUpdate;
  if PluginList.Items.Count > 0 then
  begin
    PluginList.ItemIndex := 0;
    PluginListClick(PluginList);
  end;
end;
procedure TPluginsForm.lWebClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(lWeb.Caption), nil, nil, SW_SHOW)
end;

procedure TPluginsForm.PluginListClick(Sender: TObject);
var
  Plugin: TPluginItem;
begin
  if PluginList.ItemIndex <> -1 then
  begin
    Plugin := PluginManager.Items[PluginList.ItemIndex];
    lName.Caption := Plugin.PluginInfo.Name;
    lVersion.Caption := Plugin.PluginInfo.Version;
    lAuthor.Caption := Plugin.PluginInfo.Author;
    lWeb.Caption := Plugin.PluginInfo.WebPage;
    lDescr.Caption := Plugin.PluginInfo.Description;
  end;
end;

procedure TPluginsForm.PluginListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  Plugin: TPluginItem;
  Icon: TIcon;
  S: string;
  R: TRect;

  tw, th: integer;
begin
  if odSelected in State then
    PluginList.Canvas.Brush.Color := clHighlight
  else
    PluginList.Canvas.Brush.Color := PluginList.Color;
  PluginList.Canvas.FillRect(Rect);

  Plugin := TPluginItem(PluginList.Items.Objects[Index]);
  if not Assigned(Plugin.PluginInfo.Icon) then
  begin
    pluginIcons.Draw(PluginList.Canvas, Rect.Left + 2, Rect.Top + 5, 0);
//    PluginList.Canvas.Draw(Rect.Left + 2, Rect.Top + 5, Icon);

  end
  else
  begin
    Icon := TIcon.Create;
    Icon.Handle := HIcon(Plugin.PluginInfo.Icon);
    PluginList.Canvas.Draw(Rect.Left + 2, Rect.Top + 5, Icon);
  end;

  S := Plugin.PluginInfo.Name;
  th := PluginList.Canvas.TextHeight(S);
  PluginList.Canvas.Font.Style := [fsBold];
  PluginList.Canvas.TextOut(Rect.Left + 40, Rect.Top + 2, S);

  S := 'v' + string(Plugin.PluginInfo.Version);
  PluginList.Canvas.Font.Size := 7;
  PluginList.Canvas.Font.Style := [fsItalic];
  PluginList.Canvas.TextOut(Rect.Left + 40, Rect.Top + th + 2, S);

  S := Plugin.PluginInfo.Description;
  PluginList.Canvas.Font.Size := PluginList.Font.Size;
  PluginList.Canvas.Font.Style := [];
  R := Classes.Rect(Rect.Left + 40, Rect.Top + th * 2, Rect.Right, Rect.Bottom);
  PluginList.Canvas.TextRect(R, S, [tfEndEllipsis, tfSingleLine]);

  if odSelected in State then
    PluginList.Canvas.FrameRect(Rect);
end;

{
procedure TPluginsForm.PluginListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Plugin: TPluginItem;
  Icon: TIcon;
  R: TRect;
  Text: string;
begin
  R := Item.DisplayRect(drIcon);
  Plugin := TPluginItem(Item.Data);
  Icon := TIcon.Create;
  Icon.Handle := HIcon(Plugin.PluginInfo.Icon);
  Sender.Canvas.Draw(R.Left, R.Top, Icon);
  DefaultDraw := false;

  R := Item.DisplayRect(drLabel);
  Text := Plugin.PluginInfo.Name;
  Sender.Canvas.TextRect(R, Text);
end;

procedure TPluginsForm.PluginListDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  Plugin: TPluginItem;
  Icon: TIcon;
begin
  Plugin := TPluginItem(Item.Data);
  Icon := TIcon.Create;
  Icon.Handle := HIcon(Plugin.PluginInfo.Icon);
  Sender.Canvas.Draw(Rect.Left + 2, Rect.Top + 2, Icon);
end;   }

procedure TPluginsForm.FormShow(Sender: TObject);
begin
  LoadPluginList;
end;

end.
