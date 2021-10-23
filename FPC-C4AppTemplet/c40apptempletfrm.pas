unit c40apptempletfrm;

{$mode objfpc}{$H+}
{$MODESWITCH AdvancedRecords}
{$MODESWITCH NestedProcVars}
{$MODESWITCH NESTEDCOMMENTS}
{$NOTES OFF}
{$STACKFRAMES OFF}
{$COPERATORS OFF}
{$GOTO ON}
{$INLINE ON}
{$MACRO ON}
{$HINTS ON}
{$IEEEERRORS ON}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  Variants, FileCtrl, DateUtils, TypInfo,

  CoreClasses, PascalStrings, UPascalStrings, UnicodeMixedLib, DoStatusIO,
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
  TC40AppTempletForm = class(TForm)
    logMemo: TMemo;
    botSplitter: TSplitter;
    PGControl: TPageControl;
    BuildNetworkTabSheet: TTabSheet;
    netTimer: TTimer;
    OptTabSheet: TTabSheet;
    DependNetToolPanel: TPanel;
    JoinHostEdit: TLabeledEdit;
    JoinPortEdit: TLabeledEdit;
    BuildDependNetButton: TButton;
    resetDependButton: TButton;
    DependEdit: TLabeledEdit;
    RependNetListView: TListView;
    DependPanel: TPanel;
    servicePanel: TPanel;
    net_Top_Splitter: TSplitter;
    ServiceToolPanel: TPanel;
    Label1: TLabel;
    ServIPEdit: TLabeledEdit;
    ServPortEdit: TLabeledEdit;
    ServiceDependEdit: TLabeledEdit;
    ServBuildNetButton: TButton;
    ServiceListView: TListView;
    LocalServiceStates_TabSheet: TTabSheet;
    QuietCheckBox: TCheckBox;
    SafeCheckTimerEdit: TLabeledEdit;
    PhysicsReconnectionDelayEdit: TLabeledEdit;
    UpdateServiceInfoTimerEdit: TLabeledEdit;
    PhysicsServiceTimeoutEdit: TLabeledEdit;
    PhysicsTunnelTimeoutEdit: TLabeledEdit;
    KillIDCFaultTimeoutEdit: TLabeledEdit;
    RootDirectoryEdit: TLabeledEdit;
    passwdEdit: TLabeledEdit;
    ApplyOptButton: TButton;
    ResetOptButton: TButton;
    ServiceResetButton: TButton;
    ServiceInfoMemo: TMemo;
    TunnelStatesTabSheet: TTabSheet;
    TunnelInfoMemo: TMemo;
    ServInfoPhyAddrListBox: TListBox;
    localserinfoLSplitter: TSplitter;
    TunnelInfoPhyAddrListBox: TListBox;
    tunnel_infoLSplitter: TSplitter;
    UpdateStateTimer: TTimer;
    SaaS_Network_States_TabSheet: TTabSheet;
    SaaS_Info_TreeView: TTreeView;
    cmd_tool_TabSheet: TTabSheet;
    cmdLineParamEdit: TLabeledEdit;
    GenerateCmdLineButton: TButton;
    cmdLineTitleEdit: TLabeledEdit;
    cmdLineAppTitleEdit: TLabeledEdit;
    procedure netTimerTimer(Sender: TObject);
    procedure UpdateStateTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure DependEditChange(Sender: TObject);
    procedure DependEditExit(Sender: TObject);
    procedure RependNetListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure BuildDependNetButtonClick(Sender: TObject);
    procedure resetDependButtonClick(Sender: TObject);
    procedure ServiceDependEditChange(Sender: TObject);
    procedure ServiceDependEditExit(Sender: TObject);
    procedure ServiceListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ServBuildNetButtonClick(Sender: TObject);
    procedure ServiceResetButtonClick(Sender: TObject);
    procedure ApplyOptButtonClick(Sender: TObject);
    procedure ResetOptButtonClick(Sender: TObject);
    procedure ServInfoPhyAddrListBoxClick(Sender: TObject);
    procedure TunnelInfoPhyAddrListBoxClick(Sender: TObject);
    procedure GenerateCmdLineButtonClick(Sender: TObject);
  private
    procedure DoStatus_backcall(Text_: SystemString; const ID: Integer);
    procedure ReadConfig;
    procedure WriteConfig;
    function RebuildDependInfo(sour: U_String): U_String;
    function RebuildServiceInfo(sour: U_String): U_String;
    procedure RefreshDependReg(info: U_String);
    procedure RefreshServiceReg(info: U_String);
    procedure ReloadOpt;
    procedure ApplyOpt;
    procedure UpdateServiceInfo; overload;
    procedure UpdateServiceInfo(phy_serv: TDTC40_PhysicsService; dest: TStrings); overload;
    procedure UpdateTunnelInfo; overload;
    procedure UpdateTunnelInfo(phy_tunnel: TDTC40_PhysicsTunnel; dest: TStrings); overload;
    procedure UpdateSaaSInfo;
    class function GetPathTreeNode(Text_, Split_: U_String; TreeView_: TTreeView; RootNode_: TTreeNode): TTreeNode;
  public
    IsCommandLineWorkEnvir: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExtractAndProcessCmdLine(param_: U_StringArray): Boolean;
  end;

var
  C40AppTempletForm: TC40AppTempletForm;
  C40AppParam: U_StringArray;
  On_DTC40_PhysicsTunnel_Event: IDTC40_PhysicsTunnel_Event = nil;
  On_DTC40_PhysicsService_Event: IDTC40_PhysicsService_Event = nil;

implementation

{$R *.lfm}

