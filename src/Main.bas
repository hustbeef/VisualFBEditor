﻿'#########################################################
'#  Main.bas                                             #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################
'#define __USE_GTK__

#include once "Main.bi"
#include once "mff/Dialogs.bi"
#include once "mff/Form.bi"
#include once "mff/TextBox.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/TabControl.bi"
#include once "mff/StatusBar.bi"
#include once "mff/Splitter.bi"
#include once "mff/ToolBar.bi"
#include once "mff/ListControl.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/ScrollBarControl.bi"
#include once "mff/Label.bi"
#include once "mff/Panel.bi"
#include once "mff/TrackBar.bi"
#include once "mff/Clipboard.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/IniFile.bi"
#include once "vbcompat.bi"

Using My.Sys.Forms
Using My.Sys.Drawing

#include once "frmSplash.bi"
pfSplash->Show
pApp->DoEvents

Dim Shared As iniFile iniSettings, iniTheme
Dim Shared As Toolbar tbStandard, tbExplorer, tbForm, tbProperties, tbEvents
Dim Shared As StatusBar stBar
Dim Shared As Splitter splLeft, splRight, splBottom, splProperties, splEvents
Dim Shared As ListControl lstLeft
Dim Shared As CheckBox chkLeft
Dim Shared As RadioButton radButton
Dim Shared As ScrollBarControl scrLeft
Dim Shared As Label lblLeft
Dim Shared As Panel pnlLeft, pnlRight, pnlBottom, pnlPropertyValue
Dim Shared As Trackbar trLeft
Dim Shared As ScrollBarControl scrTool
Dim Shared As MainMenu mnuMain
Dim Shared As MenuItem Ptr mnuStartWithCompile, mnuStart, mnuBreak, mnuEnd, mnuRestart, miRecentProjects, miRecentFiles, miRecentFolders, miRecentSessions
Dim Shared As SaveFileDialog SaveD
#ifndef __USE_GTK__
	Dim Shared As PageSetupDialog PageSetupD
	Dim Shared As PrintDialog PrintD
	Dim Shared As PrintPreviewDialog PrintPreviewD
	Dim Shared As My.Sys.ComponentModel.Printer pPrinter
#endif
Dim Shared As List Tools
Dim Shared As WStringList GlobalNamespaces, Comps, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs, AddIns, IncludeFiles, LoadPaths, IncludePaths, LibraryPaths, mlKeys, mlTexts, MRUFiles, MRUFolders, MRUProjects, MRUSessions ' add Sessions
Dim Shared As WString Ptr RecentFiles '
Dim Shared As Dictionary Compilers, MakeTools, Debuggers, Terminals, Helps, HotKeys
Dim Shared As ListView lvErrors, lvSearch, lvToDo
Dim Shared As ProgressBar prProgress
Dim Shared As TextBox txtPropertyValue, txtLabelProperty, txtLabelEvent
Dim Shared As ComboBoxEdit cboPropertyValue
Dim Shared As PopupMenu mnuForm, mnuVars, mnuExplorer, mnuTabs
Dim Shared As ImageList imgList, imgListD, imgListTools, imgListStates
Dim Shared As TreeListView lvProperties, lvEvents
Dim Shared As ToolPalette tbToolBox
Dim Shared As TabControl tabLeft, tabRight, tabDebug
Dim Shared As TreeView tvExplorer, tvVar, tvPrc, tvThd, tvWch
Dim Shared As TextBox txtOutput, txtImmediate, txtChangeLog ' Add Change Log
Dim Shared As TabControl tabCode, tabBottom
Dim Shared As Form frmMain
Dim Shared As Integer MainHeight =600, MainWidth = 800
Dim Shared As Integer miRecentMax =20 'David Changed
Dim Shared As Boolean mLoadLog, mLoadToDo, mChangeLogEdited, mStartLoadSession = True ' Add Change Log
Dim Shared As WString * MAX_PATH mChangelogName  'David Changed
pfrmMain = @frmMain
pSaveD = @SaveD
piniSettings = @iniSettings
piniTheme = @iniTheme
pComps = @Comps
pGlobalNamespaces = @GlobalNamespaces
pGlobalTypes = @GlobalTypes
pGlobalEnums = @GlobalEnums
pGlobalFunctions = @GlobalFunctions
pGlobalArgs = @GlobalArgs
pAddIns = @AddIns
pTools = @Tools
pCompilers = @Compilers
pMakeTools = @MakeTools
pDebuggers = @Debuggers
pTerminals = @Terminals
pHelps = @Helps
plvSearch = @lvSearch
plvToDo = @lvToDo '
ptbStandard = @tbStandard
plvProperties = @lvProperties
plvEvents = @lvEvents
pprProgress = @prProgress
pstBar = @stBar   'David Change
ptxtPropertyValue = @txtPropertyValue
ptvExplorer = @tvExplorer
ptabCode = @tabCode
ptabLeft = @tabLeft
ptabBottom = @tabBottom
ptabRight = @tabRight
pimgList = @imgList
pimgListTools = @imgListTools
pIncludeFiles = @IncludeFiles
pLoadPaths = @LoadPaths
pIncludePaths = @IncludePaths
pLibraryPaths = @LibraryPaths
LoadLanguageTexts
LoadSettings

#include once "file.bi"
#include once "Designer.bi"
#include once "TabWindow.bi"
#include once "Debug.bi"
#include once "frmFind.bi"
#include once "frmGoto.bi"
#include once "frmFindInFiles.bi"
#include once "frmAddIns.bi"
#include once "frmTools.bi"
#include once "frmAbout.bi"
#include once "frmOptions.bi"
#include once "frmParameters.bi"
#include once "frmProjectProperties.bi"

Function ML(ByRef V As WString) ByRef As WString
	If LCase(CurLanguage) = "english" Then Return V
	Dim As Integer tIndex = mlKeys.IndexOf(V) ' For improve the speed
	If tIndex >= 0 Then  '
		If mlTexts.Item(tIndex) <> "" Then Return mlTexts.Item(tIndex)
	Else
		tIndex = mlKeys.IndexOf(Replace(V, "&", "")) '
		If mlTexts.Item(tIndex) <> "" Then Return mlTexts.Item(tIndex)
	End If
	Return V
End Function

Sub ToolGroupsToCursor()
	tbToolBox.Groups.Item(0)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(1)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(2)->Buttons.Item(0)->Checked = True
	tbToolBox.Groups.Item(3)->Buttons.Item(0)->Checked = True
End Sub

Sub ClearMessages()
	txtOutput.Text = ""
	txtOutput.Update
End Sub

Sub tabCode_Paint(ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	MoveCloseButtons
End Sub

Sub SelectError(ByRef FileName As WString, iLine As Integer, tabw As TabWindow Ptr = 0)
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" Then Exit Sub
		tb = AddTab(FileName)
	End If
	tb->txtCode.SetSelection iLine - 1, iLine - 1, 0, tb->txtCode.LineLength(iLine - 1)
End Sub

Sub lvProperties_CellEditing(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr)
	'CellEditor = @cboPropertyValue
End Sub

Sub lvProperties_CellEdited(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString)
	PropertyChanged Sender, NewText, False
End Sub

Sub txtPropertyValue_LostFocus(ByRef Sender As Control)
	PropertyChanged Sender, Sender.Text, False
End Sub

Sub cboPropertyValue_Change(ByRef Sender As Control)
	PropertyChanged Sender, Sender.Text, True
End Sub

Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) As UString
	If StartsWith(FileName, GetFolderName(FilePath)) Then
		Return Mid(FileName, Len(GetFolderName(FilePath)) + 1)
	Else
		Return FileName
	End If
