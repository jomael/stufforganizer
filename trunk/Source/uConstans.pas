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

unit uConstans;

interface

uses
  SysUtils, Classes, Windows, Messages, IcePack, ShlObj, tlHelp32, Forms,
  IceLanguage;

const
  APP_TITLE                   = 'Stuff Organizer';

  CONFIGPATH                  = '\Stuff Organizer\';
  UPDATEPATH                  = '\Stuff Organizer\Update\';
  DBPATH                      = '\Stuff Organizer\Database\';
  MAINDBFILENAME              = 'main.db';
  INFODBFILENAME              = 'productinfo.db';
  CONFIG_FILENAME             = 'Configurations.xml';

  UPDATE_URL                  = 'http://stufforganizer.sourceforge.net/update.php';

  TARGET_TEMP_DIR             = '___StuffOrganizerTEMP__';
  //REGPATH                   = 'HKCU\Software\Stuff Organizer\';

  PLUGIN_DIR                  = 'Plugins\';

  WM_THREADNOTIFY             = WM_USER + 27;
  WM_PROCESS_ADDITEMS         = WM_USER + 127;

  RESULT_ERROR                = 0;
  RESULT_UNPACK               = 1;
  RESULT_COPY                 = 2;

  STATUS_NONE                 = 0;

  STATUS_UNPACK               = 1;
  STATUS_COPYDIR              = 2;
  STATUS_COPYFILE             = 3;
  STATUS_EXTRACTISO           = 4;
  STATUS_MOVEDIR              = 5;
  STATUS_MOVEFILE             = 6;
  STATUS_DELETEDIR            = 7;
  STATUS_DELETEFILE           = 8;
  STATUS_DELETE_SOURCE        = 9;
  STATUS_PROCESS_NFO          = 10;
  STATUS_SAVEDB               = 11;
  STATUS_SEARCH_ARCHIVE       = 12;
  STATUS_NEED_PASSWORD        = 13;
  STATUS_FINISHED             = 100;

  STATUS_WARNING              = 254;
  STATUS_ERROR                = 255;

  ITEM_PASSIVE                = 0;
  ITEM_ACTIVE                 = 1;
  ITEM_PROCESS_ERROR          = 2;
  ITEM_PROCESS_SUCCESS        = 3;
  ITEM_PROCESSING             = 4;
  ITEM_WAITING                = 5;

  NODE_FILTER_ALL             = 1;
  NODE_FILTER_CATEGORY        = 2;
  NODE_FILTER_NEW_CATEGORY    = 3;

var
  ProgressStopping: boolean = false;

  TagList: TStringList;
  CatIDArray: array of integer;
  TagMatrix: array of array of Extended;
  //Lang: TIceLanguage;


  (* Settings variables *)

  DELETE_TO_RECBIN: boolean = false;
  HIDE_FILE_DIALOGS: boolean = true;
  ICS_ENABLED: boolean = true;

implementation



initialization
  TagList := TStringList.Create;
{  Lang := TIceLanguage.Create(nil);
  if not DirectoryExists(ExecPath + 'Languages') then
    ForceDirectories(ExecPath + 'Languages');
  Lang.LanguageDir := ExecPath + 'Languages';
  Lang.GetLanguageFiles;
  Lang.InitializeDescriptor(TResourceStream.Create(hInstance, 'LANG_DESCRIPTOR', RT_RCDATA));}

finalization
  if Assigned(TagList) then
    TagList.Free;

{  if Assigned(Lang) then
    Lang.Free;
}
end.
