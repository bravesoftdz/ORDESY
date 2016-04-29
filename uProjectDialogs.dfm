object fmProjectCreate: TfmProjectCreate
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Add Project'
  ClientHeight = 281
  ClientWidth = 414
  Color = clBtnFace
  Constraints.MinHeight = 305
  Constraints.MinWidth = 422
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Consolas'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 414
    Height = 281
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      414
      281)
    object lblCreatorHead: TLabel
      Left = 16
      Top = 232
      Width = 48
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Creator:'
    end
    object lblCreator: TLabel
      Left = 70
      Top = 232
      Width = 6
      Height = 13
      Anchors = [akLeft, akBottom]
    end
    object lblDateCreate: TLabel
      Left = 70
      Top = 251
      Width = 6
      Height = 13
      Anchors = [akLeft, akBottom]
    end
    object lblDate: TLabel
      Left = 16
      Top = 251
      Width = 30
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Date:'
    end
    object gpbProjectName: TGroupBox
      Left = 0
      Top = 0
      Width = 414
      Height = 49
      Align = alTop
      Caption = 'Name:'
      TabOrder = 0
      DesignSize = (
        414
        49)
      object edtProjectName: TEdit
        Left = 16
        Top = 16
        Width = 385
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 255
        TabOrder = 0
      end
    end
    object gpbDescription: TGroupBox
      Left = 0
      Top = 49
      Width = 414
      Height = 177
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Description:'
      TabOrder = 1
      DesignSize = (
        414
        177)
      object mmDescription: TMemo
        Left = 16
        Top = 24
        Width = 385
        Height = 137
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
      end
    end
    object btnCreate: TBitBtn
      Left = 328
      Top = 244
      Width = 73
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Create'
      Default = True
      DoubleBuffered = True
      ModalResult = 1
      ParentDoubleBuffered = False
      TabOrder = 2
      OnClick = btnCreateClick
    end
    object btnCancel: TBitBtn
      Left = 249
      Top = 244
      Width = 73
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 3
    end
  end
end
