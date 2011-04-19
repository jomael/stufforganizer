unit uSearchInfo;

interface

uses
  Classes, SysUtils, Windows, Messages, Dialogs, SOPluginDefs, IcePack,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  StrUtils, IceXML;

var
  Self: Pointer;
  Product: PPluginProductItem;
  SaveImageToDB: TDescriptorSaveImage;
  SaveProductInfoToDB: TDescriptorSaveProductInfo;
  UserSelect: TDescriptorUserSelect;

  MovieName: string;
//  BeginPos, EndPos: Integer;

  foundItems: TDescriptorProductInfoArray;

procedure AnalyzeMoviePage(URL: string; Page: TStringList);
function GetPage(Address: string): string;
procedure GetImage(Address: string; FileName: string);
procedure HTMLDecode(var S: string);
function FindLine(Pattern: string; List: TStringList; StartAt: Integer): Integer;
function GetName(Page: TStringList; SearchStr: string): string;
procedure AnalyzePage(Address: string);
procedure AddMoviesTitles(Page: TStringList; Tag: string);
function UserSelectFromList: integer;
procedure FreeFoundItems;
function GenerateAutoTags(Name: string): string;

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

procedure HTMLDecode(var S: string);
begin
  S := DecodeEntities(S);
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
  if pos('Nincs ilyen címû film', Page.Text) <> 0 then
     showmessage('Nincs ilyen címû film a PORT adatbázisban.')
  else
  begin
    if pos('navigation string', Page.Text) = 0 then
    begin
      AnalyzeMoviePage(Address, Page);
    end else
    begin
      AddMoviesTitles(Page,'/pls/fi/films.film_page');

      if Length(foundItems) > 0 then
      begin
        SelectedIndex := UserSelectFromList;
        if SelectedIndex <> -1 then
        begin
          Address := foundItems[SelectedIndex].URL;
          UrlEncode(Address, false);
          Address := StringReplace(Address, '&amp;', 'xxampxx', [rfReplaceAll, rfIgnoreCase]);
          Address := StringReplace(Address, '&', 'xxampxx', [rfReplaceAll, rfIgnoreCase]);
          HTMLDecode(Address);
          Address := StringReplace(Address, 'xxampxx', '&', [rfReplaceAll, rfIgnoreCase]);
          AnalyzePage(Address);

          FreeFoundItems;
        end;
      end
      else
        ShowMessage('Nem található ilyen címû film!');
    end;
  end;
  Page.Free;
end;

function UserSelectFromList: integer;
begin
  result := UserSelect(Self, @foundItems);
end;

procedure AnalyzeMoviePage(URL: string; Page: TStringList);
var
  Line, Line2, Temp, Value, Value2, FullValue, CommentString, Lang, Tags: string;
  Title1, Title2: string;
  LineNr, BeginPos, EndPos, I: Integer;
  Descr: TStringBuilder;
  tempFile: string;