type
  // app.exe "Quiet(False),SafeCheckTime(SafeCheckTime+999),serv('127.0.0.1', 28989, 'DP|NA'),Tunnel('127.0.0.1', 28989, 'DP')"
  TCommand_Struct = class
  private
    function Do_Config(var OP_Param: TOpParam): Variant;
    function Do_Client(var OP_Param: TOpParam): Variant;
    function Do_Service(var OP_Param: TOpParam): Variant;
  public
    opRT: TOpCustomRunTime;
    Config: THashStringList;
    ConfigIsUpdate: Boolean;
    client_ip: string;
    client_port: Word;
    client_depend: string;
    service_ip: string;
    service_port: Word;
    service_depend: string;
    constructor Create;
    destructor Destroy; override;
    procedure Parsing(expression: U_String);
  end;

function TCommand_Struct.Do_Config(var OP_Param: TOpParam): Variant;
begin
  if length(OP_Param) > 0 then
    begin
      Config.SetDefaultValue(opRT.Trigger^.Name, VarToStr(OP_Param[0]));
      Result := True;
      ConfigIsUpdate := True;
    end
  else
      Result := Config[opRT.Trigger^.Name];
end;

function TCommand_Struct.Do_Client(var OP_Param: TOpParam): Variant;
begin
  client_ip := OP_Param[0];
  client_port := OP_Param[1];
  client_depend := OP_Param[2];
  Result := True;
end;

function TCommand_Struct.Do_Service(var OP_Param: TOpParam): Variant;
begin
  service_ip := OP_Param[0];
  service_port := OP_Param[1];
  service_depend := OP_Param[2];
  Result := True;
end;

constructor TCommand_Struct.Create;
var
  L: TListPascalString;
  i: Integer;
begin
  inherited Create;
  opRT := TOpCustomRunTime.Create;

  Config := THashStringList.Create;
  DTC40.C40WriteConfig(Config);
  Config.SetDefaultValue('Root', DTC40.DTC40_RootPath);
  Config.SetDefaultValue('Password', DTC40.DTC40_Password);
  Config.SetDefaultValue('Title', C40AppTempletForm.Caption);
  Config.SetDefaultValue('AppTitle', Application.Title);
  ConfigIsUpdate := False;

  L := TListPascalString.Create;
  Config.GetNameList(L);
  for i := 0 to L.Count - 1 do
    begin
      opRT.RegOpM(L[i], @Do_Config);
    end;
  disposeObject(L);

  opRT.RegOpM('Service', @Do_Service);
  opRT.RegOpM('Serv', @Do_Service);
  opRT.RegOpM('Listen', @Do_Service);
  opRT.RegOpM('Listening', @Do_Service);
  opRT.RegOpM('Client', @Do_Client);
  opRT.RegOpM('Cli', @Do_Client);
  opRT.RegOpM('Tunnel', @Do_Client);
  opRT.RegOpM('Connect', @Do_Client);
  opRT.RegOpM('Connection', @Do_Client);
  opRT.RegOpM('Net', @Do_Client);
  opRT.RegOpM('Build', @Do_Client);

  client_ip := '';
  client_port := 0;
  client_depend := '';
  service_ip := '';
  service_port := 0;
  service_depend := '';
end;

destructor TCommand_Struct.Destroy;
begin
  disposeObject(opRT);
  disposeObject(Config);
  inherited Destroy;
end;

procedure TCommand_Struct.Parsing(expression: U_String);
begin
  EvaluateExpressionValue(False, tsPascal, expression, opRT);
  if ConfigIsUpdate then
    begin
      DTC40.C40ReadConfig(Config);
      DTC40.DTC40_RootPath := Config.GetDefaultValue('Root', DTC40.DTC40_RootPath);
      if not umlDirectoryExists(DTC40.DTC40_RootPath) then
          umlCreateDirectory(DTC40.DTC40_RootPath);
      DTC40.DTC40_Password := Config.GetDefaultValue('Password', DTC40.DTC40_Password);
      C40AppTempletForm.Caption := Config.GetDefaultValue('Title', C40AppTempletForm.Caption);
      Application.Title := Config.GetDefaultValue('AppTitle', Application.Title);
    end;
end;

procedure TC40AppTempletForm.netTimerTimer(Sender: TObject);
begin
  C40Progress;
end;

procedure TC40AppTempletForm.UpdateStateTimerTimer(Sender: TObject);
begin
  if WindowState = wsMinimized then
      exit;
  UpdateServiceInfo;
  UpdateTunnelInfo;
  UpdateSaaSInfo;
end;

procedure TC40AppTempletForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteConfig;
  CloseAction := caFree;
end;

procedure TC40AppTempletForm.DependEditChange(Sender: TObject);
var
  i, j: Integer;
  p: PDTC40_RegistedData;
  arry: TDTC40_DependNetworkInfoArray;
  found_: Boolean;
begin
  RependNetListView.OnChange := nil;
  arry := ExtractDependInfo(DependEdit.Text);
  for i := 0 to RependNetListView.Items.Count - 1 do
    begin
      p := RependNetListView.Items[i].Data;
      found_ := False;
      for j := Low(arry) to high(arry) do
        if arry[j].Typ.Same(@p^.ServiceTyp) then
          begin
            found_ := True;
            break;
          end;
      RependNetListView.Items[i].Checked := found_;
    end;
  RependNetListView.OnChange := @RependNetListViewChange;
end;

procedure TC40AppTempletForm.DependEditExit(Sender: TObject);
begin
  DependEdit.OnChange := nil;
  DependEdit.Text := RebuildDependInfo(DependEdit.Text);
  DependEdit.OnChange := @DependEditChange;
end;

procedure TC40AppTempletForm.RependNetListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  DependEdit.OnChange := nil;
  DependEdit.Text := RebuildDependInfo(DependEdit.Text);
  DependEdit.OnChange := @DependEditChange;
