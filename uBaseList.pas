unit uBaseList;

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
  TfmBaseList = class(TForm)
    lbxList: TListBox;
    pnlControl: TPanel;
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

function ShowBaseListDialog(aProjectList: TORDESYProjectList): boolean;

implementation

{$R *.dfm}

uses
  uMain;

function ShowBaseListDialog(aProjectList: TORDESYProjectList): boolean;
begin
  with TfmBaseList.Create(Application) do
    try
      ProjectList:= aProjectList;
      UpdateList(ProjectList);
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfmBaseList.btnAddClick(Sender: TObject);
begin
  fmMain.AddBase(Self);
  UpdateList(ProjectList);
end;

procedure TfmBaseList.btnDeleteClick(Sender: TObject);
begin
  if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.Items.Objects[lbxList.ItemIndex] is TOraBase) then
  begin
    ProjectList.RemoveBaseById(TOraBase(lbxList.Items.Objects[lbxList.ItemIndex]).Id);
    UpdateList(ProjectList);
  end;
end;

procedure TfmBaseList.btnEditClick(Sender: TObject);
begin
  if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.Items.Objects[lbxList.ItemIndex] is TOraBase) then
  begin
    fmMain.EditBase(TOraBase(lbxList.Items.Objects[lbxList.ItemIndex]));
    UpdateList(ProjectList);
  end;
end;

procedure TfmBaseList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmBaseList.UpdateList(aProjectList: TORDESYProjectList);
var
  i: integer;
  iBase: TOraBase;
begin
  lbxList.Clear;
  for i := 0 to aProjectList.OraBaseCount - 1 do
  begin
    iBase:= aProjectList.GetOraBaseByIndex(i);
    lbxList.AddItem(inttostr(iBase.Id) + ':|' + iBase.Name, iBase);
  end;
end;

end.
