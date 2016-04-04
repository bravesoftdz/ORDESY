unit uORDESY;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uExplode, uConnection, uShellFuncs,
  Generics.Collections, SysUtils, Forms, Windows, IniFiles;

type
  TOraItemType = (OraProcedure, OraFunction, OraPackage);

  TOrderType = record
    Scheme: string;
    Order: integer;
  end;

  { Forward declarations }

  TOraItem = class;
  TOraScheme = class;
  TOraBase = class;
  TORDESYModule = class;
  TORDESYProject = class;

  { TGroupItem

    Класс элемента группы }
  TGroupItem = class
  private
    FId: integer;        //Идентивикатор
    FName: string;       //Отображаемое имя в списке
    FDescription: string;
    FParentId: integer;  //Идентификатор родителя
    FExpanded: boolean;  //Признак развертнутости
  public
    constructor Create(const aName: string; const aId, aParentId: integer;
      aExpanded: boolean = true);
    destructor Destroy; override;                     //Обязательно перегрузить виртуальный метод
    property Id: integer read FId;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
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
    function AddGroup(const aName: string; const aParentId: integer = 0): integer;
    procedure DeleteGroup(const aId: integer);
    function GetGroupIndex(const aId: integer): integer;
    procedure SaveGroups(const aFileName: string = 'group_list.data'); //Сохранение списка
    procedure LoadGroups(const aFileName: string = 'group_list.data'); //Загрузка списка
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
    FName: string;
    FBody: WideString;
    FLastChange: TDatetime;
  public
    constructor Create(const aSchemeId: integer; const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure; const aGroupId: integer = 0);
    function Wrap(var aProject: TORDESYProject):boolean;
    function Deploy(var aProject: TORDESYProject): boolean;
    property Id: integer read FId;
    property Name: string read FName write FName;
    property ItemType: TOraItemType read FType write FType;
    property ItemBody: widestring read FBody write FBody;
    property SchemeId: integer read FSchemeId write FSchemeId;
    property GroupId: integer read FGroupId write FGroupId;
  end;

  TOraBase = class
  private
    FId: integer;
    FName: string;
  public
    constructor Create(const aId: integer; const aName: string);
    property Id: integer read FId;
    property Name: string read FName write FName;
  end;

  TOraScheme = class
  private
    FId: integer;
    FGroupId: integer;         //Идентификатор списка (тут будет и название)
    FBaseId: integer;
    FLogin: string;
    FPass: string;
    FConnection: TConnection;
    FConnected: boolean;
    FValid: boolean;
  public
    constructor Create(const aId: integer; const aLogin, aPass: string; const aBaseId: integer; const aGroupId: integer = 0);
    procedure Connect(var aProject: TORDESYProject);
    procedure Disconnect;
    property Id: integer read FId;
    property Login: string read FLogin write FLogin;
    property Pass: string read FPass write FPass;
    property GroupId: integer read FGroupId write FGroupId;
    property Connected: boolean read FConnected;
    property Valid: boolean read FValid;
  end;

  TORDESYModule = class
  private
    FId: integer;
    FName: string;
    FDescription: WideString;
    FGroupId: integer;
  public
    constructor Create(const aId: integer; const aName: string = 'New Module'; const aDescription: WideString = ''; const aGroupId: integer = 0);
    property Id: integer read FId;
    property Name: string read FName write FName;
    property Description: widestring read FDescription write FDescription;
    property GroupId: integer read FGroupId write FGroupId;
  end;

  TORDESYProject = class
  private
    FId: integer;
    FName: string;
    FGroupId: integer;
    FOraItems: array of TOraItem;
    FOraBases: array of TOraBase;
    FOraSchemes: array of TOraScheme;
    FORDESYModules: array of TORDESYModule;
  public
    constructor Create(const aName: string = 'New Project');

    procedure AddOraItem(var aItem: TOraItem);
    procedure GetOraItem(const aIndex: integer; var aItem: TOraItem);
    function GetOraItemName(const aIndex: integer): string;

    procedure AddOraBase(var aBase: TOraBase);
    procedure GetOraBase(const aIndex: integer; var aBase: TOraBase);
    function GetOraBaseName(const aIndex: integer): string;

    procedure AddOraScheme(var aScheme: TOraScheme);
    procedure GetOraScheme(const aIndex: integer; var aScheme: TOraScheme);
    function GetOraSchemeLogin(const aIndex: integer): string;

    property Id: integer read FId write FId;
    property Name: string read FName write FName;
    property GroupId: integer read FGroupId write FGroupId;
  end;

  TORDESYProjectList = class
  private
    FProjects: array of TORDESYProject;
    function GetProjectsCount: integer;
  public
    constructor Create;
    function LoadFromFile(const aFileName: string = 'ORDESY.data'): boolean;
    function SaveToFile(const aFileName: string = 'ORDESY.data'): boolean;
    property Count: integer read GetProjectsCount;
  end;

implementation

{ TDBItem }

constructor TOraItem.Create(const aSchemeId: integer; const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure; const aGroupId: integer = 0);
begin
  inherited Create;
  FType:= aType;
  FName:= aName;
  FBody:= aBody;
  FSchemeId:= aSchemeId;
  FGroupId:= aGroupId;
end;

{ TORDESYProject }

procedure TORDESYProject.AddOraBase(var aBase: TOraBase);
var
  i: integer;
begin
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].Id = aBase.Id then
      Exit;
  end;
  SetLength(FOraBases, length(FOraBases) + 1);
  FOraBases[high(FOraBases)]:= aBase;
end;

procedure TORDESYProject.AddOraItem(var aItem: TOraItem);
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].Id = aItem.Id then
      Exit;
  end;
  SetLength(FOraItems, length(FOraItems) + 1);
  FOraItems[high(FOraItems)]:= aItem;
