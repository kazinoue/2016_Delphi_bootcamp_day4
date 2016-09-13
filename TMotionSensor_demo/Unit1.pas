unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Sensors,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.Sensors.Components,
  FMXTee.Engine, FMXTee.Series, FMXTee.Procs, FMXTee.Chart;

type
  TForm1 = class(TForm)
    MotionSensor1: TMotionSensor;
    Memo1: TMemo;
    Timer1: TTimer;
    Chart1: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    procedure Timer1Timer(Sender: TObject);
  private
    { private �錾 }
  public
    { public �錾 }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // �����x�Z���T�[�̑���l�� TMemo �ɏ����o���B
  Memo1.Lines.Insert(0,
    Format('X:%1.4f Y:%1.4f, Z:%1.4f',
      [
        MotionSensor1.Sensor.AccelerationX,
        MotionSensor1.Sensor.AccelerationY,
        MotionSensor1.Sensor.AccelerationZ
      ]
    )
  );

  // �����x�Z���T�[�̑���l�� TChart �ŃO���t�`�悷��B
  Chart1.Series[0].AddY(MotionSensor1.Sensor.AccelerationX);
  Chart1.Series[1].AddY(MotionSensor1.Sensor.AccelerationY);
  Chart1.Series[2].AddY(MotionSensor1.Sensor.AccelerationZ);
end;

end.
