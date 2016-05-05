object fmSchemeDialog: TfmSchemeDialog
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Add scheme'
  ClientHeight = 138
  ClientWidth = 214
  Color = clBtnFace
  Constraints.MinHeight = 162
  Constraints.MinWidth = 222
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 214
    Height = 138
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 168
    DesignSize = (
      214
      138)
    object gbxLogin: TGroupBox
      Left = 0
      Top = 0
      Width = 214
      Height = 49
      Align = alTop
      Caption = 'Login:'
      TabOrder = 0
      ExplicitWidth = 426
      DesignSize = (
        214
        49)
      object edtLogin: TEdit
        Left = 7
        Top = 17
        Width = 200
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        ExplicitWidth = 234
      end
    end
    object gbxPass: TGroupBox
      Left = 0
      Top = 49
      Width = 214
      Height = 49
      Align = alTop
      Caption = 'Password:'
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 230
      DesignSize = (
        214
        49)
      object edtPass: TEdit
        Left = 7
        Top = 17
        Width = 200
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object btnCancel: TButton
      Left = 16
      Top = 104
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object btnSave: TButton
      Left = 120
      Top = 104
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Save'
      ModalResult = 1
      TabOrder = 3
      OnClick = btnSaveClick
    end
  end
end
