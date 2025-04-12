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
    #define WM_COPY  0x0301
    #define WM_CUT   0x0300
    #define WM_USER_PASTE WM_USER + WM_PASTE
    #define WM_USER_COPY WM_USER + WM_COPY
    #define WM_USER_CUT WM_USER + WM_CUT

    PROCEDURE Init
        IF PEMSTATUS(_VFP, This.Class, 5) = .T.
            ERROR "Object _VFP." + This.Class + " already exists"
            RETURN .F.
        ENDIF
        
        LOCAL lcAppPath, lcAppFolder
        m.lcAppPath = STREXTRACT(SYS(16), " ", "", 2, 2)
        m.lcAppFolder = JUSTPATH(m.lcAppPath)
        
        SET LIBRARY TO &lcAppFolder\pastewatch.fll ADDITIVE
        BINDEVENT(0, WM_USER_PASTE, This, "On_WM_USER_PASTE")
        BINDEVENT(0, WM_USER_COPY, This, "On_WM_USER_COPY")
        BINDEVENT(0, WM_USER_CUT, This, "On_WM_USER_CUT")
        ADDPROPERTY(_VFP, This.Class, This)
        
        LOCAL lcCmdPaste
        m.lcCmdPaste = "_VFP." + This.Class + ".On_KEYLABEL_PASTE()"
        ON KEY LABEL CTRL+V &lcCmdPaste

        LOCAL lcCmdCopy
        m.lcCmdCopy = "_VFP." + This.Class + ".On_KEYLABEL_COPY()"
        ON KEY LABEL CTRL+C &lcCmdCopy

        LOCAL lcCmdCut
        m.lcCmdCut = "_VFP." + This.Class + ".On_KEYLABEL_CUT()"
        ON KEY LABEL CTRL+X &lcCmdCut
    ENDPROC

    PROCEDURE Release
        IF PEMSTATUS(_VFP, This.Class, 5) = .F.
            RETURN
        ENDIF

        LOCAL lcAppPath, lcAppFolder
        m.lcAppPath = STREXTRACT(SYS(16), " ", "", 2, 2)
        m.lcAppFolder = JUSTPATH(m.lcAppPath)

        ON KEY LABEL CTRL+V
        ON KEY LABEL CTRL+C
        ON KEY LABEL CTRL+X
        UNBINDEVENTS(0, WM_USER_PASTE)
        UNBINDEVENTS(0, WM_USER_COPY)
        UNBINDEVENTS(0, WM_USER_CUT)
        RELEASE LIBRARY &lcAppFolder\pastewatch.fll
        REMOVEPROPERTY(_VFP, This.Class)
    ENDPROC

    PROCEDURE Destroy
        This.Release()
    ENDPROC
    
    PROCEDURE On_WM_USER_PASTE
        LPARAMETERS hWnd, nMsg, wParam, lParam
        
        RETURN IIF(This.OnCopyPaste(WM_USER_PASTE), 0, 1)
    ENDPROC

    PROCEDURE On_KEYLABEL_PASTE
        This.OnCopyPaste(WM_USER_PASTE, .T.)
    ENDPROC

    PROCEDURE On_WM_USER_COPY
        LPARAMETERS hWnd, nMsg, wParam, lParam
        
        RETURN IIF(This.OnCopyPaste(WM_USER_COPY), 0, 1)
    ENDPROC

    PROCEDURE On_KEYLABEL_COPY
        This.OnCopyPaste(WM_USER_COPY, .T.)
    ENDPROC

    PROCEDURE On_WM_USER_CUT
        LPARAMETERS hWnd, nMsg, wParam, lParam
        
        RETURN IIF(This.OnCopyPaste(WM_USER_CUT), 0, 1)
    ENDPROC

    PROCEDURE On_KEYLABEL_CUT
        This.OnCopyPaste(WM_USER_CUT, .T.)
    ENDPROC

    HIDDEN PROCEDURE OnCopyPaste
        LPARAMETERS lnMsg, llOnKeyLabel
        
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
        
        DO CASE
        CASE m.lnMsg = WM_USER_PASTE
            IF PEMSTATUS(m.loControl, "OnPaste", 5) = .T.
                IF m.loControl.OnPaste() = .F.
                    RETURN .F.
                ENDIF
            ENDIF
            
            IF m.llOnKeyLabel AND PEMSTATUS(m.loControl, "SelText",6) AND NOT EMPTY(_CLIPTEXT)
                m.loControl.SelText = _CLIPTEXT
            ENDIF

        CASE m.lnMsg = WM_USER_COPY
            IF PEMSTATUS(m.loControl, "OnCopy", 5) = .T.
                IF m.loControl.OnCopy() = .F.
                    RETURN .F.
                ENDIF
            ENDIF
            
            IF m.llOnKeyLabel AND PEMSTATUS(m.loControl, "SelText",6) 
                _CLIPTEXT = m.loControl.SelText
            ENDIF
            
        CASE m.lnMsg = WM_USER_CUT
            IF PEMSTATUS(m.loControl, "OnCut", 5) = .T.
                IF m.loControl.OnCut() = .F.
                    RETURN .F.
                ENDIF
            ENDIF
            
            IF m.llOnKeyLabel AND PEMSTATUS(m.loControl, "SelText",6) 
                _CLIPTEXT = m.loControl.SelText
                m.loControl.SelText = ""
            ENDIF
        ENDCASE
    ENDPROC
    
ENDDEFINE
