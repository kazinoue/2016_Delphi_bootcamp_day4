unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  System.Sensors.Components, FMXTee.Engine, FMXTee.Series, FMXTee.Procs,
  FMXTee.Chart, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.ExtCtrls,
  FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Maps,
  FMX.TabControl, System.Math;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItem1MapView: TTabItem;
    MapView1: TMapView;
    ButtonShowCurrentLocation: TButton;
    SwitchMapView: TSwitch;
    TabItem2GeoCoder: TTabItem;
    ListBoxAddressInfo: TListBox;
    ListBoxGroupHeader1Location: TListBoxGroupHeader;
    ListBoxItemLatitude: TListBoxItem;
    ListBoxItemLongitude: TListBoxItem;
    ListBoxGroupHeader2Address: TListBoxGroupHeader;
    ListBoxItemAdminArea: TListBoxItem;
    ListBoxItemCountryCode: TListBoxItem;
    ListBoxItemCountryName: TListBoxItem;
    ListBoxItemFeatureName: TListBoxItem;
    ListBoxItemLocality: TListBoxItem;
    ListBoxItemPostalCode: TListBoxItem;
    ListBoxItemSubAdminArea: TListBoxItem;
    ListBoxItemSubLocality: TListBoxItem;
    ListBoxItemSubThoroughfare: TListBoxItem;
    ListBoxItemThoroughfare: TListBoxItem;
    TabItem3MotionSensor: TTabItem;
    Layout2: TLayout;
    Label1AccelX: TLabel;
    Label2AccelY: TLabel;
    Label3AccelZ: TLabel;
    LabelSyntheticAccel: TLabel;
    PlotGrid1: TPlotGrid;
    CircleTiltSensor: TCircle;
    SwitchLocationSensor: TSwitch;
    TabItem4Detail: TTabItem;
    Memo1: TMemo;
    ChartAccel: TChart;
    SyntheticAccel: TLineSeries;
    AccelX: TLineSeries;
    AccelY: TLineSeries;
    AccelZ: TLineSeries;
    Timer1: TTimer;
    StyleBook1: TStyleBook;
    LocationSensor1: TLocationSensor;
    MotionSensor1: TMotionSensor;
    Layout1: TLayout;
    Layout3: TLayout;
    procedure SwitchMapViewSwitch(Sender: TObject);
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure ButtonShowCurrentLocationClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    // コンポーネントのイベントはオブジェクトインスペクタからイベントを
    // 選ぶだけで自動的に前方宣言と空の実体部が生成されるが、
    // 逆ジオコーディングのプロシジャーはコンポーネントに紐づかないため
    // このプロシジャーだけは自分で前方宣言を記述する。
    procedure OnGeocodeReverseEvent( const Address: TCivicAddress );
    procedure SwitchLocationSensorSwitch(Sender: TObject);

  private
    { private 宣言 }
    // 地図の中心位置を保存する変数
    mapCenter: TMapCoordinate;

    // ジオコーディングのオブジェクト
    FGeocoder: TGeocoder;

    // グラフに描画済みの要素数
    numCount: integer;

  public
    { public 宣言 }

  const
    // 傾きセンサー表示用の円の大きさ
    circleDiameter = 50;

    // 測定された加速度に対する補正値
    accelCoefficient = 100;

    // 加速度グラフの横軸幅
    axis_x_limit = 50;

    // グラフをスクロールするかどうか
    graphScroll = false;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

// Switch1 が押されたときの処理。
procedure TForm1.ButtonShowCurrentLocationClick(Sender: TObject);
begin
  // 地図の表示を現在位置中心にする。
  MapView1.Location := mapCenter;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  numCount := 0;

  mapCenter := TMapCoordinate.Create( 0, 0 );

  // アプリ起動時は必ず MapView を表示する。
  TabControl1.ActiveTab := TabItem1MapView;
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  LocationString: String;
  distance: double;
