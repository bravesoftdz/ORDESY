unit uProjectCreate;

interface

uses
  uORDESY,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TfmProjectCreate = class(TForm)
    pnlMain: TPanel;
    gpbProjectName: TGroupBox;
    edtProjectName: TEdit;
    gpbDescription: TGroupBox;
    mmDescription: TMemo;
    lblCreatorHead: TLabel;
    lblCreator: TLabel;
    btnCreate: TBitBtn;
    btnCancel: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

function ShowProjectCreateDialog(const aCreator: string; var aProjectList: TORDESYProjectList): boolean;
function ShowProjectEditDialog(var aProject: TORDESYProject): boolean;

implementation

{$R *.dfm}

function ShowProjectCreateDialog(const aCreator: string; var aProjectList: TORDESYProjectList): boolean;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      lblCreator.Caption:= aCreator;
      if ShowModal = mrOk then
      begin
        if (edtProjectName.Text = '') or (length(edtProjectName.Text) > 255) then
          raise Exception.Create('Incorrect project name, empty or more than 255 characters!');
        if (length(mmDescription.Text) > 1000) then
          raise Exception.Create('Incorrect project description, more than 1000 characters!');
        aProjectList.AddProject(TORDESYProject.Create(aProjectList.GetFreeProjectId, edtProjectName.Text, mmDescription.Text, lblCreator.Caption));
        Result:= true;
      end;
    finally
      Free;
    end;
end;

function ShowProjectEditDialog(var aProject: TORDESYProject): boolean;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      Caption:= 'Edit project';
      edtProjectName.Text:= aProject.Name;
      mmDescription.Text:= aProject.Description;
      lblCreator.Caption:= aProject.Creator;
      btnCreate.Caption:= 'Save';
      if ShowModal = mrOk then
      begin
        if (edtProjectName.Text = '') or (length(edtProjectName.Text) > 255) then
          raise Exception.Create('Incorrect project name, empty or more than 255 characters!');
        if (length(mmDescription.Text) > 1000) then
          raise Exception.Create('Incorrect project description, more than 1000 characters!');
        aProject.Name:= edtProjectName.Text;
        aProject.Description:= mmDescription.Text;
        aProject.Creator:= lblCreator.Caption;
        Result:= true;
      end;
    finally
      Free;
    end;
end;

procedure TfmProjectCreate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

end.
