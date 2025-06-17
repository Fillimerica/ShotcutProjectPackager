program ShotcutProjectPackager;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Packager, FormRestoreProjectFiles, formColorLegend,
  FormCreatePackageFile, formSaveSettings;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmPackage, frmPackage);
  Application.CreateForm(TfrmRestore, frmRestore);
  Application.CreateForm(TfrmProgress, frmProgress);
  Application.CreateForm(TfrmLegend, frmLegend);
  Application.CreateForm(TfrmSaveSettings, frmSaveSettings);
  Application.Run;
end.

