#include <pro_ext.h>

static int EventHandlerID = 0;

long FAR EventHandler(WHandle theWindow, EventRec FAR* ev)
{
	if (ev->what == menuHitEvent) {
		if (ev->misc2 == _MenuId(_EDITPASTE)) {
			LRESULT res = SendMessage(
				_WhToHwnd(_WMainClientWindow()),
				WM_USER + WM_PASTE,
				0,
				0);
			return res == 0 ? NO : YES;
		}
		else if (ev->misc2 == _MenuId(_EDITCOPY)) {
			LRESULT res = SendMessage(
				_WhToHwnd(_WMainClientWindow()),
				WM_USER + WM_COPY,
				0,
				0);
			return res == 0 ? NO : YES;
		}
		else if (ev->misc2 == _MenuId(_EDITCUT)) {
			LRESULT res = SendMessage(
				_WhToHwnd(_WMainClientWindow()),
				WM_USER + WM_CUT,
				0,
				0);
			return res == 0 ? NO : YES;
		}
	}
	return NO;   // event still needs to be handled by Visual FoxPro
}

void FASTCALL OnLoad(void)
{
	if (EventHandlerID) return;
	EventHandlerID = _ActivateHandler((FPFI)EventHandler);
}

void FASTCALL OnUnload(void)
{
	if (!EventHandlerID) return;
	_DeActivateHandler(EventHandlerID);
	EventHandlerID = 0;
}

FoxInfo myFoxInfo[] = {
	{"paste_watch_onload",(FPFI)OnLoad, CALLONLOAD, ""},
	{"paste_watch_onunload",(FPFI)OnUnload, CALLONUNLOAD, ""},
};

extern "C" {
	// the FoxTable structure
	FoxTable _FoxTable = {
		(FoxTable*)0, sizeof(myFoxInfo) / sizeof(FoxInfo), myFoxInfo
	};
}


