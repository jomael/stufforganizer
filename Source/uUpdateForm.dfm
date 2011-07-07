object UpdateForm: TUpdateForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Update'
  ClientHeight = 387
  ClientWidth = 477
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 346
    Width = 477
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 444
    DesignSize = (
      477
      41)
    object Gradient2: TGradient
      Left = 0
      Top = 0
      Width = 477
      Height = 41
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 10329501
      Reverse = True
      Style = gsLinearV
      ExplicitWidth = 917
      ExplicitHeight = 40
    end
    object btnCancel: TButton
      Left = 391
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      TabOrder = 0
    end
    object btnUpdate: TButton
      Left = 310
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Update'
      Default = True
      TabOrder = 1
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 65
    Width = 477
    Height = 281
    Align = alClient
    Caption = 'Update content'
    Color = 10329501
    ParentBackground = False
    ParentColor = False
    TabOrder = 1
    ExplicitTop = -80
    ExplicitWidth = 444
    ExplicitHeight = 467
    object DataList: TVirtualStringTree
      Left = 2
      Top = 15
      Width = 473
      Height = 264
      Align = alClient
      Header.AutoSizeIndex = 0
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      StateImages = MainForm.stateImages
      TabOrder = 0
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnGetText = DataListGetText
      ExplicitLeft = 3
      ExplicitTop = 17
      ExplicitHeight = 329
      Columns = <
        item
          Position = 0
          Width = 349
          WideText = 'Module'
        end
        item
          Position = 1
          Width = 120
          WideText = 'Date'
        end>
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 477
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 444
    DesignSize = (
      477
      65)
    object Gradient1: TGradient
      Left = 0
      Top = 0
      Width = 477
      Height = 65
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 10329501
      Style = gsLinearV
      ExplicitLeft = 504
      ExplicitTop = 8
      ExplicitWidth = 100
      ExplicitHeight = 100
    end
    object lMainCaption: TLabel
      Left = 16
      Top = 5
      Width = 450
      Height = 13
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'There is a new version!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3233585
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lElapsedTime: TLabel
      Left = 32
      Top = 27
      Width = 79
      Height = 13
      Alignment = taRightJustify
      Caption = 'Current version:'
    end
    object lEstimatedTime: TLabel
      Left = 48
      Top = 46
      Width = 63
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'New version:'
    end
    object lCurrVersion: TLabel
      Left = 128
      Top = 27
      Width = 42
      Height = 13
      Caption = 'v0.4.3.6'
    end
    object lNewVersion: TLabel
      Left = 128
      Top = 46
      Width = 44
      Height = 13
      Caption = 'v0.5.0.0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
end
