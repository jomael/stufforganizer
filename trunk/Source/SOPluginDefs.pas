(*
	  This file is part of Stuff Organizer.

    Copyright (C) 2011  Icebob <icebob.apps@gmail.com>

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

unit SOPluginDefs;

interface

uses
  Windows;

const
  UNPACK_RESULT_ERROR                = 0;
  UNPACK_RESULT_SUCCESS              = 1;

type
  TFileProcType = (
                  ptArchive = 1,
                  ptISO = 2
  );

  TPluginType = (
                  ptUnPack = 1,
                  ptDescriptor = 2
  );

  TCallBackType = (
                  ctPreUnpack = 1,
                  ctUnPack = 2,
                  ctPostUnpack = 3,
                  ctDescriptor = 4
  );

  PPluginInfo = ^TPluginInfo;
  TPluginInfo = packed record
    Name              : PWideChar;
    PluginType        : integer;
    Description       : PWideChar;
    Icon              : Pointer; //HIcon
    Author            : PWideChar;
    WebPage           : PWideChar;
    Version           : PWideChar;
    VersionDate       : PWideChar;
    InterfaceVersion  : integer;
    MinimumVersion    : PWideChar;
  end;

  PPluginProductItem = ^TPluginProductItem;
  TPluginProductItem = packed record
    ID                : integer;
    Name              : PWideChar;
    TargetPath        : PWideChar;
    CategoryID        : integer;
    CategoryName      : PWideChar;
    Description       : PWideChar;
    Tags              : PWideChar;
    URL               : PWideChar;
    Modified          : boolean;
  end;

  //Minden pluginban megtal�lhat� alap export�lt fgv-ek
  TPluginLoadProc = procedure(SelfObject: Pointer); stdcall;
  TPluginUnLoadProc = procedure(); stdcall;
  TPluginGetInfo = function(): PPluginInfo; stdcall;
  TPluginSetup = function(): boolean; stdcall;
  TPluginInitialize = function(): boolean; stdcall;

  //----- Unpack plugins ------
  //Plugin megh�v�sa a kicsomagol�shoz
  TFileProcCallback =  function(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;

  //Kicsomagol� pluginoknak el�rhet� fgvek
  TNeedPassCallBack = procedure(ProcItem: Pointer; var NewPassword: PWideChar); stdcall;
  TUnPackProcessCallBack = procedure(ProcItem: Pointer; StatusText: PWideChar; Current, Total: Int64); stdcall;
  TUnPackErrorCallBack = procedure(ProcItem: Pointer; ErrorCode: integer; ErrorText: PWideChar);stdcall;
  TRemoveVolumeFromFileListCallBack = procedure(ProcItem: Pointer;FileName: PWideChar); stdcall;

  //Plugin �ltal megh�vand� fgv egy f�jlt�pus regisztr�ci�j�hoz
  TRegisterFileType = procedure(Plugin: Pointer; FileExt: PWideChar; FileProcType: integer; ProcCallBack: TFileProcCallback); stdcall;

  //Unpack Pluginnak �tadott strukt�ra az � sz�m�ra megh�vhat� fgv-ekr�l
  PPluginUnPackCallbacks = ^TPluginUnPackCallbacks;
  TPluginUnPackCallbacks = packed record
    RegisterFileType: TRegisterFileType;
    UnPackError: TUnPackErrorCallBack;
    NeedPassword: TNeedPassCallBack;
    UnPackProgress: TUnPackProcessCallBack;
    RemoveFileFromList: TRemoveVolumeFromFileListCallBack;
  end;

  //Callback-ek �tad�sa a pluginnek
  TPluginRegUnPackFunctions = procedure(PluginCallBacks: PPluginUnPackCallbacks); stdcall;


  //----- Descriptor plugins ------

  //Adatszerkezet az UserSelecthez
  PDescriptorProductInfo = ^TDescriptorProductInfo;
  TDescriptorProductInfo = packed record
    Name: PWideChar;
    Description: PWideChar;
    URL: PWideChar;
    Image: Pointer; //HBitmap
  end;

  PTDescriptorProductInfoArray = ^TDescriptorProductInfoArray;
//  PDescriptorProductInfoArray = array of PDescriptorProductInfo;
  TDescriptorProductInfoArray = array of TDescriptorProductInfo;

  //Plugin megh�v�sa a futtat�shoz
  TRunDescriptorCallback = procedure(ProductInfo: PPluginProductItem); stdcall;

  //Plugin �ltal megh�vand� fgv a descriptor-ok regisztr�l�s�hoz
  TRegisterDescriptor = procedure(Plugin: Pointer; Name: PWideChar; ProcCallBack: TRunDescriptorCallback); stdcall;

  TDescriptorSaveImage = procedure(Plugin: Pointer; ProductInfo: PPluginProductItem; FileName: PWideChar); stdcall;
  TDescriptorSaveProductInfo = procedure(Plugin: Pointer; ProductInfo: PPluginProductItem); stdcall;
  TDescriptorUserSelect = function(Plugin: Pointer; ItemList: PTDescriptorProductInfoArray): integer; stdcall;

  //Descriptor Pluginnak �tadott strukt�ra az � sz�m�ra megh�vhat� fgv-ekr�l
  PPluginDescriptorCallbacks = ^TPluginDescriptorCallbacks;
  TPluginDescriptorCallbacks = packed record
    RegisterDescriptor: TRegisterDescriptor;
    SaveImageToDB: TDescriptorSaveImage;
    SaveProductInfoToDB: TDescriptorSaveProductInfo;
    UserSelect: TDescriptorUserSelect;
  end;

  //Callback-ek �tad�sa a pluginnek
  TPluginRegDescriptorFunctions = procedure(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;

implementation

end.
