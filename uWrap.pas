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
  TWrapComboBox = class(TComboBox)
  protected
    procedure WM_CB_SETCURSEL(var Message: TMessage); message CB_SETCURSEL;
  end;

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
    lblBaseList: TLabel;
    lblSchemeList: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnUpdateClick(Sender: TObject);
    procedure lbxListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure cbxBaseListSelect(Sender: TObject);
    procedure cbxSchemeListSelect(Sender: TObject);
    procedure PrepareGUI;
    procedure btnWrapClick(Sender: TObject);
    procedure cbxItemTypeChange(Sender: TObject);
    procedure lbxListClick(Sender: TObject);
  private
    CurrentProject: TORDESYProject;
    CurrentBase: TOraBase;
    CurrentScheme: TOraScheme;
    CurrentType: string;
    CurrentName: string;
  end;

var
  fmWrap: TfmWrap;

function ShowWrapDialog(aModule: TORDESYModule; aProjectList: TORDESYProjectList): boolean;

implementation

{$R *.dfm}

uses
  uMain;

function ShowWrapDialog(aModule: TORDESYModule; aProjectList: TORDESYProjectList): boolean;
var
  iScheme: TOraScheme;
  iWrapBase, iWrapScheme: TWrapComboBox;
  i, n: integer;
begin
  with TfmWrap.Create(Application) do
    try
      Result:= false;
      PrepareGUI;
      CurrentProject:= TORDESYProject(aModule.ProjectRef);
      for n := 0 to pnlMain.ControlCount - 1 do
      begin
        if (pnlMain.Controls[n] is TWrapComboBox) and (TWrapComboBox(pnlMain.Controls[n]).Name = 'cbxWrapBase') then
          iWrapBase:= TWrapComboBox(pnlMain.Controls[n]);
        if (pnlMain.Controls[n] is TWrapComboBox) and (TWrapComboBox(pnlMain.Controls[n]).Name = 'cbxWrapScheme') then
          iWrapScheme:= TWrapComboBox(pnlMain.Controls[n]);
      end;
      for i := 0 to aProjectList.OraBaseCount - 1 do
        iWrapBase.Items.AddObject(aProjectList.GetOraBaseNameByIndex(i), aProjectList.GetOraBaseByIndex(i));
      if iWrapBase.Items.Count <> 0 then
        iWrapBase.ItemIndex:= 0;
      for i := 0 to aProjectList.OraSchemeCount - 1 do
        iWrapScheme.Items.AddObject(aProjectList.GetOraSchemeLogin(i), aProjectList.GetOraSchemeByIndex(i));
      if iWrapScheme.Items.Count <> 0 then
        iWrapScheme.ItemIndex:= 0;
      lblProject.Caption:= 'Project: ' + CurrentProject.Name;
      lblModule.Caption:= 'Module: ' + aModule.Name;
      if Assigned(CurrentBase) then
        lblBase.Caption:= 'Base: ' + CurrentBase.Name;
      if Assigned(CurrentScheme) then
        lblScheme.Caption:= 'Scheme: ' + CurrentScheme.Login;
      if ShowModal = mrOk then
      begin
        try
          CurrentProject.WrapItem(aModule.Id, CurrentBase.Id, CurrentScheme.Id, CurrentName, TOraItem.GetItemType(CurrentType));
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
  try
  if Assigned(CurrentProject) and Assigned(CurrentBase) and Assigned(CurrentScheme) then
  begin
    CurrentScheme.Connect(CurrentBase.Id);
    CurrentScheme.GetItemList(TOraItem.GetItemType(cbxItemType.Items[cbxItemType.ItemIndex]), lbxList.Items);
  end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | btnUpdateClick | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | btnUpdateClick | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmWrap.btnWrapClick(Sender: TObject);
begin
  if not Assigned(CurrentProject) or not Assigned(CurrentBase) or not Assigned(CurrentScheme) or (CurrentType = '') or (CurrentName = '') then
    ModalResult:= mrNone;
end;

procedure TfmWrap.cbxBaseListSelect(Sender: TObject);
begin
  if (Sender is TWrapComboBox) and (TWrapComboBox(Sender).Items.Count > 0) and (TWrapComboBox(Sender).Items.Objects[TWrapComboBox(Sender).ItemIndex] <> nil) and (TObject(TWrapComboBox(Sender).Items.Objects[TWrapComboBox(Sender).ItemIndex]) is TOraBase) then
  begin
    CurrentBase:= TOraBase(TWrapComboBox(Sender).Items.Objects[TWrapComboBox(Sender).ItemIndex]);
    lblBase.Caption:= 'Base: ' + CurrentBase.Name;
  end;
