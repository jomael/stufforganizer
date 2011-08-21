object UserSelectForm: TUserSelectForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Select an item'
  ClientHeight = 322
  ClientWidth = 598
  Color = 14211288
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 285
    Width = 598
    Height = 37
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      598
      37)
    object Gradient2: TGradient
      Left = 1
      Top = 1
      Width = 596
      Height = 35
      Align = alClient
      ColorBegin = 14211288
      ColorEnd = 11316396
      Style = gsLinearV
      ExplicitHeight = 38
    end
    object btnOk: TButton
      Left = 431
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 512
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object DataList: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 598
    Height = 285
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs]
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    OnDblClick = DataListDblClick
    OnGetText = DataListGetText
    Columns = <
      item
        Position = 0
        Width = 594
      end>
  end
end
