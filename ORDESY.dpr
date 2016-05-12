program ORDESY;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uORDESY in 'uORDESY.pas',
  uLog in 'uLog.pas',
  uExplode in 'uExplode.pas',
  uShellFuncs in 'uShellFuncs.pas',
  uProjectDialogs in 'uProjectDialogs.pas' {fmProject},
  uOptions in 'uOptions.pas',
  uHash in 'uHash.pas',
  uWrap in 'uWrap.pas',
  uBaseList in 'uBaseList.pas' {fmBaseList},
  uSchemeList in 'uSchemeList.pas' {fmSchemeList},
  uSchemeDialog in 'uSchemeDialog.pas' {fmSchemeDialog},
  uLazyTreeState in 'uLazyTreeState.pas',
  uItemOptions in 'uItemOptions.pas' {fmItemOptions};

{$R *.res}

begin
  {$IFDEF Debug}
  ReportMemoryLeaksOnShutdown := true; // Check for memory leaks
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'OrDeSy';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
