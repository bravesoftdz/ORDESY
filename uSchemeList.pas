unit uSchemeList;

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
  TfmSchemeList = class(TForm)
    pnlControl: TPanel;
    lbxList: TListBox;
    btnAdd: TButton;
    btnDelete: TButton;
    btnEdit: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateList(aProjectList: TORDESYProjectList);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
  private
    ProjectList: TORDESYProjectList;
  end;

function ShowSchemeListDialog(aProjectList: TORDESYProjectList): boolean;

implementation

{$R *.dfm}

uses
  uMain;

function ShowSchemeListDialog(aProjectList: TORDESYProjectList): boolean;
begin
  with TfmSchemeList.Create(Application) do
    try
      Result:= false;
      ProjectList:= aProjectList;
      UpdateList(ProjectList);
      ShowModal;
      Result:= true;
    finally
      Free;
    end;
end;

procedure TfmSchemeList.btnAddClick(Sender: TObject);
begin
  fmMain.AddScheme(Self);
  UpdateList(ProjectList);
end;

procedure TfmSchemeList.btnDeleteClick(Sender: TObject);
var
  reply: word;
  iScheme: TOraScheme;
begin
  if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.Items.Objects[lbxList.ItemIndex] is TOraScheme) then
  begin
    iScheme:= TOraScheme(lbxList.Items.Objects[lbxList.ItemIndex]);
    reply:= MessageBox(Handle, PChar('Delete scheme: ' + iScheme.Login + '?' + #13#10), PChar('Confirm'), 36);
    if reply = IDYES then
    begin
      if ProjectList.RemoveSchemeById(iScheme.Id) then
        UpdateList(ProjectList)
      else
        ShowMessage('Can''t delete.');
    end;
  end;
end;

procedure TfmSchemeList.btnEditClick(Sender: TObject);
begin
  if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.Items.Objects[lbxList.ItemIndex] is TOraScheme) then
  begin
    fmMain.EditScheme(TOraScheme(lbxList.Items.Objects[lbxList.ItemIndex]));
    UpdateList(ProjectList);
  end;
end;

procedure TfmSchemeList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmSchemeList.UpdateList(aProjectList: TORDESYProjectList);
var
  i: integer;
  iScheme: TOraScheme;
begin
  lbxList.Clear;
  for i := 0 to aProjectList.OraSchemeCount - 1 do
  begin
    iScheme:= aProjectList.GetOraSchemeByIndex(i);
    lbxList.AddItem(inttostr(iScheme.Id) + ':|' + iScheme.Login, iScheme);
  end;
end;

end.
