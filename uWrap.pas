unit uWrap;

interface

uses
  // ORDESY Modules
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uORDESY,
  // Delphi Modules
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfmWrap = class(TForm)
    cbxItemType: TComboBox;
    lblItemType: TLabel;
    pnlMain: TPanel;
    lbxList: TListBox;
    btnUpdate: TButton;
    btnWrap: TButton;
    btnClose: TButton;
    lblProject: TLabel;
    lblModule: TLabel;
    lblBase: TLabel;
    lblScheme: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnUpdateClick(Sender: TObject);
    procedure lbxListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
  private
    SchemeId: integer;
    CurrentProject: TORDESYProject;
  end;

var
  fmWrap: TfmWrap;

function ShowWrapDialog(const aSchemeId: integer; aProject: TORDESYProject): boolean;

implementation

{$R *.dfm}

uses
  uMain;

function ShowWrapDialog(const aSchemeId: integer; aProject: TORDESYProject): boolean;
var
  iScheme: TOraScheme;
begin
  with TfmWrap.Create(Application) do
    try
      Result:= false;
      CurrentProject:= aProject;
      SchemeId:= aSchemeId;
      lblProject.Caption:= 'Project: ' + aProject.Name;
      lblModule.Caption:= 'Module: ' + aProject.GetModuleById(aProject.GetOraSchemeById(SchemeId).ModuleId).Name;
      lblBase.Caption:= 'Base: ' + aProject.GetOraBaseById(aProject.GetOraSchemeById(SchemeId).BaseId).Name;
      lblScheme.Caption:= 'Scheme: ' + aProject.GetOraSchemeById(SchemeId).Login;
      btnUpdateClick(nil);
      if ShowModal = mrOk then
      begin
        try
          CurrentProject.WrapItem(aSchemeId,  lbxList.Items.Strings[lbxList.ItemIndex], TOraItem.GetItemType(cbxItemType.Items[cbxItemType.ItemIndex]));
          Result:= true;
        except
          on E: Exception do
          begin
            {$IFDEF Debug}
            AddToLog(ClassName + ' | WrapItem | ' + E.Message);
            MessageBox(Application.Handle, PChar(ClassName + ' | WrapItem | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
            {$ELSE}
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
            {$ENDIF}
          end;
        end;
      end;
    finally
      Free;
    end;
end;

procedure TfmWrap.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmWrap.btnUpdateClick(Sender: TObject);
begin
  if Assigned(CurrentProject) then
  begin
    CurrentProject.GetOraSchemeById(SchemeId).Connect(CurrentProject);
    CurrentProject.GetOraSchemeById(SchemeId).GetItemList(TOraItem.GetItemType(cbxItemType.Items[cbxItemType.ItemIndex]), lbxList.Items);
  end;
end;

procedure TfmWrap.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmWrap.lbxListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  IItem: TOraItemHead;
  ValidIcon, NotValidIcon: TBitmap;
begin
  if (Assigned(lbxList.Items.Objects[Index])) and (lbxList.Items.Objects[Index] is TOraItemHead) then
  begin
    try
      ValidIcon:= TBitmap.Create;
      NotValidIcon:= TBitmap.Create;
      fmMain.imlMain.GetBitmap(1, NotValidIcon);
      IItem:= TOraItemHead(lbxList.Items.Objects[Index]);
      case IItem.ItemType of
        OraProcedure: begin
          fmMain.imlMain.GetBitmap(15, ValidIcon);
        end;
        OraFunction: begin
          fmMain.imlMain.GetBitmap(14, ValidIcon);
        end;
        OraPackage: begin
          fmMain.imlMain.GetBitmap(9, ValidIcon);
        end;
      end;
      if not IItem.Valid then
        ValidIcon.Canvas.Draw(0, 0, NotValidIcon);
      lbxList.Canvas.FillRect(Rect);
      lbxList.Canvas.Draw(2, Rect.Top + 2, ValidIcon);
      lbxList.Canvas.TextOut(18, Rect.Top + ((lbxList.ItemHeight div 2) - (Canvas.TextHeight('A') div 2)), lbxList.Items[Index]);
    finally
      ValidIcon.Free;
      NotValidIcon.Free;
    end;
  end;
end;

end.
