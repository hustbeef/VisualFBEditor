﻿'#########################################################
'#  Designer.bi                                          #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#           Nastase Eodor(nastasa.eodor@gmail.com)      #
'#########################################################

'#Include Once "mff/Menus.bi"
'#Include Once "mff/Form.bi"
#include once "mff/Clipboard.bi"
#include once "Main.bi"

Using My.Sys.Forms

Common Shared As WString Ptr MFFPath
Common Shared As WString Ptr MFFDll

Common Shared As Integer GridSize
Common Shared As Boolean ShowAlignmentGrid
Common Shared As Boolean SnapToGridOption
Common Shared As Boolean ShowGrid

Common Shared As String SelectedClass
Common Shared As Integer SelectedType

Namespace My.Sys.Forms
	Type PDesigner As Designer Ptr
	#define QDesigner(__Ptr__) *Cast(Designer Ptr,__Ptr__)
	
	Type WindowList
		Count As Integer
		Ctrl As Any Ptr
		#ifndef __USE_GTK__
			Child As HWND Ptr
		#endif
	End Type
	
	#ifdef __USE_GTK__
		Dim Shared As GtkWidget Ptr designer_menu
	#endif
	
	Type Designer Extends My.Sys.Object
	Private:
		#ifdef __USE_GTK__
			Declare Static Function HookChildProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Declare Static Function HookDialogProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Declare Static Function HookDialogParentProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Declare Static Function DotWndProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
		#else
			Declare Static Function HookChildProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Declare Static Function HookDialogProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Declare Static Function HookDialogParentProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			Declare Static Function DotWndProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
			FPopupMenu     As HMENU
		#endif
		FActive        As Boolean
		FStepX         As Integer
		FStepY         As Integer
		FDotSize       As Integer
		FShowGrid      As Boolean
		FChilds        As WindowList
		#ifdef __USE_GTK__
			FDialog        As GtkWidget Ptr
			FDialogParent  As GtkWidget Ptr
		#else
			FDialog        As HWND
			FDialogParent  As HWND
		#endif
		FClass         As String
		FClassName     As WString Ptr
		#ifndef __USE_GTK__
			FGridBrush     As HBRUSH
		#endif
		FDotColor      As Integer
		FSelDotColor   As Integer
		#ifndef __USE_GTK__
			FDotBrush      As HBRUSH
			FSelDotBrush   As HBRUSH
		#endif
		FSnapToGrid    As Boolean
		FDown          As Boolean
		FCanInsert     As Boolean
		FCanMove       As Boolean
		FCanSize       As Boolean
		FBeginX        As Integer
		FBeginY        As Integer
		FOldX          As Integer
		FOldY          As Integer
		FNewX          As Integer
		FNewY          As Integer
		FEndX          As Integer
		FEndY          As Integer
		ReDim FLeft(0) As Integer
		ReDim FTop(0)  As Integer
		ReDim FWidth(0) As Integer
		ReDim FHeight(0) As Integer
		ReDim FLeftNew(0) As Integer
		ReDim FTopNew(0) As Integer
		ReDim FWidthNew(0) As Integer
		ReDim FHeightNew(0) As Integer
		FDotIndex      As Integer
		#ifdef __USE_GTK__
			ReDim FDots(0, 7)  As GtkWidget Ptr
		#else
			ReDim FDots(0, 7)  As HWND
		#endif
		FName          As String
		FStyleEx       As Integer
		FStyle         As Integer
		FID            As Integer
		#ifdef __USE_GTK__
			
		#else
			FHDC        As HDC
			FPoint As Point
		#endif
		Dim Ctrl As Any Ptr
		#ifndef __USE_GTK__
			Brush         As HBRUSH
			PrevBrush     As HBRUSH
		#endif
	Protected:
		Declare Sub ProcessMessage(ByRef Message As Message)
		#ifdef __USE_GTK__
			Declare        Function IsDot(hDlg As GtkWidget Ptr) As Integer
		#else
			Declare Static Sub HandleIsAllocated(ByRef Sender As Control)
			Declare Static Function EnumChildsProc(hDlg As HWND, lParam As LPARAM) As Boolean
			Declare        Function IsDot(hDlg As HWND) As Integer
		#endif
		Declare Function GetContainerControl(Ctrl As Any Ptr) As Any Ptr
		Declare        Sub HookParent
		Declare        Sub UnHookParent
		Declare        Sub RegisterDotClass(ByRef clsName As WString)
		Declare        Sub CreateDots(Parent As Control Ptr)
		Declare        Sub DestroyDots
		#ifdef __USE_GTK__
			Declare Function GetControlHandle(Control As Any Ptr) As GtkWidget Ptr
		#else
			Declare Function GetControlHandle(Control As Any Ptr) As HWND
		#endif
		'#IfDef __USE_GTK__
		Declare        Function ControlAt(Parent As Any Ptr, X As Integer, Y As Integer) As Any Ptr
		'#Else
		'	declare        function ControlAt(Parent as HWND,X as integer,Y as integer) as HWND
		'#EndIf
		#ifndef __USE_GTK__
			Declare        Sub GetChilds(Parent As HWND = 0)
		#endif
		Declare        Sub UpdateGrid
		Declare        Sub PaintGrid
		#ifndef __USE_GTK__
			Declare        Sub ClipCursor(hDlg As HWND)
		#endif
		Declare        Sub DrawBox(R As RECT)
		Declare        Sub DrawBoxs(R() As RECT)
		Declare        Sub Clear
		Declare        Function GetClassAcceptControls(AClassName As String) As Boolean
		Declare        Sub DblClick(X As Integer, Y As Integer, Shift As Integer)
		Declare        Sub MouseDown(X As Integer, Y As Integer, Shift As Integer)
		Declare        Sub MouseUp(X As Integer, Y As Integer, Shift As Integer)
		Declare        Sub MouseMove(X As Integer, Y As Integer, Shift As Integer)
		Declare        Sub KeyDown(Key As Integer, Shift As Integer)
	Public:
		CreateControlFunc As Function(ByRef ClassName As String, ByRef Name As WString, ByRef Text As WString, lLeft As Integer, lTop As Integer, lWidth As Integer, lHeight As Integer, Parent As Any Ptr) As Any Ptr
		CreateComponentFunc As Function(ClassName As String, ByRef Name As WString, lLeft As Integer, lTop As Integer, Parent As Any Ptr) As Any Ptr
		DeleteComponentFunc As Function(Cpnt As Any Ptr) As Boolean
		DeleteAllObjectsFunc As Function() As Boolean
		ReadPropertyFunc As Function(Cpnt As Any Ptr, ByRef PropertyName As String) As Any Ptr
		WritePropertyFunc As Function(Cpnt As Any Ptr, ByRef PropertyName As String, Value As Any Ptr) As Boolean
		RemoveControlSub As Sub(Parent As Any Ptr, Ctrl As Any Ptr)
		ControlByIndexFunc As Function(Parent As Any Ptr, Index As Integer) As Any Ptr
		Q_ComponentFunc As Function(Cpnt As Any Ptr) As Any Ptr
		ComponentGetBoundsSub As Sub(Ctrl As Any Ptr, ALeft As Integer Ptr, ATop As Integer Ptr, AWidth As Integer Ptr, AHeight As Integer Ptr)
		ComponentSetBoundsSub As Sub(Ctrl As Any Ptr, ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
		ControlIsContainerFunc As Function(Ctrl As Any Ptr) As Boolean
		IsControlFunc As Function(Ctrl As Any Ptr) As Boolean
		ControlSetFocusSub As Sub(Ctrl As Any Ptr)
		ControlFreeWndSub As Sub(Ctrl As Any Ptr)
		ToStringFunc As Function(Obj As Any Ptr) ByRef As WString
		FLibs          As WStringList
		Dim MFF As Any Ptr
		#ifdef __USE_GTK__
			FOverControl   As GtkWidget Ptr
		#else
			FOverControl   As HWND
		#endif
		Declare        Sub Hook
		Declare        Sub UnHook
		Declare        Sub HideDots
		Declare        Sub PaintControl()
		Declare        Sub CopyControl()
		Declare        Sub CutControl()
		Declare        Sub AddPasteControls(Ctrl As Any Ptr, ParentCtrl As Any Ptr, bStart As Boolean)
		Declare        Sub PasteControl()
		Declare        Sub DeleteControls(Ctrl As Any Ptr, EventOnly As Boolean = False)
		Declare        Sub DeleteControl()
		Declare        Sub SendToBack()
		DesignControl As Any Ptr
		SelectedControl As Any Ptr
		SelectedControls As List
		Objects As List
		Controls As List
		#ifdef __USE_GTK__
			cr As cairo_t Ptr
			layoutwidget As GtkWidget Ptr
			FSelControl    As GtkWidget Ptr
		#else
			FSelControl    As HWND
		#endif
		Declare        Sub DrawThis() 'DC as HDC, R as RECT)
		#ifdef __USE_GTK__
			Declare Function GetControl(CtrlHandle As GtkWidget Ptr) As Any Ptr
			Declare        Sub MoveDots(Control As Any Ptr, bSetFocus As Boolean = True, Left1 As Integer = -1, Top As Integer = -1, Width1 As Integer = -1, Height As Integer = -1)
		#else
			Declare Function GetControl(CtrlHandle As HWND) As Any Ptr
			Declare        Sub MoveDots(Control As Any Ptr, bSetFocus As Boolean = True)
		#endif
		Declare        Function CreateControl(AClassName As String, ByRef AName As WString, ByRef AText As WString, AParent As Any Ptr, x As Integer,y As Integer, cx As Integer, cy As Integer, bNotHook As Boolean = False) As Any Ptr
		Declare        Function CreateComponent(AClassName As String, AName As String, AParent As Any Ptr, x As Integer, y As Integer, bNotHook As Boolean = False) As Any Ptr
		OnChangeSelection  As Sub(ByRef Sender As Designer, Control As Any Ptr, iLeft As Integer = -1, iTop As Integer = -1, iWidth As Integer = -1, iHeight As Integer = -1)
		OnDeleteControl    As Sub(ByRef Sender As Designer, Control As Any Ptr)
		OnModified         As Sub(ByRef Sender As Designer, Control As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
		OnInsertControl    As Sub(ByRef Sender As Designer, ByRef ClassName As String, Ctrl As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
		OnInsertComponent  As Sub(ByRef Sender As Designer, ByRef ClassName As String, Cpnt As Any Ptr, iLeft2 As Integer, iTop2 As Integer)
		OnInsertingControl As Sub(ByRef Sender As Designer, ByRef ClassName As String, ByRef sName As String)
		OnMouseMove        As Sub(ByRef Sender As Designer, X As Integer, Y As Integer, ByRef Over As Any Ptr)
		OnDblClickControl  As Sub(ByRef Sender As Designer, Control As Any Ptr)
		OnClickProperties  As Sub(ByRef Sender As Designer, Control As Any Ptr)
		Declare            Function ClassExists() As Boolean
		'declare static     function GetClassName(hDlg as HWND) as string
		#ifdef __USE_GTK__
			Declare Property Dialog As GtkWidget Ptr
			Declare Property Dialog(value As GtkWidget Ptr)
			Declare            Sub HookControl(Control As GtkWidget Ptr)
			Declare            Sub UnHookControl(Control As GtkWidget Ptr)
		#else
			Declare            Sub HookControl(Control As HWND)
			Declare            Sub UnHookControl(Control As HWND)
			Declare Property Dialog As HWND
			Declare Property Dialog(value As HWND)
		#endif
		Declare Property Active As Boolean
		Declare Property Active(value As Boolean)
		Declare Property ChildCount As Integer
		Declare Property ChildCount(value As Integer)
		#ifndef __USE_GTK__
			Declare Property Child(index As Integer) As HWND
			Declare Property Child(index As Integer,value As HWND)
		#endif
		Declare Property StepX As Integer
		Declare Property StepX(value As Integer)
		Declare Property StepY As Integer
		Declare Property StepY(value As Integer)
		Declare Property DotColor As Integer
		Declare Property DotColor(value As Integer)
		Declare Property SnapToGrid As Boolean
		Declare Property SnapToGrid(value As Boolean)
		Declare Property ShowGrid As Boolean
		Declare Property ShowGrid(value As Boolean)
		Declare Property ClassName As String
		Declare Property ClassName(value As String)
		Declare Operator Cast As Any Ptr
		Declare Operator Cast As Control Ptr
		Declare Constructor(ParentControl As Control Ptr)
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "Designer.bas"
#endif
