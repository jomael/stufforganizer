object NFOForm: TNFOForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'NFO Viewer'
  ClientHeight = 474
  ClientWidth = 533
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object mNFO: TMemo
    Left = 0
    Top = 0
    Width = 533
    Height = 474
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Terminal'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    OnKeyPress = mNFOKeyPress
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 224
    Top = 208
  end
end
