unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  System.Sensors.Components, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    LocationSensor1: TLocationSensor;
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);

    // コンポーネントのイベントはオブジェクトインスペクタからイベントを
    // 選ぶだけで自動的に前方宣言と空の実体部が生成されるが、
    // 逆ジオコーディングのプロシジャーはコンポーネントに紐づかないため
    // このプロシジャーだけは自分で前方宣言を記述する。
    procedure OnGeocodeReverseEvent( const Address: TCivicAddress );

  private
    { private 宣言 }
    // ジオコーディングのオブジェクト
    FGeocoder: TGeocoder;

  public
    { public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
    // FGeocoder が未割当の場合は TGeocoder を新規に生成してイベントハンドラを割り当てる
    if not Assigned(FGeocoder) then
    begin
      if Assigned(TGeocoder.Current) then
        FGeocoder := TGeocoder.Current.Create;
      if Assigned(FGeocoder) then
        FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
    end;

    // FGeocoder が割り当て済みならば、現在の緯度経度情報から住所情報の取得を行う。
    if Assigned(FGeocoder) and not FGeocoder.Geocoding then
      FGeocoder.GeocodeReverse(NewLocation);
end;

// 逆ジオコーディング実行時の処理
procedure TForm1.OnGeocodeReverseEvent( const Address: TCivicAddress );
begin
  // 緯度経度から現在位置の住所が取得できた場合は表示を更新する。
  Memo1.Lines.Insert(0,Address.AdminArea);
  Memo1.Lines.Insert(0,Address.CountryCode);
  Memo1.Lines.Insert(0,Address.CountryName);
  Memo1.Lines.Insert(0,Address.FeatureName);
  Memo1.Lines.Insert(0,Address.Locality);
  Memo1.Lines.Insert(0,Address.PostalCode);
  Memo1.Lines.Insert(0,Address.SubAdminArea);
  Memo1.Lines.Insert(0,Address.SubLocality);
  Memo1.Lines.Insert(0,Address.SubThoroughfare);
  Memo1.Lines.Insert(0,Address.Thoroughfare);
  Memo1.Lines.Insert(0,'----------');
end;

end.
