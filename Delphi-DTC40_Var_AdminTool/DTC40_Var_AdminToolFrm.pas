unit DTC40_Var_AdminToolFrm;

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
  PhysicsIO;

type
  TDTC40_Var_AdminToolForm = class(TForm, IDTC40_PhysicsTunnel_Event)
    logMemo: TMemo;
    botSplitter: TSplitter;
    TopBarPanel: TPanel;
    JoinHostEdit: TLabeledEdit;
    JoinPortEdit: TLabeledEdit;
    DependEdit: TLabeledEdit;
    BuildDependNetButton: TButton;
    resetDependButton: TButton;
    serviceComboBox: TComboBox;
    queryButton: TButton;
    DTC4PasswdEdit: TLabeledEdit;
    netTimer: TTimer;
    cliPanel: TPanel;
    ActionList_: TActionList;
    MainMenu_: TMainMenu;
    File1: TMenuItem;
    NM_PopupMenu_: TPopupMenu;
    leftPanel: TPanel;
    listToolBarPanel: TPanel;
    SearchEdit: TLabeledEdit;
    SearchButton: TButton;
    NumEdit: TLabeledEdit;
    NMListView: TListView;
    lpLSplitter: TSplitter;
    rCliPanel: TPanel;
    VarListView: TListView;
    ScriptEdit: TLabeledEdit;
    RunScriptButton: TButton;
    Action_NewNM: TAction;
    NewNumberModule1: TMenuItem;
    NewNumberModule2: TMenuItem;
    Action_RemoveNM: TAction;
    RemoveNumberModule1: TMenuItem;
    RemoveNumberModule2: TMenuItem;
    Action_RemoveNMKey: TAction;
    Var_PopupMenu_: TPopupMenu;
    RemoveKeyValue1: TMenuItem;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure netTimerTimer(Sender: TObject);
    procedure queryButtonClick(Sender: TObject);
    procedure DTC4PasswdEditChange(Sender: TObject);
    procedure BuildDependNetButtonClick(Sender: TObject);
    procedure resetDependButtonClick(Sender: TObject);
    procedure NMListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure SearchButtonClick(Sender: TObject);
    procedure NMListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure RunScriptButtonClick(Sender: TObject);
    procedure VarListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure Action_NewNMExecute(Sender: TObject);
    procedure Action_RemoveNMExecute(Sender: TObject);
    procedure Action_RemoveNMKeyExecute(Sender: TObject);
  private
    procedure DoStatus_backcall(Text_: SystemString; const ID: Integer);
    procedure ReadConfig;
    procedure WriteConfig;
    procedure Do_QueryResult(Sender: TDTC40_PhysicsTunnel; L: TDTC40_InfoList);
    procedure DoConnected;
    procedure DoDisconnect;
    procedure Do_NM_Search(Sender: TDTC40_Var_Client; NMPool_: TDTC40_Var_NumberModulePool_List);
    procedure SearchNM(filter: U_String; MaxNum: Integer);
    procedure Do_NM_Script(Sender: TDTC40_Var_Client; Result_: TExpressionValueVector);
    procedure RunScript(Exp: U_String);
  private
    // IDTC40_PhysicsTunnel_Event
    procedure DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
    procedure DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
    // NM Event
    procedure Do_DTC40_Var_NM_Change(Sender: TDTC40_Var_Client; NMPool_: TDTC40_VarService_NM_Pool; NM: TNumberModule);
    procedure Do_DTC40_Var_Client_NM_Remove(Sender: TDTC40_Var_Client; NMName: U_String);
  private
    FCurrentNM: TDTC40_VarService_NM_Pool;
    procedure SetCurrentNM(const Value: TDTC40_VarService_NM_Pool);
  public
    ValidService: TDTC40_InfoList;
    CurrentClient: TDTC40_Var_Client;
    property CurrentNM: TDTC40_VarService_NM_Pool read FCurrentNM write SetCurrentNM;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TNM_Item = class(TListItem)
  public
    NM: TDTC40_VarService_NM_Pool;
  end;

  TNumber_Item = class(TListItem)
  public
    Number: TNumberModule;
  end;

var
  DTC40_Var_AdminToolForm: TDTC40_Var_AdminToolForm;

implementation

{$R *.dfm}


uses DTC40_Var_AdminToolNewNMFrm;

procedure TDTC40_Var_AdminToolForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteConfig;
  CloseAction := caFree;
end;

procedure TDTC40_Var_AdminToolForm.netTimerTimer(Sender: TObject);
begin
  C40Progress;
end;

procedure TDTC40_Var_AdminToolForm.queryButtonClick(Sender: TObject);
var
  tunnel_: TDTC40_PhysicsTunnel;
begin
  tunnel_ := DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(JoinHostEdit.Text, EStrToInt(JoinPortEdit.Text, 0));
  tunnel_.QueryInfoM(Do_QueryResult);
end;

procedure TDTC40_Var_AdminToolForm.DTC4PasswdEditChange(Sender: TObject);
begin
  DTC40.DTC40_Password := DTC4PasswdEdit.Text;
