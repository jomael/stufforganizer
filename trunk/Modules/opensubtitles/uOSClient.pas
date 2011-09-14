(*
	  This file is part of Stuff Organizer.

    Copyright (C) 2011  Ice Apps <so.iceapps@gmail.com>

    Stuff Organizer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Stuff Organizer is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Stuff Organizer.  If not, see <http://www.gnu.org/licenses/>.
*)
unit uOSClient;

interface

uses
  SysUtils, Windows, Dialogs, Classes, IcePack, IceXML, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, PerlRegEx{RegularExpressions};

type
  TSubtitle = record
    ID: string;
    MovieID: string;
    ImdbID: string;
    Lang: string;
    LangName: string;
    Name: string;
    FileName: string;
    MovieReleaseName: string;
    SubFormat: string;
    AuthorComment: string;
    TimeStamp: TDateTime;
    Rating: string;
    DownloadCount: integer;
    Year: integer;
    ImdbRating: string;
    DownloadLink: string;
    OrigFilename: string;
  end;

  TSubtitles = array of TSubtitle;
  PSubtitles = ^TSubtitles;


  TOSClient = class(TObject)
  const
    RPC_PATH = 'http://api.opensubtitles.org/xml-rpc';
    OSSupportedExtensions = '*.3g2, *.3gp, *.3gp2, *.3gpp, *.60d, *.ajp, *.asf, *.asx, *.avchd, *.avi, *.bik, *.bix, '+
      '*.box, *.cam, *.dat, *.divx, *.dmf, *.dv, *.dvr-ms, *.evo, *.flc, *.fli, *.flic, *.flv, *.flx, *.gvi, *.gvp, *.h264, '+
      '*.m1v, *.m2p, *.m2ts, *.m2v, *.m4e, *.m4v, *.mjp, *.mjpeg, *.mjpg, *.mkv, *.moov, *.mov, *.movhd, *.movie, *.movx, *.mp4, '+
      '*.mpe, *.mpeg, *.mpg, *.mpv, *.mpv2, *.mxf, *.nsv, *.nut, *.ogg, *.ogm, *.omf, *.ps, *.qt, *.ram, *.rm, *.rmvb, *.swf, *.ts, '+
      '*.vfw, *.vid, *.video, *.viv, *.vivo, *.vob, *.vro, *.wm, *.wmv, *.wmx, *.wrap, *.wvx, *.wx, *.x264, *.xvid';
  private
    HTTP: TIdHTTP;
    FToken: string;
    FLanguages: string;
    function GetMemberValue(Root: TXMLItem; memberName: string): string;
    function GetMember(Root: TXMLItem; memberName: string): TXMLItem;
    function SearchSubTitles(movieHash: string; movieSize: Cardinal;
      ImdbID: string; Subtitles: PSubtitles): boolean; overload;
    procedure SetLanguages(const Value: string);
    function GetImdbIDFromNFO(FileName: string): string;
  protected
    function RemoteCall(xml: TIceXML): integer;
  public
    property Languages: string read FLanguages write SetLanguages;

    constructor Create;
    destructor Destroy; override;

    function GetSubtitles(DirectoryName: string): TSubtitles;

    function Login: boolean;
    function Logout: boolean;

    function CheckMovieHash(movieHash: string; var ImdbID: string): boolean;
    function SearchSubTitles(ImdbID: string; Subtitles: PSubtitles): boolean; overload;
    function SearchSubTitles(movieHash: string; movieSize: Cardinal; Subtitles: PSubtitles): boolean; overload;

    function GetIMDBMovieDetails( ImdbID: string ): boolean;
  end;

function CalcGabestHash(const fname: string): string;

implementation


{$REGION 'HASH calculator'}
function CalcGabestHash(const fname: string): string;
var
  i : integer;
  s : array[1..8] of ansichar;
  tmp       : Int64 absolute s;
  hash      : Int64;
  readed    : integer;

  aStream: TFileStream;
begin
  result := '';
  if not FileExists(fname) then Exit;
  if GetFileSize(fname) < 128 * 1024 then Exit;
  

  aStream := TFileStream.Create(fName, fmShareDenyNone);
  hash := aStream.Size;

  i := 0; readed := 1;
  while ((i < 8192) and (readed > 0)) do begin
    readed := aStream.Read(s, sizeof(s));
    if readed > 0 then
    begin
      hash := hash + tmp;
    end;
    i := i + 1;
  end;

  aStream.Seek(-65536, soFromEnd); // 65536

  i := 0; readed:= 1;
  while ((i < 8192) and (readed > 0)) do begin
    readed := aStream.Read(s, sizeof(s));
    if readed > 0 then
      hash := hash + tmp;
    i := i + 1;
  end;
  aStream.Free;
  result := LowerCase(Format('%.16x',[hash]));
