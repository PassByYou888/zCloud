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
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '127.0.0.1';
  // 调度服务器端口
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
  // 打开Log信息
  DTC40.DTC40_QuietMode := False;

  // 创建调度服务和用户身份数据库服务
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('DP|UserDB');
      StartService;
    end;

  // 注册一个新用户，testUser为主标识符，主标识符可以用于数据指向和登录，例如数据条目，次要标识符则只能登录验证
  GetMyUserDB_Service.RegUser('testUser', '123456');

  // 接通调度端
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  // 主循环
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
