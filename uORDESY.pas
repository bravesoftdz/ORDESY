unit uORDESY;

interface

uses
  // ORDESY Modules
{$IFDEF Debug}
  uLog,
{$ENDIF}
  uExplode, uConnection, uShellFuncs, uHash,
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
  TPORDESYProject = ^TORDESYProject;

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
    FHash: integer;
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
    property Hash: integer read FHash;
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
    function GetOraItemName(const aIndex: integer): string;
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
    constructor Create(const aId: integer; const aName: string = 'New Project';
      const aDescription: string = 'About new project...';
      const aCreator: string = 'nobody'; const aDateCreate: TDateTime = 0);
    destructor Destroy; override;
    // Module
    function GetFreeModuleId: integer;
    procedure AddModule(aModule: TORDESYModule);
    function GetModuleById(const aId: integer): TORDESYModule;
    function GetModuleByIndex(const aIndex: integer): TORDESYModule;
    function GetModuleName(const aIndex: integer): string;
    function RemoveModuleById(const aId: integer): boolean;
    // WRAP DEPLOY!
    procedure WrapItem(const aModuleId, aBaseId, aSchemeId: integer;
      const aName: string; const aType: TOraItemType);
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
    procedure AddOraBase(aBase: TOraBase);
    function GetOraBaseById(const aId: integer): TOraBase;
    function GetOraBaseByIndex(const aIndex: integer): TOraBase;
    function GetOraBaseName(const aIndex: integer): string;
    function RemoveBaseById(const aId: integer): Boolean;
    function RemoveBaseByIndex(const aIndex: integer): boolean;
    // Scheme
    procedure AddOraScheme(aScheme: TOraScheme);
    function GetOraSchemeById(const aId: integer): TOraScheme;
    function GetOraSchemeByIndex(const aIndex: integer): TOraScheme;
    function GetOraSchemeLogin(const aIndex: integer): string;
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
  FHash := MurmurHash2(PAnsiChar(FBody));
  FSchemeId := aSchemeId;
  FBaseId := aBaseId;
  FModuleRef := aModuleRef;
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
  FORDESYModules[ high(FORDESYModules)] := aModule;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYProjectList.AddOraBase(aBase: TOraBase);
var
  i: integer;
begin
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].Id = aBase.Id then
      Exit;
  end;
  SetLength(FOraBases, length(FOraBases) + 1);
  FOraBases[ high(FOraBases)] := aBase;
  if Assigned(FOnBaseAdd) then
    OnBaseAdd(Self);
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYModule.AddOraItem(aItem: TOraItem);
var
  i: integer;
begin
  for i := 0 to high(FOraItems) do
  begin
    if FOraItems[i].Id = aItem.Id then
      Exit;
  end;
  SetLength(FOraItems, length(FOraItems) + 1);
  FOraItems[ high(FOraItems)] := aItem;
  if Assigned(FOnChange) then
    OnChange(Self);
end;

procedure TORDESYProjectList.AddOraScheme(aScheme: TOraScheme);
var
  i: integer;
begin
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].Id = aScheme.Id then
      Exit;
  end;
  SetLength(FOraSchemes, length(FOraSchemes) + 1);
  FOraSchemes[ high(FOraSchemes)] := aScheme;
  if Assigned(FOnSchemeAdd) then
    OnSchemeAdd(Self);
  if Assigned(FOnChange) then
    OnChange(Self);
end;

constructor TORDESYProject.Create(const aId: integer; const aName: string;
  const aDescription: string; const aCreator: string;
  const aDateCreate: TDateTime);
begin
  inherited Create;
  FId := aId;
  FName := aName;
  FDescription := aDescription;
  FCreator := aCreator;
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

  inherited Destroy;
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
    if FORDESYModules[i].FId = aId then
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

function TORDESYProject.GetModuleName(const aIndex: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FORDESYModules) do
    if FORDESYModules[i].FId = aIndex then
      Result := FORDESYModules[i].Name;
end;

