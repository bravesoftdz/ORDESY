unit uOptions;

interface

uses
  Windows, SysUtils;

type
  TOption = record
    Section: string;
    Name: string;
    Value: string;
  end;

  TOptions = class
    AppTitle: string;
    UserName: string;
  private
    FOptions: array of TOption;
    FEmpty: boolean;
  public
    constructor Create;
    function SaveUserOptions(const aFileName: string = 'options.ini'): boolean;
    function LoadUserOptions(const aFileName: string = 'options.ini'): boolean;
    property IsEmpty: boolean read FEmpty;
  end;

implementation



{ TOptions }

constructor TOptions.Create;
begin
  inherited Create;
  FEmpty:= true;
end;

function TOptions.LoadUserOptions(const aFileName: string = 'options.ini'): boolean;
begin
  Result:= false;
  if not FileExists(ParamStr(0) + aFileName) then
    raise Exception.Create('Options file "' + ParamStr(0) + aFileName + '" not exists!');
end;

function TOptions.SaveUserOptions(const aFileName: string = 'options.ini'): boolean;
begin
  Result:= false;
end;

end.
