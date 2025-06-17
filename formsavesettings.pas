unit formSaveSettings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  INIFiles;

type

  { TfrmSaveSettings }

  TfrmSaveSettings = class(TForm)
    btnCancel: TButton;
    btnSave: TButton;
    cbMainForm: TCheckBox;
    lblSCPF1: TLabel;
    lblSettingsFile: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

procedure AppSettingsRead();

var
  frmSaveSettings: TfrmSaveSettings;

implementation

{$R *.lfm}
uses
  Unit1;

{ TfrmSaveSettings }
procedure AppSettingsSave();

var
  JustPath:String;

// This procedure handles writing the selected options into the Application Config File

var
  INIFile:TINIFile;

begin
// Check to see if a new application file needs to be created and initialize all folders
// in the path.
JustPath:=gAppConfigFile.Substring(1,gAppConfigFile.LastDelimiter('/\'));
if not FileExists(gAppConfigFile) then ForceDirectories(JustPath);

// Open or create application config file and save selected settings.
   INIFile:=TINIFile.Create(gAppConfigFile);
   try
     If frmSaveSettings.cbMainForm.checked then
     begin
// Section 1: Main Form Size and Position on the Desktop.
       INIFile.WriteInteger('Main','FormTop',Form1.Top);
       INIFile.WriteInteger('Main','FormLeft',Form1.Left);
       INIFile.WriteInteger('Main','FormHeight',Form1.Height);
       INIFile.WriteInteger('Main','FormWidth',Form1.Width);
     end;
   finally
     INIFile.Free; //Relewase file system object after use.
   end;
end;
procedure AppSettingsRead();

var
  INIFile:TINIFile;
  FormTop,FormLeft,FormHeight,FormWidth:Integer;

begin
// Try to open the config file and read the settings for the application.
If FileExists(gAppConfigFile) then
  begin
   // Note: Config file must already exist in order for values to be read.
   // Creation or updating of the file is handled in the FormSaveSettings unit.
   INIFile:=TINIFile.Create(gAppConfigFile);
   try
// Section 1: Main Form Size and Position on the Desktop.
     FormTop:=IniFile.ReadInteger('Main','FormTop',-1);
     FormLeft:=IniFile.ReadInteger('Main','FormLeft',-1);
     FormHeight:=IniFile.ReadInteger('Main','FormHeight',-1);
     FormWidth:=IniFile.ReadInteger('Main','FormWidth',-1);
     // Validate that the read settings are rational.
     if (FormTop>-1) and (FormLeft>-1) and (FormHeight>-1) and (FormWidth>-1) then
       begin
        // Values have been read, apply to the main form if they are rational
        // for the current desktop.
        // Make Sure upper left corner starts on-screen.
        if FormTop<Screen.DesktopHeight then Form1.Top:=FormTop;
        if FormLeft<Screen.DesktopWidth then Form1.Left:=FormLeft;
        // Sizing can exceed desktop boundary but must conform to minimums.
        if FormWidth>Form1.Constraints.MinWidth  then Form1.Width:=FormWidth;
        if FormHeight>Form1.Constraints.MinHeight  then Form1.Height:=FormHeight;
       end;
   finally
     INIFile.Free; //Relewase file system object after use.
   end;
  end;

end;
procedure TfrmSaveSettings.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSaveSettings.btnSaveClick(Sender: TObject);
begin
  // Save the selected application options to the application config INI file.
  AppSettingsSave;
    //Close the modal dialog
  Close;

end;

procedure TfrmSaveSettings.FormCreate(Sender: TObject);
begin
  lblSettingsFile.Caption:=gAppConfigFile;
end;

end.

