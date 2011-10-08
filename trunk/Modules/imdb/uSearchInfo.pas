unit uSearchInfo;

interface

uses
  Classes, SysUtils, Windows, Messages, Dialogs, SOPluginDefs, IcePack,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils, PerlRegEx;


var
  Self: Pointer;
  Product: PPluginProductItem;
  SaveImageToDB: TDescriptorSaveImage;
  SaveProductInfoToDB: TDescriptorSaveProductInfo;
  UserSelect: TDescriptorUserSelect;

  MovieName: string;
  RefererPage: string = '';

  foundItems: TDescriptorProductInfoArray;

procedure SearchMovie(MovieTitle: string);
procedure AnalyzePage(URL: string);

function GetPage(Address: string): string;
procedure GetImage(Address: string; FileName: string);

function UserSelectFromList: integer;
procedure FreeFoundItems;

function XMLToStr(XML: string): string;
function GenerateAutoTags(Name: string): string;

function Padding(Str: string; Count: integer): string;

implementation

function UserSelectFromList: integer;
begin
  result := UserSelect(Self, @foundItems);
end;

procedure FreeFoundItems;
var
  I: Integer;
begin
  for I := Low(foundItems) to High(foundItems) do
  begin
    StrDispose(foundItems[I].Name);
    StrDispose(foundItems[I].URL);
    StrDispose(foundItems[I].Description);
  end;

  SetLength(foundItems, 0);
end;

function Padding(Str: string; Count: integer): string;
var
  I: Integer;
begin
  result := Copy(Str, 1, Count);
  for I := Length(result) to Count do
    result := result + ' ';
end;

function GetPage(Address: string): string;
var
  http: TIdHTTP;
begin
  result := '';
  http := TIdHTTP.Create(nil);
  http.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16';
  http.Request.Referer := RefererPage;
  try
    result := http.Get(Address);
  finally
    http.Disconnect;
    http.Free;
  end;
end;

procedure GetImage(Address: string; FileName: string);
var
  http: TIdHTTP;
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  http := TIdHTTP.Create(nil);
  http.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16';
  try
    http.Get(Address, fs);
  finally
    http.Disconnect;
    http.Free;
    fs.Free;
  end;
end;

procedure SearchMovie(MovieTitle: string);
var
  content: string;
  regexp: TPerlRegEx;
  imdbID, title, MovieAddress: string;
  resList: TStringList;
  Item: TDescriptorProductInfo;
  SelectedIndex: integer;
  url: string;
  s: string;
begin
  url := 'http://www.imdb.com/find?q=' + MovieTitle;
  content := GetPage(url);
  RefererPage := url;

  regexp := TPerlRegEx.Create;
  regexp.RegEx := 'href="/title/tt(\d{7})/"[^>]*>(.*?)</a>\s*(\((\d{4})(/.+?|)\)|)[^<]*(<small>(.*?)</small>|)';
  regexp.Subject := content;
  resList := TStringList.Create;
  SetLength(foundItems, 0);
  while regexp.MatchAgain do
  begin
    if regexp.GroupCount > 4 then
    begin
      if Pos('<img', regexp.Groups[2]) = 0 then
      begin
        imdbID := regexp.Groups[1];
        if resList.IndexOf(imdbID) = -1 then
        begin
          s := regexp.Groups[2] + ' ' + regexp.Groups[4];
          title := XMLToStr(s);
          MovieAddress := 'http://www.imdb.com/title/tt' + imdbID + '/';
          resList.Add(imdbID);

          Item.Name := StrNew(PWideChar(title));
          Item.URL := StrNew(PWideChar(MovieAddress));
          Item.Description := nil;
          Item.Image := nil;

          SetLength(foundItems, Length(foundItems) + 1);
          foundItems[Length(foundItems) - 1] := Item;
        end;

      end;
    end;
  end;
  resList.Free;

  if Length(foundItems) > 0 then
  begin
    SelectedIndex := UserSelectFromList;
    if SelectedIndex <> -1 then
    begin
      MovieAddress := foundItems[SelectedIndex].URL;
      AnalyzePage(MovieAddress);

      FreeFoundItems;
    end;
  end
  else
    ShowMessage('Sorry, movie not found!');

//  regexp.Free;
end;

