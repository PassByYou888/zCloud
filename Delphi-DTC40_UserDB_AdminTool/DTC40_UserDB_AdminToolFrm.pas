unit DTC40_UserDB_AdminToolFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Actions, Vcl.ActnList,

  Vcl.FileCtrl,
  System.IOUtils, System.DateUtils, System.TypInfo,

  CoreClasses, PascalStrings, UnicodeMixedLib, DoStatusIO,
  ListEngine, GHashList, zExpression, OpCode, TextParsing, DataFrameEngine, TextDataEngine,
  ZJson, Geometry2DUnit, Geometry3DUnit, NumberBase,
  MemoryStream64, CoreCipher, NotifyObjectBase, ZIOThread,
  CommunicationFramework,
  CommunicationFrameworkDoubleTunnelIO,
  CommunicationFrameworkDoubleTunnelIO_NoAuth,
  CommunicationFrameworkDoubleTunnelIO_VirtualAuth,
  CommunicationFrameworkDataStoreService,
  CommunicationFrameworkDataStoreService_NoAuth,
  CommunicationFrameworkDataStoreService_VirtualAuth,
  CommunicationFrameworkDataStoreServiceCommon,
  ObjectData, ObjectDataManager, ZDBEngine, ZDBLocalManager,
  FileIndexPackage, FilePackage, ItemStream, ObjectDataHashField, ObjectDataHashItem,
  ZDB2, ZDB2_Core, ZDB2_DFE, ZDB2_HS, ZDB2_HV, ZDB2_Json, ZDB2_MS64, ZDB2_NM, ZDB2_TE, ZDB2_FileEncoder,
  DTC40, DTC40_UserDB, DTC40_Var, DTC40_FS, DTC40_RandSeed, DTC40_Log_DB,
  PhysicsIO, MediaCenter;

type
  TDTC40_UserDB_AdminToolForm = class(TForm, IDTC40_PhysicsTunnel_Event)
    TopBarPanel: TPanel;
    logMemo: TMemo;
    botSplitter: TSplitter;
    JoinHostEdit: TLabeledEdit;
    JoinPortEdit: TLabeledEdit;
    DependEdit: TLabeledEdit;
    BuildDependNetButton: TButton;
    resetDependButton: TButton;
    cliPanel: TPanel;
    leftPanel: TPanel;
    lpLSplitter: TSplitter;
    listToolBarPanel: TPanel;
    UserListView: TListView;
    serviceComboBox: TComboBox;
    queryButton: TButton;
    SearchEdit: TLabeledEdit;
    SearchButton: TButton;
    jsonMemo: TMemo;
    DTC4PasswdEdit: TLabeledEdit;
    netTimer: TTimer;
    Action_List: TActionList;
    Action_downloadtoDir: TAction;
    uploadJson_OpenDialog: TOpenDialog;
    Action_UploadJson: TAction;
    Action_LargeScaleRegistrationTool: TAction;
    NumEdit: TLabeledEdit;
    Action_Kick: TAction;
    Action_Enabled: TAction;
    Action_Disable: TAction;
    Action_Remove: TAction;
    PopupMenu_: TPopupMenu;
    Downloadselectedtodirectory1: TMenuItem;
    UploadjsontoUserDB1: TMenuItem;
    Kick1: TMenuItem;
    Enabled1: TMenuItem;
    Disable1: TMenuItem;
    Remove1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    MainMenu_: TMainMenu;
    File1: TMenuItem;
    Kick2: TMenuItem;
    Disable2: TMenuItem;
    Enabled2: TMenuItem;
    Remove2: TMenuItem;
    N3: TMenuItem;
    Downloadselectedtodirectory2: TMenuItem;
    UploadjsontoUserDB2: TMenuItem;
    N4: TMenuItem;
    LargeScaleRegistrationTool2: TMenuItem;
    Action_UserDB_State: TAction;
    UserDBServiceState1: TMenuItem;
    UserDBServiceState2: TMenuItem;
    Action_exit: TAction;
    Exit1: TMenuItem;
    procedure Action_downloadtoDirExecute(Sender: TObject);
    procedure Action_KickExecute(Sender: TObject);
    procedure Action_EnabledExecute(Sender: TObject);
    procedure Action_DisableExecute(Sender: TObject);
    procedure Action_RemoveExecute(Sender: TObject);
    procedure Action_UploadJsonExecute(Sender: TObject);
    procedure Action_UserDB_StateExecute(Sender: TObject);
    procedure Action_LargeScaleRegistrationToolExecute(Sender: TObject);
    procedure Action_exitExecute(Sender: TObject);
    procedure BuildDependNetButtonClick(Sender: TObject);
    procedure netTimerTimer(Sender: TObject);
    procedure queryButtonClick(Sender: TObject);
    procedure DTC4PasswdEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SearchButtonClick(Sender: TObject);
    procedure resetDependButtonClick(Sender: TObject);
    procedure SearchEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UserListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure UserListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    procedure DoStatus_backcall(Text_: SystemString; const ID: Integer);
    procedure ReadConfig;
    procedure WriteConfig;
    procedure Do_QueryResult(Sender: TDTC40_PhysicsTunnel; L: TDTC40_InfoList);
    procedure DoConnected;
    procedure DoDisconnect;
    procedure Do_Usr_IsOpen(Sender: TDTC40_UserDB_Client; State_: TArrayBool);
    procedure Do_Usr_Serarch(Sender: TPeerIO; Result_: TDFE);
    procedure RefreshUserList(Text_: U_String; maxNum_: Integer);
    procedure Do_Usr_OnlineNum(Sender: TDTC40_UserDB_Client; Online_Num, User_Num: Integer);
  private
    // IDTC40_PhysicsTunnel_Event
    procedure DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
    procedure DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
  public
    ValidService: TDTC40_InfoList;
    CurrentClient: TDTC40_UserDB_Client;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  DTC40_UserDB_AdminToolForm: TDTC40_UserDB_AdminToolForm;

