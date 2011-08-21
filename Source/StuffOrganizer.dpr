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

