unit uHash;

interface

uses
  SysUtils;

function GetSimpleHash(Str: PChar): Integer;
function MurmurHash2(const S: AnsiString; const Seed: LongWord=$9747b28c): LongWord;

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

// http://stackoverflow.com/questions/3690608/simple-string-hashing-function
function MurmurHash2(const S: AnsiString; const Seed: LongWord=$9747b28c): LongWord;
var
    h: LongWord;
    len: LongWord;
    k: LongWord;
    data: Integer;
const
    // 'm' and 'r' are mixing constants generated offline.
    // They're not really 'magic', they just happen to work well.
    m = $5bd1e995;
    r = 24;
begin
    len := Length(S);

    //The default seed, $9747b28c, is from the original C library

    // Initialize the hash to a 'random' value
    h := seed xor len;

    // Mix 4 bytes at a time into the hash
    data := 1;

    while(len >= 4) do
    begin
        k := PLongWord(@S[data])^;

        k := k*m;
        k := k xor (k shr r);
        k := k* m;

        h := h*m;
        h := h xor k;

        data := data+4;
        len := len-4;
    end;

    {   Handle the last few bytes of the input array
            S: ... $69 $18 $2f
    }
    Assert(len <= 3);
    if len = 3 then
        h := h xor (LongWord(s[data+2]) shl 16);
    if len >= 2 then
        h := h xor (LongWord(s[data+1]) shl 8);
    if len >= 1 then
    begin
        h := h xor (LongWord(s[data]));
        h := h * m;
    end;

    // Do a few final mixes of the hash to ensure the last few
    // bytes are well-incorporated.
    h := h xor (h shr 13);
    h := h * m;
    h := h xor (h shr 15);

    Result := h;
end;

end.
