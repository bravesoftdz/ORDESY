{
Oracle Deploy System ver.1.0 (ORDESY)
by Volodymyr Sedler aka scribe
2016

Desc: wrap/deploy/save objects of oracle database.
No warranty of using this program.
Just Free.

With bugs, suggestions please write to justscribe@yahoo.com
On Github: github.com/justscribe/ORDESY

Module to save current expand state of TTreeView after update.

classes:
  TLazyTreeState - record of info about node state
  TLazyStateList - the list of LazyTreeState, saving/loading/reading/appending states.
}
unit uLazyTreeState;

interface

uses
  // ORDESY Modules
  uErrorHandle, uFileRWTypes,
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
  protected
    function ShowContents: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
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
      HandleError([ClassName, 'GetNodeData', E.Message]);
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
      HandleError([ClassName, 'AddState', E.Message]);
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
      HandleError([ClassName, 'SetNodeState', E.Message]);
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
      HandleError([ClassName, 'ReadState', E.Message]);
  end;
end;

procedure TLazyStateList.AppendState(aList: TTreeView);
var
  i: integer;
begin
  try
    try
      aList.Items.BeginUpdate;
      FUpdating:= true;
      for i := 0 to aList.Items.Count - 1 do
        SetNodeState(aList.Items[i]);
      FUpdating:= false;
    finally
      aList.Items.EndUpdate;
    end;
  except
    on E: Exception do
      HandleError([ClassName, 'AppendState', E.Message]);
  end;
end;

function TLazyStateList.LoadStateFromFile(const aFileName: string): boolean;
var
  iHandle, iCount, i: integer;
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
      FileReadString(iHandle, iFileHeader);  // Name
      FileReadString(iHandle, iFileVersion); // Version
      if (iFileHeader <> TREESTATENAME) or (iFileVersion <> TREESTATEVERSION) then
        raise Exception.Create(Format('Incorrect version! Need: %s:%s', [TREESTATENAME, TREESTATEVERSION]));
      FileReadInteger(iHandle, iCount); // Count
      for i := 0 to iCount - 1 do
      begin
        FileReadString(iHandle, ParentName);  // ParentName
        FileReadString(iHandle, CurrentName); // CurrentName
        FileReadString(iHandle, Expanded);    // Expanded
        AddState(ParentName, CurrentName, Expanded);
      end;
      FSaved:= true;
      Result:= true;
    except
      on E: Exception do
        HandleError([ClassName, 'LoadStateFromFile', E.Message]);
    end;
  finally
    FileClose(iHandle);
  end;
end;

function TLazyStateList.SaveStateToFile(const aFileName: string): boolean;
var
  iHandle, iCount, i: integer;
begin
  Result:= false;
  try
    try
      iHandle := FileCreate(aFileName);
      FileWriteString(iHandle, TREESTATENAME);    // Name
      FileWriteString(iHandle, TREESTATEVERSION); // Version
      iCount:= FCount;
      FileWrite(iHandle, iCount, SizeOf(iCount));
      for i := 0 to iCount - 1 do
      begin
        FileWriteString(iHandle, FLazyList[i].ParentName);  // ParentName
        FileWriteString(iHandle, FLazyList[i].CurrentName); // CurrentName
        FileWriteString(iHandle, FLazyList[i].Expanded);    // Expanded
      end;
      FSaved:= true;
      Result:= true;    
    except
      on E: Exception do
        HandleError([ClassName, 'SaveStateToFile', E.Message]);
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
