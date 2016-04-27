unit uHash;

interface

uses
  SysUtils;

function GetSimpleHash(Str: PChar): Integer;

implementation

// http://www.scalabium.com/faq/dct0093.htm
function GetSimpleHash(Str: PChar): Integer;
var
  Off, Len, Skip, I: Integer;
begin
  Result := 0;
  Off := 1;
  Len := StrLen(Str);
  if Len < 16 then
    for I := (Len - 1) downto 0 do
    begin
      Result := (Result * 37) + Ord(Str[Off]);
      Inc(Off);
    end
  else
  begin
    { Only sample some characters }
    Skip := Len div 8;
    I := Len - 1;
    while I >= 0 do
    begin
      Result := (Result * 39) + Ord(Str[Off]);
      Dec(I, Skip);
      Inc(Off, Skip);
    end;
  end;
end;

end.
