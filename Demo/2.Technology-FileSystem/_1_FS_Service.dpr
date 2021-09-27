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
  // ���ȷ������˿ڹ�����ַ,������ipv4,ipv6,dns
  // ������ַ,���ܸ�127.0.0.1����
  Internet_DP_Addr_ = '127.0.0.1';
  // ���ȷ������˿�
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
  // ��Log��Ϣ
  DTC40.DTC40_QuietMode := False;

  // �������ȷ�����ļ�ϵͳ����
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      // FS@SafeCheckTime=5000 ����Ϊfs�������Ĺ���������SafeCheckTime��ʾ��ȫ��⣬IO����д����̵�ʱ����
      BuildDependNetwork('DP|FS@SafeCheckTime=5000');
      StartService;
    end;

  // ��ͨ���ȶ�
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP', nil);

  // ��ѭ��
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
