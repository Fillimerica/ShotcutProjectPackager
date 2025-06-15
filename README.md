# ShotCut Project Packager Application


### Purpose
* Provides a simple way to view the list of files that are included within a ShotCut Project.

* Provides a visual confirmation regarding the availability of the files on the current system.

* Provides a mechanism to gather available included files into a single ZIP container (called a Package). This single container provides a convenient method for storing all of the project elements once the project is complete, as well as a simple way to transfer a project and its included files between systems.

### Main UI Overview
![image](https://github.com/user-attachments/assets/51d00da2-a214-4bb2-983d-c096082f85c6)
### Working with an Existing Project
Click on the Open button, navigate to any existing ShotCut Project file (.mlt extension), and select it.

The application opens and reads the contents of the project file, looking for references to files that are included within the project.
![image](https://github.com/user-attachments/assets/0f97943c-2ff2-40cf-8b8c-2ad8c6f4d90c)

* The Included Files Tree View on the left shows an explorer style view of where all of the included files are stored.
* The Included Files List on the right shows a sorted normalized list of all the files in the project.
    * The list is color coded. There is a full legend displayed by pressing the "Included Files List Legend" button below the list.
    * Files that exist on the system are shown in black, and are checked by default. This allows quick and easy project packaging of the available files.
    * Files that do not exist are shown in red, and are unchecked. (They can't be selected because they don't exist on the computer)
* Statistics and info are provided about the project as a whole, including file count and size.

### Creating A Package of the Included Files

Select the "Package Project Files" button with at least one included file checked.

The application will display a warning dialog if there are missing files.

The application will display a warning if not all of the included files are checked.

Both of these warnings are designed to prevent an incomplete project from being packaged (although there may be legitimate reasons why only a portion of the included files should be checked).


After any warnings are acknowledged, the application prompts for the name of the Package file to create. This name is arbitrary and does not need to match the project file name. The actual project file will be stored in the Package along with the included files.

Package files are standard zip files, but to differentiate files created and used by the packager application they have an extension of ".sczip".


Once the desired name is specified, the final Package options dialog will be displayed:
![image](https://github.com/user-attachments/assets/37d5e80f-abe3-4d59-972b-630c342294b5)

#### Note About Compression
While zip compression might make some files smaller, the vast majority of large media files do not compress well or at all. Therefore No compression is selected by default. This reduces the time it takes to build the package file substantially, with virtually no effect to the size of the resulting package file.

Select "Create Package" to build the package file.

#### Note about the Package "Zip" file

While the resulting package file can be opened with standard zip file readers such as 7-zip, the file naming structure uses absolute paths to permit restoration back to the exact original file locations that ShotCut expects. Therefore it is advised to only use the ShotCut Project Packager Application when extracting project files.

### Working with an Existing Project Package (.sczip)

Click on the Open button, navigate to any existing ShotCut Package file (.sczip extension), and select it.

The application opens and reads the contents of the package, extracts the 1st (and should be only) ShotCut project file (.mlt extension), and then parses the extracted project file, looking for references to files that are included within the project.

The resulting main screen is similar to what is displayed when working with a local project file.
* The ShotCut Project filename is shown in a light gray, with the (in Package) suffix to indicate that it has been opened from within the Package.
* The Package File that is active is shown next to the "Package File" field near the top of the main window.
![image](https://github.com/user-attachments/assets/f46faa90-d698-44fc-94ee-ac4d6db14560)

The Included Files List employs a variety of additional colors to indicate file status, and implements different selection logic.

* Files listed in BLACK exist only in the package file, not on the local system, and are checked for restoration by default.
* Files listed in $${\color{green}GREEN}$$ exist in the package file AND in the local file system and have the same size. They are considered identical and are unchecked by default. They can be checked if a restoration is desired. Be aware that currently date and time is NOT used to determine equivalency.
* Files listed in $${\color{gold}YELLOW}$$ highlight exist in the package file AND in the local file system but do NOT have the same size. These files are unchecked by default. They can be checked if a restoration is desired.
* Files listed in $${\color{red}RED}$$ do not exist in the package file, nor can they be found on the local system. These files are missing and cannot be checked for restoration.

### Unpacking Files from the Package

Select the "Unpackage Project Files" button with at least one included file checked.

Restore Project Files dialog will be displayed:
![image](https://github.com/user-attachments/assets/de222373-18b9-4fa8-bf5a-b9e96ff3e94a)

Pay special attention to the "Restore Project Files To:" option.
* Selecting "Original Locations" will extract the files from the package and restore them to the absolute location as shown in the Included Files List. This is the exact location from which the files were originally packaged, and are the locations that ShotCut expects in the project file. This is the default.
* Selecting "Specified Destination Folder" will attempt to extract the files into a single folder. You will be prompted to select a local folder (or create one) when choosing this option.

#### Considerations when Restoring to Original Locations
1. No attempt is made in advance to ensure that the location is available and is writable by the user. While all the sub-folders will be created if needed, the basic drive letter (Windows) or mount point (Linux) must exist otherwise an error will occur.
2. Existing files will be overwritten without warning or confirmation.

#### Considerations when Restoring to Specified Destination Folder
1. No attempt is made to resolve file name collisions. Currently files with identical names located in different folders will be overwriiten without warning or confirmation. No guarantee can be made regarding which colliding file will survive. If this is a concern, multiple restorations can be performed checking a non-conflicting subset of the included files each time and adjusting the restored file names manually after each restoration.
2. Existing files will be overwritten without warning or confirmation.

Select "Start Restore" to extract the checked files from the package file.
