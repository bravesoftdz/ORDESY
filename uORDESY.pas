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
  (*TGroupItem = class
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
  end;*)

  TOraItem = class
  private
    FId : integer;
    FSchemeId: integer;
    FType: TOraItemType;
    FName: string;
    FBody: WideString;
    FOnChange: TNotifyEvent;
    procedure SetName(const Value: string);
    procedure SetType(const Value: TOraItemType);
    procedure SetBody(const Value: widestring);
    procedure SetSchemeId(const Value: integer);
    //FLastChange: TDatetime;
  public
    constructor Create(const aId, aSchemeId: integer; const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure);
    class function GetItemSqlType(const aType: TOraItemType): string;
    {function Wrap(var aProject: TORDESYProject):boolean;
    function Deploy(var aProject: TORDESYProject): boolean;
    function SaveToProject(var aProject: TORDESYProject): boolean;}
    property Id: integer read FId;
    property Name: string read FName write SetName;
    property ItemType: TOraItemType read FType write SetType;
    property ItemBody: widestring read FBody write SetBody;
    property SchemeId: integer read FSchemeId write SetSchemeId;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TOraBase = class
  private
    FId: integer;
    FName: string;
    FOnChange: TNotifyEvent;
    procedure SetName(const Value: string);
  public
    constructor Create(const aId: integer; const aName: string);
    property Id: integer read FId;
    property Name: string read FName write SetName;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TOraScheme = class
  private
    FId: integer;
    FBaseId: integer;
    FModuleId: integer;
    FLogin: string;
    FPass: string;
    FConnection: TConnection;
    FConnected: boolean;
    FValid: boolean;
    FOnChange: TNotifyEvent;
    procedure SetBaseId(const Value: integer);
    procedure SetLogin(const Value: string);
    procedure SetModuleId(const Value: integer);
    procedure SetPass(const Value: string);
  public
    constructor Create(const aId: integer; const aLogin, aPass: string; const aBaseId, aModuleId: integer);
    destructor Destroy; override;
    procedure Connect(var aProject: TORDESYProject);
    procedure Disconnect;
    property Id: integer read FId;
    property ModuleId: integer read FModuleId write SetModuleId;
    property BaseId: integer read FBaseId write SetBaseId;
    property Login: string read FLogin write SetLogin;
    property Pass: string read FPass write SetPass;
    property Connection: TConnection read FConnection write FConnection;
    property Connected: boolean read FConnected;
    property Valid: boolean read FValid;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TORDESYModule = class
  private
    FId: integer;
    FName: string;
    FDescription: WideString;
    FOnChange: TNotifyEvent;
    procedure SetDescription(const Value: widestring);
    procedure SetName(const Value: string);
  public
    constructor Create(const aId: integer; const aName: string = 'New Module'; const aDescription: WideString = '');
    property Id: integer read FId;
    property Name: string read FName write SetName;
    property Description: widestring read FDescription write SetDescription;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TORDESYProject = class
  private
    FId: integer;
    FName: string;
    FDescription: string;
    FCreator: string;
    FDateCreate: TDateTime;
    FORDESYModules: array of TORDESYModule;
    FOraBases: array of TOraBase;
    FOraSchemes: array of TOraScheme;
    FOraItems: array of TOraItem;
    FOnChange: TNotifyEvent;
    function GetOraItemCount: integer;
    function GetModuleCount: integer;
    function GetOraBaseCount: integer;
    function GetOraSchemeCount: integer;
    procedure SetName(const Value: string);
    procedure SetCreator(const Value: string);
    procedure SetDescription(const Value: string);
  public
    constructor Create(const aId: integer; const aName: string = 'New Project'; const aDescription: string = 'About new project...'; const aCreator: string = 'nobody'; const aDateCreate: TDateTime = 0);
    destructor Destroy; override;
    function GetFreeModuleId: integer;
    function GetFreeBaseId: integer;
    function GetFreeSchemeId: integer;
    function GetFreeItemId: integer;
    // Item
    procedure AddOraItem(aItem: TOraItem);
    function GetOraItemById(const aId: integer): TOraItem;
    function GetOraItemByIndex(const aIndex: integer): TOraItem;
    function GetOraItemName(const aIndex: integer): string;
    // Base
    procedure AddOraBase(aBase: TOraBase);
    function GetOraBaseById(const aId: integer): TOraBase;
    function GetOraBaseByIndex(const aIndex: integer): TOraBase;
    function GetOraBaseName(const aIndex: integer): string;
    // Scheme
    procedure AddOraScheme(aScheme: TOraScheme);
    function GetOraSchemeById(const aId: integer): TOraScheme;
    function GetOraSchemeByIndex(const aIndex: integer): TOraScheme;
    function GetOraSchemeLogin(const aIndex: integer): string;
    // Module
    procedure AddModule(aModule: TORDESYModule);
    function GetModuleById(const aId: integer): TORDESYModule;
    function GetModuleByIndex(const aIndex: integer): TORDESYModule;
    function GetModuleName(const aIndex: integer): string;
    // WRAP DEPLOY!
    procedure WrapItem(const aSchemeId: integer; const aName: string; const aType: TOraItemType);
    procedure DeployItem(const aItemId: integer);

    property Id: integer read FId;
    property Creator: string read FCreator write SetCreator;
    property Name: string read FName write SetName;
    property Description: string read FDescription write SetDescription;
    property DateCreate: TDateTime read FDateCreate;
    //
    property ModuleCount: integer read GetModuleCount;
    property OraBaseCount: integer read GetOraBaseCount;
    property OraSchemeCount: integer read GetOraSchemeCount;
    property OraItemCount: integer read GetOraItemCount;
    //
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TORDESYProjectList = class
  private
    FProjects: array of TORDESYProject;
    FSaved: boolean;
    FOnProjectAdd: TNotifyEvent;
    FOnProjectRemove: TNotifyEvent;
    procedure Clear;
    function GetProjectsCount: integer;
    procedure OnChange(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddProject(aProject: TORDESYProject);
    procedure RemoveProjectById(const aId: integer);
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

constructor TOraItem.Create(const aId, aSchemeId: integer; const aName: string; const aBody: WideString = ''; const aType: TOraItemType = OraProcedure);
begin
  inherited Create;
  FId:= aId;
  FType:= aType;
  FName:= aName;
  FBody:= aBody;
  FSchemeId:= aSchemeId;
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
  OnChange(Self);
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
  OnChange(Self);
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
  OnChange(Self);
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
  OnChange(Self);
end;

constructor TORDESYProject.Create(const aId: integer; const aName: string; const aDescription: string; const aCreator: string; const aDateCreate: TDateTime);
begin
  inherited Create;
  FId:= aId;
  FName:= aName;
  FDescription:= aDescription;
  FCreator:= aCreator;
  if aDateCreate = 0 then
    FDateCreate:= Date + Time
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

function TORDESYProject.GetModuleById(const aId: integer): TORDESYModule;
var
  i: integer;
begin
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].FId = aId then
    begin
      Result:= FORDESYModules[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetModuleByIndex(const aIndex: integer): TORDESYModule;
begin
  Result:= nil;
  if (aIndex >= 0) and (aIndex<= high(FORDESYModules)) then
     Result:= FORDESYModules[aIndex]
  else
    raise Exception.Create('Incorrect module index. Max value is: ' + IntToStr(high(FORDESYModules)));
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

function TORDESYProject.GetOraBaseById(const aId: integer): TOraBase;
var
  i: integer;
begin
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].FId = aId then
    begin
      Result:= FOraBases[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetOraBaseByIndex(const aIndex: integer): TOraBase;
begin
  Result:= nil;
  if (aIndex >= 0) and (aIndex<= high(FOraBases)) then
     Result:= FOraBases[aIndex]
  else
    raise Exception.Create('Incorrect base index. Max value is: ' + IntToStr(high(FOraBases)));
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

function TORDESYProject.GetOraItemById(const aId: integer): TOraItem;
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].FId = aId then
    begin
      Result:= FOraItems[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetOraItemByIndex(const aIndex: integer): TOraItem;
begin
  Result:= nil;
  if (aIndex >= 0) and (aIndex<= high(FOraItems)) then
     Result:= FOraItems[aIndex]
  else
    raise Exception.Create('Incorrect item index. Max value is: ' + IntToStr(high(FOraItems)));
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

function TORDESYProject.GetOraSchemeById(const aId: integer): TOraScheme;
var
  i: integer;
begin
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].FId = aId then
    begin
      Result:= FOraSchemes[i];
      Exit;
    end;
  end;
  Result:= nil;
