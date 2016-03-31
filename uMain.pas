{$DEFINE ERROR_ALL}
unit uMain;

interface

uses
  uORDESY, uLog, uExplode,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList;

type
  TfmMain = class(TForm)
    tvMain: TTreeView;
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    pnlMain: TPanel;
    imlMain: TImageList;
    procedure miExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure InitApp;
    procedure PrepareGUI;
    procedure FreeApp;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  InitApp;
end;

procedure TfmMain.FreeApp;
begin
  Application.Terminate;
end;

procedure TfmMain.InitApp;
begin
  PrepareGUI;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  fmMain.FreeApp;
end;

// Инициализация интерфейса ползователя
procedure TfmMain.PrepareGUI;
begin

end;

end.
