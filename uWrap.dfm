object fmWrap: TfmWrap
  Left = 0
  Top = 0
  Caption = 'Wrap item'
  ClientHeight = 490
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 535
    Height = 490
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 112
    ExplicitTop = 144
    ExplicitWidth = 185
    ExplicitHeight = 41
    DesignSize = (
      535
      490)
    object lblItemType: TLabel
      Left = 8
      Top = 8
      Width = 28
      Height = 13
      Caption = 'Type:'
    end
    object lblProject: TLabel
      Left = 8
      Top = 415
      Width = 38
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Project:'
      ExplicitTop = 414
    end
    object lblModule: TLabel
      Left = 8
      Top = 434
      Width = 38
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Module:'
      ExplicitTop = 433
    end
    object lblBase: TLabel
      Left = 8
      Top = 453
      Width = 27
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Base:'
      ExplicitTop = 452
    end
    object lblScheme: TLabel
      Left = 8
      Top = 472
      Width = 41
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Scheme:'
      ExplicitTop = 471
    end
    object cbxItemType: TComboBox
      Left = 8
      Top = 24
      Width = 518
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemIndex = 0
      TabOrder = 0
      Text = 'PROCEDURE'
      Items.Strings = (
        'PROCEDURE'
        'FUNCTION'
        'PACKAGE')
      ExplicitWidth = 399
    end
    object lbxList: TListBox
      Left = 8
      Top = 51
      Width = 518
      Height = 360
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 1
    end
    object btnUpdate: TButton
      Left = 289
      Top = 457
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Update'
      ModalResult = 4
      TabOrder = 2
      OnClick = btnUpdateClick
      ExplicitLeft = 275
      ExplicitTop = 415
    end
    object btnWrap: TButton
      Left = 370
      Top = 457
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Wrap'
      Default = True
      ModalResult = 1
      TabOrder = 3
      ExplicitLeft = 356
      ExplicitTop = 415
    end
    object btnClose: TButton
      Left = 451
      Top = 457
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Close'
      ModalResult = 11
      TabOrder = 4
      OnClick = btnCloseClick
      ExplicitLeft = 437
      ExplicitTop = 415
    end
  end
end
