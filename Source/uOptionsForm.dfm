object OptionsForm: TOptionsForm
  Left = 0
  Top = 0
  Caption = 'Preferences'
  ClientHeight = 327
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 290
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object Gradient1: TGradient
      Left = 1
      Top = 1
      Width = 533
      Height = 288
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 11316396
      Style = gsLinearV
      ExplicitLeft = 2
      ExplicitTop = 2
    end
    object GroupBox1: TGroupBox
      Left = 0
      Top = 0
      Width = 313
      Height = 137
      Caption = 'Process settings'
      TabOrder = 0
      object cbDelToRB: TCheckBox
        Left = 24
        Top = 24
        Width = 273
        Height = 17
        Caption = 'Delete to recycle bin'
        TabOrder = 0
      end
      object cbHideDialogs: TCheckBox
        Left = 24
        Top = 47
        Width = 273
        Height = 17
        Caption = 'Hide copy/move/delete dialog'
        TabOrder = 1
      end
      object cbICS: TCheckBox
        Left = 24
        Top = 70
        Width = 273
        Height = 17
        Caption = 'Enable ICS (Intelligent category selector)'
        TabOrder = 2
      end
    end
    object GroupBox2: TGroupBox
      Left = 319
      Top = 0
      Width = 209
      Height = 137
      Caption = 'Auto update'
      TabOrder = 1
      object bCheckUpdate: TLabel
        Left = 40
        Top = 47
        Width = 52
        Height = 13
        Cursor = crHandPoint
        Alignment = taCenter
        Caption = 'Check now'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = bCheckUpdateClick
      end
      object cbCheckNewVersion: TCheckBox
        Left = 24
        Top = 24
        Width = 182
        Height = 17
        Caption = 'Check new version at start'
        TabOrder = 0
      end
    end
    object GroupBox3: TGroupBox
      Left = 0
      Top = 143
      Width = 313
      Height = 137
      Caption = 'Extensions'
      TabOrder = 2
      object lbExtensions: TCheckListBox
        Left = 2
        Top = 15
        Width = 309
        Height = 120
        Align = alClient
        Color = 14211288
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 290
    Width = 535
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      535
      37)
    object Gradient2: TGradient
      Left = 0
      Top = 0
      Width = 535
      Height = 37
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 11316396
      Style = gsLinearV
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 764
      ExplicitHeight = 154
    end
    object btnOk: TButton
      Left = 367
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 448
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
