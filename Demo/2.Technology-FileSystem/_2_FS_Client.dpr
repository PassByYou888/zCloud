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
  // ���ȷ������˿ڹ�����ַ,������ipv4,ipv6,dns
  // ������ַ,���ܸ�127.0.0.1����
  Internet_DP_Addr_ = '192.168.2.79';
  // ���ȷ������˿�
  Internet_DP_Port_ = 8387;

function GetMyFS_Client: TDTC40_FS_Client;
begin
  Result := TDTC40_FS_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('FS'));
end;

begin
  DTC40.DTC40_QuietMode := False;
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|FS', nil);

  // FSҲ��һ����Ҫ������ʩ����Ҫ���ڴ�Ŵ������ݣ�����ͼƬ���б��������ݵȵ�
  // C4��FS֧�ָ�Ƶ�ʲ�д��VM������������FS��Ϊ���ݽ�������Ҫ����Var�������
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('FS', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    var
      tmp: TMS64;
    begin
      tmp := TMS64.Create;
      tmp.Size := 1024 * 1024;
      MT19937Rand32(MaxInt, tmp.Memory, tmp.Size div 4);
      DoStatus('origin md5: ' + umlStreamMD5String(tmp));
      // �����������ļ�������ļ���token���Զ��������еģ����Ƕ��ڴ洢�ռ�ʹ�ò�д���ƴ���
      // postfile��api���ṹ��һ���µ�p2pVM����������Ŷ�
      // p2pVM������������ļ����������ͬ���ļ�ͬʱ���д��䣬������������IO������ɴ�����Ⱥ�˳���д�������������ĸ������ٿ��
      GetMyFS_Client.FS_PostFile_P('test', tmp, True, procedure(Sender: TDTC40_FS_Client; Token: U_String)
        begin
          // ��post��ɺ����ǽ��ļ�get������get�ļ�Ҳ�ṹ���µ�p2pVM����������䣬���ᷢ���Ŷӵ�
          GetMyFS_Client.FS_GetFile_P('test', False,
            procedure(Sender: TDTC40_FS_Client; stream: TMS64; Token: U_String; Successed: Boolean)
            begin
              DoStatus('downloaded md5: ' + umlStreamMD5String(stream));
              // get��ɺ�����ɾ��Զ���ļ�
              GetMyFS_Client.FS_RemoveFile('test', False);
            end);
        end);
    end);

  // ��ѭ��
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;
end.
