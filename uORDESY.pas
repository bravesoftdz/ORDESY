//{$DEFINE ERROR_LOGONLY}
{$DEFINE ERROR_ALL}
unit uORDESY;

interface

uses
  uLog, uExplode, uConnection,
  Generics.Collections, SysUtils, Forms, Windows;

type
  TOraItemType = (OraProcedure, OraFunction, OraPackage);

  TOrderType = record
    Scheme: string;
    Order: integer;
  end;

  { TGroupItem

    Класс элемента группы }
  TGroupItem = class
  private
    FId: integer;        //Идентивикатор
    FName: string;       //Отображаемое имя в списке
    FParentId: integer;  //Идентификатор родителя
    FExpanded: boolean;  //Признак развертнутости
  public
    constructor Create(const aName: string; const aId, aParentId: integer;
      aExpanded: boolean = true);
    destructor Destroy; override;
    property Id: integer read FId;
    property Name: string read FName write FName;
    property ParentId: integer read FParentId write FParentId;
    property Expanded: boolean read FExpanded write FExpanded;
  end;

  { TGroupList

    Класс объекта списка групп }
  TGroupList = class(TObjectList<TGroupItem>)
  private
    FAutoSave: boolean;                                //Признак автосохранения
    FFileName: string;                                 //Имя файла со структурой
    FLoaded: boolean;
    function GetUnusedgId: integer;
    function GroupExists(const aId: integer): boolean;
    function HasChild(const aId: integer): boolean;
    function GetMaxGroupId: integer;
  public
    constructor Create(const aFileName: string = '');
    destructor Destroy; override;
    procedure Add(aItem: TGroupItem);
    procedure Delete(const Value: integer);
    function AddGroup(const aName: string; const aParentId: integer = 0)
      : integer;
    function GetGroupIndex(const aId: integer): integer;
    procedure SaveGroups(const aFileName: string = 'group_list.data');
    procedure LoadGroups(const aFileName: string = 'group_list.data');
    procedure DeleteGroup(const aId: integer);
    property AutoSave: boolean read FAutoSave write FAutoSave;
    property FileName: string read FFileName write FFileName;
    property Loaded: boolean read FLoaded;
    property MaxGroupId: integer read GetMaxGroupId;
  end;

  TOraItem = class
  private
    FId : integer;
    FGroupId: integer;
    FSchemeId: integer;
    FType: TOraItemType;
    FBody: WideString;
  public
    constructor Create(const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure; const aSchemeId: integer = 0);
    property Id: integer read FId write FId;
    property ItemType: TOraItemType read FType write FType;
    property ItemBody: widestring read FBody write FBody;
    property Scheme: integer read FSchemeId write FSchemeId;
  end;

  TOraScheme = class
  private
    FId: integer;
    FGroupId: integer;         //Идентификатор списка (тут будет и название)
    FLogin: string;
    FBase: string;
    FConnection: TConnection;
  public
    //constructor Create(const aLogin, aPass: string);
  end;

  TORDESYModule = class
  private
    FId: integer;
    FGroupId: integer;
  end;

  TORDESYProject = class
  private
    FSchemesOrder: array of TOrderType;
    FItems: array of TOraItem;
  public
    constructor Create(const aName: string);
    procedure AddItem(aItem: TOraItem);
  end;

implementation

{ TDBItem }

constructor TOraItem.Create(const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure; const aSchemeId: integer = 0);
begin
  inherited Create;
  FType:= aType;
  FBody:= aBody;
  FSchemeId:= aSchemeId;
end;

{ TORDESYProject }

procedure TORDESYProject.AddItem(aItem: TOraItem);
begin

end;

constructor TORDESYProject.Create(const aName: string);
begin
  inherited Create;
end;

{ TGroupItem }

constructor TGroupItem.Create(const aName: string; const aId,
  aParentId: integer; aExpanded: boolean);
begin
  inherited Create;
  FId := aId;
  FName := aName;
  FParentId := aParentId;
  FExpanded := aExpanded;
end;

destructor TGroupItem.Destroy;
begin
  inherited Destroy;
end;

{ TGroupList }

function TGroupList.AddGroup(const aName: string;
  const aParentId: integer): integer;
var
  gFilteredName: string;
  gUnusedId: integer;
begin
  Result := 0;
  try
    gFilteredName := aName;
    gFilteredName := StringReplace(gFilteredName, chr(1), '',
      [rfReplaceAll, rfIgnoreCase]);
    gFilteredName := StringReplace(gFilteredName, chr(2), '',
      [rfReplaceAll, rfIgnoreCase]);
    gUnusedId := GetUnusedgId;
    Self.Add(TGroupItem.Create(gFilteredName, gUnusedId, aParentId));
    if FAutoSave then
      SaveGroups;
    Result := gUnusedId;
  except
    on E: Exception do
    begin
      {$IFDEF ERROR_LOGONLY}
        AddToLog(E.Message);
      {$ELSE}
        {$IFDEF ERROR_ALL}
          AddToLog(E.Message);
          MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      {$ENDIF}
    end;
  end;
end;

constructor TGroupList.Create(const aFileName: string);
begin
  inherited Create;
  FFileName := aFileName;
  FLoaded := false;
end;

