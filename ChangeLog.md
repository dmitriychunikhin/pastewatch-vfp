0.1
  - Added handling of copy/cut events

0.0.3
  - Fix: SET LIBRARY TO ...\pastewatch.fll was replaced to SET LIBRARY TO ...\pastewatch.fll <b>ADDITIVE</b>

0.0.2
  - Command KEYBOARD {Ctrl+V} in internal On_KEYLABEL_PASTE event was substituted by direct assignment of a control's SelText property. This prevents double firing of OnPaste event when _MEDIT submenu presents in system menu
  - Internal On_WM_USER_PASTE event returns 0 if control's OnPaste returns .T. and 1 when OnPaste returns .F. <br>
    This will prevent blocking of default paste behavior of VFP menu if user app will reset internal BINDEVENT(0, WM_USER + WM_PASTE, ...) of pastewatch.

0.0.1
  - Initial version
