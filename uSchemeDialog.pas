{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

Dialog to create/edit schemes.
}
unit uSchemeDialog;

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
  TfmSchemeDialog = class(TForm)
    pnlMain: TPanel;
    gbxLogin: TGroupBox;
    gbxPass: TGroupBox;
    edtPass: TEdit;
    edtLogin: TEdit;
    btnCancel: TButton;
    btnSave: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSaveClick(Sender: TObject);
  end;

function ShowSchemeCreateDialog(aProjectList: TORDESYProjectList): boolean;
function ShowSchemeEditDialog(aScheme: TOraScheme): boolean;

implementation

{$R *.dfm}

function ShowSchemeCreateDialog(aProjectList: TORDESYProjectList): boolean;
begin
  with TfmSchemeDialog.Create(Application) do
    try
      Caption:= 'Add scheme';
      if ShowModal = mrOk then
      begin
        aProjectList.AddOraScheme(TOraScheme.Create(aProjectList, aProjectList.GetFreeSchemeId, edtLogin.Text, edtPass.Text));
      end;
    finally
      Free;
    end;
end;

function ShowSchemeEditDialog(aScheme: TOraScheme): boolean;
begin
  with TfmSchemeDialog.Create(Application) do
    try
      Caption:= 'Edit scheme';
      edtLogin.Text:= aScheme.Login;
      edtPass.Text:= aScheme.Pass;
      if ShowModal = mrOk then
      begin
        aScheme.Login:= edtLogin.Text;
        aScheme.Pass:= edtPass.Text;
      end;
    finally
      Free;
    end;
end;

procedure TfmSchemeDialog.btnSaveClick(Sender: TObject);
begin
  if (edtLogin.Text = '') or (Length(edtLogin.Text) > 255) then
  begin
    ModalResult:= mrNone;
    raise Exception.Create('Incorrect scheme name, empty or more than 255 characters!');
  end;
  if (Length(edtPass.Text) > 255) then
  begin
    ModalResult:= mrNone;
    raise Exception.Create('Incorrect scheme password, more than 255 characters!');
  end;
end;

procedure TfmSchemeDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

end.
