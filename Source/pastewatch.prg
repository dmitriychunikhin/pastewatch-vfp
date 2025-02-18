LPARAMETERS llInit

DO CASE
CASE PCOUNT() > 0 AND m.llInit = .T.
    =CREATEOBJECT("PasteWatch")
CASE PCOUNT() > 0 AND m.llInit = .F.
    _VFP.PasteWatch.Release()
ENDCASE

DEFINE CLASS PasteWatch as Session
    #define WM_USER  0x0400
    #define WM_PASTE 0x0302
    #define WM_USER_PASTE WM_USER + WM_PASTE

    PROCEDURE Init
        IF PEMSTATUS(_VFP, This.Class, 5) = .T.
            ERROR "Object _VFP." + This.Class + " already exists"
            RETURN .F.
        ENDIF
        
        LOCAL lcAppPath, lcAppFolder
        m.lcAppPath = STREXTRACT(SYS(16), " ", "", 2, 2)
        m.lcAppFolder = JUSTPATH(m.lcAppPath)
        
        SET LIBRARY TO &lcAppFolder\pastewatch.fll
        BINDEVENT(0, WM_USER_PASTE, This, "On_WM_USER_PASTE")
        ADDPROPERTY(_VFP, This.Class, This)
        
        LOCAL lcCmdPaste
        m.lcCmdPaste = "_VFP." + This.Class + ".On_KEYLABEL_PASTE()"
        ON KEY LABEL CTRL+V &lcCmdPaste
    ENDPROC

    PROCEDURE Release
        IF PEMSTATUS(_VFP, This.Class, 5) = .F.
            RETURN
        ENDIF

        LOCAL lcAppPath, lcAppFolder
        m.lcAppPath = STREXTRACT(SYS(16), " ", "", 2, 2)
        m.lcAppFolder = JUSTPATH(m.lcAppPath)

        ON KEY LABEL CTRL+V
        UNBINDEVENTS(0, WM_USER_PASTE)
        RELEASE LIBRARY &lcAppFolder\pastewatch.fll
        REMOVEPROPERTY(_VFP, This.Class)
    ENDPROC

    PROCEDURE Destroy
        This.Release()
    ENDPROC
    
    PROCEDURE On_WM_USER_PASTE
        LPARAMETERS hWnd, nMsg, wParam, lParam
        
        RETURN IIF(This.OnPaste(), 0, 1)
    ENDPROC

    PROCEDURE On_KEYLABEL_PASTE
        This.OnPaste(.T.)
    ENDPROC

    HIDDEN PROCEDURE OnPaste
        LPARAMETERS llOnKeyLabel
        
        IF TYPE("_VFP.ActiveForm.ActiveControl") != "O"
            RETURN
        ENDIF
        
        LOCAL loControl
        m.loControl = _VFP.ActiveForm.ActiveControl
        
        IF m.loControl.BaseClass == "Grid"
            IF NOT BETWEEN(m.loControl.ActiveColumn, 1, m.loControl.ColumnCount)
                RETURN
            ENDIF
            LOCAL lcGridControl
            m.lcGridControl = ""
            IF EMPTY(m.loControl.Columns[m.loControl.ActiveColumn].DynamicCurrentControl) = .F.
                TRY
                    m.lcGridControl = EVALUATE(m.loControl.Columns[m.loControl.ActiveColumn].DynamicCurrentControl)
                CATCH
                    m.lcGridControl = ""
                ENDTRY
            ENDIF
            IF EMPTY(m.lcGridControl)
                m.lcGridControl = m.loControl.Columns[m.loControl.ActiveColumn].CurrentControl
            ENDIF
            
            TRY
                m.loControl = m.loControl.Columns[m.loControl.ActiveColumn].&lcGridControl
            CATCH
                m.loControl = .F.
            ENDTRY
            IF VARTYPE(m.loControl) <> "O"
                RETURN
            ENDIF
        ENDIF
        
        IF PEMSTATUS(m.loControl, "OnPaste", 5) = .T.
            IF m.loControl.OnPaste() = .F.
                RETURN .F.
            ENDIF
        ENDIF
        
        IF m.llOnKeyLabel AND PEMSTATUS(m.loControl, "SelText",6) AND NOT EMPTY(_CLIPTEXT)
            m.loControl.SelText = _CLIPTEXT
        ENDIF
    ENDPROC
    
ENDDEFINE
