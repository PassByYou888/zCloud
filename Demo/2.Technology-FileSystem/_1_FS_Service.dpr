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
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '127.0.0.1';
  // 调度服务器端口
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
  // 打开Log信息
  DTC40.DTC40_QuietMode := False;

  // 创建调度服务和文件系统服务
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      // FS@SafeCheckTime=5000 是作为fs服务器的构建参数，SafeCheckTime表示安全检测，IO数据写入磁盘的时间间隔
      BuildDependNetwork('DP|FS@SafeCheckTime=5000');
      StartService;
    end;

  // 接通调度端
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  // 主循环
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
