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

procedure AnalyzeSearchResults(MovieTitle: string);
procedure AnalyzeMoviePage(Address: string; MoviePage: TStringList);
function GetPage(Address: string): string;
procedure GetImage(Address: string; FileName: string);
procedure HTMLDecode(S: string);
function FindLine(Pattern: string; List: TStringList; StartAt: Integer): Integer;
function GetName(Page: TStringList; SearchStr: string): string;
procedure AnalyzePage(Address: string);
procedure AddMoviesTitles(Title : string; NumResults: Integer);
function UserSelectFromList: integer;
procedure FreeFoundItems;
function GenerateAutoTags(Name: string): string;
function GetStringFromHTML(Page, StartTag, CutTag, EndTag: string): string;
procedure CutAfter(var Str: string; Pattern: string);
procedure CutBefore(var Str: string; Pattern: string);
function TextBetween(WholeText: string; BeforeText: string; AfterText: string): string;
function TextAfter(WholeText: string; SearchText: string): string;

function StrOccurs(Text, SearchText: string) : integer;
function GetStringFromList(Content, Delimiter: string): string;
function GetStringFromTable(Content, Delimiter, ColDelim : string): string;
function GetStringFromAwardsTable(Content, Delimiter, ColDelim : string): string;

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

// Loads and analyses search results page
procedure AnalyzeSearchResults(MovieTitle: string);
var
  Page: TStringList;
  NumResults, Code, SelectedIndex : Integer;
  Address : string;
begin
  Page := TStringList.Create;
  Page.Text := GetPage('http://www.allrovi.com/search/movies/' + MovieTitle);
  NumResults := 0;
  if Pos('Search results for ', Page.Text) > 0 then
  begin
    NumResults := StrToIntDef(TextBetween(Page.Text, '<span class="result-count">', '</span>'), 0);
    if (NumResults > 0) and (NumResults <= 100) then
    begin
      AddMoviesTitles(MovieTitle, NumResults);
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
    end;
  end;

  if (NumResults > 100) then
    ShowMessage('Sorry, there are too many possible matches, please adjust your search and retry.')
  else
  if NumResults = 0 then
    ShowMessage('Sorry, no movies found.');

  // cleanup
  Page.Free;
end;

// Loads and analyses a movie page
procedure AnalyzePage(Address: string);
var
  Page: TStringList;
begin
  Page := TStringList.Create;
  Page.Text := GetPage(Address);
  AnalyzeMoviePage(Address, Page);
  Page.Free;
end;

function UserSelectFromList: integer;
begin
  result := UserSelect(Self, @foundItems);
end;

(*
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
*)

// Extracts movie details from page
procedure AnalyzeMoviePage(Address: String; MoviePage: TStringList);
var
  Page: string;
  Value: string;
  Content: string;
  Delimiter : string;
  Dummy: string;
  SubPage: TStringList;
  Rating : real;

  Descr: TStringBuilder;
  tempFile, imageURL, Tags: string;
  sTitle, sYear, sLength, sCountry, sRating, sGenres, sDirector, sCast, sDescr, sCredit: string;
