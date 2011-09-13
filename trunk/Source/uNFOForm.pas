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

unit uNFOForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TNFOForm = class(TForm)
    mNFO: TMemo;
    FontDialog1: TFontDialog;
    procedure mNFOKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NFOForm: TNFOForm;

procedure ShowNFOContent(Data: string);

implementation

{$R *.dfm}

procedure ShowNFOContent(Data: string);
begin
  NFOForm.Height := Round(Screen.DesktopHeight * 0.8);
  NFOForm.mNFO.Lines.Text := Trim(Data);
  if not NFOForm.Showing then
    NFOForm.Show
  else
    NFOForm.BringToFront;
end;

procedure TNFOForm.mNFOKeyPress(Sender: TObject; var Key: Char);
begin
{  if Key = 'c' then
  begin
    FontDialog1.Font.Assign(mNFO.Font);
    if FontDialog1.Execute then
      mNFO.Font.Assign(FontDialog1.Font);
  end;}
end;

end.
