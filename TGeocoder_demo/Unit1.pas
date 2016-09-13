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

    // �R���|�[�l���g�̃C�x���g�̓I�u�W�F�N�g�C���X�y�N�^����C�x���g��
    // �I�Ԃ����Ŏ����I�ɑO���錾�Ƌ�̎��̕�����������邪�A
    // �t�W�I�R�[�f�B���O�̃v���V�W���[�̓R���|�[�l���g�ɕR�Â��Ȃ�����
    // ���̃v���V�W���[�����͎����őO���錾���L�q����B
    procedure OnGeocodeReverseEvent( const Address: TCivicAddress );

  private
    { private �錾 }
    // �W�I�R�[�f�B���O�̃I�u�W�F�N�g
    FGeocoder: TGeocoder;

  public
    { public �錾 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
    // FGeocoder ���������̏ꍇ�� TGeocoder ��V�K�ɐ������ăC�x���g�n���h�������蓖�Ă�
    if not Assigned(FGeocoder) then
    begin
      if Assigned(TGeocoder.Current) then
        FGeocoder := TGeocoder.Current.Create;
      if Assigned(FGeocoder) then
        FGeocoder.OnGeocodeReverse := OnGeocodeReverseEvent;
    end;

    // FGeocoder �����蓖�čς݂Ȃ�΁A���݂̈ܓx�o�x��񂩂�Z�����̎擾���s���B
    if Assigned(FGeocoder) and not FGeocoder.Geocoding then
      FGeocoder.GeocodeReverse(NewLocation);
end;

// �t�W�I�R�[�f�B���O���s���̏���
procedure TForm1.OnGeocodeReverseEvent( const Address: TCivicAddress );
begin
	// �ܓx�o�x���猻�݈ʒu�̏Z�����擾�ł����ꍇ�͕\�����X�V����B
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
