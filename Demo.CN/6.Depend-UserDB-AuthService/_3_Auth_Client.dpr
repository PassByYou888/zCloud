program _3_Auth_Client;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  DoStatusIO,
  NotifyObjectBase,
  CommunicationFramework,
  PhysicsIO,
  DTC40;

const
  // ���ȷ������˿ڹ�����ַ,������ipv4,ipv6,dns
  // ������ַ,���ܸ�127.0.0.1����
  Internet_DP_Addr_ = '127.0.0.1';
  // ���ȷ������˿�
  Internet_DP_Port_ = 8387;

function GetVirtualAuth_Client: TDTC40_Base_VirtualAuth_Client;
begin
  Result := TDTC40_Base_VirtualAuth_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('MyVA'));
end;

procedure SearchAndBuildVirtualAuth; forward;

procedure Do_QueryInfo(Sender: TDTC40_PhysicsTunnel; L: TDTC40_InfoList);
var
  arry: TDTC40_Info_Array;
begin
  // SearchService������Ŀ����񣬲��Ը�����Ϣ����
  arry := L.SearchService('MyVA');

  if length(arry) > 0 then
    begin
      // VirtualAuth����֤���ƣ����������Ժ󲻴���˫ͨ�������ǵȴ�ִ����֤���ƣ�һ��ͨ����֤������˫ͨ�����Ӳ������Զ�����
      // �������Զ�����󣬶������������Զ���ͨ�������֤��¼
      DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(arry[0], 'MyVA', nil);
    end
  else
    begin
      SysPost.PostExecuteC_NP(5.0, SearchAndBuildVirtualAuth);
    end;
end;

procedure SearchAndBuildVirtualAuth;
begin
  with DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_) do
      QueryInfoC(Do_QueryInfo); // QueryInfo�᷵���ƶ˵�ȫ����ַ��Ϣ
end;

begin
  // һ�仰�ܽ��Զ�����֤���磬ͨ���״������֤�󣬿����Զ�������

  RegisterC40('MyVA', TDTC40_Base_VirtualAuth_Service, TDTC40_Base_VirtualAuth_Client);
  DTC40.DTC40_QuietMode := False;

  // �ͻ���ѡ��VM
  SearchAndBuildVirtualAuth;

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
