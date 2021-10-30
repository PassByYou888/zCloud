program DTC40_UserDB_AdminTool;



uses
  Vcl.Forms,
  DTC40_UserDB_AdminToolFrm in 'DTC40_UserDB_AdminToolFrm.pas' {DTC40_UserDB_AdminToolForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDTC40_UserDB_AdminToolForm, DTC40_UserDB_AdminToolForm);
  Application.Run;
end.
