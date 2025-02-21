unit Main;

interface //#################################################################### ■

uses
  System.Classes, System.Generics.Collections,
  FMX.Controls, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Types, FMX.Forms, FMX.ListBox,
  LUX.Complex,
  LUX.Complex.Diff,
  LUX.C2.Gamma.Lanczos.Diff,
  LUX.C2.Gamma.Ooura.Diff,
  Viewer;

type
  TForm1 = class(TForm)
    Viewer1: TViewerFrame;
    Panel1: TPanel;
    LabelA: TLabel;
    ComboBoxA: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBoxAChange(Sender: TObject);
  private
    { private 宣言 }
  public
    { public 宣言 }
    _Gammas :TList<TdDoubleCFunc>;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Gammas := TList<TdDoubleCFunc>.Create;

     _Gammas.Add( LUX.C2.Gamma.Lanczos.Diff.Gamma7  );  // 0
     _Gammas.Add( LUX.C2.Gamma.Lanczos.Diff.Gamma9  );  // 1
     _Gammas.Add( LUX.C2.Gamma.Lanczos.Diff.Gamma11 );  // 2
     _Gammas.Add( LUX.C2.Gamma.Lanczos.Diff.Gamma15 );  // 3
     _Gammas.Add( LUX.C2.Gamma.Ooura  .Diff.Gamma   );  // 4

     Viewer1.Area  := TDoubleAreaC.Create( -5, -5, +5, +5 );
     Viewer1.DivX  := 256;
     Viewer1.DivY  := 256;
     Viewer1.Scale := 2*Sqrt(Pi);

     ComboBoxAChange( Sender );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _Gammas.Free;
end;

//------------------------------------------------------------------------------

procedure TForm1.ComboBoxAChange(Sender: TObject);
begin
     Viewer1.Func := _Gammas[ ComboBoxA.ItemIndex ];
end;

end. //######################################################################### ■
