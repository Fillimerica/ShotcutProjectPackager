## V0.4.0alpha

- Corrected for file objects that are stored as full UNC paths.
- Corrected for file objects that do not start with a letter.
- Added a new Message if a Project File does not appear to have any file object references.
- Fixed display of file objects with sizes greater than 2Gig in the Included Files List

*Note: The logic used to detect a file object inside the Shotcut project file has changed. Now all media files must contain an extension, but can start with any valid file naming character (including numbers and symbols).*

## V0.3.0alpha

- Implement new pull down menu system for the application.
- Implemented new application configuration INI-style file, save & load in user folder.
- Implemented saving of main window position on the desktop and size preferences.

## V0.2.1alpha

- Adjusted the main UI form minimum constraints so that the resizable form must be at least 740x280 pixels. The main form cannot be resized to be smaller than this size. The minimum size may be changed in the future to accomidate new funcionality on the form.

- Fixed a few control positioning issues with the main form. 1. Hide Tree View control stays put. 2. Tree View expands vertically if the window is resized. 3. The Included files list expands both vertically and horizontally as the window is resized. 4. Total & Missing files counters move horizontally as the window expands.
  
  ## V0.2.0alpha

- Version # change indicate that the new Hide/Show Treeview function has been implemented in Unit1.pas.
  
  ## V0.1.0alpha

- Update README.md

- initial commit of full repository
