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
  StrUtils, uOSClient, uISO639, sevenzip;


var
  Self: Pointer;
  Product: PPluginProductItem;
  SaveImageToDB: TDescriptorSaveImage;
  SaveProductInfoToDB: TDescriptorSaveProductInfo;
  UserSelect: TDescriptorUserSelect;

  MovieName: string;

  foundItems: TDescriptorProductInfoArray;

procedure GetOpenSubtitlesForProduct(Product: PPluginProductItem);
procedure AddSubtitleItem(Sub: TSubtitle);

function UserSelectFromList: integer;
procedure FreeFoundItems;

function DownloadSubTitle(URL: string; SubTitle: TSubtitle): boolean;
function UnPack(FileName, TargetDir: string; ArchiveType: TGUID): boolean;


implementation

uses
  uProgress;

procedure GetOpenSubtitlesForProduct(Product: PPluginProductItem);
var
  O: TOSClient;
  Subs: TSubtitles;
  I: Integer;
  SelectedIndex: integer;
  URL: string;
begin
  O := TOSClient.Create;
  O.Languages := AutoDetectLanguage.Lang;
  O.Login;
  Subs := O.GetSubtitles(Product.TargetPath);

  SetLength(foundItems, 0);
  for I := Low(Subs) to High(Subs) do
  begin
    AddSubtitleItem(Subs[I]);
    // add movie to list
  end;
  if Length(foundItems) > 0 then
  begin
    SelectedIndex := UserSelectFromList;
    if SelectedIndex <> -1 then
    begin
      URL := foundItems[SelectedIndex].URL;
      if DownloadSubTitle(URL, Subs[SelectedIndex]) then
      begin
        MessageDlg('The selected subtitle downloaded to movie directory.', mtInformation, [mbOK], 0);
      end;

      FreeFoundItems;
    end;
  end
  else
    ShowMessage('Sorry, movie not found!');

  O.Logout;
  O.Free;
end;

procedure AddSubtitleItem(Sub: TSubtitle);
var
  Item: TDescriptorProductInfo;
  Text: string;
begin
  Text := Format('[%s] %s   (%d downloads)', [Sub.Lang, Sub.FileName, Sub.DownloadCount]);
  Item.Name := StrNew(PWideChar(Text));
  Item.URL := StrNew(PWideChar(Sub.DownloadLink));
  Item.Description := nil;
  Item.Image := nil;

  SetLength(foundItems, Length(foundItems) + 1);
  foundItems[Length(foundItems) - 1] := Item;
end;

function DownloadSubTitle(URL: string; SubTitle: TSubtitle): boolean;
var
  tempFile: string;
begin
  result := false;
  ShowProgressDialog('Downloading subtitle...', 'OpenSubtitle.org plugin');
  tempFile := IncludeTrailingBackslash(IcePack.GetTempDirectory) + subTitle.FileName + '.zip';
  try
    if IcePack.DownloadFile(URL, tempFile) then
    begin
      ChangeProgressCaption('Unpacking subtitle...');
      result := UnPack(tempFile, ExtractFilePath(SubTitle.OrigFilename), CLSID_CFormatZip);
    end;
  finally
    DeleteFile(PWideChar(tempFile));
    CloseProgressDialog;
  end;
end;


function UnPack(FileName, TargetDir: string; ArchiveType: TGUID): boolean;
var
  SevenZip: I7zInArchive;
begin
  result := false;
  try
    SevenZip := CreateInArchive(ArchiveType);
    try
      SevenZip.OpenFile(FileName);
      SevenZip.ExtractTo(TargetDir);
      SevenZip.Close;
      result := true;
    finally
//      SevenZip.Free;
    end;
  except
    on E: Exception do
    begin
    end;
  end;
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

end.
