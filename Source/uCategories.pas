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

unit uCategories;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, DirectoryEdit, JvBaseDlg,
  JvBrowseFolder, JvDialogs, Gradient, ImgList, PngImageList, JvExStdCtrls,
  JvCombobox, JvListComb;

type
  TCategoriesForm = class(TForm)
    Panel1: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    eName: TLabeledEdit;
    Label1: TLabel;
    ePath: TDirectoryEdit;
    Label2: TLabel;
    JvBrowseForFolderDialog1: TJvBrowseForFolderDialog;
    shColor: TShape;
    Label3: TLabel;
    cbColor: TCheckBox;
    ColorDialog1: TColorDialog;
    Gradient1: TGradient;
    Label4: TLabel;
    cbIcons: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure ePathButtonClick(Sender: TObject);
    procedure shColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure cbIconsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CategoriesForm: TCategoriesForm;

implementation

{$R *.dfm}

uses IcePack, uMain;

procedure TCategoriesForm.btnOkClick(Sender: TObject);
begin
  if Trim(eName.Text) = '' then
  begin
    MessageDlg('Please enter a name!', mtWarning, [mbOK], 0);
    eName.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TCategoriesForm.cbIconsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  if Index < MainForm.ilCategories.Count then
  begin
    cbIcons.Brush.Color := cbIcons.Color;
    cbIcons.Canvas.FillRect(Rect);
    MainForm.ilCategories.Draw(cbIcons.Canvas, Rect.Left, Rect.Top, Index);
  end;
end;

procedure TCategoriesForm.ePathButtonClick(Sender: TObject);
begin
  if JvBrowseForFolderDialog1.Execute then
  begin
    ePath.Text := JvBrowseForFolderDialog1.Directory;
    if eName.Text = '' then
      eName.Text := ExtractFileName(ePath.Text);
  end;
end;

procedure TCategoriesForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  shColor.Brush.Color := clWhite;

  for I := cbIcons.Items.Count to MainForm.ilCategories.Count - 1 do
    cbIcons.Items.Add('');
end;

procedure TCategoriesForm.FormShow(Sender: TObject);
begin
  eName.SetFocus;
end;

procedure TCategoriesForm.shColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog1.Color := shColor.Brush.Color;
  if ColorDialog1.Execute(Application.Handle) then
  begin
    shColor.Brush.Color := ColorDialog1.Color;
    cbColor.Checked := true;
  end;
end;

end.
