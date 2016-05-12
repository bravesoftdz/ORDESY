{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

Main unit.

classes:
  TOraItem           - item, some object of database, now supports (PROCEDURE, FUNCTION, PACKAGE)
  TOraScheme         - scheme, login + password of oracle scheme
  TOraBase           - base, name of database that we can to connect to
  TORDESYModule      - module, agregating the database items
  TORDESYProject     - project, agregating the modules
  TORDESYProjectList - the list of projects (saving/loading)
}

unit uORDESY;

interface

uses
  // ORDESY Modules  
  uExplode, uConnection, uShellFuncs, uHash, uErrorHandle, uFileRWTypes,
  // Delphi Modules
  Generics.Collections, SysUtils, Forms, Windows, Classes, Controls;

const
  ORDESYNAME = 'ORDESY PROJECT';
  ORDESYVERSION = '1.0';

type
  TOraItemType = (OraProcedure, OraFunction, OraPackage);

  { Forward declarations }

  TOraItem = class;
  TOraScheme = class;
  TOraBase = class;
  TORDESYModule = class;
  TORDESYProject = class;
  TORDESYProjectList = class;
  PORDESYProject = ^TORDESYProject;

  TOraItemHead = class
    Name: string;
    ItemType: TOraItemType;
    Valid: boolean;
  end;

  TOraItem = class
  private
    FId: integer;
    FSchemeId: integer;
    FBaseId: integer;
    FHash: LongWord;
    FType: TOraItemType;
    FValid: boolean;
    FName: string;
    FBody: WideString;
    FOnChange: TNotifyEvent;
    FModuleRef: Pointer;
    procedure SetName(const Value: string);
    procedure SetType(const Value: TOraItemType);
    procedure SetBody(const Value: WideString);
    procedure SetSchemeId(const Value: integer);
    procedure SetBaseId(const Value: integer);
  public
    constructor Create(aModuleRef: Pointer; const aId, aBaseId,
      aSchemeId: integer; const aName: string; const aBody: WideString = '';
      const aType: TOraItemType = OraProcedure; const aValid: boolean = false);
    class function GetItemSqlType(const aType: TOraItemType): string;
    class function GetItemType(const aType: string): TOraItemType;
    procedure UpdateStatus;
    function Actual: boolean;
    { function Wrap(var aProject: TORDESYProject):boolean;
      function Deploy(var aProject: TORDESYProject): boolean;
      function SaveToProject(var aProject: TORDESYProject): boolean; }
    property Id: integer read FId;
    property Name: string read FName write SetName;
    property ItemType: TOraItemType read FType write SetType;
    property Valid: boolean read FValid;
    property ItemBody: WideString read FBody write SetBody;
    property SchemeId: integer read FSchemeId write SetSchemeId;
    property BaseId: integer read FBaseId write SetBaseId;
    property Hash: LongWord read FHash;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property ModuleRef: Pointer read FModuleRef;
  end;

  TOraBase = class
  private
    FId: integer;
    FName: string;
    FOnChange: TNotifyEvent;
    FProjectListRef: Pointer;
    procedure SetName(const Value: string);
  public
    constructor Create(aProjectListRef: Pointer; const aId: integer;
      const aName: string);
    property Id: integer read FId;
    property Name: string read FName write SetName;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property ProjectListRef: Pointer read FProjectListRef;
  end;

  TOraScheme = class
  private
    FId: integer;
    FLogin: string;
    FPass: string;
    FConnection: TConnection;
    FConnected: boolean;
    FItemList: array of TOraItemHead;
    FOnChange: TNotifyEvent;
    FProjectListRef: Pointer;
    procedure SetLogin(const Value: string);
    procedure SetPass(const Value: string);
    procedure Clear;
  public
    constructor Create(aProjectListRef: Pointer; const aId: integer;
      const aLogin, aPass: string);
    destructor Destroy; override;
    procedure Connect(const BaseId: integer);
    procedure Disconnect;
    procedure GetItemList(const aItemType: TOraItemType; aList: TStrings);
    property Id: integer read FId;
    property Login: string read FLogin write SetLogin;
    property Pass: string read FPass write SetPass;
    property Connection: TConnection read FConnection write FConnection;
    property Connected: boolean read FConnected;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property ProjectListRef: Pointer read FProjectListRef;
  end;

  TORDESYModule = class
  private
    FId: integer;
    FName: string;
    FDescription: WideString;
    FOraItems: array of TOraItem;
    FOnChange: TNotifyEvent;
    FProjectRef: Pointer;
    function GetOraItemCount: integer;
    procedure SetDescription(const Value: WideString);
    procedure SetName(const Value: string);
  public
    constructor Create(aProjectRef: Pointer; const aId: integer;
      const aName: string = 'New Module'; const aDescription: WideString = '');
    destructor Destroy; override;
    // Item
    function GetFreeItemId: integer;
    procedure AddOraItem(aItem: TOraItem);
    function GetOraItemById(const aId: integer): TOraItem;
    function GetOraItemByIndex(const aIndex: integer): TOraItem;
    function GetOraItemNameById(const aId: integer): string;
    function RemoveOraItemById(const aId: integer): boolean;
    //
    property Id: integer read FId;
    property Name: string read FName write SetName;
    property Description: WideString read FDescription write SetDescription;
    property OraItemCount: integer read GetOraItemCount;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property ProjectRef: Pointer read FProjectRef;
  end;

  TORDESYProject = class
  private
    FId: integer;
    FName: string;
    FDescription: string;
    FCreator: string;
    FDateCreate: TDateTime;
    FORDESYModules: array of TORDESYModule;
    FOnChange: TNotifyEvent;
    FProjectListRef: Pointer;
    function GetModuleCount: integer;
    procedure SetName(const Value: string);
    procedure SetCreator(const Value: string);
    procedure SetDescription(const Value: string);
  public
    constructor Create(aProjectRef: Pointer; const aId: integer; const aName: string = 'New Project';
      const aDescription: string = 'About new project...';
      const aCreator: string = 'nobody'; const aDateCreate: TDateTime = 0);
    destructor Destroy; override;
    // Module
    function GetFreeModuleId: integer;
    procedure AddModule(aModule: TORDESYModule);
    function GetModuleById(const aId: integer): TORDESYModule;
    function GetModuleByIndex(const aIndex: integer): TORDESYModule;
    function GetModuleNameById(const aId: integer): string;
    function GetModuleNameByIndex(const aIndex: integer): string;
    function RemoveModuleById(const aId: integer): boolean;
    // WRAP DEPLOY!
    function WrapItem(const aModuleId, aBaseId, aSchemeId: integer;
      const aName: string; const aType: TOraItemType; const aValid: boolean): boolean;
    procedure DeployItem(const aItemId: integer);

    property Id: integer read FId;
    property Creator: string read FCreator write SetCreator;
    property Name: string read FName write SetName;
    property Description: string read FDescription write SetDescription;
    property DateCreate: TDateTime read FDateCreate;
    //
    property ModuleCount: integer read GetModuleCount;
    //
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property ProjectListRef: Pointer read FProjectListRef;
  end;

  TORDESYProjectList = class
  private
    FProjects: array of TORDESYProject;
    FOraBases: array of TOraBase;
    FOraSchemes: array of TOraScheme;
    FSaved: boolean;
    FOnProjectAdd: TNotifyEvent;
    FOnProjectRemove: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnBaseAdd: TNotifyEvent;
    FOnBaseRemove: TNotifyEvent;
    FOnSchemeAdd: TNotifyEvent;
    FOnSchemeRemove: TNotifyEvent;
    procedure Clear;
    function GetProjectsCount: integer;
    function GetOraBaseCount: integer;
    function GetOraSchemeCount: integer;
    procedure OnProjectListChange(Sender: TObject);    
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddProject(aProject: TORDESYProject);
    function GetProjectByIndex(const aIndex: integer): TORDESYProject;
    function GetProjectById(const aId: integer): TORDESYProject;
    function RemoveProjectById(const aId: integer): boolean;
    function RemoveProjectByIndex(const aIndex: integer): boolean;
    // Base
    function AddOraBase(aBase: TOraBase): boolean;
    function GetOraBaseById(const aId: integer): TOraBase;
    function GetOraBaseByIndex(const aIndex: integer): TOraBase;
    function GetOraBaseNameById(const aId: integer): string;
    function GetOraBaseNameByIndex(const aIndex: integer): string;
    function RemoveBaseById(const aId: integer): Boolean;
    function RemoveBaseByIndex(const aIndex: integer): boolean;
    // Scheme
    procedure AddOraScheme(aScheme: TOraScheme);
    function GetOraSchemeById(const aId: integer): TOraScheme;
    function GetOraSchemeByIndex(const aIndex: integer): TOraScheme;
    function GetOraSchemeLoginById(const aId: integer): string;
    function GetOraSchemeLoginByIndex(const aIndex: integer): string;
    function RemoveSchemeById(const aId: integer): Boolean;
    function RemoveSchemeByIndex(const aIndex: integer): boolean;
    //
    function GetFreeProjectId: integer;
    function GetFreeBaseId: integer;
    function GetFreeSchemeId: integer;
    function LoadFromFile(const aFileName: string = 'ORDESY.data'): boolean;
    function SaveToFile(const aFileName: string = 'ORDESY.data'): boolean;
    property ProjectCount: integer read GetProjectsCount;
    property Saved: boolean read FSaved;
  published
    property OnProjectAdd: TNotifyEvent read FOnProjectAdd write FOnProjectAdd;
    property OnProjectRemove
      : TNotifyEvent read FOnProjectRemove write FOnProjectRemove;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnBaseAdd: TNotifyEvent read FOnBaseAdd write FOnBaseAdd;
    property OnBaseRemove: TNotifyEvent read FOnBaseRemove write FOnBaseRemove;
    property OnSchemeAdd: TNotifyEvent read FOnSchemeAdd write FOnSchemeAdd;
    property OnSchemeRemove: TNotifyEvent read FOnSchemeRemove write FOnSchemeRemove;
    property OraBaseCount: integer read GetOraBaseCount;
    property OraSchemeCount: integer read GetOraSchemeCount;
  end;

