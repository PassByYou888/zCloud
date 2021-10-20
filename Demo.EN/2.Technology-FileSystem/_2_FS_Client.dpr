program _2_FS_Client;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  SysUtils,
  Windows,
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
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

function GetMyFS_Client: TDTC40_FS_Client;
begin
  Result := TDTC40_FS_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('FS'));
end;

procedure Wait_C40Clean_Done;
begin
  DTC40.C40Clean;
end;

function ConsoleProc(CtrlType: DWORD): Bool; stdcall;
begin
  case CtrlType of
    CTRL_C_EVENT, CTRL_BREAK_EVENT, CTRL_CLOSE_EVENT, CTRL_LOGOFF_EVENT, CTRL_SHUTDOWN_EVENT:
      begin
        TCompute.SyncC(Wait_C40Clean_Done);
      end;
  end;
  Result := True;
end;

begin
  SetConsoleCtrlHandler(@ConsoleProc, True);

  DTC40.DTC40_QuietMode := False;
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|FS', nil);

  { FS is also a major infrastructure, which is mainly used to store large data, such as pictures, lists, configuration data, etc }
  { FS of C4 supports high-frequency erasure. VM server can use FS as data exchange, but var network variables should be distinguished }
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('FS', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    var
      tmp: TMS64;
    begin
      tmp := TMS64.Create;
      tmp.Size := 1024 * 1024;
      MT19937Rand32(MaxInt, tmp.Memory, tmp.Size div 4);
      DoStatus('origin md5: ' + umlStreamMD5String(tmp));
      GetMyFS_Client.FS_RemoveFile('test', False);
      { When a file is returned to the server, the token of the file will automatically overwrite the existing one, which will be overwritten in the storage space and processed by the erasure mechanism }
      { The postfile API will build a new p2pvm tunnel and never queue }
      { P2pvm transmits files in parallel tunnel. If two files with the same name are transmitted in parallel at the same time, the server will complete the erasure operation in the order of transmission triggered by io. The slow network speed will cover the fast network speed }
      GetMyFS_Client.FS_PostFile_P('test', tmp, True, procedure(Sender: TDTC40_FS_Client; Token: U_String)
        begin
          { Do not use cache }
          { After the post is completed, we will get the file, and the get file will also build a new p2pvm tunnel for concurrent transmission without queuing }
          GetMyFS_Client.FS_GetFile_P(
            True,
            'test', False,
            procedure(Sender: TDTC40_FS_Client; stream: TMS64; Token: U_String; Successed: Boolean)
            begin
              if Successed then
                  DoStatus('downloaded md5: ' + umlStreamMD5String(stream));

              { Using cache }
              { After the post is completed, we will get the file, and the get file will also build a new p2pvm tunnel for concurrent transmission without queuing }
              GetMyFS_Client.FS_GetFile_P(
                True,
                'test', False,
                procedure(Sender2: TDTC40_FS_Client; stream2: TMS64; Token2: U_String; Successed2: Boolean)
                begin
                  if Successed2 then
                      DoStatus('use cache downloaded md5: ' + umlStreamMD5String(stream2));
                end);
            end);

        end);
    end);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
