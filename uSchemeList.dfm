object fmSchemeList: TfmSchemeList
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Scheme list'
  ClientHeight = 332
  ClientWidth = 254
  Color = clBtnFace
  Constraints.MinHeight = 356
  Constraints.MinWidth = 262
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
  object pnlControl: TPanel
    Left = 0
    Top = 296
    Width = 254
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      254
      36)
    object btnAdd: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Add'
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 89
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Delete'
      TabOrder = 1
      OnClick = btnDeleteClick
    end
    object btnEdit: TButton
      Left = 170
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Edit'
      TabOrder = 2
      OnClick = btnEditClick
    end
  end
  object lbxList: TListBox
    Left = 0
    Top = 0
    Width = 254
    Height = 296
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
  end
end
