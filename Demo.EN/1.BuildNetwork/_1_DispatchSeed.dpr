﻿program _1_DispatchSeed;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
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

begin
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  { Create scheduling service }
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('dp');
      StartService;
    end;
  { Connect the dispatching terminal }
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'dp', nil);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