end;

function TORDESYProject.GetOraSchemeByIndex(const aIndex: integer): TOraScheme;
begin
  Result:= nil;
  if (aIndex >= 0) and (aIndex<= high(FOraSchemes)) then
     Result:= FOraSchemes[aIndex]
  else
    raise Exception.Create('Incorrect scheme index. Max value is: ' + IntToStr(high(FOraSchemes)));
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

procedure TORDESYProject.SetCreator(const Value: string);
begin
  FCreator := Value;
  OnChange(Self);
end;

procedure TORDESYProject.SetDescription(const Value: string);
begin
  FDescription := Value;
  OnChange(Self);
end;

procedure TORDESYProject.SetName(const Value: string);
begin
  FName := Value;
  OnChange(Self);
end;

procedure TORDESYProject.WrapItem(const aSchemeId: integer; const aName: string;
  const aType: TOraItemType);
var
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  firstItem: boolean;
begin
  try
    iScheme:= GetOraSchemeById(aSchemeId);
    iModule:= GetModuleById(iScheme.ModuleId);
    iBase:= GetOraBaseById(iScheme.BaseId);
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
      iItem:= TOraItem.Create(GetFreeItemId ,aSchemeId, aName, '', aType);
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

(*constructor TGroupItem.Create(const aName: string; const aId,
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
end;*)

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

constructor TOraScheme.Create(const aId: integer; const aLogin, aPass: string; const aBaseId, aModuleId: integer);
begin
  inherited Create;
  FId:= aId;
  FLogin:= aLogin;
  FPass:= aPass;
  FBaseId:= aBaseId;
  FModuleId:= aModuleId;
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

procedure TOraScheme.SetBaseId(const Value: integer);
begin
  FBaseId := Value;
  OnChange(Self);
end;

procedure TOraScheme.SetLogin(const Value: string);
begin
  FLogin := Value;
  OnChange(Self);
end;

procedure TOraScheme.SetModuleId(const Value: integer);
begin
  FModuleId := Value;
  OnChange(Self);
end;

procedure TOraScheme.SetPass(const Value: string);
begin
  FPass := Value;
  OnChange(Self);
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

procedure TOraItem.SetBody(const Value: widestring);
begin
  FBody := Value;
  OnChange(Self);
end;

procedure TOraItem.SetName(const Value: string);
begin
  FName := Value;
  OnChange(Self);
end;

procedure TOraItem.SetSchemeId(const Value: integer);
begin
  FSchemeId := Value;
  OnChange(Self);
end;

procedure TOraItem.SetType(const Value: TOraItemType);
begin
  FType := Value;
  OnChange(Self);
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

procedure TOraBase.SetName(const Value: string);
begin
  FName := Value;
  OnChange(Self);
end;

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
  FSaved:= false;
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

destructor TORDESYProjectList.Destroy;
var
  i: integer;
begin
  for i := 0 to High(FProjects) do
    FProjects[i].Free;
  SetLength(FProjects, 0);

  inherited Destroy;
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
  Result:= nil;
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = aId then
      Result:= FProjects[i];
  end;
end;

function TORDESYProjectList.GetProjectByIndex(
  const aIndex: integer): TORDESYProject;
begin
  Result:= nil;
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
  iP, iM, iB, iSc, Ii, iId, ModuleId, BaseId, SchemeId,
  charSize, strSize, NameSize, DescSize, CreatorSize, BodySize,
  LoginSize, PassSize,
  iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;
  iItemType: TOraItemType;
  iFileHeader, iFileVersion,
  iName, iDescription, iCreator,
  iLogin, iPass, iBody: String;
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
      SetLength(iFileHeader, length(ORDESYNAME));
      SetLength(iFileVersion, length(ORDESYVERSION));
      FileRead(iHandle, iFileHeader[1], length(ORDESYNAME) * charSize);     // Reading header
      FileRead(iHandle, iFileVersion[1], length(ORDESYVERSION) * charSize); // Reading version
      //MessageBox(Application.Handle, PChar(iFileHeader + ' - ' + iFileVersion), PChar('warning'), 0);
      if (iFileHeader <> ORDESYNAME) or (iFileVersion <> ORDESYVERSION) then
        raise Exception.Create('Incorrect project version! Need: ' + ORDESYNAME + ' ' + ORDESYVERSION);
      SetLength(iFileHeader, 0);
      SetLength(iFileVersion, 0);
      FileRead(iHandle, iProjectCount, sizeof(iProjectCount)); // PROJECT COUNT
      for iP:= 0 to iProjectCount - 1 do
      begin
        // Id
        FileRead(iHandle, iId, sizeof(iId));
        // Name
        FileRead(iHandle, strSize, sizeof(strSize));   // Name length
        SetLength(iName, strSize);
        FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
        // Desc
        FileRead(iHandle, strSize, sizeof(strSize));          // Desc length
        SetLength(iDescription, strSize);
        FileRead(iHandle, iDescription[1], strSize * charSize); // Getting Desc
        // Creator
        FileRead(iHandle, strSize, sizeof(strSize));      // Creator length
        SetLength(iCreator, strSize);
        FileRead(iHandle, iCreator[1], strSize * charSize); // Getting creator
        // Datecreate
        FileRead(iHandle, iDateCreate, SizeOf(iDateCreate));
        // Creating project
        iProject:= TORDESYProject.Create(iId, iName, iDescription, iCreator, iDateCreate);
        iProject.OnChange:= OnChange;
        // Free
        SetLength(iName, 0);
        SetLength(iDescription, 0);
        SetLength(iCreator, 0);
        //--- MODULES
        FileRead(iHandle, iModuleCount, sizeof(iModuleCount)); // MODULE COUNT
        for iM := 0 to iModuleCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
          // Name
          FileRead(iHandle, strSize, sizeof(strSize));     // Name length
          SetLength(iName, strSize);
          FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
          // Desc
          FileRead(iHandle, strSize, sizeof(strSize));            // Desc length
          SetLength(iDescription, strSize);
          FileRead(iHandle, iDescription[1], strSize * charSize); // Getting Desc
          // Adding
          iProject.AddModule(TORDESYModule.Create(iId, iName, iDescription));
          // Free
          SetLength(iName, 0);
          SetLength(iDescription, 0);
        end;
        //--- BASES
        FileRead(iHandle, iBaseCount, sizeof(iBaseCount)); // BASE COUNT
        for iB := 0 to iBaseCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
          // Name
          FileRead(iHandle, strSize, sizeof(strSize));     // Name length
          SetLength(iName, strSize);
          FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
          // Adding
          iProject.AddOraBase(TOraBase.Create(iId, iName));
          // Free
          SetLength(iName, 0);
        end;
        //--- SCHEMES
        FileRead(iHandle, iSchemeCount, sizeof(iSchemeCount)); // SCHEME COUNT
        for iSc := 0 to iSchemeCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
          // Login
          FileRead(iHandle, strSize, sizeof(strSize));      // Login length
          SetLength(iLogin, strSize);
          FileRead(iHandle, iLogin[1], strSize * charSize); // Getting Login
          // Pass
          FileRead(iHandle, strSize, sizeof(strSize));       // Pass length
          SetLength(iPass, strSize);
          FileRead(iHandle, iPass[1], strSize * charSize); // Getting Login
          // ModuleId
          FileRead(iHandle, ModuleId, sizeof(ModuleId));
          // BaseId
          FileRead(iHandle, BaseId, sizeof(BaseId));
          // Adding
          iProject.AddOraScheme(TOraScheme.Create(iId, iLogin, iPass, BaseId, ModuleId));
          // Free
          SetLength(iLogin, 0);
          SetLength(iPass, 0);
        end;
        //--- ITEMS
        FileRead(iHandle, iItemCount, sizeof(iItemCount)); // ITEM COUNT
        for Ii := 0 to iItemCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, sizeof(iId));
          // ShemeId
          FileRead(iHandle, SchemeId, sizeof(SchemeId));
          // Name
          FileRead(iHandle, strSize, sizeof(strSize));     // Name length
          SetLength(iName, strSize);
          FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
          // Type
          FileRead(iHandle, iItemType, sizeof(iItemType));
          // Body
          FileRead(iHandle, strSize, sizeof(strSize));       // Body length
          SetLength(iBody, strSize);
          FileRead(iHandle, iBody[1], strSize * charSize); // Getting Name
          // Adding
          iProject.AddOraItem(TOraItem.Create(iId, SchemeId, iName, iBody, iItemType));
          // Free
          SetLength(iName, 0);
          SetLength(iBody, 0);
        end;
        // ADD PROJECT
        AddProject(iProject);
      end;
      FSaved:= true;
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

