unit uSearchInfo;

interface

uses
  Classes, SysUtils, Windows, Messages, Dialogs, SOPluginDefs, IcePack,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils, PerlRegEx, api_keys, IceXML;


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
procedure AnalyzePage(MovieID: string);

function GetPage(Address: string): string;
procedure GetImage(Address: string; FileName: string);

function UserSelectFromList: integer;
procedure FreeFoundItems;

function XMLToStr(XML: string): string;
function GenerateAutoTags(Name: string): string;

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

function GetPage(Address: string): string;
var
  http: TIdHTTP;
begin
  result := '';
  try
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
  except
  end;
end;

procedure GetImage(Address: string; FileName: string);
var
  http: TIdHTTP;
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    http := TIdHTTP.Create(nil);
    http.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16';
    try
      http.Get(Address, fs);
    finally
      http.Disconnect;
      http.Free;
    end;
  except
  end;
  fs.Free;
end;

procedure SearchMovie(MovieTitle: string);
var
  content: string;
  xml: TIceXML;
  movies, movie: TXMLItem;
  title, year, MovieAddress: string;
  resList: TStringList;
  Item: TDescriptorProductInfo;
  SelectedIndex: integer;
  url: string;
  s: string;
  I: Integer;
begin

  url := 'http://api.themoviedb.org/2.1/Movie.search/en/xml/' + TMDB_API_KEY + '/' + MovieTitle;
  content := GetPage(url);
  RefererPage := url;
  SetLength(foundItems, 0);
  xml := TIceXML.Create(nil);
  try
    xml.LoadFromString(content);
    if xml.Root.Name = 'OpenSearchDescription' then
    begin
      movies := xml.Root.GetItemEx('movies');
      if Assigned(movies) and (movies.Count > 0) then
      begin
        for I := 0 to movies.Count - 1 do
        begin
          movie := movies[I];
          title := movie.GetItemValue('name', '');
          s := movie.GetItemValue('released', '');
          year := CutAt(s, '-');
          title := Format('%s (%s)', [title, year]);
          MovieAddress := movie.GetItemValue('id', '-1');

          Item.Name := StrNew(PWideChar(title));
          Item.URL := StrNew(PWideChar(MovieAddress));
          Item.Description := nil;
          Item.Image := nil;

          SetLength(foundItems, Length(foundItems) + 1);
          foundItems[Length(foundItems) - 1] := Item;
        end;
      end;
    end;
  finally
    xml.Free;
  end;

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
end;

procedure AnalyzePage(MovieID: string);
var
  content, s: string;
  xml: TIceXML;
  movie, xCats, xCasts, Item: TXMLItem;
  title, origtitle, year, description, length, genres, rating, cast, url: string;
  trailer, director, writer: string;
  Descr: TStringBuilder;
  Tags, sTitle: string;
  imageURL, tempFile: string;
  I: Integer;

begin
  content := GetPage('http://api.themoviedb.org/2.1/Movie.getInfo/en/xml/' + TMDB_API_KEY + '/' + MovieID);
  xml := TIceXML.Create(nil);
  try
    xml.LoadFromString(content);
    if xml.Root.Name = 'OpenSearchDescription' then
    begin
      movie := xml.Root.GetItemEx('movies.movie');
      if Assigned(movie) then
      begin
        title := movie.GetItemValue('name', '');
        url := movie.GetItemValue('url', '');
        description := movie.GetItemValue('overview', '');
        rating := movie.GetItemValue('rating', '');
        length := movie.GetItemValue('runtime', '');
        trailer := movie.GetItemValue('trailer', '');
        s := movie.GetItemValue('released', '');
        year := CutAt(s, '-');

        genres := '';
        xCats := movie.GetItemEx('categories');
        if Assigned(xCats) then
        begin
          for I := 0 to xCats.Count - 1 do
          begin
            if genres <> '' then
              genres := genres + ', ';

            genres := genres + xCats[I].Attr['name'];
          end;
        end;

        cast := ''; director := ''; writer := '';
        xCasts := movie.GetItemEx('cast');
        if Assigned(xCasts) then
        begin
          for I := 0 to xCasts.Count - 1 do
          begin
            Item := xCasts[I];
            if Item.Attr['job'] = 'Actor' then
              cast := cast + '     ' + Item.Attr['name'] + '  ...  ' + Item.Attr['character'] + #13#10;
            if Item.Attr['job'] = 'Director' then
            begin
              if director <> '' then
                director := director + ', ';
              director := director + Item.Attr['name'];
            end;
            if Item.Attr['job'] = 'Screenplay' then
            begin
              if writer <> '' then
                writer := writer + ', ';
              writer := writer + Item.Attr['name'];
            end;
          end;
        end;

        Descr := TStringBuilder.Create;
        Descr.AppendFormat('%s min - Rating: %s - Genres: %s', [length, rating, genres]).AppendLine.AppendLine;

        Descr.Append(Description).AppendLine.AppendLine;
        Descr.Append('Trailer: ' + trailer).AppendLine.AppendLine;
        Descr.Append('Director: ' + Director).AppendLine;
        Descr.Append('Screenplay: ' + Writer).AppendLine.AppendLine;
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
        Item := movie.GetItemEx('images.image');
        if Assigned(Item) then
        begin
          imageURL := Item.Attr['url'];
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
  finally
    xml.Free;
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
