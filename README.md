# pastewatch

[![ChangleLog](https://img.shields.io/github/last-commit/dmitriychunikhin/pastewatch-vfp?path=%2FChangeLog.md&label=ChangeLog)](ChangeLog.md)

Adds paste handling ability to any VFP 9 control by watching
* menu bar selection if it is defined as _med_paste (by VFP API menuHitEvent handling)
* Ctrl+V keyboard shortcut (via ON KEY LABEL)

To handle paste event a control must implement OnPaste method<br>


## Files
<b>pastewatch.app, pastewatch.fll:</b> take them from Release folder and put in a folder inside your app
<br>
<b>Dependencies:</b> msvcr71.dll (Default VFP 9 dependency dll)

## Usage
```
* Initialization (put this in startup code of your app)
DO pastewatch.app WITH .T. 
...
* Release (put this in cleanup code of your app)
DO pastewatch.app WITH .F.
```

```
* OnPaste event implementation sample
DEFINE CLASS MyTextbox as Textbox
    PROCEDURE OnPaste
        IF MESSAGEBOX("Do you want to paste text in this textbox?", 4+32, "OnPaste") = 7
            * returning .F. prevents pasting text into control
            RETURN .F.
        ENDIF
    ENDPROC
ENDDEFINE
```
