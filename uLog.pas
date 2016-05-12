{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

As a part of project.
Desc: logging the errors to log.txt.
}
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
  Writeln(f, DateTimeToStr(Now) + ': ' + s);
  Flush(f);
  Closefile(f);
end;

end.

