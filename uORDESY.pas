unit uORDESY;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uExplode, uConnection, uShellFuncs,
  Generics.Collections, SysUtils, Forms, Windows, Classes;

const
  ORDESYNAME = 'ORDESY PROJECT';
  ORDESYVERSION = '1.0';

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
    //FGroupId: integer;
    FSchemeId: integer;
    FType: TOraItemType;
    FName: string;
    FBody: WideString;
    //FLastChange: TDatetime;
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
    //property GroupId: integer read FGroupId write FGroupId;
  end;

  TOraBase = class
  private
    FId: integer;
    //FGroupId: integer;
    FName: string;
  public
    constructor Create(const aId: integer; const aName: string);
    property Id: integer read FId;
    property Name: string read FName write FName;
    //property GroupId: integer read FGroupId write FGroupId;
  end;

  TOraScheme = class
  private
    FId: integer;
    //FGroupId: integer;         //Идентификатор списка (тут будет и название)
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
    property ModuleId: integer read FModuleId write FModuleId;
    property BaseId: integer read FBaseId write FBaseId;
    property Login: string read FLogin write FLogin;
    property Pass: string read FPass write FPass;
    //property GroupId: integer read FGroupId write FGroupId;
    property Connection: TConnection read FConnection write FConnection;
    property Connected: boolean read FConnected;
    property Valid: boolean read FValid;
  end;

  TORDESYModule = class
  private
    FId: integer;
    FName: string;
    FDescription: WideString;
    //FGroupId: integer;
  public
    constructor Create(const aId: integer; const aName: string = 'New Module'; const aDescription: WideString = '');
    property Id: integer read FId;
    property Name: string read FName write FName;
    property Description: widestring read FDescription write FDescription;
    //property GroupId: integer read FGroupId write FGroupId;
  end;

  TORDESYProject = class
  private
    FId: integer;
    FName: string;
    FDescription: string;
    FCreator: string;
    //FGroupId: integer;
    FDateCreate: TDateTime;
    FORDESYModules: array of TORDESYModule;
    FOraBases: array of TOraBase;
    FOraSchemes: array of TOraScheme;
    FOraItems: array of TOraItem;
    function GetOraItemCount: integer;
    function GetModuleCount: integer;
    function GetOraBaseCount: integer;
    function GetOraSchemeCount: integer;
  public
    constructor Create(const aId: integer; const aName: string = 'New Project'; const aDescription: string = 'About new project...'; const aCreator: string = 'nobody'; const aDateCreate: TDateTime = 0);
    destructor Destroy; override;
    function GetFreeModuleId: integer;
    function GetFreeBaseId: integer;
    function GetFreeSchemeId: integer;
    function GetFreeItemId: integer;
    // Item
    procedure AddOraItem(aItem: TOraItem);
    function GetOraItem(const aIndex: integer): TOraItem;
    function GetOraItemName(const aIndex: integer): string;
    // Base
    procedure AddOraBase(aBase: TOraBase);
    function GetOraBase(const aIndex: integer): TOraBase;
    function GetOraBaseName(const aIndex: integer): string;
    // Scheme
    procedure AddOraScheme(aScheme: TOraScheme);
    function GetOraScheme(const aIndex: integer): TOraScheme;
    function GetOraSchemeLogin(const aIndex: integer): string;
    // Module
    procedure AddModule(aModule: TORDESYModule);
    function GetModule(const aIndex: integer): TORDESYModule;
    function GetModuleName(const aIndex: integer): string;
    // WRAP DEPLOY!
    procedure WrapItem(const aSchemeId: integer; const aName: string; const aType: TOraItemType; const aGroupId: integer);
    procedure DeployItem(const aItemId: integer);

    property Id: integer read FId;
    property Creator: string read FCreator write FCreator;
    property Name: string read FName write FName;
    //property GroupId: integer read FGroupId write FGroupId;
    //
    property ModuleCount: integer read GetModuleCount;
    property OraBaseCount: integer read GetOraBaseCount;
    property OraSchemeCount: integer read GetOraSchemeCount;
    property OraItemCount: integer read GetOraItemCount;
  end;

  TORDESYProjectList = class
  private
    FProjects: array of TORDESYProject;
    FSaved: boolean;
    FOnProjectAdd: TNotifyEvent;
    FOnProjectRemove: TNotifyEvent;
    procedure Clear;
    function GetProjectsCount: integer;
  public
    constructor Create;
    procedure AddProject(aProject: TORDESYProject);
    procedure RemoveProject(const aIndex: integer);
    function GetFreeProjectId: integer;
    function GetProjectByIndex(const aIndex: integer): TORDESYProject;
    function GetProjectById(const aId: integer): TORDESYProject;
    function LoadFromFile(const aFileName: string = 'ORDESY.data'): boolean;
    function SaveToFile(const aFileName: string = 'ORDESY.data'): boolean;
    property Count: integer read GetProjectsCount;
    property Saved: boolean read FSaved;
  published
    property OnProjectAdd: TNotifyEvent read FOnProjectAdd write FOnProjectAdd;
    property OnProjectRemove: TNotifyEvent read FOnProjectRemove write FOnProjectRemove;
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
  //FGroupId:= aGroupId;
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
  SetLength(FORDESYModules, length(FORDESYModules) + 1);
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

