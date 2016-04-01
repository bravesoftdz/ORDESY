unit uShellFuncs;

interface

uses
  Windows, SysUtils, ShlObj;

function GetPathMyDocs: string;
function GetWindowsUser: string;

implementation

//Папка "Мои документы" для текущего пользователя
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
