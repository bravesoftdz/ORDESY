{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

Headers for read/write base types of delphi by functions (FileRead|FileWrite)
}
unit uFileRWTypes;

interface

uses
  SysUtils, Windows;

// write
procedure FileWriteString(const aHandle: integer; const aString: string);
procedure FileWriteInteger(const aHandle: integer; const aInteger: integer);
procedure FileWriteDateTime(const aHandle: integer; const aDateTime: TDateTime);
procedure FileWriteBoolean(const aHandle: integer; const aBoolean: boolean);
// read
procedure FileReadString(const aHandle: integer; var aString: string);
procedure FileReadInteger(const aHandle: integer; var aInteger: integer);
procedure FileReadDateTime(const aHandle: integer; var aDateTime: TDateTime);
procedure FileReadBoolean(const aHandle: integer; var aBoolean: boolean);

implementation

procedure FileReadBoolean(const aHandle: integer;
  var aBoolean: boolean);
begin
  FileRead(aHandle, aBoolean, sizeof(aBoolean));
end;

procedure FileReadDateTime(const aHandle: integer;
  var aDateTime: TDateTime);
begin
  FileRead(aHandle, aDateTime, sizeof(aDateTime));
end;

procedure FileReadInteger(const aHandle: integer;
  var aInteger: integer);
begin
  FileRead(aHandle, aInteger, sizeof(aInteger));
end;

procedure FileReadString(const aHandle: integer; var aString: string);
var
  strSize: integer;
begin
  FileRead(aHandle, strSize, sizeof(strSize));
  SetLength(aString, strSize);
  FileRead(aHandle, aString[1], strSize * sizeof(char));
end;

procedure FileWriteBoolean(const aHandle: integer;
  const aBoolean: boolean);
begin
  FileWrite(aHandle, aBoolean, sizeof(aBoolean));
end;

procedure FileWriteDateTime(const aHandle: integer;
  const aDateTime: TDateTime);
begin
  FileWrite(aHandle, aDateTime, sizeof(aDateTime));
end;

procedure FileWriteInteger(const aHandle, aInteger: integer);
begin
  FileWrite(aHandle, aInteger, sizeof(aInteger));
end;

procedure FileWriteString(const aHandle: integer;
  const aString: string);
var
  strSize: integer;
begin
  strSize:= length(aString);
  FileWrite(aHandle, strSize, sizeof(strSize));
  FileWrite(aHandle, aString[1], strSize * sizeof(char));
end;

end.
