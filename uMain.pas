unit uMain;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uORDESY, uExplode, uShellFuncs,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList;

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
    procedure miExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
  private
    procedure PrepareGUI;
  public
    procedure InitApp;
    procedure FreeApp;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  InitApp;
end;

procedure TfmMain.FreeApp;
begin
  Application.Terminate;
end;

procedure TfmMain.InitApp;
begin
  PrepareGUI;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  FreeApp;
end;

// Инициализация интерфейса ползователя
{procedure TfmMain.PrepareGUI;
var
  OrProject: TORDESYProject;
  OrScheme: TOraScheme;
  OrModule: TORDESYModule;
  LastAdded: TTreeNode;
begin
  OrProject:= TORDESYProject.Create('project1');
  OrScheme:= TOraScheme.Create;
  OrModule:= TORDESYModule.Create;
  LastAdded:= tvMain.Items.AddObject(nil, 'project1', OrProject);
  LastAdded:= tvMain.Items.AddChildObject(LastAdded, 'scheme', OrScheme);
  LastAdded:= tvMain.Items.AddChildObject(LastAdded, 'module', OrModule);
  tvMain.Items.AddChildObject(LastAdded, 'scribe', TOraItem.Create('scribe'));
  tvMain.Items.AddChildObject(LastAdded, 'scribe2', TOraItem.Create('scribe', '', OraFunction));
  tvMain.Items.AddChildObject(LastAdded, 'scribe3', TOraItem.Create('scribe', '', OraPackage));
end;}

procedure TfmMain.PrepareGUI;
begin
  edtUserName.Text:= GetWindowsUser; //Узнаем текущее имя пользователя
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
      AddToLog(E.Message);
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

end.
