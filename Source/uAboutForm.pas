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
unit uAboutForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Gradient, uProcs, StdCtrls, pngimage, ExtCtrls, ComCtrls, ShellAPI,
  IcePack, RichEditURL;

type
  TAboutForm = class(TForm)
    Gradient1: TGradient;
    Image1: TImage;
    Label1: TLabel;
    lVersion: TLabel;
    Label3: TLabel;
    lHomePage: TLabel;
    bOK: TButton;
    mLicenses: TRichEditURL;
    lEmail: TLabel;
    bCheckUpdate: TLabel;
    Label2: TLabel;
    lGPL: TLabel;
    iDonate: TImage;
    procedure lHomePageClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure lEmailClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bCheckUpdateClick(Sender: TObject);
    procedure lGPLClick(Sender: TObject);
    procedure mLicensesURLClick(Sender: TObject; const URL: string);
    procedure iDonateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses
  uConstans, gnugettext;

{$R *.dfm}

procedure TAboutForm.bCheckUpdateClick(Sender: TObject);
begin
  CheckUpdate(false);
end;

procedure TAboutForm.bOKClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self, 'default');
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  lVersion.Caption := IcePack.GetFileVersion('', _('Version %d.%d.%d ( Build %d )'));
  mLicenses.Lines.Text := mLicenses.Lines.Text + ' '; //URL
end;

procedure TAboutForm.iDonateClick(Sender: TObject);
begin
  OpenURL('http://sourceforge.net/donate/index.php?group_id=534563');
end;

procedure TAboutForm.lEmailClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, nil, PChar('mailto:' + TLabel(Sender).Caption), nil, nil, SW_SHOW)
end;

procedure TAboutForm.lGPLClick(Sender: TObject);
begin
  OpenURL('http://www.gnu.org/licenses/gpl-3.0.html');
end;

procedure TAboutForm.lHomePageClick(Sender: TObject);
begin
  OpenURL(TLabel(Sender).Caption);
end;

procedure TAboutForm.mLicensesURLClick(Sender: TObject; const URL: string);
begin
  OpenURL(URL);
end;

end.
