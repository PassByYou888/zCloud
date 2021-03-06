program _3_UserDB_Service;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  NotifyObjectBase,
  DoStatusIO,
  CommunicationFramework,
  PhysicsIO,
  DTC40,
  DTC40_FS,
  DTC40_UserDB,
  DTC40_Var;

const
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '127.0.0.1';
  // 调度服务器端口
  Internet_DP_Port_ = 8387;

  // 本地服务器公网地址
  Internet_LocalService_Addr_ = '127.0.0.1';
  Internet_LocalService_Port_ = 8385;

var
  FS: TDTC40_FS_Client = nil;

type
  // C4网络是扩散式的,一个链接会爬取出许多关联的链接,使用接口来监听
  TMonitorMySAAS = class(TCoreClassInterfacedObject, IDTC40_PhysicsTunnel_Event)
    procedure DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
    procedure DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
  end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
begin
  // 创建物理链接
end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
begin
  // 物理链接中断
  if Sender.DependNetworkClientPool.IndexOf(FS) >= 0 then
      FS := nil;
end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin
  // 创建p2pVM隧道
end;

procedure TMonitorMySAAS.DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin
  // p2pVM隧道握手完成
  if Custom_Client_ is TDTC40_FS_Client then
    begin
      FS := Custom_Client_ as TDTC40_FS_Client;
      DoStatus('已找到文件支持服务: %s', [Custom_Client_.ClientInfo.ServiceTyp.Text]);
    end;
end;

begin
  // 打开Log信息
  DTC40.DTC40_QuietMode := False;

  // 创建dp和用户数据库服务
  with DTC40.TDTC40_PhysicsService.Create(Internet_LocalService_Addr_, Internet_LocalService_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('dp|UserDB');
      StartService;
    end;

  // 接通调度端和文件服务
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'dp|FS', TMonitorMySAAS.Create);
  FS := nil;

  // 主循环
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
