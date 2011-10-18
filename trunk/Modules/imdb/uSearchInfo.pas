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
  LangTexts: TStringList;

  foundItems: TDescriptorProductInfoArray;

function Lang(Text: string): string;

procedure SearchMovie(MovieTitle, imdbSite: string);
procedure AnalyzePageNew(URL: string);
procedure AnalyzePageOld(URL: string);

function GetPage(Address: string): string;
procedure GetImage(Address: string; FileName: string);

function UserSelectFromList: integer;
procedure FreeFoundItems;

function XMLToStr(XML: string): string;
function GenerateAutoTags(Name: string): string;

function Padding(Str: string; Count: integer): string;

implementation

function Lang(Text: string): string;
begin
  result := LangTexts.Values[Text];
  if result = '' then
    result := Text;
end;

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
  http.HandleRedirects := true;
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

procedure SearchMovie(MovieTitle, imdbSite: string);
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
  url := 'http://www.imdb.' + imdbSite + '/find?q=' + MovieTitle;
  content := GetPage(url);
  RefererPage := url;

  regexp := TPerlRegEx.Create;
  regexp.Options := [preCaseLess, preMultiLine];
  regexp.RegEx := 'og:url" content="http://www.imdb.\w+/find"';
  regexp.Subject := content;
  if not regexp.Match then
  begin
    //Redirected to movie details page
    regexp.Start := 0;
    regexp.RegEx := 'og:url" content="(http://www.imdb.\w+/title/tt\d+/)"';
    if regexp.Match and (regexp.GroupCount > 0) then
      MovieAddress := regexp.Groups[1];

    regexp.Start := 0;
    regexp.RegEx := '<meta name="title" content="(.*?)"';
    if regexp.Match and (regexp.GroupCount > 0) then
      title := XMLToStr(regexp.Groups[1]);

    SetLength(foundItems, 0);
    Item.Name := StrNew(PWideChar(title));
    Item.URL := StrNew(PWideChar(MovieAddress));
    Item.Description := nil;
    Item.Image := nil;

    SetLength(foundItems, Length(foundItems) + 1);
    foundItems[Length(foundItems) - 1] := Item;
  end
  else
  begin
    //Search result page
    regexp.RegEx := 'href="/title/tt(\d{7})/"[^>]*>(.*?)</a>\s*(\((\d{4})(/.+?|)\)|)[^<]*(<small>(.*?)</small>|)';
    resList := TStringList.Create;
    SetLength(foundItems, 0);
    regexp.Start := 0;
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
            MovieAddress := 'http://www.imdb.' + imdbSite + '/title/tt' + imdbID + '/';
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
  end;

  if Length(foundItems) > 0 then
  begin
    SelectedIndex := UserSelectFromList;
    if SelectedIndex <> -1 then
    begin
      MovieAddress := foundItems[SelectedIndex].URL;

      if imdbSite = 'com' then
        AnalyzePageNew(MovieAddress)
      else
        AnalyzePageOld(MovieAddress);

      FreeFoundItems;
    end;
  end
  else
    ShowMessage('Sorry, movie not found!');

//  regexp.Free;
end;

procedure AnalyzePageNew(URL: string);
var
  content, s: string;
  regexp: TPerlRegEx;
  title, origtitle, year, description, length, genres, rating, storyline, cast: string;
  stars, director, writer: string;
  Descr: TStringBuilder;
  Tags, sTitle: string;
  imageURL, tempFile: string;
  plotSummary, fullCredits: string;
