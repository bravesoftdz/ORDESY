unit uMain;

interface

uses
  {$IFDEF Debug}
    uLog,
  {$ENDIF}
  uORDESY, uExplode, uShellFuncs,
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
    procedure tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
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
  tvMain.Items.AddObject(nil, 'scribe', TOraItem.Create('scribe'));
  tvMain.Items.AddObject(nil, 'scribe2', TOraItem.Create('scribe', '', OraFunction));
  tvMain.Items.AddObject(nil, 'scribe3', TOraItem.Create('scribe', '', OraPackage));
end;

procedure TfmMain.tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex:= Node.ImageIndex;
  if TObject(Node.Data) is TOraItem then
    case TOraItem(Node.Data).ItemType of
      OraProcedure:
        begin
          Node.ImageIndex:= 15;
        end;
      OraFunction:
        begin
          Node.ImageIndex:= 14;
        end;
      OraPackage:
        begin
          Node.ImageIndex:= 9;
        end;
    end;
end;

end.
