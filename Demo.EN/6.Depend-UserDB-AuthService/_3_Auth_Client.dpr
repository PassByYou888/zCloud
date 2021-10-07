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
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
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
  { The searchservice searches the target service and sorts the load information }
  arry := L.SearchService('MyVA');

  if length(arry) > 0 then
    begin
      { Verification mechanism of virtuaauth: after entering the network, do not create a dual channel, but wait for the implementation of the verification mechanism. Once it passes the verification, establish a dual channel link and start the automatic network }
      { When the automatic network is started, the disconnection and reconnection will automatically log in through authentication }
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
      QueryInfoC(Do_QueryInfo); { Queryinfo will return all address information of the cloud }
end;

begin
  { In one sentence, summarize the automatic authentication network. After passing the first authentication, start the automatic network }

  RegisterC40('MyVA', TDTC40_Base_VirtualAuth_Service, TDTC40_Base_VirtualAuth_Client);
  DTC40.DTC40_QuietMode := False;

  { Client select VM }
  SearchAndBuildVirtualAuth;

  { Waitconnected done can check whether multiple dependent services are ready at the same time }
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('MyVA', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    begin
      if not GetVirtualAuth_Client.LoginIsSuccessed then
        begin
          { Registeruserandlogin is a switch, which is false by default. When it is turned on, the connect operation will automatically register new users. When the registration is successful, the authentication login will be turned on and the automatic network will be started }
          { When the registration fails, the system will automatically log in for the first time. If the login succeeds, the automatic network will be started. If the login fails, the automatic network will not be started }
          { Note: if C4 is developed using the verification mode, it needs to be on duty before connecting to the server to pass the verification }
          GetVirtualAuth_Client.Client.RegisterUserAndLogin := True;
          GetVirtualAuth_Client.Client.Connect_P('User_Test', '123456', procedure(const State: Boolean)
            begin
              if State then
                  DoStatus('Successful registration or login')
              else
                  DoStatus('Registration or login failed');
            end);
        end;
    end);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