begin
  content := GetPage(URL);
  content := StringReplace(content, #13, '', [rfReplaceAll]);
  content := StringReplace(content, #10, '', [rfReplaceAll]);
  if content <> '' then
  begin
    regexp := TPerlRegEx.Create;
    regexp.Subject := content;
    regexp.Options := [preCaseLess, preMultiLine];
    regexp.RegEx := '<h1.*?>\s*(.*?)\s*<';
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

    regexp.Start := 0;
    regexp.RegEx := 'title-overview/primary.*?><img src="(.*?)"';
    if regexp.Match and (regexp.GroupCount > 0)then
      imageURL := regexp.Groups[1];

    Descr := TStringBuilder.Create;
    Descr.AppendFormat('%s - Rating: %s - Genres: %s', [length, rating, genres]).AppendLine.AppendLine;

    //FullCredits & Director & Writer
    fullCredits := GetPage(URL + 'fullcredits');
    regexp.Subject := fullCredits;
    regexp.RegEx := 'name="directors".*?>.*?/name/nm\d+/.*?>(.*?)</a';
    if regexp.Match and (regexp.GroupCount > 0) then
      director := Trim(XMLToStr(regexp.Groups[1]));

    regexp.Start := 0;
    regexp.RegEx := 'name="writers".*?>.*?/name/nm\d+/.*?>(.*?)</a';
    if regexp.Match and (regexp.GroupCount > 0) then
      writer := Trim(XMLToStr(regexp.Groups[1]));

    Cast := '';
    regexp.Start := 0;
//    regexp.RegEx := '<td class="nm">.*?/name/nm\d+/.*?>(.*?)</a>.*?/character/ch\d+/">(.*?)</a>';
    regexp.RegEx := '<td class="nm">.*?/name/nm\d+/.*?>(.*?)</a>.*?<td class="char">(.*?)</td>';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 1 then
        cast := cast + '     ' + Trim(StripHTMLtags(regexp.Groups[1])) + '  ...  ' + Trim(StripHTMLtags(regexp.Groups[2])) + #13#10;
    end;


    Descr.Append(Description).AppendLine.AppendLine;
    Descr.Append('Director: ' + Director).AppendLine;
    Descr.Append('Writer: ' + Writer).AppendLine;
    Descr.Append('Stars: ' + stars).AppendLine.AppendLine;

    //PlotSummary
    plotSummary := GetPage(URL + 'plotsummary');

    Descr.Append('Plot: ').AppendLine;
    regexp.Subject := plotSummary;
    regexp.RegEx := '<p class="plotpar">(\s.*?)*?</p>';
    while regexp.MatchAgain do
      Descr.Append(Trim(XMLToStr(StripHTMLtags(regexp.Groups[0])))).AppendLine.AppendLine;

    Descr.Append('Cast: ').AppendLine.Append(Cast);



    sTitle := XMLToStr(title);
    if Trim(year) <> '' then
      sTitle := sTitle + ' (' + year + ')';
    s := XMLToStr(Descr.ToString);
    Product.Name := PWideChar(sTitle);
    Product.Description := PWideChar(s);
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


procedure AnalyzePageOld(URL: string);
var
  content, s: string;
  regexp: TPerlRegEx;
  title, origtitle, year, description, length, genres, rating, storyline, cast: string;
  stars, director, writer: string;
  Descr: TStringBuilder;
  Tags, sTitle: string;
  imageURL, tempFile: string;
  plotSummary, fullCredits: string;
begin
  content := GetPage(URL);
  //content := StringReplace(content, #13, '', [rfReplaceAll]);
  //content := StringReplace(content, #10, '', [rfReplaceAll]);
  if content <> '' then
  begin
    regexp := TPerlRegEx.Create;
    regexp.Subject := content;
    regexp.Options := [preCaseLess, preMultiLine];
    regexp.RegEx := '<h1.*?>\s*(.*?)\s*<span>(.*?)<';
    if regexp.Match and (regexp.GroupCount > 0)then
      title := Trim(regexp.Groups[1]);
    if regexp.Match and (regexp.GroupCount > 1)then
      year := Trim(regexp.Groups[2]);

    origtitle := '';

    regexp.Start := 0;
    regexp.RegEx := '<h5>' + Lang('_Length') + '</h5><div.*?>(.*?)</div>';
    if regexp.Match and (regexp.GroupCount > 0)then
      length := Trim(regexp.Groups[1]);

    genres := '';
    regexp.Start := 0;
    regexp.RegEx := '<h5>' + Lang('_Genres') + '</h5>\s*<div.*?>\s*(.*?)\s*</div>';
    if regexp.Match and (regexp.GroupCount > 0)then
      genres := Trim(regexp.Groups[1]);

    regexp.Start := 0;
    regexp.RegEx := '<div class="starbar-meta">\s*.*?<b>(.*?)\/\d+</b>';
    if regexp.Match and (regexp.GroupCount > 0)then
      rating := regexp.Groups[1];

    regexp.Start := 0;
    regexp.RegEx := '<h5>' + Lang('_Summary') + '</h5>\s*<div class="info-content">\s(.*?)\s<';
    if regexp.Match and (regexp.GroupCount > 0)then
      description := Trim(regexp.Groups[1]);

{    regexp.Start := 0;
    regexp.RegEx := 'Storyline</h2>\s*\<p>\s*(.*?)\s*<em';
    if regexp.Match and (regexp.GroupCount > 0)then
      storyline := regexp.Groups[1];}

    stars := '';
{    regexp.Start := 0;
    regexp.RegEx := 'itemprop="actors"\s+>(.+?)<';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 0 then
      begin
        if stars <> '' then
          stars := stars + ', ';
        stars := stars + Trim(regexp.Groups[1]);
      end;
    end;}

    regexp.Start := 0;
    regexp.RegEx := '<div class="photo">\s*<a name="poster".*?><img.*?src="(.*?)"';
    if regexp.Match and (regexp.GroupCount > 0)then
      imageURL := regexp.Groups[1];

    Descr := TStringBuilder.Create;
    Descr.AppendFormat('%s - ' + Lang('Rating') + ': %s - ' + Lang('Genres') + ': %s', [length, rating, genres]).AppendLine.AppendLine;

    //FullCredits & Director & Writer
    fullCredits := GetPage(URL + 'fullcredits');
    regexp.Subject := fullCredits;
    regexp.RegEx := 'name="directors".*?>.*?/name/nm\d+/.*?>(.*?)</a';
    if regexp.Match and (regexp.GroupCount > 0) then
      director := Trim(XMLToStr(regexp.Groups[1]));

    regexp.Start := 0;
    regexp.RegEx := 'name="writers".*?>.*?/name/nm\d+/.*?>(.*?)</a';
    if regexp.Match and (regexp.GroupCount > 0) then
      writer := Trim(XMLToStr(regexp.Groups[1]));

    Cast := '';
    regexp.Start := 0;
    regexp.RegEx := '<td class="nm">.*?/name/nm\d+/.*?>(.*?)</a>.*?<td class="char">(.*?)</td>';
    while regexp.MatchAgain do
    begin
      if regexp.GroupCount > 1 then
        cast := cast + '     ' + Trim(StripHTMLtags(regexp.Groups[1])) + '  ...  ' + Trim(StripHTMLtags(regexp.Groups[2])) + #13#10;
    end;



    Descr.Append(Description).AppendLine.AppendLine;
    Descr.Append(Lang('Director') + ': ' + Director).AppendLine;
    Descr.Append(Lang('Writer') + ': ' + Writer).AppendLine.AppendLine;
//    Descr.Append('Stars: ' + stars).AppendLine.AppendLine;

    //PlotSummary
    plotSummary := GetPage(URL + 'plotsummary');

    Descr.Append(Lang('Plot') + ': ').AppendLine;
    regexp.Subject := plotSummary;
    regexp.RegEx := '<div id="swiki.2.1">\s*(.*?)\s*?</div>';
    while regexp.MatchAgain do
      Descr.Append(Trim(XMLToStr(StripHTMLtags(regexp.Groups[0])))).AppendLine.AppendLine;


    Descr.Append(Lang('Cast') + ': ').AppendLine.Append(Cast);



    sTitle := XMLToStr(title);
    if Trim(year) <> '' then
      sTitle := sTitle + ' ' + year;
    s := XMLToStr(Descr.ToString);
    Product.Name := PWideChar(sTitle);
    Product.Description := PWideChar(s);
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

initialization
  LangTexts := TStringList.Create;

finalization
  LangTexts.Free;

end.
