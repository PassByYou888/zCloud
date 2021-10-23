program C40AppTemplet;

{$mode objfpc}{$H+}

uses
  jemalloc4p,
  {$IFNDEF MSWINDOWS}
  cthreads,
  {$ENDIF MSWINDOWS}
  Interfaces, // this includes the LCL widgetset
  Forms, c40apptempletfrm
  { you can add units after this };

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
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TC40AppTempletForm, C40AppTempletForm);
  Application.Run;
end.

