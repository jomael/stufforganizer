library port_hu;

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
  result.Name := 'PORT.HU plugin';
  result.PluginType := 2;
  result.Description := 'PORT.HU filmadatb�zis�b�l keresi ki a filmek adatait';
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
end;

procedure RunPort_Hu(ProductInfo: PPluginProductItem); stdcall;
var
  MovieName: string;
begin
  MovieName := NormalizeMovieTitle(ProductInfo.Name);
  if InputQuery('Search description', 'A keresend� film c�me:', MovieName) then
  begin
    Product := ProductInfo;
    MovieName := StringReplace(MovieName, '&', 'xxampxx', [rfReplaceAll, rfIgnoreCase]);
    MovieName := UrlEncode(MovieName, false);
    MovieName := StringReplace(MovieName, 'xxampxx', '%26', [rfReplaceAll, rfIgnoreCase]);
    AnalyzePage('http://www.port.hu/pls/ci/cinema.film_list?i_film_title=' + MovieName + '&i_city_id=3372&i_county_id=-1');

    //SaveProductInfoToDB(Self, ProcItem, ProductInfo);
  end;
end;

procedure PluginRegDescriptorFunctions(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;
begin
  RegisterDescriptor := PluginCallBacks.RegisterDescriptor;
  SaveImageToDB := PluginCallBacks.SaveImageToDB;
  SaveProductInfoToDB := PluginCallBacks.SaveProductInfoToDB;
  UserSelect := PluginCallBacks.UserSelect;

  PluginCallBacks.RegisterDescriptor(Self, 'Film le�r�s keres�s a Port.hu-n', RunPort_Hu);
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
