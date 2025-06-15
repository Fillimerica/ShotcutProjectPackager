unit Packager;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Zipper, ZStream;

type

  { TfrmProgress }

  TfrmProgress = class(TForm)
    lblcFile: TLabel;
    lblcFile1: TLabel;
    lblcFile2: TLabel;
    lblFileCount: TLabel;
    lblProgress: TLabel;
    ProgressBar1: TProgressBar;
    procedure ZipProgressPct(Sender:TObject; const Percent:Double);
    procedure ZipProgressFile(Sender:TObject; const tFile:String);  private

  public

  end;


// For Creating new Zip Files
procedure CreateZip(tFile:String);
procedure AddFiles(tFile:String; const pCompression:Integer);
Procedure SaveZip();

// For working with existing zip files
procedure OpenZip(tFile:String; const pFileCount:Integer);
Procedure ReadFileList(pStringList:TStringList);
procedure ExtractFile(tFile,dPath:String; pFlat:Boolean);
procedure CloseZip();

// Test Procedures
//procedure TestZip(tFile:String);
//procedure TestUnZip(tFile:String);

var
  frmProgress: TfrmProgress;
  FileNumber,FileCount:Integer;
  OurZipper:TZipper;
  OurUnZipper:TUnZipper;

implementation

{$R *.lfm}

procedure TFrmProgress.ZipProgressPct(Sender:TObject; const Percent:Double);
begin
     frmProgress.ProgressBar1.Position:=Round(Percent);
     Application.ProcessMessages;
end;
procedure TFrmProgress.ZipProgressFile(Sender:TObject; const tFile:String);
begin
     frmProgress.lblcFile.Caption:=tfile.Substring(tfile.LastDelimiter('/\')+1);
     FileNumber:=FileNumber+1;
     frmProgress.lblFileCount.Caption:=Format('%4d of %4d',[FileNumber,FileCount]);
     Application.ProcessMessages;
end;
procedure CloseZip();
begin
  OurUnZipper.Free;
  frmProgress.Close;
end;
procedure OpenZip(tFile:String; const pFileCount:Integer);

begin
  OurUnZipper := TUnZipper.Create;
  OurUnZipper.FileName:=tFile;
  // Reset file progress counter variables (used in the Progress Form)
  FileNumber:=0;
  FileCount:=pFileCount;
  // Wire up Progress Callbacks
  OurUnZipper.OnProgress:=@frmProgress.ZipProgressPct;
  OurUnZipper.OnStartFile:=@frmProgress.ZipProgressFile;
  frmProgress.Show;
end;
procedure CreateZip(tFile:String);
begin
  OurZipper := TZipper.Create;
  OurZipper.FileName:=tFile;
  // Reset file progress counter variables (used in the Progress Form)
  FileNumber:=0;
  FileCount:=0;
end;
Procedure ReadFileList(pStringList:TStringList);

var
  cnt,I:Integer;
  tfile2:String;
  tfileLen:Int64;

begin
// Assumes zip file already opened in OurUnZipper
  OurUnZipper.Examine;
  cnt:=OurUnZipper.Entries.Count; // get count of entries.
  for I:=0 to (cnt-1) do begin
    tfile2:=OurUnZipper.Entries.FullEntries[I].ArchiveFileName;
    tfileLen:=OurUnZipper.Entries.FullEntries[I].Size;
    pStringList.AddObject(tfile2,Tobject(tFileLen));
  end;

end;
procedure ExtractFile(tFile,dPath:String; pFlat:Boolean);
begin

// Assumes zip file already opened in OurUnZipper
  OurUnZipper.OutputPath:=dPath;
  OurUnZipper.Flat:=pFlat;
  OurUnZipper.UnZipFile(tFile);

end;

procedure AddFiles(tFile:String; const pCompression:Integer);

var
  lFileEntry:TZipFileEntry;
  lCompression:Tcompressionlevel;

begin
// Encode the compression ordinal 0-3 into a Tcompression structure
  Case pCompression of
       0:lCompression:=clnone;
       1:lCompression:=clfastest;
       2:lCompression:=cldefault;
       3:lCompression:=clmax;
  else
    lCompression:=clnone; // Set a rational fail-safe value.
  end;

  lFileEntry:=OurZipper.Entries.AddFileEntry(tFile,tFile);
  lFileEntry.CompressionLevel:=lCompression;
  FileCount:=FileCount+1; // Count the actual # of files being queued for the Progress Form
end;
Procedure SaveZip();
begin
  // Execute the zipping operation and write the zip file.
  // Wire up Progress Callbacks
  OurZipper.OnProgress:=@frmProgress.ZipProgressPct;
  OurZipper.OnStartFile:=@frmProgress.ZipProgressFile;
  frmProgress.Show;
  OurZipper.ZipAllFiles;
  OurZipper.Free;
  frmProgress.Close;
end;
// Test Procedures
{
procedure TestZip(tFile:String);
var
  OurZipper: TZipper;

begin
  OurZipper := TZipper.Create;
  try
    // Define the file name of the zip file to be created
    OurZipper.FileName := 'MyZipFileTest.zip';
       // Specify the names of the files to be included in the zip as first argument
      // The second argument is the name of the file as it appears in the zip and
      // later in the file system after unzipping
    OurZipper.Entries.AddFileEntry(tFile,tFile);
    // Execute the zipping operation and write the zip file.
    OurZipper.ZipAllFiles;
  finally
    OurZipper.Free;
  end;
end;
procedure TestUnZip(tFile:String);
var
  OurZipper: TUnZipper;
  cnt:Integer;
  tzfile:TZipFileEntry;
  tfile2:String;

begin
  OurZipper := TUnZipper.Create;
  try
    // Define the file name of the zip file to be created
    OurZipper.FileName := 'MyZipFileTest.zip';
    OurZipper.OutputPath:='c:\temp';
    OurZipper.Flat:=true;
    OurZipper.Examine;
       // Specify the names of the files to be included in the zip as first argument
      // The second argument is the name of the file as it appears in the zip and
      // later in the file system after unzipping
      cnt:=Ourzipper.Entries.Count;
      tzfile:=Ourzipper.Entries.Entries[0];
      tfile2:=Ourzipper.Entries.FullEntries[0].ArchiveFileName;

      OurZipper.UnZipFile(tFile2);
    // Execute the zipping operation and write the zip file.
    //OurZipper.UnZipAllFiles;
  finally
    OurZipper.Free;
  end;
end;
}
end.

