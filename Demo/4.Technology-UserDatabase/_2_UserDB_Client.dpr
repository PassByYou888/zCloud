program _2_UserDB_Client;

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
  DTC40_UserDB;

const
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '192.168.2.79';
  // 调度服务器端口
  Internet_DP_Port_ = 8387;

function GetMyUserDB_Client: TDTC40_UserDB_Client;
begin
  Result := TDTC40_UserDB_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('userDB'));
end;

begin
  // 打开Log信息
  DTC40.DTC40_QuietMode := False;

  // 接通调度端和用户身份数据库服务
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|UserDB', nil);

  // WaitConnectedDone可以同时检查多个依赖服务是否就绪
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('DP|UserDB', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    begin
      // 给testUser永久增加一个可用与登录的别名，例如增加用户的电子邮件，手机号码
      GetMyUserDB_Client.Usr_NewIdentifierP('testUser', 'test@mail.com',
        procedure(sender: TDTC40_UserDB_Client; State_: Boolean; info_: SystemString)
        begin
          DoStatus(info_);
        end);

      // 使用别名远程验证用户身份，这里只是验证返回，便于VM服务器工作，userDB并不会做任何登录处理，登录处理在VM服务器干
      GetMyUserDB_Client.Usr_AuthP('test@mail.com', '123456',
        procedure(sender: TDTC40_UserDB_Client; State_: Boolean; info_: SystemString)
        begin
          DoStatus(info_);
        end);
    end);

  // 主循环
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
