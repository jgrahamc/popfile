//---------------------------------------------------------------------------
//
// icon.cpp
//
// Simple DLL that puts an icon in the Windows system tray and handles
// a popup menu and double click events.  Used by POPFile so that it can
// have a tray icon like so many other Windows applications.
//
// Copyright (c) 2003 John Graham-Cumming
//
//---------------------------------------------------------------------------

FreeLibrary(
#include "stdafx.h"
#include "icon.h"
#include "resource.h"

// Name of the window class for our parent window

char * gClassName = "POPFile.NOTIFYICONDATA.hWnd";

// These two bools (one which indicates that Shutdown has been selected
// the other the UI) are set by the popup menu handle and read by a 
// call to GetMenuMessage

bool gShutdown = false;
bool gUI       = false;
bool gHideIcon = false;

// Used to store information about the POPFile icon displayed
// in the system tray

NOTIFYICONDATA gNid;

// The number of processes that have attached to us

int gProcessCount = 0;

// Handle of the Window associated with the tray icon

HWND gHwnd = 0;

// The instance of this DLL obtained from DllMain

HINSTANCE ghInst;

// Message ID sent when the system tray icon needs to send a message

#define UWM_SYSTRAY ( WM_USER + 1 )

//---------------------------------------------------------------------------
//
// wndProc__
//
// Windows procedure for the invisible window we use to handle the messages
// pertaining to the system tray icon.  It's job is to spot right click
// to show the menu and the left double click to go to the UI
//
//---------------------------------------------------------------------------

LRESULT CALLBACK wndProc__( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
{
	switch (message) {
		case UWM_SYSTRAY:
			switch (lParam) {
				case WM_RBUTTONUP: {
					POINT pt;
					GetCursorPos(&pt);
					HMENU hMenu  = LoadMenu( ghInst, MAKEINTRESOURCE(IDM_POPFILE));
					HMENU hPopUp = GetSubMenu( hMenu, 0);

					SetForegroundWindow( hwnd );

					switch ( TrackPopupMenu( hPopUp,
								TPM_RETURNCMD |	TPM_RIGHTBUTTON,
								pt.x, pt.y,
								0,         
								hwnd,
								NULL ) ) {
						case IDM_EXIT: 
							if ( MessageBox( hwnd, "Are you sure you want to shutdown POPFile?", "Shutdown POPFile", MB_ICONQUESTION | MB_YESNO ) == IDYES ) {
   							    gShutdown = true;
							}
							break;
						case IDM_HIDEICON: 
							gHideIcon = true;
							break;
						case IDM_UI:
							gUI = true;
							break;
						default:
							break;
					}
					PostMessage( gHwnd, 0, 0, 0);
					DestroyMenu( hMenu );
				}
				break;

				case WM_LBUTTONDBLCLK:
  				    gUI = true;
					break;
		}

		return TRUE;
	}

	return DefWindowProc( hwnd, message, wParam, lParam );
}

//---------------------------------------------------------------------------
//
// ShowPOPFileIcon
//
// Puts the POPFile icon in the system tray
//
//---------------------------------------------------------------------------

void ShowPOPFileIcon__()
{
	WNDCLASSEX wc;

	wc.cbSize         = sizeof(WNDCLASSEX);
	wc.style          = 0;
	wc.lpfnWndProc    = wndProc__;
	wc.cbClsExtra     = wc.cbWndExtra = 0;
	wc.hInstance      = ghInst;
	wc.hIcon          = LoadIcon( ghInst, MAKEINTRESOURCE(IDI_POPFILE));
	wc.hCursor        = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground  = (HBRUSH)(COLOR_WINDOW + 1);
	wc.lpszMenuName   = NULL;
	wc.lpszClassName  = gClassName;
	wc.hIconSm        = (HICON)LoadImage(ghInst, MAKEINTRESOURCE(IDI_POPFILE), IMAGE_ICON,
							GetSystemMetrics(SM_CXSMICON),
							GetSystemMetrics(SM_CYSMICON), 0);

	RegisterClassEx( &wc );

	gHwnd = CreateWindowEx( 0, gClassName, gClassName, WS_POPUP, CW_USEDEFAULT, 0,
			CW_USEDEFAULT, 0, NULL, NULL, ghInst, NULL);

	gNid.cbSize           = sizeof(NOTIFYICONDATA);
	gNid.hWnd             = gHwnd;
	gNid.uID              = 1;     
	gNid.uFlags           = NIF_MESSAGE | NIF_ICON | NIF_TIP;    
	gNid.uCallbackMessage = UWM_SYSTRAY;
	gNid.hIcon            = (HICON)LoadImage( ghInst, MAKEINTRESOURCE(IDI_POPFILE), IMAGE_ICON,
							GetSystemMetrics(SM_CXSMICON),
							GetSystemMetrics(SM_CYSMICON), 0);

	strcpy( gNid.szTip, "POPFile" );

	Shell_NotifyIcon( NIM_ADD, &gNid );
}

//---------------------------------------------------------------------------
//
// HidePOPFileIcon
//
// Removes the POPFile icon from the system tray
//
//---------------------------------------------------------------------------

void HidePOPFileIcon__()
{
	Shell_NotifyIcon( NIM_DELETE, &gNid );
    DestroyIcon( gNid.hIcon );
	DestroyWindow( gHwnd );
	UnregisterClass( gClassName, ghInst );
}

//---------------------------------------------------------------------------
//
// GetMenuMessage
//
// Called to get any message from the icon.  Returns 0 to indicate no
// message, 1 to indicate shutdown and 2 to indicate go to UI
//
//---------------------------------------------------------------------------

int APIENTRY GetMenuMessage()
{
	if ( gShutdown ) {
	    return 1;
	}

	if ( gUI ) {
		gUI = false;
		return 2;
	}

	if ( gHideIcon ) {
		gHideIcon = false;
		return 3;
	}

	return 0;
}

//---------------------------------------------------------------------------
//
// HideIcon
//
// Called to make the icon disappear
//
//---------------------------------------------------------------------------

int APIENTRY HideIcon()
{
	HidePOPFileIcon__();

	return 0;
}

//---------------------------------------------------------------------------
//
// DllMain
//
// Standard Windows DLL interface function
//
//---------------------------------------------------------------------------

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved )
{
	// When the first process attaches we show the icon, when
	// the last process detaches we kill off the icon.  We do
	// not care about new threads

	switch ( ul_reason_for_call ) {
		case DLL_PROCESS_ATTACH:
			gProcessCount += 1;
			if ( gProcessCount == 1 ) {
				ghInst = (HINSTANCE) hModule;
				ShowPOPFileIcon__();
			}
			break;

	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
		break;

	case DLL_PROCESS_DETACH:
			gProcessCount -= 1;
			if ( gProcessCount == 0 ) {
				HidePOPFileIcon__();
			}
		break;
	}

    return TRUE;
}