end;

procedure TfmWrap.cbxItemTypeChange(Sender: TObject);
begin
  try
    if (cbxItemType.Items.Count > 0) and (cbxItemType.ItemIndex >= 0) and (cbxItemType.ItemIndex < cbxItemType.Items.Count) then
      CurrentType:= cbxItemType.Items.Strings[cbxItemType.ItemIndex]
    else
      CurrentType:= '';
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | cbxItemTypeChange | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | cbxItemTypeChange | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmWrap.cbxSchemeListSelect(Sender: TObject);
begin
  try
    if (Sender is TWrapComboBox) and (TWrapComboBox(Sender).Items.Count > 0) and (TWrapComboBox(Sender).Items.Objects[TWrapComboBox(Sender).ItemIndex] <> nil) and (TObject(TWrapComboBox(Sender).Items.Objects[TWrapComboBox(Sender).ItemIndex]) is TOraScheme) then
    begin
      CurrentScheme:= TOraScheme(TWrapComboBox(Sender).Items.Objects[TWrapComboBox(Sender).ItemIndex]);
      lblScheme.Caption:= 'Scheme: ' + CurrentScheme.Login;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | cbxSchemeListSelect | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | cbxSchemeListSelect | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmWrap.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmWrap.lbxListClick(Sender: TObject);
begin
  try
    if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.ItemIndex < lbxList.Count) then
      CurrentName:= lbxList.Items.Strings[lbxList.ItemIndex]
    else
      CurrentName:= '';
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | lbxListClick | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | lbxListClick | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmWrap.lbxListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  IItem: TOraItemHead;
  ValidIcon: TBitmap;
  NotValidIcon: TIcon;
begin
  try
    if (Assigned(lbxList.Items.Objects[Index])) and (lbxList.Items.Objects[Index] is TOraItemHead) then
    begin
      try
        ValidIcon:= TBitmap.Create;
        NotValidIcon:= TIcon.Create;
        fmMain.imlMain.GetIcon(1, NotValidIcon);
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
        lbxList.ItemHeight:= ValidIcon.Height + 2;
        lbxList.Canvas.FillRect(Rect);
        lbxList.Canvas.Draw(1, Rect.Top + 1, ValidIcon);
        lbxList.Canvas.TextOut(20, Rect.Top + ((lbxList.ItemHeight div 2) - (Canvas.TextHeight('A') div 2)), lbxList.Items[Index]);
      finally
        ValidIcon.Free;
        NotValidIcon.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | lbxListDrawItem | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | lbxListDrawItem | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmWrap.PrepareGUI;
var
  cbxWrapBase: TWrapComboBox;
  cbxWrapScheme: TWrapComboBox;
begin
  cbxWrapBase:= TWrapComboBox.Create(Self);
  cbxWrapBase.Anchors:= [akLeft, akTop];
  cbxWrapBase.Name:= 'cbxWrapBase';
  cbxWrapBase.OnChange:= cbxBaseListSelect;
  cbxWrapBase.Left:= 8;
  cbxWrapBase.Top:= 27;
  cbxWrapBase.Width:= 150;
  cbxWrapBase.Height:= 21;
  cbxWrapBase.Style:= csDropDownList;
  cbxWrapBase.Visible:= true;
  cbxWrapBase.Parent:= pnlMain;
  //
  cbxWrapScheme:= TWrapComboBox.Create(Self);
  cbxWrapScheme.Anchors:= [akLeft, akTop];
  cbxWrapScheme.Name:= 'cbxWrapScheme';
  cbxWrapScheme.OnChange:= cbxSchemeListSelect;
  cbxWrapScheme.Left:= 162;
  cbxWrapScheme.Top:= 27;
  cbxWrapScheme.Width:= 150;
  cbxWrapScheme.Height:= 21;
  cbxWrapScheme.Style:= csDropDownList;
  cbxWrapScheme.Visible:= true;
  cbxWrapScheme.Parent:= pnlMain;
  //
  CurrentType:= 'PROCEDURE';
end;

{ TWrapComboBox }

procedure TWrapComboBox.WM_CB_SETCURSEL(var Message: TMessage);
begin
  inherited;
  if Assigned(OnChange) then
    OnChange(Self);
end;

end.
