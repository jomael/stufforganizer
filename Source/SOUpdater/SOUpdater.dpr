program SOUpdater;

uses
  Forms,
  uMain in 'uMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Stuff Organizer Updater';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