begin
  // 以前の計測と直近の計測の位置を求める。
  //
  // 地球を球体とみなす場合の距離計算近似式（メートル単位）
  // cf: http://www.orsj.or.jp/archive2/or60-12/or60_12_701.pdf
  distance := 6371000 * arccos(
        sin( DegToRad(mapCenter.Latitude) ) * sin( DegToRad(NewLocation.Latitude) ) +
        cos( DegToRad(mapCenter.Latitude) ) * cos( DegToRad(NewLocation.Latitude) ) * cos( DegToRad(mapCenter.Longitude) - DegToRad(NewLocation.Longitude) ) );

  // 三角関数を使わない近似式の例
  // 三平方の定理を使う近似です。計算距離が小さめに出ます。
  // distance := sqrt(
  //   power(mapCenter.Latitude  - NewLocation.Latitude, 2) +
  //   power(mapCenter.Longitude - NewLocation.Longitude,2)
  // ) * 1000;

  // 計測した緯度経度を Debug 用の Memo に出力する。
  LocationString := Format( 'Lat:%2.6f, Lng:%3.6f (dist=%f)', [NewLocation.Latitude, NewLocation.Longitude, distance] );
  Memo1.Lines.Insert(0,LocationString);

  // 前回の位置と今回の位置の距離が10メートル未満なら何もしない。
  if (distance < 10)  then
    exit;

  // 計測した緯度経度を ListBox 内の Latitude, Longitude にも表示する。
  ListBoxItemLatitude.ItemData.Detail  := Format( '%2.6f', [NewLocation.Latitude]  );
  ListBoxItemLOngitude.ItemData.Detail := Format( '%3.6f', [NewLocation.Longitude] );

  // 地図の現在位置情報を書き換える。
  mapCenter := TMapCoordinate.Create( NewLocation.Latitude, NewLocation.Longitude );
  MapView1.Location := mapCenter;

  // 現在の緯度経度に対応する住所を取得するための一連の処理。
  try
    if not Assigned(FGeocoder) then
    begin
      if Assigned(TGeocoder.Current) then
        FGeocoder := TGeocoder.Current.Create;
      if Assigned(FGeocoder) then
        FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
    end;

    if Assigned(FGeocoder) and not FGeocoder.Geocoding then
      FGeocoder.GeocodeReverse(NewLocation);
  except
    ListBoxGroupHeader1Location.Text := 'Geocode service error';
  end;
end;

procedure TForm1.SwitchLocationSensorSwitch(Sender: TObject);
begin
  // スイッチで LocationSensor の値の読み取りを on / off する。
  // 実際の処理は TTimer の有効化、無効化の切り替え。
  Timer1.Enabled := SwitchLocationSensor.IsChecked;
end;

procedure TForm1.SwitchMapViewSwitch(Sender: TObject);
begin
  // 衛星画像と通常地図の切り替えを行う
  if( SwitchMapView.IsChecked ) then
    MapView1.MapType := TMapType.Satellite
  else
    MapView1.MapType := TMapType.Normal;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  // 加速度。
  syntheticAccel: double;

  // X,Y,Z軸の加速度。
  AccelX: double;
  AccelY: double;
  AccelZ: double;

  // 円が画面外に出ているかどうかのフラグ
  outOfGrid: boolean;
