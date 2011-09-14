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

library opensubtitles;

uses
  Windows,
  SysUtils,
  Classes,
  Messages,
  Dialogs,
  IcePack,
  SOPluginDefs in '..\..\Source\SOPluginDefs.pas',
  uSearchInfo in 'uSearchInfo.pas',
  uISO639 in 'uISO639.pas',
  uOSClient in 'uOSClient.pas';

{$E sop}

{$R *.res}

var
  RegisterDescriptor: TRegisterDescriptor;
  proc: Pointer;

procedure PluginLoad(SelfObject: Pointer); stdcall;
begin
  Self := SelfObject;
end;

procedure PluginUnLoad(); stdcall;
begin
  //
end;

function PluginGetInfo(): PPluginInfo; stdcall;
begin
  New(result);
  result.Name := 'OpenSubtitles.org plugin';
  result.PluginType := 2;
  result.Description := 'Get subtitles for movies from OpenSubtitles.org';
  result.Icon := nil;
  result.Author := 'Ice Apps';
  result.WebPage := 'http://stufforganizer.sourceforge.net';
  result.Version := '1.0.0.0';
  result.InterfaceVersion := 1;
  result.VersionDate := '2011-09-13';
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
  Product := ProductInfo;
  GetOpenSubtitlesForProduct(ProductInfo);
end;

procedure PluginRegDescriptorFunctions(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;
begin
  RegisterDescriptor := PluginCallBacks.RegisterDescriptor;
  SaveImageToDB := PluginCallBacks.SaveImageToDB;
  SaveProductInfoToDB := PluginCallBacks.SaveProductInfoToDB;
  UserSelect := PluginCallBacks.UserSelect;

  PluginCallBacks.RegisterDescriptor(Self, 'Search subtitles on OpenSubtitles.org', Run);
end;

function PluginInitialize(): boolean; stdcall;
begin
  result := true;
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
