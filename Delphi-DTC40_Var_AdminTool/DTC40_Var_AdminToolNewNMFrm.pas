unit DTC40_Var_AdminToolNewNMFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Actions, Vcl.ActnList,

  Vcl.FileCtrl,
  System.IOUtils, System.DateUtils, System.TypInfo,

  CoreClasses, PascalStrings, UnicodeMixedLib, DoStatusIO,
  ListEngine, GHashList, zExpression, OpCode, TextParsing, DataFrameEngine, TextDataEngine,
  ZJson, Geometry2DUnit, Geometry3DUnit, NumberBase,
  MemoryStream64, CoreCipher, NotifyObjectBase, ZIOThread,
  CommunicationFramework,
  CommunicationFrameworkDoubleTunnelIO,
  CommunicationFrameworkDoubleTunnelIO_NoAuth,
  CommunicationFrameworkDoubleTunnelIO_VirtualAuth,
  CommunicationFrameworkDataStoreService,
  CommunicationFrameworkDataStoreService_NoAuth,
  CommunicationFrameworkDataStoreService_VirtualAuth,
  CommunicationFrameworkDataStoreServiceCommon,
  ObjectData, ObjectDataManager, ZDBEngine, ZDBLocalManager,
  FileIndexPackage, FilePackage, ItemStream, ObjectDataHashField, ObjectDataHashItem,
  ZDB2, ZDB2_Core, ZDB2_DFE, ZDB2_HS, ZDB2_HV, ZDB2_Json, ZDB2_MS64, ZDB2_NM, ZDB2_TE, ZDB2_FileEncoder,
  DTC40, DTC40_UserDB, DTC40_Var, DTC40_FS, DTC40_RandSeed, DTC40_Log_DB,
  PhysicsIO;

type
  TDTC40_Var_AdminToolNewNMForm = class(TForm)
    NameEdit: TLabeledEdit;
    Label1: TLabel;
    ScriptMemo: TMemo;
    TempCheckBox: TCheckBox;
    LifeTimeEdit: TLabeledEdit;
    CreateNMButton: TButton;
    CancelButton: TButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure CreateNMButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
  public
  end;

var
  DTC40_Var_AdminToolNewNMForm: TDTC40_Var_AdminToolNewNMForm;

implementation

{$R *.dfm}


uses DTC40_Var_AdminToolFrm;

procedure TDTC40_Var_AdminToolNewNMForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TDTC40_Var_AdminToolNewNMForm.CreateNMButtonClick(Sender: TObject);
var
  i: Integer;
  n: U_String;
  nmPool: TDTC40_VarService_NM_Pool;
begin
  if DTC40_Var_AdminToolForm.CurrentClient = nil then
      exit;

  nmPool := DTC40_Var_AdminToolForm.CurrentClient.GetNM(NameEdit.Text);
  for i := 0 to ScriptMemo.Lines.Count - 1 do
    begin
      n := ScriptMemo.Lines[i];
      if n.L > 0 then
        begin
          if nmPool.IsVectorScript(n, tsPascal) then
              nmPool.RunVectorScript(n)
          else
              nmPool.RunScript(n);
        end;
    end;

  if TempCheckBox.Checked then
      DTC40_Var_AdminToolForm.CurrentClient.NM_InitAsTemp(NameEdit.Text, EStrToInt(LifeTimeEdit.Text, 5 * 1000), True, nmPool)
  else
      DTC40_Var_AdminToolForm.CurrentClient.NM_Init(NameEdit.Text, True, nmPool);
end;

procedure TDTC40_Var_AdminToolNewNMForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
end;

end.