constructor TORDESYProject.Create(const aId: integer; const aName: string; const aDescription: string; const aCreator: string; const aDateCreate: TDateTime);
begin
  inherited Create;
  FId:= aId;
  FName:= aName;
  FDescription:= aDescription;
  FCreator:= aCreator;
  if aDateCreate = 0 then
    FDateCreate:= Time
  else
    FDateCreate:= aDateCreate;
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

function TORDESYProject.GetModule(const aIndex: integer): TORDESYModule;
var
  i: integer;
begin
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].FId = aIndex then
    begin
      Result:= FORDESYModules[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetModuleCount: integer;
begin
  Result:= length(FORDESYModules);
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

function TORDESYProject.GetOraBase(const aIndex: integer): TOraBase;
var
  i: integer;
begin
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].FId = aIndex then
    begin
      Result:= FOraBases[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetOraBaseCount: integer;
begin
  Result:= Length(FOraBases);
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

function TORDESYProject.GetOraItem(const aIndex: integer): TOraItem;
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].FId = aIndex then
    begin
      Result:= FOraItems[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetOraItemCount: integer;
begin
  Result:= length(FOraItems);
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

function TORDESYProject.GetOraScheme(const aIndex: integer): TOraScheme;
var
  i: integer;
begin
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].FId = aIndex then
    begin
      Result:= FOraSchemes[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetOraSchemeCount: integer;
begin
  Result:= Length(FOraSchemes);
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
    iScheme:= GetOraScheme(aSchemeId);
    iModule:= GetModule(iScheme.FModuleId);
    iBase:= GetOraBase(iScheme.FBaseId);
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
  //FGroupId:= aGroupId;
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
    OraPackage: Result:= 'PACKAGE'
  else Result:= 'PROCEDURE';
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
  if Assigned(FOnProjectAdd) then
    FOnProjectAdd(Self);
end;

procedure TORDESYProjectList.Clear;
var
  i: integer;
begin
  for i := 0 to high(FProjects) do
    FProjects[i].Free;
  SetLength(FProjects, 0);
  FSaved:= false;
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

function TORDESYProjectList.GetProjectById(const aId: integer): TORDESYProject;
var
  i: integer;
begin
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = aId then
      Result:= FProjects[i];
  end;
end;

function TORDESYProjectList.GetProjectByIndex(
  const aIndex: integer): TORDESYProject;
begin
  if (aIndex >= 0) and (aIndex <= high(FProjects)) then
    Result:= FProjects[aIndex];
end;

function TORDESYProjectList.GetProjectsCount: integer;
begin
  Result:= Length(FProjects);
end;

function TORDESYProjectList.LoadFromFile(const aFileName: string): boolean;
var
  iHandle: integer;
  iP, iM, iB, iSc, Ii, charSize, strSize, NameSize, DescSize, CreatorSize: integer;
  iFileHeader, iFileVersion, iName, iDescription, iCreator: PChar;
  iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;
  iId: integer;
  iDateCreate: TDateTime;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
begin
  Result:= false;
  try
    if not FileExists(aFileName) then
    begin
      Result:= true;
      Exit;
    end;
    Clear;
    try
      iHandle:= FileOpen(aFileName, fmOpenRead);
      if iHandle = -1 then
        raise Exception.Create(SysErrorMessage(GetLastError));
      charSize:= SizeOf(Char);
      iFileHeader:= PChar(AllocMem(length(ORDESYNAME) * charSize + 1));       // Allocating
      iFileVersion:= PChar(AllocMem(length(ORDESYVERSION) * charSize + 1));   // Allocating
      FileRead(iHandle, iFileHeader^, length(ORDESYNAME) * charSize);     // Reading header
      FileRead(iHandle, iFileVersion^, length(ORDESYVERSION) * charSize); // Reading version
      //MessageBox(Application.Handle, iFileHeader, 'warning', 0);
      if (iFileHeader <> ORDESYNAME) or (iFileVersion <> ORDESYVERSION) then
        raise Exception.Create('Incorrect project version! Need: ' + ORDESYNAME + ':' + ORDESYVERSION);
      FreeMem(iFileHeader, length(ORDESYNAME) * charSize + 1);  //
      FreeMem(iFileVersion, length(ORDESYVERSION) * charSize + 1);
      FileRead(iHandle, iProjectCount, sizeof(iProjectCount)); // PROJECT COUNT
      //MessageBox(Application.Handle, PChar(inttostr(iProjectCount)), 'warning', 0);
      for iP:= 0 to iProjectCount - 1 do
      begin
        // Id
        FileRead(iHandle, iId, sizeof(iId));
        // Name
        FileRead(iHandle, strSize, sizeof(strSize));   // Name length
        NameSize:= strSize;                            // Saving length to free memory
        iName:= PChar(AllocMem(strSize * charSize + 1));   // Allocating memory
        FileRead(iHandle, iName^, strSize * charSize); // Getting Name
        //MessageBox(Application.Handle, iName, 'warning', 0);
        // Desc
        FileRead(iHandle, strSize, sizeof(strSize));          // Desc length
        DescSize:= strSize;                                   // Saving length to free memory
        iDescription:= PChar(AllocMem(strSize * charSize + 1));   // Allocating memory
        FileRead(iHandle, iDescription^, strSize * charSize); // Getting Desc
        //MessageBox(Application.Handle, iDescription, 'warning', 0);
        // Creator
        FileRead(iHandle, strSize, sizeof(strSize));      // Creator length
        CreatorSize:= strSize;                            // Saving length to free memory
        iCreator:= PChar(AllocMem(strSize * charSize + 1));   // Allocating memory
        FileRead(iHandle, iCreator^, strSize * charSize); // Getting creator
        // Datecreate
        FileRead(iHandle, iDateCreate, SizeOf(iDateCreate));
        // Creating project
        iProject:= TORDESYProject.Create(iId, iName, iDescription, iCreator, iDateCreate);
        // Free
        FreeMem(iName, NameSize * charSize + 1);
        FreeMem(iDescription, DescSize * charSize + 1);
        FreeMem(iCreator, CreatorSize * charSize + 1);
        //--- MODULES
        FileRead(iHandle, iModuleCount, sizeof(iModuleCount)); // MODULE COUNT
        for iM := 0 to iModuleCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
          // Name
          FileRead(iHandle, strSize, sizeof(strSize)); // Name length
          NameSize:= strSize;                          // Saving length to free memory
          iName:= PChar(AllocMem(strSize * charSize + 1)); // Allocating memory
          FileRead(iHandle, iName^, sizeof(iName));    // Getting Name
          // Desc
          FileRead(iHandle, strSize, sizeof(strSize));            // Desc length
          DescSize:= strSize;                                     // Saving length to free memory
          iDescription:= PChar(AllocMem(strSize * charSize + 1));     // Allocating memory
          FileRead(iHandle, iDescription^, SizeOf(iDescription)); // Getting Desc
          // Adding
          iProject.AddModule(TORDESYModule.Create(iId, iName, iDescription));
          // Free
          FreeMem(iName, NameSize * charSize + 1);
          FreeMem(iDescription, DescSize * charSize + 1);
        end;
        //--- BASES
        FileRead(iHandle, iBaseCount, sizeof(iBaseCount)); // BASE COUNT
        for iB := 0 to iBaseCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
          // Name
          FileRead(iHandle, strSize, sizeof(strSize)); // Name length
          NameSize:= strSize;                          // Saving length to free memory
          iName:= PChar(AllocMem(strSize * charSize + 1)); // Allocating memory
          FileRead(iHandle, iName^, sizeof(iName));    // Getting Name
          // Adding
          iProject.AddOraBase(TOraBase.Create(iId, iName));
          // Free
          FreeMem(iName, NameSize * charSize);
        end;
        //--- SCHEMES
        {FileRead(iHandle, iSchemeCount, sizeof(iSchemeCount)); // SCHEME COUNT
        for iSc := 0 to iSchemeCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
        end;}
        // ADD PROJECT
        AddProject(iProject);
      end;
      Result:= true;
    finally
      FileClose(iHandle);
    end;
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

procedure TORDESYProjectList.RemoveProject(const aIndex: integer);
var
  i: integer;
  LastItem: TORDESYProject;
begin
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = aIndex then
    begin
      LastItem:= FProjects[high(FProjects)];
      FProjects[i]:= LastItem;
      SetLength(FProjects, length(FProjects) - 1);
      if Assigned(FOnProjectRemove) then
        FOnProjectRemove(Self);
    end;
  end;
end;

function TORDESYProjectList.SaveToFile(const aFileName: string): boolean;
var
  iP, iM, iB, iSc, iI, charSize, strSize: integer;
  iHandle: integer;
  iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
begin
  Result:= false;
  FSaved:= false;
  try
    try
      iProjectCount:= Count;
      charSize:= sizeof(Char);
      iHandle:= FileCreate(aFileName);
      //
      FileWrite(iHandle, ORDESYNAME, length(ORDESYNAME) * charSize);
      FileWrite(iHandle, ORDESYVERSION, Length(ORDESYVERSION) * charSize);
      //--- PROJECTS
      FileWrite(iHandle, iProjectCount, sizeof(iProjectCount));
      for iP := 0 to iProjectCount - 1 do
      begin
        iProject:= FProjects[iP];
        FileWrite(iHandle, iProject.FId, sizeof(iProject.FId));
        // Name
        strSize:= Length(iProject.FName);
        FileWrite(iHandle, strSize, sizeof(strSize)); // Name length
        FileWrite(iHandle, iProject.FName[1], strSize * charSize); // Name
        // Desc
        strSize:= Length(iProject.FDescription);
        FileWrite(iHandle, strSize, sizeof(strSize)); // Desc length
        FileWrite(iHandle, iProject.FDescription[1], strSize * charSize); // Desc
        // Creator
        strSize:= Length(iProject.FCreator);
        FileWrite(iHandle, strSize, sizeof(strSize)); // Creator length
        FileWrite(iHandle, iProject.FCreator[1], strSize * charSize); // Creator
        // Datecreate
        FileWrite(iHandle, iProject.FDateCreate, sizeof(iProject.FDateCreate));
        //--- MODULES
        iModuleCount:= iProject.ModuleCount;
        FileWrite(iHandle, iModuleCount, sizeof(iModuleCount));
        for iM := 0 to iModuleCount - 1 do
        begin
          iModule:= iProject.GetModule(iM);
          // Id
          FileWrite(iHandle, iModule.Id, sizeof(iModule.Id));
          // Name
          strSize:= Length(iModule.Name);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Name length
          FileWrite(iHandle, iModule.Name[1], strSize * charSize); // Name
          // Desc
          strSize:= Length(iModule.Description);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Desc length
          FileWrite(iHandle, iModule.Description[1], strSize * charSize); // Desc
        end;
        //--- BASES
        iBaseCount:= iProject.OraBaseCount;
        FileWrite(iHandle, iBaseCount, sizeof(iBaseCount));
        for iB := 0 to iBaseCount - 1 do
        begin
          iBase:= iProject.GetOraBase(iB);
          // Id
          FileWrite(iHandle, iBase.Id, sizeof(iBase.Id));
          // Name
          strSize:= Length(iBase.Name);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Name length
          FileWrite(iHandle, iBase.Name[1], strSize * charSize); // Name
        end;
        //--- SCHEMES
        iSchemeCount:= iProject.OraBaseCount;
        FileWrite(iHandle, iSchemeCount, sizeof(iSchemeCount));
        for iSc := 0 to iBaseCount - 1 do
        begin
          iScheme:= iProject.GetOraScheme(iSc);
          // Id
          FileWrite(iHandle, iScheme.Id, sizeof(iScheme.Id));
          // Login
          strSize:= Length(iScheme.Login);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Login length
          FileWrite(iHandle, iScheme.Login[1], strSize * charSize); // Login
          // Pass
          strSize:= Length(iScheme.Pass);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Pass length
          FileWrite(iHandle, iScheme.Pass[1], strSize * charSize); // Pass
          // ModuleId
          FileWrite(iHandle, iScheme.ModuleId, sizeof(iScheme.ModuleId));
          // ModuleId
          FileWrite(iHandle, iScheme.BaseId, sizeof(iScheme.BaseId));
        end;
        //--- ITEMS
        iItemCount:= iProject.OraItemCount;
        FileWrite(iHandle, iItem, sizeof(iItemCount));
        for iI := 0 to iItemCount - 1 do
        begin
          iItem:= iProject.GetOraItem(iI);
          // Id
          FileWrite(iHandle, iItem.Id, sizeof(iItem.Id));
          // Name
          strSize:= Length(iItem.Name);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Name length
          FileWrite(iHandle, iItem.Name[1], strSize * charSize); // Name
          // Type
          FileWrite(iHandle, iItem.ItemType, sizeof(iItem.ItemType));
          // Body
          strSize:= Length(iItem.ItemBody);
          FileWrite(iHandle, strSize, sizeof(strSize)); // Body length
          FileWrite(iHandle, iItem.ItemBody[1], strSize * charSize); // Body
        end;
      end;
      FSaved:= true;
    finally
      FileClose(iHandle);
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

constructor TORDESYModule.Create(const aId: integer; const aName: string = 'New Module'; const aDescription: WideString = '');
begin
  inherited Create;
  FId:= aId;
  FName:= aName;
  FDescription:= aDescription;
  //FGroupId:= aGroupId;
end;

end.
