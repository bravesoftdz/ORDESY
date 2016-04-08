{
@Name: Unit "Options"
@creator: V.SEDLER aka scribe

Сохранение и загрузка настроек пограммы в текстовом виде (используется *.ini)
}
unit uOptions;

interface

uses
  Windows, Classes, SysUtils, IniFiles;

type
  TOption = record
    Section: string;
    Name: string;
    Value: string;
  end;

  TOptions = class
  private
    FOptions: array of TOption;
    FEmpty: boolean;
    FLastChange, FLastSave: TDateTime;
    function GetOptionsCount: integer;
    function GetSavedMark: boolean;
  public
    AppTitle: string;
    UserName: string;
    constructor Create;
    destructor Destroy; override;
    function SaveUserOptions(const aFileName: string = 'options.ini'): boolean;
    function LoadUserOptions(const aFileName: string = 'options.ini'): boolean;
    function GetOption(const aSection, aName: string): string;
    function SetOption(const aSection, aName, aValue: string): boolean;
    property IsEmpty: boolean read FEmpty;
    property Count: integer read GetOptionsCount;
    property Saved: boolean read GetSavedMark;
  end;

implementation



{ TOptions }

constructor TOptions.Create;
begin
  inherited Create;
  FEmpty:= true;
  SetLength(FOptions, 0);
end;

destructor TOptions.Destroy;
begin
  SetLength(FOptions, 0);
  inherited Destroy;
end;

function TOptions.GetOption(const aSection, aName: string): string;
var
  i: integer;
begin
  Result:= 'NULL';
  if FEmpty then
    raise Exception.Create('Options are empty, please load from file first!');
  for i := 0 to high(FOptions) do
  begin
    if (FOptions[i].Section = aSection) and (FOptions[i].Name = aName) then
    begin
      Result:= FOptions[i].Value;
      Exit;
    end;
  end;
  raise Exception.Create('No such value in [' + aSection + ']:[' + aName + ']');
end;

function TOptions.GetOptionsCount: integer;
var
  i: integer;
begin
  Result:= 0;
  if FEmpty then
    Exit;
  Result:= length(FOptions);
end;

function TOptions.GetSavedMark: boolean;
begin
  Result:= false;
  if FEmpty then
    Exit;
  if FLastChange <= FLastSave then
    Result:= true;
end;

function TOptions.LoadUserOptions(const aFileName: string = 'options.ini'): boolean;
var
  iniFile: TIniFile;
  i, n: integer;
  Sections, Section, Values: TStringList;
begin
  Result:= false;
  if not FileExists(ExtractFilePath(ParamStr(0)) + aFileName) then
    Exit;
    //raise Exception.Create('Options file "' + ExtractFilePath(ParamStr(0)) + aFileName + '" not exists!');
  try
    SetLength(FOptions, 0);
    iniFile:= TIniFile.Create(ExtractFilePath(ParamStr(0)) + aFileName);
    Sections:= TStringList.Create;
    Section:= TStringList.Create;
    Values:= TStringList.Create;
    iniFile.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do
    begin
      iniFile.ReadSection(Sections.Strings[i], Section);
      for n := 0 to Section.Count - 1 do
      begin
        SetLength(FOptions, length(FOptions) + 1);
        FOptions[high(FOptions)].Section:= Sections.Strings[i];
        FOptions[high(FOptions)].Name:= Section.Strings[n];
        FOptions[high(FOptions)].Value:= iniFile.ReadString(Sections.Strings[i], Section.Strings[n], 'NULL');
      end;
    end;
    if Length(FOptions) <> 0 then
      FEmpty:= false;
    FLastChange:= GetTime;
    FLastSave:= FLastChange;
    Result:= true;
  finally
    Sections.Free;
    Section.Free;
    Values.Free;
    iniFile.Free;
  end;
end;

function TOptions.SaveUserOptions(const aFileName: string = 'options.ini'): boolean;
var
  iniFile: TIniFile;
  i: integer;
begin
  Result:= false;
  if FEmpty then
    raise Exception.Create('No options added, nothing to save!');
  try
    iniFile:= TIniFile.Create(ExtractFilePath(ParamStr(0)) + aFileName);
    for i := 0 to high(FOptions) do
    begin
      iniFile.WriteString(FOptions[i].Section, FOptions[i].Name, FOptions[i].Value);
    end;
    FLastSave:= GetTime;
    Result:= true;
  finally
    iniFile.Free;
  end;
end;

function TOptions.SetOption(const aSection, aName, aValue: string): boolean;
var
  i: integer;
  Founded: boolean;
begin
  Result:= False;
  Founded:= false;
  if (aSection = '') or (aName = '') or (aValue = '') then
    raise Exception.Create('Some of option agrument is empty!');
  for i := 0 to high(FOptions) do
  begin
    if (FOptions[i].Section = aSection) and (FOptions[i].Name = aName) then
    begin
      FOptions[i].Value:= aValue;
      Founded:= true;
    end;
  end;
  if not Founded then
  begin
    SetLength(FOptions, length(FOptions) + 1);
    FOptions[high(FOptions)].Section:= aSection;
    FOptions[high(FOptions)].Name:= aName;
    FOptions[high(FOptions)].Value:= aValue;
  end;
  FLastChange:= GetTime;
  FEmpty:= false;
  Result:= true;
end;

end.