end;

procedure TC40AppTempletForm.BuildDependNetButtonClick(Sender: TObject);
begin
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(JoinHostEdit.Text, EStrToInt(JoinPortEdit.Text, 0), DependEdit.Text, On_DTC40_PhysicsTunnel_Event);
end;

procedure TC40AppTempletForm.resetDependButtonClick(Sender: TObject);
begin
  C40Clean_Client;
end;

procedure TC40AppTempletForm.ServiceDependEditChange(Sender: TObject);
var
  i, j: Integer;
  p: PDTC40_RegistedData;
  arry: TDTC40_DependNetworkInfoArray;
  found_: Boolean;
begin
  ServiceListView.OnChange := nil;
  arry := ExtractDependInfo(ServiceDependEdit.Text);
  for i := 0 to ServiceListView.Items.Count - 1 do
    begin
      p := ServiceListView.Items[i].Data;
      found_ := False;
      for j := Low(arry) to high(arry) do
        if arry[j].Typ.Same(@p^.ServiceTyp) then
          begin
            found_ := True;
            break;
          end;
      ServiceListView.Items[i].Checked := found_;
    end;
  ServiceListView.OnChange := @ServiceListViewChange;
end;

procedure TC40AppTempletForm.ServiceDependEditExit(Sender: TObject);
begin
  ServiceDependEdit.OnChange := nil;
  ServiceDependEdit.Text := RebuildServiceInfo(ServiceDependEdit.Text);
  ServiceDependEdit.OnChange := @ServiceDependEditChange;
end;

procedure TC40AppTempletForm.ServiceListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  ServiceDependEdit.OnChange := nil;
  ServiceDependEdit.Text := RebuildServiceInfo(ServiceDependEdit.Text);
  ServiceDependEdit.OnChange := @ServiceDependEditChange;
end;

