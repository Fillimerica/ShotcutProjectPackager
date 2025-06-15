unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, DOM, XMLRead, FileUtil, LCLType, Grids, StrUtils,
  Packager,  FormCreatePackageFile, FormColorLegend, FormRestoreProjectFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnTVHide: TButton;
    btnSelAllIncFiles: TButton;
    btnOpen: TButton;
    btnPackProjFiles: TButton;
    btnRestoreProjFiles: TButton;
    btnLegend: TButton;
    lblSCPF2: TLabel;
    lblPackageFile: TLabel;
    SaveDialog1: TSaveDialog;
    SelFiles: TLabel;
    SelFiles1: TLabel;
    SelFiles2: TLabel;
    SelFilesSize: TLabel;
    sgIFL: TStringGrid;
    TVIL: TImageList;
    lblSCPF1: TLabel;
    lblSCPF4: TLabel;
    lblifList: TLabel;
    lblSCPF6: TLabel;
    lblTotalFiles: TLabel;
    lblMissingFiles: TLabel;
    lblSCProjectFile: TLabel;
    lblifTV: TLabel;
    OpenDialog1: TOpenDialog;
    TV: TTreeView;
    procedure btnLegendClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnPackProjFilesClick(Sender: TObject);
    procedure btnRestoreProjFilesClick(Sender: TObject);
    procedure btnSelAllIncFilesClick(Sender: TObject);
    procedure btnTVClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgIFLCheckboxToggled(Sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure sgIFLPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private

  public

  end;


var
  Form1: TForm1;
  gTotalFiles,gMissingFiles:Integer;
  gSelFiles:Integer;
  gSelFilesSize:QWord;
  gPkgFileList:TStringList;
  gSelAllIncFiles:Char;  // state flag to indicate mode for the Select/Unselect All Control


const
  gcPVerStr:String='0.1.0 alpha';

  // Define helpful constants for the sTringGrid columns
  cIFLCheckBox:Integer=0;
  cIFLFileName:Integer=1;
  cIFLFileSize:Integer=2;
  cIFLLineColor:Integer=3;
  cIFLSizeBytes:Integer=4;




implementation

{$R *.lfm}



Procedure UpdateProjectUI();
begin
// Handles updating of UI status variables.
With Form1 do begin
  lblTotalFiles.Caption:=Format('%12.0n',[gTotalFiles+0.1-0.1]);
  lblMissingFiles.Caption:=Format('%12.0n',[gMissingFiles+0.1-0.1]);
  SelFiles.Caption:=Format('%12.0n',[gSelFiles+0.1-0.1]);
  SelFilesSize.Caption:=Format('%12.0n KB',[(gSelFilesSize/1024+0.1-0.1)]);
end; // with
end;

Procedure InitProject();
begin
// Handles reset of global UI variables as shown on the form.
With Form1 do begin
  btnPackProjFiles.Enabled:=false;
  btnRestoreProjFiles.Enabled:=false;
  btnSelAllIncFiles.Enabled:=false;
  lblSCProjectFile.Font.Color:=clBlack;
  lblSCProjectFile.Caption:='-- none --';
  lblPackageFile.Caption:='-- none --';
  gTotalFiles:=0;
  gMissingFiles:=0;
  gSelFiles:=0;
  gSelFilesSize:=0;
  gSelAllIncFiles:='1';
  UpdateProjectUI;
end; // with
end;

Procedure InsertFileInTree(FQFN:String);

var
   j1:Integer;
   aPFolders:TStringArray;
   aPFoldersIndex:Integer;
   Node,NodeC:TTreeNode;
   NodeMatch:Boolean;

begin
// Break up each path into an array of strings for each folder
aPFolders:=FQFN.Split('\/');
aPFoldersIndex:=Length(aPFolders)-1; // Index is 0 based

Node:=nil;
// Parse aPFolders Array and create Treeview Nodes if Needed
// Look for path starter at the root level of the treeview
for j1:=0 to (Form1.TV.Items.Count -1) do begin
    if Form1.TV.Items[j1].Level=0 then
       if Form1.TV.Items[j1].Text=apFolders[0] then begin
          Node:=Form1.TV.Items[j1];
          break;
       end;
end;
// At this point, if Node=nil a new root will need to be added, othewrwise
// Node points to the existing root.
if Node=nil then begin
  Node:=Form1.TV.Items.Add(nil,apFolders[0]);
  if aPFoldersIndex=0 then //root node is a file, not a folder
  Node.ImageIndex:=1 else Node.ImageIndex:=0;
end;

// Once root is set, add any needed children in the tree.
for j1:=1 to aPFoldersIndex do begin
  NodeMatch:=False;
  NodeC:=Node.GetFirstChild;
    while (Not NodeMatch) and (NodeC<>nil) do
        if NodeC.Text=apFolders[j1] then NodeMatch:=True
        else NodeC:=NodeC.GetNextSibling;

    if NodeMatch then
       Node:=NodeC
    else begin
        Node:=Form1.TV.Items.AddChild(Node,aPFolders[j1]);
        if j1=aPFoldersIndex then // node is a file, not a folder
           Node.ImageIndex:=1 else Node.ImageIndex:=0;
    end;

end;
end;
procedure AddFileToStringGrid(SrcFQFN:String);

var
   LIndex,lNewRow:Integer; // row index when searching.
   lFileSize:String;
   nFileSize:Integer;

begin
// Checked/selected is col 0
// String Value of file name is set as col 1
// File size in megabytes is column 2
// Font Color is column 3 (subitem) not displayed. Custom drawing routine uses this value
// to determine what to color each line.
// If file can be located, color is black.
// If file can not be found on the system, color is red.
// File size in bytes is col 4

// Only add if not already in the list.

lIndex:=Form1.sgIFL.Cols[cIFLFileName].IndexOf(SrcFQFN);

if lIndex=-1 then begin
  lNewRow:=Form1.sgIFL.RowCount;
  Form1.sgIFL.RowCount:=lNewRow+1;
  Form1.sgIFL.Cells[cIFLFileName,lNewRow]:=SrcFQFN;

    if FileExists(SrcFQFN) then begin
   Form1.sgIFL.Cells[cIFLCheckBox,lNewRow]:='1'; // checked
// Return file size in kilobytes in column 2
    nFileSize:=FileSize(SrcFQFN);
    lFileSize:=Format('%12.0n',[(nFileSize/1024)])+' KB';
    Form1.sgIFL.Cells[2,lNewRow]:=lFileSize;
    Form1.sgIFL.Cells[3,lNewRow]:='clBlack';
    Form1.sgIFL.Cells[4,lNewRow]:=InttoStr(nFileSize);
    // Update global counters in UI
    gTotalFiles:=gTotalFiles+1;
    gSelFiles:=gSelFiles+1;
    gSelFilesSize:=gSelFilesSize+nFileSize;
   end
  else begin
    Form1.sgIFL.Cells[cIFLCheckBox,lNewRow]:='0'; // unchecked
    Form1.sgIFL.Cells[2,lNewRow]:='';
    Form1.sgIFL.Cells[3,lNewRow]:='clRed';
    Form1.sgIFL.Cells[4,lNewRow]:='0';
    // Update global counters in UI
    gTotalFiles:=gTotalFiles+1;
    gMissingFiles:=gMissingFiles+1;
  end; // inside if
end; // outer if
end;
procedure AddFileToStringGridPackage(SrcFQFN:String);

var
   LIndex,lNewRow:Integer; // row index when searching.
   lFileSize:String;
   nFileSize,nFileSizeD:Int64;
   lPkgIndex:Integer;
   lOnDisk:Boolean;

begin
// Checked/selected is col 0
// String Value of file name is set as col 1
// File size in megabytes is column 2
// Font Color is column 3 (subitem) not displayed. Custom drawing routine uses this value
// to determine what to color each line.
// If file can be located, color is black.
// If file can not be found on the system, color is red.
// File size in bytes is col 4

// Only add if not already in the list.

lIndex:=Form1.sgIFL.cols[cIFLFileName].IndexOf(SrcFQFN);

if lIndex=-1 then begin
// Get index in archive if file is in the archive
  lPkgIndex:=gPkgFileList.IndexOf(srcFQFN);
// Flag if file is within the local file system
  lOnDisk:=FileExists(SrcFQFN);

// Add entry to StringGrid, color and selected based on presence rules.
   lNewRow:=Form1.sgIFL.RowCount;
   Form1.sgIFL.RowCount:=lNewRow+1;
   Form1.sgIFL.Cells[cIFLFileName,lNewRow]:=SrcFQFN;

  If (lPkgIndex>-1) and (not lOnDisk) then begin
  // in archive but not on local system (black text, line checked)
      Form1.sgIFL.Cells[cIFLCheckBox,lNewRow]:='1'; // checked
// Return file size in kilobytes in column 2
// get file size from archive.
      nFileSize:=Int64(gPkgFileList.Objects[lPkgIndex]);
      lFileSize:=Format('%12.0n',[(nFileSize/1024)])+' KB';
      Form1.sgIFL.Cells[2,lNewRow]:=lFileSize;
      Form1.sgIFL.Cells[3,lNewRow]:='clBlack';
      Form1.sgIFL.Cells[4,lNewRow]:=InttoStr(nFileSize);
      // Update global counters in UI
      gTotalFiles:=gTotalFiles+1;
      gSelFiles:=gSelFiles+1;
      gSelFilesSize:=gSelFilesSize+nFileSize;
  end else if (lPkgIndex>-1) and (lOnDisk) then begin
  // in archive AND on local system (yellow text, line un-checked)
        Form1.sgIFL.Cells[cIFLCheckBox,lNewRow]:='0'; // unchecked
// file exists both in archive and on disk, compare file sizes.
        nFileSizeD:=FileSize(SrcFQFN);
        nFileSize:=Int64(gPkgFileList.Objects[lPkgIndex]);
        if nFileSize=nFileSizeD then
            lFileSize:='(=) '+Format('%12.0n',[(nFileSize/1024)])+' KB'
            else
            lFileSize:='Archive='+Format('%12.0n',[(nFileSize/1024)])+' KB'+
            '(<>) Disk='+Format('%12.0n',[(nFileSizeD/1024)])+' KB';
        Form1.sgIFL.Cells[2,lNewRow]:=lFileSize;
// change the line color if the file sizes do not match
        if nFileSize=nFileSizeD then
          Form1.sgIFL.Cells[3,lNewRow]:='clGreen'
        else
        Form1.sgIFL.Cells[3,lNewRow]:='InverseYellow';
        Form1.sgIFL.Cells[4,lNewRow]:=InttoStr(nFileSize);
        // Update global counters in UI
        gTotalFiles:=gTotalFiles+1;
end else if (lPkgIndex=-1) and (lOnDisk) then begin
    // NOT in archive BUT on local system (black text, line un-checked)
      Form1.sgIFL.Cells[cIFLCheckBox,lNewRow]:='0'; // unchecked
      // get file size from local system
      nFileSize:=FileSize(SrcFQFN);
      lFileSize:=Format('%12.0n',[(nFileSize/1024)])+' KB';
      Form1.sgIFL.Cells[2,lNewRow]:=lFileSize;
      Form1.sgIFL.Cells[3,lNewRow]:='clGray';
      Form1.sgIFL.Cells[4,lNewRow]:=InttoStr(nFileSize);
      // Update global counters in UI
      gTotalFiles:=gTotalFiles+1;
end else if (lPkgIndex=-1) and (not lOnDisk) then begin
    // NOT in archive and NOT on local system (red text, line un-checked)
      Form1.sgIFL.Cells[cIFLCheckBox,lNewRow]:='0'; // unchecked
      Form1.sgIFL.Cells[2,lNewRow]:='';
      Form1.sgIFL.Cells[3,lNewRow]:='clRed';
      Form1.sgIFL.Cells[4,lNewRow]:='0';
      // Update global counters in UI
      gTotalFiles:=gTotalFiles+1;
      gMissingFiles:=gMissingFiles+1;
end;
end; // if llIndex=-1

end;
procedure NormalizePath(var FQFN:String);

var
  j:Integer;
const
  SPChar:Char='\';
  DPChar:Char='/';

begin

// Implement path normalization on the files read from the project file.
for j:=1 to Length(FQFN) do
  if FQFN[j]=SPChar then FQFN[j]:=DPChar;

end;

procedure LoadProjFile(SrcFQFN,mltFQFN:String;SrcType:Char);
// Modified to be usable for both project file on disk srcType='L'
// and project file extracted from package srcType='P'
// SrcFQFN is the project base path.
// mltFQFN is the actual mlt file to process (which may be a different path/name)

var
Doc: TXMLDocument;
Child: TDOMNode;
j: Integer;
SelFilePath:AnsiString;
FCFileName:String;
lPrevEntry:String;

const
// Shotcut file resources are specified using the NodeName, followed by an attribute
cNodeName:UnicodeString = 'property';
cName:UnicodeString ='name';
cResource:UnicodeString='resource';
// There are a few resources that end up not being file resources, so an additional
// filter is used to help validate.
cFirstCarSet:Set of Char=['A'..'Z', 'a'..'z'];

begin
try
  InitProject();
  // Need to reset a few StringGrid properties prior to clearing the list
  Form1.sgIFL.RowCount:=Form1.sgIFL.FixedRows;
  Form1.TV.Items.Clear;

  SelFilePath:=ExtractFilePath(mltFQFN);
  if SelFilePath[2]=':' then // if a standard drive letter, make sure drive is uppercase
    SelFilePath[1]:=UpperCase(SelFilePath[1])[1];
  ReadXMLFile(Doc, SrcFQFN);
  // using FirstChild and NextSibling properties
  Child := Doc.DocumentElement.FirstChild;
  while Assigned(Child) do
  begin
    // using ChildNodes method
    with Child.ChildNodes do
// For each Item in the node if all the filter conditions are met add the file name
// to the ListView if it is not already present.
    try
      for j := 0 to (Count - 1) do begin
       if Item[j].NodeName=cNodeName then
          if (Item[j].Attributes.Item[0].NodeName=cName) and (Item[j].Attributes.Item[0].NodeValue=cResource) then
             if Item[j].FirstChild.NodeValue[1] in cFirstCarSet then begin
                FCFileName:=String(Item[j].FirstChild.NodeValue);
// if file only, prepend project path otherwise ensure that drive letter is uppercase
                 if FCFileName[2]<>':' then FCFileName:=SelFilePath+FCFileName
                   else FCFileName[1]:=UpperCase(FCFileName[1])[1];
                 NormalizePath(FCFileName);
// Call the appropriate listview handler based on the file source.
                 Case SrcType of
                    'L':AddFiletoStringGrid(FCFileName);
                    'P':AddFiletoStringGridPackage(FCFileName);
                 else
                   Application.MessageBox(Pchar('Internal Error: Unknown SrcType='+srcType),
                   'LoadProjFile',MB_ICONERROR+MB_OK)
                 end;
             end;
     end;
    finally
      Free;
    end;
    Child := Child.NextSibling;
    end;
finally
  Doc.Free;
end;

// Check to see if any file name entries were loaded into the StringGrid. If so
// handle post loading tasks and also update the Treeview.
if Form1.sgIFL.RowCount>Form1.sgIFL.FixedRows then begin
   // After the StringGrid is fully loaded, set the minimum width of the File Name
   // and File Size Columns.
   // Perform an ititial sorting of the list as well.
   With Form1.sgIFL Do begin
    AutoSizeColumn(cIFLFileName);
    AutoSizeColumn(cIFLFileSize);
    Form1.sgIFL.SortColRow(true,cIFLFileName);

   // Populate the treeview.
    lPrevEntry:='';
    for j:=1 to (RowCount-1) do begin
      if Cells[cIFLFileName,j]<>lPrevEntry then
         begin
         lPrevEntry:=Cells[cIFLFileName,j];
         InsertFileInTree(lPrevEntry)
         end;
    end;
  end;
  // Finally handle any additional UI Updating.
  Case SrcType of
     'L':Begin
        Form1.lblSCProjectFile.Caption:=mltFQFN;
        Form1.btnPackProjFiles.Enabled:=true;
      End;
     'P':Begin
        Form1.lblSCProjectFile.Caption:=mltFQFN+' (in Package)';
        Form1.btnRestoreProjFiles.Enabled:=true;
      End;
  else
    Application.MessageBox(Pchar('Internal Error: Unknown SrcType='+srcType),
    'LoadProjFile',MB_ICONERROR+MB_OK)
  end;

  // Enable the global selection control once the Listview has files in it.
  Form1.btnSelAllIncFiles.Enabled:=true;
  UpdateProjectUI;

end;
end;
Procedure LoadPackageFile(SrcFQFN:String);
// This procedure extracts a temporary project mlt file
// and builds a global TStringList of the files contained within the package.
// Then it calls LoadProjFile to populate the UI.
var
   lMsg,lmltFQFN,lProjmltName,tStrRev:String;
   j1,lIndex,lDelimPos:Integer;

begin
// Open up the package file and extract the mlt inside into a temporary file for processing
gPkgFileList:=TStringList.Create;

Packager.OpenZip(SrcFQFN,1);
Packager.ReadFileList(gPkgFileList);

// Parse the list looking for the .mlt file (tlm. in reverse).
lIndex:=-1; //default to string not found.
for j1:=0 to (gPkgFileList.Count-1) do begin
    tStrRev:=ReverseString(gPkgFileList.Strings[j1]);
    if Pos('tlm.',tStrRev)>0 then begin
      lIndex:=j1;
      break;
    end;
end;
if (lIndex>-1) then begin
// Project File located within the Package, Extract it and then call LoadProjFile
  lmltFQFN:=GetTempDir(false);
  Packager.ExtractFile(gPkgFileList.Strings[lIndex],lmltFQFN,true);
  lDelimPos:=gPkgFileList.Strings[lIndex].LastDelimiter('/');
  lmltFQFN:=lmltFQFN+gPkgFileList.Strings[lIndex].Substring(lDelimPos+1);
  lProjmltName:=gPkgFileList.Strings[lIndex];
  LoadProjFile(lmltFQFN,lProjmltName,'P');

  // For Package, add the project mlt file to the list of files.
  AddFiletoStringGridPackage(lProjmltName);
  Form1.sgIFL.SortColRow(true,1); // re-sort the file list to integrade the mlt file.
  Form1.lblPackageFile.Caption:=SrcFQFN;
  Form1.lblSCProjectFile.Font.Color:=clGray;
// Decided to decriment "total file count in project" by one to exclude mlt file.
// since the mlt file isn't technically in the project even though it is in the Package.
  gTotalFiles:=gTotalFiles-1;

  // Processing of project file is completed, delete the temp project file.
  DeleteFile(lmltFQFN);
  UpdateProjectUI;

end else begin
  lMsg:='Unable to locate the ShotCut Project (.mlt) file in the Package'+CHR(13)+CHR(13)+
       'Package file will not be opened.';
  Application.MessageBox(PChar(lMsg),'LoadPackageFile Error',MB_ICONERROR+MB_OK);
end;

Packager.CloseZip();
if Assigned(gPkgFileList) then FreeAndNil(gPkgFileList);

end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
 Caption:='ShotCut Project Packager '+ gcPVerStr;
 InitProject();
end;
procedure TForm1.sgIFLCheckboxToggled(Sender: TObject; aCol, aRow: Integer;
  aState: TCheckboxState);

var
   lMsg:String;
   TSG:TStringGrid Absolute Sender;

begin
// Trap and discard checking on invalid list items.
if aState=cbChecked then begin
  if TSG.Cells[cIFLLineColor,aRow]='clRed' then begin
    lMsg:='Cannot select a missing file for any action.'+CHR(13)+
    'Item will remain unchecked.';
    Application.MessageBox(PChar(lMsg),'Included Files Operation',MB_ICONEXCLAMATION+MB_OK);
    TSG.Cells[cIFLCheckBox,aRow]:='0';
    Exit;
  end;
  if TSG.Cells[cIFLLineColor,aRow]='clGray' then begin
    lMsg:='Cannot select a file not in the package for restoration.'+CHR(13)+
    'Item will remain unchecked.';
    Application.MessageBox(PChar(lMsg),'Included Files Operation',MB_ICONEXCLAMATION+MB_OK);
    TSG.Cells[cIFLCheckBox,aRow]:='0';
    Exit;
  end;
end;

// Trap section complete. If execution gets here, checked state change is allowed.

// When the checked status is changed by the user, recalculate the selected totals
if aState=cbChecked then begin
  gSelFiles:=gSelFiles+1;
  gSelFilesSize:=gSelFilesSize+StrToInt(TSG.Cells[cIFLSizeBytes,aRow]);
  end else begin
   gSelFiles:=gSelFiles-1;
   gSelFilesSize:=gSelFilesSize-StrToInt(TSG.Cells[cIFLSizeBytes,aRow]);
  end;
UpdateProjectUI;

end;

procedure TForm1.sgIFLPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
// This event procedure is called from the StringGrid during row painting.
// custom row coloration is set in this event handler.

var
   TSG:TStringGrid Absolute Sender;

begin
// Only process data rows that are not the header row.
if aRow>0 then
  // Handle the special case where both the brush and font color is changed.
  if TSG.Cells[cIFLLineColor,aRow]='InverseYellow' then
    begin
     TSG.canvas.Font.color:=clBlack;
     TSG.canvas.Brush.color:=clYellow;
    end else begin
     TSG.Canvas.Font.Color := StringToColor(TSG.Cells[cIFLLineColor,aRow]);
     TSG.Canvas.Brush.Color := clWhite;

    end;
end;
procedure TForm1.btnOpenClick(Sender: TObject);
// Call the OpenDialog to get the .mlt or .sczip project/package filename
// and call the appropriate handler based on the file extension returned.

var
   lFileExt:String;
   lFileDelimPos:Integer;
   lMsg:String;

begin
  try
    if Form1.OpenDialog1.Execute then begin
      lFileDelimPos:=Form1.OpenDialog1.FileName.LastDelimiter('.');
      if lFileDelimPos>0 then
        lFileExt:=UpperCase(Form1.OpenDialog1.FileName.Substring(lFileDelimPos))
      else lFileExt:='';
      if lFileExt='.MLT' then
// Load the local project file directly, files are already present.
        LoadProjFile(Form1.OpenDialog1.FileName,Form1.OpenDialog1.FileName,'L')
      else if lFileExt='.SCZIP' then
// Call the package file handler to extract the project file, which calls
// LoadProjFile from within.
        LoadPackageFile(Form1.OpenDialog1.FileName)
      else begin
        lMsg:='Selected File: '+Form1.OpenDialog1.FileName+CHR(13)+
        'Is Not A Project or Package'+Chr(13)+'Nothing opened.';
        Application.MessageBox(PChar(lMsg),'Open',MB_ICONEXCLAMATION);
      end;
    end;
  except
  end;
  end;

procedure TForm1.btnLegendClick(Sender: TObject);
begin
     FormColorLegend.frmLegend.ShowModal;
end;

procedure TForm1.btnPackProjFilesClick(Sender: TObject);
// Handle packing the project file into a custom zip file.
// Package files are stored with absolute paths, but may be restored into a flat directory

// Validations: 1. If Any project files are missing, display a warning dialog to proceed.
// 2. If user selects an existing package file, confirm overwrite.
// 3. If user cancels file selection, advise and cancel operation.
// Display a final confirmation form/dialog with the selected package file name,
// the total # of files to be packaged, the approximate size. And wait for a final Confirmation.

var
   lMsg:String;
   lResult:Integer;

begin
// If no included files are checked, advise user and cancel Package Creation.
if gSelFiles=0 then begin
  lMsg:='No files from the Included Files List are Checked.'+CHR(13)+CHR(13)+
   'There must be at least 1 file checked to create the Package.'+CHR(13)+CHR(13)+
   'Package Operation Canceled.';
  lResult:=Application.MessageBox(PChar(lMsg),'Selected Files Confirmation',MB_ICONEXCLAMATION+MB_OK);
  exit;
end;

// If Any project files are missing, display a warning dialog to proceed.
if gMissingFiles>0 then begin
  lMsg:='Some files referenced in the project are missing or inaccesible from this computer.'+CHR(13)+CHR(13)+
   'Continue with packaging excluding these missing files?';
  lResult:=Application.MessageBox(PChar(lMsg),'Missing Files Confirmation',MB_ICONEXCLAMATION+MB_YESNO);
  if lResult= IDNO then exit;
end;

// Warn User if the selected file count is less than the total files in the project.
if gSelFiles<>gTotalFiles then begin
  lMsg:='Some files referenced in the project are not selected for inclusion.'+CHR(13)+CHR(13)+
   'Continue with packaging excluding these unchecked files?';
  lResult:=Application.MessageBox(PChar(lMsg),'Unselected Files Confirmation',MB_ICONEXCLAMATION+MB_YESNO);
  if lResult= IDNO then exit;
end;

// Call SaveDialog, if user specifies a valid file name, invoke the conformation form.
if Form1.SaveDialog1.Execute then with FormCreatePackageFile.frmPackage do begin
   lblSCProjectFile.Caption:=Form1.lblSCProjectFile.Caption;
   lblPackageFile.Caption:=Form1.SaveDialog1.FileName;
   SelFiles.Caption:=Form1.SelFiles.Caption;
   SelFilesSize.Caption:=Form1.SelFilesSize.Caption;
   Show
 end else begin
   lMsg:='Package Name Not Specified.'+CHR(13)+CHR(13)+'Package Ooperation Cancelled.';
   Application.MessageBox(PChar(lMsg),'Package Creation',MB_ICONINFORMATION+MB_OK);
end;

end;

procedure TForm1.btnRestoreProjFilesClick(Sender: TObject);

// Handle restoring project files from a previously createrd package.
// Package files are stored with absolute paths, but may be restored into a flat directory

// Display a final confirmation form/dialog with the selected package file name,
// the total # of files to be packaged, the approximate size. And wait for a final Confirmation.

var
   lMsg:String;

begin
// If no included files are checked, advise user and cancel Package Creation.
if gSelFiles=0 then begin
  lMsg:='No files from the Included Files List are Checked.'+CHR(13)+CHR(13)+
   'There must be at least 1 file checked to unpackage.'+CHR(13)+CHR(13)+
   'Package Operation Canceled.';
  Application.MessageBox(PChar(lMsg),'Selected Files Confirmation',MB_ICONEXCLAMATION+MB_OK);
  exit;
end;

// invoke the conformation form.
with FormRestoreProjectFiles.frmRestore do begin
   lblSCProjectFile.Caption:=Form1.lblSCProjectFile.Caption;
   lblPackageFile.Caption:=Form1.lblPackageFile.Caption;
   SelFiles.Caption:=Form1.SelFiles.Caption;
   SelFilesSize.Caption:=Form1.SelFilesSize.Caption;
   rbOrigLocation.Checked:=true; // default to original location
   lblDestFolder.Caption:=''; // default to original target location.
   Show
end;

end;

procedure TForm1.btnSelAllIncFilesClick(Sender: TObject);

var
   cnt:Integer;
   AllowChange:Boolean;

begin
// Walk the StringGrid (Included Files List) and either select or unselect
// all of the permitted (if on disk or if in Package) files.
   for cnt:=1 to (sgIFL.RowCount-1) do begin
    AllowChange:=NOT ((sgIFL.Cells[cIFLLineColor,cnt]='clRed') OR
      (sgIFL.Cells[cIFLLineColor,cnt]='clGray'));
    if AllowChange then
      if sgIFL.Cells[cIFLCheckBox,cnt]<>gSelAllIncFiles then begin
        // Need to determine transition and update the UI counters.
        if gSelAllIncFiles='1' then begin
           gSelFiles:=gSelFiles+1;
           gSelFilesSize:=gSelFilesSize+StrToInt(sgIFL.Cells[cIFLSizeBytes,cnt]);
        end else begin
           gSelFiles:=gSelFiles-1;
           gSelFilesSize:=gSelFilesSize-StrToInt(sgIFL.Cells[cIFLSizeBytes,cnt]);
        end;
        sgIFL.Cells[cIFLCheckBox,cnt]:=gSelAllIncFiles;
      end;
   end;

   UpdateProjectUI; // in case items changed state, show updated values.

// Finally toggle the global state tracking variable.
   if gSelAllIncFiles='0' then gSelAllIncFiles:='1' else gSelAllIncFiles:='0';
end;

procedure TForm1.btnTVClick(Sender: TObject);

const
     cFullLeft:Integer=16;
     csgIFLLeft:Integer=402;

begin
  If btnTVHide.Caption='Hide Tree View' then begin
   lblifTV.Hide;
   lblifList.Left:=cFullLeft;
   sgIFL.Left:=cFullLeft;
   sgIFL.Width:=sgIFL.Width+(csgIFLLeft-cFullLeft);
   btnTVHide.Caption:='Show Tree View';
  end else begin
   lblifTV.Show;
   lblifList.Left:=csgIFLLeft;
   sgIFL.Left:=csgIFLLeft;
   sgIFL.Width:=sgIFL.Width-(csgIFLLeft-cFullLeft);
   btnTVHide.Caption:='Hide Tree View';
  end;
end;


end.

