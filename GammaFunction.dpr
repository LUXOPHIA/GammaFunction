program GammaFunction;

uses
  System.StartUpCopy,
  FMX.Forms,
  LUX in '_LIBRARY\LUXOPHIA\LUX\LUX.pas',
  LUX.D1.DIff in '_LIBRARY\LUXOPHIA\LUX\LUX.D1.DIff.pas',
  LUX.D1 in '_LIBRARY\LUXOPHIA\LUX\LUX.D1.pas',
  LUX.D2.Diff in '_LIBRARY\LUXOPHIA\LUX\LUX.D2.Diff.pas',
  LUX.D2 in '_LIBRARY\LUXOPHIA\LUX\LUX.D2.pas',
  LUX.D2x2 in '_LIBRARY\LUXOPHIA\LUX\LUX.D2x2.pas',
  LUX.D3.Diff in '_LIBRARY\LUXOPHIA\LUX\LUX.D3.Diff.pas',
  LUX.D3 in '_LIBRARY\LUXOPHIA\LUX\LUX.D3.pas',
  LUX.D3x3 in '_LIBRARY\LUXOPHIA\LUX\LUX.D3x3.pas',
  LUX.D4.Diff in '_LIBRARY\LUXOPHIA\LUX\LUX.D4.Diff.pas',
  LUX.D4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D4.pas',
  LUX.D4x4.Diff in '_LIBRARY\LUXOPHIA\LUX\LUX.D4x4.Diff.pas',
  LUX.D4x4 in '_LIBRARY\LUXOPHIA\LUX\LUX.D4x4.pas',
  LUX.Complex in '_LIBRARY\LUXOPHIA\LUX\Complex\LUX.Complex.pas',
  LUX.Complex.Diff in '_LIBRARY\LUXOPHIA\LUX\Complex\LUX.Complex.Diff.pas',
  LUX.FMX.Graphics.D3 in '_LIBRARY\LUXOPHIA\LUX.FMX.Graphics.D3\LUX.FMX.Graphics.D3.pas',
  LUX.FMX.Graphics.D3.Shaper in '_LIBRARY\LUXOPHIA\LUX.FMX.Graphics.D3\LUX.FMX.Graphics.D3.Shaper.pas',
  LUX.Gamma.FMX.D3 in '_LIBRARY\LUX.Gamma.FMX.D3.pas',
  LUX.Gamma.C2 in '_LIBRARY\LUX.Gamma.C2.pas',
  LUX.Gamma.C2.Diff in '_LIBRARY\LUX.Gamma.C2.Diff.pas',
  Main in 'Main.pas' {Form1},
  Viewer in 'Viewer.pas' {ViewerFrame: TFrame},
  Core in 'Core.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
