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
}
unit uShellFuncs;

interface

uses
  Windows, SysUtils, ShlObj;

function GetPathMyDocs: string;
function GetWindowsUser: string;

implementation

// Retrieveing MyDocuments folder
function GetPathMyDocs: string;
var
  bResult: boolean;
  path: array [0..MAX_PATH] of Char;
begin
  bResult:= SHGetSpecialFolderPath(0, path, CSIDL_PERSONAL, false);
  if not bResult then
    raise Exception.Create('Personal folder not found!');
  Result:= path;
end;

// Current username
function GetWindowsUser: string;
var
  UserName : string;
  UserNameLen : Dword;
begin
  UserNameLen := 255;
  SetLength(userName, UserNameLen);
  try
    if GetUserName(PChar(UserName), UserNameLen) then
      Result := Copy(UserName,1,UserNameLen - 1)
    else
      Result := 'Unknown';
  except
    Result := 'Unknown';
  end;
end;

end.
