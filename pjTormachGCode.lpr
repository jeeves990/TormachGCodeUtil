program pjTormachGCode;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  frmTormachGCode,
  dialogs,
  lazcontrols, formAnnotateGCode, untStore;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
//	Application.CreateForm(Tdmod, dmod);
//  Application.CreateForm(TformGCodeFile, formGCodeFile);
  Application.CreateForm(TfrmTormach, frmTormach);
  Application.Run;
end.

