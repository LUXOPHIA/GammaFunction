unit Viewer;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Viewport3D,
  LUX.D4x4,
  LUX.FMX.Graphics.D3,
  LUX.Gamma.FMX.D3,
  LUX.Gamma.C2.Diff;

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
       _World3D  :TF3DWorld;
       _Camera3D :TF3DCamera;
       _Light3D  :TF3DLight;
       _Gamma3D  :TGamma3D;
     public
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
     end;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TViewerFrame

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TViewerFrame.Create( Owner_:TComponent );
begin
     inherited;

     _World3D := TF3DWorld.Create( Viewport3D1 );

     _Camera3D := TF3DCamera.Create( _World3D );
     _Camera3D.Pose := TSingleM4.RotateX( DegToRad( 0 ) )
                     * TSingleM4.Translate( 0, 0, 20 );

     Viewport3D1.Camera := _Camera3D.Camera;

     _Light3D := TF3DLight.Create( _Camera3D );
     _Light3D.Pose := TSingleM4.RotateX( DegToRad( -45 ) );

     _Gamma3D := TGamma3D.Create( _World3D );
     _Gamma3D.Material.Ambient  := TAlphaColors.Black;
     _Gamma3D.Material.Diffuse  := TAlphaColors.White;
     _Gamma3D.Material.Specular := TAlphaColors.Null;
     _Gamma3D.Material.Texture.LoadFromFile( '../../_DATA/Texture 1024x1024.png' );
     _Gamma3D.Pose := TSingleM4.Translate( 1/2, -2*Sqrt(Pi), 0 );
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
