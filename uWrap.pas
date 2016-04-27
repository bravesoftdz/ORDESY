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
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnUpdateClick(Sender: TObject);
  private
    SchemeId: integer;
    CurrentProject: TORDESYProject;
  end;

var
  fmWrap: TfmWrap;

function ShowWrapDialog(const aSchemeId: integer; var aProject: TORDESYProject): boolean;

implementation

{$R *.dfm}

function ShowWrapDialog(const aSchemeId: integer; var aProject: TORDESYProject): boolean;
var
  iScheme: TOraScheme;
begin
  with TfmWrap.Create(Application) do
    try
      CurrentProject:= aProject;
      SchemeId:= aSchemeId;
      if ShowModal = mrOk then
      begin
        try
          CurrentProject.WrapItem(aSchemeId,  lbxList.Items.Strings[lbxList.ItemIndex], TOraItem.GetItemType(cbxItemType.Items[cbxItemType.ItemIndex]));
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
  if Assigned(CurrentProject) then
  begin
    CurrentProject.GetOraSchemeById(SchemeId).Connect(CurrentProject);
    //CurrentProject.GetOraSchemeById(SchemeId).GetItemList(TOraItem.GetItemType(cbxItemType.Items[cbxItemType.ItemIndex]), lbxList.Items);
  end;
end;

procedure TfmWrap.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

end.
