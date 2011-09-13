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

unit uPasswordForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TPasswordForm = class(TForm)
    ePass: TLabeledEdit;
    bOk: TButton;
    bCancel: TButton;
    procedure bOkClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PasswordForm: TPasswordForm;

function ShowPasswordDialog(DirName: string): string;

implementation

uses uMain, uClasses;

{$R *.dfm}

function ShowPasswordDialog(DirName: string): string;
begin
  UserPassword := '';
  PasswordForm := TPasswordForm.Create(MainForm);
  PasswordForm.Caption := Format('Password for %s', [DirName]);
  PasswordForm.ePass.Text := '';
{  if PasswordForm.ShowModal = mrOk then
    result := PasswordForm.ePass.Text
  else
    result := '';
  PasswordForm.Free;}
  PasswordForm.Show;
end;

procedure TPasswordForm.bCancelClick(Sender: TObject);
begin
  UserPassword := '';
  NeedPasswordEvent.SetEvent;
  Close;
end;

procedure TPasswordForm.bOkClick(Sender: TObject);
begin
  UserPassword := PasswordForm.ePass.Text;
  NeedPasswordEvent.SetEvent;
  Close;
end;

procedure TPasswordForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
