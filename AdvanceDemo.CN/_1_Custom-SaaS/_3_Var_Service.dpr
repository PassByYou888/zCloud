program _3_Var_Service;

uses
  Vcl.Forms,
  CoreClasses,
  PascalStrings,
  DTC40,
  TextParsing,
  C40AppTempletFrm in '..\..\Delphi-C4AppTemplet\C40AppTempletFrm.pas' {C40AppTempletForm} ,
  MyService in 'MyService.pas';

{$R *.res}
{$REGION 'Monitor'}


type
  TEventMonitor = class(CoreClasses.TCoreClassInterfacedObject, IDTC40_PhysicsTunnel_Event, IDTC40_PhysicsService_Event)
  public
    procedure DTC40_PhysicsService_Build_Network(Sender: TDTC40_PhysicsService; Custom_Service_: TDTC40_Custom_Service);
    procedure DTC40_PhysicsService_Start(Sender: TDTC40_PhysicsService);
    procedure DTC40_PhysicsService_Stop(Sender: TDTC40_PhysicsService);
    procedure DTC40_PhysicsService_LinkSuccess(Sender: TDTC40_PhysicsService; Custom_Service_: TDTC40_Custom_Service; Trigger_: TCoreClassObject);
    procedure DTC40_PhysicsService_UserOut(Sender: TDTC40_PhysicsService; Custom_Service_: TDTC40_Custom_Service; Trigger_: TCoreClassObject);
    procedure DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
    procedure DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
    procedure DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
  end;

procedure TEventMonitor.DTC40_PhysicsService_Build_Network(Sender: TDTC40_PhysicsService; Custom_Service_: TDTC40_Custom_Service);
begin

end;

procedure TEventMonitor.DTC40_PhysicsService_Start(Sender: TDTC40_PhysicsService);
begin

end;

procedure TEventMonitor.DTC40_PhysicsService_Stop(Sender: TDTC40_PhysicsService);
begin

end;

procedure TEventMonitor.DTC40_PhysicsService_LinkSuccess(Sender: TDTC40_PhysicsService; Custom_Service_: TDTC40_Custom_Service; Trigger_: TCoreClassObject);
begin

end;

procedure TEventMonitor.DTC40_PhysicsService_UserOut(Sender: TDTC40_PhysicsService; Custom_Service_: TDTC40_Custom_Service; Trigger_: TCoreClassObject);
begin

end;

procedure TEventMonitor.DTC40_PhysicsTunnel_Connected(Sender: TDTC40_PhysicsTunnel);
begin

end;

procedure TEventMonitor.DTC40_PhysicsTunnel_Disconnect(Sender: TDTC40_PhysicsTunnel);
begin

end;

procedure TEventMonitor.DTC40_PhysicsTunnel_Build_Network(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin

end;

procedure TEventMonitor.DTC40_PhysicsTunnel_Client_Connected(Sender: TDTC40_PhysicsTunnel; Custom_Client_: TDTC40_Custom_Client);
begin

end;
{$ENDREGION 'Monitor'}


// ʹ��C40AppTempletForm����Ҫ�޸�����Ĵ���
// ��������������ӿںͲ��������ú�̨�������ѿ��ӻ�״̬���У����ַ�ʽ�ǳ��ʺ�windows
procedure Init;
var
  tmp: TEventMonitor;
begin
  // ָ��C40AppParam�Ľű��﷨
  C40AppParsingTextStyle := TTextStyle.tsPascal;
  // C40AppParam��C4Ӧ��ģ��Ľű����ݣ����ֽű�����֧�����������룬Ҳ����ֱ�Ӱ��ַ�����ʽ����
  // �ű�������C40AppTempletForm��ʹ��command line tool����
  C40AppParam := [
  // ���ڱ��⣬д��Ϊ��title(...)
    'Title('#39'Var Service.'#39')',
  // Ӧ�ñ��⣬д��Ϊ��AppTitle(...)
  'AppTitle('#39'Var Service'#39')',
  // �Ƿ�����UI����ֹ��������ҷ������У�д��Ϊ��DisableUI(false/true)
  'DisableUI(True)',
  // ѭ�������ֵԽСѭ��Խ�ܼ���ע�⣺fpc��Ϊ�ײ�IO������ͨѶģ�ͣ���ֵ�������delphiʹ��cross-socket�첽ͨѶģ��
  'Timer(100)',
  // ��������
  'Password('#39'DTC40@ZSERVER'#39')',
  // �����ķ���д��Ϊ��service(ip,port,depend)
  'Service('#39'127.0.0.1'#39','#39'18182'#39','#39'DP|Var'#39')',
  // ������������ӣ�д��Ϊ��tunnel(ip,port,depend)
  'Tunnel('#39'127.0.0.1'#39','#39'18180'#39','#39'DP'#39')'];

  // �¼��ӿ�ʵ��
  tmp := TEventMonitor.Create;
  On_DTC40_PhysicsTunnel_Event := tmp;  // ��������¼��ӿ�
  On_DTC40_PhysicsService_Event := tmp; // �������¼��ӿ�
end;

begin
  Init;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TC40AppTempletForm, C40AppTempletForm);
  Application.Run;

end.