function TORDESYProject.RemoveModuleById(const aId: integer): boolean;
begin
  Result := false;
  try
    if GetModuleById(aId) <> nil then
    begin
      FORDESYModules[aId].Free;
      FORDESYModules[aId] := FORDESYModules[High(FORDESYModules)];
      SetLength(FORDESYModules, length(FORDESYModules) - 1);
      if Assigned(FOnChange) then
        OnChange(Self);
      Result:= true;
    end;
  except
    on E: Exception do
    begin
{$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveModuleById | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveModuleById | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ENDIF}
    end;
  end;
end;

function TORDESYProjectList.GetOraBaseById(const aId: integer): TOraBase;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FOraBases) do
  begin
    if FOraBases[i].FId = aId then
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
    raise Exception.Create('Incorrect base index. Max value is: ' + IntToStr
        ( high(FOraBases)));
end;

function TORDESYProjectList.GetOraBaseCount: integer;
begin
  Result := length(FOraBases);
end;

function TORDESYProjectList.GetOraBaseName(const aIndex: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FOraBases) do
    if FOraBases[i].FId = aIndex then
      Result := FOraBases[i].Name;
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
    raise Exception.Create('Incorrect item index. Max value is: ' + IntToStr
        ( high(FOraItems)));
end;

function TORDESYModule.GetOraItemCount: integer;
begin
  Result := length(FOraItems);
end;

function TORDESYModule.GetOraItemName(const aIndex: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FOraItems) do
    if FOraItems[i].FId = aIndex then
      Result := FOraItems[i].Name;
end;

function TORDESYProjectList.GetOraSchemeById(const aId: integer): TOraScheme;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to high(FOraSchemes) do
  begin
    if FOraSchemes[i].FId = aId then
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
    raise Exception.Create('Incorrect scheme index. Max value is: ' + IntToStr
        ( high(FOraSchemes)));
end;

function TORDESYProjectList.GetOraSchemeCount: integer;
begin
  Result := length(FOraSchemes);
end;

