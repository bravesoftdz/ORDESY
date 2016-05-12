{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

Unit for handle/log errors
}
unit uErrorHandle;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  SysUtils, Windows, Forms;

procedure HandleError(const Args: array of const);

implementation

procedure HandleError(const Args: array of const);
  {$IFDEF Debug}
var
  i: integer;
  fmtStr, dvdr: string;
  {$ENDIF}
begin
  {$IFDEF Debug}
  dvdr:= '';
  for i := 0 to high(Args) do
  begin
    fmtStr:= fmtStr + dvdr + '%s';
    dvdr:= ' | ';
  end;
  AddToLog(Format(fmtStr, Args));
  MessageBox(0, PChar(Format(fmtStr, Args)), PChar('Error'), 48);
  {$ELSE}
  MessageBox(0, PChar(Args[high(Args)]), PChar('Error'), 48);
  {$ENDIF}
end;

end.