end;

procedure TDTC40_Var_AdminToolForm.BuildDependNetButtonClick(Sender: TObject);
var
  info: TDTC40_Info;
begin
  if serviceComboBox.ItemIndex < 0 then
      exit;
  info := TDTC40_Info(serviceComboBox.Items.Objects[serviceComboBox.ItemIndex]);
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(info, info.ServiceTyp, self);
end;

procedure TDTC40_Var_AdminToolForm.resetDependButtonClick(Sender: TObject);
begin
  C40Clean;
end;

procedure TDTC40_Var_AdminToolForm.NMListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TNM_Item;
end;

procedure TDTC40_Var_AdminToolForm.SearchButtonClick(Sender: TObject);
begin
  SearchNM(SearchEdit.Text, EStrToInt(NumEdit.Text, 100));
end;

procedure TDTC40_Var_AdminToolForm.NMListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
      CurrentNM := TNM_Item(Item).NM
  else
      CurrentNM := nil;
end;

procedure TDTC40_Var_AdminToolForm.RunScriptButtonClick(Sender: TObject);
begin
  RunScript(ScriptEdit.Text);
end;

procedure TDTC40_Var_AdminToolForm.VarListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TNumber_Item;
end;

procedure TDTC40_Var_AdminToolForm.Action_NewNMExecute(Sender: TObject);
begin
  if CurrentClient = nil then
      exit;
  DTC40_Var_AdminToolNewNMForm.Show;
end;

procedure TDTC40_Var_AdminToolForm.Action_RemoveNMExecute(Sender: TObject);
var
  i: Integer;
  itm: TNM_Item;
begin
  if CurrentClient = nil then
      exit;
  i := 0;
  while i < NMListView.Items.Count do
    begin
      itm := NMListView.Items[i] as TNM_Item;
      if itm.Selected then
        begin
          if CurrentNM = itm.NM then
              CurrentNM := nil;
          CurrentClient.NM_Remove(itm.NM.Name, False);
          NMListView.Items.Delete(i);
        end
      else
          inc(i);
    end;
end;

procedure TDTC40_Var_AdminToolForm.Action_RemoveNMKeyExecute(Sender: TObject);
var
  i: Integer;
  itm: TNumber_Item;
begin
  if CurrentClient = nil then
      exit;
  i := 0;
  while i < VarListView.Items.Count do
    begin
      itm := VarListView.Items[i] as TNumber_Item;
      if itm.Selected then
        begin
          CurrentClient.NM_RemoveKey(CurrentNM.Name, itm.Number.Name, False);
          VarListView.Items.Delete(i);
        end
      else
          inc(i);
    end;
end;

procedure TDTC40_Var_AdminToolForm.DoStatus_backcall(Text_: SystemString; const ID: Integer);
begin
  if logMemo.Lines.Count > 2000 then
      logMemo.Clear;
  logMemo.Lines.Add(DateTimeToStr(now) + ' ' + Text_);
end;

procedure TDTC40_Var_AdminToolForm.ReadConfig;
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

procedure TDTC40_Var_AdminToolForm.WriteConfig;
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

procedure TDTC40_Var_AdminToolForm.Do_QueryResult(Sender: TDTC40_PhysicsTunnel; L: TDTC40_InfoList);
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

procedure TDTC40_Var_AdminToolForm.DoConnected;
begin
  SearchButtonClick(SearchButton);
end;

procedure TDTC40_Var_AdminToolForm.DoDisconnect;
begin
  SysPost.PostExecuteP_NP(1.0, procedure
    begin
      serviceComboBox.Clear;
      NMListView.Items.Clear;
    end);
end;

procedure TDTC40_Var_AdminToolForm.Do_NM_Search(Sender: TDTC40_Var_Client; NMPool_: TDTC40_Var_NumberModulePool_List);
var
  i: Integer;
  itm: TNM_Item;
begin
  NMListView.Items.BeginUpdate;
  NMListView.Items.Clear;
  for i := 0 to NMPool_.Count - 1 do
    begin
      itm := NMListView.Items.Add as TNM_Item;
      itm.NM := NMPool_[i];
      itm.Caption := itm.NM.Name;
    end;
  NMListView.Items.EndUpdate;
end;

procedure TDTC40_Var_AdminToolForm.SearchNM(filter: U_String; MaxNum: Integer);
begin
  if CurrentClient = nil then
      exit;
  CurrentNM := nil;
  NMListView.Clear;
  CurrentClient.NM_CloseAll(True);
  CurrentClient.NM_SearchM(filter, MaxNum, True, Do_NM_Search);
end;

procedure TDTC40_Var_AdminToolForm.Do_NM_Script(Sender: TDTC40_Var_Client; Result_: TExpressionValueVector);
begin
  DoStatusE(Result_);
end;

procedure TDTC40_Var_AdminToolForm.RunScript(Exp: U_String);
var
  i: Integer;
  itm: TNM_Item;
