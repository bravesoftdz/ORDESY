unit uORDESY;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uExplode, uConnection, uShellFuncs,
  Generics.Collections, SysUtils, Forms, Windows;

type
  TOraItemType = (OraProcedure, OraFunction, OraPackage);

  {TOrderType = record
    Scheme: string;
    Order: integer;
  end;}

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
    constructor Create(const aId, aSchemeId: integer; const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure; const aGroupId: integer = 0);
    class function GetItemSqlType(const aType: TOraItemType): string;
    {function Wrap(var aProject: TORDESYProject):boolean;
    function Deploy(var aProject: TORDESYProject): boolean;
    function SaveToProject(var aProject: TORDESYProject): boolean;}
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
    FGroupId: integer;
    FName: string;
  public
    constructor Create(const aId: integer; const aName: string);
    property Id: integer read FId;
    property Name: string read FName write FName;
    property GroupId: integer read FGroupId write FGroupId;
  end;

  TOraScheme = class
  private
    FId: integer;
    FGroupId: integer;         //Идентификатор списка (тут будет и название)
    FBaseId: integer;
    FModuleId: integer;
    FLogin: string;
    FPass: string;
    FConnection: TConnection;
    FConnected: boolean;
    FValid: boolean;
  public
    constructor Create(const aId: integer; const aLogin, aPass: string; const aBaseId, aModuleId: integer; const aGroupId: integer = 0);
    destructor Destroy; override;
    procedure Connect(var aProject: TORDESYProject);
    procedure Disconnect;
    property Id: integer read FId;
    property Login: string read FLogin write FLogin;
    property Pass: string read FPass write FPass;
    property GroupId: integer read FGroupId write FGroupId;
    property Connection: TConnection read FConnection write FConnection;
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
    FDescription: string;
    FCreator: string;
    FGroupId: integer;
    FDateCreate: TDateTime;
    FORDESYModules: array of TORDESYModule;
    FOraBases: array of TOraBase;
    FOraSchemes: array of TOraScheme;
    FOraItems: array of TOraItem;
  public
    constructor Create(const aId: integer; const aName: string = 'New Project'; const aDescription: string = 'About new project...'; const aCreator: string = 'nobody');
    destructor Destroy; override;
    function GetFreeModuleId: integer;
    function GetFreeBaseId: integer;
    function GetFreeSchemeId: integer;
    function GetFreeItemId: integer;
    // Item
    procedure AddOraItem(aItem: TOraItem);
    procedure GetOraItem(const aIndex: integer; var aItem: TOraItem);
    function GetOraItemName(const aIndex: integer): string;
    // Base
    procedure AddOraBase(aBase: TOraBase);
    procedure GetOraBase(const aIndex: integer; var aBase: TOraBase);
    function GetOraBaseName(const aIndex: integer): string;
    // Scheme
    procedure AddOraScheme(aScheme: TOraScheme);
    procedure GetOraScheme(const aIndex: integer; var aScheme: TOraScheme);
    function GetOraSchemeLogin(const aIndex: integer): string;
    // Module
    procedure AddModule(aModule: TORDESYModule);
    procedure GetModule(const aIndex: integer; var aModule: TORDESYModule);
    function GetModuleName(const aIndex: integer): string;
    // WRAP DEPLOY!
    procedure WrapItem(const aSchemeId: integer; const aName: string; const aType: TOraItemType; const aGroupId: integer);
    procedure DeployItem(const aItemId: integer);

    property Id: integer read FId;
    property Creator: string read FCreator write FCreator;
    property Name: string read FName write FName;
    property GroupId: integer read FGroupId write FGroupId;
  end;

  TORDESYProjectList = class
  private
    FProjects: array of TORDESYProject;
    FSaved: boolean;
    function GetProjectsCount: integer;
  public
    constructor Create;
    procedure AddProject(aProject: TORDESYProject);
    function GetFreeProjectId: integer;
    function LoadFromFile(const aFileName: string = 'ORDESY.data'): boolean;
    function SaveToFile(const aFileName: string = 'ORDESY.data'): boolean;
    property Count: integer read GetProjectsCount;
    property Saved: boolean read FSaved;
  end;

implementation

{ TDBItem }

constructor TOraItem.Create(const aId, aSchemeId: integer; const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure; const aGroupId: integer = 0);
begin
  inherited Create;
  FId:= aId;
  FType:= aType;
  FName:= aName;
  FBody:= aBody;
  FSchemeId:= aSchemeId;
  FGroupId:= aGroupId;
end;

{ TORDESYProject }

procedure TORDESYProject.AddModule(aModule: TORDESYModule);
var
  i: integer;
begin
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].Id = aModule.Id then
      Exit;
  end;
  SetLength(FORDESYModules, length(FOraBases) + 1);
  FORDESYModules[high(FORDESYModules)]:= aModule;
end;

procedure TORDESYProject.AddOraBase(aBase: TOraBase);
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

