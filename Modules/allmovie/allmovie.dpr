library allmovie;

uses
  Windows,
  SysUtils,
  Classes,
  sevenzip,
  Messages,
  Dialogs, IcePack,
  SOPluginDefs in '..\..\Source\SOPluginDefs.pas',
  uSearchInfo in 'uSearchInfo.pas';

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
  result.Name := 'Allmovie.com plugin';
  result.PluginType := 2;
  result.Description := 'All Movie Guide detailed info import with small picture';
  result.Icon := nil;
  result.Author := 'Ice Apps';
  result.WebPage := 'http://';
  result.Version := '1.0.0.0';
  result.InterfaceVersion := 1;
  result.VersionDate := '2010-04-16';
  result.MinimumVersion := '0.4.2.0';
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
    AnalyzePage('http://www.allmovie.com/search/work/' + StringReplace(URLEncode(MovieName, false), '%20', '+', [rfReplaceAll]));
  end;
end;

procedure PluginRegDescriptorFunctions(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;
begin
  RegisterDescriptor := PluginCallBacks.RegisterDescriptor;
  SaveImageToDB := PluginCallBacks.SaveImageToDB;
  SaveProductInfoToDB := PluginCallBacks.SaveProductInfoToDB;
  UserSelect := PluginCallBacks.UserSelect;

  PluginCallBacks.RegisterDescriptor(Self, 'Search description on www.allmovie.com', Run);
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
