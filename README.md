# pastewatch

[![ChangleLog](https://img.shields.io/github/last-commit/dmitriychunikhin/pastewatch-vfp?path=%2FChangeLog.md&label=ChangeLog)](ChangeLog.md)

Adds copy-paste handling ability to any VFP 9 control by watching
* menu bar selection if it is defined as _med_paste/_med_copy/_med_cut (by VFP API menuHitEvent handling)
* Ctrl+V/Ctrl+C/Ctrl+X keyboard shortcuts (pastewatch implicitly defines ON KEY LABEL CTRL+V/CTRL+C/CTRL+X command during initialization)

To handle copy-paste events a control must implement OnPaste/OnCopy/OnCut methods<br>


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
* Copy-paste events implementation sample
DEFINE CLASS MyTextbox as Textbox
    PROCEDURE OnPaste
        IF MESSAGEBOX("Do you want to paste text in this textbox?", 4+32, "OnPaste") = 7
            * returning .F. prevents pasting text into control
            RETURN .F.
        ENDIF
    ENDPROC
    PROCEDURE OnCopy
        IF MESSAGEBOX("Do you want to copy text from this textbox?", 4+32, "OnCopy") = 7
            * returning .F. prevents copying text from control
            RETURN .F.
        ENDIF
    ENDPROC
    PROCEDURE OnCut
        IF MESSAGEBOX("Do you want to cut text from this textbox?", 4+32, "OnCut") = 7
            * returning .F. prevents cutting text from control
            RETURN .F.
        ENDIF
    ENDPROC
ENDDEFINE
```
