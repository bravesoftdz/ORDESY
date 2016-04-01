program ORDESY;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uORDESY in 'uORDESY.pas',
  uLog in 'uLog.pas',
  uExplode in 'uExplode.pas',
  uShellFuncs in 'uShellFuncs.pas',
  uProjectCreate in 'uProjectCreate.pas' {fmProjectCreate};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'OrDeSy';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
