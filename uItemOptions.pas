unit uItemOptions;

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
  TfmItemOptions = class(TForm)
    gbxName: TGroupBox;
    edtName: TEdit;
    gbxInfo: TGroupBox;
    lbxBase: TListBox;
    lblBase: TLabel;
    lbxScheme: TListBox;
    lblScheme: TLabel;
    gbxTypeInfo: TGroupBox;
    cbxType: TComboBox;
    lblType: TLabel;
    chbxValid: TCheckBox;
    edtHash: TEdit;
    lblHash: TLabel;
    pnlSystem: TPanel;
    btnSave: TButton;
    btnCancel: TButton;
    btnFolder: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSaveClick(Sender: TObject);
  private
    procedure VisualizeItemType(aType: TOraItemType);
    procedure LoadBases(aItem: TOraItem);
    procedure LoadSchemes(aItem: ToraItem);
  public
    { Public declarations }
  end;

function ShowItemOptionsDialog(aItem: TOraItem): boolean;

implementation

{$R *.dfm}

function ShowItemOptionsDialog(aItem: TOraItem): boolean;
begin
  with TfmItemOptions.Create(Application) do
    try
      Result:= false;
      edtName.Text:= aItem.Name;
      chbxValid.Checked:= aItem.Valid;
      VisualizeItemType(aItem.ItemType);
      LoadBases(aItem);
      LoadSchemes(aItem);
      edtHash.Text:= inttostr(aItem.Hash);
      if ShowModal = mrOk then
      begin
        aItem.Name:= edtName.Text;
        aItem.ItemType:= TOraItem.GetItemType(cbxType.Items.Strings[cbxType.ItemIndex]);
        aItem.BaseId:= TOraBase(lbxBase.Items.Objects[lbxBase.ItemIndex]).Id;
        aItem.SchemeId:= TOraScheme(lbxScheme.Items.Objects[lbxScheme.ItemIndex]).Id;
      end;
      Result:= true;
    finally
      Free;
    end;
end;

procedure TfmItemOptions.btnSaveClick(Sender: TObject);
begin
  if (edtName.Text = '') or (Length(edtName.Text) > 255) then
    ModalResult:= mrNone;
end;

procedure TfmItemOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmItemOptions.LoadBases(aItem: TOraItem);
var
  iProjectList: TORDESYProjectList;
  i: integer;
begin
  try
    lbxBase.Items.BeginUpdate;
    lbxBase.Clear;
    iProjectList:= TORDESYProjectList(TORDESYProject(TORDESYModule(aItem.ModuleRef).ProjectRef).ProjectListRef);
    for i := 0 to iProjectList.OraBaseCount - 1 do
      lbxBase.AddItem(iProjectList.GetOraBaseNameByIndex(i), iProjectList.GetOraBaseByIndex(i));
    for i := 0 to lbxBase.Count - 1 do
      if TOraBase(lbxBase.Items.Objects[i]).Id = aItem.BaseId then
        lbxBase.ItemIndex:= i;
    lbxBase.Items.EndUpdate;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | LoadBases | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | LoadBases | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmItemOptions.LoadSchemes(aItem: TOraItem);
var
  iProjectList: TORDESYProjectList;
  i: integer;
begin
  try
    lbxScheme.Items.BeginUpdate;
    lbxScheme.Clear;
    iProjectList:= TORDESYProjectList(TORDESYProject(TORDESYModule(aItem.ModuleRef).ProjectRef).ProjectListRef);
    for i := 0 to iProjectList.OraSchemeCount - 1 do
      lbxScheme.AddItem(iProjectList.GetOraSchemeLoginByIndex(i), iProjectList.GetOraSchemeByIndex(i));
    for i := 0 to lbxScheme.Count - 1 do
      if TOraScheme(lbxScheme.Items.Objects[i]).Id = aItem.SchemeId then
        lbxScheme.ItemIndex:= i;
    lbxScheme.Items.EndUpdate;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | LoadSchemes | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | LoadSchemes | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmItemOptions.VisualizeItemType(aType: TOraItemType);
begin
  case aType of
    OraProcedure:
      cbxType.ItemIndex:= 0;
    OraFunction:
      cbxType.ItemIndex:= 1;
    OraPackage:
      cbxType.ItemIndex:= 2
    else
      cbxType.ItemIndex:= 0;
  end;
end;

end.
