unit FormRestoreProjectFiles;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType,
  ExtCtrls, Packager;

type

  { TfrmRestore }

  TfrmRestore = class(TForm)
    btnRestore: TButton;
    btnCancel: TButton;
    lblDestFolder: TLabel;
    lblSCPF1: TLabel;
    lblSCPF2: TLabel;
    lblSCProjectFile: TLabel;
    lblPackageFile: TLabel;
    pnlDest: TPanel;
    rbOrigLocation: TRadioButton;
    rbDestFolder: TRadioButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SelFiles: TLabel;
    SelFiles1: TLabel;
    SelFiles2: TLabel;
    SelFilesSize: TLabel;
    pnlCompText: TStaticText;
    procedure btnCancelClick(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure rbDestFolderChange(Sender: TObject);
  private

  public

  end;

var
  frmRestore: TfrmRestore;

implementation

{$R *.lfm}
uses
  Unit1;

{ TfrmRestore }

procedure TfrmRestore.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRestore.btnRestoreClick(Sender: TObject);

var
  lcnt:Integer;

begin
  // All prerequisites have been met.

  // Open Package File and Export all the project files.
  Packager.OpenZip(lblPackageFile.Caption,gSelFiles);

  // Loop through the included files list and extract all selected files.
  With Unit1.Form1.sgIFL Do begin
    for lcnt:=1 to (RowCount-1) do
      if Cells[cIFLCheckBox,lcnt]='1' then
      Packager.ExtractFile(Cells[cIFLFileName,lcnt],lblDestFolder.Caption,frmRestore.rbDestFolder.Checked);
  end;

  // Close Package File
  Packager.CloseZip;

  //Close the modal dialog
  Close;
end;

procedure TfrmRestore.rbDestFolderChange(Sender: TObject);
begin
  if Self.rbDestFolder.Checked then begin
   if Self.SelectDirectoryDialog1.Execute then begin
    Self.lblDestFolder.Caption:=Self.SelectDirectoryDialog1.FileName;
   end;
  end else Self.lblDestFolder.Caption:='';
end;

end.

