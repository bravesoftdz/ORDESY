unit uLazyTreeState;

interface

uses
  // ORDESY Modules
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  // Delphi Modules
  SysUtils, Windows, Forms, ComCtrls;

const
  TREESTATENAME = 'LAZY TREE STATE';
  TREESTATEVERSION = '1.0';
  
  
type
  TLazyTreeState = record
    ParentName: string;
    CurrentName: string;
    Expanded: string;
    Procedure Clear;
  end;

  TLazyStateList = class
    FLazyList: array of TLazyTreeState;
    FSaved: boolean;
    FUpdating: boolean;
    FCount: integer;
  private
    procedure GetNodeData(aNode: TTreeNode; var aPName, aCName, aExpanded: string);
    function AddState(const aPName, aCName, aExpanded: string): boolean;
    function SetNodeState(aNode: TTreeNode): boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function ShowContents: string;
    procedure ReadState(aList: TTreeView);
    procedure AppendState(aList: TTreeView);
    function SaveStateToFile(const aFileName: string = 'tree_state.data'): boolean;
    function LoadStateFromFile(const aFileName: string = 'tree_state.data'): boolean;
    property Saved: boolean read FSaved;
    property Count: integer read FCount;
  end;

implementation



{ TLazyStateList }

constructor TLazyStateList.Create;
begin
  FSaved:= false;
  FUpdating:= false;
end;

destructor TLazyStateList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TLazyStateList.Clear;
var
  i: integer;
begin
  for i := 0 to high(FLazyList) do
    FLazyList[i].Clear;
  SetLength(FLazyList, 0);
  FSaved:= false;
  FCount:= 0;
end;

procedure TLazyStateList.GetNodeData(aNode: TTreeNode; var aPName, aCName, aExpanded: string);
begin
  try
    if not Assigned(aNode) then
      Exit;
    aCName:= aNode.Text;
    aExpanded:= BoolToStr(aNode.Expanded, true);
    if Assigned(aNode.Parent) then
      aPName:= aNode.Parent.Text
    else
      aPName:= '';
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | GetNodeData | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | GetNodeData | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TLazyStateList.AddState(const aPName, aCName, aExpanded: string): boolean;
begin
  Result:= false;
  try
    SetLength(FLazyList, length(FLazyList) + 1);
    FLazyList[High(FLazyList)].ParentName:= aPName;
    FLazyList[High(FLazyList)].CurrentName:= aCName;
    FLazyList[High(FLazyList)].Expanded:= aExpanded;
    FSaved:= false;
    FCount:= Length(FLazyList);
    Result:= true;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | AddState | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | AddState | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TLazyStateList.SetNodeState(aNode: TTreeNode): boolean;
var
  i: integer;
  ParentName: string;
begin
  Result:= false;
  try
    for i := 0 to high(FLazyList) do
    begin
      if Assigned(aNode.Parent) then
        ParentName:= aNode.Parent.Text
      else
        ParentName:= '';
      if (FLazyList[i].ParentName = ParentName) and (FLazyList[i].CurrentName = aNode.Text) then
      begin
        if FLazyList[i].Expanded = 'True' then
          aNode.Expanded:= true
        else
          aNode.Expanded:= false;
      end;
    end;
    Result:= true;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | SetNodeState | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | SetNodeState | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TLazyStateList.ShowContents: string;
var
  i: integer;
begin
  for i := 0 to high(FLazyList) do
    Result:= Result + FLazyList[i].ParentName + '|' + FLazyList[i].CurrentName + '|' + FLazyList[i].Expanded + #13#10;
end;

procedure TLazyStateList.ReadState(aList: TTreeView);
var
  i: integer;
  iPName, iCName, iExpanded: string;
begin
  if FUpdating then
    Exit;
  try
    Clear;
    for i := 0 to aList.Items.Count - 1 do
    begin
      GetNodeData(aList.Items[i], iPName, iCName, iExpanded);
      AddState(iPName, iCName, iExpanded);
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | ReadState | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | ReadState | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TLazyStateList.AppendState(aList: TTreeView);
var
  i: integer;
begin
  try
    aList.Items.BeginUpdate;
    FUpdating:= true;
    for i := 0 to aList.Items.Count - 1 do
      SetNodeState(aList.Items[i]);
    FUpdating:= false;
    aList.Items.EndUpdate;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | AppendState | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | AppendState | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TLazyStateList.LoadStateFromFile(const aFileName: string): boolean;
