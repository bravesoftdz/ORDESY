unit uProjectDialogs;

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
    lblDateCreate: TLabel;
    lblDate: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateCurrentDateTime(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
  end;

function ShowProjectCreateDialog(const aCreator: string; var aProjectList: TORDESYProjectList): boolean;
function ShowProjectEditDialog(aProject: TORDESYProject): boolean;
function ShowModuleCreateDialog(aProject: TORDESYProject): boolean;
function ShowModuleEditDialog(aModule: TORDESYModule): boolean;

implementation

{$R *.dfm}

function ShowProjectCreateDialog(const aCreator: string; var aProjectList: TORDESYProjectList): boolean;
var
  dTimer: TTimer;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      lblCreator.Caption:= aCreator;
      dTimer:= TTimer.Create(Parent);
      dTimer.Interval:= 1000;
      dTimer.OnTimer:= UpdateCurrentDateTime;
      if ShowModal = mrOk then
      begin
        aProjectList.AddProject(TORDESYProject.Create(aProjectList.GetFreeProjectId, edtProjectName.Text, mmDescription.Text, lblCreator.Caption));
        Result:= true;
      end;
    finally
      dTimer.Free;
      Free;
    end;
end;

function ShowProjectEditDialog(aProject: TORDESYProject): boolean;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      Caption:= 'Edit project';
      edtProjectName.Text:= aProject.Name;
      mmDescription.Text:= aProject.Description;
      lblCreator.Caption:= aProject.Creator;
      lblDateCreate.Caption:= FormatDateTime('c', aProject.DateCreate);
      lblDateCreate.Visible:= true;
      btnCreate.Caption:= 'Save';
      if ShowModal = mrOk then
      begin
        aProject.Name:= edtProjectName.Text;
        aProject.Description:= mmDescription.Text;
        aProject.Creator:= lblCreator.Caption;
        Result:= true;
      end;
    finally
      Free;
    end;
end;

function ShowModuleCreateDialog(aProject: TORDESYProject): boolean;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      Caption:= 'Add module';
      lblCreatorHead.Visible:= false;
      lblDate.Visible:= false;
      if ShowModal = mrOk then
      begin
        aProject.AddModule(TORDESYModule.Create(aProject, aProject.GetFreeModuleId, edtProjectName.Text, mmDescription.Text));
        Result:= true;
      end;
    finally
      Free;
    end;
end;

function ShowModuleEditDialog(aModule: TORDESYModule): boolean;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      Caption:= 'Edit module';
      edtProjectName.Text:= aModule.Name;
      mmDescription.Text:= aModule.Description;
      lblCreatorHead.Visible:= false;
      lblDate.Visible:= false;
      btnCreate.Caption:= 'Save';
      if ShowModal = mrOk then
      begin
        aModule.Name:= edtProjectName.Text;
        aModule.Description:= mmDescription.Text;
        Result:= true;
      end;
    finally
      Free;
    end;
end;

procedure TfmProjectCreate.btnCreateClick(Sender: TObject);
begin
  if (edtProjectName.Text = '') or (length(edtProjectName.Text) > 255) then
  begin
    ModalResult:= mrNone;
    raise Exception.Create('Incorrect project name, empty or more than 255 characters!');
  end;
  if (length(mmDescription.Text) > 1000) then
  begin
    ModalResult:= mrNone;
    raise Exception.Create('Incorrect project description, more than 1000 characters!');
  end;
end;

procedure TfmProjectCreate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

procedure TfmProjectCreate.UpdateCurrentDateTime(Sender: TObject);
begin
  lblDateCreate.Caption:= FormatDateTime('c', Date + Time);
end;

end.
