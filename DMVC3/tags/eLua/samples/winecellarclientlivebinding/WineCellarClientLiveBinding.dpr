program WineCellarClientLiveBinding;

uses
  Vcl.Forms,
  MainFormU in 'MainFormU.pas' {Form5},
  MVCFramework.RESTClient in '..\..\sources\MVCFramework.RESTClient.pas',
  WinesBO in '..\winecellar\WinesBO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