procedure TORDESYProject.AddOraItem(aItem: TOraItem);
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

procedure TORDESYProject.AddOraScheme(aScheme: TOraScheme);
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

constructor TORDESYProject.Create(const aId: integer; const aName: string; const aDescription: string; const aCreator: string);
begin
  inherited Create;
  FId:= aId;
  FName:= aName;
  FDescription:= aDescription;
  FCreator:= aCreator;
  FDateCreate:= Time;
end;

procedure TORDESYProject.DeployItem(const aItemId: integer);
begin

end;

destructor TORDESYProject.Destroy;
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
    FOraItems[i].Free;
  SetLength(FOraItems, 0);

  for i := 0 to high(FOraSchemes) do
    FOraSchemes[i].Free;
  SetLength(FOraSchemes, 0);

  for i := 0 to high(FOraBases) do
    FOraBases[i].Free;
  SetLength(FOraBases, 0);

  for i := 0 to high(FORDESYModules) do
    FORDESYModules[i].Free;
  SetLength(FORDESYModules, 0);

  inherited Destroy;
end;

function TORDESYProject.GetFreeBaseId: integer;
var
  i, NewId: integer;
label
  Restart;
begin
  NewId:= 0;
  Restart:
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result:= NewId;
end;

function TORDESYProject.GetFreeItemId: integer;
var
  i, NewId: integer;
label
  Restart;
begin
  NewId:= 0;
  Restart:
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result:= NewId;
end;

function TORDESYProject.GetFreeModuleId: integer;
var
  i, NewId: integer;
label
  Restart;
begin
  NewId:= 0;
  Restart:
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result:= NewId;
end;

function TORDESYProject.GetFreeSchemeId: integer;
var
  i, NewId: integer;
label
  Restart;
begin
  NewId:= 0;
  Restart:
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result:= NewId;
end;

procedure TORDESYProject.GetModule(const aIndex: integer;
  var aModule: TORDESYModule);
var
  i: integer;
begin
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].FId = aIndex then
    begin
      aModule:= FORDESYModules[i];
      Exit;
    end;
  end;
  aModule:= nil;
end;

function TORDESYProject.GetModuleName(const aIndex: integer): string;
var
  i: integer;
begin
  Result:= 'NULL';
  for i := 0 to high(FORDESYModules) do
    if FORDESYModules[i].FId = aIndex then
      Result:= FORDESYModules[i].Name;
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

procedure TORDESYProject.WrapItem(const aSchemeId: integer; const aName: string;
  const aType: TOraItemType; const aGroupId: integer);