begin
  Descr := TStringBuilder.Create;
  Product.URL := PWideChar(URL);
  Product.Modified := true;
  Value := '';
  //hungarian title
  LineNr := FindLine('blackbigtitle">', Page, 0);
  if LineNr > -1 then
  begin
    Line := Page[LineNr];
    BeginPos := pos('blackbigtitle">', Line)+15;
    EndPos := pos('</h1>', Line);
    Value := copy(Line, BeginPos, EndPos - BeginPos);
    Title1 := StripHTMLtags(Value);
  end;

  Title2 := '';
  //original title
  LineNr := LineNr + 1;
  Line := Page[LineNr];
  BeginPos := pos('"txt">(', Line)+7;
  EndPos := pos(')', Line);
  if pos('"txt">(', Line) <> 0 then
    Title2 := copy(Line, BeginPos, EndPos - BeginPos);
  if (Title2 <> '') then
  begin
    Title2 := StripHTMLtags(Title2);
  end;

  if (Title1 <> '') and (Title2 <> '') then
    Product.Name := PWideChar(Format('%s (%s)', [Title1, Title2]))
  else if Title1 <> '' then
    Product.Name := PWideChar(Title1)
  else if Title2 <> '' then
    Product.Name := PWideChar(Title2);

  LineNr := FindLine('perc, ', Page, 0);
  if LineNr > -1 then
  begin
    Line := Page[LineNr];
    BeginPos := pos('"txt">', Line)+6;
    EndPos := pos('</span>', Line);
    Value := Trim(copy(Line, BeginPos, EndPos - BeginPos));
    Descr.AppendFormat('%s'+#13#10, [Value]);
  end;

  //description
  BeginPos:=0;
  Line := '';

  repeat
    LineNr := FindLine('<div class="separator"></div>', Page, BeginPos);
    Line := Page[LineNr+1];
    BeginPos := LineNr+1;
  until (Line = '     <td>') or (pos('<span class="txt">', Line) > 0) or (LineNr=-1);
  if (LineNr>-1) then begin
    Line := Page[LineNr+1];
    if ((copy(Line, 0, 18)<>'<span class="txt">') or (copy(Line, 19, 1)=' ')  or (copy(Line, 19, 7)='</span>')) then
      Line := ''
    else LineNr:=0;
  end else begin
    Line := '';
  end;

  if Line <> '' then
  begin
    BeginPos := pos('"txt">', Line)+6;
    Delete(Line, 1, BeginPos-1);
    EndPos := pos('</span>', Line)-1;
    Value := copy(Line, 0, EndPos);
    Value := StringReplace(Value, '<BR>', #13#10, [rfReplaceAll, rfIgnoreCase]);
    Value := StripHTMLtags(Value);
    Descr.AppendLine;
    Descr.AppendFormat('%s'+#13#10, [Value]);
  end;

  //actors
  LineNr := FindLine('>szerepl', Page, 0);
  if LineNr > -1 then
  begin
    i:=0;
    Value := '';
    repeat
      Line := Page[LineNr+i];
      BeginPos := pos('szerepl', Line)+11;
      Delete(Line, 1, BeginPos-1);

      BeginPos := pos('<span class="txt">', Line)+18;
      Delete(Line, 1, BeginPos-1);

      EndPos := pos('</span>', Line);
      Value := Value + Line;
      i:=i+1;
    until ((EndPos>0) or (i>50));
    Value := StringReplace(Value, '<br />', #13#10, [rfReplaceAll, rfIgnoreCase]);
    Value := StripHTMLtags(Value);
    HTMLDecode(Value);
    Descr.AppendLine;
    Descr.Append('Szereplõk:').AppendLine;
    Descr.Append(Value).AppendLine;
  end;


  //comments
  CommentString := '';

  //comments - director
  Value := GetName(Page, 'rendez');
  if Value<>'' then
    CommentString := CommentString+'Rendezõ: '+Value+#13#10;

  //comments - producer
  Value := GetName(Page, 'producer');
  if Value<>'' then
    CommentString := CommentString+'Producer: '+Value+#13#10;

  //comments - writer
  Value := GetName(Page, 'író');
  if Value<>'' then
    CommentString := CommentString+'Író: '+Value+#13#10;

  //comments - screenwriter
  Value := GetName(Page, 'forgatókönyvíró');
  if Value<>'' then
    CommentString := CommentString+'Forgatókönyvíró: '+Value+#13#10;

  //comments - cameraman
  Value := GetName(Page, 'operat');
  if Value<>'' then
    CommentString := CommentString+'Operatõr: '+Value+#13#10;

  //comments - ?? designer
  Value := GetName(Page, 'díszlettervez');
  if Value<>'' then
    CommentString := CommentString+'Díszlettervezõ: '+Value+#13#10;

  //comments - costum designer
  Value := GetName(Page, 'jelmeztervez');
  if Value<>'' then
    CommentString := CommentString+'Jelmeztervezõ: '+Value+#13#10;

  //comments - music
  Value := GetName(Page, 'zeneszerz');
  if Value<>'' then
    CommentString := CommentString+'Zeneszerzõ: '+Value+#13#10;

  //comments - executive producer
  Value := GetName(Page, 'executive producer');
  if Value<>'' then
    CommentString := CommentString+'Executive producer: '+Value+#13#10;

  //comments - cutter
  Value := GetName(Page, 'vágó');
  if Value<>'' then
    CommentString := CommentString+'Vágó: '+Value+#13#10;

  //comments - ??
  Value := GetName(Page, 'látványtervez');
  if Value<>'' then
    CommentString := CommentString+'Látványtervezõ: '+Value+#13#10;

  //SetField(fieldComments, CommentString);
  Descr.AppendLine;
  Descr.AppendFormat('%s', [CommentString]);

  Product.Description := PWideChar(Trim(Descr.ToString));
  Product.Modified := true;
  Descr.Free;

  Tags := GenerateAutoTags(Product.Name);
  Product.Tags := PWideChar(Tags);
  //Save new product info
  SaveProductInfoToDB(Self, Product);

  //picture
  LineNr := FindLine('class="object_picture" src', Page, 0);
  if LineNr = -1 then LineNr := FindLine('src="http://media.port-network.com/picture/instance_', Page, 0);
  if LineNr > -1 then
  begin
    Line := Page[LineNr];
    BeginPos := pos('src="http://media.port-network.com/picture/instance_', Line) + 5;
    Delete(Line, 1, BeginPos-1);
    EndPos := pos('"', Line);
    Value := copy(Line, 1, EndPos - 1);
    if pos('http://media.port-network.com/picture/instance_', Value)<>0 then begin
      Value := StringReplace(Value, '_2', '_1', [rfReplaceAll, rfIgnoreCase]);
      Value := StringReplace(Value, '_3', '_1', [rfReplaceAll, rfIgnoreCase]);
      Value := StringReplace(Value, '_4', '_1', [rfReplaceAll, rfIgnoreCase]);
    end;
    tempFile := IncludeTrailingBackslash(IcePack.GetTempDirectory) + ExtractUrlFileName(Value);
    if FileExists(tempFile) then
      DeleteFile(PWideChar(tempFile));
    GetImage(Value, tempFile);

    SaveImageToDB(Self, Product, PWideChar(tempFile));
    DeleteFile(PWideChar(tempFile));
  end;
end;

procedure AddMoviesTitles(Page: TStringList; Tag: string);
var
  Line: string;
  LineNr, Len: Integer;
  MovieTitle, OriTitle, MovieAddress, MovieInfo: string;
  StartPos, EndPos: Integer;
  Item: TDescriptorProductInfo;
  pTitle, pURL: PWideChar;
begin
  SetLength(foundItems, 0);
  LineNr := FindLine(tag, Page, 0);
  if LineNr > -1 then
  begin
    //PickTreeAdd('Találatok:', '');
    Line := Page[LineNr];
    repeat
      StartPos := pos('"btxt"><a href="', Line) + 15;
      Delete(Line, 1, StartPos);
      MovieAddress := 'http://port.hu' + Copy(Line, 1, pos('" target="', Line) - 1);
      StartPos := Pos('target="_top">', Line) + 14;
      MovieTitle := Copy(Line, StartPos, Pos('</a>', Line) - StartPos);
      StartPos := Pos('</a>', Line) + 5;
      if ( Pos('</a> (',Line)>0) then
      begin
        OriTitle := Copy(Line, (StartPos+1), Pos(')</span>', Line) - (StartPos+1));
      end else begin
        OriTitle := MovieTitle;
      end;
      MovieInfo:='';
      StartPos := Pos('"txt"> (', Line) +8;
      Delete(Line, 1, StartPos-1);
      EndPos := Pos(') </span>', Line);
      MovieInfo := copy(Line, 1, EndPos-1);
      MovieTitle:=MovieTitle+' ('+OriTitle+')';
      HTMLDecode(Movietitle);
      HTMLDecode(MovieInfo);

      Item.Name := StrNew(PWideChar(MovieTitle));
      Item.URL := StrNew(PWideChar(MovieAddress));
      Item.Description := StrNew(PWideChar(MovieInfo));
      Item.Image := nil;

      SetLength(foundItems, Length(foundItems) + 1);
      foundItems[Length(foundItems) - 1] := Item;

      LineNr := FindLine(tag, Page, LineNr+1);
      if LineNr > -1 then
        Line := Page[LineNr]
      else
        Line := '';
    until Line = '';
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