procedure AnalyzePage(URL: string);
var
  content, s: string;
  regexp: TPerlRegEx;
  title, origtitle, year, description, length, genres, rating, storyline, cast: string;
  stars, director, writer: string;
  Descr: TStringBuilder;
  Tags, sTitle: string;
  imageURL, tempFile: string;
begin
  content := GetPage(URL);
  content := StringReplace(content, #13, '', [rfReplaceAll]);
  content := StringReplace(content, #10, '', [rfReplaceAll]);
  if content <> '' then
  begin
    regexp := TPerlRegEx.Create;
    regexp.Subject := content;
    regexp.Options := [preCaseLess, preMultiLine];
    regexp.RegEx := '<h1.+?>\s*(.*?)\s*<';
    if regexp.Match and (regexp.GroupCount > 0)then
      title := Trim(regexp.Groups[1]);

    regexp.Start := 0;
    regexp.RegEx := '<a href="/year/.+?>(.*?)</a';
    if regexp.Match and (regexp.GroupCount > 0)then
      year := regexp.Groups[1];

    regexp.Start := 0;
    regexp.RegEx := 'title-extra">\s*?(.*?)\s*?<i>\(original';
    if regexp.Match and (regexp.GroupCount > 0)then
      origtitle := Trim(regexp.Groups[1]);

    regexp.Start := 0;
    regexp.RegEx := 'Runtime:</h4>\s*<time.*">(.*)\s*</time';
    if regexp.Match and (regexp.GroupCount > 0)then
      length := Trim(regexp.Groups[1]);

    genres := '';
    regexp.Start := 0;
    regexp.RegEx := '<a href\="/keyword/[\w\-]+">(.*?)</a>';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 0 then
      begin
        if genres <> '' then
          genres := genres + ', ';
        genres := genres + Trim(regexp.Groups[1]);
      end;
    end;

    regexp.Start := 0;
    regexp.RegEx := '<span itemprop="ratingValue">(\d{1,2}\.\d)';
    if regexp.Match and (regexp.GroupCount > 0)then
      rating := regexp.Groups[1];

    regexp.Start := 0;
    regexp.RegEx := '<p itemprop="description">\s*(.*?)\s*</p>';
    if regexp.Match and (regexp.GroupCount > 0)then
      description := regexp.Groups[1];

    regexp.Start := 0;
    regexp.RegEx := 'Storyline</h2>\s*\<p>\s*(.*?)\s*<em';
    if regexp.Match and (regexp.GroupCount > 0)then
      storyline := regexp.Groups[1];

    stars := '';
    regexp.Start := 0;
    regexp.RegEx := 'itemprop="actors"\s+>(.+?)<';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 0 then
      begin
        if stars <> '' then
          stars := stars + ', ';
        stars := stars + Trim(regexp.Groups[1]);
      end;
    end;

  {  regexp.Start := 0;
    regexp.RegEx := '<h5>(.*?)</h5>\s+<div\s+(.*?)\s+.*(<a.*?>(.*?)</a.*)\s+</div>';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 3 then
      begin
        if Pos('Director', Trim(regexp.Groups[1])) = 1 then
          director := Trim(regexp.Groups[4])
        else if Pos('Writer', Trim(regexp.Groups[1])) = 1 then
          writer := Trim(regexp.Groups[4])
      end;
    end;    }

{    CutAt(content, '<h2>Cast</h2>');
    s := CutAt(content, '<h2>Storyline</h2>');
    IcePack.WriteToFileS('c:\text.txt', s);
    cast := '';
    regexp.Subject := s;
    regexp.Start := 0;
    regexp.RegEx := 'name/nm\d+/"\s*>(.*?)<(\s*.*?)+?/character/ch\d+/">(.*?)<';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 2 then
      begin
        cast := cast + Padding(Trim(regexp.Groups[1]), 50) + ' ... ' + Trim(regexp.Groups[3]) + #13#10;
      end;
    end;               }

    regexp.Start := 0;
    regexp.RegEx := 'title-overview/primary.*?><img src="(.*?)"';
    if regexp.Match and (regexp.GroupCount > 0)then
      imageURL := regexp.Groups[1];

    Descr := TStringBuilder.Create;
    Descr.AppendFormat('%s - Rating: %s - Genres: %s', [length, rating, genres]).AppendLine.AppendLine;

    Descr.Append(Description).AppendLine.AppendLine;
//    Descr.Append('Director: ' + Director).AppendLine;
//    Descr.Append('Writer: ' + Director).AppendLine;
    Descr.Append('Stars: ' + stars).AppendLine;

  sTitle := XMLToStr(title + ' (' + year + ')');
  Product.Name := PWideChar(sTitle);
  Product.Description := PWideChar(Descr.ToString);
  Product.URL := PWideChar(URL);
  Product.Modified := true;
  Descr.Free;

  Tags := GenerateAutoTags(Product.Name);
  Product.Tags := PWideChar(Tags);
  //Save new product info
  SaveProductInfoToDB(Self, Product);

  //picture
  if System.Length(imageURL) > 0 then
  begin
    tempFile := IncludeTrailingBackslash(IcePack.GetTempDirectory) + ExtractUrlFileName(imageURL);
    tempFile := CutAt(tempFile, '?');
    if FileExists(tempFile) then
      DeleteFile(PWideChar(tempFile));
    GetImage(imageURL, tempFile);

    SaveImageToDB(Self, Product, PWideChar(tempFile));
    DeleteFile(PWideChar(tempFile));
  end;

  end;
end;

function GenerateAutoTags(Name: string): string;
var
  s, t, tags: string;
  I: Integer;
begin
  tags := '';
  S := LowerCase(Trim(Name));

  t := '';
  for I := 1 to Length(S) do
  begin
    if IsCharAlphaNumeric(S[I]) then
      t := t + S[I]
    else
    begin
      if length(t) > 2 then
      begin
        if tags <> '' then
          tags := tags + ', ';
        tags := tags + t;
      end;
      t := '';
    end;
  end;
  if length(t) > 2 then
  begin
    if tags <> '' then
      tags := tags + ', ';
    tags := tags + t;
  end;


  result := tags;
end;

function XMLToStr(XML: string): string;
var
  Poz: integer;
  S: string;
  I: Integer;
  iVal: integer;
  LastPos: integer;
begin
  Result := StringReplace(XML, '&amp;br;', #13#10, [rfReplaceAll]);
  Result := StringReplace(Result, '&br;', #13#10, [rfReplaceAll]);
  Result := StringReplace(Result, '&lt;', '<', [rfReplaceAll]);
  Result := StringReplace(Result, '&gt;', '>', [rfReplaceAll]);
  Result := StringReplace(Result, '&quot;', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '&amp;', '&', [rfReplaceAll]);
  Result := StringReplace(Result, '&nbsp;', ' ', [rfReplaceAll]);

  LastPos := 0;
  Poz := Pos('&#x', LowerCase(Result));   //  &#x024A; -> õ
  while (Poz>0) and (Poz <> LastPos) do
  begin
    S := '';
    Inc(Poz, 2);
    for I := 1 to 5 do
    begin
      if not (Result[Poz+I] in ['0'..'9', 'a'..'f', 'A'..'F'] ) then break;
      S := S + Result[Poz+I];
    end;
    if S <> '' then
    begin
      iVal := StrToIntDef('$' + S, 32);
      if Result[Poz+I] <> #0 then
        S := S + Result[Poz+I];
      result := StringReplace(Result, '&#x' + S,Chr(iVal),[rfReplaceAll,rfIgnoreCase]);
    end;
    LastPos := Poz - 2;
    Poz := Pos('&#x',LowerCase(Result));   //  &#245;
  end;

  LastPos := 0;
  Poz := Pos('&#',Result);   //  &#245; -> õ
  while (Poz>0) and (Poz <> LastPos)  do
  begin
    S := '';
    Inc(Poz,1);
    for I := 1 to 5 do
    begin
      if not (Result[Poz+I] in ['0'..'9'] ) then break;
      S := S + Result[Poz+I];
    end;
    if S <> '' then
    begin
      iVal := StrToIntDef(S,32);
      if Result[Poz+I] <> #0 then
        S := S + Result[Poz+I];
      result := StringReplace(Result, '&#' + S,Chr(iVal),[rfReplaceAll,rfIgnoreCase]);
    end;

    LastPos := Poz - 1;
    Poz := Pos('&#',Result);   //  &#245;
  end;
end;

end.
