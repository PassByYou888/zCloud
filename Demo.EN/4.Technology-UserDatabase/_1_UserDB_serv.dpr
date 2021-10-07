program _1_UserDB_serv;

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
  DTC40_UserDB;

const
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

function GetMyUserDB_Service: TDTC40_UserDB_Service;
var
  arry: TDTC40_Custom_Service_Array;
begin
  arry := DTC40_ServicePool.GetFromServiceTyp('userDB');
  if length(arry) > 0 then
      Result := TDTC40_UserDB_Service(arry[0] as TDTC40_UserDB_Service)
  else
      Result := nil;
end;

begin
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  { Create scheduling service and user identity database service }
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('DP|UserDB');
      StartService;
    end;

  { Register a new user. Testuser is the primary identifier. The primary identifier can be used for data pointing and login, such as data entry. The secondary identifier can only be used for login authentication }
  GetMyUserDB_Service.RegUser('testUser', '123456');

  { Connect the dispatching terminal }
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
