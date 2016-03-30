unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TfmMain = class(TForm)
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    procedure miExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure InitApp;
    procedure FreeApp;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.FreeApp;
begin
  Application.Terminate;
end;

procedure TfmMain.InitApp;
begin

end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  fmMain.FreeApp;
end;

end.