implementation

{$R *.dfm}


uses DTC40_UserDB_AdminLargeScaleRegFrm;

type
  TUsr_Item = class(TListItem)
  public
    json: TZJ;
    PrimaryIdentifier: U_String;
    Ready: Boolean;
    constructor Create(AOwner: TListItems); override;
    destructor Destroy; override;
  end;

constructor TUsr_Item.Create(AOwner: TListItems);
begin
  inherited;
  json := TZJ.Create;
  Ready := False;
end;

destructor TUsr_Item.Destroy;
begin
  DisposeObject(json);
  inherited;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_downloadtoDirExecute(Sender: TObject);
var
  i: Integer;
  dir: string;
  itm: TUsr_Item;
begin
  if UserListView.SelCount <= 0 then
      exit;
  if CurrentClient = nil then
      exit;

  dir := umlCurrentDirectory;
  if not SelectDirectory('downlaod to...', '', dir) then
      exit;

  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      if itm.Selected then
          itm.json.SaveToFile(umlCombineFileName(dir, itm.PrimaryIdentifier + '.json'));
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_KickExecute(Sender: TObject);
var
  i: Integer;
  itm: TUsr_Item;
begin
  if CurrentClient = nil then
      exit;

  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      if itm.Selected then
          CurrentClient.Usr_Kick(itm.PrimaryIdentifier);
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_EnabledExecute(Sender: TObject);
var
  i: Integer;
  itm: TUsr_Item;
begin
  if CurrentClient = nil then
      exit;

  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      if itm.Selected then
          CurrentClient.Usr_Enabled(itm.PrimaryIdentifier);
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_DisableExecute(Sender: TObject);
var
  i: Integer;
  itm: TUsr_Item;
begin
  if CurrentClient = nil then
      exit;

  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      if itm.Selected then
          CurrentClient.Usr_Disable(itm.PrimaryIdentifier);
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_RemoveExecute(Sender: TObject);
var
  i: Integer;
  itm: TUsr_Item;