implementation

{ TDBItem }

function TOraItem.Actual: boolean;
var
  iBody: WideString;
  iHash: LongWord;
  firstItem: boolean;
  iProjectList: TORDESYProjectList;
  iBase: TOraBase;
  iScheme: TOraScheme;
begin
  result:= false;
  try
    Screen.Cursor:= crSQLWait;
    try
      iProjectList:= TORDESYProjectList(TORDESYModule(ModuleRef).ProjectRef);
      if not Assigned(iProjectList) then
        raise Exception.Create('Error with getting ORDESY ProjectList object.');
      iBase:= iProjectList.GetOraBaseById(BaseId);
      if not Assigned(iBase) then
        raise Exception.Create(Format('Error with getting OraBase object. BaseId = %u', [BaseId]));
      iScheme:= iProjectList.GetOraSchemeById(SchemeId);
      if not Assigned(iScheme) then
        raise Exception.Create(Format('Error with getting OraScheme object. SchemeId = %u', [SchemeId]));
      // connecting...
      if not iScheme.Connected then
        iScheme.Connect(iBase.Id);
      // retrieve
      with iScheme.Connection do
      begin
        Query.Active := false;
        Query.SQL.Text :=
          Format('select text from sys.all_source where owner = ''%s'' and name = ''%s'' and type = ''%s'' order by line asc', [iScheme.Login, FName, TOraItem.GetItemSqlType(ItemType)]);
        Query.Active := true;
        firstItem := true;
        while not Query.Eof do
        begin
          if firstItem then
            iBody := iBody + 'CREATE OR REPLACE ' + Query.Fields[0].AsString
          else
            iBody := iBody + Query.Fields[0].AsString;
          firstItem := false;
          Query.Next;
        end;
        iHash:= MurmurHash2(iBody);
        if iHash = Hash then
          Result:= true;
      end;
    finally
      Screen.Cursor:= crDefault;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'Actual', E.Message]);      
  end;
