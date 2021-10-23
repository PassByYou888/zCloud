program C40AppTemplet;

uses
  Vcl.Forms,
  System.SysUtils,
  C40AppTempletFrm in 'C40AppTempletFrm.pas' {C40AppTempletForm};

{$R *.res}


procedure InitC40AppParamFromCmd;
var
  i: integer;
begin
  SetLength(C40AppParam, ParamCount);
  for i := 1 to ParamCount do
      C40AppParam[i - 1] := ParamStr(i);
end;

begin
  InitC40AppParamFromCmd;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TC40AppTempletForm, C40AppTempletForm);
  Application.Run;

end.
