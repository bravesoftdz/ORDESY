{

edt - TEdit
btn - TButton
pnl - TPanel
lbl - TLabel
gbx - TGroupBox
cbx - TComboBox
lbx - TListBox
spl - TSplitter
mmo - TMemo
tv - TTreeView
mm - TMainMenu
mi - TMenuItem
fm - TForm

}
unit uMain;

interface

uses
  // ORDESY Modules
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uORDESY, uExplode, uShellFuncs, uOptions, uWrap,
  uSchemeDialog, uBaseList, uSchemeList, uProjectDialogs, // Dialogs
  // Delphi Modules
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Buttons;

type
  TfmMain = class(TForm)
    tvMain: TTreeView;
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    pnlMain: TPanel;
    imlMain: TImageList;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlClient: TPanel;
    edtUserName: TEdit;
    lblUserName: TLabel;
    miProject: TMenuItem;
    miAddProject: TMenuItem;
    miOptions: TMenuItem;
    miShow: TMenuItem;
    miShowAll: TMenuItem;
    miScheme: TMenuItem;
    miAddScheme: TMenuItem;
    miSchemeList: TMenuItem;
    miEditProject: TMenuItem;
    miLast: TMenuItem;
    miAbout: TMenuItem;
    miHelp: TMenuItem;
    splMain: TSplitter;
    miBase: TMenuItem;
    miBaseList: TMenuItem;
    ppmMain: TPopupMenu;
    gbxInfo: TGroupBox;
    edName: TEdit;
    lblName: TLabel;
    lblDescription: TLabel;
    mmoDesc: TMemo;
    miSavechanges: TMenuItem;
    miModule: TMenuItem;
    miModuleList: TMenuItem;
    AddModule1: TMenuItem;
    miAddBase: TMenuItem;
    miItem: TMenuItem;
    miItemList: TMenuItem;
    miWrapItem: TMenuItem;
    miDeployItem: TMenuItem;
    procedure miExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure splMainMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ViewProjects(aTreeView: TTreeView);
    procedure ppmMainPopup(Sender: TObject);
    procedure AddProject(Sender: TObject);
    procedure EditProject(Sender: TObject);
    procedure DeleteProject(Sender: TObject);
    procedure WrapItem(Sender: TObject);
    procedure AddModule(Sender: TObject);
    procedure EditModule(Sender: TObject);
    procedure DeleteModule(Sender: TObject);
    procedure AddBase(Sender: TObject);
    procedure OnEditBase(Sender: TObject); // Edit base by ProjectList
    procedure EditBase(aBase: TOraBase); // Edit base by BaseList
    procedure DeleteBase(Sender: TObject);
    procedure AddScheme(Sender: TObject);
    procedure OnEditScheme(Sender: TObject); // Edit scheme by ProjectList
    procedure EditScheme(aScheme: TOraScheme); // Edit scheme by SchemeList
    procedure DeleteScheme(Sender: TObject);
    procedure tvMainClick(Sender: TObject);
    procedure miFileClick(Sender: TObject);
    procedure miSavechangesClick(Sender: TObject);
    procedure miBaseListClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure miSchemeListClick(Sender: TObject);
    procedure miAddSchemeClick(Sender: TObject);
  private
    AppOptions: TOptions;
    ProjectList: TORDESYProjectList;
    //procedure WMWindowPosChanged(var aMessage: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    function CanPopup(const aTag: integer; aObject: Pointer): boolean;
    procedure SaveFormSize(const aWidth, aHeight: integer);
    procedure PrepareGUI;
    procedure UpdateGUI;
    procedure PrepareOptions;
    procedure PrepareProjects;
  public
    procedure InitApp;
    procedure FreeApp(var Action: TCloseAction);
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.DeleteBase(Sender: TObject);
var
  reply: word;
  iSelected: TTreeNode;
  iObj: TObject;
