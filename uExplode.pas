unit uExplode;

interface

procedure Explode(var a: array of string; Border, S: string);

implementation

// Разбиение строки на массив строк
procedure Explode(var a: array of string; Border, S: string);
var
  S2: string;
  i: integer;
begin
  i := 0;
  S2 := S + Border;
  repeat
    a[i] := Copy(S2, 0, Pos(Border, S2) - 1);
    Delete(S2, 1, Length(a[i] + Border));
    Inc(i);
  until S2 = '';
end;

end.
