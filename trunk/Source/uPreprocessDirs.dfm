object PreProcessForm: TPreProcessForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Preprocessing new directories'
  ClientHeight = 440
  ClientWidth = 917
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 917
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 917
    Height = 403
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object VList: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 915
      Height = 291
      Align = alClient
      CheckImageKind = ckXP
      Color = 15790320
      Colors.HeaderHotColor = clBtnFace
      Header.AutoSizeIndex = 0
      Header.Background = 10329501
      Header.DefaultHeight = 17
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoColumnResize, hoOwnerDraw, hoShowSortGlyphs, hoVisible]
      Header.Style = hsFlatButtons
      PopupMenu = PopupMenu1
      StateImages = MainForm.stateImages
      TabOrder = 0
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
      TreeOptions.PaintOptions = [toShowBackground, toShowButtons, toShowDropmark, toShowTreeLines, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toExtendedFocus, toMultiSelect]
      OnClick = VListClick
      OnFocusChanged = VListFocusChanged
      OnGetText = VListGetText
      OnGetImageIndex = VListGetImageIndex
      OnHeaderDraw = VListHeaderDraw
      OnKeyDown = VListKeyDown
      OnMouseUp = VListMouseUp
      Columns = <
        item
          CheckBox = True
          Color = 15790320
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Style = vsOwnerDraw
          Width = 151
          WideText = 'Category'
        end
        item
          Position = 1
          Style = vsOwnerDraw
          Width = 240
          WideText = 'New directory name'
        end
        item
          Position = 2
          Style = vsOwnerDraw
          Width = 280
          WideText = 'Old directory'
        end
        item
          CheckBox = True
          Position = 3
          Style = vsOwnerDraw
          WideText = 'Unpack'
        end
        item
          Position = 4
          Style = vsOwnerDraw
          Width = 40
          WideText = 'ISO'
        end
        item
          CheckBox = True
          Position = 5
          Style = vsOwnerDraw
          Width = 70
          WideText = 'Del source'
        end
        item
          Alignment = taRightJustify
          Position = 6
          Style = vsOwnerDraw
          Width = 80
          WideText = 'Size'
        end>
      WideDefaultText = ''
    end
    object SettingsPanel: TPanel
      Left = 1
      Top = 292
      Width = 915
      Height = 110
      Align = alBottom
      BevelOuter = bvNone
      Color = 10329501
      DoubleBuffered = False
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 1
      DesignSize = (
        915
        110)
      object Gradient1: TGradient
        Left = 0
        Top = 0
        Width = 915
        Height = 110
        Align = alClient
        ColorBegin = 14211288
        ColorEnd = 10329501
        Style = gsLinearV
        ExplicitLeft = 504
        ExplicitTop = 8
        ExplicitWidth = 100
        ExplicitHeight = 100
      end
      object Label3: TLabel
        Left = 7
        Top = 7
        Width = 45
        Height = 13
        Caption = 'Category'
      end
      object lNewPath: TLabel
        Left = 7
        Top = 46
        Width = 650
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'New path:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6710886
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lAddCat: TLabel
        Left = 58
        Top = 7
        Width = 19
        Height = 13
        Cursor = crHandPoint
        Caption = 'Add'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = lAddCatClick
      end
      object lSaveDefault: TLabel
        Left = 696
        Top = 92
        Width = 75
        Height = 13
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        Caption = 'Save as default'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = lSaveDefaultClick
      end
      object cbCategories: TComboBox
        Left = 7
        Top = 24
        Width = 262
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbCategoriesChange
      end
      object eNewDirName: TLabeledEdit
        Left = 275
        Top = 24
        Width = 390
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 96
        EditLabel.Height = 13
        EditLabel.Caption = 'New directory name'
        TabOrder = 1
        OnExit = eNewDirNameExit
      end
      object cbUnpack: TCheckBox
        Left = 673
        Top = 19
        Width = 97
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Unpack'
        TabOrder = 2
        OnClick = cbUnpackClick
      end
      object cbUnPackISO: TCheckBox
        Left = 673
        Top = 42
        Width = 97
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Extract ISO'
        TabOrder = 3
        OnClick = cbUnpackClick
      end
      object cbDelSource: TCheckBox
        Left = 792
        Top = 19
        Width = 113
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Delete source path'
        TabOrder = 4
        OnClick = cbUnpackClick
      end
      object cbDelNFO: TCheckBox
        Left = 792
        Top = 42
        Width = 113
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Delete *.nfo'
        TabOrder = 5
        OnClick = cbUnpackClick
      end
      object cbDelDIZ: TCheckBox
        Left = 792
        Top = 65
        Width = 113
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Delete *.diz'
        TabOrder = 6
        OnClick = cbUnpackClick
      end
      object cbDelSFV: TCheckBox
        Left = 792
        Top = 88
        Width = 113
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Delete *.sfv'
        TabOrder = 7
        OnClick = cbUnpackClick
      end
      object eTags: TLabeledEdit
        Left = 7
        Top = 84
        Width = 658
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 23
        EditLabel.Height = 13
        EditLabel.Caption = 'Tags'
        TabOrder = 8
        OnExit = eTagsExit
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 403
    Width = 917
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    Color = 10329501
    Ctl3D = True
    DoubleBuffered = True
    ParentBackground = False
    ParentCtl3D = False
    ParentDoubleBuffered = False
    TabOrder = 1
    DesignSize = (
      917
      37)
    object Gradient2: TGradient
      Left = 0
      Top = 0
      Width = 917
      Height = 37
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 10329501
      Reverse = True
      Style = gsLinearV
      ExplicitHeight = 40
    end
    object bOk: TButton
      Left = 742
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Process'
      ModalResult = 1
      TabOrder = 0
      OnClick = bOkClick
    end
    object bCancel: TButton
      Left = 831
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Close'
      ModalResult = 2
      TabOrder = 1
      OnClick = bCancelClick
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 216
    Top = 120
    object Deleteselecteditem1: TMenuItem
      Caption = 'Delete selected item'
      OnClick = Deleteselecteditem1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Checkall1: TMenuItem
      Caption = 'Check all'
      OnClick = Checkall1Click
    end
    object Uncheckall1: TMenuItem
      Caption = 'Uncheck all'
      OnClick = Uncheckall1Click
    end
  end
end