end;

{$ENDREGION}

{ TOSClient }

function TOSClient.CheckMovieHash(movieHash: string;
  var ImdbID: string): boolean;
var
  xml: TIceXML;
  params, param: TXMLItem;
  responseData, member, items: TXMLItem;
  memberValue: string;
  iResult: integer;
begin
  result := false;
  ImdbID := '';
  xml := TIceXML.Create(nil);
  try
    xml.Root.Name := 'methodCall';
    xml.Root.SetItemValue('methodName', 'CheckMovieHash');
    params := xml.Root.GetItemEx('params', true);
    params.New('param').SetItemValue('value.string', FToken);

    param := params.New('param').SetItemValue('value.array.data.value.string', movieHash);

    iResult := RemoteCall(xml);
    if iResult = 200 then
    begin
      responseData := xml.Root.GetItemEx('params.param.value.struct');
      if Assigned(responseData) then
      begin
        member := GetMember(responseData, 'data');
        if Assigned(member) then
        begin
          items := member.GetItemEx('value.struct');
          if Assigned(items) then
          begin
            member := GetMember(items, movieHash);
            if Assigned(member) then
            begin
              ImdbID := GetMemberValue(member.GetItemEx('value.struct', true), 'MovieImdbID');

              result := true;
            end;
          end;
        end;
      end;
    end;
  finally
    xml.Free;
  end;
end;

constructor TOSClient.Create;
begin
  FLanguages := 'eng';

  HTTP := TIdHTTP.Create(nil);
end;

destructor TOSClient.Destroy;
begin
  HTTP.Free;

  inherited;
end;

function TOSClient.GetIMDBMovieDetails(ImdbID: string): boolean;
begin

end;

function TOSClient.GetMember(Root: TXMLItem; memberName: string): TXMLItem;
var
  I: Integer;
begin
  result := nil;
  for I := 0 to Root.Count - 1 do
    if Root[I].GetItemValue('name', '') = memberName then
      Exit(Root[I]);
end;

function TOSClient.GetMemberValue(Root: TXMLItem; memberName: string): string;
var
  I: Integer;
  member: TXMLItem;
begin
  result := '';
  member := GetMember(Root, memberName);
  if Assigned(member) then
    result := member.GetItemEx('value', true)[0].Text;
end;

function TOSClient.GetSubtitles(DirectoryName: string): TSubtitles;
var
  Files: TStrings;
  I: Integer;
  bRes: boolean;
  movieHash, ImdbID, fileImdbID: string;
  movieSize: Cardinal;
  J: Integer;
  tmpSub: TSubtitle;
begin
  if DirectoryExists(DirectoryName) then
  begin
    Files := IcePack.GetFiles(DirectoryName, '*.*', true);
    for I := Files.Count - 1 downto 0 do
    begin
      if LowerCase(ExtractFileExt(Files[I])) = '.nfo' then
      begin
        fileImdbID := GetImdbIDFromNFO(Files[I]);
      end;

      if Pos(LowerCase(ExtractFileExt(Files[I])), OSSupportedExtensions) = 0 then
        Files.Delete(I)
    end;

    ImdbID := '';
    SetLength(result, 0);
    for I := 0 to Files.Count - 1 do
    begin
      movieHash := CalcGabestHash(Files[I]);
      movieSize := GetFileSize(Files[I]);
      if movieHash <> '' then
      begin
        bRes := CheckMovieHash(movieHash, imdbID);
        if imdbID = '' then imdbID := fileImdbID;

        if (imdbID <> '') then
        begin
          bRes := SearchSubTitles(movieHash, movieSize, @result);
          if Length(result) = 0 then
            bRes := SearchSubTitles(imdbID, @result);
          if bRes then
          begin
            //if filenames same then move to first as relevant subtitle
            for J := Low(result) to High(result) do
            begin
              result[J].OrigFilename := Files[I];
              if (Pos(LowerCase(result[J].MovieReleaseName), LowerCase(Files[I])) > 0) and (J <> 0) then
              begin
                tmpSub := result[0];
                result[0] := result[J];
                result[J] := tmpSub;

                break;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TOSClient.GetImdbIDFromNFO(FileName: string): string;