begin
  if CurrentClient = nil then
      exit;

  if MessageDlg('remove?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
      exit;
  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      if itm.Selected then
          CurrentClient.Usr_Remove(itm.PrimaryIdentifier);
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_UploadJsonExecute(Sender: TObject);
var
  i: Integer;
  L: TZJL;
begin
  if CurrentClient = nil then
      exit;
  if not uploadJson_OpenDialog.Execute then
      exit;

  L := TZJL.Create(True);
  for i := 0 to uploadJson_OpenDialog.Files.Count - 1 do
      L.AddFromFile(uploadJson_OpenDialog.Files[i]);
  CurrentClient.Usr_Upload(L);
  DisposeObject(L);
end;

procedure TDTC40_UserDB_AdminToolForm.Action_UserDB_StateExecute(Sender: TObject);
begin
  if CurrentClient = nil then
      exit;
  CurrentClient.Usr_OnlineNumM(Do_Usr_OnlineNum);
end;

procedure TDTC40_UserDB_AdminToolForm.Action_LargeScaleRegistrationToolExecute(Sender: TObject);
begin
  DTC40_UserDB_AdminLargeScaleRegForm.Show;
  DTC40_UserDB_AdminLargeScaleRegForm.RefreshCorpus;
end;

procedure TDTC40_UserDB_AdminToolForm.Action_exitExecute(Sender: TObject);
begin
  Close;
end;

procedure TDTC40_UserDB_AdminToolForm.BuildDependNetButtonClick(Sender: TObject);
var
  info: TDTC40_Info;
begin
  if serviceComboBox.ItemIndex < 0 then
      exit;
  info := TDTC40_Info(serviceComboBox.Items.Objects[serviceComboBox.ItemIndex]);
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(info, info.ServiceTyp, self);
end;

procedure TDTC40_UserDB_AdminToolForm.netTimerTimer(Sender: TObject);
begin
  C40Progress;
end;

procedure TDTC40_UserDB_AdminToolForm.queryButtonClick(Sender: TObject);
var
  tunnel_: TDTC40_PhysicsTunnel;
begin
  tunnel_ := DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(JoinHostEdit.Text, EStrToInt(JoinPortEdit.Text, 0));
  tunnel_.QueryInfoM(Do_QueryResult);
end;

procedure TDTC40_UserDB_AdminToolForm.DTC4PasswdEditChange(Sender: TObject);
begin
  DTC40.DTC40_Password := DTC4PasswdEdit.Text;
end;

procedure TDTC40_UserDB_AdminToolForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteConfig;
  CloseAction := caFree;
end;

procedure TDTC40_UserDB_AdminToolForm.SearchButtonClick(Sender: TObject);
begin
  RefreshUserList(SearchEdit.Text, EStrToInt(NumEdit.Text, 1000));
end;

procedure TDTC40_UserDB_AdminToolForm.resetDependButtonClick(Sender: TObject);
begin
  C40Clean;
end;

procedure TDTC40_UserDB_AdminToolForm.SearchEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
      SearchButtonClick(SearchButton);
end;

procedure TDTC40_UserDB_AdminToolForm.UserListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TUsr_Item;
end;

procedure TDTC40_UserDB_AdminToolForm.UserListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  m64: TMS64;
begin
  if Selected then
    begin
      m64 := TMS64.Create;
      TUsr_Item(Item).json.SaveToStream(m64, True);
      m64.Position := 0;
      jsonMemo.Lines.LoadFromStream(m64, TEncoding.UTF8);
      m64.Free;
    end
  else
      jsonMemo.Clear;
end;

procedure TDTC40_UserDB_AdminToolForm.DoStatus_backcall(Text_: SystemString; const ID: Integer);
begin
  if logMemo.Lines.Count > 2000 then
      logMemo.Clear;
  logMemo.Lines.Add(DateTimeToStr(now) + ' ' + Text_);
end;

procedure TDTC40_UserDB_AdminToolForm.ReadConfig;
var
  fn: U_String;
  te: THashTextEngine;
begin
  fn := umlChangeFileExt(Application.ExeName, '.conf');
  if not umlFileExists(fn) then
      exit;
  te := THashTextEngine.Create;
  te.LoadFromFile(fn);
  JoinHostEdit.Text := te.GetDefaultValue('Main', JoinHostEdit.Name, JoinHostEdit.Text);
  JoinPortEdit.Text := te.GetDefaultValue('Main', JoinPortEdit.Name, JoinPortEdit.Text);
  DisposeObject(te);
end;

procedure TDTC40_UserDB_AdminToolForm.WriteConfig;
var
  fn: U_String;
  te: THashTextEngine;
begin
  fn := umlChangeFileExt(Application.ExeName, '.conf');

  te := THashTextEngine.Create;

  te.SetDefaultValue('Main', JoinHostEdit.Name, JoinHostEdit.Text);
  te.SetDefaultValue('Main', JoinPortEdit.Name, JoinPortEdit.Text);

  te.SaveToFile(fn);
  DisposeObject(te);
end;

procedure TDTC40_UserDB_AdminToolForm.Do_QueryResult(Sender: TDTC40_PhysicsTunnel; L: TDTC40_InfoList);
var
  arry: TDTC40_Info_Array;
  i: Integer;
begin
  arry := L.SearchService(ExtractDependInfo(DependEdit.Text));
  for i := low(arry) to high(arry) do
      ValidService.Add(arry[i].Clone);

  serviceComboBox.Clear;
  for i := 0 to ValidService.Count - 1 do
      serviceComboBox.AddItem(Format('"%s" host "%s" port %d', [ValidService[i].ServiceTyp.Text, ValidService[i].PhysicsAddr.Text, ValidService[i].PhysicsPort]), ValidService[i]);

  if serviceComboBox.Items.Count > 0 then
      serviceComboBox.ItemIndex := 0;
end;

procedure TDTC40_UserDB_AdminToolForm.DoConnected;
begin
  SearchButtonClick(SearchButton);
end;

procedure TDTC40_UserDB_AdminToolForm.DoDisconnect;
begin
  SysPost.PostExecuteP_NP(1.0, procedure
    begin
      serviceComboBox.Clear;
      UserListView.Items.Clear;
    end);
end;

procedure TDTC40_UserDB_AdminToolForm.Do_Usr_IsOpen(Sender: TDTC40_UserDB_Client; State_: TArrayBool);
var
  itm: TUsr_Item;
  i: Integer;
begin
  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      itm.SubItems[2] := umlBoolToStr(State_[i]);
      itm.Ready := True;
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.Do_Usr_Serarch(Sender: TPeerIO; Result_: TDFE);
var
  itm: TUsr_Item;
  i: Integer;
  arry: U_StringArray;
begin
  if CurrentClient = nil then
      exit;
  UserListView.Items.BeginUpdate;
  UserListView.Items.Clear;
  while Result_.R.NotEnd do
    begin
      itm := UserListView.Items.Add as TUsr_Item;
      itm.json.ParseText(Result_.R.ReadString);
      itm.PrimaryIdentifier := itm.json.S['PrimaryIdentifier'];
      itm.Caption := itm.PrimaryIdentifier;
      itm.SubItems.Add(DateTimeToStr(itm.json.D['LastAuth']));
      itm.SubItems.Add(umlBoolToStr(itm.json.B['Enabled']));
      itm.SubItems.Add('...');
    end;
  UserListView.Items.EndUpdate;
  UserListView.Height := UserListView.Height - 1;
  SetLength(arry, UserListView.Items.Count);
  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      arry[i] := itm.PrimaryIdentifier;
    end;
  CurrentClient.Usr_IsOpenM(arry, Do_Usr_IsOpen);
end;

procedure TDTC40_UserDB_AdminToolForm.RefreshUserList(Text_: U_String; maxNum_: Integer);
var
  i: Integer;
  itm: TUsr_Item;
begin
  if CurrentClient = nil then
      exit;

  for i := 0 to UserListView.Items.Count - 1 do
    begin
      itm := UserListView.Items[i] as TUsr_Item;
      if not itm.Ready then
        begin
          DoStatus('busy.');
          exit;
        end;
    end;

  CurrentClient.Usr_SearchM(Text_, maxNum_, Do_Usr_Serarch);
end;

procedure TDTC40_UserDB_AdminToolForm.Do_Usr_OnlineNum(Sender: TDTC40_UserDB_Client; Online_Num, User_Num: Integer);
begin
  ShowMessage(Format('online:%d registated user:%d', [Online_Num, User_Num]));
end;

procedure TDTC40_UserDB_AdminToolForm.DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
begin

end;

procedure TDTC40_UserDB_AdminToolForm.DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
begin
  if Sender.DependNetworkClientPool.IndexOf(CurrentClient) >= 0 then
    begin
      DoDisconnect;
      ValidService.Clear;
      CurrentClient := nil;
    end;
end;

procedure TDTC40_UserDB_AdminToolForm.DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin

end;

procedure TDTC40_UserDB_AdminToolForm.DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
var
  info: TDTC40_Info;
begin
  if serviceComboBox.ItemIndex < 0 then
      exit;
  info := TDTC40_Info(serviceComboBox.Items.Objects[serviceComboBox.ItemIndex]);
  if info.Same(Custom_Client_.ClientInfo) and (Custom_Client_ is TDTC40_UserDB_Client) then
    begin
      CurrentClient := TDTC40_UserDB_Client(Custom_Client_);
      DoConnected;
    end;
end;

constructor TDTC40_UserDB_AdminToolForm.Create(AOwner: TComponent);
var
  i: Integer;
  p: PDTC40_RegistedData;
  depend_: U_String;
begin
  inherited Create(AOwner);
  DTC40_QuietMode := False;
  AddDoStatusHook(self, DoStatus_backcall);
  InitGlobalMedia([gmtDict]);

  DTC4PasswdEdit.Text := DTC40.DTC40_Password;
  ReadConfig;
  ValidService := TDTC40_InfoList.Create(True);
  CurrentClient := nil;

  depend_ := '';
  for i := 0 to DTC40_Registed.Count - 1 do
    begin
      p := DTC40_Registed[i];
      if p^.ClientClass.InheritsFrom(TDTC40_UserDB_Client) then
        begin
          if depend_.L > 0 then
              depend_.Append('|');
          depend_.Append(p^.ServiceTyp);
        end;
    end;
  DependEdit.Text := depend_;
end;

destructor TDTC40_UserDB_AdminToolForm.Destroy;
begin
  C40Clean;
  RemoveDoStatusHook(self);
  inherited Destroy;
end;

end.
