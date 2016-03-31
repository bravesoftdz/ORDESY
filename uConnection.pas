unit uConnection;

interface

uses SysUtils, ADODB, Classes, Dialogs, Windows;

const
  connstrORA =
    'Provider=MSDAORA.1;Password=%s;User ID=%s;Data Source=%s;Persist Security Info=True';
  connstrMS =
    //'Provider=SQLOLEDB.1;Password=%s;User ID=%s;Data Source=%s;Initial Catalog=IFRS;';
    //'Provider=SQLNCLI10;Password=%s;User ID=%s;Data Source=%s;Initial Catalog=IFRS;';
    'Provider=MSDASQL.1;Password=%s;User ID=%s;Data Source=%s;Persist Security Info=False';

type
  TConnection = class
  strict private
    FConn: TADOConnection;
    FConnected: boolean;
    FLastError: string;
    FOnChangeStatus: TNotifyEvent;
    procedure SetConnected(const aValue: boolean);
    procedure SetChangeStatus(aValue: TNotifyEvent);
  public
    Query: TADOQuery;
    constructor Create(const aServer, aUser, aPass: string;
      const aConnStr: string = connstrMS);
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    property Connected: boolean read FConnected write SetConnected;
    property LastError: string read FLastError;
    property OnChangeStatus: TNotifyEvent read FOnChangeStatus write SetChangeStatus;
  end;

implementation

{ TURConnection }

procedure TConnection.Connect;
begin
  try
    FConn.Connected := true;
    FConnected := FConn.Connected;
    FOnChangeStatus(Self);
  except
    on E: Exception do
    begin
      FLastError := E.Message;
    end;
  end;
end;

constructor TConnection.Create(const aServer, aUser, aPass, aConnStr: string);
begin
  inherited Create;
  try
    FConn := TADOConnection.Create(nil);
    FConn.ConnectionString := Format(aConnStr, [aPass, aUser, aServer]);
    FConn.LoginPrompt := false;
    Query := TADOQuery.Create(nil);
    Query.Connection := FConn;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
    end;
  end;
end;

destructor TConnection.Destroy;
begin
  Query.Close;
  FConn.Close;
  Query.Free;
  FConn.Free;
  inherited;
end;

procedure TConnection.Disconnect;
begin
  try
    FConn.Connected := false;
    FConnected := FConn.Connected;
    FOnChangeStatus(Self);
  except
    on E: Exception do
    begin
      FLastError := E.Message;
    end;
  end;
end;

procedure TConnection.SetChangeStatus(aValue: TNotifyEvent);
begin
  FOnChangeStatus := aValue;
end;

procedure TConnection.SetConnected(const aValue: boolean);
begin
  try
    FConn.Connected := aValue;
    FConnected := FConn.Connected;
    FOnChangeStatus(Self);
  except
    on E: Exception do
    begin
      FConn.Connected := false;
      FConnected := FConn.Connected;
      FLastError:= E.Message;
    end;
  end;
end;

end.
