program AutohandelClaude;

uses
  Vcl.Forms,
  AutoHandel.BusinessCase.Verkauf in 'AutoHandel.BusinessCase.Verkauf.pas',
  AutoHandel.Interfaces in 'AutoHandel.Interfaces.pas',
  AutoHandel.Models in 'AutoHandel.Models.pas',
  AutoHandel.StateMachine in 'AutoHandel.StateMachine.pas',
  AutoHandel.Tests in 'AutoHandel.Tests.pas',
  AutoHandel.ViewModel.Verkauf in 'AutoHandel.ViewModel.Verkauf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
