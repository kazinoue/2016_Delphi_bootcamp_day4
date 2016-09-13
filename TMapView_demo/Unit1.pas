unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  System.Sensors.Components, FMX.StdCtrls, FMX.Layouts,
  FMX.Controls.Presentation, FMX.Maps;

type
  TForm1 = class(TForm)
    MapView1: TMapView;
    Button1: TButton;
    Layout1: TLayout;
    Switch1: TSwitch;
    LocationSensor1: TLocationSensor;
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure Switch1Switch(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { private �錾 }
    // ���݈ʒu��ێ�����ϐ�
    CurrentLocation: TMapCoordinate;
  public
    { public �錾 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  // �ێ�����Ă��錻�݈ʒu�̏��Œn�}�\�����s���B
  MapView1.Location := CurrentLocation;
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
  // ���ʂ��ꂽ���݈ʒu���� private �ϐ��ɕۑ����Ă����B
  CurrentLocation := TMapCoordinate.Create(NewLocation.Latitude,NewLocation.Longitude);

  // ���݈ʒu�̏��Œn�}�\�����s���B
  MapView1.Location := CurrentLocation;
end;

procedure TForm1.Switch1Switch(Sender: TObject);
begin
  // �}�b�v�\����ʏ�̒n�}�Ɖq���摜�̐؂�ւ����s���B
  if (Switch1.isChecked) then
    MapView1.Maptype := TMapType.Satellite
  else
    MapView1.MapType := TMapType.Normal;
end;

end.
