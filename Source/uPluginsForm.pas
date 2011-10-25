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
unit uPluginsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ImgList, PngImageList, Gradient,
  IceTabSet, IceXML, ICePack, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP;

type
  TPluginsForm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Panel2: TPanel;
    Splitter1: TSplitter;
    btnOk: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lDescr: TLabel;
    lName: TLabel;
    lVersion: TLabel;
    lAuthor: TLabel;
    lWeb: TLabel;
    pluginIcons: TPngImageList;
    Gradient1: TGradient;
    Gradient2: TGradient;
    Panel3: TPanel;
    PluginList: TListBox;
    IceTabSet1: TIceTabSet;
    bInstall: TButton;
    http: TIdHTTP;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PluginListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PluginListClick(Sender: TObject);
    procedure lWebClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IceTabSet1TabSelected(Sender: TObject; ATab: TIceTab;
      ASelected: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bInstallClick(Sender: TObject);
    procedure httpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure httpWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
  {  procedure PluginListDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure PluginListCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);    }
  private
    procedure LoadInstalledPluginList;
    procedure LoadDownloadablePluginList;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PluginsForm: TPluginsForm;
  dlPluginXML: TIceXML = nil;
  MaxCount: Int64 = 0;

implementation

{$R *.dfm}

uses
  uPluginClasses, ShellAPI, uConstans, uProcs, uProgress, ShlObj, gnugettext;

procedure TPluginsForm.bInstallClick(Sender: TObject);
var
  FS: TFileStream;
  UpdateDir: string;
  Item, Files: TXMLItem;
  I: integer;
  filename: string;
begin
  if (PluginList.ItemIndex <> -1) and Assigned(dlPluginXML) and (dlPluginXML.Root.Count > PluginList.ItemIndex) then
  begin
    ShowProgressDialog(Format(_('Downloading plugin (%d%%)...'), [0]), _('Please wait'));
    try
      UpdateDir := GetSpecialFolderPath(CSIDL_LOCAL_APPDATA) + UPDATEPATH;
      ForceDirectories(UpdateDir);

      Item := TXMLItem(PluginList.Items.Objects[PluginList.ItemIndex]);
      Files := Item.GetItemEx('Files', true);
      for I := 0 to Files.Count - 1 do
      begin
        filename := UpdateDir + Files[I].Attr['name'];
        ForceDirectories(ExtractFilePath(filename));
        FS := TFileStream.Create(filename, fmCreate);
        try
          try
            HTTP.Get(Files[I].Text, FS);
          finally
            FS.Free;
          end;
        except
          on E: Exception do
          begin
            if FileExists(filename) then
              DeleteFile(filename);

            raise Exception.Create(E.Message);
          end;
        end;
      end;
      CloseProgressDialog();
      MessageDlg(_('Application exit for install new plugin...'), mtInformation, [mbOK], 0);
      ExecuteSOUpdater;
    except
      on E: Exception do
      begin
        CloseProgressDialog();
        MessageDlg(_('Download error: ') + E.Message, mtError, [mbOK], 0);
      end;
    end;
  end;

end;

procedure TPluginsForm.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TPluginsForm.LoadDownloadablePluginList;
var
  I: Integer;
  Plugin: TXMLItem;
begin
  if not Assigned(dlPluginXML) then
  begin
    ShowProgressDialog(_('Downloading plugin list...'), _('Please wait'));
    dlPluginXML := GetDownloadablePluginList;
    CloseProgressDialog();
  end;

  if Assigned(dlPluginXML) then
  begin
    PluginList.Items.BeginUpdate;
    PluginList.Items.Clear;
    for I := 0 to dlPluginXML.Root.Count - 1 do
    begin
      Plugin := dlPluginXML.Root[I];
      PluginList.AddItem(Plugin.Attr['fullname'], Plugin);
    end;
    PluginList.Items.EndUpdate;
  end;
  if PluginList.Items.Count > 0 then
  begin
    PluginList.ItemIndex := 0;
    PluginListClick(PluginList);
  end;
end;

procedure TPluginsForm.LoadInstalledPluginList;
var
  I: Integer;
  Plugin: TPluginItem;
begin
  PluginList.Items.BeginUpdate;
  PluginList.Items.Clear;
  for I := 0 to PluginManager.Count - 1 do
  begin
    Plugin := PluginManager.Items[I];
    PluginList.AddItem(Plugin.PluginInfo.Name, Plugin);
  end;
  PluginList.Items.EndUpdate;
  if PluginList.Items.Count > 0 then
  begin
    PluginList.ItemIndex := 0;
    PluginListClick(PluginList);
  end;
end;
procedure TPluginsForm.lWebClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(lWeb.Caption), nil, nil, SW_SHOW)
end;

procedure TPluginsForm.PluginListClick(Sender: TObject);
var
  Plugin: TPluginItem;
  PluginXML: TXMLItem;
  descr: string;
