object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'OrDeSy'
  ClientHeight = 644
  ClientWidth = 822
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 822
    Height = 25
    Caption = 'ToolBar1'
    TabOrder = 0
    ExplicitWidth = 819
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'ToolButton1'
      ImageIndex = 0
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object ComboBox1: TComboBox
      Left = 31
      Top = 0
      Width = 145
      Height = 21
      TabOrder = 0
      Text = 'ComboBox1'
    end
    object ToolButton3: TToolButton
      Left = 176
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 25
    Width = 822
    Height = 619
    Align = alClient
    BevelOuter = bvNone
    DoubleBuffered = False
    ParentDoubleBuffered = False
    TabOrder = 1
    ExplicitWidth = 819
    object TreeView1: TTreeView
      Left = 23
      Top = 49
      Width = 281
      Height = 400
      Align = alCustom
      Indent = 19
      TabOrder = 0
    end
  end
  object mmMain: TMainMenu
    Left = 16
    Top = 40
    object miFile: TMenuItem
      Caption = 'File'
      object miExit: TMenuItem
        Caption = 'Exit'
        OnClick = miExitClick
      end
    end
  end
end
