unit uAboutForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Gradient, uProcs, StdCtrls, pngimage, ExtCtrls, ComCtrls, ShellAPI,
  IcePack;

type
  TAboutForm = class(TForm)
    Gradient1: TGradient;
    Image1: TImage;
    Label1: TLabel;
    lVersion: TLabel;
    Label3: TLabel;
    lHomePage: TLabel;
    bOK: TButton;
    RichEdit1: TRichEdit;
    lEmail: TLabel;
    bCheckUpdate: TLabel;
    Label2: TLabel;
    lGPL: TLabel;
    procedure lHomePageClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure lEmailClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bCheckUpdateClick(Sender: TObject);
    procedure lGPLClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.bCheckUpdateClick(Sender: TObject);
begin
  CheckUpdate(false);
end;

procedure TAboutForm.bOKClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  lVersion.Caption := IcePack.GetFileVersion('', 'Version %d.%d.%d ( Build %d )');
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

end.