var
  iHandle: integer;
  charSize, iCount, i, strSize: integer;
  iFileHeader, iFileVersion, ParentName, CurrentName, Expanded: string;
begin
  Result:= false;
  if not FileExists(aFileName) then
  begin
    Result := true;
    Exit;
  end;
  try 
    try   
      Clear;
      iHandle := FileOpen(aFileName, fmOpenRead);
      if iHandle = -1 then
        raise Exception.Create(SysErrorMessage(GetLastError));
      charSize := SizeOf(Char);
      SetLength(iFileHeader, length(TREESTATENAME));
      SetLength(iFileVersion, length(TREESTATEVERSION));
      FileRead(iHandle, iFileHeader[1], length(TREESTATENAME) * charSize);
      // Reading header
      FileRead(iHandle, iFileVersion[1], length(TREESTATEVERSION) * charSize);
      // Reading version      
      if (iFileHeader <> TREESTATENAME) or (iFileVersion <> TREESTATEVERSION) then
        raise Exception.Create('Incorrect version! Need: ' + TREESTATENAME + ' ' + TREESTATEVERSION);
      SetLength(iFileHeader, 0);
      SetLength(iFileVersion, 0);
      FileRead(iHandle, iCount, SizeOf(iCount)); // Count
      //
      for i := 0 to iCount - 1 do
      begin
        // ParentName
        FileRead(iHandle, strSize, SizeOf(strSize)); // Name length
        SetLength(ParentName, strSize);
        FileRead(iHandle, ParentName[1], strSize * charSize); // Getting Name
        // CurrentName
        FileRead(iHandle, strSize, SizeOf(strSize)); // Name length
        SetLength(CurrentName, strSize);
        FileRead(iHandle, CurrentName[1], strSize * charSize); // Getting Name
        // Expanded
        FileRead(iHandle, strSize, SizeOf(strSize)); // Expanded length
        SetLength(Expanded, strSize);
        FileRead(iHandle, Expanded[1], strSize * charSize);
        //
        AddState(ParentName, CurrentName, Expanded);
        //
        SetLength(ParentName, 0);
        SetLength(CurrentName, 0);
        SetLength(Expanded, 0);
      end;
      FSaved:= true;
      Result:= true;
    except
      on E: Exception do
      begin
        {$IFDEF Debug}
        AddToLog(ClassName + ' | LoadStateFromFile | ' + E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | LoadStateFromFile | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      end;
    end;
  finally
    FileClose(iHandle);
  end;
end;

function TLazyStateList.SaveStateToFile(const aFileName: string): boolean;
var
  iHandle: integer;
  charSize, iCount, i, strSize: integer;
begin
  Result:= false;
  try
    try
      iHandle := FileCreate(aFileName);
      charSize := SizeOf(Char);
      FileWrite(iHandle, TREESTATENAME[1], length(TREESTATENAME) * charSize);
      FileWrite(iHandle, TREESTATEVERSION[1], length(TREESTATEVERSION) * charSize);
      // Count
      iCount:= FCount;
      FileWrite(iHandle, iCount, SizeOf(iCount));
      for i := 0 to iCount - 1 do
      begin
        strSize := length(FLazyList[i].ParentName);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // ParentName length
        FileWrite(iHandle, FLazyList[i].ParentName[1], strSize * charSize); // ParentName
        //
        strSize := length(FLazyList[i].CurrentName);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // CurrentName length
        FileWrite(iHandle, FLazyList[i].CurrentName[1], strSize * charSize); // CurrentName
        //
        strSize := length(FLazyList[i].Expanded);
        FileWrite(iHandle, strSize, SizeOf(strSize)); // Expanded length
        FileWrite(iHandle, FLazyList[i].Expanded[1], strSize * charSize); // Expanded
      end;
      FSaved:= true;
      Result:= true;    
    except
      on E: Exception do
      begin
        {$IFDEF Debug}
        AddToLog(ClassName + ' | SaveStateToFile | ' + E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | SaveStateToFile | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      end;
    end;
  finally
    FileClose(iHandle);
  end;
end;



{ TLazyTreeState }

procedure TLazyTreeState.Clear;
begin
  Self:= default(TLazyTreeState);
end;

end.