end;

constructor TOraItem.Create(aModuleRef: Pointer; const aId, aBaseId,
  aSchemeId: integer; const aName: string; const aBody: WideString = '';
  const aType: TOraItemType = OraProcedure; const aValid: boolean = false);
begin
  inherited Create;
  FId := aId;
  FType := aType;
  FValid := aValid;
  FName := aName;
  FBody := aBody;
  // FHash:= GetSimpleHash(PChar(FBody));
  FHash := MurmurHash2(FBody);
  FSchemeId := aSchemeId;
  FBaseId := aBaseId;
  FModuleRef := aModuleRef;
end;

{ TORDESYProject }

procedure TORDESYProject.AddModule(aModule: TORDESYModule);
begin
  if GetModuleById(aModule.Id) <> nil then
    Exit;
  SetLength(FORDESYModules, length(FORDESYModules) + 1);
  FORDESYModules[ high(FORDESYModules)] := aModule;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

function TORDESYProjectList.AddOraBase(aBase: TOraBase): boolean;
begin
  Result:= false;
  try
    if GetOraBaseById(aBase.Id) <> nil then
      Exit;
    SetLength(FOraBases, length(FOraBases) + 1);
    FOraBases[ high(FOraBases)] := aBase;
    if Assigned(FOnBaseAdd) then
      OnBaseAdd(Self);
    if Assigned(FOnChange) then
      OnChange(Self);
    Result:= true;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveModuleById', E.Message]);
  end;
end;

procedure TORDESYModule.AddOraItem(aItem: TOraItem);
begin
  if GetOraItemById(aItem.Id) <> nil then
    Exit;
  SetLength(FOraItems, length(FOraItems) + 1);
  FOraItems[ high(FOraItems)] := aItem;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYProjectList.AddOraScheme(aScheme: TOraScheme);
begin
  if GetOraSchemeById(aScheme.Id) <> nil then
    Exit;
  SetLength(FOraSchemes, length(FOraSchemes) + 1);
  FOraSchemes[ high(FOraSchemes)] := aScheme;
  if Assigned(FOnSchemeAdd) then
    OnSchemeAdd(Self);
  if Assigned(FOnChange) then
    OnChange(Self);
end;

constructor TORDESYProject.Create(aProjectRef: Pointer; const aId: integer; const aName: string;
  const aDescription: string; const aCreator: string;
  const aDateCreate: TDateTime);
begin
  inherited Create;
  FId := aId;
  FName := aName;
  FDescription := aDescription;
  FCreator := aCreator;
  FProjectListRef:= aProjectRef;
  if aDateCreate = 0 then
    FDateCreate := Date + Time
  else
    FDateCreate := aDateCreate;
end;

procedure TORDESYProject.DeployItem(const aItemId: integer);
begin

end;

destructor TORDESYProject.Destroy;
var
  i: integer;
begin
  for i := 0 to high(FORDESYModules) do
    FORDESYModules[i].Free;
  SetLength(FORDESYModules, 0);
  inherited;
end;

function TORDESYProjectList.GetFreeBaseId: integer;
var
  i, NewId: integer;
label Restart;
begin
  NewId := 0;
Restart :
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result := NewId;
end;

function TORDESYModule.GetFreeItemId: integer;
var
  i, NewId: integer;
label Restart;
begin
  NewId := 0;
Restart :
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result := NewId;
end;

function TORDESYProject.GetFreeModuleId: integer;
var
  i, NewId: integer;
label Restart;
begin
  NewId := 0;
Restart :
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result := NewId;
end;

function TORDESYProjectList.GetFreeSchemeId: integer;
var
  i, NewId: integer;
label Restart;
begin
  NewId := 0;
Restart :
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result := NewId;
end;

function TORDESYProject.GetModuleById(const aId: integer): TORDESYModule;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FORDESYModules) do
  begin
    if FORDESYModules[i].Id = aId then
    begin
      Result := FORDESYModules[i];
      Exit;
    end;
  end;
end;

function TORDESYProject.GetModuleByIndex(const aIndex: integer): TORDESYModule;
begin
  Result := nil;
  if (aIndex >= 0) and (aIndex <= high(FORDESYModules)) then
    Result := FORDESYModules[aIndex]
  else
    raise Exception.Create('Incorrect module index. Max value is: ' + IntToStr
        ( high(FORDESYModules)));
end;

function TORDESYProject.GetModuleCount: integer;
begin
  Result := length(FORDESYModules);
end;

