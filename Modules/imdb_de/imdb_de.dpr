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

library imdb_de;



{$R *.dres}

uses
  Windows,
  SysUtils,
  Classes,
  Messages,
  Dialogs,
  IcePack,
  Graphics,
  SOPluginDefs in '..\..\Source\SOPluginDefs.pas' {$E sop},
  uSearchInfo in '..\imdb\uSearchInfo.pas';

{$E sop}

{$R *.res}

var
  RegisterDescriptor: TRegisterDescriptor;
  proc: Pointer;
  MainIcon: TIcon;

procedure PluginLoad(SelfObject: Pointer); stdcall;
begin
  Self := SelfObject;
  MainIcon := TIcon.Create;
  MainIcon.LoadFromResourceName(hInstance, 'MAIN_32');
end;

procedure PluginUnLoad(); stdcall;
begin
  //
end;

function PluginGetInfo(): PPluginInfo; stdcall;
begin
  New(result);
  result.Name := 'IMDb.de plugin';
  result.PluginType := 2;
  result.Description := 'Get movie description from IMDb.de';
  result.Icon := Pointer(MainIcon.Handle);
  result.Author := 'Ice Apps';
  result.WebPage := 'http://stufforganizer.sourceforge.net';
  result.Version := '1.0.0.0';
  result.InterfaceVersion := 1;
  result.VersionDate := '2011-10-18';
  result.MinimumVersion := '0.4.5.0';
end;

function PluginSetup(): boolean; stdcall;
begin
  result := true;
end;

function NormalizeMovieTitle(Title: string): string;
var
  S, SS: string;
  I: integer;
begin
  SS := Title;
  S := Trim(CutAt(SS, '('));;

  result := '';
  for I := 1 to Length(S) do
  begin
    if IsCharAlphaNumeric(S[I]) then
      result := result + S[I]
    else if (Length(result) > 0) and (result[Length(result) - 1] <> ' ') then
      result := result + ' ';
  end;
  result := Trim(result);
end;

procedure Run(ProductInfo: PPluginProductItem); stdcall;
var
  MovieName: string;
begin
  MovieName := NormalizeMovieTitle(ProductInfo.Name);
  if InputQuery('Search description', 'Enter title (only letters, digits and spaces): ', MovieName) then
  begin
    Product := ProductInfo;
    SearchMovie( StringReplace(URLEncode(MovieName, false), '%20', '+', [rfReplaceAll]) , 'de');
  end;
end;
procedure PluginRegDescriptorFunctions(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;
begin
  RegisterDescriptor := PluginCallBacks.RegisterDescriptor;
  SaveImageToDB := PluginCallBacks.SaveImageToDB;
  SaveProductInfoToDB := PluginCallBacks.SaveProductInfoToDB;
  UserSelect := PluginCallBacks.UserSelect;

  PluginCallBacks.RegisterDescriptor(Self, 'Search description on IMDb.de (Deutsch)', Run);
end;

function PluginInitialize(): boolean; stdcall;
begin
  result := true;

  LangTexts.Values['Director'] := 'Regie';
  LangTexts.Values['Writer'] := 'Buch';
  LangTexts.Values['Plot'] := 'Inhaltsangabe';
  LangTexts.Values['Cast'] := 'Besetzung';
  LangTexts.Values['Rating'] := 'Nutzer-Bewertung';
  LangTexts.Values['Genres'] := 'Genre';


  LangTexts.Values['_Length'] := 'L&#xE4;nge:';
  LangTexts.Values['_Genres'] := 'Genre:';
  LangTexts.Values['_Summary'] := 'Handlung:';

end;




exports
  PluginLoad,
  PluginUnLoad,
  PluginGetInfo,
  PluginSetup,
  PluginRegDescriptorFunctions,
  PluginInitialize;

begin

end.
