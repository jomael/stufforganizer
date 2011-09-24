object PasswordForm: TPasswordForm
  Left = 0
  Top = 0
  Caption = 'Password'
  ClientHeight = 94
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ePass: TLabeledEdit
    Left = 16
    Top = 32
    Width = 265
    Height = 20
    EditLabel.Width = 94
    EditLabel.Height = 13
    EditLabel.Caption = 'Enter the password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Wingdings'
    Font.Style = []
    ParentFont = False
    PasswordChar = 'l'
    TabOrder = 0
  end
  object bOk: TButton
    Left = 125
    Top = 59
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 206
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = bCancelClick
  end
end