var
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  firstItem: boolean;
begin
  try
    GetOraScheme(aSchemeId, iScheme);
    GetModule(iScheme.FModuleId, iModule);
    GetOraBase(iScheme.FBaseId, iBase);
    if (not Assigned(iScheme) or not Assigned(iModule) or not Assigned(iBase)) then
      raise Exception.Create('Some of objects not created!');
    if not iScheme.Connected then
      iScheme.Connect(Self);
    with iScheme.Connection do
    begin
      Query.Active:= false;
      Query.SQL.Text:= 'select text from sys.all_sources where ' +
        'owner = ''' + iScheme.Login + '''' +
        'name = ''' + Name + '''' +
        'type = ''' + TOraItem.GetItemSqlType(aType) + ''' ' +
        'order by line';
      Query.Active:= true;
      firstItem:= true;
      iItem:= TOraItem.Create(GetFreeItemId ,aSchemeId, aName, '', aType, aGroupId);
      while not Query.Eof do
      begin
        if firstItem then
          iItem.ItemBody:= iItem.ItemBody + 'CREATE OR REPLACE ' + Query.Fields[0].AsString + #13#10;
        iItem.ItemBody:= iItem.ItemBody + Query.Fields[0].AsString + #13#10;
        firstItem:= false;
      end;
      AddOraItem(iItem);
    end;
  except
    on E: Exception do
      begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | WrapItem | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | WrapItem | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
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

constructor TOraScheme.Create(const aId: integer; const aLogin, aPass: string; const aBaseId, aModuleId: integer; const aGroupId: integer = 0);
begin
  inherited Create;
  FId:= aId;
  FLogin:= aLogin;
  FPass:= aPass;
  FBaseId:= aBaseId;
  FModuleId:= aModuleId;
  FGroupId:= aGroupId;
end;

destructor TOraScheme.Destroy;
begin
  if Assigned(FConnection) then
  begin
    FConnection.Disconnect;
    FConnection.Free;
  end;
  inherited Destroy;
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

(*function TOraItem.Deploy(var aProject: TORDESYProject): boolean;
begin

end;*)

class function TOraItem.GetItemSqlType(const aType: TOraItemType): string;
begin
  case aType of
    OraProcedure: Result:= 'PROCEDURE';
    OraFunction: Result:= 'FUNCTION';
    OraPackage: Result:= 'PACKAGE';
  end;
end;

(*function TOraItem.SaveToProject(var aProject: TORDESYProject): boolean;
var
  iFileName: string;
  iFile: textfile;
  iScheme: TOraScheme;
  iModule: TORDESYModule;
  iBase: TOraBase;
  reply: word;
begin
  aProject.GetOraScheme(FSchemeId, iScheme);
  aProject.GetModule(iScheme.FModuleId, iModule);
  aProject.GetOraBase(iScheme.FBaseId, iBase);
  // Проверка на создание объектов
  //Assert(not Assigned(iScheme) or not Assigned(iModule) or not Assigned(iBase));
  if (not Assigned(iScheme) or not Assigned(iModule) or not Assigned(iBase)) then
    raise Exception.Create('TOraItem.SaveToProject|Some of objects not created!');
  // Сохранение
  iFileName:= ExtractFilePath(ParamStr(0)) + 'Projects\' + aProject.Name + '\' + iModule.Name + '\' + iScheme.Login + '\' + Name + '.sql';
  if FileExists(iFileName) then
  begin
    reply := MessageBox(Application.Handle, PChar('Заменить файл:' + #13#10 + iFileName + '?'), PChar('Файл уже существует.'), 36);
    if reply = IDNO then
      Exit;
  end;
  try
    AssignFile(iFile, iFileName);
    Rewrite(iFile);
    Write(iFile, FBody);
  finally
    CloseFile(iFile);
  end;
end;*)

(*function TOraItem.Wrap(var aProject: TORDESYProject): boolean;
var
  iScheme: TOraScheme;
  iModule: TORDESYModule;
  iBase: TOraBase;
  firstItem: boolean;
begin
  try
    aProject.GetOraScheme(FSchemeId, iScheme);
    aProject.GetModule(iScheme.FModuleId, iModule);
    aProject.GetOraBase(iScheme.FBaseId, iBase);
    if (not Assigned(iScheme) or not Assigned(iModule) or not Assigned(iBase)) then
      raise Exception.Create('TOraItem.SaveToProject|Some of objects not created!');
    if not iScheme.Connected then
      iScheme.Connect(aProject);
    with iScheme.FConnection do
    begin
      Query.Active:= false;
      Query.SQL.Text:= 'select text from sys.all_sources where ' +
        'owner = ''' + iScheme.Login + '''' +
        'name = ''' + Name + '''' +
        'type = ''' + GetItemSqlType(FType) + ''' ' +
        'order by line';
      Query.Active:= true;
      firstItem:= true;
      while not Query.Eof do
      begin
        if firstItem then
          FBody:= FBody + 'CREATE OR REPLACE ' + Query.Fields[0].AsString + #13#10;
        FBody:= FBody + Query.Fields[0].AsString + #13#10;
        firstItem:= false;
      end;
    end;
  except
    on E: Exception do
      begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | Wrap | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | Wrap | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;*)

{ TORDESYProjectList }

procedure TORDESYProjectList.AddProject(aProject: TORDESYProject);
var
  i: integer;
begin
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = aProject.Id then
      Exit;
  end;
  SetLength(FProjects, length(FProjects) + 1);
  FProjects[high(FProjects)]:= aProject;
end;

constructor TORDESYProjectList.Create;
begin
  inherited Create;
end;

function TORDESYProjectList.GetFreeProjectId: integer;
var
  i, NewId: integer;
label
  Restart;
begin
  NewId:= 0;
  Restart:
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result:= NewId;
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
  i, n: integer;
begin
  Result:= false;
  FSaved:= false;
  try
    try
      {iniFile:= TIniFile.Create(ExtractFilePath(ParamStr(0)) + aFileName);
      for i := 0 to high(FProjects) do
      begin
        iniFile.WriteString('Project', FProjects[i].Name, inttostr(FProjects[i].FId));
        // Bases
        for n := 0 to high(FProjects[i].FOraBases) do
        begin
          iniFile.WriteString(FProjects[i].Name + '_Base', FProjects[i].FOraBases[n].Name, inttostr(FProjects[i].FOraBases[n].Id));
        end;
        // Schemes
        for n := 0 to high(FProjects[i].FOraSchemes) do
        begin
          iniFile.WriteString(FProjects[i].Name + '_Scheme_' + FProjects[i].FOraSchemes[n].FLogin, inttostr(FProjects[i].FOraSchemes[n].Id), FProjects[i].FOraSchemes[n].FPass);
        end;
        // Modules
        for n := 0 to high(FProjects[i].FORDESYModules) do
        begin
          iniFile.WriteString(FProjects[i].Name + '_Module_' + FProjects[i].FORDESYModules[n].FName, inttostr(FProjects[i].FORDESYModules[n].Id), FProjects[i].FORDESYModules[n].FPass);
        end;
      end; }
      FSaved:= true;
    finally

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
