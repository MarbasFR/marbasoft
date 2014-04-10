program ldvelh_import;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  ldvelh.functions in 'ldvelh.functions.pas',
  ldvelh.classes in 'ldvelh.classes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
