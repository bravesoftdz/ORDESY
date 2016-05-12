{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

Dialog to edit the list of bases in ProjectList.
}
unit uBaseList;

interface

uses
  // ORDESY Modules
  uORDESY, uErrorHandle,
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
      try
        Result:= false;
        ProjectList:= aProjectList;
        UpdateList(ProjectList);
        ShowModal;
        Result:= true;
      except
        on E: Exception do
          HandleError([ClassName, 'ShowBaseListDialog', E.Message]);
      end;
    finally
      Free;
    end;
end;

procedure TfmBaseList.btnAddClick(Sender: TObject);
begin
  try
    fmMain.AddBase(Self);
    UpdateList(ProjectList);
  except
    on E: Exception do
      HandleError([ClassName, 'btnAddClick', E.Message]);
  end;
end;

procedure TfmBaseList.btnDeleteClick(Sender: TObject);
var
  reply: word;
begin
  try
    if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.Items.Objects[lbxList.ItemIndex] is TOraBase) then
    begin
      reply:= MessageBox(Handle, PChar('Delete base: ' + TOraBase(lbxList.Items.Objects[lbxList.ItemIndex]).Name + '?' + #13#10), PChar('Confirm'), 36);
      if reply = IDYES then
        if ProjectList.RemoveBaseById(TOraBase(lbxList.Items.Objects[lbxList.ItemIndex]).Id) then
          UpdateList(ProjectList);
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'btnDeleteClick', E.Message]);
  end;
end;

procedure TfmBaseList.btnEditClick(Sender: TObject);
begin
  try
    if (lbxList.Count > 0) and (lbxList.ItemIndex >= 0) and (lbxList.Items.Objects[lbxList.ItemIndex] is TOraBase) then
      if fmMain.EditBase(TOraBase(lbxList.Items.Objects[lbxList.ItemIndex])) then
        UpdateList(ProjectList);
  except
    on E: Exception do
      HandleError([ClassName, 'btnEditClick', E.Message]);
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
  try
    lbxList.Items.BeginUpdate;
    lbxList.Clear;
    for i := 0 to aProjectList.OraBaseCount - 1 do
    begin
      iBase:= aProjectList.GetOraBaseByIndex(i);
      if Assigned(iBase) then
        lbxList.AddItem(inttostr(iBase.Id) + ':|' + iBase.Name, iBase);
    end;
    lbxList.Items.EndUpdate;
  except
    on E: Exception do
      HandleError([ClassName, 'UpdateList', E.Message]);
  end;
end;

end.
