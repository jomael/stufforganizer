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

unit uNFOForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TNFOForm = class(TForm)
    mNFO: TMemo;
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

end.
