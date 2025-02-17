# pastewatch

0.0.1<br>
Adds paste handling ability to any VFP 9 control by watching
* menu bar selection if it is defined as _med_paste
* Ctrl+V keyboard shortcut (via ON KEY LABEL)

To handle paste event a control must implement OnPaste method<br>


## Files
<b>pastewatch.app, pastewatch.fll:</b> take them from Release folder and put in a folder inside your app
<br>
<b>Dependencies:</b> msvcr71.dll (Default VFP 9 dependency dll)

## Usage
```
DO pastewatch.app WITH .T. &&Initialization
...
DO pastewatch.app WITH .F. &&Release
```