function TORDESYProject.GetModuleNameById(const aId: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FORDESYModules) do
    if FORDESYModules[i].FId = aId then
    begin
      Result := FORDESYModules[i].Name;
      Exit;
    end;
end;

function TORDESYProject.GetModuleNameByIndex(const aIndex: integer): string;
begin
  Result := '';
  if (aIndex >= 0) and (aIndex <= high(FORDESYModules)) then
    Result := FORDESYModules[aIndex].Name
  else
    raise Exception.Create('Incorrect module index. Max value is: ' + IntToStr
        ( high(FORDESYModules)));
end;

function TORDESYProject.RemoveModuleById(const aId: integer): boolean;
var
  i: integer;
begin
  Result := false;
  try
    for i := 0 to high(FORDESYModules) do
    begin
      if FORDESYModules[i].Id = aId then
      begin
        FORDESYModules[i].Free;
        FORDESYModules[i] := FORDESYModules[High(FORDESYModules)];
        SetLength(FORDESYModules, length(FORDESYModules) - 1);
        if Assigned(FOnChange) then
          OnChange(Self);
        Result:= true;
        Exit;
      end;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveModuleById', E.Message]);
  end;
end;

function TORDESYProjectList.GetOraBaseById(const aId: integer): TOraBase;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].Id = aId then
    begin
      Result := FOraBases[i];
      Exit;
    end;
  end;
end;

function TORDESYProjectList.GetOraBaseByIndex(const aIndex: integer): TOraBase;
begin
  Result := nil;
  if (aIndex >= 0) and (aIndex <= high(FOraBases)) then
    Result := FOraBases[aIndex]
  else
    raise Exception.Create(Format('Incorrect base index. Max value is: %u', [high(FOraBases)]));
end;

function TORDESYProjectList.GetOraBaseCount: integer;
begin
  Result := length(FOraBases);
end;

function TORDESYProjectList.GetOraBaseNameById(const aId: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FOraBases) do
    if FOraBases[i].FId = aId then
    begin
      Result := FOraBases[i].Name;
      Exit;
    end;
end;

function TORDESYProjectList.GetOraBaseNameByIndex(
  const aIndex: integer): string;
begin
  Result := '';
  if (aIndex >= 0) and (aIndex <= high(FOraBases)) then
    Result := FOraBases[aIndex].Name
  else
    raise Exception.Create(Format('Incorrect base index. Max value is: %u', [high(FOraBases)]));
end;

function TORDESYModule.GetOraItemById(const aId: integer): TOraItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].FId = aId then
    begin
      Result := FOraItems[i];
      Exit;
    end;
  end;
end;

function TORDESYModule.GetOraItemByIndex(const aIndex: integer): TOraItem;
begin
  Result := nil;
  if (aIndex >= 0) and (aIndex <= high(FOraItems)) then
    Result := FOraItems[aIndex]
  else
    raise Exception.Create(Format('Incorrect item index. Max value is: %u', [high(FOraItems)]));
end;

function TORDESYModule.GetOraItemCount: integer;
begin
  Result := length(FOraItems);
end;

function TORDESYModule.GetOraItemNameById(const aId: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FOraItems) do
    if FOraItems[i].FId = aId then
    begin
      Result := FOraItems[i].Name;
      Exit;
    end;
end;

function TORDESYModule.RemoveOraItemById(const aId: integer): boolean;
var
  i: integer;
begin
  Result := false;
  try
    for i := 0 to high(FOraItems) do
    begin
      if FOraItems[i].Id = aId then
      begin
        FOraItems[i].Free;
        FOraItems[i] := FOraItems[High(FOraItems)];
        SetLength(FOraItems, length(FOraItems) - 1);
        if Assigned(FOnChange) then
          OnChange(Self);
        Result:= true;
        Exit;
      end;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveOraItemById', E.Message]);    
  end;
end;

function TORDESYProjectList.GetOraSchemeById(const aId: integer): TOraScheme;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].Id = aId then
    begin
      Result := FOraSchemes[i];
      Exit;
    end;
  end;
end;

function TORDESYProjectList.GetOraSchemeByIndex(const aIndex: integer)
  : TOraScheme;
begin
  Result := nil;
  if (aIndex >= 0) and (aIndex <= high(FOraSchemes)) then
    Result := FOraSchemes[aIndex]
  else
    raise Exception.Create(Format('Incorrect scheme index. Max value is: $u', [high(FOraSchemes)]));
end;

function TORDESYProjectList.GetOraSchemeCount: integer;
begin
  Result := length(FOraSchemes);
end;

function TORDESYProjectList.GetOraSchemeLoginById(const aId: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FOraSchemes) do
    if FOraSchemes[i].FId = aId then
    begin
      Result := FOraSchemes[i].Login;
      Exit;
    end;
end;

function TORDESYProjectList.GetOraSchemeLoginByIndex(
  const aIndex: integer): string;
begin
  Result := '';
  if (aIndex >= 0) and (aIndex <= high(FOraSchemes)) then
    Result := FOraSchemes[aIndex].Login
  else
    raise Exception.Create(Format('Incorrect scheme index. Max value is: $u', [high(FOraSchemes)]));
end;

procedure TORDESYProject.SetCreator(const Value: string);
begin
  FCreator := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYProject.SetDescription(const Value: string);
begin
  FDescription := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYProject.SetName(const Value: string);
begin
  FName := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

function TORDESYProject.WrapItem(const aModuleId, aBaseId, aSchemeId: integer;
  const aName: string; const aType: TOraItemType; const aValid: boolean): boolean;
var
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  firstItem: boolean;
  ItemBody: WideString;
