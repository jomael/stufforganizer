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

unit uProcessThread;

interface

uses
  SysUtils, Classes, Windows, SyncObjs, uClasses, IcePack, Graphics;

type
  TFinishEvent = procedure of object;

  TProcessThread = class(TThread)
  private
    { Private declarations }
    FLock: TCriticalSection;
    FItems: TList;
    FEventList: TList;
    FFinish: TFinishEvent;
    FWindowHandler: THandle;
    procedure SetFinish(const Value: TFinishEvent);
  protected
    procedure Execute; override;

  public

    procedure Initialize(WindowHandler: THandle);
    destructor Destroy; override;

    procedure Lock; inline;
    procedure UnLock; inline;

    procedure AddItem(Data: TPreProcessItem);
    procedure ClearItems;

    function GetEvents: TList;

    property Finish: TFinishEvent read FFinish write SetFinish;
    property Terminated;

    procedure ItemProcessEvent(Sender: TPreProcessItem; StatusCode: integer; StatusText: string; Progress: integer);
  end;

var
  ProcThread: TProcessThread;
  NowProcessing: boolean = false;

implementation

uses uMain, sqlitewrap, uConstans;

{ TProcessThread }

procedure TProcessThread.AddItem(Data: TPreProcessItem);
begin
  Lock;
  if FItems.IndexOf(Data) = -1 then
  begin
    FItems.Add(Data);
    Data.Status := ITEM_WAITING;
  end;
  UnLock;
end;

procedure TProcessThread.ClearItems;
begin
  Lock;
  FItems.Clear;
  UnLock;
end;

procedure TProcessThread.Initialize(WindowHandler: THandle);
begin
  FLock := TCriticalSection.Create;
  FreeOnTerminate := true;
  FItems := TList.Create;
  FEventList := TList.Create;
  FWindowHandler := WindowHandler;

end;

destructor TProcessThread.Destroy;
begin
  ProcThread := nil;

  FItems.Free;
  FEventList.Free;
  FLock.Free;

  inherited;
end;

procedure TProcessThread.Execute;
var
  Item: TPreProcessItem;
begin
  while (FItems.Count > 0) and (not Terminated) do
  begin
    try
      Item := FItems[0];
      FItems.Delete(0);
      Item.OnStatusEvent := ItemProcessEvent;
      Item.Status := ITEM_PROCESSING;
      if Item.Execute in [RESULT_UNPACK, RESULT_COPY] then
      begin
        Item.SaveToDB;
        Item.Status := ITEM_PROCESS_SUCCESS;
        ItemProcessEvent(Item, STATUS_FINISHED, 'Finished.', 100);
      end
      else
      begin
        Item.Status := ITEM_PROCESS_ERROR;
        ItemProcessEvent(Item, STATUS_ERROR, 'Aborted.', 100);
      end;
    except on E: Exception do
      begin
        Item.Status := ITEM_PROCESS_ERROR;
        ItemProcessEvent(Item, STATUS_ERROR, E.Message, 0);
      end;
    end;
  end;

  if Assigned(Finish) then
    Synchronize(Finish);
end;



function TProcessThread.GetEvents: TList;
var
  I: Integer;
begin
  result := TList.Create;
  Lock;
  try
    for I := 0 to FEventList.Count - 1 do
      result.Add(FEventList[I]);
    FEventList.Clear;
  finally
    UnLock;
  end;
end;

procedure TProcessThread.ItemProcessEvent(Sender: TPreProcessItem;
  StatusCode: integer; StatusText: string; Progress: integer);
var
  Event: PThreadEvent;
begin
  Lock;
  try
    New(Event);
    Event.Item := Sender;
    Event.StatusCode := StatusCode;
    Event.StatusText := StatusText;
    Event.Progress := Progress;
    FEventList.Add(Event);
  finally
    UnLock;
  end;
  PostMessage(FWindowHandler, WM_THREADNOTIFY, 0, 0);
end;

procedure TProcessThread.Lock;
begin
  FLock.Enter;
end;

procedure TProcessThread.SetFinish(const Value: TFinishEvent);
begin
  FFinish := Value;
end;

procedure TProcessThread.UnLock;
begin
  FLock.Leave;
end;

end.
