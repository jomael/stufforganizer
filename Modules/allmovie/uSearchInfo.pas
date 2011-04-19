unit uSearchInfo;

interface

uses
  Classes, SysUtils, Windows, Messages, Dialogs, SOPluginDefs, IcePack,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils;

var
  Self: Pointer;
  Product: PPluginProductItem;
  SaveImageToDB: TDescriptorSaveImage;
  SaveProductInfoToDB: TDescriptorSaveProductInfo;
  UserSelect: TDescriptorUserSelect;

  MovieName: string;
//  BeginPos, EndPos: Integer;

  foundItems: TDescriptorProductInfoArray;

procedure AnalyzeMoviePage(URL: string; MoviePage: TStringList);
function GetPage(Address: string): string;
procedure GetImage(Address: string; FileName: string);
procedure HTMLDecode(S: string);
function FindLine(Pattern: string; List: TStringList; StartAt: Integer): Integer;
function GetName(Page: TStringList; SearchStr: string): string;
procedure AnalyzePage(Address: string);
procedure AddMoviesTitles(ResultsPage: TStringList);
function UserSelectFromList: integer;
procedure FreeFoundItems;
function GenerateAutoTags(Name: string): string;
function GetStringFromHTML(Page, StartTag, CutTag, EndTag: string): string;
procedure CutAfter(var Str: string; Pattern: string);
procedure CutBefore(var Str: string; Pattern: string);
function TextBetween(WholeText: string; BeforeText: string; AfterText: string): string;
function TextAfter(WholeText: string; SearchText: string): string;

implementation

function GetPage(Address: string): string;
var
  http: TIdHTTP;
begin
  result := '';
  http := TIdHTTP.Create(nil);
  http.Request.UserAgent := 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16';
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

procedure HTMLDecode(S: string);
begin

end;

function FindLine(Pattern: string; List: TStringList; StartAt: Integer): Integer;
var
  i: Integer;
begin
  result := -1;
  if StartAt < 0 then
    StartAt := 0;
  for i := StartAt to List.Count-1 do
    if Pos(Pattern, List[i]) <> 0 then
    begin
      result := i;
      Break;
    end;
end;

function GetName(Page: TStringList; SearchStr: string): string;
var
  i: Integer;
  Line, Value, Temp: string;
  LineNr: Integer;
  BeginPos, EndPos: Integer;
begin
  result := '';
  LineNr := FindLine('<span class="btxt">' + SearchStr + '', Page, 0);
  if LineNr > -1 then
  begin
    Line := Page[LineNr];
    BeginPos := pos('<span class="btxt">' + SearchStr + '', Line)+33+Length(SearchStr);
    Delete(Line, 1, BeginPos-1);
    EndPos := pos('<br>', Line)-1;
    Value := copy(Line, 0, EndPos);
    if (value='') then begin
      Line := Page[LineNr];
      BeginPos := pos('<span class="btxt">' + SearchStr + '', Line)+20+Length(SearchStr);
      Delete(Line, 1, BeginPos-1);
      repeat
        If (Value<>'') then Value := Value + ', ';
        BeginPos := pos(' target="_top">', Line)+15;
        Delete(Line, 1, BeginPos-1);
        EndPos := pos('</a>', Line)-1;
        Value := Value + copy(Line, 0, EndPos);
        Temp := copy(Line, EndPos+1, 12);
      until (Temp <> '</a></span>,');
    end;
    Value := StripHTMLtags(Value);
    result := Value;
  end;
end;

procedure AnalyzePage(Address: string);
var
  Page: TStringList;
  SelectedIndex: integer;
begin
  Page := TStringList.Create;
  Page.Text := GetPage(Address);

  if Pos('Search Results for:', Page.Text) > 0 then
  begin
    AddMoviesTitles(Page);
    if Length(foundItems) > 0 then
    begin
      SelectedIndex := UserSelectFromList;
      if SelectedIndex <> -1 then
      begin
        Address := foundItems[SelectedIndex].URL;
        AnalyzePage(Address);

        FreeFoundItems;
      end;
    end
    else
      ShowMessage('Sorry, movie not found!');
  end
  else if Pos('Sorry, there are too many possible matches, please adjust your search.', Page.Text) > 0 then
  begin
    ShowMessage('Sorry, there is too many possible matches, please adjust your search.');
    if InputQuery('All Movie Import', 'Enter the title of the movie:', MovieName) then
      AnalyzePage('http://www.allmovie.com/search/work/' + URLEncode(MovieName, false));
  end
  else
  begin
    AnalyzeMoviePage(Address, Page)
  end;

  Page.Free;
end;

function UserSelectFromList: integer;
begin
  result := UserSelect(Self, @foundItems);
