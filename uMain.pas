{$DEFINE LOG}
unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, uORDESY, ExtCtrls, ComCtrls, ToolWin, uLog;

type
  TfmMain = class(TForm)
    TreeView1: TTreeView;
    ToolBar1: TToolBar;
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    ToolButton1: TToolButton;
    ComboBox1: TComboBox;
    pnlMain: TPanel;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
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
  {$IFDEF Debug}
  showmessage('LOG defined');
  {$ELSE}
  showmessage('LOG are not defined');
  {$ENDIF}
end;

end.
