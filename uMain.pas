{

edt - TEdit
btn - TButton
pnl - TPanel
lbl - TLabel
gpb - TGroupBox
spl - TSplitter
tv - TTreeView
mm - TMainMenu
mi - TMenuItem
fm - TForm

}
unit uMain;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uORDESY, uExplode, uShellFuncs, uProjectCreate, uOptions,
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
    BitBtn1: TBitBtn;
    miBase: TMenuItem;
    miCreateBase: TMenuItem;
    miModule: TMenuItem;
    miBaseOptions: TMenuItem;
    miCreateModule: TMenuItem;
    miModuleOptions: TMenuItem;
    procedure miExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure splMainMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WMWindowPosChanged(var aMessage: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure miCreateProjectClick(Sender: TObject);
    procedure ViewProjects(aTreeView: TTreeView);
  private
    AppOptions: TOptions;
    ProjectList: TORDESYProjectList;
    //GroupList: TGroupList;
    procedure PrepareGUI;
    procedure UpdateGUI;
    procedure PrepareOptions;
    procedure PrepareProjects;
  public
    procedure InitApp;
    procedure FreeApp;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeApp;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  InitApp;
end;

procedure TfmMain.FreeApp;
begin
  try
    AppOptions.SetOption('GUI', 'GroupList', IntToStr(tvMain.Width));
    AppOptions.SetOption('GUI', 'FormLeft', inttostr(fmMain.Left));
    AppOptions.SetOption('GUI', 'FormTop', inttostr(fmMain.Top));
    AppOptions.SaveUserOptions();
    ProjectList.Free;
    {if not AppOptions.SaveUserOptions() then
      raise Exception.Create('Cant''t save user options!');}
    //ProjectList.SaveToFile();
    //GroupList.SaveGroups();
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
  Application.Terminate;
end;

procedure TfmMain.InitApp;
begin
  PrepareOptions;
  PrepareProjects;
  PrepareGUI;
end;

procedure TfmMain.ViewProjects(aTreeView: TTreeView);
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
      iModule:= iProject.GetModule(iM);
      ModuleAdded:= tvMain.Items.AddChildObject(ProjectAdded, iModule.Name, iModule);
      for iB := 0 to iProject.OraBaseCount - 1 do
      begin
        iBase:= iProject.GetOraBase(iB);
        BaseAdded:= tvMain.Items.AddChildObject(ModuleAdded, iBase.Name, iBase);
        for iSc := 0 to iProject.OraSchemeCount - 1 do
        begin
          iScheme:= iProject.GetOraScheme(iSc);
          SchemeAdded:= tvMain.Items.AddChildObject(BaseAdded, iScheme.Login, iScheme);
          for Ii := 0 to iProject.OraItemCount - 1 do
          begin
            iItem:= iProject.GetOraItem(Ii);
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

procedure TfmMain.PrepareGUI;
begin
  try
    edtUserName.Text:= AppOptions.UserName;
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
    {if not Assigned(GroupList) then
      GroupList:= TGroupList.Create();
    GroupList.LoadGroups();}
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
    {ProjectList.OnProjectAdd:= ViewProjects(tvMain);
    ProjectList.OnProjectRemove:= ViewProjects(tvMain);}
    if not ProjectList.LoadFromFile() then
      raise Exception.Create('Error while loading project list. Please check the files/folders!');
    //TEST
    {iProject:= TORDESYProject.Create(ProjectList.GetFreeProjectId, 'ORDESY PROJECT');
    iProject.AddModule(TORDESYModule.Create(iProject.GetFreeModuleId, 'Little Module'));
    iProject.AddOraBase(TOraBase.Create(iProject.GetFreeBaseId, 'Some BASE'));
    iProject.AddOraScheme(TOraScheme.Create(iProject.GetFreeSchemeId, 'Scheme of SOME BASE', 'pass', iProject.GetFreeBaseId - 1, iProject.GetFreeModuleId - 1));
    iProject.AddOraItem(TOraItem.Create(iProject.GetFreeItemId, iProject.GetFreeSchemeId - 1, 'PROC_1', 'procedure', OraProcedure));
    iProject.AddOraItem(TOraItem.Create(iProject.GetFreeItemId, iProject.GetFreeSchemeId - 1, 'FUNC_1', 'function', OraFunction));
    iProject.AddOraItem(TOraItem.Create(iProject.GetFreeItemId, iProject.GetFreeSchemeId - 1, 'PACK_1', 'package', OraPackage));
    ProjectList.AddProject(iProject);
    ProjectList.SaveToFile();}
    //END TEST
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
