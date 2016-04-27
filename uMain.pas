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
  uORDESY, uExplode, uShellFuncs, uProject, uOptions, uWrap,
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
    miCreateProject: TMenuItem;
    miOptions: TMenuItem;
    miShow: TMenuItem;
    miShowAll: TMenuItem;
    miScheme: TMenuItem;
    miCreateScheme: TMenuItem;
    miSchemeOptions: TMenuItem;
    miProjectOptions: TMenuItem;
    miObject: TMenuItem;
    miCreateObject: TMenuItem;
    miObjectOptions: TMenuItem;
    miLast: TMenuItem;
    miAbout: TMenuItem;
    miHelp: TMenuItem;
    splMain: TSplitter;
    miBase: TMenuItem;
    miCreateBase: TMenuItem;
    miModule: TMenuItem;
    miBaseOptions: TMenuItem;
    miCreateModule: TMenuItem;
    miModuleOptions: TMenuItem;
    ppmMain: TPopupMenu;
    gbInfo: TGroupBox;
    edName: TEdit;
    lblName: TLabel;
    lblDescription: TLabel;
    mmoDesc: TMemo;
    miSavechanges: TMenuItem;
    procedure miExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure splMainMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WMWindowPosChanged(var aMessage: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure miCreateProjectClick(Sender: TObject);
    procedure ViewProjects(aTreeView: TTreeView);
    procedure ppmMainPopup(Sender: TObject);
    procedure EditProject(Sender: TObject);
    procedure DeleteProject(Sender: TObject);
    procedure tvMainClick(Sender: TObject);
    procedure miFileClick(Sender: TObject);
    procedure miSavechangesClick(Sender: TObject);
  private
    AppOptions: TOptions;
    ProjectList: TORDESYProjectList;
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
    UpdateGUI;
  end;
end;

procedure TfmMain.EditProject(Sender: TObject);
var
  Project: TORDESYProject;
begin
  Project:= TORDESYProject(tvMain.Selected.Data);
  if ShowProjectEditDialog(Project) then
  begin
    UpdateGUI;
  end;
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

  function GetBaseItem(const aProjectId, aModuleId, aBaseId: integer): TTreeNode;
  var
    i, ip1, ip2: integer;
    Parent1, Parent2: TTreeNode;
  begin
    Result:= nil;
    for i := 0 to aTreeView.Items.Count - 1 do
    begin
      if (TObject(aTreeView.Items[i].Data) is TORDESYProject) and (TORDESYProject(aTreeView.Items[i].Data).Id = aProjectId) then
      begin
        Parent1:= aTreeView.Items[i];
        for ip1 := 0 to Parent1.Count - 1 do
          if (TObject(Parent1.Item[ip1].Data) is TORDESYModule) and (TORDESYModule(Parent1.Item[ip1].Data).Id = aModuleId) then
          begin
            Parent2:= Parent1.Item[ip1];
            for ip2 := 0 to Parent2.Count - 1 do
              if (TObject(Parent2.Item[ip2].Data) is TOraBase) and (TOraBase(Parent2.Item[ip2].Data).Id = aBaseId) then
                Result:= Parent2.Item[ip2];
          end;
      end;
    end;
  end;

var
  iPL, iM, iB, iSc, Ii: integer;
  iProject: TORDESYProject;
  iModule: TORDESYModule;
  iBase: TOraBase;
  iScheme: TOraScheme;
  iItem: TOraItem;
  ProjectAdded, ModuleAdded, BaseAdded, SchemeAdded, ItemAdded: TTreeNode;
begin
  if ProjectList.Count <= 0 then
    Exit;
  aTreeView.Items.BeginUpdate;
  aTreeView.Items.Clear;
  for iPL := 0 to ProjectList.Count - 1 do
  begin
    iProject:= ProjectList.GetProjectByIndex(iPL);
    ProjectAdded:= tvMain.Items.AddObject(nil, iProject.Name, iProject);
    for iM := 0 to iProject.ModuleCount - 1 do
    begin
      iModule:= iProject.GetModuleByIndex(iM);
      ModuleAdded:= tvMain.Items.AddChildObject(ProjectAdded, iModule.Name, iModule);
      for iSc := 0 to iProject.OraSchemeCount - 1 do
      begin
        iScheme:= iProject.GetOraSchemeByIndex(iSc);
        if iScheme.ModuleId = iModule.Id then
        begin
          for iB := 0 to iProject.OraBaseCount - 1 do
          begin
            iBase:= iProject.GetOraBaseByIndex(iB);
            if iScheme.BaseId = iBase.Id then
            begin
              BaseAdded:= GetBaseItem(iProject.Id, iModule.Id, iBase.Id);
              if not Assigned(BaseAdded) then
                BaseAdded:= tvMain.Items.AddChildObject(ModuleAdded, iBase.Name, iBase);
              SchemeAdded:= tvMain.Items.AddChildObject(BaseAdded, iScheme.Login, iScheme);
            end;
          end;
          for Ii := 0 to iProject.OraItemCount - 1 do
          begin
            iItem:= iProject.GetOraItemByIndex(Ii);
            ItemAdded:= tvMain.Items.AddChildObject(SchemeAdded, iItem.Name, iItem);
          end;
        end;
      end;
    end;
  end;
  aTreeView.Items.EndUpdate;
end;

procedure TfmMain.miCreateProjectClick(Sender: TObject);
begin
  if ShowProjectCreateDialog(AppOptions.UserName, ProjectList) then
  begin
    UpdateGUI;
  end;
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

procedure TfmMain.ppmMainPopup(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to ppmMain.Items.Count - 1 do
  begin
    if Assigned(tvMain.Selected) and  (TObject(tvMain.Selected.Data) is TORDESYProject) then
    begin
      if (ppmMain.Items[i].Tag >= 1) and (ppmMain.Items[i].Tag <= 10) then
        ppmMain.Items[i].Visible:= true
    end
      else
        ppmMain.Items[i].Visible:= false;
  end;
end;

procedure TfmMain.PrepareGUI;
var
  MenuItem: TMenuItem;
begin
  try
    edtUserName.Text:= AppOptions.UserName;
    tvMain.Width:= strtoint(AppOptions.GetOption('GUI', 'GroupList'));
    fmMain.Width:= strtoint(AppOptions.GetOption('GUI', 'FormWidth'));
    fmMain.Height:= strtoint(AppOptions.GetOption('GUI', 'FormHeight'));
    // Project Popup
    MenuItem:= TMenuItem.Create(ppmMain);
    MenuItem.OnClick:= miCreateProject.OnClick;
    MenuItem.Caption:= 'Create project';
    MenuItem.Tag:= 1;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    MenuItem.OnClick:= EditProject;
    MenuItem.Caption:= 'Edit project';
    MenuItem.Tag:= 2;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    //
    MenuItem:= TMenuItem.Create(ppmMain);
    MenuItem.OnClick:= DeleteProject;
    MenuItem.Caption:= 'Delete project';
    MenuItem.Tag:= 3;
    MenuItem.Visible:= false;
    ppmMain.Items.Add(MenuItem);
    // Module popup

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
    //TEST
    {iProject:= TORDESYProject.Create(ProjectList.GetFreeProjectId, 'BIG PROJECT');
    iProject.AddModule(TORDESYModule.Create(iProject.GetFreeModuleId, 'Little Module1', 'DESCRIPTION1'));
    iProject.AddModule(TORDESYModule.Create(iProject.GetFreeModuleId, 'Little Module2', 'DESCRIPTION2'));
    iProject.AddModule(TORDESYModule.Create(iProject.GetFreeModuleId, 'Little Module3', 'DESCRIPTION3'));
    iProject.AddModule(TORDESYModule.Create(iProject.GetFreeModuleId, 'Little Module4', 'DESCRIPTION4'));
    iProject.AddOraBase(TOraBase.Create(iProject.GetFreeBaseId, 'Some BASE'));
    iProject.AddOraScheme(TOraScheme.Create(iProject.GetFreeSchemeId, 'Scheme of SOME BASE', 'pass', iProject.GetFreeBaseId - 1, iProject.GetFreeModuleId - 1));
    iProject.AddOraItem(TOraItem.Create(iProject.GetFreeItemId, iProject.GetFreeSchemeId - 1, 'PROC_1', 'procedure', OraProcedure));
    iProject.AddOraItem(TOraItem.Create(iProject.GetFreeItemId, iProject.GetFreeSchemeId - 1, 'FUNC_1', 'function', OraFunction));
    iProject.AddOraItem(TOraItem.Create(iProject.GetFreeItemId, iProject.GetFreeSchemeId - 1, 'PACK_1', 'package', OraPackage));
    ProjectList.AddProject(iProject);}
    //END TEST
    ViewProjects(tvMain);
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
  if Assigned(tvMain.Selected) then
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
        Node.ImageIndex:= 58;
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

end.
