unit _3_Auth_IM_Client_LoginFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,

  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  DoStatusIO,
  NotifyObjectBase,
  CommunicationFramework,
  PhysicsIO,
  DTC40;

type
  T_3_Auth_IM_Client_LoginForm = class(TForm)
    UserEdit: TLabeledEdit;
    PasswdEdit: TLabeledEdit;
    loginButton: TButton;
    cancelButton: TButton;
    regButton: TButton;
    HostEdit: TLabeledEdit;
    PortEdit: TLabeledEdit;
    procedure loginButtonClick(Sender: TObject);
    procedure regButtonClick(Sender: TObject);
    procedure cancelButtonClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  _3_Auth_IM_Client_LoginForm: T_3_Auth_IM_Client_LoginForm;

implementation

{$R *.dfm}


uses _3_Auth_IM_Client_Frm, _3_Auth_IM_Client_RegFrm;

procedure T_3_Auth_IM_Client_LoginForm.loginButtonClick(Sender: TObject);
begin
  DTC40.DTC40_PhysicsTunnelPool.SearchServiceAndBuildConnection(HostEdit.Text, umlStrToInt(PortEdit.Text), False, 'MyVA', _3_Auth_IM_Client_Form);

  DTC40.DTC40_ClientPool.WaitConnectedDoneP('MyVA', procedure(States_: TDTC40_Custom_ClientPool_Wait_States)
    var
      cli: TMyVA_Client;
    begin
      cli := States_[0].Client_ as TMyVA_Client;
      cli.Client.Connect_P(UserEdit.Text, PasswdEdit.Text, procedure(const State: Boolean)
        begin
          if State then
            begin
              DoStatus('Login succeeded');
            end;
        end);
    end)
end;

procedure T_3_Auth_IM_Client_LoginForm.regButtonClick(Sender: TObject);
begin
  DTC40.DTC40_PhysicsTunnelPool.SearchServiceAndBuildConnection(HostEdit.Text, umlStrToInt(PortEdit.Text), False, 'MyVA', _3_Auth_IM_Client_Form);
  _3_Auth_IM_Client_RegForm.Show;
end;

procedure T_3_Auth_IM_Client_LoginForm.cancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure T_3_Auth_IM_Client_LoginForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
      Close;
end;

procedure T_3_Auth_IM_Client_LoginForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caHide;
end;

end.