procedure TGroupList.Add(aItem: TGroupItem);
begin
  inherited Add(aItem);
  if Count > 0 then
    FLoaded := true
  else
    FLoaded := false;
  if AutoSave then
    SaveGroups;
end;

procedure TGroupList.Delete(const Value: integer);
begin
  inherited Delete(Value);
  if Count > 0 then
    FLoaded := true
  else
    FLoaded := false;
  if AutoSave then
    SaveGroups;
end;

procedure TGroupList.DeleteGroup(const aId: integer);
var
  i: integer;
begin
  try
    i := 0;
    if not GroupExists(aId) then
      Exit;
    repeat
      if Items[i].ParentId = aId then
      begin
        DeleteGroup(Items[i].Id);
        i := -1;
      end
      else if Items[i].Id = aId then
      begin
        Delete(i);
        i := -1;
      end;
      Inc(i);
    until i > Count - 1;
  except
    on E: Exception do
    begin
      {$IFDEF ERROR_LOGONLY}
        AddToLog(E.Message);
      {$ELSE}
        {$IFDEF ERROR_ALL}
          AddToLog(E.Message);
          MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      {$ENDIF}
    end;
  end;
end;

destructor TGroupList.Destroy;
begin
  inherited Destroy;
end;

function TGroupList.GetGroupIndex(const aId: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if Items[i].FId = aId then
      Result := i;
end;

function TGroupList.GetMaxGroupId: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    if Result < Items[i].FId then
      Result := Items[i].FId;
end;

function TGroupList.GetUnusedgId: integer;
var
  i: integer;
label restart;
begin
  Result := 1;
restart:
  for i := 0 to Count - 1 do
  begin
    if Result = Items[i].FId then
    begin
      Inc(Result);
      goto restart;
    end;
  end;
end;

function TGroupList.GroupExists(const aId: integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Count - 1 do
    if Items[i].FId = aId then
      Result := true;
end;

function TGroupList.HasChild(const aId: integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Count - 1 do
  begin
    if Items[i].FParentId = aId then
      Result := true;
  end;
end;

procedure TGroupList.LoadGroups(const aFileName: string);
var
  gFile: TextFile;
  gLine: string;
  gSep: char;
  gArrLine: array of string;
  numLine: integer;
begin
  if FFileName = '' then
    FFileName := ExtractFilePath(ParamStr(0)) + aFileName;
  if not FileExists(FFileName) then
    Exit;
  gSep := chr(1);
  SetLength(gArrLine, 5);
  numLine := 0;
  try
    try
      AssignFile(gFile, FFileName);
      Reset(gFile);
    except
      on E: Exception do
      begin
        Clear;
        FLoaded := false;
        {$IFDEF ERROR_LOGONLY}
          AddToLog(E.Message);
        {$ELSE}
          {$IFDEF ERROR_ALL}
            AddToLog(E.Message);
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
          {$ENDIF}
        {$ENDIF}
      end;
    end;
    try
      while not Eof(gFile) do
      begin
        Readln(gFile, gLine);
        if Trim(gLine) = '' then
          Exit;
        Explode(gArrLine, gSep, gLine);
        Add(TGroupItem.Create(gArrLine[1], StrToInt(gArrLine[0]), StrToInt
              (gArrLine[2]), strtobool(gArrLine[3])));
        Inc(numLine);
      end;
    except
      on E: Exception do
      begin
        Self.Clear;
        FLoaded := false;
        {$IFDEF ERROR_LOGONLY}
          AddToLog(E.Message);
        {$ELSE}
          {$IFDEF ERROR_ALL}
            AddToLog(E.Message);
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
          {$ENDIF}
        {$ENDIF}
      end;
    end;
  finally
    SetLength(gArrLine, 0);
    if Count <> 0 then
      FLoaded := true;
    CloseFile(gFile);
  end;
end;

procedure TGroupList.SaveGroups(const aFileName: string);
var
  gFile: TextFile;
  i: integer;
  gLine: string;
  gSep: char;
  numLine: integer;
begin
  if FFileName = '' then
    FFileName := ExtractFilePath(ParamStr(0)) + aFileName;
  gSep := chr(1);
  numLine := 0;
  try
    try
      AssignFile(gFile, FFileName);
      Rewrite(gFile);
    except
      on E: Exception do
      begin
        {$IFDEF ERROR_LOGONLY}
          AddToLog(E.Message);
        {$ELSE}
          {$IFDEF ERROR_ALL}
            AddToLog(E.Message);
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
          {$ENDIF}
        {$ENDIF}
      end;
    end;
    try
      for i := 0 to Count - 1 do
      begin
        gLine := inttostr(Items[i].FId) + gSep + Items[i].FName + gSep +
          inttostr(Items[i].FParentId) + gSep + booltostr (Items[i].FExpanded);
        Writeln(gFile, gLine);
        Inc(numLine);
      end;
    except
      on E: Exception do
      begin
        {$IFDEF ERROR_LOGONLY}
          AddToLog(E.Message);
        {$ELSE}
          {$IFDEF ERROR_ALL}
            AddToLog(E.Message);
            MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
          {$ENDIF}
        {$ENDIF}
      end;
    end;
  finally
    CloseFile(gFile);
  end;
end;

end.
