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


// 使用C40AppTempletForm不需要修改里面的代码
// 我们在外面给出接口和参数即可让后台服务器已可视化状态运行，这种方式非常适合windows
procedure Init;
var
  tmp: TEventMonitor;
begin
  // 指定C40AppParam的脚本语法
  C40AppParsingTextStyle := TTextStyle.tsPascal;
  // C40AppParam是C4应用模板的脚本内容，这种脚本可以支持命令行输入，也可以直接按字符串方式输入
  // 脚本可以在C40AppTempletForm种使用command line tool生成
  C40AppParam := [
  // 窗口标题，写法为，title(...)
    'Title('#39'Var Service.'#39')',
  // 应用标题，写法为，AppTitle(...)
  'AppTitle('#39'Var Service'#39')',
  // 是否屏蔽UI，防止误操作打乱服务序列，写法为，DisableUI(false/true)
  'DisableUI(True)',
  // 循环间隔，值越小循环越密集，注意：fpc因为底层IO是阻塞通讯模型，该值必须给大，delphi使用cross-socket异步通讯模型
  'Timer(100)',
  // 入网密码
  'Password('#39'DTC40@ZSERVER'#39')',
  // 启动的服务，写法为，service(ip,port,depend)
  'Service('#39'127.0.0.1'#39','#39'18182'#39','#39'DP|Var'#39')',
  // 启动的隧道连接，写法为，tunnel(ip,port,depend)
  'Tunnel('#39'127.0.0.1'#39','#39'18180'#39','#39'DP'#39')'];

  // 事件接口实例
  tmp := TEventMonitor.Create;
  On_DTC40_PhysicsTunnel_Event := tmp;  // 连接隧道事件接口
  On_DTC40_PhysicsService_Event := tmp; // 服务器事件接口
end;

begin
  Init;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TC40AppTempletForm, C40AppTempletForm);
  Application.Run;

end.