procedure TORDESYProjectList.OnChange(Sender: TObject);
begin
  FSaved:= false;
end;

procedure TORDESYProjectList.RemoveProjectById(const aId: integer);
var
  i: integer;
  LastItem: TORDESYProject;
begin
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = aId then
    begin
      FProjects[i].Free;
      LastItem:= FProjects[high(FProjects)];
      FProjects[i]:= LastItem;
      SetLength(FProjects, length(FProjects) - 1);
      FSaved:= false;
      if Assigned(FOnProjectRemove) then
        FOnProjectRemove(Self);
    end;
  end;
end;

function TORDESYProjectList.SaveToFile(const aFileName: string): boolean;
var
  iP, iM, iB, iSc, iI, charSize, strSize, i: integer;
  iHandle: integer;
  iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  Buffer: PChar;
begin
  Result:= false;
  FSaved:= false;
  try
    try
      iProjectCount:= Count;
      charSize:= sizeof(Char);
      iHandle:= FileCreate(aFileName);
      FileWrite(iHandle, ORDESYNAME[1], Length(ORDESYNAME) * charSize);
      FileWrite(iHandle, ORDESYVERSION[1], Length(ORDESYVERSION) * charSize);
      //--- PROJECTS
      iProjectCount:= GetProjectsCount;
      FileWrite(iHandle, iProjectCount, sizeof(iProjectCount));
      for iP := 0 to iProjectCount - 1 do
      begin
        iProject:= GetProjectByIndex(iP);
        // Id
        FileWrite(iHandle, iProject.Id, sizeof(iProject.Id));
        // Name
        strSize:= Length(iProject.Name);
        FileWrite(iHandle, strSize, sizeof(strSize));             // Name length
        FileWrite(iHandle, iProject.Name[1], strSize * charSize); // Name
        // Desc
        strSize:= Length(iProject.Description);
        FileWrite(iHandle, strSize, sizeof(strSize));                    // Desc length
        FileWrite(iHandle, iProject.Description[1], strSize * charSize); // Desc
        // Creator
        strSize:= Length(iProject.Creator);
        FileWrite(iHandle, strSize, sizeof(strSize));                // Creator length
        FileWrite(iHandle, iProject.Creator[1], strSize * charSize); // Creator
        // Datecreate
        FileWrite(iHandle, iProject.DateCreate, sizeof(iProject.DateCreate));
        //--- MODULES
        iModuleCount:= iProject.ModuleCount;
        FileWrite(iHandle, iModuleCount, sizeof(iModuleCount));
        for iM := 0 to iModuleCount - 1 do
        begin
          iModule:= iProject.GetModuleByIndex(iM);
          // Id
          FileWrite(iHandle, iModule.Id, sizeof(iModule.Id));
          // Name
          strSize:= Length(iModule.Name);
          FileWrite(iHandle, strSize, sizeof(strSize));            // Name length
          FileWrite(iHandle, iModule.Name[1], strSize * charSize); // Name
          // Desc
          strSize:= Length(iModule.Description);
          FileWrite(iHandle, strSize, sizeof(strSize));                   // Desc length
          FileWrite(iHandle, iModule.Description[1], strSize * charSize); // Desc
        end;
        //--- BASES
        iBaseCount:= iProject.OraBaseCount;
        FileWrite(iHandle, iBaseCount, sizeof(iBaseCount));
        for iB := 0 to iBaseCount - 1 do
        begin
          iBase:= iProject.GetOraBaseByIndex(iB);
          // Id
          FileWrite(iHandle, iBase.Id, sizeof(iBase.Id));
          // Name
          strSize:= Length(iBase.Name);
          FileWrite(iHandle, strSize, sizeof(strSize));          // Name length
          FileWrite(iHandle, iBase.Name[1], strSize * charSize); // Name
        end;
        //--- SCHEMES
        iSchemeCount:= iProject.OraBaseCount;
        FileWrite(iHandle, iSchemeCount, sizeof(iSchemeCount));
        for iSc := 0 to iSchemeCount - 1 do
        begin
          iScheme:= iProject.GetOraSchemeByIndex(iSc);
          // Id
          FileWrite(iHandle, iScheme.Id, sizeof(iScheme.Id));
          // Login
          strSize:= Length(iScheme.Login);
          FileWrite(iHandle, strSize, sizeof(strSize));             // Login length
          FileWrite(iHandle, iScheme.Login[1], strSize * charSize); // Login
          // Pass
          strSize:= Length(iScheme.Pass);
          FileWrite(iHandle, strSize, sizeof(strSize));                // Pass length
          FileWrite(iHandle, iScheme.Pass[1], strSize * charSize); // Pass
          // ModuleId
          FileWrite(iHandle, iScheme.ModuleId, sizeof(iScheme.ModuleId));
          // BaseId
          FileWrite(iHandle, iScheme.BaseId, sizeof(iScheme.BaseId));
        end;
        //--- ITEMS
        iItemCount:= iProject.OraItemCount;
        FileWrite(iHandle, iItemCount, sizeof(iItemCount));
        for iI := 0 to iItemCount - 1 do
        begin
          iItem:= iProject.GetOraItemByIndex(iI);
          // Id
          FileWrite(iHandle, iItem.Id, sizeof(iItem.Id));
          // SchemeId
          FileWrite(iHandle, iItem.SchemeId, sizeof(iItem.SchemeId));
          // Name
          strSize:= Length(iItem.Name);
          FileWrite(iHandle, strSize, sizeof(strSize));          // Name length
          FileWrite(iHandle, iItem.Name[1], strSize * charSize); // Name
          // Type
          FileWrite(iHandle, iItem.ItemType, sizeof(iItem.ItemType));
          // Body
          strSize:= Length(iItem.ItemBody);
          FileWrite(iHandle, strSize, sizeof(strSize));              // Body length
          FileWrite(iHandle, iItem.ItemBody[1], strSize * charSize); // Body
        end;
      end;
      FSaved:= true;
      Result:= true;
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
end;

procedure TORDESYModule.SetDescription(const Value: widestring);
begin
  FDescription := Value;
  OnChange(Self);
end;

procedure TORDESYModule.SetName(const Value: string);
begin
  FName := Value;
  OnChange(Self);
end;

end.