var
  Content: TStringList;
  RegEx: TPerlRegEx;
begin
  result := '';
  Content := TStringList.Create;
  try
    Content.LoadFromFile(FileName);
    //    /imdb\.[^\/]+\/title\/tt(\d+)/i
    RegEx := TPerlRegEx.Create();
    RegEx.RegEx := 'imdb\.[^\/]+\/title\/tt(\d+)';
    RegEx.Options := [preCaseLess];
    RegEx.Subject := Content.Text;
    if RegEx.Match and (RegEx.GroupCount > 0) then
    begin
      result := RegEx.Groups[1];
    end;
  finally
    Content.Free;
  end;
end;

{function TOSClient.GetImdbIDFromNFO(FileName: string): string;
var
  Content: TStringList;
  RegEx: TRegEx;
  Match: TMatch;
begin
  result := '';
  Content := TStringList.Create;
  try
    Content.LoadFromFile(FileName);
    //    /imdb\.[^\/]+\/title\/tt(\d+)/i
    RegEx := TRegEx.Create('imdb\.[^\/]+\/title\/tt(\d+)', [roIgnoreCase, roMultiLine]);
    Match := Regex.Match(Content.Text);
    if Match.Success and (Match.Groups.Count = 2) then
      result := Match.Groups[1].Value;
  finally
    Content.Free;
  end;
end;}

function TOSClient.Login: boolean;
var
  xml: TIceXML;
  params, param: TXMLItem;
  responseData, member: TXMLItem;
  memberValue: string;
  iResult: integer;
begin
  result := false;
  xml := TIceXML.Create(nil);
  try
    xml.Root.Name := 'methodCall';
    xml.Root.SetItemValue('methodName', 'LogIn');
    params := xml.Root.GetItemEx('params', true);
    params.New('param').SetItemValue('value.string', '');
    params.New('param').SetItemValue('value.string', '');
    params.New('param').SetItemValue('value.string', 'en');
    params.New('param').SetItemValue('value.string', 'Stuff Organizer v0.4.5');

    iResult := RemoteCall(xml);
    if iResult = 200 then
    begin
      responseData := xml.Root.GetItemEx('params.param.value.struct');
      if Assigned(responseData) then
      begin
        FToken := GetMemberValue(responseData, 'token');
        result := true;
      end;
    end;
  finally
    xml.Free;
  end;
end;

function TOSClient.Logout: boolean;
var
  xml: TIceXML;
  params, param: TXMLItem;
  responseData, member: TXMLItem;
  memberValue: string;
  iResult: integer;
begin
  result := false;
  xml := TIceXML.Create(nil);
  try
    xml.Root.Name := 'methodCall';
    xml.Root.SetItemValue('methodName', 'LogOut');
    params := xml.Root.GetItemEx('params', true);
    params.New('param').SetItemValue('value.string', FToken);

    iResult := RemoteCall(xml);
    if iResult = 200 then
    begin
      result := true;
    end;
  finally
    xml.Free;
  end;
end;

function TOSClient.RemoteCall(xml: TIceXML): integer;
var
  Source, Response: TMemoryStream;
  Status, StatusCode: string;
  members: TXMLItem;
begin
  result := -1;
  try
    Source := TMemoryStream.Create;
    Response := TMemoryStream.Create;
    try
      xml.SaveToStream(Source);
      Source.Position := 0;
      //rm10.memo1.lines.add(xml.SaveToString);

      http.Post(RPC_PATH, Source, Response);

      Response.Position := 0;
      xml.LoadFromStream(Response);
      //rm10.memo1.lines.add(xml.SaveToString);

      //Get status code
      if xml.Root.Name = 'methodResponse' then
      begin
        members := xml.Root.GetItemEx('params.param.value.struct');
        if Assigned(members) then
        begin
          Status := GetMemberValue(members, 'status');
          if Status <> '' then
          begin
            StatusCode := CutAt(Status, ' ');
            result := StrToIntDef(StatusCode, -1);
          end;
        end;
      end;
    finally
      Source.Free;
      Response.Free;
    end;
  except
    on E: Exception do
    begin


    end;
  end;
end;

function TOSClient.SearchSubTitles(ImdbID: string; Subtitles: PSubtitles): boolean;
begin
  result := SearchSubTitles('', 0, ImdbID, Subtitles);
end;

