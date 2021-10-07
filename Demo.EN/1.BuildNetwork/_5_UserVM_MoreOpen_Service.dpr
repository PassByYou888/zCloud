program _5_UserVM_MoreOpen_Service;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  DoStatusIO,
  CommunicationFramework,
  PhysicsIO,
  DTC40,
  DTC40_FS,
  DTC40_UserDB,
  DTC40_Var;

const
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

  { Local server public network address }
  Internet_LocalService_Addr_ = '127.0.0.1';
  Internet_LocalService_Port_ = 8384;

var
  FS: TDTC40_FS_Client = nil;
  UserDB: TDTC40_UserDB_Client = nil;
  Var_: TDTC40_Var_Client = nil;

type
  { C4 network is diffuse. A link will crawl out many associated links and use interfaces to listen }
  TMonitorMySAAS = class(TCoreClassInterfacedObject, IDTC40_PhysicsTunnel_Event)
    procedure DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
    procedure DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
  end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
begin
  { Create physical link }
end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
begin
  { Physical link break }
  if Sender.DependNetworkClientPool.IndexOf(FS) >= 0 then
      FS := nil;
  if Sender.DependNetworkClientPool.IndexOf(UserDB) >= 0 then
      UserDB := nil;
  if Sender.DependNetworkClientPool.IndexOf(Var_) >= 0 then
      Var_ := nil;
end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin
  { Create p2pvm tunnel }
end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin
  { P2pvm tunnel handshake completed }
  if Custom_Client_ is TDTC40_FS_Client then
    begin
      FS := Custom_Client_ as TDTC40_FS_Client;
      DoStatus('Found file support service "%s"', [Custom_Client_.ClientInfo.ServiceTyp.Text]);
    end;
  if Custom_Client_ is TDTC40_UserDB_Client then
    begin
      UserDB := Custom_Client_ as TDTC40_UserDB_Client;
      DoStatus('User database support service found "%s"', [Custom_Client_.ClientInfo.ServiceTyp.Text]);
    end;
  if Custom_Client_ is TDTC40_Var_Client then
    begin
      Var_ := Custom_Client_ as TDTC40_Var_Client;
      DoStatus('Found network variable support service "%s"', [Custom_Client_.ClientInfo.ServiceTyp.Text]);
    end;
end;

begin
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  { Create service }
  with DTC40.TDTC40_PhysicsService.Create(Internet_LocalService_Addr_, Internet_LocalService_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('dp');
      StartService;
    end;

  { Connect the dispatching terminal, file service, user database service and network variable service }
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'dp|FS|UserDB|var', TMonitorMySAAS.Create);

  { Loop to check whether the specified end is ready, so that we can trigger some events }
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('dp|fs|UserDB|var', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    begin
      DoStatus('All the dependent services are ready... Let'#39's do something');
    end);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
