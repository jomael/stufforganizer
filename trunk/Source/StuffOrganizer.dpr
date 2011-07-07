program StuffOrganizer;



{$R *.dres}

uses
  ExceptionLog,
  Forms,
  JclAppInst,
  uMain in 'uMain.pas' {MainForm},
  uPreprocessDirs in 'uPreprocessDirs.pas' {PreProcessForm},
  uCategories in 'uCategories.pas' {CategoriesForm},
  uPasswordForm in 'uPasswordForm.pas' {PasswordForm},
  uNFOForm in 'uNFOForm.pas' {NFOForm},
  uClasses in 'uClasses.pas',
  uConstans in 'uConstans.pas',
  uThreadProcessForm in 'uThreadProcessForm.pas' {ThreadProcessForm},
  uProcessThread in 'uProcessThread.pas',
  uOptionsForm in 'uOptionsForm.pas' {OptionsForm},
  uPluginClasses in 'uPluginClasses.pas',
  SOPluginDefs in 'SOPluginDefs.pas',
  uPluginsForm in 'uPluginsForm.pas' {PluginsForm},
  uUserSelectForm in 'uUserSelectForm.pas' {UserSelectForm},
  uProcs in 'uProcs.pas',
  uUpdateForm in 'uUpdateForm.pas' {UpdateForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Stuff Organizer';
  JclAppInst.JclAppInstances;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPreProcessForm, PreProcessForm);
  Application.CreateForm(TCategoriesForm, CategoriesForm);
  Application.CreateForm(TPasswordForm, PasswordForm);
  Application.CreateForm(TNFOForm, NFOForm);
  Application.CreateForm(TThreadProcessForm, ThreadProcessForm);
  Application.CreateForm(TOptionsForm, OptionsForm);
  Application.CreateForm(TPluginsForm, PluginsForm);
  Application.CreateForm(TUpdateForm, UpdateForm);
  //  Application.CreateForm(TUserSelectForm, UserSelectForm);
  Application.Run;
end.