End Function

Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
	If CInt(InStr(Path, ":") > 0) OrElse CInt(StartsWith(Path, "/")) OrElse CInt(StartsWith(Path, "\")) Then
		Return Path
	ElseIf StartsWith(Path, "./") OrElse StartsWith(Path, ".\") Then
		If FromFile = "" Then
			If EndsWith(ExePath, "\..") OrElse EndsWith(ExePath, "/..") Then
				Return GetFolderName(GetFolderName(ExePath)) & Mid(Path, 3)
			Else
				Return ExePath & Slash & Mid(Path, 3)
			End If
		Else
			Return GetFolderName(FromFile) & Mid(Path, 3)
		End If
	ElseIf StartsWith(Path, "../") OrElse StartsWith(Path, "..\") Then
		If FromFile = "" Then
			Return GetFolderName(ExePath) & Mid(Path, 4)
		Else
			Return GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4)
		End If
	Else
		Return Path
	End If
End Function

Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
	Dim Pos1 As Long = InStrRev(FileName, "\", Len(FileName) - 1)
	Dim Pos2 As Long = InStrRev(FileName, "/", Len(FileName) - 1)
	If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
	If Pos1 > 0 Then
		If Not WithSlash Then Pos1 -= 1
		Return Left(FileName, Pos1)
	End If
	Return ""
End Function

Function GetFileName(ByRef FileName As WString) As UString
	Dim Pos1 As Long = InStrRev(FileName, "\")
	Dim Pos2 As Long = InStrRev(FileName, "/")
	If Pos1 = 0 OrElse Pos2 > Pos1 Then Pos1 = Pos2
	If Pos1 > 0 Then
		Return Mid(FileName, Pos1 + 1)
	End If
	Return FileName
End Function

Function GetBakFileName(ByRef FileName As WString) As UString
	Dim Pos1 As Long = InStrRev(FileName, ".")
	If Pos1 = 0 Then Pos1 = Len(FileName)
	If Pos1 > 0 Then
		Return FileName & ".bak" 'Left(FileName, Pos1 - 1) & "_bak" & Mid(FileName, Pos1)
	End If
End Function

Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) As UString
	Dim As UString CompileWith = " " & LTrim(sLine)
	Dim As UString pFileName = FileName
	Dim As UString ExeFileName
	Dim As String SearchChar
	Dim As Long Pos1, Pos2
	Pos1 = InStr(CompileWith, " -x ")
	If Pos1 > 0 Then
		If Mid(CompileWith, Pos1 + 4, 1) = """" Then
			SearchChar = """"
		Else
			SearchChar = " "
		End If
		Pos2 = InStr(Pos1 + 5, CompileWith, SearchChar)
		If Pos2 > 0 Then
			ExeFileName = Mid(CompileWith, Pos1 + 5, Pos2 - Pos1 - 5)
			If CInt(InStr(ExeFileName, ":") = 0) AndAlso CInt(Not StartsWith(ExeFileName, "/")) Then
				Return GetFolderName(pFileName) + ExeFileName
			Else
				Return ExeFileName
			End If
		End If
	End If
	Pos1 = InStrRev(pFileName, ".")
	If Pos1 = 0 Then Pos1 = Len(pFileName) + 1
	If Pos1 > 0 Then
		#ifdef __USE_GTK__
			Return Left(pFileName, Pos1 - 1) & IIf(InStr(CompileWith, "-dll"), ".so", "")
		#else
			Return Left(pFileName, Pos1 - 1) & IIf(InStr(CompileWith, "-dll"), ".dll", ".exe")
		#endif
	End If
End Function

Function Compile(Parameter As String = "") As Integer
	On Error Goto ErrorHandler
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim MainFile As WString Ptr: WLet MainFile, GetMainFile(AutoSaveBeforeCompiling, Project, ProjectNode)
	If Len(*MainFile) <= 0 Then
		ThreadsEnter()
		ShowMessages ML("No Main file specified for the project.") & "!"
		ThreadsLeave()
		WDeallocate MainFile
		Return 0
	End If
	Dim FirstLine As WString Ptr: WLet FirstLine, GetFirstCompileLine(*MainFile, Project)
	Versioning *MainFile, *FirstLine, Project, ProjectNode
	Dim FileOut As Integer
	ThreadsEnter()
	Dim As Boolean Bit32 = tbStandard.Buttons.Item("B32")->Checked
	ThreadsLeave()
	Dim ExeName As WString Ptr: WLet ExeName, GetExeFileName(*MainFile, *FirstLine)
	Dim FbcExe As WString Ptr = IIf(Bit32, Compiler32Path, Compiler64Path)
	If *FbcExe = "" Then
		WDeallocate MainFile
		ThreadsEnter()
		ShowMessages ML("Invalid defined compiler path.")
		ThreadsLeave()
		Return 0
	Else
		#ifdef __USE_GTK__
			If g_find_program_in_path(*FbcExe) = NULL Then
		#else
			If Not FileExists(*FbcExe) Then
		#endif
			WDeallocate MainFile
			ThreadsEnter()
			ShowMessages ML("File") & " """ & *FbcExe & """ " & ML("not found") & "!"
			ThreadsLeave()
			Return 0
		End If
	End If
	Dim As ToolType Ptr Tool
	For i As Integer = 0 To Tools.Count - 1
		Tool = Tools.Item(i)
		If Tool->LoadType = LoadTypes.BeforeCompile Then Tool->Execute
	Next
	Dim LogFileName As WString Ptr '
	Dim LogFileName2 As WString Ptr
	Dim BatFileName As WString Ptr
	Dim fbcCommand As WString Ptr
	Dim CompileWith As WString Ptr
	Dim MFFPathC As WString Ptr
	Dim As WString Ptr ErrFileName, ErrTitle
	Dim As Integer iLine
	Dim LogText As WString Ptr
	
	WLet MFFPathC, *MFFPath
	If CInt(InStr(*MFFPathC, ":") = 0) AndAlso CInt(Not StartsWith(*MFFPathC, "/")) Then WLet MFFPathC, ExePath & "/" & *MFFPath
	WLet BatFileName, ExePath + "/debug.bat"
	Dim As Boolean Band, Yaratilmadi
	ChDir(GetFolderName(*MainFile))
	If Parameter = "Check" Then
		WLet ExeName, "chk.dll"
	End If
	ClearMessages
	FileOut = FreeFile
	If Dir(*ExeName) <> "" Then 'delete exe if exist
		If Kill(*ExeName) <> 0 Then
			ThreadsEnter()
			ShowMessages(Str(Time) & ": " &  ML("Cannot compile - the program is now running") & " " & *ExeName) '
			ThreadsLeave()
			Band = True
			WDeallocate fbcCommand  '
			WDeallocate CompileWith
			WDeallocate MFFPathC
			WDeallocate MainFile
			WDeallocate FirstLine
			WDeallocate ExeName
			WDeallocate LogText
			Return 0
		End If
	End If
	WLet CompileWith, *FirstLine
	If CInt(InStr(*CompileWith, " -s ") = 0) AndAlso CInt(tbStandard.Buttons.Item("Form")->Checked) Then
		WAdd CompileWith, " -s gui"
	End If
	If CInt(UseDebugger) OrElse CInt(CInt(Project) AndAlso CInt(Project->CreateDebugInfo)) Then WAdd CompileWith, " -g"
	If Project Then
		If Project->CompileToGCC Then
			WAdd CompileWith, " -gen gcc" & IIf(Project->OptimizationLevel > 0, " -Wc -O" & WStr(Project->OptimizationLevel), IIf(Project->OptimizationFastCode, " -Wc -Ofast", IIf(Project->OptimizationSmallCode, " -Wc -Os", "")))
		End If
	End If
	If IncludeMFFPath Then WAdd CompileWith, " -i """ & *MFFPathC & """"
	For i As Integer = 0 To pIncludePaths->Count - 1
		WAdd CompileWith, " -i """ & pIncludePaths->Item(i) & """"
	Next
	For i As Integer = 0 To pLibraryPaths->Count - 1
		WAdd CompileWith, " -p """ & pLibraryPaths->Item(i) & """"
	Next
	'WLet LogFileName, ExePath & "/Temp/debug_compil.log"
	WLet LogFileName2, ExePath & "/Temp/debug_compil2.log"
	WLet fbcCommand, " -b """ & GetFileName(*MainFile) & """ " & *CompileWith
	If Parameter <> "" AndAlso Parameter <> "Make" AndAlso Parameter <> "MakeClean" Then
		If Parameter = "Check" Then WAdd fbcCommand, " -x """ & *ExeName & """"
	End If
	Dim As WString Ptr PipeCommand
	If CInt(Parameter = "Make") OrElse CInt(CInt(Parameter = "Run") AndAlso CInt(UseMakeOnStartWithCompile) AndAlso CInt(FileExists(GetFolderName(*MainFile) & "/makefile"))) Then
		Dim As String Colon = ""
		#ifdef __USE_GTK__
			Colon = ":"
		#endif
		WLet PipeCommand, """" & *MakeToolPath & """ FBC" & Colon & "=""""""" & *fbcexe & """"""" XFLAG" & Colon & "=""-x """"" & *ExeName & """""""" & IIf(UseDebugger, " GFLAG" & Colon & "=-g", "") & " " & *Make1Arguments
	ElseIf Parameter = "MakeClean" Then
		WLet PipeCommand, """" & *MakeToolPath & """ " & *Make2Arguments
	Else
		WLet PipeCommand, """" & *fbcexe & """ " & *fbcCommand
	End If
	'	' for better showing
	'	#ifdef __USE_GTK__
	'		*PipeCommand=Replace(Replace(*PipeCommand,"\","/"),"/./","/")
	'	#else
	'		*PipeCommand=Replace(Replace(*PipeCommand,"/","\"),"\.\","\")
	'	#endif
	If Parameter <> "Check" Then
		ThreadsEnter()
		ShowMessages(Str(Time) + ": " + IIf(Parameter = "MakeClean", ML("Clean"), ML("Compilation")) & ": " & *PipeCommand & " ..." + WChr(13) + WChr(10))
		ThreadsLeave()
	End If
	'OPEN *BatFileName For Output As #FileOut
	'Print #FileOut, *fbcCommand  + " > """ + *LogFileName + """" + " 2>""" + *LogFileName2 + """"
	'Close #FileOut
	'Shell("""" + BatFileName + """")
	ChDir(GetFolderName(*MainFile))
	'Shell(*fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """")
	'Open Pipe *fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """" For Input As #1
	'Close #1
	'PipeCmd "", *PipeCommand & " > """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """"
	ThreadsEnter()
	StartProgress
	lvErrors.ListItems.Clear
	ptabBottom->Tabs[1]->Caption = ML("Errors") '    'Inits
	ThreadsLeave()
	Dim As Long nLen, nLen2
	Dim As Boolean Log2_
	
	Dim As Integer Result = -1, Fn =FreeFile
	Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
	#ifdef __USE_GTK__
		If Open Pipe(*PipeCommand & " 2> """ + *LogFileName2 + """" For Input As #Fn) = 0 Then
	#else
		If Open Pipe("""" & *PipeCommand & " 2> """ + *LogFileName2 + """" & """" For Input As #Fn) = 0 Then
			'ShowWindow(getconsolewindow,SW_HIDE)
	#endif
		While Not EOF(Fn)
			Line Input #Fn, Buff
			SplitError(Buff, ErrFileName, ErrTitle, iLine)
			ThreadsEnter()
			If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
			lvErrors.ListItems.Add *ErrTitle, IIf(InStr(*ErrTitle, "warning"), "Warning", IIf(InStr(LCase(*ErrTitle), "error"), "Error", "Info"))
			lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(1) = WStr(iLine)
			lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(2) = *ErrFileName
			ShowMessages(Buff, False)
			ThreadsLeave()
			'*LogText = *LogText & *Buff & WChr(13) & WChr(10)
		Wend
		Close #Fn
	End If
	WDeallocate PipeCommand
	#ifdef __USE_GTK__
		Yaratilmadi = g_find_program_in_path(*ExeName) = NULL
	#else
		Yaratilmadi = Dir(*ExeName) = ""
	#endif
	
	Fn =FreeFile
	Result=-1
	Result = Open(*LogFileName2 For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(*LogFileName2 For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(*LogFileName2 For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(*LogFileName2 For Input As #Fn)
	If Result = 0 Then
		While Not EOF(Fn)
			Line Input #Fn, Buff
			'If Trim(*Buff) <> "" Then lvErrors.ListItems.Add *Buff
			SplitError(Buff, ErrFileName, ErrTitle, iLine)
			ThreadsEnter()
			If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
			lvErrors.ListItems.Add *ErrTitle, IIf(InStr(*ErrTitle, "warning"), "Warning", IIf(InStr(LCase(*ErrTitle), "error"), "Error", "Info"))
			lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(1) = WStr(iLine)
			lvErrors.ListItems.Item(lvErrors.ListItems.Count - 1)->Text(2) = *ErrFileName
			ShowMessages(Buff, False)
			ThreadsLeave()
			'*LogText = *LogText & *Buff & WChr(13) & WChr(10)
			Log2_ = True
		Wend
		Close #Fn
	End If
	ThreadsEnter()
	If lvErrors.ListItems.Count <> 0 Then
		ptabBottom->Tabs[1]->Caption = ML("Errors") & " (" & lvErrors.ListItems.Count & " " & ML("Pos") & ")"
	Else
		ptabBottom->Tabs[1]->Caption = ML("Errors")
	End If
	ThreadsLeave()
	'If LogFileName Then Deallocate LogFileName
	If LogFileName2 Then Deallocate LogFileName2
	If BatFileName Then Deallocate BatFileName
	WDeallocate fbcCommand
	WDeallocate CompileWith
	WDeallocate MFFPathC
	WDeallocate MainFile
	WDeallocate FirstLine
	ThreadsEnter()
	ShowMessages("")
	StopProgress
	ThreadsLeave()
	For i As Integer = 0 To Tools.Count - 1
		Tool = Tools.Item(i)
		If Tool->LoadType = LoadTypes.AfterCompile Then Tool->Execute
	Next
	If Yaratilmadi Or Band Then
		ThreadsEnter()
		If Parameter <> "Check" Then
			ShowMessages(Str(Time) & ": " & ML("Do not build file."))
			If (Not Log2_) AndAlso lvErrors.ListItems.Count <> 0 Then ptabBottom->Tabs[1]->SelectTab
		ElseIf lvErrors.ListItems.Count <> 0 Then
			ShowMessages(Str(Time) & ": " & ML("Checking ended."))
			ptabBottom->Tabs[1]->SelectTab
		Else
			ShowMessages(Str(Time) & ": " & ML("No errors or warnings were found."))
		End If
		ThreadsLeave()
		WDeallocate LogText
		Return 0
	Else
		ThreadsEnter()
		If InStr(*LogText, "warning") > 0 Then
			If Parameter <> "Check" Then
				ShowMessages(Str(Time) & ": " & ML("Layout has been successfully completed, but there are warnings."))
			End If
		Else
			If Parameter <> "Check" Then
				ShowMessages(Str(Time) & ": " & ML("Layout succeeded!"))
			Else
				ShowMessages(Str(Time) & ": " & ML("Syntax errors not found!"))
			End If
		End If
		ThreadsLeave()
		WDeallocate LogText
		WDeallocate ExeName
		Return 1
	End If
	
	Exit Function
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
	ThreadsLeave()
End Function

Sub SelectSearchResult(ByRef FileName As WString, iLine As Integer, ByVal iSelStart As Integer =-1, ByVal iSelLength As Integer =-1, tabw As TabWindow Ptr = 0, ByRef SearchText As WString = "")
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" Then Exit Sub
		tb = AddTab(FileName)
	End If
	If SearchText <> "" Then
		If iSelStart = -1 AndAlso tb->txtCode.LinesCount > iLine - 1 Then iSelStart = InStr(LCase(tb->txtCode.Lines(iLine - 1)), LCase(SearchText))
		If iSelLength = -1 Then iSelLength = Len(SearchText)
	End If
	#ifdef __USE_GTK__
		pApp->DoEvents
	#endif
	tb->txtCode.TopLine = iLine - tb->txtCode.VisibleLinesCount / 2
	tb->txtCode.SetSelection iLine - 1, iLine - 1, iSelStart - 1, iSelStart + iSelLength - 1
End Sub

Sub txtOutput_DblClick(ByRef Sender As Control)
	Dim Buff As WString Ptr = @txtOutput.Lines(txtOutput.GetLineFromCharIndex)
	Dim As WString Ptr ErrFileName, ErrTitle
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As Integer iLine
	Dim As WString Ptr Temp
	SplitError(*Buff, ErrFileName, ErrTitle, iLine)
	Dim MainFile As WString Ptr: WLet MainFile, GetMainFile(False, Project, ProjectNode)
	If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet ErrFileName, GetFolderName(*MainFile) & *ErrFileName
	WDeallocate Temp
	WDeallocate MainFile
	SelectError(*ErrFileName, iLine)
End Sub

Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
	If tbExplorer.Buttons.Item(3)->Checked Then
		If EndsWith(FileName, ".bi") Then
			Return tn->Nodes.Item(0)
		ElseIf EndsWith(FileName, ".frm") Then
			Return tn->Nodes.Item(1)
		ElseIf EndsWith(FileName, ".bas") OrElse EndsWith(FileName, ".inc") Then
			Return tn->Nodes.Item(2)
		ElseIf EndsWith(FileName, ".rc") Then
			Return tn->Nodes.Item(3)
		Else
			Return tn->Nodes.Item(4)
		End If
	Else
		Return tn
	End If
End Function

Sub AddMRUProject(ByRef FileName As WString)
	Var i = MRUProjects.IndexOf(FileName)
	If i >= 0 Then
		If i > 0 Then
			MRUProjects.Remove i
			MRUProjects.Add FileName
		End If
	Else
		MRUProjects.Add FileName
		i= miRecentProjects->Count -1
		miRecentProjects->Item(i)->Caption = FileName
		miRecentProjects->Item(i)->Name = FileName
		miRecentProjects->Add(ML("Clear Recently Opened"),"","ClearProjects", @mClickMRU)
	End If
End Sub

Sub AddMRUFolder(ByRef FolderName As WString)
	Var i = MRUFolders.IndexOf(FolderName)
	If i <> 0 Then
		If i > 0 Then MRUFolders.Remove i
		MRUFolders.Insert 0, FolderName
		For i = 0 To Min(miRecentFolders->Count - 1, MRUFolders.Count - 1)
			miRecentFolders->Item(i)->Caption = MRUFolders.Item(i)
			miRecentFolders->Item(i)->Name = MRUFolders.Item(i)
		Next
		For i = i To Min(9, MRUFolders.Count - 1)
			miRecentFolders->Add(MRUFolders.Item(i), "", MRUFolders.Item(i), @mClickMRU)
		Next
	End If
End Sub

'Extern "rtlib"
'   Declare Function LineInputWstr Alias "fb_FileLineInputWstr"_
'      ( _
'         ByVal filenumber As Long, _
'         ByVal dst As WString Ptr, _
'         ByVal maxchars As Integer _
'      ) As Long
'End Extern

Sub ClearTreeNode(ByRef tn As TreeNode Ptr)
	If tn = 0 Then Exit Sub
	For i As Integer = 0 To tn->Nodes.Count - 1
		Delete Cast(ExplorerElement Ptr, tn->Nodes.Item(i)->Tag)
	Next
	tn->Nodes.Clear
End Sub

Sub ExpandFolder(ByRef tn As TreeNode Ptr)
	If tn = 0 Then Exit Sub
	Dim As ExplorerElement Ptr ee = tn->Tag, ee1
	If ee = 0 OrElse ee->FileName = 0 Then Exit Sub
	ClearTreeNode tn
	Dim As TreeNode Ptr tn1
	Dim As String f, IconName
	Dim As UInteger Attr
	Dim As WStringList Files
	f = Dir(*ee->FileName & "/*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then
				IconName = "Opened"
				tn1 = tn->Nodes.Add(GetFileName(f), , f, IconName, IconName)
				If FileExists(f & Slash & f & ".vfp") Then
					AddProject f & Slash & f & ".vfp", , tn1
					WLet Cast(ExplorerElement Ptr, tn1->Tag)->FileName, *ee->FileName & "/" & f
				Else
					ee1 = New ExplorerElement
					WLet ee1->FileName, *ee->FileName & "/" & f
					tn1->Tag = ee1
				End If
				tn1->Nodes.Add ""
			End If
		Else
			Files.Add *ee->FileName & "/" & f
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Files.Count - 1
		If EndsWith(LCase(Files.Item(i)), ".vfp") Then
			IconName = "Project"
		ElseIf EndsWith(LCase(Files.Item(i)), ".rc") OrElse EndsWith(LCase(Files.Item(i)), ".res") OrElse EndsWith(LCase(Files.Item(i)), ".xpm") Then
			IconName = "Res"
		Else
			IconName = "File"
		End If
		tn1 = tn->Nodes.Add(GetFileName(*ee->FileName & "/" & Files.Item(i)), , Files.Item(i), IconName, IconName)
		ee1 = New ExplorerElement
		WLet ee1->FileName, Files.Item(i)
		tn1->Tag = ee1
	Next i
End Sub

Sub CloseFolder(ByRef tn As TreeNode Ptr)
	ClearTreeNode tn
	Delete tn
End Sub

Function AddFolder(ByRef FolderName As WString) As TreeNode Ptr
	Dim As TreeNode Ptr tn
	If FolderName <> "" Then
		AddMRUFolder FolderName
		Dim As Integer Pos1
		For i As Integer = 0 To tvExplorer.Nodes.Count - 1
			If tvExplorer.Nodes.Item(i)->Tag <> 0 AndAlso EqualPaths(*Cast(ExplorerElement Ptr, tvExplorer.Nodes.Item(i)->Tag)->FileName, FolderName) Then
				tvExplorer.Nodes.Item(i)->SelectItem
				Return tvExplorer.Nodes.Item(i)
			End If
		Next
		Dim As String IconName = "Opened"
		tn = tvExplorer.Nodes.Add(GetFileName(FolderName), , FolderName, IconName, IconName)
		If FileExists(FolderName & Slash & GetFileName(FolderName) & ".vfp") Then
			AddProject FolderName & Slash & GetFileName(FolderName) & ".vfp", , tn
			WLet Cast(ExplorerElement Ptr, tn->Tag)->FileName, FolderName
		Else
			Dim As ExplorerElement Ptr ee
			ee = New ExplorerElement
			WLet ee->FileName, FolderName
			tn->Tag = ee
		End If
		ExpandFolder tn
		tn->Expand
	End If
	Return tn
End Function

Function AddProject(ByRef FileName As WString = "", pFilesList As WStringList Ptr = 0, tn As TreeNode Ptr = 0) As TreeNode Ptr
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr tn3
	Dim As Boolean inFolder = tn <> 0
	If Not inFolder Then
		If FileName <> "" Then
			If Not FileExists(FileName) Then
				MsgBox ML("File not found") & ": " & FileName
				Return tn
			End If
			AddMRUProject FileName
			'Dim As WString Ptr buff '
			Dim As Integer Pos1
			For i As Integer = 0 To tvExplorer.Nodes.Count - 1
				If tvExplorer.Nodes.Item(i)->Tag <> 0 AndAlso EqualPaths(*Cast(ExplorerElement Ptr, tvExplorer.Nodes.Item(i)->Tag)->FileName, FileName) Then
					tvExplorer.Nodes.Item(i)->SelectItem
					Return tvExplorer.Nodes.Item(i)
				End If
			Next
			tn = tvExplorer.Nodes.Add(GetFileName(FileName), , FileName, "Project", "Project")
		Else
			Var n = 0
			Dim NewName As String
			Do
				n = n + 1
				NewName = "Project" & Str(n)
			Loop While tvExplorer.Nodes.Contains(NewName)
			tn = tvExplorer.Nodes.Add(NewName & " *", , , "Project", "Project")
		End If
		'If tn <> 0 Then
		If tbExplorer.Buttons.Item(3)->Checked Then
			tn->Nodes.Add ML("Includes"), "Includes", , "Opened", "Opened"
			tn->Nodes.Add ML("Forms"), "Forms", , "Opened", "Opened"
			tn->Nodes.Add ML("Modules"), "Modules", , "Opened", "Opened"  '.  Using "Modules" is better than "Sources"
			tn->Nodes.Add ML("Resources"), "Resources", , "Opened", "Opened"
			tn->Nodes.Add ML("Others"), "Others", , "Opened", "Opened"
			'End if
		End If
		tn->SelectItem
	End If
	If FileName <> "" Then
		Dim As TreeNode Ptr tn1, tn2
		'Dim buff As WString Ptr '
		Dim Pos1 As Integer
		Dim bMain As Boolean
		Dim As ProjectElement Ptr ppe
		Dim As WStringList Files
		Dim As WStringList Ptr pFiles
		ppe = New ProjectElement
		WLet ppe->FileName, FileName
		tn->Tag = ppe
		If pFilesList = 0 Then pFiles = @Files Else pFiles = pFilesList
		Dim As String Parameter
		Dim As String IconName
		Dim Buff As WString * 1024 ' for V1.07 Line Input not working fine
		Dim As Integer Fn = FreeFile
		Dim Result As Integer = -1 '
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				Pos1 = InStr(Buff, "=")
				If Pos1 <> 0 Then
					Parameter = Left(Buff, Pos1 - 1)
				Else
					Parameter = ""
				End If
				If Parameter = "File" OrElse Parameter = "*File" Then
					bMain = StartsWith(Buff, "*")
					Buff = Trim(Mid(Buff, Pos1+1 ))
					ee = New ExplorerElement
					If CInt(InStr(Buff, ":") = 0) OrElse CInt(StartsWith(Buff, "/")) Then
						#ifdef __USE_GTK__
							WLet ee->FileName, GetFolderName(FileName) & Buff
						#else
							WLet ee->FileName, GetFolderName(FileName) & Replace(Buff, "/", "\")
						#endif
					Else
						WLet ee->FileName, Buff
					End If
					If Not inFolder Then
						tn1 = GetTreeNodeChild(tn, Buff)
					End If
					'
					Dim As Boolean FileEx = Dir(*ee->FileName)<>""
					If bMain Then
						IconName = "MainRes"
						If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".res") Then  '
							WLet ppe->ResourceFileName, *ee->FileName
						ElseIf EndsWith(LCase(*ee->FileName), ".xpm") Then  '
							WLet ppe->IconResourceFileName, *ee->FileName
						Else
							WLet ppe->MainFileName, *ee->FileName
							IconName = "MainFile"
						End If
						If Not FileEx Then IconName = "New"
						If Not inFolder Then
							tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName),, *ee->FileName, IconName, IconName, True)
							If MainNode = 0 Then SetMainNode GetParentNode(tn1)  '
						End If
					Else
						If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".res") OrElse EndsWith(LCase(*ee->FileName), ".xpm") Then
							IconName = "Res"
						ElseIf EndsWith(LCase(*ee->FileName), ".frm") Then
							IconName = "Form"
						Else
							IconName = "File"
						End If
						If Not FileEx Then IconName = "New"
						If Not inFolder Then
							tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName), , *ee->FileName, IconName, IconName, True)
						End If
					End If
					If EndsWith(*ee->FileName, ".bas") OrElse EndsWith(*ee->FileName, ".frm") OrElse EndsWith(*ee->FileName, ".bi") OrElse EndsWith(*ee->FileName, ".inc") Then
						pFiles->Add *ee->FileName
						If Not LoadPaths.Contains(*ee->FileName) Then LoadPaths.Add *ee->FileName
						ThreadCreate(@LoadOnlyFilePath, @LoadPaths.Item(LoadPaths.IndexOf(*ee->FileName)))
					End If
					If inFolder Then
						ppe->Files.Add *ee->FileName
						Delete ee
					Else
						tn2->Tag = ee
					End If
					' tn1->Expand
				ElseIf Parameter = "ProjectType" Then
					ppe->ProjectType = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "ProjectName" Then
					WLet ppe->ProjectName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "HelpFileName" Then
					WLet ppe->HelpFileName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "ProjectDescription" Then
					WLet ppe->ProjectDescription, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "MajorVersion" Then
					ppe->MajorVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "MinorVersion" Then
					ppe->MinorVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "RevisionVersion" Then
					ppe->RevisionVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "BuildVersion" Then
					ppe->BuildVersion = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "AutoIncrementVersion" Then
					ppe->AutoIncrementVersion = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "ApplicationTitle" Then
					WLet ppe->ApplicationTitle, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "ApplicationIcon" Then
					WLet ppe->ApplicationIcon, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CompanyName" Then
					WLet ppe->CompanyName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "FileDescription" Then
					WLet ppe->FileDescription, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "InternalName" Then
					WLet ppe->InternalName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "LegalCopyright" Then
					WLet ppe->LegalCopyright, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "LegalTrademarks" Then
					WLet ppe->LegalTrademarks, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "OriginalFilename" Then
					WLet ppe->OriginalFilename, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "ProductName" Then
					WLet ppe->ProductName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CompileToGCC" Then
					ppe->CompileToGCC = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationLevel" Then
					ppe->OptimizationLevel = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationFastCode" Then
					ppe->OptimizationFastCode = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationSmallCode" Then
					ppe->OptimizationFastCode = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "CompilationArguments32Windows" Then
					WLet ppe->CompilationArguments32Windows, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CompilationArguments64Windows" Then
					WLet ppe->CompilationArguments64Windows, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CompilationArguments32Linux" Then
					WLet ppe->CompilationArguments32Linux, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CompilationArguments64Linux" Then
					WLet ppe->CompilationArguments64Linux, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CommandLineArguments" Then
					WLet ppe->CommandLineArguments, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "CreateDebugInfo" Then
					ppe->CreateDebugInfo = CBool(Mid(Buff, Pos1 + 1))
				End If
			Loop
		End If
		Close #Fn
		If pFilesList = 0 Then
			For i As Integer = 0 To pFiles->Count - 1
				ThreadCreate(@LoadOnlyIncludeFiles, @LoadPaths.Item(LoadPaths.IndexOf(pFiles->Item(i))))
			Next
		End If
	End If
	If Not inFolder Then
		tn->Expand
	End If
	'pfProjectProperties->RefreshProperties
	Return tn
End Function

Sub OpenFolder()
	Dim As FolderBrowserDialog BrowseD
	If Not BrowseD.Execute Then Exit Sub
	AddFolder BrowseD.Directory
	TabLeft.Tabs[0]->SelectTab
End Sub

Sub OpenProject()
	Dim As OpenFileDialog OpenD
	OpenD.InitialDir = GetFullPath(*ProjectsPath)
	OpenD.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("All Files") & "|*.*|"
	If Not OpenD.Execute Then Exit Sub
	AddProject OpenD.FileName
	TabLeft.Tabs[0]->SelectTab
End Sub

Sub OpenUrl(ByVal url As String)
	Dim As String cmd
	#ifdef __USE_GTK__
		cmd = "xdg-open " & url
	#else
		cmd =  "start /b " & url
	#endif
	Shell cmd
End Sub

Function AddSession(ByRef FileName As WString) As Boolean
	'Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr tn
	AddMRUSession FileName
	Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
	Dim As WStringList Files
	Dim As Integer Fn = FreeFile
	Dim Result As Integer = -1 '
	Result = Open(FileName For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input As #Fn)
	If Result = 0 Then
		Dim As WString Ptr filn
		Dim As Boolean bMain
		Dim As Integer Pos1
		MainNode = 0 '
		Dim CurrentPath As WString * 255
		CurrentPath = GetFolderName(FileName)
		Do Until EOF(Fn)
			Line Input #Fn, Buff
			If StartsWith(LCase(Buff), "file=") OrElse StartsWith(LCase(Buff), "*file=") Then
				Pos1 = InStr(Buff, "=")
				If Pos1 <> 0 Then
					bMain = StartsWith(Buff, "*")
					WLet filn, Mid(Buff, Pos1 + 1)
					If CInt(InStr(*filn, ":") = 0) OrElse CInt(StartsWith(*filn, "/")) Then
						WLet filn, CurrentPath & Replace(*filn, BackSlash, Slash)
						If EndsWith(*filn, Slash) Then WLet filn, Left(*filn, Len(*filn) - 1), True
					End If
					Dim tn As TreeNode Ptr
					If EndsWith(LCase(*filn), ".vfp") Then
						tn = AddProject(*filn, @Files)
						If tn = 0 Then Continue Do
					ElseIf Len(Dir(*filn, fbDirectory)) Then
						tn = AddFolder(*filn)
						If tn = 0 Then Continue Do
					Else
						Var tb = AddTab(*filn)
						If tb Then tn = tb->tn
					End If
					If bMain Then
						SetMainNode tn
					End If
				End If
			End If
		Loop
		WDeallocate filn
		If MainNode = 0 AndAlso tn > 0 Then SetMainNode tn ' For No MainFIle
		Close #Fn
		For i As Integer = 0 To Files.Count - 1
			ThreadCreate(@LoadOnlyIncludeFiles, @LoadPaths.Item(LoadPaths.IndexOf(Files.Item(i))))
		Next
		Return True
	End If
	Return False
End Function

Sub OpenSession()
	Dim As OpenFileDialog OpenD
	OpenD.Filter = ML("VisualFBEditor Session") & " (*.vfs)|*.vfs|" & ML("All Files") & "|*.*|"
	If WGet(LastOpenPath) <> "" Then
		OpenD.InitialDir = *LastOpenPath
	Else
		OpenD.InitialDir = GetFullPath(*ProjectsPath)
	End If
	If Not OpenD.Execute Then Exit Sub
	'David Chang It is not allowed load two Sessions.
	For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			CloseProject(tvExplorer.Nodes.Item(i))
		End If
	Next i
	WLet LastOpenPath, GetFolderName(OpenD.FileName)
	AddSession OpenD.FileName
	TabLeft.Tabs[0]->SelectTab
End Sub

Sub AddMRUFile(ByRef FileName As WString)
	Var i = MRUFiles.IndexOf(FileName)
	If i >= 0 Then ' David Change
		If i > 0 Then
			MRUFiles.Remove i
			MRUFiles.Add FileName
		End If
	Else
		MRUFiles.Add FileName
		i= miRecentFiles->Count -1
		miRecentFiles->Item(i)->Caption = FileName
		miRecentFiles->Item(i)->Name = FileName
		miRecentFiles->Add(ML("Clear Recently Opened"),"","ClearFiles", @mClickMRU)
	End If
End Sub

'
Sub AddMRUSession(ByRef FileName As WString)
	Var i = MRUSessions.IndexOf(FileName)
	If i >= 0 Then
		If i > 0 Then
			MRUSessions.Remove i
			MRUSessions.Add FileName
		End If
	Else
		MRUSessions.Add FileName
		i = miRecentSessions->Count -1
		miRecentSessions->Item(i)->Caption = FileName
		miRecentSessions->Item(i)->Name = FileName
		miRecentSessions->Add(ML("Clear Recently Opened"),"","ClearSessions", @mClickMRU)
	End If
End Sub

Function FolderExists(ByRef FolderName As WString) As Boolean
	Return Len(Dir(FolderName, fbDirectory))
End Function

Sub OpenFiles(ByRef FileName As WString)
	If EndsWith(FileName, ".vfs") Then
		AddMRUSession FileName  '
		AddSession FileName
	ElseIf EndsWith(FileName, ".vfp") Then
		AddMRUProject FileName    '
		AddProject FileName
	ElseIf FolderExists(FileName) Then
		AddMRUFolder FileName
		AddFolder FileName
	ElseIf Trim(FileName)<>"" Then '
		AddMRUFile FileName
		AddTab FileName
	End If
	WLet LastOpenPath, GetFolderName(FileName)
	wLet RecentFiles, FileName
End Sub

Sub OpenProgram()
	Dim As OpenFileDialog OpenD
	'	If WGet(LastOpenPath) <> "" Then
	'		OpenD.InitialDir = *LastOpenPath
	'	Else
	OpenD.InitialDir = GetFullPath(*ProjectsPath)
	'   End If
	'  Add *.inc
	OpenD.Filter = ML("FreeBasic Files") & " (*.vfs,*.vfp,*.bas,*.bi,*.inc,*.rc)|*.vfs;*.vfp;*.bas;*.bi;*.inc;*.rc|" & ML("VisualFBEditor Project Group") & " (*.vfs)|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("FreeBasic Resource Files") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If OpenD.Execute Then
		OpenFiles(OpenD.Filename)
	End If
	TabLeft.Tabs[0]->SelectTab
End Sub

Function SaveSession() As Boolean
	Dim As ExplorerElement Ptr ee
	SaveD.Filter = ML("VisualFBEditor Session") & " (*.vfs)|*.vfs|"
	Dim As WString Ptr Temp, Temp2
	If WGet(LastOpenPath) <> "" Then
		SaveD.InitialDir = *LastOpenPath
	Else
		SaveD.InitialDir = GetFullPath(*ProjectsPath)
	End If
	If Not SaveD.Execute Then Return False
	WLet LastOpenPath, GetFolderName(SaveD.FileName)
	If FileExists(SaveD.Filename) Then
		Select Case MsgBox(ML("Are you sure you want to overwrite the session") & "?" & WChr(13,10) & SaveD.Filename, "Visual FB Editor", mtWarning, btYesNo)
		Case mrYES:
		Case mrNO: Return SaveSession()
		End Select
	End If
	Dim As TreeNode Ptr tn1
	Dim As Integer p
	Dim As String Zv
	Dim As Integer Fn =FreeFile
	If Open(SaveD.Filename For Output Encoding "utf-8" As #Fn) = 0 Then
		For i As Integer = 0 To tvExplorer.Nodes.Count - 1
			tn1 = tvExplorer.Nodes.Item(i)
			ee = tn1->Tag
			If ee = 0 Then Continue For
			Zv = IIf(tn1 = MainNode, "*", "")
			If StartsWith(*ee->FileName & Slash, GetFolderName(SaveD.Filename)) Then
				Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(SaveD.Filename)) + 1), "\", "/")
			Else
				Print #Fn, Zv & "File=" & *ee->FileName
			End If
		Next
		Close #Fn
	End If
	WDeallocate Temp
	WDeallocate Temp2
	Return True
End Function

Function SaveProject(ByRef tnP As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
	If tnP = 0 Then Return True
	Dim As TreeNode Ptr tn = GetParentNode(tnP)
	Dim As ExplorerElement Ptr ee
	Dim As ProjectElement Ptr ppe
	ppe = tn->Tag
	If tn->ImageKey <> "Project" AndAlso ppe = 0 Then Return True
	If CInt(ppe = 0) OrElse CInt(WGet(ppe->FileName) = "") OrElse CInt(bWithQuestion) Then
		SaveD.FileName = Left(tn->Text, Len(tn->Text) - IIf(EndsWith(tn->Text, " *"), 2, 0))
		'		If WGet(LastOpenPath) <> "" Then
		'			SaveD.InitialDir = *LastOpenPath
		'		Else
		SaveD.InitialDir = GetFullPath(*ProjectsPath)
		'		End If
		SaveD.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|"
		If Not SaveD.Execute Then Return False
		WLet LastOpenPath, GetFolderName(SaveD.FileName)
		If FileExists(SaveD.Filename) Then
			Select Case MsgBox(ML("Are you sure you want to overwrite the project") & "?" & WChr(13,10) & SaveD.Filename, "Visual FB Editor", mtWarning, btYesNo)
			Case mrYES:
			Case mrNO: Return SaveProject(tn, bWithQuestion)
			End Select
		End If
		ppe = New ProjectElement
		WLet ppe->FileName, SaveD.FileName
		AddMRUProject SaveD.FileName
	End If
	Dim As TreeNode Ptr tn1, tn2
	Dim As String Zv = "*"
	Dim As Integer Fn =FreeFile
	Open *ppe->FileName For Output Encoding "utf-8" As #Fn
	For i As Integer = 0 To tn->Nodes.Count - 1
		tn1 = tn->Nodes.Item(i)
		ee = tn1->Tag
		If ee <> 0 Then
			Zv = IIf(ppe AndAlso (*ee->FileName = *ppe->MainFileName OrElse *ee->FileName = *ppe->ResourceFileName OrElse *ee->FileName = *ppe->IconResourceFileName), "*", "")
			If StartsWith(*ee->FileName, GetFolderName(*ppe->FileName)) Then
				Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*ppe->FileName)) + 1), "\", "/")
			Else
				Print #Fn, Zv & "File=" & *ee->FileName
			End If
		ElseIf tn1->Nodes.Count > 0 Then
			For j As Integer = 0 To tn1->Nodes.Count - 1
				tn2 = tn1->Nodes.Item(j)
				ee = tn2->Tag
				If ee <> 0 Then
					Zv = IIf(ppe AndAlso (*ee->FileName = *ppe->MainFileName OrElse *ee->FileName = *ppe->ResourceFileName OrElse *ee->FileName = *ppe->IconResourceFileName), "*", "")
					If StartsWith(Replace(*ee->FileName, "\", "/"), Replace(GetFolderName(*ppe->FileName), "\", "/")) Then
						Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*ppe->FileName)) + 1), "\", "/")
					Else
						Print #Fn, Zv & "File=" & *ee->FileName
					End If
				End If
			Next
		End If
	Next
	Print #Fn, "ProjectType=" & ppe->ProjectType
	Print #Fn, "ProjectName=""" & *ppe->ProjectName & """"
	Print #Fn, "HelpFileName=""" & *ppe->HelpFileName & """"
	Print #Fn, "ProjectDescription=""" & *ppe->ProjectDescription & """"
	Print #Fn, "MajorVersion=" & ppe->MajorVersion
	Print #Fn, "MinorVersion=" & ppe->MinorVersion
	Print #Fn, "RevisionVersion=" & ppe->RevisionVersion
	Print #Fn, "BuildVersion=" & ppe->BuildVersion
	Print #Fn, "AutoIncrementVersion=" & ppe->AutoIncrementVersion
	Print #Fn, "ApplicationTitle=""" & *ppe->ApplicationTitle & """"
	Print #Fn, "ApplicationIcon=""" & *ppe->ApplicationIcon & """"
	Print #Fn, "CompanyName=""" & *ppe->CompanyName & """"
	Print #Fn, "FileDescription=""" & *ppe->FileDescription & """"
	Print #Fn, "InternalName=""" & *ppe->InternalName & """"
	Print #Fn, "LegalCopyright=""" & *ppe->LegalCopyright & """"
	Print #Fn, "LegalTrademarks=""" & *ppe->LegalTrademarks & """"
	Print #Fn, "OriginalFilename=""" & *ppe->OriginalFilename & """"
	Print #Fn, "ProductName=""" & *ppe->ProductName & """"
	Print #Fn, "CompileToGCC=" & ppe->CompileToGCC
	Print #Fn, "OptimizationLevel=" & ppe->OptimizationLevel
	Print #Fn, "OptimizationFastCode=" & ppe->OptimizationFastCode
	Print #Fn, "OptimizationSmallCode=" & ppe->OptimizationSmallCode
	Print #Fn, "CompilationArguments32Windows=""" & *ppe->CompilationArguments32Windows & """"
	Print #Fn, "CompilationArguments64Windows=""" & *ppe->CompilationArguments64Windows & """"
	Print #Fn, "CompilationArguments32Linux=""" & *ppe->CompilationArguments32Linux & """"
	Print #Fn, "CompilationArguments64Linux=""" & *ppe->CompilationArguments64Linux & """"
	Print #Fn, "CommandLineArguments=""" & *ppe->CommandLineArguments & """"
	Print #Fn, "CreateDebugInfo=" & ppe->CreateDebugInfo
	Close #Fn
	tn->Text = GetFileName(WGet(ppe->FileName))
	tn->Tag = ppe
	Return True
End Function

Sub SaveAll()
	Dim tb As TabWindow Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		tb->Save
	Next i
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			SaveProject tvExplorer.Nodes.Item(i)
		End If
	Next i
End Sub

Sub SaveAllBeforeCompile()
	If AutoSaveBeforeCompiling = 2 Then SaveAll
End Sub

Sub PrintThis()
	#ifndef __USE_GTK__
		PrintD.Execute
	#endif
End Sub

Sub PrintPreview()
	#ifndef __USE_GTK__
		PrintPreviewD.Execute
	#endif
End Sub

Sub PageSetup()
	#ifndef __USE_GTK__
		PageSetupD.Execute
	#endif
End Sub

Sub CloseAllTabs(WithoutCurrent As Boolean = False)
	Dim tb As TabWindow Ptr
	Dim j As Integer = ptabCode->TabIndex
	For i As Long = 0 To ptabCode->TabCount - 1
		If WithoutCurrent Then
			If i = j Then Continue For
		End If
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		tb->CloseTab
	Next i
End Sub

Sub RunHelp(Param As Any Ptr)
	Type HH_AKLINK
		cbStruct     As Long         ' int       cbStruct;     // sizeof this structure
		fReserved    As Boolean      ' BOOL      fReserved;    // must be FALSE (really!)
		pszKeywords  As WString Ptr  ' LPCTSTR   pszKeywords;  // semi-colon separated keywords
		pszUrl       As WString Ptr  ' LPCTSTR   pszUrl;       // URL to jump to if no keywords found (may be NULL)
		pszMsgText   As WString Ptr  ' LPCTSTR   pszMsgText;   // Message text to display in MessageBox if pszUrl is NULL and no keyword match
		pszMsgTitle  As WString Ptr  ' LPCTSTR   pszMsgTitle;  // Message text to display in MessageBox if pszUrl is NULL and no keyword match
		pszWindow    As WString Ptr  ' LPCTSTR   pszWindow;    // Window to display URL in
		fIndexOnFail As Boolean      ' BOOL      fIndexOnFail; // Displays index if keyword lookup fails.
	End Type
	#define HH_DISPLAY_TOPIC   0000
	#define HH_DISPLAY_TOC     0001
	#define HH_KEYWORD_LOOKUP  0013
	#define HH_HELP_CONTEXT    0015
	Dim As UString CurrentHelpPath
	Dim As Integer IndexDefault
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If Param <> 0 Then
		CurrentHelpPath = QWString(Param)
	Else
		IndexDefault = Helps.IndexOfKey(*DefaultHelp)
		CurrentHelpPath = *HelpPath
	End If
	If Not FileExists(CurrentHelpPath) Then
		ThreadsEnter()
		ShowMessages ML("File") & " " & CurrentHelpPath & " " & ML("not found")
		ThreadsLeave()
	Else
		#ifdef __USE_GTK__
			PipeCmd "", CurrentHelpPath
		#endif
	End If
	#ifndef __USE_GTK__
		Dim As WString * MAX_PATH wszKeyword, wszKeywordUpper
		Dim As Boolean bFind
		Dim As Any Ptr gpHelpLib
		Dim HtmlHelpW As Function (ByVal hwndCaller As HWnd, _
		ByVal pswzFile As WString Ptr, _
		ByVal uCommand As UINT, _
		ByVal dwData As DWORD_PTR _
		) As HWND
		gpHelpLib = DyLibLoad( "hhctrl.ocx" )
		HtmlHelpW = DyLibSymbol( gpHelpLib, "HtmlHelpW")
		If HtmlHelpW <> 0 Then
			If Param <> 0 OrElse tb = 0 Then
				HtmlHelpW(0, CurrentHelpPath, HH_DISPLAY_TOC, Null)
			Else
				wszKeyword = tb->txtCode.GetWordAtCursor
				If wszKeyword = "" Then
					HtmlHelpW(0, CurrentHelpPath, HH_DISPLAY_TOC, NULL)
				Else
					wszKeywordUpper = UCase(wszKeyword)
					For i As Integer = -1 To Helps.Count - 1
						If i = IndexDefault Then Continue For
						If i = -1 Then
							CurrentHelpPath = *HelpPath
						Else
							CurrentHelpPath = Helps.Item(i)->Text
						End If
						If FileExists(CurrentHelpPath) Then
							Dim li As HH_AKLINK
							For j As Integer = 1 To 2
								With li
									.cbStruct     = SizeOf(HH_AKLINK)
									.fReserved    = False
									If j = 1 Then
										.pszKeywords  = @wszKeyword
									Else
										.pszKeywords  = @wszKeywordUpper
									End If
									.pszUrl       = Null
									.pszMsgText   = Null
									.pszMsgTitle  = Null
									.pszWindow    = Null
									.fIndexOnFail = False
								End With
								If HtmlHelpW(0, CurrentHelpPath, HH_KEYWORD_LOOKUP, Cast(DWORD_PTR, @li)) <> 0 Then
									bFind = True
									Exit For, For
								End If
							Next
						End If
					Next
					If Not bFind Then MsgBox ML("Keyword") & " """ & wszKeyword & """ " & ML("not found in Help") & "!"
				End If
			End If
			'DyLibFree(gpHelpLib)
		End If
	#endif
End Sub

Sub NewProject()
	AddProject
End Sub

Function ContainsFileName(tn As TreeNode Ptr, ByRef FileName As WString) As Boolean
	Dim As ExplorerElement Ptr ee
	For i As Integer = 0 To tn->Nodes.Count - 1
		ee = tn->Nodes.Item(i)->Tag
		If ee <> 0 Then
			'
			If LCase(*ee->FileName) = LCase(Replace(FileName,"\","/")) OrElse LCase(*ee->FileName) = LCase(Replace(FileName,"/","\")) Then
				Return True
			End If
		End If
	Next
	Return False
End Function

Sub AddFileToProject
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	Dim As TreeNode Ptr ptn, tn3
	Dim As ExplorerElement Ptr ee
	ptn = GetParentNode(tvExplorer.SelectedNode)
	If ptn->ImageKey <> "Project" Then Exit Sub
	Dim OpenD As OpenFileDialog
	OpenD.Options.Include ofOldStyleDialog
	OpenD.MultiSelect = True
	OpenD.Filter = ML("FreeBasic Files") & " (*.vfp, *.bas, *.bi, *.rc)|*.vfp;*.bas;*.bi;*.rc|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("FreeBasic Resource Files") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If OpenD.Execute Then
		Dim tn1 As TreeNode Ptr
		For i As Integer = 0 To OpenD.FileNames.Count - 1
			tn1 = GetTreeNodeChild(ptn, OpenD.FileNames.Item(i))
			If ContainsFileName(tn1, OpenD.FileNames.Item(i)) Then Continue For
			Dim As WString Ptr Temp
			tn3 = tn1->Nodes.Add(GetFileName(OpenD.FileNames.Item(i)), , , "File", "File", True)
			ee = New ExplorerElement
			WLet ee->FileName, OpenD.FileNames.Item(i)
			tn3->Tag = ee
			'tn1->Expand
		Next
		If Not EndsWith(ptn->Text, " *") Then ptn->Text &= " *"
		If ptn->Nodes.Count > 0 Then
			If Not ptn->IsExpanded Then ptn->Expand
			For i As Integer = 0 To ptn->Nodes.Count - 1
				If CInt(ptn->Nodes.Item(i)->Nodes.Count > 0) Then ptn->Nodes.Item(i)->Expand
			Next
			'pfProjectProperties->RefreshProperties
		End If
	End If
End Sub

Sub RemoveFileFromProject
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	If tvExplorer.SelectedNode->Tag = 0 Then Exit Sub
	If tvExplorer.SelectedNode->ParentNode = 0 Then Exit Sub
	Dim As TreeNode Ptr ptn
	ptn = GetParentNode(tvExplorer.SelectedNode)
	If ptn->ImageKey <> "Project" Then Exit Sub
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	Dim tb As TabWindow Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		If tb->tn = tn Then
			If tb->CloseTab = False Then Exit Sub
			Exit For
		End If
	Next i
	If Not EndsWith(tn->ParentNode->Text, " *") Then tn->ParentNode->Text &= " *"
	If tn->ParentNode->Nodes.IndexOf(tn) <> -1 Then tn->ParentNode->Nodes.Remove tn->ParentNode->Nodes.IndexOf(tn)
	'pfProjectProperties->RefreshProperties
End Sub

Sub OpenProjectFolder
	Dim As TreeNode Ptr ptn = tvExplorer.SelectedNode
	If ptn = 0 Then Exit Sub
	ptn = GetParentNode(ptn)
	Dim As ExplorerElement Ptr ee = ptn->Tag
	If ee = 0 Then Exit Sub
	If WGet(ee->FileName) <> "" Then
		#ifdef __USE_GTK__
			Shell "xdg-open """ & GetFolderName(*ee->FileName) & """"
		#else
			Shell "explorer """ & Replace(GetFolderName(*ee->FileName), "/", "\") & """"
		#endif
	End If
End Sub

Sub SetMainNode(tn As TreeNode Ptr)
	MainNode = tn
	If tn = 0 Then
		lblLeft.Text = ML("Main File") & ": " & ML("Automatic")
	Else
		lblLeft.Text = ML("Main File") & ": " & MainNode->Text
	End If
End Sub

Sub SetAsMain()
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
	If CInt(pTabCode->Focused) AndAlso CInt(pTabCode->SelectedTab <> 0) Then tn = Cast(TabWindow Ptr, pTabCode->SelectedTab)->tn
	If tn = 0 Then Exit Sub
	If tn->ParentNode = 0 OrElse (tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement) Then
		SetMainNode tn
		lblLeft.Text = ML("Main File") & ": " & MainNode->Text
	Else
		Dim As ExplorerElement Ptr ee = tn->Tag
		Dim As TreeNode Ptr ptn = GetParentNode(tn)
		Dim As ProjectElement Ptr ppe
		Dim As WString * MAX_PATH tMainNode
		If ptn <> 0 Then
			ppe = ptn->Tag
			If ppe = 0 Then
				ppe = New ProjectElement
				WLet ppe->FileName, ""
			End If
			If ee <> 0 AndAlso ppe <> 0 Then
				'David Change
				'If *ee->FileName = *pee->Project->MainFileName OrElse *ee->FileName = *pee->Project->ResourceFileName Then Exit Sub
				If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".bas") Then
					Dim tn1 As TreeNode Ptr = tn->ParentNode
					Dim As Integer tIndex
					Dim As String IconName
					If Not EndsWith(ptn->Text, " *") Then ptn->Text &= " *"
					If Not EndsWith(LCase(*ee->FileName), ".rc") Then
						WLet ppe->MainFileName, *ee->FileName
						IconName = "MainFile"
					Else
						WLet ppe->ResourceFileName, *ee->FileName
						IconName = "MainRes"
					End If
					MainNode = ptn 'MainNode must be root node
					tMainNode = *ee->FileName
					For j As Integer = tn1->Nodes.Count - 1 To 0 Step -1
						ee = New ExplorerElement
						ee = tn1->Nodes.Item(j)->Tag
						tIndex = tn1->Nodes.Item(j)->Index
						If IconName = tn1->Nodes.Item(j)->ImageKey Then
							If *ee->FileName <> *ppe->MainFileName Then
								tn1->Nodes.Remove(tIndex)
								tn = tn1->Nodes.Add(GetFileName(*ee->FileName),, *ee->FileName, Mid(IconName,5), Mid(IconName,5), True)
								tn->Tag = ee
							End If
						ElseIf *ee->FileName = tMainNode Then ' *.rc you can set As MainMenu in RC node also
							tn1->Nodes.Remove(tIndex)
							tn = tn1->Nodes.Add(GetFileName(*ee->FileName),, *ee->FileName, IconName, IconName, True)
							tn->Tag = ee
						End If
					Next
					If tn1->Nodes.Count=1 Then 'Only one file
						tn1->Nodes.Remove(0)
						tn = tn1->Nodes.Add(GetFileName(*ee->FileName),, *ee->FileName, IconName, IconName, True)
						tn->Tag = ee
					End If
				End If
			End If
		End If
		'SaveProject ptn
	End If
End Sub

Sub Save()
	If tvExplorer.Focused Then
		If tvExplorer.SelectedNode = 0 Then Exit Sub
		If tvExplorer.SelectedNode->ImageKey = "Project" Then
			SaveProject tvExplorer.SelectedNode
		Else
			Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
			Dim tb As TabWindow Ptr
			If tn = 0 Then Exit Sub
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				If tb->tn = tn Then
					tb->Save
					Exit For
				End If
			Next i
		End If
	Else
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		tb->Save
	End If
End Sub

Function CloseProject(tn As TreeNode Ptr) As Boolean
	If tn = 0 Then Return True
	If tn->ImageKey <> "Project" Then Return True
	Dim tb As TabWindow Ptr
	For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
		If tn->Nodes.Item(j)->Nodes.Count = 0 Then
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If tn->Nodes.Item(j)->Text = tb->tn->Text Then
					If CInt(tb) AndAlso CInt(Not tb->CloseTab) Then Return False
					Exit For
				End If
			Next i
		Else
			For k As Integer = tn->Nodes.Item(j)->Nodes.Count - 1 To 0 Step - 1 '
				For i As Integer = 0 To ptabCode->TabCount - 1
					tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
					If tn->Nodes.Item(j)->Nodes.Item(k)->Text = tb->tn->Text Then '
						If CInt(tb) AndAlso CInt(Not tb->CloseTab) Then Return False
						Exit For
					End If
				Next i
			Next k
		End If
	Next
	If EndsWith(tn->Text, " *") Then
		Select Case MsgBox(ML("Want to save the project") & " """ & tn->Text & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
		Case mrYES: If Not SaveProject(tn) Then Return False
		Case mrNO:
		Case mrCANCEL: Return False
		End Select
	End If
	If tn = MainNode Then SetMainNode 0
	If tvExplorer.Nodes.IndexOf(tn) <> -1 Then tvExplorer.Nodes.Remove tvExplorer.Nodes.IndexOf(tn)
	Return True
End Function

Sub NextBookmark(iTo As Integer = 1)
	If ptabCode->SelectedTab = 0 Then Exit Sub
	Dim As Integer i, j, k, n, iStart, iEnd, iStartLine, iEndLine
	Dim As EditControl Ptr txt
	Dim As EditControlLine Ptr FECLine
	Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
	Dim As Integer CurTabIndex = ptabCode->SelectedTab->Index
	If iTo = 1 Then
		iStart = 0
		iEnd = ptabCode->TabCount - 1
	Else
		iStart = ptabCode->TabCount - 1
		iEnd = 0
	End If
	For k = 1 To 2
		For j = IIf(k = 1, CurTabIndex, iStart) To IIf(k = 1, iEnd, CurTabIndex) Step iTo
			txt = @Cast(TabWindow Ptr, ptabCode->Tabs[j])->txtCode
			If iTo = 1 Then
				iStartLine = 0
				iEndLine = txt->FLines.Count - 1
			Else
				iStartLine = txt->FLines.Count - 1
				iEndLine = 0
			End If
			If k = 1 AndAlso j = CurTabIndex Then
				txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				n = iSelEndLine + iTo
			Else
				n = iStartLine
			End If
			For i = n To iEndLine Step iTo
				FECLine = txt->FLines.Items[i]
				If FECLine->Bookmark Then
					ptabCode->Tabs[j]->SelectTab
					txt->SetSelection i, i, 0, 0
					Exit Sub
				End If
			Next
		Next j
	Next k
End Sub

Sub ClearAllBookmarks
	For i As Integer = 0 To ptabCode->TabCount -1
		Cast(TabWindow Ptr, ptabCode->Tabs[i])->txtCode.ClearAllBookmarks
	Next
End Sub

Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
	UseDebugger = bUseDebugger
	If ChangeObject <> 0 Then tbStandard.Buttons.Item("TBUseDebugger")->Checked = bUseDebugger
	If ChangeObject <> 1 AndAlso mnuUseDebugger->Checked <> UseDebugger Then mnuUseDebugger->Checked = bUseDebugger
End Sub

Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
	ThreadsEnter()
	tbStandard.Buttons.Item("StartWithCompile")->Enabled = bStart
	tbStandard.Buttons.Item("Start")->Enabled = bStart
	tbStandard.Buttons.Item("Break")->Enabled = bBreak
	tbStandard.Buttons.Item("End")->Enabled = bEnd
	mnuStartWithCompile->Enabled = bStart
	mnuStart->Enabled = bStart
	mnuBreak->Enabled = bBreak
	mnuEnd->Enabled = bEnd
	ThreadsLeave()
End Sub

#ifndef __USE_GTK__
	Sub TimerProc(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
		If FnTab < 0 Or Fcurlig < 1 Then Exit Sub
		If source(Fntab) = "" Then Exit Sub
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tabCode.SelectedTab)
		If tb = 0 OrElse Not EqualPaths(tb->FileName, source(Fntab)) Then
			tb = AddTab(LCase(source(Fntab)))
		End If
		If tb = 0 Then Exit Sub
		ChangeEnabledDebug True, False, True
		tb->txtCode.CurExecutedLine = Fcurlig - 1
		tb->txtCode.SetSelection Fcurlig - 1, Fcurlig - 1, 0, 0
		tb->txtCode.PaintControl
		CurEC = @tb->txtCode
		SetForegroundWindow frmMain.Handle
		FnTab = 0
		Fcurlig = -1
	End Sub
#endif

Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
	Dim FileNameLeft As WString Ptr
	Dim FileNameRight As WString Ptr
	WLet FileNameLeft, Replace(a, "\", "/"), True
	If EndsWith(*FileNameLeft, ":") Then *FileNameLeft = Left(*FileNameLeft, Len(*FileNameLeft) - 1)
	WLet FileNameRight, Replace(b, "\", "/"), True
	EqualPaths = LCase(*FileNameLeft) = LCase(*FileNameRight)
	WDeallocate FileNameLeft
	WDeallocate FileNameRight
End Function

Sub ChangeTabsTn(TnPrev As TreeNode Ptr, Tn As TreeNode Ptr)
	Dim tb As TabWindow Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
		If tb->tn = TnPrev Then
			tb->tn = Tn
			If ptabCode->SelectedTab = ptabCode->Tabs[i] Then Tn->SelectItem
			Exit For
		End If
	Next
End Sub

Sub WithFolder
	Dim As TreeNode Ptr tn, tnF, tnI, tnS, tnR, tnO
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			tn = tvExplorer.Nodes.Item(i)
			If tbExplorer.Buttons.Item(3)->Checked Then
				tnI = tn->Nodes.Add(ML("Includes"), "Includes", , "Opened", "Opened")
				tnF = tn->Nodes.Add(ML("Forms"), "Forms", , "Opened", "Opened")
				tnS = tn->Nodes.Add(ML("Modules"), "Modules",, "Opened", "Opened") ' "Modules" is better than "Sources"
				tnR = tn->Nodes.Add(ML("Resources"), "Resources", , "Opened", "Opened")
				tnO = tn->Nodes.Add(ML("Others"), "Others", , "Opened", "Opened")
			End If
			Dim As TreeNode Ptr tn1, tn2
			For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
				If tbExplorer.Buttons.Item(3)->Checked Then
					If tn->Nodes.Item(j)->Tag <> 0 Then
						If EndsWith(LCase(tn->Nodes.Item(j)->Text), ".bi") Then '
							tn1 = tnI
						ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".bas") Then  '
							tn1 = tnS
						ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".frm") Then  '
							tn1 = tnF
						ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".rc") Then '
							tn1 = tnR
						Else
							tn1 = tnO
						End If
						tn2 = tn1->Nodes.Add(tn->Nodes.Item(j)->Text, , , tn->Nodes.Item(j)->ImageKey, tn->Nodes.Item(j)->ImageKey, True)
						tn2->Tag = tn->Nodes.Item(j)->Tag
						ChangeTabsTn tn->Nodes.Item(j), tn2
						'                        If tn->Expanded Then
						'
						'                        End If
						tn1->Expand
						tn->Nodes.Remove j
					End If
				Else
					For k As Integer = 0 To tn->Nodes.Item(j)->Nodes.Count - 1
						tn2 = tn->Nodes.Add(tn->Nodes.Item(j)->Nodes.Item(k)->Text, , , tn->Nodes.Item(j)->Nodes.Item(k)->ImageKey, tn->Nodes.Item(j)->Nodes.Item(k)->ImageKey)
						'?k, tn->Text, tn->Nodes.Item(j)->Text, tn->Nodes.Item(j)->Nodes.Item(k)->Text
						tn2->Tag = tn->Nodes.Item(j)->Nodes.Item(k)->Tag
						ChangeTabsTn tn->Nodes.Item(j)->Nodes.Item(k), tn2
					Next k
					tn->Nodes.Remove j
				End If
			Next
		End If
	Next
End Sub

Sub CompileProgram(Param As Any Ptr)
	'If Compile Then RunProgram(0) ', Run Program after compiled with FBC.exe only here.
	Compile
End Sub

Sub CompileAndRun(Param As Any Ptr)
	If Compile("Run") Then RunProgram(0)
End Sub

Sub MakeExecute(Param As Any Ptr)
	Compile("Make")
End Sub

Sub MakeClean(Param As Any Ptr)
	Compile("MakeClean")
End Sub

Sub SyntaxCheck(Param As Any Ptr)
	Compile("Check")
End Sub

Sub ToolBoxClick(ByRef Sender As My.Sys.Object)
	With *Cast(ToolButton Ptr, @Sender)
		If .Style = tbsCheck Then
			Var flag = .Checked
			tbToolBox.UpdateLock
			'For i As Integer = tbToolBox.Buttons.IndexOf(Cast(ToolButton Ptr, @Sender)) + 2 To tbToolBox.Buttons.Count - 1
			'   If tbToolBox.Buttons.Item(i)->Style = tbsCheck Then
			'       Exit For
			'   End If
			'   tbToolBox.Buttons.Item(i)->Visible = Flag
			'Next
			Var c = 0
			'For i As Integer = 0 To tbToolBox.Buttons.Count - 1
			'    If tbToolBox.Buttons.Item(i)->Visible Then c = c + 1
			'Next
			scrTool.MaxValue = c
			tbToolBox.UpdateUnLock
		ElseIf .Name = "Cursor" Then
			SelectedClass = ""
			SelectedTool = 0
			SelectedType = 0
		Else
			'If .Checked Then
			SelectedClass = Sender.ToString
			SelectedTool = Cast(ToolButton Ptr, @Sender)
			SelectedType = Cast(TypeElement Ptr, SelectedTool->Tag)->ControlType
			'End If
		End If
	End With
End Sub

Function GetTypeControl(ControlType As String) As Integer
	If Comps.Contains(ControlType) Then
		Var tbi = Cast(TypeElement Ptr, Comps.Object(Comps.IndexOf(ControlType))) 'Breakpoint
		Select Case LCase(tbi->TypeName)
		Case "control": Return 1
		Case "containercontrol": Return 2
		Case "component": Return 3
		Case "dialog": Return 4
		Case "": Return 0
		Case Else
			If ControlType = tbi->TypeName Then Return 0 Else Return GetTypeControl(tbi->TypeName)
		End Select
	Else
		Return 0
	End If
End Function

Dim Shared tpShakl As TabPage Ptr

Sub tpShakl_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		tbToolBox.SetBounds 0, tbForm.Height, NewWidth, NewHeight
	#else
		tbToolBox.SetBounds 0, tbForm.Height, NewWidth - IIf(scrTool.Visible, scrTool.Width, 0), NewHeight
		scrTool.MaxValue = Max(0, tbToolBox.Height - (NewHeight - tbForm.Height))
		scrTool.Visible = scrTool.MaxValue <> 0
	#endif
End Sub

Sub tbToolBox_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
	scrTool.Position = Min(scrTool.MaxValue, Max(scrTool.MinValue, scrTool.Position + -Direction * scrTool.ArrowChangeSize))
End Sub

Sub scrTool_MouseWheel(ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
	scrTool.Position = Min(scrTool.MaxValue, Max(scrTool.MinValue, scrTool.Position + -Direction * scrTool.ArrowChangeSize))
End Sub

Function DirExists(ByRef DirPath As WString) As Integer
	Const InAttr = fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive
	Dim AttrTester As Integer, DirString As String
	DirString = Dir (DirPath, InAttr, AttrTester)
	If (AttrTester And fbDirectory) Then
		Return (-1)
	End If
	Return (0)
End Function

Function GetOSPath(ByRef Path As WString) As UString
	Return Replace(Path, BackSlash, Slash)
End Function

Function GetRelativePath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
	If CInt(InStr(Path, ":") > 0) OrElse CInt(StartsWith(Path, "/")) OrElse CInt(StartsWith(Path, "\")) Then
		Return GetOSPath(Path)
	ElseIf StartsWith(Path, "./") OrElse StartsWith(Path, ".\") Then
		Return GetOSPath(GetFolderName(FromFile) & Mid(Path, 3))
	ElseIf StartsWith(Path, "../") OrElse StartsWith(Path, "..\") Then
		Return GetOSPath(GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4))
	End If
	Dim Result As UString = GetOSPath(GetFolderName(FromFile) & Path)
	If FileExists(Result) Then
		Return Result
	Else
		Result = GetOSPath(GetFullPath(*MFFPath) & Slash & Path)
		If FileExists(Result) Then
			Return Result
		Else
			#ifdef __USE_GTK__
				Result = GetOSPath(GetFolderName(GetFolderName(GetFullPath(*Compiler32Path))) & "include/freebasic/" & Path)
			#else
				Result = GetOSPath(GetFolderName(GetFullPath(*Compiler32Path)) & "inc\" & Path)
			#endif
			If FileExists(Result) Then
				Return Result
			Else
				#ifdef __USE_GTK__
					Result = GetOSPath(GetFolderName(GetFolderName(GetFullPath(*Compiler64Path))) & "include/freebasic/" & Path)
				#else
					Result = GetOSPath(GetFolderName(GetFullPath(*Compiler64Path)) & "inc\" & Path)
				#endif
				If FileExists(Result) Then
					Return Result
				Else
					Return GetOSPath(Path)
				End If
			End If
		End If
	End If
End Function

Function WithoutPointers(ByRef e As String) As String
	If EndsWith(LCase(e), " ptr") Then
		Return WithoutPointers(Trim(Left(e, Len(e) - 4)))
	ElseIf EndsWith(LCase(e), " pointer") Then
		Return WithoutPointers(Trim(Left(e, Len(e) - 8)))
	Else
		Return e
	End If
End Function

Sub LoadFunctions(ByRef Path As WString, LoadParameter As LoadParam = FilePathAndIncludeFiles, ByRef Types As WStringList, ByRef Enums As WStringList, ByRef Functions As WStringList, ByRef Args As WStringList, ec As Control Ptr = 0)
	If FormClosing Then Exit Sub
	MutexLock tlockSave
	If LoadParameter <> LoadParam.OnlyIncludeFiles AndAlso LoadParameter <> LoadParam.OnlyFilePathOverwrite Then
		If ec = 0 Then
			If IncludeFiles.Contains(Path) Then
				MutexUnlock tlockSave
				Exit Sub
			Else
				IncludeFiles.Add Path
			End If
		End If
		If @Types = @Comps Then
			pfSplash->lblProcess.Text = Path
			#ifdef __USE_GTK__
				pApp->DoEvents
			#endif
		End If
	End If
	'	#ifdef __US_GTK__
	'		Exit Sub
	'	#endif
	Dim As UString b1, Comment, PathFunction, LoadFunctionPath
	Dim As String t, e, tOrig, bt
	Dim As Integer Pos1, Pos2, Pos3, Pos4, Pos5, l, n, nc, Index
	Dim As TypeElement Ptr te, tbi, typ
	Dim As Boolean inType, inUnion, inEnum, InFunc, InNamespace
	Dim As Boolean bTypeIsPointer
	Dim As Integer inPubPriPro = 0
	Dim As Integer Result
	Dim As WString * 2048 bTrim, bTrimLCase
	Dim b As WString * 2048 ' for V1.07 Line Input not working fine
	Dim As WStringList Lines, Files, Namespaces
	PathFunction = Path
	If ec <> 0 Then
		With *Cast(EditControl Ptr, ec)
			For i As Integer = 0 To .LinesCount - 1
				Lines.Add .Lines(i)
			Next
		End With
	Else
		Dim As Integer ff = FreeFile
		Result = Open(PathFunction For Input Encoding "utf-32" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input Encoding "utf-16" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input Encoding "utf-8" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input As #ff)
		If Result = 0 Then
			inType = False
			Do Until EOF(ff)
				Line Input #ff, b
				Lines.Add b
			Loop
			Close #ff
		End If
	End If
	For i As Integer = 0 To Lines.Count - 1
		b1 = Replace(Lines.Item(i), !"\t", " ")
		If StartsWith(Trim(b1), "'") Then
			Comment &= Mid(Trim(b1), 2) & Chr(13) & Chr(10)
			Continue For
		ElseIf Trim(b1) = "" Then
			Comment = ""
			Continue For
		End If
		Dim As UString res(Any)
		Split(b1, """", res())
		b = ""
		For j As Integer = 0 To UBound(res)
			If j = 0 Then
				b = res(0)
			ElseIf j Mod 2 = 0 Then
				b &= """" & res(j)
			Else
				b &= """" & WSpace(Len(res(j)))
			End If
		Next
		Split(b, ":", res())
		Dim k As Integer = 1
		For j As Integer = 0 To UBound(res)
			l = Len(res(j))
			b = Mid(b1, k, l)
			bTrim = Trim(b)
			bTrimLCase = LCase(bTrim)
			k = k + Len(res(j)) + 1
			If CInt(LoadParameter <> LoadParam.OnlyFilePath) AndAlso CInt(LoadParameter <> LoadParam.OnlyFilePathOverwrite) AndAlso CInt(StartsWith(LTrim(LCase(b)), "#include ")) Then
				Pos1 = InStr(b, """")
				If Pos1 > 0 Then
					Pos2 = InStr(Pos1 + 1, b, """")
					LoadFunctionPath = GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), PathFunction)
					Files.Add LoadFunctionPath
				End If
			ElseIf LoadParameter <> LoadParam.OnlyIncludeFiles Then
				Pos3 = InStr(bTrimLCase, " as ")
				If CInt(StartsWith(bTrimLCase, "type ")) AndAlso CInt(IIf(InType, Pos3 = 0, True)) Then
					Pos1 = InStr(" " & bTrimLCase, " type ")
					If Pos1 > 0 Then
						Pos2 = InStr(bTrimLCase, " extends ")
						If Pos2 > 0 Then
							t = Trim(Mid(bTrim, Pos1 + 5, Pos2 - Pos1 - 5))
							e = Trim(Mid(bTrim, Pos2 + 9))
						ElseIf Pos3 > 0 Then
							t = Trim(Mid(bTrim, Pos1 + 5, Pos3 - Pos1 - 5))
							e = Trim(Mid(bTrim, Pos3 + 4))
						Else
							Pos2 = InStr(Pos1 + 5, bTrim, " ")
							If Pos2 > 0 Then
								t = Trim(Mid(bTrim, Pos1 + 5, Pos2 - Pos1 - 5))
							Else
								t = Trim(Mid(bTrim, Pos1 + 5))
							End If
							e = ""
						End If
						Pos4 = InStr(e, "'")
						If Pos4 > 0 Then
							e = Trim(Left(e, Pos4 - 1))
						End If
						bTypeIsPointer = EndsWith(LCase(e), " ptr") OrElse EndsWith(LCase(e), " pointer")
						e = WithoutPointers(e)
						If Not Comps.Contains(t) Then
							tOrig = t
							If t = "Object" And e = "Object" Then
								t = "My.Sys.Object"
								e = ""
							End If
							inType = Pos3 = 0
							inPubPriPro = 0
							tbi = New TypeElement
							tbi->Name = t
							tbi->DisplayName = t & " [Type]"
							tbi->TypeIsPointer = bTypeIsPointer
							tbi->TypeName = e
							tbi->ElementType = IIf(Pos3 > 0, "TypeCopy", "Type")
							tbi->StartLine = i
							tbi->FileName = PathFunction
							tbi->IncludeFile = "mff/" & GetFileName(PathFunction)
							tbi->Parameters = Trim(Mid(bTrim, 6))
							Types.Add t, tbi
							typ = tbi
							If Namespaces.Count > 0 Then
								Index = GlobalNamespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								Cast(TypeElement Ptr, GlobalNamespaces.Object(Index))->Elements.Add tOrig, tbi
							End If
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "end type ") Then
					inType = False
				ElseIf CInt(StartsWith(bTrimLCase, "union ")) Then
					InUnion = True
					t = Trim(Mid(bTrim, 7))
					Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					'If Not Types.Contains(t) Then
					tbi = New TypeElement
					tbi->Name = t
					tbi->DisplayName = t & " [Union]"
					tbi->TypeName = ""
					tbi->ElementType = "Union"
					tbi->StartLine = i
					tbi->FileName = PathFunction
					Types.Add t, tbi
					typ = tbi
					If Namespaces.Count > 0 Then
						Index = GlobalNamespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
						Cast(TypeElement Ptr, GlobalNamespaces.Object(Index))->Elements.Add tbi->Name, tbi
					End If
					'End If
				ElseIf CInt(StartsWith(bTrimLCase, "end union")) Then
					InUnion = False
				ElseIf StartsWith(bTrimLCase & " ", "#define ") Then
					Pos1 = InStr(9, bTrim, " ")
					Pos2 = InStr(9, bTrim, "(")
					Pos3 = InStr(9, bTrim, ")")
					If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
					te = New TypeElement
					If Pos1 = 0 Then
						te->Name = Trim(Mid(bTrim, 9))
					Else
						te->Name = Trim(Mid(bTrim, 9, Pos1 - 9))
					End If
					te->DisplayName = te->Name
					te->ElementType = "#Define"
					te->Parameters = Trim(Mid(bTrim, 9))
					Pos4 = InStr(te->Parameters, "'")
					If Pos4 > 0 Then
						te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
					End If
					If Pos2 > 0 AndAlso Pos3 > 0 OrElse Pos1 > 0 Then
						te->Value = Trim(Mid(bTrim, IIf(Pos2 > 0, Pos3 + 1, Pos1 + 1)))
					End If
					te->StartLine = i
					te->EndLine = i
					If Comment <> "" Then te->Comment= Comment: Comment = ""
					te->FileName = PathFunction
					Functions.Add te->Name, te
				ElseIf StartsWith(bTrimLCase & " ", "namespace ") AndAlso Pos3 = 0 Then
					InNamespace = True
					Pos1 = InStr(11, bTrim, " ")
					Dim As String Names
					Dim As UString res1(Any)
					If Pos1 = 0 Then
						Names = Trim(Mid(bTrim, 11))
					Else
						Names = Trim(Mid(bTrim, 11, Pos1 - 11))
					End If
					Split(Names, ".", res1())
					nc = UBound(res1)
					For n As Integer = 0 To nc
						te = New TypeElement
						te->Name = Trim(res1(n))
						te->DisplayName = te->Name
						te->ElementType = "Namespace"
						te->Parameters = bTrim
						Pos4 = InStr(te->Parameters, "'")
						If Pos4 > 0 Then
							te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
						End If
						te->StartLine = i
						te->EndLine = i
						te->ControlType = nc
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						GlobalNamespaces.Add te->Name, te
						If Namespaces.Count > 0 Then
							Index = GlobalNamespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							Cast(TypeElement Ptr, GlobalNamespaces.Object(Index))->Elements.Add te->Name, te
						End If
						Namespaces.Add te->Name, te
					Next
				ElseIf StartsWith(bTrimLCase & " ", "end namespace ") Then
					InNamespace = False
					If Namespaces.Count > 0 Then
						nc = Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->ControlType
						For i As Integer = 1 To nc
							If Namespaces.Count > 0 Then Namespaces.Remove Namespaces.Count - 1
						Next i
					End If
				ElseIf StartsWith(bTrimLCase & " ", "declare ") Then
					Pos1 = InStr(9, bTrim, " ")
					Pos3 = InStr(9, bTrim, "(")
					If StartsWith(Trim(Mid(bTrimLCase, 9)), "static ") Then
						Pos1 = InStr(Pos1 + 1, bTrim, " ")
					End If
					Pos4 = InStr(Pos1 + 1, bTrim, " ")
					If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
					Pos4 = InStr(bTrim, "(")
					If Pos4 > 0 AndAlso (Pos4 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos4
					te = New TypeElement
					te->Declaration = True
					If Pos1 = 0 Then
						te->ElementType = Trim(Mid(bTrim, 9))
					Else
						te->ElementType = Trim(Mid(bTrim, 9, Pos1 - 9))
					End If
					If inType AndAlso typ <> 0 AndAlso (LCase(te->ElementType) = "constructor" OrElse LCase(te->ElementType) = "destructor") Then
						te->Name = typ->Name
						te->DisplayName = typ->Name & " [" & te->ElementType & "] [Declare]"
						te->TypeName = typ->Name
						te->Parameters = typ->Name & IIf(POs4 > 0, Mid(bTrim, Pos4), "()")
					Else
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos1))
						Else
							te->Name = Trim(Mid(bTrim, Pos1, Pos3 - Pos1))
						End If
						If LCase(te->ElementType) = "property" Then
							If EndsWith(bTrim, ")") Then
								te->DisplayName = te->Name & " [Let] [Declare]"
							Else
								te->DisplayName = te->Name & " [Get] [Declare]"
							End If
						Else
							te->DisplayName = te->Name & " [Declare]"
						End If
						te->Parameters = Trim(Mid(bTrim, Pos1))
						If inType AndAlso typ <> 0 Then te->DisplayName = typ->Name & "." & te->DisplayName
						Pos2 = InStr(bTrim, ")")
						Pos3 = InStr(Pos2, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos2 + 1, bTrimLCase, " as ")
						If Pos3 = 0 Then
							te->TypeName = ""
						Else
							te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						End If
						Pos4 = InStr(te->TypeName, "'")
						If Pos4 > 0 Then
							Pos5 = InStr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
							If Pos5 > 0 Then
								te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
							Else
								te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
							End If
							te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
						End If
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
					End If
					If inType Then
						te->Locals = inPubPriPro
					End If
					Pos4 = InStr(te->Parameters, "'")
					If Pos4 > 0 Then
						te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
					End If
					te->StartLine = i
					te->EndLine = i
					If Comment <> "" Then te->Comment = Comment: Comment = ""
					te->FileName = PathFunction
					If inType AndAlso typ <> 0 AndAlso LCase(te->ElementType) <> "constructor" AndAlso LCase(te->ElementType) <> "destructor" Then
						typ->Elements.Add te->Name, te
					Else
						Functions.Add te->Name, te
					End If
				ElseIf inType OrElse inUnion Then
					If StartsWith(bTrimLCase & " ", "public: ") Then
						inPubPriPro = 0
						Comment = ""
					ElseIf StartsWith(bTrimLCase & " ", "private: ") Then
						inPubPriPro = 1
						Comment = ""
					ElseIf StartsWith(bTrimLCase & " ", "protected: ") Then
						inPubPriPro = 2
						Comment = ""
					ElseIf CInt(StartsWith(bTrimLCase, "as ")) OrElse _
						InStr(bTrimLCase, " as ") Then
						Dim As UString b2 = bTrim
						Dim As UString CurType, ElementValue
						Dim As UString res1(Any)
						If b2.ToLower.StartsWith("dim ") Then
							b2 = Trim(Mid(b2, 4))
						ElseIf b2.ToLower.StartsWith("static ") Then
							b2 = Trim(Mid(b2, 7))
						End If
						Pos1 = InStr(b2, "=>")
						If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
						If b2.ToLower.StartsWith("as ") Then
							If b2.ToLower.StartsWith("as ") Then CurType = Trim(Mid(b2, 4)) Else CurType = Trim(b2)
							Pos1 = InStr(CurType, " ")
							Pos2 = InStr(CurType, " Ptr ")
							Pos3 = InStr(CurType, " Pointer ")
							If Pos2 > 0 Then
								Pos1 = Pos2 + 4
							ElseIf Pos3 > 0 Then
								Pos1 = Pos2 + 8
							End If
							If Pos1 > 0 Then
								Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
								CurType = Left(CurType, Pos1 - 1)
							End If
						Else
							Split GetChangedCommas(b2), ",", res1()
						End If
						For n As Integer = 0 To UBound(res1)
							res1(n) = Replace(res1(n), ";", ",")
							ElementValue = ""
							If InStr(b2.ToLower, " sub(") = 0 Then
								Pos1 = InStr(res1(n), "=")
								If Pos1 > 0 Then
									ElementValue = Trim(Mid(res1(n), Pos1 + 1))
								End If
								If Pos1 > 0 Then res1(n) = Trim(Left(res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(res1(n)), " as ")
							If Pos1 > 0 Then
								CurType = Trim(Mid(res1(n), Pos1 + 4))
								res1(n) = Left(res1(n), Pos1 - 1)
							End If
							res1(n) = res1(n).TrimAll
							If Not CurType.ToLower.StartsWith("sub") Then
								Pos1 = InStrRev(CurType, ".")
								If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							End If
							Var te = New TypeElement
							te->Name = res1(n)
							te->DisplayName = te->Name
							te->TypeName = CurType
							Pos4 = InStr(te->TypeName, "'")
							If Pos4 > 0 Then
								Pos5 = InStr(Trim(Mid(te->TypeName, Pos4 + 1)), " ")
								If Pos5 > 0 Then
									te->EnumTypeName = Left(Trim(Mid(te->TypeName, Pos4 + 1)), Pos5 - 1)
								Else
									te->EnumTypeName = Trim(Mid(te->TypeName, Pos4 + 1))
								End If
								te->TypeName = Trim(Left(te->TypeName, Pos4 - 1))
							End If
							te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
							te->TypeName = WithoutPointers(te->TypeName)
							te->Value = ElementValue
							te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
							te->Locals = inPubPriPro
							te->StartLine = i
							te->Parameters = res1(n) & " As " & CurType
							te->FileName = PathFunction
							If Comment <> "" Then te->Comment = Comment: Comment = ""
							If tbi Then tbi->Elements.Add te->Name, te
						Next
					End If
				ElseIf CInt(StartsWith(Trim(LCase(b)), "enum ")) Then
					InEnum = True
					t = Trim(Mid(bTrim, 6))
					Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					If Not Comps.Contains(t) Then
						tbi = New TypeElement
						tbi->Name = t
						tbi->DisplayName = t & " [Enum]"
						tbi->TypeName = ""
						tbi->ElementType = "Enum"
						tbi->StartLine = i
						tbi->FileName = PathFunction
						Enums.Add t, tbi
						If Namespaces.Count > 0 Then
							Index = GlobalNamespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							Cast(TypeElement Ptr, GlobalNamespaces.Object(Index))->Elements.Add tbi->Name, tbi
						End If
					End If
				ElseIf CInt(StartsWith(bTrimLCase, "end enum")) Then
					InEnum = False
				ElseIf inEnum Then
					If StartsWith(bTrim, "#") OrElse StartsWith(bTrim, "'") Then Continue For
					Dim As UString b2 = b, res1(), ElementValue
					Pos2 = InStr(b2, "'")
					If Pos2 > 0 Then b2 = Trim(Left(b2, Pos2 - 1))
					Split b2, ",", res1()
					For i As Integer = 0 To UBound(res1)
						Pos3 = InStr(res1(i), "=")
						If Pos3 > 0 Then
							ElementValue = Trim(Mid(res1(i), Pos3 + 1))
						Else
							ElementValue = ""
						End If
						If Pos3 > 0 Then
							t = Trim(Left(res1(i), Pos3 - 1))
						Else
							t = Trim(res1(i))
						End If
						Var te = New TypeElement
						te->Name = t
						te->DisplayName = te->Name
						te->ElementType = "Enum"
						te->Value = ElementValue
						te->StartLine = i
						te->Parameters = Trim(res1(i))
						te->FileName = PathFunction
						If tbi Then tbi->Elements.Add te->Name, te
					Next i
				Else 'If LoadParameter <> LoadParam.OnlyTypes Then
					If CInt(StartsWith(bTrimLCase & " ", "end sub ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end function ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end property ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end operator ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end destructor ")) Then
						inFunc = False
					ElseIf CInt(StartsWith(bTrimLCase, "operator ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private operator ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public operator ")) Then
						inFunc = True
					ElseIf CInt(StartsWith(bTrimLCase, "constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public constructor ")) Then
						inFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " constructor ") + 12
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = New TypeElement
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name & " [Constructor]"
						te->TypeName = te->Name
						te->ElementType = "Constructor"
						te->Locals = IIf(StartsWith(bTrimLCase, "private "), 1, 0)
						te->StartLine = i
						te->Parameters = te->Name & IIf(Pos3 > 0, Mid(bTrim, Pos3), "()")
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						Functions.Add te->Name, te
					ElseIf CInt(StartsWith(bTrimLCase, "destructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private destructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public destructor ")) Then
						inFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " destructor ") + 11
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5), Any !"\t "))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = New TypeElement
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name & " [Destructor]"
						te->TypeName = te->Name
						te->ElementType = "Destructor"
						te->Locals = IIf(StartsWith(bTrimLCase, "private "), 1, 0)
						te->StartLine = i
						te->Parameters = te->Name & IIf(Pos3 > 0, Mid(bTrim, Pos3), "()")
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						Functions.Add te->Name, te
					ElseIf CInt(StartsWith(bTrimLCase, "sub ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private sub ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public sub ")) Then
						inFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " sub ") + 4
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = New TypeElement
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then
							bt = Left(te->Name, Pos1 - 1)
							te->Name = Mid(te->Name, Pos1 + 1)
						Else
							bt = ""
						End If
						te->TypeName = ""
						te->ElementType = "Sub"
						te->Locals = IIf(StartsWith(bTrimLCase, "private sub "), 1, 0)
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If EndsWith(LCase(te->Parameters), " __export__") Then
							te->Parameters = Trim(Left(te->Parameters, Len(te->Parameters) - 11))
						End If
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							n = Types.IndexOf(bt)
							If n > -1 Then Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							If n = -1 Then
								n = Comps.IndexOf(bt)
								If n > -1 AndAlso Comps.Object(n) <> 0 Then Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							End If
						Else
							Functions.Add te->Name, te
						End If
					ElseIf CInt(StartsWith(bTrimLCase, "function ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private function ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public function ")) Then
						inFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " function") + 9
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = New TypeElement
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then
							bt = Left(te->Name, Pos1 - 1)
							te->Name = Mid(te->Name, Pos1 + 1)
						Else
							bt = ""
						End If
						Pos4 = InStr(bTrim, ")")
						Pos3 = InStr(Pos4, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos4 + 1, bTrimLCase, " as ")
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						te->ElementType = "Function"
						te->Locals = IIf(StartsWith(bTrimLCase, "private function "), 1, 0)
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If EndsWith(LCase(te->Parameters), " __export__") Then
							te->Parameters = Trim(Left(te->Parameters, Len(te->Parameters) - 11))
						End If
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							n = Types.IndexOf(bt)
							If n > -1 Then Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							If n = -1 Then
								n = Comps.IndexOf(bt)
								If n > -1 AndAlso Comps.Object(n) <> 0 Then Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							End If
						Else
							Functions.Add te->Name, te
						End If
					ElseIf CInt(StartsWith(bTrimLCase, "property ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private property ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public property ")) Then
						inFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " property") + 9
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = New TypeElement
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						If EndsWith(bTrim, ")") Then
							te->DisplayName = te->Name & " [Let]"
						Else
							te->DisplayName = te->Name & " [Get]"
						End If
						Pos1 = InStr(te->Name, ".")
						If Pos1 > 0 Then
							bt = Left(te->Name, Pos1 - 1)
							te->Name = Mid(te->Name, Pos1 + 1)
						Else
							bt = ""
						End If
						Pos4 = InStr(bTrim, ")")
						Pos3 = InStr(Pos4, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos4 + 1, bTrimLCase, " as ")
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						te->ElementType = "property"
						te->Locals = IIf(StartsWith(bTrimLCase, "private property "), 1, 0)
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							n = Types.IndexOf(bt)
							If n > -1 Then Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							If n = -1 Then
								n = Comps.IndexOf(bt)
								If n > -1 AndAlso Comps.Object(n) <> 0 Then Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							End If
						Else
							Functions.Add te->Name, te
						End If
					ElseIf CInt(Not inType) AndAlso CInt(Not inEnum) AndAlso CInt(Not inFunc) AndAlso _
						CInt(CInt(StartsWith(bTrimLCase, "dim ")) OrElse _
						CInt(StartsWith(bTrimLCase, "common ")) OrElse _
						CInt(StartsWith(bTrimLCase, "static ")) OrElse _
						CInt(StartsWith(bTrimLCase, "const ")) OrElse _
						CInt(StartsWith(bTrimLCase, "var "))) Then
						Dim As UString b2 = Trim(Mid(bTrim, InStr(bTrim, " ")))
						Dim As UString CurType, ElementValue
						Dim As UString res1(Any)
						Dim As Boolean bShared
						Pos1 = InStr(b2, "'")
						If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
						If b2.ToLower.StartsWith("shared ") Then bShared = True: b2 = Trim(Mid(b2, 7))
						If b2.ToLower.StartsWith("as ") Then
							CurType = Trim(Mid(b2, 4))
							Pos1 = InStr(CurType, " ")
							Pos2 = InStr(CurType, " Ptr ")
							Pos3 = InStr(CurType, " Pointer ")
							If Pos2 > 0 Then
								Pos1 = Pos2 + 4
							ElseIf Pos3 > 0 Then
								Pos1 = Pos2 + 8
							End If
							If Pos1 > 0 Then
								Split GetChangedCommas(Mid(CurType, Pos1 + 1)), ",", res1()
								CurType = Left(CurType, Pos1 - 1)
							End If
						Else
							Split GetChangedCommas(b2), ",", res1()
						End If
						For n As Integer = 0 To UBound(res1)
							res1(n) = Replace(res1(n), ";", ",")
							Pos1 = InStr(res1(n), "=")
							If Pos1 > 0 Then
								ElementValue = Trim(Mid(res1(n), Pos1 + 1))
							Else
								ElementValue = ""
							End If
							If Pos1 > 0 Then res1(n) = Trim(Left(res1(n), Pos1 - 1))
							Pos1 = InStr(LCase(res1(n)), " as ")
							If Pos1 > 0 Then
								CurType = Trim(Mid(res1(n), Pos1 + 4))
								res1(n) = Left(res1(n), Pos1 - 1)
							End If
							res1(n) = res1(n).TrimAll
							Pos1 = InStrRev(CurType, ".")
							If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							Var te = New TypeElement
							te->Name = res1(n)
							te->DisplayName = te->Name
							te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub("), "Event", "Property")
							te->TypeIsPointer = CurType.ToLower.EndsWith(" pointer") OrElse CurType.ToLower.EndsWith(" ptr")
							te->TypeName = CurType
							te->TypeName = WithoutPointers(te->TypeName)
							te->Value = ElementValue
							te->Locals = IIf(bShared, 0, 1)
							te->StartLine = i
							te->Parameters = res1(n) & " As " & CurType
							te->FileName = PathFunction
							If Comment <> "" Then te->Comment = Comment: Comment = ""
							Args.Add te->Name, te
						Next
					End If
				End If
			End If
		Next
		If FormClosing Then MutexUnlock tlockSave: Exit Sub
	Next
	MutexUnlock tlockSave
	For i As Integer = 0 To Files.Count - 1
		LoadFunctions Files.Item(i), , Types, Enums, Functions, Args
		If FormClosing Then Exit Sub
	Next
End Sub

tlock = MutexCreate()
tlockSave = MutexCreate()
Sub LoadFunctionsSub(Param As Any Ptr)
	MutexLock tlock
	If Not FormClosing Then
		If Not IncludeFiles.Contains(QWString(Param)) Then LoadFunctions QWString(Param), FilePathAndIncludeFiles, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs
	End If
	MutexUnlock tlock
End Sub

Sub LoadOnlyFilePath(Param As Any Ptr)
	MutexLock tlock
	If Not FormClosing Then
		If Not IncludeFiles.Contains(QWString(Param)) Then LoadFunctions QWString(Param), LoadParam.OnlyFilePath, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs
	End If
	MutexUnlock tlock
End Sub

Sub LoadOnlyFilePathOverwrite(Param As Any Ptr)
	MutexLock tlock
	If Not FormClosing Then
		LoadFunctions QWString(Param), LoadParam.OnlyFilePathOverwrite, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs
	End If
	MutexUnlock tlock
End Sub

Sub LoadOnlyIncludeFiles(Param As Any Ptr)
	MutexLock tlock
	If Not FormClosing Then
		LoadFunctions QWString(Param), LoadParam.OnlyIncludeFiles, GlobalTypes, GlobalEnums, GlobalFunctions, GlobalArgs
	End If
	MutexUnlock tlock
End Sub

Sub LoadToolBox
	Dim As String f
	Dim As Integer i, j
	Dim As My.Sys.Drawing.Cursor cur
	Dim As String IncludePath
	Dim MFF As Any Ptr
	IncludeMFFPath = iniSettings.ReadBool("Options", "IncludeMFFPath", True)
	WLet MFFPath, iniSettings.ReadString("Options", "MFFPath", "./MyFbFramework")
	#ifndef __USE_GTK__
		#ifdef __FB_64BIT__
			WLet MFFDll, *MFFPath & "/mff64.dll"
		#else
			WLet MFFDll, *MFFPath & "/mff32.dll"
		#endif
	#else
		#ifdef __USE_GTK3__
			#ifdef __FB_64BIT__
				WLet MFFDll, *MFFPath & "/libmff64_gtk3.so"
			#else
				WLet MFFDll, *MFFPath & "/libmff32_gtk3.so"
			#endif
		#else
			#ifdef __FB_64BIT__
				WLet MFFDll, *MFFPath & "/libmff64_gtk2.so"
			#else
				WLet MFFDll, *MFFPath & "/libmff32_gtk2.so"
			#endif
		#endif
	#endif
	If Not FileExists(*MFFDll) Then '
		MsgBox ML("File not found") & ": " & WChr(13,10) & WChr(13,10) & *MFFDll & WChr(13,10) & WChr(13,10) & ML("Can not load control to toolbox")
	End If
	MFF = DyLibLoad(*MFFDll)
	Dim As TypeElement Ptr tbi
	#ifndef __USE_GTK__
		cur = crArrow
	#endif
	Dim cl As Integer = clSilver
	#ifdef __USE_GTK__
		gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), *MFFPath & "/resources")
		tbToolBox.Align = 5
	#else
		imgListTools.AddPng "DropDown", "DropDown"
		imgListTools.AddPng "Kursor", "Cursor"
	#endif
	tbToolBox.Top = tbForm.Height
	tbToolBox.Flat = True
	tbToolBox.Wrapable = True
	tbToolBox.BorderStyle = 0
	tbToolBox.List = True
	tbToolBox.Style = tpsBothHorizontal
	tbToolBox.OnMouseWheel = @tbToolBox_MouseWheel
	tbToolBox.ImagesList = @imgListTools
	tbToolBox.HotImagesList = @imgListTools
	IncludePath = GetFolderName(*MFFDll) & "mff/"
	f = Dir(IncludePath & "*.bi")
	While f <> ""
		LoadFunctions GetOSPath(GetFullPath(IncludePath) & f), LoadParam.OnlyFilePath, Comps, GlobalEnums, GlobalFunctions, GlobalArgs
		f = Dir()
	Wend
	f = Dir(IncludePath & "*.bas")
	While f <> ""
		LoadFunctions GetOSPath(GetFullPath(IncludePath) & f), LoadParam.OnlyFilePath, Comps, GlobalEnums, GlobalFunctions, GlobalArgs
		f = Dir()
	Wend
	Comps.Sort
	Var iOld = -1, iNew = 0
	Dim As String it = "Cursor", g(1 To 4): g(1) = ML("Controls"): g(2) = ML("Containers"): g(3) = ML("Components"): g(4) = ML("Dialogs")
	tbToolBox.Groups.Add ML("Controls")
	tbToolBox.Groups.Add ML("Containers")
	tbToolBox.Groups.Add ML("Components")
	tbToolBox.Groups.Add ML("Dialogs")
	tbToolBox.Groups.Item(0)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	tbToolBox.Groups.Item(1)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	tbToolBox.Groups.Item(2)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	tbToolBox.Groups.Item(3)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap Or tstChecked)
	'For j As Integer = 1 To 4
	'    If j > 1 Then tbToolBox.Buttons.Add tbsSeparator,,,,,,,,tstHidden
	'    tbToolBox.Buttons.Add tbsCheck,"DropDown",,@ToolBoxClick,g(j),g(j),,,tstEnabled Or tstChecked Or tstWrap
	'    tbToolBox.Buttons.Add tbsSeparator
	For i = 0 To Comps.Count - 1
		If LCase(Comps.Item(i)) = "control" Or LCase(Comps.Item(i)) = "containercontrol" Or LCase(Comps.Item(i)) = "menu" Or LCase(Comps.Item(i)) = "component" Or LCase(Comps.Item(i)) = "dialog" Then Continue For
		iNew = GetTypeControl(Comps.Item(i))
		If Comps.Contains(Comps.Item(i)) Then
			Var tbi = Cast(TypeElement Ptr, Comps.Object(Comps.IndexOf(Comps.Item(i))))
			If tbi->ElementType = "TypeCopy" Then Continue For
			tbi->ControlType = iNew
		End If
		If iNew = 0 Then Continue For
		'If iNew <> j Then Continue For
		it = Comps.Item(i)
		#ifndef __USE_GTK__
			imgListTools.AddPng it, it, MFF
		#endif
		Var toolb = tbToolBox.Groups.Item(iNew - 1)->Buttons.Add(tbsCheckGroup,it,,@ToolBoxClick, it, it, it, True, tstEnabled Or tstWrap)
		toolb->Tag = Comps.Object(i)
		iOld = iNew
	Next i
	'With *tbToolBox.Buttons.Button(tbToolBox.Buttons.Count - 1)
	'    If .State = tstEnabled Then .State = tstEnabled Or tstWrap
	'End With
	'Next j
	If MFF Then DyLibFree(MFF)
End Sub

Sub LoadSettings
	MainWidth = iniSettings.ReadInteger("MainWindow", "MainWidth", MainWidth)
	MainHeight = iniSettings.ReadInteger("MainWindow", "MainHeight", MainHeight)
	frmMain.Width= Max(MainWidth,600)
	frmMain.Height= Max(MainHeight,400)
	Dim As UString Temp
	Dim As Integer Fn
	Dim As WString * 1024 Buff
	For i As Integer = 0 To 9
		Temp = iniSettings.ReadString("Compilers", "Version_" & WStr(i), "")
		If Temp <> "" Then Compilers.Add Temp, iniSettings.ReadString("Compilers", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("MakeTools", "Version_" & WStr(i), "")
		If Temp <> "" Then MakeTools.Add Temp, iniSettings.ReadString("MakeTools", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("Debuggers", "Version_" & WStr(i), "")
		If Temp <> "" Then Debuggers.Add Temp, iniSettings.ReadString("Debuggers", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("Terminals", "Version_" & WStr(i), "")
		If Temp <> "" Then Terminals.Add Temp, iniSettings.ReadString("Terminals", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		If Temp <> "" Then Helps.Add Temp, iniSettings.ReadString("Helps", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("IncludePaths", "Path_" & WStr(i), "")
		If Temp <> "" Then IncludePaths.Add Temp
		Temp = iniSettings.ReadString("LibraryPaths", "Path_" & WStr(i), "")
		If Temp <> "" Then LibraryPaths.Add Temp
	Next
	WLet CurrentCompiler32, ""
	WLet CurrentCompiler64, ""
	WLet CurrentMakeTool1, ""
	WLet CurrentMakeTool2, ""
	WLet CurrentTerminal, ""
	WLet CurrentDebugger, ""
	WLet DefaultCompiler32, iniSettings.ReadString("Compilers", "DefaultCompiler32", "")
	WLet DefaultCompiler64, iniSettings.ReadString("Compilers", "DefaultCompiler64", "")
	WLet Compiler32Path, Compilers.Get(*DefaultCompiler32, "fbc")
	WLet Compiler64Path, Compilers.Get(*DefaultCompiler64, "fbc")
	WLet DefaultMakeTool, iniSettings.ReadString("MakeTools", "DefaultMakeTool", "make")
	WLet MakeToolPath, MakeTools.Get(*DefaultMakeTool, "make")
	WLet DefaultDebugger, iniSettings.ReadString("Debuggers", "DefaultDebugger", "")
	WLet DebuggerPath, Debuggers.Get(*DefaultDebugger, "")
	WLet DefaultTerminal, iniSettings.ReadString("Terminals", "DefaultTerminal", "")
	WLet TerminalPath, Terminals.Get(*DefaultTerminal, "")
	WLet DefaultHelp, iniSettings.ReadString("Helps", "DefaultHelp", "")
	WLet HelpPath, Helps.Get(*DefaultHelp, "")
	
	UseMakeOnStartWithCompile = iniSettings.ReadBool("Options", "UseMakeOnStartWithCompile", False)
	LimitDebug = iniSettings.ReadBool("Options", "LimitDebug", False)
	DisplayWarningsInDebug = iniSettings.ReadBool("Options", "DisplayWarningsInDebug", False)
	WLet ProjectsPath, iniSettings.ReadString("Options", "ProjectsPath", "./Projects")
	GridSize = iniSettings.ReadInteger("Options", "GridSize", 10)
	ShowAlignmentGrid = iniSettings.ReadBool("Options", "ShowAlignmentGrid", True)
	SnapToGridOption = iniSettings.ReadBool("Options", "SnapToGrid", True)
	AutoIncrement = iniSettings.ReadBool("Options", "AutoIncrement", True)
	AutoCreateRC = iniSettings.ReadBool("Options", "AutoCreateRC", True)
	AutoSaveBeforeCompiling = iniSettings.ReadInteger("Options", "AutoSaveBeforeCompiling", 1)
	AutoCreateBakFiles = iniSettings.ReadBool("Options", "AutoCreateBakFiles", False)
	AutoReloadLastOpenFiles = iniSettings.ReadBool("Options", "AutoReloadLastOpenFiles", True)
	AutoComplete = iniSettings.ReadBool("Options", "AutoComplete", True)
	AutoIndentation = iniSettings.ReadBool("Options", "AutoIndentation", True)
	ShowSpaces = iniSettings.ReadBool("Options", "ShowSpaces", True)
	HighlightBrackets = iniSettings.ReadBool("Options", "HighlightBrackets", True)
	HighlightCurrentLine = iniSettings.ReadBool("Options", "HighlightCurrentLine", True)
	HighlightCurrentWord = iniSettings.ReadBool("Options", "HighlightCurrentWord", True)
	TabAsSpaces = iniSettings.ReadBool("Options", "TabAsSpaces", True)
	ChoosedTabStyle = iniSettings.ReadInteger("Options", "ChoosedTabStyle", 1)
	TabWidth = iniSettings.ReadInteger("Options", "TabWidth", 4)
	HistoryLimit = iniSettings.ReadInteger("Options", "HistoryLimit", 20)
	ChangeKeyWordsCase = iniSettings.ReadBool("Options", "ChangeKeyWordsCase", True)
	ChoosedKeyWordsCase = iniSettings.ReadInteger("Options", "ChoosedKeyWordsCase", 0)
	WLet CurrentTheme, iniSettings.ReadString("Options", "CurrentTheme", "Default Theme")
	WLet EditorFontName, iniSettings.ReadString("Options", "EditorFontName", "Courier New")
	EditorFontSize = iniSettings.ReadInteger("Options", "EditorFontSize", 10)
	#ifdef __USE_GTK__
		WLet InterfaceFontName, iniSettings.ReadString("Options", "InterfaceFontName", "Ubuntu")
		InterfaceFontSize = iniSettings.ReadInteger("Options", "InterfaceFontSize", 11)
	#else
		WLet InterfaceFontName, iniSettings.ReadString("Options", "InterfaceFontName", "Tahoma")
		InterfaceFontSize = iniSettings.ReadInteger("Options", "InterfaceFontSize", 8)
	#endif
	DisplayMenuIcons = iniSettings.ReadBool("Options", "DisplayMenuIcons", True)
	ShowMainToolbar = iniSettings.ReadBool("Options", "ShowMainToolbar", True)
	pDefaultFont->Name = WGet(InterfaceFontName)
	pDefaultFont->Size  = InterfaceFontSize
	
	mnuMain.ImagesList = IIf(DisplayMenuIcons, @imgList, 0)
	tbStandard.Visible = ShowMainToolbar
	
	WLet Compiler32Arguments, iniSettings.ReadString("Parameters", "Compiler32Arguments", "-exx")
	WLet Compiler64Arguments, iniSettings.ReadString("Parameters", "Compiler64Arguments", "-exx")
	WLet Make1Arguments, iniSettings.ReadString("Parameters", "Make1Arguments", "")
	WLet Make2Arguments, iniSettings.ReadString("Parameters", "Make2Arguments", "clean")
	WLet RunArguments, iniSettings.ReadString("Parameters", "RunArguments", "")
	
	iniTheme.Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
	Bookmarks.ForegroundOption = iniTheme.ReadInteger("Colors", "BookmarksForeground", -1)
	Bookmarks.BackgroundOption = iniTheme.ReadInteger("Colors", "BookmarksBackground", -1)
	Bookmarks.FrameOption = iniTheme.ReadInteger("Colors", "BookmarksFrame", -1)
	Bookmarks.IndicatorOption = iniTheme.ReadInteger("Colors", "BookmarksIndicator", -1)
	Bookmarks.Bold = iniTheme.ReadInteger("FontStyles", "BookmarksBold", 0)
	Bookmarks.Italic = iniTheme.ReadInteger("FontStyles", "BookmarksItalic", 0)
	Bookmarks.Underline = iniTheme.ReadInteger("FontStyles", "BookmarksUnderline", 0)
	Breakpoints.ForegroundOption = iniTheme.ReadInteger("Colors", "BreakpointsForeground", -1)
	Breakpoints.BackgroundOption = iniTheme.ReadInteger("Colors", "BreakpointsBackground", -1)
	Breakpoints.FrameOption = iniTheme.ReadInteger("Colors", "BreakpointsFrame", -1)
	Breakpoints.IndicatorOption = iniTheme.ReadInteger("Colors", "BreakpointsIndicator", -1)
	Breakpoints.Bold = iniTheme.ReadInteger("FontStyles", "BreakpointsBold", 0)
	Breakpoints.Italic = iniTheme.ReadInteger("FontStyles", "BreakpointsItalic", 0)
	Breakpoints.Underline = iniTheme.ReadInteger("FontStyles", "BreakpointsUnderline", 0)
	Comments.ForegroundOption = iniTheme.ReadInteger("Colors", "CommentsForeground", -1)
	Comments.BackgroundOption = iniTheme.ReadInteger("Colors", "CommentsBackground", -1)
	Comments.FrameOption = iniTheme.ReadInteger("Colors", "CommentsFrame", -1)
	Comments.Bold = iniTheme.ReadInteger("FontStyles", "CommentsBold", 0)
	Comments.Italic = iniTheme.ReadInteger("FontStyles", "CommentsItalic", 0)
	Comments.Underline = iniTheme.ReadInteger("FontStyles", "CommentsUnderline", 0)
	CurrentBrackets.ForegroundOption = iniTheme.ReadInteger("Colors", "CurrentBracketsForeground", -1)
	CurrentBrackets.BackgroundOption = iniTheme.ReadInteger("Colors", "CurrentBracketsBackground", -1)
	CurrentBrackets.FrameOption = iniTheme.ReadInteger("Colors", "CurrentBracketsFrame", -1)
	CurrentBrackets.Bold = iniTheme.ReadInteger("FontStyles", "CurrentBracketsBold", 0)
	CurrentBrackets.Italic = iniTheme.ReadInteger("FontStyles", "CurrentBracketsItalic", 0)
	CurrentBrackets.Underline = iniTheme.ReadInteger("FontStyles", "CurrentBracketsUnderline", 0)
	CurrentLine.ForegroundOption = iniTheme.ReadInteger("Colors", "CurrentLineForeground", -1)
	CurrentLine.BackgroundOption = iniTheme.ReadInteger("Colors", "CurrentLineBackground", -1)
	CurrentLine.FrameOption = iniTheme.ReadInteger("Colors", "CurrentLineFrame", -1)
	CurrentWord.ForegroundOption = iniTheme.ReadInteger("Colors", "CurrentWordForeground", -1)
	CurrentWord.BackgroundOption = iniTheme.ReadInteger("Colors", "CurrentWordBackground", -1)
	CurrentWord.FrameOption = iniTheme.ReadInteger("Colors", "CurrentWordFrame", -1)
	CurrentWord.Bold = iniTheme.ReadInteger("FontStyles", "CurrentWordBold", 0)
	CurrentWord.Italic = iniTheme.ReadInteger("FontStyles", "CurrentWordItalic", 0)
	CurrentWord.Underline = iniTheme.ReadInteger("FontStyles", "CurrentWordUnderline", 0)
	ExecutionLine.ForegroundOption = iniTheme.ReadInteger("Colors", "ExecutionLineForeground", -1)
	ExecutionLine.BackgroundOption = iniTheme.ReadInteger("Colors", "ExecutionLineBackground", -1)
	ExecutionLine.FrameOption = iniTheme.ReadInteger("Colors", "ExecutionLineFrame", -1)
	ExecutionLine.IndicatorOption = iniTheme.ReadInteger("Colors", "ExecutionLineIndicator", -1)
	FoldLines.ForegroundOption = iniTheme.ReadInteger("Colors", "FoldLinesForeground", -1)
	IndicatorLines.ForegroundOption = iniTheme.ReadInteger("Colors", "IndicatorLinesForeground", -1)
	Keywords.ForegroundOption = iniTheme.ReadInteger("Colors", "KeywordsForeground", -1)
	Keywords.BackgroundOption = iniTheme.ReadInteger("Colors", "KeywordsBackground", -1)
	Keywords.FrameOption = iniTheme.ReadInteger("Colors", "KeywordsFrame", -1)
	Keywords.Bold = iniTheme.ReadInteger("FontStyles", "KeywordsBold", 0)
	Keywords.Italic = iniTheme.ReadInteger("FontStyles", "KeywordsItalic", 0)
	Keywords.Underline = iniTheme.ReadInteger("FontStyles", "KeywordsUnderline", 0)
	LineNumbers.ForegroundOption = iniTheme.ReadInteger("Colors", "LineNumbersForeground", -1)
	LineNumbers.BackgroundOption = iniTheme.ReadInteger("Colors", "LineNumbersBackground", -1)
	LineNumbers.Bold = iniTheme.ReadInteger("FontStyles", "LineNumbersBold", 0)
	LineNumbers.Italic = iniTheme.ReadInteger("FontStyles", "LineNumbersItalic", 0)
	LineNumbers.Underline = iniTheme.ReadInteger("FontStyles", "LineNumbersUnderline", 0)
	NormalText.ForegroundOption = iniTheme.ReadInteger("Colors", "NormalTextForeground", -1)
	NormalText.BackgroundOption = iniTheme.ReadInteger("Colors", "NormalTextBackground", -1)
	NormalText.FrameOption = iniTheme.ReadInteger("Colors", "NormalTextFrame", -1)
	NormalText.Bold = iniTheme.ReadInteger("FontStyles", "NormalTextBold", 0)
	NormalText.Italic = iniTheme.ReadInteger("FontStyles", "NormalTextItalic", 0)
	NormalText.Underline = iniTheme.ReadInteger("FontStyles", "NormalTextUnderline", 0)
	Preprocessors.ForegroundOption = iniTheme.ReadInteger("Colors", "PreprocessorsForeground", -1)
	Preprocessors.BackgroundOption = iniTheme.ReadInteger("Colors", "PreprocessorsBackground", -1)
	Preprocessors.FrameOption = iniTheme.ReadInteger("Colors", "PreprocessorsFrame", -1)
	Preprocessors.Bold = iniTheme.ReadInteger("FontStyles", "PreprocessorsBold", 0)
	Preprocessors.Italic = iniTheme.ReadInteger("FontStyles", "PreprocessorsItalic", 0)
	Preprocessors.Underline = iniTheme.ReadInteger("FontStyles", "PreprocessorsUnderline", 0)
	Selection.ForegroundOption = iniTheme.ReadInteger("Colors", "SelectionForeground", -1)
	Selection.BackgroundOption = iniTheme.ReadInteger("Colors", "SelectionBackground", -1)
	Selection.FrameOption = iniTheme.ReadInteger("Colors", "SelectionFrame", -1)
	SpaceIdentifiers.ForegroundOption = iniTheme.ReadInteger("Colors", "SpaceIdentifiersForeground", -1)
	Strings.ForegroundOption = iniTheme.ReadInteger("Colors", "StringsForeground", -1)
	Strings.BackgroundOption = iniTheme.ReadInteger("Colors", "StringsBackground", -1)
	Strings.FrameOption = iniTheme.ReadInteger("Colors", "StringsFrame", -1)
	Strings.Bold = iniTheme.ReadInteger("FontStyles", "StringsBold", 0)
	Strings.Italic = iniTheme.ReadInteger("FontStyles", "StringsItalic", 0)
	Strings.Underline = iniTheme.ReadInteger("FontStyles", "StringsUnderline", 0)
	SetAutoColors
	
End Sub

Sub LoadLanguageTexts
	iniSettings.Load SettingsPath
	CurLanguage = iniSettings.ReadString("Options", "Language", "english")
	
	If CurLanguage = "" Then
		mlKeys.Add "#Til"
		mlTexts.Add "English"
		CurLanguage = "English"
	Else
		Dim As Integer i, Pos1
		Dim As Integer Fn = FreeFile, Result
		Dim Buff As WString * 2048 '
		Dim As UString FileName = ExePath & "/Settings/Languages/" & CurLanguage & ".lng"
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				Pos1 = InStr(Buff, "=")
				If Pos1 > 0 Then
					mlKeys.Add Trim(Left(Buff, Pos1 - 1), " ")
					mlTexts.Add Trim(Mid(Buff, Pos1 + 1), " ")
				End If
			Loop
			Close #Fn
		End If
	End If
End Sub

Sub LoadHotKeys
	Dim As Integer Fn = FreeFile, Pos1
	Dim As String Buff
	Open ExePath & "/Settings/Others/HotKeys.txt" For Input As #Fn
	While Not EOF(Fn)
		Line Input #Fn, Buff
		Pos1 = InStr(Buff, "=")
		If Pos1 > 0 Then
			HotKeys.Add Left(Buff, Pos1 - 1), Mid(Buff, Pos1 + 1)
		End If
	Wend
	Close #Fn
End Sub

Function HK(Key As String, Default As String = "") As String
	Dim As String HotKey = HotKeys.Get(Key, Default)
	If HotKey = "" Then
		Return ""
	Else
		Return !"\t" & HotKey
	End If
End Function

Sub CreateMenusAndToolBars
	imgList.Name = "imgList"
	imgList.AddPng "StartWithCompile", "StartWithCompile"
	imgList.AddPng "Start", "Start"
	imgList.AddPng "Break", "Break"
	imgList.AddPng "EndProgram", "End"
	imgList.AddPng "New", "New"
	imgList.AddPng "Open", "Open"
	imgList.AddPng "Save", "Save"
	imgList.AddPng "SaveAll", "SaveAll"
	imgList.AddPng "Close", "Close"
	imgList.AddPng "Exit", "Exit"
	imgList.AddPng "Undo", "Undo"
	imgList.AddPng "Redo", "Redo"
	imgList.AddPng "Cut", "Cut"
	imgList.AddPng "Copy", "Copy"
	imgList.AddPng "Paste", "Paste"
	imgList.AddPng "Search", "Find"
	imgList.AddPng "Code", "Code"
	imgList.AddPng "Console", "Console"
	imgList.AddPng "Form", "Form"
	imgList.AddPng "Format", "Format"
	imgList.AddPng "Unformat", "Unformat"
	imgList.AddPng "CodeAndForm", "CodeAndForm"
	imgList.AddPng "SyntaxCheck", "SyntaxCheck"
	imgList.AddPng "List", "Try"
	imgList.AddPng "UseDebugger", "UseDebugger"
	imgList.AddPng "Compile", "Compile"
	imgList.AddPng "Make", "Make"
	imgList.AddPng "Help", "Help"
	imgList.AddPng "About", "About"
	imgList.AddPng "File", "File"
	imgList.AddPng "MainFile", "MainFile"
	imgList.AddPng "Res", "Res"
	imgList.AddPng "MainRes", "MainRes"
	imgList.AddPng "Settings", "Parameters"
	imgList.AddPng "Folder", "Folder"
	imgList.AddPng "Project", "Project"
	imgList.AddPng "Add", "Add"
	imgList.AddPng "Remove", "Remove"
	imgList.AddPng "Error", "Error"
	imgList.AddPng "Warning", "Warning"
	imgList.AddPng "Info", "Info"
	imgList.AddPng "Label", "Label"
	imgList.AddPng "Component", "Component"
	imgList.AddPng "Property", "Property"
	imgList.AddPng "Sub", "Sub"
	imgList.AddPng "Bookmark", "Bookmark"
	imgList.AddPng "Breakpoint", "Breakpoint"
	imgList.AddPng "B32", "B32"
	imgList.AddPng "B64", "B64"
	imgList.AddPng "Opened", "Opened"
	imgList.AddPng "Tools", "Tools"
	imgList.AddPng "StandartTypes", "StandartTypes"
	imgList.AddPng "Enum", "Enum"
	imgList.AddPng "Type", "Type"
	imgList.AddPng "Function", "Function"
	imgList.AddPng "Event", "Event"
	imgList.AddPng "Collapsed", "Collapsed"
	imgList.AddPng "Categorized", "Categorized"
	imgList.AddPng "Comment", "Comment"
	imgList.AddPng "UnComment", "UnComment"
	imgList.AddPng "Print", "Print"
	imgList.AddPng "PrintPreview", "PrintPreview"
	imgListD.AddPng "StartWithCompileD", "StartWithCompile"
	imgListD.AddPng "StartD", "Start"
	imgListD.AddPng "BreakD", "Break"
	imgListD.AddPng "EndD", "End"
	
	'mnuMain.ImagesList = @imgList
	
	LoadHotKeys
	
	#ifdef __USE_GTK__
		Var miFile = mnuMain.Add(ML("&File") & !"\tAlt+F", "", "File")
	#else
		Var miFile = mnuMain.Add(ML("&File"), "", "File")
	#endif
	miFile->Add(ML("New Project") & HK("NewProject", "Ctrl+Shift+N"), "Project", "NewProject", @mclick)
	miFile->Add(ML("Open Project") & HK("OpenProject", "Ctrl+Shift+O"), "", "OpenProject", @mclick)
	miFile->Add(ML("Close Project") & HK("CloseProject", "Ctrl+Shift+F4"), "", "CloseProject", @mclick)
	miFile->Add(ML("Import from Folder") & HK("OpenFolder", "Alt+O"), "", "OpenFolder", @mclick)
	miFile->Add("-")
	miFile->Add(ML("Save Project") & "..." & HK("SaveProject", "Ctrl+Shift+S"), "SaveAll", "SaveProject", @mclick)
	miFile->Add(ML("Save Project As") & "..." & HK("SaveProjectAs"), "", "SaveProjectAs", @mclick)
	miFile->Add("-")
	miFile->Add(ML("Open Session") & HK("OpenSession", "Ctrl+Alt+O"), "", "OpenSession", @mclick)
	miFile->Add(ML("Save Session") & HK("SaveFolder", "Ctrl+Alt+S"), "", "SaveSession", @mclick)
	miFile->Add("-")
	miFile->Add(ML("&New") & HK("New", "Ctrl+N"), "New", "New", @mclick)
	miFile->Add(ML("&Open") & "..." & HK("Open", "Ctrl+O"), "Open", "Open", @mclick)
	miFile->Add("-")
	miFile->Add(ML("&Save") & "..." & HK("Save", "Ctrl+S"), "Save", "Save", @mclick)
	miFile->Add(ML("Save &As") & "..." & HK("SaveAs"), "", "SaveAs", @mclick)
	miFile->Add(ML("Save All") & HK("SaveAll", "Ctrl+Alt+Shift+S"), "SaveAll", "SaveAll", @mclick)
	miFile->Add("-")
	miFile->Add(ML("&Close") & HK("Close", "Ctrl+F4"), "Close", "Close", @mclick)
	miFile->Add(ML("Close All") & HK("CloseAll", "Ctrl+Alt+Shift+F4"), "", "CloseAll", @mclick)
	miFile->Add("-")
	miFile->Add(ML("&Print") & HK("Print", "Ctrl+P"), "Print", "Print", @mclick)
	miFile->Add(ML("Print P&review") & HK("PrintPreview"), "PrintPreview", "PrintPreview", @mclick)
	miFile->Add(ML("Page Set&up") & "..." & HK("PageSetup"), "", "PageSetup", @mclick)
	miFile->Add("-")
	' Add Recent Sessions
	miRecentProjects = miFile->Add(ML("Recent Projects"), "", "RecentProjects", @mclick)
	Dim sTmp As WString * 1024
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUProjects", "MRUProject_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUProjects.Add sTmp
			miRecentProjects->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentProjects->Add("-")
	miRecentProjects->Add(ML("Clear Recently Opened"),"","ClearProjects", @mClickMRU)
	
	'David Change  Add Recent Sessions
	miRecentSessions = miFile->Add(ML("Recent Sessions"), "", "RecentSessions", @mclick)
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUSessions", "MRUSession_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUSessions.Add sTmp
			miRecentSessions->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentSessions->Add("-")
	miRecentSessions->Add(ML("Clear Recently Opened"),"","ClearSessions", @mClickMRU)
	
	miRecentFiles = miFile->Add(ML("Recent Files"), "", "RecentFiles", @mclick)
	For i As Integer = 0 To miRecentMax
		sTmp =iniSettings.ReadString("MRUFiles", "MRUFile_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUFiles.Add sTmp
			miRecentFiles->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentFiles->Add("-")
	miRecentFiles->Add(ML("Clear Recently Opened"),"","ClearFiles", @mClickMRU)
	
	miFile->Add("-")
	miFile->Add(ML("&Command Prompt") & HK("CommandPrompt", "Alt+C"), "Console", "CommandPrompt", @mclick)
	miFile->Add("-")
	miFile->Add(ML("&Exit") & HK("Exit", "Alt+F4"), "Exit", "Exit", @mclick)
	
	Var miEdit = mnuMain.Add(ML("&Edit"), "", "Tahrir")
	miEdit->Add(ML("Undo") & HK("Undo", "Ctrl+Z"), "Undo", "Undo", @mclick)
	miEdit->Add(ML("Redo") & HK("Redo", "Ctrl+Y"), "Redo", "Redo", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("Cu&t") & HK("Cut", "Ctrl+X"), "Cut", "Cut", @mclick)
	miEdit->Add(ML("&Copy") & HK("Copy", "Ctrl+C"), "Copy", "Copy", @mclick)
	miEdit->Add(ML("&Paste") & HK("Paste", "Ctrl+V"), "Paste", "Paste", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("&Single Comment") & HK("SingleComment", "Ctrl+I"), "Comment", "SingleComment", @mclick)
	miEdit->Add(ML("&Block Comment") & HK("BlockComment", "Ctrl+Alt+I"), "", "BlockComment", @mclick)
	miEdit->Add(ML("&Uncomment Block") & HK("UnComment", "Ctrl+Shift+I"), "UnComment", "UnComment", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("Select &All") & HK("SelectAll", "Ctrl+A"), "", "SelectAll", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("&Indent") & HK("Indent", "Tab"), "", "Indent", @mclick)
	miEdit->Add(ML("&Outdent") & HK("Outdent", "Shift+Tab"), "", "Outdent", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("&Format") & HK("Format", "Ctrl+Tab"), "Format", "Format", @mclick)
	miEdit->Add(ML("&Unformat") & HK("Unformat", "Ctrl+Shift+Tab"), "Unformat", "Unformat", @mclick)
	miEdit->Add(ML("&Format Project") & HK("FormatProject"), "FormatProject", "FormatProject", @mclick)
	miEdit->Add(ML("&Unformat Project") & HK("UnformatProject"), "UnformatProject", "UnformatProject", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("Collapse All") & HK("CollapseAll"), "", "CollapseAll", @mclick)
	miEdit->Add(ML("Uncollapse All") & HK("UnCollapseAll"), "", "UnCollapseAll", @mclick)
	miEdit->Add("-")
	miEdit->Add(ML("Complete Word") & HK("CompleteWord", "Ctrl+J"), "", "CompleteWord", @mclick)
	miEdit->Add("-")
	Var miTry = miEdit->Add(ML("Error Handling"), "", "Try")
	miTry->Add(ML("Numbering") & HK("NumberOn"), "", "NumberOn", @mclick)
	miTry->Add(ML("Remove Numbering") & HK("NumberOff"), "", "NumberOff", @mclick)
	miTry->Add("-")
	miTry->Add(ML("Procedure numbering") & HK("ProcedureNumberOn"), "", "ProcedureNumberOn", @mclick)
	miTry->Add(ML("Remove Procedure numbering") & HK("ProcedureNumberOff"), "", "ProcedureNumberOff", @mclick)
	miTry->Add("-")
	miTry->Add("On Error Resume Next" & HK("OnErrorResumeNext"), "", "OnErrorResumeNext", @mclick)
	miTry->Add("On Error Goto ..." & HK("OnErrorGoto"), "", "OnErrorGoto", @mclick)
	miTry->Add("On Error Goto ... Resume Next" & HK("OnErrorGotoResumeNext"), "", "OnErrorGotoResumeNext", @mclick)
	miTry->Add(ML("Remove Error Handling") & HK("RemoveErrorHandling"), "", "RemoveErrorHandling", @mclick)
	
	Var miSearch = mnuMain.Add(ML("&Search"), "", "Search")
	miSearch->Add(ML("&Find") & "..." & HK("Find", "Ctrl+F"), "Find", "Find", @mclick)
	miSearch->Add(ML("&Replace") & "..."  & HK("Replace", "Ctrl+H"), "", "Replace", @mclick)
	miSearch->Add(ML("Find &Next") & HK("FindNext", "F3"), "", "FindNext", @mclick)
	miSearch->Add(ML("Find &Previous") & HK("FindPrev", "Shift+F3"), "", "FindPrev", @mclick)
	miSearch->Add("-")
	miSearch->Add(ML("Find In Files") & "..." & HK("FindInFiles", "Ctrl+Shift+F"), "", "FindInFiles", @mclick)
	miSearch->Add(ML("Replace In Files") & "..." & HK("ReplaceInFiles", "Ctrl+Shift+H"), "", "ReplaceInFiles", @mclick)
	miSearch->Add("-")
	miSearch->Add(ML("&Goto") & HK("Goto", "Ctrl+G"), "", "Goto", @mclick)
	miSearch->Add("-")
	miSearch->Add(ML("&Define") & HK("Define", "F2"), "", "Define", @mclick)
	Var miBookmark = miSearch->Add(ML("Bookmarks"), "", "Bookmarks")
	miBookmark->Add(ML("Toggle Bookmark") & HK("ToggleBookmark", "F6"), "Bookmark", "ToggleBookmark", @mclick)
	miBookmark->Add(ML("Next Bookmark") & HK("NextBookmark", "Ctrl+F6"), "", "NextBookmark", @mclick)
	miBookmark->Add(ML("Previous Bookmark") & HK("PreviousBookmark", "Ctrl+Shift+F6"), "", "PreviousBookmark", @mclick)
	miBookmark->Add(ML("Clear All Bookmarks") & HK("ClearAllBookmarks"), "", "ClearAllBookmarks", @mclick)
	
	#ifdef __USE_GTK__
		Var miProject = mnuMain.Add(ML("&Project") & !"\tAlt+P", "", "Project")
	#else
		Var miProject = mnuMain.Add(ML("&Project"), "", "Project")
	#endif
	miProject->Add(ML("&New Form") & HK("NewForm", "Ctrl+Alt+N"), "Form", "NewForm", @mclick)
	miProject->Add(ML("New &Module") & HK("NewModule","Ctrl+Alt+M"), "File", "NewModule", @mclick)
	miProject->Add(ML("New Resources File") & HK("NewModule"), "File", "NewModule", @mclick)
	miProject->Add("-")
	miProject->Add(ML("&Switch Code/Form") & HK("SwitchCodeForm"), "Code", "SwitchCodeForm", @mclick)
	miProject->Add("-")
	miProject->Add(ML("Add Files to Project") & HK("AddFileToProject"), "Add", "AddFileToProject", @mclick)
	miProject->Add(ML("&Remove Files from Project") & HK("RemoveFileFromProject"), "Remove", "RemoveFileFromProject", @mclick)
	miProject->Add("-")
	miProject->Add(ML("&Open Project Folder") & HK("OpenProjectFolder"), "", "OpenProjectFolder", @mclick)
	miProject->Add("-")
	miProject->Add(ML("&Project Properties") & "..." & HK("ProjectProperties"), "", "ProjectProperties", @mclick)
	
	Var miBuild = mnuMain.Add(ML("&Build"), "", "Build")
	miBuild->Add(ML("&Syntax Check") & HK("SyntaxCheck"), "SyntaxCheck", "SyntaxCheck", @mclick)
	miBuild->Add("-")
	miBuild->Add(ML("&Compile") & HK("Compile", "Ctrl+F9"), "Compile", "Compile", @mclick)
	miBuild->Add("-")
	miBuild->Add(ML("&Make") & HK("Make"), "Make", "Make", @mclick)
	miBuild->Add(ML("Make Clea&n") & HK("MakeClean"), "", "MakeClean", @mclick)
	miBuild->Add("-")
	miBuild->Add(ML("&Parameters") & HK("Parameters"), "Parameters", "Parameters", @mclick)
	
	Var miDebug = mnuMain.Add(ML("&Debug"), "", "Debug")
	mnuUseDebugger = miDebug->Add(ML("&Use Debugger") & HK("UseDebugger"), "", "UseDebugger", @mclick, True)
	miDebug->Add("-")
	miDebug->Add(ML("Step &Into")& HK("StepInto", "F8"), "", "StepInto", @mclick)
	miDebug->Add(ML("Step &Over") & HK("StepOver", "Shift+F8"), "", "StepOver", @mclick)
	miDebug->Add(ML("Step O&ut") & HK("StepOut", "Ctrl+Shift+F8"), "", "StepOut", @mclick)
	miDebug->Add(ML("&Run To Cursor") & HK("RunToCursor", "Ctrl+F8"), "", "RunToCursor", @mclick)
	miDebug->Add("-")
	miDebug->Add(ML("&Add Watch") & HK("AddWatch"), "", "AddWatch", @mclick)
	miDebug->Add("-")
	miDebug->Add(ML("&Toggle Breakpoint") & HK("Breakpoint", "F9"), "Breakpoint", "Breakpoint", @mclick)
	miDebug->Add(ML("&Clear All Breakpoints") & HK("ClearAllBreakpoints", "Ctrl+Shift+F9"), "", "ClearAllBreakpoints", @mclick)
	miDebug->Add("-")
	miDebug->Add(ML("Set &Next Statement") & HK("SetNextStatement"), "", "SetNextStatement", @mclick)
	miDebug->Add(ML("Show Ne&xt Statement") & HK("ShowNextStatement"), "", "ShowNextStatement", @mclick)
	
	Var miRun = mnuMain.Add(ML("&Run"), "", "Run")
	mnuStartWithCompile = miRun->Add(ML("Start With &Compile") & HK("StartWithCompile", "F5"), "StartWithCompile", "StartWithCompile", @mclick)
	mnuStart = miRun->Add(ML("&Start") & HK("Start", "Ctrl+F5"), "Start", "Start", @mclick)
	mnuBreak = miRun->Add(ML("&Break") & HK("Break", "Ctrl+Break"), "Break", "Break", @mclick)
	mnuEnd = miRun->Add(ML("&End") & HK("End"), "End", "End", @mclick)
	mnuRestart = miRun->Add(ML("&Restart") & HK("Restart", "Shift+F5"), "", "Restart", @mclick)
	mnuBreak->Enabled = False
	mnuEnd->Enabled = False
	mnuRestart->Enabled = False
	
	miXizmat = mnuMain.Add(ML("Servi&ce"), "", "Service")
	miXizmat->Add(ML("&Add-Ins") & "..." & HK("AddIns"), "", "AddIns", @mclick)
	miXizmat->Add("-")
	miXizmat->Add(ML("&Tools") & "..." & HK("Tools"), "", "Tools", @mclick)
	miXizmat->Add("-")
	Dim As My.Sys.Drawing.BitmapType Bitm
	Dim As My.Sys.Drawing.Icon Ico
	Dim As Integer Fn = FreeFile
	Dim As WString * 1024 Buff
	Dim As MenuItem Ptr mi
	Dim As ToolType Ptr tt
	#ifdef __USE_GTK__
		Open ExePath & "/Tools/ToolsX.ini" For Input Encoding "utf8" As #Fn
	#else
		Open ExePath & "/Tools/Tools.ini" For Input Encoding "utf8" As #Fn
	#endif
	Do Until EOF(Fn)
		Line Input #Fn, Buff
		If StartsWith(Buff, "Path=") Then
			tt = New ToolType
			tt->Path = Mid(Buff, 6)
			Tools.Add tt
		ElseIf tt <> 0 Then
			If StartsWith(Buff, "Name=") Then
				tt->Name = Mid(Buff, 6)
			ElseIf StartsWith(Buff, "Parameters=") Then
				tt->Parameters = Mid(Buff, 12)
			ElseIf StartsWith(Buff, "WorkingFolder=") Then
				tt->WorkingFolder = Mid(Buff, 15)
			ElseIf StartsWith(Buff, "Accelerator=") Then
				tt->Accelerator = Mid(Buff, 13)
				#ifdef __USE_GTK__
				#else
					Ico.Handle = ExtractIconW(Instance, tt->Path, NULL)
					Bitm.Handle = Ico.ToBitmap
				#endif
				mi = miXizmat->Add(tt->Name & !"\t" & tt->Accelerator, Bitm, "Tools", @mClickTool)
				mi->Tag = tt
			ElseIf StartsWith(Buff, "LoadType=") Then
				tt->LoadType = Cast(LoadTypes, Val(Mid(Buff, 10)))
			ElseIf StartsWith(Buff, "WaitComplete=") Then
				tt->WaitComplete = CDbl(Mid(Buff, 14))
			End If
		End If
	Loop
	Close #Fn
	miXizmat->Add("-")
	miXizmat->Add(ML("&Options") & HK("Options"), "Tools", "Options", @mclick)
	
	Var miHelp = mnuMain.Add(ML("&Help"), "", "Help")
	miHelp->Add(ML("&Content") & HK("Content", "F1"), "Help", "Content", @mclick)
	miHelps = miHelp->Add(ML("&Others"), "", "Others")
	Dim As WString * 1024 sTmp2
	For i As Integer = 0 To 9
		sTmp = iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		sTmp2 = iniSettings.ReadString("Helps", "Path_" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			miHelps->Add(sTmp & HK(sTmp), sTmp2, sTmp, @mClickHelp)
		End If
	Next
	miHelp->Add("-")
	miHelp->Add(ML("FreeBasic WiKi") & HK("FreeBasicWiKi"), "Help", "FreeBasicWiKi", @mclick)
	miHelp->Add(ML("FreeBasic Forums") & HK("FreeBasicForums"), "", "FreeBasicForums", @mclick)
	Var miGitHub = miHelp->Add(ML("GitHub"))
	miGitHub->Add(ML("GitHub WebSite") & HK("GitHubWebSite"), "", "GitHubWebSite", @mclick)
	miGitHub->Add("-")
	miGitHub->Add(ML("FreeBasic Repository") & HK("FreeBasicRepository"), "", "FreeBasicRepository", @mclick)
	miGitHub->Add("-")
	miGitHub->Add(ML("VisualFBEditor Repository") & HK("VisualFBEditorRepository"), "", "VisualFBEditorRepository", @mclick)
	miGitHub->Add(ML("MyFbFramework Repository") & HK("MyFbFrameworkRepository"), "", "MyFbFrameworkRepository", @mclick)
	miHelp->Add("-")
	miHelp->Add(ML("&About") & HK("About"), "About", "About", @mclick)
	
	mnuForm.ImagesList = @imgList '<m>
	mnuForm.Add(ML("Cu&t"), "Cut", "Cut", @mclick)
	mnuForm.Add(ML("&Copy"), "Copy", "Copy", @mclick)
	mnuForm.Add(ML("&Paste"), "Paste", "Paste", @mclick)
	
	mnuTabs.ImagesList = @imgList '<m>
	mnuTabs.Add(ML("&Set As Main"), "SetAsMain", "SetAsMain", @mclick)
	mnuTabs.Add("-")
	mnuTabs.Add(ML("&Close"), "Close", "Close", @mclick)
	mnuTabs.Add(ML("Close All Without Current"), "CloseAllWithoutCurrent", "CloseAllWithoutCurrent", @mclick)
	mnuTabs.Add(ML("Close &All"), "CloseAll", "CloseAll", @mclick)
	
	mnuVars.ImagesList = @imgList '<m>
	mnuVars.Add(ML("Show String"), "", "ShowString", @mclick)
	mnuVars.Add(ML("Show/Expand Variable"), "", "ShowExpandVariable", @mclick)
	
	mnuExplorer.ImagesList = @imgList '<m>
	mnuExplorer.Add(ML("&Add Files To Project"), "Add", "AddFileToProject", @mclick)
	mnuExplorer.Add(ML("&Remove Files From Project"), "Remove", "RemoveFileFromProject", @mclick)
	mnuExplorer.Add("-")
	mnuExplorer.Add(ML("&Set As Main"), "", "SetAsMain", @mclick)
	mnuExplorer.Add("-")
	mnuExplorer.Add(ML("Open Project Folder"), "", "OpenProjectFolder", @mclick)
	mnuExplorer.Add("-")
	mnuExplorer.Add(ML("Project &Properties") & "...", "", "ProjectProperties", @mclick)
	
	'txtCommands.Left = 300
	'txtCommands.AnchorRight = asAnchor
	'cboCommands.ImagesList = @imgList
	'txtCommands.Style = cbDropDown
	'txtCommands.Align = 3
	'txtCommands.Items.Add "fdfd"
	
	tbStandard.Name = "Standard"
	tbStandard.ImagesList = @imgList
	tbStandard.HotImagesList = @imgList
	tbStandard.DisabledImagesList = @imgListD
	tbStandard.Align = 3
	tbStandard.Flat = True
	tbStandard.List = True
	tbStandard.Buttons.Add tbsAutosize, "New",,@mClick, "New", , ML("New") & " (Ctrl+N)", True
	tbStandard.Buttons.Add , "Open",, @mClick, "Open", , ML("Open") & " (Ctrl+O)", True
	tbStandard.Buttons.Add , "Save",, @mClick, "Save", , ML("Save") & "..." & " (Ctrl+S)", True
	tbStandard.Buttons.Add , "SaveAll",, @mClick, "SaveAll", , ML("Save &All") & " (Shift+Ctrl+S)", True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "Undo",, @mClick, "Undo", , ML("Undo") & " (Ctrl+Z)", True
	tbStandard.Buttons.Add , "Redo",, @mClick, "Redo", , ML("Redo") & " (Ctrl+Y)", True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "Cut",, @mClick, "Cut", , ML("Cut") & " (Ctrl+X)", True
	tbStandard.Buttons.Add , "Copy",, @mClick, "Copy", , ML("Copy") & " (Ctrl+C)", True
	tbStandard.Buttons.Add , "Paste",, @mClick, "Paste", , ML("Paste") & " (Ctrl+V)", True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "Find",, @mClick, "Find", , ML("Find") & " (Ctrl+F)", True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "Format",, @mClick, "Format", , ML("Format") & " (Ctrl+Tab)", True
	tbStandard.Buttons.Add , "Unformat",, @mClick, "Unformat", , ML("Unformat") & " (Shift+Ctrl+Tab)", True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "Comment",, @mClick, "SingleComment", , ML("Single comment") & " (Ctrl+I)", True
	tbStandard.Buttons.Add , "UnComment",, @mClick, "UnComment", , ML("UnComment") & " (Shift+Ctrl+I)", True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "SyntaxCheck",, @mClick, "SyntaxCheck", , ML("Syntax Check"), True
	Var tbButton = tbStandard.Buttons.Add(tbsWholeDropdown, "Try",, @mClick, "Try", ML("Error Handling"), ML("Error Handling"), True)
	tbButton->DropDownMenu.Add ML("Numbering"), "", "NumberOn", @mclick
	tbButton->DropDownMenu.Add ML("Remove Numbering"), "", "NumberOff", @mclick
	tbButton->DropDownMenu.Add "-"
	tbButton->DropDownMenu.Add ML("Procedure numbering"), "", "ProcedureNumberOn", @mclick
	tbButton->DropDownMenu.Add ML("Remove Procedure numbering"), "", "ProcedureNumberOff", @mclick
	tbButton->DropDownMenu.Add "-"
	tbButton->DropDownMenu.Add ML("Preprocessor Numbering"), "", "PreprocessorNumberOn", @mclick
	tbButton->DropDownMenu.Add ML("Remove Preprocessor Numbering"), "", "PreprocessorNumberOff", @mclick
	tbButton->DropDownMenu.Add "-"
	tbButton->DropDownMenu.Add "On Error Resume Next", "", "OnErrorResumeNext", @mclick
	tbButton->DropDownMenu.Add "On Error Goto ...", "", "OnErrorGoto", @mclick
	tbButton->DropDownMenu.Add "On Error Goto ... Resume Next", "", "OnErrorGotoResumeNext", @mclick
	tbButton->DropDownMenu.Add ML("Remove Error Handling"), "", "RemoveErrorHandling", @mclick
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add tbsCheck Or tbsAutoSize, "UseDebugger",, @mClick, "TBUseDebugger", , ML("Use Debugger"), True
	tbStandard.Buttons.Add , "Compile",, @mClick, "Compile", , ML("Compile") & " (Ctrl+F9)", True
	Var tbMake = tbStandard.Buttons.Add(tbsAutosize Or tbsWholeDropdown, "Make",, @mClick, "Make", , ML("Make"), True)
	tbMake->DropDownMenu.Add "Make", "", "Make", @mclick
	tbMake->DropDownMenu.Add "Make clean", "", "MakeClean", @mclick
	tbStandard.Buttons.Add , "Parameters",, @mClick, "Parameters", , ML("Parameters"), True
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add , "StartWithCompile",, @mClick, "StartWithCompile", , ML("Start With Compile") & " (F5)", True
	tbStandard.Buttons.Add , "Start",, @mClick, "Start", , ML("Start") & " (Ctrl+F5)", True
	tbStandard.Buttons.Add , "Break",, @mClick, "Break", , ML("Break") & " (Ctrl+Pause)", True, 0
	tbStandard.Buttons.Add , "End",, @mClick, "End", , ML("End"), True, 0
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "Console",, @mClick, "Console", , ML("Console"), True
	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "Form",, @mClick, "Form", , ML("GUI"), True
	tbStandard.Buttons.Add tbsSeparator
	#ifdef __USE_GTK__
		tbStandard.Buttons.Add tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True
		tbStandard.Buttons.Add tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True
		#ifdef __FB_64BIT__
			tbStandard.Buttons.Item("B64")->Checked = True
		#else
			tbStandard.Buttons.Item("B32")->Checked = True
		#endif
	#else
		'#IfDef __FB_64bit__
		tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True
		'	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True, tstEnabled Or tstChecked
		'#Else
		'	tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B32",, @mClick, "B32", , ML("32-bit"), True, tstEnabled Or tstChecked
		tbStandard.Buttons.Add tbsAutosize Or tbsCheckGroup, "B64",, @mClick, "B64", , ML("64-bit"), True
		'#EndIf
		#ifdef __FB_64BIT__
			tbStandard.Buttons.Item("B64")->Checked = True
		#else
			tbStandard.Buttons.Item("B32")->Checked = True
		#endif
	#endif
End Sub

CreateMenusAndToolBars
'tbStandard.AddRange 1, @cboCommands

#ifdef __USE_GTK__
	Dim Shared progress_bar_timer_id As UInteger
	Function progress_cb(ByVal user_data As gpointer) As gboolean
		gtk_progress_bar_pulse(GTK_PROGRESS_BAR(user_data))
		'?gtk_progress_bar_get_fraction (GTK_PROGRESS_BAR(user_data))
		If progress_bar_timer_id = 0 Then
			Return False
			'Return G_SOURCE_REMOVE
		Else
			Return True
		End If
	End Function
#endif

Sub StartProgress
	prProgress.Visible = True
	#ifdef __USE_GTK__
		progress_bar_timer_id = g_timeout_add(100, @progress_cb, prProgress.Widget)
	#endif
End Sub

Sub StopProgress
	#ifdef __USE_GTK__
		If progress_bar_timer_id <> 0 Then
			'g_source_remove_ progress_bar_timer_id
			progress_bar_timer_id = 0
		End If
	#endif
	prProgress.Visible = False
End Sub

stBar.Align = 4
stBar.Add ML("Press F1 for get more information")
stBar.Panels[0]->Width = frmMain.ClientWidth - 560
stBar.Add Space(20)
stBar.Panels[1]->Width = 240
stBar.Add Space(20)
stBar.Panels[2]->Width = 160
stBar.Add "UTF-8"
stBar.Panels[3]->Width = 50
stBar.Add "CR+LF"
stBar.Panels[4]->Width = 50
stBar.Add "NUM"
Var spProgress = stBar.Add("")
spProgress->Width = 100

prProgress.Visible = False
prProgress.Marquee = True
prProgress.SetMarquee True, 100
#ifdef __USE_GTK__
	prProgress.Height = 30
	gtk_box_pack_end (GTK_BOX (gtk_statusbar_get_message_area (gtk_statusbar(stBar.Widget))), prProgress.Widget, False, True, 10)
#else
	prProgress.Top = 3
	prProgress.Parent = @stBar
#endif

'stBar.Add ""
'stBar.Panels[1]->Alignment = 1

tbExplorer.ImagesList = @imgList
tbExplorer.Align = 3
tbExplorer.Buttons.Add , "Add",, @mClick, "AddFileToProject", , ML("Add Files To Project"), True
tbExplorer.Buttons.Add , "Remove",, @mClick, "RemoveFileFromProject", , ML("Remove Files From Project"), True
tbExplorer.Buttons.Add tbsSeparator
tbExplorer.Buttons.Add tbsCheck, "Folder",, @mClick, "Folder", , ML("Show Folders"), True
tbExplorer.Flat = True

Sub tbFormClick(ByRef Sender As My.Sys.Object)
	Var bFlag = Cast(ToolButton Ptr, @Sender)->Checked
	Select Case Sender.ToString
	Case "Text"
		If bFlag Then
			tbToolBox.Style = tpsBothHorizontal
		Else
			tbToolBox.Style = tpsIcons
		End If
		'tbToolBox.RecreateWnd
	End Select
	tpShakl_Resize *tpShakl, tpShakl->Width, tpShakl->Height
End Sub

tbForm.ImagesList = @imgList
tbForm.Align = 3
tbForm.List = True
tbForm.Buttons.Add tbsCheck, "Label", , @tbFormClick, "Text", "", ML("Text"), , tstChecked Or tstEnabled
tbForm.Buttons.Add tbsSeparator
tbForm.Buttons.Add , "Component", , ,"", "", ML("Add Components")
tbForm.Flat = True

tabLeftWidth = 150
tabRightWidth = 150
tabBottomHeight = 150

splLeft.Align = 1
splRight.Align = 2
splBottom.Align = 4

Function GetLeftClosedStyle As Boolean
	Return Not tabLeft.TabPosition = tpTop
End Function

Sub SetLeftClosedStyle(Value As Boolean)
	If Value Then
		'tabLeft.Align = 1
		tabLeft.TabPosition = tpLeft
		tabLeft.TabIndex = -1
		#ifdef __USE_GTK__
			pnlLeft.Width = 30
		#else
			pnlLeft.Width = tabLeft.ItemWidth(0) + 2
		#endif
		splLeft.Visible = False
	Else
		pnlLeft.Width = tabLeftWidth
		'tabLeft.Width = tabLeftWidth
		tabLeft.TabPosition = tpTop
		'tabLeft.Align = 5
		splLeft.Visible = True
	End If
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
End Sub

Sub tabLeft_DblClick(ByRef Sender As Control)
	SetLeftClosedStyle Not GetLeftClosedStyle
End Sub

Sub scrTool_Scroll(ByRef Sender As Control, ByRef NewPos As Integer)
	tbToolBox.Top = tbForm.Height - NewPos
End Sub

scrTool.Style = sbVertical
scrTool.Align = 2
scrTool.ArrowChangeSize = tbToolBox.ButtonHeight
scrTool.PageSize = 3 * scrTool.ArrowChangeSize
scrTool.OnScroll = @scrTool_Scroll
scrTool.OnMouseWheel = @scrTool_MouseWheel
scrTool.OnResize = @tpShakl_Resize

Sub tvExplorer_NodeActivate(ByRef Sender As Control, ByRef Item As TreeNode)
	#ifdef __USE_GTK__
		If Item.Nodes.Count > 0 Then
			If Item.IsExpanded Then
				Item.Collapse
			Else
				Item.Expand
			End If
		End If
	#endif
	If Item.ImageKey = "Opened" Then Exit Sub
	If Item.ImageKey = "Project" AndAlso Item.ParentNode = 0 Then Exit Sub
	Dim As ExplorerElement Ptr ee = Item.Tag
	If ee <> 0 AndAlso _
		(EndsWith(*ee->FileName, ".exe") OrElse EndsWith(*ee->FileName, ".dll") OrElse EndsWith(*ee->FileName, ".dll.a") OrElse EndsWith(*ee->FileName, ".so") OrElse _
		EndsWith(*ee->FileName, ".png") OrElse EndsWith(*ee->FileName, ".jpg") OrElse EndsWith(*ee->FileName, ".bmp") OrElse EndsWith(*ee->FileName, ".ico") OrElse _
		EndsWith(*ee->FileName, ".chm") OrElse EndsWith(*ee->FileName, ".zip") OrElse EndsWith(*ee->FileName, ".7z") OrElse EndsWith(*ee->FileName, ".rar")) Then
		Shell *ee->FileName
		Exit Sub
	End If
	Dim t As Boolean
	For i As Integer = 0 To ptabCode->TabCount - 1
		If Cast(TabWindow Ptr, ptabCode->Tabs[i])->tn = @Item Then
			ptabCode->TabIndex = ptabCode->Tabs[i]->Index
			t = True
			Exit For
		End If
	Next i
	If Not t Then
		If ee <> 0 Then AddTab *ee->FileName, , @Item
	End If
End Sub

Sub tvExplorer_NodeExpanding(ByRef Sender As Control, ByRef Item As TreeNode)
	If Item.ImageKey <> "Opened" Then Exit Sub
	ExpandFolder @Item
End Sub

Sub tvExplorer_DblClick(ByRef Sender As Control)
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	If tn = 0 Then Exit Sub
	tvExplorer_NodeActivate Sender, *tn
	'	If tn->ImageKey = "Project" Then Exit Sub
	'	Dim t As Boolean
	'	For i As Integer = 0 To ptabCode->TabCount - 1
	'		If Cast(TabWindow Ptr, ptabCode->Tabs[i])->tn = tn Then
	'			ptabCode->TabIndex = ptabCode->Tabs[i]->Index
	'			t = True
	'			Exit For
	'		End If
	'	Next i
	'	If Not t Then
	'		If tn->Tag <> 0 Then AddTab *Cast(ExplorerElement Ptr, tn->Tag)->FileName, , tn
	'	End If
	'	', Why the tvExplorer.SelectedNode changed after add tab
	'	tvExplorer.SelectedNode = tn
End Sub

Sub tvExplorer_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
	#ifdef __USE_GTK__
		Select Case Key
		Case GDK_KEY_LEFT
			
		End Select
	#else
		If Key = VK_Return Then tvExplorer_DblClick Sender
	#endif
End Sub

Function GetParentNode(tn As TreeNode Ptr) As TreeNode Ptr
	If tn = 0 OrElse tn->ParentNode = 0 Then
		Return tn
	ElseIf tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement Then
		Return tn
	Else
		Return GetParentNode(tn->ParentNode)
	End If
End Function

Sub tvExplorer_SelChange(ByRef Sender As TreeView, ByRef Item As TreeNode)
	Static OldParentNode As TreeNode Ptr
	Dim As TreeNode Ptr ptn = tvExplorer.SelectedNode
	If ptn = 0 Then Exit Sub 'David Change For Safty
	ptn = GetParentNode(ptn)
	If OldParentNode <> ptn Then
		OldParentNode = ptn
		MainNode = ptn
		lblLeft.Text = ML("Main Project") & ": " & MainNode->Text
		mLoadLog = False
		mLoadToDO = False
		If ptn->ImageKey <> "Project" Then  'David Change For compile Single .bas file
			MainNode = 0
			lblLeft.Text = ML("Main Project") & ": " & ML("Automatic")
		Else
			If mStartLoadSession = False Then
				If ptabBottom->TabIndex = 4 AndAlso Not mLoadLog Then
					If mChangeLogEdited AndAlso mChangelogName<> "" Then
						txtChangeLog.SaveToFile(mChangelogName)  ' David Change
						mChangeLogEdited = False
					End If
					mChangelogName = ExePath & Slash & StringExtract(MainNode->Text, ".") & "_Change.log"
					txtChangeLog.Text = "Waiting...... "
					If Dir(mChangelogName)<>"" AndAlso mChangelogName<> "" Then
						txtChangeLog.LoadFromFile(mChangelogName) ' David Change
						#ifndef __USE_GTK__
							If InStr(txtChangeLog.Text,Chr(13,10)) < 1 Then txtChangeLog.Text = Replace(txtChangeLog.Text,Chr(10),Chr(13,10))
						#endif
					Else
						txtChangeLog.Text = ""
					End If
					mLoadLog = True
				ElseIf ptabBottom->TabIndex = 3  AndAlso Not mLoadToDO Then
					ThreadCreate(@FindToDoSub, MainNode)
					mLoadToDo = True
				End If
			End If
		End If
	End If
End Sub

tvExplorer.Images = @imgList
tvExplorer.SelectedImages = @imgList
tvExplorer.Align = 5
tvExplorer.HideSelection = False
'tvExplorer.Sorted = True
'tvExplorer.OnDblClick = @tvExplorer_DblClick
tvExplorer.OnNodeActivate = @tvExplorer_NodeActivate
tvExplorer.OnNodeExpanding = @tvExplorer_NodeExpanding
tvExplorer.OnKeyDown = @tvExplorer_KeyDown
tvExplorer.OnSelChanged = @tvExplorer_SelChange
tvExplorer.ContextMenu = @mnuExplorer

Sub tabLeft_SelChange(ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
	#else
		If tabLeft.TabPosition = tpLeft And tabLeft.TabIndex <> -1 Then
	#endif
		tabLeft.SetFocus
		pnlLeft.Width = tabLeftWidth
		pnlLeft.RequestAlign
		splLeft.Visible = True
		'#IfNDef __USE_GTK__
		frmMain.RequestAlign
		'#EndIf
	End If
End Sub

Sub tabLeft_Click(ByRef Sender As Control)
	If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
		tabLeft.SetFocus
		pnlLeft.Width = tabLeftWidth
		pnlLeft.RequestAlign
		splLeft.Visible = True
		frmMain.RequestAlign
	End If
End Sub

Sub pnlLeft_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlLeft.Width <> 30 Then tabLeftWidth = NewWidth ': tabLeft.Width = pnlLeft.Width
	#else
		If tabLeft.TabIndex <> -1 Then tabLeftWidth = pnlLeft.Width
	#endif
End Sub

pnlLeft.Name = "pnlLeft"
pnlLeft.Align = 1
pnlLeft.Width = tabLeftWidth
pnlLeft.OnReSize = @pnlLeft_Resize

tabLeft.Name = "tabLeft"
tabLeft.Width = tabLeftWidth
tabLeft.Align = 5
tabLeft.OnClick = @tabLeft_Click
tabLeft.OnDblClick = @tabLeft_DblClick
tabLeft.OnSelChange = @tabLeft_SelChange
pnlLeft.Add @tabLeft
'tabLeft.TabPosition = tpLeft

Var tpLoyiha = tabLeft.AddTab(ML("Project"))

tpShakl = tabLeft.AddTab(ML("Toolbox")) ' ToolBox is better than "Form"
tpShakl->Name = "tpShakl"

lblLeft.Text = ML("Main File") & ": " & ML("Automatic")
lblLeft.Align = 4

tpLoyiha->Add @tbExplorer
tpLoyiha->Add @lblLeft
tpLoyiha->Add @tvExplorer
#ifndef __USE_GTK__
	tpShakl->Add @scrTool
#endif
tpShakl->Add @tbToolBox
tpShakl->Add @tbForm
tpShakl->OnReSize = @tpShakl_Resize
'tabLeft.Tabs[1]->Style = tabLeft.Tabs[1]->Style Or ES_AUTOVSCROLL or WS_VSCROLL

'pnlLeft.Width = 153
'pnlLeft.Align = 1
'pnlLeft.AddRange 1, @tabLeft

Sub tbProperties_ButtonClick(Sender As My.Sys.Object)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Select Case Sender.ToString
	Case "Properties"
		
	End Select
End Sub

tbProperties.ImagesList = @imgList
tbProperties.Align = 3
tbProperties.Buttons.Add tbsCheck, "Categorized", , @tbProperties_ButtonClick, "PropertyCategory", "", ML("Categorized"), , tstEnabled Or tstChecked
tbProperties.Buttons.Add tbsSeparator
tbProperties.Buttons.Add , "Property", , @tbProperties_ButtonClick, "Properties", "", ML("Properties"), , tstEnabled
tbProperties.Flat = True

tbEvents.ImagesList = @imgList
tbEvents.Align = 3
tbEvents.Buttons.Add tbsCheck, "Categorized", , @tbProperties_ButtonClick, "EventCategory", "", ML("Categorized"), , tstEnabled
tbEvents.Buttons.Add tbsSeparator
tbEvents.Flat = True

Sub txtPropertyValue_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	
End Sub

Sub txtPropertyValue_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	If Key = 13 Then
		lvProperties.SetFocus
	End If
End Sub

Sub txtPropertyValue_KeyPress(ByRef Sender As Control, Key As Byte)
	
End Sub

'txtPropertyValue.BorderStyle = 0
txtPropertyValue.Visible = False
txtPropertyValue.WantReturn = True
txtPropertyValue.OnKeyDown = @txtPropertyValue_KeyDown
txtPropertyValue.OnKeyUp = @txtPropertyValue_KeyUp
txtPropertyValue.OnKeyPress = @txtPropertyValue_KeyPress
txtPropertyValue.OnLostFocus = @txtPropertyValue_LostFocus

cboPropertyValue.OnKeyUp = @txtPropertyValue_KeyUp
cboPropertyValue.OnChange = @cboPropertyValue_Change
cboPropertyValue.Left = -1
cboPropertyValue.Top = -2

pnlPropertyValue.Visible = False
pnlPropertyValue.Add @cboPropertyValue

Dim Shared CtrlEdit As Control Ptr
Dim Shared Cpnt As Component Ptr

Sub lvProperties_SelectedItemChanged(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 OrElse tb->Des->ReadPropertyFunc = 0 Then Exit Sub
	Dim As Rect lpRect
	'Dim As TreeListViewItem Ptr Item = lvProperties.ListItems.Item(ItemIndex)
	lvProperties.SetFocus
	txtPropertyValue.Visible = False
	pnlPropertyValue.Visible = False
	#ifndef __USE_GTK__
		ListView_GetSubItemRect(lvProperties.Handle, Item->GetItemIndex, 1, LVIR_BOUNDS, @lpRect)
	#endif
	Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), GetItemText(Item))
	If te = 0 Then Exit Sub
	#ifndef __USE_GTK__
		If LCase(te->TypeName) = "boolean" Then
			CtrlEdit = @pnlPropertyValue
			cboPropertyValue.Clear
			cboPropertyValue.AddItem " false"
			cboPropertyValue.AddItem " true"
			cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item->Text(1))
		ElseIf LCase(te->TypeName) = "integer" AndAlso CInt(te->EnumTypeName <> "") AndAlso CInt(GlobalEnums.Contains(te->EnumTypeName)) Then
			CtrlEdit = @pnlPropertyValue
			cboPropertyValue.Clear
			Var tbi = Cast(TypeElement Ptr, GlobalEnums.Object(GlobalEnums.IndexOf(te->EnumTypeName)))
			If tbi Then
				For i As Integer = 0 To tbi->Elements.Count - 1
					cboPropertyValue.AddItem " " & i & " - " & tbi->Elements.Item(i)
				Next i
				If Val(Item->Text(1)) >= 0 AndAlso Val(Item->Text(1)) <= tbi->Elements.Count - 1 Then
					cboPropertyValue.ItemIndex = Val(Item->Text(1))
				End If
			End If
		ElseIf IsBase(te->TypeName, "Component") Then
			CtrlEdit = @pnlPropertyValue
			cboPropertyValue.Clear
			For i As Integer = 1 To tb->cboClass.Items.Count - 1
				Cpnt = tb->cboClass.Items.Item(i)->Object
				If Cpnt <> 0 Then
					If CInt(te->EnumTypeName <> "") Then
						If (CInt(Cpnt->ClassName = Trim(te->EnumTypeName)) OrElse CInt(IsBase(Cpnt->ClassName, Trim(te->EnumTypeName)))) Then
							cboPropertyValue.AddItem " " & Cpnt->Name
						End If
					ElseIf CInt(Cpnt->ClassName = WithoutPtr(Trim(te->TypeName))) OrElse CInt(IsBase(Cpnt->ClassName, WithoutPtr(Trim(te->TypeName)))) Then
						cboPropertyValue.AddItem " " & Cpnt->Name
					End If
				End If
			Next i
			cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item->Text(1))
		Else
			Dim tbi As TypeElement Ptr
			If Comps.Contains(te->TypeName) Then
				tbi = Cast(TypeElement Ptr, Comps.Object(Comps.IndexOf(te->TypeName)))
			ElseIf GlobalEnums.Contains(te->TypeName) Then
				tbi = Cast(TypeElement Ptr, GlobalEnums.Object(GlobalEnums.IndexOf(te->TypeName)))
			End If
			If tbi AndAlso tbi->ElementType = "Enum" Then
				CtrlEdit = @pnlPropertyValue
				cboPropertyValue.Clear
				For i As Integer = 0 To tbi->Elements.Count - 1
					cboPropertyValue.AddItem " " & i & " - " & tbi->Elements.Item(i)
				Next i
				If Val(Item->Text(1)) >= 0 AndAlso Val(Item->Text(1)) <= tbi->Elements.Count - 1 Then
					cboPropertyValue.ItemIndex = Val(Item->Text(1))
				End If
			Else
				CtrlEdit = @txtPropertyValue
				CtrlEdit->Text = Item->Text(1)
			End If
		End If
		CtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
		If CtrlEdit = @pnlPropertyValue Then cboPropertyValue.Width = lpRect.Right - lpRect.Left + 2
		CtrlEdit->Visible = True
	#endif
	If te->Comment <> 0 Then
		txtLabelProperty.Text = te->Comment
	Else
		txtLabelProperty.Text = ""
	End If
End Sub

Sub lvEvents_SelectedItemChanged(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 OrElse tb->Des->ReadPropertyFunc = 0 Then Exit Sub
	Var te = GetPropertyType(WGet(tb->Des->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), GetItemText(Item))
	If te = 0 Then Exit Sub
	If te->Comment <> 0 Then
		txtLabelEvent.Text = te->Comment
	Else
		txtLabelEvent.Text = ""
	End If
End Sub

'Sub lvProperties_ItemDblClick(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
'    If Item <> 0 Then ClickProperty Item->Index
'End Sub

Sub lvEvents_ItemDblClick(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Dim As TabWindow Ptr tb = tabRight.Tag
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	If Item <> 0 Then FindEvent tb->Des->SelectedControl, Item->Text(0)
End Sub

Sub lvProperties_EndScroll(ByRef Sender As TreeListView)
	If CtrlEdit = 0 Then Exit Sub
	If lvProperties.SelectedItem = 0 Then
		CtrlEdit->Visible = False
	Else
		Dim As Rect lpRect
		#ifndef __USE_GTK__
			ListView_GetSubItemRect(lvProperties.Handle, lvProperties.SelectedItem->Index, 1, LVIR_BOUNDS, @lpRect)
		#endif
		'If lpRect.Top < lpRect.Bottom - lpRect.Top Then
		'    txtPropertyValue.Visible = False
		'Else
		CtrlEdit->SetBounds lpRect.Left, lpRect.Top, lpRect.Right - lpRect.Left, lpRect.Bottom - lpRect.Top - 1
		CtrlEdit->Visible = True
		'End If
	End If
End Sub

Dim Shared lvWidth As Integer

Sub lvProperties_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvProperties.Width - 22
	lvProperties.Columns.Column(1)->Width = (lvWidth - 32) / 2
	lvProperties.Columns.Column(0)->Width = lvWidth - (lvWidth - 32) / 2
	txtPropertyValue.Width = (lvWidth - 32) / 2
	pnlPropertyValue.Width = (lvWidth - 32) / 2
	cboPropertyValue.Width = (lvWidth - 32) / 2 + 2
	lvProperties_EndScroll(*Cast(TreeListView Ptr, @Sender))
End Sub

Sub lvEvents_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvEvents.Width - 22
	lvEvents.Columns.Column(0)->Width = lvWidth / 2
	lvEvents.Columns.Column(1)->Width = lvWidth / 2
	'lvEvents_EndScroll(*Cast(ListView Ptr, @Sender))
End Sub

'Sub lvProperties_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
'    Dim iItem As Integer
'	Dim dwState As Integer
'	Dim iIndent As Integer
'	Dim iIndentChild As Integer
'	' Get the selected item...
'	#IfNDef __USE_GTK__
'		iItem = ListView_GetNextItem(lvProperties.Handle, -1, LVNI_FOCUSED Or LVNI_SELECTED)
'	#EndIf
'	If (iItem <> -1) Then
'    ' Get the item's indent and state values
'	#IfNDef __USE_GTK__
'		dwState = Listview_GetItemStateEx(lvProperties.Handle, iItem, iIndent)
'		Select Case Key
'		  ' ========================================================
'		  ' The right arrow key expands the selected item, then selects the current
'		  ' item's first child
'		  Case VK_RIGHT
'			' If the item is collaped, expanded it, otherwise select
'			' the first child of the selected item (if any)
'			If (dwState = 1) Then
'			  AddChildItems(iItem, iIndent)
'			ElseIf (dwState = 2) Then
'			  If iItem < lvProperties.ListItems.Count - 1 AndAlso lvProperties.ListItems.Item(iItem + 1)->Indent > iIndent Then
'				  ListView_SetItemState(lvProperties.Handle, iItem + 1, LVIS_FOCUSED Or LVIS_SELECTED, LVIS_FOCUSED Or LVIS_SELECTED)
'			  End If
'			  'iItem = ListView_GetRelativeItem(m_hwndLV, iItem, lvriChild)
'			  'If (iItem <> -1) Then Call ListView_SetFocusedItem(lvProperties.Handle, iItem)
'			End If
'		  ' ========================================================
'		  ' The left arrow key collapses the selected item, then selects the current
'		  ' item's parent. The backspace key only selects the current item's parent
'		  Case VK_LEFT, VK_BACK
'			' If vbKeyLeft and the item is expanded, collaped it, otherwise select
'			' the parent of the selected item (if any)
'			If (Key = VK_LEFT) And (dwState = 2) Then
'				RemoveChildItems(iItem, iIndent)
'			Else
'				For i As Integer = iItem To 0 Step -1
'					dwState = Listview_GetItemStateEx(lvProperties.Handle, i, iIndentChild)
'					If iIndentChild < iIndent Then
'						ListView_SetItemState(lvProperties.Handle, i, LVIS_FOCUSED Or LVIS_SELECTED, LVIS_FOCUSED Or LVIS_SELECTED)
'						Exit For
'					End If
'				Next
'	'          iItem = ListView_GetRelativeItem(m_hwndLV, iItem, lvriParent)
'	'          If (iItem <> LVI_NOITEM) Then
'	'            Call ListView_SetFocusedItem(m_hwndLV, iItem)
'	'            Call ListView_EnsureVisible(m_hwndLV, iItem, False)
'	'          End If
'			End If
'		End Select   ' KeyCode
'	#EndIf
'  End If   ' (iItem <> LVI_NOITEM)
'End Sub

Sub lvEvents_KeyDown(ByRef Sender As Control, ByRef Item As TreeListViewItem Ptr)
	
End Sub

Sub lvProperties_KeyPress(ByRef Sender As Control, Key As Byte)
	txtPropertyValue.Text = WChr(Key)
	txtPropertyValue.SetFocus
	txtPropertyValue.SetSel 1, 1
	Key = 0
End Sub

Sub lvProperties_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_Return: txtPropertyValue.SetFocus
		Case VK_Left, VK_Right, VK_Up, VK_Down, VK_NEXT, VK_PRIOR
		End Select
	#endif
	'Key = 0
End Sub

imgListStates.AddPng "Collapsed", "Collapsed"
imgListStates.AddPng "Expanded", "Expanded"
imgListStates.AddPng "Property", "Property"
imgListStates.AddPng "Event", "Event"

lvProperties.Align = 5
'lvProperties.Sort = ssSortAscending
lvProperties.StateImages = @imgListStates
lvProperties.SmallImages = @imgListStates
'lvProperties.ColumnHeaderHidden = True
lvProperties.Columns.Add ML("Property"), , 70
lvProperties.Columns.Add ML("Value"), , 50, , True
lvProperties.Add @txtPropertyValue
lvProperties.Add @pnlPropertyValue
lvProperties.OnSelectedItemChanged = @lvProperties_SelectedItemChanged
lvProperties.OnEndScroll = @lvProperties_EndScroll
lvProperties.OnResize = @lvProperties_Resize
'lvProperties.OnMouseDown = @lvProperties_MouseDown
'lvProperties.OnKeyDown = @lvProperties_KeyDown
'lvProperties.OnItemDblClick = @lvProperties_ItemDblClick
lvProperties.OnKeyUp = @lvProperties_KeyUp
lvProperties.OnCellEditing = @lvProperties_CellEditing
lvProperties.OnCellEdited = @lvProperties_CellEdited
lvProperties.OnItemExpanding = @lvProperties_ItemExpanding

lvEvents.Align = 5
lvEvents.Sort = ssSortAscending
lvEvents.Columns.Add ML("Event"), , 70
lvEvents.Columns.Add ML("Value"), , -2
lvEvents.OnSelectedItemChanged = @lvEvents_SelectedItemChanged
lvEvents.OnItemKeyDown = @lvEvents_KeyDown
#ifdef __USE_GTK__
	lvEvents.OnItemActivate = @lvEvents_ItemDblClick
#else
	lvEvents.OnItemDblClick = @lvEvents_ItemDblClick
#endif
lvEvents.OnResize = @lvEvents_Resize
lvEvents.SmallImages = @imgListStates

splProperties.Align = 4

splEvents.Align = 4

txtLabelProperty.Height = 50
txtLabelProperty.Align = 4
txtLabelProperty.Multiline = True
txtLabelProperty.ReadOnly = True
#ifndef __USE_GTK__
	txtLabelProperty.BackColor = clBtnFace
#endif
txtLabelProperty.WordWraps = True

txtLabelEvent.Height = 50
txtLabelEvent.Align = 4
txtLabelEvent.Multiline = True
txtLabelEvent.ReadOnly = True
#ifndef __USE_GTK__
	txtLabelEvent.BackColor = clBtnFace
#endif
txtLabelEvent.WordWraps = True

Function GetRightClosedStyle As Boolean
	Return Not tabRight.TabPosition = tpTop
End Function

Sub SetRightClosedStyle(Value As Boolean)
	If Value Then
		tabRight.TabPosition = tpRight
		tabRight.TabIndex = -1
		#ifdef __USE_GTK__
			pnlRight.Width = 30
		#else
			pnlRight.Width = tabRight.ItemWidth(0) + 2
		#endif
		splRight.Visible = False
		pnlRight.RequestAlign
	Else
		tabRight.TabPosition = tpTop
		tabRight.Width = tabRightWidth
		pnlRight.Width = tabRightWidth
		'pnlRight.RequestAlign
		splRight.Visible = True
		
	End If
	frmMain.RequestAlign
End Sub

Sub tabRight_DblClick(ByRef Sender As Control)
	SetRightClosedStyle Not GetRightClosedStyle
End Sub

Sub tabRight_SelChange(ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If tabRight.TabPosition = tpRight And pnlRight.Width = 30 Then
	#else
		If tabRight.TabPosition = tpRight And tabRight.TabIndex <> -1 Then
	#endif
		tabRight.SetFocus
		pnlRight.Width = tabRightWidth
		pnlRight.RequestAlign
		splRight.Visible = True
		frmMain.RequestAlign
	End If
End Sub

tvVar.Align = 5
tvPrc.Align = 5
tvThd.Align = 5
tvWch.Align = 5

tvVar.ContextMenu = @mnuVars

Sub tabRight_Click(ByRef Sender As Control)
	If tabRight.TabPosition = tpRight And pnlRight.Width = 30 Then
		tabRight.SetFocus
		pnlRight.Width = tabRightWidth
		pnlRight.RequestAlign
		splRight.Visible = True
		frmMain.RequestAlign
	End If
End Sub

Sub pnlRight_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlRight.Width <> 30 Then tabRightWidth = NewWidth: tabRight.SetBounds(0, 0, tabRightWidth, NewHeight)
	#else
		If tabRight.TabIndex <> -1 Then tabRightWidth = tabRight.Width
	#endif
End Sub

pnlRight.Align = 2
pnlRight.Width = tabRightWidth
pnlRight.OnResize = @pnlRight_Resize

tabRight.Width = tabRightWidth
#ifdef __USE_GTK__
	tabRight.Align = 2
#else
	tabRight.Align = 5
#endif
tabRight.OnClick = @tabRight_Click
tabRight.OnDblClick = @tabRight_DblClick
tabRight.OnSelChange = @tabRight_SelChange
'tabRight.TabPosition = tpRight
tabRight.AddTab(ML("Properties"))
tabRight.Tabs[0]->Add @tbProperties
tabRight.Tabs[0]->Add @txtLabelProperty
tabRight.Tabs[0]->Add @splProperties
tabRight.Tabs[0]->Add @lvProperties
tabRight.AddTab(ML("Events"))
tabRight.Tabs[1]->Add @tbEvents
tabRight.Tabs[1]->Add @txtLabelEvent
tabRight.Tabs[1]->Add @splEvents
tabRight.Tabs[1]->Add @lvEvents
pnlRight.Add @tabRight

'pnlRight.Width = 153
'pnlRight.Align = 2
'pnlRight.AddRange 1, @tabRight

'ptabCode->Images.AddIcon bmp

Sub tabCode_SelChange(ByRef Sender As TabControl, NewIndex As Integer)
	Static tbOld As TabWindow Ptr
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, Sender.Tab(NewIndex))
	If tb = 0 Then Exit Sub
	If tb = tbOld Then Exit Sub
	tb->tn->SelectItem
	Static OldIndex As Integer
	If OldIndex <> NewIndex Then
		If pfFind->Visible = True AndAlso pfFind->OptFindinCurrFile.Checked Then
			wLet gSearchSave,""
			pfFind->FindAll plvSearch, 2,, False
		End If
	End If
	If frmMain.ActiveControl <> tb And frmMain.ActiveControl <> @tb->txtCode Then tb->txtCode.SetFocus
	lvProperties.ListItems.Clear
	'tb->FillAllProperties
	If tb->FileName = "" Then
		frmMain.Caption = tb->Caption & " - " & pApp->Title
	Else
		frmMain.Caption = tb->FileName & " - " & pApp->Title
	End If
	tbOld = tb
End Sub

ptabCode->Images = @imgList
ptabCode->Align = 5
ptabCode->Reorderable = True
ptabCode->OnPaint = @tabCode_Paint
ptabCode->OnSelChange = @tabCode_SelChange
ptabCode->ContextMenu = @mnuTabs

txtOutput.Name = "txtOutput"
txtOutput.Align = 5
txtOutput.Multiline = True
txtOutput.ScrollBars = 3
txtOutput.OnDblClick = @txtOutput_DblClick

Sub txtImmediate_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Integer iLine = txtImmediate.GetLineFromCharIndex(txtImmediate.SelStart)
	Dim As WString Ptr sLine ' = @txtImmediate.Lines(iLine) '  for got wrong value
	Dim bCtrl As Boolean
	#ifdef __USE_GTK__
		bCtrl = Shift And GDK_Control_MASK
	#else
		bCtrl = GetKeyState(VK_CONTROL) And 8000
	#endif
	'
	wLet sLine, txtImmediate.Lines(iLine)
	If CInt(Not bCtrl) AndAlso CInt(WGet(sLine) <> "") AndAlso CInt(Not StartsWith(Trim(WGet(sLine)),"'")) Then
		If Key = Keys.Enter Then
			'
			SaveAll
			Dim As Integer Fn =FreeFile
			Open ExePath & "/Temp/FBTemp.bas" For Output Encoding "utf-8" As #Fn
			'Print #Fn, "#Include Once " + Chr(34) + "mff/SysUtils.bas"+Chr(34)
			For i As Integer =0 To iLine
				If StartsWith(Trim(LCase(txtImmediate.Lines(i))),"import ") Then Print #Fn, Mid(Trim(txtImmediate.Lines(i)),7)
			Next
			If CInt(StartsWith(Trim(*sLine),"?")) Then  '
				Print #Fn, "Print Str(" & Trim(Mid(*sLine,2)) & " & Space(1024))" ' space for wstring
			ElseIf CInt(StartsWith(Trim(LCase(*sLine)),"print ")) Then
				Print #Fn, "Print Str(" & Trim(Mid(*sLine,6)) & " & Space(1024))" 'space for wstring
			Else
				Print #Fn, "Print Str(" & Trim(*sLine) & " & Space(1024))" 'space for wstring
			End If
			Close #Fn
			Dim As WString Ptr FbcExe, ExeName
			If tbStandard.Buttons.Item("B32")->Checked Then
				FbcExe = Compiler32Path
			Else
				FbcExe = Compiler32Path
			End If
			PipeCmd "", """" & *FbcExe & """ -b """ & ExePath & "/Temp/FBTemp.bas"" -i """ & ExePath & "/" & *MFFPath & """ > """ & ExePath & "/Temp/debug_compil.log"" 2> """ & ExePath & "/Temp/debug_compil2.log"""
			Dim As WString Ptr LogText
			Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
			Dim As WString Ptr ErrFileName, ErrTitle
			Dim As Integer nLen, nLen2
			WLet LogText, ""
			Fn =FreeFile
			Dim Result As Integer=-1 '
			Result = Open(ExePath & "/Temp/debug_compil.log" For Input As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/debug_compil.log" For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/debug_compil.log" For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result =  Open(ExePath & "/Temp/debug_compil.log" For Input Encoding "utf-8" As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, Buff
					SplitError(Trim(Buff), ErrFileName, ErrTitle, iLine)
					WAdd LogText, *ErrTitle & !"\r"
				Wend
			End If
			Close #Fn
			Fn =FreeFile
			Result =-1
			Result = Open(ExePath & "/Temp/debug_compil2.log" For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/debug_compil2.log" For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/debug_compil2.log" For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/debug_compil2.log" For Input As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, buff
					WAdd LogText, Trim(Buff) & !"\r"
				Wend
			End If
			Close #Fn
			Key = 0
			If WGet(LogText) <> "" Then
				MsgBox !"Compile error:\r\r" & *LogText, , mtWarning
			Else
				#ifdef __USE_GTK__
					WLet ExeName, ExePath & "/Temp/FBTemp"
				#else
					WLet ExeName, ExePath & "\Temp\FBTemp.exe" ' > output.txt
				#endif
				PipeCmd "",  *ExeName
				Fn =FreeFile
				If Open Pipe(*ExeName For Input Encoding "utf-8" As #Fn) = 0 Then '
					Dim As Integer i
					While Not EOF(Fn)
						Line Input #Fn, Buff
						i = txtImmediate.GetCharIndexFromLine(iLine) + txtImmediate.GetLineLength(iLine)
						txtImmediate.SetSel i, i
						txtImmediate.SelText = WChr(13,10) + Trim(Buff)
						ptabBottom->Update
						txtImmediate.Update
						frmMain.Update
					Wend
				End If
				Close #Fn
				Kill *ExeName
			End If
			WDeallocate ExeName
			WDeallocate LogText
			WDeallocate ErrFileName
			WDeallocate ErrTitle
		End If
	End If
	WDeallocate sLine '
	If Not EndsWith(txtImmediate.Text, !"\r") Then txtImmediate.Text &= !"\r"
End Sub

txtImmediate.Align = 5
txtImmediate.Multiline = True
txtImmediate.ScrollBars = 3
txtImmediate.OnKeyDown = @txtImmediate_KeyDown
'
txtImmediate.BackColor=cLBlack
txtImmediate.Font.Color=cLWhite
txtImmediate.Text = "import #Include Once " + Chr(34) + "mff/SysUtils.bas"+Chr(34) & WChr(13,10) & WChr(13,10)

Sub txtChangeLog_KeyDown(ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim bCtrl As Boolean
	#ifdef __USE_GTK__
		bCtrl = Shift And GDK_Control_MASK
	#else
		bCtrl = GetKeyState(VK_CONTROL) And 8000
	#endif
	If CInt(Not bCtrl) OrElse Shift <> 1 Then mChangeLogEdited = True
	If CInt(bCtrl) And key =13 Then
		txtChangeLog.SelText = Format(Now, "yyyy/mm/dd hh:mm:ss") & !"\t" & !"\t"
		mChangeLogEdited = True
	ElseIf CInt(bCtrl) And Shift And (key =108 Or key =76) Then
		Dim As TabWindow Ptr tb= Cast(TabWindow Ptr, pTabCode->SelectedTab)
		If tb <> 0 Then
			'txtChangeLog.SelText =" {" & Replace(tb->Caption,"*","") & "|" & tb->cboFunction.Text & " Ln" & Val(Trim(Replace(pstBar->Panels[1]->Caption,ML("Row"),""))) & "}"
			txtChangeLog.SelText =" {" & tb->Caption & "|" & tb->cboFunction.Text & " Ln" & Val( pstBar->Panels[1]->Caption)
			mChangeLogEdited = True
			
		End If
	End If
End Sub
'mChangeLogEdited
txtChangeLog.Align = 5
txtChangeLog.Multiline = True
txtChangeLog.ScrollBars = 3
txtChangeLog.OnKeyDown = @txtChangeLog_KeyDown

Sub lvToDo_ItemActivate(ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvToDo.ListItems.Item(itemIndex)
	SelectSearchResult(item->Text(3), Val(item->Text(1)), Val(item->Text(2)), Len(lvToDo.Text), item->Tag)
End Sub

lvToDo.Images = @imgList
lvToDo.StateImages = @imgList
lvToDo.SmallImages = @imgList
lvToDo.Align = 5
lvToDo.Columns.Add ML("Content"), , 500, cfLeft
lvToDo.Columns.Add ML("Line"), , 50, cfRight
lvToDo.Columns.Add ML("Column"), , 50, cfRight
lvToDo.Columns.Add ML("File"), , 300, cfLeft
lvToDo.OnItemActivate = @lvToDo_ItemActivate

Sub lvErrors_ItemActivate(ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvErrors.ListItems.Item(itemIndex)
	SelectError(item->Text(2), Val(item->Text(1)), item->Tag)
End Sub

'Sub lvErrors_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
'    #IfNDef __USE_GTK__
'		If Key = VK_Return Then
'			Dim lvi As ListViewItem Ptr = lvErrors.SelectedItem
'			If lvi <> 0 Then lvErrors_ItemDblClick Sender, *lvi
'		End If
'	#EndIf
'End Sub

lvErrors.Images = @imgList
lvErrors.StateImages = @imgList
lvErrors.SmallImages = @imgList
lvErrors.Align = 5
lvErrors.Columns.Add ML("Content"), , 500, cfLeft
lvErrors.Columns.Add ML("Line"), , 50, cfRight
lvErrors.Columns.Add ML("File"), , 300, cfLeft
lvErrors.OnItemActivate = @lvErrors_ItemActivate
'lvErrors.OnKeyDown = @lvErrors_KeyDown

Sub lvSearch_ItemActivate(ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvSearch.ListItems.Item(itemIndex)
	SelectSearchResult(item->Text(3), Val(item->Text(1)), Val(item->Text(2)), Len(lvSearch.Text), item->Tag)
End Sub

'Sub lvSearch_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
'    #IfNDef __USE_GTK__
'		If Key = VK_Return Then
'			Dim lvi As ListViewItem Ptr = lvSearch.SelectedItem
'			If lvi <> 0 Then lvSearch_ItemDblClick Sender, *lvi
'		End If
'	#EndIf
'End Sub

lvSearch.Align = 5
lvSearch.Columns.Add ML("Line Text"), , 500, cfLeft
lvSearch.Columns.Add ML("Line"), , 50, cfRight
lvSearch.Columns.Add ML("Column"), , 50, cfRight
lvSearch.Columns.Add ML("File"), , 300, cfLeft
lvSearch.OnItemActivate = @lvSearch_ItemActivate
'lvSearch.OnKeyDown = @lvSearch_KeyDown

Function GetBottomClosedStyle As Boolean
	Return Not ptabBottom->TabPosition = tpTop
End Function

Sub SetBottomClosedStyle(Value As Boolean)
	If Value Then
		ptabBottom->TabPosition = tpBottom
		ptabBottom->TabIndex = -1
		#ifdef __USE_GTK__
			pnlBottom.Height = 25
		#else
			pnlBottom.Height = ptabBottom->ItemHeight(0) + 2
		#endif
		splBottom.Visible = False
		'pnlBottom.RequestAlign
	Else
		ptabBottom->TabPosition = tpTop
		ptabBottom->Height = tabBottomHeight
		pnlBottom.Height = tabBottomHeight
		pnlBottom.RequestAlign
		splBottom.Visible = True
	End If
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
End Sub

Sub tabBottom_DblClick(ByRef Sender As Control) '...'
	SetBottomClosedStyle Not GetBottomClosedStyle
End Sub

Sub tabBottom_SelChange(ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If ptabBottom->TabPosition = tpBottom And pnlBottom.Height = 25 Then
	#else
		If ptabBottom->TabPosition = tpBottom And ptabBottom->TabIndex <> -1 Then
	#endif
		ptabBottom->SetFocus
		pnlBottom.Height = tabBottomHeight
		pnlBottom.RequestAlign
		splBottom.Visible = True
		frmMain.RequestAlign '<bp>
	End If
	If MainNode <>0 AndAlso MainNode->Text <> "" AndAlso InStr(MainNode->Text,".") Then
		If ptabBottom->TabIndex = 4 AndAlso Not mLoadLog Then
			If mChangeLogEdited AndAlso mChangelogName<> "" Then
				txtChangeLog.SaveToFile(mChangelogName)  ' David Change
				mChangeLogEdited = False
			End If
			mChangelogName = ExePath & Slash & StringExtract(MainNode->Text, ".") & "_Change.log"
			txtChangeLog.Text = "Waiting...... "
			If Dir(mChangelogName)<>"" AndAlso mChangelogName<> "" Then
				txtChangeLog.LoadFromFile(mChangelogName) ' David Change
				#ifndef __USE_GTK__
					If InStr(txtChangeLog.Text,Chr(13,10)) < 1 Then txtChangeLog.Text = Replace(txtChangeLog.Text,Chr(10),Chr(13,10))
				#endif
			Else
				txtChangeLog.Text = ""
			End If
			mLoadLog = True
		ElseIf ptabBottom->TabIndex = 3  AndAlso Not mLoadToDO Then
			ThreadCreate(@FindToDoSub, MainNode)
			mLoadToDo = True
		End If
	End If
End Sub

Sub tabBottom_Click(ByRef Sender As Control) '<...>
	#ifdef __USE_GTK__
		If ptabBottom->TabPosition = tpBottom And pnlBottom.Height = 25 Then
	#else
		If ptabBottom->TabPosition = tpBottom And ptabBottom->TabIndex <> -1 Then
	#endif
		ptabBottom->SetFocus
		pnlBottom.Height = tabBottomHeight
		pnlBottom.RequestAlign
		splBottom.Visible = True
		frmMain.RequestAlign '<bp>
	End If
End Sub

Sub ShowMessages(ByRef msg As WString, ChangeTab As Boolean = True)
	If ChangeTab Then
		tabBottom_SelChange(*ptabBottom, 0)
		tabBottom.TabIndex = 0
	End If
	txtOutput.SetSel txtOutput.GetTextLength, txtOutput.GetTextLength
	txtOutput.SelText = msg & WChr(13) & WChr(10)
	tabBottom.Update
	txtOutput.Update
	frmMain.Update
	#ifdef __USE_GTK__
		While gtk_events_pending()
			gtk_main_iteration()
		Wend
	#endif
	'    txtOutput.ScrollToCaret
End Sub

Sub pnlBottom_Resize(ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlBottom.Height <> 25 Then tabBottomHeight = NewHeight: ptabBottom->SetBounds 0, 0, NewWidth, tabBottomHeight
	#else
		If ptabBottom->TabIndex <> -1 Then tabBottomHeight = ptabBottom->Height
	#endif
End Sub

pnlBottom.Name = "pnlBottom"
pnlBottom.Align = 4
pnlBottom.Height = tabBottomHeight
pnlBottom.OnResize = @pnlBottom_Resize

'ptabBottom->Images.AddIcon bmp
ptabBottom->Name = "tabBottom"
ptabBottom->Height = tabBottomHeight
#ifdef __USE_GTK__
	ptabBottom->Align = 4
#else
	ptabBottom->Align = 5
#endif
'ptabBottom->TabPosition = tpBottom
ptabBottom->AddTab(ML("Output"))
ptabBottom->AddTab(ML("Errors"))
ptabBottom->AddTab(ML("Find"))
ptabBottom->AddTab(ML("ToDo"))
ptabBottom->AddTab(ML("Change Log"))
ptabBottom->AddTab(ML("Immediate"))
ptabBottom->AddTab(ML("Locals"))
ptabBottom->AddTab(ML("Processes"))
ptabBottom->AddTab(ML("Threads"))
ptabBottom->AddTab(ML("Watches"))
ptabBottom->Tabs[0]->Add @txtOutput
ptabBottom->Tabs[1]->Add @lvErrors
ptabBottom->Tabs[2]->Add @lvSearch
ptabBottom->Tabs[3]->Add @lvToDo
ptabBottom->Tabs[4]->Add @txtChangeLog
ptabBottom->Tabs[5]->Add @txtImmediate
ptabBottom->Tabs[6]->Add @tvVar
ptabBottom->Tabs[7]->Add @tvPrc
ptabBottom->Tabs[8]->Add @tvThd
ptabBottom->Tabs[9]->Add @tvWch
ptabBottom->OnClick = @tabBottom_Click
ptabBottom->OnDblClick = @tabBottom_DblClick
ptabBottom->OnSelChange = @tabBottom_SelChange
'pnlBottom.Height = 153
'pnlBottom.Align = 4
'pnlBottom.AddRange 1, @tabBottom
pnlBottom.Add ptabBottom

LoadKeyWords '<bm>

Sub frmMain_ActiveControlChanged(ByRef sender As My.Sys.Object)
	If frmMain.ActiveControl = 0 Then Exit Sub
	If tabLeft.TabPosition = tpLeft And tabLeft.TabIndex <> -1 Then
		If frmMain.ActiveControl->Parent <> tabLeft.SelectedTab AndAlso frmMain.ActiveControl <> @tabLeft Then
			splLeft.Visible = False
			#ifdef __USE_GTK__
				pnlLeft.Width = 30
			#else
				tabLeft.TabIndex = -1
				pnlLeft.Width = tabLeft.ItemWidth(0) + 2
			#endif
			frmMain.RequestAlign
		End If
	End If
	If tabRight.TabPosition = tpRight And tabRight.TabIndex <> -1 Then
		If frmMain.ActiveControl->Parent <> tabRight.SelectedTab AndAlso frmMain.ActiveControl <> @tabRight _
			AndAlso frmMain.ActiveControl <> @txtPropertyValue AndAlso frmMain.ActiveControl <> @cboPropertyValue Then
			splRight.Visible = False
			#ifdef __USE_GTK__
				pnlRight.Width = 30
			#else
				tabRight.TabIndex = -1
				pnlRight.Width = tabRight.ItemWidth(0) + 2
			#endif
			frmMain.RequestAlign
		End If
	End If
	If ptabBottom->TabPosition = tpBottom And ptabBottom->TabIndex <> -1 Then
		If frmMain.ActiveControl->Parent <> ptabBottom->SelectedTab AndAlso frmMain.ActiveControl <> ptabBottom Then
			splBottom.Visible = False
			#ifdef __USE_GTK__
				pnlBottom.Height = 25
			#else
				ptabBottom->TabIndex = -1
				pnlBottom.Height = ptabBottom->ItemHeight(0) + 2
			#endif
			frmMain.RequestAlign
		End If
	End If
End Sub

Sub frmMain_Resize(ByRef sender As My.Sys.Object, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifndef __USE_GTK__
		stBar.Panels[0]->Width = NewWidth - 570
		prProgress.Left = stBar.Panels[0]->Width + stBar.Panels[1]->Width +3
	#endif
End Sub

Sub frmMain_DropFile(ByRef sender As My.Sys.Object, ByRef FileName As WString)
	AddTab FileName
End Sub

Sub ConnectAddIn(AddIn As String)
	Dim As Sub(VisualFBEditorApp As Any Ptr, ByRef AppPath As WString) OnConnection
	Dim As Any Ptr AddInDll
	Dim As String f
	#ifdef __FB_WIN32__
		f = Dir(ExePath & "/AddIns/" & AddIn & ".dll")
	#else
		f = Dir(ExePath & "/AddIns/" & AddIn & ".so")
	#endif
	AddInDll = DyLibLoad(ExePath & "/AddIns/" & f)
	If AddInDll <> 0 Then
		OnConnection = DyLibSymbol(AddInDll, "OnConnection")
		If OnConnection Then
			OnConnection(pApp, pApp->FileName)
			AddIns.Add AddIn, AddInDll
		End If
	End If
End Sub

Sub DisConnectAddIn(AddIn As String)
	Dim As Sub(VisualFBEditorApp As Any Ptr) OnDisconnection
	Dim As Any Ptr AddInDll
	Dim i As Integer = AddIns.IndexOf(AddIn)
	If i <> -1 Then
		AddInDll = AddIns.Object(i)
		If AddInDll <> 0 Then
			OnDisconnection = DyLibSymbol(AddInDll, "OnDisconnection")
			If OnDisconnection Then
				OnDisconnection(pApp)
				DyLibFree(AddInDll)
			End If
		End If
		AddIns.Remove i
	End If
End Sub

Sub LoadAddIns
	Dim As String f, AddIn
	#ifdef __FB_WIN32__
		f = Dir(ExePath & "/AddIns/*.dll")
	#else
		f = Dir(ExePath & "/AddIns/*.so")
	#endif
	While f <> ""
		AddIn = Left(f, InStrRev(f, ".") - 1)
		If iniSettings.ReadBool("AddInsOnStartup", AddIn, False) Then
			ConnectAddIn AddIn
		End If
		f = Dir()
	Wend
End Sub

Sub UnLoadAddins
	Dim As Any Ptr AddInDll
	For i As Integer = 0 To AddIns.Count - 1
		DisconnectAddIn AddIns.Item(i)
	Next
	AddIns.Clear
End Sub

Sub LoadTools
	Dim As ToolType Ptr Tool
	For i As Integer = 0 To Tools.Count - 1
		Tool = Tools.Item(i)
		If Tool->LoadType = LoadTypes.OnEditorStartup Then Tool->Execute
	Next
End Sub

Sub GetColors(ByRef cs As ECColorScheme, DefaultForeground As Integer = -1, DefaultBackground As Integer = -1, DefaultFrame As Integer = -1, DefaultIndicator As Integer = -1)
	cs.Foreground = IIf(cs.ForegroundOption = -1, DefaultForeground, cs.ForegroundOption)
	cs.Background = IIf(cs.BackgroundOption = -1, DefaultBackground, cs.BackgroundOption)
	cs.Frame = IIf(cs.FrameOption = -1, DefaultFrame, cs.FrameOption)
	cs.Indicator = IIf(cs.IndicatorOption = -1, DefaultIndicator, cs.IndicatorOption)
	GetColor cs.Foreground, cs.ForegroundRed, cs.ForegroundGreen, cs.ForegroundBlue
	GetColor cs.Background, cs.BackgroundRed, cs.BackgroundGreen, cs.BackgroundBlue
	GetColor cs.Frame, cs.FrameRed, cs.FrameGreen, cs.FrameBlue
	GetColor cs.Indicator, cs.IndicatorRed, cs.IndicatorGreen, cs.IndicatorBlue
End Sub

Sub SetAutoColors
	GetColors Bookmarks, , , , clAqua
	GetColors Breakpoints, clWhite, clMaroon, , clMaroon
	GetColors Comments, clGreen
	GetColors CurrentBrackets, , , clGreen
	GetColors CurrentLine, , clBtnFace
	GetColors CurrentWord, , clBtnFace
	GetColors ExecutionLine, clBlack, clYellow, , clYellow
	GetColors FoldLines, clBtnShadow
	GetColors IndicatorLines, clBlack
	GetColors Keywords, clBlue
	GetColors LineNumbers, clBlack, clBtnFace
	GetColors NormalText, clBlack, clWhite
	GetColors Preprocessors, clPurple
	GetColors Selection, clHighlightText, clHighlight
	GetColors SpaceIdentifiers, clLtGray
	GetColors Strings, clMaroon
End Sub

Sub frmMain_Create(ByRef Sender As Control)
	#ifdef __USE_GTK__
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), "VisualFBEditor1")
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), ToUTF8("VisualFBEditor4"))
	#endif
	
	LoadToolBox
	
	tabLeftWidth = iniSettings.ReadInteger("MainWindow", "LeftWidth", tabLeftWidth)
	SetLeftClosedStyle iniSettings.ReadBool("MainWindow", "LeftClosed", True)
	tabRightWidth = iniSettings.ReadInteger("MainWindow", "RightWidth", tabRightWidth)
	SetRightClosedStyle iniSettings.ReadBool("MainWindow", "RightClosed", True)
	tabBottomHeight = iniSettings.ReadInteger("MainWindow", "BottomHeight", tabBottomHeight)
	SetBottomClosedStyle iniSettings.ReadBool("MainWindow", "BottomClosed", True)
	tbExplorer.Buttons.Item(3)->Checked = iniSettings.ReadBool("MainWindow", "ProjectFolders", True)
	tbForm.Buttons.Item(0)->Checked = iniSettings.ReadBool("MainWindow", "ToolLabels", True)
	ChangeUseDebugger iniSettings.ReadBool("MainWindow", "UseDebugger", True)
	Var bGUI = iniSettings.ReadBool("MainWindow", "CompileGUI", True)
	tbStandard.Buttons.Item("Form")->Checked = bGUI
	tbStandard.Buttons.Item("Console")->Checked = Not bGUI
	Var file = Command(-1)
	wLet RecentFiles, iniSettings.ReadString("MainWindow", "RecentFiles", "")
	If file = "" Then
		' , Auto Load the last one.
		If AutoReloadLastOpenFiles Then OpenFiles *RecentFiles
	Else
		OpenFiles file
	End If
	#ifndef __USE_GTK__
		windmain = frmMain.Handle
		htab2    = ptabCode->Handle
		tviewVar = tvVar.Handle
		tviewPrc = tvPrc.Handle
		tviewThd = tvThd.Handle
		tviewWch = tvWch.Handle
		DragAcceptFiles(frmMain.Handle, True)
	#endif
	'	If MainNode <> 0 Then
	'		' Should have changelog file for every project
	'		If MainNode->Text<>"" AndAlso InStr(MainNode->Text,".") Then
	'			Dim As WString Ptr Changelog
	'			wlet Changelog, ExePath & Slash & StringExtract(MainNode->Text, ".") & "_Change.log", True
	'			If Dir(*Changelog)<>"" Then txtChangeLog.LoadFromFile(*Changelog) '
	'			wDeallocate Changelog
	'		End If
	'	End If
	LoadAddins
	LoadTools
	mStartLoadSession = False
End Sub

Sub frmMain_Show(ByRef Sender As Control)
	pfSplash->CloseForm
End Sub

Sub frmMain_Close(ByRef Sender As Form, ByRef Action As Integer)
	On Error Goto ErrorHandler
	FormClosing = True
	Dim tb As TabWindow Ptr
	Dim tn As TreeNode Ptr
	For i As Integer = 0 To ptabCode->TabCount - 1
		tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
		If CInt(tb) AndAlso CInt(tb->Modified) AndAlso CInt(Not tb->CloseTab) Then Action = 0: Return
	Next i
	For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
		tn = tvExplorer.Nodes.Item(i)
		If CInt(tn->ImageKey = "Project") AndAlso CInt(EndsWith(tn->Text, " *")) AndAlso CInt(Not CloseProject(tn)) Then Action = 0: Return
	Next i
	iniSettings.WriteInteger("MainWindow", "MainWidth", frmMain.Width)
	iniSettings.WriteInteger("MainWindow", "MainHeight", frmMain.Height)
	iniSettings.WriteBool("MainWindow", "LeftClosed", GetLeftClosedStyle)
	iniSettings.WriteInteger("MainWindow", "LeftWidth", tabLeftWidth)
	iniSettings.WriteBool("MainWindow", "RightClosed", GetRightClosedStyle)
	iniSettings.WriteInteger("MainWindow", "RightWidth", tabRightWidth)
	iniSettings.WriteBool("MainWindow", "BottomClosed", GetBottomClosedStyle)
	iniSettings.WriteInteger("MainWindow", "BottomHeight", tabBottomHeight)
	iniSettings.WriteBool("MainWindow", "ProjectFolders", tbExplorer.Buttons.Item(3)->Checked)
	iniSettings.WriteBool("MainWindow", "ToolLabels", tbForm.Buttons.Item(0)->Checked)
	iniSettings.WriteBool("MainWindow", "UseDebugger", UseDebugger)
	iniSettings.WriteBool("MainWindow", "CompileGUI", tbStandard.Buttons.Item("Form")->Checked)
	
	Dim As Integer MRUFilesCount, kk=-1
	MRUFilesCount = MRUFiles.Count
	If MRUFilesCount<1 Then
		For i As Integer = 0 To miRecentMax
			iniSettings.KeyRemove("MRUFiles", "MRUFile_0" & WStr(i))
		Next
	Else
		For i As Integer = Max(MRUFilesCount - miRecentMax, 0) To MRUFilesCount - 1
			kk += 1
			iniSettings.WriteString("MRUFiles", "MRUFile_0" & WStr(kk), MRUFiles.Item(i))
		Next
	End If
	
	MRUFilesCount = MRUProjects.Count
	kk=-1
	If MRUFilesCount<1 Then
		For i As Integer = 0 To miRecentMax
			iniSettings.KeyRemove("MRUProjects", "MRUProject_0" & WStr(i))
		Next
	Else
		For i As Integer = Max(MRUFilesCount - miRecentMax, 0) To MRUFilesCount - 1
			kk += 1
			iniSettings.WriteString("MRUProjects", "MRUProject_0" & WStr(kk), MRUProjects.Item(i))
		Next
	End If
	' David Change
	MRUFilesCount = MRUSessions.Count
	kk=-1
	If MRUFilesCount<1 Then
		For i As Integer = 0 To miRecentMax
			iniSettings.KeyRemove("MRUSessions", "MRUSession_0" & WStr(i))
		Next
	Else
		For i As Integer = Max(MRUFilesCount - miRecentMax, 0) To MRUFilesCount - 1
			kk += 1
			iniSettings.WriteString("MRUSessions", "MRUSession_0" & WStr(kk), MRUSessions.Item(i))
		Next
	End If
	iniSettings.WriteString("MainWindow", "RecentFiles", *RecentFiles)
	If mChangeLogEdited Then txtChangeLog.SaveToFile(ExePath & Slash & StringExtract(MainNode->Text, ".") & "_Change.log") '
	UnLoadAddins
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Sub

#ifdef __USE_GTK__
	frmMain.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
#else
	frmMain.Icon.LoadFromResourceID(1)
#endif
frmMain.StartPosition = FormStartPosition.DefaultBounds
frmMain.MainForm = True
#ifdef __FB_64BIT__
	frmMain.Text = "Visual FB Editor (x64)"
#else
	frmMain.Text = "Visual FB Editor (x32)"
#endif
frmMain.OnActiveControlChange = @frmMain_ActiveControlChanged
frmMain.OnResize = @frmMain_Resize
frmMain.OnCreate = @frmMain_Create
frmMain.OnShow = @frmMain_Show
frmMain.OnClose = @frmMain_Close
frmMain.OnDropFile = @frmMain_DropFile
frmMain.Menu = @mnuMain
frmMain.Add @tbStandard
frmMain.Add @stBar
frmMain.Add @pnlLeft
frmMain.Add @splLeft
frmMain.Add @pnlRight
frmMain.Add @splRight
frmMain.Add @pnlBottom
frmMain.Add @splBottom
frmMain.Add ptabCode

frmMain.CreateWnd
frmMain.Show
frmMain.CenterToScreen '

Sub OnProgramStart() Constructor
	'	pfSplash = @fSplash
	'	pfSplash->Show
End Sub

Sub OnProgramQuit() Destructor
	WDeallocate HelpPath
	WDeallocate ProjectsPath
	WDeallocate LastOpenPath
	WDeallocate DefaultMakeTool
	WDeallocate CurrentMakeTool1
	WDeallocate CurrentMakeTool2
	WDeallocate MakeToolPath
	WDeallocate DefaultDebugger
	WDeallocate CurrentDebugger
	WDeallocate DebuggerPath
	WDeallocate DefaultTerminal
	WDeallocate CurrentTerminal
	WDeallocate TerminalPath
	WDeallocate DefaultCompiler32
	WDeallocate CurrentCompiler32
	WDeallocate DefaultCompiler64
	WDeallocate CurrentCompiler64
	WDeallocate Compiler32Path
	WDeallocate Compiler64Path
	WDeallocate Compiler32Arguments
	WDeallocate Compiler64Arguments
	WDeallocate Make1Arguments
	WDeallocate Make2Arguments
	WDeallocate RunArguments
	WDeallocate DebugArguments
	WDeallocate RecentFiles '
End Sub