procedure TC40AppTempletForm.ServBuildNetButtonClick(Sender: TObject);
begin
  with DTC40.TDTC40_PhysicsService.Create(ServIPEdit.Text, EStrToInt(ServPortEdit.Text, 0), PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork(ServiceDependEdit.Text);
      OnEvent := On_DTC40_PhysicsService_Event;
      StartService;
    end;
end;

procedure TC40AppTempletForm.ServiceResetButtonClick(Sender: TObject);
begin
  DTC40.C40Clean_Service;
end;

procedure TC40AppTempletForm.ApplyOptButtonClick(Sender: TObject);
begin
  ApplyOpt;
end;

procedure TC40AppTempletForm.ResetOptButtonClick(Sender: TObject);
begin
  C40ResetDefaultConfig;
  ReloadOpt;
end;

procedure TC40AppTempletForm.ServInfoPhyAddrListBoxClick(Sender: TObject);
var
  i: Integer;
begin
  ServiceInfoMemo.Lines.BeginUpdate;
  for i := 0 to ServInfoPhyAddrListBox.Items.Count - 1 do
    if ServInfoPhyAddrListBox.Selected[i] then
      begin
        ServiceInfoMemo.Clear;
        UpdateServiceInfo(ServInfoPhyAddrListBox.Items.Objects[i] as TDTC40_PhysicsService, ServiceInfoMemo.Lines);
      end;
  ServiceInfoMemo.Lines.EndUpdate;
end;

procedure TC40AppTempletForm.TunnelInfoPhyAddrListBoxClick(Sender: TObject);
var
  i: Integer;
begin
  TunnelInfoMemo.Lines.BeginUpdate;
  for i := 0 to TunnelInfoPhyAddrListBox.Items.Count - 1 do
    if TunnelInfoPhyAddrListBox.Selected[i] then
      begin
        TunnelInfoMemo.Clear;
        UpdateTunnelInfo(TunnelInfoPhyAddrListBox.Items.Objects[i] as TDTC40_PhysicsTunnel, TunnelInfoMemo.Lines);
      end;
  TunnelInfoMemo.Lines.EndUpdate;
end;

procedure TC40AppTempletForm.GenerateCmdLineButtonClick(Sender: TObject);
var
  hs: THashStringList;
  param: TPascalStringList;
  final_param: U_String;
  i: Integer;
  procedure Do_Near_Progress(Sender: THashStringList; Name_: PSystemString; const V: SystemString);
      begin
        if DTC40_DefaultConfig.GetDefaultValue(Name_^, V) <> V then
            param.Add(Format('%s(%s)', [Name_^, V]));
      end;
begin
  hs := THashStringList.Create;
  DTC40.C40WriteConfig(hs);

  param := TPascalStringList.Create;

  param.Add(Format('Title(' + #39 + '%s' + #39 + ')', [cmdLineTitleEdit.Text]));
  param.Add(Format('AppTitle(' + #39 + '%s' + #39 + ')', [cmdLineAppTitleEdit.Text]));
  param.Add(Format('Password(' + #39 + '%s' + #39 + ')', [DTC40.DTC40_Password]));
  hs.ProgressP(@Do_Near_Progress);

  if (ServIPEdit.Text <> '') and (ServPortEdit.Text <> '') and (ServiceDependEdit.Text <> '') then
      param.Add(Format('Service(' + #39 + '%s' + #39 + ',%s,' + #39 + '%s' + #39 + ')', [ServIPEdit.Text, ServPortEdit.Text, ServiceDependEdit.Text]));

  if (JoinHostEdit.Text <> '') and (JoinPortEdit.Text <> '') and (DependEdit.Text <> '') then
      param.Add(Format('Tunnel(' + #39 + '%s' + #39 + ',%s,' + #39 + '%s' + #39 + ')', [JoinHostEdit.Text, JoinPortEdit.Text, DependEdit.Text]));

  final_param := '"';
  for i := 0 to param.Count - 1 do
    begin
      if i > 0 then
          final_param.Append(',');
      final_param.Append(param[i]);
    end;
  final_param.Append('"');
  cmdLineParamEdit.Text := final_param;

  disposeObject(hs);
  disposeObject(param);
end;

procedure TC40AppTempletForm.DoStatus_backcall(Text_: SystemString; const ID: Integer);
begin
  if logMemo.Lines.Count > 2000 then
    begin
      logMemo.Lines.BeginUpdate;
      while logMemo.Lines.Count > 500 do
          logMemo.Lines.Delete(0);
      logMemo.Lines.EndUpdate;
    end;
  logMemo.Lines.Add(DateTimeToStr(now) + ' ' + Text_);
end;

procedure TC40AppTempletForm.ReadConfig;
var
  fn: U_String;
  te: THashTextEngine;
begin
  if IsCommandLineWorkEnvir then
      exit;
  fn := umlChangeFileExt(Application.ExeName, '.conf');
  if not umlFileExists(fn) then
      exit;
  te := THashTextEngine.Create;
  te.LoadFromFile(fn);
  DTC40.C40ReadConfig(te.HStringList['Sys']);
  ReloadOpt;

  JoinHostEdit.Text := te.GetDefaultValue('Main', JoinHostEdit.Name, JoinHostEdit.Text);
  JoinPortEdit.Text := te.GetDefaultValue('Main', JoinPortEdit.Name, JoinPortEdit.Text);
  DependEdit.Text := te.GetDefaultValue('Main', DependEdit.Name, DependEdit.Text);
  DependEditExit(DependEdit);

  ServIPEdit.Text := te.GetDefaultValue('Main', ServIPEdit.Name, ServIPEdit.Text);
  ServPortEdit.Text := te.GetDefaultValue('Main', ServPortEdit.Name, ServPortEdit.Text);
  ServiceDependEdit.Text := te.GetDefaultValue('Main', ServiceDependEdit.Name, ServiceDependEdit.Text);
  ServiceDependEditExit(ServiceDependEdit);
  disposeObject(te);
end;

procedure TC40AppTempletForm.WriteConfig;
var
  fn: U_String;
  te: THashTextEngine;
begin
  if IsCommandLineWorkEnvir then
      exit;
  fn := umlChangeFileExt(Application.ExeName, '.conf');

  te := THashTextEngine.Create;
  ApplyOpt;
  DTC40.C40WriteConfig(te.HStringList['Sys']);

  te.SetDefaultValue('Main', JoinHostEdit.Name, JoinHostEdit.Text);
  te.SetDefaultValue('Main', JoinPortEdit.Name, JoinPortEdit.Text);
  te.SetDefaultValue('Main', DependEdit.Name, DependEdit.Text);

  te.SetDefaultValue('Main', ServIPEdit.Name, ServIPEdit.Text);
  te.SetDefaultValue('Main', ServPortEdit.Name, ServPortEdit.Text);
  te.SetDefaultValue('Main', ServiceDependEdit.Name, ServiceDependEdit.Text);

  te.SaveToFile(fn);
  disposeObject(te);
end;

function TC40AppTempletForm.RebuildDependInfo(sour: U_String): U_String;
var
  sourNet, destNet: TDTC40_DependNetworkInfoList;
  i, j: Integer;
  info: TDTC40_DependNetworkInfo;
  p: PDTC40_RegistedData;
begin
  Result := '';
  sourNet := ExtractDependInfoToL(sour);
  destNet := TDTC40_DependNetworkInfoList.Create;

  for i := 0 to RependNetListView.Items.Count - 1 do
    if RependNetListView.Items[i].Checked then
      begin
        p := RependNetListView.Items[i].Data;
        info.Typ := p^.ServiceTyp;
        for j := 0 to sourNet.Count - 1 do
          if sourNet[j].Typ.Same(@info.Typ) then
            begin
              info.param := sourNet[j].param;
              break;
            end;
        destNet.Add(info);
      end;

  for i := 0 to destNet.Count - 1 do
    begin
      if i > 0 then
          Result.Append('|');
      info := destNet[i];
      Result.Append(info.Typ);
      if info.param.L > 0 then
          Result.Append('@' + info.param);
    end;

  disposeObject(sourNet);
  disposeObject(destNet);
end;

function TC40AppTempletForm.RebuildServiceInfo(sour: U_String): U_String;
var
  sourNet, destNet: TDTC40_DependNetworkInfoList;
  i, j: Integer;
  info: TDTC40_DependNetworkInfo;
  p: PDTC40_RegistedData;
begin
  Result := '';
  sourNet := ExtractDependInfoToL(sour);
  destNet := TDTC40_DependNetworkInfoList.Create;

  for i := 0 to ServiceListView.Items.Count - 1 do
    if ServiceListView.Items[i].Checked then
      begin
        p := ServiceListView.Items[i].Data;
        info.Typ := p^.ServiceTyp;
        for j := 0 to sourNet.Count - 1 do
          if sourNet[j].Typ.Same(@info.Typ) then
            begin
              info.param := sourNet[j].param;
              break;
            end;
        destNet.Add(info);
      end;

  for i := 0 to destNet.Count - 1 do
    begin
      if i > 0 then
          Result.Append('|');
      info := destNet[i];
      Result.Append(info.Typ);
      if info.param.L > 0 then
          Result.Append('@' + info.param);
    end;

  disposeObject(sourNet);
  disposeObject(destNet);
end;

procedure TC40AppTempletForm.RefreshDependReg(info: U_String);
var
  i, j: Integer;
  p: PDTC40_RegistedData;
  arry: TDTC40_DependNetworkInfoArray;
begin
  RependNetListView.Items.BeginUpdate;
  RependNetListView.Items.Clear;
  for i := 0 to DTC40.DTC40_Registed.Count - 1 do
    begin
      p := DTC40.DTC40_Registed[i];
      if p^.ClientClass <> nil then
        with RependNetListView.Items.Add do
          begin
            Caption := p^.ServiceTyp;
            SubItems.Add(p^.ClientClass.ClassName);
            SubItems.Add(p^.ClientClass.UnitName + '.pas');
            Data := p;
          end;
    end;
  RependNetListView.Items.EndUpdate;

  arry := ExtractDependInfo(info);
  for i := 0 to RependNetListView.Items.Count - 1 do
    begin
      p := RependNetListView.Items[i].Data;
      for j := Low(arry) to high(arry) do
        if arry[j].Typ.Same(@p^.ServiceTyp) then
          begin
            RependNetListView.Items[i].Checked := True;
            break;
          end;
    end;
end;

procedure TC40AppTempletForm.RefreshServiceReg(info: U_String);
var
  i, j: Integer;
  p: PDTC40_RegistedData;
  arry: TDTC40_DependNetworkInfoArray;
begin
  ServiceListView.Items.BeginUpdate;
  ServiceListView.Items.Clear;
  for i := 0 to DTC40.DTC40_Registed.Count - 1 do
    begin
      p := DTC40.DTC40_Registed[i];
      if p^.ServiceClass <> nil then
        with ServiceListView.Items.Add do
          begin
            Caption := p^.ServiceTyp;
            SubItems.Add(p^.ServiceClass.ClassName);
            SubItems.Add(p^.ServiceClass.UnitName + '.pas');
            Data := p;
          end;
    end;
  ServiceListView.Items.EndUpdate;

  arry := ExtractDependInfo(info);
  for i := 0 to ServiceListView.Items.Count - 1 do
    begin
      p := ServiceListView.Items[i].Data;
      for j := Low(arry) to high(arry) do
        if arry[j].Typ.Same(@p^.ServiceTyp) then
          begin
            ServiceListView.Items[i].Checked := True;
            break;
          end;
    end;
end;

procedure TC40AppTempletForm.ReloadOpt;
begin
  QuietCheckBox.Checked := DTC40.DTC40_QuietMode;
  SafeCheckTimerEdit.Text := umlIntToStr(DTC40.DTC40_SafeCheckTime);
  PhysicsReconnectionDelayEdit.Text := umlShortFloatToStr(DTC40.DTC40_PhysicsReconnectionDelayTime);
  UpdateServiceInfoTimerEdit.Text := umlIntToStr(DTC40.DTC40_UpdateServiceInfoDelayTime);
  PhysicsServiceTimeoutEdit.Text := umlIntToStr(DTC40.DTC40_PhysicsServiceTimeout);
  PhysicsTunnelTimeoutEdit.Text := umlIntToStr(DTC40.DTC40_PhysicsTunnelTimeout);
  KillIDCFaultTimeoutEdit.Text := umlIntToStr(DTC40.DTC40_KillIDCFaultTimeout);
  RootDirectoryEdit.Text := DTC40.DTC40_RootPath;
  passwdEdit.Text := DTC40.DTC40_Password;
end;

procedure TC40AppTempletForm.ApplyOpt;
begin
  DTC40.C40SetQuietMode(QuietCheckBox.Checked);
  DTC40.DTC40_SafeCheckTime := EStrToInt(SafeCheckTimerEdit.Text, DTC40.DTC40_SafeCheckTime);
  DTC40.DTC40_PhysicsReconnectionDelayTime := EStrToDouble(PhysicsReconnectionDelayEdit.Text, DTC40.DTC40_PhysicsReconnectionDelayTime);
  DTC40.DTC40_UpdateServiceInfoDelayTime := EStrToInt(UpdateServiceInfoTimerEdit.Text, DTC40.DTC40_UpdateServiceInfoDelayTime);
  DTC40.DTC40_PhysicsServiceTimeout := EStrToInt(PhysicsServiceTimeoutEdit.Text, DTC40.DTC40_PhysicsServiceTimeout);
  DTC40.DTC40_PhysicsTunnelTimeout := EStrToInt(PhysicsTunnelTimeoutEdit.Text, DTC40.DTC40_PhysicsTunnelTimeout);
  DTC40.DTC40_KillIDCFaultTimeout := EStrToInt(KillIDCFaultTimeoutEdit.Text, DTC40.DTC40_KillIDCFaultTimeout);
  DTC40.DTC40_RootPath := RootDirectoryEdit.Text;
  DTC40.DTC40_Password := passwdEdit.Text;
end;

procedure TC40AppTempletForm.UpdateServiceInfo;
var
  i: Integer;
  phy_serv: TDTC40_PhysicsService;
begin
  for i := 0 to DTC40_PhysicsServicePool.Count - 1 do
    begin
      phy_serv := DTC40_PhysicsServicePool[i];
      if ServInfoPhyAddrListBox.Items.IndexOfObject(phy_serv) < 0 then
          ServInfoPhyAddrListBox.Items.AddObject(Format('service "%s" port:%d', [phy_serv.PhysicsAddr.Text, phy_serv.PhysicsPort]), phy_serv);
    end;

  i := 0;
  while i < ServInfoPhyAddrListBox.Items.Count do
    if DTC40_PhysicsServicePool.IndexOf(TDTC40_PhysicsService(ServInfoPhyAddrListBox.Items.Objects[i])) < 0 then
        ServInfoPhyAddrListBox.Items.Delete(i)
    else
        inc(i);
end;

procedure TC40AppTempletForm.UpdateServiceInfo(phy_serv: TDTC40_PhysicsService; dest: TStrings);
var
  i: Integer;
  custom_serv: TDTC40_Custom_Service;
begin
  dest.Add(Format('Physics service: "%s" Unit: "%s"', [phy_serv.PhysicsTunnel.ClassName, phy_serv.PhysicsTunnel.UnitName + '.pas']));
  dest.Add(Format('Physics service workload: %d', [phy_serv.PhysicsTunnel.Count]));
  dest.Add(Format('Physcis Listening ip: "%s" Port: %d', [phy_serv.PhysicsAddr.Text, phy_serv.PhysicsPort]));
  dest.Add(Format('Listening Successed: %s', [if_(phy_serv.Activted, 'Yes', 'Failed')]));
  for i := 0 to phy_serv.DependNetworkServicePool.Count - 1 do
    begin
      dest.Add(Format('--------------------------------------------', []));
      custom_serv := phy_serv.DependNetworkServicePool[i];
      dest.Add(Format('Type: %s', [custom_serv.ServiceInfo.ServiceTyp.Text]));
      dest.Add(Format('workload: %d / %d', [custom_serv.ServiceInfo.Workload, custom_serv.ServiceInfo.MaxWorkload]));
      dest.Add(Format('Only Instance: %s', [if_(custom_serv.ServiceInfo.OnlyInstance, 'Yes', 'More Instance.')]));
      dest.Add(Format('Hash: %s', [umlMD5ToStr(custom_serv.ServiceInfo.Hash).Text]));
      dest.Add(Format('Class: "%s" Unit: "%s"', [custom_serv.ClassName, custom_serv.UnitName + '.pas']));
      dest.Add(Format('Receive Tunnel IP: %s Port: %d',
        [custom_serv.ServiceInfo.p2pVM_RecvTunnel_Addr.Text, custom_serv.ServiceInfo.p2pVM_RecvTunnel_Port]));
      dest.Add(Format('Send Tunnel IP: %s Port: %d',
        [custom_serv.ServiceInfo.p2pVM_SendTunnel_Addr.Text, custom_serv.ServiceInfo.p2pVM_SendTunnel_Port]));
      dest.Add(Format('Workload: %d/%d', [custom_serv.ServiceInfo.Workload, custom_serv.ServiceInfo.MaxWorkload]));
      dest.Add(Format('Parameter', []));
      dest.Add(Format('{', []));
      dest.Add(custom_serv.ParamList.AsText);
      dest.Add(Format('}', []));
    end;
  dest.Add(Format('', []));
end;

procedure TC40AppTempletForm.UpdateTunnelInfo;
var
  i: Integer;
  phy_tunnel: TDTC40_PhysicsTunnel;
begin
  for i := 0 to DTC40_PhysicsTunnelPool.Count - 1 do
    begin
      phy_tunnel := DTC40_PhysicsTunnelPool[i];
      if TunnelInfoPhyAddrListBox.Items.IndexOfObject(phy_tunnel) < 0 then
          TunnelInfoPhyAddrListBox.Items.AddObject(Format('tunnel "%s" port:%d', [phy_tunnel.PhysicsAddr.Text, phy_tunnel.PhysicsPort]), phy_tunnel);
    end;

  i := 0;
  while i < TunnelInfoPhyAddrListBox.Items.Count do
    if DTC40_PhysicsTunnelPool.IndexOf(TDTC40_PhysicsTunnel(TunnelInfoPhyAddrListBox.Items.Objects[i])) < 0 then
        TunnelInfoPhyAddrListBox.Items.Delete(i)
    else
        inc(i);
end;

procedure TC40AppTempletForm.UpdateTunnelInfo(phy_tunnel: TDTC40_PhysicsTunnel; dest: TStrings);
var
  i: Integer;
  custom_client: TDTC40_Custom_Client;
begin
  dest.Add(Format('Physics tunnel: "%s" Unit: "%s"', [phy_tunnel.PhysicsTunnel.ClassName, phy_tunnel.PhysicsTunnel.UnitName + '.pas']));
  dest.Add(Format('Physcis ip: "%s" Port: %d', [phy_tunnel.PhysicsAddr.Text, phy_tunnel.PhysicsPort]));
  dest.Add(Format('Physcis Connected: %s', [if_(phy_tunnel.PhysicsTunnel.Connected, 'Yes', 'Failed')]));
  for i := 0 to phy_tunnel.DependNetworkClientPool.Count - 1 do
    begin
      dest.Add(Format('--------------------------------------------', []));
      custom_client := phy_tunnel.DependNetworkClientPool[i];
      dest.Add(Format('Type: %s', [custom_client.ClientInfo.ServiceTyp.Text]));
      dest.Add(Format('Connected: %s', [if_(custom_client.Connected, 'Yes', 'Failed')]));
      dest.Add(Format('Only Instance: %s', [if_(custom_client.ClientInfo.OnlyInstance, 'Yes', 'More Instance.')]));
      dest.Add(Format('Hash: %s', [umlMD5ToStr(custom_client.ClientInfo.Hash).Text]));
      dest.Add(Format('Class: "%s" Unit: "%s"', [custom_client.ClassName, custom_client.UnitName + '.pas']));
      dest.Add(Format('Receive Tunnel IP: %s Port: %d',
        [custom_client.ClientInfo.p2pVM_RecvTunnel_Addr.Text, custom_client.ClientInfo.p2pVM_RecvTunnel_Port]));
      dest.Add(Format('Send Tunnel IP: %s Port: %d',
        [custom_client.ClientInfo.p2pVM_SendTunnel_Addr.Text, custom_client.ClientInfo.p2pVM_SendTunnel_Port]));
      dest.Add(Format('Workload: %d/%d', [custom_client.ClientInfo.Workload, custom_client.ClientInfo.MaxWorkload]));
      dest.Add(Format('Parameter', []));
      dest.Add(Format('{', []));
      dest.Add(custom_client.ParamList.AsText);
      dest.Add(Format('}', []));
    end;
  dest.Add(Format('', []));
end;

procedure TC40AppTempletForm.UpdateSaaSInfo;
  procedure Do_Update_Statistics(node_: TTreeNode; F: TCommunicationFramework);
  var
    st: TStatisticsType;
    n: string;
  begin
    for st := low(TStatisticsType) to high(TStatisticsType) do
      begin
        n := GetEnumName(TypeInfo(TStatisticsType), Ord(st));
        GetPathTreeNode(Format('%s:*@%s: %d', [n, n, F.Statistics[st]]), '|', SaaS_Info_TreeView, node_);
      end;
  end;

var
  i, j: Integer;
  phy_tunnel: TDTC40_PhysicsTunnel;
  dpc_arry: TDTC40_Custom_Client_Array;
  phy_serv: TDTC40_PhysicsService;
  dps_arry: TDTC40_Custom_Service_Array;
  L: TDTC40_InfoList;
  nd1, nd2, nd3: TTreeNode;
  cs: TDTC40_Custom_Service;
  cc: TDTC40_Custom_Client;
begin
  L := TDTC40_InfoList.Create(True);
  for i := 0 to DTC40_PhysicsTunnelPool.Count - 1 do
    begin
      phy_tunnel := DTC40_PhysicsTunnelPool[i];
      dpc_arry := phy_tunnel.DependNetworkClientPool.SearchClass(DTC40.TDTC40_Dispatch_Client, True);
      for j := 0 to length(dpc_arry) - 1 do
          L.MergeAndUpdateWorkload(DTC40.TDTC40_Dispatch_Client(dpc_arry[j]).ServiceInfoList);
    end;
  for i := 0 to DTC40_PhysicsServicePool.Count - 1 do
    begin
      phy_serv := DTC40_PhysicsServicePool[i];
      dps_arry := phy_serv.DependNetworkServicePool.GetFromClass(DTC40.TDTC40_Dispatch_Service);
      for j := 0 to length(dps_arry) - 1 do
          L.MergeAndUpdateWorkload(DTC40.TDTC40_Dispatch_Service(dps_arry[j]).ServiceInfoList);
    end;
  for i := 0 to L.Count - 1 do
    begin
      nd1 := GetPathTreeNode(Format('host: %s port: %d', [L[i].PhysicsAddr.Text, L[i].PhysicsPort]), '|', SaaS_Info_TreeView, nil);
      nd2 := GetPathTreeNode(Format('Type: %s', [L[i].ServiceTyp.Text]), '|', SaaS_Info_TreeView, nd1);
      GetPathTreeNode(Format('hash:*@hash: %s', [umlMD5ToStr(L[i].Hash).Text]), '|', SaaS_Info_TreeView, nd2);
      GetPathTreeNode(Format('workload:*@workload: %d / %d', [L[i].Workload, L[i].MaxWorkload]), '|', SaaS_Info_TreeView, nd2);
    end;
  disposeObject(L);

  for i := 0 to DTC40_ServicePool.Count - 1 do
    begin
      cs := DTC40_ServicePool[i];
      nd1 := GetPathTreeNode(Format('host: %s port: %d', [cs.ServiceInfo.PhysicsAddr.Text, cs.ServiceInfo.PhysicsPort]), '|', SaaS_Info_TreeView, nil);
      nd2 := GetPathTreeNode(Format('Type: %s', [cs.ServiceInfo.ServiceTyp.Text]), '|', SaaS_Info_TreeView, nd1);
      nd3 := GetPathTreeNode(Format('local service is running, class: %s unit: %s', [cs.ClassName, cs.UnitName + '.pas']), '|', SaaS_Info_TreeView, nd2);
    end;

  for i := 0 to DTC40_ClientPool.Count - 1 do
    begin
      cc := DTC40_ClientPool[i];
      nd1 := GetPathTreeNode(Format('host: %s port: %d', [cc.ClientInfo.PhysicsAddr.Text, cc.ClientInfo.PhysicsPort]), '|', SaaS_Info_TreeView, nil);
      nd2 := GetPathTreeNode(Format('Type: %s', [cc.ClientInfo.ServiceTyp.Text]), '|', SaaS_Info_TreeView, nd1);
      nd3 := GetPathTreeNode(Format('local client is running, class: %s unit: %s', [cc.ClassName, cc.UnitName + '.pas']), '|', SaaS_Info_TreeView, nd2);
    end;
end;

class function TC40AppTempletForm.GetPathTreeNode(Text_, Split_: U_String; TreeView_: TTreeView; RootNode_: TTreeNode): TTreeNode;
var
  i: Integer;
  prefix_, match_, value_: U_String;
begin
  prefix_ := umlGetFirstStr(Text_, Split_);
  if prefix_.Exists('@') then
    begin
      match_ := umlGetFirstStr(prefix_, '@');
      value_ := umlDeleteFirstStr(prefix_, '@');
    end
  else
    begin
      match_ := prefix_;
      value_ := prefix_;
    end;

  if Text_ = '' then
      Result := RootNode_
  else if RootNode_ = nil then
    begin
      if TreeView_.Items.Count > 0 then
        begin
          for i := 0 to TreeView_.Items.Count - 1 do
            begin
              if (TreeView_.Items[i].Parent = RootNode_) and umlMultipleMatch(True, match_, TreeView_.Items[i].Text) then
                begin
                  TreeView_.Items[i].Text := value_;
                  Result := GetPathTreeNode(umlDeleteFirstStr(Text_, Split_), Split_, TreeView_, TreeView_.Items[i]);
                  exit;
                end;
            end;
        end;
      Result := TreeView_.Items.AddChild(RootNode_, value_);
      with Result do
        begin
          ImageIndex := -1;
          StateIndex := -1;
          SelectedIndex := -1;
          Data := nil;
        end;
      Result := GetPathTreeNode(umlDeleteFirstStr(Text_, Split_), Split_, TreeView_, Result);
    end
  else
    begin
      if (RootNode_.Count > 0) then
        begin
          for i := 0 to RootNode_.Count - 1 do
            begin
              if (RootNode_.Items[i].Parent = RootNode_) and umlMultipleMatch(True, match_, RootNode_.Items[i].Text) then
                begin
                  RootNode_.Items[i].Text := value_;
                  Result := GetPathTreeNode(umlDeleteFirstStr(Text_, Split_), Split_, TreeView_, RootNode_.Items[i]);
                  exit;
                end;
            end;
        end;
      Result := TreeView_.Items.AddChild(RootNode_, value_);
      with Result do
        begin
          ImageIndex := -1;
          StateIndex := -1;
          SelectedIndex := -1;
          Data := nil;
        end;
      Result := GetPathTreeNode(umlDeleteFirstStr(Text_, Split_), Split_, TreeView_, Result);
    end;
end;

constructor TC40AppTempletForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  IsCommandLineWorkEnvir := False;
  AddDoStatusHook(self, @DoStatus_backcall);
  PGControl.ActivePageIndex := 0;

  RefreshDependReg('DP');
  RefreshServiceReg('DP');

  ExtractAndProcessCmdLine(C40AppParam);
  ReloadOpt;
  ReadConfig;

  cmdLineTitleEdit.Text := Caption;
  cmdLineAppTitleEdit.Text := Application.Title;
end;

destructor TC40AppTempletForm.Destroy;
begin
  C40Clean;
  RemoveDoStatusHook(self);
  inherited Destroy;
end;

function TC40AppTempletForm.ExtractAndProcessCmdLine(param_: U_StringArray): Boolean;
  procedure DoDisableAllComp(comp: TComponent);
  var
    i: Integer;
  begin
    if (comp is TWinControl) and (TWinControl(comp).Parent = cmd_tool_TabSheet) then
        exit;
    if (comp is TCustomEdit) then
      begin
        if not(comp is TCustomMemo) then
          begin
            TEdit(comp).Color := clBtnface;
            TEdit(comp).Enabled := False;
          end;
      end
    else if (comp is TCustomComboBox) then
      begin
        TComboBox(comp).Color := clBtnface;
        TComboBox(comp).Enabled := False;
      end
    else if (comp is TCustomCheckBox) then
      begin
        TCheckBox(comp).Font.Color := clBtnface;
        TCheckBox(comp).Enabled := False;
      end
    else if (comp is TCustomButton) then
      begin
        TButton(comp).Font.Color := clBtnface;
        TButton(comp).Enabled := False;
      end;

    for i := 0 to comp.ComponentCount - 1 do
        DoDisableAllComp(comp.Components[i]);
  end;

var
  error_: Boolean;
  IsInited_: Boolean;
  cs: TCommand_Struct;
  i: Integer;
  arry: TDTC40_DependNetworkInfoArray;
begin
  error_ := False;
  IsInited_ := False;
  try
    cs := TCommand_Struct.Create;
    for i := low(param_) to high(param_) do
        cs.Parsing(param_[i]);

    if (not error_) and (cs.service_ip <> '') and (cs.service_port > 0) and (cs.service_depend <> '') then
      begin
        arry := ExtractDependInfo(cs.service_depend);
        for i := Low(arry) to high(arry) do
          if FindRegistedC40(arry[i].Typ) = nil then
            begin
              DoStatus('no found %s', [arry[i].Typ.Text]);
              error_ := True;
            end;
      end;

    if (not error_) and (cs.client_ip <> '') and (cs.client_port > 0) and (cs.client_depend <> '') then
      begin
        arry := ExtractDependInfo(cs.client_depend);
        for i := Low(arry) to high(arry) do
          if FindRegistedC40(arry[i].Typ) = nil then
            begin
              DoStatus('no found %s', [arry[i].Typ.Text]);
              error_ := True;
            end;
      end;

    if not error_ then
      begin
        if (cs.service_ip <> '') and (cs.service_port > 0) and (cs.service_depend <> '') then
          begin
            ServIPEdit.Text := cs.service_ip;
            ServPortEdit.Text := umlIntToStr(cs.client_port);
            ServiceDependEdit.Text := cs.service_depend;
            ServiceDependEdit.OnChange := nil;
            ServiceDependEdit.Text := RebuildServiceInfo(ServiceDependEdit.Text);
            ServiceDependEdit.OnChange := @ServiceDependEditChange;
            ServBuildNetButtonClick(ServBuildNetButton);
            IsInited_ := True;
          end;

        if (cs.client_ip <> '') and (cs.client_port > 0) and (cs.client_depend <> '') then
          begin
            JoinHostEdit.Text := cs.client_ip;
            JoinPortEdit.Text := umlIntToStr(cs.client_port);
            DependEdit.Text := cs.client_depend;
            DependEdit.OnChange := nil;
            DependEdit.Text := RebuildDependInfo(DependEdit.Text);
            DependEdit.OnChange := @DependEditChange;
            BuildDependNetButtonClick(BuildDependNetButton);
            IsInited_ := True;
          end;

        if IsInited_ then
          begin
            DoDisableAllComp(self);
            IsCommandLineWorkEnvir := True;
          end;
      end;

    cs.Free;
  except
  end;
  Result := IsInited_;
end;

initialization

SetLength(C40AppParam, 0);
On_DTC40_PhysicsTunnel_Event := nil;
On_DTC40_PhysicsService_Event := nil;

end.