end;

procedure TORDESYProject.AddOraScheme(var aScheme: TOraScheme);
var
  i: integer;
begin
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].Id = aScheme.Id then
      Exit;
  end;
  SetLength(FOraSchemes, length(FOraSchemes) + 1);
  FOraSchemes[high(FOraSchemes)]:= aScheme;
end;

constructor TORDESYProject.Create(const aName: string = 'New Project');
begin
  inherited Create;
  FName:= aName;
end;

procedure TORDESYProject.GetOraBase(const aIndex: integer; var aBase: TOraBase);
var
  i: integer;
begin
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].FId = aIndex then
    begin
      aBase:= FOraBases[i];
      Exit;
    end;
  end;
  aBase:= nil;
end;

function TORDESYProject.GetOraBaseName(const aIndex: integer): string;
var
  i: integer;
begin
  Result:= 'NULL';
  for i := 0 to high(FOraBases) do
    if FOraBases[i].FId = aIndex then
      Result:= FOraBases[i].Name;
end;

procedure TORDESYProject.GetOraItem(const aIndex: integer; var aItem: TOraItem);
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].FId = aIndex then
    begin
      aItem:= FOraItems[i];
      Exit;
    end;
  end;
  aItem:= nil;
end;

function TORDESYProject.GetOraItemName(const aIndex: integer): string;
var
  i: integer;
begin
  Result:= 'NULL';
  for i := 0 to high(FOraItems) do
    if FOraItems[i].FId = aIndex then
      Result:= FOraItems[i].Name;
end;

procedure TORDESYProject.GetOraScheme(const aIndex: integer;
  var aScheme: TOraScheme);
var
  i: integer;
begin
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].FId = aIndex then
    begin
      aScheme:= FOraSchemes[i];
      Exit;
    end;
  end;
  aScheme:= nil;
end;

function TORDESYProject.GetOraSchemeLogin(const aIndex: integer): string;
var
  i: integer;
begin
  Result:= 'NULL';
  for i := 0 to high(FOraSchemes) do
    if FOraSchemes[i].FId = aIndex then
      Result:= FOraSchemes[i].Login;
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
      {$IFDEF Debug}
      AddToLog(E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
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
      {$IFDEF Debug}
      AddToLog(E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
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
        {$IFDEF Debug}
        AddToLog(E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
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
        {$IFDEF Debug}
        AddToLog(E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
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
        {$IFDEF Debug}
        AddToLog(E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
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
        {$IFDEF Debug}
        AddToLog(E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      end;
    end;
  finally
    CloseFile(gFile);
  end;
end;

{ TOraScheme }

procedure TOraScheme.Connect(var aProject: TORDESYProject);
begin
  try
    if not FConnected then
    begin
      if not Assigned(FConnection) then
        FConnection:= TConnection.Create(aProject.GetOraBaseName(FBaseId), FLogin, FPass, connstrORA);
      FConnection.Connect;
      FConnected:= FConnection.Connected;
      FValid:= true;
    end;
  except
    on E: Exception do
      begin
        FValid:= false;
        FConnected:= false;
        {$IFDEF Debug}
        AddToLog(E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      end;
  end;
end;

constructor TOraScheme.Create(const aId: integer; const aLogin, aPass: string; const aBaseId: integer; const aGroupId: integer = 0);
begin
  inherited Create;
  FId:= aId;
  FLogin:= aLogin;
  FPass:= aPass;
  FBaseId:= aBaseId;
  FGroupId:= aGroupId;
end;

procedure TOraScheme.Disconnect;
begin
  if Assigned(FConnection) and (FConnected) then
    FConnection.Disconnect;
  FConnected:= FConnection.Connected;
end;

{ TOraBase }

constructor TOraBase.Create(const aId: integer; const aName: string);
begin
  inherited Create;
  FId:= aId;
  FName:= aName;
end;

function TOraItem.Deploy(var aProject: TORDESYProject): boolean;
begin

end;

function TOraItem.Wrap(var aProject: TORDESYProject): boolean;
begin

end;

{ TORDESYProjectList }

constructor TORDESYProjectList.Create;
begin

end;

function TORDESYProjectList.GetProjectsCount: integer;
begin
  Result:= Length(FProjects);
end;

function TORDESYProjectList.LoadFromFile(const aFileName: string): boolean;
begin
  Result:= false;
  try

  except
    on E: Exception do
      begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | LoadFromFile | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | LoadFromFile | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TORDESYProjectList.SaveToFile(const aFileName: string): boolean;
var
  iniFile: TIniFile;
  i, n: integer;
begin
  Result:= false;
  try
    try
      iniFile:= TIniFile.Create(ExtractFilePath(ParamStr(0)) + aFileName);
      for i := 0 to high(FProjects) do
      begin
        iniFile.WriteString('Project', FProjects[i].Name, inttostr(FProjects[i].FId));
        for n := 0 to high(FProjects[i].FOraBases) do
        begin
          iniFile.WriteString(FProjects[i].Name + '_Bases', FProjects[i].FOraBases[n].Name, inttostr(FProjects[i].FOraBases[n].Id));
        end;
      end;
    finally
      iniFile.Free;
    end;
  except
    on E: Exception do
      begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | SaveToFile | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | SaveToFile | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

{ TORDESYModule }

constructor TORDESYModule.Create(const aId: integer; const aName: string = 'New Module'; const aDescription: WideString = ''; const aGroupId: integer = 0);
begin
  inherited Create;
  FId:= aId;
  FName:= aName;
  FDescription:= aDescription;
  FGroupId:= aGroupId;
end;

end.
