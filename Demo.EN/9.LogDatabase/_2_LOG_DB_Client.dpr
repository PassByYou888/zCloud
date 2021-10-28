program _2_LOG_DB_Client;

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
  DTC40_Log_DB, DateUtils;

const
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

function Get_Log_DB_Client: TDTC40_Log_DB_Client;
begin
  Result := TDTC40_Log_DB_Client(DTC40_ClientPool.FindConnectedServiceTyp('Log'));
end;

begin
  DTC40.DTC40_QuietMode := False;
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|Log', nil);

  DTC40.DTC40_ClientPool.WaitConnectedDoneP('Log', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    var
      i, j: integer;
    begin
      for j := 1 to 20 do
        for i := 1 to 10 do
          begin
            Get_Log_DB_Client.PostLog(PFormat('test_log_db_%d', [j]), PFormat('log %d', [i]), PFormat('log %d', [i * i]));
          end;

      Get_Log_DB_Client.GetLogDBP(procedure(Sender: TDTC40_Log_DB_Client; arry: U_StringArray)
        var
          i: integer;
        begin
          for i := 0 to length(arry) - 1 do
              doStatus(arry[i]);
        end);

      Get_Log_DB_Client.QueryLogP('test_log_db_1', IncHour(now, -1), IncHour(now, 1),
        procedure(Sender: TDTC40_Log_DB_Client; LogDB: SystemString; arry: TArrayLogData)
        var
          i: integer;
        begin
          for i := 0 to length(arry) - 1 do
              doStatus(arry[i].Log1);
          doStatus('query done.');
        end);
    end);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