begin
  begin
    // x,y,z軸の加速度を取得する。
    AccelX := MotionSensor1.Sensor.AccelerationX * accelCoefficient;
    AccelY := MotionSensor1.Sensor.AccelerationY * accelCoefficient;
    AccelZ := MotionSensor1.Sensor.AccelerationZ * accelCoefficient;

    // 3軸の合成加速度を算出する。
    // これは加速度ベクトルの大きさ（スカラー成分）だけを取り出す処理。
    // 3軸の加速度が変化しても合成加速度に変化がなければ、
    // 物体の運動は変化していないと判断できる。
    syntheticAccel := sqrt( power(AccelX,2) + power(AccelY,2) + power(AccelZ,2) );

    // 取得した値をラベルに出力する。
    Label1AccelX.Text := Format( 'X: %3.2f', [ AccelX ] );
    Label2AccelY.Text := Format( 'Y: %3.2f', [ AccelY ] );
    Label3AccelZ.Text := Format( 'Z: %3.2f', [ AccelZ ] );
    LabelSyntheticAccel.Text := Format( 'accel: %3.2f', [ syntheticAccel ] );

    // 加速度の + - によってフォントの色を変える。
    If( AccelX >= 0 ) then
      Label1AccelX.TextSettings.FontColor := TAlphaColorRec.Black
    else
      Label1AccelX.TextSettings.FontColor := TAlphaColorRec.Red;

    If( AccelY >= 0 ) then
      Label2AccelY.TextSettings.FontColor := TAlphaColorRec.Black
    else
      Label2AccelY.TextSettings.FontColor := TAlphaColorRec.Red;
  
    If( AccelZ >= 0 ) then
      Label3AccelZ.TextSettings.FontColor := TAlphaColorRec.Black
    else
      Label3AccelZ.TextSettings.FontColor := TAlphaColorRec.Red;

    // Circle の直径を合成加速度に合わせて変える。
    CircleTiltSensor.Width  := circleDiameter*syntheticAccel/accelCoefficient;
    CircleTiltSensor.Height := CircleTiltSensor.Width;

    // Circle を x, y 軸の加速度の値に合わせて Grid に重ねて表示する。
    CircleTiltSensor.Position.X := ((PlotGrid1.Width  - CircleTiltSensor.Width )/2.0) - (AccelX*10.0);
    CircleTiltSensor.Position.Y := ((PlotGrid1.Height - CircleTiltSensor.Height)/2.0) + (AccelY*10.0);
    
    // Circle の計算上の位置が画面の外にはみ出しそうな場合は、
    // はみ出さないように計算結果を補正する。
    outOfGrid := false;

    if (CircleTiltSensor.Position.X < 0) then begin
      CircleTiltSensor.Position.X := 0;
      outOfGrid := true;
    end
    else if (CircleTiltSensor.Position.X > PlotGrid1.Width - CircleTiltSensor.Width ) then begin
      CircleTiltSensor.Position.X := PlotGrid1.Width - CircleTiltSensor.Width;
      outOfGrid := true;
    end;

    if (CircleTiltSensor.Position.Y < 0) then begin
      CircleTiltSensor.Position.Y := 0;
      outOfGrid := true;
    end
    else if (CircleTiltSensor.Position.Y > PlotGrid1.Height - CircleTiltSensor.Height ) then begin
      CircleTiltSensor.Position.Y := PlotGrid1.Height - CircleTiltSensor.Height;
      outOfGrid := true;
    end;

    if (outOfGrid) then
      CircleTiltSensor.Stroke.Color := TAlphaColorRec.Red
    else
      CircleTiltSensor.Stroke.Color := TAlphaColorRec.Black;
  end;

  // グラフ描画に関する処理。
  begin

    if ( graphScroll = true ) then
    begin
      // グラフをスクロールする実装。
      // 通常はこちらを用いたほうが見栄えがよいが、Webセミナーでは使わない方向で。
      ChartAccel.Axes.Bottom.SetMinMax( numCount - axis_x_limit, numCount );
    end
    else
    begin
      // グラフをスクロールせずにページングする例
      // GoToWebiner 向けを想定した実装。
      if ( numCount mod axis_x_limit = 0 ) then
      begin
        ChartAccel.Series[0].Clear;
        ChartAccel.Series[1].Clear;
        ChartAccel.Series[2].Clear;
        ChartAccel.Series[3].Clear;
        ChartAccel.Axes.Bottom.SetMinMax( 0, axis_x_limit );
        ChartAccel.Axes.Left.SetMinMax( -(accelCoefficient*2), accelCoefficient*2 );
      end;
    end;

    Inc( numCount );

    ChartAccel.Series[0].AddY(syntheticAccel);
    ChartAccel.Series[1].AddY(AccelX);
    ChartAccel.Series[2].AddY(AccelY);
    ChartAccel.Series[3].AddY(AccelZ);

  end;
end;

// 逆ジオコーディング実行時の処理
procedure TForm1.OnGeocodeReverseEvent( const Address: TCivicAddress );
begin
  // 緯度経度から現在位置の住所が取得できた場合は表示を更新する。
  ListBoxItemAdminArea.ItemData.Detail       := Address.AdminArea;
  ListBoxItemCountryCode.ItemData.Detail     := Address.CountryCode;
  ListBoxItemCountryName.ItemData.Detail     := Address.CountryName;
  ListBoxItemFeatureName.ItemData.Detail     := Address.FeatureName;
  ListBoxItemLocality.ItemData.Detail        := Address.Locality;
  ListBoxItemPostalCode.ItemData.Detail      := Address.PostalCode;
  ListBoxItemSubAdminArea.ItemData.Detail    := Address.SubAdminArea;
  ListBoxItemSubLocality.ItemData.Detail     := Address.SubLocality;
  ListBoxItemSubThoroughfare.ItemData.Detail := Address.SubThoroughfare;
  ListBoxItemThoroughfare.ItemData.Detail    := Address.Thoroughfare;
end;

end.