begin
  Result:= false;
  try
    if not Assigned(TORDESYProjectList(ProjectListRef)) then
      Exit;
    iScheme := TORDESYProjectList(ProjectListRef).GetOraSchemeById(aSchemeId);
    iModule := GetModuleById(aModuleId);
    iBase := TORDESYProjectList(ProjectListRef).GetOraBaseById(aBaseId);
    if (not Assigned(iScheme) or not Assigned(iModule) or not Assigned(iBase))
      then
      raise Exception.Create('Some of objects not created!');
    if not iScheme.Connected then
      iScheme.Connect(aBaseId);
    with iScheme.Connection do
    begin
      Query.Active := false;
      Query.SQL.Text :=
        Format('select text from sys.all_source where owner = ''%s'' and name = ''%s'' and type = ''%s'' order by line asc', [iScheme.Login, aName, TOraItem.GetItemSqlType(aType)]);
      Query.Active := true;
      firstItem := true;
      while not Query.Eof do
      begin
        if firstItem then
          ItemBody := ItemBody + 'CREATE OR REPLACE ' + Query.Fields[0]
            .AsString
        else
          ItemBody := ItemBody + Query.Fields[0].AsString;
        firstItem := false;
        Query.Next;
      end;
      iItem := TOraItem.Create(iModule, iModule.GetFreeItemId, aBaseId,
        aSchemeId, aName, AdjustLineBreaks(ItemBody), aType, aValid);
      iModule.AddOraItem(iItem);
      if Assigned(FOnChange) then
        OnChange(Self);
      Result:= true;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'WrapItem', E.Message]);    
  end;
end;

{ TOraScheme }

procedure TOraScheme.Clear;
var
  i: integer;
begin
  for i := 0 to high(FItemList) do
    FItemList[i].Free;
  SetLength(FItemList, 0);
end;

procedure TOraScheme.Connect(const BaseId: integer);
begin
  try
    try
      Screen.Cursor:= crSQLWait;
      if not Connected then
      begin
        if not Assigned(FConnection) then
          FConnection := TConnection.Create(TORDESYProjectList(FProjectListRef)
              .GetOraBaseNameById(BaseId), FLogin, FPass, connstrORA);
        FConnection.Connect;
        FConnected := FConnection.Connected;
        if FConnection.LastError <> '' then
          raise Exception.Create(FConnection.LastError);
      end;
    finally
      Screen.Cursor:= crDefault;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'Connect', E.Message]);
  end;
end;

constructor TOraScheme.Create(aProjectListRef: Pointer; const aId: integer;
  const aLogin, aPass: string);
begin
  inherited Create;
  FId := aId;
  FLogin := aLogin;
  FPass := aPass;
  FConnected := false;
  FProjectListRef := aProjectListRef;
end;

destructor TOraScheme.Destroy;
var
  i: integer;
begin
  if Assigned(FConnection) then
  begin
    FConnection.Disconnect;
    FConnection.Free;
  end;
  Clear;
  inherited;
end;

procedure TOraScheme.Disconnect;
begin
  if Assigned(FConnection) and (FConnected) then
    FConnection.Disconnect;
  FConnected := FConnection.Connected;
end;

procedure TOraScheme.GetItemList(const aItemType: TOraItemType;
  aList: TStrings);
var
  i: integer;
begin
  try
    Screen.Cursor:= crSQLWait;
    try
      Clear;
      if not Connected then
        raise Exception.Create('Connect scheme to base first.');
      if not Assigned(aList) then
        raise Exception.Create('The list of items not defined.');
      with Connection.Query do
      begin
        aList.BeginUpdate;
        aList.Clear;
        Active := false;
        SQL.Text :=
          Format('select object_name, status from sys.all_objects where owner = user and subobject_name is null and object_name not like ''%s'' and object_type = ''%s''', ['BIN$%', TOraItem.GetItemSqlType(aItemType)]);
        Active := true;
        if RecordCount = 0 then
          raise Exception.Create('Error while getting items list. No data returned!');
        while not Eof do
        begin
          SetLength(FItemList, length(FItemList) + 1);
          FItemList[ High(FItemList)] := TOraItemHead.Create;
          FItemList[ High(FItemList)].Name := Fields[0].AsString;
          if Fields[1].AsString = 'VALID' then
            FItemList[ High(FItemList)].Valid := true
          else
            FItemList[ High(FItemList)].Valid := false;
          FItemList[ High(FItemList)].ItemType := aItemType;
          aList.AddObject(FItemList[ High(FItemList)].Name,
            FItemList[ High(FItemList)]);
          Next;
        end;
        aList.EndUpdate;
      end;
    finally
      Screen.Cursor:= crDefault;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'GetItemList', E.Message]);
  end;
end;

procedure TOraScheme.SetLogin(const Value: string);
begin
  FLogin := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TOraScheme.SetPass(const Value: string);
begin
  FPass := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

{ TOraBase }

constructor TOraBase.Create(aProjectListRef: Pointer; const aId: integer;
  const aName: string);
begin
  inherited Create;
  FId := aId;
  FName := aName;
  FProjectListRef := aProjectListRef;
end;

(* function TOraItem.Deploy(var aProject: TORDESYProject): boolean;
  begin

  end; *)

class function TOraItem.GetItemSqlType(const aType: TOraItemType): string;
begin
  case aType of
    OraProcedure:
      Result := 'PROCEDURE';
    OraFunction:
      Result := 'FUNCTION';
    OraPackage:
      Result := 'PACKAGE'
    else
      Result := 'PROCEDURE';
  end;
end;