begin
  imageURL := '';
  Descr := TStringBuilder.Create;
  Product.URL := PWideChar(Address);
  Product.Modified := true;

  Page    := MoviePage.Text;
  SubPage := TStringList.Create;

  // Original title
  sTitle := TextBetween(Page, 'div class="page-heading">', '</div>');
  sTitle := StripHTMLTags(Trim(UTF8Decode(sTitle)));
  HTMLDecode(sTitle);
  Product.Name := PWideChar(sTitle);

  Content := TextAfter(Page, '<div class="star-blick">');

  // Year
  sYear := Trim(GetStringFromHTML(Content, '<dt>release date</dt>',
                             '<li>', '</li>'));

  // Length
  //if CanSetField(fieldLength) then
  //begin
  //  Value := TextAfter(Content, '<span>Run Time</span>');
  //  Value := TextAfter(Value, '<td class="formed-sub" style="width: 86px;"'); // length is second field in the table
  //  Value := GetStringFromHTML(Value, '<td class="formed-sub" style="width: 86px;">',
  //                                    '<td class="formed-sub" style="width: 86px;">', ' min');
  //  SetField(fieldLength, Value);
  //end;

  // Length
  Value := GetStringFromHTML(Content, '<dt>run time</dt>',
                             '<dd>', '</dd>');
  sLength := UTF8Decode(Value);


  // Country
  Value := GetStringFromHTML(Content, '<dt>countries</dt>',
                             '<dd>', '</dd>');
  sCountry := UTF8Decode(Value);

  // AKA -> translated title
  //if CanSetField(fieldTranslatedTitle) then
  //begin
  //  Value := TextAfter(Content, '<span>AKA</span>');
  //  Value := GetStringFromHTML(Value, 'class="formed-sub">', 'class="formed-sub">', '</td>');
  //  Value := UTF8Decode(Value);
  //  SetField(fieldTranslatedTitle, Value);
  //end;

  // Rating (multiplied by 2, because 0 <= AMG rating <= 5)
  Value := TextAfter(Content, '<dt>rovi rating</dt>');
  Value := TextBetween(Value, '<ul class="rating rovi">', '</ul>');
  if Length(Value) > 0 then
  begin
    Rating := StrOccurs(Value, 'star full');
    Rating := Rating + (StrOccurs(Value, 'star half') * 0.5);
    sRating := FloatToStr(Rating * 2);
  end;

  // Director
  Value := TextAfter(Content, '<dt>directed by</dt>');
  Value := TextBetween(Value, '<ul class="warning-list">', '</ul>');
  Value := UTF8Decode(Value);
  Value := GetStringFromList(Value, ',');
  sDirector := Value;

  // Genre -> category
  Value := TextAfter(Content, '<dt>genres</dt>');
  Value := TextBetween(Value, '<ul class="warning-list">', '</ul>');
  Value := UTF8Decode(Value);
{  if GetOption('CategoryOptions') = 1 then
  begin
    Value := TextBetween(Value, '<li>', '</li>');
    HTMLRemoveTags(Value);
  end
  else  }
  begin
{    if GetOption('CategoryOptions') = 2 then
      Delimiter := '/';
    if GetOption('CategoryOptions') = 3 then
}      Delimiter := ',';
    Dummy := GetStringFromList(Value, Delimiter);
    // sub-genres
    Value := TextAfter(Content, '<dt>sub-genres</dt>');
    Value := TextBetween(Value, '<ul class="warning-list">', '</ul>');
    Value := UTF8Decode(Value);
    Value := GetStringFromList(Value, Delimiter);
    if Length(Value) > 0 then
      Value := Dummy + Delimiter + Value
    else
      Value := Dummy;
  end;
  sGenres := Value;

 { // Producing company  -> producer
  if CanSetField(fieldProducer) then
  begin
    Value := '';
    if GetOption('ProducerOptions') = 0 then
    begin
      Value := GetStringFromHTML(Content, '<dt>produced by</dt>',
                                 '<div>', '</div>');
      Value := UTF8Decode(Value);
    end;

    if GetOption('ProducerOptions') = 1 then
    begin
      Value := GetStringFromHTML(Content, '<dt>released by</dt>',
                                 '<div>', '</div>');
      Value := UTF8Decode(Value);
    end;

    HTMLRemoveTags(Value);
    SetField(fieldProducer, Value);
  end;   }

  Descr.AppendFormat('%s - Rating: %s - Genres: %s (%s)', [sLength, sRating, sGenres, sCountry]).AppendLine;
  Descr.Append('Director: ' + sDirector).AppendLine.AppendLine;

  // Image
  Value := TextBetween(Page, '<img class="cover-art" src="', '" alt=');
  // don't bother getting the default "no-image"
  if ( (Length(Value) > 0) and (Pos('no-image', Value) = 0) ) then
    imageURL := Value;

  // get the center panel content -- this yields the plot synopsis
  Content := TextAfter(Page, '<div class="toggle-box">');
  Content := TextBetween(Content, '<p>', '</p>');

  // Plot synopsis
  if true then
  begin
    // store the author of the synopsis
    Dummy := TextBetween(Page, '<div class="tab-title">', '</div>');
    Dummy := StripHTMLTags(TextBetween(Dummy, '<span>', '</span>'));
    Dummy := TextAfter(Dummy, 'by ');

    Value := GetStringFromHTML('<p>' + Content + '</p>', '<p>', '<p>', '</p>');
    if (Length(Value) > 0) then
      Value := 'AMG SYNOPSIS: ' + Value + ' -- ' + Dummy + #13#10 + #13#10;
      Value := UTF8Decode(Value);

    Descr.Append(Value);
  end;

  // Cast -> actors
  if true then
  begin
    // get the page
    SubPage.Text := GetPage(Address + '/cast_crew');

    // get the center panel content -- this yields the Cast table
    Content := TextBetween(SubPage.Text, '<div class="description-box">', '</div>');
    Content := TextAfter(Content, '<h2>cast</h2>');
    Content := TextBetween(Content, '<table>', '</table>');

    Value := GetStringFromTable(Content, '~~ ', '||');
    Value := UTF8Decode(Value);

    if Length(Value) > 0 then
    begin
      // remove double spaces if only actor name given
      while Pos('  ', Value) > 0 do
        Delete(Value, Pos('  ', Value), 2);

     {if GetOption('CastOptions') = 1 then
      begin
        Value := StringReplaceAll(Value, '~~ ', ';');
        Value := StringReplaceAll(Value, '||', '-');
        SetField(fieldActors, Value);
      end;

      if GetOption('CastOptions') = 2 then
      begin
        Value := StringReplace(Value, '~~ ', #13#10);
        Value := StringReplaceAll(Value, '||', '-');
        if (Copy(Value, Length(Value) - 1, 2) = #13#10) then
          Value := Copy(Value, 0, Length(Value) - 2);
        SetField(fieldActors, Value);
      end;   }

      if true then
      begin
        Value := StringReplace(Value, '~~ ', #13#10, [rfReplaceAll]);
        Value := StringReplace(Value, '||', ' ... ', [rfReplaceAll]);
        if (Copy(Value, Length(Value) - 1, 2) = #13#10) then
          Value := Copy(Value, 0, Length(Value) - 2);
        Descr.AppendFormat('Cast:'+#13#10+'%s', [Value]).AppendLine;
      end;

      {if GetOption('CastOptions') = 4 then
      begin
        Value := StringReplace(Value, '~~ ', ')'+#13#10);
        Value := StringReplace(Value, '|| ', '(');
        if (Copy(Value, Length(Value) - 1, 2) = #13#10) then
          Value := Copy(Value, 0, Length(Value) - 2);
        SetField(fieldActors, Value);
      end;

      if GetOption('CastOptions') = 5 then
      begin
        Value := StringReplace(Value, '~~ ', '), ');
        Value := StringReplace(Value, '|| ', '(');
        if (Copy(Value, Length(Value) - 1, 2) = ', ') then
          Value := Copy(Value, 0, Length(Value) - 2);
        SetField(fieldActors, Value);
      end; }
    end;
  end;

  // Review -> description
  if true then
  begin
    // get the page
    SubPage.Text := GetPage(Address + '/review');

    // store the author of the synopsis
    Dummy := TextBetween(SubPage.Text, '<div class="tab-title">', '</div>');
    Dummy := StripHTMLTags(TextBetween(Dummy, '<span>', '</span>'));
    Dummy := TextAfter(Dummy, 'by ');

    // get the center panel content -- this yields the review
    Content := TextAfter(SubPage.Text, '<div class="toggle-box">');
    Content := TextBetween(Content, '<p>', '</p>');

    Value := GetStringFromHTML('<p>' + Content + '</p>', '<p>', '<p>', '</p>');
    if (Length(Value) > 0) then
      Value := 'AMG REVIEW: ' + Value + ' -- ' + Dummy + #13#10 + #13#10;
      Value := UTF8Decode(Value);

    Descr.Append(#13#10 + Value);
  end;

  // Awards -> description
  if false then
  begin
    // get the page
    SubPage.Text := GetPage(Address + '/awards');

    // get the awards panel content -- this yields the awards
    Content := TextAfter(SubPage.Text, '<div class="awards-box">');

    Value := GetStringFromAwardsTable(Content, '~~ ', '||');
    Value := UTF8Decode(Value);

    Value := StringReplace(Value, '~~ ', #13#10, [rfReplaceAll]);
    Value := StringReplace(Value, '||', ' - ', [rfReplaceAll]);

    if Length(Value) > 0 then
    begin
      Descr.Append('AWARDS:' +#13#10 + Value + #13#10);
    end;
  end;

  // ProductionCredits -> Comments/Description
  if true then
  begin
    // get the page
    SubPage.Text := GetPage(Address + '/cast_crew');

    // get the center panel content -- this yields the Cast table
    Content := TextBetween(SubPage.Text, '<div class="profession-box">', '</div>');
    Content := TextAfter(Content, '<h2>crew</h2>');
    Content := TextBetween(Content, '<dl>', '</dl>');

    // transform the weirdly formatted list into a pseudo table so we can
    // reuse existing code
    Content := StringReplace(Content, '<dt>', '<tr><td>', [rfReplaceAll]);
    Content := StringReplace(Content, '</dd>', '</td></tr>', [rfReplaceAll]);
    Content := StringReplace(Content, '</dt>', '</td>', [rfReplaceAll]);
    Content := StringReplace(Content, '<dd>', '<td>', [rfReplaceAll]);

    Value := GetStringFromTable(Content, '~~ ', '||');
    Value := UTF8Decode(Value);

    if Length(Value) > 0 then
    begin
      // remove double spaces if only name given
      while Pos('  ', Value) > 0 do
        Delete(Value, Pos('  ', Value), 2);

      {if GetOption('CreditsOptions') = 1 then
      begin
        Value := StringReplace(Value, '~~ ', #13#10);
        Value := StringReplaceAll(Value, '||', '-');
        if (Copy(Value, Length(Value) - 1, 2) = #13#10) then
          Value := Copy(Value, 0, Length(Value) - 2);
      end; }

      if true then
      begin
        Value := StringReplace(Value, '~~ ', #13#10, [rfReplaceAll]);
        Value := StringReplace(Value, '||', ' ... ', [rfReplaceAll]);
        if (Copy(Value, Length(Value) - 1, 2) = #13#10) then
          Value := Copy(Value, 0, Length(Value) - 2);
      end;

      {if GetOption('CreditsOptions') = 3 then
      begin
        Value := StringReplace(Value, '~~ ', ')'+#13#10);
        Value := StringReplace(Value, '|| ', '(');
        if (Copy(Value, Length(Value) - 1, 2) = #13#10) then
          Value := Copy(Value, 0, Length(Value) - 2);
        SetField(fieldActors, Value);
      end; }

      Descr.Append('PRODUCTION CREDITS:' +#13#10 + Value);
    end;
  end;

  SubPage.Free;

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
    tempFile := CutAt(tempFile, '?');
    if FileExists(tempFile) then
      DeleteFile(PWideChar(tempFile));
    GetImage(imageURL, tempFile);

    SaveImageToDB(Self, Product, PWideChar(tempFile));
    DeleteFile(PWideChar(tempFile));
  end;
end;

// Adds movie titles from search results to tree
procedure AddMoviesTitles(Title : string; NumResults: Integer);
var
  PageText : string;
  SearchAddress : string;
  MovieTitle, MovieAddress, MovieYear, Temp: string;
  Item: TDescriptorProductInfo;
begin
  SetLength(foundItems, 0);

  SearchAddress := 'http://www.allrovi.com/search/ajax_more_results/movies/' +
                   Title + '/0/' + IntToStr(NumResults);
  PageText := GetPage(SearchAddress);

  // Every movie entry begins with string "<tr>"
  while Pos('<tr>', PageText) > 0 do
  begin
    Temp := TextBetween(PageText, '<td class="title">', '</td>');
    MovieAddress := TextBetween(Temp, '<a href="', '">');
    MovieTitle := GetStringFromHTML(Temp, '">', '">', '</a>');
    Temp := TextBetween(PageText, '<td class="year">', '</td>');
    MovieYear := Trim(Temp);
    MovieTitle := MovieTitle + ' (' + MovieYear + ')';
    // remove the entry we just processed
    CutAfter(PageText, '</tr>');

    // add movie to list
    Item.Name := StrNew(PWideChar(MovieTitle));
    Item.URL := StrNew(PWideChar(MovieAddress));
    Item.Description := nil;
    Item.Image := nil;

    SetLength(foundItems, Length(foundItems) + 1);
    foundItems[Length(foundItems) - 1] := Item;
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

function StrOccurs(Text, SearchText: string) : integer;
var
   loc, len : integer;
begin
  result := 0;
  len       := length(SearchText);
  loc       := 1;
  repeat
    loc := Pos(SearchText, Text);
    if loc > 0 then
    begin
      result := result + 1;
      loc  := loc + len;
      Text := Copy(Text, loc, Length(Text) - loc);
    end;
  until(loc <= 0);
end;

function RemoveWhiteSpace(S : string) : string;
begin
    Result := StringReplace(S, #9, '', [rfReplaceAll]);
    Result := StringReplace(Result, #13#10, '', [rfReplaceAll]);
    Result := Trim(Result);
end;


function GetStringFromList(Content, Delimiter: string): string;
var
  Data : string;
begin
    while(true) do
    begin
      Data := TextBetween(Content, '<li>', '</li>');
      if (Length(Data) = 0) then
        break;
      Data := StripHTMLTags(Data);
      Data := RemoveWhiteSpace(Data);
      Result := Result + Data + Delimiter + ' ';
      Content := TextAfter(Content, '</li>');
    end;
    // remove trailing delimiter
    Result := Trim(Result);
    if (Copy(Result, Length(Result), 1) = Delimiter) then
      Result := Copy(Result, 0, Length(Result) - 1);
end;

function GetStringFromTable(Content, Delimiter, ColDelim : string): string;
var
  Data   : string;
  ColLen : Integer;
begin
  Content  := StringReplace(Content, '<TR >', '<tr>', [rfReplaceAll]);
  Content  := StringReplace(Content, '<TR>', '<tr>', [rfReplaceAll]);
  Content  := StringReplace(Content, '</TR>', '</tr>', [rfReplaceAll]);
  ColLen   := Length(ColDelim);
  Result   := '';

  while(true) do
  begin
    Data := TextBetween(Content, '<tr>', '</tr>');
    // make a unique delimiter between character and name
    Data := StringReplace(Data, '</td>', ColDelim, [rfReplaceAll]);

    Data := StripHTMLTags(Data);
    HTMLDecode(Data);

    if (Length(Data) = 0) then
      break;

    Data := RemoveWhiteSpace(Data);

    // make sure we don't start with the ColDelim
    if (Copy(Data, 0, ColLen) = ColDelim) then
      Data := Copy(Data, ColLen + 1, Length(Data));
    // make sure we don't end with the ColDelim
    if (Copy(Data, Length(Data) - ColLen + 1, ColLen) = ColDelim) then
      Data := Copy(Data, 1, Length(Data) - ColLen);

    Content := TextAfter(Content, '</tr>');
    Result  := Result + Data + Delimiter;
  end;
end;

function GetStringFromAwardsTable(Content, Delimiter, ColDelim : string): string;
var
  Data       : string;
  RowData    : string;
  ColLen     : Integer;
  AwardTitle : string;
  AwardType  : string;
  AwardRecps : string;
  AwardYear  : string;
  Presenter  : string;
begin
  Content  := StringReplace(Content, 'class="award-status won"', 'class="award-status"', [rfReplaceAll]);
  ColLen   := Length(ColDelim);
  Result   := '';

  while(true) do
  begin
    Data      := TextBetween(Content, '<table class="movie-awards">', '</table>');
    Presenter := Trim( TextBetween(Content, '<h3 class="award">', '</h3>') );

    HTMLDecode(Data);

    if (Length(Data) = 0) then
      break;

    Data := RemoveWhiteSpace(Data);
    RowData := Data;

    while(true) do
    begin
      Data := TextBetween(RowData, '<tr>', '</tr>');

      if (Length(Data) = 0) then
        break;

      AwardType  := Trim( TextBetween(Data, '<td class="award-status">', '</td>') );
      AwardTitle := Trim( TextBetween(Data, '<td class="award-title">', '<div class="recipients">') );
      AwardRecps := Trim( TextBetween(Data, '<div class="recipients">', '</div>') );
      AwardYear  := Trim( TextBetween(Data, '<td class="year">', '</td>') );

      AwardTitle := StripHTMLTags(AwardTitle);
      AwardRecps := StripHTMLTags(AwardRecps);

      if (Length(AwardType) > 0) then
        AwardType := ' (' + AwardType + ')';

      Data       := AwardTitle + AwardType + ColDelim + AwardRecps + ColDelim + AwardYear + ColDelim + Presenter;
      Result     := Result + Trim(Data) + Delimiter;
      RowData    := TextAfter(RowData, '</tr>');
    end;

    Content := TextAfter(Content, '</table>');
  end;
end;

end.
