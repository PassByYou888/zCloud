program _1_UserDB_IM_Centre_Serv;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  CommunicationFramework,
  CommunicationFrameworkDoubleTunnelIO_VirtualAuth,
  DoStatusIO,
  PhysicsIO,
  ZJson,
  DTC40, DTC40_UserDB;

const
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

  { Local server public network address }
  Internet_LocalService_Addr_ = '127.0.0.1';
  Internet_LocalService_Port_ = 8387;

begin
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  with DTC40.TDTC40_PhysicsService.Create(Internet_LocalService_Addr_, Internet_LocalService_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('DP|UserDB');
      StartService;
    end;
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