begin
  try
    iSelected:= tvMain.Selected;
    iObj:= TObject(iSelected.Data);
    if not (iObj is TOraBase) and not (iObj is TOraScheme) then
      Exit;
    reply:= MessageBox(Handle, PChar('Delete base?' + #13#10 + 'Deleting base will affect on all projects.'), PChar('Confirm'), 36);
    if reply = IDYES then
    begin
      if iObj is TOraBase then
        ProjectList.RemoveBaseById(TOraBase(iObj).Id);
      if iObj is TOraScheme then
      begin
        if Assigned(iSelected.Parent) and (iSelected.Parent.Data <> nil) and (TObject(iSelected.Parent.Data) is TOraBase) then
          ProjectList.RemoveBaseById(TOraBase(iSelected.Parent.Data).Id);
      end;
      tvMain.Deselect(tvMain.Selected);
      tvMain.Selected.Data:= nil;
      UpdateGUI;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | DeleteBase | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | DeleteBase | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.DeleteModule(Sender: TObject);
var
  reply: word;
  Project: TORDESYProject;
begin
  Project:= TORDESYProject(TORDESYModule(tvMain.Selected.Data).ProjectRef);
  reply:= MessageBox(Handle, PChar('Delete module?' + #13#10), PChar('Confirm'), 36);
  if reply = IDYES then
  begin
    Project.RemoveModuleById(TORDESYModule(tvMain.Selected.Data).Id);
    tvMain.Selected.Data:= nil;
    tvMain.Deselect(tvMain.Selected);
    UpdateGUI;
  end;
end;

procedure TfmMain.DeleteProject(Sender: TObject);
var
  reply: word;
  Project: TORDESYProject;
begin
  Project:= TORDESYProject(tvMain.Selected.Data);
  reply:= MessageBox(Handle, PChar('Delete project?' + #13#10), PChar('Confirm'), 36);
  if reply = IDYES then
  begin
    ProjectList.RemoveProjectById(Project.Id);
    tvMain.Selected.Data:= nil;
    tvMain.Deselect(tvMain.Selected);
    UpdateGUI;
  end;
end;

procedure TfmMain.DeleteScheme(Sender: TObject);
var
  iScheme: TOraScheme;
  iSelected: TTreeNode;
  reply: word;
begin
  iSelected:= tvMain.Selected;
  if not Assigned(iSelected) then
    Exit;
  if TObject(iSelected.Data) is TOraScheme then
    iScheme:= TOraScheme(iSelected.Data)
  else if TObject(iSelected.Data) is TOraItem then
    iScheme:= ProjectList.GetOraSchemeById(TOraItem(iSelected.Data).SchemeId)
  else
    Exit;
  if not Assigned(iScheme) then
    Exit;
  reply:= MessageBox(Handle, PChar('Delete scheme: ' + iScheme.Login + '?' + #13#10), PChar('Confirm'), 36);
  if reply = IDYES then
  begin
    ProjectList.RemoveSchemeById(iScheme.Id);
    tvMain.Selected.Data:= nil;
    tvMain.Deselect(tvMain.Selected);
    UpdateGUI;
  end;
end;

procedure TfmMain.EditBase(aBase: TOraBase);
var
  BaseName: string;
begin
  try
    BaseName:= aBase.Name;
    if InputQuery('Edit base', 'Change base name:', BaseName) then
    begin
      if (BaseName <> '') and (Length(BaseName) <= 255) then
      begin
        aBase.Name:= BaseName;
        UpdateGUI;
      end;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | AddBase | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | AddBase | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.EditModule(Sender: TObject);
begin
  if ShowModuleEditDialog(TORDESYModule(tvMain.Selected.Data)) then
    UpdateGUI;
end;

procedure TfmMain.EditProject(Sender: TObject);
begin
  if ShowProjectEditDialog(TORDESYProject(tvMain.Selected.Data)) then
    UpdateGUI;
end;

procedure TfmMain.EditScheme(aScheme: TOraScheme);
begin
  if ShowSchemeEditDialog(aScheme) then
    UpdateGUI;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeApp(Action);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  InitApp;
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  SaveFormSize(fmMain.Width, fmMain.Height);
end;

procedure TfmMain.FreeApp(var Action: TCloseAction);
var
  reply: word;
begin
  try
    if Assigned(ProjectList) then
    begin
      if not ProjectList.Saved then
      begin
        reply:= MessageBox(handle, PChar('Some data were not retained, save?' + #13#10 +
          'When refuse, all new data will be lost!'), PChar('Warning!'), 51);
        if reply = IDYES then
          ProjectList.SaveToFile();
        if reply = IDCANCEL then
        begin
          Action:= caNone;
          Exit;
        end;
      end;
      ProjectList.Free;
      if Assigned(AppOptions) then
      begin
        AppOptions.SetOption('GUI', 'GroupList', IntToStr(tvMain.Width));
        AppOptions.SetOption('GUI', 'FormLeft', inttostr(fmMain.Left));
        AppOptions.SetOption('GUI', 'FormTop', inttostr(fmMain.Top));
        if not AppOptions.SaveUserOptions() then
          raise Exception.Create('Cant''t save user options!');
        AppOptions.Free;
      end;
    end;
  except
  on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | FreeApp | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | FreeApp | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.InitApp;
begin
  PrepareOptions;
  PrepareProjects;
  PrepareGUI;
end;

procedure TfmMain.ViewProjects(aTreeView: TTreeView);

  function BaseInModule(const aProjectId, aModuleId, aBaseId: integer): TTreeNode;
  var
    iP, iM, iB: integer;
    Parent1, Parent2: TTreeNode;
  begin
    Result:= nil;
    for iP := 0 to aTreeView.Items.Count - 1 do
    begin
      if (TObject(aTreeView.Items[iP].Data) is TORDESYProject) and (TORDESYProject(aTreeView.Items[iP].Data).Id = aProjectId) then
      begin
        Parent1:= aTreeView.Items[iP];
        for iM := 0 to Parent1.Count - 1 do
          if (TObject(Parent1.Item[iM].Data) is TORDESYModule) and (TORDESYModule(Parent1.Item[iM].Data).Id = aModuleId) then
          begin
            Parent2:= Parent1.Item[iM];
            for iB := 0 to Parent2.Count - 1 do
              if (TObject(Parent2.Item[iB].Data) is TOraBase) and (TOraBase(Parent2.Item[iB].Data).Id = aBaseId) then
                Result:= Parent2.Item[iB];
          end;
      end;
    end;
  end;

  function SchemeInBase(const aProjectId, aModuleId, aBaseId, aSchemeId: integer): TTreeNode;
  var
    iP, iM, iB, iSc: integer;
    Parent1, Parent2, Parent3: TTreeNode;
  begin
    Result:= nil;
    for iP := 0 to aTreeView.Items.Count - 1 do
    begin
      if (TObject(aTreeView.Items[iP].Data) is TORDESYProject) and (TORDESYProject(aTreeView.Items[iP].Data).Id = aProjectId) then
      begin
        Parent1:= aTreeView.Items[iP];
        for iM := 0 to Parent1.Count - 1 do
          if (TObject(Parent1.Item[iM].Data) is TORDESYModule) and (TORDESYModule(Parent1.Item[iM].Data).Id = aModuleId) then
          begin
            Parent2:= Parent1.Item[iM];
            for iB := 0 to Parent2.Count - 1 do
              if (TObject(Parent2.Item[iB].Data) is TOraBase) and (TOraBase(Parent2.Item[iB].Data).Id = aBaseId) then
                Parent3:= Parent2.Item[iB];
                for iSc := 0 to Parent3.Count - 1 do
                if (TObject(Parent3.Item[iSc].Data) is TOraScheme) and (TOraScheme(Parent3.Item[iSc].Data).Id = aSchemeId) then
                  Result:= Parent3.Item[iSc];
          end;
      end;
    end;
  end;

var
  iPL, iM, iB, iSc, iI: integer;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  ProjectAdded, ModuleAdded, BaseAdded, SchemeAdded, ItemAdded: TTreeNode;
begin
  aTreeView.Items.Clear;
  if ProjectList.ProjectCount <= 0 then
    Exit;
  aTreeView.Items.BeginUpdate;
  for iPL := 0 to ProjectList.ProjectCount - 1 do
  begin
    iProject:= ProjectList.GetProjectByIndex(iPL);
    ProjectAdded:= aTreeView.Items.AddObject(nil, iProject.Name, iProject);
    for iM := 0 to iProject.ModuleCount - 1 do
    begin
      iModule:= iProject.GetModuleByIndex(iM);
      ModuleAdded:= aTreeView.Items.AddChildObject(ProjectAdded, iModule.Name, iModule);
      for iI := 0 to iModule.OraItemCount - 1 do
      begin
        iItem:= iModule.GetOraItemByIndex(iI);
        iBase:= ProjectList.GetOraBaseById(iItem.BaseId);
        iScheme:= ProjectList.GetOraSchemeById(iItem.SchemeId);
        BaseAdded:= nil;
        SchemeAdded:= nil;
        if Assigned(iBase) then
        begin
          BaseAdded:= BaseInModule(iProject.Id, iModule.Id, iItem.BaseId);
          if not Assigned(BaseAdded) then
            BaseAdded:= aTreeView.Items.AddChildObject(ModuleAdded, iBase.Name, iBase);
        end
        else
          // No such base in project
          BaseAdded:= aTreeView.Items.AddChildObject(ModuleAdded, '?', nil);
        if Assigned(iScheme) then
        begin
          SchemeAdded:= SchemeInBase(iProject.Id, iModule.Id, iItem.BaseId, iItem.SchemeId);
          if not Assigned(SchemeAdded) then
            SchemeAdded:= aTreeView.Items.AddChildObject(BaseAdded, iScheme.Login, iScheme);
          ItemAdded:= aTreeView.Items.AddChildObject(SchemeAdded, iItem.Name, iItem);
        end
        else
        begin
          // No such scheme in project
          SchemeAdded:= aTreeView.Items.AddChildObject(BaseAdded, '?', nil);
          ItemAdded:= aTreeView.Items.AddChildObject(SchemeAdded, iItem.Name, iItem);
        end;
      end;
    end;
  end;
  aTreeView.Items.EndUpdate;
end;

procedure TfmMain.AddModule(Sender: TObject);
var
  iProject: TORDESYProject;
begin
  if TObject(tvMain.Selected.Data) is TORDESYProject then
    iProject:= TORDESYProject(tvMain.Selected.Data)
  else if TObject(tvMain.Selected.Data) is TORDESYModule then
    iProject:= TORDESYProject(TORDESYModule((tvMain.Selected.Data)).ProjectRef);
  if ShowModuleCreateDialog(iProject) then
    UpdateGUI;
end;

procedure TfmMain.AddProject(Sender: TObject);
begin
  if ShowProjectCreateDialog(AppOptions.UserName, ProjectList) then
    UpdateGUI;
end;

procedure TfmMain.AddScheme(Sender: TObject);
begin
  if ShowSchemeCreateDialog(ProjectList) then
    UpdateGUI;
end;

procedure TfmMain.miAddSchemeClick(Sender: TObject);
begin
  AddScheme(Self);
end;

procedure TfmMain.miBaseListClick(Sender: TObject);
begin
  if ShowBaseListDialog(ProjectList) then
    UpdateGUI;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  fmMain.Close;
end;

procedure TfmMain.miFileClick(Sender: TObject);
begin
  miSavechanges.Visible:= false;
  if Assigned(ProjectList) then
    miSavechanges.Visible:= not ProjectList.Saved;
end;

procedure TfmMain.miSavechangesClick(Sender: TObject);
begin
  if Assigned(ProjectList) then
    ProjectList.SaveToFile();
end;

procedure TfmMain.miSchemeListClick(Sender: TObject);
begin
  if ShowSchemeListDialog(ProjectList) then
    UpdateGUI;
end;

procedure TfmMain.OnEditBase(Sender: TObject);
var
  BaseName: string;
  iSelected: TTreeNode;
label
  retry;
begin
  try
    iSelected:= tvMain.Selected;
    retry:
    if TObject(iSelected.Data) is TOraBase then
      BaseName:= TOraBase(iSelected.Data).Name
    else if TObject(iSelected.Data) is TOraScheme then
      if (iSelected.Parent <> nil) and (iSelected.Parent.Data <> nil) and (TObject(iSelected.Parent.Data) is TOraBase) then
        BaseName:= TOraBase(iSelected.Parent.Data).Name
    else
      Exit;
    if InputQuery('Edit base', 'Change base name:', BaseName) then
    begin
      if (BaseName <> '') and (Length(BaseName) <= 255) then
      begin
        TOraBase(tvMain.Selected.Data).Name:= BaseName;
        UpdateGUI;
      end
      else
        goto retry;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | AddBase | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | AddBase | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.OnEditScheme(Sender: TObject);
var
  BaseName: string;
  iSelected: TTreeNode;
  iScheme: TOraScheme;
begin
  try
    iSelected:= tvMain.Selected;
    if TObject(iSelected.Data) is TOraScheme then
      iScheme:= TOraScheme(iSelected.Data)
    else if TObject(iSelected.Data) is TOraItem then
      if (iSelected.Parent <> nil) and (iSelected.Parent.Data <> nil) and (TObject(iSelected.Parent.Data) is TOraScheme) then
        iScheme:= TOraScheme(iSelected.Parent.Data)
    else
      Exit;
    if Assigned(iScheme) then
      EditScheme(iScheme);
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | AddBase | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | AddBase | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.AddBase(Sender: TObject);
var
  BaseName: string;
label
  retry;
begin
  try
    retry:
    if InputQuery('Add base', 'Enter base name:', BaseName) then
    begin
      if (BaseName <> '') and (Length(BaseName) <= 255) then
      begin
        ProjectList.AddOraBase(TOraBase.Create(ProjectList ,ProjectList.GetFreeBaseId, BaseName));
        UpdateGUI;
      end
      else
        goto retry;
    end;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | AddBase | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | AddBase | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

function TfmMain.CanPopup(const aTag: integer; aObject: Pointer): boolean;
begin
  Result:= false;
  if aObject <> nil then
  begin
    if (TObject(aObject) is TORDESYProject) and (aTag >= 1) and (aTag <= 10) or (aTag = 0) then
      Result:= true;
    if (TObject(aObject) is TORDESYModule) and (aTag >= 5) and (aTag <= 15) or (aTag = 0) then
      Result:= true;
    if (TObject(aObject) is TOraBase) and (aTag >= 10) and (aTag <= 20) or (aTag = 0) then
      Result:= true;
    if (TObject(aObject) is TOraScheme) and (aTag >= 15) and (aTag <= 25) or (aTag = 0) then
      Result:= True;
    if (TObject(aObject) is TOraItem) and (aTag >= 20) and (aTag <= 30) or (aTag = 0) then
      Result:= true;
  end
  else
    if aTag = 0 then
      Result:= True;
end;

procedure TfmMain.ppmMainPopup(Sender: TObject);
var
  i, n: integer;
begin
  for i := 0 to ppmMain.Items.Count - 1 do
  begin
    for n := 0 to ppmMain.Items[i].Count - 1 do
      if Assigned(tvMain.Selected)  then
      begin
        ppmMain.Items[i].Visible:= CanPopup(ppmMain.Items[i].Tag , tvMain.Selected.Data);
        ppmMain.Items[i].Items[n].Visible:= CanPopup(ppmMain.Items[i].Items[n].Tag , tvMain.Selected.Data);
      end
      else
      begin
        ppmMain.Items[i].Visible:= CanPopup(ppmMain.Items[i].Tag , nil);
        ppmMain.Items[i].Items[n].Visible:= CanPopup(ppmMain.Items[i].Items[n].Tag , nil);
      end;
  end;
end;

procedure TfmMain.PrepareGUI;
var
  ProjectMenu: TMenuItem;
  ModuleMenu: TMenuItem;
  BaseMenu: TMenuItem;
  SchemeMenu: TMenuItem;
  MenuItem: TMenuItem;
begin
  try
    edtUserName.Text:= AppOptions.UserName;
    try
      tvMain.Width:= strtoint(AppOptions.GetOption('GUI', 'GroupList'));
      fmMain.Width:= strtoint(AppOptions.GetOption('GUI', 'FormWidth'));
      fmMain.Height:= strtoint(AppOptions.GetOption('GUI', 'FormHeight'));
    except
      on E: Exception do
      begin
        {$IFDEF Debug}
        AddToLog(ClassName + ' | PrepareGUI | ' + E.Message);
        MessageBox(Application.Handle, PChar(ClassName + ' | PrepareGUI | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ELSE}
        MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
        {$ENDIF}
      end;
    end;
    // -----------------------------------------Project Popup 1-10
    ProjectMenu:= TMenuItem.Create(ppmMain);
    ProjectMenu.Caption:= 'Project';
    ProjectMenu.Tag:= 0;
    ppmMain.Items.Add(ProjectMenu);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= AddProject;
      MenuItem.Caption:= 'Add project';
      MenuItem.Tag:= 0;
      ProjectMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= EditProject;
      MenuItem.Caption:= 'Edit project';
      MenuItem.Tag:= 1;
      ProjectMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= DeleteProject;
      MenuItem.Caption:= 'Delete project';
      MenuItem.Tag:= 1;
      ProjectMenu.Add(MenuItem);
    //
    ModuleMenu:= TMenuItem.Create(ppmMain);
    ModuleMenu.Caption:= 'Module';
    ModuleMenu.Tag:= 0;
    ppmMain.Items.Add(ModuleMenu);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= AddModule;
      MenuItem.Caption:= 'Add module';
      MenuItem.Tag:= 0;
      ModuleMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= EditModule;
      MenuItem.Caption:= 'Edit module';
      MenuItem.Tag:= 11;
      ModuleMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= DeleteModule;
      MenuItem.Caption:= 'Delete module';
      MenuItem.Tag:= 11;
      ModuleMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= WrapItem;
      MenuItem.Caption:= 'Wrap item';
      MenuItem.Tag:= 11;
      ModuleMenu.Add(MenuItem);
    //
    BaseMenu:= TMenuItem.Create(ppmMain);
    BaseMenu.Caption:= 'Base';
    BaseMenu.Tag:= 0;
    ppmMain.Items.Add(BaseMenu);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= AddBase;
      MenuItem.Caption:= 'Add base';
      MenuItem.Tag:= 0;
      BaseMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= OnEditBase;
      MenuItem.Caption:= 'Edit base';
      MenuItem.Tag:= 16;
      BaseMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= DeleteBase;
      MenuItem.Caption:= 'Delete base';
      MenuItem.Tag:= 16;
      BaseMenu.Add(MenuItem);
    //
    SchemeMenu:= TMenuItem.Create(ppmMain);
    SchemeMenu.Caption:= 'Scheme';
    SchemeMenu.Tag:= 0;
    ppmMain.Items.Add(SchemeMenu);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= AddScheme;
      MenuItem.Caption:= 'Add scheme';
      MenuItem.Tag:= 0;
      SchemeMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= OnEditScheme;
      MenuItem.Caption:= 'Edit scheme';
      MenuItem.Tag:= 21;
      SchemeMenu.Add(MenuItem);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= DeleteScheme;
      MenuItem.Caption:= 'Delete scheme';
      MenuItem.Tag:= 21;
      SchemeMenu.Add(MenuItem);
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | PrepareGUI | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | PrepareGUI | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.PrepareOptions;
begin
  try
    if not Assigned(AppOptions) then
      AppOptions:= TOptions.Create;
    AppOptions.AppTitle:= Application.Title;
    AppOptions.UserName:= GetWindowsUser; //Узнаем текущее имя пользователя
    AppOptions.LoadUserOptions();
    {if not AppOptions.LoadUserOptions() then
      raise Exception.Create('Cant''t load user options!');}
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | PrepareOptions | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | PrepareOptions | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.PrepareProjects;
//TEST
{var
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;}
//END TEST
begin
  try
    if not Assigned(ProjectList) then
      ProjectList:= TORDESYProjectList.Create;
    if not ProjectList.LoadFromFile() then
      raise Exception.Create('Error while loading project list. Please check the files/folders!');
    //
    //TEST
    {iProject:= TORDESYProject.Create(ProjectList.GetFreeProjectId, 'BIG PROJECT');
    iProject.AddModule(TORDESYModule.Create(iProject, iProject.GetFreeModuleId, 'Little Module1', 'DESCRIPTION1'));
    iProject.AddModule(TORDESYModule.Create(iProject, iProject.GetFreeModuleId, 'Little Module2', 'DESCRIPTION2'));
    iProject.AddModule(TORDESYModule.Create(iProject, iProject.GetFreeModuleId, 'Little Module3', 'DESCRIPTION3'));
    iModule:= TORDESYModule.Create(iProject, iProject.GetFreeModuleId, 'Little Module4', 'DESCRIPTION4');
    iProject.AddModule(iModule);

    ProjectList.AddOraBase(TOraBase.Create(ProjectList ,ProjectList.GetFreeBaseId, 'Some BASE _ 1'));
    iBase:= TOraBase.Create(ProjectList ,ProjectList.GetFreeBaseId, 'Some BASE _ 2');
    ProjectList.AddOraBase(iBase);
    iScheme:= TOraScheme.Create(ProjectList, ProjectList.GetFreeSchemeId, 'Scheme of SOME BASE', 'pass');
    ProjectList.AddOraScheme(iScheme);

    iModule.AddOraItem(TOraItem.Create(iModule, iModule.GetFreeItemId, iBase.Id, iScheme.Id, 'PROC_1', 'procedure', OraProcedure));
    iModule.AddOraItem(TOraItem.Create(iModule, iModule.GetFreeItemId, iBase.Id, iScheme.Id, 'FUNC_1', 'function', OraFunction));
    iModule.AddOraItem(TOraItem.Create(iModule, iModule.GetFreeItemId, iBase.Id, iScheme.Id, 'PACK_1', 'package', OraPackage));

    ProjectList.AddProject(iProject);}

    //ShowMessage(ProjectList.GetProjectByIndex(0).GetModuleByIndex(2).GetOraItemByIndex(2).Name);
    //ShowMessage(inttostr(ProjectList.GetProjectByIndex(0).GetModuleByIndex(3).OraItemCount));
    //END TEST
    ViewProjects(tvMain);
    //ShowMessage(ProjectList.GetProjectByIndex(0).GetOraItemByIndex(0).Name);
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | PrepareProjects | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | PrepareProjects | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.SaveFormSize(const aWidth, aHeight: integer);
begin
  if Assigned(AppOptions) then
  begin
    AppOptions.SetOption('GUI', 'FormWidth', inttostr(aWidth)); // leak memory here, idk what the reason
    AppOptions.SetOption('GUI', 'FormHeight', inttostr(aHeight)); // leak memory here, idk what the reason
    //ShowMessage(inttostr(AppOptions.Count));
  end;
end;

procedure TfmMain.splMainMoved(Sender: TObject);
begin
  if Assigned(AppOptions) then
    AppOptions.SetOption('GUI', 'GroupList', IntToStr(tvMain.Width));
end;

procedure TfmMain.tvMainClick(Sender: TObject);
begin
  if Assigned(tvMain.Selected) and (tvMain.Selected.Data <> nil) then
    if TObject(tvMain.Selected.Data) is TORDESYProject then
    begin
      edName.Text:= TORDESYProject(tvMain.Selected.Data).Name;
      mmoDesc.Text:= TORDESYProject(tvMain.Selected.Data).Description;
    end
    else if TObject(tvMain.Selected.Data) is TORDESYModule then
    begin
      edName.Text:= TORDESYModule(tvMain.Selected.Data).Name;
      mmoDesc.Text:= TORDESYModule(tvMain.Selected.Data).Description;
    end
    else if TObject(tvMain.Selected.Data) is TOraBase then
    begin
      edName.Text:= TOraBase(tvMain.Selected.Data).Name;
      mmoDesc.Text:= '';
    end
    else if TObject(tvMain.Selected.Data) is TOraScheme then
    begin
      edName.Text:= TOraScheme(tvMain.Selected.Data).Login;
      mmoDesc.Text:= '';
    end
    else if TObject(tvMain.Selected.Data) is TOraItem then
    begin
      edName.Text:= TOraItem(tvMain.Selected.Data).Name;
      mmoDesc.Text:= TOraItem(tvMain.Selected.Data).ItemBody;
    end
    else
    begin
      edName.Text:= '';
      mmoDesc.Text:= '';
    end;
end;

procedure TfmMain.tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  try
    Node.SelectedIndex:= Node.ImageIndex;
    if TObject(Node.Data) is TOraItem then
      case TOraItem(Node.Data).ItemType of
        OraProcedure:
          begin
            Node.ImageIndex:= 15;
          end;
        OraFunction:
          begin
            Node.ImageIndex:= 14;
          end;
        OraPackage:
          begin
            Node.ImageIndex:= 9;
          end;
      end
    else if TObject(Node.Data) is TOraScheme then
      Node.ImageIndex:= 52
    else if TObject(Node.Data) is TOraBase then
      Node.ImageIndex:= 50
    else if TObject(Node.Data) is TORDESYModule then
      if Node.HasChildren and Node.Expanded then
        Node.ImageIndex:= 55
      else
        Node.ImageIndex:= 54
    else if TObject(Node.Data) is TORDESYProject then
      if Node.HasChildren and Node.Expanded then
        Node.ImageIndex:= 59
      else
        Node.ImageIndex:= 58
    else if (Node.Data = nil) and (Node.Text = '?') then
      Node.ImageIndex:= 0;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | tvMainGetImageIndex | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | tvMainGetImageIndex | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.UpdateGUI;
begin
  ViewProjects(tvMain);
end;

{procedure TfmMain.WMWindowPosChanged(var aMessage: TWMWindowPosChanged);
begin
  inherited;
  SaveFormSize(fmMain.Width, fmMain.Height);
end;}

procedure TfmMain.WrapItem(Sender: TObject);
begin
  if ShowWrapDialog(TORDESYModule(tvMain.Selected.Data), ProjectList) then
    UpdateGUI;
end;

end.
