program _1_Auth_serv;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  CommunicationFramework,
  CommunicationFrameworkDoubleTunnelIO_VirtualAuth,
  DoStatusIO,
  PhysicsIO,
  ZJson,
  DTC40;

const
  { The public network address of the dispatching server port, which can be IPv4, IPv6 or DNS }
  { Public address, not 127.0.0.1 }
  Internet_DP_Addr_ = '127.0.0.1';
  { Scheduling server port }
  Internet_DP_Port_ = 8387;

type
  { Minimal authentication service }
  TMyVA_Service = class(TDTC40_Base_VirtualAuth_Service)
  protected
    procedure DoUserReg_Event(Sender: TDTService_VirtualAuth; RegIO: TVirtualRegIO); override;
    procedure DoUserAuth_Event(Sender: TDTService_VirtualAuth; AuthIO: TVirtualAuthIO); override;
  public
    { Simply open a JSON memory database, and the user stores the user authentication password }
    UserJson: TZJ;
    UserJsonFileName: U_String;
    constructor Create(PhysicsService_: TDTC40_PhysicsService; ServiceTyp, Param_: U_String); override;
    destructor Destroy; override;
  end;

procedure TMyVA_Service.DoUserReg_Event(Sender: TDTService_VirtualAuth; RegIO: TVirtualRegIO);
begin
  if UserJson.IndexOf(RegIO.UserID) < 0 then
    begin
      UserJson.S[RegIO.UserID] := RegIO.Passwd;
      RegIO.Accept;
      DoStatus('Successfully registered user "%s"', [RegIO.UserID]);
      UserJson.SaveToFile(UserJsonFileName);
    end
  else
    begin
      DoStatus('Duplicate registered user name "%s"', [RegIO.UserID]);
      RegIO.Reject;
    end;
end;

procedure TMyVA_Service.DoUserAuth_Event(Sender: TDTService_VirtualAuth; AuthIO: TVirtualAuthIO);
begin
  if (UserJson.IndexOf(AuthIO.UserID) >= 0) and umlSameText(UserJson.S[AuthIO.UserID], AuthIO.Passwd) then
    begin
      AuthIO.Accept;
      DoStatus('User authentication succeeded "%s"', [AuthIO.UserID]);
    end
  else
    begin
      AuthIO.Reject;
      DoStatus('User authentication failed "%s"', [AuthIO.UserID]);
    end;
end;

constructor TMyVA_Service.Create(PhysicsService_: TDTC40_PhysicsService; ServiceTyp, Param_: U_String);
begin
  inherited Create(PhysicsService_, ServiceTyp, Param_);
  UserJson := TZJ.Create;
  UserJsonFileName := umlCombineFileName(DTVirtualAuthService.PublicFileDirectory, 'user.json');
  if umlFileExists(UserJsonFileName) then
      UserJson.LoadFromFile(UserJsonFileName);
end;

destructor TMyVA_Service.Destroy;
begin
  DisposeObject(UserJson);
  inherited Destroy;
end;

begin
  { In one sentence, summarize the automatic authentication network. After passing the first authentication, start the automatic network }

  RegisterC40('MyVA', TMyVA_Service, TDTC40_Base_VirtualAuth_Client);
  { Open log information }
  DTC40.DTC40_QuietMode := False;

  { Virtuaauth dual channel service with authentication mechanism in C4 network }
  { Virtuaauth can work in a non authenticated environment }
  with DTC40.TDTC40_PhysicsService.Create(Internet_DP_Addr_, Internet_DP_Port_, PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('MyVA');
      StartService;
    end;

  { Main cycle }
  while True do
    begin
      DTC40.C40Progress;
      TCompute.Sleep(1);
    end;

end.