end;

procedure AnalyzeMoviePage(URL: string; MoviePage: TStringList);
var
  Descr: TStringBuilder;
  tempFile: string;
  Page: string;
  Value: string;
  Content: string;
  Dummy: string;
  SubPage: TStringList;

  imageURL, Tags: string;
  sTitle, sYear, sLength, sCountry, sRating, sGenres, sDirector, sCast, sDescr, sCredit: string;
begin
  imageURL := '';
  Descr := TStringBuilder.Create;
  Product.URL := PWideChar(URL);
  Product.Modified := true;

  Page := MoviePage.Text;
  Page := UTF8Decode(Page);
  SubPage := TStringList.Create;

  // Original title
  sTitle := TextBetween(Page, 'span class="title">', '</span>');
  Product.Name := PWideChar(sTitle);

  // get the left panel content -- this yields year, runtime, country, director & genre
  Content := TextBetween(Page, '<title>', '</html>');

  // remove unwanted formatting code
  Content := StringReplace(Content, #9, '', [rfReplaceAll]);
  Content := StringReplace(Content, '  ', '', [rfReplaceAll]);

  // Year
  sYear := TextAfter(Content, '<span>Year</span>');
  sYear := GetStringFromHTML(sYear, 'allmovie.com/explore/year/', '">', '</a>');

  sLength := TextAfter(Content, '<span>Run Time</span>');
  sLength := TextAfter(sLength, 'width: 86px;">'); // length is second field in the table
  sLength := GetStringFromHTML(sLength, 'width: 86px;">', 'width: 86px;">', ' min');

  // Country
  sCountry := TextAfter(Content, '<span>Countries</span>');
  sCountry := GetStringFromHTML(sCountry, 'allmovie.com/explore/country/', '">', '</a>');

{  // AKA -> translated title
  if CanSetField(fieldTranslatedTitle) then
  begin
    Value := TextAfter(Content, '<span>AKA</span>');
    Value := GetStringFromHTML(Value, 'class="formed-sub">', 'class="formed-sub">', '</td>');
    SetField(fieldTranslatedTitle, Value);
  end; }

  // Rating (multiplied by 2, because 0 <= AMG rating <= 5)
  Value := GetStringFromHTML(Page, '<span>Work Rating</span>', 'alt="', ' Stars');
  if Length(Value) > 0 then
    sRating := Value;

  // Director
  sDirector := TextAfter(Content, '<span>Director</span>');
  sDirector := GetStringFromHTML(sDirector, 'allmovie.com/artist/', '">', '</a>');

  // Genre -> category
  Value := TextAfter(Content, '<span>Genres</span>');
  Value := TextBetween(Value, '<ul>', '</ul>');
  Value := StringReplace(Value, '[nf]', '', [rfReplaceAll]);
  HTMLDecode(Value);
  Value := TextBetween(Value, '<li>', '</li>');
  sGenres := StripHTMLTags(Value);

  Descr.AppendFormat('(%s) %s, %s - Length: %s min - Rating: %s - Director: %s', [sYear, sCountry, sGenres, sLength, sRating, sDirector]).AppendLine;

  // Image
  imageURL := GetStringFromHTML(Page, 'http://image.allmusic.com', '', '"');

  // store the author of the synopsis
  Value := GetStringFromHTML(Content, 'class="author">by ', '<td colspan="2">', '</table>');
  Descr.AppendLine.Append(StripHTMLTags(Value)).AppendLine;

  // Cast -> actors
  if Pos('cast">Cast</a>', Page) > 0 then
  begin
    // first find the link
    Dummy := TextBetween(Page, '>Review<','Cast</a>');
    Dummy := TextBetween(Dummy, 'href="','">');
    // get the page
    SubPage.Text := GetPage(Dummy);

    // get the center panel content -- this yields the Cast table
    Value := TextBetween(SubPage.Text, '<div id="results-table">', '</table>');
    // Clean up list
    Value := StringReplace(Value, #9, '', [rfReplaceAll]);
    Value := StringReplace(Value, #10, '', [rfReplaceAll]);
    Value := StringReplace(Value, #13, '', [rfReplaceAll]);
    Value := StringReplace(Value, '&nbsp;', '', [rfReplaceAll]);
    Value := StringReplace(Value, '<td width="305">- <em>', '||', [rfReplaceAll]);
    Value := StringReplace(Value, '</tr>', '~~', [rfReplaceAll]);
    Value := StringReplace(Value, ' ~~', '~~', [rfReplaceAll]);
    Value := StripHTMLTags(Value);
    HTMLDecode(Value);
    Value := UTF8Decode(Value);
    Value := StringReplace(Value, '~~', #13#10, [rfReplaceAll]);
    Value := StringReplace(Value, '||', ' ... ', [rfReplaceAll]);
    sCast := Trim(Value);
    Descr.AppendFormat('Cast:'+#13#10+'%s', [sCast]).AppendLine;
    SubPage.Free;
  end;

  Product.Description := PWideChar(Descr.ToString);
  Product.Modified := true;
  Descr.Free;

  Tags := GenerateAutoTags(Product.Name);
  Product.Tags := PWideChar(Tags);
  //Save new product info
  SaveProductInfoToDB(Self, Product);

  //picture
  if Length(imageURL) > 0 then
  begin
    tempFile := IncludeTrailingBackslash(IcePack.GetTempDirectory) + ExtractUrlFileName(imageURL);
    if FileExists(tempFile) then
      DeleteFile(PWideChar(tempFile));
    GetImage(imageURL, tempFile);

    SaveImageToDB(Self, Product, PWideChar(tempFile));
    DeleteFile(PWideChar(tempFile));
  end;
end;

procedure AddMoviesTitles(ResultsPage: TStringList);
var
  Page: string;
  MovieTitle, MovieAddress: string;
  Item: TDescriptorProductInfo;
begin
  SetLength(foundItems, 0);

  if Assigned(ResultsPage) then
  begin
    Page := TextBetween(ResultsPage.Text, '<a>Category</a>', '<div id="footer">');

    // Every movie entry begins with string '<a href="http://www.allmovie.com/work/'
    while Pos('<a href="http://www.allmovie.com/work/', Page) > 0 do
    begin
      CutBefore(Page, '<a href="http://www.allmovie.com/work/');
      MovieAddress := GetStringFromHTML(Page, 'http://www.allmovie.com/work/', '', '">');
    // Get Movie Title
      MovieTitle := GetStringFromHTML(Page, '">', '">', '</a>');
    // Add year to movie title
      MovieTitle := MovieTitle + ' ('+GetStringFromHTML(Page, '<td class="cell" style="width: 70px;">', '">', '</td>')+')';
      // Add producer to MovieTitle
      MovieTitle := MovieTitle + ' '+GetStringFromHTML(Page, '<td class="cell" style="width: 190px;">', '">', '</td>');
      CutAfter(Page, '</a>');

      Item.Name := StrNew(PWideChar(MovieTitle));
      Item.URL := StrNew(PWideChar(MovieAddress));
      Item.Description := nil;
      Item.Image := nil;

      SetLength(foundItems, Length(foundItems) + 1);
      foundItems[Length(foundItems) - 1] := Item;
    end;
  end;
end;

function TextBetween(WholeText: string; BeforeText: string; AfterText: string): string;
var
  FoundPos: Integer;
  WorkText, RemainingText: string;
begin
  RemainingText := WholeText;
  Result := '';
  FoundPos := Pos(BeforeText, WholeText);
  if FoundPos = 0 then
    Exit;
  WorkText := Copy(WholeText, FoundPos + Length(BeforeText), Length(WholeText));
  FoundPos := Pos(AfterText, WorkText);
  if FoundPos = 0 then
    Exit;
  Result := Copy(WorkText, 1, FoundPos - 1);
//  RemainingText := Copy(WorkText, FoundPos + Length(AfterText), Length(WorkText));
end;

function TextAfter(WholeText: string; SearchText: string): string;
var
  FoundPos: Integer;
begin
  Result := '';
  FoundPos := Pos(SearchText, WholeText);
  if FoundPos = 0 then
    Exit;
  Result := Copy(WholeText, FoundPos + Length(SearchText), Length(WholeText));
end;

procedure CutAfter(var Str: string; Pattern: string);
begin
  Str := Copy(str, Pos(Pattern, Str) + Length(Pattern), Length(Str));
end;

procedure CutBefore(var Str: string; Pattern: string);
begin
  Str := Copy(Str, Pos(Pattern, Str), Length(Str));
end;

// Extracts single movie detail (like director, genre) from page
function GetStringFromHTML(Page, StartTag, CutTag, EndTag: string): string;
begin
  Result := '';
  // recognition tag - if present, extract detail from page, otherwise assume detail is not present
  if Pos(StartTag, Page) > 0 then begin
    CutBefore(Page, StartTag);
    // optional cut tag helps finding right string in html page
    if Length(CutTag) > 0 then
      CutAfter(Page, CutTag);
    // movie detail copied with html tags up to end string
    Result := Copy(Page, 0, Pos(EndTag, Page) - 1);
    // remove html tags and decode html string
    Result := StripHTMLtags(Result);
    HTMLDecode(Result);
    Result := UTF8Decode(Result);
  end;
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


end.
