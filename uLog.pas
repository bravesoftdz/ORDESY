unit uLog;

interface

uses
  SysUtils;

procedure AddToLog(s: string);

implementation

procedure AddToLog(s: string);
var
  fn: string;
  F: TextFile;
begin
  Fn := ExtractFilePath(ParamStr(0)) + 'log.txt';
  assignFile(f, fn);
  if FileExists(fn) then
    Append(f)
  else
    Rewrite(f);
  //Writeln(f,DateTimeToStr(Now));
  Writeln(f, s);
  Flush(f);
  Closefile(f);
end;

end.

