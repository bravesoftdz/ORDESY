program ORDESY;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uORDESY in 'uORDESY.pas',
  uLog in 'uLog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