class function TOraItem.GetItemType(const aType: string): TOraItemType;
begin
  Result := OraProcedure;
  if aType = 'FUNCTION' then
    Result := OraFunction
  else if aType = 'PACKAGE' then
    Result := OraPackage;
end;

procedure TOraItem.SetBody(const Value: WideString);
begin
  FBody := Value;
  FHash := MurmurHash2(FBody);
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TOraItem.SetName(const Value: string);
begin
  FName := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TOraItem.SetSchemeId(const Value: integer);
begin
  FSchemeId := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TOraItem.SetBaseId(const Value: integer);
begin
  FBaseId := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TOraItem.SetType(const Value: TOraItemType);
begin
  FType := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TOraItem.UpdateStatus;
var
  iScheme: TOraScheme;
begin
  try
    try
      Screen.Cursor := crSQLWait;
      iScheme := TORDESYProjectList
        (TORDESYProject(TORDESYModule(ModuleRef).ProjectRef).ProjectListRef)
        .GetOraSchemeById(SchemeId);
      if not Assigned(iScheme) then
        raise Exception.Create(
          Format('Error while connecting throw item scheme. SchemeId = %u', [SchemeId]));
      if not iScheme.Connected then
        iScheme.Connect(BaseId);
      with iScheme.Connection.Query do
      begin
        Active := false;
        SQL.Text :=
          Format('select created, last_ddl_time, status from sys.all_objects where owner = user and object_name not like ''%s'' and subobject_name is null and object_type = ''%s'' and object_name = ''%s''', ['BIN$%', TOraItem.GetItemSqlType(ItemType), FName]);
        Active := true;
        if RecordCount = 0 then
          raise Exception.Create(
            'The item not deployed yet or deleted manually. Can''t get status.')
        else
        begin
          First;
          if Fields[2].AsString = 'VALID' then
          begin
            if FValid <> true then
            begin
              FValid := true;
              if Assigned(FOnChange) then
                OnChange(Self);
            end;
          end
          else
          begin
            if FValid <> false then
            begin            
              FValid := false;
              if Assigned(FOnChange) then
                OnChange(Self);
            end;
          end;
        end;
      end;      
    finally
      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'UpdateStatus', E.Message]);
  end;
end;

(* function TOraItem.SaveToProject(var aProject: TORDESYProject): boolean;
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
  end; *)

(* function TOraItem.Wrap(var aProject: TORDESYProject): boolean;
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
  end; *)

procedure TOraBase.SetName(const Value: string);
begin
  FName := Value;
  if Assigned(FOnChange) then
    FOnChange(Self);
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
  FProjects[ high(FProjects)] := aProject;
  FSaved := false;
  if Assigned(FOnProjectAdd) then
    OnProjectAdd(Self);
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYProjectList.Clear;
var
  i: integer;
begin
  for i := 0 to high(FProjects) do
    FProjects[i].Free;
  SetLength(FProjects, 0);
  FSaved := false;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

constructor TORDESYProjectList.Create;
begin
  inherited Create;
  OnChange := OnProjectListChange;
end;

destructor TORDESYProjectList.Destroy;
var
  i: integer;
begin
  for i := 0 to High(FProjects) do
    FProjects[i].Free;
  SetLength(FProjects, 0);

  for i := 0 to high(FOraSchemes) do
    FOraSchemes[i].Free;
  SetLength(FOraSchemes, 0);

  for i := 0 to high(FOraBases) do
    FOraBases[i].Free;
  SetLength(FOraBases, 0);

  inherited;
end;

function TORDESYProjectList.GetFreeProjectId: integer;
var
  i, NewId: integer;
label Restart;
begin
  NewId := 0;
Restart :
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = NewId then
    begin
      inc(NewId);
      goto Restart;
    end;
  end;
  Result := NewId;
end;

function TORDESYProjectList.GetProjectById(const aId: integer): TORDESYProject;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FProjects) do
  begin
    if FProjects[i].Id = aId then
    begin
      Result := FProjects[i];
      Exit;
    end;
  end;
end;

function TORDESYProjectList.GetProjectByIndex(const aIndex: integer)
  : TORDESYProject;
begin
  Result := nil;
  if (aIndex >= 0) and (aIndex <= high(FProjects)) then
    Result := FProjects[aIndex]
  else
    raise Exception.Create('Incorrect project index. Max value is: ' + IntToStr
        ( high(FProjects)));
end;

function TORDESYProjectList.GetProjectsCount: integer;
begin
  Result := length(FProjects);
end;

function TORDESYProjectList.LoadFromFile(const aFileName: string): boolean;
var
  iHandle: integer;
  iP, iM, iB, iSc, Ii, iId, ModuleId, BaseId, SchemeId,
    iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;  
  iFileHeader, iFileVersion,
    iName, iDescription, iCreator, iLogin, iPass, iBody: String;
  iIntItemType: integer;
  iDateCreate: TDateTime;
  IItemValid: boolean;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
