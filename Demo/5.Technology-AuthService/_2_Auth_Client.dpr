program _2_Auth_Client;

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
  DTC40;

const
  // ���ȷ������˿ڹ�����ַ,������ipv4,ipv6,dns
  // ������ַ,���ܸ�127.0.0.1����
  Internet_DP_Addr_ = '192.168.2.79';
  // ���ȷ������˿�
  Internet_DP_Port_ = 8387;

function GetVirtualAuth_Client: TDTC40_Base_VirtualAuth_Client;
begin
  Result := TDTC40_Base_VirtualAuth_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('MyVA'));
end;

begin
  // һ�仰�ܽ��Զ�����֤���磬ͨ���״������֤�󣬿����Զ�������

  RegisterC40('MyVA', TDTC40_Base_VirtualAuth_Service, TDTC40_Base_VirtualAuth_Client);
  DTC40.DTC40_QuietMode := False;

  // VirtualAuth����֤���ƣ����������Ժ󲻴���˫ͨ�������ǵȴ�ִ����֤���ƣ�һ��ͨ����֤������˫ͨ�����Ӳ������Զ�����
  // �������Զ�����󣬶������������Զ���ͨ�������֤��¼
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'MyVA', nil);

  // WaitConnectedDone����ͬʱ��������������Ƿ����
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('MyVA', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    begin
      if not GetVirtualAuth_Client.LoginIsSuccessed then
        begin
          // RegisterUserAndLogin�Ǹ����أ�Ĭ��Ϊfalse�����Ժ�connect�������Զ���ע�����û���ע��ɹ�ʱ�Ὺ����֤��¼���������Զ�����
          // ��ע��ʧ��ʱ��ϵͳ���Զ��״ε�¼�������¼�ɹ��������Զ����磬��¼ʧ�ܣ����أ����������Զ�����
          // ע�⣺���ʹ����֤ģʽ����c4����ͨ������ǰ����Ҫ��Ϊֵ��ͨ����֤
          GetVirtualAuth_Client.Client.RegisterUserAndLogin := True;
          GetVirtualAuth_Client.Client.Connect_P('User_Test', '123456', procedure(const State: Boolean)
            begin
              if State then
                  DoStatus('ע����¼�ɹ�')
              else
                  DoStatus('ע����¼ʧ��.');
            end);
        end;
    end);

  // ��ѭ��
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
