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

implementation

{$R *.dfm}

function ShowProjectCreateDialog(const aCreator: string; var aProjectList: TORDESYProjectList): boolean;
var
  iProject: TORDESYProject;
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
        iProject:= TORDESYProject.Create(aProjectList.GetFreeProjectId, edtProjectName.Text, mmDescription.Text, lblCreator.Caption);
        aProjectList.AddProject(iProject);
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