begin
  if PluginList.ItemIndex <> -1 then
  begin
    if IceTabSet1.TabIndex = 0 then
    begin
      Plugin := PluginManager.Items[PluginList.ItemIndex];
      lName.Caption := Plugin.PluginInfo.Name;
      lVersion.Caption := Plugin.PluginInfo.Version;
      lAuthor.Caption := Plugin.PluginInfo.Author;
      lWeb.Caption := Plugin.PluginInfo.WebPage;
      lDescr.Caption := Plugin.PluginInfo.Description;
      bInstall.Visible := false;
    end
    else if Assigned(dlPluginXML) and (dlPluginXML.Root.Count > PluginList.ItemIndex) then
    begin
      PluginXML := dlPluginXML.Root[PluginList.ItemIndex];
      lName.Caption := PluginXML.Attr['fullname'];
      lVersion.Caption := PluginXML.GetItemValue('Version', '');
      lAuthor.Caption := PluginXML.GetItemValue('Author', '');
      lWeb.Caption := PluginXML.GetItemValue('Web', '');
      descr := Base64Decode(PluginXML.GetItemValue('Description', ''));
      lDescr.Caption := StripHTMLtags(descr);
      bInstall.Visible := true;
    end;
  end;
end;

procedure TPluginsForm.PluginListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  Plugin: TPluginItem;
  PluginItem: TXMLItem;
  Icon: TIcon;
  S: string;
  R: TRect;
  descr: string;

  tw, th: integer;
begin
  if odSelected in State then
    PluginList.Canvas.Brush.Color := clHighlight
  else
    PluginList.Canvas.Brush.Color := PluginList.Color;
  PluginList.Canvas.FillRect(Rect);

  Plugin := nil; PluginItem := nil;
  if PluginList.Items.Objects[Index] is TPluginItem then
    Plugin := TPluginItem(PluginList.Items.Objects[Index])
  else
    PluginItem := TXMLItem(PluginList.Items.Objects[Index]);

  if Assigned(PluginItem) or (not Assigned(Plugin.PluginInfo.Icon)) then
  begin
    pluginIcons.Draw(PluginList.Canvas, Rect.Left + 2, Rect.Top + 5, 0);
  end
  else
  begin
    Icon := TIcon.Create;
    Icon.Handle := HIcon(Plugin.PluginInfo.Icon);
    PluginList.Canvas.Draw(Rect.Left + 2, Rect.Top + 5, Icon);
  end;

  if Assigned(Plugin) then
    S := Plugin.PluginInfo.Name
  else
    S := PluginItem.Attr['fullname'];
  th := PluginList.Canvas.TextHeight(S);
  PluginList.Canvas.Font.Style := [fsBold];
  PluginList.Canvas.TextOut(Rect.Left + 40, Rect.Top + 2, S);

  if Assigned(Plugin) then
    S := 'v' + string(Plugin.PluginInfo.Version)
  else
    S := 'v' + PluginItem.GetItemValue('Version', '');
  PluginList.Canvas.Font.Size := 7;
  PluginList.Canvas.Font.Style := [fsItalic];
  PluginList.Canvas.TextOut(Rect.Left + 40, Rect.Top + th + 2, S);

  if Assigned(Plugin) then
    S := Plugin.PluginInfo.Description
  else
  begin
    descr := Base64Decode(PluginItem.GetItemValue('Description', ''));
    S := StripHTMLtags(descr);
  end;
  PluginList.Canvas.Font.Size := PluginList.Font.Size;
  PluginList.Canvas.Font.Style := [];
  R := Classes.Rect(Rect.Left + 40, Rect.Top + th * 2, Rect.Right, Rect.Bottom);
  PluginList.Canvas.TextRect(R, S, [tfEndEllipsis, tfSingleLine]);

  if odSelected in State then
    PluginList.Canvas.FrameRect(Rect);
end;
procedure TPluginsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(dlPluginXML) then
    FreeAndNil(dlPluginXML);
end;

procedure TPluginsForm.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self, 'default');

end;

procedure TPluginsForm.FormShow(Sender: TObject);
begin
  IceTabSet1.TabIndex := 0;
  LoadInstalledPluginList;
end;

procedure TPluginsForm.httpWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if MaxCount > 0 then
    ChangeProgressCaption(Format(_('Downloading plugin (%d%%)...'), [AWorkCount * 100 div MaxCount]));
end;

procedure TPluginsForm.httpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  MaxCount := AWorkCountMax;
end;

procedure TPluginsForm.IceTabSet1TabSelected(Sender: TObject; ATab: TIceTab;
  ASelected: Boolean);
begin
  if ASelected then
  begin
    if ATab.Index = 0 then
      LoadInstalledPluginList
    else
      LoadDownloadablePluginList;
  end;
end;

end.
