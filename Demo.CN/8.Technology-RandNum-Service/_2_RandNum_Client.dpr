program _2_RandNum_Client;

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
  ListEngine,
  PhysicsIO,
  DTC40,
  DTC40_RandSeed;

const
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '127.0.0.1';
  // 调度服务器端口
  Internet_DP_Port_ = 8387;

function GetRandSeed_Client: TDTC40_RandSeed_Client;
begin
  Result := TDTC40_RandSeed_Client(DTC40_ClientPool.FindConnectedServiceTyp('RandSeed'));
end;

begin
  DTC40.DTC40_QuietMode := False;
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|RandSeed', nil);

  DTC40.DTC40_ClientPool.WaitConnectedDoneP('RandSeed', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    var
      i: Integer;
      L: TListCardinal;
    begin
      L := TListCardinal.Create;
      for i := 0 to 100 do
          GetRandSeed_Client.MakeSeed_P('my_group', 1000, 9999,
          procedure(sender: TDTC40_RandSeed_Client; Seed_: UInt32)
          begin
            L.Add(Seed_);
          end);

      GetRandSeed_Client.DTNoAuthClient.SendTunnel.IO_IDLE_TraceP(nil, procedure(data: TCoreClassObject)
        var
          i: Integer;
        begin
          for i := 0 to L.Count - 1 do
              GetRandSeed_Client.RemoveSeed('my_group', L[i]);
          L.Free;
        end);
    end);

  // 主循环
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
