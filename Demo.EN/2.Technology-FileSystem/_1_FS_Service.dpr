program _1_FS_Service;

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
  DTC40_FS;

const
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

function GetMyUserDB_Service: TDTC40_FS_Service;
var
  arry: TDTC40_Custom_Service_Array;
begin
  arry := DTC40_ServicePool.GetFromServiceTyp('FS');
  if length(arry) > 0 then
      Result := arry[0] as TDTC40_FS_Service
  else
      Result := nil;
end;

begin
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  { Create scheduling service and file system service }
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      { FS@SafeCheckTime =5000 is the build parameter of FS server. Safechecktime indicates the time interval between security detection and IO data writing to disk }
      BuildDependNetwork('DP|FS@SafeCheckTime=5000');
      StartService;
    end;

  { Connect the dispatching terminal }
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
