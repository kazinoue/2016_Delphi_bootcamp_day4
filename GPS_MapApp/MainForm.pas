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

    // �R���|�[�l���g�̃C�x���g�̓I�u�W�F�N�g�C���X�y�N�^����C�x���g��
    // �I�Ԃ����Ŏ����I�ɑO���錾�Ƌ�̎��̕�����������邪�A
    // �t�W�I�R�[�f�B���O�̃v���V�W���[�̓R���|�[�l���g�ɕR�Â��Ȃ�����
    // ���̃v���V�W���[�����͎����őO���錾���L�q����B
    procedure OnGeocodeReverseEvent( const Address: TCivicAddress );

  private
    { private �錾 }
    // �n�}�̒��S�ʒu��ۑ�����ϐ�
    mapCenter: TMapCoordinate;

    // �W�I�R�[�f�B���O�̃I�u�W�F�N�g
    FGeocoder: TGeocoder;

    // �O���t�ɕ`��ς݂̗v�f��
    numCount: integer;

  public
    { public �錾 }

  const
    // �X���Z���T�[�\���p�̉~�̑傫��
    circleDiameter = 50;

    // ���肳�ꂽ�����x�ɑ΂���␳�l
    accelCoefficient = 100;

    // �����x�O���t�̉�����
    axis_x_limit = 50;

    // �O���t���X�N���[�����邩�ǂ���
    graphScroll = false;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

// Switch1 �������ꂽ�Ƃ��̏����B
procedure TForm1.ButtonShowCurrentLocationClick(Sender: TObject);
begin
  // �n�}�̕\�������݈ʒu���S�ɂ���B
  MapView1.Location := mapCenter;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  numCount := 0;

  // �A�v���N�����͕K�� MapView ��\������B
  TabControl1.ActiveTab := TabItem1MapView;
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  LocationString: String;
begin
  // �v�������ܓx�o�x�� Debug �p�� Memo �ɏo�͂���B
  LocationString := Format( '%2.6f, %2.6f', [NewLocation.Latitude, NewLocation.Longitude] );
  Memo1.Lines.Insert(0,LocationString);

  // �v�������ܓx�o�x�� ListBox ���� Latitude, Longitude �ɂ��\������B
  ListBoxItemLatitude.ItemData.Detail  := Format( '%2.6f', [NewLocation.Latitude]  );
  ListBoxItemLOngitude.ItemData.Detail := Format( '%2.6f', [NewLocation.Longitude] );

  // �n�}�̌��݈ʒu��������������B
  mapCenter := TMapCoordinate.Create( NewLocation.Latitude, NewLocation.Longitude );
  MapView1.Location := mapCenter;

  // ���݂̈ܓx�o�x�ɑΉ�����Z�����擾���邽�߂̈�A�̏����B
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

procedure TForm1.SwitchMapViewSwitch(Sender: TObject);
begin
  // �q���摜�ƒʏ�n�}�̐؂�ւ����s��
  if( SwitchMapView.IsChecked ) then
    MapView1.MapType := TMapType.Satellite
  else
    MapView1.MapType := TMapType.Normal;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  // �����x�B
  syntheticAccel: double;

  // X,Y,Z���̉����x�B
  AccelX: double;
  AccelY: double;
  AccelZ: double;

  // �~����ʊO�ɏo�Ă��邩�ǂ����̃t���O
  outOfGrid: boolean;
begin
  begin
    // x,y,z���̉����x���擾����B
    AccelX := MotionSensor1.Sensor.AccelerationX * accelCoefficient;
    AccelY := MotionSensor1.Sensor.AccelerationY * accelCoefficient;
    AccelZ := MotionSensor1.Sensor.AccelerationZ * accelCoefficient;

    // 3���̍��������x���Z�o����B
    // ����͉����x�x�N�g���̑傫���i�X�J���[�����j���������o�������B
    // 3���̉����x���ω����Ă����������x�ɕω����Ȃ���΁A
    // ���̂̉^���͕ω����Ă��Ȃ��Ɣ��f�ł���B
    syntheticAccel := sqrt( power(AccelX,2) + power(AccelY,2) + power(AccelZ,2) );

    // �擾�����l�����x���ɏo�͂���B
    Label1AccelX.Text := Format( 'X: %3.2f', [ AccelX ] );
    Label2AccelY.Text := Format( 'Y: %3.2f', [ AccelY ] );
    Label3AccelZ.Text := Format( 'Z: %3.2f', [ AccelZ ] );
    LabelSyntheticAccel.Text := Format( 'accel: %3.2f', [ syntheticAccel ] );

    // �����x�� + - �ɂ���ăt�H���g�̐F��ς���B
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

    // Circle �̒��a�����������x�ɍ��킹�ĕς���B
    CircleTiltSensor.Width  := circleDiameter*syntheticAccel/accelCoefficient;
    CircleTiltSensor.Height := CircleTiltSensor.Width;

    // Circle �� x, y ���̉����x�̒l�ɍ��킹�� Grid �ɏd�˂ĕ\������B
    CircleTiltSensor.Position.X := ((PlotGrid1.Width  - CircleTiltSensor.Width )/2.0) - (AccelX*10.0);
    CircleTiltSensor.Position.Y := ((PlotGrid1.Height - CircleTiltSensor.Height)/2.0) + (AccelY*10.0);
    
    // Circle �̌v�Z��̈ʒu����ʂ̊O�ɂ͂ݏo�������ȏꍇ�́A
    // �͂ݏo���Ȃ��悤�Ɍv�Z���ʂ�␳����B
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

  // �O���t�`��Ɋւ��鏈���B
  begin

    if ( graphScroll = true ) then
    begin
      // �O���t���X�N���[����������B
      // �ʏ�͂������p�����ق������h�����悢���AWeb�Z�~�i�[�ł͎g��Ȃ������ŁB
      ChartAccel.Axes.Bottom.SetMinMax( numCount - axis_x_limit, numCount );
    end
    else
    begin
      // �O���t���X�N���[�������Ƀy�[�W���O�����
      // GoToWebiner ������z�肵�������B
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

// �t�W�I�R�[�f�B���O���s���̏���
procedure TForm1.OnGeocodeReverseEvent( const Address: TCivicAddress );
begin
  // �ܓx�o�x���猻�݈ʒu�̏Z�����擾�ł����ꍇ�͕\�����X�V����B
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
