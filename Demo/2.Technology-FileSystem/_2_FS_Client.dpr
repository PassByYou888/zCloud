program _2_FS_Client;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  DoStatusIO,
  MemoryStream64,
  NotifyObjectBase,
  CommunicationFramework,
  PhysicsIO,
  DTC40,
  DTC40_FS;

const
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '192.168.2.79';
  // 调度服务器端口
  Internet_DP_Port_ = 8387;

function GetMyFS_Client: TDTC40_FS_Client;
begin
  Result := TDTC40_FS_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('FS'));
end;

begin
  DTC40.DTC40_QuietMode := False;
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|FS', nil);

  // FS也是一种主要基础设施，主要用于存放大型数据，例如图片，列表，配置数据等等
  // C4的FS支持高频率擦写，VM服务器可以用FS作为数据交换，但要区分Var网络变量
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('FS', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    var
      tmp: TMS64;
    begin
      tmp := TMS64.Create;
      tmp.Size := 1024 * 1024;
      MT19937Rand32(MaxInt, tmp.Memory, tmp.Size div 4);
      DoStatus('origin md5: ' + umlStreamMD5String(tmp));
      // 往服务器仍文件，这个文件的token会自动覆盖已有的，覆盖都在存储空间使用擦写机制处理
      // postfile的api，会构建一个新的p2pVM隧道，永不排队
      // p2pVM并发隧道传输文件，如果两个同名文件同时并行传输，服务器会依据IO触发完成传输的先后顺序擦写操作，网速慢的覆盖网速快的
      GetMyFS_Client.FS_PostFile_P('test', tmp, True, procedure(Sender: TDTC40_FS_Client; Token: U_String)
        begin
          // 当post完成后，我们将文件get下来，get文件也会构建新的p2pVM隧道并发传输，不会发生排队等
          GetMyFS_Client.FS_GetFile_P('test', False,
            procedure(Sender: TDTC40_FS_Client; stream: TMS64; Token: U_String; Successed: Boolean)
            begin
              DoStatus('downloaded md5: ' + umlStreamMD5String(stream));
              // get完成后，我们删除远程文件
              GetMyFS_Client.FS_RemoveFile('test', False);
            end);
        end);
    end);

  // 主循环
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;
end.
