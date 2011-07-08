object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Stuff Organizer Updater'
  ClientHeight = 97
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object StepList1: TStepList
    Left = 9
    Top = 8
    Width = 225
    Height = 80
    Steps = <
      item
        ItemID = 0
        Caption = 'Checking files...'
        State = ssNone
      end
      item
        ItemID = 0
        Caption = 'Close Stuff Organizer...'
        State = ssNone
      end
      item
        ItemID = 0
        Caption = 'Copy new files...'
        State = ssNone
      end
      item
        ItemID = 0
        Caption = 'Delete temporary files...'
        State = ssNone
      end
      item
        ItemID = 0
        Caption = 'Start Stuff Organizer...'
        State = ssNone
      end>
    CurrentStep = 0
    RowHeight = 0
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 208
    Top = 8
  end
end