begin
  Result := false;
  try
    if not FileExists(aFileName) then
    begin
      Result := true;
      Exit;
    end;
    Clear;
    try
      iHandle := FileOpen(aFileName, fmOpenRead);
      if iHandle = -1 then
        raise Exception.Create(SysErrorMessage(GetLastError));
      FileReadString(iHandle, iFileHeader);
      FileReadString(iHandle, iFileVersion);
      if (iFileHeader <> ORDESYNAME) or (iFileVersion <> ORDESYVERSION) then
        raise Exception.Create
          ('Incorrect project version! Need: ' + ORDESYNAME + ' ' +
            ORDESYVERSION);
      FileReadInteger(iHandle, iProjectCount); // PROJECT COUNT
      for iP := 0 to iProjectCount - 1 do
      begin
        FileReadInteger(iHandle, iId);          // Id
        FileReadString(iHandle, iName);         // Name
        FileReadString(iHandle, iDescription);  // Desc
        FileReadString(iHandle, iCreator);      // Creator
        FileReadDateTime(iHandle, iDateCreate); // Datecreate
        // Creating project
        iProject := TORDESYProject.Create(Self ,iId, iName, iDescription, iCreator,
          iDateCreate);
        iProject.OnChange := OnChange;
        // --- MODULES
        FileReadInteger(iHandle, iModuleCount); // MODULE COUNT
        for iM := 0 to iModuleCount - 1 do
        begin
          FileReadInteger(iHandle, iId);         // Id
          FileReadString(iHandle, iName);        // Name
          FileReadString(iHandle, iDescription); // Desc
          // Adding
          iModule := TORDESYModule.Create(iProject, iId, iName, iDescription);
          iModule.OnChange:= OnChange;
          iProject.AddModule(iModule);
          // --- ITEMS
          FileReadInteger(iHandle, iItemCount); // ITEM COUNT
          for Ii := 0 to iItemCount - 1 do
          begin
            FileReadInteger(iHandle, iId);          // Id
            FileReadInteger(iHandle, BaseId);       // BaseId
            FileReadInteger(iHandle, SchemeId);     // ShemeId
            FileReadString(iHandle, iName);         // Name
            FileReadInteger(iHandle, iIntItemType); // Type
            FileReadBoolean(iHandle, IItemValid);   // Valid
            FileReadString(iHandle, iBody);         // Body
            // Adding
            iItem:= TOraItem.Create(iModule, iId, BaseId, SchemeId,
                iName, iBody, TOraItemType(iIntItemType), IItemValid);
            iItem.OnChange:= OnChange;
            iModule.AddOraItem(iItem);
          end;
        end;
        AddProject(iProject); // ADD PROJECT
      end;
      // --- BASES
      FileReadInteger(iHandle, iBaseCount); // BASE COUNT
      for iB := 0 to iBaseCount - 1 do
      begin
        FileReadInteger(iHandle, iId);  // Id
        FileReadString(iHandle, iName); // Name
        // Adding
        iBase:= TOraBase.Create(Self, iId, iName);
        iBase.OnChange:= OnChange;
        AddOraBase(iBase);
      end;
      // --- SCHEMES
      FileReadInteger(iHandle, iSchemeCount); // SCHEME COUNT
      for iSc := 0 to iSchemeCount - 1 do
      begin
        FileReadInteger(iHandle, iId);   // Id
        FileReadString(iHandle, iLogin); // Login
        FileReadString(iHandle, iPass);  // Pass
        // Adding
        iScheme:= TOraScheme.Create(Self, iId, iLogin, iPass);
        iScheme.OnChange:= OnChange;
        AddOraScheme(iScheme);
      end;
      FSaved := true;
      Result := true;
    finally
      FileClose(iHandle);
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'LoadFromFile', E.Message]);
  end;
end;

procedure TORDESYProjectList.OnProjectListChange(Sender: TObject);
begin
  FSaved := false;
end;

function TORDESYProjectList.RemoveBaseById(const aId: integer): Boolean;
var
  i: integer;
begin
  Result:= false;
  try
    for i := 0 to OraBaseCount - 1 do
    begin
      if FOraBases[i].Id = aId then
      begin
        FOraBases[i].Free;
        FOraBases[i]:= FOraBases[ high(FOraBases)];
        SetLength(FOraBases, length(FOraBases) - 1);
        FSaved := false;
        if Assigned(FOnBaseRemove) then
          OnBaseRemove(Self);
        if Assigned(FOnChange) then
          OnChange(Self);
        Result:= true;
        Exit;
      end;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveBaseById', E.Message]);
  end;
end;

function TORDESYProjectList.RemoveBaseByIndex(const aIndex: integer): boolean;
begin
  Result:= false;
  try
    if (aIndex >= 0) and (aIndex < OraBaseCount) then
    begin
      FOraBases[aIndex].Free;
      FOraBases[aIndex]:= FOraBases[ high(FOraBases)];
      SetLength(FOraBases, length(FOraBases) - 1);
      FSaved := false;
      if Assigned(FOnBaseRemove) then
        OnBaseRemove(Self);
      if Assigned(FOnChange) then
        OnChange(Self);
      Result:= true;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveBaseByIndex', E.Message]);
  end;
end;

function TORDESYProjectList.RemoveProjectById(const aId: integer): boolean;
var
  i: integer;
begin
  Result:= false;
  try
    for i := 0 to ProjectCount - 1 do
    begin
      if FProjects[i].Id = aId then
      begin
        FProjects[i].Free;
        FProjects[i]:= FProjects[ high(FProjects)];
        SetLength(FProjects, length(FProjects) - 1);
        FSaved := false;
        if Assigned(FOnProjectRemove) then
          OnProjectRemove(Self);
        if Assigned(FOnChange) then
          OnChange(Self);
        Result:= true;
        Exit;
      end;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveProjectById', E.Message]);
  end;
end;

function TORDESYProjectList.RemoveProjectByIndex(
  const aIndex: integer): boolean;
begin
  Result:= false;
  try
    if (aIndex >= 0) and (aIndex < ProjectCount) then
    begin
      FProjects[aIndex].Free;
      FProjects[aIndex]:= FProjects[ high(FProjects)];
      SetLength(FProjects, length(FProjects) - 1);
      FSaved := false;
      if Assigned(FOnProjectRemove) then
        OnProjectRemove(Self);
      if Assigned(FOnChange) then
        OnChange(Self);
      Result:= true;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveProjectByIndex', E.Message]);
  end;
