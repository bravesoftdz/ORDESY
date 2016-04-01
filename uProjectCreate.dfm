object fmProjectCreate: TfmProjectCreate
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Create Project'
  ClientHeight = 283
  ClientWidth = 422
  Color = clBtnFace
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
    Width = 422
    Height = 283
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 80
    ExplicitTop = 104
    ExplicitWidth = 185
    ExplicitHeight = 41
    DesignSize = (
      422
      283)
    object lblCreatorHead: TLabel
      Left = 16
      Top = 232
      Width = 48
      Height = 13
      Caption = 'Creator:'
    end
    object lblCreator: TLabel
      Left = 70
      Top = 232
      Width = 6
      Height = 13
    end
    object gpbProjectName: TGroupBox
      Left = 0
      Top = 0
      Width = 422
      Height = 57
      Align = alTop
      Caption = 'Name:'
      TabOrder = 0
      ExplicitTop = 81
      object edtProjectName: TEdit
        Left = 16
        Top = 16
        Width = 393
        Height = 21
        MaxLength = 255
        TabOrder = 0
      end
    end
    object gpbDescription: TGroupBox
      Left = 0
      Top = 57
      Width = 422
      Height = 160
      Align = alTop
      Caption = 'Description:'
      TabOrder = 1
      object mmDescription: TMemo
        Left = 16
        Top = 24
        Width = 393
        Height = 121
        TabOrder = 0
      end
    end
    object btnCreate: TBitBtn
      Left = 222
      Top = 246
      Width = 73
      Height = 25
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Create'
      Default = True
      DoubleBuffered = True
      ModalResult = 1
      ParentDoubleBuffered = False
      TabOrder = 2
      ExplicitTop = 248
      ExplicitWidth = 75
    end
    object btnCancel: TBitBtn
      Left = 126
      Top = 246
      Width = 73
      Height = 25
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Cancel'
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 3
      ExplicitTop = 248
      ExplicitWidth = 75
    end
  end
end
