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
    { private 宣言 }
    // 現在位置を保持する変数
    CurrentLocation: TMapCoordinate;
  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  // 保持されている現在位置の情報で地図表示を行う。
  MapView1.Location := CurrentLocation;
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
  // 測位された現在位置情報を private 変数に保存しておく。
  CurrentLocation := TMapCoordinate.Create(NewLocation.Latitude,NewLocation.Longitude);

  // 現在位置の情報で地図表示を行う。
  MapView1.Location := CurrentLocation;
end;

procedure TForm1.Switch1Switch(Sender: TObject);
begin
  // マップ表示を通常の地図と衛星画像の切り替えを行う。
  if (Switch1.isChecked) then
    MapView1.Maptype := TMapType.Satellite
  else
    MapView1.MapType := TMapType.Normal;
end;

end.
