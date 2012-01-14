object ThreadProcessForm: TThreadProcessForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Processing'
  ClientHeight = 573
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 444
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      444
      65)
    object Gradient1: TGradient
      Left = 0
      Top = 0
      Width = 444
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
      Top = 8
      Width = 417
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Processing...'
    end
    object lElapsedTime: TLabel
      Left = 16
      Top = 46
      Width = 64
      Height = 13
      Caption = 'Elapsed time:'
    end
    object lEstimatedTime: TLabel
      Left = 359
      Top = 50
      Width = 74
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Estimated time:'
    end
    object pBar: TProgressBar
      Left = 16
      Top = 27
      Width = 417
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 532
    Width = 444
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      444
      41)
    object Gradient2: TGradient
      Left = 0
      Top = 0
      Width = 444
      Height = 41
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 10329501
      Reverse = True
      Style = gsLinearV
      ExplicitWidth = 917
      ExplicitHeight = 40
    end
    object Label1: TLabel
      Left = 20
      Top = 11
      Width = 34
      Height = 13
      Alignment = taRightJustify
      Caption = 'Priority'
    end
    object btnHide: TButton
      Left = 359
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Hide'
      TabOrder = 0
      OnClick = btnHideClick
    end
    object btnPause: TButton
      Left = 278
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Pause'
      TabOrder = 1
      OnClick = btnPauseClick
    end
    object btnStop: TButton
      Left = 197
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Stop'
      TabOrder = 2
      Visible = False
      OnClick = btnStopClick
    end
    object cbPriority: TComboBox
      Left = 59
      Top = 8
      Width = 97
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 2
      TabOrder = 3
      Text = 'Normal'
      OnChange = cbPriorityChange
      Items.Strings = (
        'Low'
        'Below normal'
        'Normal'
        'Above normal'
        'High')
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 65
    Width = 444
    Height = 467
    Align = alClient
    Caption = 'Process log'
    Color = 10329501
    ParentBackground = False
    ParentColor = False
    TabOrder = 2
    object LogList: TVirtualStringTree
      Left = 2
      Top = 15
      Width = 440
      Height = 450
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
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnBeforeCellPaint = LogListBeforeCellPaint
      OnGetText = LogListGetText
      OnGetImageIndex = LogListGetImageIndex
      Columns = <
        item
          Position = 0
          Width = 316
          WideText = 'Log'
        end
        item
          Position = 1
          Width = 120
          WideText = 'Progress'
        end>
    end
  end
  object TimeTimer: TTimer
    Enabled = False
    OnTimer = TimeTimerTimer
    Left = 336
    Top = 144
  end
end
