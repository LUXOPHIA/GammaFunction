unit Viewer;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Viewport3D,
  LUX.D4x4,
  LUX.Complex,
  LUX.Complex.Diff,
  LUX.Complex.FMX.D3,
  LUX.FMX.Graphics.D3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【 T Y P E 】

     TViewerFrame = class( TFrame )
       Viewport3D1: TViewport3D;
       procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
       procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
       procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
     private
       _MouseS :TShiftState;
       _MouseP :TPointF;
       _Angle  :TPointF;
     protected
       _World3D   :TF3DWorld;
       _Camera3D  :TF3DCamera;
       _Light3D   :TF3DLight;
       _Complex3D :TComplex3D;
       ///// A C C E S S O R
       function GetFunc :TdDoubleCFunc;
       procedure SetFunc( const Func_:TdDoubleCFunc );
       function GetArea :TDoubleAreaC;
       procedure SetArea( const Area_:TDoubleAreaC );
       function GetDivX :Integer;
       procedure SetDivX( const DivX_:Integer );
       function GetDivY :Integer;
       procedure SetDivY( const DivY_:Integer );
       function GetScale :Double;
       procedure SetScale( const Scale_:Double );
     public
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
       ///// P R O P E R T Y
       property Func  :TdDoubleCFunc read GetFunc  write SetFunc ;
       property Area  :TDoubleAreaC  read GetArea  write SetArea ;
       property DivX  :Integer       read GetDivX  write SetDivX ;
       property DivY  :Integer       read GetDivY  write SetDivY ;
       property Scale :Double        read GetScale write SetScale;
     end;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TViewerFrame

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//////////////////////////////////////////////////////////////// A C C E S S O R

function TViewerFrame.GetFunc :TdDoubleCFunc;
begin
     Result := _Complex3D.Func;
end;

procedure TViewerFrame.SetFunc( const Func_:TdDoubleCFunc );
begin
     _Complex3D.Func := Func_;
end;

//------------------------------------------------------------------------------

function TViewerFrame.GetArea :TDoubleAreaC;
begin
     Result := _Complex3D.Area;
end;

procedure TViewerFrame.SetArea( const Area_:TDoubleAreaC );
begin
     _Complex3D.Area := Area_;
end;

//------------------------------------------------------------------------------

function TViewerFrame.GetDivX :Integer;
begin
     Result := _Complex3D.DivX;
end;

procedure TViewerFrame.SetDivX( const DivX_:Integer );
begin
     _Complex3D.DivX := DivX_;
end;

function TViewerFrame.GetDivY :Integer;
begin
     Result := _Complex3D.DivY;
end;

procedure TViewerFrame.SetDivY( const DivY_:Integer );
begin
     _Complex3D.DivY := DivY_;
end;

//------------------------------------------------------------------------------

function TViewerFrame.GetScale :Double;
begin
     Result := _Complex3D.Scale;
end;

procedure TViewerFrame.SetScale( const Scale_:Double );
begin
     _Complex3D.Scale := Scale_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TViewerFrame.Create( Owner_:TComponent );
begin
     inherited;

     _World3D := TF3DWorld.Create( Viewport3D1 );

     _Camera3D := TF3DCamera.Create( _World3D );
     _Camera3D.Pose := TSingleM4.Translate( 0, 0, 20 );

     Viewport3D1.Camera := _Camera3D.Camera;

     _Light3D := TF3DLight.Create( _Camera3D );
     _Light3D.Pose := TSingleM4.RotateX( DegToRad( -45 ) );

     _Complex3D := TComplex3D.Create( _World3D );
     _Complex3D.Material.Ambient  := TAlphaColorF.Create( 0.2, 0.2, 0.2 ).ToAlphaColor;
     _Complex3D.Material.Diffuse  := TAlphaColorF.Create( 0.8, 0.8, 0.8 ).ToAlphaColor;
     _Complex3D.Material.Specular := TAlphaColors.Null;
     _Complex3D.Material.Texture.LoadFromFile( '../../_DATA/Texture 1024x1024.png' );
     _Complex3D.Pose := TSingleM4.Translate( 1/2, -2*Sqrt(Pi), 0 );
end;

destructor TViewerFrame.Destroy;
begin

     inherited;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TViewerFrame.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TViewerFrame.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          _Angle := _Angle + ( P - _MouseP );

          _Camera3D.Pose := TSingleM4.RotateY( -DegToRad( _Angle.X ) )
                          * TSingleM4.RotateX( -DegToRad( _Angle.Y ) )
                          * TSingleM4.Translate( 0, 0, 20 );

          _MouseP := P;
     end;
end;

procedure TViewerFrame.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

end. //######################################################################### ■
