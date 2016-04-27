unit uWrap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfmWrap = class(TForm)
    cbxitemType: TComboBox;
    lblItemType: TLabel;
    pnlMain: TPanel;
    ListBox1: TListBox;
    btnUpdate: TButton;
    btnWrap: TButton;
    btnClose: TButton;
    lblProject: TLabel;
    lblModule: TLabel;
    lblBase: TLabel;
    lblScheme: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmWrap: TfmWrap;

implementation

{$R *.dfm}

function ShowWrapDialog(): boolean;
begin

end;

procedure TfmWrap.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmWrap.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:= caFree;
end;

end.