function TOSClient.SearchSubTitles(movieHash: string;
  movieSize: Cardinal; Subtitles: PSubtitles): boolean;
begin
  result := SearchSubTitles(movieHash, movieSize, '', Subtitles);
end;

procedure TOSClient.SetLanguages(const Value: string);
begin
  FLanguages := Value;
end;

function TOSClient.SearchSubTitles(movieHash: string;
  movieSize: Cardinal; ImdbID: string; Subtitles: PSubtitles): boolean;
var
  xml: TIceXML;
  params, param: TXMLItem;
  responseData, member, items: TXMLItem;
  memberValue, SubID: string;
  iResult: integer;
  I: Integer;
  J: Integer;
begin
  result := false;
  xml := TIceXML.Create(nil);
  try
    xml.Root.Name := 'methodCall';
    xml.Root.SetItemValue('methodName', 'SearchSubtitles');
    params := xml.Root.GetItemEx('params', true);
    params.New('param').SetItemValue('value.string', FToken);

    param := params.New('param');
    param := param.GetItemEx('value.array.data.value.struct', true);
    member := param.New('member');
    member.SetItemValue('name', 'sublanguageid');
    member.SetItemValue('value.string', FLanguages);
    if ImdbID = '' then
    begin
      member := param.New('member');
      member.SetItemValue('name', 'moviehash');
      member.SetItemValue('value.string', movieHash);
      member := param.New('member');
      member.SetItemValue('name', 'moviebytesize');
      member.SetItemValue('value.double', movieSize);
    end
    else
    begin
      member := param.New('member');
      member.SetItemValue('name', 'imdbid');
      member.SetItemValue('value.string', ImdbID);
    end;

    iResult := RemoteCall(xml);
    if iResult = 200 then
    begin
      responseData := xml.Root.GetItemEx('params.param.value.struct');
      if Assigned(responseData) then
      begin
        member := GetMember(responseData, 'data');
        if Assigned(member) then
        begin
          items := member.GetItemEx('value.array.data');
          if Assigned(items) then
          begin
            for I := 0 to items.Count - 1 do
            begin
              member := items[i].GetItemEx('struct');
              if Assigned(member) then
              begin
                //Check if SubID exists
                SubID := GetMemberValue(member, 'IDSubtitleFile');
                for J := Low(Subtitles^) to High(Subtitles^) do
                  if Subtitles^[J].ID = SubID then continue;

                result := true;
                SetLength(Subtitles^, Length(Subtitles^) + 1);
                Subtitles^[High(Subtitles^)].ID := GetMemberValue(member, 'IDSubtitleFile');
                Subtitles^[High(Subtitles^)].Name := GetMemberValue(member, 'MovieName');
                Subtitles^[High(Subtitles^)].MovieID := GetMemberValue(member, 'IDMovie');
                Subtitles^[High(Subtitles^)].ImdbID := GetMemberValue(member, 'IDMovieImdb');
                Subtitles^[High(Subtitles^)].Lang := GetMemberValue(member, 'ISO639');
                Subtitles^[High(Subtitles^)].LangName := GetMemberValue(member, 'LanguageName');
                Subtitles^[High(Subtitles^)].FileName := GetMemberValue(member, 'SubFileName');
                Subtitles^[High(Subtitles^)].MovieReleaseName := GetMemberValue(member, 'MovieReleaseName');
                Subtitles^[High(Subtitles^)].SubFormat := GetMemberValue(member, 'SubFormat');
                Subtitles^[High(Subtitles^)].AuthorComment := GetMemberValue(member, 'SubAuthorComment');
                Subtitles^[High(Subtitles^)].TimeStamp := IcePack.StrToDateTime(GetMemberValue(member, 'SubAddDate'), 'yyyy-mm-dd hh:nn:ss');
                Subtitles^[High(Subtitles^)].Rating := GetMemberValue(member, 'SubRating');
                Subtitles^[High(Subtitles^)].DownloadCount := StrToIntDef(GetMemberValue(member, 'SubDownloadsCnt'), 0);
                Subtitles^[High(Subtitles^)].Year := StrToIntDef(GetMemberValue(member, 'MovieYear'), 0);;
                Subtitles^[High(Subtitles^)].ImdbRating := GetMemberValue(member, 'MovieImdbRating');
                Subtitles^[High(Subtitles^)].DownloadLink := GetMemberValue(member, 'ZipDownloadLink');
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    xml.Free;
  end;
end;


end.
