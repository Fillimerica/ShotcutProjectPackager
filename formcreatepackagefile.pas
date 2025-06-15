unit FormCreatePackageFile;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType,
  ExtCtrls, Packager;

type

  { TfrmPackage }

  TfrmPackage = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    lblSCPF1: TLabel;
    lblSCPF2: TLabel;
    lblSCProjectFile: TLabel;
    lblPackageFile: TLabel;
    pnlComp: TPanel;
    rbCompNone: TRadioButton;
    rbCompFast: TRadioButton;
    rbCompDeflate: TRadioButton;
    rbCompMax: TRadioButton;
    SelFiles: TLabel;
    SelFiles1: TLabel;
    SelFiles2: TLabel;
    SelFilesSize: TLabel;
    pnlCompText: TStaticText;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private

  public

  end;

var
  frmPackage: TfrmPackage;

implementation

{$R *.lfm}
uses
  Unit1;

{ TfrmPackage }

procedure TfrmPackage.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPackage.btnSaveClick(Sender: TObject);

var
  lcnt,lCompression:Integer;
  lMsg:String;

begin
  // All prerequisites have been met.
  // Determine the desired file compression level from the option buttons.
  lCompression:=0; // code failsafe in case the UI is altered
  if rbCompNone.Checked then lCompression:=0;
  if rbCompFast.Checked then lCompression:=1;
  if rbCompDeflate.Checked then lCompression:=2;
  if rbCompMax.Checked then lCompression:=3;

  // Create Package File and Export all the project files.
  Packager.CreateZip(lblPackageFile.Caption);
  Packager.AddFiles(lblSCProjectFile.Caption,lCompression);  // add Project file 1st.

  // Loop through the included files list and add all selected files.
  With Unit1.Form1.sgIFL Do begin
    for lcnt:=1 to (RowCount-1) do
      if Cells[cIFLCheckBox,lcnt]='1' then
         Packager.AddFiles(Cells[cIFLFileName,lcnt],lCompression);
  end;
 Hide;
  // Save Zip File
  Packager.SaveZip;

  // Advise user that the operation completed.
  if FileExists(lblPackageFile.Caption) then begin
     lMsg:='Packaging Operation Completed.'+CHR(13)+CHR(13)+
     'Package File: '+lblPackageFile.Caption+CHR(13)+CHR(13)+
     'Has been sucessfully created.';
     Application.MessageBox(PChar(lMsg),'Package Creation',MB_ICONINFORMATION+MB_OK)
  end else begin
    lMsg:='Packaging Operation Completed WITH ERROR.'+CHR(13)+CHR(13)+
    'Package File: '+lblPackageFile.Caption+CHR(13)+CHR(13)+
    'Has NOT been Created.';
    Application.MessageBox(PChar(lMsg),'Package Creation',MB_ICONERROR+MB_OK)
  end;


  //Close the modal dialog
  Close;
end;

end.

