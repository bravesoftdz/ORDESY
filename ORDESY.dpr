program ORDESY;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uORDESY in 'uORDESY.pas',
  uLog in 'uLog.pas',
  uExplode in 'uExplode.pas',
  uShellFuncs in 'uShellFuncs.pas',
  uProject in 'uProject.pas' {fmProject},
  uOptions in 'uOptions.pas';

{$R *.res}

begin
  {$IFDEF Debug}
  ReportMemoryLeaksOnShutdown := true; // Проверка на утечки памяти
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'OrDeSy';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
