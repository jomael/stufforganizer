unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StepList, IcePack, ExtCtrls, ShellAPI;

type
  TMainForm = class(TForm)
    StepList1: TStepList;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    procedure SOUpdate;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.SOUpdate;
var
  PrgPath, UpdPath: string;
  Files: TStrings;
  I: Integer;
  RelPath: string;
begin
  //System check
  StepList1.CurrentStep := 1;
  PrgPath := ParamStr(1);
  UpdPath := PrgPath + 'Update\';
  if not DirectoryExists(PrgPath) then
  begin
    StepList1.CurrentStepState(ssFailed);
    MessageDlg('Directory not found: ' + PrgPath, mtWarning, [mbOK], 0);
    Exit;
  end;
  if not DirectoryExists(UpdPath) then
  begin
    StepList1.CurrentStepState(ssFailed);
    MessageDlg('Directory not found: ' + UpdPath, mtWarning, [mbOK], 0);
    Exit;
  end;
  Files := IcePack.GetFiles(UpdPath, '*.*', true);
  if Files.Count = 0 then
  begin
    StepList1.CurrentStepState(ssFailed);
    MessageDlg('No update files!', mtWarning, [mbOK], 0);
    Exit;
  end;
  StepList1.CurrentStepState(ssPassed);

  //Wait for SO exit
  StepList1.CurrentStep := 2;
  while IcePack.IsRunProcess('stufforganizer.exe') and (not Application.Terminated) do
  begin
    Delay(100);
    Application.ProcessMessages;
  end;
  if Application.Terminated then Exit;
  StepList1.CurrentStepState(ssPassed);

  //Copy files
  StepList1.CurrentStep := 3;
  for I := 0 to Files.Count - 1 do
  begin
    RelPath := ExtractRelativePath(UpdPath, Files[I]);
    CopyFile(PWideChar(Files[I]), PWideChar(PrgPath + RelPath), false);
  end;
  StepList1.CurrentStepState(ssPassed);


  //Delete temporary files
  StepList1.CurrentStep := 4;
  IcePack.DelTree(UpdPath, false, false);
  StepList1.CurrentStepState(ssPassed);

  //Start SO
  StepList1.CurrentStep := 5;
  if not FileExists(PrgPath + 'StuffOrganizer.exe') then
  begin
    StepList1.CurrentStepState(ssFailed);
    MessageDlg('StuffOrganizer.exe not found!', mtWarning, [mbOK], 0);
    Exit;
  end;
  ShellExecute(0, 'open', PWideChar(PrgPath + 'StuffOrganizer.exe'), '', PWideChar(PrgPath), SW_SHOW) ;
  StepList1.CurrentStepState(ssPassed);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;

  SOUpdate;
  Delay(1000);
  Application.Terminate;
end;

end.