begin
  if CurrentClient = nil then
      exit;
  if NMListView.SelCount = 0 then
      exit;
  if NMListView.SelCount = 1 then
    begin
      itm := NMListView.Selected as TNM_Item;
      CurrentClient.NM_ScriptM(itm.NM.Name, [Exp.Text], Do_NM_Script);
      exit;
    end;
  for i := 0 to NMListView.Items.Count - 1 do
    begin
      itm := NMListView.Items[i] as TNM_Item;
      if itm.Selected then
          CurrentClient.NM_ScriptM(itm.NM.Name, [Exp.Text], Do_NM_Script);
    end;
end;

procedure TDTC40_Var_AdminToolForm.DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
begin

end;

procedure TDTC40_Var_AdminToolForm.DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
begin
  if Sender.DependNetworkClientPool.IndexOf(CurrentClient) >= 0 then
    begin
      DoDisconnect;
      ValidService.Clear;
      CurrentClient := nil;
      CurrentNM := nil;
    end;
end;

procedure TDTC40_Var_AdminToolForm.DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin

end;

procedure TDTC40_Var_AdminToolForm.DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
var
  info: TDTC40_Info;
begin
  if serviceComboBox.ItemIndex < 0 then
      exit;
  info := TDTC40_Info(serviceComboBox.Items.Objects[serviceComboBox.ItemIndex]);
  if info.Same(Custom_Client_.ClientInfo) and (Custom_Client_ is TDTC40_Var_Client) then
    begin
      CurrentClient := TDTC40_Var_Client(Custom_Client_);
      CurrentClient.OnChange := Do_DTC40_Var_NM_Change;
      CurrentClient.OnRemove := Do_DTC40_Var_Client_NM_Remove;
      SysPost.PostExecuteM_NP(0.5, DoConnected);
    end;
end;

procedure TDTC40_Var_AdminToolForm.Do_DTC40_Var_NM_Change(Sender: TDTC40_Var_Client; NMPool_: TDTC40_VarService_NM_Pool; NM: TNumberModule);
var
  i: Integer;
  itm: TNumber_Item;
  found_: Boolean;
begin
  if CurrentNM <> NMPool_ then
      exit;
  found_ := False;
  for i := 0 to VarListView.Items.Count - 1 do
    begin
      itm := VarListView.Items[i] as TNumber_Item;
      if itm.Number = NM then
        begin
          itm.SubItems[0] := NM.CurrentAsString;
          found_ := True;
        end;
    end;
  if not found_ then
    begin
      itm := VarListView.Items.Add as TNumber_Item;
      itm.Number := NM;
      itm.Caption := NM.Name;
      itm.SubItems.Add(NM.CurrentAsString);
    end;
end;

procedure TDTC40_Var_AdminToolForm.Do_DTC40_Var_Client_NM_Remove(Sender: TDTC40_Var_Client; NMName: U_String);
var
  i: Integer;
  itm: TNM_Item;
begin
  if (CurrentNM <> nil) and (NMName.Same(CurrentNM.Name)) then
      VarListView.Clear;

  i := 0;
  while i < NMListView.Items.Count do
    begin
      itm := NMListView.Items[i] as TNM_Item;
      if itm.NM.Name.Same(NMName) then
          NMListView.Items.Delete(i)
      else
          inc(i);
    end;
end;

procedure TDTC40_Var_AdminToolForm.SetCurrentNM(const Value: TDTC40_VarService_NM_Pool);
begin
  VarListView.Clear;
  FCurrentNM := Value;
  if FCurrentNM = nil then
      exit;
  VarListView.Items.BeginUpdate;
  FCurrentNM.List.ProgressP(procedure(const Name_: PSystemString; Obj_: TNumberModule)
    var
      itm: TNumber_Item;
    begin
      itm := VarListView.Items.Add as TNumber_Item;
      itm.Number := Obj_;
      itm.Caption := Obj_.Name;
      itm.SubItems.Add(Obj_.CurrentAsString);
    end);
  VarListView.Items.EndUpdate;
end;

constructor TDTC40_Var_AdminToolForm.Create(AOwner: TComponent);
var
  i: Integer;
  p: PDTC40_RegistedData;
  depend_: U_String;
begin
  inherited Create(AOwner);
  DTC40_QuietMode := False;
  AddDoStatusHook(self, DoStatus_backcall);

  DTC4PasswdEdit.Text := DTC40.DTC40_Password;
  ReadConfig;
  ValidService := TDTC40_InfoList.Create(True);
  CurrentClient := nil;
  CurrentNM := nil;

  depend_ := '';
  for i := 0 to DTC40_Registed.Count - 1 do
    begin
      p := DTC40_Registed[i];
      if p^.ClientClass.InheritsFrom(TDTC40_Var_Client) then
        begin
          if depend_.L > 0 then
              depend_.Append('|');
          depend_.Append(p^.ServiceTyp);
        end;
    end;
  DependEdit.Text := depend_;
end;

destructor TDTC40_Var_AdminToolForm.Destroy;
begin
  C40Clean;
  RemoveDoStatusHook(self);
  inherited Destroy;
end;

end.
