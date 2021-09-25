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
  // ���ȷ������˿ڹ�����ַ,������ipv4,ipv6,dns
  // ������ַ,���ܸ�127.0.0.1����
  Internet_DP_Addr_ = '192.168.2.79';
  // ���ȷ������˿�
  Internet_DP_Port_ = 8387;

function GetMyUserDB_Client: TDTC40_UserDB_Client;
begin
  Result := TDTC40_UserDB_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('userDB'));
end;

begin
  // ��Log��Ϣ
  DTC40.DTC40_QuietMode := False;

  // ��ͨ���ȶ˺��û�������ݿ����
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|UserDB', nil);

  // WaitConnectedDone����ͬʱ��������������Ƿ����
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('DP|UserDB', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    begin
      // ��testUser��������һ���������¼�ı��������������û��ĵ����ʼ����ֻ�����
      GetMyUserDB_Client.Usr_NewIdentifierP('testUser', 'test@mail.com',
        procedure(sender: TDTC40_UserDB_Client; State_: Boolean; info_: SystemString)
        begin
          DoStatus(info_);
        end);

      // ʹ�ñ���Զ����֤�û���ݣ�����ֻ����֤���أ�����VM������������userDB���������κε�¼������¼������VM��������
      GetMyUserDB_Client.Usr_AuthP('test@mail.com', '123456',
        procedure(sender: TDTC40_UserDB_Client; State_: Boolean; info_: SystemString)
        begin
          DoStatus(info_);
        end);
    end);

  // ��ѭ��
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
