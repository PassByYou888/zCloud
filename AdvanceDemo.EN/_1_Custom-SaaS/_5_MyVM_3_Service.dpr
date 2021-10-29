program _5_MyVM_3_Service;

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


{ There is no need to modify the code in c40apptempletform }
{ We can make the background server run visually by giving the interface and parameters outside. This method is very suitable for windows }
procedure Init;
var
  tmp: TEventMonitor;
begin
  { Specifies the script syntax for c40appparam }
  C40AppParsingTextStyle := TTextStyle.tsPascal;
  { C40appparam is the script content of C4 application template. This script can support command line input or input directly in string mode }
  { Scripts can be generated in c40apptempletform using the command line tool }
  C40AppParam := [
  { Window title, written as, title (...) }
    'Title('#39'MyVM3 Service.'#39')',
  { Application title, written as apptitle (...) }
  'AppTitle('#39'MyVM3 Service'#39')',
  { Whether the UI is shielded to prevent misoperation from disrupting the service sequence. It is written as disableui (false / true) }
  'DisableUI(True)',
  { For the cycle interval, the smaller the value, the denser the cycle. Note: FPC because the underlying IO is a blocking communication model, the value must be larger. Delphi uses the cross socket asynchronous communication model }
  'Timer(100)',
  { Network access password }
  'Password('#39'DTC40@ZSERVER'#39')',
  { The service started is written as service (IP, port, dependent) }
  'Service('#39'127.0.0.1'#39','#39'18186'#39','#39'DP|MyCustom|MyCustom_2'#39')',
  { The tunnel connection started is written as tunnel (IP, port, dependent) }
  'Tunnel('#39'127.0.0.1'#39','#39'18180'#39','#39'DP|Log|FS|Var|UserDB'#39')'];

  { Event interface instance }
  tmp := TEventMonitor.Create;
  On_DTC40_PhysicsTunnel_Event := tmp;  { Connect tunnel event interface }
  On_DTC40_PhysicsService_Event := tmp; { Server event interface }
end;

begin
  Init;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TC40AppTempletForm, C40AppTempletForm);
  Application.Run;
end.
