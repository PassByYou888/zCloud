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
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

function GetMyUserDB_Client: TDTC40_UserDB_Client;
begin
  Result := TDTC40_UserDB_Client(DTC40_ClientPool.ExistsConnectedServiceTyp('userDB'));
end;

begin
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  { Connect the dispatcher and user identity database services }
  DTC40.DTC40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'DP|UserDB', nil);

  { Waitconnected done can check whether multiple dependent services are ready at the same time }
  DTC40.DTC40_ClientPool.WaitConnectedDoneP('DP|UserDB', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    begin
      { Permanently add a login alias to testuser, such as e-mail and mobile phone number }
      GetMyUserDB_Client.Usr_NewIdentifierP('testUser', 'test@mail.com',
        procedure(sender: TDTC40_UserDB_Client; State_: Boolean; info_: SystemString)
        begin
          DoStatus(info_);
        end);

      { The alias is used to remotely verify the user's identity. Here is only the verification return, which is convenient for the VM server to work. The userdb does not do any login processing, and the login processing is done on the VM server }
      GetMyUserDB_Client.Usr_AuthP('test@mail.com', '123456',
        procedure(sender: TDTC40_UserDB_Client; State_: Boolean; info_: SystemString)
        begin
          DoStatus(info_);
        end);
    end);

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