end;

function TORDESYProjectList.RemoveSchemeById(const aId: integer): Boolean;
var
  i: integer;
begin
  Result:= false;
  try
    for i := 0 to OraSchemeCount - 1 do
      if FOraSchemes[i].Id = aId then
      begin
        FOraSchemes[i].Free;
        FOraSchemes[i]:= FOraSchemes[ high(FOraSchemes)];
        SetLength(FOraSchemes, length(FOraSchemes) - 1);
        FSaved := false;
        if Assigned(FOnSchemeRemove) then
          OnSchemeRemove(Self);
        if Assigned(FOnChange) then
          OnChange(Self);
        Result:= true;
        Exit;
      end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveSchemeById', E.Message]);
  end;
end;

function TORDESYProjectList.RemoveSchemeByIndex(const aIndex: integer): boolean;
begin
  Result:= false;
  try
    if (aIndex >= 0) and (aIndex < OraSchemeCount) then
    begin
      FOraSchemes[aIndex].Free;
      FOraSchemes[aIndex]:= FOraSchemes[ high(FOraSchemes)];
      SetLength(FOraSchemes, length(FOraSchemes) - 1);
      FSaved := false;
      if Assigned(FOnSchemeRemove) then
        OnSchemeRemove(Self);
      if Assigned(FOnChange) then
        OnChange(Self);
      Result:= true;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'RemoveSchemeByIndex', E.Message]);
  end;
end;

function TORDESYProjectList.SaveToFile(const aFileName: string): boolean;
var
  iP, iM, iB, iSc, Ii, charSize, strSize, i: integer;
  iHandle: integer;
  iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
begin
  Result := false;
  FSaved := false;
  try
    try
      charSize := SizeOf(Char);
      iHandle := FileCreate(aFileName);
      FileWriteString(iHandle, ORDESYNAME);
      FileWriteString(iHandle, ORDESYVERSION);
      // --- PROJECTS
      iProjectCount := ProjectCount;
      FileWriteInteger(iHandle, iProjectCount);
      for iP := 0 to iProjectCount - 1 do
      begin
        iProject := GetProjectByIndex(iP);
        FileWriteInteger(iHandle, iProject.Id);          // Id
        FileWriteString(iHandle, iProject.Name);         // Name
        FileWriteString(iHandle, iProject.Description);  // Desc
        FileWriteString(iHandle, iProject.Creator);      // Creator
        FileWriteDateTime(iHandle, iProject.DateCreate); // Datecreate
        // --- MODULES
        iModuleCount := iProject.ModuleCount;
        FileWriteInteger(iHandle, iModuleCount);
        for iM := 0 to iModuleCount - 1 do
        begin
          iModule := iProject.GetModuleByIndex(iM);
          FileWriteInteger(iHandle, iModule.Id);          // Id
          FileWriteString(iHandle, iModule.Name);         // Name
          FileWriteString(iHandle, iModule.Description);  // Desc
          // --- ITEMS
          iItemCount := iModule.OraItemCount;
          FileWriteInteger(iHandle, iItemCount);
          for Ii := 0 to iItemCount - 1 do
          begin
            iItem := iModule.GetOraItemByIndex(Ii);
            FileWriteInteger(iHandle, iItem.Id);        // Id
            FileWriteInteger(iHandle, iItem.BaseId);    // BaseId
            FileWriteInteger(iHandle, iItem.SchemeId);  // SchemeId
            FileWriteString(iHandle, iItem.Name);       // Name
            FileWriteInteger(iHandle, integer(iItem.ItemType)); // Type
            FileWriteBoolean(iHandle, iItem.Valid);     // Valid
            FileWriteString(iHandle, iItem.ItemBody);   // Body
          end;
        end;
      end;
      // --- BASES
      iBaseCount := OraBaseCount;
      FileWriteInteger(iHandle, iBaseCount);
      for iB := 0 to iBaseCount - 1 do
      begin
        iBase := GetOraBaseByIndex(iB);
        FileWriteInteger(iHandle, iBase.Id);  // Id
        FileWriteString(iHandle, iBase.Name); // Name
      end;
      // --- SCHEMES
      iSchemeCount := OraSchemeCount;
      FileWriteInteger(iHandle, iSchemeCount);
      for iSc := 0 to iSchemeCount - 1 do
      begin
        iScheme := GetOraSchemeByIndex(iSc);
        FileWriteInteger(iHandle, iScheme.Id);   // Id
        FileWriteString(iHandle, iScheme.Login); // Login
        FileWriteString(iHandle, iScheme.Pass);  // Pass
      end;
      FSaved := true;
      Result := true;
    finally
      FileClose(iHandle);
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'SaveToFile', E.Message]);
  end;
end;

{ TORDESYModule }

constructor TORDESYModule.Create(aProjectRef: Pointer; const aId: integer;
  const aName: string = 'New Module'; const aDescription: WideString = '');
begin
  inherited Create;
  FId := aId;
  FName := aName;
  FDescription := aDescription;
  FProjectRef := aProjectRef;
end;

destructor TORDESYModule.Destroy;
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
    FOraItems[i].Free;
  SetLength(FOraItems, 0);
  inherited;
end;

procedure TORDESYModule.SetDescription(const Value: WideString);
begin
  FDescription := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYModule.SetName(const Value: string);
begin
  FName := Value;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

end.
