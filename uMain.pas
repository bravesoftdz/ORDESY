{

edt - TEdit
btn - TButton
pnl - TPanel
lbl - TLabel
gpb - TGroupBox
spl - TSplitter
mmo - TMemo
tv - TTreeView
mm - TMainMenu
mi - TMenuItem
fm - TForm
cbx - TComboBox
lbx - TListBox

}
unit uMain;

interface

uses
  // ORDESY Modules
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uORDESY, uExplode, uShellFuncs, uProjectDialogs, uOptions, uWrap,
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
    gbInfo: TGroupBox;
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
    procedure WMWindowPosChanged(var aMessage: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure ViewProjects(aTreeView: TTreeView);
    procedure ppmMainPopup(Sender: TObject);
    procedure AddProject(Sender: TObject);
    procedure EditProject(Sender: TObject);
    procedure DeleteProject(Sender: TObject);
    procedure WrapItem(Sender: TObject);
    procedure AddModule(Sender: TObject);
    procedure EditModule(Sender: TObject);
    procedure DeleteModule(Sender: TObject);
    procedure tvMainClick(Sender: TObject);
    procedure miFileClick(Sender: TObject);
    procedure miSavechangesClick(Sender: TObject);
  private
    AppOptions: TOptions;
    ProjectList: TORDESYProjectList;
    function CanPopup(const aTag: integer; aObject: Pointer): boolean;
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

procedure TfmMain.DeleteModule(Sender: TObject);
var
  reply: word;
  Project: TORDESYProject;
begin
  Project:= TORDESYProject(TORDESYModule(tvMain.Selected.Data).ProjectRef);
  reply:= MessageBox(Handle, PChar('Delete module?' + #13#10), PChar('Confirm'), 36);
  if reply = IDYES then
  begin
    tvMain.Deselect(tvMain.Selected);
    Project.RemoveModuleById(TORDESYModule(tvMain.Selected.Data).Id);
    tvMain.Selected.Data:= nil;
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
    tvMain.Deselect(tvMain.Selected);
    ProjectList.RemoveProjectById(Project.Id);
    tvMain.Selected.Data:= nil;
    UpdateGUI;
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

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeApp(Action);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  InitApp;
end;

procedure TfmMain.FreeApp(var Action: TCloseAction);
var
  reply: word;
begin
  try
    if Assigned(AppOptions) then
    begin
      AppOptions.SetOption('GUI', 'GroupList', IntToStr(tvMain.Width));
      AppOptions.SetOption('GUI', 'FormLeft', inttostr(fmMain.Left));
      AppOptions.SetOption('GUI', 'FormTop', inttostr(fmMain.Top));
      if not AppOptions.SaveUserOptions() then
        raise Exception.Create('Cant''t save user options!');
      AppOptions.Free;
    end;
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
        if iBase <> nil then
        begin
          BaseAdded:= BaseInModule(iProject.Id, iModule.Id, iItem.BaseId);
          if BaseAdded = nil then
            BaseAdded:= aTreeView.Items.AddChildObject(ModuleAdded, iBase.Name, iBase);
          if iScheme <> nil then
          begin
            SchemeAdded:= SchemeInBase(iProject.Id, iModule.Id, iItem.BaseId, iItem.SchemeId);
            if SchemeAdded = nil then
              SchemeAdded:= aTreeView.Items.AddChildObject(BaseAdded, iScheme.Login, iScheme);
            ItemAdded:= aTreeView.Items.AddChildObject(SchemeAdded, iItem.Name, iItem);
          end
          else
          begin
            // No such scheme in project
            SchemeAdded:= aTreeView.Items.AddChildObject(BaseAdded, '?', nil);
            ItemAdded:= aTreeView.Items.AddChildObject(SchemeAdded, iItem.Name, iItem);
          end;
        end
        else
        begin
          // No such base in project
          BaseAdded:= aTreeView.Items.AddChildObject(ModuleAdded, '?', nil);
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

(*procedure TfmMain.AddBase(Sender: TObject);
var
  BaseName: string;
begin
  try
    if InputQuery('Add base', 'Enter base name:', BaseName) then
    begin
      if (BaseName <> '') and (Length(BaseName) <= 255) then
      begin
        if (TObject(tvMain.Selected.Data) is TORDESYModule) then
          with TORDESYProject(TORDESYModule(tvMain.Selected.Data).ProjectRef) do
          begin
            AddOraBase(TOraBase.Create(GetFreeBaseId, BaseName));
            UpdateGUI;
          end;
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
end;*)

function TfmMain.CanPopup(const aTag: integer; aObject: Pointer): boolean;
begin
  Result:= false;
  if aObject <> nil then
  begin
    if (TObject(aObject) is TORDESYProject) and (aTag >= 0) and (aTag <= 10) then
      Result:= true;
    if (TObject(aObject) is TORDESYModule) and (aTag >= 5) and (aTag <= 15) then
      Result:= true;
    if (TObject(aObject) is TOraBase) and (aTag >= 10) and (aTag <= 20) then
      Result:= true;
    if (TObject(aObject) is TOraScheme) and (aTag >= 15) and (aTag <= 25) then
      Result:= True;
    if (TObject(aObject) is TOraItem) and (aTag >= 20) and (aTag <= 30) then
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
  MenuItem: TMenuItem;
begin
  try
    edtUserName.Text:= AppOptions.UserName;
    tvMain.Width:= strtoint(AppOptions.GetOption('GUI', 'GroupList'));
    fmMain.Width:= strtoint(AppOptions.GetOption('GUI', 'FormWidth'));
    fmMain.Height:= strtoint(AppOptions.GetOption('GUI', 'FormHeight'));
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
    ModuleMenu.Tag:= 5;
    ppmMain.Items.Add(ModuleMenu);
      //
      MenuItem:= TMenuItem.Create(ppmMain);
      MenuItem.OnClick:= AddModule;
      MenuItem.Caption:= 'Add module';
      MenuItem.Tag:= 5;
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
    // -----------------------------------------Module popup 11-20
    {MenuItem:= TMenuItem.Create(ppmMain);
    MenuItem.OnClick:= AddModule;
    MenuItem.Caption:= 'Add base';
    MenuItem.Tag:= 11;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);}
    // -----------------------------------------Base popup 21-30
    {MenuItem:= TMenuItem.Create(ppmMain);
    MenuItem.OnClick:= AddBase;
    MenuItem.Caption:= 'Add base';
    MenuItem.Tag:= 21;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    //MenuItem.OnClick:= miCreateProject.OnClick;
    MenuItem.Caption:= 'Edit base';
    MenuItem.Tag:= 22;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    //MenuItem.OnClick:= miCreateProject.OnClick;
    MenuItem.Caption:= 'Delete base';
    MenuItem.Tag:= 23;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);}
    // -----------------------------------------Scheme popup 31-40
    {MenuItem:= TMenuItem.Create(ppmMain);
    //MenuItem.OnClick:= miCreateProject.OnClick;
    MenuItem.Caption:= 'Add scheme';
    MenuItem.Tag:= 31;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    //MenuItem.OnClick:= EditScheme
    MenuItem.Caption:= 'Edit scheme';
    MenuItem.Tag:= 32;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    MenuItem.OnClick:= WrapItem;
    MenuItem.Caption:= 'Wrap item';
    MenuItem.Tag:= 33;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    //MenuItem.OnClick:= EditScheme
    MenuItem.Caption:= 'Delete scheme';
    MenuItem.Tag:= 34;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);}
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
var
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
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

procedure TfmMain.splMainMoved(Sender: TObject);
begin
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

procedure TfmMain.WMWindowPosChanged(var aMessage: TWMWindowPosChanged);
begin
  inherited;
  if Assigned(AppOptions) then
  begin
    AppOptions.SetOption('GUI', 'FormWidth', inttostr(fmMain.Width));
    AppOptions.SetOption('GUI', 'FormHeight', inttostr(fmMain.Height));
  end;
end;

procedure TfmMain.WrapItem(Sender: TObject);
var
  iModule: TORDESYModule;
begin
  iModule:= TORDESYModule(tvMain.Selected.Data);
  with iModule do
  begin
    if ShowWrapDialog(iModule, ProjectList) then
  end;
end;

end.
