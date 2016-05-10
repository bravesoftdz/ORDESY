object fmWrap: TfmWrap
  Left = 0
  Top = 0
  Caption = 'Wrap item'
  ClientHeight = 421
  ClientWidth = 445
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 400
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
    Width = 445
    Height = 421
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      445
      421)
    object lblItemType: TLabel
      Left = 319
      Top = 8
      Width = 28
      Height = 13
      Caption = 'Type:'
    end
    object lblProject: TLabel
      Left = 8
      Top = 346
      Width = 38
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Project:'
      ExplicitTop = 414
    end
    object lblModule: TLabel
      Left = 8
      Top = 365
      Width = 38
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Module:'
      ExplicitTop = 433
    end
    object lblBase: TLabel
      Left = 8
      Top = 384
      Width = 27
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Base:'
      ExplicitTop = 452
    end
    object lblScheme: TLabel
      Left = 8
      Top = 403
      Width = 41
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Scheme:'
      ExplicitTop = 471
    end
    object lblBaseList: TLabel
      Left = 8
      Top = 8
      Width = 43
      Height = 13
      Caption = 'BaseList:'
    end
    object lblSchemeList: TLabel
      Left = 164
      Top = 8
      Width = 57
      Height = 13
      Caption = 'SchemeList:'
    end
    object cbxItemType: TComboBox
      Left = 318
      Top = 27
      Width = 118
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
    end
    object lbxList: TListBox
      Left = 8
      Top = 51
      Width = 428
      Height = 283
      Style = lbOwnerDrawFixed
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 1
      OnDrawItem = lbxListDrawItem
    end
    object btnUpdate: TButton
      Left = 199
      Top = 388
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Update'
      TabOrder = 2
      OnClick = btnUpdateClick
    end
    object btnWrap: TButton
      Left = 280
      Top = 388
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Wrap'
      Default = True
      ModalResult = 1
      TabOrder = 3
    end
    object btnClose: TButton
      Left = 361
      Top = 388
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Close'
      ModalResult = 11
      TabOrder = 4
      OnClick = btnCloseClick
    end
  end
end
