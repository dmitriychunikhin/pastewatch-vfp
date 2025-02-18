SET ESCAPE OFF
SET MULTILOCKS ON
SET TALK OFF
SET NOTIFY CURSOR OFF
SET SAFETY OFF

SET SYSMENU TO DEFAULT
* DO sample.mpr && custom menu


SET PROCEDURE TO 

DO ..\Release\pastewatch.app WITH .T.

DO FORM sample

READ EVENTS

DO ..\Release\pastewatch.app WITH .F.

SET SYSMENU TO DEFAULT
