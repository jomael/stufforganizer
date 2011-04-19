object CategoriesForm: TCategoriesForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Category'
  ClientHeight = 168
  ClientWidth = 438
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
  DesignSize = (
    438
    168)
  PixelsPerInch = 96
  TextHeight = 13
  object Gradient1: TGradient
    Left = 0
    Top = 0
    Width = 438
    Height = 131
    Align = alClient
    ColorBegin = 14211288
    ColorEnd = 11316396
    Style = gsLinearV
    ExplicitLeft = -660
    ExplicitWidth = 1098
    ExplicitHeight = 139
  end
  object Label1: TLabel
    Left = 24
    Top = 59
    Width = 103
    Height = 13
    Caption = 'Category target path'
  end
  object Label2: TLabel
    Left = 24
    Top = 101
    Width = 168
    Height = 13
    Caption = 'If blank, it'#39's equal with source path'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object shColor: TShape
    Left = 224
    Top = 32
    Width = 49
    Height = 21
    Cursor = crHandPoint
    OnMouseUp = shColorMouseUp
  end
  object Label3: TLabel
    Left = 200
    Top = 17
    Width = 25
    Height = 13
    Caption = 'Color'
  end
  object Label4: TLabel
    Left = 298
    Top = 17
    Width = 21
    Height = 13
    Caption = 'Icon'
  end
  object Panel1: TPanel
    Left = 0
    Top = 131
    Width = 438
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    Color = 11316396
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      438
      37)
    object btnCancel: TButton
      Left = 353
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOk: TButton
      Left = 272
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      TabOrder = 1
      OnClick = btnOkClick
    end
  end
  object eName: TLabeledEdit
    Left = 24
    Top = 32
    Width = 147
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 74
    EditLabel.Height = 13
    EditLabel.Caption = 'Category name'
    TabOrder = 1
  end
  object ePath: TDirectoryEdit
    Left = 24
    Top = 78
    Width = 403
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    TabOrder = 2
    OnButtonClick = ePathButtonClick
    TitleName = 'Please specify a directory'
  end
  object cbColor: TCheckBox
    Left = 203
    Top = 34
    Width = 17
    Height = 17
    TabOrder = 3
  end
  object cbIcons: TComboBox
    Left = 298
    Top = 32
    Width = 49
    Height = 22
    Style = csOwnerDrawFixed
    ItemHeight = 16
    TabOrder = 4
    OnDrawItem = cbIconsDrawItem
  end
  object JvBrowseForFolderDialog1: TJvBrowseForFolderDialog
    Left = 371
    Top = 71
  end
  object ColorDialog1: TColorDialog
    Left = 112
    Top = 16
  end
end
