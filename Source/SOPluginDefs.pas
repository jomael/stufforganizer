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

  //Base exported functions in every plugin
  TPluginLoadProc = procedure(SelfObject: Pointer); stdcall;
  TPluginUnLoadProc = procedure(); stdcall;
  TPluginGetInfo = function(): PPluginInfo; stdcall;
  TPluginSetup = function(): boolean; stdcall;
  TPluginInitialize = function(): boolean; stdcall;
  TPluginOptions = function(): boolean; stdcall;

  (*********************************************
   *********** Unpack/preprocess plugins *******
   *********************************************)
  //Callback for unpack
  TFileProcCallback =  function(ProcItem: Pointer; FileName, TargetDir: PWideChar): integer; stdcall;

  //Callbacks for preprocess plugins
  TNeedPassCallBack = procedure(ProcItem: Pointer; var NewPassword: PWideChar); stdcall;
  TUnPackProcessCallBack = procedure(ProcItem: Pointer; StatusText: PWideChar; Current, Total: Int64); stdcall;
  TUnPackErrorCallBack = procedure(ProcItem: Pointer; ErrorCode: integer; ErrorText: PWideChar);stdcall;
  TRemoveVolumeFromFileListCallBack = procedure(ProcItem: Pointer;FileName: PWideChar); stdcall;

  //Callback for register a file extension by plugin
  TRegisterFileType = procedure(Plugin: Pointer; FileExt: PWideChar; FileProcType: integer; ProcCallBack: TFileProcCallback); stdcall;

  //Callback struct for unpack/preprocess plugin
  PPluginUnPackCallbacks = ^TPluginUnPackCallbacks;
  TPluginUnPackCallbacks = packed record
    RegisterFileType: TRegisterFileType;
    UnPackError: TUnPackErrorCallBack;
    NeedPassword: TNeedPassCallBack;
    UnPackProgress: TUnPackProcessCallBack;
    RemoveFileFromList: TRemoveVolumeFromFileListCallBack;
  end;

  //Give callbacks to plugin
  TPluginRegUnPackFunctions = procedure(PluginCallBacks: PPluginUnPackCallbacks); stdcall;

  (*********************************************
   ******* Descriptor/postprocess plugins ******
   *********************************************)

  //Struct for UserSelect
  PDescriptorProductInfo = ^TDescriptorProductInfo;
  TDescriptorProductInfo = packed record
    Name: PWideChar;
    Description: PWideChar;
    URL: PWideChar;
    Image: Pointer; //HBitmap
  end;

  PTDescriptorProductInfoArray = ^TDescriptorProductInfoArray;
  TDescriptorProductInfoArray = array of TDescriptorProductInfo;

  //Execution callback
  TRunDescriptorCallback = procedure(ProductInfo: PPluginProductItem); stdcall;

  //CAllback for register the description function
  TRegisterDescriptor = procedure(Plugin: Pointer; Name: PWideChar; ProcCallBack: TRunDescriptorCallback); stdcall;

  TDescriptorSaveImage = procedure(Plugin: Pointer; ProductInfo: PPluginProductItem; FileName: PWideChar); stdcall;
  TDescriptorSaveProductInfo = procedure(Plugin: Pointer; ProductInfo: PPluginProductItem); stdcall;
  TDescriptorUserSelect = function(Plugin: Pointer; ItemList: PTDescriptorProductInfoArray): integer; stdcall;

  //Callback struct for descriptor/preprocess plugin
  PPluginDescriptorCallbacks = ^TPluginDescriptorCallbacks;
  TPluginDescriptorCallbacks = packed record
    RegisterDescriptor: TRegisterDescriptor;
    SaveImageToDB: TDescriptorSaveImage;
    SaveProductInfoToDB: TDescriptorSaveProductInfo;
    UserSelect: TDescriptorUserSelect;
  end;

  //Give callbacks to plugin
  TPluginRegDescriptorFunctions = procedure(PluginCallBacks: PPluginDescriptorCallbacks); stdcall;

implementation

end.