function TORDESYProjectList.GetOraSchemeLogin(const aIndex: integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to high(FOraSchemes) do
    if FOraSchemes[i].FId = aIndex then
      Result := FOraSchemes[i].Login;
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

procedure TORDESYProject.WrapItem(const aModuleId, aBaseId, aSchemeId: integer;
  const aName: string; const aType: TOraItemType);
var
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  firstItem: boolean;
  ItemBody: WideString;
begin
  try
    iScheme := TORDESYProjectList(FProjectListRef).GetOraSchemeById(aSchemeId);
    iModule := GetModuleById(aModuleId);
    iBase := TORDESYProjectList(FProjectListRef).GetOraBaseById(aBaseId);
    if (not Assigned(iScheme) or not Assigned(iModule) or not Assigned(iBase))
      then
      raise Exception.Create('Some of objects not created!');
    if not iScheme.Connected then
      iScheme.Connect(aBaseId);
    with iScheme.Connection do
    begin
      Query.Active := false;
      Query.SQL.Text :=
        'select text from sys.all_sources where ' + 'owner = ''' +
        iScheme.Login + '''' + 'name = ''' + Name + '''' + 'type = ''' +
        TOraItem.GetItemSqlType(aType) + ''' ' + 'order by line';
      Query.Active := true;
      firstItem := true;
      while not Query.Eof do
      begin
        if firstItem then
          ItemBody := ItemBody + 'CREATE OR REPLACE ' + Query.Fields[0]
            .AsString + #13#10;
        ItemBody := ItemBody + Query.Fields[0].AsString + #13#10;
        firstItem := false;
      end;
      iItem := TOraItem.Create(iModule, iModule.GetFreeItemId, aBaseId,
        aSchemeId, aName, ItemBody, aType);
      iModule.AddOraItem(iItem);
    end;
  except
    on E: Exception do
    begin
{$IFDEF Debug}
      AddToLog(ClassName + ' | WrapItem | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | WrapItem | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ENDIF}
    end;
  end;
end;

{ TOraScheme }

procedure TOraScheme.Connect(const BaseId: integer);
begin
  try
    if not Connected then
    begin
      if not Assigned(FConnection) then
        FConnection := TConnection.Create(TORDESYProjectList(FProjectListRef)
            .GetOraBaseName(BaseId), FLogin, FPass, connstrORA);
      FConnection.Connect;
      FConnected := FConnection.Connected;
      if FConnection.LastError <> '' then
        raise Exception.Create(FConnection.LastError);
    end;
  except
    on E: Exception do
    begin
      FConnected := false;
{$IFDEF Debug}
      AddToLog(ClassName + ' | Connect | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | Connect | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ENDIF}
    end;
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
  for i := 0 to High(FItemList) do
    FItemList[i].Free;
  SetLength(FItemList, 0);
  inherited Destroy;
end;

procedure TOraScheme.Disconnect;
begin
  if Assigned(FConnection) and (FConnected) then
    FConnection.Disconnect;
  FConnected := FConnection.Connected;
end;

procedure TOraScheme.GetItemList(const aItemType: TOraItemType;
  aList: TStrings);
begin
  try
    SetLength(FItemList, 0);
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
        'select object_name, status from sys.all_objects where owner = user and subobject_name is null and object_name not like ''BIN$%'' and object_type = ''' + TOraItem.GetItemSqlType(aItemType) + '''';
      Active := true;
      if RecordCount = 0 then
        raise Exception.Create('Error while getting items list.');
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
      end;
      aList.EndUpdate;
    end;
  except
    on E: Exception do
    begin
{$IFDEF Debug}
      AddToLog(ClassName + ' | GetItemList | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | GetItemList | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ENDIF}
    end;
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
  // FHash:= GetSimpleHash(PChar(FBody));
  FHash := MurmurHash2(PAnsiChar(FBody));
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
        (TORDESYProject(TORDESYModule(ModuleRef).ProjectRef).FProjectListRef)
        .GetOraSchemeById(SchemeId);
      if not Assigned(iScheme) then
        raise Exception.Create(
          'Error while connecting throw item scheme. SchemeId = ' + IntToStr
            (SchemeId));
      if not iScheme.Connected then
        iScheme.Connect(BaseId);
      with iScheme.Connection.Query do
      begin
        Active := false;
        SQL.Text :=
          'select created, last_ddl_time, status from sys.all_objects where owner = user and object_name not like ''BIN$%'' and subobjectname is null and object_type = ''' + TOraItem.GetItemSqlType(ItemType) + '''' + ' and objectname = ''' + Name + '''';
        Active := true;
        if RecordCount = 0 then
          raise Exception.Create(
            'The item not deployed yet or deleted manualy. Can''t get status.')
        else
        begin
          First;
          if Fields[2].ToString = 'VALID' then
            FValid := true
          else
            FValid := false;
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do
    begin
{$IFDEF Debug}
      AddToLog(ClassName + ' | UpdateStatus | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | UpdateStatus | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
{$ENDIF}
    end;
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
    FOnProjectAdd(Self);
end;

procedure TORDESYProjectList.Clear;
var
  i: integer;
begin
  for i := 0 to high(FProjects) do
    FProjects[i].Free;
  SetLength(FProjects, 0);
  FSaved := false;
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

  inherited Destroy;
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
      Result := FProjects[i];
  end;
end;

function TORDESYProjectList.GetProjectByIndex(const aIndex: integer)
  : TORDESYProject;
begin
  Result := nil;
  if (aIndex >= 0) and (aIndex <= high(FProjects)) then
    Result := FProjects[aIndex];
end;

function TORDESYProjectList.GetProjectsCount: integer;
begin
  Result := length(FProjects);
end;

function TORDESYProjectList.LoadFromFile(const aFileName: string): boolean;
var
  iHandle: integer;
  iP, iM, iB, iSc, Ii, iId, ModuleId, BaseId, SchemeId, charSize, strSize,
    NameSize, DescSize, CreatorSize, BodySize, LoginSize, PassSize,
    iProjectCount, iModuleCount, iBaseCount, iSchemeCount, iItemCount: integer;
  iItemType: TOraItemType;
  iFileHeader, iFileVersion, iName, iDescription, iCreator, iLogin, iPass,
    iBody: String;
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
      charSize := SizeOf(Char);
      SetLength(iFileHeader, length(ORDESYNAME));
      SetLength(iFileVersion, length(ORDESYVERSION));
      FileRead(iHandle, iFileHeader[1], length(ORDESYNAME) * charSize);
      // Reading header
      FileRead(iHandle, iFileVersion[1], length(ORDESYVERSION) * charSize);
      // Reading version
      // MessageBox(Application.Handle, PChar(iFileHeader + ' - ' + iFileVersion), PChar('warning'), 0);
      if (iFileHeader <> ORDESYNAME) or (iFileVersion <> ORDESYVERSION) then
        raise Exception.Create
          ('Incorrect project version! Need: ' + ORDESYNAME + ' ' +
            ORDESYVERSION);
      SetLength(iFileHeader, 0);
      SetLength(iFileVersion, 0);
      FileRead(iHandle, iProjectCount, SizeOf(iProjectCount)); // PROJECT COUNT
      for iP := 0 to iProjectCount - 1 do
      begin
        // Id
        FileRead(iHandle, iId, SizeOf(iId));
        // Name
        FileRead(iHandle, strSize, SizeOf(strSize)); // Name length
        SetLength(iName, strSize);
        FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
        // Desc
        FileRead(iHandle, strSize, SizeOf(strSize)); // Desc length
        SetLength(iDescription, strSize);
        FileRead(iHandle, iDescription[1], strSize * charSize); // Getting Desc
        // Creator
        FileRead(iHandle, strSize, SizeOf(strSize)); // Creator length
        SetLength(iCreator, strSize);
        FileRead(iHandle, iCreator[1], strSize * charSize); // Getting creator
        // Datecreate
        FileRead(iHandle, iDateCreate, SizeOf(iDateCreate));
        // Creating project
        iProject := TORDESYProject.Create(iId, iName, iDescription, iCreator,
          iDateCreate);
        iProject.OnChange := OnChange;
        // Free
        SetLength(iName, 0);
        SetLength(iDescription, 0);
        SetLength(iCreator, 0);
        // --- MODULES
        FileRead(iHandle, iModuleCount, SizeOf(iModuleCount)); // MODULE COUNT
        for iM := 0 to iModuleCount - 1 do
        begin
          // Id
          FileRead(iHandle, iId, SizeOf(iId));
          // Name
          FileRead(iHandle, strSize, SizeOf(strSize)); // Name length
          SetLength(iName, strSize);
          FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
          // Desc
          FileRead(iHandle, strSize, SizeOf(strSize)); // Desc length
          SetLength(iDescription, strSize);
          FileRead(iHandle, iDescription[1], strSize * charSize);
          // Getting Desc
          // Adding
          iModule := TORDESYModule.Create(iProject, iId, iName, iDescription);
          iProject.AddModule(iModule);
          // Free
          SetLength(iName, 0);
          SetLength(iDescription, 0);
          //
          // --- ITEMS
          FileRead(iHandle, iItemCount, SizeOf(iItemCount)); // ITEM COUNT
          // MessageBox(Application.Handle, PChar('item loaded count = ' + inttostr(iItemCount)), PChar('warning'), 0);
          for Ii := 0 to iItemCount - 1 do
          begin
            // Id
            FileRead(iHandle, iId, SizeOf(iId));
            // BaseId
            FileRead(iHandle, BaseId, SizeOf(BaseId));
            // ShemeId
            FileRead(iHandle, SchemeId, SizeOf(SchemeId));
            // Name
            FileRead(iHandle, strSize, SizeOf(strSize)); // Name length
            SetLength(iName, strSize);
            FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
            // Type
            FileRead(iHandle, iItemType, SizeOf(iItemType));
            // Valid
            FileRead(iHandle, IItemValid, SizeOf(IItemValid));
            // Body
            FileRead(iHandle, strSize, SizeOf(strSize)); // Body length
            SetLength(iBody, strSize);
            FileRead(iHandle, iBody[1], strSize * charSize); // Getting Name
            // Adding
            iModule.AddOraItem(TOraItem.Create(iModule, iId, BaseId, SchemeId,
                iName, iBody, iItemType, IItemValid));
            // Free
            SetLength(iName, 0);
            SetLength(iBody, 0);
          end;
        end;
        // ADD PROJECT
        AddProject(iProject);
      end;
      // --- BASES
      FileRead(iHandle, iBaseCount, SizeOf(iBaseCount)); // BASE COUNT
      // MessageBox(Application.Handle, PChar('base loaded count = ' + inttostr(iBaseCount)), PChar('warning'), 0);
      for iB := 0 to iBaseCount - 1 do
      begin
        // Id
        FileRead(iHandle, iId, SizeOf(iId));
        // Name
        FileRead(iHandle, strSize, SizeOf(strSize)); // Name length
        SetLength(iName, strSize);
        FileRead(iHandle, iName[1], strSize * charSize); // Getting Name
        // Adding
        AddOraBase(TOraBase.Create(Self, iId, iName));
        // Free
        SetLength(iName, 0);
      end;
      // --- SCHEMES
      FileRead(iHandle, iSchemeCount, SizeOf(iSchemeCount)); // SCHEME COUNT
      // MessageBox(Application.Handle, PChar('scheme loaded count = ' + inttostr(iSchemeCount)), PChar('warning'), 0);
      for iSc := 0 to iSchemeCount - 1 do
      begin
        // Id
        FileRead(iHandle, iId, SizeOf(iId));
        // Login
        FileRead(iHandle, strSize, SizeOf(strSize)); // Login length
        SetLength(iLogin, strSize);
        FileRead(iHandle, iLogin[1], strSize * charSize); // Getting Login
        // Pass
        FileRead(iHandle, strSize, SizeOf(strSize)); // Pass length
        SetLength(iPass, strSize);
        FileRead(iHandle, iPass[1], strSize * charSize); // Getting Login
        // Adding
        AddOraScheme(TOraScheme.Create(Self, iId, iLogin, iPass));
        // Free
        SetLength(iLogin, 0);
        SetLength(iPass, 0);
      end;
      FSaved := true;
      Result := true;
    finally
      FileClose(iHandle);
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | LoadFromFile | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | LoadFromFile | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
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
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveBaseById | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveBaseById | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
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
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveBaseByIndex | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveBaseByIndex | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TORDESYProjectList.RemoveProjectById(const aId: integer): boolean;
var
  iProject: TORDESYProject;
  i: integer;
begin
  Result:= false;
  try
    iProject:= GetProjectById(aId);
    if iProject <> nil then
    begin
      for i := 0 to ProjectCount - 1 do
      begin
        if FProjects[i] = iProject then
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
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveProjectById | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveProjectById | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
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
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveProjectByIndex | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveProjectByIndex | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TORDESYProjectList.RemoveSchemeById(const aId: integer): Boolean;
var
  iScheme: TOraScheme;
  i: integer;
begin
  Result:= false;
  try
    iScheme:= GetOraSchemeById(aId);
    if iScheme <> nil then
    begin
      for i := 0 to ProjectCount - 1 do
      begin
        if FOraSchemes[i] = iScheme then
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
      end;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveSchemeById | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveSchemeById | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
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
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | RemoveSchemeByIndex | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | RemoveSchemeByIndex | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
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
      FileWrite(iHandle, ORDESYNAME[1], length(ORDESYNAME) * charSize);
      FileWrite(iHandle, ORDESYVERSION[1], length(ORDESYVERSION) * charSize);
      // --- PROJECTS
      iProjectCount := ProjectCount;
      FileWrite(iHandle, iProjectCount, SizeOf(iProjectCount));
      for iP := 0 to iProjectCount - 1 do
      begin
        iProject := GetProjectByIndex(iP);
        // Id
        FileWrite(iHandle, iProject.Id, SizeOf(iProject.Id));
        // Name
        strSize := length(iProject.Name);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Name length
        FileWrite(iHandle, iProject.Name[1], strSize * charSize); // Name
        // Desc
        strSize := length(iProject.Description);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Desc length
        FileWrite(iHandle, iProject.Description[1], strSize * charSize); // Desc
        // Creator
        strSize := length(iProject.Creator);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Creator length
        FileWrite(iHandle, iProject.Creator[1], strSize * charSize); // Creator
        // Datecreate
        FileWrite(iHandle, iProject.DateCreate, SizeOf(iProject.DateCreate));
        // --- MODULES
        iModuleCount := iProject.ModuleCount;
        FileWrite(iHandle, iModuleCount, SizeOf(iModuleCount));
        for iM := 0 to iModuleCount - 1 do
        begin
          iModule := iProject.GetModuleByIndex(iM);
          // Id
          FileWrite(iHandle, iModule.Id, SizeOf(iModule.Id));
          // Name
          strSize := length(iModule.Name);
          FileWrite(iHandle, strSize, SizeOf(strSize)); // Name length
          FileWrite(iHandle, iModule.Name[1], strSize * charSize); // Name
          // Desc
          strSize := length(iModule.Description);
          FileWrite(iHandle, strSize, SizeOf(strSize)); // Desc length
          FileWrite(iHandle, iModule.Description[1], strSize * charSize);
          // Desc
          // --- ITEMS
          iItemCount := iModule.OraItemCount;
          FileWrite(iHandle, iItemCount, SizeOf(iItemCount));
          for Ii := 0 to iItemCount - 1 do
          begin
            iItem := iModule.GetOraItemByIndex(Ii);
            // Id
            FileWrite(iHandle, iItem.Id, SizeOf(iItem.Id));
            // BaseId
            FileWrite(iHandle, iItem.BaseId, SizeOf(iItem.BaseId));
            // SchemeId
            FileWrite(iHandle, iItem.SchemeId, SizeOf(iItem.SchemeId));
            // Name
            strSize := length(iItem.Name);
            FileWrite(iHandle, strSize, SizeOf(strSize)); // Name length
            FileWrite(iHandle, iItem.Name[1], strSize * charSize); // Name
            // Type
            FileWrite(iHandle, iItem.ItemType, SizeOf(iItem.ItemType));
            // Valid
            FileWrite(iHandle, iItem.Valid, SizeOf(iItem.Valid));
            // Body
            strSize := length(iItem.ItemBody);
            FileWrite(iHandle, strSize, SizeOf(strSize)); // Body length
            FileWrite(iHandle, iItem.ItemBody[1], strSize * charSize); // Body
          end;
        end;
      end;
      // --- BASES
      iBaseCount := OraBaseCount;
      FileWrite(iHandle, iBaseCount, SizeOf(iBaseCount));
      for iB := 0 to iBaseCount - 1 do
      begin
        iBase := GetOraBaseByIndex(iB);
        // Id
        FileWrite(iHandle, iBase.Id, SizeOf(iBase.Id));
        // Name
        strSize := length(iBase.Name);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Name length
        FileWrite(iHandle, iBase.Name[1], strSize * charSize); // Name
      end;
      // --- SCHEMES
      iSchemeCount := OraSchemeCount;
      FileWrite(iHandle, iSchemeCount, SizeOf(iSchemeCount));
      for iSc := 0 to iSchemeCount - 1 do
      begin
        iScheme := GetOraSchemeByIndex(iSc);
        // Id
        FileWrite(iHandle, iScheme.Id, SizeOf(iScheme.Id));
        // Login
        strSize := length(iScheme.Login);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Login length
        FileWrite(iHandle, iScheme.Login[1], strSize * charSize); // Login
        // Pass
        strSize := length(iScheme.Pass);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Pass length
        FileWrite(iHandle, iScheme.Pass[1], strSize * charSize); // Pass
      end;
      FSaved := true;
      Result := true;
    finally
      FileClose(iHandle);
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | SaveToFile | ' + E.Message);
      MessageBox(Application.Handle, PChar
          (ClassName + ' | SaveToFile | ' + E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar
          (Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
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

  inherited Destroy;
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
