object fmItemOptions: TfmItemOptions
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Item Options'
  ClientHeight = 438
  ClientWidth = 315
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  DesignSize = (
    315
    438)
  PixelsPerInch = 96
  TextHeight = 13
  object gbxName: TGroupBox
    Left = 0
    Top = 0
    Width = 315
    Height = 41
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Name:'
    TabOrder = 0
    ExplicitWidth = 383
    DesignSize = (
      315
      41)
    object edtName: TEdit
      Left = 6
      Top = 14
      Width = 303
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      ExplicitWidth = 371
    end
  end
  object gbxInfo: TGroupBox
    Left = 0
    Top = 41
    Width = 315
    Height = 245
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Connection info:'
    TabOrder = 1
    ExplicitWidth = 367
    ExplicitHeight = 235
    DesignSize = (
      315
      245)
    object lblBase: TLabel
      Left = 8
      Top = 24
      Width = 59
      Height = 13
      Caption = 'Select base:'
    end
    object lblScheme: TLabel
      Left = 162
      Top = 24
      Width = 72
      Height = 13
      Caption = 'Select scheme:'
    end
    object lbxBase: TListBox
      Left = 6
      Top = 43
      Width = 150
      Height = 196
      Anchors = [akLeft, akTop, akBottom]
      ItemHeight = 13
      TabOrder = 0
      ExplicitHeight = 186
    end
    object lbxScheme: TListBox
      Left = 159
      Top = 43
      Width = 150
      Height = 196
      Anchors = [akLeft, akTop, akBottom]
      ItemHeight = 13
      TabOrder = 1
      ExplicitHeight = 186
    end
  end
  object gbxTypeInfo: TGroupBox
    Left = 0
    Top = 286
    Width = 315
    Height = 105
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Type info:'
    TabOrder = 2
    ExplicitTop = 305
    DesignSize = (
      315
      105)
    object lblType: TLabel
      Left = 8
      Top = 21
      Width = 66
      Height = 13
      Caption = 'Change type:'
    end
    object lblHash: TLabel
      Left = 8
      Top = 61
      Width = 107
      Height = 13
      Caption = 'Body hash (Murmur2):'
    end
    object cbxType: TComboBox
      Left = 6
      Top = 38
      Width = 150
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemIndex = 0
      TabOrder = 0
      Text = 'PROCEDURE'
      Items.Strings = (
        'PROCEDURE'
        'FUNCTION'
        'PACKAGE')
    end
    object chbxValid: TCheckBox
      Left = 162
      Top = 40
      Width = 97
      Height = 17
      Anchors = [akTop]
      Caption = 'Valid'
      Enabled = False
      TabOrder = 1
    end
    object edtHash: TEdit
      Left = 6
      Top = 76
      Width = 303
      Height = 21
      ReadOnly = True
      TabOrder = 2
    end
  end
  object pnlSystem: TPanel
    Left = 0
    Top = 397
    Width = 315
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitTop = 403
    object btnSave: TButton
      Left = 234
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Save'
      ModalResult = 1
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnCancel: TButton
      Left = 153
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnFolder: TButton
      Left = 6
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Open folder'
      TabOrder = 2
    end
  end
end
