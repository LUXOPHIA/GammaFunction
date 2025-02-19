unit Main;

interface //#################################################################### ■

uses
  System.Classes,
  FMX.Controls, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Types, FMX.Forms,
  Viewer;

type
  TForm1 = class(TForm)
    Viewer1: TViewerFrame;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private 宣言 }
  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
     /////
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     /////
end;

end. //######################################################################### ■
