program FMXPDFViewerbtns;

uses
  System.StartUpCopy,
  FMX.Forms,
  main in 'main.pas' {fmPDFview};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmPDFview, fmPDFview);
  Application.Run;
end.
