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
  // ���ȷ������˿ڹ�����ַ,������ipv4,ipv6,dns
  // ������ַ,���ܸ�127.0.0.1����
  Internet_DP_Addr_ = '127.0.0.1';
  // ���ȷ������˿�
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
  // ��Log��Ϣ
  DTC40.DTC40_QuietMode := False;

  // �������ȷ�����û�������ݿ����
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('DP|UserDB');
      StartService;
    end;

  // ע��һ�����û���testUserΪ����ʶ��������ʶ��������������ָ��͵�¼������������Ŀ����Ҫ��ʶ����ֻ�ܵ�¼��֤
  GetMyUserDB_Service.RegUser('testUser', '123456');

  // ��ͨ���ȶ�
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  // ��ѭ��
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
