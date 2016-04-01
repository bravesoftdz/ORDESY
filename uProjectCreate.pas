unit uProjectCreate;

interface

uses
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

function ShowProjectCreateDialog(): boolean;

implementation

{$R *.dfm}

function ShowProjectCreateDialog(): boolean;
begin
  with TfmProjectCreate.Create(Application) do
    try
      Result:= false;
      if ModalResult = mrOk then
      begin
        ShowMessage('All ok!');
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
