object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'OrDeSy'
  ClientHeight = 498
  ClientWidth = 738
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object mmMain: TMainMenu
    Left = 24
    Top = 16
    object miFile: TMenuItem
      Caption = 'File'
      object miExit: TMenuItem
        Caption = 'Exit'
        OnClick = miExitClick
      end
    end
  end
end
