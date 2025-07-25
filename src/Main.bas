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
#include once "mff/SearchBox.bi"
#include once "mff/TextBox.bi"
#include once "mff/RichTextBox.bi"
#include once "mff/TabControl.bi"
#include once "mff/StatusBar.bi"
#include once "mff/Splitter.bi"
#include once "mff/HorizontalBox.bi"
#include once "mff/ToolBar.bi"
#include once "mff/ListControl.bi"
#include once "mff/CheckBox.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/ComboBoxEx.bi"
#include once "mff/RadioButton.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/ScrollBarControl.bi"
#include once "mff/Label.bi"
#include once "mff/LinkLabel.bi"
#include once "mff/Panel.bi"
#include once "mff/TrackBar.bi"
#include once "mff/Clipboard.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/IniFile.bi"
#include once "mff/PointerList.bi"
#include once "mff/ReBar.bi"
#include once "mff/HTTP.bi"
#include once "fbthread.bi"
#include once "vbcompat.bi"

Using My.Sys.Forms
Using My.Sys.Drawing

Dim Shared As Boolean bQuitting
#ifdef __USE_WINAPI__
	Function EnumWindowsProc(ByVal hWnd As HWND, ByVal lParam As LPARAM) As BOOL
		Dim As Any Ptr VisualFBEditorAppPtr = GetProp(hWnd, "VisualFBEditorApp")
		
		If VisualFBEditorAppPtr <> 0 Then
			Dim As ZString Ptr FileFromCmdLine = Cast(ZString Ptr, lParam)
			Dim cds As COPYDATASTRUCT
			cds.dwData = 0
			cds.cbData = Len(*FileFromCmdLine) + 1
			cds.lpData = FileFromCmdLine
			If SendMessage(hWnd, WM_COPYDATA, 0, Cast(lParam, @cds)) <> 0 Then
				bQuitting = True
				End
			End If
		End If
		
		Return True
	End Function
	
	If App.PrevInstance Then
		Var FileFromCommandLine = Command(-1)
		Var Pos1 = InStr(FileFromCommandLine, "2>CON")
		If Pos1 > 0 Then FileFromCommandLine = Left(FileFromCommandLine, Pos1 - 1)
		If FileFromCommandLine <> "" AndAlso Right(LCase(FileFromCommandLine), 4) <> ".exe" Then
			EnumWindows(@EnumWindowsProc, Cast(LPARAM, StrPtr(FileFromCommandLine)))
		End If
	End If
	
	InitDarkMode
	'setDarkMode(True, True)
#endif

#include once "frmSplash.bi"
pfSplash->MainForm = False
pfSplash->Show
#ifdef __FB_64BIT__
	pfSplash->lblSplash1.Text = "(" & ML("Version") & " " & pApp->Version & "  " & ML("64-bit") & ")"
#else
	pfSplash->lblSplash1.Text = "(" & ML("Version") & " " & pApp->Version & "  " & ML("32-bit") & ")"
#endif
pApp->DoEvents

Dim Shared As VisualFBEditor.Application VisualFBEditorApp
Dim Shared As ComboBoxEdit cboBuildConfiguration, cboAIAgentModels
Dim Shared As IniFile iniSettings, iniTheme
Dim Shared As SearchBox txtExplorer, txtForm, txtProperties, txtEvents
Dim Shared As ToolBar tbStandard, tbEdit, tbBuild, tbRun, tbProject, tbExplorer, tbForm, tbAIAgent, tbProperties, tbEvents, tbBottom, tbLeft, tbRight
Dim Shared As StatusBar stBar
Dim Shared As Splitter splLeft, splRight, splBottom, splAIAgent, splProperties, splEvents
Dim Shared As ListControl lstLeft
Dim Shared As CheckBox chkLeft
Dim Shared As RadioButton radButton
Dim Shared As ScrollBarControl scrLeft
Dim Shared As Label lblLeft
Dim Shared As Panel pnlLeft, pnlRight, pnlBottom, pnlBottomTab, pnlLeftPin, pnlRightPin, pnlBottomPin, pnlPropertyValue, pnlColor
Dim Shared As TrackBar trLeft
Dim Shared As MainMenu mnuMain
Dim Shared As MenuItem Ptr mnuStartWithCompile, mnuStart, mnuBreak, mnuEnd, mnuRestart, mnuStandardToolBar, mnuEditToolBar, mnuProjectToolBar, mnuBuildToolBar, mnuRunToolBar, mnuSplit, mnuSplitHorizontally, mnuSplitVertically, mnuWindowSeparator, miRecentProjects, miRecentFiles, miRecentFolders, miRecentSessions, miSetAsMain, miClearStartUp, miTabSetAsMain, miTabReloadHistoryCode, miRemoveFiles, miToolBars
Dim Shared As MenuItem Ptr miRecentAIChat,  miFileAIChat
Dim Shared As MenuItem Ptr miSaveProject, miSaveProjectAs, miCloseProject, miCloseFolder, miSave, miSaveAs, miSaveAll, miClose, miCloseAll, miCloseSession, miPrint, miPrintPreview, miPageSetup, miOpenProjectFolder, miProjectProperties, miExplorerOpenProjectFolder, miExplorerRename, miExplorerProjectProperties, miExplorerCloseProject, miRename, miRemoveFileFromProject
Dim Shared As MenuItem Ptr miUndo, miRedo, miCutCurrentLine, miCut, miCopy, miPaste, miSingleComment, miBlockComment, miUncommentBlock, miDuplicate, miSelectAll, miIndent, miOutdent, miFormat, miUnformat, miFormatProject, miUnformatProject, miAddSpaces, miDeleteBlankLines, miSuggestions, miCompleteWord, miParameterInfo, miStepInto, miStepOver, miStepOut, miRunToCursor, miGDBCommand, miAddWatch, miToggleBreakpoint, miClearAllBreakpoints, miSetNextStatement, miShowNextStatement
Dim Shared As MenuItem Ptr miNumbering, miMacroNumbering, miRemoveNumbering, miProcedureNumbering, miProcedureMacroNumbering, miRemoveProcedureNumbering, miProjectMacroNumbering, miProjectMacroNumberingStartsOfProcedures, miRemoveProjectNumbering, miModuleMacroNumbering, miModuleMacroNumberingStartsOfProcedures, miRemoveModuleNumbering, miPreprocessorNumbering, miRemovePreprocessorNumbering, miProjectPreprocessorNumbering, miRemoveProjectPreprocessorNumbering, miModulePreprocessorNumbering, miRemoveModulePreprocessorNumbering, miOnErrorResumeNext, miOnErrorGoto, miOnErrorGotoResumeNext, miOnLocalErrorGoto, miOnLocalErrorGotoResumeNext, miRemoveErrorHandling
Dim Shared As MenuItem Ptr dmiNumbering, dmiMacroNumbering, dmiRemoveNumbering, dmiProcedureNumbering, dmiProcedureMacroNumbering, dmiRemoveProcedureNumbering, dmiModuleMacroNumbering, dmiModuleMacroNumberingStartsOfProcedures, dmiRemoveModuleNumbering, dmiPreprocessorNumbering, dmiRemovePreprocessorNumbering, dmiModulePreprocessorNumbering, dmiRemoveModulePreprocessorNumbering, dmiOnErrorResumeNext, dmiOnErrorGoto, dmiOnErrorGotoResumeNext, dmiOnLocalErrorGoto, dmiOnLocalErrorGotoResumeNext, dmiRemoveErrorHandling, dmiMake, dmiMakeClean
Dim Shared As MenuItem Ptr miCode, miForm, miCodeAndForm, miGotoCodeForm, miCollapseCurrent, miCollapseAllProcedures, miCollapseAll, miUnCollapseCurrent, miUnCollapseAllProcedures, miUnCollapseAll, miImageManager, miAddProcedure, miAddType, miFind, miReplace, miFindNext, miFindPrevious, miGoto, miDefine, miToggleBookmark, miNextBookmark, miPreviousBookmark, miClearAllBookmarks, miSyntaxCheck, miCompile, miCompileAll, miBuildBundle, miBuildAPK, miGenerateSignedBundle, miGenerateSignedAPK, miMake, miMakeClean
Dim Shared As MenuItem Ptr miShowWithFolders, miShowWithoutFolders, miShowAsFolder
Dim Shared As ToolButton Ptr tbtSave, tbtSaveAll, tbtSyntaxCheck, tbtSuggestions, tbtCompile, tbtUndo, tbtRedo, tbtCut, tbtCopy, tbtPaste, tbtBlockComment, tbtSingleComment, tbtUncommentBlock, tbtFormat, tbtUnformat, tbtCompleteWord, tbtParameterInfo, tbtFind, tbtUseDirect2D, tbtRemoveFileFromProject, tbtStartWithCompile, tbtStart, tbtBreak, tbtEnd, tbt32Bit, tbt64Bit, tbtUseDebugger, tbtNotSetted, tbtConsole, tbtGUI
Dim Shared As SaveFileDialog SaveD
Dim Shared As ReBar MainReBar
#ifndef __USE_GTK__
	Dim Shared As ScrollBarControl scrTool
	Dim Shared As PageSetupDialog PageSetupD
	Dim Shared As PrintDialog PrintD
	Dim Shared As PrintPreviewDialog PrintPreviewD
	Dim Shared As My.Sys.ComponentModel.Printer pPrinter
#endif
Dim Shared As List Tools, TabPanels, ControlLibraries
Dim Shared As WStringOrStringList Comps, GlobalAsmFunctionsHelp, GlobalFunctionsHelp, Snippets, TypesInFunc, EnumsInFunc
'Dim Shared As WStringOrStringList GlobalNamespaces, GlobalTypes, GlobalEnums, GlobalDefines, GlobalFunctions, GlobalTypeProcedures, GlobalArgs
Dim Shared As WStringList AddIns, IncludeFiles, LoadPaths, IncludePaths, LibraryPaths, MRUAIChat, MRUFiles, MRUFolders, MRUProjects, MRUSessions, ProfilingFunctions ' add Sessions
Dim Shared As WString Ptr RecentFiles, RecentFile, RecentProject, RecentFolder, RecentSession, RecentAIChat
Dim Shared As Dictionary Helps, HotKeys, Compilers, MakeTools, Debuggers, Terminals, OtherEditors, BuildConfigurations, mlCompiler, mlTemplates, AIAgents, mpKeys, mcKeys
Dim Shared As ListView lvProblems, lvSuggestions, lvSearch, lvToDo, lvMemory
Dim Shared As ProgressBar prProgress
Dim Shared As CommandButton btnPropertyValue
Dim Shared As TextBox txtPropertyValue, txtExpand, txtAIRequest
Dim Shared As RichTextBox txtLabelProperty, txtLabelEvent, txtAIAgent
Dim Shared As ComboBoxEdit cboPropertyValue
Dim Shared As PopupMenu mnuForm, mnuVars, mnuWatch, mnuExplorer, mnuTabs, mnuProcedures, mnuProblems, mnuAIChat
Dim Shared As ImageList imgList, imgListD, imgListTools, imgListStates, imgList32, imgListAIProviders32, imgListAIModels32
Dim Shared As TreeListView lvProperties, lvEvents, lvLocals, lvGlobals, lvThreads, lvWatches, lvProfiler
Dim Shared As ToolPalette tbToolBox
Dim Shared As Panel pnlToolBox, pnlAIAgent
Dim Shared As HTTPConnection HTTPAIAgent
Dim Shared As Boolean bInAIThread, bInThingk, bInNOTThingk, AIBold, AIPostDataFirstTime
Dim Shared As Dictionary AIMessages, AIContext
Dim Shared As WStringList AIIncludeFileNameList
Dim Shared As Any Ptr AIThread
Dim Shared As WString Ptr AISystem_PromoptPtr, AIPostDataPtr_1st, AIPostDataPtr_2nd, AIBodyWStringPtr, AIBodyWStringSavePtr, AIAssistantsAnswersPtr
Dim Shared As String AIPostData
Dim Shared As TabControl tabLeft, tabRight, tabBottom ', tabDebug
Dim Shared As TreeView tvExplorer, tvVar, tvPrc, tvThd, tvWch
Dim Shared As TextBox txtOutput, txtImmediate
Dim Shared As TextBox txtChangeLog ' Add Change Log
Dim Shared As TabPage Ptr tpProject, tpToolbox, tpProperties, tpEvents, tpOutput, tpProblems, tpSuggestions, tpFind, tpToDo, tpChangeLog, tpImmediate, tpLocals, tpGlobals, tpProcedures, tpThreads, tpWatches, tpMemory, tpProfiler, tpAIAgent
Dim Shared As Form frmMain
Dim Shared As Integer tabItemHeight
Dim Shared As Integer miRecentMax =20 'David Changed
Dim Shared As Boolean mLoadLog, mLoadToDo, mChangeLogEdited, mStartLoadSession = True, ManifestIcoCopy
Dim Shared As WString * MAX_PATH mChangelogName  'David Changed
pApp = @VisualFBEditorApp
pfrmMain = @frmMain
pSaveD = @SaveD
piniSettings = @iniSettings
piniTheme = @iniTheme
pAddIns = @AddIns
pTools = @Tools
pControlLibraries = @ControlLibraries
pCompilers = @Compilers
pMakeTools = @MakeTools
pDebuggers = @Debuggers
pTerminals = @Terminals
pOtherEditors = @OtherEditors
pHelps = @Helps
pAIAgents = @AIAgents
pHTTPAIAgent = @HTTPAIAgent
plvSearch = @lvSearch
plvToDo = @lvToDo '
ptbStandard = @tbStandard
pcboBuildConfiguration = @cboBuildConfiguration
plvProperties = @lvProperties
plvEvents = @lvEvents
pprProgress = @prProgress
pstBar = @stBar   'David Change
ptxtPropertyValue = @txtPropertyValue
pbtnPropertyValue = @btnPropertyValue
ptvExplorer = @tvExplorer
ptabLeft = @tabLeft
ptabBottom = @tabBottom
ptabRight = @tabRight
pimgList = @imgList
pimgListTools = @imgListTools
pimgListAIProviders32 = @imgListAIProviders32
pimgListAIModels32 = @imgListAIModels32
pIncludeFiles = @IncludeFiles
pLoadPaths = @LoadPaths
pIncludePaths = @IncludePaths
pLibraryPaths = @LibraryPaths
pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("Settings")

'LoadLanguageTexts
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
#include once "frmImageManager.bi"
#include once "frmOptions.bi"
#include once "frmTemplates.bi"
#include once "frmParameters.bi"
#include once "frmProjectProperties.bi"
#include once "frmSave.bi"
#include once "frmTipOfDay.frm"
#include once "frmComponents.frm"
#include once "Debug.bi"

pComps = @Comps
pGlobalNamespaces = @Globals.Namespaces
pGlobalTypes = @Globals.Types
pGlobalEnums = @Globals.Enums
pGlobalDefines = @Globals.Defines
pGlobalFunctions = @Globals.Functions
pGlobalTypeProcedures = @Globals.TypeProcedures
pGlobalArgs = @Globals.Args
IncludePaths.Sorted = True
Comps.Sorted = True
Globals.Namespaces.Sorted = True
Globals.Types.Sorted = True
Globals.TypeProcedures.Sorted = True
Globals.Enums.Sorted = True
Globals.Defines.Sorted = True
Globals.Functions.Sorted = True
Globals.Args.Sorted = True
GlobalAsmFunctionsHelp.Sorted = True
GlobalFunctionsHelp.Sorted = True
WithFrame = Month(Now) = 12 OrElse Month(Now) = 1

Namespace VisualFBEditor
	Function Application.ReadProperty(ByRef PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "mainprojectfile", "mainfile", "exefile"
			Dim As ProjectElement Ptr Project
			Dim As ExplorerElement Ptr ee
			Dim As TreeNode Ptr ProjectNode
			Dim As UString ProjectFile = ""
			Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
			Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
			Dim As UString ExeFile = GetExeFileName(MainFile, CompileLine & " " & FirstLine)
			If ProjectNode <> 0 Then ee = ProjectNode->Tag
			If ee <> 0 Then ProjectFile = *ee->FileName
			Select Case LCase(PropertyName)
			Case "mainprojectfile": Return ProjectFile.vptr
			Case "mainfile": Return MainFile.vptr
			Case "exefile": Return ExeFile.vptr
			End Select
		Case "currentword"
			Dim As UString CurrentWord = ""
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb <> 0 Then CurrentWord = tb->txtCode.GetWordAtCursor
			Return CurrentWord.vptr
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
	
	Function Application.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		If Value = 0 Then
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
		Else
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			
		End If
		Return True
	End Function
End Namespace

Function MS cdecl(ByRef V As WString, ...) As UString
	Dim As UString Result
	Dim As Boolean bFind
	If LCase(App.CurLanguage) <> "english" Then
		Dim As Integer tIndex = mlKeys.IndexOfKey(V)
		If tIndex >= 0 Then
			Result = mlKeys.Item(tIndex)->Text
			bFind = True
		End If
	End If
	If Not bFind Then Result = V
	Dim args As Cva_List
	Cva_Start(args, V)
	For i As Integer = 1 To Min(InStrCount(V, "$"), InStrCount(Result, "$"))
		Result = Replace(Result, "$" & Trim(Str(i)), * (Cva_Arg(args, WString Ptr)))
	Next
	MS = Result
	Cva_End(args)
End Function

Function MLCompilerFun(ByRef V As WString) ByRef As WString
	If LCase(App.CurLanguage) = "english" Then Return V
	Dim As Integer tIndex = mlCompiler.IndexOfKey(V) ' For improve the speed
	If tIndex >= 0 Then Return mlCompiler.Item(tIndex)->Text Else Return V
End Function

'David Change For the comment of control's Properties
Function MC(ByRef V As WString) ByRef As WString
	If (Not gLocalProperties) Then Return V
	Dim As WString * 2048 TempV = ""
	Dim As Integer Posi = InStrRev(V, ".")
	TempV = IIf(Posi > 0, Mid(V, Posi + 1), V)
	Dim As Integer tIndex = mcKeys.IndexOfKey(TempV) 'David Changed
	If tIndex >= 0 Then Return mcKeys.Item(tIndex)->Text
	Return V
End Function

Function MP(ByRef V As WString) ByRef As WString
	If (Not gLocalProperties) OrElse LCase(App.CurLanguage) = "english" Then Return V
	Dim As Integer tIndex = -1, tIndex2 = -1
	If InStr(V,".") Then
		Static As WString * 2048 TempWstr = ""
		Dim As WString Ptr LineParts(Any)
		Split(V, ".", LineParts())
		For k As Integer = 0 To UBound(LineParts)
			tIndex = mpKeys.IndexOfKey(*LineParts(k))
			If tIndex >=0 Then
				If k = 0 Then
					TempWstr = mpKeys.Item(tIndex)->Text
				Else
					TempWstr &= "." & mpKeys.Item(tIndex)->Text
				End If
			Else
				If k=0 Then
					TempWstr = *LineParts(k)
				Else
					TempWstr &= "." & *LineParts(k)
				End If
			End If
			Deallocate LineParts(k)
		Next
		Erase LineParts
		If TempWstr = "" Then
			Return V
		Else
			Return TempWstr
		End If
	Else
		tIndex = mpKeys.IndexOfKey(V)
		If tIndex >= 0 Then
			If mpKeys.Item(tIndex)->Text = "" Then
				Return V
			Else
				Return mpKeys.Item(tIndex)->Text
			End If
		Else
			Return V
		End If
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

Sub SetCodeVisible(tb As TabWindow Ptr)
	If tb->tbrTop.Buttons.Item("Form")->Checked = True Then tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
End Sub

Sub SelectError(ByRef FileName As WString, iLine As Integer, tabw As TabWindow Ptr = 0)
	Dim tb As TabWindow Ptr
	If tabw <> 0 AndAlso ptabCode->IndexOfTab(tabw) <> -1 Then
		tb = tabw
		tb->SelectTab
	Else
		If FileName = "" OrElse EndsWith(LCase(FileName), ".exe") OrElse Dir(FileName) = ""  Then Exit Sub
		tb = AddTab(FileName)
	End If
	tb->txtCode.SetSelection iLine - 1, iLine - 1, 0, tb->txtCode.LineLength(iLine - 1)
	SetCodeVisible tb
End Sub

Sub lvProperties_CellEditing(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr, ByRef Cancel As Boolean)
	'CellEditor = @cboPropertyValue
End Sub

Sub lvProperties_CellEdited(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString, ByRef Cancel As Boolean)
	PropertyChanged Sender, NewText, False
End Sub

Sub txtPropertyValue_LostFocus(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	PropertyChanged Sender, txtPropertyValue.Text, False
End Sub

Dim Shared bNotChange As Boolean
Sub cboPropertyValue_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If Trim(cboPropertyValue.Text) = "" Then
		Exit Sub
	End If
	#ifdef __USE_GTK__
		If bNotChange Then
			bNotChange = False
			Exit Sub
		End If
	#endif
	PropertyChanged Sender, cboPropertyValue.Text, True
End Sub

Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) As UString
	If StartsWith(FileName, GetFolderName(FilePath)) Then
		Return Mid(FileName, Len(GetFolderName(FilePath)) + 1)
	Else
		Return FileName
	End If
End Function

Function GetFullPathInSystem(ByRef Path As WString) As UString
	If InStr(Path, ":") > 0 OrElse Path = "" Then
		Return Path
	Else
		Dim As WString * MAX_PATH fullPath
		#ifdef __USE_GTK__
			If FileExists(ExePath & Slash & Path) Then
				fullPath = ExePath & Slash & Path
			Else
				fullPath = WStr(*g_find_program_in_path(Path))
			End If
		#else
			Dim As WString Ptr lpFilePart
			If SearchPath(NULL, Path, ".exe", MAX_PATH - 1, @fullPath, 0) = 0 Then
				
			End If
		#endif
		Return fullPath
	End If
End Function

Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
	If CInt(InStr(Path, ":") > 0) OrElse CInt(StartsWith(Path, "/")) OrElse CInt(StartsWith(Path, "\")) Then
		If EndsWith(Path, "\..") OrElse EndsWith(Path, "/..") Then
			Return GetFolderName(GetFolderName(Path))
		Else
			Return Path
		End If
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
		If FromFile = "" Then
			Dim As UString Path_ = GetFullPathInSystem(Path)
			If Path_ <> "" Then
				Return Path_
			Else
				Return ExePath & Slash & Path
			End If
		Else
			Return GetFolderName(FromFile) & Path
		End If
	End If
End Function

Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
	Dim Posi As Long = InStrRev(FileName, Any "\/", Len(FileName) - 1)
	If Posi <= 0 Then Return ""
	If Not WithSlash Then Posi -= 1
	Return Left(FileName, Posi)
End Function

Function GetFileName(ByRef FileName As WString, WithExtension As Boolean = True) As UString
	Dim As Long nPos, Posi = InStrRev(FileName, Any "\/:")
	nPos = InStrRev(FileName, ".")
	If nPos < 1 OrElse nPos < Posi Then nPos = Len(FileName)
	If Posi > 0 Then
		Return IIf(WithExtension, Mid(FileName, Posi + 1), Mid(FileName, Posi + 1, nPos - Posi - 1))
	Else
		Return IIf(WithExtension, FileName, Mid(FileName, 1, nPos - 1))
	End If
End Function

Function GetBakFileName(ByRef FileName As WString) As UString
	If FileName = "" Then Return ""
	Dim As String BakDate = Format(Now, "yyyymmdd_hhmm") 'David Change ReplaceAny(__DATE_ISO__ & "_" & Time,":/\-","")
	Dim As WString * MAX_PATH iFileName
	Dim Pos1 As Long = InStrRev(FileName, ".")
	If Pos1 = 0 Then Pos1 = Len(FileName)
	If Pos1 > 0 Then
		Return ExePath + "/Temp/" + GetFileName(FileName) + "_" & BakDate & ".bak"
	Else
		Return ExePath + "/Temp/" + BakDate & ".bak"
	End If
End Function

Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) As UString
	Dim As UString CompileWith = " " & Replace(LTrim(sLine), BackSlash, Slash)
	Dim As UString pFileName = Replace(FileName, BackSlash, Slash)
	Dim As UString ExeFileName
	Dim As String SearchChar
	Dim As Long Pos1, Pos2
	Pos1 = InStr(CompileWith, " -x ")
	If Pos1 > 0 Then
		If Mid(CompileWith, Pos1 + 4, 1) = """" Then
			SearchChar = """"
		Else
			SearchChar = " "
			Pos1 -= 1
		End If
		Pos2 = InStr(Pos1 + 5, CompileWith, SearchChar)
		If Pos2 > 0 Then
			ExeFileName = Mid(CompileWith, Pos1 + 5, Pos2 - Pos1 - 5)
		Else
			ExeFileName = Mid(CompileWith, Pos1 + 5)
		End If
		If CInt(InStr(ExeFileName, ":") = 0) AndAlso CInt(Not StartsWith(ExeFileName, Slash)) Then
			Return GetFolderName(pFileName) + ExeFileName
		Else
			Return ExeFileName
		End If
	End If
	Pos1 = InStrRev(pFileName, ".")
	If Pos1 = 0 Then Pos1 = Len(pFileName) + 1
	If Pos1 > 0 Then
		#ifdef __USE_GTK__
			Pos2 = InStrRev(pFileName, Slash)
			If Pos2 > 0 AndAlso InStr(CompileWith, "-dll") > 0 Then
				Return Left(pFileName, Pos2) & "lib" & Mid(pFileName, Pos2 + 1, Pos1 - Pos2 - 1) & ".so"
			Else
				Return IIf(InStr(CompileWith, "-dll") + InStr(CompileWith, "-lib") > 0, "lib", "") & Left(pFileName, Pos1 - 1) & IIf(InStr(CompileWith, "-dll"), ".so", IIf(InStr(CompileWith, "-lib"), ".o", ""))
			End If
		#else
			If InStr(CompileWith, "-target js-asmjs") Then
				Return Left(pFileName, Pos1 - 1) & ".html"
			ElseIf InStr(CompileWith, "-target ") Then
				Pos2 = InStrRev(pFileName, Slash)
				If Pos2 > 0 AndAlso InStr(CompileWith, "-dll") + InStr(CompileWith, "-lib") > 0 Then
					Return Left(pFileName, Pos2) & "lib" & Mid(pFileName, Pos2 + 1, Pos1 - Pos2 - 1) & ".so"
				Else
					Return IIf(InStr(CompileWith, "-dll") + InStr(CompileWith, "-lib") > 0, "lib", "") & Left(pFileName, Pos1 - 1) & IIf(InStr(CompileWith, "-dll"), ".so", IIf(InStr(CompileWith, "-lib"), ".o", ""))
				End If
			Else
				Return Left(pFileName, Pos1 - 1) & IIf(InStr(CompileWith, "-dll"), ".dll", ".exe")
			End If
		#endif
	End If
End Function

Function Compile(Parameter As String = "", bAll As Boolean = False) As Integer
	On Error Goto ErrorHandler
	Dim As WString Ptr MainFileNameOnly, MainFile, LogFileName, LogFileName2, LogText, BatFileName, fbcCommand, PipeApplicationName, PipeCommand, fbcCommand1, PipeCommand1
	Dim As WString Ptr CompileWith, MFFPathC, ErrFileName, ErrTitle, ExeName, FirstLine, ProjectPath
	Dim As Integer NumberErr, NumberWarning, NumberInfo, NodesCount, CompileResult = 1
	Dim As UString CompileLine
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As Boolean Bit32 = tbt32Bit->Checked
	Dim As WString Ptr FbcExe, CurrentCompiler = IIf(Bit32, CurrentCompiler32, CurrentCompiler64)
	ThreadsEnter()
	ClearMessages
	NodesCount = IIf(bAll, tvExplorer.Nodes.Count, 1)
	StartProgress
	lvProblems.ListItems.Clear
	tpProblems->Caption = ML("Problems") '    'Inits
	ThreadsLeave()
	For k As Integer = 0 To NodesCount - 1
		ThreadsEnter()
		If bAll Then ProjectNode = tvExplorer.Nodes.Item(k) Else ProjectNode = 0
		WLet(MainFile, GetMainFile(AutoSaveBeforeCompiling, Project, ProjectNode))
		If Project Then
			If EndsWith(LCase(*Project->FileName), ".vfp") Then
				WLet(ProjectPath, GetFolderName(*Project->FileName))
			Else
				WLet(ProjectPath, *Project->FileName)
			End If
		Else
			WLet(ProjectPath, GetFolderName(*MainFile))
		End If
		ThreadsLeave()
		If Len(*MainFile) <= 0 Then
			ThreadsEnter()
			ShowMessages ML("No Main file specified for the project.") & "!"
			ThreadsLeave()
			CompileResult = 0
			Continue For
		End If
		WLet(FirstLine, GetFirstCompileLine(*MainFile, Project, CompileLine))
		Versioning *MainFile, *FirstLine & CompileLine, Project, ProjectNode
		Dim FileOut As Integer
		WLet(ExeName, GetExeFileName(*MainFile, CompileLine & " " & *FirstLine))
		If Project AndAlso Trim(*Project->CompilerPath) <> "" Then
			WLet(FbcExe, GetFullPath(*Project->CompilerPath))
		Else
			WLet(FbcExe, GetFullPath(IIf(Bit32, *Compiler32Path, *Compiler64Path)))
		End If
		If *FbcExe = "" Then
			ThreadsEnter()
			ShowMessages ML("Invalid defined compiler path.")
			ThreadsLeave()
			CompileResult = 0
			Continue For
		ElseIf InStr(GetFolderName(GetFullPathInSystem(*FbcExe)), " ") > 0 Then
			ThreadsEnter()
			ShowMessages ML("It is impossible to use a compiler that has a space in the paths.")
			ThreadsLeave()
			CompileResult = 0
			Continue For
		Else
			ChDir(ExePath)
			#ifdef __USE_GTK__
				If g_find_program_in_path(ToUtf8(*FbcExe)) = NULL Then
			#else
				If Not FileExists(*FbcExe) Then
			#endif
				ThreadsEnter()
				ShowMessages ML("File") & " """ & *FbcExe & """ " & ML("not found") & "!"
				ThreadsLeave()
				CompileResult = 0
				Continue For
			End If
		End If
		Dim As Integer iLine
		WLet(MFFPathC, *MFFPath)
		If CInt(InStr(*MFFPathC, ":") = 0) AndAlso CInt(Not StartsWith(*MFFPathC, "/")) Then WLet(MFFPathC, ExePath & "/" & *MFFPath)
		WLet(BatFileName, ExePath + "/debug.bat")
		Dim As Boolean Band, Yaratilmadi
		Dim As UserToolType Ptr Tool
		For i As Integer = 0 To Tools.Count - 1
			Tool = Tools.Item(i)
			If Tool->LoadType = LoadTypes.BeforeCompile Then Tool->Execute
		Next
		Dim As Any Ptr AddInDll
		Dim As Sub(VisualFBEditorApp As Any Ptr, ByRef CompilingProgramPath As WString) OnBeforeCompile
		For i As Integer = 0 To AddIns.Count - 1
			AddInDll = AddIns.Object(i)
			If AddInDll <> 0 Then
				OnBeforeCompile = DyLibSymbol(AddInDll, "OnBeforeCompile")
				If OnBeforeCompile Then
					OnBeforeCompile(@VisualFBEditorApp, *ExeName)
				End If
			End If
		Next
		ChDir(GetFolderName(*MainFile))
		If Parameter = "Check" Then
			WLet(ExeName, "chk.dll")
		End If
		If Dir(*ExeName) <> "" Then 'delete exe if exist
			If *ExeName = ExePath OrElse Kill(*ExeName) <> 0 Then
				ThreadsEnter()
				ShowMessages(Str(Time) & ": " &  ML("Cannot compile - the program is now running") & " " & *ExeName) '
				ThreadsLeave()
				Band = True
				CompileResult = 0
				Continue For
			End If
		End If
		Dim As Integer Idx
		Dim As ToolType Ptr CompilerTool
		If Parameter = "Make" Then
			Idx = pMakeTools->IndexOfKey(*CurrentMakeTool1)
			If Idx <> -1 Then CompilerTool = pMakeTools->Item(Idx)->Object
		ElseIf Parameter = "MakeClean" Then
			Idx = pMakeTools->IndexOfKey(*CurrentMakeTool2)
			If Idx <> -1 Then CompilerTool = pMakeTools->Item(Idx)->Object
		Else
			Idx = pCompilers->IndexOfKey(*CurrentCompiler)
			If Idx <> -1 Then CompilerTool = pCompilers->Item(Idx)->Object
		End If
		If CompilerTool <> 0 Then
			WLet(CompileWith, CompilerTool->GetCommand(, True))
		End If
		WAdd(CompileWith, " " & *FirstLine)
		WLet(MainFileNameOnly, GetFileName(*MainFile))
		'If IncludeMFFPath Then WAdd CompileWith, " -i """ & *MFFPathC & """"
		Dim As Boolean UseWasm = InStr(*FirstLine & CompileLine, "__USE_WASM__") > 0
		'If UseWasm Then
		'	WAdd CompileWith, " -Wl ""--post-js " & *MFFPathC & "\mff\Web\mff.js"""
		'End If
		If Project Then
			For i As Integer = 0 To Project->Components.Count - 1
				If EndsWith(Project->Components.Item(i), Slash) Then
					WAdd CompileWith, " -i """ & GetRelativePath(Left(Project->Components.Item(i), Len(Project->Components.Item(i)) - 1), *ProjectPath & Slash) & """"
				Else
					WAdd CompileWith, " -i """ & GetRelativePath(Project->Components.Item(i), *ProjectPath & Slash) & """"
				End If
			Next
		End If
		Dim CtlLibrary As Library Ptr
		For i As Integer = 0 To ControlLibraries.Count - 1
			CtlLibrary = ControlLibraries.Item(i)
			If CtlLibrary <> 0 AndAlso CtlLibrary->Enabled Then
				If EndsWith(CtlLibrary->IncludeFolder, Slash) Then
					WAdd CompileWith, " -i """ & Left(CtlLibrary->IncludeFolder, Len(CtlLibrary->IncludeFolder) - 1) & """"
				Else
					WAdd CompileWith, " -i """ & CtlLibrary->IncludeFolder & """"
				End If
				Dim As UString LibFolder
				#ifdef __FB_WIN32__
					#ifdef __FB_ARM__
						LibFolder = CtlLibrary->Lib64ArmFolder
					#else
						If Bit32 Then
							LibFolder = CtlLibrary->Lib32Folder
						Else
							LibFolder = CtlLibrary->Lib64Folder
						End If
					#endif
				#else
					If Bit32 Then
						LibFolder = CtlLibrary->LibX32Folder
					Else
						LibFolder = CtlLibrary->LibX64Folder
					End If
				#endif
				If LibFolder <> "" Then
					If EndsWith(LibFolder, Slash) Then
						WAdd CompileWith, " -p """ & Left(LibFolder, Len(LibFolder) - 1) & """"
					Else
						WAdd CompileWith, " -p """ & LibFolder & """"
					End If
				End If
			End If
		Next
		
		For i As Integer = 0 To pIncludePaths->Count - 1
			WAdd CompileWith, " -i """ & pIncludePaths->Item(i) & """"
		Next
		For i As Integer = 0 To pLibraryPaths->Count - 1
			WAdd CompileWith, " -p """ & pLibraryPaths->Item(i) & """"
		Next
		WAdd CompileWith, " -d _DebugWindow_=" & Str(txtImmediate.Handle)
		'WLet LogFileName, ExePath & "/Temp/debug_compil.log"
		WLet(LogFileName2, ExePath & "/Temp/Compile.log")
		Dim As UString OtherModuleFiles
		If CInt(ProjectNode <> 0) AndAlso CInt(Project <> 0) AndAlso CInt(Project->PassAllModuleFilesToCompiler) Then
			For i As Integer = 0 To ProjectNode->Nodes.Count - 1
				If EndsWith(LCase(ProjectNode->Nodes.Item(i)->Text), ".bas") Then
					If LCase(*MainFileNameOnly) <> LCase(ProjectNode->Nodes.Item(i)->Text) Then
						OtherModuleFiles &= " """ & GetRelative(*Cast(ExplorerElement Ptr, ProjectNode->Nodes.Item(i)->Tag)->FileName, GetFolderName(*Project->MainFileName)) & """"
					End If
				Else
					For j As Integer = 0 To ProjectNode->Nodes.Item(i)->Nodes.Count - 1
						If EndsWith(LCase(ProjectNode->Nodes.Item(i)->Nodes.Item(j)->Text), ".bas") Then
							If LCase(*MainFileNameOnly) <> LCase(ProjectNode->Nodes.Item(i)->Nodes.Item(j)->Text) Then
								OtherModuleFiles &= " """ & GetRelative(*Cast(ExplorerElement Ptr, ProjectNode->Nodes.Item(i)->Nodes.Item(j)->Tag)->FileName, GetFolderName(*Project->MainFileName)) & """"
							End If
						End If
					Next
				End If
			Next
		End If
		If InStr(*CompileWith, "{S}") > 0 Then
			WLet(fbcCommand, Replace(*CompileWith, "{S}", """" & *MainFileNameOnly & """" & OtherModuleFiles))
		Else
			WLet(fbcCommand, """" & *MainFileNameOnly & """" & OtherModuleFiles & " " & *CompileWith)
		End If
		If Parameter <> "" AndAlso Parameter <> "Make" AndAlso Parameter <> "MakeClean" Then
			If Parameter = "Check" Then WAdd fbcCommand, " -x """ & *ExeName & """"
		End If
		If CInt(Parameter = "Make") OrElse CInt(CInt(Parameter = "Run") AndAlso CInt(UseMakeOnStartWithCompile) AndAlso CInt(FileExists(GetFolderName(*MainFile) & "/makefile") OrElse FileExists(*ProjectPath & "/makefile"))) Then
			Dim As String Colon = ""
			#ifdef __USE_GTK__
				Colon = ":"
			#endif
			WLet(PipeCommand, """" & *MakeToolPath1 & """ FBC" & Colon & "=""""""" & *FbcExe & """"""" XFLAG" & Colon & "=""-x """"" & *ExeName & """""""" & IIf(UseDebugger, " GFLAG" & Colon & "=-g", "") & " " & *Make1Arguments)
		ElseIf Parameter = "MakeClean" Then
			WLet(PipeCommand, """" & *MakeToolPath2 & """ " & *Make2Arguments)
		Else
			WLet(PipeCommand, """" & *FbcExe & """ " & *fbcCommand)
		End If
		'	' for better showing
		'	#ifdef __USE_GTK__
		'		*PipeCommand=Replace(Replace(*PipeCommand,"\","/"),"/./","/")
		'	#else
		'		*PipeCommand=Replace(Replace(*PipeCommand,"/","\"),"\.\","\")
		'	#endif
		'OPEN *BatFileName For Output As #FileOut
		'Print #FileOut, *fbcCommand  + " > """ + *LogFileName + """" + " 2>""" + *LogFileName2 + """"
		'Close #FileOut
		'Shell("""" + BatFileName + """")
		Dim As WString Ptr BatchCompilationFileName
		#ifdef __FB_WIN32__
			If Project Then BatchCompilationFileName = Project->BatchCompilationFileNameWindows
		#else
			If Project Then BatchCompilationFileName = Project->BatchCompilationFileNameLinux
		#endif
		If WGet(BatchCompilationFileName) <> "" AndAlso Parameter <> "Make" AndAlso Parameter <> "MakeClean" Then 'CBool(Project <> 0) AndAlso (Not EndsWith(*Project->FileName, ".vfp")) AndAlso FileExists(*Project->FileName & "/gradlew") Then
			If EndsWith(LCase(*BatchCompilationFileName), "gradlew.bat") OrElse EndsWith(LCase(*BatchCompilationFileName), "/gradlew") Then
				Dim As String gradlewFile, gradlewCommand
				If Parameter = "Bundle" Then
					gradlewCommand = "bundleRelease"
				ElseIf Parameter = "APK" Then
					gradlewCommand = "assembleRelease"
				Else
					gradlewCommand = "assembleDebug"
				End If
				#ifdef __FB_WIN32__
					gradlewFile = "gradlew.bat"
				#else
					gradlewFile = "./gradlew"
				#endif
				WLet(PipeCommand, gradlewFile & " " & gradlewCommand)
			ElseIf LCase(GetFileName(*BatchCompilationFileName)) = "makefile" Then
				WLet(PipeCommand, "make")
			Else
				WLet(PipeCommand, *BatchCompilationFileName)
			End If
			ChDir(GetFolderName(*BatchCompilationFileName))
			Dim As Integer Fn1 = FreeFile_
			Open *BatchCompilationFileName For Input As #Fn1
			Dim pBuff As WString Ptr
			Dim As Integer FileSize
			Dim As WStringList Lines
			FileSize = LOF(Fn1)
			WReAllocate(pBuff, FileSize)
			Do Until EOF(Fn1)
				LineInputWstr Fn1, pBuff, FileSize
				Lines.Add *pBuff
			Loop
			CloseFile_(Fn1)
			WDeAllocate(pBuff)
			Dim As Integer Fn2 = FreeFile_
			Open *BatchCompilationFileName For Output As #Fn2
			For i As Integer = 0 To Lines.Count - 1
				If StartsWith(Lines.Item(i), "set FBC=") Then
					Print #Fn2, "set FBC=" & *FbcExe
				ElseIf StartsWith(Lines.Item(i), "set MFF=") Then
					Print #Fn2, "set MFF=" & *MFFPathC
				ElseIf StartsWith(Lines.Item(i), "set NDK=") Then
					Print #Fn2, "set NDK=" & *Project->AndroidNDKLocation
				Else
					Print #Fn2, Lines.Item(i)
				End If
			Next i
			CloseFile_(Fn2)
		Else
			If CInt(Parameter = "Make") OrElse CInt(Parameter = "MakeClean") OrElse CInt(CInt(Parameter = "Run") AndAlso CInt(UseMakeOnStartWithCompile) AndAlso CInt(FileExists(GetFolderName(*MainFile) & "/makefile") OrElse FileExists(*ProjectPath & "/makefile"))) Then
				If FileExists(GetFolderName(*MainFile) & "/makefile") Then
					ChDir(GetFolderName(*MainFile))
				Else
					ChDir(*ProjectPath)
				End If
			Else
				ChDir(GetFolderName(*MainFile))
			End If
		End If
		'Shell(*fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """")
		'Open Pipe *fbcCommand  + "> """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """" For Input As #Fn
		'Close #Fn
		'PipeCmd "", *PipeCommand & " > """ + *LogFileName + """" + " 2> """ + *LogFileName2 + """"
		
		Dim As Long nLen, nLen2
		Dim As Boolean Log2_, ERRGoRc
		Dim As Integer Result = -1
		Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
		#ifdef __USE_GTK__
			WLetEx(PipeCommand, *PipeCommand & " 2> """ + *LogFileName2 + """", True)
		#else
			'WLetEx PipeCommand, """" & *PipeCommand & " 2> """ + *LogFileName2 + """" & """", True
		#endif
		If Parameter <> "Check" Then
			ThreadsEnter()
			ShowMessages(Str(Time) + ": " + IIf(Parameter = "MakeClean", ML("Clean"), ML("Compilation")) & ": " & *PipeCommand + WChr(13) + WChr(10))
			ThreadsLeave()
		End If
		Dim As Dictionary CompileCommands
		If UseWasm Then
			Dim FbcFolder As UString = GetFolderName(*FbcExe)
			Var Pos1 = InStrRev(*MainFileNameOnly, ".")
			If Pos1 > 0 Then
				*MainFileNameOnly = Left(*MainFileNameOnly, Pos1 - 1)
			End If
			CompileCommands.Add "", *PipeCommand
			CompileCommands.Add "compiling C :  ", GetFullPath("emcc") & " -c -nostdlib -nostdinc -Wall -Wno-unused-label -Wno-unused-function -Wno-unused-variable -Wno-warn-absolute-paths -Wno-main -Werror-implicit-function-declaration -fno-strict-aliasing -fno-math-errno -fwrapv -fno-exceptions -fno-asynchronous-unwind-tables -funwind-tables -Wno-format """ & *MainFileNameOnly & ".c"" -o """ & *MainFileNameOnly & ".o"""
			'CompileCommands.Add "linking :      ", GetFullPath("emcc") & " -o """ & *MainFileNameOnly & ".html"" -O0 -Wno-warn-absolute-paths -s CASE_INSENSITIVE_FS=1 -s TOTAL_MEMORY=67108864 -s ALLOW_MEMORY_GROWTH=1 -s RETAIN_COMPILER_SETTINGS=1 --shell-file """ & FbcFolder & "lib\js-asmjs\fb_shell.html"" --post-js """ & FbcFolder & "lib\js-asmjs\fb_rtlib.js"" --post-js """ & FbcFolder & "lib\js-asmjs\termlib_min.js"" -L""" & FbcFolder & "lib\js-asmjs"" -L""."" """ & *MainFileNameOnly & ".o"" -lfb -lfb  -s ASYNCIFY=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s WASM=1 -s EXPORTED_FUNCTIONS=""['_ONLOAD']"" --post-js " & *MFFPathC & "\mff\Web\mff.js"
			Dim As String EXPORTED_FUNCTIONS = "'_ONSTART', '_ONLOAD', '_ONCHANGE', '_ONCLICK', '_ONCLOSE', '_ONDBLCLICK', '_ONGOTFOCUS', '_ONLOSTFOCUS', '_ONKEYDOWN', '_ONKEYPRESS', '_ONKEYUP', '_ONMOUSEENTER', '_ONMOUSEDOWN', '_ONMOUSEMOVE', '_ONMOUSEUP', '_ONMOUSELEAVE', '_ONMOUSEWHEEL', '_ONUNLOAD'"
			For i As Integer = 0 To Globals.Functions.Count - 1
				
			Next
			CompileCommands.Add "linking :      ", GetFullPath("emcc") & " -o """ & *MainFileNameOnly & ".html"" -O0 -Wno-warn-absolute-paths -s CASE_INSENSITIVE_FS=1 -s TOTAL_MEMORY=67108864 -s ALLOW_MEMORY_GROWTH=1 -s DEFAULT_LIBRARY_FUNCS_TO_INCLUDE=$stringToNewUTF8 -s RETAIN_COMPILER_SETTINGS=1 --shell-file """ & *MFFPathC & "\mff\Web\mff.html"" --post-js """ & FbcFolder & "lib\js-asmjs\fb_rtlib.js"" --post-js """ & FbcFolder & "lib\js-asmjs\termlib_min.js"" -L""" & FbcFolder & "lib\js-asmjs"" -L""."" """ & *MainFileNameOnly & ".o"" -lfb -lfb  -s ASYNCIFY=1 -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s WASM=1 -s EXPORTED_FUNCTIONS=""[" & EXPORTED_FUNCTIONS & "]"" --post-js " & *MFFPathC & "\mff\Web\mff.js"
		Else
			CompileCommands.Add "", *PipeCommand
		End If
		Dim As UShort bFlagErr
		Dim As Double CompileElapsedTime = Timer
		For cc As Integer = 0 To CompileCommands.Count - 1
			WLet(PipeCommand, CompileCommands.Item(cc)->Text)
			If cc > 0 Then
				If UseWasm AndAlso CBool(cc = 1) Then
					'Var Fn = FreeFile_
					'If Open(*MainFileNameOnly & ".c" For Input As #Fn) = 0 Then
					'	Dim As String Buffer
					'	Dim As WStringList Lines
					'	Lines.Add "typedef void fn(void); fn *volatile fp;"
					'	Do Until EOF(Fn)
					'		Line Input #Fn, Buffer
					'		If StartsWith(Trim(Buffer, Any !"\t "), "goto *") Then
					'			Var n = Len(Buffer) - Len(Trim(Buffer, Any !"\t "))
					'			Lines.Add Left(Buffer, n) & "fp = (fn*)" & Mid(Buffer, n + 7) & " fp();"
					'		'ElseIf InStr(Buffer, " goto ") > 0 Then
					'		'	Lines.Add Buffer
					'		'ElseIf InStr(Buffer, "goto ") > 0 Then
					'		'	Lines.Add Buffer
					'		Else
					'			Lines.Add Buffer
					'		End If
					'	Loop
					'	Close #Fn
					'	Fn = FreeFile_
					'	Open *MainFileNameOnly & ".c" For Output As #Fn
					'	For ii As Integer = 0 To Lines.Count - 1
					'		Print #Fn, Lines.Item(ii)
					'	Next
					'	Close #Fn
					'End If
				End If
				ThreadsEnter()
				ShowMessages(Str(Time) + ": " + CompileCommands.Item(cc)->Key & *PipeCommand)
				ThreadsLeave()
			End If
			Dim As String TmpStrKey = "@freebasic compiler@copyright@standalone@target@backend@compiling@compiling rc@compiling rc failed@compiling c@assembling@linking@obj@creating@restarting@creating import library@archiving@"
			Dim As WString * 2048 TmpStr
			#ifdef __USE_GTK__
				Dim As Integer Fn = FreeFile_
				If Open Pipe(*PipeCommand For Input As #Fn) = 0 Then
					While Not EOF(Fn)
						Line Input #Fn, Buff
						If Len(Trim(Buff)) <= 1 OrElse StartsWith(Trim(Buff), "|") Then Continue While
						Dim As Integer nPos = InStr(Buff, ":")
						If nPos < 1 Then nPos = InStr(Buff, " ")
						If nPos < 1 Then
							nPos = Len(Buff) + 1
							TmpStr = Trim(Buff)
						Else
							TmpStr = Trim(Left(Buff, nPos - 1))
						End If
						Dim As Boolean bErrorInfo = InStr(LCase(TmpStrKey), "@" & LCase(TmpStr) & "@") OrElse InStr(LCase(Buff), "ld.exe") > 0
						If Not bErrorInfo Then
							ThreadsEnter()
							ShowMessages(Buff, False)
							ThreadsLeave()
							bFlagErr = SplitError(Buff, ErrFileName, ErrTitle, iLine)
							If iLine > 0 OrElse InStr(LCase(*ErrTitle), "runtime error") > 0 Then
								If bFlagErr = 2 Then
									NumberErr += 1
								ElseIf bFlagErr = 1 Then
									NumberWarning += 1
								Else
									NumberInfo += 1
								End If
							End If
							If 	bFlagErr >= 0 Then
								ThreadsEnter()
								If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet(ErrFileName, GetFolderName(*MainFile) & *ErrFileName)
								lvProblems.ListItems.Add *ErrTitle, IIf(bFlagErr = 1, "Warning", IIf(bFlagErr = 2, "Error", "Info"))
								lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(1) = WStr(iLine)
								lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(2) = *ErrFileName
								'ShowMessages(Buff, False)
								ThreadsLeave()
							End If
						Else
							ThreadsEnter()
							ShowMessages Str(Time) & ": " & ML(TmpStr) & " " & Trim(Mid(Buff, nPos))
							ThreadsLeave()
						End If
					Wend
				End If
				CloseFile_(Fn)
			#else
				Dim As Integer BufferSize = 128
				Dim si As STARTUPINFO
				Dim pi As PROCESS_INFORMATION
				Dim sa As SECURITY_ATTRIBUTES
				Dim hReadPipe As HANDLE
				Dim hWritePipe As HANDLE
				Dim sBuffer As ZString * 2048
				Dim sOutput As UString
				Dim bytesRead As DWORD
				Dim result_ As Integer
				
				sa.nLength = SizeOf(SECURITY_ATTRIBUTES)
				sa.lpSecurityDescriptor = NULL
				sa.bInheritHandle = True
				
				If CreatePipe(@hReadPipe, @hWritePipe, @sa, ByVal 0) = 0 Then
					ShowMessages(ML("Error: Couldn't Create Pipe"), False)
					CompileResult = 0
					Continue For
				End If
				
				si.cb = Len(STARTUPINFO)
				si.dwFlags = STARTF_USESTDHANDLES Or STARTF_USESHOWWINDOW
				si.hStdOutput = hWritePipe
				si.hStdError = hWritePipe
				si.hStdInput  = hReadPipe
				si.wShowWindow = 0
				
				If CreateProcess(PipeApplicationName, PipeCommand, @sa, @sa, 1, NORMAL_PRIORITY_CLASS Or CREATE_NEW_CONSOLE, ByVal 0, ByVal 0, @si, @pi) = 0 Then
					ShowMessages(ML("Error: Couldn't Create Process") & ": " & GetErrorString(GetLastError), False)
					CompileResult = 0
					Continue For
				End If
				
				CloseHandle hWritePipe
				Dim As Integer Pos1, PosFirstErr, FirstErrFlag
				Do
					result_ = ReadFile(hReadPipe, @sBuffer, BufferSize, @bytesRead, ByVal 0)
					sBuffer = Left(sBuffer, bytesRead)
					If CBool(FirstErrFlag < 2) AndAlso CBool(InStr(sBuffer, "compiling:")) Then sBuffer += Chr(10) : FirstErrFlag += 1: BufferSize = 2048
					Pos1 = InStrRev(sBuffer, Chr(10))
					If Pos1 > 0 Then
						sOutput += Left(sBuffer, Pos1 - 1)
						Dim res() As WString Ptr
						If CBool(InStr(sOutput, "GoRC.exe' terminated with exit code") > 0) OrElse CBool(InStr(sOutput, "of Resource Script ") > 0) Then
							sOutput = Replace(sOutput, Chr(13, 10), " ")
							ERRGoRc = True
						End If
						Dim As String buffer = Str(sOutput)
						Dim As Integer wideCharsNeeded = MultiByteToWideChar(CP_ACP, 0, StrPtr(buffer), -1, NULL, 0)
						sOutput.Resize wideCharsNeeded
						MultiByteToWideChar(CP_ACP, 0, StrPtr(buffer), -1, sOutput.m_Data, wideCharsNeeded)
						Split sOutput, Chr(10), res()
						For i As Integer = 0 To UBound(res) 'Copyright
							*res(i) = Trim(*res(i), Any !"\t\n\r ")
							If Len(*res(i)) < 10 OrElse StartsWith(Trim(*res(i)), "|") Then Continue For
							Dim As Integer nPos = InStr(*res(i), ":")
							If nPos < 1 Then nPos = InStr(*res(i), " ")
							If nPos < 1 Then
								nPos = Len(*res(i)) + 1
								TmpStr = Trim(*res(i))
							Else
								TmpStr = Trim(Left(*res(i), nPos - 1))
							End If
							Dim As Boolean bErrorInfo = InStr(LCase(TmpStrKey), "@" & LCase(TmpStr) & "@") OrElse InStr(LCase(*res(i)), "ld.exe") > 0
							If Not bErrorInfo Then
								bFlagErr = SplitError(*res(i), ErrFileName, ErrTitle, iLine)
								If iLine > 0 OrElse InStr(LCase(*ErrTitle), "runtime error") > 0 Then
									If bFlagErr = 2 Then
										NumberErr += 1
									ElseIf bFlagErr = 1 Then
										NumberWarning += 1
									Else
										NumberInfo += 1
									End If
									
								End If
								If bFlagErr >= 0 AndAlso *ErrFileName <> "" AndAlso iLine> 0 Then
									If InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet(ErrFileName, GetFolderName(*MainFile) & *ErrFileName)
									lvProblems.ListItems.Add *ErrTitle, IIf(bFlagErr = 1, "Warning", IIf(bFlagErr = 2, "Error", "Info"))
									lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(1) = WStr(iLine)
									lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(2) = *ErrFileName
									FirstErrFlag += 1
									ShowMessages(*res(i), False)
								Else
									ShowMessages(Str(Time) & ": " & *res(i), False)
								End If
							Else
								If StartsWith(TmpStr, "FreeBASIC") Then
									nPos = Len(*res(i)) + 1
									TmpStr = Replace(Replace(*res(i), "FreeBASIC Compiler", ML("FreeBASIC Compiler")), "Version", ML("Version"))
									Var Pos1 = InStr(TmpStr, "built for ")
									If Pos1 > 0 Then
										TmpStr = Left(TmpStr, Pos1 - 1) & MS("built for $1", Mid(TmpStr, Pos1 + 10))
									End If
								ElseIf StartsWith(TmpStr, "Copyright") Then
									nPos = Len(*res(i)) + 1
									TmpStr = Replace(Replace(*res(i), "Copyright", ML("Copyright")), "The FreeBASIC development team.", ML("The FreeBASIC development team."))
								End If
								#if 0
									ML("standalone")
									ML("target")
									ML("backend")
									ML("compiling")
									ML("compiling C")
									ML("assembling")
									ML("compiling rc")
									ML("linking")
									ML("OBJ file not made")
									ML("creating import library")
									ML("compiling rc failed")
									ML("Restarting fbc")
									ML("creating")
									ML("archiving")
									ML("Error")
									ML("Warning")
								#endif
								ThreadsEnter()
								ShowMessages Str(Time) & ": " & ML(TmpStr) & " " & Trim(Mid(*res(i), nPos))
								ThreadsLeave()
							End If
							_Deallocate(res(i)): res(i) = 0
							sOutput = ""
						Next i
						Erase res
						If sBuffer <> "" Then sOutput = Mid(sBuffer, Pos1 + 1)
					Else
						sOutput += sBuffer
					End If
				Loop While result_
				
				CloseHandle pi.hProcess
				CloseHandle pi.hThread
				CloseHandle hReadPipe
			#endif
			If NumberErr > 0 Then Exit For
		Next cc
		#ifdef __USE_GTK__
			Yaratilmadi = g_find_program_in_path(ToUtf8(*ExeName)) = NULL
		#else
			Yaratilmadi = Dir(*ExeName) = ""
		#endif
		'Delete the default ManifestFile And IcoFile
		'If ManifestIcoCopy Then Kill GetFolderName(*MainFile) & "Manifest.xml": Kill GetFolderName(*MainFile) & "Form1.rc": Kill GetFolderName(*MainFile) & "Form1.ico"
		#ifdef __USE_GTK__
			Dim Fn As Integer = FreeFile_
			Result = -1
			Result = Open(*LogFileName2 For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(*LogFileName2 For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(*LogFileName2 For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(*LogFileName2 For Input As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, Buff
					'If Trim(*Buff) <> "" Then lvErrors.ListItems.Add *Buff
					bFlagErr = SplitError(Buff, ErrFileName, ErrTitle, iLine)
					If bFlagErr = 2 Then
						NumberErr += 1
					ElseIf bFlagErr = 1 Then
						NumberWarning += 1
					Else
						NumberInfo += 1
					End If
					ThreadsEnter()
					If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet(ErrFileName, GetFolderName(*MainFile) & *ErrFileName)
					lvProblems.ListItems.Add *ErrTitle, IIf(InStr(*ErrTitle, "warning"), "Warning", IIf(InStr(LCase(*ErrTitle), "error"), "Error", "Info"))
					lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(1) = WStr(iLine)
					lvProblems.ListItems.Item(lvProblems.ListItems.Count - 1)->Text(2) = *ErrFileName
					ShowMessages(Buff, False)
					ThreadsLeave()
					'*LogText = *LogText & *Buff & WChr(13) & WChr(10)
					Log2_ = True
				Wend
			End If
			CloseFile_(Fn)
		#endif
		ThreadsEnter()
		ShowMessages("")
		If lvProblems.ListItems.Count <> 0 Then
			tpProblems->Caption = ML("Problems") & IIf(NumberErr + NumberWarning + NumberInfo > 0, " (" & WStr(NumberErr + NumberWarning + NumberInfo) & " " & ML("Pos") & ")", "")
			Dim As UString Problems
			Problems = IIf(NumberErr > 0, ML("Errors") & " (" & WStr(NumberErr) & " " & ML("Pos") & ")", "")
			Problems &= IIf(NumberWarning > 0, IIf(Problems = "", "", ", ") & ML("Warnings") & " (" & WStr(NumberWarning) & " " & ML("Pos") & ")", "")
			Problems &= IIf(NumberInfo > 0, IIf(Problems = "", "", ", ") & ML("Messages") & " (" & WStr(NumberInfo) & " " & ML("Pos") & ")", "")
			ShowMessages(Str(Time) & ": " & MS("Found $1.", *Problems.vptr), False)
		Else
			tpProblems->Caption = ML("Problems")
		End If
		ThreadsLeave()
		For i As Integer = 0 To Tools.Count - 1
			Tool = Tools.Item(i)
			If Tool->LoadType = LoadTypes.AfterCompile Then Tool->Execute
		Next
		If Yaratilmadi Or Band Then
			ThreadsEnter()
			If Parameter <> "Check" Then
				'Sometimes information is missed when compiling too quickly in less than 1 second.
				If lvProblems.ListItems.Count < 1 Then ShowMessages(Str(Time) & ": " & MS("Found $1.",  ML("Errors") & " (1) " & ML("Pos")), False)
				ShowMessages(Str(Time) & ": " & ML("Do not build file.")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				If (Not Log2_) AndAlso lvProblems.ListItems.Count <> 0 Then tpProblems->SelectTab
			ElseIf lvProblems.ListItems.Count <> 0 Then
				ShowMessages(Str(Time) & ": " & ML("Checking ended.")) & " " & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				tpProblems->SelectTab
			Else
				ShowMessages(Str(Time) & ": " & ML("No errors or warnings were found.")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
			End If
			ThreadsLeave()
			CompileResult = 0
		Else
			ThreadsEnter()
			If InStr(*LogText, "warning") > 0 Then
				If Parameter <> "Check" Then
					ShowMessages(Str(Time) & ": " & ML("Layout has been successfully completed, but there are warnings.")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				End If
			Else
				If Parameter <> "Check" Then
					ShowMessages(Str(Time) & ": " & ML("Layout succeeded!")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				Else
					ShowMessages(Str(Time) & ": " & ML("Syntax errors not found!")) & " "  & ML("Elapsed Time") & ": " & Format(Timer - CompileElapsedTime, "#0.00") & " " & ML("Seconds")
				End If
			End If
			ThreadsLeave()
		End If
	Next k
	ThreadsEnter()
	StopProgress
	ThreadsLeave()
	WDeAllocate(FbcExe)
	WDeAllocate(PipeApplicationName)
	WDeAllocate(PipeCommand)
	WDeAllocate(ExeName)
	WDeAllocate(LogText)
	WDeAllocate(fbcCommand)
	WDeAllocate(CompileWith)
	WDeAllocate(MFFPathC)
	WDeAllocate(FirstLine)
	WDeAllocate(ErrTitle)
	WDeAllocate(ErrFileName)
	WDeAllocate(LogFileName)
	WDeAllocate(LogFileName2)
	WDeAllocate(BatFileName)
	WDeAllocate(MainFile)
	WDeAllocate(MainFileNameOnly)
	WDeAllocate(ProjectPath)
	Return CompileResult
	Exit Function
	ErrorHandler:
	ThreadsEnter()
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
	ThreadsLeave()
End Function

Sub CreateKeyStore
	#ifndef __USE_GTK__
		Dim As WString Ptr Workdir, CmdL
		Dim As ProjectElement Ptr Project
		Dim As TreeNode Ptr ProjectNode
		Dim MainFile As UString = GetMainFile(, Project, ProjectNode)
		If Project = 0 Then
			ShowMessages ML("Project not found!")
			Exit Sub
		End If
		If Not FileExists(*Project->FileName & "/gradle.properties") Then
			ShowMessages ML("File") & " " & *Project->FileName & "/gradle.properties " & ML("not found!")
			Exit Sub
		End If
		Dim As Integer Fn = FreeFile_
		Dim pBuff As WString Ptr
		Dim As Integer FileSize
		Open *Project->FileName & "/gradle.properties" For Input As #Fn
		Dim As UString JavaHome
		FileSize = LOF(Fn)
		WReAllocate(pBuff, FileSize)
		Do Until EOF(Fn)
			LineInputWstr Fn, pBuff, FileSize
			If StartsWith(Trim(*pBuff), "org.gradle.java.home=") Then
				JavaHome = Replace(Replace(Mid(Trim(*pBuff), 22), "\\", "\"), "\:", ":")
				Exit Do
			End If
		Loop
		CloseFile_(Fn)
		If JavaHome = "" Then
			ShowMessages ML("org.gradle.java.home not specified in file gradle.properties!")
			Exit Sub
		End If
		If Not FileExists(JavaHome & "/bin/keytool.exe") Then
			ShowMessages ML("File") & " " & JavaHome & "/bin/keytool.exe " & ML("not found") & "!"
			Exit Sub
		End If
		Dim As Integer pClass, Result
		Dim As Unsigned Long ExitCode
		Dim As SaveFileDialog SaveD
		SaveD.InitialDir = GetFullPath(*ProjectsPath)
		SaveD.Caption = "Save key"
		SaveD.Filter = ML("Key files") & " (*.jks)|*.jks|" & ML("All Files") & "|*.*|"
		If Not SaveD.Execute Then Exit Sub
		WLet(CmdL, Environ("COMSPEC") & " /K cd /D """ & GetFolderName(SaveD.FileName) & """ & """ & JavaHome & "/bin/keytool"" -genkey -v -keystore " & SaveD.FileName & " -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias")
		Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
		SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
		pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
		If CreateProcessW(Null, CmdL, ByVal Null, ByVal Null, False, pClass, Null, Workdir, @SInfo, @PInfo) Then
			WaitForSingleObject pinfo.hProcess, INFINITE
			GetExitCodeProcess(pinfo.hProcess, @ExitCode)
			CloseHandle(pinfo.hProcess)
			CloseHandle(pinfo.hThread)
			Result = ExitCode
			ShowMessages(ML("Key store created!"))
			'Result = Shell(Debugger & """" & *ExeFileName + """")
		Else
			Result = GetLastError()
			ShowMessages(ML("keytool do not run. Error code") & ": " & Result & " - " & GetErrorString(Result))
			Exit Sub
		End If
		WDeallocate(CmdL)
	#endif
End Sub

Sub GenerateSignedBundleAPK(Parameter As String)
	#ifndef __USE_GTK__
		Dim Result As Integer
		Dim As ProjectElement Ptr Project
		Dim As TreeNode Ptr ProjectNode
		Dim MainFile As UString = GetMainFile(, Project, ProjectNode)
		If CBool(Project <> 0) AndAlso (Not EndsWith(LCase(*Project->FileName), ".vfp")) AndAlso FileExists(*Project->FileName & "/local.properties") Then
		Else
			ShowMessages ML("File") & " local.properties " & ML("not found") & "!"
			Exit Sub
		End If
		Dim As Integer Fn = FreeFile_
		Open *Project->FileName & "/local.properties" For Input As #Fn
		Dim SDKDir As UString
		Dim pBuff As WString Ptr
		Dim As Integer FileSize
		FileSize = LOF(Fn)
		WReAllocate(pBuff, FileSize)
		Do Until EOF(Fn)
			LineInputWstr Fn, pBuff, FileSize
			If StartsWith(*pBuff, "sdk.dir=") Then
				SDKDir = Replace(Replace(Mid(*pBuff, 9), "\\", "\"), "\:", ":")
				Exit Do
			End If
		Loop
		CloseFile_(Fn)
		If SDKDir = "" Then
			ShowMessages ML("Sdk.dir not specified in file local.properties!")
			Exit Sub
		End If
		If Not FileExists(*Project->FileName & "/app/build.gradle") Then
			ShowMessages ML("File ") & *Project->FileName & "/app/build.gradle " & ML("not found") & "!"
			Exit Sub
		End If
		Fn = FreeFile_
		Open *Project->FileName & "/app/build.gradle" For Input As #Fn
		Dim buildToolsVersion As String
		FileSize = LOF(Fn)
		WReAllocate(pBuff, FileSize)
		Do Until EOF(Fn)
			LineInputWstr Fn, pBuff, FileSize
			If StartsWith(Trim(*pBuff), "buildToolsVersion ") Then
				buildToolsVersion = Left(Mid(Trim(*pBuff), 20), Len(Mid(Trim(*pBuff), 20)) - 1)
				Exit Do
			End If
		Loop
		CloseFile_(Fn)
		If buildToolsVersion = "" Then
			ShowMessages ML("buildToolsVersion not found in file app/build.gradle!")
			Exit Sub
		End If
		If Parameter = "apk" Then
			If Not FileExists(*Project->FileName & "/app/build/outputs/apk/release/app-release-unsigned.apk") Then
				ShowMessages ML("File ") & *Project->FileName & "/app/build/outputs/apk/release/app-release-unsigned.apk " & ML("not found") & "!" & ML("You need to compile without debug.")
				Exit Sub
			End If
			ChDir(*Project->FileName & "/app/build/outputs/apk/release")
			Dim As WString Ptr Workdir, CmdL
			Dim As Integer pClass
			Dim As Unsigned Long ExitCode
			WLet(CmdL, SDKDir & "/build-tools/" & buildToolsVersion & "/zipalign -v -p 4 app-release-unsigned.apk app-release-unsigned-aligned.apk")
			Dim SInfo As STARTUPINFO
			Dim PInfo As PROCESS_INFORMATION
			SInfo.cb = Len(SInfo)
			SInfo.dwFlags = STARTF_USESHOWWINDOW
			SInfo.wShowWindow = SW_NORMAL
			pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
			If CreateProcessW(NULL, CmdL, ByVal NULL, ByVal NULL, False, pClass, NULL, Workdir, @SInfo, @PInfo) Then
				WaitForSingleObject PInfo.hProcess, INFINITE
				GetExitCodeProcess(PInfo.hProcess, @ExitCode)
				CloseHandle(PInfo.hProcess)
				CloseHandle(PInfo.hThread)
				Result = ExitCode
				'Result = Shell(Debugger & """" & *ExeFileName + """")
			Else
				Result = GetLastError()
				ShowMessages(ML("zipalign do not run. Error code") & ": " & Result & " - " & GetErrorString(Result))
				Exit Sub
			End If
			Dim As OpenFileDialog OpenD
			OpenD.InitialDir = GetFullPath(*ProjectsPath)
			OpenD.Caption = "Select key"
			OpenD.Filter = ML("Key files") & " (*.jks)|*.jks|" & ML("All Files") & "|*.*|"
			If Not OpenD.Execute Then Exit Sub
			WLet(CmdL, Environ("COMSPEC") & " /K cd /D """ & *Project->FileName & "/app/build/outputs/apk/release"" & " & SDKDir & "/build-tools/" & buildToolsVersion & "/apksigner sign --ks " & OpenD.FileName & " --out ../../../../release/app-release.apk app-release-unsigned-aligned.apk")
			If CreateProcessW(NULL, CmdL, ByVal NULL, ByVal NULL, False, pClass, NULL, Workdir, @SInfo, @PInfo) Then
				WaitForSingleObject PInfo.hProcess, INFINITE
				GetExitCodeProcess(PInfo.hProcess, @ExitCode)
				CloseHandle(PInfo.hProcess)
				CloseHandle(PInfo.hThread)
				Result = ExitCode
				'Result = Shell(Debugger & """" & *ExeFileName + """")
				ShowMessages(Time & ": " & ML("Signed APK file generated") & "!")
			Else
				Result = GetLastError()
				ShowMessages(Time & ": " & ML("APK signer do not run. Error code") & ": " & Result & " - " & GetErrorString(Result))
			End If
			WDeAllocate(CmdL)
		Else
			
		End If
	#endif
End Sub

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

Sub txtOutput_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim Buff As WString Ptr = @txtOutput.Lines(txtOutput.GetLineFromCharIndex)
	If Buff > 0 AndAlso InStr(LCase(*Buff), ML("debugprint")) > 1 Then Exit Sub
	Dim As WString Ptr ErrFileName, ErrTitle
	Dim As ProjectElement Ptr Project
	Dim As TreeNode Ptr ProjectNode
	Dim As Integer iLine
	Dim As WString Ptr Temp
	SplitError(*Buff, ErrFileName, ErrTitle, iLine)
	Dim MainFile As WString Ptr: WLet(MainFile, GetMainFile(False, Project, ProjectNode))
	If *ErrFileName <> "" AndAlso InStr(*ErrFileName, "/") = 0 AndAlso InStr(*ErrFileName, "\") = 0 Then WLet(ErrFileName, GetFolderName(*MainFile) & *ErrFileName)
	WDeAllocate(Temp)
	WDeAllocate(MainFile)
	SelectError(*ErrFileName, iLine)
End Sub

Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
	If tn->Tag AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement AndAlso Cast(ProjectElement Ptr, tn->Tag)->ProjectFolderType = ProjectFolderTypes.ShowWithFolders Then
		If EndsWith(LCase(FileName), ".bi") Then
			Return tn->Nodes.Item(0)
		ElseIf EndsWith(LCase(FileName), ".frm") Then
			Return tn->Nodes.Item(1)
		ElseIf EndsWith(LCase(FileName), ".bas") OrElse EndsWith(LCase(FileName), ".inc") Then
			Return tn->Nodes.Item(2)
		ElseIf EndsWith(LCase(FileName), ".rc") Then
			Return tn->Nodes.Item(3)
		Else
			Return tn->Nodes.Item(4)
		End If
	Else
		Return tn
	End If
End Function

Sub ClearTreeNode(ByRef tn As TreeNode Ptr)
	If tn = 0 Then Exit Sub
	Dim As TabWindow Ptr tb
	For i As Integer = 0 To tn->Nodes.Count - 1
		ClearTreeNode(tn->Nodes.Item(i))
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For j As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(j))
				If tb->tn = tn->Nodes.Item(i) Then
					tb->tn = 0
					Exit For
				End If
			Next j
		Next jj
		If tn->Nodes.Item(i)->Tag <> 0 Then _Delete( Cast(ExplorerElement Ptr, tn->Nodes.Item(i)->Tag)): tn->Nodes.Item(i)->Tag = 0
	Next
	tn->Nodes.Clear
End Sub

Function GetIconName(ByRef FileName As WString, ppe As ProjectElement Ptr = 0) As String
	Dim As String sMain = ""
	If ppe <> 0 Then
		If FileName = WGet(ppe->MainFileName) OrElse FileName = WGet(ppe->ResourceFileName) OrElse FileName = WGet(ppe->IconResourceFileName) OrElse FileName = WGet(ppe->BatchCompilationFileNameWindows) OrElse FileName = WGet(ppe->BatchCompilationFileNameLinux) Then
			sMain = "Main"
		End If
	End If
	If EndsWith(LCase(FileName), ".rc") OrElse EndsWith(LCase(FileName), ".res") OrElse EndsWith(LCase(FileName), ".xpm") Then
		Return sMain & "Resource"
	ElseIf EndsWith(LCase(FileName), ".vfs") Then
		Return sMain & "Session"
	ElseIf EndsWith(LCase(FileName), ".vfp") Then
		Return sMain & "Project"
	ElseIf EndsWith(LCase(FileName), ".frm") Then
		Return sMain & "Form"
	ElseIf EndsWith(LCase(FileName), ".bas") Then
		Return sMain & "Module"
	ElseIf CBool(InStr(FileName, ".") = 0) AndAlso CBool(FileName <> "") AndAlso FolderExists(FileName) Then
		Return sMain & "Folder"
	Else
		Return sMain & "File"
	End If
End Function

Sub ExpandFolder(ByRef tn As TreeNode Ptr)
	If tn = 0 Then Exit Sub
	Dim As ExplorerElement Ptr ee = tn->Tag, ee1
	If ee = 0 OrElse ee->FileName = 0 Then Exit Sub
	ClearTreeNode tn
	Dim As TreeNode Ptr tn1, tnP = GetParentNode(tn)
	Dim As String f, IconName
	Dim As UInteger Attr
	Dim As WStringList Files
	f = Dir(*ee->FileName & "/*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then
				If FileExists(f & Slash & f & ".vfp") Then
					IconName = "Project"
					tn1 = tn->Nodes.Add(GetFileName(f), , f, IconName, IconName)
					AddProject f & Slash & f & ".vfp", , tn1
					WLet(Cast(ExplorerElement Ptr, tn1->Tag)->FileName, *ee->FileName & Slash & f)
				Else
					IconName = "Opened"
					tn1 = tn->Nodes.Add(GetFileName(f), , f, IconName, IconName)
					ee1 = _New( ExplorerElement)
					WLet(ee1->FileName, *ee->FileName & Slash & f)
					tn1->Tag = ee1
				End If
				tn1->Nodes.Add ""
			End If
		Else
			Files.Add *ee->FileName & Slash & f
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Files.Count - 1
		If tnP->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tnP->Tag) Is ProjectElement Then
			IconName = GetIconName(Files.Item(i), tnP->Tag)
		Else
			IconName = GetIconName(Files.Item(i))
		End If
		'		If EndsWith(LCase(Files.Item(i)), ".vfp") Then
		'			IconName = "Project"
		'		ElseIf EndsWith(LCase(Files.Item(i)), ".rc") OrElse EndsWith(LCase(Files.Item(i)), ".res") OrElse EndsWith(LCase(Files.Item(i)), ".xpm") Then
		'			IconName = "Resource"
		'		Else
		'			IconName = "File"
		'		End If
		tn1 = tn->Nodes.Add(GetFileName(*ee->FileName & "/" & Files.Item(i)), , Files.Item(i), IconName, IconName)
		ee1 = _New( ExplorerElement)
		WLet(ee1->FileName, Files.Item(i))
		tn1->Tag = ee1
		Dim As TabWindow Ptr tb
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For j As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(j))
				If tb->FileName = Files.Item(i) Then
					tb->tn = tn1
					Exit For
				End If
			Next j
		Next jj
	Next i
End Sub

Sub CloseFolder(ByRef tn As TreeNode Ptr)
	Dim As TabWindow Ptr tb
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb->ptn = tn Then
				If Not CloseTab(tb, True) Then Return
				Exit For
			End If
		Next i
	Next jj
	ClearTreeNode tn
	'miSaveProject->Enabled = False
	'miSaveProjectAs->Enabled = False
	'miCloseProject->Enabled = False
	'miCloseFolder->Enabled = False
	'miExplorerCloseProject->Enabled = False
	'miProjectProperties->Enabled = False
	'miExplorerProjectProperties->Enabled = False
	Var Index = tvExplorer.Nodes.IndexOf(tn)
	If Index <> -1 Then tvExplorer.Nodes.Remove Index
	ChangeMenuItemsEnabled
	'Delete tn
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
		Dim As String IconName
		If FileExists(FolderName & Slash & GetFileName(FolderName) & ".vfp") Then
			IconName = "Opened"
			tn = tvExplorer.Nodes.Add(GetFileName(FolderName), , FolderName, IconName, IconName)
			AddProject FolderName & Slash & GetFileName(FolderName) & ".vfp", , tn
			WLet(Cast(ExplorerElement Ptr, tn->Tag)->FileName, FolderName)
			If MainNode = 0 Then SetMainNode tn
		Else
			IconName = "Opened"
			tn = tvExplorer.Nodes.Add(GetFileName(FolderName), , FolderName, IconName, IconName)
			Dim As ExplorerElement Ptr ee
			ee = _New( ExplorerElement)
			WLet(ee->FileName, FolderName)
			tn->Tag = ee
		End If
		ExpandFolder tn
		tn->Expand
	End If
	Return tn
End Function

Function IfNegative(Value As Integer, NonNegative As Integer) As Integer
	If Value < 0 Then
		Return NonNegative
	Else
		Return Value
	End If
End Function

Dim Shared As PointerList Threads
Sub ThreadCounter(Id As Any Ptr)
	Threads.Add Id
End Sub

Function AddProject(ByRef FileName As WString = "", pFilesList As WStringList Ptr = 0, tn1 As TreeNode Ptr = 0, bNew As Boolean = False) As TreeNode Ptr
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr tn, tn3
	Dim As Boolean inFolder = tn1 <> 0
	If inFolder Then
		tn = tn1
	Else
		If FileName <> "" AndAlso Not bNew Then
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
			Dim Buff As WString * 1024 ' for V1.07 Line Input not working fine
			Dim As Integer Fn = FreeFile_
			Dim Result As Integer = -1
			Result = Open(FileName For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(FileName For Input As #Fn)
			If Result = 0 Then
				Do Until EOF(Fn)
					Line Input #Fn, Buff
					If InStr(LCase(Buff), "openprojectasfolder") > 0 AndAlso InStr(LCase(Buff), "true") > 0 Then
						Return AddFolder(GetFolderName(FileName, False))
					End If
				Loop
			End If
			CloseFile_(Fn)
			tn = tvExplorer.Nodes.Add(GetFileName(FileName), , FileName, "Project", "Project")
		Else
			Var n = 0
			Dim As String ProjectName = "Project"
			Dim NewName As String
			Do
				n = n + 1
				NewName = ProjectName & Str(n)
			Loop While tvExplorer.Nodes.Contains(NewName) OrElse tvExplorer.Nodes.Contains(NewName & "*")
			tn = tvExplorer.Nodes.Add(NewName & "*", , , "Project", "Project")
		End If
		'If tn <> 0 Then
		If ShowProjectFolders Then
			tn->Nodes.Add ML("Includes"), "Includes", , "Opened", "Opened"
			tn->Nodes.Add ML("Forms"), "Forms", , "Opened", "Opened"
			tn->Nodes.Add ML("Modules"), "Modules", , "Opened", "Opened"  '.  Using "Modules" is better than "Sources"
			tn->Nodes.Add ML("Resources"), "Resources", , "Opened", "Opened"
			tn->Nodes.Add ML("Others"), "Others", , "Opened", "Opened"
			'End if
		End If
	End If
	If FileName <> "" Then
		Dim As TreeNode Ptr tn1, tn2
		'Dim buff As WString Ptr '
		Dim Pos1 As Integer
		Dim bMain As Boolean
		Dim As ProjectElement Ptr ppe
		Dim As WStringList Files
		Dim As WStringList Ptr pFiles
		ppe = _New( ProjectElement)
		If bNew Then
			WLet(ppe->FileName, Left(tn->Text, Len(tn->Text) - 1))
			WLet(ppe->TemplateFileName, FileName)
		Else
			WLet(ppe->FileName, FileName)
		End If
		If inFolder Then ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Else ppe->ProjectFolderType = IIf(ShowProjectFolders, 0, 1)
		tn->Tag = ppe
		If pFilesList = 0 Then pFiles = @Files Else pFiles = pFilesList
		Dim As String Parameter
		Dim As String IconName
		Dim As String ZvFile
		If bNew Then ZvFile = "*" Else ZvFile = ""
		Dim Buff As WString * 1024 ' for V1.07 Line Input not working fine
		Dim As Integer Fn = FreeFile_
		Dim Result As Integer = -1
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
					ee = _New( ExplorerElement)
					If CInt(InStr(Buff, ":") = 0) OrElse CInt(StartsWith(Buff, "/")) Then
						#ifdef __USE_GTK__
							WLet(ee->FileName, GetFolderName(FileName) & Buff)
						#else
							WLet(ee->FileName, GetFolderName(FileName) & Replace(Buff, "/", "\"))
						#endif
					Else
						WLet(ee->FileName, Buff)
					End If
					If bNew Then
						WLet(ee->TemplateFileName, WGet(ee->FileName))
						WLet(ee->FileName, GetFileName(Buff))
					End If
					If Not inFolder Then
						tn1 = GetTreeNodeChild(tn, Buff)
					End If
					Dim As Boolean FileEx = CInt(FileExists(*ee->FileName)) OrElse CInt(bNew)
					If bMain Then
						If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".res") Then  ' Then
							WLet(ppe->ResourceFileName, *ee->FileName)
						ElseIf EndsWith(LCase(*ee->FileName), ".xpm") Then
							WLet(ppe->IconResourceFileName, *ee->FileName)
						ElseIf LCase(GetFileName(*ee->FileName)) = "makefile" Then
							If WGet(ppe->BatchCompilationFileNameWindows) = "" Then WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
							If WGet(ppe->BatchCompilationFileNameLinux) = "" Then WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
						ElseIf EndsWith(LCase(*ee->FileName), ".bat") Then
							WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
						ElseIf EndsWith(LCase(*ee->FileName), ".sh") OrElse InStr(*ee->FileName, ".") = 0 Then
							WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
						Else
							WLet(ppe->MainFileName, *ee->FileName)
						End If
					End If
					IconName = GetIconName(*ee->FileName, ppe)
					If Not FileEx Then IconName = "New"
					If Not inFolder Then
						tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName) & ZvFile,, *ee->FileName, IconName, IconName, True)
						If bMain Then
							If MainNode = 0 Then SetMainNode GetParentNode(tn1)
							If bNew AndAlso IconName <> "MainRes" Then AddTab *ee->TemplateFileName, bNew, tn2
						End If
					End If
					If EndsWith(LCase(*ee->FileName), ".bas") OrElse EndsWith(LCase(*ee->FileName), ".frm") OrElse EndsWith(LCase(*ee->FileName), ".bi") OrElse EndsWith(LCase(*ee->FileName), ".inc") Then
						pFiles->Add *ee->FileName, ppe
						If Not LoadPaths.Contains(*ee->FileName) Then LoadPaths.Add *ee->FileName
						ThreadCounter(ThreadCreate_(@LoadOnlyFilePath, @LoadPaths.Item(LoadPaths.IndexOf(*ee->FileName))))
					End If
					ppe->Files_.Add *ee->FileName
					If inFolder Then
						ppe->Files.Add *ee->FileName
						_Delete( ee)
					Else
						tn2->Tag = ee
					End If
					If bNew Then tn1->Expand
				ElseIf Parameter = "ProjectType" Then
					ppe->ProjectType = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "Subsystem" Then
					ppe->Subsystem = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "ProjectName" Then
					WLet(ppe->ProjectName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "HelpFileName" Then
					WLet(ppe->HelpFileName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "ProjectDescription" Then
					WLet(ppe->ProjectDescription, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "PassAllModuleFilesToCompiler" Then
					ppe->PassAllModuleFilesToCompiler = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OpenProjectAsFolder" Then
					ppe->OpenProjectAsFolder = CBool(Mid(Buff, Pos1 + 1))
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
					WLet(ppe->ApplicationTitle, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "ApplicationIcon" Then
					WLet(ppe->ApplicationIcon, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "Manifest" Then
					ppe->Manifest = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "RunAsAdministrator" Then
					ppe->RunAsAdministrator = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "CompanyName" Then
					WLet(ppe->CompanyName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "FileDescription" Then
					WLet(ppe->FileDescription, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "InternalName" Then
					WLet(ppe->InternalName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "LegalCopyright" Then
					WLet(ppe->LegalCopyright, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "LegalTrademarks" Then
					WLet(ppe->LegalTrademarks, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "OriginalFilename" Then
					WLet(ppe->OriginalFilename, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "ProductName" Then
					WLet(ppe->ProductName, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompileTo" Then
					ppe->CompileTo = Cast(CompileToVariants, Val(Mid(Buff, Pos1 + 1)))
				ElseIf Parameter = "OptimizationLevel" Then
					ppe->OptimizationLevel = Val(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationFastCode" Then
					ppe->OptimizationFastCode = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "OptimizationSmallCode" Then
					ppe->OptimizationFastCode = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "CompilationArguments32Windows" Then
					WLet(ppe->CompilationArguments32Windows, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilationArguments64Windows" Then
					WLet(ppe->CompilationArguments64Windows, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilationArguments32Linux" Then
					WLet(ppe->CompilationArguments32Linux, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilationArguments64Linux" Then
					WLet(ppe->CompilationArguments64Linux, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CompilerPath" Then
					WLet(ppe->CompilerPath, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CommandLineArguments" Then
					WLet(ppe->CommandLineArguments, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "CreateDebugInfo" Then
					ppe->CreateDebugInfo = CBool(Mid(Buff, Pos1 + 1))
				ElseIf Parameter = "AndroidSDKLocation" Then
					WLet(ppe->AndroidSDKLocation, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "AndroidNDKLocation" Then
					WLet(ppe->AndroidNDKLocation, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "JDKLocation" Then
					WLet(ppe->JDKLocation, Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2))
				ElseIf Parameter = "IncludePath" Then
					ppe->IncludePaths.Add Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "LibraryPath" Then
					ppe->LibraryPaths.Add Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
				ElseIf Parameter = "ControlLibrary" Then
					Dim As Library Ptr CtlLibrary
					Dim As Boolean bFinded, bChanged
					Dim As UString LibraryPath = Mid(Buff, Pos1 + 2, Len(Buff) - Pos1 - 2)
					ppe->Components.Add LibraryPath
					For i As Integer = 0 To ControlLibraries.Count - 1
						CtlLibrary = ControlLibraries.Item(i)
						If Replace(GetFolderName(CtlLibrary->Path, False), "\", "/") = LibraryPath Then
							bFinded = True
							Exit For
						End If
					Next
					If bFinded Then
						If Not CtlLibrary->Enabled Then
							CtlLibrary->Enabled = True
							LoadToolBox CtlLibrary
							bChanged = True
						End If
					Else
						If LibraryPath <> "" Then
							Dim LibKey As String = GetLibKey
							Dim As IniFile ini
							ini.Load GetRelativePath(LibraryPath) & Slash & "Settings.ini"
							Var CtlLibrary = _New(Library)
							CtlLibrary->Name = ini.ReadString("Setup", "Name")
							CtlLibrary->Tips = ini.ReadString("Setup", "Tips")
							CtlLibrary->Path = LibraryPath & Slash & ini.ReadString("Setup", LibKey, " ")
							CtlLibrary->HeadersFolder = ini.ReadString("Setup", "HeadersFolder")
							CtlLibrary->SourcesFolder = ini.ReadString("Setup", "SourcesFolder")
							CtlLibrary->IncludeFolder = GetFullPath(GetFullPath(ini.ReadString("Setup", "IncludeFolder"), CtlLibrary->Path))
							CtlLibrary->Enabled = True
							ControlLibraries.Add CtlLibrary
							LoadToolBox CtlLibrary
							bChanged = True
						End If
					End If
					If bChanged Then
						pnlToolBox.RequestAlign
						pnlToolBox_Resize *pnlToolBox.Designer, pnlToolBox, pnlToolBox.Width, pnlToolBox.Height
						pnlToolBox.RequestAlign
					End If
				End If
			Loop
		End If
		CloseFile_(Fn)
		If pFilesList = 0 Then
			For i As Integer = 0 To pFiles->Count - 1
				ThreadCounter(ThreadCreate_(@LoadOnlyIncludeFiles, @LoadPaths.Item(LoadPaths.IndexOf(pFiles->Item(i)))))
			Next
			If ProjectAutoSuggestions Then
				For i As Integer = 0 To pFiles->Count - 1
					Var ecc = _New(EditControlContent)
					ecc->FileName = pFiles->Item(i)
					ecc->Globals = @Cast(ProjectElement Ptr, pFiles->Object(i))->Globals
					ecc->Tag = pFiles->Object(i)
					Cast(ProjectElement Ptr, pFiles->Object(i))->Contents.Add ecc
					If Not LoadPaths.Contains(pFiles->Item(i)) Then LoadPaths.Add pFiles->Item(i)
					ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwriteWithContent, ecc))
				Next
			End If
		End If
	End If
	If Not inFolder Then
		tn->Expand
	End If
	'pfProjectProperties->RefreshProperties
	tn->SelectItem
	Return tn
End Function

Sub OpenFolder()
	Dim As FolderBrowserDialog BrowseD
	BrowseD.InitialDir = GetFullPath(*ProjectsPath)
	If Not BrowseD.Execute Then Exit Sub
	AddFolder BrowseD.Directory
	WLet(RecentFolder, BrowseD.Directory)
	tpProject->SelectTab
End Sub

Sub OpenProject()
	Dim As OpenFileDialog OpenD
	OpenD.InitialDir = GetFullPath(*ProjectsPath)
	OpenD.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("All Files") & "|*.*|"
	If Not OpenD.Execute Then Exit Sub
	AddProject OpenD.FileName
	WLet(RecentProject, OpenD.FileName)
	tpProject->SelectTab
End Sub

Sub OpenUrl(ByVal url As String)
	Dim As String cmd
	#ifdef __USE_GTK__
		cmd = "xdg-open " & url
	#else
		cmd =  "start /b " & url
	#endif
	'Shell cmd
	PipeCmd "", cmd
End Sub

Function AddSession(ByRef FileName As WString) As Boolean
	'Dim As ExplorerElement Ptr ee
	If Not FileExists(FileName) Then
		MsgBox ML("File not found") & ": " & FileName
		Return False
	End If
	SessionOpened = True
	Dim As TreeNode Ptr tn
	AddMRUSession FileName
	Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
	Dim As WStringList Files
	Dim As Integer Fn = FreeFile_
	Dim Result As Integer = -1 '
	Result = Open(FileName For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(FileName For Input As #Fn)
	If Result = 0 Then
		Dim As WString Ptr filn
		Dim As Boolean bMain, bTabs
		Dim As Integer Pos1, n = 0
		MainNode = 0 '
		Dim CurrentPath As WString * 255
		CurrentPath = GetFolderName(FileName)
		Do Until EOF(Fn)
			Line Input #Fn, Buff
			If StartsWith(LCase(Buff), "[tabs]") Then
				bTabs = True
				n = 0
			ElseIf StartsWith(LCase(Buff), "file=") OrElse StartsWith(LCase(Buff), "*file=") Then
				Pos1 = InStr(Buff, "=")
				If Pos1 <> 0 Then
					n += 1
					bMain = StartsWith(Buff, "*")
					WLet(filn, Replace(Mid(Buff, Pos1 + 1), BackSlash, Slash))
					If CInt(InStr(*filn, ":") = 0) OrElse CInt(StartsWith(*filn, Slash)) Then
						WLet(filn, CurrentPath & *filn)
						If EndsWith(*filn, Slash) Then WLetEx filn, Left(*filn, Len(*filn) - 1), True
					End If
					Dim tn As TreeNode Ptr
					If bTabs Then
						Var tb = AddTab(*filn, , , Not bMain)
						If tb AndAlso tb->Index <> n - 1 Then ptabCode->ReorderTab(tb, n - 1, True)
					Else
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
			End If
		Loop
		WDeAllocate(filn)
		If MainNode = 0 AndAlso tn > 0 Then SetMainNode tn ' For No MainFIle
		For i As Integer = 0 To Files.Count - 1
			ThreadCounter(ThreadCreate_(@LoadOnlyIncludeFiles, @LoadPaths.Item(LoadPaths.IndexOf(Files.Item(i)))))
		Next
		If ProjectAutoSuggestions Then
			For i As Integer = 0 To Files.Count - 1
				Var ecc = _New(EditControlContent)
				ecc->FileName = Files.Item(i)
				ecc->Globals = @Cast(ProjectElement Ptr, Files.Object(i))->Globals
				ecc->Tag = Files.Object(i)
				Cast(ProjectElement Ptr, Files.Object(i))->Contents.Add ecc
				If Not LoadPaths.Contains(Files.Item(i)) Then LoadPaths.Add Files.Item(i)
				ThreadCounter(ThreadCreate_(@LoadOnlyFilePathOverwriteWithContent, ecc))
			Next
		End If
		CloseFile_(Fn)
		Return True
	End If
	CloseFile_(Fn)
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
	WLet(LastOpenPath, GetFolderName(OpenD.FileName))
	AddSession OpenD.FileName
	WLet(RecentSession, OpenD.FileName)
	tpProject->SelectTab
End Sub

Sub AddMRU(ByRef FileFolderName As WString, ByRef MRUFilesFolders As WStringList, miRecentFilesFolders As MenuItem Ptr, ByRef MRUType As String)
	Dim As UString FileFolderName_
	If AddRelativePathsToRecent Then
		FileFolderName_ = GetShortFileName(FileFolderName, ExePath & Slash & Slash)
	Else
		FileFolderName_ = FileFolderName
	End If
	Dim As Integer i = MRUFilesFolders.IndexOf(FileFolderName_)
	If i <> -1 Then MRUFilesFolders.Remove i
	MRUFilesFolders.Add FileFolderName_
	miRecentFilesFolders->Clear
	For i = 0 To MRUFilesFolders.Count - 1
		miRecentFilesFolders->Add(MRUFilesFolders.Item(i), "", MRUFilesFolders.Item(i), @mClickMRU, , i)
	Next
	miRecentFilesFolders->Add("-")
	miRecentFilesFolders->Add(ML("Clear Recently Opened"), "", "Clear" & MRUType, @mClickMRU)
	If miRecentFilesFolders->Enabled = False Then miRecentFilesFolders->Enabled = True
	
End Sub

Sub AddMRUAIChat(ByRef FileName As WString)
	Dim As UString FileName_
	If AddRelativePathsToRecent Then
		FileName_ = GetShortFileName(FileName, ExePath & Slash & Slash)
	Else
		FileName_ = FileName
	End If
	Dim As Integer i = MRUAIChat.IndexOf(FileName_)
	If i <> -1 Then MRUAIChat.Remove i
	MRUAIChat.Add FileName_
	miRecentAIChat->Clear
	For i = 0 To MRUAIChat.Count - 1
		miRecentAIChat->Add(MRUAIChat.Item(i), "", MRUAIChat.Item(i), @mClickAIChat, , i)
	Next
	miRecentAIChat->Add("-")
	miRecentAIChat->Add(ML("Clear Recently Opened"), "", "ClearAIChat", @mClickAIChat)
	If miRecentAIChat->Enabled = False Then miRecentAIChat->Enabled = True
End Sub

Sub AddMRUFile(ByRef FileName As WString)
	AddMRU FileName, MRUFiles, miRecentFiles, "Files"
End Sub

Sub AddMRUProject(ByRef FileName As WString)
	AddMRU FileName, MRUProjects, miRecentProjects, "Projects"
End Sub

Sub AddMRUFolder(ByRef FolderName As WString)
	AddMRU FolderName, MRUFolders, miRecentFolders, "Folders"
End Sub

Sub AddMRUSession(ByRef FileName As WString)
	AddMRU FileName, MRUSessions, miRecentSessions, "Sessions"
End Sub

Function FolderCopy(FromDir As UString, ToDir As UString) As Integer
	Dim As WString * 1024 f, fsrc, fdest
	Dim As UInteger Attr
	Dim As WStringList Folders
	MkDir ToDir
	f = Dir(FromDir & Slash & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, Attr)
	While f <> ""
		If (Attr And fbDirectory) <> 0 Then
			If f <> "." AndAlso f <> ".." Then Folders.Add FromDir & IIf(EndsWith(FromDir, Slash), "", Slash) & f
		Else
			#ifdef __USE_GTK__
				FileCopy FromDir & Slash & f, ToDir & Slash & f
			#else
				fsrc = FromDir & Slash & f
				fdest = ToDir & Slash & f
				CopyFileW @fsrc, @fdest, False
			#endif
		End If
		f = Dir(Attr)
	Wend
	For i As Integer = 0 To Folders.Count - 1
		FolderCopy Folders.Item(i), ToDir & Slash & GetFileName(Folders.Item(i))
	Next
	Folders.Clear
	Return 0
End Function

Function FolderExists(ByRef FolderName As WString) As Boolean
	If Trim(FolderName)="" Then Return False
	Dim AttrTester As Integer, DirString As String
	DirString = Dir(FolderName, fbDirectory, AttrTester)
	Return AttrTester = fbDirectory
End Function

Sub AddNew(ByRef Template As WString = "")
	If EndsWith(LCase(Template), ".vfp") Then
		AddProject Template, , , True
	Else
		AddTab Template, True
	End If
End Sub

Sub OpenFiles(ByRef FileName As WString)
	If EndsWith(LCase(FileName), ".vfs") Then
		AddSession FileName
		WLet(RecentSession, FileName)
	ElseIf EndsWith(LCase(FileName), ".vfp") Then
		AddProject FileName
		WLet(RecentProject, FileName)
	ElseIf FolderExists(FileName) Then
		AddFolder FileName
		WLet(RecentFolder, FileName)
	ElseIf Trim(FileName)<>"" Then '
		If FileExists(FileName) Then AddMRUFile FileName
		AddTab FileName
		WLet(RecentFile, FileName)
	End If
	WLet(RecentFiles, FileName)
End Sub

Sub OpenProgram()
	Dim As OpenFileDialog OpenD
	If WGet(LastOpenPath) <> "" Then
		OpenD.InitialDir = *LastOpenPath
	Else
		OpenD.InitialDir = GetFullPath(*ProjectsPath)
	End If
	'  Add *.inc
	OpenD.Filter = ML("FreeBasic Files") & " (*.vfs, *.vfp, *.bas, *.frm, *.bi, *.inc, *.rc)|*.vfs;*.vfp;*.bas;*.frm;*.bi;*.inc;*.rc|" & ML("VisualFBEditor Project Group") & " (*.vfs)|*.vfs|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Form Module") & " (*.frm)|*.frm|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("Other Include File") & " (*.inc)|*.inc|" & ML("Resource File") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If OpenD.Execute Then
		WLet(LastOpenPath, GetFolderName(OpenD.FileName))
		OpenFiles(GetFullPath(OpenD.FileName))
	End If
	tpProject->SelectTab
End Sub

Function SaveSession(WithoutQuestion As Boolean = False) As Boolean
	Dim As ExplorerElement Ptr ee
	Dim As WString Ptr Temp, Temp2
	If WithoutQuestion Then
		SaveD.FileName = *RecentSession
	Else
		SaveD.Caption = ML("Save Session As")
		SaveD.Filter = ML("VisualFBEditor Session") & " (*.vfs)|*.vfs|"
		If WGet(LastOpenPath) <> "" Then
			SaveD.InitialDir = *LastOpenPath
		Else
			SaveD.InitialDir = GetFullPath(*ProjectsPath)
		End If
		If Not SaveD.Execute Then Return False
		WLet(LastOpenPath, GetFolderName(SaveD.FileName))
		WLet(RecentSession, *LastOpenPath)
		If FileExists(SaveD.FileName) Then
			Select Case MsgBox(ML("Are you sure you want to overwrite the session") & "?" & WChr(13,10) & SaveD.FileName, "Visual FB Editor", mtWarning, btYesNo)
			Case mrYes:
			Case mrNo: Return SaveSession()
			End Select
		End If
	End If
	Dim As TreeNode Ptr tn1
	Dim As Integer p
	Dim As String Zv
	Dim As Integer Fn = FreeFile_
	Dim As TabWindow Ptr tb
	If Open(SaveD.FileName For Output Encoding "utf-8" As #Fn) = 0 Then
		For i As Integer = 0 To tvExplorer.Nodes.Count - 1
			tn1 = tvExplorer.Nodes.Item(i)
			ee = tn1->Tag
			If ee = 0 Then
				For j As Integer = 0 To TabPanels.Count - 1
					Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
					For i As Integer = 0 To ptabCode->TabCount - 1
						tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
						If tb AndAlso tb->tn = tn1 Then
							If tb->Modified Then
								If (Not tb->Save) AndAlso CBool(tb->FileName = "" OrElse tb->FileName = ML("Untitled")) Then
									Continue For
								End If
							End If
							Zv = IIf(tn1 = MainNode, "*", "")
							If StartsWith(tb->FileName & Slash, GetFolderName(SaveD.FileName)) Then
								Print #Fn, Zv & "File=" & Replace(Mid(tb->FileName, Len(GetFolderName(SaveD.FileName)) + 1), "\", "/")
							Else
								Print #Fn, Zv & "File=" & Replace(tb->FileName, "\", "/")
							End If
						End If
					Next i
				Next j
			Else
				Zv = IIf(tn1 = MainNode, "*", "")
				If StartsWith(*ee->FileName & Slash, GetFolderName(SaveD.FileName)) Then
					Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(SaveD.FileName)) + 1), "\", "/")
				Else
					Print #Fn, Zv & "File=" & Replace(*ee->FileName, "\", "/")
				End If
			End If
		Next
		Print #Fn, "[Tabs]"
		For j As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				If tb Then
					Zv = IIf(tb->IsSelected, "*", "")
					If StartsWith(tb->FileName & Slash, GetFolderName(SaveD.FileName)) Then
						Print #Fn, Zv & "File=" & Replace(Mid(tb->FileName, Len(GetFolderName(SaveD.FileName)) + 1), "\", "/")
					Else
						Print #Fn, Zv & "File=" & Replace(tb->FileName, "\", "/")
					End If
				End If
			Next i
		Next j
	End If
	CloseFile_(Fn)
	WDeAllocate(Temp)
	WDeAllocate(Temp2)
	Return True
End Function

Sub SetSaveDialogParameters(ByRef FileName As WString)
	pSaveD->Caption = ML("Save File As")
	pSaveD->Filter = ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("Other Include File") & " (*.inc)|*.inc|" & ML("Form Module") & " (*.frm)|*.frm|" & ML("Resource File") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If InStr(FileName, "/") = 0 AndAlso InStr(FileName, "\") = 0 Then
		If *LastOpenPath = "" Then
			pSaveD->InitialDir = *ProjectsPath
		Else
			pSaveD->InitialDir = *LastOpenPath
		End If
	Else
		pSaveD->InitialDir = GetFolderName(FileName)
	End If
	pSaveD->FileName = FileName
	If FileName = ML("Untitled") Then
		'pSaveD->FileName = FileName & ".bas"
		pSaveD->InitialDir = GetFullPath(*ProjectsPath)
		pSaveD->FilterIndex = 1
	ElseIf EndsWith(LCase(FileName), ".bas") Then
		pSaveD->FilterIndex = 1
	ElseIf EndsWith(LCase(FileName), ".bi") Then
		pSaveD->FilterIndex = 2
	ElseIf EndsWith(LCase(FileName), ".inc") Then
		pSaveD->FilterIndex = 3
	ElseIf EndsWith(LCase(FileName), ".frm") Then
		pSaveD->FilterIndex = 4
	ElseIf EndsWith(LCase(FileName), ".rc") Then
		pSaveD->FilterIndex = 5
	Else
		pSaveD->FileName = FileName
		pSaveD->FilterIndex = 6
	End If
End Sub

Function SaveProjectFile(ppe As ProjectElement Ptr, ee As ExplorerElement Ptr, tn As TreeNode Ptr) As Boolean
	If ppe = 0 OrElse ee = 0 OrElse tn = 0 Then Return False
	Dim As TabWindow Ptr tb = GetTabFromTn(tn)
	If tb <> 0 Then
		If tb->Modified Then Return tb->Save
	ElseIf InStr(WGet(ee->FileName), "\") = 0 AndAlso InStr(WGet(ee->FileName), "/") = 0 Then
		SetSaveDialogParameters(WGet(ee->FileName))
		Do
			If pSaveD->Execute Then
				WLet(LastOpenPath, GetFolderName(pSaveD->FileName))
				If FileExists(pSaveD->FileName) Then
					Select Case MsgBox(ML("Want to replace the file") & " """ & pSaveD->FileName & """?", App.Title, mtWarning, btYesNoCancel)
					Case mrYes: Exit Do
					Case mrCancel: Return False
					Case mrNo:
					End Select
				Else
					Exit Do
				End If
			Else
				Return False
			End If
		Loop
		If WGet(ppe->MainFileName) = WGet(ee->FileName) Then WLet(ppe->MainFileName, pSaveD->FileName)
		If WGet(ppe->ResourceFileName) = WGet(ee->FileName) Then WLet(ppe->ResourceFileName, pSaveD->FileName)
		If WGet(ppe->IconResourceFileName) = WGet(ee->FileName) Then WLet(ppe->IconResourceFileName, pSaveD->FileName)
		If WGet(ppe->BatchCompilationFileNameWindows) = WGet(ee->FileName) Then WLet(ppe->BatchCompilationFileNameWindows, pSaveD->FileName)
		If WGet(ppe->BatchCompilationFileNameLinux) = WGet(ee->FileName) Then WLet(ppe->BatchCompilationFileNameLinux, pSaveD->FileName)
		WLet(ee->FileName, pSaveD->FileName)
		tn->Text = GetFileName(*ee->FileName)
		If WGet(ee->TemplateFileName) <> "" Then FileCopy WGet(ee->TemplateFileName), WGet(ee->FileName)
	End If
	Return True
End Function

Function SaveProject(ByRef tnP As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
	If tnP = 0 Then MsgBox(ML("Project not selected!")): Return True
	Dim As TreeNode Ptr tnPr = GetParentNode(tnP)
	If tnPr = 0 Then Return True
	Dim As ExplorerElement Ptr ee
	Dim As ProjectElement Ptr ppe
	ppe = tnPr->Tag
	If tnPr->ImageKey <> "Project" AndAlso tnPr->ImageKey <> "Opened" Then MsgBox(ML("Project not selected!")): Return True
	If CInt(ppe = 0) OrElse CInt(InStr(WGet(ppe->FileName), "\") = 0 AndAlso InStr(WGet(ppe->FileName), "/") = 0) OrElse CInt(bWithQuestion) Then
		SaveD.Caption = ML("Save Project As")
		SaveD.InitialDir = GetFullPath(*ProjectsPath)
		If ppe <> 0 Then
			SaveD.FileName = WGet(ppe->FileName)
			'			If InStr(WGet(ppe->FileName), "\") = 0 AndAlso InStr(WGet(ppe->FileName), "\") = 0 Then
			'				SaveD.FileName = WGet(ppe->FileName) & ".vfp"
			'			Else
			'				SaveD.FileName = WGet(ppe->FileName)
			'			End If
		End If
		SaveD.Filter = ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|"
		If Not SaveD.Execute Then Return False
		WLet(LastOpenPath, GetFolderName(SaveD.FileName))
		If FileExists(SaveD.FileName) Then
			Select Case MsgBox(ML("Are you sure you want to overwrite the project") & "?" & WChr(13,10) & SaveD.FileName, "Visual FB Editor", mtWarning, btYesNo)
			Case mrYes:
			Case mrNo: Return SaveProject(tnPr, bWithQuestion)
			End Select
		End If
		If ppe = 0 Then ppe = _New( ProjectElement)
		WLet(ppe->FileName, SaveD.FileName)
		AddMRUProject SaveD.FileName
	End If
	Dim As TreeNode Ptr tn1, tn2
	Dim As String Zv = "*"
	For i As Integer = 0 To tnPr->Nodes.Count - 1
		tn1 = tnPr->Nodes.Item(i)
		ee = tn1->Tag
		If ee <> 0 Then
			If Not SaveProjectFile(ppe, ee, tn1) Then Return False
		ElseIf tn1->Nodes.Count > 0 Then
			For j As Integer = 0 To tn1->Nodes.Count - 1
				tn2 = tn1->Nodes.Item(j)
				ee = tn2->Tag
				If ee <> 0 Then
					If Not SaveProjectFile(ppe, ee, tn2) Then Return False
				End If
			Next
		End If
	Next
	Dim As Integer Fn = FreeFile_
	If Not EndsWith(LCase(*ppe->FileName), ".vfp") Then
		Open *ppe->FileName & "/" & GetFileName(*ppe->FileName) & ".vfp" For Output Encoding "utf-8" As #Fn
		For i As Integer = 0 To ppe->Files.Count - 1
			Zv = IIf(ppe AndAlso (ppe->Files.Item(i) = *ppe->MainFileName OrElse ppe->Files.Item(i) = *ppe->ResourceFileName OrElse ppe->Files.Item(i) = *ppe->IconResourceFileName OrElse ppe->Files.Item(i) = *ppe->BatchCompilationFileNameWindows OrElse ppe->Files.Item(i) = *ppe->BatchCompilationFileNameLinux), "*", "")
			If StartsWith(ppe->Files.Item(i), *ppe->FileName & "\") Then
				Print #Fn, Zv & "File=" & Replace(Mid(ppe->Files.Item(i), Len(*ppe->FileName & "\") + 1), "\", "/")
			Else
				Print #Fn, Zv & "File=" & ppe->Files.Item(i)
			End If
		Next
	Else
		Open *ppe->FileName For Output Encoding "utf-8" As #Fn
		For i As Integer = 0 To tnPr->Nodes.Count - 1
			tn1 = tnPr->Nodes.Item(i)
			ee = tn1->Tag
			If ee <> 0 Then
				Zv = IIf(ppe AndAlso (*ee->FileName = *ppe->MainFileName OrElse *ee->FileName = *ppe->ResourceFileName OrElse *ee->FileName = *ppe->IconResourceFileName OrElse *ee->FileName = *ppe->BatchCompilationFileNameWindows OrElse *ee->FileName = *ppe->BatchCompilationFileNameLinux), "*", "")
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
						Zv = IIf(ppe AndAlso (*ee->FileName = *ppe->MainFileName OrElse *ee->FileName = *ppe->ResourceFileName OrElse *ee->FileName = *ppe->IconResourceFileName OrElse *ee->FileName = *ppe->BatchCompilationFileNameWindows OrElse *ee->FileName = *ppe->BatchCompilationFileNameLinux), "*", "")
						If StartsWith(Replace(*ee->FileName, "\", "/"), Replace(GetFolderName(*ppe->FileName), "\", "/")) Then
							Print #Fn, Zv & "File=" & Replace(Mid(*ee->FileName, Len(GetFolderName(*ppe->FileName)) + 1), "\", "/")
						Else
							Print #Fn, Zv & "File=" & *ee->FileName
						End If
					End If
				Next
			End If
		Next
	End If
	Print #Fn, "ProjectType=" & ppe->ProjectType
	Print #Fn, "Subsystem=" & ppe->Subsystem
	Print #Fn, "ProjectName=""" & *ppe->ProjectName & """"
	Print #Fn, "HelpFileName=""" & *ppe->HelpFileName & """"
	Print #Fn, "ProjectDescription=""" & *ppe->ProjectDescription & """"
	Print #Fn, "PassAllModuleFilesToCompiler=" & ppe->PassAllModuleFilesToCompiler
	Print #Fn, "OpenProjectAsFolder=" & ppe->OpenProjectAsFolder
	Print #Fn, "MajorVersion=" & ppe->MajorVersion
	Print #Fn, "MinorVersion=" & ppe->MinorVersion
	Print #Fn, "RevisionVersion=" & ppe->RevisionVersion
	Print #Fn, "BuildVersion=" & ppe->BuildVersion
	Print #Fn, "AutoIncrementVersion=" & ppe->AutoIncrementVersion
	Print #Fn, "ApplicationTitle=""" & *ppe->ApplicationTitle & """"
	Print #Fn, "ApplicationIcon=""" & *ppe->ApplicationIcon & """"
	Print #Fn, "Manifest=" & ppe->Manifest
	Print #Fn, "RunAsAdministrator=" & ppe->RunAsAdministrator
	Print #Fn, "CompanyName=""" & *ppe->CompanyName & """"
	Print #Fn, "FileDescription=""" & *ppe->FileDescription & """"
	Print #Fn, "InternalName=""" & *ppe->InternalName & """"
	Print #Fn, "LegalCopyright=""" & *ppe->LegalCopyright & """"
	Print #Fn, "LegalTrademarks=""" & *ppe->LegalTrademarks & """"
	Print #Fn, "OriginalFilename=""" & *ppe->OriginalFilename & """"
	Print #Fn, "ProductName=""" & *ppe->ProductName & """"
	Print #Fn, "CompileTo=" & ppe->CompileTo
	Print #Fn, "OptimizationLevel=" & ppe->OptimizationLevel
	Print #Fn, "OptimizationFastCode=" & ppe->OptimizationFastCode
	Print #Fn, "OptimizationSmallCode=" & ppe->OptimizationSmallCode
	Print #Fn, "CompilationArguments32Windows=""" & *ppe->CompilationArguments32Windows & """"
	Print #Fn, "CompilationArguments64Windows=""" & *ppe->CompilationArguments64Windows & """"
	Print #Fn, "CompilationArguments32Linux=""" & *ppe->CompilationArguments32Linux & """"
	Print #Fn, "CompilationArguments64Linux=""" & *ppe->CompilationArguments64Linux & """"
	Print #Fn, "CompilerPath=""" & *ppe->CompilerPath & """"
	Print #Fn, "CommandLineArguments=""" & *ppe->CommandLineArguments & """"
	Print #Fn, "CreateDebugInfo=" & ppe->CreateDebugInfo
	Print #Fn, "AndroidSDKLocation=""" & *ppe->AndroidSDKLocation & """"
	Print #Fn, "AndroidNDKLocation=""" & *ppe->AndroidNDKLocation & """"
	Print #Fn, "JDKLocation=""" & *ppe->JDKLocation & """"
	For i As Integer = 0 To ppe->Components.Count - 1
		Print #Fn, "ControlLibrary=""" & Replace(ppe->Components.Item(i), "\", "/") & """"
	Next
	For i As Integer = 0 To ppe->IncludePaths.Count - 1
		Print #Fn, "IncludePath=""" & Replace(ppe->IncludePaths.Item(i), "\", "/") & """"
	Next
	For i As Integer = 0 To ppe->LibraryPaths.Count - 1
		Print #Fn, "LibraryPath=""" & Replace(ppe->LibraryPaths.Item(i), "\", "/") & """"
	Next
	'Dim As Library Ptr CtlLibrary
	'For i As Integer = 0 To ControlLibraries.Count - 1
	'	CtlLibrary = ControlLibraries.Item(i)
	'	If CtlLibrary->Enabled Then
	'		Print #Fn, "ControlLibrary=""" & Replace(GetFolderName(CtlLibrary->Path, False), "\", "/") & """"
	'	End If
	'Next
	CloseFile_(Fn)
	'Else
	'	MsgBox ML("Save file failure!") & Chr(13,10) & *ppe->FileName
	'End If
	If tnPr->Text <> GetFileName(WGet(ppe->FileName)) Then tnPr->Text = GetFileName(WGet(ppe->FileName))
	tnPr->Tag = ppe
	Return True
End Function

Sub SaveAll()
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->Modified Then tb->Save
		Next i
	Next j
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		If tvExplorer.Nodes.Item(i)->ImageKey = "Project" Then
			SaveProject tvExplorer.Nodes.Item(i)
		End If
	Next i
End Sub

Function SaveAllBeforeCompile() As Boolean
	If AutoSaveBeforeCompiling = 1 Then
		Dim As ProjectElement Ptr Project
		Dim As TreeNode Ptr ProjectNode
		GetMainFile(AutoSaveBeforeCompiling, Project, ProjectNode)
		If ProjectNode <> 0 Then SaveProject(ProjectNode)
	ElseIf AutoSaveBeforeCompiling = 2 Then
		SaveAll
	ElseIf AutoSaveBeforeCompiling = 3 Then
		Dim tnP As TreeNode Ptr
		Dim As TreeNode Ptr tn
		Dim As TabWindow Ptr tb
		Dim Index As Integer
		With *pfSave
			.lstFiles.Clear
			For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
				tn = tvExplorer.Nodes.Item(i)
				If CInt(tn->ImageKey = "Project") AndAlso EndsWith(tn->Text, "*") Then
					.lstFiles.AddItem tn->Text, tn
				End If
			Next i
			For j As Integer = TabPanels.Count - 1 To 0 Step - 1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
				For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
					tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
					If tb->Modified Then
						tnP = tb->ptn
						Index = .lstFiles.IndexOfData(tnP)
						If Index <> -1 Then
							.lstFiles.InsertItem Index + 1, WSpace(2) & tb->Caption, tb
						Else
							.lstFiles.AddItem tb->Caption, tb
						End If
					End If
				Next i
			Next j
			If .lstFiles.ItemCount > 0 Then
				.lstFiles.SelectAll
				Select Case .ShowModal(*pfrmMain)
				Case ModalResults.Yes
					For i As Integer = .lstFiles.ItemCount - 1 To 0 Step -1
						If .lstFiles.Selected(i) Then
							If tvExplorer.Nodes.Contains(.lstFiles.ItemData(i)) Then
								If Not SaveProject(.lstFiles.ItemData(i)) Then Return False
							Else
								If Not Cast(TabWindow Ptr, .lstFiles.ItemData(i))->Save Then Return False
							End If
						End If
					Next
				Case ModalResults.No
				Case ModalResults.Cancel: Return False
				End Select
			End If
		End With
	End If
	Return True
End Function

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
	Dim j As Integer = ptabCode->SelectedTabIndex
	For jj As Integer = TabPanels.Count - 1 To 0 Step -1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Long = ptabCode->TabCount - 1 To 0 Step -1
			If WithoutCurrent Then
				If i = j Then Continue For
			End If
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			CloseTab(tb)
		Next i
	Next jj
End Sub

Function CloseSession() As Boolean
	#ifndef __USE_GTK__
		If prun AndAlso kill_process(ML("Trying to launch but debuggee still running")) = False Then
			Return False
		End If
	#endif
	Dim tb As TabWindow Ptr
	Dim tn As TreeNode Ptr
	Dim tnP As TreeNode Ptr
	Dim Index As Integer
	#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
		If iFlagStartDebug = 1 Then
			NewCommand = !"q\n"
			MutexUnlock tlockGDB
		End If
	#endif
	With *pfSave
		.lstFiles.Clear
		For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
			tn = tvExplorer.Nodes.Item(i)
			If CInt(tn->ImageKey = "Project") AndAlso EndsWith(tn->Text, "*") Then
				.lstFiles.AddItem tn->Text, tn
			End If
			'If CInt(tn->ImageKey = "Project") AndAlso CInt(Not CloseProject(tn)) Then Action = 0: Return
		Next i
		For j As Integer = TabPanels.Count - 1 To 0 Step -1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If tb->Modified Then
					tnP = tb->ptn
					Index = .lstFiles.IndexOfData(tnP)
					If Index <> -1 Then
						.lstFiles.InsertItem Index + 1, WSpace(2) & tb->Caption, tb
					Else
						.lstFiles.AddItem tb->Caption, tb
					End If
				End If
			Next i
		Next j
		If .lstFiles.ItemCount > 0 Then
			.lstFiles.SelectAll
			Select Case .ShowModal(*pfrmMain)
			Case ModalResults.Yes
				For i As Integer = .SelectedItems.Count - 1 To 0 Step -1
					If tvExplorer.Nodes.Contains(.SelectedItems.Item(i)) Then
						If Not SaveProject(.SelectedItems.Item(i)) Then Return False
					Else
						If Not Cast(TabWindow Ptr, .SelectedItems.Item(i))->Save Then Return False
					End If
				Next
			Case ModalResults.No
			Case ModalResults.Cancel: Return False
			End Select
		End If
	End With
	For j As Integer = TabPanels.Count - 1 To 0 Step -1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			CloseTab(tb, True)
		Next i
	Next j
	For i As Integer = tvExplorer.Nodes.Count - 1 To 0 Step -1
		tn = tvExplorer.Nodes.Item(i)
		If CInt(tn->ImageKey = "Project") Then CloseProject(tn, True)
	Next i
	Return True
End Function

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
	If Param <> 0 Then CurrentHelpPath = Cast(HelpOptions Ptr, Param)->CurrentPath
	If CurrentHelpPath = "" Then
		IndexDefault = Helps.IndexOfKey(*DefaultHelp)
		CurrentHelpPath = *HelpPath
	End If
	CurrentHelpPath = GetFullPath(CurrentHelpPath)
	If Not FileExists(CurrentHelpPath) Then
		ThreadsEnter()
		ShowMessages ML("File") & " " & CurrentHelpPath & " " & ML("not found")
		ThreadsLeave()
	Else
		#ifdef __USE_GTK__
			Dim As WString * MAX_PATH wszKeyword
			If Param <> 0 Then wszKeyword = Cast(HelpOptions Ptr, Param)->CurrentWord
			If wszKeyword = "" AndAlso Param = 0 AndAlso tb <> 0 Then wszKeyword = tb->txtCode.GetWordAtCursor
			If wszKeyword = "" Then
				PipeCmd "", ExePath & "/CHMVIEW " & CurrentHelpPath, False
			Else
				PipeCmd "", ExePath & "/CHMVIEW " & CurrentHelpPath & " -k " & wszKeyword, False
			End If
		#endif
	End If
	#ifndef __USE_GTK__
		Dim As WString * MAX_PATH wszKeyword, wszKeywordUpper
		Dim As Boolean bFind
		Dim As Any Ptr gpHelpLib
		Dim HtmlHelpW As Function (ByVal hwndCaller As HWND, _
		ByVal pswzFile As WString Ptr, _
		ByVal uCommand As UINT, _
		ByVal dwData As DWORD_PTR _
		) As HWND
		gpHelpLib = DyLibLoad( "hhctrl.ocx" )
		HtmlHelpW = DyLibSymbol( gpHelpLib, "HtmlHelpW")
		If HtmlHelpW <> 0 Then
			If Param <> 0 Then wszKeyword = Cast(HelpOptions Ptr, Param)->CurrentWord
			If wszKeyword = "" AndAlso Param = 0 AndAlso tb <> 0 Then wszKeyword = tb->txtCode.GetWordAtCursor
			If wszKeyword = "" Then
				HtmlHelpW(0, CurrentHelpPath, HH_DISPLAY_TOC, NULL)
			Else
				wszKeywordUpper = UCase(wszKeyword)
				For i As Integer = -1 To Helps.Count - 1
					If i = IndexDefault Then Continue For
					If i = -1 Then
						CurrentHelpPath = GetFullPath(*HelpPath)
					Else
						CurrentHelpPath = GetFullPath(Helps.Item(i)->Text)
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
								.pszUrl       = NULL
								.pszMsgText   = NULL
								.pszMsgTitle  = NULL
								.pszWindow    = NULL
								.fIndexOnFail = False
							End With
							If HtmlHelpW(0, CurrentHelpPath, HH_KEYWORD_LOOKUP, Cast(DWORD_PTR, @li)) <> 0 Then
								bFind = True
								Exit For, For
							End If
						Next
					End If
				Next
				If Not bFind Then HtmlHelpW(0, *HelpPath, HH_DISPLAY_TOC, NULL) 'MsgBox ML("Keyword") & " """ & wszKeyword & """ " & ML("not found in Help") & "!"
			End If
			'DyLibFree(gpHelpLib)
		End If
	#endif
End Sub

Sub NewProject()
	If pfTemplates->ShowModal(frmMain) = ModalResults.OK Then
		If pfTemplates->SelectedFolder <> "" Then
			AddFolder pfTemplates->SelectedFolder
		ElseIf pfTemplates->SelectedTemplate <> "" Then
			AddNew pfTemplates->SelectedTemplate
		ElseIf pfTemplates->SelectedFile <> "" Then
			OpenFiles pfTemplates->SelectedFile
		End If
	End If
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

Sub AddFromTemplate(ByRef Template As WString)
	Dim As TreeNode Ptr ptn, tn1, tn3, tnSelecte
	tnSelecte = tvExplorer.SelectedNode
	If tnSelecte <> 0 Then
		ptn = GetParentNode(tnSelecte)
		If ptn->ImageKey = "Project" OrElse ptn->ImageKey = "Opened" Then
			If ptn->ImageKey = "Opened" Then
				Dim As String tmpKeyStr = " @Sub @StandartTypes @Property @Enum @EnumItem @Type @Function @Opened "
				If InStr(tmpKeyStr, " @" & tnSelecte->ImageKey & " ") Then
					tn1 = IIf(tnSelecte->ParentNode->ImageKey = tnSelecte->ImageKey, tnSelecte->ParentNode->ParentNode , tnSelecte->ParentNode)
				Else
					tn1 = tnSelecte
				End If
				If tnSelecte->ImageKey <> "Opened" Then tn1 = tn1->ParentNode
			Else
				tn1 = GetTreeNodeChild(ptn, Template)
			End If
			Dim As String IconName = GetIconName(Template)
			Dim As UString FileName = Replace(GetFileName(Template), " ", "")
			Dim As UString FileExt
			Dim As ExplorerElement Ptr ee
			Dim Pos1 As Integer = InStrRev(FileName, ".")
			If Pos1 > 0 Then
				FileExt = Mid(FileName, Pos1)
				FileName = Left(FileName, Pos1 - 1)
			End If
			Dim NewName As UString
			Dim As Integer n = 0
			Do
				n = n + 1
				NewName = FileName & Str(n) & FileExt
			Loop While tn1->Nodes.Contains(*NewName.vptr) OrElse tn1->Nodes.Contains(WStr(NewName & "*"))
			tn3 = tn1->Nodes.Add(NewName & "*", , , IconName, IconName, True)
			ee = _New( ExplorerElement)
			WLet(ee->FileName, NewName)
			WLet(ee->TemplateFileName, Template)
			tn3->Tag = ee
			If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
			If Not ptn->IsExpanded Then ptn->Expand
			If Not tn1->IsExpanded Then tn1->Expand
			tn3->SelectItem
			AddTab *ee->TemplateFileName, True, tn3
		End If
	End If
	If tn3 = 0 Then AddNew Template
End Sub

Sub AddFromTemplates
	pfTemplates->OnlyFiles = True
	If pfTemplates->ShowModal(frmMain) = ModalResults.OK Then
		AddFromTemplate pfTemplates->SelectedTemplate
	End If
End Sub

Sub AddFilesToProject
	Dim As TreeNode Ptr ptn, tn3
	Dim As ExplorerElement Ptr ee
	If tvExplorer.SelectedNode <> 0 Then
		ptn = GetParentNode(tvExplorer.SelectedNode)
		If ptn->ImageKey <> "Project" Then ptn = 0
	End If
	Dim OpenD As OpenFileDialog
	OpenD.Options.Include ofOldStyleDialog
	OpenD.MultiSelect = True
	OpenD.Filter = ML("FreeBasic Files") & " (*.vfp, *.bas, *.frm, *.bi, *.inc; *.rc)|*.vfp;*.bas;*.frm;*.bi;*.inc;*.rc|" & ML("VisualFBEditor Project") & " (*.vfp)|*.vfp|" & ML("FreeBasic Module") & " (*.bas)|*.bas|" & ML("FreeBasic Include File") & " (*.bi)|*.bi|" & ML("Other Include File") & " (*.inc)|*.inc|" & ML("Form Module") & " (*.frm)|*.frm|" & ML("Resource File") & " (*.rc)|*.rc|" & ML("All Files") & "|*.*|"
	If OpenD.Execute Then
		Dim tn1 As TreeNode Ptr
		For i As Integer = 0 To OpenD.FileNames.Count - 1
			If ptn <> 0 Then
				tn1 = GetTreeNodeChild(ptn, OpenD.FileNames.Item(i))
				If ContainsFileName(tn1, OpenD.FileNames.Item(i)) Then Continue For
				Dim As String IconName = GetIconName(OpenD.FileNames.Item(i))
				tn3 = tn1->Nodes.Add(GetFileName(OpenD.FileNames.Item(i)), , , IconName, IconName, True)
				ee = _New( ExplorerElement)
				WLet(ee->FileName, OpenD.FileNames.Item(i))
				tn3->Tag = ee
				'tn1->Expand
			Else
				OpenFiles OpenD.FileNames.Item(i)
			End If
		Next
		If ptn <> 0 Then
			If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
			If ptn->Nodes.Count > 0 Then
				If Not ptn->IsExpanded Then ptn->Expand
				For i As Integer = 0 To ptn->Nodes.Count - 1
					If CInt(ptn->Nodes.Item(i)->Nodes.Count > 0) Then ptn->Nodes.Item(i)->Expand
				Next
				'pfProjectProperties->RefreshProperties
			End If
		End If
	End If
End Sub

Dim Shared g_bAllowLabelEdit As Boolean
Sub RenameFile
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	g_bAllowLabelEdit = True
	tvExplorer.SelectedNode->EditLabel
End Sub

Sub RemoveFileFromProject
	If tvExplorer.SelectedNode = 0 Then Exit Sub
	'	If tvExplorer.SelectedNode->Tag = 0 Then Exit Sub
	'	If tvExplorer.SelectedNode->ParentNode = 0 Then Exit Sub
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	Dim As TreeNode Ptr ptn
	ptn = GetParentNode(tn)
	If ptn->ImageKey <> "Project" Then
		If ptn->ImageKey = "Opened" AndAlso tn->Tag > 0 Then
			Dim As ExplorerElement Ptr ee
			ee = New ExplorerElement
			ee = tn->Tag
			If ee->FileName> 0 AndAlso Dir(*ee->FileName) <> "" Then
				'Move the file to temp folds.
				FileCopy(*ee->FileName, ExePath + "/Temp/" + GetFileName(*ee->FileName))
				Kill *ee->FileName
			End If
		End If
		ptn = 0
	End If
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->ptn = ptn Then
				If Not CloseTab(tb) Then Exit Sub
				Exit For
			End If
		Next i
	Next j
	If ptn <> 0 Then
		If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
	End If
	If tn->ParentNode <> 0 Then
		If tn->ParentNode->Nodes.IndexOf(tn) <> -1 Then tn->ParentNode->Nodes.Remove tn->ParentNode->Nodes.IndexOf(tn)
	ElseIf tn->ImageKey = "Project" Then
		CloseProject tn
	End If
	'pfProjectProperties->RefreshProperties
End Sub

Sub OpenProjectFolder
	Dim As TreeNode Ptr ptn, tnSelect = tvExplorer.SelectedNode
	If tnSelect = 0 Then Exit Sub
	ptn = GetParentNode(tnSelect)
	If ptn = 0 Then Exit Sub
	If ptn->ImageKey = "Opened" Then
		Dim As String tmpKeyStr = "@Sub@StandartTypes@Property@Enum@EnumItem@Type@Function@"
		If InStr(tmpKeyStr, " @" & tnSelect->ImageKey & "@") AndAlso tnSelect->ParentNode Then
			If tnSelect->ParentNode Then ptn = IIf(tnSelect->ParentNode->ImageKey = tnSelect->ImageKey, tnSelect->ParentNode->ParentNode , tnSelect->ParentNode)
		Else
			ptn = tnSelect
		End If
	End If
	Dim As ExplorerElement Ptr ee = ptn->Tag
	If ee = 0 Then Exit Sub
	If WGet(ee->FileName) <> "" Then
		#ifdef __USE_GTK__
			Shell "xdg-open """ & GetFolderName(*ee->FileName) & """"
		#else
			PipeCmd "", "explorer """ & Replace(GetFolderName(*ee->FileName), "/", "\") & """"
			'Shell "explorer """ & Replace(GetFolderName(*ee->FileName), "/", "\") & """"
		#endif
	End If
End Sub

Sub SetMainNode(tn As TreeNode Ptr)
	If MainNode <> 0 Then MainNode->Bold = False
	MainNode = tn
	If tn = 0 Then
		lblLeft.Text = ML("Main Project") & ": " & ML("Automatic")
	Else
		MainNode->Bold = True
		lblLeft.Text = ML("Main Project") & ": " & MainNode->Text
	End If
End Sub

Sub ReloadHistoryCode()
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->txtCode.Modified Then
		tb->Save
	End If
	Dim As OpenFileDialog OpenD
	OpenD.InitialDir = ExePath & Slash & "Temp"
	OpenD.Filter = ML("Backup Files") & " (*.bak)|" & GetFileName(tb->FileName) & "*.bak|" & ML("All Files") & "|*.*|"
	If OpenD.Execute AndAlso Trim(OpenD.FileName) <> "" Then
		tb->txtCode.Changing "Reload"
		tb->txtCode.LoadFromFile(OpenD.FileName, tb->FileEncoding, tb->NewLineType)
		tb->txtCode.Changed "Reload"
		#ifdef __USE_WINAPI__
			tb->DateFileTime = GetFileLastWriteTime(tb->FileName)
		#endif
		tb->txtCode.Modified = True
	End If
	
End Sub

Sub SetAsMain(IsTab As Boolean)
	Dim As TreeNode Ptr tn, ptn
	If IsTab AndAlso ptabCode->SelectedTab <> 0 Then
		tn = Cast(TabWindow Ptr, ptabCode->SelectedTab)->tn
	Else
		tn = tvExplorer.SelectedNode
	End If
	If CInt(ptabCode->Focused) AndAlso CInt(ptabCode->SelectedTab <> 0) Then tn = Cast(TabWindow Ptr, ptabCode->SelectedTab)->tn
	If tn = 0 Then Exit Sub Else ptn = GetParentNode(tn)
	If tn->ParentNode = 0 OrElse (ptn <> 0 AndAlso ptn->ImageKey = "Opened") OrElse (tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement) Then
		SetMainNode tn
		lblLeft.Text = ML("Main Project") & ": " & MainNode->Text
	Else
		Dim As ExplorerElement Ptr ee = tn->Tag
		Dim As ProjectElement Ptr ppe
		Dim As WString * MAX_PATH tMainNode
		If ptn <> 0 Then
			ppe = ptn->Tag
			If ppe = 0 Then
				ppe = _New(ProjectElement)
				WLet(ppe->FileName, "")
				ptn->Tag = ppe
			ElseIf Not *Cast(ExplorerElement Ptr, ptn->Tag) Is ProjectElement Then
				Dim As UString FileName = *Cast(ExplorerElement Ptr, ppe)->FileName
				_Delete(Cast(ExplorerElement Ptr, ppe))
				ppe = _New(ProjectElement)
				WLet(ppe->FileName, FileName)
				ptn->Tag = ppe
				ptn->ImageKey = "Project"
				ptn->SelectedImageKey = "Project"
				ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder
				ChangeMenuItemsEnabled
			End If
			If ee <> 0 AndAlso ppe <> 0 Then
				'David Change
				'If *ee->FileName = *pee->Project->MainFileName OrElse *ee->FileName = *pee->Project->ResourceFileName Then Exit Sub
				If EndsWith(LCase(*ee->FileName), ".rc") OrElse EndsWith(LCase(*ee->FileName), ".xpm") OrElse EndsWith(LCase(*ee->FileName), ".bas") OrElse EndsWith(LCase(*ee->FileName), ".bi") OrElse EndsWith(LCase(*ee->FileName), ".frm") _
					OrElse EndsWith(LCase(*ee->FileName), ".inc") OrElse EndsWith(LCase(*ee->FileName), ".bat") OrElse CBool(LCase(GetFileName(*ee->FileName)) = "makefile") OrElse EndsWith(LCase(*ee->FileName), ".sh") OrElse InStr(*ee->FileName, ".") = 0 Then
					Dim As TreeNode Ptr tn1, tn2
					Dim As Integer tIndex
					Dim As String IconName
					If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"
					If EndsWith(LCase(*ee->FileName), ".rc") Then
						WLet(ppe->ResourceFileName, *ee->FileName)
					ElseIf EndsWith(LCase(*ee->FileName), ".xpm") Then
						WLet(ppe->IconResourceFileName, *ee->FileName)
					ElseIf LCase(GetFileName(*ee->FileName)) = "makefile" Then
						WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
						WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
					ElseIf EndsWith(LCase(*ee->FileName), ".bat") Then
						WLet(ppe->BatchCompilationFileNameWindows, *ee->FileName)
					ElseIf EndsWith(LCase(*ee->FileName), ".sh") OrElse InStr(*ee->FileName, ".") = 0 Then
						WLet(ppe->BatchCompilationFileNameLinux, *ee->FileName)
					Else
						WLet(ppe->MainFileName, *ee->FileName)
					End If
					If Not ppe->Files.Contains(*ee->FileName) Then
						ppe->Files.Add *ee->FileName
					End If
					IconName = GetIconName(WGet(ee->FileName), ppe)
					If MainNode <> 0 Then MainNode->Bold = False
					MainNode = ptn 'MainNode must be root node
					MainNode->Bold = True
					tn->ImageKey = IconName
					tn->SelectedImageKey = IconName
					tMainNode = *ee->FileName
					For i As Integer = 0 To ptn->Nodes.Count - 1
						tn1 = ptn->Nodes.Item(i)
						If tn1->Nodes.Count = 0 Then
							If StartsWith(tn1->ImageKey, "Main") Then
								ee = tn1->Tag
								If ee <> 0 Then
									tn1->ImageKey = GetIconName(WGet(ee->FileName), ppe)
									tn1->SelectedImageKey = tn1->ImageKey
								End If
							End If
						Else
							For j As Integer = tn1->Nodes.Count - 1 To 0 Step -1
								tn2 = tn1->Nodes.Item(j)
								If StartsWith(tn2->ImageKey, "Main") Then
									ee = tn2->Tag
									If ee <> 0 Then
										tn2->ImageKey = GetIconName(WGet(ee->FileName), ppe)
										tn2->SelectedImageKey = tn2->ImageKey
									End If
								End If
							Next
						End If
					Next
					'					If tn1->Nodes.Count=1 Then 'Only one file
					'						tn1->Nodes.Remove(0)
					'						tn = tn1->Nodes.Add(GetFileName(*ee->FileName),, *ee->FileName, IconName, IconName, True)
					'						tn->Tag = ee
					'					End If
				End If
			End If
		End If
		'SaveProject ptn
	End If
End Sub

Sub Save()
	If tvExplorer.Focused Then
		Dim tn As TreeNode Ptr = GetParentNode(tvExplorer.SelectedNode)
		If tn = 0 Then Exit Sub
		If tn->ImageKey = "Project" Then
			SaveProject tn
			'		Else
			'			Dim tb As TabWindow Ptr
			'			If tn = 0 Then Exit Sub
			'			For i As Integer = 0 To ptabCode->TabCount - 1
			'				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			'				If tb->tn = tn Then
			'					tb->Save
			'					Exit For
			'				End If
			'			Next i
		End If
	Else
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		tb->Save
	End If
End Sub

Function CloseProject(tn As TreeNode Ptr, WithoutMessage As Boolean = False) As Boolean
	If tn = 0 Then Return True
	If tn->ImageKey <> "Project" AndAlso tn->ImageKey <> "MainProject" AndAlso tn->ImageKey <> "Opened" Then Return True
	Dim tb As TabWindow Ptr
	Dim As Boolean bProjectModified = EndsWith(tn->Text, "*")
	If Not WithoutMessage Then
		Dim tnP As TreeNode Ptr
		Dim Index As Integer
		With *pfSave
			.lstFiles.Clear
			If bProjectModified Then .lstFiles.AddItem tn->Text, tn
			For j As Integer = TabPanels.Count - 1 To 0 Step -1
				Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
				For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
					tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
					If tb->Modified Then
						tnP = tb->ptn
						If tnP = tn Then
							.lstFiles.AddItem IIf(bProjectModified, WSpace(2), "") & tb->Caption, tb
						End If
					End If
				Next i
			Next j
			If .lstFiles.ItemCount > 0 Then
				Select Case .ShowModal(*pfrmMain)
				Case ModalResults.Yes
					For i As Integer = .lstFiles.ItemCount - 1 To 0 Step -1
						If .lstFiles.Selected(i) Then
							If tvExplorer.Nodes.Contains(.lstFiles.ItemData(i)) Then
								If Not SaveProject(.lstFiles.ItemData(i)) Then Return False
							Else
								If Not Cast(TabWindow Ptr, .lstFiles.ItemData(i))->Save Then Return False
							End If
						End If
					Next
				Case ModalResults.No
				Case ModalResults.Cancel: Return False
				End Select
			End If
		End With
	End If
	For jj As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			If tb->ptn = tn Then
				If Not CloseTab(tb, True) Then Return False
				Exit For
			End If
		Next i
	Next jj
	For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
		If tn->Nodes.Item(j)->Nodes.Count = 0 Then
			'For jj As Integer = 0 To TabPanels.Count - 1
			'	Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			'	For i As Integer = 0 To ptabCode->TabCount - 1
			'		tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
			'		If tn->Nodes.Item(j) = tb->tn Then
			'			If Not CloseTab(tb, True) Then Return False
			'			Exit For
			'		End If
			'	Next i
			'Next jj
			If tn->Nodes.Item(j)->Tag <> 0 Then _Delete(Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Tag))
		Else
			For k As Integer = tn->Nodes.Item(j)->Nodes.Count - 1 To 0 Step - 1 '
				'For jj As Integer = 0 To TabPanels.Count - 1
				'	Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
				'	For i As Integer = 0 To ptabCode->TabCount - 1
				'		tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				'		If tn->Nodes.Item(j)->Nodes.Item(k) = tb->tn Then
				'			If Not CloseTab(tb, True) Then Return False
				'			Exit For
				'		End If
				'	Next i
				'Next jj
				If tn->Nodes.Item(j)->Nodes.Item(k)->Tag <> 0 Then _Delete(Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Nodes.Item(k)->Tag))
			Next k
		End If
	Next
	'	If bProjectModified AndAlso Not WithoutMessage Then
	'		Select Case MsgBox(ML("Want to save the project") & " """ & tn->Text & """?", "Visual FB Editor", mtWarning, btYesNoCancel)
	'		Case mrYES: If Not SaveProject(tn) Then Return False
	'		Case mrNO:
	'		Case mrCANCEL: Return False
	'		End Select
	'	End If
	If tn = MainNode Then SetMainNode 0
	If tn->Tag <> 0 Then _Delete(Cast(ProjectElement Ptr, tn->Tag))
	'miSaveProject->Enabled = False
	'miSaveProjectAs->Enabled = False
	'miCloseProject->Enabled = False
	'miCloseFolder->Enabled = False
	'miExplorerCloseProject->Enabled = False
	'miProjectProperties->Enabled = False
	'miExplorerProjectProperties->Enabled = False
	If tvExplorer.Nodes.IndexOf(tn) <> -1 Then tvExplorer.Nodes.Remove tvExplorer.Nodes.IndexOf(tn)
	ChangeMenuItemsEnabled
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
				iEndLine = txt->Content.Lines.Count - 1
			Else
				iStartLine = txt->Content.Lines.Count - 1
				iEndLine = 0
			End If
			If k = 1 AndAlso j = CurTabIndex Then
				txt->GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				n = iSelEndLine + iTo
			Else
				n = iStartLine
			End If
			For i = n To iEndLine Step iTo
				FECLine = txt->Content.Lines.Items[i]
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
	For j As Integer = 0 To TabPanels.Count - 1
		
		For i As Integer = 0 To ptabCode->TabCount -1
			Cast(TabWindow Ptr, ptabCode->Tabs[i])->txtCode.ClearAllBookmarks
		Next
	Next
End Sub

Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
	UseDebugger = bUseDebugger
	If ChangeObject <> 0 Then tbtUseDebugger->Checked = bUseDebugger
	If ChangeObject <> 1 AndAlso mnuUseDebugger->Checked <> UseDebugger Then mnuUseDebugger->Checked = bUseDebugger
End Sub

Sub ChangeFileEncoding(FileEncoding As FileEncodings)
	If miPlainText <> 0 Then miPlainText->Checked = FileEncoding = FileEncodings.PlainText
	If miUtf8 <> 0 Then miUtf8->Checked = FileEncoding = FileEncodings.Utf8
	If miUtf8BOM <> 0 Then miUtf8BOM->Checked = FileEncoding = FileEncodings.Utf8BOM
	If miUtf16BOM <> 0 Then miUtf16BOM->Checked = FileEncoding = FileEncodings.Utf16BOM
	If miUtf32BOM <> 0 Then miUtf32BOM->Checked = FileEncoding = FileEncodings.Utf32BOM
	If stBar.Count > 3 Then
		With *stBar.Panels[3]
			Select Case FileEncoding
			Case FileEncodings.PlainText: .Caption = "ASCII"
			Case FileEncodings.Utf8: .Caption = "UTF-8"
			Case FileEncodings.Utf8BOM: .Caption = "UTF-8 (BOM)"
			Case FileEncodings.Utf16BOM: .Caption = "UTF-16 (BOM)"
			Case FileEncodings.Utf32BOM: .Caption = "UTF-32 (BOM)"
			End Select
		End With
	End If
End Sub

Sub ChangeNewLineType(NewLineType As NewLineTypes)
	If miWindowsCRLF <> 0 Then miWindowsCRLF->Checked = NewLineType = NewLineTypes.WindowsCRLF
	If miLinuxLF <> 0 Then miLinuxLF->Checked = NewLineType = NewLineTypes.LinuxLF
	If miMacOSCR <> 0 Then miMacOSCR->Checked = NewLineType = NewLineTypes.MacOSCR
	If stBar.Count > 4 Then
		With *stBar.Panels[4]
			Select Case NewLineType
			Case NewLineTypes.WindowsCRLF: .Caption = "CR+LF"
			Case NewLineTypes.LinuxLF: .Caption = "LF"
			Case NewLineTypes.MacOSCR: .Caption = "CR"
			End Select
		End With
	End If
End Sub

Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
	tbtStartWithCompile->Enabled = bStart
	tbtStart->Enabled = bStart
	tbtBreak->Enabled = bBreak
	tbtEnd->Enabled = bEnd
	mnuStartWithCompile->Enabled = bStart
	mnuStart->Enabled = bStart
	mnuBreak->Enabled = bBreak
	mnuEnd->Enabled = bEnd
	mnuRestart->Enabled = bStart
	miGDBCommand->Enabled = bEnd
	miAddWatch->Enabled = bEnd
	miStepOut->Enabled = bEnd
	miShowNextStatement->Enabled = bEnd
End Sub

#ifdef __FB_WIN32__
	Sub TimerProc(hwnd As HWND, uMsg As UINT, idEvent As UINT_PTR, dwTime As DWORD)
#else
	Sub TimerProc()
#endif
	If fntab < 0 Or fcurlig < 1 Then Exit Sub
	If source(fntab) = "" Then Exit Sub
	shwtab = fntab
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse Not EqualPaths(tb->FileName, source(fntab)) Then
		tb = AddTab(LCase(source(fntab)))
	End If
	If tb = 0 Then Exit Sub
	CurEC = @tb->txtCode
	tb->txtCode.CurExecutedLine = fcurlig - 1
	tb->txtCode.SetSelection fcurlig - 1, fcurlig - 1, 0, 0
	tb->txtCode.PaintControl
	#ifndef __USE_GTK__
		SetForegroundWindow frmMain.Handle
		ChangeEnabledDebug True, False, True
	#endif
	fntab = 0
	fcurlig = -1
End Sub

#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
	Function TimerProcGDB() As Integer
		If fcurlig < 1 AndAlso fcurlig <> -2 Then Return 1
		ChangeEnabledDebug True, False, True
		If fcurlig <> -2 Then
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb = 0 OrElse Not EqualPaths(tb->FileName, CurrentFile) Then
				tb = AddTab(CurrentFile)
			End If
			If tb Then
				CurEC = @tb->txtCode
				tb->txtCode.CurExecutedLine = fcurlig - 1
				tb->txtCode.SetSelection fcurlig - 1, fcurlig - 1, 0, 0
				tb->txtCode.PaintControl
			End If
		Else
			tpOutput->SelectTab
			txtOutput.SetSel txtOutput.GetTextLength, txtOutput.GetTextLength
			txtOutput.ScrollToCaret
		End If
		'info_all_variables_debug()
		#ifdef __USE_WINAPI__
			SetForegroundWindow pApp->MainForm->Handle
		#endif
		fcurlig = -1
		Return 1
	End Function
#endif

Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
	Dim FileNameLeft As WString Ptr
	Dim FileNameRight As WString Ptr
	WLet(FileNameLeft, Replace(a, "\", "/"))
	If EndsWith(*FileNameLeft, ":") Then *FileNameLeft = Left(*FileNameLeft, Len(*FileNameLeft) - 1)
	WLet(FileNameRight, Replace(b, "\", "/"))
	EqualPaths = LCase(*FileNameLeft) = LCase(*FileNameRight)
	WDeAllocate(FileNameLeft)
	WDeAllocate(FileNameRight)
End Function

Sub ChangeTabsTn(TnPrev As TreeNode Ptr, Tn As TreeNode Ptr)
	Dim tb As TabWindow Ptr
	For j As Integer = 0 To TabPanels.Count - 1
		Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->tn = TnPrev Then
				tb->tn = Tn
				If ptabCode->SelectedTab = ptabCode->Tabs[i] Then Tn->SelectItem
				Exit For
			End If
		Next
	Next
End Sub

Declare Sub tvExplorer_NodeExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode, ByRef Cancel As Boolean)

Dim Shared bNotExpand As Boolean
Sub ChangeFolderType(Value As ProjectFolderTypes)
	Dim As TreeNode Ptr tn = tvExplorer.SelectedNode
	Select Case Value
	Case ProjectFolderTypes.ShowWithFolders: miShowWithFolders->RadioItem = True: ShowProjectFolders = True
	Case ProjectFolderTypes.ShowWithoutFolders: miShowWithoutFolders->RadioItem = True: ShowProjectFolders = False
	Case ProjectFolderTypes.ShowAsFolder: miShowAsFolder->RadioItem = True
	End Select
	If tn = 0 Then Exit Sub
	tn = GetParentNode(tn)
	If tn = 0 OrElse tn->Tag = 0 Then Exit Sub
	If tn->ImageKey <> "Project" Then Exit Sub
	Dim As ProjectElement Ptr ppe = Cast(ProjectElement Ptr, tn->Tag)
	Dim As ExplorerElement Ptr ee
	If ppe->ProjectFolderType <> Value Then
		If ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then
			bNotExpand = True
			ClearTreeNode tn
			bNotExpand = False
		End If
		Dim As TreeNode Ptr tnF, tnI, tnS, tnR, tnO
		Dim As TreeNode Ptr tn1, tn2
		If Value = ProjectFolderTypes.ShowWithFolders Then
			tnI = tn->Nodes.Add(ML("Includes"), "Includes", , "Opened", "Opened")
			tnF = tn->Nodes.Add(ML("Forms"), "Forms", , "Opened", "Opened")
			tnS = tn->Nodes.Add(ML("Modules"), "Modules",, "Opened", "Opened") ' "Modules" is better than "Sources"
			tnR = tn->Nodes.Add(ML("Resources"), "Resources", , "Opened", "Opened")
			tnO = tn->Nodes.Add(ML("Others"), "Others", , "Opened", "Opened")
		End If
		If ppe->ProjectFolderType = ProjectFolderTypes.ShowAsFolder Then
			tn->Text = tn->Text & ".vfp"
			WLet(ppe->FileName, *ppe->FileName & Slash & GetFileName(*ppe->FileName) & ".vfp")
			Dim As String IconName
			For j As Integer = 0 To ppe->Files.Count - 1
				ee = _New(ExplorerElement)
				WLet(ee->FileName, ppe->Files.Item(j))
				IconName = GetIconName(*ee->FileName, ppe)
				If Value = ProjectFolderTypes.ShowWithFolders Then
					If EndsWith(LCase(*ee->FileName), ".bi") Then
						tn1 = tnI
					ElseIf EndsWith(LCase(*ee->FileName), ".bas") Then
						tn1 = tnS
					ElseIf EndsWith(LCase(*ee->FileName), ".frm") Then
						tn1 = tnF
					ElseIf EndsWith(LCase(*ee->FileName), ".rc") Then
						tn1 = tnR
					Else
						tn1 = tnO
					End If
					tn2 = tn1->Nodes.Add(GetFileName(*ee->FileName), , , IconName, IconName, True)
					tn2->Tag = ee
				ElseIf Value = ProjectFolderTypes.ShowWithoutFolders Then
					tn2 = tn->Nodes.Add(GetFileName(*ee->FileName), , , IconName, IconName, True)
					tn2->Tag = ee
				End If
			Next
			ppe->Files.Clear
		Else
			For j As Integer = tn->Nodes.Count - 1 To 0 Step -1
				If ppe->ProjectFolderType = ProjectFolderTypes.ShowWithoutFolders Then
					If tn->Nodes.Item(j)->Tag <> 0 Then
						If Value = ProjectFolderTypes.ShowWithFolders Then
							If EndsWith(LCase(tn->Nodes.Item(j)->Text), ".bi") Then
								tn1 = tnI
							ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".bas") Then
								tn1 = tnS
							ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".frm") Then
								tn1 = tnF
							ElseIf EndsWith(LCase(tn->Nodes.Item(j)->Text), ".rc") Then
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
							'tn1->Expand
							tn->Nodes.Remove j
						ElseIf Value = ProjectFolderTypes.ShowAsFolder Then
							ppe->Files.Add *Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Tag)->FileName
						End If
					End If
				ElseIf ppe->ProjectFolderType = ProjectFolderTypes.ShowWithFolders Then
					For k As Integer = 0 To tn->Nodes.Item(j)->Nodes.Count - 1
						If Value = ProjectFolderTypes.ShowWithoutFolders Then
							Dim iIndex As Integer = -1
							For i As Integer = j + 1 To tn->Nodes.Count - 1
								If LCase(tn->Nodes.Item(i)->Text) > LCase(tn->Nodes.Item(j)->Nodes.Item(k)->Text) Then
									iIndex = i
									Exit For
								End If
							Next
							tn2 = tn->Nodes.Insert(iIndex, tn->Nodes.Item(j)->Nodes.Item(k)->Text, , , tn->Nodes.Item(j)->Nodes.Item(k)->ImageKey, tn->Nodes.Item(j)->Nodes.Item(k)->ImageKey)
							tn2->Tag = tn->Nodes.Item(j)->Nodes.Item(k)->Tag
							ChangeTabsTn tn->Nodes.Item(j)->Nodes.Item(k), tn2
						ElseIf Value = ProjectFolderTypes.ShowAsFolder Then
							ppe->Files.Add *Cast(ExplorerElement Ptr, tn->Nodes.Item(j)->Nodes.Item(k)->Tag)->FileName
						End If
					Next k
					If Value = ProjectFolderTypes.ShowWithoutFolders Then
						tn->Nodes.Remove j
					End If
				End If
			Next
			If Value = ProjectFolderTypes.ShowAsFolder Then
				tn->Text = GetFileName(GetFolderName(*ppe->FileName, False))
				WLet(ppe->FileName, GetFolderName(*ppe->FileName, False))
				tvExplorer_NodeExpanding(*tvExplorer.Designer, tvExplorer, *tn, False)
			End If
		End If
	End If
	ppe->ProjectFolderType = Value
End Sub

Sub CompileProgram(Param As Any Ptr)
	'If Compile Then RunProgram(0) ', Run Program after compiled with FBC.exe only here.
	Compile
End Sub

Sub CompileAll(Param As Any Ptr)
	'If Compile Then RunProgram(0) ', Run Program after compiled with FBC.exe only here.
	Compile(, True)
End Sub

Sub CompileBundle(Param As Any Ptr)
	Compile("Bundle")
End Sub

Sub CompileAPK(Param As Any Ptr)
	Compile("APK")
End Sub

Sub CompileAndRun(Param As Any Ptr)
	If Compile("Run") Then RunProgram(0)
	ThreadsEnter
	ChangeEnabledDebug True, False, False
	ThreadsLeave
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

Sub ToolBoxClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
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
			#ifndef __USE_GTK__
				scrTool.MaxValue = c
			#endif
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
		Case "component", "my.sys.componentmodel.component": Return 3
		Case "dialog": Return 4
		Case "": Return 0
		Case Else
			If ControlType = tbi->TypeName Then Return 0 Else Return GetTypeControl(tbi->TypeName)
		End Select
	Else
		Return 0
	End If
End Function

Sub pnlToolBox_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		tbToolBox.SetBounds 0, 0, NewWidth, NewHeight
	#else
		scrTool.MaxValue = Max(0, tbToolBox.Height - NewHeight)
		scrTool.Visible = scrTool.MaxValue <> 0
		tbToolBox.SetBounds 0, 0, NewWidth - IIf(scrTool.MaxValue <> 0, scrTool.Width, 0), NewHeight
	#endif
End Sub

#ifndef __USE_GTK__
	Sub tbToolBox_MouseWheel(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
		scrTool.Position = Min(scrTool.MaxValue, Max(scrTool.MinValue, scrTool.Position + -Direction * scrTool.ArrowChangeSize))
	End Sub
	
	Sub scrTool_MouseWheel(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Direction As Integer, x As Integer, y As Integer, Shift As Integer)
		scrTool.Position = Min(scrTool.MaxValue, Max(scrTool.MinValue, scrTool.Position + -Direction * scrTool.ArrowChangeSize))
	End Sub
#endif

Function DirExists(ByRef DirPath As WString) As Integer
	Const InAttr = fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive
	Dim AttrTester As Integer, DirString As String
	DirString = Dir(DirPath, InAttr, AttrTester)
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
		If FromFile = "" Then
			Return GetOSPath(ExePath & "\" & Mid(Path, 3))
		Else
			Return GetOSPath(GetFolderName(FromFile) & Mid(Path, 3))
		End If
	ElseIf StartsWith(Path, "../") OrElse StartsWith(Path, "..\") Then
		Return GetOSPath(GetFolderName(GetFolderName(FromFile)) & Mid(Path, 4))
	End If
	Dim Result As UString = GetOSPath(GetFolderName(FromFile) & Path)
	If GetFolderName(FromFile) <> "" AndAlso FileExists(Result) Then
		Return Result
	Else
		Dim Result As UString = GetOSPath(ExePath & Slash & Path)
		If FileExists(Result) Then
			Return Result
		Else
			Dim As Library Ptr CtlLibrary
			For i As Integer = 0 To ControlLibraries.Count - 1
				CtlLibrary = ControlLibraries.Item(i)
				If Not CtlLibrary->Enabled Then Continue For
				Result = GetOSPath(GetFullPath(GetFullPath(CtlLibrary->IncludeFolder, CtlLibrary->Path)) & IIf(EndsWith(CtlLibrary->IncludeFolder, "\") OrElse EndsWith(CtlLibrary->IncludeFolder, "/"), "", Slash) & Path)
				If FileExists(Result) Then Return Result
			Next
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
					For i As Integer = 0 To pIncludePaths->Count - 1
						Result = GetOSPath(pIncludePaths->Item(i) & IIf(EndsWith(pIncludePaths->Item(i), "\") OrElse EndsWith(pIncludePaths->Item(i), "/"), "", Slash) & Path)
						If FileExists(Result) Then Return Result
					Next
					Return GetOSPath(Path)
				End If
			End If
		End If
	End If
End Function

Function GetXY(XorY As Integer) As Integer
	Return IIf(XorY > 60000, XorY - 65535, XorY)
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

Function WithoutQuotes(ByRef e As UString) As UString
	Dim As UString s = e
	If StartsWith(s, """") Then s = Mid(s, 2)
	If EndsWith(s, """") Then s = Left(s, Len(s) - 1)
	Return Replace(s, """""", """")
End Function

Function DeleteSpaces(b As String) As String
	Dim iCount As Integer
	Dim bNew As String = b
	'	Do
	'		?bNew
	'		bNew = Replace(bNew, "  ", " ", , iCount)
	'		?bNew
	'		?iCount
	'	Loop While iCount > 0
	Return bNew
End Function

Function GetRelative(ByRef FileName As WString, ByRef FromFile As WString) As UString
	If StartsWith(FileName, FromFile) Then
		Dim As UString Path = Mid(FileName, Len(FromFile) + 1)
		If StartsWith(Path, "\") OrElse StartsWith(Path, "/") Then Path = Mid(Path, 2)
		Return Path
	Else Return FileName
	End If
End Function

Sub LoadFunctions(ByRef Path As WString, LoadParameter As LoadParam = FilePathAndIncludeFiles, ByRef Types As WStringOrStringList, ByRef Enums As WStringOrStringList, ByRef Functions As WStringOrStringList, ByRef TypeProcedures As WStringOrStringList, ByRef Args As WStringOrStringList, ec As Control Ptr = 0, CtlLibrary As Library Ptr = 0, CurFileItem As Any Ptr = 0, OldFileItem As Any Ptr = 0)
	If FormClosing Then Exit Sub
	Dim As EditControlContent Ptr File = CurFileItem, OldFile = OldFileItem
	MutexLock tlockSave 'If LoadParameter <> LoadParam.OnlyFilePathOverwrite Then
	If LoadParameter <> LoadParam.OnlyIncludeFiles AndAlso LoadParameter <> LoadParam.OnlyFilePathOverwrite AndAlso LoadParameter <> LoadParam.OnlyFilePathOverwriteWithContent Then
		If ec = 0 Then
			If IncludeFiles.Contains(Path) Then
				MutexUnlock tlockSave
				Exit Sub
			Else
				If File = 0 Then
					File = _New(EditControlContent)
					File->FileName = Path
				End If
				IncludeFiles.Add Path, File
			End If
		End If
		If @Types = @Comps Then
			pfSplash->lblProcess.Text = Path
			#ifdef __USE_GTK__
				pApp->DoEvents
			#endif
		End If
	End If
	Var Idx = -1
	If File = 0 Then
		If IncludeFiles.Contains(Path, , , , Idx) Then
			File = IncludeFiles.Object(Idx)
			If File = 0 Then
				File = _New(EditControlContent)
				File->FileName = Path
				IncludeFiles.Object(Idx) = File
			End If
		Else
			File = _New(EditControlContent)
			File->FileName = Path
			IncludeFiles.Add Path, File
		End If
		'ElseIf CurFileItem <> 0 AndAlso IncludeFiles.Contains(Path, , , , Idx) Then
		'	IncludeFiles.Object(Idx) = CurFileItem
	End If
	If OldFile <> 0 AndAlso OldFile->Includes.Contains(Path, , , , Idx) Then
		OldFile->Includes.Object(Idx) = File
	End If
	'	#ifdef __US_GTK__
	'		Exit Sub
	'	#endif
	Dim As WString * 2048 b, b1, Comment, bTrim, bTrimLCase
	Dim As WString * 255 PathFunction, LoadFunctionPath
	Dim As String t, e, tOrig, bt, CurrentCondition
	Dim As Integer Pos1, Pos2, Pos3, Pos4, Pos5, l, n, nc, Index, iStart, i, j, iC, OldiC
	Dim As TypeElement Ptr te, tbi, typ, lastfunctionte
	Dim As Boolean inType, inUnion, inEnum, InFunc, InNamespace, InAsm, OldInType
	Dim As Boolean bTypeIsPointer
	Dim As Integer inPubProPri = 0
	Dim As Integer Result
	'Dim b As WString * 2048 ' for V1.07 Line Input not working fine
	Dim As EditControlLine Ptr FECLine
	Dim As Integer LastIndexFunction
	Dim As WStringList Lines, Namespaces, OldTypes
	Dim As IntegerList TypesPubProPri
	PathFunction = Path
	If ec <> 0 Then
		With *Cast(EditControl Ptr, ec)
			For i As Integer = 0 To .LinesCount - 1
				Lines.Add .Lines(i)
			Next
		End With
	Else
		Dim As Integer ff = FreeFile_
		Result = Open(PathFunction For Input Encoding "utf-32" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input Encoding "utf-16" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input Encoding "utf-8" As #ff)
		If Result <> 0 Then Result = Open(PathFunction For Input As #ff)
		If Result = 0 Then
			inType = False
			i = 0
			Do Until EOF(ff)
				Line Input #ff, b
				If LoadParameter = LoadParam.OnlyFilePathOverwriteWithContent Then
					FECLine = _New( EditControlLine)
					WLet(FECLine->Text, b)
					File->Lines.Add(FECLine)
					iC = FindCommentIndex(b, OldiC)
					FECLine->CommentIndex = iC
					FECLine->InAsm = InAsm
					File->ChangeCollapsibility i
					If FECLine->ConstructionIndex = C_Asm Then
						InAsm = FECLine->ConstructionPart = 0
					End If
					FECLine->InAsm = InAsm
					OldiC = iC
					i += 1
				Else
					Lines.Add b
				End If
			Loop
		End If
		CloseFile_(ff)
	End If
	If LoadParameter = LoadParam.OnlyFilePathOverwriteWithContent Then
		LoadFunctionsWithContent Path, File->Tag, *File
		MutexUnlock tlockSave
		Exit Sub
	End If
	For i As Integer = 0 To Lines.Count - 1
		b1 = Replace(Lines.Item(i), !"\t", " ")
		If StartsWith(Trim(b1), "'") Then
			If i = 0 OrElse Trim(Comment) = "" Then
				Comment = Mid(Trim(b1), 2)
			Else
				Comment &= " <br> " & Mid(Trim(b1), 2)
			End If
			Continue For
		ElseIf Trim(b1) = "" Then
			Comment = ""
			Continue For
		End If
		Dim As WString Ptr res(Any)
		Split(b1, """", res())
		b = ""
		For j As Integer = 0 To UBound(res)
			If j = 0 Then
				b = *res(0)
			ElseIf j Mod 2 = 0 Then
				b &= """" & *res(j)
			Else
				b &= """" & WSpace(Len(*res(j)))
			End If
			Deallocate res(j)
		Next
		Erase res
		Pos4 = InStr(b, "'")
		If Pos4 > 0 Then
			b = Left(b, Pos4 - 1)
		End If
		If inType Then
			b = Replace(b, ":", "%")
		End If
		Split(b, ":", res())
		Dim k As Integer = 1
		For j As Integer = 0 To UBound(res)
			l = Len(*res(j))
			b = Mid(b1, k, l)
			bTrim = Trim(b, Any !"\t ") 'DeleteSpaces(Trim(b, Any !"\t "))
			bTrimLCase = LCase(bTrim)
			k = k + Len(*res(j)) + 1
			If CInt(StartsWith(LTrim(LCase(b)), "#include ")) Then
				Pos1 = InStr(b, """")
				If Pos1 > 0 Then
					Pos2 = InStr(Pos1 + 1, b, """")
					LoadFunctionPath = GetRelativePath(Mid(b, Pos1 + 1, Pos2 - Pos1 - 1), PathFunction)
					Var Idx = IncludeFiles.IndexOf(LoadFunctionPath)
					If Idx <> -1 Then
						File->Includes.Add LoadFunctionPath, IncludeFiles.Object(Idx)
					Else
						File->Includes.Add LoadFunctionPath
					End If
					File->IncludeLines.Add i
				End If
			ElseIf LoadParameter <> LoadParam.OnlyIncludeFiles Then
				Pos3 = InStr(bTrimLCase, " as ")
				If CInt(StartsWith(bTrimLCase, "type ") OrElse StartsWith(bTrimLCase, "private type ") OrElse StartsWith(bTrimLCase, "public type ") OrElse _
					StartsWith(bTrimLCase, "class ") OrElse StartsWith(bTrimLCase, "private class ") OrElse StartsWith(bTrimLCase, "public class ")) AndAlso CInt(IIf(inType, Pos3 = 0, True)) Then
					Pos1 = InStr(" " & bTrimLCase, " type ")
					Pos5 = 5
					If Pos1 = 0 Then Pos1 = InStr(" " & bTrimLCase, " class "): Pos5 = 6
					If Pos1 > 0 Then
						Pos2 = InStr(bTrimLCase, " extends ")
						If Pos2 > 0 Then
							t = Trim(Mid(bTrim, Pos1 + Pos5, Pos2 - Pos1 - Pos5))
							e = Trim(Mid(bTrim, Pos2 + 9))
						ElseIf Pos3 > 0 Then
							If Trim(Left(LCase(bTrim), Pos3)) = "type" Then  'Like "Type As    Short gint16, gshort, gunichar2" Then
								Pos5 = InStrRev(bTrim, " ")
								t = Trim(Mid(bTrim, Pos5 + 1))
								e = Trim(Mid(bTrim, Pos3 + 4, Pos5 - (Pos3 + 4)))
							Else
								t = Trim(Mid(bTrim, Pos1 + Pos5, Pos3 - Pos1 - Pos5))
								e = Trim(Mid(bTrim, Pos3 + 4))
							End If
						Else
							Pos2 = InStr(Pos1 + Pos5, bTrim, " ")
							If Pos2 > 0 Then
								t = Trim(Mid(bTrim, Pos1 + Pos5, Pos2 - Pos1 - Pos5))
							Else
								t = Trim(Mid(bTrim, Pos1 + Pos5))
							End If
							e = ""
						End If
						Pos4 = InStr(e, "'")
						If Pos4 > 0 Then
							e = Trim(Left(e, Pos4 - 1))
						End If
						bTypeIsPointer = EndsWith(LCase(e), " ptr") OrElse EndsWith(LCase(e), " pointer")
						e = WithoutPointers(e)
						tOrig = t
						If t = "Object" And e = "Object" Then
							t = "My.Sys.Object"
							e = ""
						End If
						OldInType = inType
						inType = Pos3 = 0
						inPubProPri = 0
						If Types.Contains(t, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->FileName = PathFunction AndAlso OldTypes.Count = 0 Then
							tbi = Types.Object(Idx)
						Else
							tbi = _New( TypeElement)
						End If
						tbi->Name = t
						tbi->DisplayName = t & IIf(Pos5 = 5, " [Type]", " [Class]")
						tbi->TypeIsPointer = bTypeIsPointer
						tbi->TypeName = e
						tbi->ElementType = IIf(Pos3 > 0, E_TypeCopy, E_Type)
						tbi->InCondition = CurrentCondition
						tbi->StartLine = i
						tbi->FileName = PathFunction
						If CtlLibrary Then tbi->IncludeFile = Replace(GetRelative(PathFunction, CtlLibrary->IncludeFolder), "\", "/")
						tbi->Parameters = Trim(Mid(bTrim, Pos1 + Pos5))
						tbi->CtlLibrary = CtlLibrary
						tbi->Tag = CtlLibrary
						If Comment <> "" Then tbi->Comment = Comment: Comment = ""
						If inType Then OldTypes.Add t, tbi
						typ = tbi
						If Types.Contains(t, , , , Idx) AndAlso Cast(TypeElement Ptr, Types.Object(Idx))->FileName = PathFunction Then
							If OldTypes.Count > 1 Then
								TypesInFunc.Add t, tbi
							End If
						ElseIf InFunc = False Then
							If OldTypes.Count > 1 Then
								Dim As TypeElement Ptr teOld = OldTypes.Object(OldTypes.Count - 2)
								teOld->Elements.Add t, tbi
								teOld->Types.Add t, tbi
							Else
								Types.Add t, tbi
								If Namespaces.Count > 0 Then
									Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add tOrig, tbi
									For n_i As Integer = 0 To Namespaces.Count - 1
										tbi->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
									Next
								End If
							End If
						Else
							TypesInFunc.Add t, tbi
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "end type ") OrElse StartsWith(bTrimLCase & " ", "end class ") OrElse StartsWith(bTrimLCase & " ", "__startofclassbody__ ") Then
					If OldTypes.Count > 0 Then
						If OldTypes.Count > 1 AndAlso typ->InCondition = "Not " & Cast(TypeElement Ptr, OldTypes.Object(OldTypes.Count - 2))->InCondition Then
							OldTypes.Remove OldTypes.Count - 1
						End If
						OldTypes.Remove OldTypes.Count - 1
					End If
					If OldTypes.Count > 0 Then
						inType = True
						typ = OldTypes.Object(OldTypes.Count - 1)
						tbi = typ
						Var Idx = TypesPubProPri.IndexOfObject(typ)
						If Idx > -1 Then inPubProPri = TypesPubProPri.Item(Idx)
					Else
						inType = False
					End If
				ElseIf StartsWith(bTrimLCase, "union ") Then
					inUnion = True
					t = Trim(Mid(bTrim, 7))
					Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					'If Not Types.Contains(t) Then
					tbi = _New( TypeElement)
					tbi->Name = t
					tbi->DisplayName = t & " [Union]"
					tbi->TypeName = ""
					tbi->ElementType = E_Union
					tbi->StartLine = i
					tbi->FileName = PathFunction
					tbi->CtlLibrary = CtlLibrary
					Types.Add t, tbi
					typ = tbi
					If Namespaces.Count > 0 Then
						Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
						If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add tbi->Name, tbi
					End If
					'End If
				ElseIf CInt(StartsWith(bTrimLCase, "end union")) Then
					inUnion = False
				ElseIf StartsWith(bTrimLCase, "#if ") Then
					CurrentCondition = Trim(Mid(bTrimLCase, 5))
				ElseIf StartsWith(bTrimLCase, "#ifdef") Then
					CurrentCondition = Trim(Mid(bTrimLCase, 7))
				ElseIf StartsWith(bTrimLCase, "#ifndef") Then
					CurrentCondition = "Not " & Trim(Mid(bTrimLCase, 8))
				ElseIf StartsWith(bTrimLCase, "#elseif") Then
					CurrentCondition = Trim(Mid(bTrimLCase, 8))
				ElseIf StartsWith(bTrimLCase, "#else") Then
					CurrentCondition = "Not " & CurrentCondition
				ElseIf StartsWith(bTrimLCase, "#endif") Then
					CurrentCondition = ""
				ElseIf StartsWith(bTrimLCase & " ", "#define ") Then
					If Not InFunc Then
						Dim As UString b2 = Trim(Mid(bTrim, 9))
						Pos1 = InStr(b2, " ")
						Pos2 = InStr(b2, "(")
						Pos3 = InStr(b2, ")")
						If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
						te = _New( TypeElement)
						If Pos1 = 0 Then
							te->Name = b2
						Else
							te->Name = Trim(Left(b2, Pos1 - 1))
						End If
						te->DisplayName = te->Name
						te->ElementType = E_Define
						te->Parameters = Trim(b2)
						Pos4 = InStr(te->Parameters, "'")
						If Pos4 > 0 Then
							te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
						End If
						If Pos1 > 0 Then
							te->Value = Trim(Mid(b2, IIf(Pos3, Pos3, Pos1) + 1))
						End If
						If inType Then
							te->Locals = inPubProPri
						End If
						te->StartLine = i
						te->EndLine = i
						If Comment <> "" Then te->Comment= Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						Globals.Defines.Add te->Name, te
						lastfunctionte = te
						If inType AndAlso typ <> 0 Then
							typ->Elements.Add te->Name, te
						Else
							LastIndexFunction = Functions.Add(te->Name, te)
							If Namespaces.Count > 0 Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
								For n_i As Integer = 0 To Namespaces.Count - 1
									te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
								Next
								te->FullName = te->OwnerNamespace & "." & te->Name
							Else
								te->FullName = te->Name
							End If
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "#macro ") Then
					Pos1 = InStr(8, bTrim, " ")
					Pos2 = InStr(8, bTrim, "(")
					Pos3 = InStr(8, bTrim, ")")
					If Pos2 > 0 AndAlso (Pos2 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos2
					te = _New( TypeElement)
					If Pos1 = 0 Then
						te->Name = Trim(Mid(bTrim, 8))
					Else
						te->Name = Trim(Mid(bTrim, 8, Pos1 - 8))
					End If
					te->DisplayName = te->Name
					te->ElementType = E_Macro
					te->Parameters = Trim(Mid(bTrim, 8))
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
					te->CtlLibrary = CtlLibrary
					Globals.Defines.Add te->Name, te
					lastfunctionte = te
					If inType AndAlso typ <> 0 Then
						typ->Elements.Add te->Name, te
					Else
						LastIndexFunction = Functions.Add(te->Name, te)
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
					End If
				ElseIf StartsWith(bTrimLCase & " ", "namespace ") AndAlso Pos3 = 0 Then
					InNamespace = True
					Pos1 = InStr(11, bTrim, " ")
					Dim As String Names
					Dim As WString Ptr res1(Any)
					If Pos1 = 0 Then
						Names = Trim(Mid(bTrim, 11))
					Else
						Names = Trim(Mid(bTrim, 11, Pos1 - 11))
					End If
					Split(Names, ".", res1())
					nc = UBound(res1)
					For n As Integer = 0 To nc
						te = _New( TypeElement)
						te->Name = Trim(*res1(n))
						te->DisplayName = te->Name
						te->ElementType = E_Namespace
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
						te->CtlLibrary = CtlLibrary
						Globals.Namespaces.Add te->Name, te
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
						Namespaces.Add te->Name, te
						Deallocate res1(n)
					Next
					Erase res1
				ElseIf StartsWith(bTrimLCase & " ", "end namespace ") Then
					InNamespace = False
					If Namespaces.Count > 0 Then
						nc = Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->ControlType
						For i As Integer = 0 To nc
							If Namespaces.Count > 0 Then Namespaces.Remove Namespaces.Count - 1
						Next i
					End If
				ElseIf StartsWith(bTrimLCase & " ", "declare ") Then
					iStart = 9
					Pos1 = InStr(9, bTrim, " ")
					Pos3 = InStr(9, bTrim, "(")
					If StartsWith(Trim(Mid(bTrimLCase, 9)), "static ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "virtual ") OrElse StartsWith(Trim(Mid(bTrimLCase, 9)), "abstract ") Then
						iStart = Pos1
						Pos1 = InStr(Pos1 + 1, bTrim, " ")
					End If
					Pos4 = InStr(Pos1 + 1, bTrim, " ")
					If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
					Pos4 = InStr(bTrim, "(")
					If Pos4 > 0 AndAlso (Pos4 < Pos1 OrElse Pos1 = 0) Then Pos1 = Pos4
					If StartsWith(LCase(Trim(Mid(bTrim, 9))), "operator") Then Continue For
					te = _New( TypeElement)
					te->Declaration = True
					Select Case LCase(IIf(Pos1 = 0, Trim(Mid(bTrim, iStart)), Trim(Mid(bTrim, iStart, Pos1 - iStart))))
					Case "sub": te->ElementType = E_Sub
					Case "function": te->ElementType = E_Function
					Case "property": te->ElementType = E_Property
					Case "operator": te->ElementType = E_Operator
					Case "constructor": te->ElementType = E_Constructor
					Case "destructor": te->ElementType = E_Destructor
					End Select
					If inType AndAlso typ <> 0 AndAlso (te->ElementType = E_Constructor OrElse te->ElementType = E_Destructor) Then
						te->Name = typ->Name
						te->DisplayName = typ->Name & " [" & IIf(te->ElementType = E_Constructor, "Constructor", "Destructor") & "] [Declare]"
						te->TypeName = typ->Name
						te->Parameters = typ->Name & IIf(Pos4 > 0, Mid(bTrim, Pos4), "()")
					Else
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos1))
						Else
							te->Name = Trim(Mid(bTrim, Pos1, Pos3 - Pos1))
						End If
						If te->ElementType = E_Property Then
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
						Pos4 = InStrRev(te->TypeName, ".")
						If Pos4 > 0 AndAlso LCase(te->TypeName) <> "my.sys.object" Then
							te->TypeName = Mid(te->TypeName, Pos4 + 1)
						End If
					End If
					If inType Then
						te->Locals = inPubProPri
					End If
					If te->ElementType = E_Operator Then
						te->Locals = 2
					End If
					Pos4 = InStr(te->Parameters, "'")
					If Pos4 > 0 Then
						te->Parameters = Trim(Left(te->Parameters, Pos4 - 1))
					End If
					te->StartLine = i
					te->EndLine = i
					If Comment <> "" Then te->Comment = Comment: Comment = ""
					te->FileName = PathFunction
					te->CtlLibrary = CtlLibrary
					If inType AndAlso typ <> 0 AndAlso te->ElementType <> E_Constructor AndAlso te->ElementType <> E_Destructor Then
						typ->Elements.Add te->Name, te
					Else
						LastIndexFunction = Functions.Add(te->Name, te)
						lastfunctionte = te
						If Not inType Then
							If Namespaces.Count > 0 Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index <> -1 Then
									Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
								End If
								For n_i As Integer = 0 To Namespaces.Count - 1
									te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
								Next
								te->FullName = te->OwnerNamespace & "." & te->Name
							Else
								te->FullName = te->Name
							End If
						End If
					End If
				ElseIf inType OrElse inUnion Then
					If bTrimLCase = "public:" Then
						inPubProPri = 0
						Var Idx = TypesPubProPri.IndexOfObject(tbi)
						If Idx = -1 Then
							TypesPubProPri.Add inPubProPri, tbi
						Else
							TypesPubProPri.Item(Idx) = inPubProPri
						End If
						Comment = ""
					ElseIf bTrimLCase = "protected:" Then
						inPubProPri = 1
						Var Idx = TypesPubProPri.IndexOfObject(tbi)
						If Idx = -1 Then
							TypesPubProPri.Add inPubProPri, tbi
						Else
							TypesPubProPri.Item(Idx) = inPubProPri
						End If
						Comment = ""
					ElseIf bTrimLCase = "private:" Then
						inPubProPri = 2
						Var Idx = TypesPubProPri.IndexOfObject(tbi)
						If Idx = -1 Then
							TypesPubProPri.Add inPubProPri, tbi
						Else
							TypesPubProPri.Item(Idx) = inPubProPri
						End If
						Comment = ""
					ElseIf CInt(StartsWith(bTrimLCase, "as ")) OrElse CInt(StartsWith(bTrimLCase, "const ")) OrElse InStr(bTrimLCase, " as ") Then
						Dim As WString * 2048 b2 = bTrim
						Dim As WString * 2048 CurType, ElementValue, TypeComment
						Dim As WString Ptr res1(Any)
						Dim As Integer uu, ct
						Dim As Boolean bOldAs
						If StartsWith(LCase(b2), "dim ") Then
							b2 = Trim(Mid(b2, 4))
						ElseIf StartsWith(LCase(b2), "redim ") Then
							b2 = Trim(Mid(b2, 6))
						ElseIf StartsWith(LCase(b2), "static ") Then
							b2 = Trim(Mid(b2, 7))
						End If
						Pos1 = InStr(b2, "'")
						Pos2 = InStr(b2, "/'")
						If Pos2 > 0 AndAlso Pos2 < Pos1 Then
							Pos1 = InStr(b2, "'/")
							If Pos1 = 0 Then
								TypeComment = Trim(Mid(b2, Pos2 + 2))
								b2 = Trim(Left(b2, Pos2 - 1))
							Else
								TypeComment = Trim(Mid(b2, Pos2 + 2, Pos1 - 1 - (Pos2 + 2)))
								b2 = Trim(Left(b2, Pos2 - 1)) & " " & Trim(Mid(b2, Pos1 + 3))
							End If
						ElseIf Pos1 > 0 Then
							TypeComment = Trim(Mid(b2, Pos1 + 1))
							b2 = Trim(Left(b2, Pos1 - 1))
						End If
						Pos1 = InStr(b2, "=>")
						If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
						If StartsWith(LCase(b2), "as ") Then
							If StartsWith(LCase(b2), "as ") Then CurType = Trim(Mid(b2, 4)) Else CurType = Trim(b2)
							bOldAs = True
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
								If UBound(res1) > -1 Then
									CurType = ..Left(CurType, Pos1 + Len(*res1(0)))
								End If
							End If
						Else
							Split GetChangedCommas(b2), ",", res1()
						End If
						For n As Integer = 0 To UBound(res1)
							*res1(n) = Trim(Replace(*res1(n), ";", ","))
							ElementValue = ""
							If InStr(LCase(b2), " sub(") = 0 Then
								Pos1 = InStr(*res1(n), "=")
								If Pos1 > 0 Then
									ElementValue = Trim(Mid(*res1(n), Pos1 + 1))
									If CBool(n = 0) AndAlso bOldAs Then
										CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) + Pos1 - 2))
										CurType = Replace(CurType, "`", "=")
									End If
								End If
								If Pos1 > 0 Then *res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(*res1(n)), " as ")
							If Pos1 > 0 AndAlso Not bOldAs Then
								CurType = Trim(Mid(*res1(n), Pos1 + Len("As") + 2))
								CurType = Replace(CurType, "`", "=")
								*res1(n) = Trim(..Left(*res1(n), Pos1 - 1))
							End If
							'If Pos1 > 0 Then
							'	CurType = Trim(Mid(*res1(n), Pos1 + 4))
							''								Pos2 = InStr(CurType, "*") 'David Change. Like Wstring * 200
							''								If Pos2 > 1 Then CurType = Trim(Mid(*res1(n), Pos1 + 4, Pos2 - Pos1 - 3)) Else CurType = Trim(Mid(*res1(n), Pos1 + 4))
							'	*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							'End If
							'If CBool(n = 0) AndAlso bOldAs Then
							'	CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n))))
							'	CurType = Replace(CurType, "`", "=")
							'End If
							Pos1 = InStr(*res1(n), ":")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							If StartsWith(LCase(*res1(n)), "byref") OrElse StartsWith(LCase(*res1(n)), "byval") Then
								ct += Len(*res1(n)) - Len(Trim(Mid(*res1(n), 6)))
								*res1(n) = Trim(Mid(*res1(n), 6))
							End If
							Pos1 = InStr(*res1(n), "(")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(*res1(n)), " alias ")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(..Left(*res1(n), Pos1 - 1))
							End If
							ct += Len(*res1(n)) - Len(Trim(*res1(n)))
							*res1(n) = Trim(*res1(n))
							Pos1 = InStrRev(*res1(n), " ")
							If Pos1 > 0 Then *res1(n) = Trim(Mid(*res1(n), Pos1 + 1))
							If CBool(n = 0) AndAlso bOldAs Then
								CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) - ct))
							End If
							If Not (StartsWith(LCase(CurType), "sub") OrElse StartsWith(LCase(CurType), "function")) Then
								Pos1 = InStrRev(CurType, ".")
								If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							End If
							Var te = _New( TypeElement)
							te->Name = *res1(n)
							If tbi AndAlso tbi->Name <> "" Then
								te->DisplayName = tbi->Name & "." & te->Name
							Else
								te->DisplayName = te->Name
							End If
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
							ElseIf TypeComment <> "" Then
								te->EnumTypeName = TypeComment
							End If
							te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
							te->TypeName = WithoutPointers(te->TypeName)
							te->Value = ElementValue
							te->ElementType = IIf(StartsWith(bTrimLCase, "const "), E_Constant, IIf(StartsWith(LCase(te->TypeName), "sub(") OrElse StartsWith(LCase(te->TypeName), "function("), E_Event, E_Field))
							te->Locals = inPubProPri
							te->StartLine = i
							te->Parameters = *res1(n) & " As " & CurType
							te->FileName = PathFunction
							te->CtlLibrary = CtlLibrary
							If Comment <> "" Then te->Comment = Comment: Comment = ""
							If tbi Then tbi->Elements.Add te->Name, te
							Deallocate res1(n)
						Next n
						Erase res1
					End If
				ElseIf CInt(StartsWith(Trim(LCase(b)), "enum ")) OrElse CInt(StartsWith(Trim(LCase(b)), "public enum ")) OrElse CInt(StartsWith(Trim(LCase(b)), "private enum ")) OrElse CInt(Trim(LCase(b)) = "enum") Then
					inEnum = True
					Pos2 = InStr(" " & bTrimLCase, " enum")
					t = Trim(Mid(" " & bTrim, Pos2 + 5))
					Pos2 = InStr(t, "'")
					If Pos2 > 0 Then t = Trim(Left(t, Pos2 - 1))
					If Not Comps.Contains(t) Then
						tbi = _New( TypeElement)
						tbi->Name = t
						tbi->DisplayName = t & " [Enum]"
						tbi->TypeName = ""
						tbi->ElementType = E_Enum
						tbi->StartLine = i
						tbi->FileName = PathFunction
						tbi->CtlLibrary = CtlLibrary
						If InFunc = False Then
							If inType Then
								tbi->Elements.Add t, tbi
								tbi->Enums.Add t, tbi
							Else
								Enums.Add t, tbi
								If Namespaces.Count > 0 Then
									Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
									If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add tbi->Name, tbi
									For n_i As Integer = 0 To Namespaces.Count - 1
										tbi->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
									Next
								End If
							End If
						Else
							EnumsInFunc.Add t, tbi
						End If
					End If
				ElseIf CInt(StartsWith(bTrimLCase, "end enum")) Then
					inEnum = False
				ElseIf inEnum Then
					If StartsWith(bTrim, "#") OrElse StartsWith(bTrim, "'") Then Continue For
					Dim As WString * 2048 b2 = b, ElementValue
					Dim As WString Ptr res1(Any)
					Pos2 = InStr(b2, "'")
					If Pos2 > 0 Then b2 = Trim(Left(b2, Pos2 - 1))
					Split b2, ",", res1()
					For n As Integer = 0 To UBound(res1)
						Pos3 = InStr(*res1(n), "=")
						If Pos3 > 0 Then
							ElementValue = Trim(Mid(*res1(n), Pos3 + 1))
						Else
							ElementValue = ""
						End If
						If Pos3 > 0 Then
							t = Trim(Left(*res1(n), Pos3 - 1))
						Else
							t = Trim(*res1(n))
						End If
						Var te = _New( TypeElement)
						te->Name = t
						If tbi AndAlso tbi->Name <> "" Then
							te->DisplayName = tbi->Name & "." & te->Name
						Else
							te->DisplayName = te->Name
						End If
						te->ElementType = E_EnumItem
						te->Value = ElementValue
						te->StartLine = i
						te->Parameters = Trim(*res1(n))
						te->FileName = PathFunction
						If tbi Then tbi->Elements.Add te->Name, te
						te = _New( TypeElement)
						te->Name = t
						If tbi AndAlso tbi->Name <> "" Then
							te->DisplayName = tbi->Name & "." & te->Name
						Else
							te->DisplayName = te->Name
						End If
						te->ElementType = E_EnumItem
						te->Value = ElementValue
						te->StartLine = i
						te->Parameters = Trim(*res1(n))
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						Args.Add te->Name, te
						Deallocate res1(n)
					Next n
					Erase res1
				Else 'If LoadParameter <> LoadParam.OnlyTypes Then
					If CInt(StartsWith(bTrimLCase & " ", "end sub ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end function ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end property ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end operator ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase & " ", "end destructor ")) Then
						InFunc = False
						If lastfunctionte <> 0 Then
							lastfunctionte->EndLine = i
							LastIndexFunction = -1
						End If
					ElseIf CInt(StartsWith(bTrimLCase, "operator ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private operator ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public operator ")) Then
						InFunc = True
					ElseIf CInt(StartsWith(bTrimLCase, "constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private constructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public constructor ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " constructor ") + 12
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name & " [Constructor]"
						te->TypeName = te->Name
						te->ElementType = E_Constructor
						te->Locals = IIf(StartsWith(bTrimLCase, "private "), 1, 0)
						te->StartLine = i
						te->Parameters = te->Name & IIf(Pos3 > 0, Mid(bTrim, Pos3), "()")
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
						LastIndexFunction = Functions.Add(te->Name, te)
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "destructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private destructor ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public destructor ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " destructor ") + 11
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5), Any !"\t "))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
						If Pos3 = 0 Then
							te->Name = Trim(Mid(bTrim, Pos5))
						Else
							te->Name = Trim(Mid(bTrim, Pos5, Pos3 - Pos5))
						End If
						te->DisplayName = te->Name & " [Destructor]"
						te->TypeName = te->Name
						te->ElementType = E_Destructor
						te->Locals = IIf(StartsWith(bTrimLCase, "private "), 1, 0)
						te->StartLine = i
						te->Parameters = te->Name & IIf(Pos3 > 0, Mid(bTrim, Pos3), "()")
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
							If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & te->Name
						Else
							te->FullName = te->Name
						End If
						LastIndexFunction = Functions.Add(te->Name, te)
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "sub ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private sub ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public sub ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " sub ") + 4
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
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
							te->OwnerTypeName = bt
							te->Locals = 2
						Else
							bt = ""
							te->Locals = 0 'IIf(StartsWith(bTrimLCase, "private sub "), 1, 0)
						End If
						te->TypeName = ""
						te->ElementType = E_Sub
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If EndsWith(LCase(te->Parameters), " __export__") Then
							te->Parameters = Trim(Left(te->Parameters, Len(te->Parameters) - 11))
						End If
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							If bt = "" Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							End If
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & IIf(bt = "", "", bt & ".") & te->Name
						Else
							te->FullName = IIf(bt = "", "", bt & ".") & te->Name
						End If
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							'te->TypeProcedure = True
							'n = Types.IndexOf(bt)
							'If n > -1 Then
							'	Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							'ElseIf n = -1 Then
							'	If bt = "Object" Then
							'		n = Comps.IndexOf("My.Sys.Object")
							'	Else
							'		n = Comps.IndexOf(bt)
							'	End If
							'	If n > -1 AndAlso Comps.Object(n) <> 0 Then
							'		Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							'	Else
							'		'?bTrim
							'	End If
							'End If
							LastIndexFunction = TypeProcedures.Add(te->Name, te)
						Else
							'LastIndexFunction = Functions.Add(te->Name, te)
							LastIndexFunction = Functions.Add(te->Name, te)
						End If
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "function ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private function ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public function ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " function") + 9
						If StartsWith(Trim(Mid(bTrim, Pos5)), "=") Then Continue For
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
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
							te->OwnerTypeName = bt
							te->Locals = 2
						Else
							bt = ""
							te->Locals = 0 'IIf(StartsWith(bTrimLCase, "private function "), 1, 0)
						End If
						Pos4 = InStrRev(bTrim, ")")
						Pos3 = InStr(Pos4, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos4 + 1, bTrimLCase, " as ")
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						te->ElementType = E_Function
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If EndsWith(LCase(te->Parameters), " __export__") Then
							te->Parameters = Trim(Left(te->Parameters, Len(te->Parameters) - 11))
						End If
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							If bt = "" Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							End If
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & IIf(bt = "", "", bt & ".") & te->Name
						Else
							te->FullName = IIf(bt = "", "", bt & ".") & te->Name
						End If
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							'te->TypeProcedure = True
							'n = Types.IndexOf(bt)
							'If n > -1 Then
							'	Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							'ElseIf n = -1 Then
							'	If bt = "Object" Then
							'		n = Comps.IndexOf("My.Sys.Object")
							'	Else
							'		n = Comps.IndexOf(bt)
							'	End If
							'	If n > -1 AndAlso Comps.Object(n) <> 0 Then
							'		Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							'	Else
							'		'?bTrim
							'	End If
							'End If
							LastIndexFunction = TypeProcedures.Add(te->Name, te)
						Else
							'LastIndexFunction = Functions.Add(te->Name, te)
							LastIndexFunction = Functions.Add(te->Name, te)
						End If
						lastfunctionte = te
					ElseIf CInt(StartsWith(bTrimLCase, "property ")) OrElse _
						CInt(StartsWith(bTrimLCase, "private property ")) OrElse _
						CInt(StartsWith(bTrimLCase, "public property ")) Then
						InFunc = True
						Pos3 = InStr(bTrim, "(")
						Pos5 = InStr(bTrimLCase, " property") + 9
						n = Len(bTrim) - Len(Trim(Mid(bTrim, Pos5)))
						Pos4 = InStr(n + 1, bTrim, " ")
						If Pos4 > 0 AndAlso (Pos4 < Pos3 OrElse Pos3 = 0) Then Pos3 = Pos4
						te = _New( TypeElement)
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
							te->OwnerTypeName = bt
							te->Locals = 2
						Else
							bt = ""
							te->Locals = 0 'IIf(StartsWith(bTrimLCase, "private property "), 1, 0)
						End If
						Pos4 = InStr(bTrim, ")")
						Pos3 = InStr(Pos4, bTrimLCase, ")as ")
						If Pos3 = 0 Then Pos3 = InStr(Pos4 + 1, bTrimLCase, " as ")
						te->TypeName = Trim(Mid(bTrim, Pos3 + 4))
						te->TypeIsPointer = EndsWith(LCase(te->TypeName), " ptr") OrElse EndsWith(LCase(te->TypeName), " pointer")
						te->TypeName = WithoutPointers(te->TypeName)
						te->ElementType = E_Property
						te->StartLine = i
						te->Parameters = Trim(Mid(bTrim, Pos5))
						If Comment <> "" Then te->Comment = Comment: Comment = ""
						te->FileName = PathFunction
						te->CtlLibrary = CtlLibrary
						If Namespaces.Count > 0 Then
							If bt = "" Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
							End If
							For n_i As Integer = 0 To Namespaces.Count - 1
								te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
							Next
							te->FullName = te->OwnerNamespace & "." & IIf(bt = "", "", bt & ".") & te->Name
						Else
							te->FullName = IIf(bt = "", "", bt & ".") & te->Name
						End If
						If bt <> "" Then
							te->Parameters = Trim(Mid(te->Parameters, Len(bt) + 2))
							'te->TypeProcedure = True
							'n = Types.IndexOf(bt)
							'If n > -1 Then Cast(TypeElement Ptr, Types.Object(n))->Elements.Add te->Name, te
							'If n = -1 Then
							'	n = Comps.IndexOf(bt)
							'	If n > -1 AndAlso Comps.Object(n) <> 0 Then Cast(TypeElement Ptr, Comps.Object(n))->Elements.Add te->Name, te
							'End If
							'Else
							'	LastIndexFunction = Functions.Add(te->Name, te)
						End If
						LastIndexFunction = TypeProcedures.Add(te->Name, te)
						lastfunctionte = te
					ElseIf (CInt(Not inType) AndAlso CInt(Not inEnum) AndAlso CInt(Not InFunc) OrElse InStr(bTrimLCase, " shared ") > 0) AndAlso _
						CInt(CInt(StartsWith(bTrimLCase, "dim ")) OrElse _
						CInt(StartsWith(bTrimLCase, "common ")) OrElse _
						CInt(StartsWith(bTrimLCase, "static ")) OrElse _
						CInt(StartsWith(bTrimLCase, "const ")) OrElse _
						CInt(StartsWith(bTrimLCase, "redim ")) OrElse _
						CInt(StartsWith(bTrimLCase, "extern ")) OrElse _
						CInt(StartsWith(bTrimLCase, "var "))) Then
						Dim As WString * 2048 b2 = Trim(Mid(bTrim, InStr(bTrim, " ")))
						Dim As WString * 2048 CurType, ElementValue
						Dim As Integer ct
						Dim As WString Ptr res1(Any)
						Dim As Boolean bShared, bOldAs
						Pos1 = InStr(b2, "'")
						If Pos1 > 0 Then b2 = Trim(Left(b2, Pos1 - 1))
						If StartsWith(LCase(b2), "shared ") Then bShared = True: b2 = Trim(Mid(b2, 7))
						If StartsWith(LCase(b2), "import ") Then b2 = Trim(Mid(b2, 7))
						If StartsWith(LCase(b2), "as ") Then
							bOldAs = True
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
								If UBound(res1) > -1 Then
									CurType = Trim(..Left(CurType, Pos1 + Len(*res1(0))))
								End If
							End If
						Else
							Split GetChangedCommas(b2), ",", res1()
						End If
						For n As Integer = 0 To UBound(res1)
							*res1(n) = Trim(Replace(*res1(n), ";", ","))
							Pos1 = InStr(*res1(n), "=")
							If Pos1 > 0 Then
								ElementValue = Trim(Mid(*res1(n), Pos1 + 1))
								If CBool(n = 0) AndAlso bOldAs Then
									CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) + Pos1 - 2))
									CurType = Replace(CurType, "`", "=")
								End If
							Else
								ElementValue = ""
							End If
							If Pos1 > 0 Then *res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							Pos1 = InStr(LCase(*res1(n)), " as ")
							If Pos1 > 0 Then
								CurType = Trim(Mid(*res1(n), Pos1 + 4))
								CurType = Replace(CurType, "`", "=")
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(*res1(n), ":")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(..Left(*res1(n), Pos1 - 1))
							End If
							If StartsWith(LCase(*res1(n)), "byref") OrElse StartsWith(LCase(*res1(n)), "byval") Then
								ct += Len(*res1(n)) - Len(Trim(Mid(*res1(n), 6)))
								*res1(n) = Trim(Mid(*res1(n), 6))
							'Else
							'	Pos1 = InStrRev(*res1(n), " ") 'David Change,  a As WString*2
							'	*res1(n) = Trim(Mid(*res1(n), Pos1 + 1))
							End If
							Pos1 = InStr(*res1(n), "(")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							Pos1 = InStr(LCase(*res1(n)), " alias ")
							If Pos1 > 0 Then
								ct += Len(*res1(n)) - Pos1 + 1
								*res1(n) = Trim(Left(*res1(n), Pos1 - 1))
							End If
							ct += Len(*res1(n)) - Len(Trim(*res1(n)))
							*res1(n) = Trim(*res1(n))
							Pos1 = InStrRev(*res1(n), " ")
							If Pos1 > 0 Then
								*res1(n) = Trim(Mid(*res1(n), Pos1 + 1))
							End If
							If CBool(n = 0) AndAlso bOldAs Then
								CurType = Trim(..Left(CurType, Len(CurType) - Len(*res1(n)) - ct))
								CurType = Replace(CurType, "`", "=")
							End If
							If Not (StartsWith(LCase(CurType), "sub") OrElse StartsWith(LCase(CurType), "function")) Then
								Pos1 = InStrRev(CurType, ".")
								If Pos1 > 0 Then CurType = Mid(CurType, Pos1 + 1)
							End If
							Var te = _New( TypeElement)
							te->Name = *res1(n)
							te->DisplayName = te->Name
							If StartsWith(bTrimLCase, "common ") Then
								te->ElementType = E_CommonVariable
							ElseIf StartsWith(bTrimLCase, "const ") Then
								te->ElementType = E_Constant
							ElseIf bShared Then
								te->ElementType = E_SharedVariable
							Else
								te->ElementType = IIf(StartsWith(LCase(te->TypeName), "sub(") OrElse StartsWith(LCase(te->TypeName), "function("), E_Event, E_Property)
							End If
							te->TypeIsPointer = EndsWith(LCase(CurType), " pointer") OrElse EndsWith(LCase(CurType), " ptr")
							te->TypeName = CurType
							te->TypeName = WithoutPointers(te->TypeName)
							te->Value = ElementValue
							te->Locals = 0 'IIf(bShared, 0, 2)
							te->StartLine = i
							te->Parameters = *res1(n) & " As " & CurType
							te->FileName = PathFunction
							te->CtlLibrary = CtlLibrary
							If Comment <> "" Then te->Comment = Comment: Comment = ""
							Args.Add te->Name, te
							If Namespaces.Count > 0 Then
								Index = Globals.Namespaces.IndexOf(Cast(TypeElement Ptr, Namespaces.Object(Namespaces.Count - 1))->Name)
								If Index > -1 Then Cast(TypeElement Ptr, Globals.Namespaces.Object(Index))->Elements.Add te->Name, te
								For n_i As Integer = 0 To Namespaces.Count - 1
									te->OwnerNamespace &= IIf(n_i = 0, "", ".") & Namespaces.Item(n_i)
								Next
							End If
							Deallocate res1(n)
						Next
						Erase res1
					End If
				End If
			End If
			Deallocate res(j)
		Next
		Erase res
		If FormClosing Then MutexUnlock tlockSave: Exit Sub
	Next
	Lines.Clear
	MutexUnlock tlockSave 'If LoadParameter <> LoadParam.OnlyFilePathOverwrite Then
	If CInt(LoadParameter <> LoadParam.OnlyFilePath) AndAlso CInt(LoadParameter <> LoadParam.OnlyFilePathOverwrite) AndAlso CInt(LoadParameter <> LoadParam.OnlyFilePathOverwriteWithContent) Then
		For i As Integer = 0 To File->Includes.Count - 1
			LoadFunctions File->Includes.Item(i), , Types, Enums, Functions, TypeProcedures, Args
			If FormClosing Then Exit Sub
		Next
	End If
End Sub

tlock = MutexCreate()
tlockSave = MutexCreate()
tlockToDo = MutexCreate()
tlockGDB = MutexCreate()
tlockSuggestions = MutexCreate()

Sub StartOfLoadFunctions
	LoadFunctionsCount += 1
	MutexLock tlock
	If LoadFunctionsCount = 1 Then
		stBar.Panels[2]->Caption = ""
	End If
End Sub

Sub EndOfLoadFunctions
	LoadFunctionsCount -= 1
	If LoadFunctionsCount = 0 Then
		stBar.Panels[2]->Caption = ML("IntelliSense fully loaded")
		Dim As TabWindow Ptr tb
		For j As Integer = TabPanels.Count - 1 To 0 Step -1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = ptabCode->TabCount - 1 To 0 Step -1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If tb Then
					tb->txtCode.Content.ExternalIncludesLoaded = False
					'If AutoSuggestions Then
					'	#ifndef __USE_GTK__
					'		PostMessage tb->Handle, EM_SETMODIFY, 0, 0
					'	#endif
					'End If
				End If
			Next i
		Next j
	End If
	MutexUnlock tlock
End Sub

Sub LoadFunctionsSub(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		If Not IncludeFiles.Contains(QWString(Param)) Then LoadFunctions QWString(Param), FilePathAndIncludeFiles, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyFilePath(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		If Not IncludeFiles.Contains(QWString(Param)) Then LoadFunctions QWString(Param), LoadParam.OnlyFilePath, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyFilePathOverwrite(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		LoadFunctions QWString(Param), LoadParam.OnlyFilePathOverwrite, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyFilePathOverwriteWithContent(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		LoadFunctions Cast(EditControlContent Ptr, Param)->FileName, LoadParam.OnlyFilePathOverwriteWithContent, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , , Param
	End If
	EndOfLoadFunctions
End Sub

Sub LoadOnlyIncludeFiles(Param As Any Ptr)
	StartOfLoadFunctions
	If Not FormClosing Then
		LoadFunctions QWString(Param), LoadParam.OnlyIncludeFiles, Globals.Types, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args
	End If
	EndOfLoadFunctions
End Sub

Enum Paragraph
	parStart
	parSyntax
	parUsage
	parParameters
	parReturnValue
	parDescription
	parExample
	parDifferencesFromQB
	parSeeAlso
End Enum

Sub LoadHelp
	Dim As WStringOrStringList Ptr pFunctions = @Globals.Functions
	Dim As Boolean InEnglish
	Dim As Integer Fn = FreeFile_, tEncode
	If LCase(App.CurLanguage) = "english" OrElse Dir(ExePath & "/Settings/Others/KeywordsHelp." & App.CurLanguage & ".txt") = "" Then
		InEnglish = True
		WLet(KeywordsHelpPath, ExePath & "/Settings/Others/KeywordsHelp.txt")
	Else
		WLet(KeywordsHelpPath, ExePath & "/Settings/Others/KeywordsHelp." & App.CurLanguage & ".txt")
	End If
	Dim As Integer Result = -1
	Result = Open(*KeywordsHelpPath For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(*KeywordsHelpPath For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(*KeywordsHelpPath For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(*KeywordsHelpPath For Input As #Fn): tEncode= 1
	If Result = 0 Then
		#ifdef __FB_WIN32__
			If tEncode = 1 AndAlso Not InEnglish Then MsgBox ML("The file encoding is not UTF-8 (BOM). You should convert it to UTF-8 (BOM).") & Chr(13, 10) & *KeywordsHelpPath
		#endif
		Dim As TypeElement Ptr te, te1
		Dim As WString * 1024 Buff, StartBuff, bTrim
		Dim As Boolean bStart, bStartEnd, bDescriptionStart, bDescriptionEnd, bReturnValueStart, bOperator
		Dim As Paragraph Parag
		Dim As WString * 1024 MLSyntax = ML("Syntax"), MLUsage = ML("Usage"), MLParameters = ML("Parameters"), MLReturnValue = ML("Return Value"), MLDescription = ML("Description"), _
		MLExample = ML("Example"), MLDifferencesFromQB = ML("Differences from QB"), MLSeeAlso = ML("See also"), MLMoreDetails = ML("More details ..."), MLDot = ML(".")
		Dim As Integer Pos2, Pos1, LineNumber
		Do Until EOF(Fn)
			LineNumber += 1
			Line Input #Fn, Buff
			If Trim(Buff) = "" Then Continue Do
			If StartsWith(Buff, "---") Then
				If StartsWith(Buff, "------------ KeyWin32AbnormalTermination") Then
					pFunctions = @GlobalFunctionsHelp
				End If
				bStart = True : bDescriptionStart = False : bReturnValueStart = False
				Parag = parStart
			ElseIf Buff = "Syntax" OrElse Buff = MLSyntax Then
				Parag = parSyntax
			ElseIf Buff = "Usage" OrElse Buff = MLUsage Then
				Parag = parUsage
			ElseIf Buff = "Parameters" OrElse Buff = MLParameters Then
				Parag = parParameters
			ElseIf Buff = "Return Value" OrElse Buff = MLReturnValue Then
				Parag = parReturnValue: bReturnValueStart = True
			ElseIf Buff = "Description" OrElse Buff = MLDescription Then
				Parag = parDescription : bDescriptionStart = True
			ElseIf Buff = "Example" OrElse Buff = MLExample Then
				Parag = parExample
			ElseIf Buff = "Differences from QB" OrElse Buff = MLDifferencesFromQB Then
				Parag = parDifferencesFromQB
			ElseIf Buff = "See also" OrElse Buff = MLSeeAlso Then
				Parag = parSeeAlso
			Else
				If bStart Then
					If te <> 0 AndAlso bDescriptionEnd = False Then  ' the last one not add ending
						te->Comment &= " " & " <a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLMoreDetails & !"</a>\r"
						bDescriptionEnd = True
					End If
					bTrim = Trim(Buff)
					Pos2 = InStr(bTrim, "   ")  ' For good understanding, KeyWords + "   " + Local
					If Pos2 > 0 Then bTrim = Trim(Left(bTrim, Pos2))
					StartBuff = bTrim
					bOperator = False
					If StartsWith(bTrim, "Operator ") Then bOperator = True: bTrim = Trim(Mid(bTrim, 10))
					If StartsWith(bTrim, "Placement ") Then bTrim = Trim(Mid(bTrim, 11))
					Pos1 = InStr(bTrim, " ")
					If Pos1 > 0 Then bTrim = Left(bTrim, Pos1 - 1)
					Pos1 = InStr(bTrim, "...")
					If Pos1 > 0 Then bTrim = Left(bTrim, Pos1 - 1)
					Pos1 = InStr(bTrim, "(")
					If Pos1 = 1 Then bTrim = Mid(bTrim, Pos1 + 1) Else If Pos1 > 1 Then bTrim = Left(bTrim, Pos1 - 1)
					te = _New( TypeElement)
					te->Name = bTrim
					te->DisplayName = Trim(Buff)
					If bOperator Then
						te->ElementType = E_KeywordOperator
					Else
						te->ElementType = E_Keyword
					End If
					te->FileName = *KeywordsHelpPath
					pFunctions->Add te->Name, te
					bStartEnd = False
					bDescriptionEnd = False
					te->Comment = "<a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & IIf(Pos2 = 0, Trim(Buff), Left(Trim(Buff), Pos2)) & !"</a>\r   " & IIf(Pos2 = 0, "", LTrim(Mid(Trim(Buff), Pos2)))
					'DebugPrint  "te->Name " & te->Name, , False, False
					'Print te->Name
				ElseIf Parag = parStart Then
					If Buff <> "" AndAlso te <> 0 Then
						If te->Comment = "" Then
							te->Comment = Buff
						Else
							te->Comment &= " " & LTrim(Buff, !"\t")
						End If
						'DebugPrint  "te->Comment " & te->Comment, , False, False
					End If
				ElseIf Parag = parSyntax Then
					If Not bStartEnd Then
						If te <> 0 AndAlso Not EndsWith(te->Comment, ".") Then te->Comment &= "."
						bStartEnd = True
					End If
					If te <> 0 AndAlso Trim(Buff) <> "" Then
						If StartsWith(Trim(Buff), "Declare ") AndAlso te->Name <> "Declare" Then
							bTrim = LTrim(Mid(LTrim(Buff), 9))
							If StartsWith(bTrim, "Function ") Then
								Buff = LTrim(Mid(LTrim(bTrim), 10))
								te->ElementType = E_KeywordFunction
							ElseIf StartsWith(bTrim, "Sub ") Then
								Buff = LTrim(Mid(LTrim(bTrim), 5))
								te->ElementType = E_KeywordSub
							ElseIf StartsWith(bTrim, "Operator ") Then
								Buff = LTrim(Mid(LTrim(bTrim), 10))
								te->ElementType = E_KeywordOperator
							End If
						End If
						If te->Parameters = "" Then
							te->Parameters = Buff
						ElseIf EndsWith(te->Parameters, " ") Then
							te->Parameters &= LTrim(Buff)
						Else
							te->Parameters &= !"\r" & Buff
						End If
					End If
				ElseIf Parag = parUsage Then
					'If Buff <> "" AndAlso te <> 0 Then te->Comment &= !"\r" & Trim(Buff)
				ElseIf Parag = parParameters Then
					'If Buff <> "" AndAlso te <> 0 Then te->Comment &= !"\r" & Trim(Buff)
				ElseIf Parag = parReturnValue Then
					If Buff <> "" AndAlso te <> 0 Then
						If bReturnValueStart Then
							te->Comment &= !"\r" & MLReturnValue & !"\r   " & Buff '"<a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLReturnValue & !"</a>\r " & Trim(Buff)
						Else
							te->Comment &= !"\r" & Trim(Buff)
							bReturnValueStart = False
						End If
					End If
				ElseIf Parag = parDescription Then
					If Not bDescriptionEnd Then
						Pos1 = InStr(Buff, MLDot) 'you must add "." to your language file for good local showing
						If Pos1 = InStr(Buff, "...") Then Pos1 = InStr(Pos1 + 3, Buff, MLDot)
						'If Pos1 < 100 Then Pos1 = 100
						If Pos1 > 0 Then
							Buff = Left(Buff, Pos1) & " <a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLMoreDetails & !"</a>\r"
							bDescriptionEnd = True
						End If
						If Buff <> "" AndAlso te <> 0 Then
							If bDescriptionStart Then
								te->Comment &= !"\r" & MLDescription & !"\r   " & Buff '!"\r<a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLDescription & !"</a>\r " & Trim(Buff)
							Else
								te->Comment &= " " & Trim(Buff)
							End If
						End If
						bDescriptionStart = False
					End If
				ElseIf Parag = parExample Then
					
				ElseIf Parag = parDifferencesFromQB Then
					
				ElseIf Parag = parSeeAlso Then
					If te <> 0 AndAlso EndsWith(te->Parameters, !"\r") Then te->Parameters = Left(te->Parameters, Len(te->Parameters) - 1)
					If bDescriptionEnd = False Then
						te->Comment &= " <a href=""" & *KeywordsHelpPath & "~" & Str(LineNumber) & "~" & MLMoreDetails & "~" & StartBuff & """>" & MLMoreDetails & !"</a>\r"
						bDescriptionEnd = True
					End If
					If te->Name = "Print" Then
						te1 = _New( TypeElement)
						te1->Name = "?"
						te1->DisplayName = te->DisplayName
						te1->ElementType = te->ElementType
						te1->FileName = te->FileName
						te1->Parameters = te->Parameters
						te1->Comment = te->Comment
						pFunctions->Add te1->Name, te1
					End If
				End If
				bStart = False
			End If
		Loop
	End If
	CloseFile_(Fn)
	pFunctions = @GlobalAsmFunctionsHelp
	InEnglish = False
	Fn = FreeFile_
	If LCase(App.CurLanguage) = "english" OrElse Dir(ExePath & "/Settings/Others/AsmKeywordsHelp." & App.CurLanguage & ".txt") = "" Then
		InEnglish = True
		WLet(AsmKeywordsHelpPath, ExePath & "/Settings/Others/AsmKeywordsHelp.txt")
	Else
		WLet(AsmKeywordsHelpPath, ExePath & "/Settings/Others/AsmKeywordsHelp." & App.CurLanguage & ".txt")
	End If
	Result = -1
	Result = Open(*AsmKeywordsHelpPath For Input Encoding "utf-8" As #Fn)
	If Result <> 0 Then Result = Open(*AsmKeywordsHelpPath For Input Encoding "utf-16" As #Fn)
	If Result <> 0 Then Result = Open(*AsmKeywordsHelpPath For Input Encoding "utf-32" As #Fn)
	If Result <> 0 Then Result = Open(*AsmKeywordsHelpPath For Input As #Fn): tEncode= 1
	If Result = 0 Then
		#ifdef __FB_WIN32__
			If tEncode = 1 AndAlso Not InEnglish Then MsgBox ML("The file encoding is not UTF-8 (BOM). You should convert it to UTF-8 (BOM).") & Chr(13, 10) & *AsmKeywordsHelpPath
		#endif
		Dim As TypeElement Ptr te, te1
		Dim As WString * 1024 Buff, StartBuff, bTrim
		Dim As Boolean bAsmCommand, bExampleStarted
		Dim As Paragraph Parag
		Dim As List Commands
		Dim As WString * 1024 MLSyntax = ML("Syntax"), MLExample = ML("Example"), MLMoreDetails = ML("More details ..."), MLDot = ML(".")
		Dim As Integer Pos1, Pos2, LineNumber
		Do Until EOF(Fn)
			LineNumber += 1
			Line Input #Fn, Buff
			If Trim(Buff) = "" Then Continue Do
			Dim As UString res(Any)
			Pos1 = InStr(Buff, " — ")
			bAsmCommand = False
			If Pos1 > 0 Then
				bAsmCommand = True
				Split(Left(Buff, Pos1 - 1), ", ", res())
				For i As Integer = 0 To UBound(res)
					If InStr(Trim(res(i)), " ") Then bAsmCommand = False: Exit For
				Next
			End If
			If bAsmCommand Then
				Parag = parStart
				Commands.Clear
				For i As Integer = 0 To UBound(res)
					te = _New( TypeElement)
					te->Name = Trim(res(i))
					te->DisplayName = Trim(res(i))
					te->ElementType = E_Keyword
					te->FileName = *AsmKeywordsHelpPath
					te->Comment = "<a href=""" & *AsmKeywordsHelpPath & "~" & Str(LineNumber - 1) & "~" & te->Name & "~" & te->Name & """>" & te->Name & !"</a>\r   " & Mid(Buff, Pos1 + 3) & !"\r"
					pFunctions->Add te->Name, te
					Commands.Add te
				Next
			ElseIf Buff = "Syntax" OrElse Buff = MLSyntax Then
				Parag = parSyntax
			ElseIf Buff = "Example" OrElse Buff = "Examples" OrElse Buff = MLExample Then
				Parag = parExample
				bExampleStarted = True
			ElseIf Buff = "Arithmetic And Logic Instructions" Then
				
			Else
				If Parag = parStart Then
					For i As Integer = 0 To Commands.Count - 1
						te = Commands.Item(i)
						If te->Comment = "" Then
							te->Comment = Buff
						Else
							te->Comment &= "   " & LTrim(Buff, !"\t")
						End If
					Next i
				ElseIf Parag = parSyntax Then
					For i As Integer = 0 To Commands.Count - 1
						te = Commands.Item(i)
						If te->Parameters = "" Then
							te->Parameters = Buff
						ElseIf EndsWith(te->Parameters, " ") Then
							te->Parameters &= LTrim(Buff)
						Else
							te->Parameters &= !"\r" & Buff
						End If
					Next
				ElseIf Parag = parExample Then
					For i As Integer = 0 To Commands.Count - 1
						te = Commands.Item(i)
						If bExampleStarted Then
							te->Comment &= !"\r\r" & MLExample & !"\r   " & Buff
							bExampleStarted	= False
						Else
							te->Comment &= !"\r" & "   " & Trim(Buff)
						End If
					Next
				End If
			End If
		Loop
	End If
	CloseFile_(Fn)
End Sub

Sub LoadSnippets
	Dim As UString f
	f = Dir("./Settings/Snippets/*.ini")
	While f <> ""
		Dim As Integer i, Pos1, Pos2, Pos3
		Dim As Integer Fn = FreeFile_, Result
		Dim As WString * 2048 Buff, Parameters, NewParameters
		Dim As TypeElement Ptr te, teParam
		Dim As UString FileName = ExePath & "/Settings/Snippets/" & f
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				Pos1 = InStr(Buff, "=")
				If (Len(Trim(Buff, Any !"\t ")) > 0) AndAlso (Pos1 > 0) AndAlso Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then
					te = _New( TypeElement)
					te->Name = Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")
					te->DisplayName = te->Name
					te->ElementType = E_Snippet
					Parameters = Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					Parameters = Replace(Parameters, "\r", !"\r")
					Parameters = Replace(Parameters, "\t", !"\t")
					te->Comment = te->Name
					Snippets.Add te->Name, te
					Dim As Integer s = 1, idx, j, k
					Dim As String ch, Number
					Pos1 = InStr(Parameters, "$")
					NewParameters = ""
					Do While Pos1 > 0
						NewParameters &= Mid(Parameters, s, Pos1 - s)
						Number = ""
						teParam = _New(TypeElement)
						teParam->ElementType = E_Snippet
						For i As Integer = Pos1 + 1 To Len(Parameters) + 1
							ch = Chr(Parameters[i - 1])
							If ch = "{" Then
								Pos2 = InStr(i + 1, Parameters, ":")
								Pos3 = InStr(i + 1, Parameters, "}")
								Number = Mid(Parameters, i + 1, Pos2 - (i + 1))
								teParam->DisplayName = Mid(Parameters, Pos2 + 1, Pos3 - Pos2 - 1)
								NewParameters &= teParam->DisplayName
								j = j + Len(Number) + 4
								s = Pos3 + 1
								Exit For
							ElseIf ch >= "0" AndAlso ch <= "9" Then
								Number &= ch
								j = j + 1
							Else
								If Number <> "" AndAlso te->Elements.Contains(Number, , , , idx) Then
									teParam->DisplayName = Cast(TypeElement Ptr, te->Elements.Object(idx))->DisplayName
									NewParameters &= teParam->DisplayName
									j = j - Len(Number) + 1
								Else
									j = j + 1
								End If
								If ch = !"\r" Then
									j = 0
									k = 0
								End If
								s = i
								Exit For
							End If
						Next
						Pos2 = InStrRev(Parameters, !"\r", Pos1)
						teParam->Name = Number
						teParam->StartLine = InStrCount(Left(Parameters, Pos1), !"\r")
						teParam->EndLine = teParam->StartLine
						teParam->StartChar = Pos1 - Pos2 - 1 - k
						teParam->EndChar = teParam->StartChar + Len(teParam->DisplayName)
						te->Elements.Add teParam->Name, teParam
						Pos1 = InStr(s, Parameters, "$")
						k = j
					Loop
					NewParameters &= Mid(Parameters, s)
					te->Parameters = NewParameters
					te->Elements.Sort
				End If
			Loop
			Snippets.Sort
		End If
		CloseFile_(Fn)
		f = Dir()
	Wend
End Sub

Function GetTypeLink(ByRef TypeName As String, ByVal bMarkDown As Boolean = False) As String
	'putFont As Function(ByVal pThis As Any Ptr,ByVal pVal As IFontDisp Ptr) As HRESULT
	Dim As String NewTypeName
	If bMarkDown Then
		If StartsWith(TypeName, "Const ") Then
			NewTypeName = Trim(Mid(TypeName, 7))
			Return "[`Const`](""https://www.freebasic.net/wiki/KeyPgConst"")" & IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "[`" & NewTypeName & "`]" & "(a href=""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """)", "[`" & NewTypeName & "`]")
		Else
			Dim As Integer posi = InStrRev(LCase(TypeName), " as ") + 4
			If posi < 5 Then posi = 1
			NewTypeName = Trim(Mid(TypeName, posi))
			Return IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "[`" & NewTypeName & "`](""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """)" , "[`" & NewTypeName & "`]")
		End If
	Else
		If StartsWith(TypeName, "Const ") Then
			NewTypeName = Trim(Mid(TypeName, 7))
			Return "<a href=""https://www.freebasic.net/wiki/KeyPgConst"">Const</a> " & IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "<a href=""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """>" & NewTypeName & "</a>", "[[" & NewTypeName & "]]")
		Else
			Dim As Integer posi = InStrRev(LCase(TypeName), " as ") + 4
			If posi < 5 Then posi = 1
			NewTypeName = Trim(Mid(TypeName, posi))
			Return IIf(pkeywords1 <> 0 AndAlso pkeywords1->Contains(NewTypeName), "<a href=""https://www.freebasic.net/wiki/KeyPg" & NewTypeName & """>" & NewTypeName & "</a>", "[[" & NewTypeName & "]]")
		End If
	End If
End Function

Sub LoadToolBox(ForLibrary As Library Ptr = 0)
	Dim As String f
	Dim As Integer i, j
	Dim As My.Sys.Drawing.Cursor cur
	Dim As String IncludePath
	Dim As UString MFF, Temp
	Dim As UInteger Attr
	Dim As Library Ptr MFFCtlLibrary
	#ifndef __USE_GTK__
		#ifdef __FB_64BIT__
			MFF = IIf(i = 0, "Controls\MyFbFramework\mff64.dll", "")
		#else
			MFF = IIf(i = 0, "Controls\MyFbFramework\mff32.dll", "")
		#endif
	#else
		#ifdef __USE_GTK3__
			#ifdef __FB_WIN32__
				#ifdef __FB_64BIT_
					MFF = IIf(i = 0, "Controls/MyFbFramework/mff64_gtk3.dll", "")
				#else
					MFF = IIf(i = 0, "Controls/MyFbFramework/mff32_gtk3.dll", "")
				#endif
			#else
				#ifdef __FB_64BIT__
					MFF = IIf(i = 0, "Controls/MyFbFramework/libmff64_gtk3.so", "")
				#else
					MFF = IIf(i = 0, "Controls/MyFbFramework/libmff32_gtk3.so", "")
				#endif
			#endif
		#else
			#ifdef __FB_WIN32__
				#ifdef __FB_64BIT_
					MFF = IIf(i = 0, "Controls/MyFbFramework/mff64_gtk2.dll", "")
				#else
					MFF = IIf(i = 0, "Controls/MyFbFramework/mff32_gtk2.dll", "")
				#endif
			#else
				#ifdef __FB_64BIT__
					MFF = IIf(i = 0, "Controls/MyFbFramework/libmff64_gtk2.so", "")
				#else
					MFF = IIf(i = 0, "Controls/MyFbFramework/libmff32_gtk2.so", "")
				#endif
			#endif
		#endif
	#endif
	If ForLibrary = 0 Then
		IncludeMFFPath = iniSettings.ReadBool("Options", "IncludeMFFPath", True)
		WLet(MFFPath, iniSettings.ReadString("Options", "MFFPath", "./Controls/MyFbFramework"))
		Do Until iniSettings.KeyExists("ControlLibraries", "Path_" & WStr(i)) = -1
			Dim As IniFile ini
			Temp = iniSettings.ReadString("ControlLibraries", "Path_" & WStr(i), MFF)
			ini.Load GetFolderName(GetRelativePath(Temp)) & "Settings.ini"
			Var CtlLibrary = _New(Library)
			CtlLibrary->Name = ini.ReadString("Setup", "Name")
			CtlLibrary->Tips = ini.ReadString("Setup", "Tips")
			CtlLibrary->Path = Temp
			CtlLibrary->HeadersFolder = ini.ReadString("Setup", "HeadersFolder")
			CtlLibrary->SourcesFolder = ini.ReadString("Setup", "SourcesFolder")
			CtlLibrary->IncludeFolder = GetFullPath(GetFullPath(ini.ReadString("Setup", "IncludeFolder"), Temp))
			CtlLibrary->Lib32Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "Lib32Folder"), Temp))
			CtlLibrary->Lib64Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "Lib64Folder"), Temp))
			CtlLibrary->Lib64ArmFolder = GetFullPath(GetFullPath(ini.ReadString("Setup", "Lib64ArmFolder"), Temp))
			CtlLibrary->LibX32Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "LibX32Folder"), Temp))
			CtlLibrary->LibX64Folder = GetFullPath(GetFullPath(ini.ReadString("Setup", "LibX64Folder"), Temp))
			CtlLibrary->Enabled = iniSettings.ReadBool("ControlLibraries", "Enabled_" & WStr(i), False)
			If Temp = MFF Then
				If CtlLibrary->HeadersFolder = "" Then CtlLibrary->HeadersFolder = "mff"
				If CtlLibrary->SourcesFolder = "" Then CtlLibrary->SourcesFolder = "mff"
				MFFCtlLibrary = CtlLibrary
			End If
			ControlLibraries.Add CtlLibrary
			i += 1
		Loop
	End If
	Dim As Library Ptr CtlLibrary
	For i = 0 To ControlLibraries.Count - 1
		CtlLibrary = ControlLibraries.Item(i)
		If ForLibrary <> 0 AndAlso CtlLibrary <> ForLibrary Then Continue For
		CtlLibrary->Handle = DyLibLoad(GetFullPath(CtlLibrary->Path))
		If Not FileExists(GetFullPath(CtlLibrary->Path)) Then
			MsgBox ML("File not found") & ": " & WChr(13, 10) & WChr(13, 10) & GetFullPath(CtlLibrary->Path) & WChr(13, 10) & WChr(13, 10) & ML("Can not load control to toolbox")
		ElseIf CtlLibrary->Handle = 0 Then
			MsgBox ML("File not loaded") & ": " & WChr(13, 10) & WChr(13, 10) & GetFullPath(CtlLibrary->Path) & WChr(13, 10) & WChr(13, 10) & ML("Can not load control to toolbox")
		End If
		If Not CtlLibrary->Enabled Then Continue For
		#ifdef __USE_GTK__
			gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), ToUtf8(GetFolderName(GetFullPath(CtlLibrary->Path)) & "/resources"))
			gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), ToUtf8(GetFolderName(GetFullPath(CtlLibrary->Path)) & "/Resources"))
		#endif
		IncludePath = GetFullPath(GetFullPath(CtlLibrary->HeadersFolder, CtlLibrary->Path))
		If Not EndsWith(IncludePath, Slash) Then IncludePath &= Slash
		f = Dir(IncludePath & "*.bi")
		While f <> ""
			LoadFunctions GetOSPath(IncludePath & f), LoadParam.OnlyFilePath, Comps, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , CtlLibrary
			f = Dir()
		Wend
		IncludePath = GetFullPath(GetFullPath(CtlLibrary->SourcesFolder, CtlLibrary->Path))
		If Not EndsWith(IncludePath, Slash) Then IncludePath &= Slash
		f = Dir(IncludePath & "*.bas")
		While f <> ""
			LoadFunctions GetOSPath(IncludePath & f), LoadParam.OnlyFilePath, Comps, Globals.Enums, Globals.Functions, Globals.TypeProcedures, Globals.Args, , CtlLibrary
			f = Dir()
		Wend
	Next i
	Comps.Sort
	Var iOld = -1, iNew = 0
	Dim As String it = "Cursor"
	Dim As String wikiFolder = ExePath & "/Controls/MyFbFramework/MyFbFramework.wiki/"
	Dim As String wikiTitle
	Dim As List ECLines, teList
	Dim As TypeElement Ptr tbi, tbi1, te, te1
	For i = 0 To Comps.Count - 1
		tbi = Cast(TypeElement Ptr, Comps.Object(i))
		If LCase(Comps.Item(i)) = "control" Or LCase(Comps.Item(i)) = "containercontrol" Or LCase(Comps.Item(i)) = "menu" Or LCase(Comps.Item(i)) = "component" Or LCase(Comps.Item(i)) = "dialog" Then Continue For
		If tbi->ElementType = E_TypeCopy Then Continue For
		If ForLibrary <> 0 AndAlso tbi->Tag <> ForLibrary Then Continue For
		iNew = GetTypeControl(Comps.Item(i))
		tbi->ControlType = iNew
		If iNew = 0 Then Continue For
		it = Comps.Item(i)
		#ifndef __USE_GTK__
			Dim As Any Ptr LibHandle
			LibHandle = Cast(Library Ptr, tbi->Tag)->Handle
			imgListTools.Add it, it, LibHandle
		#endif
		Var toolb = tbToolBox.Groups.Item(iNew - 1)->Buttons.Add(tbsCheckGroup, it, , @ToolBoxClick, it, it, it, True, Cast(ToolButtonState, tstEnabled Or tstWrap))
		toolb->Tag = Comps.Object(i)
		iOld = iNew
	Next i
	' HTML STYLE
	#if 0
		If Dir(wikiFolder) = "" Then MkDir wikiFolder
		Dim As String ControlParent, TmpControlName, TmpControlChildName, TmpControlSubName
		Dim As String ControlTypArr(0 To 4) = {"type", "Control", "Container Control", "component", "Dialog"}
		Dim As Integer Posi
		Dim As Dictionary ControlParentDict
		If Dir(ExePath & "/Controls/MyFbFramework/ControlParent.csv") <> "" Then
			ControlParentDict.LoadFromFile(ExePath & "/Controls/MyFbFramework/ControlParent.csv")
		Else
			ControlParentDict.Add "NULL", "NULL"
		End If
		
		For i = 0 To Comps.Count - 1
			tbi = Cast(TypeElement Ptr, Comps.Object(i))
			If tbi = 0 OrElse tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			Dim As Integer Fn = FreeFile_
			Open wikiFolder & Comps.Item(i) & ".mediawiki" For Output As #Fn
			Print #Fn, "== Definition =="
			If Trim(tbi->OwnerNamespace) <> "" Then Print #Fn, "Namespace: [[" & tbi->OwnerNamespace & "]]"
			If tbi->ControlType = 0 Then
				Posi = ControlParentDict.IndexOfKey(Comps.Item(i))
				If Posi <> -1 Then TmpControlName = ControlParentDict.Item(Posi)->Text Else TmpControlName= ""
				Print #Fn,  "```" & Comps.Item(i) & "``` is a type or collection of the " & TmpControlName & " control, part of the freeBasic framework MyFbFramework."
			Else
				TmpControlName = Comps.Item(i)
				Print #Fn,  "```" & Comps.Item(i) & "``` is a " & ControlTypArr(tbi->ControlType) & " within the MyFbFramework."
				Print #Fn, "The " & TmpControlName & " control structure is highly analogous to the VB6, vb.net " & TmpControlName & " control, with similar components, properties, and behaviors but uses the syntax and conventions defined by the MyFbFramework."
			End If
			
			Print #Fn, ""
			Print #Fn, "'''" & Comps.Item(i) & "''' - " & tbi->Comment
			Print #Fn, ""
			Print #Fn, "== Properties =="
			Print #Fn, "<table>"
			Print #Fn, "<thead>"
			Print #Fn, "<tr class=""header"">"
			Print #Fn, "<th>Name</th>"
			Print #Fn, "<th>Description</th>"
			Print #Fn, "</tr>"
			Print #Fn, "</thead>"
			Print #Fn, "<tbody>"
			FPropertyItems.Clear
			TabWindow.FillProperties Comps.Item(i)
			FPropertyItems.Sort
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Field AndAlso te->ElementType <> ElementTypes.E_Property Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				Print #Fn, "<tr class=""property"">"
				Print #Fn, "<td><a href=""" & wikiTitle & """>" & FPropertyItems.Item(j) & "</a></td>"
				'Print #Fn, "<td>[[" & wikiTitle & "|" & FPropertyItems.Item(j) & "]]</td>"
				Print #Fn, "<td>" & te->Comment & "</td>"
				Print #Fn, "</tr>"
				Dim As Integer Fn1 = FreeFile_
				Open wikiFolder & wikiTitle & ".mediawiki" For Output As #Fn1
				Print #Fn1, "<h2>" & wikiTitle & " Property" & "</h2>"
				Print #Fn1, te->Comment
				If tbi->OwnerNamespace <> "" Then
					Print #Fn1, "<h2>Definition</h2>"
					Print #Fn1, "Namespace: [[" & tbi->OwnerNamespace & "]]"
				End If
				Posi = InStr(wikiTitle, ".")
				If Posi > 0 Then
					TmpControlChildName = Left(wikiTitle, Posi - 1)
					TmpControlSubName = Mid(wikiTitle, Posi + 1)
				Else
					TmpControlChildName = ""
					TmpControlSubName = wikiTitle
				End If
				
				If Posi > 0 Then
					If TmpControlName <> "" AndAlso TmpControlName <> TmpControlChildName Then
						Print #Fn1,  "```" & TmpControlSubName & "``` is property of the " & TmpControlChildName & " within the " & TmpControlName & " control, part of the freeBasic framework MyFbFramework."
					Else
						Print #Fn1,  "```" & TmpControlSubName & "``` is property of the "  & TmpControlChildName & " control, part of the freeBasic framework MyFbFramework."
					End If
				End If
				
				Print #Fn1, "<h2>Syntax</h2>"
				Print #Fn1, "```fb"
				Print #Fn1, te->Parameters
				Print #Fn1, "```"
				Print #Fn1, "<h2>Property Value</h2>"
				Print #Fn1, GetTypeLink(te->TypeName)
				Print #Fn1, "<h2>See also</h2>"
				Print #Fn1, "* [[" & Left(te->DisplayName, InStr(te->DisplayName, ".") - 1) & "]]"
				If Trim(TmpControlChildName) <> "" Then Print #Fn1, "`" & TmpControlChildName & "`[[" & TmpControlChildName & ".mediawiki]]"
				If TmpControlName <> "" AndAlso TmpControlName <> TmpControlChildName Then Print #Fn1, "[`" & TmpControlName & "`](" & TmpControlName & ".mediawiki)"
				CloseFile_(Fn1)
			Next
			Print #Fn, "</tbody>"
			Print #Fn, "</table>"
			Print #Fn, "== Methods =="
			Print #Fn, "<table>"
			Print #Fn, "<thead>"
			Print #Fn, "<tr class=""header"">"
			Print #Fn, "<th>Name</th>"
			Print #Fn, "<th>Description</th>"
			Print #Fn, "</tr>"
			Print #Fn, "</thead>"
			Print #Fn, "<tbody>"
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Function AndAlso te->ElementType <> ElementTypes.E_Sub AndAlso te->ElementType <> ElementTypes.E_Define AndAlso te->ElementType <> ElementTypes.E_Macro Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				Print #Fn, "<tr class=""method"">"
				Print #Fn, "<td><a href=""" & wikiTitle & """>" & FPropertyItems.Item(j) & "</a></td>"
				'Print #Fn, "<td>[[" & wikiTitle & "|" & FPropertyItems.Item(j) & "]]</td>"
				Print #Fn, "<td>" & te->Comment & "</td>"
				Print #Fn, "</tr>"
				If Not teList.Contains(te) Then
					teList.Add te
					Dim As Integer Fn1 = FreeFile_
					Open wikiFolder & wikiTitle & ".mediawiki" For Output As #Fn1
					Print #Fn1, "<h2>" & wikiTitle & " Method" & "</h2>"
					Print #Fn1, te->Comment
					If tbi->OwnerNamespace <> "" Then
						Print #Fn1, "<h2>Definition</h2>"
						Print #Fn1, "Namespace: [[" & tbi->OwnerNamespace & "]]"
					End If
					Posi = InStr(wikiTitle, ".")
					If Posi > 0 Then
						TmpControlChildName = Left(wikiTitle, Posi - 1)
						TmpControlSubName = Mid(wikiTitle, Posi + 1)
					Else
						TmpControlChildName = ""
						TmpControlSubName = wikiTitle
					End If
					If Posi > 0 Then
						If TmpControlName <> "" AndAlso TmpControlName <> TmpControlChildName Then
							Print #Fn1,  "```" & TmpControlSubName & "``` is method of the " & TmpControlChildName & " within the " & TmpControlName & " control, part of the freeBasic framework MyFbFramework."
						Else
							Print #Fn1,  "```" & TmpControlSubName & "``` is method of the " & TmpControlChildName & " control, part of the freeBasic framework MyFbFramework."
						End If
					End If
					
					Print #Fn1, "<h2>Syntax</h2>"
					Print #Fn1, "```fb"
					Print #Fn1, IIf(te->ElementType = ElementTypes.E_Function, "Declare Function", "Declare Sub") & " " & te->Parameters
					Print #Fn1, "```"
					Print #Fn1, ""
					Pos1 = InStr(te->Parameters, "(")
					If Pos1 > 0 Then
						SplitParameters te->Parameters, Pos1, Mid(te->Parameters, Pos1 + 1, Len(te->Parameters) - Pos1 - 1), te->FileName, te, te->StartLine, 0, ECLines, te->InCondition, te->Declaration, False
						Print #Fn1, "<h2>Parameters</h2>"
						Print #Fn1, "{|"
						Print #Fn1, "|'''Part'''||'''Type'''||'''Description'''"
						For k As Integer = 0 To te->Elements.Count - 1
							If Trim(te->Elements.Item(k)) = "" Then Continue For
							te1 = te->Elements.Object(k)
							Print #Fn1, "|-"
							Print #Fn1, "|<code>" & te->Elements.Item(k) & "</code>||" & GetTypeLink(te1->TypeName) & "||" & te1->Comment
						Next
						Print #Fn1, "|}"
					End If
					If te->ElementType = ElementTypes.E_Function Then
						Print #Fn1, ""
						Print #Fn1, "<h2>Return Value</h2>"
						Print #Fn1, GetTypeLink(te->TypeName)
					End If
					Print #Fn1, "<h2>See also</h2>"
					Print #Fn1, "* [[" & Left(te->DisplayName, InStr(te->DisplayName, ".") - 1) & "]]"
					If TmpControlName <> "" AndAlso TmpControlName <> TmpControlChildName Then Print #Fn1, "[`" & TmpControlName & "`](" & TmpControlName & ".mediawiki)"
					CloseFile_(Fn1)
				End If
			Next
			Print #Fn, "</tbody>"
			Print #Fn, "</table>"
			Print #Fn, "== Events =="
			If FPropertyItems.Count > 0 Then
				Print #Fn, "<table>"
				Print #Fn, "<thead>"
				Print #Fn, "<tr class=""header"">"
				Print #Fn, "<th>Name</th>"
				Print #Fn, "<th>Description</th>"
				Print #Fn, "</tr>"
				Print #Fn, "</thead>"
				Print #Fn, "<tbody>"
				For j As Integer = 0 To FPropertyItems.Count - 1
					te = FPropertyItems.Object(j)
					If te = 0 OrElse te->ElementType <> ElementTypes.E_Event Then Continue For
					Var Pos1 = InStr(te->DisplayName, "[")
					If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
					Print #Fn, "<tr class=""event"">"
					Print #Fn, "<td><a href=""" & wikiTitle & """>" & FPropertyItems.Item(j) & "</a></td>"
					'Print #Fn, "<td>[[" & wikiTitle & "|" & FPropertyItems.Item(j) & "]]</td>"
					Print #Fn, "<td>" & te->Comment & "</td>"
					Print #Fn, "</tr>"
					If Not teList.Contains(te) Then
						teList.Add te
						Dim As Integer Fn1 = FreeFile_
						Open wikiFolder & wikiTitle & ".mediawiki" For Output As #Fn1
						Print #Fn1, "<h2>" & wikiTitle & " Event" & "</h2>"
						Print #Fn1, te->Comment
						If tbi->OwnerNamespace <> "" Then
							Print #Fn1, "<h2>Definition</h2>"
							Print #Fn1, "Namespace: [[" & tbi->OwnerNamespace & "]]"
						End If
						Posi = InStr(wikiTitle, ".")
						If Posi > 0 Then
							TmpControlChildName = Left(wikiTitle, Posi - 1)
							TmpControlSubName = Mid(wikiTitle, Posi + 1)
						Else
							TmpControlChildName = ""
							TmpControlSubName = wikiTitle
						End If
						If Posi > 0 Then
							If TmpControlName <> "" AndAlso TmpControlName <> TmpControlChildName Then
								Print #Fn1,  "``" & TmpControlSubName & "``` is event of the " & TmpControlChildName & " within the " & TmpControlName & " control, part of the freeBasic framework MyFbFramework."
							Else
								Print #Fn1,  "```" & TmpControlSubName & "``` is event of the "  & TmpControlChildName & " control, part of the freeBasic framework MyFbFramework."
							End If
						End If
						
						Print #Fn1, "<h2>Syntax</h2>"
						Print #Fn1, "```fb"
						Print #Fn1, te->Parameters
						Print #Fn1, "```"
						Print #Fn1, ""
						Pos1 = InStr(te->Parameters, "(")
						If Pos1 > 0 Then
							SplitParameters te->Parameters, Pos1, Mid(te->Parameters, Pos1 + 1, Len(te->Parameters) - Pos1 - 1), te->FileName, te, te->StartLine, 0, ECLines, te->InCondition, te->Declaration, False
							Print #Fn1, "<h2>Parameters</h2>"
							Print #Fn1, "{|"
							Print #Fn1, "|'''Part'''||'''Type'''||'''Description'''"
							For k As Integer = 0 To te->Elements.Count - 1
								If Trim(te->Elements.Item(k)) = "" Then Continue For
								te1 = te->Elements.Object(k)
								Print #Fn1, "|-"
								Print #Fn1, "|<code>" & te->Elements.Item(k) & "</code>||" & GetTypeLink(te1->TypeName) & "||" & IIf(te1->Name = "Designer", "The designer of the object that received the signal. When an object is created without a designer, the designer will be empty. This can be checked with the command: <code>Designer.IsEmpty()</code>", IIf(te1->Name = "Sender", "The object which received the signal", te1->Comment))
							Next
							Print #Fn1, "|}"
						End If
						If StartsWith(LCase(te->TypeName), "function(") Then
							Print #Fn1, ""
							Print #Fn1, "<h2>Return Value</h2>"
							Print #Fn1, GetTypeLink(te->TypeName)
						End If
						Print #Fn1, ""
						Print #Fn1, "<h2>See also</h2>"
						Print #Fn1, "* [[" & Left(te->DisplayName, InStr(te->DisplayName, ".") - 1) & "]]"
						If TmpControlName <> "" AndAlso TmpControlName <> TmpControlChildName Then Print #Fn1, "[`" & TmpControlName & "`](" & TmpControlName & ".md)"
						CloseFile_(Fn1)
					End If
				Next
			Else
				Print #Fn, "(No events defined for this component)"
			End If
			Print #Fn, "</tbody>"
			Print #Fn, "</table>"
			If tbi->OwnerNamespace <> "" Then
				Print #Fn, "<h2>See also</h2>"
				Print #Fn, "* [[" & tbi->OwnerNamespace & "]]"
			End If
			CloseFile_(Fn)
		Next i
		For i = 0 To Globals.Enums.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Enums.Object(i))
			If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			Dim As Integer Fn = FreeFile_
			Open wikiFolder & Globals.Enums.Item(i) & ".mediawiki" For Output As #Fn
			Print #Fn, "<h2>" & Globals.Enums.Item(i) & " Enum</h2>"
			Print #Fn,  "`" & Globals.Enums.Item(i) & "` is a global enum within the MyFbFramework."
			Print #Fn, tbi->Comment
			If tbi->OwnerNamespace <> "" Then
				Print #Fn, "<h2>Definition</h2>"
				If Trim(tbi->OwnerNamespace) <> "" Then Print #Fn, "Namespace: [[" & tbi->OwnerNamespace & "]]"
			End If
			Print #Fn, "<h2>Fields</h2>"
			Print #Fn, "<table>"
			Print #Fn, "<tbody>"
			For j As Integer = 0 To tbi->Elements.Count - 1
				te = tbi->Elements.Object(j)
				Print #Fn, "<tr class=""property"">"
				Print #Fn, "<td>" & tbi->Elements.Item(j) & "</td>"
				Print #Fn, "<td>" & te->Value & "</td>"
				Print #Fn, "<td>" & te->Comment & "</td>"
				Print #Fn, "</tr>"
			Next
			Print #Fn, "</tbody>"
			Print #Fn, "</table>"
			If tbi->OwnerNamespace <> "" Then
				Print #Fn, "<h2>See also</h2>"
				Print #Fn, "* [[" & tbi->OwnerNamespace & "]]"
			End If
			CloseFile_(Fn)
		Next i
		For i = 0 To Globals.Namespaces.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Namespaces.Object(i))
			If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			If Not teList.Contains(tbi) Then
				teList.Add tbi
				Dim As Boolean bNamespaces, bTypes, bEnums, bDefines, bMacros, bMethods, bConstants, bVariables
				For ii As Integer = 0 To Globals.Namespaces.Count - 1
					tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
					If tbi1->CtlLibrary <> MFFCtlLibrary Then Continue For
					If tbi1->Name <> tbi->Name Then Continue For
					For j As Integer = 0 To tbi1->Elements.Count - 1
						te = tbi1->Elements.Object(j)
						Select Case te->ElementType
						Case E_Namespace: bNamespaces = True
						Case E_Type, E_TypeCopy, E_Class, E_Union: bTypes = True
						Case E_Enum: bEnums = True
						Case E_Define: bDefines = True
						Case E_Macro: bMacros = True
						Case E_Function, E_Sub: bMethods = True
						Case E_Constant: bConstants = True
						Case E_CommonVariable, E_LocalVariable, E_ExternVariable, E_SharedVariable: bVariables = True
						End Select
					Next
				Next
				Dim As Integer Fn = FreeFile_
				Open wikiFolder & tbi->FullName & ".mediawiki" For Output As #Fn
				Print #Fn,  "`" & tbi->FullName & "` is a global namespaces within the MyFbFramework."
				Print #Fn, tbi->Comment
				Print #Fn, ""
				If bNamespaces Then
					Dim As WStringList Namespaces
					Print #Fn, "== Namespaces =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> E_Namespace Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							If Not Namespaces.Contains(te->Name) Then
								Namespaces.Add te->Name
								Print #Fn, "<tr class=""namespace"">"
								Print #Fn, "<td><a href=""" & te->FullName & """>" & te->Name & "</a></td>"
								Print #Fn, "<td>" & te->Comment & "</td>"
								Print #Fn, "</tr>"
							End If
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bTypes Then
					Print #Fn, "== Types =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> E_Type AndAlso te->ElementType <> E_TypeCopy AndAlso te->ElementType <> E_Union AndAlso te->ElementType <> E_Class Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							Print #Fn, "<tr class=""type"">"
							Print #Fn, "<td><a href=""" & te->Name & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bEnums Then
					Print #Fn, "== Enums =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> E_Enum Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							Print #Fn, "<tr class=""enum"">"
							Print #Fn, "<td><a href=""" & te->Name & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bDefines Then
					Print #Fn, "== Defines =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> E_Define AndAlso te->ElementType <> E_Macro Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							Print #Fn, "<tr class=""define"">"
							Print #Fn, "<td><a href=""" & te->FullName & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bMacros Then
					Print #Fn, "== Macros =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> E_Define AndAlso te->ElementType <> E_Macro Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							Print #Fn, "<tr class=""macro"">"
							Print #Fn, "<td><a href=""" & te->FullName & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bMethods Then
					Print #Fn, "== Methods =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> ElementTypes.E_Function AndAlso te->ElementType <> ElementTypes.E_Sub Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							If te->Declaration Then Continue For
							Print #Fn, "<tr class=""method"">"
							Print #Fn, "<td><a href=""" & te->FullName & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bConstants Then
					Print #Fn, "== Constants =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> ElementTypes.E_Constant Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							Print #Fn, "<tr class=""constant"">"
							Print #Fn, "<td><a href=""" & te->Name & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				If bVariables Then
					Print #Fn, "== Variables =="
					Print #Fn, "<table>"
					Print #Fn, "<tbody>"
					For ii As Integer = 0 To Globals.Namespaces.Count - 1
						tbi1 = Cast(TypeElement Ptr, Globals.Namespaces.Object(ii))
						If tbi1->Name <> tbi->Name Then Continue For
						For j As Integer = 0 To tbi1->Elements.Count - 1
							te = tbi1->Elements.Object(j)
							If te->ElementType <> ElementTypes.E_CommonVariable AndAlso te->ElementType <> ElementTypes.E_LocalVariable AndAlso te->ElementType <> ElementTypes.E_ExternVariable AndAlso te->ElementType <> ElementTypes.E_SharedVariable Then Continue For
							If te->CtlLibrary <> MFFCtlLibrary Then Continue For
							Print #Fn, "<tr class=""variable"">"
							Print #Fn, "<td><a href=""" & te->Name & """>" & te->Name & "</a></td>"
							Print #Fn, "<td>" & te->Comment & "</td>"
							Print #Fn, "</tr>"
						Next
					Next
					Print #Fn, "</tbody>"
					Print #Fn, "</table>"
					Print #Fn, ""
				End If
				CloseFile_(Fn)
			End If
		Next i
		For i = 0 To Globals.Functions.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Functions.Object(i))
			If tbi->ElementType <> ElementTypes.E_Define AndAlso tbi->ElementType <> ElementTypes.E_Macro AndAlso tbi->ElementType <> ElementTypes.E_Function AndAlso tbi->ElementType <> ElementTypes.E_Sub Then Continue For
			If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			If tbi->Declaration Then Continue For
			Dim As Integer Fn1 = FreeFile_
			Open wikiFolder & tbi->FullName & ".mediawiki" For Output As #Fn1
			Print #Fn1, "<h2>" & tbi->FullName & IIf(tbi->ElementType = ElementTypes.E_Function, " Function", IIf(tbi->ElementType = ElementTypes.E_Sub, " Method", IIf(tbi->ElementType = ElementTypes.E_Define, " Define", IIf(tbi->ElementType = ElementTypes.E_Macro, " Macro", "")))) & "</h2>"
			Dim As UString Lines()
			Split(tbi->Comment, Chr(13) & Chr(10), Lines())
			Dim iLine As Integer
			Do While iLine <= UBound(Lines) AndAlso Trim(Lines(iLine), Any !"\t ") <> "Parameters" AndAlso Trim(Lines(iLine), Any !"\t ") <> "Return Value" AndAlso Trim(Lines(iLine), Any !"\t ") <> "See also"
				Print #Fn1, LTrim(Lines(iLine), Any !"\t ")
				iLine += 1
			Loop
			'Print #Fn1, tbi->Comment
			If tbi->OwnerNamespace <> "" Then
				Print #Fn1, "<h2>Definition</h2>"
				Print #Fn1, "Namespace: [[" & tbi->OwnerNamespace & "]]"
			End If
			Print #Fn1, "`" & tbi->FullName & "` Is a global " & IIf(tbi->ElementType = ElementTypes.E_Function, "function", IIf(tbi->ElementType = ElementTypes.E_Sub, "sub", IIf(tbi->ElementType = ElementTypes.E_Define, "definition", IIf(tbi->ElementType = ElementTypes.E_Macro, "macro", "")))) & " within the MyFbFramework, part of the freeBasic framework."
			Print #Fn1, "<h2>Syntax</h2>"
			Print #Fn1, ""
			Print #Fn1, "```fb"
			Print #Fn1, IIf(tbi->ElementType = ElementTypes.E_Function, "Function", IIf(tbi->ElementType = ElementTypes.E_Sub, "Sub", IIf(tbi->ElementType = ElementTypes.E_Define, "#define", IIf(tbi->ElementType = ElementTypes.E_Macro, "#macro", "")))) & " " & tbi->Parameters
			Print #Fn1, "```"
			Print #Fn1, ""
			Var Pos1 = InStr(tbi->Parameters, "(")
			If Pos1 > 0 Then
				SplitParameters tbi->Parameters, Pos1, Mid(tbi->Parameters, Pos1 + 1, Len(tbi->Parameters) - Pos1 - 1), tbi->FileName, tbi, tbi->StartLine, 0, ECLines, tbi->InCondition, tbi->Declaration, False
				Print #Fn1, "<h2>Parameters</h2>"
				Print #Fn1, "{|"
				Print #Fn1, "|'''Part'''||'''Type'''||'''Description'''"
				For k As Integer = 0 To tbi->Elements.Count - 1
					te1 = tbi->Elements.Object(k)
					Dim As UString Comment = IIf(te1->Value = "", "Required. ", "Optional. ")
					Dim As Boolean bFinded
					For kk As Integer = iLine To UBound(Lines)
						If LCase(Trim(Lines(kk), Any !"\t ")) = LCase(tbi->Elements.Item(k)) Then
							bFinded = True
						ElseIf bFinded Then
							If Trim(Lines(kk), Any !"\t ") = "Return Value" OrElse Trim(Lines(kk), Any !"\t ") = "Remarks" OrElse Trim(Lines(kk), Any !"\t ") = "Example" OrElse Trim(Lines(kk), Any !"\t ") = "See also" OrElse (k < tbi->Elements.Count - 1 AndAlso LCase(Trim(Lines(kk), Any !"\t ")) = LCase(tbi->Elements.Item(k + 1))) Then
								iLine = kk
								Exit For
							Else
								Comment = Comment & IIf(Comment = "", "", !"\r") & Trim(Lines(kk), Any !"\t ")
							End If
						End If
					Next
					If Trim(tbi->Elements.Item(k)) = "" Then Continue For
					Print #Fn1, "|-"
					Print #Fn1, "|<code>" & tbi->Elements.Item(k) & "</code>||" & GetTypeLink(te1->TypeName) & "||" & te1->Comment & Comment
				Next
				Print #Fn1, "|}"
			End If
			If tbi->ElementType = ElementTypes.E_Function Then
				Print #Fn1, ""
				Print #Fn1, "<h2>Return Value</h2>"
				Print #Fn1, GetTypeLink(tbi->TypeName)
				Print #Fn1, ""
				Dim bFinded As Boolean
				For kk As Integer = iLine To UBound(Lines)
					If Trim(Lines(kk), Any !"\t ") = "Return Value" Then
						bFinded = True
					ElseIf bFinded Then
						If Trim(Lines(kk), Any !"\t ") = "Remarks" OrElse Trim(Lines(kk), Any !"\t ") = "Example" OrElse Trim(Lines(kk), Any !"\t ") = "See also" Then
							iLine = kk
							Exit For
						Else
							Print #Fn1, Trim(Lines(kk), Any !"\t ")
						End If
					End If
				Next
			End If
			Dim As Boolean bSeeAlso, bExample
			For kk As Integer = iLine To UBound(Lines)
				If LTrim(Lines(kk), Any !"\t ") = "Remarks" Then
					If bExample Then
						Print #Fn1, "```"
						bExample = False
					End If
					Print #Fn1, "<h2>" & LTrim(Lines(kk), Any !"\t ") & "</h2>"
				ElseIf LTrim(Lines(kk), Any !"\t ") = "Example" Then
					bExample = True
					Print #Fn1, "<h2>" & LTrim(Lines(kk), Any !"\t ") & "</h2>"
					Print #Fn1, "```fb"
				ElseIf LTrim(Lines(kk), Any !"\t ") = "See also" Then
					If bExample Then
						Print #Fn1, "```"
						bExample = False
					End If
					bSeeAlso = True
					Print #Fn1, "<h2>" & LTrim(Lines(kk), Any !"\t ") & "</h2>"
				ElseIf bSeeAlso Then
					If Trim(Lines(kk), Any !"\t ") = "" Then Continue For
					Print #Fn1, "* [[" & LTrim(Lines(kk), Any !"\t ") & "]]"
				ElseIf bExample Then
					Print #Fn1, Lines(kk)
				Else
					Print #Fn1, LTrim(Lines(kk), Any !"\t ")
				End If
			Next
			If tbi->OwnerNamespace <> "" AndAlso Not bSeeAlso Then
				Print #Fn1, "<h2>See also</h2>"
				Print #Fn1, "* [[" & te->OwnerNamespace & "]]"
			End If
			CloseFile_(Fn1)
		Next i
		For i = 0 To Globals.Args.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Args.Object(i))
			If tbi->Name <> "App" AndAlso tbi->Name <> "Clipboard" AndAlso tbi->Name <> "DebugWindowHandle" AndAlso tbi->Name <> "DefaultFont" Then Continue For
			If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			Dim As Integer Fn = FreeFile_
			Open wikiFolder & tbi->Name & ".mediawiki" For Output As #Fn
			Print #Fn, "== Definition =="
			If Trim(tbi->OwnerNamespace) <> "" Then Print #Fn, "Namespace: " & tbi->OwnerNamespace
			Print #Fn,  "`" & tbi->Name & "` is a global variable in MyFbFramework, part of the freeBasic framework."
			Print #Fn, ""
			Print #Fn, "'''" & tbi->Name & "''' - " & tbi->Comment
			Print #Fn, ""
			Print #Fn, "<pre>"
			Print #Fn, tbi->Parameters
			Print #Fn, "</pre>"
			Print #Fn, ""
			Print #Fn, "== Property Value =="
			Print #Fn, GetTypeLink(tbi->TypeName)
			CloseFile_(Fn)
		Next i
	#endif
	' Markdown STYLE
	'This is a component of the MyFbFramework, which is part of the freeBasic framework and belongs to the container control.
	
	'This is part of the freeBasic framework MyFbFramework. It belongs to the container control.
	'This is part of the properties of the grid control. It belongs to the .
	
	'The Grid control is similar in functionality to the DataGridView in VB.Net but uses the syntax and conventions defined by the MyFbFramework.
	#if 1
		If Dir(wikiFolder) = "" Then MkDir wikiFolder
		Dim As String ControlParent, TmpControlName, TmpControlChildName, TmpControlSubName, StringToC, tmpDefinition
		Dim As String ControlTypArr(0 To 4) = {"type", "Control", "Container Control", "component", "Dialog"}
		Dim As Integer Posi
		Dim As Boolean bNotEmpty
		Dim As Dictionary ControlParentDict
		Dim As WString Ptr FileContentPtr, FileContentPtr1, FileContentEmpty
		Dim As FileEncodings FileEncoding = FileEncodings.Utf8
		Dim As NewLineTypes NewLineType, NewLineType1
		If Dir(ExePath & "/Controls/MyFbFramework/ControlParent.csv") <> "" Then
			ControlParentDict.LoadFromFile(ExePath & "/Controls/MyFbFramework/ControlParent.csv")
		Else
			ControlParentDict.Add "NULL", "NULL"
		End If
		For i = 0 To Comps.Count - 1
			tbi = Cast(TypeElement Ptr, Comps.Object(i))
			If tbi = 0 OrElse tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			If tbi->ControlType = 0 Then
				Posi = ControlParentDict.IndexOfKey(Comps.Item(i))
				If Posi <> -1 Then TmpControlName = ControlParentDict.Item(Posi)->Text Else TmpControlName= ""
				tmpDefinition = "`" & Comps.Item(i) & "` is a type or collection of the " & TmpControlName & " control, part of the freeBasic framework MyFbFramework."
			Else
				TmpControlName = Comps.Item(i)
				tmpDefinition = "```" & Comps.Item(i) & "``` is a " & ControlTypArr(tbi->ControlType) & " within the MyFbFramework."
				tmpDefinition &= "The " & TmpControlName & " control structure is highly analogous to the VB6, vb.net " & TmpControlName & " control, with similar components, properties, and behaviors but uses the syntax and conventions defined by the MyFbFramework."
			End If
			
			WAdd(FileContentPtr, Chr(13, 10) & "## " & Comps.Item(i))
			WAdd(FileContentPtr, Chr(13, 10) & "### Definition")
			If Trim(tbi->OwnerNamespace) <> "" Then WAdd(FileContentPtr, Chr(13, 10) & "Namespace: " & tbi->OwnerNamespace & " ")
			FPropertyItems.Clear
			TabWindow.FillProperties Comps.Item(i)
			FPropertyItems.Sort
			WAdd(FileContentPtr, Chr(13, 10))
			WAdd(FileContentPtr, Chr(13, 10) & "`" & Comps.Item(i) & "` - " & IIf(Trim(tbi->Comment) <> "", WStr(tbi->Comment), WStr(tmpDefinition)))
			WAdd(FileContentPtr, Chr(13, 10))
			bNotEmpty = False
			WAdd(FileContentPtr, Chr(13, 10) & "### Properties")
			WLet(FileContentPtr1, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Field AndAlso te->ElementType <> ElementTypes.E_Property Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				WAdd(FileContentPtr1, Chr(13, 10) & "|" & FPropertyItems.Item(j) & "|" & Trim(te->Comment, Any !"\r\n\t ") & "|`" & te->Parameters & "`|")
				bNotEmpty = True
			Next
			If bNotEmpty Then
				WAdd(FileContentPtr, Chr(13, 10) & *FileContentPtr1)
			Else
				WAdd(FileContentPtr, Chr(13, 10) & "(No properties defined)")
			End If
			
			WAdd(FileContentPtr, Chr(13, 10))
			bNotEmpty = False
			WAdd(FileContentPtr, Chr(13, 10) & "### Methods")
			WLet(FileContentPtr1, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Function AndAlso te->ElementType <> ElementTypes.E_Sub AndAlso te->ElementType <> ElementTypes.E_Define AndAlso te->ElementType <> ElementTypes.E_Macro Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				WAdd(FileContentPtr1, Chr(13, 10) & "|" & FPropertyItems.Item(j) & "|" & Trim(te->Comment, Any !"\r\n\t ") & "|`" & IIf(te->ElementType = ElementTypes.E_Function, "Declare Function", "Declare Sub") & " " & te->Parameters & "`|")
				bNotEmpty = True
			Next
			If bNotEmpty Then
				WAdd(FileContentPtr, Chr(13, 10) & *FileContentPtr1)
			Else
				WAdd(FileContentPtr, Chr(13, 10) & "(No methods defined)")
			End If
			bNotEmpty = False
			WAdd(FileContentPtr, Chr(13, 10) & "### Events")
			WLet(FileContentPtr1, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To FPropertyItems.Count - 1
				te = FPropertyItems.Object(j)
				If te = 0 OrElse te->ElementType <> ElementTypes.E_Event Then Continue For
				Var Pos1 = InStr(te->DisplayName, "[")
				If Pos1 > 0 Then wikiTitle = Trim(Left(te->DisplayName, Pos1 - 1)) Else wikiTitle = te->DisplayName
				WAdd(FileContentPtr1, Chr(13, 10) & "|" & FPropertyItems.Item(j) & "|" & Trim(te->Comment, Any !"\r\n\t ") & "|`" & te->Parameters & "`|")
				bNotEmpty = True
			Next
			If bNotEmpty Then
				WAdd(FileContentPtr, Chr(13, 10) & *FileContentPtr1)
			Else
				WAdd(FileContentPtr, Chr(13, 10) & "(No events defined)")
			End If
			'SaveToFile(wikiFolder & Comps.Item(i) & ".md", *FileContentPtr, FileEncoding, NewLineType)
			'If tbi->ControlType <> 0 Then
				'Debug.Print Comps.Item(i)
				AIContext.Add(Comps.Item(i), *FileContentPtr)
			'End If
			Deallocate FileContentPtr : FileContentPtr = 0
		Next i
		WLet(FileContentPtr, "## " & "Globals Enums")
		For i = 0 To Globals.Enums.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Enums.Object(i))
			If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			WAdd(FileContentPtr, Chr(13, 10) & "### " & Globals.Enums.Item(i) & " Enum")
			WAdd(FileContentPtr, Chr(13, 10) &  "`" & Globals.Enums.Item(i) & "` is a global enum within the MyFbFramework.")
			WAdd(FileContentPtr, Chr(13, 10) & tbi->Comment)
			If tbi->OwnerNamespace <> "" Then
				WAdd(FileContentPtr, Chr(13, 10) & "#### Definition")
				If Trim(tbi->OwnerNamespace) <> "" Then WAdd(FileContentPtr, Chr(13, 10) & "Namespace: " & tbi->OwnerNamespace)
			End If
			WAdd(FileContentPtr, Chr(13, 10) & "#### Fields")
			WAdd(FileContentPtr, Chr(13, 10) & "|Name|Description|Syntax|")
			WAdd(FileContentPtr, Chr(13, 10) & "| :---- | :---- | :---- |")
			For j As Integer = 0 To tbi->Elements.Count - 1
				te = tbi->Elements.Object(j)
				WAdd(FileContentPtr, Chr(13, 10) & "|`" & tbi->Elements.Item(j) & "`|" & te->Value & "|`" & te->Comment & "`|")
			Next
		Next i
		'SaveToFile(wikiFolder & "Globals Enums.md", *FileContentPtr, FileEncoding, NewLineType)
		AIContext.Add("Globals Enums", *FileContentPtr)
		Deallocate FileContentPtr : FileContentPtr = 0
		Deallocate FileContentPtr1 : FileContentPtr1 = 0
		WLet(FileContentPtr1, "## Globals Procedures")
		WAdd(FileContentPtr1, Chr(13, 10) & "|Name|Type|Description|Syntax|")
		WAdd(FileContentPtr1, Chr(13, 10) & "| :---- | :---- | :---- | :---- |")
		For i = 0 To Globals.Functions.Count - 1
			tbi = Cast(TypeElement Ptr, Globals.Functions.Object(i))
			If tbi->ElementType <> ElementTypes.E_Define AndAlso tbi->ElementType <> ElementTypes.E_Macro AndAlso tbi->ElementType <> ElementTypes.E_Function AndAlso tbi->ElementType <> ElementTypes.E_Sub Then Continue For
			If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
			If tbi->Declaration Then Continue For
			WAdd(FileContentPtr1, Chr(13, 10) & "|" & Replace(tbi->FullName, "My.Sys.Forms.", "") & "|" & IIf(tbi->ElementType = ElementTypes.E_Function, " Function", IIf(tbi->ElementType = ElementTypes.E_Sub, " Method", IIf(tbi->ElementType = ElementTypes.E_Define, " Define", IIf(tbi->ElementType = ElementTypes.E_Macro, " Macro", "")))) & "|" )
			WAdd(FileContentPtr1, "|`" & IIf(tbi->ElementType = ElementTypes.E_Function, "Function", IIf(tbi->ElementType = ElementTypes.E_Sub, "Sub", IIf(tbi->ElementType = ElementTypes.E_Define, "#define", IIf(tbi->ElementType = ElementTypes.E_Macro, "#macro", "")))) & " " & tbi->Parameters & "`|")
		Next i
		'SaveToFile(wikiFolder & "Globals Procedures.md", *FileContentPtr1, FileEncoding, NewLineType)
		AIContext.Add("Globals Procedures", *FileContentPtr1)
		Deallocate FileContentPtr1 : FileContentPtr1 = 0
		'WLet(FileContentPtr1, "## Globals Args")
		'For i = 0 To Globals.Args.Count - 1
		'	tbi = Cast(TypeElement Ptr, Globals.Args.Object(i))
		'	If tbi->CtlLibrary <> MFFCtlLibrary Then Continue For
		'	WAdd(FileContentPtr1, Chr(13, 10) & "### " & tbi->Name)
		'	WAdd(FileContentPtr, Chr(13, 10) & "#### Definition")
		'	If Trim(tbi->OwnerNamespace) <> "" Then WAdd(FileContentPtr1, Chr(13, 10) & "Namespace:  " & tbi->OwnerNamespace)
		'	WAdd(FileContentPtr1, Chr(13, 10) &  "`" & tbi->Name & "` is a global variable in MyFbFramework.")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "`" & tbi->Name & "` - " & tbi->Comment)
		'	WAdd(FileContentPtr1, Chr(13, 10) & "#### Syntax")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "```FreeBasic")
		'	WAdd(FileContentPtr1, Chr(13, 10) & tbi->Parameters)
		'	WAdd(FileContentPtr1, Chr(13, 10) & "```")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "")
		'	WAdd(FileContentPtr1, Chr(13, 10) & "#### Property Value")
		'	WAdd(FileContentPtr1, Chr(13, 10) & GetTypeLink(tbi->TypeName, True))
		'Next i
		'SaveToFile(wikiFolder & "Globals Args.md", *FileContentPtr1, FileEncoding, NewLineType)
		'Deallocate FileContentPtr1 : FileContentPtr1 = 0
	#endif
	

	For i = 0 To ControlLibraries.Count - 1
		CtlLibrary = ControlLibraries.Item(i)
		If ForLibrary <> 0 AndAlso CtlLibrary <> ForLibrary Then Continue For
		If CtlLibrary->Handle Then DyLibFree(CtlLibrary->Handle)
	Next i
End Sub

Sub LoadTheme
	iniTheme.Load ExePath & "/Settings/Themes/" & *CurrentTheme & ".ini"
	#ifdef __USE_GTK__
		NormalText.ForegroundOption = iniTheme.ReadInteger("Colors", "NormalTextForeground", clBlack)
		NormalText.BackgroundOption = iniTheme.ReadInteger("Colors", "NormalTextBackground", clWhite)
	#else
		NormalText.ForegroundOption = iniTheme.ReadInteger("Colors", "NormalTextForeground", IIf(g_darkModeEnabled, darkTextColor, clBlack))
		NormalText.BackgroundOption = iniTheme.ReadInteger("Colors", "NormalTextBackground", IIf(g_darkModeEnabled, darkBkColor, clWhite))
	#endif
	NormalText.FrameOption = iniTheme.ReadInteger("Colors", "NormalTextFrame", -1)
	NormalText.Bold = iniTheme.ReadInteger("FontStyles", "NormalTextBold", 0)
	NormalText.Italic = iniTheme.ReadInteger("FontStyles", "NormalTextItalic", 0)
	NormalText.Underline = iniTheme.ReadInteger("FontStyles", "NormalTextUnderline", 0)
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
	Identifiers.ForegroundOption = iniTheme.ReadInteger("Colors", "IdentifiersForeground", NormalText.ForegroundOption)
	Identifiers.BackgroundOption = iniTheme.ReadInteger("Colors", "IdentifiersBackground", NormalText.BackgroundOption)
	Identifiers.FrameOption = iniTheme.ReadInteger("Colors", "IdentifiersFrame", NormalText.FrameOption)
	Identifiers.Bold = iniTheme.ReadInteger("FontStyles", "IdentifiersBold", 0)
	Identifiers.Italic = iniTheme.ReadInteger("FontStyles", "IdentifiersItalic", 0)
	Identifiers.Underline = iniTheme.ReadInteger("FontStyles", "IdentifiersUnderline", 0)
	IndicatorLines.ForegroundOption = iniTheme.ReadInteger("Colors", "IndicatorLinesForeground", -1)
	For k As Integer = 0 To UBound(Keywords)
		Keywords(k).ForegroundOption = iniTheme.ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Foreground", iniTheme.ReadInteger("Colors", "KeywordsForeground", -1))
		Keywords(k).BackgroundOption = iniTheme.ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Background", iniTheme.ReadInteger("Colors", "KeywordsBackground", -1))
		Keywords(k).FrameOption = iniTheme.ReadInteger("Colors", Replace(KeywordLists.Item(k), " ", "") & "Frame", iniTheme.ReadInteger("Colors", "KeywordsFrame", -1))
		Keywords(k).Bold = iniTheme.ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Bold", iniTheme.ReadInteger("Colors", "KeywordsBold", 0))
		Keywords(k).Italic = iniTheme.ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Italic", iniTheme.ReadInteger("Colors", "KeywordsItalic", 0))
		Keywords(k).Underline = iniTheme.ReadInteger("FontStyles", Replace(KeywordLists.Item(k), " ", "") & "Underline", iniTheme.ReadInteger("Colors", "KeywordsUnderline", 0))
	Next k
	LineNumbers.ForegroundOption = iniTheme.ReadInteger("Colors", "LineNumbersForeground", -1)
	LineNumbers.BackgroundOption = iniTheme.ReadInteger("Colors", "LineNumbersBackground", -1)
	LineNumbers.Bold = iniTheme.ReadInteger("FontStyles", "LineNumbersBold", 0)
	LineNumbers.Italic = iniTheme.ReadInteger("FontStyles", "LineNumbersItalic", 0)
	LineNumbers.Underline = iniTheme.ReadInteger("FontStyles", "LineNumbersUnderline", 0)
	Numbers.ForegroundOption = iniTheme.ReadInteger("Colors", "NumbersForeground", -1)
	Numbers.BackgroundOption = iniTheme.ReadInteger("Colors", "NumbersBackground", -1)
	Numbers.FrameOption = iniTheme.ReadInteger("Colors", "NumbersFrame", -1)
	Numbers.Bold = iniTheme.ReadInteger("FontStyles", "NumbersBold", 0)
	Numbers.Italic = iniTheme.ReadInteger("FontStyles", "NumbersItalic", 0)
	Numbers.Underline = iniTheme.ReadInteger("FontStyles", "NumbersUnderline", 0)
	RealNumbers.ForegroundOption = iniTheme.ReadInteger("Colors", "RealNumbersForeground", Numbers.ForegroundOption )
	RealNumbers.BackgroundOption = iniTheme.ReadInteger("Colors", "RealNumbersBackground", Numbers.ForegroundOption )
	RealNumbers.FrameOption = iniTheme.ReadInteger("Colors", "RealNumbersFrame", Numbers.ForegroundOption )
	RealNumbers.Bold = iniTheme.ReadInteger("FontStyles", "RealNumbersBold", Numbers.Bold)
	RealNumbers.Italic = iniTheme.ReadInteger("FontStyles", "RealNumbersItalic", Numbers.Italic)
	RealNumbers.Underline = iniTheme.ReadInteger("FontStyles", "RealNumbersUnderline", Numbers.Underline)
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
	
	ColorOperators.ForegroundOption = iniTheme.ReadInteger("Colors", "OperatorsForeground", -1)
	ColorOperators.BackgroundOption = iniTheme.ReadInteger("Colors", "OperatorsBackground", -1)
	ColorOperators.FrameOption = iniTheme.ReadInteger("Colors", "ColorOperatorsFrame", -1)
	ColorOperators.Bold = iniTheme.ReadInteger("FontStyles", "OperatorsBold", 0)
	ColorOperators.Italic = iniTheme.ReadInteger("FontStyles", "OperatorsItalic", 0)
	ColorOperators.Underline = iniTheme.ReadInteger("FontStyles", "OperatorsUnderline", 0)
	
	ColorByRefParameters.ForegroundOption = iniTheme.ReadInteger("Colors", "ByRefParametersForeground", Identifiers.ForegroundOption)
	ColorByRefParameters.BackgroundOption = iniTheme.ReadInteger("Colors", "ByRefParametersBackground", Identifiers.BackgroundOption)
	ColorByRefParameters.FrameOption = iniTheme.ReadInteger("Colors", "ByRefParametersFrame", Identifiers.FrameOption)
	ColorByRefParameters.Bold = iniTheme.ReadInteger("FontStyles", "ByRefParametersBold", 0)
	ColorByRefParameters.Italic = iniTheme.ReadInteger("FontStyles", "ByRefParametersItalic", 0)
	ColorByRefParameters.Underline = iniTheme.ReadInteger("FontStyles", "ByRefParametersUnderline", 0)
	
	ColorByValParameters.ForegroundOption = iniTheme.ReadInteger("Colors", "ByValParametersForeground", Identifiers.ForegroundOption)
	ColorByValParameters.BackgroundOption = iniTheme.ReadInteger("Colors", "ByValParametersBackground", Identifiers.BackgroundOption)
	ColorByValParameters.FrameOption = iniTheme.ReadInteger("Colors", "ByValParametersFrame", Identifiers.FrameOption)
	ColorByValParameters.Bold = iniTheme.ReadInteger("FontStyles", "ByValParametersBold", 0)
	ColorByValParameters.Italic = iniTheme.ReadInteger("FontStyles", "ByValParametersItalic", 0)
	ColorByValParameters.Underline = iniTheme.ReadInteger("FontStyles", "ByValParametersUnderline", 0)
	
	ColorCommonVariables.ForegroundOption = iniTheme.ReadInteger("Colors", "CommonVariablesForeground", Identifiers.ForegroundOption)
	ColorCommonVariables.BackgroundOption = iniTheme.ReadInteger("Colors", "CommonVariablesBackground", Identifiers.BackgroundOption)
	ColorCommonVariables.FrameOption = iniTheme.ReadInteger("Colors", "CommonVariablesFrame", Identifiers.FrameOption)
	ColorCommonVariables.Bold = iniTheme.ReadInteger("FontStyles", "CommonVariablesBold", 0)
	ColorCommonVariables.Italic = iniTheme.ReadInteger("FontStyles", "CommonVariablesItalic", 0)
	ColorCommonVariables.Underline = iniTheme.ReadInteger("FontStyles", "CommonVariablesUnderline", 0)
	
	ColorComps.ForegroundOption = iniTheme.ReadInteger("Colors", "ComponentsForeground", Identifiers.ForegroundOption)
	ColorComps.BackgroundOption = iniTheme.ReadInteger("Colors", "ComponentsBackground", Identifiers.BackgroundOption)
	ColorComps.FrameOption = iniTheme.ReadInteger("Colors", "ComponentsFrame", Identifiers.FrameOption)
	ColorComps.Bold = iniTheme.ReadInteger("FontStyles", "ComponentsBold", 0)
	ColorComps.Italic = iniTheme.ReadInteger("FontStyles", "ComponentsItalic", 0)
	ColorComps.Underline = iniTheme.ReadInteger("FontStyles", "ComponentsUnderline", 0)
	
	ColorConstants.ForegroundOption = iniTheme.ReadInteger("Colors", "ConstantsForeground", Identifiers.ForegroundOption)
	ColorConstants.BackgroundOption = iniTheme.ReadInteger("Colors", "ConstantsBackground", Identifiers.BackgroundOption)
	ColorConstants.FrameOption = iniTheme.ReadInteger("Colors", "ConstantsFrame", Identifiers.FrameOption)
	ColorConstants.Bold = iniTheme.ReadInteger("FontStyles", "ConstantsBold", 0)
	ColorConstants.Italic = iniTheme.ReadInteger("FontStyles", "ConstantsItalic", 0)
	ColorConstants.Underline = iniTheme.ReadInteger("FontStyles", "ConstantsUnderline", 0)
	
	ColorDefines.ForegroundOption = iniTheme.ReadInteger("Colors", "DefinesForeground", Identifiers.ForegroundOption)
	ColorDefines.BackgroundOption = iniTheme.ReadInteger("Colors", "DefinesBackground", Identifiers.BackgroundOption)
	ColorDefines.FrameOption = iniTheme.ReadInteger("Colors", "DefinesFrame", Identifiers.FrameOption)
	ColorDefines.Bold = iniTheme.ReadInteger("FontStyles", "DefinesBold", 0)
	ColorDefines.Italic = iniTheme.ReadInteger("FontStyles", "DefinesItalic", 0)
	ColorDefines.Underline = iniTheme.ReadInteger("FontStyles", "DefinesUnderline", 0)
	
	ColorFields.ForegroundOption = iniTheme.ReadInteger("Colors", "FieldsForeground", Identifiers.ForegroundOption)
	ColorFields.BackgroundOption = iniTheme.ReadInteger("Colors", "FieldsBackground", Identifiers.BackgroundOption)
	ColorFields.FrameOption = iniTheme.ReadInteger("Colors", "FieldsFrame", Identifiers.FrameOption)
	ColorFields.Bold = iniTheme.ReadInteger("FontStyles", "FieldsBold", 0)
	ColorFields.Italic = iniTheme.ReadInteger("FontStyles", "FieldsItalic", 0)
	ColorFields.Underline = iniTheme.ReadInteger("FontStyles", "FieldsUnderline", 0)
	
	ColorGlobalFunctions.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalFunctionsForeground", Identifiers.ForegroundOption)
	ColorGlobalFunctions.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalFunctionsBackground", Identifiers.BackgroundOption)
	ColorGlobalFunctions.FrameOption = iniTheme.ReadInteger("Colors", "GlobalFunctionsFrame", Identifiers.FrameOption)
	ColorGlobalFunctions.Bold = iniTheme.ReadInteger("FontStyles", "GlobalFunctionsBold", 0)
	ColorGlobalFunctions.Italic = iniTheme.ReadInteger("FontStyles", "GlobalFunctionsItalic", 0)
	ColorGlobalFunctions.Underline = iniTheme.ReadInteger("FontStyles", "GlobalFunctionsUnderline", 0)
	
	ColorEnumMembers.ForegroundOption = iniTheme.ReadInteger("Colors", "EnumMembersForeground", Identifiers.ForegroundOption)
	ColorEnumMembers.BackgroundOption = iniTheme.ReadInteger("Colors", "EnumMembersBackground", Identifiers.BackgroundOption)
	ColorEnumMembers.FrameOption = iniTheme.ReadInteger("Colors", "EnumMembersFrame", Identifiers.FrameOption)
	ColorEnumMembers.Bold = iniTheme.ReadInteger("FontStyles", "EnumMembersBold", 0)
	ColorEnumMembers.Italic = iniTheme.ReadInteger("FontStyles", "EnumMembersItalic", 0)
	ColorEnumMembers.Underline = iniTheme.ReadInteger("FontStyles", "EnumMembersUnderline", 0)
	
	ColorGlobalEnums.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalEnumsForeground", Identifiers.ForegroundOption)
	ColorGlobalEnums.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalEnumsBackground", Identifiers.BackgroundOption)
	ColorGlobalEnums.FrameOption = iniTheme.ReadInteger("Colors", "GlobalEnumsFrame", Identifiers.FrameOption)
	ColorGlobalEnums.Bold = iniTheme.ReadInteger("FontStyles", "GlobalEnumsBold", 0)
	ColorGlobalEnums.Italic = iniTheme.ReadInteger("FontStyles", "GlobalEnumsItalic", 0)
	ColorGlobalEnums.Underline = iniTheme.ReadInteger("FontStyles", "GlobalEnumsUnderline", 0)
	
	ColorLineLabels.ForegroundOption = iniTheme.ReadInteger("Colors", "LineLabelsForeground", Identifiers.ForegroundOption)
	ColorLineLabels.BackgroundOption = iniTheme.ReadInteger("Colors", "LineLabelsBackground", Identifiers.BackgroundOption)
	ColorLineLabels.FrameOption = iniTheme.ReadInteger("Colors", "LineLabelsFrame", Identifiers.FrameOption)
	ColorLineLabels.Bold = iniTheme.ReadInteger("FontStyles", "LineLabelsBold", 0)
	ColorLineLabels.Italic = iniTheme.ReadInteger("FontStyles", "LineLabelsItalic", 0)
	ColorLineLabels.Underline = iniTheme.ReadInteger("FontStyles", "LineLabelsUnderline", 0)
	
	ColorLocalVariables.ForegroundOption = iniTheme.ReadInteger("Colors", "LocalVariablesForeground", Identifiers.ForegroundOption)
	ColorLocalVariables.BackgroundOption = iniTheme.ReadInteger("Colors", "LocalVariablesBackground", Identifiers.BackgroundOption)
	ColorLocalVariables.FrameOption = iniTheme.ReadInteger("Colors", "LocalVariablesFrame", Identifiers.FrameOption)
	ColorLocalVariables.Bold = iniTheme.ReadInteger("FontStyles", "LocalVariablesBold", 0)
	ColorLocalVariables.Italic = iniTheme.ReadInteger("FontStyles", "LocalVariablesItalic", 0)
	ColorLocalVariables.Underline = iniTheme.ReadInteger("FontStyles", "LocalVariablesUnderline", 0)
	
	ColorMacros.ForegroundOption = iniTheme.ReadInteger("Colors", "MacrosForeground", Identifiers.ForegroundOption)
	ColorMacros.BackgroundOption = iniTheme.ReadInteger("Colors", "MacrosBackground", Identifiers.BackgroundOption)
	ColorMacros.FrameOption = iniTheme.ReadInteger("Colors", "MacrosFrame", Identifiers.FrameOption)
	ColorMacros.Bold = iniTheme.ReadInteger("FontStyles", "MacrosBold", 0)
	ColorMacros.Italic = iniTheme.ReadInteger("FontStyles", "MacrosItalic", 0)
	ColorMacros.Underline = iniTheme.ReadInteger("FontStyles", "MacrosUnderline", 0)
	
	ColorGlobalNamespaces.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalNamespacesForeground", Identifiers.ForegroundOption)
	ColorGlobalNamespaces.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalNamespacesBackground", Identifiers.BackgroundOption)
	ColorGlobalNamespaces.FrameOption = iniTheme.ReadInteger("Colors", "GlobalNamespacesFrame", Identifiers.FrameOption)
	ColorGlobalNamespaces.Bold = iniTheme.ReadInteger("FontStyles", "GlobalNamespacesBold", 0)
	ColorGlobalNamespaces.Italic = iniTheme.ReadInteger("FontStyles", "GlobalNamespacesItalic", 0)
	ColorGlobalNamespaces.Underline = iniTheme.ReadInteger("FontStyles", "GlobalNamespacesUnderline", 0)
	
	ColorProperties.ForegroundOption = iniTheme.ReadInteger("Colors", "PropertiesForeground", Identifiers.ForegroundOption)
	ColorProperties.BackgroundOption = iniTheme.ReadInteger("Colors", "PropertiesBackground", Identifiers.BackgroundOption)
	ColorProperties.FrameOption = iniTheme.ReadInteger("Colors", "PropertiesFrame", Identifiers.FrameOption)
	ColorProperties.Bold = iniTheme.ReadInteger("FontStyles", "PropertiesBold", 0)
	ColorProperties.Italic = iniTheme.ReadInteger("FontStyles", "PropertiesItalic", 0)
	ColorProperties.Underline = iniTheme.ReadInteger("FontStyles", "PropertiesUnderline", 0)
	
	ColorSharedVariables.ForegroundOption = iniTheme.ReadInteger("Colors", "SharedVariablesForeground", Identifiers.ForegroundOption)
	ColorSharedVariables.BackgroundOption = iniTheme.ReadInteger("Colors", "SharedVariablesBackground", Identifiers.BackgroundOption)
	ColorSharedVariables.FrameOption = iniTheme.ReadInteger("Colors", "SharedVariablesFrame", Identifiers.FrameOption)
	ColorSharedVariables.Bold = iniTheme.ReadInteger("FontStyles", "SharedVariablesBold", 0)
	ColorSharedVariables.Italic = iniTheme.ReadInteger("FontStyles", "SharedVariablesItalic", 0)
	ColorSharedVariables.Underline = iniTheme.ReadInteger("FontStyles", "SharedVariablesUnderline", 0)
	
	ColorSubs.ForegroundOption = iniTheme.ReadInteger("Colors", "SubsForeground", Identifiers.ForegroundOption)
	ColorSubs.BackgroundOption = iniTheme.ReadInteger("Colors", "SubsBackground", Identifiers.BackgroundOption)
	ColorSubs.FrameOption = iniTheme.ReadInteger("Colors", "SubsFrame", Identifiers.FrameOption)
	ColorSubs.Bold = iniTheme.ReadInteger("FontStyles", "SubsBold", 0)
	ColorSubs.Italic = iniTheme.ReadInteger("FontStyles", "SubsItalic", 0)
	ColorSubs.Underline = iniTheme.ReadInteger("FontStyles", "SubsUnderline", 0)
	
	ColorGlobalTypes.ForegroundOption = iniTheme.ReadInteger("Colors", "GlobalTypesForeground", Identifiers.ForegroundOption)
	ColorGlobalTypes.BackgroundOption = iniTheme.ReadInteger("Colors", "GlobalTypesBackground", Identifiers.BackgroundOption)
	ColorGlobalTypes.FrameOption = iniTheme.ReadInteger("Colors", "GlobalTypesFrame", Identifiers.FrameOption)
	ColorGlobalTypes.Bold = iniTheme.ReadInteger("FontStyles", "GlobalTypesBold", 0)
	ColorGlobalTypes.Italic = iniTheme.ReadInteger("FontStyles", "GlobalTypesItalic", 0)
	ColorGlobalTypes.Underline = iniTheme.ReadInteger("FontStyles", "GlobalTypesUnderline", 0)
	
	SetAutoColors
End Sub

Sub UpdateAllTabWindows
	Dim As TabWindow Ptr tb
	#ifdef __USE_GTK__
		tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then tb->txtCode.Update
	#else
		For jj As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(jj))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
				If tb <> 0 Then tb->txtCode.PaintControl True
			Next
		Next
	#endif
End Sub

Sub LoadSettings
	Dim As UString Temp
	Dim As ToolType Ptr Tool
	Dim As ModelInfo Ptr Info
	Dim i As Integer = 0
	WLet(DefaultAIAgent, iniSettings.ReadString("AIAgents", "DefaultAIAgent", "deepseek/deepseek-chat-v3-0324:free|OpenRouter"))
	WLet(CurrentAIAgent, *DefaultAIAgent)
	cboAIAgentModels.AddItem ML("(not selected)")
	cboBuildConfiguration.AddItem ML("No options")
	Do Until iniSettings.KeyExists("AIAgents", "Version_" & WStr(i)) + iniSettings.KeyExists("Compilers", "Version_" & WStr(i)) + iniSettings.KeyExists("MakeTools", "Version_" & WStr(i)) + _
		iniSettings.KeyExists("Debuggers", "Version_" & WStr(i)) + iniSettings.KeyExists("Terminals", "Version_" & WStr(i)) + iniSettings.KeyExists("BuildConfigurations", "Name_" & WStr(i)) + _
		iniSettings.KeyExists("Helps", "Version_" & WStr(i)) + iniSettings.KeyExists("OtherEditors", "Version_" & WStr(i)) + _
		iniSettings.KeyExists("IncludePaths", "Path_" & WStr(i)) + iniSettings.KeyExists("LibraryPaths", "Path_" & WStr(i)) = -10
		Temp = iniSettings.ReadString("Compilers", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("Compilers", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("Compilers", "Command_" & WStr(i), "")
			Compilers.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("AIAgents", "Version_" & WStr(i), "")
		If i = 0 AndAlso Temp = "" Then Temp = "deepseek/deepseek-chat-v3-0324:free|OpenRouter"
		If Temp <> "" Then
			Info = _New(ModelInfo)
			Info->Name = Temp
			Info->ModelName = iniSettings.ReadString("AIAgents", "ModelName_" & WStr(i), "deepseek/deepseek-chat-v3-0324:free")
			Info->Provider = iniSettings.ReadString("AIAgents", "Provider_" & WStr(i), "OpenRouter")
			Info->Port = iniSettings.ReadInteger("AIAgents", "Port_" & WStr(i), 443)
			Info->Host = iniSettings.ReadString("AIAgents", "Host_" & WStr(i), "openrouter.ai")
			Info->Address = iniSettings.ReadString("AIAgents", "Address_" & WStr(i), "api/v1/chat/completions")
			Info->APIKey = iniSettings.ReadString("AIAgents", "APIKey_" & WStr(i), "sk-or-v1-XXXXXX")
			Info->Response_Format = iniSettings.ReadString("AIAgents", "Response_Format_" & WStr(i), "")
			Info->Temperature = iniSettings.ReadFloat("AIAgents", "Temperature_" & WStr(i), 0.6)
			Info->Top_P = iniSettings.ReadFloat("AIAgents", "Top_P_" & WStr(i), 0)
			Info->Stream = iniSettings.ReadBool("AIAgents", "Stream_" & WStr(i), True)
			cboAIAgentModels.AddItem(Temp)
			AIAgents.Add Temp, Info->Host, Info
			If *CurrentAIAgent = Temp Then
				AIAgentModelName = Info->ModelName
				AIAgentProvider = Info->Provider
				AIAgentHost = Info->Host
				AIAgentAddress  = Info->Address
				AIAgentAPIKey = Info->APIKey
				AIAgentTemperature = Info->Temperature
				AIAgentStream  = Info->Stream
				cboAIAgentModels.Text = Temp
				AIPostDataFirstTime= True
				AIIncludeFileNameList.Clear
			End If
		End If
		Temp = iniSettings.ReadString("MakeTools", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("MakeTools", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("MakeTools", "Command_" & WStr(i), "")
			MakeTools.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("Debuggers", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("Debuggers", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("Debuggers", "Command_" & WStr(i), "")
			Debuggers.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("Terminals", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("Terminals", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("Terminals", "Command_" & WStr(i), "")
			Terminals.Add Temp, Tool->Path, Tool
		End If
		Temp = iniSettings.ReadString("OtherEditors", "Version_" & WStr(i), "")
		If Temp <> "" Then
			Tool = _New(ToolType)
			Tool->Name = Temp
			Tool->Path = iniSettings.ReadString("OtherEditors", "Path_" & WStr(i), "")
			Tool->Parameters = iniSettings.ReadString("OtherEditors", "Command_" & WStr(i), "")
			Tool->Extensions = iniSettings.ReadString("OtherEditors", "Extensions_" & WStr(i), "")
			OtherEditors.Add Temp, Tool->Path, Tool
		End If
		
		Temp = iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		If Temp <> "" Then Helps.Add Temp, iniSettings.ReadString("Helps", "Path_" & WStr(i), "")
		Temp = iniSettings.ReadString("BuildConfigurations", "Name_" & WStr(i), "")
		If Temp <> "" Then BuildConfigurations.Add Temp, iniSettings.ReadString("BuildConfigurations", "Switches_" & WStr(i), ""): cboBuildConfiguration.AddItem Temp
		Temp = iniSettings.ReadString("IncludePaths", "Path_" & WStr(i), "")
		If Temp <> "" Then IncludePaths.Add Temp
		Temp = iniSettings.ReadString("LibraryPaths", "Path_" & WStr(i), "")
		If Temp <> "" Then LibraryPaths.Add Temp
		i += 1
	Loop
	
	WLet(DefaultCompiler32, iniSettings.ReadString("Compilers", "DefaultCompiler32", ""))
	WLet(CurrentCompiler32, *DefaultCompiler32)
	WLet(DefaultCompiler64, iniSettings.ReadString("Compilers", "DefaultCompiler64", ""))
	WLet(CurrentCompiler64, *DefaultCompiler64)
	WLet(Compiler32Path, Compilers.Get(*CurrentCompiler32, "fbc"))
	WLet(Compiler64Path, Compilers.Get(*CurrentCompiler64, "fbc"))
	WLet(DefaultMakeTool, iniSettings.ReadString("MakeTools", "DefaultMakeTool", "make"))
	WLet(CurrentMakeTool1, *DefaultMakeTool)
	WLet(MakeToolPath1, MakeTools.Get(*CurrentMakeTool1, "make"))
	WLet(CurrentMakeTool2, *DefaultMakeTool)
	WLet(MakeToolPath2, MakeTools.Get(*CurrentMakeTool2, "make"))
	#ifdef __FB_64BIT__
		WLet(DefaultDebugger32, iniSettings.ReadString("Debuggers", "DefaultDebugger32", "Integrated GDB Debugger"))
	#else
		WLet(DefaultDebugger32, iniSettings.ReadString("Debuggers", "DefaultDebugger32", "Integrated IDE Debugger"))
	#endif
	DefaultDebuggerType32 = IIf(*DefaultDebugger32 = "Integrated IDE Debugger", IntegratedIDEDebugger, IIf(*DefaultDebugger32 = "Integrated GDB Debugger", IntegratedGDBDebugger, CustomDebugger))
	WLet(CurrentDebugger32, *DefaultDebugger32)
	CurrentDebuggerType32 = DefaultDebuggerType32
	WLet(Debugger32Path, Debuggers.Get(*CurrentDebugger32, ""))
	WLet(GDBDebugger32, iniSettings.ReadString("Debuggers", "GDBDebugger32", ""))
	WLet(GDBDebugger32Path, Debuggers.Get(*GDBDebugger32, ""))
	#ifdef __FB_64BIT__
		WLet(DefaultDebugger64, iniSettings.ReadString("Debuggers", "DefaultDebugger64", "Integrated IDE Debugger"))
	#else
		WLet(DefaultDebugger64, iniSettings.ReadString("Debuggers", "DefaultDebugger64", "Integrated GDB Debugger"))
	#endif
	DefaultDebuggerType64 = IIf(*DefaultDebugger64 = "Integrated IDE Debugger", IntegratedIDEDebugger, IIf(*DefaultDebugger64 = "Integrated GDB Debugger", IntegratedGDBDebugger, CustomDebugger))
	WLet(CurrentDebugger64, *DefaultDebugger64)
	CurrentDebuggerType64 = DefaultDebuggerType64
	WLet(Debugger64Path, Debuggers.Get(*CurrentDebugger64, ""))
	WLet(GDBDebugger64, iniSettings.ReadString("Debuggers", "GDBDebugger64", ""))
	WLet(GDBDebugger64Path, Debuggers.Get(*GDBDebugger64, ""))
	WLet(DefaultTerminal, iniSettings.ReadString("Terminals", "DefaultTerminal", ""))
	WLet(CurrentTerminal, *DefaultTerminal)
	WLet(TerminalPath, Terminals.Get(*CurrentTerminal, ""))
	WLet(DefaultHelp, iniSettings.ReadString("Helps", "DefaultHelp", ""))
	WLet(HelpPath, Helps.Get(*DefaultHelp, ""))
	WLet(DefaultBuildConfiguration, iniSettings.ReadString("BuildConfigurations", "DefaultBuildConfiguration", ""))
	cboBuildConfiguration.ItemIndex = Max(0, cboBuildConfiguration.IndexOf(*DefaultBuildConfiguration))
	UseMakeOnStartWithCompile = iniSettings.ReadBool("Options", "UseMakeOnStartWithCompile", False)
	CreateNonStaticEventHandlers = iniSettings.ReadBool("Options", "CreateNonStaticEventHandlers", True)
	PlaceStaticEventHandlersAfterTheConstructor = iniSettings.ReadBool("Options", "PlaceStaticEventHandlersAfterTheConstructor", True)
	CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning = iniSettings.ReadBool("Options", "CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning", False)
	CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt = iniSettings.ReadBool("Options", "CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt", True)
	CreateFormTypesWithoutTypeWord = iniSettings.ReadBool("Options", "CreateFormTypesWithoutTypeWord", False)
	OpenCommandPromptInMainFileFolder = iniSettings.ReadBool("Options", "OpenCommandPromptInMainFileFolder", True)
	WLet(CommandPromptFolder, iniSettings.ReadString("Options", "CommandPromptFolder", "./Projects"))
	LimitDebug = iniSettings.ReadBool("Options", "LimitDebug", False)
	DisplayWarningsInDebug = iniSettings.ReadBool("Options", "DisplayWarningsInDebug", False)
	TurnOnEnvironmentVariables = iniSettings.ReadBool("Options", "TurnOnEnvironmentVariables", True)
	WLet(EnvironmentVariables, iniSettings.ReadString("Options", "EnvironmentVariables"))
	WLet(ProjectsPath, iniSettings.ReadString("Options", "ProjectsPath", "./Projects"))
	GridSize = iniSettings.ReadInteger("Options", "GridSize", 10)
	ShowAlignmentGrid = iniSettings.ReadBool("Options", "ShowAlignmentGrid", True)
	SnapToGridOption = iniSettings.ReadBool("Options", "SnapToGrid", True)
	AutoIncrement = iniSettings.ReadBool("Options", "AutoIncrement", True)
	AutoCreateRC = iniSettings.ReadBool("Options", "AutoCreateRC", True)
	AutoSaveSession = iniSettings.ReadBool("Options", "AutoSaveSession", False)
	AutoSaveBeforeCompiling = iniSettings.ReadInteger("Options", "AutoSaveBeforeCompiling", 1)
	AutoCreateBakFiles = iniSettings.ReadBool("Options", "AutoCreateBakFiles", False)
	AddRelativePathsToRecent = iniSettings.ReadBool("Options", "AddRelativePathsToRecent", True)
	WhenVisualFBEditorStarts = iniSettings.ReadInteger("Options", "WhenVisualFBEditorStarts", 2)
	WLet(DefaultProjectFile, iniSettings.ReadString("Options", "DefaultProjectFile", "Files/Form.frm"))
	DefaultFileFormat = iniSettings.ReadInteger("Options", "DefaultFileFormat", FileEncodings.Utf8BOM)
	#ifdef __FB_WIN32__
		DefaultNewLineFormat = iniSettings.ReadInteger("Options", "DefaultNewLineFormat", NewLineTypes.WindowsCRLF)
	#elseif __FB_DARWIN__
		DefaultNewLineFormat = iniSettings.ReadInteger("Options", "DefaultNewLineFormat", NewLineTypes.MacOSCR)
	#else
		DefaultNewLineFormat = iniSettings.ReadInteger("Options", "DefaultNewLineFormat", NewLineTypes.LinuxLF)
	#endif
	LastOpenedFileType = iniSettings.ReadInteger("Options", "LastOpenedFileType", 0)
	AutoComplete = iniSettings.ReadBool("Options", "AutoComplete", True)
	AutoSuggestions = iniSettings.ReadBool("Options", "AutoSuggestions", True)
	AutoIndentation = iniSettings.ReadBool("Options", "AutoIndentation", True)
	ShowSpaces = iniSettings.ReadBool("Options", "ShowSpaces", True)
	ShowKeywordsToolTip = iniSettings.ReadBool("Options", "ShowKeywordsTooltip", True)
	ShowTooltipsAtTheTop = iniSettings.ReadBool("Options", "ShowTooltipsAtTheTop", False)
	GlobalSettings.ShowSymbolsTooltipsOnMouseHover = iniSettings.ReadBool("Options", "ShowSymbolsTooltipsOnMouseHover", True)
	GlobalSettings.ShowClassesExplorerOnOpenWindow = iniSettings.ReadBool("Options", "ShowClassesExplorerOnOpenWindow", True)
	ShowHorizontalSeparatorLines = iniSettings.ReadBool("Options", "ShowHorizontalSeparatorLines", True)
	ShowHolidayFrame = iniSettings.ReadBool("Options", "ShowHolidayFrame", True)
	UseDirect2D = iniSettings.ReadBool("Options", "UseDirect2D", True)
	HighlightBrackets = iniSettings.ReadBool("Options", "HighlightBrackets", True)
	HighlightCurrentLine = iniSettings.ReadBool("Options", "HighlightCurrentLine", True)
	HighlightCurrentWord = iniSettings.ReadBool("Options", "HighlightCurrentWord", True)
	TabAsSpaces = iniSettings.ReadBool("Options", "TabAsSpaces", True)
	ChoosedTabStyle = iniSettings.ReadInteger("Options", "ChoosedTabStyle", 1)
	CodeEditorHoverTime = iniSettings.ReadInteger("Options", "CodeEditorHoverTime", 0)
	TabWidth = iniSettings.ReadInteger("Options", "TabWidth", 4)
	AutoSaveCharMax = iniSettings.ReadInteger("Options", "AutoSaveCharMax", 100)
	HistoryLimit = iniSettings.ReadInteger("Options", "HistoryLimit", 20)
	IntellisenseLimit = iniSettings.ReadInteger("Options", "IntellisenseLimit", 100)
	HistoryCodeDays = iniSettings.ReadInteger("Options", "HistoryCodeDays", 100)
	HistoryCodeCleanDay = iniSettings.ReadInteger("Options", "HistoryCodeCleanDay", DateValue(Format(Now, "yyyy/mm/dd")))
	If HistoryCodeCleanDay <> DateValue(Format(Now, "yyyy/mm/dd")) Then HistoryCodeClean(ExePath & "/Temp")
	SyntaxHighlightingIdentifiers = iniSettings.ReadBool("Options", "SyntaxHighlightingIdentifiers", True)
	ChangeIdentifiersCase = iniSettings.ReadBool("Options", "ChangeIdentifiersCase", True)
	ChangeKeyWordsCase = iniSettings.ReadBool("Options", "ChangeKeyWordsCase", True)
	ChangeEndingType = iniSettings.ReadBool("Options", "ChangeEndingType", True)
	ChoosedKeyWordsCase = iniSettings.ReadInteger("Options", "ChoosedKeyWordsCase", 0)
	ChoosedConstructions = iniSettings.ReadInteger("Options", "ChoosedConstructions", 0)
	AddSpacesToOperators = iniSettings.ReadBool("Options", "AddSpacesToOperators", True)
	WLet(CurrentTheme, iniSettings.ReadString("Options", "CurrentTheme", "Default Theme"))
	WLet(EditorFontName, iniSettings.ReadString("Options", "EditorFontName", "Courier New"))
	EditorFontSize = iniSettings.ReadInteger("Options", "EditorFontSize", 10)
	#ifdef __USE_GTK__
		WLet(InterfaceFontName, iniSettings.ReadString("Options", "InterfaceFontName", "Ubuntu"))
		InterfaceFontSize = iniSettings.ReadInteger("Options", "InterfaceFontSize", 11)
	#else
		WLet(InterfaceFontName, iniSettings.ReadString("Options", "InterfaceFontName", "Tahoma"))
		InterfaceFontSize = iniSettings.ReadInteger("Options", "InterfaceFontSize", 8)
	#endif
	DisplayMenuIcons = iniSettings.ReadBool("Options", "DisplayMenuIcons", True)
	ShowMainToolBar = iniSettings.ReadBool("Options", "ShowMainToolbar", True)
	DarkMode = iniSettings.ReadBool("Options", "DarkMode", True)
	'gLocalToolBox = iniSettings.ReadBool("Options", "ShowToolBoxLocal", False)
	gLocalProperties = iniSettings.ReadBool("Options", "PropertiesLocal", False)
	'gLocalKeyWords = iniSettings.ReadBool("Options", "KeyWordsLocal", False)
	ProjectAutoSuggestions = False
	
	If (*CurrentTheme = "Default Theme" AndAlso DarkMode) OrElse (*CurrentTheme = "Dark (Visual Studio)" AndAlso Not DarkMode) Then
		*CurrentTheme = IIf(DarkMode, "Dark (Visual Studio)", "Default Theme")
	End If
	#ifdef __USE_WINAPI__
		If DarkMode AndAlso g_darkModeSupported Then
			txtLabelProperty.BackColor = darkBkColor
			txtLabelEvent.BackColor = darkBkColor
			fAddIns.txtDescription.BackColor = GetSysColor(COLOR_WINDOW)
		End If
	#endif
	pDefaultFont->Name = WGet(InterfaceFontName)
	pDefaultFont->Size  = InterfaceFontSize
	mnuMain.DisplayIcons = DisplayMenuIcons
	mnuMain.ImagesList = IIf(DisplayMenuIcons, @imgList, 0)
	MainReBar.Visible = ShowMainToolBar
	SetDarkMode DarkMode, False
	
	WLet(Compiler32Arguments, iniSettings.ReadString("Parameters", "Compiler32Arguments", "-b {S} -exx"))
	WLet(Compiler64Arguments, iniSettings.ReadString("Parameters", "Compiler64Arguments", "-b {S} -exx"))
	WLet(Make1Arguments, iniSettings.ReadString("Parameters", "Make1Arguments", ""))
	WLet(Make2Arguments, iniSettings.ReadString("Parameters", "Make2Arguments", "clean"))
	WLet(RunArguments, iniSettings.ReadString("Parameters", "RunArguments", ""))
	WLet(Debug32Arguments, iniSettings.ReadString("Parameters", "Debug32Arguments", ""))
	WLet(Debug64Arguments, iniSettings.ReadString("Parameters", "Debug64Arguments", ""))
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("KeyWords")
	LoadKeyWords
	LoadTheme
	LoadD2D1
	EditControlFrame.LoadFromFile(ExePath & "/Resources/Frame.png")
End Sub

Sub LoadLanguageTexts
	iniSettings.Load SettingsPath
	App.CurLanguagePath = ExePath & "/Settings/Languages/"
	App.CurLanguage = iniSettings.ReadString("Options", "Language", "english")
	Dim As Boolean StartGeneral = True, StartKeyWords, StartProperty, StartCompiler, StartTemplates
	If App.CurLanguage = "" Then
		mpKeys.Add "#Til", "English"
		mlKeys.Add "#Til", "English"
		mlCompiler.Add "#Til", "English"
		App.CurLanguage = "English"
	Else
		mlKeys.Clear
		mcKeys.Clear
		mpKeys.Clear
		mlCompiler.Clear
		Dim As Integer i, Pos1, Pos2
		Dim As Integer Fn = FreeFile_, Result
		Dim As WString * 2048 Buff, tKey
		Dim As UString FileName = ExePath & "/Settings/Languages/" & App.CurLanguage & ".lng"
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				If LCase(Trim(Buff)) = "[keywords]" Then
					StartKeyWords = True
					StartProperty = False
					StartCompiler = False
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[property]" Then
					StartKeyWords = False
					StartProperty = True
					StartCompiler = False
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[compiler]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = True
					StartTemplates = False
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[templates]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					StartTemplates = True
					StartGeneral = False
				ElseIf LCase(Trim(Buff)) = "[general]" Then
					StartKeyWords = False
					StartProperty = False
					StartCompiler = False
					StartTemplates = False
					StartGeneral = True
				End If
				Pos1 = InStr(Buff, "=")
				If Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
					Pos2 = InStr(Pos1, Buff, "|")
					'David Change For the Control Property's Language.
					'note: "=" already convert To "~"
					tKey = Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")
					Var Pos3 = InStr(Buff, "~")
					If Pos3 > 0 AndAlso Pos3 < Pos1 Then Buff = Replace(Buff, "~", "=")
					If StartGeneral = True Then
						If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlKeys.Add Trim(Left(Buff, Pos1 - 1), Any !"\t "), Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartProperty = True Then
						If Pos2 > 0 Then
							mpKeys.Add tKey, Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1), Any !"\t ")
							If Len(Buff) - Pos2 <= 1 Then
								mcKeys.Add tKey, Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")  & IIf(Trim(Mid(Buff, 1, Pos1 - 1)) <> Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1)), "  " & Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1), Any !"\t "), "")   ' No comment
							Else
								mcKeys.Add tKey, Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")  & IIf(Trim(Mid(Buff, 1, Pos1 - 1)) <> Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1)), "  " & Trim(Mid(Buff, Pos1 + 1, Pos2 - Pos1 - 1), Any !"\t "), "") & Chr(13, 10) & Trim(Mid(Buff, Pos2 + 1, Len(Buff) - Pos2), Any !"\t ")
							End If
						Else
							mpKeys.Add tKey, Trim(Mid(Buff, Pos1 + 1, Len(Buff) - Pos2), Any !"\t ")
							mcKeys.Add tKey, Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ") & "  " & Trim(Mid(Buff, Pos1 + 1, Len(Buff) - Pos2), Any !"\t ")
						End If
					ElseIf StartKeyWords = True Then
						
					ElseIf StartCompiler = True Then
						If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlCompiler.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					ElseIf StartTemplates = True Then
						If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlTemplates.Add tKey, Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
					End If
				End If
			Loop
			mlKeys.SortKeys
			mpKeys.SortKeys
			mlCompiler.SortKeys
			mlTemplates.SortKeys
			CloseFile_(Fn)
			Exit Sub
		Else
			MsgBox ML("Open file failure!") &  " " & Chr(13, 10) & ML("in function") & " Main.LoadLanguageTexts" & Chr(13, 10) & "  " & ExePath & "/Settings/Languages/" & App.CurLanguage & ".lng"
		End If
		CloseFile_(Fn)
	End If
	mlKeys.Clear
	mcKeys.Clear
	mpKeys.Clear
	mlCompiler.Clear
	mpKeys.Add "#Til", "English"
	mlKeys.Add "#Til", "English"
	mlCompiler.Add "#Til", "English"
	App.CurLanguage = "english"
End Sub

Sub LoadHotKeys
	Dim As Integer Fn = FreeFile_, Pos1
	Dim As String Buff
	If Open(ExePath & "/Settings/Others/HotKeys.txt" For Input As #Fn) = 0 Then
		While Not EOF(Fn)
			Line Input #Fn, Buff
			Pos1 = InStr(Buff, "=")
			If Pos1 > 0 Then
				HotKeys.Add Left(Buff, Pos1 - 1), Mid(Buff, Pos1 + 1)
			End If
		Wend
	End If
	CloseFile_(Fn)
End Sub

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
		progress_bar_timer_id = g_timeout_add(100, Cast(GSourceFunc, @progress_cb), prProgress.Handle)
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

Dim As Double tWidth = Max(8, DefaultFont.Size) * 0.85
stBar.Align = DockStyle.alBottom
stBar.Add ML("Press F1 for get more information"), tWidth * 25
stBar.Add("", tWidth * 50) 'Row +Col 
stBar.Add ML("IntelliSense fully loaded"), tWidth * 27
stBar.Add "UTF-8 (BOM)", tWidth * 11
stBar.Add "CR+LF", tWidth * 6
stBar.Add "NUM", tWidth * 4
stBar.Panels[0]->Width = Max(stBar.Width - 50 - stBar.Panels[1]->Width - stBar.Panels[2]->Width - stBar.Panels[3]->Width  - stBar.Panels[4]->Width - stBar.Panels[5]->Width, 20)
Var spProgress = stBar.Add("")
spProgress->Width = stBar.Panels[2]->Width + 3
prProgress.Width = stBar.Panels[2]->Width + 3
prProgress.Visible = False
prProgress.Marquee = True

#ifdef __USE_GTK__
	prProgress.Height = 30
	gtk_box_pack_end (GTK_BOX (gtk_statusbar_get_message_area (GTK_STATUSBAR(stBar.Handle))), prProgress.Handle, False, True, 10)
#else
	prProgress.SetMarquee True, 100
	prProgress.Top = 3
	prProgress.Parent = @stBar
#endif

'stBar.Add ""
'stBar.Panels[1]->Alignment = 1

Function HK(Key As String, Default As String = "", WithSpace As Boolean = False) As String
	Dim As String HotKey = HotKeys.Get(Key, Default)
	If HotKey = "" Then
		Return ""
	ElseIf WithSpace Then
		Return " (" & HotKey & ")"
	Else
		Return !"\t" & HotKey
	End If
End Function

Sub GDBCommand
	fTheme.Text = ML("GDB Command")
	fTheme.lblThemeName.Text = ML("Type command:")
	If fTheme.ShowModal(frmMain) = ModalResults.OK Then
		'ShowResult = True
		#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
			command_debug fTheme.txtThemeName.Text
		#endif
	End If
End Sub

Sub CreateMenusAndToolBars
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("Create Menus And ToolBars")
	imgList.Name = "imgList"
	imgList.Add "StartWithCompile", "StartWithCompile"
	imgList.Add "Start", "Start"
	imgList.Add "Break", "Break"
	imgList.Add "EndProgram", "EndProgram"
	imgList.Add "New", "New"
	imgList.Add "Open", "Open"
	imgList.Add "Save", "Save"
	imgList.Add "SaveAll", "SaveAll"
	imgList.Add "Close", "Close"
	imgList.Add "Exit", "Exit"
	imgList.Add "Undo", "Undo"
	imgList.Add "Redo", "Redo"
	imgList.Add "Cut", "Cut"
	imgList.Add "Copy", "Copy"
	imgList.Add "Paste", "Paste"
	imgList.Add "Find", "Find"
	imgList.Add "Code", "Code"
	imgList.Add "CompleteWord", "CompleteWord"
	imgList.Add "Console", "Console"
	imgList.Add "Form", "Form"
	imgList.Add "MainForm", "MainForm"
	imgList.Add "Format", "Format"
	imgList.Add "Unformat", "Unformat"
	imgList.Add "Numbering", "Numbering"
	imgList.Add "CodeAndForm", "CodeAndForm"
	imgList.Add "SyntaxCheck", "SyntaxCheck"
	imgList.Add "List", "List"
	imgList.Add "UseDebugger", "UseDebugger"
	imgList.Add "Compile", "Compile"
	imgList.Add "Make", "Make"
	imgList.Add "Book", "Book"
	imgList.Add "About", "About"
	imgList.Add "Session", "Session"
	imgList.Add "File", "File"
	imgList.Add "MainFile", "MainFile"
	imgList.Add "Resource", "Resource"
	imgList.Add "MainResource", "MainResource"
	imgList.Add "Module", "Module"
	imgList.Add "MainModule", "MainModule"
	imgList.Add "NotSetted", "NotSetted"
	imgList.Add "UserControl", "UserControl"
	imgList.Add "Eraser", "Eraser"
	imgList.Add "Pin", "Pin"
	imgList.Add "Pinned", "Pinned"
	imgList.Add "ParameterInfo", "ParameterInfo"
	imgList.Add "Parameters", "Parameters"
	imgList.Add "Folder", "Folder"
	imgList.Add "MainProject", "MainProject"
	imgList.Add "Project", "Project"
	imgList.Add "Apply", "Apply"
	imgList.Add "Add", "Add"
	imgList.Add "Remove", "Remove"
	imgList.Add "Error", "Error"
	imgList.Add "Warning", "Warning"
	imgList.Add "Info", "Info"
	imgList.Add "Label", "Label"
	imgList.Add "Component", "Component"
	imgList.Add "Property", "Property"
	imgList.Add "Sub", "Sub"
	imgList.Add "Bookmark", "Bookmark"
	imgList.Add "Breakpoint", "Breakpoint"
	imgList.Add "B32", "B32"
	imgList.Add "B64", "B64"
	imgList.Add "Opened", "Opened"
	imgList.Add "Tools", "Tools"
	imgList.Add "StandartTypes", "StandartTypes"
	imgList.Add "Enum", "Enum"
	imgList.Add "Type", "Type"
	imgList.Add "Function", "Function"
	imgList.Add "Event", "Event"
	imgList.Add "Collapsed", "Collapsed"
	imgList.Add "Categorized", "Categorized"
	imgList.Add "BlockComment", "BlockComment"
	imgList.Add "Comment", "Comment"
	imgList.Add "UnComment", "UnComment"
	imgList.Add "Print", "Print"
	imgList.Add "PrintPreview", "PrintPreview"
	imgList.Add "FileError", "FileError"
	imgList.Add "Up", "Up"
	imgList.Add "Down", "Down"
	imgList.Add "Sort", "Sort"
	imgList.Add "EnumItem", "EnumItem"
	imgList.Add "Update", "Update"
	imgList.Add "Forum", "Forum"
	imgList.Add "Fixme", "Fixme"
	imgList.Add "Suggestions", "Suggestions"
	imgList.Add "DarkMode", "DarkMode"
	imgList.Add "FindSymbol", "FindSymbol"
	imgList.Add "NewChat", "NewChat"
	imgList.Add "AddComment", "AddComment"
	imgList.Add "TracepointError", "TracepointError"
	imgList.Add "Intellicode", "Intellicode"
	imgList.Add "OptimizeCode", "OptimizeCode"
	imgList.Add "ConvertC", "ConvertC"
	imgList.Add "Translate", "Translate"
	imgList.Add "TranslateE", "TranslateE"
	imgList.Add "WebBrowserItem", "WebBrowserItem"
	imgList.Add "UseDirect2D", "UseDirect2D"
	
	'imgListD.Add "StartWithCompileD", "StartWithCompile"
	'imgListD.Add "StartD", "Start"
	'imgListD.Add "BreakD", "Break"
	'imgListD.Add "EndD", "EndProgram"
	imgList32.Name = "imgList32"
	imgList32.ImageWidth = 32
	imgList32.ImageHeight = 32
	imgList32.Add "AppWindows", "AppWindows"
	imgList32.Add "AppAndroid", "AppAndroid"
	imgList32.Add "AppAddin", "AppAddin"
	imgList32.Add "AppControl", "AppControl"
	imgList32.Add "AppConsole", "AppConsole"
	imgList32.Add "AppGUI", "AppGUI"
	imgList32.Add "AppDynamic", "AppDynamic"
	imgList32.Add "AppStatic", "AppStatic"
	imgList32.Add "AppGTK", "AppGTK"
	imgList32.Add "AppEmpty", "AppEmpty"
	imgList32.Add "File32", "File32"
	imgList32.Add "Resource32", "Resource32"
	imgList32.Add "Module32", "Module32"
	imgList32.Add "UserControl32", "UserControl32"
	imgList32.Add "Form32", "Form32"
	imgList32.Add "Form3D32", "Form3D32"
	imgList32.Add "FormRC", "FormRC"
	imgList32.Add "Manifest32", "Manifest32"
	
	'mnuMain.ImagesList = @imgList
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("Load Hot Keys")
	LoadHotKeys
	Var miFile = mnuMain.Add(ML("&File"), "", "File")
	miFile->Add(ML("&New Project") & HK("NewProject", "Ctrl+Shift+N"), "Project", "NewProject", @mClick)
	miFile->Add("-")
	miFile->Add(ML("&New") & HK("New", "Ctrl+N"), "New", "New", @mClick)
	miFile->Add(ML("&Open") & "..." & HK("Open", "Ctrl+O"), "Open", "Open", @mClick)
	'miFile->Add(ML("New Project") & HK("NewProject", "Ctrl+Shift+N"), "Project", "NewProject", @mClick)
	'miFile->Add(ML("Open Project") & HK("OpenProject", "Ctrl+Shift+O"), "", "OpenProject", @mClick)
	miFile->Add("-")
	miSaveProject = miFile->Add(ML("Save Project") & "..." & HK("SaveProject", "Ctrl+Shift+S"), "SaveAll", "SaveProject", @mClick, , , False)
	miSaveProjectAs = miFile->Add(ML("Save Project As") & "..." & HK("SaveProjectAs"), "", "SaveProjectAs", @mClick, , , False)
	miCloseProject = miFile->Add(ML("Close Project") & HK("CloseProject", "Ctrl+Shift+F4"), "", "CloseProject", @mClick, , , False)
	miFile->Add("-")
	miFile->Add(ML("Open Session") & HK("OpenSession", "Ctrl+Alt+O"), "", "OpenSession", @mClick)
	miFile->Add(ML("Save Session") & HK("SaveFolder", "Ctrl+Alt+S"), "", "SaveSession", @mClick)
	miFile->Add("-")
	miFile->Add(ML("Open Folder") & HK("OpenFolder", "Alt+O"), "", "OpenFolder", @mClick)
	miCloseFolder = miFile->Add(ML("Close Folder") & HK("CloseFolder", "Alt+F4"), "", "CloseFolder", @mClick, , , False)
	miFile->Add("-")
	miSave = miFile->Add(ML("&Save") & "..." & HK("Save", "Ctrl+S"), "Save", "Save", @mClick, , , False)
	miSaveAs = miFile->Add(ML("Save &As") & "..." & HK("SaveAs"), "", "SaveAs", @mClick, , , False)
	miSaveAll = miFile->Add(ML("Save All") & HK("SaveAll", "Ctrl+Alt+Shift+S"), "SaveAll", "SaveAll", @mClick, , , False)
	miFile->Add("-")
	miClose = miFile->Add(ML("&Close") & HK("Close", "Ctrl+F4"), "Close", "Close", @mClick, , , False)
	miCloseAll = miFile->Add(ML("Close All") & HK("CloseAll", "Ctrl+Shift+F4"), "", "CloseAll", @mClick, , , False)
	miCloseSession = miFile->Add(ML("Close Session") & HK("CloseSession", "Ctrl+Alt+Shift+F4"), "", "CloseSession", @mClick, , , False)
	miFile->Add("-")
	miPrint = miFile->Add(ML("&Print") & HK("Print", "Ctrl+P"), "Print", "Print", @mClick, , , False)
	miPrintPreview = miFile->Add(ML("Print P&review") & HK("PrintPreview"), "PrintPreview", "PrintPreview", @mClick, , , False)
	miPageSetup = miFile->Add(ML("Page Set&up") & "..." & HK("PageSetup"), "", "PageSetup", @mClick, , , False)
	miFile->Add("-")
	Var miFileFormat = miFile->Add(ML("File format"))
	miPlainText = miFileFormat->Add(ML("Encoding") & ": " & ML("Plain text") & HK("PlainText"), "", "PlainText", @mClick, True)
	miUtf8 = miFileFormat->Add(ML("Encoding") & ": " & ML("Utf8") & HK("Utf8"), "", "Utf8", @mClick, True)
	miUtf8BOM = miFileFormat->Add(ML("Encoding") & ": " & ML("Utf8 (BOM)") & HK("Utf8BOM"), "", "Utf8BOM", @mClick, True)
	miUtf16BOM = miFileFormat->Add(ML("Encoding") & ": " & ML("Utf16 (BOM)") & HK("Utf16BOM"), "", "Utf16BOM", @mClick, True)
	miUtf32BOM = miFileFormat->Add(ML("Encoding") & ": " & ML("Utf32 (BOM)") & HK("Utf32BOM"), "", "Utf32BOM", @mClick, True)
	miFileFormat->Add("-")
	miWindowsCRLF = miFileFormat->Add(ML("Newline") & ": " & ML("Windows (CRLF)") & HK("WindowsCRLF"), "", "WindowsCRLF", @mClick, True)
	miLinuxLF = miFileFormat->Add(ML("Newline") & ": " & ML("Linux (LF)") & HK("LinuxLF"), "", "LinuxLF", @mClick, True)
	miMacOSCR = miFileFormat->Add(ML("Newline") & ": " & ML("MacOS (CR)") & HK("MacOSCR"), "", "MacOSCR", @mClick, True)
	miUtf8BOM->Checked = True
	#ifdef __FB_WIN32__
		miWindowsCRLF->Checked = True
	#else
		miLinuxLF->Checked = True
	#endif
	miFile->Add("-")
	
	'David Change  Add Recent Sessions
	miRecentSessions = miFile->Add(ML("Recent Sessions"), "", "RecentSessions", @mClick)
	Dim sTmp As WString * 1024
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUSessions", "MRUSession_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUSessions.Add sTmp
			miRecentSessions->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentSessions->Add("-")
	miRecentSessions->Add(ML("Clear Recently Opened"),"","ClearSessions", @mClickMRU)
	
	miRecentFolders = miFile->Add(ML("Recent Folders"), "", "RecentFolders", @mClick)
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUFolders", "MRUFolder_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUFolders.Add sTmp
			miRecentFolders->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentFolders->Add("-")
	miRecentFolders->Add(ML("Clear Recently Opened"),"","ClearFolders", @mClickMRU)
	
	' Add Recent Sessions
	miRecentProjects = miFile->Add(ML("Recent Projects"), "", "RecentProjects", @mClick)
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUProjects", "MRUProject_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUProjects.Add sTmp
			miRecentProjects->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentProjects->Add("-")
	miRecentProjects->Add(ML("Clear Recently Opened"),"","ClearProjects", @mClickMRU)
	
	miRecentFiles = miFile->Add(ML("Recent Files"), "", "RecentFiles", @mClick)
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUFiles", "MRUFile_0" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			MRUFiles.Add sTmp
			miRecentFiles->Add(sTmp, "", sTmp, @mClickMRU)
		End If
	Next
	miRecentFiles->Add("-")
	miRecentFiles->Add(ML("Clear Recently Opened"), "", "ClearFiles", @mClickMRU)
	
	mnuAIChat.Add(ML("&Edit"), "Edit", "AIChatEdit", @mClickAIChat, , , True)
	mnuAIChat.Add("-")
	mnuAIChat.Add(ML("&Open") & "..." , "Open", "AIChatOpen", @mClickAIChat, , , True)
	mnuAIChat.Add("-")
	mnuAIChat.Add(ML("&Save") , "Save", "AIChatSave", @mClickAIChat, , , True)
	mnuAIChat.Add(ML("Save &As") & "...", "", "AIChatSaveAs", @mClickAIChat, , , True)
	mnuAIChat.Add("-")
	miRecentAIChat = mnuAIChat.Add(ML("Recent Files"), "", "RecentFiles", @mClickAIChat)
	For i As Integer = 0 To miRecentMax
		sTmp = iniSettings.ReadString("MRUAIChat", "MRUAIChat_0" & WStr(i), "")
		If Trim(sTmp) <> "" AndAlso Dir(ExePath & "/AIChat/" & sTmp) <> "" Then
			MRUAIChat.Add sTmp
			miRecentAIChat->Add(sTmp, "", sTmp, @mClickAIChat)
		End If
	Next
	miRecentAIChat->Add("-")
	miRecentAIChat->Add(ML("Clear Recently Opened"), "", "ClearAIChat", @mClickAIChat)
	
	miFile->Add("-")
	miFile->Add(ML("&Command Prompt") & HK("CommandPrompt", "Alt+C"), "Console", "CommandPrompt", @mClick)
	miFile->Add("-")
	miFile->Add(ML("&Exit") & HK("Exit", "Alt+F4"), "Exit", "Exit", @mClick)
	
	Var miEdit = mnuMain.Add(ML("&Edit"), "", "Tahrir")
	miUndo = miEdit->Add(ML("Undo") & HK("Undo", "Ctrl+Z"), "Undo", "Undo", @mClick, , , False)
	miRedo = miEdit->Add(ML("Redo") & HK("Redo", "Ctrl+Shift+Z"), "Redo", "Redo", @mClick, , , False)
	miEdit->Add("-")
	miCutCurrentLine = miEdit->Add(ML("C&ut Current Line") & HK("CutCurrentLine", "Ctrl+Y"), "", "CutCurrentLine", @mClick, , , False)
	miCut = miEdit->Add(ML("Cu&t") & HK("Cut", "Ctrl+X"), "Cut", "Cut", @mClick, , , False)
	miCopy = miEdit->Add(ML("&Copy") & HK("Copy", "Ctrl+C"), "Copy", "Copy", @mClick, , , False)
	miPaste = miEdit->Add(ML("&Paste") & HK("Paste", "Ctrl+V"), "Paste", "Paste", @mClick, , , False)
	miEdit->Add("-")
	miSingleComment = miEdit->Add(ML("&Single Comment") & HK("SingleComment", "Ctrl+I"), "Comment", "SingleComment", @mClick, , , False)
	miBlockComment = miEdit->Add(ML("&Block Comment") & HK("BlockComment", "Ctrl+Alt+I"), "BlockComment", "BlockComment", @mClick, , , False)
	miUncommentBlock = miEdit->Add(ML("&Uncomment Block") & HK("UnComment", "Ctrl+Shift+I"), "UnComment", "UnComment", @mClick, , , False)
	miEdit->Add("-")
	miDuplicate = miEdit->Add(ML("&Duplicate") & HK("Duplicate", "Ctrl+D"), "", "Duplicate", @mClick, , , False)
	miEdit->Add("-")
	miSelectAll = miEdit->Add(ML("Select &All") & HK("SelectAll", "Ctrl+A"), "", "SelectAll", @mClick, , , False)
	miEdit->Add("-")
	miIndent = miEdit->Add(ML("&Indent") & HK("Indent", "Tab"), "", "Indent", @mClick, , , False)
	miOutdent = miEdit->Add(ML("&Outdent") & HK("Outdent", "Shift+Tab"), "", "Outdent", @mClick, , , False)
	miEdit->Add("-")
	miFormat = miEdit->Add(ML("&Format") & HK("Format", "Ctrl+Tab"), "Format", "Format", @mClick, , , False)
	miUnformat = miEdit->Add(ML("&Unformat") & HK("Unformat", "Ctrl+Shift+Tab"), "Unformat", "Unformat", @mClick, , , False)
	miFormatProject = miEdit->Add(ML("&Format Project") & HK("FormatProject"), "", "FormatProject", @mClick, , , False)
	miUnformatProject = miEdit->Add(ML("&Unformat Project") & HK("UnformatProject"), "", "UnformatProject", @mClick, , , False)
	miAddSpaces = miEdit->Add(ML("Add &Spaces") & HK("AddSpaces"), "", "AddSpaces", @mClick, , , False)
	miDeleteBlankLines = miEdit->Add(ML("Merge Multiple Blank Lines"), "", "DeleteBlankLines", @mClick)
	miEdit->Add("-")
	miSuggestions = miEdit->Add(ML("Suggestions") & HK("Suggestions"), "Suggestions", "Suggestions", @mClick, , , False)
	miCompleteWord = miEdit->Add(ML("Complete Word") & HK("CompleteWord", "Ctrl+Space"), "CompleteWord", "CompleteWord", @mClick, , , False)
	miParameterInfo = miEdit->Add(ML("Parameter Info") & HK("ParameterInfo", "Ctrl+J"), "ParameterInfo", "ParameterInfo", @mClick, , , False)
	miEdit->Add("-")
	Var miTry = miEdit->Add(ML("Error Handling"), "", "Try")
	miNumbering = miTry->Add(ML("Numbering") & HK("NumberOn"), "Numbering", "NumberOn", @mClick, , , False)
	miMacroNumbering = miTry->Add(ML("Macro numbering") & HK("MacroNumberOn"), "", "MacroNumberOn", @mClick, , , False)
	miRemoveNumbering = miTry->Add(ML("Remove Numbering") & HK("NumberOff"), "", "NumberOff", @mClick, , , False)
	miTry->Add("-")
	miPreprocessorNumbering = miTry->Add(ML("Preprocessor numbering") & HK("PreprocessorNumberOn"), "Numbering", "PreprocessorNumberOn", @mClick, , , False)
	miRemovePreprocessorNumbering = miTry->Add(ML("Remove Preprocessor numbering") & HK("PreprocessorNumberOff"), "", "PreprocessorNumberOff", @mClick, , , False)
	miTry->Add("-")
	miProcedureNumbering = miTry->Add(ML("Procedure numbering") & HK("ProcedureNumberOn"), "Numbering", "ProcedureNumberOn", @mClick, , , False)
	miProcedureMacroNumbering = miTry->Add(ML("Procedure macro numbering") & HK("ProcedureMacroNumberOn"), "", "ProcedureMacroNumberOn", @mClick, , , False)
	miRemoveProcedureNumbering = miTry->Add(ML("Remove Procedure numbering") & HK("ProcedureNumberOff"), "", "ProcedureNumberOff", @mClick, , , False)
	miTry->Add("-")
	miModuleMacroNumbering = miTry->Add(ML("Module macro numbering") & HK("ModuleMacroNumberOn"), "Numbering", "ModuleMacroNumberOn", @mClick, , , False)
	miModuleMacroNumberingStartsOfProcedures = miTry->Add(ML("Module macro numbering: Starts of procedures") & HK("ModuleMacroNumberOnStartsOfProcs"), "", "ModuleMacroNumberOnStartsOfProcs", @mClick, , , False)
	miRemoveModuleNumbering = miTry->Add(ML("Remove Module numbering") & HK("ModuleNumberOff"), "", "ModuleNumberOff", @mClick, , , False)
	miTry->Add("-")
	miModulePreprocessorNumbering = miTry->Add(ML("Module preprocessor numbering") & HK("ModulePreprocessorNumberOn"), "Numbering", "ModulePreprocessorNumberOn", @mClick, , , False)
	miRemoveModulePreprocessorNumbering = miTry->Add(ML("Remove Module preprocessor numbering") & HK("ModulePreprocessorNumberOff"), "", "ModulePreprocessorNumberOff", @mClick, , , False)
	miTry->Add("-")
	miProjectMacroNumbering = miTry->Add(ML("Project macro numbering") & HK("ProjectMacroNumberOn"), "Numbering", "ProjectMacroNumberOn", @mClick, , , False)
	miProjectMacroNumberingStartsOfProcedures = miTry->Add(ML("Project macro numbering: Starts of procedures") & HK("ProjectMacroNumberOnStartsOfProcs"), "", "ProjectMacroNumberOnStartsOfProcs", @mClick, , , False)
	miRemoveProjectNumbering = miTry->Add(ML("Remove Project numbering") & HK("ProjectNumberOff"), "", "ProjectNumberOff", @mClick, , , False)
	miTry->Add("-")
	miProjectPreprocessorNumbering = miTry->Add(ML("Project preprocessor numbering") & HK("ProjectPreprocessorNumberOn"), "Numbering", "ProjectPreprocessorNumberOn", @mClick, , , False)
	miRemoveProjectPreprocessorNumbering = miTry->Add(ML("Remove Project preprocessor numbering") & HK("ProjectPreprocessorNumberOff"), "", "ProjectPreprocessorNumberOff", @mClick, , , False)
	miTry->Add("-")
	'miOnErrorResumeNext = miTry->Add("On Error Resume Next" & HK("OnErrorResumeNext"), "", "OnErrorResumeNext", @mClick, , , False)
	miOnErrorGoto = miTry->Add("On Error Goto ..." & HK("OnErrorGoto"), "", "OnErrorGoto", @mClick, , , False)
	miOnErrorGotoResumeNext = miTry->Add("On Error Goto ... Resume Next" & HK("OnErrorGotoResumeNext"), "", "OnErrorGotoResumeNext", @mClick, , , False)
	miOnLocalErrorGoto = miTry->Add("On Local Error Goto ..." & HK("OnLocalErrorGoto"), "", "OnLocalErrorGoto", @mClick, , , False)
	miOnLocalErrorGotoResumeNext = miTry->Add("On Local Error Goto ... Resume Next" & HK("OnLocalErrorGotoResumeNext"), "", "OnLocalErrorGotoResumeNext", @mClick, , , False)
	miRemoveErrorHandling = miTry->Add(ML("Remove Error Handling") & HK("RemoveErrorHandling"), "", "RemoveErrorHandling", @mClick, , , False)
	
	Var miSearch = mnuMain.Add(ML("&Search"), "", "Search")
	miFind = miSearch->Add(ML("&Find") & "..." & HK("Find", "Ctrl+F"), "Find", "Find", @mClick, , , False)
	miReplace = miSearch->Add(ML("&Replace") & "..."  & HK("Replace", "Ctrl+H"), "", "Replace", @mClick, , , False)
	miFindNext = miSearch->Add(ML("Find &Next") & HK("FindNext", "F3"), "", "FindNext", @mClick, , , False)
	miFindPrevious = miSearch->Add(ML("Find &Previous") & HK("FindPrev", "Shift+F3"), "", "FindPrev", @mClick, , , False)
	miSearch->Add("-")
	miSearch->Add(ML("Find In Files") & "..." & HK("FindInFiles", "Ctrl+Shift+F"), "", "FindInFiles", @mClick)
	miSearch->Add(ML("Replace In Files") & "..." & HK("ReplaceInFiles", "Ctrl+Shift+H"), "", "ReplaceInFiles", @mClick)
	miSearch->Add("-")
	miGoto = miSearch->Add(ML("&Goto") & HK("Goto", "Ctrl+G"), "", "Goto", @mClick, , , False)
	miSearch->Add("-")
	miDefine = miSearch->Add(ML("&Define") & HK("Define", "F2"), "", "Define", @mClick, , , False)
	Var miBookmark = miSearch->Add(ML("Bookmarks"), "", "Bookmarks")
	miToggleBookmark = miBookmark->Add(ML("Toggle Bookmark") & HK("ToggleBookmark", "F6"), "Bookmark", "ToggleBookmark", @mClick, , , False)
	miNextBookmark = miBookmark->Add(ML("Next Bookmark") & HK("NextBookmark", "Ctrl+F6"), "", "NextBookmark", @mClick, , , False)
	miPreviousBookmark = miBookmark->Add(ML("Previous Bookmark") & HK("PreviousBookmark", "Ctrl+Shift+F6"), "", "PreviousBookmark", @mClick, , , False)
	miClearAllBookmarks = miBookmark->Add(ML("Clear All Bookmarks") & HK("ClearAllBookmarks"), "", "ClearAllBookmarks", @mClick, , , False)
	
	Var miView = mnuMain.Add(ML("&View"), "", "View")
	miCode = miView->Add(ML("Code") & HK("Code", "Ctrl+F7"), "Code", "Code", @mClick, , , False)
	miForm = miView->Add(ML("Form") & HK("Form", "Shift+F7"), "Form", "Form", @mClick, , , False)
	miCodeAndForm = miView->Add(ML("Code And Form") & HK("CodeAndForm", "Ctrl+Shift+F7"), "CodeAndForm", "CodeAndForm", @mClick, , , False)
	miView->Add("-")
	miGotoCodeForm = miView->Add(ML("Goto Code/Form") & HK("GotoCodeForm", "F7"), "GotoCodeForm", "GotoCodeForm", @mClick, , , False)
	miView->Add("-")
	Var miCollapse = miView->Add(ML("Collapse") & HK("Collapse"), "", "Collapse", @mClick)
	miCollapseCurrent = miCollapse->Add(ML("Current") & HK("CollapseCurrent"), "", "CollapseCurrent", @mClick, , , False)
	miCollapseAllProcedures = miCollapse->Add(ML("All procedures") & HK("CollapseAllProcedures"), "", "CollapseAllProcedures", @mClick, , , False)
	miCollapseAll = miCollapse->Add(ML("All") & HK("CollapseAll"), "", "CollapseAll", @mClick, , , False)
	Var miUnCollapse = miView->Add(ML("Uncollapse") & HK("UnCollapse"), "", "UnCollapse", @mClick)
	miUnCollapseCurrent = miUnCollapse->Add(ML("Current") & HK("UnCollapseCurrent"), "", "UnCollapseCurrent", @mClick, , , False)
	miUnCollapseAllProcedures = miUnCollapse->Add(ML("All procedures") & HK("UnCollapseAllProcedures"), "", "UnCollapseAllProcedures", @mClick, , , False)
	miUnCollapseAll = miUnCollapse->Add(ML("All") & HK("UnCollapseAll"), "", "UnCollapseAll", @mClick, , , False)
	miView->Add("-")
	miView->Add(ML("Dark Mode") & HK("DarkMode"), "DarkMode", "DarkMode", @mClick)
	miView->Add("-")
	miView->Add(ML("Project Explorer") & HK("ProjectExplorer", "Ctrl+R"), "Project", "ProjectExplorer", @mClick)
	miView->Add(ML("Properties Window") & HK("PropertiesWindow", "F4"), "Property", "PropertiesWindow", @mClick)
	miView->Add(ML("Events Window") & HK("EventsWindow", "Ctrl+E"), "Event", "EventsWindow", @mClick)
	miView->Add(ML("Toolbox") & HK("Toolbox", "Ctrl+T"), "Tools", "Toolbox", @mClick)
	Var miOtherWindows = miView->Add(ML("Other Windows"))
	miOtherWindows->Add(ML("Output Window") & HK("OutputWindow"), "", "OutputWindow", @mClick)
	miOtherWindows->Add(ML("Problems Window") & HK("ProblemsWindow"), "", "ProblemsWindow", @mClick)
	miOtherWindows->Add(ML("Suggestions Window") & HK("SuggestionsWindow"), "", "SuggestionsWindow", @mClick)
	miOtherWindows->Add(ML("Find Window") & HK("FindWindow"), "", "FindWindow", @mClick)
	miOtherWindows->Add(ML("ToDo Window") & HK("ToDoWindow"), "", "ToDoWindow", @mClick)
	miOtherWindows->Add(ML("Change Log Window") & HK("ChangeLogWindow"), "", "ChangeLogWindow", @mClick)
	miOtherWindows->Add(ML("Immediate Window") & HK("ImmediateWindow"), "", "ImmediateWindow", @mClick)
	miOtherWindows->Add(ML("Locals Window") & HK("LocalsWindow"), "", "LocalsWindow", @mClick)
	miOtherWindows->Add(ML("Globals Window") & HK("GlobalsWindow"), "", "GlobalsWindow", @mClick)
	'miOtherWindows->Add(ML("Procedures Window") & HK("ProceduresWindow"), "", "ProceduresWindow", @mclick)
	miOtherWindows->Add(ML("Threads Window") & HK("ThreadsWindow"), "", "ThreadsWindow", @mClick)
	miOtherWindows->Add(ML("Watch Window") & HK("WatchWindow"), "", "WatchWindow", @mClick)
	miView->Add("-")
	miImageManager = miView->Add(ML("Image Manager") & HK("ImageManager"), "", "ImageManager", @mClick, , , False)
	miView->Add("-")
	miToolBars = miView->Add(ML("Toolbars") & HK("Toolbars"), "", "Toolbars", @mClick)
	mnuStandardToolBar = miToolBars->Add(ML("Standard") & HK("Standard"), "", "Standard", @mClick, True)
	mnuEditToolBar = miToolBars->Add(ML("Edit") & HK("Edit"), "", "Edit", @mClick, True)
	mnuProjectToolBar = miToolBars->Add(ML("Project") & HK("Project"), "", "Project", @mClick, True)
	mnuBuildToolBar = miToolBars->Add(ML("Build") & HK("Build"), "", "Build", @mClick, True)
	mnuRunToolBar = miToolBars->Add(ML("Run") & HK("Run"), "", "Run", @mClick, True)
	
	Var miProject = mnuMain.Add(ML("&Project"), "", "Project")
	miProject->Add(ML("Add &Form") & HK("AddForm", "Ctrl+Alt+N"), "Form", "AddForm", @mClick)
	miProject->Add(ML("Add &Module") & HK("AddModule","Ctrl+Alt+M"), "Module", "AddModule", @mClick)
	miProject->Add(ML("Add &Include File") & HK("AddIncludeFile",""), "File", "AddIncludeFile", @mClick)
	miProject->Add(ML("Add &User Control") & HK("AddUserControl", "Ctrl+Alt+U"), "UserControl", "AddUserControl", @mClick)
	miProject->Add(ML("Add &Resource File") & HK("AddResoureFile",""), "Resource", "AddResourceFile", @mClick)
	miProject->Add(ML("Add Ma&nifest File") & HK("AddManifestFile",""), "File", "AddManifestFile", @mClick)
	miProject->Add(ML("Add From Templates") & "..." & HK("AddFromTemplates"), "Add", "AddFromTemplates", @mClick)
	miProject->Add(ML("Add Files") & "..." & HK("AddFilesToProject"), "Add", "AddFilesToProject", @mClick)
	miProject->Add("-")
	miRename = miProject->Add(ML("R&ename") & HK("Rename"), "Rename", "Rename", @mClick, , , False)
	miRemoveFileFromProject = miProject->Add(ML("&Remove") & HK("RemoveFileFromProject"), "Remove", "RemoveFileFromProject", @mClick, , , False)
	miProject->Add("-")
	miOpenProjectFolder = miProject->Add(ML("&Open Project Folder") & HK("OpenProjectFolder"), "", "OpenProjectFolder", @mClick, , , False)
	miProject->Add(ML("Import from Folder") & "..." & HK("OpenFolder", "Alt+O"), "", "OpenFolder", @mClick)
	miProject->Add("-")
	miProjectProperties = miProject->Add(ML("&Project Properties") & "..." & HK("ProjectProperties"), "", "ProjectProperties", @mClick, , , False)
	
	Var miBuild = mnuMain.Add(ML("&Build"), "", "Build")
	miSyntaxCheck = miBuild->Add(ML("&Syntax Check") & HK("SyntaxCheck"), "SyntaxCheck", "SyntaxCheck", @mClick, , , False)
	miBuild->Add("-")
	miCompile = miBuild->Add(ML("&Compile") & HK("Compile", "Ctrl+F9"), "Compile", "Compile", @mClick, , , False)
	miCompileAll = miBuild->Add(ML("Compile &All") & HK("CompileAll", "Ctrl+Alt+F9"), "", "CompileAll", @mClick, , , False)
	miBuild->Add("-")
	Var miBuildBundleAPK = miBuild->Add(ML("&Build Bundle / APK") & HK("BuildBundleAPK"), "", "BuildBundleAPK", @mClick)
	miBuildBundle = miBuildBundleAPK->Add(ML("Build &Bundle") & HK("BuildBundle"), "", "BuildBundle", @mClick, , , False)
	miBuildAPK = miBuildBundleAPK->Add(ML("Build &APK") & HK("BuildAPK"), "", "BuildAPK", @mClick, , , False)
	Var miGenerateSignedBundleAPK = miBuild->Add(ML("&Generate Signed Bundle / APK") & HK("GenerateSignedBundleAPK"), "", "GenerateSignedBundleAPK", @mClick)
	miGenerateSignedBundleAPK->Add(ML("Create Key Store") & HK("CreateKeyStore"), "", "CreateKeyStore", @mClick)
	miGenerateSignedBundleAPK->Add("-")
	miGenerateSignedBundle = miGenerateSignedBundleAPK->Add(ML("Generate Signed &Bundle") & HK("GenerateSignedBundle"), "", "GenerateSignedBundle", @mClick, , , False)
	miGenerateSignedAPK = miGenerateSignedBundleAPK->Add(ML("Generate Signed &APK") & HK("GenerateSignedAPK"), "", "GenerateSignedAPK", @mClick, , , False)
	miBuild->Add("-")
	miMake = miBuild->Add(ML("&Make") & HK("Make"), "Make", "Make", @mClick, , , False)
	miMakeClean = miBuild->Add(ML("Make Clea&n") & HK("MakeClean"), "", "MakeClean", @mClick, , , False)
	miBuild->Add("-")
	miBuild->Add(ML("&Parameters") & HK("Parameters"), "Parameters", "Parameters", @mClick)
	
	Var miDebug = mnuMain.Add(ML("&Debug"), "", "Debug")
	mnuUseDebugger = miDebug->Add(ML("&Use Debugger") & HK("UseDebugger"), "", "UseDebugger", @mClick, True)
	mnuUseProfiler = miDebug->Add(ML("Use &Profiler") & HK("UseProfiler"), "", "UseProfiler", @mClick, True)
	miDebug->Add("-")
	miStepInto = miDebug->Add(ML("Step &Into") & HK("StepInto", "F8"), "", "StepInto", @mClick, , , False)
	miStepOver = miDebug->Add(ML("Step &Over") & HK("StepOver", "Shift+F8"), "", "StepOver", @mClick, , , False)
	miStepOut = miDebug->Add(ML("Step O&ut") & HK("StepOut", "Ctrl+Shift+F8"), "", "StepOut", @mClick, , , False)
	miRunToCursor = miDebug->Add(ML("&Run To Cursor") & HK("RunToCursor", "Ctrl+F8"), "", "RunToCursor", @mClick, , , False)
	miDebug->Add("-")
	miGDBCommand = miDebug->Add(ML("&GDB Command") & HK("GDBCommand"), "", "GDBCommand", @mClick, , , False)
	miAddWatch = miDebug->Add(ML("&Add Watch") & HK("AddWatch"), "", "AddWatch", @mClick, , , False)
	miDebug->Add("-")
	miToggleBreakpoint = miDebug->Add(ML("&Toggle Breakpoint") & HK("Breakpoint", "F9"), "Breakpoint", "Breakpoint", @mClick, , , False)
	miClearAllBreakpoints = miDebug->Add(ML("&Clear All Breakpoints") & HK("ClearAllBreakpoints", "Ctrl+Shift+F9"), "", "ClearAllBreakpoints", @mClick, , , False)
	miDebug->Add("-")
	miSetNextStatement = miDebug->Add(ML("Set &Next Statement") & HK("SetNextStatement"), "", "SetNextStatement", @mClick, , , False)
	miShowNextStatement = miDebug->Add(ML("Show Ne&xt Statement") & HK("ShowNextStatement"), "", "ShowNextStatement", @mClick, , , False)
	
	Var miRun = mnuMain.Add(ML("&Run"), "", "Run")
	mnuStartWithCompile = miRun->Add(ML("Start With &Compile") & HK("StartWithCompile", "F5"), "StartWithCompile", "StartWithCompile", @mClick, , , False)
	mnuStart = miRun->Add(ML("&Start") & HK("Start", "Ctrl+F5"), "Start", "Start", @mClick, , , False)
	mnuBreak = miRun->Add(ML("&Break") & HK("Break", "Ctrl+Break"), "Break", "Break", @mClick, , , False)
	mnuEnd = miRun->Add(ML("&End") & HK("End"), "EndProgram", "End", @mClick, , , False)
	mnuRestart = miRun->Add(ML("&Restart") & HK("Restart", "Shift+F5"), "", "Restart", @mClick, , , False)
	
	miXizmat = mnuMain.Add(ML("Servi&ce"), "", "Service")
	miAddProcedure = miXizmat->Add(ML("Add &Procedure") & "..." & HK("AddProcedure"), "", "AddProcedure", @mClick, , , False)
	miAddType = miXizmat->Add(ML("Add &Type") & "..." & HK("AddType"), "", "AddType", @mClick, , , False)
	miXizmat->Add("-")
	miXizmat->Add(ML("&Add-Ins") & "..." & HK("AddIns"), "", "AddIns", @mClick)
	miXizmat->Add("-")
	miXizmat->Add(ML("&Tools") & "..." & HK("Tools"), "", "Tools", @mClick)
	miXizmat->Add("-")
	Dim As My.Sys.Drawing.BitmapType Bitm
	Dim As WString * 1024 Buff
	Dim As MenuItem Ptr mi
	Dim As UserToolType Ptr tt
	Dim As WString * 260 ToolsINI
	#ifdef __USE_GTK__
		ToolsINI = ExePath & "/Tools/ToolsX.ini"
	#else
		ToolsINI = ExePath & "/Tools/Tools.ini"
	#endif
	If FileExists(ToolsINI) Then
		Dim As Integer Fn = FreeFile_
		Open ToolsINI For Input Encoding "utf8" As #Fn
		Do Until EOF(Fn)
			Line Input #Fn, Buff
			If StartsWith(Buff, "Path=") Then
				tt = _New( UserToolType)
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
						Dim As HICON IcoHandle
						ExtractIconEx(GetFullPath(tt->Path), NULL, NULL, @IcoHandle, 1)
						Bitm = IcoHandle
						DestroyIcon IcoHandle
					#endif
					mi = miXizmat->Add(tt->Name & !"\t" & tt->Accelerator, Bitm, "Tools", @mClickTool)
					Bitm.Handle = 0
					mi->Tag = tt
				ElseIf StartsWith(Buff, "LoadType=") Then
					tt->LoadType = Cast(LoadTypes, Val(Mid(Buff, 10)))
				ElseIf StartsWith(Buff, "WaitComplete=") Then
					tt->WaitComplete = Cast(Boolean, Mid(Buff, 14))
				End If
			End If
		Loop
		CloseFile_(Fn)
	End If
	miXizmat->Add("-")
	miXizmat->Add(ML("&Options") & HK("Options"), "Tools", "Options", @mClick)
	
	miWindow = mnuMain.Add(ML("&Window"), "", "Window")
	mnuSplitHorizontally = miWindow->Add(ML("Split &Horizontally") & HK("SplitHorizontally"), "", "SplitHorizontally", @mClick, True, , False)
	mnuSplitVertically = miWindow->Add(ML("Split &Vertically") & HK("SplitVertically"), "", "SplitVertically", @mClick, True, , False)
	mnuWindowSeparator = miWindow->Add("-")
	mnuWindowSeparator->Visible = False
	
	Var miHelp = mnuMain.Add(ML("&Help"), "", "Help")
	miHelp->Add(ML("&Content") & HK("Content", "F1"), "Book", "Content", @mClick)
	miHelps = miHelp->Add(ML("&Others"), "", "Others")
	Dim As WString * 1024 sTmp2
	For i As Integer = 0 To pHelps->Count - 1
		sTmp = pHelps->Item(i)->Key 'iniSettings.ReadString("Helps", "Version_" & WStr(i), "")
		sTmp2 = pHelps->Item(i)->Text 'iniSettings.ReadString("Helps", "Path_" & WStr(i), "")
		If Trim(sTmp) <> "" Then
			miHelps->Add(Trim(sTmp) & HK(sTmp), sTmp2, sTmp, @mClickHelp)
		End If
	Next
	miHelp->Add("-")
	miHelp->Add(ML("FreeBasic WiKi") & HK("FreeBasicWiKi"), "Book", "FreeBasicWiKi", @mClick)
	miHelp->Add(ML("FreeBasic Forums") & HK("FreeBasicForums"), "Forum", "FreeBasicForums", @mClick)
	Var miGitHub = miHelp->Add(ML("GitHub"))
	miGitHub->Add(ML("FreeBasic Repository") & HK("FreeBasicRepository"), "", "FreeBasicRepository", @mClick)
	miGitHub->Add("-")
	miGitHub->Add(ML("VisualFBEditor Repository") & HK("VisualFBEditorRepository"), "", "VisualFBEditorRepository", @mClick)
	miGitHub->Add(ML("VisualFBEditor WiKi") & HK("VisualFBEditorWiKi"), "Book", "VisualFBEditorWiKi", @mClick)
	miGitHub->Add(ML("VisualFBEditor Discussions") & HK("VisualFBEditorDiscussions"), "Forum", "VisualFBEditorDiscussions", @mClick)
	miGitHub->Add("-")
	miGitHub->Add(ML("MyFbFramework Repository") & HK("MyFbFrameworkRepository"), "", "MyFbFrameworkRepository", @mClick)
	miGitHub->Add(ML("MyFbFramework WiKi") & HK("MyFbFrameworkWiKi"), "Book", "MyFbFrameworkWiKi", @mClick)
	miGitHub->Add(ML("MyFbFramework Discussions") & HK("MyFbFrameworkDiscussions"), "Forum", "MyFbFrameworkDiscussions", @mClick)
	miHelp->Add("-")
	miHelp->Add(ML("Tip of the Day"), "Book", "TipoftheDay", @mClick)
	miHelp->Add("-")
	miHelp->Add(ML("&About") & HK("About"), "About", "About", @mClick)
	
	'mnuForm.ImagesList = @imgList '<m>
	mnuForm.Add(ML("Cu&t"), "Cut", "Cut", @mClick)
	mnuForm.Add(ML("&Copy"), "Copy", "Copy", @mClick)
	mnuForm.Add(ML("&Paste"), "Paste", "Paste", @mClick)
	
	'mnuTabs.ImagesList = @imgList '<m>
	miTabSetAsMain = mnuTabs.Add(ML("&Set as Main"), "", "SetAsMain", @mClick)
	miTabReloadHistoryCode = mnuTabs.Add(ML("&Reload History Code"), "", "ReloadHistoryCode", @mClick)
	mnuTabs.Add("-")
	mnuTabs.Add(ML("&Close"), "Close", "Close", @mClick)
	mnuTabs.Add(ML("Close All Without Current"), "", "CloseAllWithoutCurrent", @mClick)
	mnuTabs.Add(ML("Close &All"), "", "CloseAll", @mClick)
	mnuTabs.Add("-")
	mnuTabs.Add(ML("Split Up"), "", "SplitUp", @mClick)
	mnuTabs.Add(ML("Split Down"), "", "SplitDown", @mClick)
	mnuTabs.Add(ML("Split Left"), "", "SplitLeft", @mClick)
	mnuTabs.Add(ML("Split Right"), "", "SplitRight", @mClick)
	mnuTabs.Add("-")
	mnuTabs.Add(ML("Split &Horizontally"), "", "SplitHorizontally", @mClick)
	mnuTabs.Add(ML("Split &Vertically"), "", "SplitVertically", @mClick)
	
	'mnuVars.ImagesList = @imgList '<m>
	mnuVars.Add(ML("Variable Dump"), "", "VariableDump", @mClick)
	mnuVars.Add(ML("Pointed data Dump"), "", "PointedDataDump", @mClick)
	mnuVars.Add("-")
	mnuVars.Add(ML("Show String"), "", "ShowString", @mClick)
	mnuVars.Add(ML("Show/Expand Variable"), "", "ShowExpandVariable", @mClick)
	
	mnuWatch.Add(ML("Memory Dump"), "", "MemoryDumpWatch", @mClick)
	mnuWatch.Add("-")
	mnuWatch.Add(ML("Show String"), "", "ShowStringWatch", @mClick)
	mnuWatch.Add(ML("Show/Expand Variable"), "", "ShowExpandVariableWatch", @mClick)
	
	mnuProblems.Add(ML("Copy "), "", "ProblemsCopy", @mClick)
	mnuProblems.Add(ML("Copy All"), "", "ProblemsCopyAll", @mClick)
	
	mnuProcedures.Add(ML("Locate procedure (source)"), "", "LocateProcedure", @mClick)
	mnuProcedures.Add(ML("Toggle sort by module or by procedure"), "", "ToggleSort", @mClick)
	mnuProcedures.Add("-")
	mnuProcedures.Add(ML("Enable/disable"), "", "EnableDisable", @mClick)
	
	'mnuExplorer.ImagesList = @imgList '<m>
	miSetAsMain = mnuExplorer.Add(ML("&Set As Main"), "", "SetAsMain", @mClick)
	miClearStartUp = mnuExplorer.Add(ML("&Clear Start Up"), "", "ClearStartUp", @mClick)
	mnuExplorer.Add("-")
	Var miAdd = mnuExplorer.Add(ML("&Add"), "Add", "Add", @mClick)
	miAdd->Add(ML("Add &Form"), "Form", "AddForm", @mClick)
	miAdd->Add(ML("Add &Module"), "Module", "AddModule", @mClick)
	miAdd->Add(ML("Add &Include File"), "File", "AddIncludeFile", @mClick)
	miAdd->Add(ML("Add &User Control"), "UserControl", "AddUserControl", @mClick)
	miAdd->Add(ML("Add &Resource File"), "Resource", "AddResourceFile", @mClick)
	miAdd->Add(ML("Add Ma&nifest File"), "File", "AddManifestFile", @mClick)
	miAdd->Add(ML("Add From Templates") & "...", "", "AddFromTemplates", @mClick)
	miAdd->Add(ML("Add Files") & "...", "", "AddFilesToProject", @mClick)
	miExplorerRename = mnuExplorer.Add(ML("Rename"), "", "Rename", @mClick, , , False)
	miRemoveFiles = mnuExplorer.Add(ML("&Remove"), "Remove", "RemoveFileFromProject", @mClick)
	mnuExplorer.Add("-")
	miExplorerOpenProjectFolder = mnuExplorer.Add(ML("Open Project Folder"), "", "OpenProjectFolder", @mClick, , , False)
	miExplorerCloseProject = mnuExplorer.Add(ML("Close Project"), "", "CloseProject", @mClick, , , False)
	mnuExplorer.Add("-")
	miExplorerProjectProperties = mnuExplorer.Add(ML("Project &Properties") & "...", "", "ProjectProperties", @mClick, , , False)
	
	'txtCommands.Left = 300
	'txtCommands.AnchorRight = asAnchor
	'cboCommands.ImagesList = @imgList
	'txtCommands.Style = cbDropDown
	'txtCommands.Align = 3
	'txtCommands.Items.Add "fdfd"
	
	tbStandard.Name = "Standard"
	tbStandard.ImagesList = @imgList
	tbStandard.HotImagesList = @imgList
	'tbStandard.DisabledImagesList = @imgListD
	'	#ifdef __USE_GTK__
	'		tbStandard.Align = 3
	'	#endif
	tbStandard.Flat = True
	tbStandard.List = True
	tbStandard.Buttons.Add tbsAutosize, "New", , @mClick, "New", , ML("New") & HK("New", "Ctrl+N", True), True
	tbStandard.Buttons.Add , "Open", , @mClick, "Open", , ML("Open") & HK("Open", "Ctrl+O", True), True
	tbtSave = tbStandard.Buttons.Add(, "Save", , @mClick, "Save", , ML("Save") & "..." & HK("Save", "Ctrl+S", True), True, ToolButtonState.tstNone)
	tbtSaveAll = tbStandard.Buttons.Add(, "SaveAll", , @mClick, "SaveAll", , ML("Save &All") & HK("SaveAll", "Ctrl+Alt+Shift+S", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbtUndo = tbStandard.Buttons.Add(, "Undo", , @mClick, "Undo", , ML("Undo") & HK("Undo", "Ctrl+Z", True), True, ToolButtonState.tstNone)
	tbtRedo = tbStandard.Buttons.Add(, "Redo", , @mClick, "Redo", , ML("Redo") & HK("Redo", "Ctrl+Shift+Z", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbtCut = tbStandard.Buttons.Add(, "Cut", , @mClick, "Cut", , ML("Cut") & HK("Cut", "Ctrl+X", True), True, ToolButtonState.tstNone)
	tbtCopy = tbStandard.Buttons.Add(, "Copy", , @mClick, "Copy", , ML("Copy") & HK("Copy", "Ctrl+C", True), True, ToolButtonState.tstNone)
	tbtPaste = tbStandard.Buttons.Add(, "Paste", , @mClick, "Paste", , ML("Paste") & HK("Paste", "Ctrl+V", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbtFind = tbStandard.Buttons.Add(, "Find", , @mClick, "Find", , ML("Find") & HK("Find", "Ctrl+F", True), True, ToolButtonState.tstNone)
	tbStandard.Buttons.Add tbsSeparator
	tbStandard.Buttons.Add(, "DarkMode", , @mClick, "DarkMode", , ML("Dark Mode") & HK("DarkMode"), True)
	tbtUseDirect2D = tbStandard.Buttons.Add(tbsCheck, "UseDirect2D", , @mClick, "UseDirect2D", , ML("Use Direct2D (For Windows)") & HK("UseDirect2D"), True)
	Var b = UseDirect2D
	tbtUseDirect2D->Checked = UseDirect2D
	UseDirect2D = b
	'tbStandard.Buttons.Add tbsSeparator
	tbEdit.Name = "Edit"
	tbEdit.ImagesList = @imgList
	tbEdit.HotImagesList = @imgList
	'tbEdit.DisabledImagesList = @imgListD
	'	#ifdef __USE_GTK__
	'		tbEdit.Align = 3
	'	#endif
	tbEdit.Flat = True
	tbEdit.List = True
	tbtFormat = tbEdit.Buttons.Add(, "Format", , @mClick, "Format", , ML("Format") & HK("Format", "Ctrl+Tab", True), True, ToolButtonState.tstNone)
	tbtUnformat = tbEdit.Buttons.Add(, "Unformat", , @mClick, "Unformat", , ML("Unformat") & HK("Unformat", "Shift+Ctrl+Tab", True), True, ToolButtonState.tstNone)
	tbEdit.Buttons.Add tbsSeparator
	tbtSingleComment = tbEdit.Buttons.Add(, "Comment", , @mClick, "SingleComment", , ML("Single comment") & HK("SingleComment", "Ctrl+I", True), True, ToolButtonState.tstNone)
	tbtBlockComment = tbEdit.Buttons.Add(, "BlockComment", , @mClick, "BlockComment", , ML("Block comment") & HK("BlockComment", "Ctrl+Alt+I", True), True, ToolButtonState.tstNone)
	tbtUncommentBlock = tbEdit.Buttons.Add(, "UnComment", , @mClick, "UnComment", , ML("UnComment") & HK("UnComment", "Shift+Ctrl+I", True), True, ToolButtonState.tstNone)
	tbEdit.Buttons.Add tbsSeparator
	tbtCompleteWord = tbEdit.Buttons.Add(, "CompleteWord", , @mClick, "CompleteWord", , ML("Complete Word") & HK("CompleteWord", "Ctrl+Space", True), True, ToolButtonState.tstNone)
	tbtParameterInfo = tbEdit.Buttons.Add(, "ParameterInfo", , @mClick, "ParameterInfo", , ML("Parameter Info") & HK("ParameterInfo", "Ctrl+J", True), True)
	tbEdit.Buttons.Add tbsSeparator
	tbtSyntaxCheck = tbEdit.Buttons.Add(, "SyntaxCheck", , @mClick, "SyntaxCheck", , ML("Syntax Check"), True, ToolButtonState.tstNone)
	tbtSuggestions = tbEdit.Buttons.Add(, "Suggestions", , @mClick, "Suggestions", , ML("Suggestions"), True, ToolButtonState.tstNone)
	Var tbButton = tbEdit.Buttons.Add(tbsWholeDropdown, "List", , @mClick, "Try", ML("Error Handling"), ML("Error Handling"), True)
	'tbButton->DropDownMenu.ImagesList = @imgList
	dmiNumbering = tbButton->DropDownMenu.Add(ML("Numbering"), "Numbering", "NumberOn", @mClick, , , False)
	dmiMacroNumbering = tbButton->DropDownMenu.Add(ML("Macro numbering"), "", "MacroNumberOn", @mClick, , , False)
	dmiRemoveNumbering = tbButton->DropDownMenu.Add(ML("Remove Numbering"), "", "NumberOff", @mClick, , , False)
	tbButton->DropDownMenu.Add "-"
	dmiPreprocessorNumbering = tbButton->DropDownMenu.Add(ML("Preprocessor Numbering"), "Numbering", "PreprocessorNumberOn", @mClick, , , False)
	dmiRemovePreprocessorNumbering = tbButton->DropDownMenu.Add(ML("Remove Preprocessor Numbering"), "", "PreprocessorNumberOff", @mClick, , , False)
	tbButton->DropDownMenu.Add "-"
	dmiProcedureNumbering = tbButton->DropDownMenu.Add(ML("Procedure numbering"), "Numbering", "ProcedureNumberOn", @mClick, , , False)
	dmiProcedureMacroNumbering = tbButton->DropDownMenu.Add(ML("Procedure macro numbering"), "", "ProcedureMacroNumberOn", @mClick, , , False)
	dmiRemoveProcedureNumbering = tbButton->DropDownMenu.Add(ML("Remove Procedure numbering"), "", "ProcedureNumberOff", @mClick, , , False)
	tbButton->DropDownMenu.Add "-"
	dmiModuleMacroNumbering = tbButton->DropDownMenu.Add(ML("Module macro numbering"), "Numbering", "ModuleMacroNumberOn", @mClick, , , False)
	dmiModuleMacroNumberingStartsOfProcedures = tbButton->DropDownMenu.Add(ML("Module macro numbering: Starts of procedures"), "", "ModuleMacroNumberOnStartsOfProcs", @mClick, , , False)
	dmiRemoveModuleNumbering = tbButton->DropDownMenu.Add(ML("Remove Module numbering"), "", "ModuleNumberOff", @mClick, , , False)
	tbButton->DropDownMenu.Add "-"
	dmiModulePreprocessorNumbering = tbButton->DropDownMenu.Add(ML("Module preprocessor numbering"), "Numbering", "ModulePreprocessorNumberOn", @mClick, , , False)
	dmiRemoveModulePreprocessorNumbering = tbButton->DropDownMenu.Add(ML("Remove Module preprocessor numbering"), "", "ModulePreprocessorNumberOff", @mClick, , , False)
	tbButton->DropDownMenu.Add "-"
	'dmiOnErrorResumeNext = tbButton->DropDownMenu.Add("On Error Resume Next", "", "OnErrorResumeNext", @mClick, , , False)
	dmiOnErrorGoto = tbButton->DropDownMenu.Add("On Error Goto ...", "", "OnErrorGoto", @mClick, , , False)
	dmiOnErrorGotoResumeNext = tbButton->DropDownMenu.Add("On Error Goto ... Resume Next", "", "OnErrorGotoResumeNext", @mClick, , , False)
	dmiOnLocalErrorGoto = tbButton->DropDownMenu.Add("On Local Error Goto ...", "", "OnLocalErrorGoto", @mClick, , , False)
	dmiOnLocalErrorGotoResumeNext = tbButton->DropDownMenu.Add("On Local Error Goto ... Resume Next", "", "OnLocalErrorGotoResumeNext", @mClick, , , False)
	dmiRemoveErrorHandling = tbButton->DropDownMenu.Add(ML("Remove Error Handling"), "", "RemoveErrorHandling", @mClick, , , False)
	'tbStandard.Buttons.Add tbsSeparator
	tbBuild.Name = "Build"
	tbBuild.ImagesList = @imgList
	tbBuild.HotImagesList = @imgList
	'tbBuild.DisabledImagesList = @imgListD
	'	#ifdef __USE_GTK__
	'		tbBuild.Align = 3
	'	#endif
	tbBuild.Flat = True
	tbBuild.List = True
	tbtUseDebugger = tbBuild.Buttons.Add(Cast(ToolButtonStyle, tbsCheck Or tbsAutosize), "UseDebugger", , @mClick, "TBUseDebugger", , ML("Use Debugger"), True)
	tbtCompile = tbBuild.Buttons.Add(, "Compile", , @mClick, "Compile", , ML("Compile") & HK("Compile", "Ctrl+F9", True), True, ToolButtonState.tstNone)
	Var tbMake = tbBuild.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsWholeDropdown), "Make", , @mClick, "Make", , ML("Make"), True)
	dmiMake = tbMake->DropDownMenu.Add("Make", "", "Make", @mClick, , , False)
	dmiMakeClean = tbMake->DropDownMenu.Add("Make clean", "", "MakeClean", @mClick, , , False)
	tbBuild.Buttons.Add , "Parameters", , @mClick, "Parameters", , ML("Parameters"), True
	'tbStandard.Buttons.Add tbsSeparator
	tbRun.Name = "Run"
	tbRun.ImagesList = @imgList
	tbRun.HotImagesList = @imgList
	'tbRun.DisabledImagesList = @imgListD
	'	#ifdef __USE_GTK__
	'		tbRun.Align = 3
	'	#endif
	tbRun.Flat = True
	tbRun.List = True
	tbtStartWithCompile = tbRun.Buttons.Add( , "StartWithCompile", , @mClick, "StartWithCompile", , ML("Start With Compile") & HK("StartWithCompile", "F5", True), True, ToolButtonState.tstNone)
	tbtStart = tbRun.Buttons.Add( , "Start", , @mClick, "Start", , ML("Start") & HK("Start", "Ctrl+F5", True), True, ToolButtonState.tstNone)
	tbtBreak = tbRun.Buttons.Add( , "Break", , @mClick, "Break", , ML("Break") & HK("Break", "Ctrl+Pause", True), True, ToolButtonState.tstNone)
	tbtEnd = tbRun.Buttons.Add( , "EndProgram", , @mClick, "End", , ML("End"), True, ToolButtonState.tstNone)
	'tbStandard.Buttons.Add tbsSeparator
	tbProject.Name = "Run"
	tbProject.ImagesList = @imgList
	tbProject.HotImagesList = @imgList
	'tbProject.DisabledImagesList = @imgListD
	'	#ifdef __USE_GTK__
	'		tbProject.Align = 3
	'	#endif
	tbProject.Flat = True
	tbProject.List = True
	tbtNotSetted = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "NotSetted", , @mClick, "NotSetted", , ML("Not Setted"), True)
	tbtConsole = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "Console", , @mClick, "Console", , ML("Console"), True)
	tbtGUI = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "Form", , @mClick, "GUI", , ML("GUI"), True)
	tbProject.Buttons.Add tbsSeparator
	#ifdef __USE_GTK__
		tbt32Bit = tbProject.Buttons.Add(tbsCheckGroup, "B32", , @mClick, "B32", , ML("32-bit"), True)
		tbt64Bit = tbProject.Buttons.Add(tbsCheckGroup, "B64", , @mClick, "B64", , ML("64-bit"), True)
	#else
		tbt32Bit = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "B32", , @mClick, "B32", , ML("32-bit"), True)
		tbt64Bit = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsAutosize Or tbsCheckGroup), "B64", , @mClick, "B64", , ML("64-bit"), True)
	#endif
	#ifdef __FB_64BIT__
		tbt64Bit->Checked = True
	#else
		tbt32Bit->Checked = True
	#endif
	tbProject.Buttons.Add tbsSeparator
	tbButton = tbProject.Buttons.Add(Cast(ToolButtonStyle, tbsWholeDropdown Or tbsAutosize), "Apply", , @mClick, "Use", ML("Use"), ML("Use"), True)
	Var mnuDefault = tbButton->DropDownMenu.Add(ML("Default"), "", "Default:", @mClickUseDefine, True)
	tbButton->DropDownMenu.Add "-"
	Var mnuWinAPI = tbButton->DropDownMenu.Add("WinAPI", "", "WinAPI", @mClickUseDefine)
	Var mnuDefaultWinAPI = mnuWinAPI->Add(ML("Default"), "", "DefaultWinAPI:__USE_WINAPI__", @mClickUseDefine, True)
	mnuWinAPI->Add "-"
	mnuWinAPI->Add "Windows NT 4.0", "", "WindowsNT4:__USE_WINAPI__ -d _WIN32_WINNT=&h0400", @mClickUseDefine, True
	mnuWinAPI->Add "Windows 2000", "", "Windows2000:__USE_WINAPI__ -d _WIN32_WINNT=&h0500", @mClickUseDefine, True
	mnuWinAPI->Add "Windows XP", "", "WindowsXP:__USE_WINAPI__ -d _WIN32_WINNT=&h0501", @mClickUseDefine, True
	mnuWinAPI->Add "Windows Server 2003", "", "WindowsServer2003:__USE_WINAPI__ -d _WIN32_WINNT=&h0502", @mClickUseDefine, True
	mnuWinAPI->Add "Windows Vista", "", "WindowsVista:__USE_WINAPI__ -d _WIN32_WINNT=&h0600", @mClickUseDefine, True
	mnuWinAPI->Add "Windows Server 2008", "", "WindowsServer2008:__USE_WINAPI__ -d _WIN32_WINNT=&h0600", @mClickUseDefine, True
	mnuWinAPI->Add "Windows 7", "", "Windows7:__USE_WINAPI__ -d _WIN32_WINNT=&h0601", @mClickUseDefine, True
	mnuWinAPI->Add "Windows 8", "", "Windows8:__USE_WINAPI__ -d _WIN32_WINNT=&h0602", @mClickUseDefine, True
	mnuWinAPI->Add "Windows 8.1", "", "Windows8_1:__USE_WINAPI__ -d _WIN32_WINNT=&h0603", @mClickUseDefine, True
	mnuWinAPI->Add "Windows 10", "", "Windows10:__USE_WINAPI__ -d _WIN32_WINNT=&h0A00", @mClickUseDefine, True
	Var mnuGTK = tbButton->DropDownMenu.Add("GTK", "", "GTK", @mClickUseDefine)
	mnuGTK->Add ML("Default"), "", "Default:__USE_GTK__", @mClickUseDefine, True
	mnuGTK->Add "-"
	mnuGTK->Add "GTK2", "", "GTK2:__USE_GTK__ -d __USE_GTK2__", @mClickUseDefine, True
	mnuGTK->Add "GTK3", "", "GTK3:__USE_GTK__ -d __USE_GTK3__", @mClickUseDefine, True
	mnuGTK->Add "GTK4", "", "GTK4:__USE_GTK__ -d __USE_GTK4__", @mClickUseDefine, True
	Var mnuJNI = tbButton->DropDownMenu.Add("JNI", "", "JNI", @mClickUseDefine)
	mnuJNI->Add ML("Default"), "", "Default:__USE_JNI__", @mClickUseDefine, True
	mnuJNI->Add "-"
	mnuJNI->Add "Android GUI", "", "AndroidGUI:__USE_JNI__ -d __USE_ANDROIDGUI__", @mClickUseDefine, True
	mnuJNI->Add "Native GUI", "", "NativeGUI:__USE_JNI__ -d __USE_NATIVEGUI__", @mClickUseDefine, True
	Var mnuWASM = tbButton->DropDownMenu.Add("WASM", "", "WASM:__USE_WASM__ -target js-asmjs -r", @mClickUseDefine)
	mnuDefault->Checked = True
	miUseDefine = mnuDefault
	tbProject.Buttons.Add tbsSeparator
	tbButton = tbProject.Buttons.Add(tbsCustom)
	tbButton->Width = 170
	tbButton->Child = @cboBuildConfiguration
End Sub

CreateMenusAndToolBars
'tbStandard.AddRange 1, @cboCommands

Sub tbLeft_OnResize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer, NewHeight As Integer)
	pnlLeftPin.Height = NewHeight
End Sub

tbLeft.ImagesList = @imgList
tbLeft.Buttons.Add tbsCheck, "Pinned", , @mClick, "PinLeft", "", ML("Pin"), , Cast(ToolButtonState, tstEnabled Or tstChecked)
tbLeft.Flat = True
tbLeft.Width = 23
tbLeft.Parent = @pnlLeftPin
tbLeft.OnResize = @tbLeft_OnResize

tbExplorer.ImagesList = @imgList
tbExplorer.HotImagesList = @imgList
'tbExplorer.DisabledImagesList = @imgList
tbExplorer.Flat = True
tbExplorer.Align = DockStyle.alTop
tbExplorer.AutoSize = True
tbExplorer.ExtraMargins.Right = tbLeft.Width
tbExplorer.Buttons.Add , "Add",, @mClick, "AddFilesToProject", , ML("Add"), True
tbtRemoveFileFromProject = tbExplorer.Buttons.Add(, "Remove", , @mClick, "RemoveFileFromProject", , ML("&Remove"), True, ToolButtonState.tstNone)
tbExplorer.Buttons.Add tbsSeparator
Var tbFolder = tbExplorer.Buttons.Add(tbsWholeDropdown, "Folder", , @mClick, "Folder", , ML("Show Folders"), True)
miShowWithFolders = tbFolder->DropDownMenu.Add(ML("Show With Folders"), "", "ShowWithFolders", @mClick, , , True)
miShowWithoutFolders = tbFolder->DropDownMenu.Add(ML("Show Without Folders"), "", "ShowWithoutFolders", @mClick, , , True)
miShowAsFolder = tbFolder->DropDownMenu.Add(ML("Show As Folder"), "", "ShowAsFolder", @mClick, , , False)
tbExplorer.Buttons.Add tbsSeparator
Var tbSearch = tbExplorer.Buttons.Add(tbsCustom)
txtExplorer.Width = 2
tbSearch->Child = @txtExplorer
tbSearch->Expand = True
tbExplorer.Buttons.Add tbsSeparator

Sub tbFormClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Var bFlag = Cast(ToolButton Ptr, @Sender)->Checked
	Select Case Sender.ToString
	Case "Text"
		If bFlag Then
			tbToolBox.Style = tpsBothHorizontal
		Else
			tbToolBox.Style = tpsIcons
		End If
		'tbToolBox.RecreateWnd
	Case "Components"
		frmComponents.Show frmMain
	End Select
	pnlToolBox_Resize *pnlToolBox.Designer, pnlToolBox, pnlToolBox.Width, pnlToolBox.Height
End Sub

tbForm.ImagesList = @imgList
tbForm.HotImagesList = @imgList
'tbForm.DisabledImagesList = @imgListD
tbForm.Align = DockStyle.alTop
tbForm.Flat = True
tbForm.ExtraMargins.Right = tbLeft.Width
tbForm.Buttons.Add tbsCheck, "Label", , @tbFormClick, "Text", "", ML("Text"), , Cast(ToolButtonState, tstChecked Or tstEnabled)
tbForm.Buttons.Add tbsSeparator
tbForm.Buttons.Add , "Component", , @tbFormClick, "Components", "", ML("Add Components")
tbForm.Buttons.Add tbsSeparator
Var FormSearch = tbForm.Buttons.Add(tbsCustom)
txtForm.Width = 2
FormSearch->Child = @txtForm
FormSearch->Expand = True
tbForm.Buttons.Add tbsSeparator

tabLeftWidth = 150
tabRightWidth = 150
tabBottomHeight = 150

splLeft.Align = SplitterAlignmentConstants.alLeft
splRight.Align = SplitterAlignmentConstants.alRight
splBottom.Align = SplitterAlignmentConstants.alBottom

Sub CloseLeft()
	splLeft.Visible = False
	#ifdef __USE_GTK__
		pnlLeft.Width = 30
	#else
		tabLeft.SelectedTabIndex = -1
		pnlLeft.Width = tabLeft.ItemWidth(0) + 2
	#endif
	pnlLeftPin.Visible = False
	frmMain.RequestAlign
End Sub

Sub ShowLeft()
	tabLeft.SetFocus
	pnlLeft.Width = tabLeftWidth
	pnlLeft.RequestAlign
	splLeft.Visible = True
	pnlLeftPin.Left = tabLeftWidth - pnlLeftPin.Width - 4
	pnlLeftPin.Visible = True
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
End Sub

Sub CloseRight()
	splRight.Visible = False
	#ifdef __USE_GTK__
		pnlRight.Width = 30
	#else
		tabRight.SelectedTabIndex = -1
		pnlRight.Width = tabRight.ItemWidth(0) + 2
	#endif
	pnlRightPin.Visible = False
	frmMain.RequestAlign
End Sub

Sub ShowRight()
	tabRight.SetFocus
	pnlRight.Width = tabRightWidth
	pnlRight.RequestAlign
	splRight.Visible = True
	pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - tabRight.ItemWidth(0) - 4
	pnlRightPin.Visible = True
	frmMain.RequestAlign
End Sub

Sub CloseBottom()
	splBottom.Visible = False
	#ifdef __USE_GTK__
		pnlBottom.Height = 25
	#else
		ptabBottom->SelectedTabIndex = -1
		pnlBottom.Height = ptabBottom->ItemHeight(0) + 2
	#endif
	pnlBottomPin.Visible = False
	frmMain.RequestAlign
End Sub

Sub ShowBottom()
	ptabBottom->SetFocus
	pnlBottom.Height = tabBottomHeight
	pnlBottom.RequestAlign
	splBottom.Visible = True
	pnlBottomPin.Visible = True
	frmMain.RequestAlign '<bp>
End Sub

Function GetLeftClosedStyle As Boolean
	Return Not tabLeft.TabPosition = tpTop
End Function

Dim Shared bClosing As Boolean
Sub SetLeftClosedStyle(Value As Boolean, WithClose As Boolean = True)
	If bClosing Then Exit Sub
	bClosing = True
	With *tbLeft.Buttons.Item("PinLeft")
		If Value Then
			tabLeft.TabPosition = tpLeft
			.ImageKey = "Pin"
			.Checked = False
			pnlLeftPin.Top = 2
			If WithClose Then CloseLeft
		Else
			pnlLeft.Width = tabLeftWidth
			tabLeft.TabPosition = tpTop
			splLeft.Visible = True
			pnlLeftPin.Visible = True
			.ImageKey = "Pinned"
			.Checked = True
			pnlLeftPin.Top = tabItemHeight
		End If
	End With
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
	bClosing = False
End Sub

Sub tabLeft_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	SetLeftClosedStyle Not GetLeftClosedStyle
End Sub

#ifndef __USE_GTK__
	Sub scrTool_Scroll(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef NewPos As Integer)
		tbToolBox.Top = -NewPos
	End Sub
	
	scrTool.Style = sbVertical
	scrTool.Align = DockStyle.alRight
	scrTool.ArrowChangeSize = tbToolBox.ButtonHeight
	scrTool.PageSize = 3 * scrTool.ArrowChangeSize
	scrTool.OnScroll = @scrTool_Scroll
	scrTool.OnMouseWheel = @scrTool_MouseWheel
	'scrTool.OnResize = @pnlToolBox_Resize
#endif

Function ToolType.GetCommand(ByRef FileName As WString = "", WithoutProgram As Boolean = False) As UString
	Dim As ProjectElement Ptr Project
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr ProjectNode
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As UString ProjectFile = ""
	Dim As UString CompileLine, MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project, CompileLine)
	Dim As UString ExeFile = GetExeFileName(MainFile, CompileLine & " " & FirstLine)
	Dim As UString CurrentWord = ""
	Dim As UString Params
	If Trim(This.Path) <> "" AndAlso Not WithoutProgram Then
		'#ifdef __USE_GTK__
		'	If Not g_find_program_in_path(ToUTF8(This.Path)) = NULL Then
		'#else
		If Not FileExists(This.Path) Then
			'#endif
			Params = """" & GetRelativePath(This.Path, pApp->FileName) & """ "
		Else
			Params = """" & GetRelativePath(This.Path, pApp->FileName) & """ "
		End If
	End If
	Params &= This.Parameters
	If ProjectNode <> 0 Then ee = ProjectNode->Tag
	If ee <> 0 Then ProjectFile = *ee->FileName
	If tb <> 0 Then CurrentWord = tb->txtCode.GetWordAtCursor
	Params = Replace(Params, "{P}", ProjectFile)
	Params = Replace(Params, "{P|S}", IIf(ProjectFile = "", MainFile, ProjectFile))
	Params = Replace(Params, "{S}", MainFile)
	Params = Replace(Params, "{W}", CurrentWord)
	Params = Replace(Params, "{E}", ExeFile)
	Params = Replace(Params, "{D}", GetFolderName(ExeFile))
	If InStr(Params, "{|F}") > 0 Then
		Params = Replace(Params, "{|F}", "")
	ElseIf InStr(Params, "{F}") > 0 Then
		Params = Replace(Params, "{F}", FileName)
	ElseIf FileName <> "" Then
		Params &= " """ & FileName & """"
	End If
	Return Params
End Function

Sub tvExplorer_NodeActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode)
	#ifdef __USE_GTK__
		If Item.Nodes.Count > 0 Then
			If Item.IsExpanded Then
				Item.Collapse
			Else
				Item.Expand
			End If
		End If
	#endif
	RestoreStatusText
	If Item.ImageKey = "Opened" Then Exit Sub
	If Item.ImageKey = "Project" AndAlso Item.ParentNode = 0 Then Exit Sub
	Dim As ExplorerElement Ptr ee = Item.Tag
	If ee <> 0 Then
		If *ee Is TypeElement Then
			Dim As TypeElement Ptr te = Item.Tag
			If te->Tag <> 0 Then
				Dim As TabWindow Ptr tb = te->Tag
				If Not tb->IsSelected Then
					tb->SelectTab
				End If
				tb->txtCode.SetSelection te->StartLine, te->StartLine, te->StartChar, te->StartChar
			End If
			Exit Sub
		Else
			Dim As Integer Pos1 = InStrRev(*ee->FileName, ".")
			If Pos1 > 0 Then
				Dim As UString Extension = Mid(*ee->FileName, Pos1)
				For i As Integer = 0 To pOtherEditors->Count - 1
					Dim As ToolType Ptr Tool = pOtherEditors->Item(i)->Object
					If InStr(" " & LCase(Tool->Extensions) & ",", " " & LCase(Extension) & ",") > 0 Then
						If Not FileExists(GetFullPath(Tool->Path)) Then Continue For
						'Shell """" & Tool->GetCommand(*ee->FileName) & """"
						PipeCmd "", Tool->GetCommand(*ee->FileName)
						Exit Sub
					End If
				Next
			End If
			Dim As String extStr = LCase(Right(*ee->FileName, 4))
			If CBool(extStr = ".exe" OrElse extStr = ".dll"  OrElse extStr = ".png" OrElse extStr = ".jpg" OrElse extStr = ".bmp" OrElse extStr = ".ico" OrElse extStr = ".cur" OrElse extStr = ".gif" OrElse extStr = ".avi" OrElse _
				extStr = ".chm" OrElse extStr = ".zip" OrElse extStr = ".rar") OrElse EndsWith(LCase(*ee->FileName), ".dll.a") OrElse EndsWith(LCase(*ee->FileName), ".so") OrElse EndsWith(LCase(*ee->FileName), ".7z") Then
				Shell *ee->FileName
				'PipeCmd "", *ee->FileName
				Exit Sub
			ElseIf extStr = ".vfp" Then
				AddProject *ee->FileName
				WLet(RecentProject, *ee->FileName)
				tpProject->SelectTab
				Exit Sub
			End If
		End If
	End If
	Dim t As Boolean
	Dim As TabWindow Ptr tb
	Dim As TabControl Ptr ptabCode
	For j As Integer = 0 To TabPanels.Count - 1
		ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
		For i As Integer = 0 To ptabCode->TabCount - 1
			tb = Cast(TabWindow Ptr, ptabCode->Tabs[i])
			If tb->tn = @Item Then
				ptabCode->SelectedTabIndex = ptabCode->Tabs[i]->Index
				If tb->Des <> 0 AndAlso tb->tbrTop.Buttons.Item("Code")->Checked Then
					tb->tbrTop.Buttons.Item("CodeAndForm")->Checked = True
					tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("CodeAndForm")
				End If
				tb->txtCode.SetFocus
				t = True
				Exit For
			End If
		Next i
	Next j
	If Not t Then
		If ee <> 0 Then
			If InStr(WGet(ee->FileName), "\") = 0 AndAlso InStr(WGet(ee->FileName), "/") = 0 AndAlso WGet(ee->TemplateFileName) <> "" Then
				AddTab WGet(ee->TemplateFileName), True, @Item
			Else
				AddTab WGet(ee->FileName), , @Item
			End If
		End If
	End If
End Sub

Sub tvExplorer_NodeExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode, ByRef Cancel As Boolean)
	Dim As ExplorerElement Ptr ee = Item.Tag
	If ee = 0 OrElse Not FolderExists(*ee->FileName) Then Exit Sub
	If bNotExpand Then Exit Sub
	bNotExpand = True
	ExpandFolder @Item
	bNotExpand = False
End Sub

Sub tvExplorer_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim tn As TreeNode Ptr = tvExplorer.SelectedNode
	If tn = 0 Then Exit Sub
	tvExplorer_NodeActivate Designer, Sender, *tn
	'	If tn->ImageKey = "Project" Then Exit Sub
	'	Dim t As Boolean
	'	For i As Integer = 0 To ptabCode->TabCount - 1
	'		If Cast(TabWindow Ptr, ptabCode->Tabs[i])->tn = tn Then
	'			ptabCode->SelectedTabIndex = ptabCode->Tabs[i]->Index
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

Sub tvExplorer_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifdef __USE_GTK__
		Select Case Key
		Case GDK_KEY_Left
			
		End Select
	#else
		If Key = VK_RETURN Then tvExplorer_DblClick Designer, Sender
	#endif
End Sub

Function GetParentNode(tn As TreeNode Ptr) As TreeNode Ptr
	If tn = 0 OrElse tn->ParentNode = 0 Then
		Return tn
	ElseIf tn->ImageKey = "Project" Then 'tn->Tag <> 0 AndAlso *Cast(ExplorerElement Ptr, tn->Tag) Is ProjectElement Then
		Return tn
	Else
		Return GetParentNode(tn->ParentNode)
	End If
End Function

Sub tvExplorer_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode)
	Static OldParentNode As TreeNode Ptr
	Dim As TreeNode Ptr ptn = tvExplorer.SelectedNode
	If ptn = 0 Then Exit Sub 'David Change For Safty
	ptn = GetParentNode(ptn)
	If ptn > 0 AndAlso OldParentNode <> ptn Then
		OldParentNode = ptn
		'If MainNode <> 0 Then MainNode->Bold = False
		'MainNode = ptn
		'lblLeft.Text = ML("Main Project") & ": " & MainNode->Text
		mLoadLog = False
		mLoadToDo = False
		If ptn->Tag > 0 Then
			Select Case Cast(ProjectElement Ptr, ptn->Tag)->ProjectFolderType
			Case ProjectFolderTypes.ShowWithFolders: miShowWithFolders->RadioItem = True
			Case ProjectFolderTypes.ShowWithoutFolders: miShowWithoutFolders->RadioItem = True
			Case ProjectFolderTypes.ShowAsFolder: miShowAsFolder->RadioItem = True
			End Select
		End If
		ChangeMenuItemsEnabled
		If ptn->ImageKey <> "Project" AndAlso ptn->ImageKey <> "MainProject" AndAlso ptn->ImageKey <> "Opened" Then  'David Change For compile Single .bas file Then
			'miSaveProject->Enabled = False
			'miSaveProjectAs->Enabled = False
			'miCloseProject->Enabled = False
			'miCloseFolder->Enabled = False
			'miExplorerCloseProject->Enabled = False
			'miProjectProperties->Enabled = False
			'miExplorerProjectProperties->Enabled = False
			'			MainNode = 0
			'			lblLeft.Text = ML("Main Project") & ": " & ML("Automatic")
		Else
			'miSaveProject->Enabled = True
			'miSaveProjectAs->Enabled = True
			'miCloseProject->Enabled = True
			'miCloseFolder->Enabled = True
			'miExplorerCloseProject->Enabled = True
			'miProjectProperties->Enabled = True
			'miExplorerProjectProperties->Enabled = True
			'			MainNode->ImageKey = "MainProject"
			'			MainNode->Bold = True
			If mStartLoadSession = False Then
				If tpChangeLog->IsSelected AndAlso Not mLoadLog Then
					If mChangeLogEdited AndAlso mChangelogName<> "" Then
						txtChangeLog.SaveToFile(mChangelogName)  ' David Change
						mChangeLogEdited = False
					End If
					mChangelogName = ExePath & Slash & StringExtract(ptn->Text, ".") & "_Change.log"
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
				End If
				If tpToDo->IsSelected AndAlso Not mLoadToDo Then
					WLet(gSearchSave, WChr(39) + WChr(84) + "ODO")
					ThreadCounter(ThreadCreate_(@FindSubProj, ptn))
					mLoadToDo = True
				End If
			End If
		End If
	End If
End Sub

Sub tvExplorer_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 1 Then Exit Sub
	Dim As TreeNode Ptr ptn, tn = tvExplorer.DraggedNode
	If tn = 0 Then
		tn = tvExplorer.SelectedNode
	Else
		tvExplorer.SelectedNode = tn
	End If
	If tn <> 0 AndAlso tn->ParentNode <> 0 Then
		ptn = GetParentNode(tn)
		If ptn->ImageKey <> "Project" Then
			miProjectProperties->Enabled = False
			miCloseProject->Enabled = False
		End If
		miSetAsMain->Caption = ML("Set as Main")
		If tn->ImageKey = "Opened" Then
			miSetAsMain->Enabled = False
		End If
	Else
		miSetAsMain->Caption = ML("Set as Start Up")
	End If
	Dim As String tmpKeyStr = " @Sub @StandartTypes @Property @Enum @EnumItem @Type @Function @Opened "
	If CInt(tn = 0) OrElse CInt(tn <> 0 AndAlso InStr(tmpKeyStr, " @" & tn->ImageKey & " ")) Then
		miSetAsMain->Enabled = IIf(tn <> 0 AndAlso tn->ParentNode <> 0, False, True)
		miRemoveFiles->Enabled = False
		miRemoveFiles->Caption = ML("Remove")
	Else
		miSetAsMain->Enabled = True
		miRemoveFiles->Enabled = True
		miRemoveFiles->Caption = ML("Remove") & " " & tn->Text
	End If
End Sub

Sub tvExplorer_BeforeLabelEdit(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
	If Not g_bAllowLabelEdit Then
		Cancel = True
		Exit Sub
	End If
	g_bAllowLabelEdit = False
	If Item.IsEmpty Then Exit Sub
	If Item.ImageKey = "Opened" Then
		Cancel = True
	End If
End Sub

Sub tvExplorer_AfterLabelEdit(ByRef Designer As My.Sys.Object, ByRef Sender As TreeView, ByRef Item As TreeNode, ByRef NodeLabel As WString, ByRef Cancel As Boolean)
	If Item.IsEmpty Then Exit Sub
	If Item.ImageKey = "Opened" Then
		Cancel = True
	ElseIf Item.ImageKey = "Project" Then
		Dim As ProjectElement Ptr ppe = Item.Tag
		If ppe <> 0 AndAlso *ppe->FileName <> "" Then
			Dim As Boolean bModified = EndsWith(NodeLabel, "*")
			Dim As UString bFileName = GetFolderName(*ppe->FileName) & NodeLabel
			If bModified Then
				bFileName = Left(bFileName, Len(bFileName) - 1)
			End If
			#ifdef __USE_WINAPI__
				If MoveFile(ppe->FileName, bFileName.vptr) = 0 Then
					MsgBox ML("Renaming error!") & " " & GetErrorString(GetLastError, , True)
					Cancel = True
					Exit Sub
				End If
			#else
				Dim As Long Result = Name(*ppe->FileName, bFileName)
				If Result <> 0 Then
					MsgBox ML("Renaming error!") & " " & Err2Description(Result)
					Cancel = True
					Exit Sub
				End If
			#endif
			WLet(ppe->FileName, bFileName)
		End If
	Else
		Dim As TabWindow Ptr tb = GetTabFromTn(@Item)
		Dim As TreeNode Ptr ptn = GetParentNode(@Item)
		Dim As ExplorerElement Ptr ee = Item.Tag
		Dim As Boolean bModified
		If ee <> 0 AndAlso *ee->FileName <> "" Then
			bModified = EndsWith(NodeLabel, "*")
			Dim As UString bFileName = GetFolderName(*ee->FileName) & NodeLabel
			If bModified Then
				bFileName = Left(bFileName, Len(bFileName) - 1)
			End If
			If InStr(*ee->FileName, Any ":\/") > 0 Then
				#ifdef __USE_WINAPI__
					If MoveFile(ee->FileName, bFileName.vptr) = 0 Then
						MsgBox ML("Renaming error!") & " " & GetErrorString(GetLastError, , True)
						Cancel = True
						Exit Sub
					End If
				#else
					Dim As Long Result = Name(*ee->FileName, bFileName)
					If Result <> 0 Then
						MsgBox ML("Renaming error!") & " " & Err2Description(Result)
						Cancel = True
						Exit Sub
					End If
				#endif
			End If
			If ptn <> 0 AndAlso ptn->ImageKey = "Project" Then
				Dim As ProjectElement Ptr pee = ptn->Tag
				If pee <> 0 Then
					If WGet(pee->MainFileName) = WGet(ee->FileName) Then WLet(pee->MainFileName, bFileName)
					If WGet(pee->ResourceFileName) = WGet(ee->FileName) Then WLet(pee->ResourceFileName, bFileName)
					If WGet(pee->IconResourceFileName) = WGet(ee->FileName) Then WLet(pee->IconResourceFileName, bFileName)
					If WGet(pee->BatchCompilationFileNameWindows) = WGet(ee->FileName) Then WLet(pee->BatchCompilationFileNameWindows, bFileName)
					If WGet(pee->BatchCompilationFileNameLinux) = WGet(ee->FileName) Then WLet(pee->BatchCompilationFileNameLinux, bFileName)
					If Not EndsWith(ptn->Text, "*") Then ptn->Text & = "*"
				End If
			End If
			WLet(ee->FileName, bFileName)
		End If
		If tb Then
			bModified = EndsWith(tb->Caption, "*")
			If bModified AndAlso Not EndsWith(NodeLabel, "*") Then
				tb->Caption = NodeLabel & "*"
			Else
				tb->Caption = NodeLabel
			End If
		End If
	End If
End Sub

tvExplorer.Images = @imgList
tvExplorer.SelectedImages = @imgList
tvExplorer.Align = DockStyle.alClient
tvExplorer.HideSelection = False
tvExplorer.EditLabels = True
'tvExplorer.OnDblClick = @tvExplorer_DblClick
tvExplorer.OnNodeActivate = @tvExplorer_NodeActivate
tvExplorer.OnNodeExpanding = @tvExplorer_NodeExpanding
tvExplorer.OnMouseUp = @tvExplorer_MouseUp
tvExplorer.OnKeyDown = @tvExplorer_KeyDown
tvExplorer.OnSelChanged = @tvExplorer_SelChange
tvExplorer.OnBeforeLabelEdit = @tvExplorer_BeforeLabelEdit
tvExplorer.OnAfterLabelEdit = @tvExplorer_AfterLabelEdit
tvExplorer.ContextMenu = @mnuExplorer

Sub tabLeft_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
	#else
		If tabLeft.TabPosition = tpLeft And tabLeft.SelectedTabIndex <> -1 Then
	#endif
		ShowLeft
		'		tabLeft.SetFocus
		'		pnlLeft.Width = tabLeftWidth
		'		pnlLeft.RequestAlign
		'		splLeft.Visible = True
		'		tbLeft.Visible = True
		'		'#IfNDef __USE_GTK__
		'		frmMain.RequestAlign
		'		'#EndIf
	End If
End Sub

Sub tabLeft_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If tabLeft.TabPosition = tpLeft And pnlLeft.Width = 30 Then
		ShowLeft
		'		tabLeft.SetFocus
		'		pnlLeft.Width = tabLeftWidth
		'		pnlLeft.RequestAlign
		'		splLeft.Visible = True
		'		tbLeft.Visible = True
		'		frmMain.RequestAlign
	End If
End Sub

Sub pnlLeft_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlLeft.Width <> 30 Then tabLeftWidth = NewWidth ': tabLeft.Width = pnlLeft.Width
	#else
		If tabLeft.SelectedTabIndex <> -1 Then tabLeftWidth = pnlLeft.Width
	#endif
End Sub

pnlLeft.Name = "pnlLeft"
pnlLeft.Align = DockStyle.alLeft
pnlLeft.Width = tabLeftWidth
pnlLeft.OnResize = @pnlLeft_Resize

tabLeft.Name = "tabLeft"
tabLeft.GroupName = "ToolWindow"
tabLeft.Width = tabLeftWidth
tabLeft.Align = DockStyle.alClient
tabLeft.Detachable = True
tabLeft.Reorderable = True
tabLeft.OnClick = @tabLeft_Click
tabLeft.OnDblClick = @tabLeft_DblClick
tabLeft.OnSelChange = @tabLeft_SelChange
pnlLeft.Add @tabLeft
'tabLeft.TabPosition = tpLeft

tpProject = tabLeft.AddTab(ML("Project"))

tpToolbox = tabLeft.AddTab(ML("Toolbox")) ' ToolBox is better than "Form"
tpToolbox->Name = "Toolbox"
tpAIAgent = tabLeft.AddTab(ML("AI Agent")) ' ToolBox is better than "Form"
tpAIAgent->Name = "AIAgent"
tpAIAgent->Add @tbAIAgent
tpAIAgent->Add @pnlAIAgent

pnlAIAgent.Align = DockStyle.alClient
pnlAIAgent.Width = tabLeftWidth
'pnlAIAgent.OnResize = @pnlAIAgent_Resize
#ifdef __USE_GTK__
	#ifdef __USE_GTK3__
		Function OverlayLeft_get_child_position(self As GtkOverlay Ptr, widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr) As Boolean
			Dim As gint x, y
			Dim As Control Ptr tb = IIf(tabLeft.SelectedTab = tpProject, @tbExplorer, @tbForm)
			gtk_widget_translate_coordinates(tb->Handle, pnlLeft.Handle, tb->ScaleX(pnlLeft.Width), 0, @x, @y)
			tbLeft.Width = tbLeft.Buttons.Item(0)->Width + tbLeft.Height - tbLeft.Buttons.Item(0)->Height
			tbExplorer.ExtraMargins.Right = tbLeft.Width - 10
			tbForm.ExtraMargins.Right = tbLeft.Width - 10
			allocation->x = x - tbLeft.ScaleX(tbLeft.Width) - IIf(tabLeft.TabPosition = TabPosition.tpLeft, x - pnlLeft.ScaleX(pnlLeft.Width), 0)
			allocation->y = y
			allocation->width = tbLeft.ScaleX(tbLeft.Width)
			allocation->height = tbLeft.ScaleY(tbLeft.Height)
			Return True
		End Function
	#endif
#endif

pnlLeftPin.Anchor.Right = AnchorStyle.asAnchor
pnlLeftPin.Top = tabItemHeight
pnlLeftPin.Width = tbLeft.Width
pnlLeftPin.Left = tabLeftWidth - pnlLeftPin.Width - 4
pnlLeftPin.Height = tbLeft.Height
pnlLeftPin.Parent = @pnlLeft
#ifdef __USE_GTK__
	#ifdef __USE_GTK3__
		Dim As GtkWidget Ptr overlayLeft = gtk_overlay_new()
		gtk_container_add(GTK_CONTAINER(overlayLeft), pnlLeft.Handle)
		g_object_ref(pnlLeftPin.Handle)
		gtk_container_remove(GTK_CONTAINER(pnlLeft.Handle), pnlLeftPin.Handle)
		gtk_overlay_add_overlay(GTK_OVERLAY(overlayLeft), pnlLeftPin.Handle)
		g_signal_connect(overlayLeft, "get-child-position", G_CALLBACK(@OverlayLeft_get_child_position), @pnlLeft)
		pnlLeft.WriteProperty("overlaywidget", overlayLeft)
	#endif
#endif

Function SetVisibleToTreeNode(Node As TreeNode Ptr, ByRef SearchText As WString) As Boolean
	Dim As Boolean bVisible
	If Node->Nodes.Count > 0 Then
		If SearchText = "" AndAlso (Node->ParentNode <> 0 OrElse Node->ImageKey <> "Project") Then
			Node->Collapse
		Else
			Node->Expand
		End If
	End If
	For i As Integer = 0 To Node->Nodes.Count - 1
		If SetVisibleToTreeNode(Node->Nodes.Item(i), SearchText) Then
			bVisible = True
		End If
	Next
	If Not bVisible Then
		bVisible = SearchText = "" OrElse InStr(LCase(Node->Text), SearchText) > 0
	End If
	Node->Visible = bVisible
	Return bVisible
End Function

Sub txtExplorer_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	Dim As UString SearchText = Trim(LCase(txtExplorer.Text))
	For i As Integer = 0 To tvExplorer.Nodes.Count - 1
		SetVisibleToTreeNode(tvExplorer.Nodes.Item(i), SearchText)
	Next
	If SearchText <> "" Then
		tvExplorer.ExpandAll
	End If
End Sub

txtExplorer.OnChange = @txtExplorer_Change

lblLeft.Text = ML("Main File") & ": " & ML("Automatic")
lblLeft.Align = DockStyle.alBottom
lblLeft.Height = Max(8, DefaultFont.Size) / 72 * 96 + 5
tpProject->Add @tbExplorer
tpProject->Add @lblLeft
tpProject->Add @tvExplorer

pnlToolBox.Align = DockStyle.alClient
pnlToolBox.Add @tbToolBox
#ifndef __USE_GTK__
	pnlToolBox.Add @scrTool
#endif
pnlToolBox.OnResize = @pnlToolBox_Resize

Sub txtForm_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	Dim As Boolean bVisible
	Dim As UString SearchText = Trim(LCase(txtForm.Text))
	For i As Integer = 0 To tbToolBox.Groups.Count - 1
		For j As Integer = 0 To tbToolBox.Groups.Item(i)->Buttons.Count - 1
			bVisible =  SearchText = "" OrElse InStr(LCase(tbToolBox.Groups.Item(i)->Buttons.Item(j)->Caption), SearchText) > 0
			tbToolBox.Groups.Item(i)->Buttons.Item(j)->Visible = bVisible
		Next
	Next
End Sub

txtForm.OnChange = @txtForm_Change

tpToolbox->Add @pnlToolBox 'tbToolBox
tpToolbox->Add @tbForm

'tpToolbox->Style = tpToolbox->Style Or ES_AUTOVSCROLL or WS_VSCROLL

'pnlLeft.Width = 153
'pnlLeft.Align = 1
'pnlLeft.AddRange 1, @tabLeft
Sub cboAIAgentModels_Change(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As Integer Index = pAIAgents->IndexOfKey(cboAIAgentModels.Text)
	If Index < 0 Then
		ShowMessages("AIAgents not found! ") & cboAIAgentModels.Text
		Return
	End If
	Dim As ModelInfo Ptr Info = Cast(ModelInfo Ptr, pAIAgents->Item(Index)->Object)
	If bInAIThread Then ThreadsEnter 
	If Info Then
		WLet(DefaultAIAgent, Info->Name)
		WLet(CurrentAIAgent, Info->Name)
		bAIAgentFirstRun = True
		AIAgentModelName = Info->ModelName
		AIAgentProvider = Info->Provider
		AIAgentHost = Info->Host
		AIAgentAddress  = Info->Address
		AIAgentAPIKey = Info->APIKey
		AIAgentTemperature = Info->Temperature
		AIAgentStream  = Info->Stream
		AIPostDataFirstTime = True
		AIIncludeFileNameList.Clear
	End If
	If bInAIThread Then ThreadsLeave
End Sub

tbAIAgent.ImagesList = @imgList
tbAIAgent.HotImagesList = @imgList
tbAIAgent.Flat = True
tbAIAgent.Align = DockStyle.alTop
tbAIAgent.AutoSize = True
tbAIAgent.ExtraMargins.Right = tbLeft.Width
tbAIAgent.Buttons.Add , "NewChat", , @mClick, "AINewChat", , ML("New Chat"), True
tbAIAgent.Buttons.Add , "AddComment", , @mClick, "AIAddComment", , ML("Comment selected code"), True
tbAIAgent.Buttons.Add , "OptimizeCode", , @mClick, "AIOptimizeCode", , ML("Optimize selected code"), True
tbAIAgent.Buttons.Add , "Intellicode", , @mClick, "AIIntellicode", , ML("Generate code based on the requirements of the selected comment lines"), True
tbAIAgent.Buttons.Add , "TracepointError", , @mClick, "AITracepointError", , ML("Explain the selected compiler error message"), True
tbAIAgent.Buttons.Add , "WebBrowserItem", , @mClick, "AIWebBrowserItem", , ML("Ignore the constraints of the provided references and perform regular search and analysis. Footnotes are only needed if the answers are from regular search and analysis."), True
tbAIAgent.Buttons.Add , "ConvertC", , @mClick, "AIConvertCtoFB", , ML("Convert the given C source code into equivalent FreeBasic source code."), True
tbAIAgent.Buttons.Add , "Translate", , @mClick, "AITranslate", , ML("Output with MARKDOWN source code, translate the selected message to") & " " &  ML(App.CurLanguage), True
tbAIAgent.Buttons.Add , "TranslateE", , @mClick, "AITranslateE", , ML("Output with MARKDOWN source code, translate the selected message to") & " " & ML("English"), True
tbAIAgent.Buttons.Add , "Close", , @mClick, "AIRelease", , ML("Release the AI Agent"), True
tbAIAgent.Buttons.Add tbsSeparator
Var tbAIModels = tbAIAgent.Buttons.Add(tbsCustom)
tbAIModels->Child = @cboAIAgentModels
tbAIModels->Expand = True
tbAIAgent.Buttons.Add tbsSeparator
cboAIAgentModels.OnChange = @cboAIAgentModels_Change
txtAIAgent.Align = DockStyle.alClient
txtAIAgent.Parent = @pnlAIAgent
txtAIAgent.Multiline = True
txtAIAgent.Font.Name = *EditorFontName
txtAIAgent.Font.Size = EditorFontSize
AIEditorFontName = *EditorFontName
txtAIAgent.ReadOnly = True
txtAIAgent.WordWraps = True
txtAIAgent.MaxLength = 0
txtAIAgent.ScrollBars = ScrollBarsType.Vertical
txtAIAgent.ContextMenu = @mnuAIChat

Function EscapeJsonForPrompt(ByRef iText As WString) As String
	Dim As Integer Posi = 0, iLen = Len(iText)
	If iLen < 1 Then Return ""
	Dim As Integer bufferSize = iLen * 6 + 2
	Dim As WString Ptr ResultPtr = Allocate(bufferSize * SizeOf(WString))     ' 预分配最大可能空间
	Dim As String TmpStr
	For i As Integer = 0 To iLen  - 1
		If Posi >= bufferSize - 6 Then
			bufferSize *= 2
			ResultPtr = Reallocate(ResultPtr, bufferSize * SizeOf(WString))
		End If
		If ResultPtr = 0 Then Return "" ' 内存分配失败保护
		Select Case iText[i]
		Case 92                  '"\\", "\"))    ' 反斜杠
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 92
			Posi += 1
			i += 1
		Case 34                  '"\""", """"))  ' 双引号
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 34
			Posi += 1
		Case 47                  '"\/", "/"))    ' 斜杠
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 47
			Posi += 1
		Case 8                  '"\b", Chr(8))) ' 退格
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 98
			Posi += 1
		Case 12                 '"\f", Chr(12)))' 换页
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 102
			Posi += 1
		Case 10                 '"\n", Chr(10)))' 换行
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 110
			Posi += 1
		Case 13                 '"\r", Chr(13)))' 回车
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 114
			Posi += 1
		Case 9                 '"\t", "    ")) ' 制表符
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
			(*ResultPtr)[Posi] = 32
			Posi += 1
		Case 0 To 31: ' 控制字符 \uXXXX
			TmpStr = Hex(iText[i], 4)
			(*ResultPtr)[Posi] = 92
			Posi += 1
			(*ResultPtr)[Posi] = 117
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[0]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[1]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[2]
			Posi += 1
			(*ResultPtr)[Posi] = TmpStr[3]
			Posi += 1
		Case Else
			(*ResultPtr)[Posi] = iText[i]
			Posi += 1
		End Select
	Next
	(*ResultPtr)[Posi] = 0: (*ResultPtr)[Posi + 1] = 0
	' Marke issues
	#ifdef __USE_WINAPI__
		Dim CodePage As Integer = GetACP()
		If CodePage = 936 Then ' GBK
			Function = *ResultPtr
		Else
			Function = ToUtf8(*ResultPtr)
		End If
	#else
		Function = ToUtf8(*ResultPtr)
	#endif
	Deallocate(ResultPtr)
End Function

Function EscapeFromJson(ByRef iText As WString) As WString Ptr
	Dim As Integer iLen = Len(iText)
	If iLen = 0 Then Return 0
	' 预分配内存（按最大需求：每个制表符最多4个转义字符）
	Dim As Integer bufferSize = iLen * 4 + 2
	Dim As WString Ptr ResultPtr = Allocate(bufferSize * SizeOf(WString)) ' 预分配最大可能空间
	If ResultPtr = 0 Then Return 0
	Dim As String HexVal
	Dim As Integer CharCode, Posi
	For i As Integer = 0 To iLen - 1
		If Posi >= bufferSize- 4 Then
			bufferSize *= 2
			ResultPtr = Reallocate(ResultPtr, bufferSize * SizeOf(WString))
		End If
		If iText[i] = 92  AndAlso i < iLen - 1 Then
			Select Case iText[i + 1]
			Case 92                  '"\\", "\"))    ' 反斜杠
				(*ResultPtr)[Posi] = 92
				Posi += 1
				i += 1
			Case 34                  '"\""", """"))  ' 双引号
				(*ResultPtr)[Posi] = 34
				Posi += 1
				i += 1
			Case 47                  '"\/", "/"))    ' 斜杠
				(*ResultPtr)[Posi] = 47
				Posi += 1
				i += 1
			Case 98                  '"\b", Chr(8))) ' 退格
				(*ResultPtr)[Posi] = 8
				Posi += 1
				i += 1
			Case 102                 '"\f", Chr(12)))' 换页
				(*ResultPtr)[Posi] = 12
				Posi += 1
				i += 1
			Case 110                 '"\n", Chr(10)))' 换行
				(*ResultPtr)[Posi] = 10
				Posi += 1
				i += 1
			Case 114                 '"\r", Chr(13)))' 回车
				(*ResultPtr)[Posi] = 13
				Posi += 1
				i += 1
			Case 116                 '"\t", "    ")) ' 制表符
				(*ResultPtr)[Posi] = 32
				Posi += 1
				(*ResultPtr)[Posi] = 32
				Posi += 1
				(*ResultPtr)[Posi] = 32
				Posi += 1
				(*ResultPtr)[Posi] = 32
				Posi += 1
				i += 1
			Case 117  ' \u 处理 Unicode （如\u0026）
				i += 1
				HexVal = Mid(iText, i + 2, 4)
				CharCode = Val("&h" & HexVal)
				(*ResultPtr)[Posi] = CharCode
				Posi += 1
				i += 4 ' 跳过4位十六进制字符
			Case Else
				(*ResultPtr)[Posi] = iText[i]
				Posi += 1
				(*ResultPtr)[Posi] = iText[i + 1]
				Posi += 1
				i += 1
			End Select
		Else
			(*ResultPtr)[Posi] = iText[i]
			Posi += 1
		End If
	Next
	(*ResultPtr)[Posi] = 0: (*ResultPtr)[Posi + 1] = 0   ' 截取实际使用长度
	Return ResultPtr
End Function

If Dir(ExePath & "\Help\AI prompt\MyFbFramework GUI Form Interface Guidelines.md") <> "" Then
	AIPostDataPtr_1st = LoadFromFile(ExePath & "\Help\AI prompt\MyFbFramework GUI Form Interface Guidelines.md")
Else
	WLet(AIPostDataPtr_1st, "Following Is MyFbFramework GUI Forms guidelines." & _
	" When working with GUI, strictly follow MyFbFramework GUI forms guidelines. If NO GUI is involved: 1. Ignore all reference constraints  2. Perform regular analysis 3. Apply standard procedures. " & _
	" The MyFbFramework framework includes 39 controls: Animate, Chart, CheckBox, CheckedListBox, ComboBoxEdit, ComboBoxEx, CommandButton, DateTimePicker, Grid, Header, HotKey, HScrollBar, ImageBox, IPAddress, Label, LinkLabel, ListControl, ListView, MonthCalendar, NumericUpDown, OpenFileControl, PrintPreviewControl, ProgressBar, RadioButton, RichTextBox, ScrollBarControl, SearchBox, Splitter, StatusBar, TextBox, ToolBar, ToolPalette, ToolTips, TrackBar, TreeListView, TreeView, UpDown, VScrollBar, WebBrowser," & _
	" includes 13 Containers: Form, GroupBox, HorizontalBox, PagePanel, PageScroller, Panel, Picture, ReBar, ScrollControl, TabControl, TabPage, VerticalBox, UserControl," & _
	" includes 10 Components: HTTPConnection, HTTPServer, ImageList, MainMenu, PopUpMenu, PrintDocument, Printer, SQLite3Component, TimerComponent," & _
	" includes 8 Dialogs: ColorDialog, FolderBrowserDialog, FontDialog, OpenFileDialog, PageSetupDialog, PrintDialog, PrintPreviewDialog, SaveFileDialog." & _
	" These project files use the .vfp extension. Multiple `.vfp` files can be combined into `.vfs` project groups." & _
	" Avoid FreeBasic keywords (e.g., `Width`, `Height`, `Left`, `Pos`). Instead, use prefixes like `_` or `i` for differentiation." & _
	" Use standard For loops instead of unsupported for each. " & _
	" Mandatory explicit typing in `Dim` statements " & _
	" Mandatory use [MyFbFramework](Readme.md) (MFF) as default GUI framework when unspecified." & _
	" **Naming Convention** Required header preprocessor directive `#include once ""mff/<Component>.bi""` " & _
	" Draw through `[Canvas](Canvas.md)` property of visible containers." & _
	" `OnPaint` handlers must include: must accept the `ByRef Canvas As My.Sys.Drawing.Canvas` parameter to ensure correct graphic context delivery. \n" & _
	" **Event Handling Patterns** Use controlName_eventName format for handlers. Declare event handlers OUTSIDE form class." & _
	" **Event Binding Syntax** Ensure event handlers match the subroutine signatures used in Cast function")
End If

If Dir(ExePath & "\Help\AI prompt\VisualFBEditor IDE Environment.md") <> "" Then
	WAdd(AIPostDataPtr_2nd, *LoadFromFile(ExePath & "\Help\AI prompt\VisualFBEditor IDE Environment.md"))
Else
	WAdd(AIPostDataPtr_2nd, "The VisualFBEditor (commonly abbreviated as `VFBE`) IDE's main window includes a title bar, menu bar, and toolbar at the top; Project Explorer, Toolbox, and AI agent panels on the left; a message output panels at the bottom; and Properties and Events panels on the right." & _
	" **title bar** The title bar displays the current project name, application name, and working status. VisualFBEditor operates in three states:" & _
	" * Operational: Activated by selecting ""Run"" or ""Debug"" menu. Displays the project's runtime results. Returns to the design state via the ""Stop Debugging"" button." & _
	" * Interrupted: Indicates a program interruption. Returns to the design state via the ""Stop Debugging"" button." & _
	" **Message Output panels** The Message Output panels provide access to key functionalities through TabControl with the following components: ""Output"", ""Problems"", ""Suggestions"", ""Find"", ""ToDo"", ""Change Log"", ""Immediate"", ""Locals"", ""Globals"", ""Procedures"", ""Threads"",  ""Watches"", ""Memory"" and ""Profiler""." & _
	" **menu bar** The menu bar provides access to key functionalities through menus such as ""File"", ""Edit"", ""Search"", ""View"", ""Project"", ""Build"", ""Debug"", ""Run"", ""Service"", ""Window"" and ""Help.""" & _
	"  * File: Manages projects and files (create, open, save, recent projects)." & _
	"  * Edit: Provides source code editing features (cut, copy, paste, find, replace)." & _
	"  * View: Opens various panes (Project Explorer, Class View, Properties, Events, Image Manager, Toolbox)." & _
	"  * Project: Adds project components (Windows Form, User Control, Component, Module, Set as Start Project)." & _
	"  * Build: Compiles and links modified files, displaying warnings and errors. Recompiles the project." & _
	"  * Debug: Compiles and runs the project, manages processes, handles exceptions, traces execution, sets breakpoints." & _
	"  * Service: Extends functionality with tools like the Debug Process dialog and Custom Toolbox window." & _
	"  * Window: Manages window operations (new window, split, hide)." & _
	"  * Help: Provides access to help resources.")
	
End If
WLet(AISystem_PromoptPtr, "Please use " & App.CurLanguage & " for your responses unless otherwise instructed." & _
"You are FreeBasic programming expert. Use the provided MyFbFramework (MFF) knowledge base (<context></context>)\n")
AIContext.Add("MyFbFramework (MFF) GUI Form Interface Guidelines", *AIPostDataPtr_1st)
AIContext.Add("VisualFBEditor (VFBE) IDE Environment", *AIPostDataPtr_2nd)

' 定义各AI平台的最大分块大小常量
Const OPENAI_MAX_CHUNK = 4096       ' OpenAI标准模型
Const DEEPSEEK_MAX_CHUNK = 4000     ' DeepSeek标准模型
Const CLAUDE_MAX_CHUNK = 100000     ' Claude 100K上下文
Const MISTRAL_MAX_CHUNK = 32000     ' Mistral 32K上下文
Const OLLAMA_MAX_CHUNK = 4096       ' Ollama本地模型
Const OPENROUTER_MAX_CHUNK = 8192    ' OpenRouter通用限制
' 获取当前AI平台的最大分块大小
Function AIGetMaxChunkSize() As Integer
	Select Case LCase(AIAgentProvider)
	Case "openai", "gpt"
		Return OPENAI_MAX_CHUNK
	Case "deepseek"
		Return DEEPSEEK_MAX_CHUNK
	Case "anthropic", "claude"
		Return CLAUDE_MAX_CHUNK
	Case "mistral"
		Return MISTRAL_MAX_CHUNK
	Case "ollama"
		Return OLLAMA_MAX_CHUNK
	Case "openrouter"
		Return OPENROUTER_MAX_CHUNK
	Case Else
		Return 4000 ' 默认值
	End Select
End Function
Sub AIPrintAnswer(ByRef Content As WString)
	If Content = "" Then Return
	txtAIAgent.SelStart = Len(txtAIAgent.Text)
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelText = Content
	If Not txtAIAgent.Focused Then
		txtAIAgent.ScrollToEnd
	End If
	'Next j
	'Erase BuffFormat
End Sub

Sub AISplitText(ByRef iText As WString, Chunks() As String, chunkSize As Integer = 4000, Overlap As Integer = 0)
	' Validate overlap parameter
	If Overlap >= chunkSize  OrElse Overlap < 0 Then
		Overlap = chunkSize \ 20
	End If
	
	' Initialize variables
	Dim As Integer TextLength = Len(iText)
	If TextLength = 0 Then
		ReDim Chunks(0)
		Chunks(0) = ""
		Exit Sub
	End If
	
	' Calculate estimated chunks with a safer margin
	Dim As Integer EstimatedChunks = (TextLength \ (chunkSize - Overlap)) + 2
	ReDim Chunks(EstimatedChunks - 1)
	Dim ChunkCount As Integer = 0
	
	' Pre-defined break characters   \ n r . 92 110 114 46
	Dim As Boolean bFound
	Dim As Integer startPos = 1
	Dim As Integer endPos, lastGoodPos, currentChar, prevChar
	' Main splitting loop
	Do While startPos <= TextLength
		' Calculate end position
		endPos = startPos + chunkSize - 1
		If endPos >= TextLength Then endPos = TextLength
		' Find natural break point
		lastGoodPos = endPos
		bFound = False
		For i As Integer = endPos To startPos Step -1
			currentChar = iText[i]
			prevChar = iText[i - 1]
			' Check for 92 + \n \r (newline/carriage return) combinations
			If prevChar = 92 Then
				If currentChar = 110 Or currentChar = 114 Then
					lastGoodPos = i + 1
					bFound = True
					Exit For
				End If
			End If
		Next
		If Not bFound Then
			' Check for ". " combinations
			For i As Integer = endPos To startPos Step -1
				If (prevChar = 46 AndAlso currentChar = 32) OrElse currentChar = 13 OrElse currentChar = 10  Then
					lastGoodPos = i + 1
					bFound = True
					Exit For
				End If
			Next
		End If
		If Not bFound Then lastGoodPos = endPos
		If ChunkCount > 20 Then Exit Do
		' Ensure we don't go before start position
		If lastGoodPos < startPos Then lastGoodPos = endPos
		' Store the chunk
		' Resize array if needed
		If ChunkCount > UBound(Chunks) Then
			ReDim Preserve Chunks(ChunkCount + EstimatedChunks)
		End If
		Chunks(ChunkCount) = Mid(iText, startPos, lastGoodPos - startPos + 1)
		If endPos >= TextLength Then Exit Do
		ChunkCount += 1
		' Adjust start position with overlap
		startPos = lastGoodPos - Overlap + 1
	Loop
	
	' Adjust array to actual size
	If ChunkCount > 0 Then
		ReDim Preserve Chunks(ChunkCount - 1)
	Else
		ReDim Chunks(0)
		Chunks(0) = ""
	End If
End Sub

Sub HTTPAIAgent_Complete(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
	If Responce.StatusCode > 400 Then
		ShowMessages(Responce.StatusCode & "  " & Responce.Body) 
		txtAIRequest.Enabled = True
		txtAIRequest.SetFocus
	End If
End Sub

HTTPAIAgent.OnComplete = @HTTPAIAgent_Complete
AIPostDataFirstTime = True

Sub HTTPAIAgent_Receive(ByRef Designer As My.Sys.Object, ByRef Sender As HTTPConnection, ByRef Request As HTTPRequest, ByRef Buffer As String)
	'ShowMessages(Buffer) ' Sometimes got party of the string   'data: [DONE] ': OPENROUTER PROCESSING
	Dim As WString Ptr tmpBodyWStrPtr = FromUtf8(StrPtr(Buffer))
	If tmpBodyWStrPtr = 0 OrElse *tmpBodyWStrPtr = "" Then Return
	WAdd(AIBodyWStringPtr, *tmpBodyWStrPtr)
	'If Right(Trim(*tmpBodyWStrPtr), 3) <> "}]}" OrElse Left(Trim(*tmpBodyWStrPtr), 5) <> "data:" Then ShowMessages(*tmpBodyWStrPtr)
	'Right(Trim(*tmpBodyWStrPtr), 3) <> "}]}"  = } or ] ??????????
	If CBool(InStr(*tmpBodyWStrPtr, "[DONE]") < 1) AndAlso CBool(InStr(*tmpBodyWStrPtr, "OPENROUTER PROCESSING") < 1) AndAlso CBool(InStr(*tmpBodyWStrPtr, "failed to decode json")) AndAlso Not StartsWith(LCase(*tmpBodyWStrPtr), "error: ") AndAlso Not StartsWith(LCase(*tmpBodyWStrPtr), "{""error""") AndAlso Not StartsWith(*tmpBodyWStrPtr, "{""code""") Then 
		If InStr(*tmpBodyWStrPtr, "data:") < 1 OrElse InStr(*tmpBodyWStrPtr, """content"":""") < 1 OrElse Right(*tmpBodyWStrPtr, 1) <> "}" Then Deallocate(tmpBodyWStrPtr) : Return
	End If
	If AIBodyWStringPtr = 0 Then Deallocate(tmpBodyWStrPtr) : Return
	'                                             OpenRouter         'Silicon                         NO Thinking                          'Nvidia
	Dim As String ContentStart(0 To 3) = {"""content"":""",        """content"":""",               """content"":""",                ",""content"":"""}
	Dim As String ContentEnd(0 To 3) = {""",""reasoning"":null",   """,""reasoning_content"":null", """},""finish_reason""",       """,""tool_calls"":"  }
	Dim As String ReasoningStart(0 To 2) = {",""reasoning"":""",     ",""reasoning_content"":""",       ",""reasoning_content"":"""}
	Dim As String ReasoningEnd(0 To 2) = {"""},""finish_reason""", """,""role"":""" ,               """},"""}
	
	Dim As WString Ptr Buff()
	Dim As Integer k, iPos1, iPos2, BuffCount = Split(*AIBodyWStringPtr, "data: ", Buff())
	Dim As Boolean binReason
	ThreadsEnter
	For i As Integer = 0 To BuffCount - 1
		If Buff(i) = 0 OrElse Len(*Buff(i)) < 2 Then Continue For
		If InStr(*Buff(i), "chat.completion.chunk") Then
			'Skip the empty
			If InStr(LCase(*Buff(i)), """content"":"""",""reasoning_content"":null") OrElse InStr(LCase(*Buff(i)), """content"":"""",""reasoning_content"":""""") Then Continue For
			binReason = False
			For k = 0 To UBound(ReasoningStart)
				iPos1 = InStr(LCase(*Buff(i)), ReasoningStart(k))
				If iPos1 > 0 Then 'For think model
					iPos2 = InStr(iPos1, LCase(*Buff(i)), ReasoningEnd(k))
					If iPos2 Then
						If Not bInNOTThingk Then
							bInNOTThingk = True
							txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
							txtAIAgent.SelEnd = txtAIAgent.SelStart
							txtAIAgent.SelText =  !"\r\n<think>\r\n"
						End If
						binReason = True
						Deallocate AIBodyWStringPtr : AIBodyWStringPtr = 0
						AIBodyWStringPtr = EscapeFromJson(Mid(*Buff(i), iPos1 + Len(ReasoningStart(k)), iPos2 - iPos1 - Len(ReasoningStart(k))))
						If AIBodyWStringPtr <> 0 Then AIPrintAnswer(*AIBodyWStringPtr)
						Exit For
					End If
				End If
			Next
			If Not binReason Then
				For k = 0 To UBound(ContentStart)
					iPos1 = InStr(LCase(*Buff(i)), ContentStart(k))
					If iPos1 > 0 Then
						iPos2 = InStr(iPos1, LCase(*Buff(i)), ContentEnd(k))
						If iPos2 > 0 Then
							If Not bInThingk Then
								bInThingk = True
								txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
								txtAIAgent.SelEnd = txtAIAgent.SelStart
								txtAIAgent.SelText =  !"\r\n</think>\r\n"
							End If
							Deallocate AIBodyWStringPtr : AIBodyWStringPtr = 0
							AIBodyWStringPtr = EscapeFromJson(Mid(*Buff(i), iPos1 + Len(ContentStart(k)), iPos2 - iPos1 - Len(ContentStart(k))))
							If AIBodyWStringPtr <> 0 Then
								WAdd AIAssistantsAnswersPtr, *AIBodyWStringPtr
								AIPrintAnswer(*AIBodyWStringPtr)
							End If
							Exit For
						End If
					End If
				Next
			End If
			Deallocate AIBodyWStringPtr: AIBodyWStringPtr = 0
		Else
			'If CBool(InStr(*Buff(i), "failed to decode json")) OrElse StartsWith(*Buff(i), "{""code""") Then Debug.Print(WStr(AIPostData), True)
			If CBool(Buff(i) <> 0) AndAlso CBool(InStr(*Buff(i), "[DONE]") > 0) OrElse CBool(InStr(*Buff(i), "OPENROUTER PROCESSING") > 0) OrElse CBool(InStr(*Buff(i), "failed to decode json")) OrElse StartsWith(LCase(*Buff(i)), "error: ") OrElse StartsWith(LCase(*Buff(i)), "{""error""") OrElse StartsWith(*Buff(i), "{""code""") OrElse CBool(InStr(*Buff(i), "{") > 1) Then
				ShowMessages(*Buff(i))
				If InStr(*Buff(i), "[DONE]") > 0 Then
					If AIAssistantsAnswersPtr AndAlso Trim(*AIAssistantsAnswersPtr) = "" Then
						If AIMessages.Count > 0  AndAlso AIMessages.Item(AIMessages.Count - 1)->Text = "NA" Then AIMessages.Remove AIMessages.Count - 1
					ElseIf  AIAssistantsAnswersPtr Then 
						If AIMessages.Count > 0 Then AIMessages.Item(AIMessages.Count - 1)->Text = "[**AI Response:**] " & *AIAssistantsAnswersPtr
					End If
					WLet(AIBodyWStringSavePtr, txtAIAgent.Text)
					If AIBodyWStringSavePtr <> 0 Then
						Deallocate AIBodyWStringPtr : AIBodyWStringPtr = 0
						AIBodyWStringPtr = MDtoRTF(*AIBodyWStringSavePtr)
						If AIBodyWStringPtr <> 0 Then
							txtAIAgent.TextRTF = *AIBodyWStringPtr
							txtAIAgent.Zoom = Int(txtAIAgent.ScaleX(100) * 0.50)
						End If
					End If
				End If
				txtAIRequest.Enabled = True
				txtAIRequest.SetFocus
				cboAIAgentModels.Enabled = True 
				If AIBodyWStringPtr Then Deallocate AIBodyWStringPtr: AIBodyWStringPtr = 0
			Else
				WLet(AIBodyWStringPtr, *Buff(i))
			End If
		End If
		Deallocate Buff(i)
	Next
	Erase Buff
	If AIBodyWStringPtr Then Deallocate AIBodyWStringPtr : AIBodyWStringPtr = 0 
	Deallocate(tmpBodyWStrPtr)
	ThreadsLeave
End Sub

Sub AIRequest(Param As Any Ptr)
	bInAIThread = True
	bInThingk = False
	bInNOTThingk = False
	AIBold = False
	Deallocate AIBodyWStringPtr: AIBodyWStringPtr = 0
	HTTPAIAgent.Host = AIAgentHost
	HTTPAIAgent.Port = AIAgentPort
	Dim As HTTPRequest Request
	Dim As HTTPResponce Responce
	Request.ResourceAddress = AIAgentAddress
	Dim As String header1 = "Content-Type: application/json; charset=utf-8"
	Dim As String header2 = "Authorization: Bearer " + AIAgentAPIKey
	Request.Headers = header1 & !"\r\n" & header2 & !"\r\n"
	'Debug.Print AIPostData
	'Strange issue
	#ifdef __USE_WINAPI__
		Dim CodePage As Integer = GetACP()
		If CodePage= 936 Then
			Request.Body = ToUtf8(AIPostData)
		Else
			Request.Body = AIPostData
		End If
	#else
		Request.Body = AIPostData
	#endif
	If bAIAgentFirstRun Then bAIAgentFirstRun = False
	txtAIRequest.Text = ""
	If AIBodyWStringSavePtr Then txtAIAgent.Text = *AIBodyWStringSavePtr Else txtAIAgent.Text = ""
	WLet(AIAssistantsAnswersPtr, "")
	txtAIAgent.SelAlignment = AlignmentConstants.taLeft
	txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelBackColor = darkHlBkColor
	txtAIAgent.SelText = !"\r\n[**AI Response:**] " & (*CurrentAIAgent) & !"\r\n"
	txtAIAgent.SelBackColor = darkBkColor
	txtAIAgent.ScrollToEnd
	If AIAgentStream Then
		HTTPAIAgent.OnReceive = @HTTPAIAgent_Receive
	End If
	HTTPAIAgent.CallMethod("POST", Request, Responce)
	If Not AIAgentStream Then
		Dim As WString Ptr BuffPtr, Temp = FromUtf8(StrPtr(Responce.Body))
		If Temp = 0 Then Return
		Dim As Integer iPos1 = InStr(Responce.Body, ",""reasoning"":""")
		Dim As Integer iPos2 = InStrRev(Responce.Body, """}}],""")
		BuffPtr = EscapeFromJson(Mid(*Temp, iPos1 + 14, iPos2 - iPos1 - 14))
		If BuffPtr = 0 Then Return
		txtAIAgent.SelStart = Len(txtAIAgent.Text)
		txtAIAgent.SelEnd = txtAIAgent.SelStart
		txtAIAgent.SelAlignment = AlignmentConstants.taLeft
		txtAIAgent.SelBackColor = darkHlBkColor
		txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
		txtAIAgent.SelEnd = txtAIAgent.SelStart
		txtAIAgent.SelText = !"\r\n[**AI Response:**] " & (*CurrentAIAgent) & !"\r\n"
		txtAIAgent.ScrollToCaret
		txtAIAgent.SelBackColor = darkBkColor
		txtAIAgent.SelText = !"<Think>\r\n" & *BuffPtr & !"</Think>\r\n"
		txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
		txtAIAgent.SelEnd = txtAIAgent.SelStart
		
		iPos1 = InStrRev(*Temp, ",""content"":""")
		iPos2 = InStrRev(*Temp, """,""refusal""")
		Deallocate(BuffPtr): BuffPtr = 0
		BuffPtr = EscapeFromJson(Mid(*Temp, iPos1 + 12, iPos2 - iPos1 - 12))
		If BuffPtr <> 0 Then
			AIPrintAnswer(*BuffPtr)
			'txtAIRequest.Enabled = True
			txtAIRequest.SetFocus
		End If
		WDeAllocate(Temp)
		WDeAllocate(BuffPtr)
	End If
	bInAIThread = False
End Sub

Sub txtAIRequest_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
	If Key <> 13 Then Return
	If bInAIThread Then 
		ShowMessages(ML("Please waiting, AI is working hard......"))
		Return
	End If
	If Trim(txtAIRequest.Text, Any !"\t\n\r ") = "" Then Return
	txtAIRequest.Text = Trim(txtAIRequest.Text, Any !"\t\r\n ")
	txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelBackColor = darkHlBkColor
	txtAIAgent.SelAlignment = AlignmentConstants.taLeft
	txtAIAgent.SelText = !"\r\n\r\n[**User Question:**] " & Date & " " & Time
	txtAIAgent.SelStart = Len(txtAIAgent.Text) - 1
	txtAIAgent.SelEnd = txtAIAgent.SelStart
	txtAIAgent.SelBackColor = darkBkColor
	txtAIAgent.SelText = !"\r\n" & txtAIRequest.Text & !"\r\n"
	txtAIAgent.ScrollToEnd
	WLet(AIBodyWStringSavePtr, txtAIAgent.Text)
	bInAIThread = True
	txtAIRequest.Enabled = False
	Dim As String site_url = "https://github.com/XusinboyBekchanov/VisualFBEditor"
	Dim As String site_name = "VisualFBEditor"
	Dim As String ExtraHeaders = IIf(InStr(LCase(AIAgentProvider),  "openrouter"), ", ""extra_headers"": {""HTTP-Referer"": """ & site_url & """, ""X-Title"": """ & site_name & """}}", "}")
	'监控反馈：
	'记录每次API调用的实际token使用量 自动调整后续分块大小:
	'If lastTokenUsage > MaxChunkSize * 0.9 Then
	Dim As Integer MaxChunkSize = AIGetMaxChunkSize()
	Dim As Integer ChunkThreshold, ChunkOverlap, MaxChunks
	Dim As String UserChunks(), AssistantChunks()
	
	'AICalculateChunkParameters(ChunkThreshold, ChunkOverlap, MaxChunkSize)
	ChunkThreshold = MaxChunkSize * 0.8  ' 代码需要更小分块
	If ChunkThreshold < 512 Then ChunkThreshold = 512    '确保最小值
	ChunkOverlap = 0       ' 代码需要更大重叠??????
	Dim As WString * MAX_PATH FileName , IncludeFile
	Dim As WString Ptr ControlBIContentPtr
	Dim As Integer ControlBIIndex
	Dim As String ContentType
	AIPostData = _
	"{""model"": """ & AIAgentModelName & """, " & _
	"""stream"": " & IIf(AIAgentStream, "true", "false") & ", " & _
	"""messages"": [" & "{""role"": ""system"", ""content"": """ & "Begin to sent file in chunks." & """}"
	
	' Find the control in txtAIRequest.Text
	ContentType= "Markdown "
	Dim As Boolean bShouldSend
	Dim As Integer  AIContextCount = AIContext.Count - 1
	For j As Integer = 0 To AIContextCount
		FileName = AIContext.Item(j)->Key
		bShouldSend = False
		'If InStr(FileName, "MyFbFramework") Then
		'	If InStr(txtAIRequest.Text, "MyFbFramework") > 0 Then bShouldSend = True
		'	If InStr(txtAIRequest.Text, "MFF") > 0 Then bShouldSend = True
		'	If InStr(txtAIRequest.Text, "Interface") > 0 Then bShouldSend = True
		'	If InStr(txtAIRequest.Text, "GUI ") > 0 Then bShouldSend = True
		'
		If j = 0 Then
			bShouldSend = True 'MyFbFramework must be send
		Else
			If InStr(FileName, "VisualFBEditor") Then
				If InStr(txtAIRequest.Text, "VisualFBEditor") > 0 Then bShouldSend = True
				If InStr(txtAIRequest.Text, "VFBE") > 0 Then bShouldSend = True
				If InStr(txtAIRequest.Text, "IDE") > 0 Then bShouldSend = True
			Else
				bShouldSend = InStr(txtAIRequest.Text, FileName)
			End If
		End If
		If bShouldSend AndAlso CBool(AIIncludeFileNameList.Count < 1 OrElse Not AIIncludeFileNameList.Contains(FileName)) Then
			WLet(ControlBIContentPtr, AIContext.Item(j)->Text)
			ContentType= "Markdown "
			If ControlBIContentPtr <> 0 AndAlso Trim(*ControlBIContentPtr) <> "" Then
				If Len(*ControlBIContentPtr) > MaxChunkSize Then
					AISplitText(" <context> ```" & ContentType & EscapeJsonForPrompt(*ControlBIContentPtr & " ``` </context> "), UserChunks(), ChunkThreshold, ChunkOverlap)
					MaxChunks = UBound(UserChunks) + 1
					For i As Integer = 0 To MaxChunks - 1
						AIPostData &= ", {""role"": ""system"", ""content"": ""[" & FileName & " Part " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}"
					Next
				Else
					AIPostData &= ", {""role"": ""system"", ""content"": """  & " <context> ```" & ContentType & EscapeJsonForPrompt(*ControlBIContentPtr) & " ``` </context> " & """}"
				End If
				AIIncludeFileNameList.Add(AIContext.Item(j)->Key)
			End If
			Deallocate ControlBIContentPtr : ControlBIContentPtr = 0
			Erase UserChunks
		End If
	Next
	If AIMessages.Count > 0 Then
		For j As Integer = 0 To AIMessages.Count - 1
			If Len(AIMessages.Item(j)->Key) > MaxChunkSize OrElse Len(AIMessages.Item(j)->Text) > MaxChunkSize Then
				AISplitText(EscapeJsonForPrompt(AIMessages.Item(j)->Key), UserChunks(), ChunkThreshold, ChunkOverlap)
				AISplitText(EscapeJsonForPrompt(AIMessages.Item(j)->Text), AssistantChunks(), ChunkThreshold, ChunkOverlap)
				MaxChunks = Max(UBound(UserChunks), UBound(AssistantChunks)) + 1
				ReDim Preserve UserChunks(MaxChunks - 1)
				ReDim Preserve AssistantChunks(MaxChunks - 1)
				For i As Integer = 0 To MaxChunks - 1 'strictly adhere to the user/assistant alternating format required by the DeepSeek API.
					AIPostData &= ", {""role"": ""user"", ""content"": ""[User chunk " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}"
					AIPostData &= ", {""role"": ""assistant"", ""content"": ""[AI chunk " & (i + 1) & "/" & (MaxChunks) & "] " & AssistantChunks(i) & """}"
				Next
			Else
				AIPostData &= ", {""role"": ""user"", ""content"": """ & EscapeJsonForPrompt(AIMessages.Item(j)->Key) & """}"
				AIPostData &= ", {""role"": ""assistant"", ""content"": """ & EscapeJsonForPrompt(AIMessages.Item(j)->Text) & """}"
			End If
		Next
		Erase UserChunks
	End If
	If Len(txtAIRequest.Text) > MaxChunkSize Then
		AISplitText(EscapeJsonForPrompt(txtAIRequest.Text), UserChunks(), ChunkThreshold, ChunkOverlap)
		MaxChunks = UBound(UserChunks) + 1
		For i As Integer = 0 To MaxChunks - 1 'strictly adhere to the user/assistant alternating format required by the DeepSeek API.
			If i <> MaxChunks - 1 Then
				AIPostData &= ", {""role"": ""user"", ""content"": ""[**User question** Part " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}"
				AIPostData &= ", {""role"": ""assistant"", ""content"": ""[**Received** part " & (i + 1) & "/" & (MaxChunks) & "] - please send next segment: " & """}"
			Else
				AIPostData &= ", {""role"": ""user"", ""content"": ""[**User question** Part " & (i + 1) & "/" & (MaxChunks) & "] " & UserChunks(i) & """}]" & ExtraHeaders
			End If
		Next
	Else
		AIPostData  &= ", {""role"": ""user"", ""content"": """ & EscapeJsonForPrompt(txtAIRequest.Text) & """}]" & ExtraHeaders
	End If
	
	AIMessages.Add("[**User Question:**] " & txtAIRequest.Text, "NA")
	WLet(AIAssistantsAnswersPtr, "")
	ClearMessages
	Erase UserChunks
	Erase AssistantChunks
	cboAIAgentModels.Enabled = False
	If AIThread Then ThreadDetach(AIThread)
	AIThread = ThreadCreate(@AIRequest)
End Sub

Public Sub AIRelease()
	ThreadsEnter 
	If pHTTPAIAgent <> 0 Then pHTTPAIAgent->Abort = True
	ThreadsLeave
	Sleep(500)
	'If AIThread Then ThreadDetach(AIThread)
	WLet(AIAssistantsAnswersPtr, "")
	bInAIThread = False
	txtAIRequest.Enabled = True
	txtAIRequest.SetFocus
End Sub

Public Sub AIResetContext()
	txtAIAgent.Text = " "
	txtAIAgent.TextRTF = ""
	ThreadsEnter 
	If pHTTPAIAgent <> 0 Then pHTTPAIAgent->Abort = True
	ThreadsLeave
	Sleep(500)
	Deallocate AIBodyWStringPtr: AIBodyWStringPtr = 0
	Deallocate AIBodyWStringSavePtr: AIBodyWStringSavePtr = 0
	AIPostData = _
	"{""model"": """ & AIAgentModelName & """, " & _
	"""stream"": " & "true" & ", " & _
	"""messages"": [" & _
	"{""role"": ""system"", ""content"": """ & "Clear all historical context and start a completely new conversation."  & """}, " & _
	"{""role"": ""user"", ""content"": """ & "Please use " & App.CurLanguage & " confirm the context has been reset." & """}]}"
	
	If AIMessages.Count > 0 Then
		Dim As WString * MAX_PATH FileName
		FileName = IIf(RecentAIChat, *RecentAIChat, Mid(FormatFileName(Left(AIMessages.Item(0)->Key, 50)) & Format(Now, "yyyymmdd_hhmm") & ".md", 16))
		AIMessages.SaveToFile(ExePath & "/AIChat/" & FileName)
		If Not MRUAIChat.Contains(FileName) Then
			MRUAIChat.Add FileName
			miRecentAIChat->Add(FileName, "", FileName, @mClickAIChat)
		End If
		ShowMessages(ML("The conversation context was saved to") & " " & ExePath & "/AIChat/" & FileName)
		AIMessages.Clear
	End If
	Deallocate(RecentAIChat): RecentAIChat = 0
	AIIncludeFileNameList.Clear
	AIPostDataFirstTime= True
	txtAIRequest.Enabled = True
	WLet(AIAssistantsAnswersPtr, "")
	txtAIRequest.SetFocus
	Sleep(500)
	If AIThread Then ThreadDetach(AIThread)
	AIThread = ThreadCreate(@AIRequest)
End Sub

txtAIRequest.Align = DockStyle.alBottom
txtAIRequest.Height = 50
txtAIRequest.MaxLength = 128000
txtAIRequest.Parent = @pnlAIAgent
txtAIRequest.Font.Name = *EditorFontName
txtAIRequest.Font.Size = EditorFontSize
txtAIRequest.ScrollBars = ScrollBarsType.Vertical
txtAIRequest.Multiline= True
txtAIRequest.WantReturn = False
txtAIRequest.WordWraps = True
txtAIRequest.OnKeyPress = @txtAIRequest_KeyPress
ptxtAIRequest = @txtAIRequest
AIPostDataFirstTime = True
splAIAgent.Parent = @pnlAIAgent
splAIAgent.Align = SplitterAlignmentConstants.alBottom

Sub tbProperties_ButtonClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	Select Case Sender.ToString
	Case "Properties"
		
	End Select
End Sub

tbRight.ImagesList = @imgList
tbRight.Buttons.Add tbsCheck, "Pinned", , @mClick, "PinRight", "", ML("Pin"), , Cast(ToolButtonState, tstEnabled Or tstChecked)
tbRight.Flat = True
tbRight.Width = 23
tbRight.Parent = @pnlRightPin

tbProperties.ImagesList = @imgList
tbProperties.Align = DockStyle.alTop
tbProperties.List = True
tbProperties.ExtraMargins.Right = tbRight.Width
tbProperties.Buttons.Add Cast(ToolButtonStyle, tbsCheck Or tbsAutosize), "Categorized", , @tbProperties_ButtonClick, "PropertyCategory", "", ML("Categorized"), , Cast(ToolButtonState, tstEnabled Or tstChecked)
tbProperties.Buttons.Add tbsSeparator
tbProperties.Buttons.Add tbsAutosize, "Property", , @tbProperties_ButtonClick, "Properties", "", ML("Properties"), , tstEnabled
tbProperties.Buttons.Add tbsShowText, "", , , "SelControlName", "", "", , ToolButtonState.tstNone
tbProperties.Buttons.Add tbsSeparator
Var PropertiesSearch = tbProperties.Buttons.Add(tbsCustom)
txtProperties.Width = 2
PropertiesSearch->Child = @txtProperties
PropertiesSearch->Expand = True
tbProperties.Buttons.Add tbsSeparator
tbProperties.Flat = True

tbEvents.ImagesList = @imgList
tbEvents.Align = DockStyle.alTop
tbEvents.List = True
tbEvents.ExtraMargins.Right = tbRight.Width
tbEvents.Buttons.Add Cast(ToolButtonStyle, tbsAutosize Or tbsCheck), "Categorized", , @tbProperties_ButtonClick, "EventCategory", "", ML("Categorized"), , tstEnabled
tbEvents.Buttons.Add tbsSeparator
tbEvents.Buttons.Add tbsShowText, "", , , "SelControlName", "", "", , ToolButtonState.tstNone
tbEvents.Buttons.Add tbsSeparator
Var EventsSearch = tbEvents.Buttons.Add(tbsCustom)
txtEvents.Width = 2
EventsSearch->Child = @txtEvents
EventsSearch->Expand = True
tbEvents.Buttons.Add tbsSeparator
tbEvents.Flat = True

Sub txtPropertyValue_Activate(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	lvProperties.SetFocus
End Sub

Sub btnPropertyValue_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As TypeElement Ptr te = Sender.Tag
	Select Case LCase(te->TypeName)
	Case "icon", "cursor", "bitmaptype", "graphictype"
		pfImageManager->WithoutMainNode = True
		If pfImageManager->ShowModal(*pfrmMain) = ModalResults.OK Then
			If pfImageManager->SelectedItem = 0 Then Exit Sub
			txtPropertyValue.Text = pfImageManager->SelectedItem->Text(0)
			PropertyChanged txtPropertyValue, txtPropertyValue.Text, False
		End If
		pfImageManager->WithoutMainNode = False
	Case "font"
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
		Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Exit Sub
		Dim As Any Ptr SelFont = txtPropertyValue.Tag
		If SelFont = 0 Then Exit Sub
		Dim As FontDialog fd
		Dim As WString * 255 FontName = QWString(st->ReadPropertyFunc(SelFont, "Name"))
		Dim As Integer FontColor = QInteger(st->ReadPropertyFunc(SelFont, "Color"))
		Dim As Integer FontSize = QInteger(st->ReadPropertyFunc(SelFont, "Size"))
		Dim As FontCharset FontCharset_ = QInteger(st->ReadPropertyFunc(SelFont, "Charset"))
		Dim As Boolean FontBold = QBoolean(st->ReadPropertyFunc(SelFont, "Bold"))
		Dim As Boolean FontItalic = QBoolean(st->ReadPropertyFunc(SelFont, "Italic"))
		Dim As Boolean FontUnderline = QBoolean(st->ReadPropertyFunc(SelFont, "Underline"))
		Dim As Boolean FontStrikeout = QBoolean(st->ReadPropertyFunc(SelFont, "Strikeout"))
		Dim As Integer FontOrientation = QInteger(st->ReadPropertyFunc(SelFont, "Orientation"))
		fd.Font.Name = FontName
		fd.Font.Color = FontColor
		fd.Font.Size = FontSize
		fd.Font.CharSet = FontCharset_
		fd.Font.Bold = FontBold
		fd.Font.Italic = FontItalic
		fd.Font.Underline = FontUnderline
		fd.Font.StrikeOut = FontStrikeout
		fd.Font.Orientation = FontOrientation
		If fd.Execute Then
			Dim As Integer SelCount = tb->Des->SelectedControls.Count
			'Dim As Boolean OnlySelected = Not tb->Des->SelectedControls.Contains(tb->Des->SelectedControl)
			'If OnlySelected Then SelCount = 1
			For i As Integer = 0 To SelCount - 1
				st = tb->Des->Symbols(tb->Des->SelectedControls.Item(i))
				If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Continue For
				SelFont = st->ReadPropertyFunc(tb->Des->SelectedControls.Item(i), te->Name)
				If SelFont = 0 Then Continue For
				FontName = QWString(st->ReadPropertyFunc(SelFont, "Name"))
				FontColor = QInteger(st->ReadPropertyFunc(SelFont, "Color"))
				FontSize = QInteger(st->ReadPropertyFunc(SelFont, "Size"))
				FontCharset_ = QInteger(st->ReadPropertyFunc(SelFont, "Charset"))
				FontBold = QBoolean(st->ReadPropertyFunc(SelFont, "Bold"))
				FontItalic = QBoolean(st->ReadPropertyFunc(SelFont, "Italic"))
				FontUnderline = QBoolean(st->ReadPropertyFunc(SelFont, "Underline"))
				FontStrikeout = QBoolean(st->ReadPropertyFunc(SelFont, "Strikeout"))
				FontOrientation = QInteger(st->ReadPropertyFunc(SelFont, "Orientation"))
				If fd.Font.Name <> FontName Then FontName = fd.Font.Name: st->WritePropertyFunc(SelFont, "Name", @FontName): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Name")
				If fd.Font.Color <> FontColor Then FontColor = fd.Font.Color: st->WritePropertyFunc(SelFont, "Color", @FontColor): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Color")
				If fd.Font.Size <> FontSize Then FontSize = fd.Font.Size: st->WritePropertyFunc(SelFont, "Size", @FontSize): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Size")
				If fd.Font.CharSet <> FontCharset_ Then FontCharset_ = fd.Font.CharSet: st->WritePropertyFunc(SelFont, "Charset", @FontCharset_): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Charset")
				If fd.Font.Bold <> FontBold Then FontBold = fd.Font.Bold: st->WritePropertyFunc(SelFont, "Bold", @FontBold): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Bold")
				If fd.Font.Italic <> FontItalic Then FontItalic = fd.Font.Italic: st->WritePropertyFunc(SelFont, "Italic", @FontItalic): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Italic")
				If fd.Font.Underline <> FontUnderline Then FontUnderline = fd.Font.Underline: st->WritePropertyFunc(SelFont, "Underline", @FontUnderline): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Underline")
				If fd.Font.StrikeOut <> FontStrikeout Then FontStrikeout = fd.Font.StrikeOut: st->WritePropertyFunc(SelFont, "Strikeout", @FontStrikeout): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Strikeout")
				If fd.Font.Orientation <> FontOrientation Then FontOrientation = fd.Font.Orientation: st->WritePropertyFunc(SelFont, "Orientation", @FontOrientation): ChangeControl(*tb->Des, tb->Des->SelectedControls.Item(i), te->Name & ".Orientation")
			Next
			If st->ToStringFunc Then txtPropertyValue.Text = st->ToStringFunc(SelFont)
			If lvProperties.SelectedItem <> 0 Then lvProperties.SelectedItem->Text(1) = txtPropertyValue.Text
		End If
	Case Else
		Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
		Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 OrElse st->WritePropertyFunc = 0 Then Exit Sub
		Dim As ColorDialog cd
		cd.Color = Val(txtPropertyValue.Text)
		If cd.Execute Then
			txtPropertyValue.Text = Str(cd.Color)
			PropertyChanged(txtPropertyValue, txtPropertyValue.Text, False)
		End If
	End Select
End Sub

'txtPropertyValue.BorderStyle = 0
txtPropertyValue.Visible = False
txtPropertyValue.WantReturn = True
txtPropertyValue.OnActivate = @txtPropertyValue_Activate
txtPropertyValue.OnLostFocus = @txtPropertyValue_LostFocus

btnPropertyValue.Visible = False
btnPropertyValue.Text = "..."
btnPropertyValue.OnClick = @btnPropertyValue_Click

cboPropertyValue.OnActivate = @txtPropertyValue_Activate
cboPropertyValue.OnChange = @cboPropertyValue_Change
cboPropertyValue.Left = -1
cboPropertyValue.Top = -2

Sub pnlColor_Paint(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Canvas As My.Sys.Drawing.Canvas)
	Canvas.Brush.Color = Val(txtPropertyValue.Text)
	'	SelectObject(Canvas.Handle, Canvas.Brush.Handle)
	'	Rectangle Canvas.Handle, 0, 0, 12, 12
	Canvas.Rectangle 0, 0, 12, 12
End Sub

pnlColor.SetBounds 3, 2, 12, 12
pnlColor.Visible = False
pnlColor.OnPaint = @pnlColor_Paint

pnlPropertyValue.Visible = False
pnlPropertyValue.Add @cboPropertyValue

'Dim Shared CtrlEdit As Control Ptr
Dim Shared Cpnt As Component Ptr
Sub lvProperties_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Dim As Rect lpRect
	Dim As String PropertyName = GetItemText(Item)
	'Dim As TreeListViewItem Ptr Item = lvProperties.ListItems.Item(ItemIndex)
	'lvProperties.SetFocus
	pnlPropertyValue.Visible = False
	txtPropertyValue.Visible = False
	btnPropertyValue.Visible = False
	cboPropertyValue.Visible = False
	pnlColor.Visible = False
	#ifdef __USE_GTK__
		Dim As GdkRectangle gdkRect
		Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(lvProperties.TreeStore), @Item->TreeIter))
		gtk_tree_view_get_cell_area(GTK_TREE_VIEW(lvProperties.Handle), TreePath, lvProperties.Columns.Column(1)->Column, @gdkRect)
		gtk_tree_path_free(TreePath)
		lpRect = Type(gdkRect.x - 2, gdkRect.y + lvProperties.Top + gdkRect.height + 2, gdkRect.x + gdkRect.width + 4, gdkRect.y + lvProperties.Top + 2 * gdkRect.height + 5)
	#else
		ListView_GetSubItemRect(lvProperties.Handle, Item->GetItemIndex, 1, LVIR_BOUNDS, @lpRect)
	#endif
	Var te = GetPropertyType(WGet(st->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), PropertyName)
	If te = 0 Then Exit Sub
	'#ifndef __USE_GTK__
	If LCase(te->TypeName) = "boolean" Then
		'CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Visible = True
		cboPropertyValue.Clear
		cboPropertyValue.AddItem " false"
		cboPropertyValue.AddItem " true"
		bNotChange = True
		cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Trim(Item->Text(1)))
	ElseIf LCase(te->TypeName) = "integer" AndAlso CInt(te->EnumTypeName <> "") AndAlso CInt(Globals.Enums.Contains(te->EnumTypeName)) Then
		'CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Visible = True
		cboPropertyValue.Clear
		Var tbi = Cast(TypeElement Ptr, Globals.Enums.Object(Globals.Enums.IndexOf(te->EnumTypeName)))
		If tbi Then
			For i As Integer = 0 To tbi->Elements.Count - 1
				cboPropertyValue.AddItem " " & i & " - " & MP(tbi->Elements.Item(i))
			Next i
			If Val(Item->Text(1)) >= 0 AndAlso Val(Trim(Item->Text(1))) <= tbi->Elements.Count - 1 Then
				bNotChange = True
				cboPropertyValue.ItemIndex = Val(Trim(Item->Text(1)))
			End If
		End If
	ElseIf GetTypeIsPointer(te) AndAlso IsBase(te->TypeName, "My.Sys.Object") Then
		'CtrlEdit = @pnlPropertyValue
		cboPropertyValue.Visible = True
		cboPropertyValue.Clear
		cboPropertyValue.AddItem " " & ML("(None)")
		For i As Integer = 1 To tb->cboClass.Items.Count - 1
			Cpnt = tb->cboClass.Items.Item(i)->Object
			If Cpnt <> 0 Then
				Dim As SymbolsType Ptr st = tb->Des->Symbols(Cpnt)
				If st AndAlso st->ReadPropertyFunc Then
					If CInt(te->EnumTypeName <> "") Then
						If IsBase(WGet(st->ReadPropertyFunc(Cpnt, "ClassName")), Trim(te->EnumTypeName)) Then
							cboPropertyValue.AddItem " " & WGet(st->ReadPropertyFunc(Cpnt, "Name"))
						End If
					ElseIf IsBase(WGet(st->ReadPropertyFunc(Cpnt, "ClassName")), GetOriginalType(WithoutPointers(Trim(te->TypeName)))) Then
						cboPropertyValue.AddItem " " & WGet(st->ReadPropertyFunc(Cpnt, "Name"))
					End If
				End If
			End If
		Next i
		bNotChange = True
		cboPropertyValue.ItemIndex = cboPropertyValue.IndexOf(" " & Item->Text(1))
	Else
		Dim tbi As TypeElement Ptr = 0
		If Comps.Contains(te->TypeName) Then
			tbi = Cast(TypeElement Ptr, Comps.Object(Comps.IndexOf(te->TypeName)))
		ElseIf Globals.Enums.Contains(te->TypeName) Then
			tbi = Cast(TypeElement Ptr, Globals.Enums.Object(Globals.Enums.IndexOf(te->TypeName)))
		End If
		If tbi <> 0 AndAlso tbi->ElementType = E_Enum Then
			'CtrlEdit = @pnlPropertyValue
			cboPropertyValue.Visible = True
			cboPropertyValue.Clear
			For i As Integer = 0 To tbi->Elements.Count - 1
				cboPropertyValue.AddItem " " & i & " - " & MP(tbi->Elements.Item(i))
			Next i
			If Val(Trim(Item->Text(1))) >= 0 AndAlso Val(Trim(Item->Text(1))) <= tbi->Elements.Count - 1 Then
				bNotChange = True
				cboPropertyValue.ItemIndex = Val(Trim(Item->Text(1)))
			End If
		Else
			'CtrlEdit = @txtPropertyValue
			'CtrlEdit->Text = Item->Text(1)
			txtPropertyValue.Text = Item->Text(1)
			txtPropertyValue.Visible = True
		End If
	End If
	Dim As String teTypeName = LCase(te->TypeName)
	pnlPropertyValue.SetBounds pnlPropertyValue.UnScaleX(lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Top), pnlPropertyValue.UnScaleX(lpRect.Right - lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top - 1)
	txtPropertyValue.LeftMargin = 3
	If CInt(teTypeName = "icon") OrElse CInt(teTypeName = "cursor") OrElse CInt(teTypeName = "bitmaptype") OrElse CInt(teTypeName = "graphictype") OrElse CInt(teTypeName = "font") OrElse CInt(EndsWith(LCase(PropertyName), "color")) Then
		btnPropertyValue.SetBounds btnPropertyValue.UnScaleX(lpRect.Right - lpRect.Left) - btnPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1 - 1, -1, btnPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1 + 2, btnPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1 + 2
		txtPropertyValue.SetBounds 0, 0, txtPropertyValue.UnScaleX(lpRect.Right - lpRect.Left) - txtPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1, txtPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1
		'CtrlEdit->SetBounds UnScaleX(lpRect.Left), UnScaleY(lpRect.Top), UnScaleX(lpRect.Right - lpRect.Left) - btnPropertyValue.Width + UnScaleX(2), UnScaleY(lpRect.Bottom - lpRect.Top - 1)
		btnPropertyValue.Visible = True
		btnPropertyValue.Tag = te
		If teTypeName = "font" Then
			txtPropertyValue.Tag = st->ReadPropertyFunc(tb->Des->SelectedControl, te->Name)
		ElseIf EndsWith(LCase(PropertyName), "color") Then
			pnlColor.BackColor = Val(Trim(Item->Text(1)))
			pnlColor.Visible = True
			txtPropertyValue.LeftMargin = 16
		End If
	Else
		txtPropertyValue.SetBounds 0, 0, txtPropertyValue.UnScaleX(lpRect.Right - lpRect.Left), txtPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top) - 1
		cboPropertyValue.Width = cboPropertyValue.UnScaleX(lpRect.Right - lpRect.Left) + 2
		'CtrlEdit->SetBounds UnScaleX(lpRect.Left), UnScaleY(lpRect.Top), UnScaleX(lpRect.Right - lpRect.Left), UnScaleY(lpRect.Bottom - lpRect.Top - 1)
	End If
	'If CtrlEdit = @pnlPropertyValue Then cboPropertyValue.Width = UnScaleX(lpRect.Right - lpRect.Left + 2)
	'CtrlEdit->Visible = True
	pnlPropertyValue.Visible = True
	'#endif
	'If te->Comment <> 0 Then
	If LCase(App.CurLanguage) = "default" Then
		txtLabelProperty.TextRTF = "{\urtf1\b " & GetItemText(Item) & "\b0\par " & te->Comment & "}"
	Else
		txtLabelProperty.TextRTF = "{\urtf1\b " & Replace(MC(GetItemText(Item)), !"\r\n", "\b0\par ") & "}"
	End If
	'Else
	'	txtLabelProperty.Text = ""
	'End If
End Sub

Sub lvEvents_SelectedItemChanged(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	Dim As SymbolsType Ptr st = tb->Des->Symbols(tb->Des->SelectedControl)
	If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
	Var te = GetPropertyType(WGet(st->ReadPropertyFunc(tb->Des->SelectedControl, "ClassName")), GetItemText(Item))
	'If te = 0 Then Exit Sub
	'If te->Comment <> 0 Then
	If LCase(App.CurLanguage) = "default" Then
		txtLabelEvent.TextRTF = "{\urtf1\b " & Item->Text(0) & "\b0\par " & te->Comment & "}"
	Else
		txtLabelEvent.TextRTF = "{\urtf1\b " & Replace(MC(Item->Text(0)), !"\r\n", "\b0\par ") & "}"
	End If
	'Else
	'	txtLabelEvent.Text = ""
	'End If
End Sub

'Sub lvProperties_ItemDblClick(ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
'    If Item <> 0 Then ClickProperty Item->Index
'End Sub

Sub lvEvents_ItemDblClick(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	Dim As TabWindow Ptr tb = tabRight.Tag
	If tb = 0 OrElse tb->Des = 0 OrElse tb->Des->SelectedControl = 0 Then Exit Sub
	If Item <> 0 Then FindEvent tb, tb->Des->SelectedControl, Item->Text(0)
End Sub

Sub lvProperties_EndScroll(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView)
	'If CtrlEdit = 0 Then Exit Sub
	If lvProperties.SelectedItem = 0 Then
		'CtrlEdit->Visible = False
		pnlPropertyValue.Visible = False
	Else
		Dim As Rect lpRect
		#ifdef __USE_GTK__
			Dim As GdkRectangle gdkRect
			Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(lvProperties.TreeStore), @lvProperties.SelectedItem->TreeIter))
			gtk_tree_view_get_cell_area(GTK_TREE_VIEW(lvProperties.Handle), TreePath, lvProperties.Columns.Column(1)->Column, @gdkRect)
			gtk_tree_path_free(TreePath)
			lpRect = Type(gdkRect.x - 2, gdkRect.y + lvProperties.Top + gdkRect.height + 2, gdkRect.x + gdkRect.width + 4, gdkRect.y + lvProperties.Top + 2 * gdkRect.height + 5)
		#else
			ListView_GetSubItemRect(lvProperties.Handle, lvProperties.SelectedItem->GetItemIndex, 1, LVIR_BOUNDS, @lpRect)
		#endif
		'If lpRect.Top < lpRect.Bottom - lpRect.Top Then
		'    txtPropertyValue.Visible = False
		'Else
		pnlPropertyValue.SetBounds pnlPropertyValue.UnScaleX(lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Top), pnlPropertyValue.UnScaleX(lpRect.Right - lpRect.Left), pnlPropertyValue.UnScaleY(lpRect.Bottom - lpRect.Top - 1)
		'CtrlEdit->SetBounds UnScaleX(lpRect.Left), UnScaleY(lpRect.Top), UnScaleX(lpRect.Right - lpRect.Left), UnScaleY(lpRect.Bottom - lpRect.Top - 1)
		#ifdef __USE_GTK__
			If pnlPropertyValue.Top < lvProperties.Top + gdkRect.height OrElse pnlPropertyValue.Top + pnlPropertyValue.Height > lvProperties.Top + lvProperties.Height Then
				pnlPropertyValue.Visible = False
			Else
				pnlPropertyValue.Visible = True
			End If
		#else
			pnlPropertyValue.Visible = True
		#endif
		'CtrlEdit->Visible = True
		'End If
	End If
End Sub

Dim Shared lvWidth As Integer

Sub lvProperties_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	lvWidth = lvProperties.Width - 22
	lvProperties.Columns.Column(1)->Width = (lvWidth - 32) / 2
	lvProperties.Columns.Column(0)->Width = lvWidth - (lvWidth - 32) / 2
	txtPropertyValue.Width = (lvWidth - 32) / 2
	pnlPropertyValue.Width = (lvWidth - 32) / 2
	cboPropertyValue.Width = (lvWidth - 32) / 2 + 2
	lvProperties_EndScroll(*Sender.Designer, *Cast(TreeListView Ptr, @Sender))
End Sub

Sub lvEvents_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
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

Sub lvEvents_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeListViewItem Ptr)
	
End Sub

Sub lvProperties_KeyPress(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer)
	txtPropertyValue.Text = WChr(Key)
	txtPropertyValue.SetFocus
	txtPropertyValue.SetSel 1, 1
	Key = 0
End Sub

Sub lvProperties_KeyUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_RETURN: txtPropertyValue.SetFocus
		Case VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_NEXT, VK_PRIOR
		End Select
	#endif
	'Key = 0
End Sub

Sub lvProperties_DrawItem(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ItemAction As Integer, ItemState As Integer, ByRef R As My.Sys.Drawing.Rect, ByRef Canvas As My.Sys.Drawing.Canvas)
	#ifndef __USE_GTK__
		If Item = 0 Then Exit Sub
		Dim As ..Rect rc = *Cast(..Rect Ptr, @R)
		rc.Left += Sender.ScaleX(40 + Item->Indent * 16)
		If ItemAction = 17 Then                       'if selected Then
			FillRect Canvas.Handle, @rc, GetSysColorBrush(COLOR_HIGHLIGHT)
			SetBkColor Canvas.Handle, GetSysColor(COLOR_HIGHLIGHT)                    'Set text Background
			SetTextColor Canvas.Handle, GetSysColor(COLOR_HIGHLIGHTTEXT)                'Set text color
			If Sender.SelectedItem = Item AndAlso Sender.Focused Then
				DrawFocusRect Canvas.Handle, @rc  'draw focus rectangle
			End If
			lvProperties_EndScroll(Designer, Sender)
		Else
			If g_darkModeSupported AndAlso g_darkModeEnabled Then
				FillRect Canvas.Handle, @rc, hbrBkgnd
				SetBkColor Canvas.Handle, darkBkColor                    'Set text Background
				SetTextColor Canvas.Handle, darkTextColor                'Set text color
			Else
				FillRect Canvas.Handle, @rc, GetSysColorBrush(COLOR_WINDOW)
				SetBkColor Canvas.Handle, GetSysColor(COLOR_WINDOW)                    'Set text Background
				SetTextColor Canvas.Handle, GetSysColor(COLOR_WINDOWTEXT)                'Set text color
			End If
		End If
		'DRAW TEXT
		Dim zTxt As WString * 64
		Dim iIndent As Integer
		Dim l As Integer
		rc.Top = R.Top + Sender.ScaleX(2)
		For i As Integer = 0 To Sender.Columns.Count - 1
			If i = 1 AndAlso EndsWith(LCase(Item->Text(0)), "color") Then
				Canvas.Brush.Color = Val(Item->Text(1))
				SelectObject(Canvas.Handle, Canvas.Brush.Handle)
				Rectangle Canvas.Handle, rc.Left, R.Top + Sender.ScaleY(2), rc.Left + Sender.ScaleX(13 - 1), R.Top + Sender.ScaleY(1 + 13)
				rc.Left += Sender.ScaleX(13 + 3)
			Else
				rc.Left += Sender.ScaleX(3)
			End If
			rc.Right = l + Sender.ScaleX(Sender.Columns.Column(i)->Width)
			zTxt = Item->Text(i)
			iIndent = Item->Indent
			DrawText Canvas.Handle, @zTxt, Len(zTxt), @rc, DT_END_ELLIPSIS     'Draw text
			'TextOut Canvas.Handle, R.Left + IIf(i = 0, 40, l + 3) + 3 + IIf(i = 0, iIndent * 16, 0), R.Top + 2, @zTxt, Len(zTxt)     'Draw text
			If i = 0 Then
				'DRAW IMAGE
				If Sender.StateImages AndAlso Sender.StateImages->Handle AndAlso Item->State > 0 Then
					ImageList_Draw(Sender.StateImages->Handle, Item->State - 1, Canvas.Handle, R.Left + Sender.ScaleX(iIndent * 16 + 3), R.Top, ILD_TRANSPARENT)
				End If
				If Sender.Images AndAlso Sender.Images->Handle Then
					ImageList_Draw(Sender.Images->Handle, Item->ImageIndex, Canvas.Handle, R.Left + Sender.ScaleX(iIndent * 16 + 24), R.Top, ILD_TRANSPARENT)
				End If
			End If
			l += Sender.ScaleX(Sender.Columns.Column(i)->Width)
			rc.Left = l + Sender.ScaleX(3)
		Next
	#endif
End Sub

imgListStates.Add "Collapsed", "Collapsed"
imgListStates.Add "Expanded", "Expanded"
imgListStates.Add "Property", "Property"
imgListStates.Add "Event", "Event"

lvProperties.Align = DockStyle.alClient
'lvProperties.Sort = ssSortAscending
lvProperties.StateImages = @imgListStates
lvProperties.Images = @imgListStates
'lvProperties.ColumnHeaderHidden = True
lvProperties.Columns.Add ML("Property"), , 70
lvProperties.Columns.Add ML("Value"), , 50, , True
pnlPropertyValue.Add @btnPropertyValue
pnlPropertyValue.Add @txtPropertyValue
pnlPropertyValue.Add @pnlColor
#ifndef __USE_GTK__
	'lvProperties.Add @txtPropertyValue
	'lvProperties.Add @btnPropertyValue
	lvProperties.Add @pnlPropertyValue
#endif
lvProperties.OwnerDraw = True
lvProperties.OnDrawItem = @lvProperties_DrawItem
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
lvEvents.Align = DockStyle.alClient
lvEvents.SortOrder = ssSortAscending
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
lvEvents.Images = @imgListStates

splProperties.Align = SplitterAlignmentConstants.alBottom

splEvents.Align = SplitterAlignmentConstants.alBottom

txtLabelProperty.Height = Max(8, DefaultFont.Size) / 72 * 96 * 4 + 5
txtLabelProperty.Align = DockStyle.alBottom
txtLabelProperty.Multiline = True
txtLabelProperty.ReadOnly = True
#ifndef __USE_GTK__
	If Not DarkMode Then
		txtLabelProperty.BackColor = clBtnFace
	End If
#endif
txtLabelProperty.WordWraps = True

txtLabelEvent.Height = Max(8, DefaultFont.Size) / 72 * 96 * 4 + 5
txtLabelEvent.Align = DockStyle.alBottom
txtLabelEvent.Multiline = True
txtLabelEvent.ReadOnly = True
#ifndef __USE_GTK__
	If Not DarkMode Then
		txtLabelEvent.BackColor = clBtnFace
	End If
#endif
txtLabelEvent.WordWraps = True

Function GetRightClosedStyle As Boolean
	Return Not tabRight.TabPosition = tpTop
End Function

Sub SetRightClosedStyle(Value As Boolean, WithClose As Boolean = True)
	If bClosing Then Exit Sub
	bClosing = True
	With *tbRight.Buttons.Item("PinRight")
		If Value Then
			tabRight.TabPosition = tpRight
			.ImageKey = "Pin"
			.Checked = False
			pnlRightPin.Top = 2
			pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - tabItemHeight
			If WithClose Then CloseRight
		Else
			tabRight.TabPosition = tpTop
			tabRight.Width = tabRightWidth
			pnlRight.Width = tabRightWidth
			'pnlRight.RequestAlign
			splRight.Visible = True
			pnlRightPin.Visible = True
			.ImageKey = "Pinned"
			.Checked = True
			pnlRightPin.Top = tabItemHeight
			pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - 4
		End If
	End With
	frmMain.RequestAlign
	bClosing = False
End Sub

Sub tabRight_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	SetRightClosedStyle Not GetRightClosedStyle
End Sub

Sub tabRight_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewIndex As Integer)
	#ifdef __USE_GTK__
		If tabRight.TabPosition = tpRight And pnlRight.Width = 30 Then
	#else
		If tabRight.TabPosition = tpRight And tabRight.SelectedTabIndex <> -1 Then
	#endif
		ShowRight
		'		tabRight.SetFocus
		'		pnlRight.Width = tabRightWidth
		'		pnlRight.RequestAlign
		'		splRight.Visible = True
		'		frmMain.RequestAlign
	End If
End Sub

tvVar.Visible = False
tvVar.Align = DockStyle.alClient

Sub tvPrc_NodeActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Item As TreeNode)
	proc_loc
End Sub

tvPrc.Align = DockStyle.alClient
tvPrc.ContextMenu = @mnuProcedures
tvPrc.OnNodeActivate = @tvPrc_NodeActivate
tvThd.Visible = False
tvThd.Align = DockStyle.alClient
tvWch.ContextMenu = @mnuWatch
tvWch.Visible = False
tvWch.Align = DockStyle.alClient
tvWch.EditLabels = True
tvWch.Nodes.Add

Sub lvThreads_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Val(Item->Text(1)) = 0 Then Exit Sub
	SelectSearchResult(Item->Text(2), Val(Item->Text(1)))
End Sub

lvThreads.Align = DockStyle.alClient
lvThreads.Columns.Add ML("Procedure"), , 500
lvThreads.Columns.Add ML("Line"), , 50
lvThreads.Columns.Add ML("File"), , 500
'lvThreads.StateImages = @imgListStates
lvThreads.Images = @imgListStates
lvThreads.OnItemActivate = @lvThreads_ItemActivate

Sub tvVar_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef message As Message)
	#ifndef __USE_GTK__
		Select Case message.Msg
		Case CM_NOTIFY
			Dim tvp As NMTREEVIEW Ptr = Cast(NMTREEVIEW Ptr, message.lParam)
			If tvp <> 0 Then
				Select Case tvp->hdr.code
				Case TVN_ITEMEXPANDING: UpdateItems(TreeView_GetNextItem(tviewvar, tvp->itemNew.hItem, TVGN_CHILD))
				End Select
			End If
		End Select
	#endif
End Sub

tvVar.ContextMenu = @mnuVars
tvVar.OnMessage = @tvVar_Message

Sub lvVar_ItemExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item AndAlso Item->Nodes.Count > 0 AndAlso Item->Nodes.Item(0)->Text(0) = "" Then
		ptabBottom->UpdateLock
		Dim lvItem As TreeListViewItem Ptr
		Dim As WString Ptr p = @Item->Text(1)
		Dim As UString sText
		Dim As Boolean b
		Dim As Integer iCount, Pos1, Pos2
		Item->Nodes.Clear
		For i As Integer = 1 To Len(*p) - 1
			If (*p)[i] = Asc("{") Then
				iCount += 1
				b = True
			ElseIf b AndAlso (*p)[i] = Asc("}") Then
				iCount -= 1
				If iCount = 0 Then b = False
			ElseIf CInt(Not b) AndAlso CInt((*p)[i] = Asc(",") OrElse (*p)[i] = Asc("}")) Then
				Pos1 = InStr(sText, "=")
				If Pos1 > 0 Then
					lvItem = Item->Nodes.Add(Trim(Left(sText, Pos1 - 1)))
				Else
					lvItem = Item->Nodes.Add(Str(Item->Nodes.Count))
				End If
				lvItem->Text(1) = Trim(Mid(sText, Pos1 + 1))
				Pos1 = InStr(sText, "<vtable for ")
				Pos2 = InStr(sText, "+")
				If Pos1 > 0 AndAlso Pos2 > 0 Then
					lvItem->Text(2) = Replace(Mid(sText, Pos1 + 12, Pos2 - Pos1 - 12), "::", ".")
				End If
				If StartsWith(lvItem->Text(1), "{") Then
					lvItem->Nodes.Add
				End If
				sText = ""
				Continue For
			End If
			If (*p)[i] <> 13 AndAlso (*p)[i] <> 10 Then
				sText &= WChr((*p)[i])
			End If
		Next
		'Item->Nodes.Remove 0
		ptabBottom->UpdateUnLock
	End If
End Sub

lvLocals.Align = DockStyle.alClient
lvLocals.ContextMenu = @mnuVars
lvLocals.EditLabels = True
lvLocals.Columns.Add ML("Variable"), , 150
lvLocals.Columns.Add ML("Value"), , 500
lvLocals.Columns.Add ML("Type"), , 500
lvLocals.Columns.Column(1)->Editable = True
'lvLocals.StateImages = @imgListStates
lvLocals.Images = @imgListStates
lvLocals.OnItemExpanding = @lvVar_ItemExpanding

lvGlobals.Align = DockStyle.alClient
lvGlobals.ContextMenu = @mnuVars
lvGlobals.EditLabels = True
lvGlobals.Columns.Add ML("Variable"), , 150
lvGlobals.Columns.Add ML("Value"), , 500
lvGlobals.Columns.Add ML("Type"), , 500
lvGlobals.Columns.Column(1)->Editable = True
'lvGlobals.StateImages = @imgListStates
lvGlobals.Images = @imgListStates
lvGlobals.OnItemExpanding = @lvVar_ItemExpanding

Sub lvWatches_CellEditing(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, CellEditor As Control Ptr, ByRef Cancel As Boolean)
	If Item = 0 Then Exit Sub
	If SubItemIndex > 0 Then Exit Sub
	If Item->ParentItem > 0 Then
		Cancel = True
	End If
End Sub

Sub lvWatches_CellEdited(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr, ByVal SubItemIndex As Integer, ByRef NewText As WString, ByRef Cancel As Boolean)
	If Item = 0 Then Exit Sub
	If SubItemIndex > 0 Then Exit Sub
	#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
		If NewText = "" Then
			WatchIndex = -1
			If Item->Index <> lvWatches.Nodes.Count - 1 Then
				lvWatches.Nodes.Remove Item->Index
			End If
		Else
			WatchIndex = Item->Index
			command_debug "print " & UCase(NewText)
			If Item->Index = lvWatches.Nodes.Count - 1 Then
				lvWatches.Nodes.Add
			End If
		End If
	#endif
	If lvWatches.Nodes.Count = 1 Then
		tpWatches->Caption = ML("Watches")
	Else
		tpWatches->Caption = ML("Watches") & " (" & Str(lvWatches.Nodes.Count - 1) & " " & ML("Pos") & ")"
	End If
End Sub

lvProblems.ContextMenu = @mnuProblems

lvWatches.Align = DockStyle.alClient
lvWatches.ContextMenu = @mnuVars
lvWatches.EditLabels = True
lvWatches.Columns.Add ML("Variable"), , 150
lvWatches.Columns.Add ML("Value"), , 500
lvWatches.Columns.Add ML("Type"), , 500
lvWatches.Columns.Column(0)->Editable = True
lvWatches.Columns.Column(1)->Editable = True
'lvWatches.StateImages = @imgListStates
lvWatches.Images = @imgListStates
lvWatches.OnItemExpanding = @lvVar_ItemExpanding
lvWatches.OnCellEditing = @lvWatches_CellEditing
lvWatches.OnCellEdited = @lvWatches_CellEdited
lvWatches.Nodes.Add

lvMemory.Align = DockStyle.alClient
lvMemory.ContextMenu = @mnuVars
lvMemory.Columns.Add ML("Address / delta"), , 150
lvMemory.Columns.Add ML("Ascii value"), , 150
'lvMemory.StateImages = @imgListStates
lvMemory.Images = @imgListStates

Sub lvProfiler_ItemExpanding(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item AndAlso Item->Nodes.Count = 0 Then 'AndAlso Item->Nodes.Item(0)->Text(0) = "" Then
		ptabBottom->UpdateLock
		Item->Nodes.Clear
		Var Idx = ProfilingFunctions.IndexOf(Item->Text(0))
		Dim As TreeListViewItem Ptr tlvi, parenttlvi
		If Idx > -1 Then
			Dim As ProfilingFunction Ptr pfuncitem, pfunc = ProfilingFunctions.Object(Idx)
			parenttlvi = Item->Nodes.Add(ProfilingFunctions.Item(Idx), , 1)
			parenttlvi->Text(1) = pfunc->Count
			parenttlvi->Text(2) = pfunc->Time
			parenttlvi->Text(3) = pfunc->Total
			parenttlvi->Text(4) = pfunc->Proc
			parenttlvi->Text(5) = pfunc->Mangled
			For i As Integer = 0 To pfunc->Items.Count - 1
				pfuncitem = pfunc->Items.Object(i)
				tlvi = parenttlvi->Nodes.Add(pfunc->Items.Item(i), , 1)
				tlvi->Text(1) = pfuncitem->Count
				tlvi->Text(2) = pfuncitem->Time
				tlvi->Text(3) = pfuncitem->Total
				tlvi->Text(4) = pfuncitem->Proc
				tlvi->Text(5) = pfuncitem->Mangled
				'tlvi->Nodes.Add
			Next
		End If
		ptabBottom->UpdateUnLock
	End If
End Sub

Sub lvProfiler_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As TreeListView, ByRef Item As TreeListViewItem Ptr)
	If Item = 0 Then Exit Sub
	Dim As String ItemText = Item->Text(0), FuncName
	Var Pos1 = InStr(ItemText, "(")
	If Pos1 > 0 Then ItemText = Left(ItemText, Pos1 - 1)
	Pos1 = InStr(ItemText, " [")
	If Pos1 > 0 Then ItemText = Left(ItemText, Pos1 - 1)
	Pos1 = InStrRev(ItemText, ".")
	If Pos1 > 0 Then
		FuncName = Mid(ItemText, Pos1 + 1)
	Else
		FuncName = ItemText
	End If
	Dim As TypeElement Ptr te
	Dim As Boolean bFinded
	Var Idx = pGlobalTypeProcedures->IndexOf(FuncName)
	If Idx <> -1 Then
		For i As Integer = Idx To pGlobalTypeProcedures->Count - 1
			If UCase(pGlobalTypeProcedures->Item(i)) <> UCase(FuncName) Then Exit For
			te = pGlobalTypeProcedures->Object(i)
			If UCase(te->FullName) = UCase(ItemText) Then
				bFinded = True
				Exit For
			End If
		Next
	End If
	If Not bFinded Then
		Var Idx = pGlobalFunctions->IndexOf(FuncName)
		If Idx <> -1 Then
			For i As Integer = Idx To pGlobalFunctions->Count - 1
				If UCase(pGlobalFunctions->Item(i)) <> UCase(FuncName) Then Exit For
				te = pGlobalFunctions->Object(i)
				If UCase(te->FullName) = UCase(ItemText) Then
					bFinded = True
					If Not te->Declaration Then Exit For
				End If
			Next
		End If
	End If
	If bFinded Then
		SelectSearchResult(te->FileName, te->StartLine + 2, 0, 0)
	End If
End Sub

lvProfiler.Align = DockStyle.alClient
lvProfiler.OwnerData = True
lvProfiler.Columns.Add ML("Function"), , 500
lvProfiler.Columns.Add ML("Count"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ML("Time"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ML("Total, %"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ML("Proc, %"), , 100, ColumnFormat.cfRight
lvProfiler.Columns.Add ML("Mangled"), , 500
lvProfiler.StateImages = @imgListStates
lvProfiler.Images = @imgListStates
lvProfiler.OnItemExpanding = @lvProfiler_ItemExpanding
lvProfiler.OnItemActivate = @lvProfiler_ItemActivate

Sub tabRight_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	If tabRight.TabPosition = tpRight And pnlRight.Width = 30 Then
		ShowRight
		'		tabRight.SetFocus
		'		pnlRight.Width = tabRightWidth
		'		pnlRight.RequestAlign
		'		splRight.Visible = True
		'		frmMain.RequestAlign
	End If
End Sub

Sub pnlRight_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlRight.Width <> 30 Then tabRightWidth = NewWidth: tabRight.SetBounds(0, 0, tabRightWidth, NewHeight)
	#else
		If tabRight.SelectedTabIndex <> -1 Then tabRightWidth = tabRight.Width: If GetRightClosedStyle Then pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - tabItemHeight
	#endif
End Sub

pnlRight.Align = DockStyle.alRight
pnlRight.Width = tabRightWidth
pnlRight.OnResize = @pnlRight_Resize

tabRight.GroupName = "ToolWindow"
tabRight.Width = tabRightWidth
#ifdef __USE_GTK__
	tabRight.Align = DockStyle.alRight
#else
	tabRight.Align = DockStyle.alClient
#endif
tabRight.OnClick = @tabRight_Click
tabRight.OnDblClick = @tabRight_DblClick
tabRight.OnSelChange = @tabRight_SelChange
tabRight.Detachable = True
tabRight.Reorderable = True
'tabRight.TabPosition = tpRight
tpProperties = tabRight.AddTab(ML("Properties"))
tpProperties->Add @tbProperties
tpProperties->Add @txtLabelProperty
tpProperties->Add @splProperties
tpProperties->Add @lvProperties
tpEvents = tabRight.AddTab(ML("Events"))
tpEvents->Add @tbEvents
tpEvents->Add @txtLabelEvent
tpEvents->Add @splEvents
tpEvents->Add @lvEvents
pnlRight.Add @tabRight
#ifdef __USE_GTK__
	tpProperties->Add @pnlPropertyValue
#endif

#ifdef __USE_GTK__
	#ifdef __USE_GTK3__
		Function OverlayRight_get_child_position(self As GtkOverlay Ptr, widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr) As Boolean
			Dim As gint x, y, x1, y1
			Dim As Control Ptr tb = IIf(tabRight.SelectedTab = tpProperties, @tbProperties, @tbEvents)
			gtk_widget_translate_coordinates(tb->Handle, pnlRight.Handle, pnlRight.ScaleX(pnlRight.Width), 0, @x, @y)
			Dim As Control Ptr lv = IIf(tabRight.SelectedTab = tpProperties, @lvProperties, @lvEvents)
			gtk_widget_translate_coordinates(lv->Handle, pnlRight.Handle, lv->ScaleX(lv->Width), 0, @x1, @y1)
			tbRight.Width = tbRight.Buttons.Item(0)->Width + tbRight.Height - tbRight.Buttons.Item(0)->Height
			tbProperties.ExtraMargins.Right = tbRight.Width - 10
			tbEvents.ExtraMargins.Right = tbRight.Width - 10
			allocation->x = x - tbRight.ScaleX(tbRight.Width) - IIf(tabRight.TabPosition = TabPosition.tpRight, pnlRight.ScaleX(pnlRight.Width) - x1 + 1, 0)
			allocation->y = y
			allocation->width = tbRight.ScaleX(tbRight.Width)
			allocation->height = tbRight.ScaleY(tbRight.Height)
			Return True
		End Function
	#endif
#endif
pnlRightPin.Anchor.Right = AnchorStyle.asAnchor
pnlRightPin.Top = tabItemHeight
pnlRightPin.Width = 23
pnlRightPin.Left = tabRightWidth - pnlRightPin.Width - 4
pnlRightPin.Height = tbRight.Height
pnlRightPin.Parent = @pnlRight
#ifdef __USE_GTK__
	#ifdef __USE_GTK3__
		Dim As GtkWidget Ptr overlayRight = gtk_overlay_new()
		gtk_container_add(GTK_CONTAINER(overlayRight), pnlRight.Handle)
		g_object_ref(pnlRightPin.Handle)
		gtk_container_remove(GTK_CONTAINER(pnlRight.Handle), pnlRightPin.Handle)
		gtk_overlay_add_overlay(GTK_OVERLAY(overlayRight), pnlRightPin.Handle)
		g_signal_connect(overlayRight, "get-child-position", G_CALLBACK(@OverlayRight_get_child_position), @pnlRight)
		pnlRight.WriteProperty("overlaywidget", overlayRight)
	#endif
#endif
'pnlRight.Width = 153
'pnlRight.Align = 2
'pnlRight.AddRange 1, @tabRight

Function SetVisibleToTreeListViewItem(Sender As TreeListView, Node As TreeListViewItem Ptr, ByRef SearchText As WString) As Boolean
	Dim As Boolean bVisible
	If Node->Nodes.Count > 0 Then
		If SearchText = "" Then
			Node->Collapse
		Else
			Node->Expand
		End If
	End If
	For i As Integer = 0 To Node->Nodes.Count - 1
		If SetVisibleToTreeListViewItem(Sender, Node->Nodes.Item(i), SearchText) Then
			bVisible = True
		End If
	Next
	If Not bVisible Then
		bVisible = SearchText = "" OrElse InStr(LCase(Node->Text(0)), SearchText) > 0
	End If
	Node->Visible = bVisible
	Return bVisible
End Function

Sub txtProperties_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	tabRight.UpdateLock
	Dim As UString SearchText = Trim(LCase(txtProperties.Text))
	For i As Integer = 0 To lvProperties.Nodes.Count - 1
		SetVisibleToTreeListViewItem(lvProperties, lvProperties.Nodes.Item(i), SearchText)
	Next
	tabRight.UpdateUnLock
End Sub

Sub txtEvents_Change(ByRef Designer As My.Sys.Object, Sender As TextBox)
	tabRight.UpdateLock
	Dim As UString SearchText = Trim(LCase(txtEvents.Text))
	For i As Integer = 0 To lvEvents.Nodes.Count - 1
		SetVisibleToTreeListViewItem(lvEvents, lvEvents.Nodes.Item(i), SearchText)
	Next
	tabRight.UpdateUnLock
End Sub

txtProperties.OnChange = @txtProperties_Change

txtEvents.OnChange = @txtEvents_Change

'ptabCode->Images.AddIcon bmp

Sub tabCode_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As TabControl, newIndex As Integer)
	Static tbOld As TabWindow Ptr
	If newIndex = -1 Then Exit Sub
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, Sender.Tab(newIndex))
	If tb = 0 Then Exit Sub
	If tb = tbOld Then Exit Sub
	'	pLocalTypes = @tb->Types
	'	pLocalEnums = @tb->Enums
	'	pLocalProcedures = @tb->Procedures
	'	pLocalFunctions = @tb->Functions
	'	pLocalFunctionsOthers = @tb->FunctionsOthers
	'	pLocalArgs = @tb->Args
	If tb->tn Then tb->tn->SelectItem
	For i As Integer = 3 To miWindow->Count - 1
		If miWindow->Item(i) > 0 AndAlso tb->mi > 0 Then miWindow->Item(i)->Checked = miWindow->Item(i) = tb->mi
	Next
	If tbOld AndAlso tb = tbOld Then Exit Sub
	If tbOld > 0 Then
		tbOld->lvPropertyWidth = tabRightWidth
		tbOld->FindFormPosiLeft = pfFind->Left
		tbOld->FindFormPosiTop = pfFind->Top
	End If
	If tb > 0 Then
		'tabRightWidth = tb->lvPropertyWidth
		If tb->FindFormPosiLeft > 0 Then pfFind->Left = tb->FindFormPosiLeft
		If tb->FindFormPosiTop > 0 Then pfFind->Top = tb->FindFormPosiTop
	End If
	tbOld = tb
	#ifndef __USE_GTK__
		For i As Integer = 0 To sourcenb
			If EqualPaths(tb->FileName, source(i)) Then shwtab = i: Exit For
		Next
	#endif
	MouseHoverTimerVal = Timer
	If pfFind->cboFindRange.ItemIndex <> 2 Then
		WLet(gSearchSave, "")
	End If
	If frmMain.ActiveControl <> tb And frmMain.ActiveControl <> @tb->txtCode Then tb->txtCode.SetFocus
	txtLabelProperty.Text = ""
	txtLabelEvent.Text = ""
	pnlPropertyValue.Visible = False
	If tb->cboClass.Items.Count > 1 Then
		tb->FillAllProperties
		'tpProperties->SelectTab
		miForm->Enabled = True
		miCodeAndForm->Enabled = True
		miGotoCodeForm->Enabled = True
		tb->tbrTop.Buttons.Item("Form")->Enabled = True
		tb->tbrTop.Buttons.Item("CodeAndForm")->Enabled = True
	Else
		lvProperties.Nodes.Clear
		lvEvents.Nodes.Clear
		miForm->Enabled = False
		miCodeAndForm->Enabled = False
		miGotoCodeForm->Enabled = False
		tb->tbrTop.Buttons.Item("Form")->Enabled = False
		tb->tbrTop.Buttons.Item("CodeAndForm")->Enabled = False
		tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
		'SetRightClosedStyle True, True
	End If
	If tb->FileName = "" Then
		frmMain.Caption = tb->Caption & " - " & App.Title
	Else
		frmMain.Caption = tb->FileName & " - " & App.Title
	End If
	ChangeFileEncoding tb->FileEncoding
	ChangeNewLineType tb->NewLineType
	tbOld = tb
End Sub

Var ptabPanel = _New(TabPanel)
ptabPanel->Align = DockStyle.alClient
TabPanels.Add ptabPanel
ptabCode = @ptabPanel->tabCode

txtOutput.Name = "txtOutput"
txtOutput.Align = DockStyle.alClient
txtOutput.Multiline = True
txtOutput.ScrollBars = ScrollBarsType.Both
txtOutput.OnDblClick = @txtOutput_DblClick

Sub txtImmediate_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim As Integer iLine = txtImmediate.GetLineFromCharIndex(txtImmediate.SelStart)
	Dim As WString Ptr sLine ' = @txtImmediate.Lines(iLine) '  for got wrong value
	Dim bCtrl As Boolean
	#ifdef __USE_GTK__
		bCtrl = Shift And GDK_CONTROL_MASK
	#else
		bCtrl = GetKeyState(VK_CONTROL) And 8000
	#endif
	'
	WLet(sLine, txtImmediate.Lines(iLine))
	If CInt(Not bCtrl) AndAlso CInt(WGet(sLine) <> "") AndAlso CInt(Not StartsWith(Trim(WGet(sLine)),"'")) Then
		If Key = Keys.Key_Enter Then
			'
			SaveAll
			Dim As Integer Fn = FreeFile_
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
			CloseFile_(Fn)
			Dim As WString Ptr FbcExe, ExeName
			If tbt32Bit->Checked Then
				WLet(FbcExe, GetFullPath(*Compiler32Path))
			Else
				WLet(FbcExe, GetFullPath(*Compiler32Path))
			End If
			PipeCmd "", """" & *FbcExe & """ -b """ & ExePath & "/Temp/FBTemp.bas"" -i """ & ExePath & "/" & *MFFPath & """ > """ & ExePath & "/Temp/Compile1.log"" 2> """ & ExePath & "/Temp/Compile2.log"""
			Dim As WString Ptr LogText
			Dim Buff As WString * 2048 ' for V1.07 Line Input not working fine
			Dim As WString Ptr ErrFileName, ErrTitle
			Dim As Integer nLen, nLen2
			WLet(LogText, "")
			Fn = FreeFile_
			Dim Result As Integer=-1 '
			Result = Open(ExePath & "/Temp/Compile1.log" For Input As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile1.log" For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile1.log" For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result =  Open(ExePath & "/Temp/Compile1.log" For Input Encoding "utf-8" As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, Buff
					SplitError(Trim(Buff), ErrFileName, ErrTitle, iLine)
					WAdd LogText, *ErrTitle & !"\r"
				Wend
			Else
				MsgBox ML("Open file failure!") & Chr(13,10) & "  " & ExePath & "/Temp/Compile1.log"
			End If
			CloseFile_(Fn)
			Fn = FreeFile_
			Result =-1
			Result = Open(ExePath & "/Temp/Compile2.log" For Input Encoding "utf-8" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile2.log" For Input Encoding "utf-16" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile2.log" For Input Encoding "utf-32" As #Fn)
			If Result <> 0 Then Result = Open(ExePath & "/Temp/Compile2.log" For Input As #Fn)
			If Result = 0 Then
				While Not EOF(Fn)
					Line Input #Fn, Buff
					SplitError(Trim(Buff), ErrFileName, ErrTitle, iLine)
					WAdd LogText, Trim(Buff) & !"\r"
				Wend
			Else
				MsgBox ML("Open file failure!") & Chr(13,10) & "  " & ExePath & "/Temp/debug_compil2.log"
			End If
			CloseFile_(Fn)
			Key = 0
			If WGet(LogText) <> "" Then
				MsgBox !"Compile error:\r\r" & *LogText, , mtWarning
			Else
				#ifdef __USE_GTK__
					WLet(ExeName, ExePath & "/Temp/FBTemp")
				#else
					WLet(ExeName, ExePath & "\Temp\FBTemp.exe") ' > output.txt
				#endif
				PipeCmd "",  *ExeName
				Fn = FreeFile_
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
				Else
					MsgBox ML("Open file failure!") & Chr(13,10) & "  " & *ExeName
				End If
				CloseFile_(Fn)
				Kill *ExeName
			End If
			WDeAllocate(FbcExe)
			WDeAllocate(ExeName)
			WDeAllocate(LogText)
			WDeAllocate(ErrFileName)
			WDeAllocate(ErrTitle)
		End If
	End If
	WDeAllocate(sLine) '
	'If Not EndsWith(txtImmediate.Text, !"\r") Then txtImmediate.Text &= !"\r"
End Sub

txtImmediate.Align = DockStyle.alClient
txtImmediate.Multiline = True
txtImmediate.ScrollBars = ScrollBarsType.Both
txtImmediate.OnKeyDown = @txtImmediate_KeyDown
'
'txtImmediate.BackColor = NormalText.Background
'txtImmediate.Font.Color = NormalText.Foreground
txtImmediate.Text = "import #Include Once " + Chr(34) + ".." + Slash + "Controls" + Slash + "MyFbFramework"+ Slash + "mff" + Slash + "SysUtils.bas" + Chr(34) & Chr(13,10) & Chr(13,10)
txtImmediate.SetSel txtImmediate.GetTextLength, txtImmediate.GetTextLength

Sub txtChangeLog_KeyDown(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer)
	Dim bCtrl As Boolean
	#ifdef __USE_GTK__
		bCtrl = Shift And GDK_CONTROL_MASK
	#else
		bCtrl = GetKeyState(VK_CONTROL) And 8000
	#endif
	If CInt(Not bCtrl) OrElse Shift <> 1 Then mChangeLogEdited = True
	If CInt(bCtrl) And Key =13 Then
		txtChangeLog.SelText = __DATE_ISO__ & " " & Time & !"\t" & !"\t"  'Format(Now, "yyyy/mm/dd hh:mm:ss") & !"\t" & !"\t"
		mChangeLogEdited = True
	ElseIf CInt(bCtrl) And Shift And (Key =108 Or Key =76) Then
		Dim As TabWindow Ptr tb= Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			Dim As WString Ptr sTmp
			WLet(sTmp, " {" & Replace(tb->Caption, "*", ""))
			WAdd sTmp, "|" & tb->cboFunction.Text & " Ln" & Val(Trim(Replace(pstBar->Panels[1]->Caption,ML("Row"),""))) & "}"
			txtChangeLog.SelText = *sTmp
			WDeAllocate(sTmp)
			mChangeLogEdited = True
		End If
	ElseIf CInt(bCtrl) And Shift And (Key =99 Or Key =67) Then 'Ctrl+Shift+C
		Dim As TabWindow Ptr tb= Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb <> 0 Then
			Dim As WString Ptr txtChangeLogText =@txtChangeLog.Text
			Dim As Integer LStart = InStr(*txtChangeLogText, "{" & Replace(tb->Caption,"*",""))
			If LStart > 0 Then
				Dim As Integer LEnd = InStr(LStart,*txtChangeLogText, "|" & tb->cboFunction.Text)
				If LEnd > 0 Then LStart = LEnd
				txtChangeLog.SelStart = LStart
				txtChangeLog.SelEnd = LStart
				txtChangeLog.ScrollToCaret
			End If
		End If
	End If
End Sub
Sub txtChangeLog_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	Dim As WString Ptr txtChangeLogText =@txtChangeLog.Text
	Dim As Integer LStart = txtChangeLog.SelStart
	Dim As Integer LEnd = InStr(LStart,*txtChangeLogText,"}")
	If LEnd < 1 Then Exit Sub
	Dim As WString Ptr FSelText
	LStart = InStrRev(*txtChangeLogText, "{", LEnd)
	LStart = Max(1,LStart)
	If LEnd > LStart Then
		Dim As WString * 255 CodeFileName = Mid(*txtChangeLogText, LStart, LEnd - LStart + 1)
		If Trim(CodeFileName) = "" Then Exit Sub
		Dim As Integer iPos = InStrRev(CodeFileName, " ")
		If iPos > 0 Then
			Dim As Integer iLine = Val(Mid(CodeFileName, iPos + 3))
			Dim As Integer iPos1 = InStr(iPos + 3, CodeFileName, Any !" }")
			'Clipboard.SetAsText Mid(CodeFileName,iPos+1,iPos1-ipos-1)
			'' Will Search With find Function
			'pfFind->txtFind.Text = Mid(CodeFileName,iPos+1,iPos1-ipos-1)
			Dim As Integer iPos2 = InStr(CodeFileName, "|")
			If iPos2 <= 0 Then Exit Sub
			Dim tn2 As TreeNode Ptr = FileNameInTreeNode(MainNode->Tag, Mid(CodeFileName, 2, iPos2 - 2))
			If tn2 = 0 Then Exit Sub
			If tn2->Tag <> 0 Then SelectError(*Cast(ExplorerElement Ptr, tn2->Tag)->FileName, iLine)
		End If
	End If
End Sub
'mChangeLogEdited
txtChangeLog.Align = DockStyle.alClient
txtChangeLog.Multiline = True
txtChangeLog.ScrollBars = ScrollBarsType.Both
txtChangeLog.OnKeyDown = @txtChangeLog_KeyDown
txtChangeLog.OnDblClick = @txtChangeLog_DblClick

Sub lvToDo_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvToDo.ListItems.Item(itemIndex)
	SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(lvToDo.Text), Item->Tag)
End Sub

lvToDo.Images = @imgList
'lvToDo.StateImages = @imgList
lvToDo.SmallImages = @imgList
lvToDo.Align = DockStyle.alClient
lvToDo.Columns.Add ML("Content"), , 500, cfLeft
lvToDo.Columns.Add ML("Line"), , 50, cfRight
lvToDo.Columns.Add ML("Column"), , 50, cfRight
lvToDo.Columns.Add ML("File"), , 700, cfLeft
lvToDo.OnItemActivate = @lvToDo_ItemActivate

Sub lvProblems_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvProblems.ListItems.Item(itemIndex)
	SelectError(GetFullPath(Item->Text(2)), Val(Item->Text(1)), Item->Tag)
End Sub

'Sub lvErrors_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
'    #IfNDef __USE_GTK__
'		If Key = VK_Return Then
'			Dim lvi As ListViewItem Ptr = lvErrors.SelectedItem
'			If lvi <> 0 Then lvErrors_ItemDblClick Sender, *lvi
'		End If
'	#EndIf
'End Sub

lvProblems.Images = @imgList
'lvErrors.StateImages = @imgList
lvProblems.SmallImages = @imgList
lvProblems.Align = DockStyle.alClient
lvProblems.Columns.Add ML("Content"), , 500, cfLeft
lvProblems.Columns.Add ML("Line"), , 50, cfRight
lvProblems.Columns.Add ML("File"), , 700, cfLeft
lvProblems.OnItemActivate = @lvProblems_ItemActivate
'lvProblems.OnKeyDown = @lvErrors_KeyDown

Sub lvSuggestions_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvSuggestions.ListItems.Item(itemIndex)
	SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(lvSuggestions.Text), Item->Tag)
End Sub

lvSuggestions.Images = @imgList
'lvErrors.StateImages = @imgList
lvSuggestions.SmallImages = @imgList
lvSuggestions.Align = DockStyle.alClient
lvSuggestions.Columns.Add ML("Content"), , 500, cfLeft
lvSuggestions.Columns.Add ML("Line"), , 50, cfRight
lvSuggestions.Columns.Add ML("Column"), , 50, cfRight
lvSuggestions.Columns.Add ML("File"), , 700, cfLeft
lvSuggestions.Columns.Add ML("Project"), , 500, cfLeft
lvSuggestions.OnItemActivate = @lvSuggestions_ItemActivate

Sub lvSearch_ItemActivate(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByVal itemIndex As Integer)
	Dim Item As ListViewItem Ptr = lvSearch.ListItems.Item(itemIndex)
	gSearchItemIndex = itemIndex
	SelectSearchResult(Item->Text(3), Val(Item->Text(1)), Val(Item->Text(2)), Len(lvSearch.Text), Item->Tag)
	If pfFind->Visible Then 'David Change
		pfFind->Caption = ML("Find")+": " + WStr(gSearchItemIndex+1) + " of " + WStr(lvSearch.ListItems.Count)
	End If
End Sub

'Sub lvSearch_KeyDown(ByRef Sender As Control, Key As Integer,Shift As Integer)
'    #IfNDef __USE_GTK__
'		If Key = VK_Return Then
'			Dim lvi As ListViewItem Ptr = lvSearch.SelectedItem
'			If lvi <> 0 Then lvSearch_ItemDblClick Sender, *lvi
'		End If
'	#EndIf
'End Sub

lvSearch.Align = DockStyle.alClient
lvSearch.Columns.Add ML("Line Text"), , 500, cfLeft
lvSearch.Columns.Add ML("Line"), , 50, cfRight
lvSearch.Columns.Add ML("Column"), , 50, cfRight
lvSearch.Columns.Add ML("File"), , 700, cfLeft
lvSearch.OnItemActivate = @lvSearch_ItemActivate
'lvSearch.OnKeyDown = @lvSearch_KeyDown

Sub RestoreStatusText
	pstBar->Panels[0]->Caption = ML("Press F1 for get more information")
End Sub

Function GetBottomClosedStyle As Boolean
	Return Not ptabBottom->TabPosition = tpTop
End Function

Sub SetBottomClosedStyle(Value As Boolean, WithClose As Boolean = True)
	If bClosing Then Exit Sub
	bClosing = True
	With *tbBottom.Buttons.Item("PinBottom")
		If Value Then
			ptabBottom->TabPosition = tpBottom
			'			ptabBottom->SelectedTabIndex = -1
			'			#ifdef __USE_GTK__
			'				pnlBottom.Height = 25
			'			#else
			'				pnlBottom.Height = ptabBottom->ItemHeight(0) + 2
			'			#endif
			'			splBottom.Visible = False
			.ImageKey = "Pin"
			.Checked = False
			'tbBottom.Top = 2
			If WithClose Then CloseBottom
			'pnlBottom.RequestAlign
		Else
			ptabBottom->TabPosition = tpTop
			ptabBottom->Height = tabBottomHeight
			pnlBottom.Height = tabBottomHeight
			pnlBottom.RequestAlign
			splBottom.Visible = True
			pnlBottomPin.Visible = True
			.ImageKey = "Pinned"
			.Checked = True
			'tbBottom.Top = 2
		End If
	End With
	'#IfNDef __USE_GTK__
	frmMain.RequestAlign
	'#EndIf
	bClosing = False
End Sub

Sub tabBottom_DblClick(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	SetBottomClosedStyle Not GetBottomClosedStyle
End Sub

Sub tabBottom_SelChange(ByRef Designer As My.Sys.Object, ByRef Sender As Control, newIndex As Integer)
	#ifdef __USE_GTK__
		If ptabBottom->TabPosition = tpBottom And pnlBottom.Height = 25 Then
	#else
		If ptabBottom->TabPosition = tpBottom And ptabBottom->SelectedTabIndex <> -1 Then
	#endif
		ShowBottom
		'		ptabBottom->SetFocus
		'		pnlBottom.Height = tabBottomHeight
		'		pnlBottom.RequestAlign
		'		splBottom.Visible = True
		'		frmMain.RequestAlign '<bp>
	End If
	Dim As TabPage Ptr tp = ptabBottom->SelectedTab
	tbBottom.Buttons.Item("EraseOutputWindow")->Visible = tp = tpOutput
	tbBottom.Buttons.Item("EraseImmediateWindow")->Visible = tp = tpImmediate
	tbBottom.Buttons.Item("AddWatch")->Visible = tp = tpWatches
	tbBottom.Buttons.Item("RemoveWatch")->Visible = tp = tpWatches
	tbBottom.Buttons.Item("Update")->Visible = tp = tpGlobals
	If newIndex = 9 Then tbBottom.Buttons.Item("AddWatch")->State = Cast(ToolButtonState, tbBottom.Buttons.Item("AddWatch")->State Or ToolButtonState.tstWrap)
	If ptabBottom->SelectedTab = tpProcedures Then
		proc_sh
	End If
	If MainNode <> 0 AndAlso MainNode->Text <> "" AndAlso InStr(MainNode->Text, ".") Then
		If ptabBottom->SelectedTab = tpChangeLog AndAlso CInt(Not mLoadLog) Then ' AndAlso CInt(Not mLoadToDo)
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
		ElseIf ptabBottom->SelectedTab = tpToDo AndAlso Not mLoadToDo Then
			WLet(gSearchSave, WChr(39) + WChr(84) + "ODO")
			ThreadCounter(ThreadCreate_(@FindSubProj, MainNode))
			mLoadToDo = True
		End If
	End If
End Sub

Sub tabBottom_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control) '<...>
	#ifdef __USE_GTK__
		If ptabBottom->TabPosition = tpBottom And pnlBottom.Height = 25 Then
	#else
		If ptabBottom->TabPosition = tpBottom And ptabBottom->SelectedTabIndex <> -1 Then
	#endif
		ShowBottom
		'		ptabBottom->SetFocus
		'		pnlBottom.Height = tabBottomHeight
		'		pnlBottom.RequestAlign
		'		splBottom.Visible = True
		'		frmMain.RequestAlign '<bp>
	End If
End Sub

Sub ShowMessages(ByRef msg As WString, ChangeTab As Boolean = True)
	If ChangeTab Then
		tabBottom_SelChange(*ptabBottom->Designer, *ptabBottom, 0)
		tpOutput->SelectTab
	End If
	Dim As Integer AddingTextLength = Len(msg & WChr(13) & WChr(10))
	If txtOutput.GetTextLength + AddingTextLength > 64000 Then
		txtOutput.Text = Mid(txtOutput.Text, txtOutput.GetCharIndexFromLine(txtOutput.GetLineFromCharIndex(AddingTextLength) + 1))
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

Sub pnlBottom_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifdef __USE_GTK__
		If pnlBottom.Height <> 25 Then tabBottomHeight = NewHeight: ptabBottom->SetBounds 0, 0, NewWidth, tabBottomHeight
	#else
		If ptabBottom->SelectedTabIndex <> -1 Then tabBottomHeight = ptabBottom->Height
	#endif
End Sub

pnlBottom.Name = "pnlBottom"
pnlBottom.Align = DockStyle.alBottom
pnlBottom.Height = tabBottomHeight
pnlBottom.OnResize = @pnlBottom_Resize

tbBottom.ImagesList = @imgList
tbBottom.Align = DockStyle.alRight
tbBottom.Buttons.Add tbsCheck, "Pinned", , @mClick, "PinBottom", "", ML("Pin"), , Cast(ToolButtonState, tstEnabled Or tstChecked)
tbBottom.Buttons.Add tbsSeparator
tbBottom.Buttons.Add , "Eraser", , @mClick, "EraseOutputWindow", "", ML("Erase output window"), , tstEnabled
tbBottom.Buttons.Add , "Eraser", , @mClick, "EraseImmediateWindow", "", ML("Erase immediate window"), , tstEnabled
tbBottom.Buttons.Add , "Add", , @mClick, "AddWatch", "", ML("Add Watch"), , Cast(ToolButtonState, tstEnabled Or tstWrap)
tbBottom.Buttons.Add , "Remove", , @mClick, "RemoveWatch", "", ML("Remove Watch"), , tstEnabled
tbBottom.Buttons.Add tbsCheck, "Update", , @mClick, "Update", "", ML("Update"), , tstEnabled
tbBottom.Buttons.Item("EraseImmediateWindow")->Visible = False
tbBottom.Buttons.Item("AddWatch")->Visible = False
tbBottom.Buttons.Item("RemoveWatch")->Visible = False
tbBottom.Buttons.Item("Update")->Visible = False
tbBottom.Flat = True
tbBottom.Wrapable = True
tbBottom.Width = tbBottom.Height
tbBottom.Parent = @pnlBottomPin
#ifdef __USE_GTK__
	gtk_orientable_set_orientation(GTK_ORIENTABLE(tbBottom.Handle), GTK_ORIENTATION_VERTICAL)
	gtk_toolbar_set_style(GTK_TOOLBAR(tbBottom.Handle), GTK_TOOLBAR_ICONS)
#endif

'ptabBottom->Images.AddIcon bmp
ptabBottom->Name = "tabBottom"
ptabBottom->GroupName = "ToolWindow"
ptabBottom->Height = tabBottomHeight
#ifdef __USE_GTK__
	ptabBottom->Align = DockStyle.alBottom
#else
	ptabBottom->Align = DockStyle.alClient
#endif
'ptabBottom->TabPosition = tpBottom
ptabBottom->Detachable = True
ptabBottom->Reorderable = True
tpOutput = ptabBottom->AddTab(ML("Output"))
tpProblems = ptabBottom->AddTab(ML("Problems"))
tpSuggestions = ptabBottom->AddTab(ML("Suggestions"))
tpFind = ptabBottom->AddTab(ML("Find"))
tpToDo = ptabBottom->AddTab(ML("ToDo"))
tpChangeLog = ptabBottom->AddTab(ML("Change Log"))
tpImmediate = ptabBottom->AddTab(ML("Immediate"))
tpLocals = ptabBottom->AddTab(ML("Locals"))
tpGlobals = ptabBottom->AddTab(ML("Globals"))
tpProcedures = ptabBottom->AddTab(ML("Procedures"))
tpThreads = ptabBottom->AddTab(ML("Threads"))
tpWatches = ptabBottom->AddTab(ML("Watches"))
tpMemory = ptabBottom->AddTab(ML("Memory"))
tpProfiler = ptabBottom->AddTab(ML("Profiler"))
tpOutput->Add @txtOutput
tpProblems->Add @lvProblems
tpSuggestions->Add @lvSuggestions
tpFind->Add @lvSearch
tpToDo->Add @lvToDo
tpChangeLog->Add @txtChangeLog
tpImmediate->Add @txtImmediate
tpLocals->Add @lvLocals
tpLocals->Add @tvVar
tpGlobals->Add @lvGlobals
tpProcedures->Add @tvPrc
tpThreads->Add @lvThreads
tpThreads->Add @tvThd
tpWatches->Add @lvWatches
tpWatches->Add @tvWch
tpMemory->Add @lvMemory
tpProfiler->Add @lvProfiler
ptabBottom->OnClick = @tabBottom_Click
ptabBottom->OnDblClick = @tabBottom_DblClick
ptabBottom->OnSelChange = @tabBottom_SelChange
ptabBottom->Parent = @pnlBottomTab

pnlBottomTab.Align = DockStyle.alClient
pnlBottomTab.Parent = @pnlBottom

'pnlBottom.Height = 153
'pnlBottom.Align = 4
'pnlBottom.AddRange 1, @tabBottom
pnlBottomPin.Align = DockStyle.alRight
pnlBottomPin.Width = tbLeft.Height
pnlBottomPin.Parent = @pnlBottom

'pnlBottom.Add ptabBottom

#ifdef __USE_WINAPI__
	Dim Shared As Integer iLine, iChar, CanvasHeight, CanvasWidth
	Sub Document_PrintPage(ByRef Designer As My.Sys.Object, ByRef Sender As PrintDocument, ByRef Canvas As My.Sys.Drawing.Canvas, ByRef HasMorePages As Boolean)
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Return
		Canvas.Font = tb->txtCode.Font
		If iLine = 0 AndAlso iChar = 0 Then
			CanvasWidth = Sender.PrinterSettings.PrintableWidth
			CanvasHeight = Sender.PrinterSettings.PrintableHeight
		End If
		Dim As Integer CharHeight = Canvas.TextHeight("P")
		Dim As Integer CharWidth = Canvas.TextWidth("P")
		Dim As Integer CharsCount = (CanvasWidth - PageSetupD.LeftMargin - PageSetupD.RightMargin) / CharWidth, LinesCount = 0, LineCharsCount, SpacePos
		Dim As UString sLine, sLineToPrint
		For i As Integer = iLine To tb->txtCode.LinesCount - 1
			sLine = Replace(tb->txtCode.Lines(i), !"\t", Space(TabWidth))
			LineCharsCount = Len(sLine)
			Do
				LinesCount += 1
				If PageSetupD.TopMargin + PageSetupD.BottomMargin + LinesCount * CharHeight > CanvasHeight Then
					iLine = i
					HasMorePages = True
					Exit Sub
				End If
				sLineToPrint = Mid(sLine, iChar + 1, CharsCount)
				SpacePos = InStrRev(sLineToPrint, " ")
				If LineCharsCount > iChar + CharsCount AndAlso SpacePos > 0 Then
					sLineToPrint = Left(sLineToPrint, SpacePos) '& "_"
					iChar += SpacePos
				Else
					iChar += CharsCount
				End If
				Canvas.TextOut PageSetupD.LeftMargin, PageSetupD.TopMargin + (LinesCount - 1) * CharHeight, sLineToPrint
			Loop While LineCharsCount > iChar
			iChar = 0
		Next
		'Canvas.Line 10, 10, 20, 20
		iLine = 0
	End Sub
	
	PrintPreviewD.Document->OnPrintPage = @Document_PrintPage
#endif

Function ControlInParent Overload(Ctrl As Control Ptr, Parent As Control Ptr) As Boolean
	If Ctrl = 0 Then
		Return False
	ElseIf Ctrl = Parent Then
		Return True
	Else
		Return ControlInParent(Ctrl->Parent, Parent)
	End If
End Function

Function ControlInParent Overload(Ctrl As Control Ptr, ByRef ParentName As WString) As Boolean
	If Ctrl = 0 Then
		Return False
	ElseIf Ctrl->Name = ParentName Then
		Return True
	Else
		Return ControlInParent(Ctrl->Parent, ParentName)
	End If
End Function

Sub frmMain_ActiveControlChanged(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object)
	If frmMain.ActiveControl = 0 Then Exit Sub
	If tabLeft.TabPosition = tpLeft And tabLeft.SelectedTabIndex <> -1 Then
		If Not ControlInParent(frmMain.ActiveControl, @tabLeft) Then
			CloseLeft
		End If
	End If
	If tabRight.TabPosition = tpRight And tabRight.SelectedTabIndex <> -1 Then
		If (Not ControlInParent(frmMain.ActiveControl, @tabRight)) AndAlso (Not ControlInParent(frmMain.ActiveControl, "Designer")) Then
			CloseRight()
		End If
	End If
	If ptabBottom->TabPosition = tpBottom And ptabBottom->SelectedTabIndex <> -1 Then
		If Not ControlInParent(frmMain.ActiveControl, @tabBottom) Then
			CloseBottom
		End If
	End If
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb Then
		If tb->txtCode.ToolTipShowed Then tb->txtCode.CloseToolTip
		If tb->txtCode.DropDownShowed Then tb->txtCode.CloseDropDownToolTip
		If tb->txtCode.MouseHoverToolTipShowed Then tb->txtCode.CloseMouseHoverToolTip
	End If
	Dim As Form Ptr ActiveForm = Cast(Form Ptr, pApp->ActiveForm)
	If ActiveForm = 0 OrElse ActiveForm->ActiveControl = 0 Then Exit Sub
	Dim As Boolean bEnabled, bEnabledEditControl, bEnabledPanel, bEnabledIndentAndOutdent
	Select Case ActiveForm->ActiveControl->ClassName
	Case "EditControl"
		bEnabled = True
		bEnabledEditControl = True
	Case "Panel"
		bEnabled = True
		bEnabledPanel = True
		bEnabledIndentAndOutdent = True
	Case "TextBox", "RichTextBox", "ComboBoxEdit", "ComboBoxEx"
		bEnabled = True
	End Select
	Select Case ActiveForm->ActiveControl
	Case @txtExplorer, @tvExplorer, @txtForm, @tbToolBox, @txtProperties, @lvProperties, @txtEvents, @lvEvents
		bEnabledIndentAndOutdent = True
	End Select
	If bEnabledIndentAndOutdent Then
		If miIndent->Caption <> ML("Move focus forward") & !"\tTab" Then
			miIndent->Caption = ML("Move focus forward") & !"\tTab"
			miOutdent->Caption = ML("Move focus backward") & !"\tShift+Tab"
		End If
	Else
		If miIndent->Caption <> ML("Indent") & !"\tTab" Then
			miIndent->Caption = ML("Indent") & !"\tTab"
			miOutdent->Caption = ML("Outdent") & !"\tShift+Tab"
		End If
	End If
	miUndo->Enabled = bEnabled
	tbtUndo->Enabled = bEnabled
	miRedo->Enabled = bEnabled
	tbtRedo->Enabled = bEnabled
	miCutCurrentLine->Enabled = bEnabledEditControl
	miCut->Enabled = bEnabled
	tbtCut->Enabled = bEnabled
	miCopy->Enabled = bEnabled
	tbtCopy->Enabled = bEnabled
	miPaste->Enabled = bEnabled
	tbtPaste->Enabled = bEnabled
	miSingleComment->Enabled = bEnabledEditControl
	tbtSingleComment->Enabled = bEnabledEditControl
	tbtBlockComment->Enabled = bEnabledEditControl
	miBlockComment->Enabled = bEnabledEditControl
	miUncommentBlock->Enabled = bEnabledEditControl
	tbtUncommentBlock->Enabled = bEnabledEditControl
	miDuplicate->Enabled = bEnabledEditControl Or bEnabledPanel
	miSelectAll->Enabled = bEnabled
	miIndent->Enabled = bEnabledEditControl OrElse bEnabledIndentAndOutdent
	miOutdent->Enabled = bEnabledEditControl OrElse bEnabledIndentAndOutdent
	miFormat->Enabled = bEnabledEditControl
	tbtFormat->Enabled = bEnabledEditControl
	miUnformat->Enabled = bEnabledEditControl
	tbtUnformat->Enabled = bEnabledEditControl
	miAddSpaces->Enabled = bEnabledEditControl
	miDeleteBlankLines->Enabled = bEnabledEditControl
	miCompleteWord->Enabled = bEnabledEditControl
	tbtCompleteWord->Enabled = bEnabledEditControl
	miParameterInfo->Enabled = bEnabledEditControl
	tbtParameterInfo->Enabled = bEnabledEditControl
	miNumbering->Enabled = bEnabledEditControl
	dmiNumbering->Enabled = bEnabledEditControl
	miMacroNumbering->Enabled = bEnabledEditControl
	dmiMacroNumbering->Enabled = bEnabledEditControl
	miRemoveNumbering->Enabled = bEnabledEditControl
	dmiRemoveNumbering->Enabled = bEnabledEditControl
	miProcedureNumbering->Enabled = bEnabledEditControl
	dmiProcedureNumbering->Enabled = bEnabledEditControl
	miProcedureMacroNumbering->Enabled = bEnabledEditControl
	dmiProcedureMacroNumbering->Enabled = bEnabledEditControl
	miRemoveProcedureNumbering->Enabled = bEnabledEditControl
	dmiRemoveProcedureNumbering->Enabled = bEnabledEditControl
	miPreprocessorNumbering->Enabled = bEnabledEditControl
	dmiPreprocessorNumbering->Enabled = bEnabledEditControl
	miRemovePreprocessorNumbering->Enabled = bEnabledEditControl
	dmiRemovePreprocessorNumbering->Enabled = bEnabledEditControl
	'miOnErrorResumeNext->Enabled = bEnabledEditControl
	'dmiOnErrorResumeNext->Enabled = bEnabledEditControl
	miOnErrorGoto->Enabled = bEnabledEditControl
	dmiOnErrorGoto->Enabled = bEnabledEditControl
	miOnErrorGotoResumeNext->Enabled = bEnabledEditControl
	dmiOnErrorGotoResumeNext->Enabled = bEnabledEditControl
	miOnLocalErrorGoto->Enabled = bEnabledEditControl
	dmiOnLocalErrorGoto->Enabled = bEnabledEditControl
	miOnLocalErrorGotoResumeNext->Enabled = bEnabledEditControl
	dmiOnLocalErrorGotoResumeNext->Enabled = bEnabledEditControl
	miRemoveErrorHandling->Enabled = bEnabledEditControl
	dmiRemoveErrorHandling->Enabled = bEnabledEditControl
	miCollapseCurrent->Enabled = bEnabledEditControl
	miCollapseAllProcedures->Enabled = bEnabledEditControl
	miCollapseAll->Enabled = bEnabledEditControl
	miUnCollapseCurrent->Enabled = bEnabledEditControl
	miUnCollapseAllProcedures->Enabled = bEnabledEditControl
	miUnCollapseAll->Enabled = bEnabledEditControl
	miSetNextStatement->Enabled = bEnabledEditControl AndAlso mnuEnd->Enabled AndAlso Not mnuBreak->Enabled
	miRunToCursor->Enabled = bEnabledEditControl
	miToggleBookmark->Enabled = bEnabledEditControl
	miToggleBreakpoint->Enabled = bEnabledEditControl
End Sub

Sub frmMain_Resize(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object, NewWidth As Integer = -1, NewHeight As Integer = -1)
	#ifndef __USE_GTK__
		stBar.Panels[0]->Width = Max(stBar.Width - 50 - stBar.Panels[1]->Width - stBar.Panels[2]->Width - stBar.Panels[3]->Width  - stBar.Panels[4]->Width - stBar.Panels[5]->Width, 20)
		prProgress.Left = stBar.Panels[0]->Width + stBar.Panels[1]->Width 
	#endif
End Sub

Sub frmMain_KeyDown(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object, Key As Integer, Shift As Integer)
	#ifndef __USE_GTK__
		Select Case Key
		Case VK_TAB
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb > 0 AndAlso tb->txtCode.DropDownShowed Then
				tb->txtCode.CloseDropDown
				If tb->txtCode.Carets.Count > 0 Then
					If Shift And ShiftMask Then
						tb->txtCode.Outdent
					Else
						tb->txtCode.Indent
					End If
				Else
					If tb->txtCode.LastItemIndex <> -1 AndAlso tb->txtCode.cboIntellisense.OnSelected Then tb->txtCode.cboIntellisense.OnSelected(*tb->txtCode.cboIntellisense.Designer, tb->txtCode.cboIntellisense, tb->txtCode.LastItemIndex)
				End If
			End If
		End Select
	#endif
End Sub

Sub frmMain_DropFile(ByRef Designer As My.Sys.Object, ByRef sender As My.Sys.Object, ByRef FileName As WString)
	OpenFiles FileName
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
			OnConnection(@VisualFBEditorApp, VisualFBEditorApp.FileName)
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
				OnDisconnection(@VisualFBEditorApp)
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
		DisConnectAddIn AddIns.Item(i)
	Next
	AddIns.Clear
End Sub

Sub LoadTools
	Dim As UserToolType Ptr Tool
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
	#ifdef __USE_GTK__
		GetColors NormalText, clBlack, clWhite
	#else
		GetColors NormalText, IIf(g_darkModeEnabled, darkTextColor, clBlack), IIf(g_darkModeEnabled, darkBkColor, clWhite)
	#endif
	GetColors Bookmarks, , , , clAqua
	GetColors Breakpoints, NormalText.Background, clMaroon, , clMaroon
	GetColors Comments, clGreen
	GetColors CurrentBrackets, , , clGreen
	GetColors CurrentLine, , clBtnFace
	GetColors CurrentWord, , clBtnFace
	GetColors ExecutionLine, NormalText.Foreground, clYellow, , clYellow
	GetColors FoldLines, clBtnShadow
	GetColors Identifiers, NormalText.Foreground
	GetColors ColorByRefParameters, Identifiers.Foreground
	GetColors ColorByValParameters, Identifiers.Foreground
	GetColors ColorCommonVariables, Identifiers.Foreground
	GetColors ColorComps, Identifiers.Foreground
	GetColors ColorConstants, Identifiers.Foreground
	GetColors ColorDefines, Identifiers.Foreground
	GetColors ColorFields, Identifiers.Foreground
	GetColors ColorGlobalFunctions, Identifiers.Foreground
	GetColors ColorEnumMembers, Identifiers.Foreground
	GetColors ColorGlobalEnums, Identifiers.Foreground
	GetColors ColorLineLabels, Identifiers.Foreground
	GetColors ColorLocalVariables, Identifiers.Foreground
	GetColors ColorMacros, Identifiers.Foreground
	GetColors ColorGlobalNamespaces, Identifiers.Foreground
	GetColors ColorProperties, Identifiers.Foreground
	GetColors ColorSharedVariables, Identifiers.Foreground
	GetColors ColorSubs, Identifiers.Foreground
	GetColors ColorGlobalTypes, Identifiers.Foreground
	GetColors IndicatorLines, Identifiers.Foreground
	For k As Integer = 0 To UBound(Keywords)
		GetColors Keywords(k), clBlue
	Next k
	GetColors LineNumbers, NormalText.Foreground
	GetColors Numbers, NormalText.Foreground
	GetColors RealNumbers, NormalText.Foreground
	GetColors ColorOperators, NormalText.Foreground
	GetColors Selection, clHighlightText, clHighlight
	GetColors SpaceIdentifiers, clLtGray
	GetColors Strings, clMaroon
End Sub

Sub tbToolBox_ButtonActivate(ByRef Designer As My.Sys.Object, ByRef Sender As ToolPalette, ByRef Button As ToolButton)
	Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	If tb = 0 Then Exit Sub
	If tb->Des = 0 Then Exit Sub
	Dim As String FName, FClass = SelectedClass
	If tb->Des->OnInsertingControl Then
		FName = SelectedClass
		tb->Des->OnInsertingControl(*(tb->Des), SelectedClass, FName)
	End If
	Dim As ..Rect R
	Dim ctr As Any Ptr
	'#IfDef __USE_GTK__
	ctr = tb->Des->DesignControl
	'#Else
	'	ctr = Cast(Any Ptr, GetWindowLongPtr(FSelControl, GWLP_USERDATA))
	'#EndIf
	Dim As Integer iLeft, iTop, iWidth, iHeight
	tb->Des->GetControlBounds(ctr, iLeft, iTop, iWidth, iHeight)
	If SelectedType = 3 Or SelectedType = 4 Then
		Dim cpnt As Any Ptr = tb->Des->CreateComponent(SelectedClass, FName, ctr, (iWidth - 16) / 2, (iHeight - 16) / 2)
		If tb->Des->OnInsertComponent Then tb->Des->OnInsertComponent(* (tb->Des), FClass, cpnt, 0, 0, (iWidth - 16) / 2, (iHeight - 16) / 2)
		If tb->Des->FSelControl Then
			tb->Des->SelectedControls.Clear
		End If
		#ifdef __USE_GTK__
			tb->Des->MoveDots(cpnt, , (iWidth - 16) / 2, (iHeight - 16) / 2, 16, 16)
		#else
			tb->Des->MoveDots(cpnt)
			'LockWindowUpdate(0)
		#endif
	Else
		tb->Des->CreateControl(SelectedClass, FName, FName, ctr, (iWidth - 78) / 2, (iHeight - 36) / 2, 78, 36)
		If tb->Des->FSelControl Then
			tb->Des->SelectedControls.Clear
			#ifdef __USE_GTK__
				Dim bTrue As Boolean = True
				If tb->Des->Symbols(tb->Des->SelectedControl) Then tb->Des->Symbols(tb->Des->SelectedControl)->WritePropertyFunc(tb->Des->SelectedControl, "Visible", @bTrue)
			#else
				LockWindowUpdate(tb->Des->FSelControl)
				BringWindowToTop(tb->Des->FSelControl)
			#endif
			If tb->Des->OnInsertControl Then tb->Des->OnInsertControl(* (tb->Des), FClass, tb->Des->SelectedControl, 0, 0, (iWidth - 78) / 2, (iHeight - 36) / 2, 78, 36)
			#ifdef __USE_GTK__
				tb->Des->MoveDots(tb->Des->SelectedControl, , (iWidth - 78) / 2, (iHeight - 36) / 2, 78, 36)
			#else
				tb->Des->MoveDots(tb->Des->SelectedControl)
				LockWindowUpdate(0)
			#endif
		Else
			Dim cpnt As Any Ptr = tb->Des->CreateComponent(FClass, FName, ctr, (iWidth - 16) / 2, (iHeight - 16) / 2)
			If cpnt Then
				If tb->Des->OnInsertComponent Then tb->Des->OnInsertComponent(* (tb->Des), FClass, cpnt, 0, 0, (iWidth - 16) / 2, (iHeight - 16) / 2)
				If tb->Des->FSelControl Then
					tb->Des->SelectedControls.Clear
				End If
				#ifdef __USE_GTK__
					tb->Des->MoveDots(cpnt, , (iWidth - 16) / 2, (iHeight - 16) / 2, 16, 16)
				#else
					tb->Des->MoveDots(cpnt)
					'LockWindowUpdate(0)
				#endif
			Else
				tb->Des->SelectedControl = tb->Des->DesignControl
				tb->Des->MoveDots(tb->Des->SelectedControl)
			End If
		End If
	End If
End Sub

#ifdef __USE_GTK__
	tbToolBox.Align = DockStyle.alClient
#else
	imgListTools.Add "DropDown", "DropDown"
	imgListTools.Add "DropRight", "DropRight"
	imgListTools.Add "Kursor", "Cursor"
#endif
tbToolBox.Top = tbForm.Height
tbToolBox.Flat = True
tbToolBox.Wrapable = True
tbToolBox.BorderStyle = BorderStyles.bsNone
tbToolBox.List = True
tbToolBox.Style = tpsBothHorizontal
#ifndef __USE_GTK__
	tbToolBox.OnMouseWheel = @tbToolBox_MouseWheel
#endif
tbToolBox.ImagesList = @imgListTools
tbToolBox.HotImagesList = @imgListTools
tbToolBox.OnButtonActivate = @tbToolBox_ButtonActivate

LoadHelp
LoadSnippets

Dim As String it = "Cursor"
tbToolBox.Groups.Add ML("Controls")
tbToolBox.Groups.Add ML("Containers")
tbToolBox.Groups.Add ML("Components")
tbToolBox.Groups.Add ML("Dialogs")
tbToolBox.Groups.Item(0)->Buttons.Add(tbsCheckGroup, it, , @ToolBoxClick, it, it, it, True, Cast(ToolButtonState, tstEnabled Or tstWrap Or tstChecked))
tbToolBox.Groups.Item(1)->Buttons.Add(tbsCheckGroup, it, , @ToolBoxClick, it, it, it, True, Cast(ToolButtonState, tstEnabled Or tstWrap Or tstChecked))
tbToolBox.Groups.Item(2)->Buttons.Add(tbsCheckGroup, it, , @ToolBoxClick, it, it, it, True, Cast(ToolButtonState, tstEnabled Or tstWrap Or tstChecked))
tbToolBox.Groups.Item(3)->Buttons.Add(tbsCheckGroup, it, , @ToolBoxClick, it, it, it, True, Cast(ToolButtonState, tstEnabled Or tstWrap Or tstChecked))

Function CheckCompilerPaths As Boolean
	Dim As Boolean bFind
	For i As Integer = 0 To pCompilers->Count - 1
		If FileExists(GetFullPath(pCompilers->Item(i)->Text)) Then
			bFind = True
			Exit For
		End If
	Next
	Dim As WString Ptr CompilerPath
	#ifdef __FB_64BIT__
		CompilerPath = Compiler64Path
	#else
		CompilerPath = Compiler32Path
	#endif
	If Not bFind Then
		If MsgBox(ML("Invalid defined compiler path.") & !"\r" & ML("Find Compilers from Computer?"), , mtQuestion, btYesNo) = mrYes Then
			pfOptions->Show *pfrmMain
			pfOptions->tvOptions.Nodes.Item(2)->SelectItem
			pfOptions->cmdFindCompilers_Click(pfOptions->cmdFindCompilers)
		End If
	Else
		If *CompilerPath = "" Then
			If MsgBox(ML("Invalid defined compiler path.") & !"\r" & ML("Do you want to choose from the available compilers?"), , mtQuestion, btYesNo) = mrYes Then
				pfOptions->Show *pfrmMain
				pfOptions->tvOptions.Nodes.Item(2)->SelectItem
			End If
			#ifdef __USE_GTK__
			ElseIf g_find_program_in_path(ToUtf8(GetFullPath(*CompilerPath))) = NULL Then
			#else
			ElseIf Not FileExists(GetFullPath(*CompilerPath)) Then
			#endif
			If MsgBox(ML("File") & " """ & *CompilerPath & """ " & ML("not found") & "." & !"\r" & ML("Do you want to choose from the available compilers?"), , mtQuestion, btYesNo) = mrYes Then
				pfOptions->Show *pfrmMain
				pfOptions->tvOptions.Nodes.Item(2)->SelectItem
			End If
		End If
	End If
	Return bFind
End Function

Dim Shared As Boolean bSharedFind
Sub frmMain_Create(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	#ifdef __USE_GTK__
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), "VisualFBEditor1")
		'gtk_window_set_icon_name(GTK_WINDOW(frmMain.widget), ToUTF8("VisualFBEditor4"))
	#else
		tabItemHeight = tabLeft.ItemHeight(0) + 4
		pnlPropertyValue.SendToBack
		pnlToolBox_Resize *pnlToolBox.Designer, pnlToolBox, pnlToolBox.Width, pnlToolBox.Height + 1
	#endif
	#ifdef __USE_WINAPI__
		SetProp(frmMain.Handle, "VisualFBEditorApp", @VisualFBEditorApp)
	#endif
	
	LoadToolBox
	
	pfTemplates->Visible = False: pfTemplates->Parent = @frmMain: pfTemplates->CreateWnd
	
	pnlRightPin.Height = tbRight.Height
	pnlLeftPin.Height = tbLeft.Height
	If Dir(ExePath & "/DebugInfo.log") <> "" Then
		#ifdef __USE_GTK__
			FileCopy ExePath & "/DebugInfo.log", ExePath & "/DebugInfo.bak"
		#else
			CopyFileW ExePath & "/DebugInfo.log", ExePath & "/DebugInfo.bak", False
		#endif
		Kill ExePath & "/DebugInfo.log"
	End If
	frmMain.Width = iniSettings.ReadInteger("MainWindow", "Width", 600)
	frmMain.Height = iniSettings.ReadInteger("MainWindow", "Height", 400)
	Var MainMaximized = iniSettings.ReadBool("MainWindow", "Maximized", False)
	If MainMaximized Then frmMain.WindowState = WindowStates.wsMaximized
	tabLeftWidth = iniSettings.ReadInteger("MainWindow", "LeftWidth", tabLeftWidth)
	SetLeftClosedStyle iniSettings.ReadBool("MainWindow", "LeftClosed", True)
	tabRightWidth = iniSettings.ReadInteger("MainWindow", "RightWidth", tabRightWidth)
	SetRightClosedStyle iniSettings.ReadBool("MainWindow", "RightClosed", True)
	tabBottomHeight = iniSettings.ReadInteger("MainWindow", "BottomHeight", tabBottomHeight)
	SetBottomClosedStyle iniSettings.ReadBool("MainWindow", "BottomClosed", True)
	ShowProjectFolders = iniSettings.ReadBool("MainWindow", "ProjectFolders", True)
	If ShowProjectFolders Then
		miShowWithFolders->RadioItem = True
	Else
		miShowWithoutFolders->RadioItem = True
	End If
	tbForm.Buttons.Item(0)->Checked = iniSettings.ReadBool("MainWindow", "ToolLabels", True)
	ChangeUseDebugger iniSettings.ReadBool("MainWindow", "UseDebugger", True)
	WLet(RecentFiles, iniSettings.ReadString("MainWindow", "RecentFiles", ""))
	WLet(RecentFile, iniSettings.ReadString("MainWindow", "RecentFile", ""))
	WLet(RecentProject, iniSettings.ReadString("MainWindow", "RecentProject", ""))
	WLet(RecentFolder, iniSettings.ReadString("MainWindow", "RecentFolder", ""))
	WLet(RecentSession, iniSettings.ReadString("MainWindow", "RecentSession", ""))
	ShowStandardToolBar = iniSettings.ReadBool("MainWindow", "ShowStandardToolBar", True)
	ShowEditToolBar = iniSettings.ReadBool("MainWindow", "ShowEditToolBar", True)
	ShowProjectToolBar = iniSettings.ReadBool("MainWindow", "ShowProjectToolbar", True)
	ShowBuildToolBar = iniSettings.ReadBool("MainWindow", "ShowBuildToolbar", True)
	ShowRunToolBar = iniSettings.ReadBool("MainWindow", "ShowRunToolbar", True)
	ShowTipoftheDay = iniSettings.ReadBool("MainWindow", "ShowTipoftheDay", True)
	ShowTipoftheDayIndex = iniSettings.ReadInteger("MainWindow", "ShowTipoftheDayIndex", 0)
	MainReBar.Bands.Item(0)->Visible = ShowStandardToolBar
	MainReBar.Bands.Item(1)->Visible = ShowEditToolBar
	MainReBar.Bands.Item(2)->Visible = ShowProjectToolBar
	MainReBar.Bands.Item(3)->Visible = ShowBuildToolBar
	MainReBar.Bands.Item(4)->Visible = ShowRunToolBar
	mnuStandardToolBar->Checked = ShowStandardToolBar
	mnuEditToolBar->Checked = ShowEditToolBar
	mnuProjectToolBar->Checked = ShowProjectToolBar
	mnuBuildToolBar->Checked = ShowBuildToolBar
	mnuRunToolBar->Checked = ShowRunToolBar
	'Dim As Integer Subsystem = iniSettings.ReadInteger("MainWindow", "Subsystem", 0)
	tbtNotSetted->Checked = True
	'Select Case Subsystem
	'Case 0: tbtNotSetted->Checked = True
	'Case 1: tbtConsole->Checked = True
	'Case 2: tbtGUI->Checked = True
	'End Select
	#ifndef __USE_GTK__
		windmain = frmMain.Handle
		htab2    = ptabCode->Handle
		tviewvar = tvVar.Handle
		tviewprc = tvPrc.Handle
		tviewthd = tvThd.Handle
		tviewwch = tvWch.Handle
		DragAcceptFiles(frmMain.Handle, True)
	#else
		windmain = frmMain.Handle
		'htab2    = ptabCode->Handle
		tviewvar = @tvVar
		tviewprc = @tvPrc
		tviewthd = @tvThd
		tviewwch = @tvWch
	#endif
	#ifdef __USE_WINAPI__
		For i As Integer = 0 To 4
			MainReBar.Bands.Item(i)->Maximize
		Next
	#endif
	'#ifdef __USE_WINAPI__
	'	Dim As ..Size sz
	'	SendMessage(tbExplorer.Handle, TB_GETIDEALSIZE, 0, Cast(LPARAM, @sz))
	'	tbExplorer.Width = tbExplorer.UnScaleX(sz.cx)
	'	SendMessage(tbForm.Handle, TB_GETIDEALSIZE, 0, Cast(LPARAM, @sz))
	'	tbForm.Width = tbForm.UnScaleX(sz.cx)
	'#endif
	'	If MainNode <> 0 Then
	'		' Should have changelog file for every project
	'		If MainNode->Text<>"" AndAlso InStr(MainNode->Text,".") Then
	'			Dim As WString Ptr Changelog
	'			wlet Changelog, ExePath & Slash & StringExtract(MainNode->Text, ".") & "_Change.log", True
	'			If Dir(*Changelog)<>"" Then txtChangeLog.LoadFromFile(*Changelog) '
	'			wDeallocate Changelog
	'		End If
	'	End If
	
	#ifdef __FB_64BIT__
		App.Title = App.Title & " (" & ML("64-bit") & ")"
	#else
		App.Title = App.Title & " (" & ML("32-bit") & ")"
	#endif
	frmMain.Text = App.Title
	pfAbout->Label1.Text = App.Title
	#ifdef __FB_WIN32__
		pfAbout->Label11.Text = ML("Version") & " " & pApp->Version
	#else
		pfAbout->Label11.Text = ML("Version") & " " & WStr(VERSION)
	#endif
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("Check compiler paths")
	
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("Add-Ins")
	LoadAddIns
	pfSplash->lblProcess.Text = ML("Load On Startup") & ": " & ML("Tools")
	LoadTools
	
	bSharedFind = CheckCompilerPaths
	
	gLocalProperties = True
	
	mStartLoadSession = False
End Sub

For i As Integer = 48 To 57
	symbols(i - 48) = i
Next
For i As Integer = 97 To 102
	symbols(i - 87) = i
Next

Function IsNumeric(ByRef subject As Const WString, base_ As Integer = 10) As Boolean
	If subject = "" OrElse subject = "." OrElse subject = "+" OrElse subject = "-" Then Return False
	Err = 0
	
	If base_ < 2 OrElse base_ > 16 Then
		Err = 1000
		Return False
	End If
	
	Dim t As String = LCase(subject)
	
	If (t[0] = plus) OrElse (t[0] = minus) Then
		t = Mid(t, 2)
	End If
	
	If Left(t, 2) = "&h" Then
		If base_ <> 16 Then Return False
		t = Mid(t, 3)
	End If
	
	If Left(t, 2) = "&o" Then
		If base_ <> 8 Then Return False
		t = Mid(t, 3)
	End If
	
	If Left(t, 2) = "&b" Then
		If base_ <> 2 Then Return False
		t = Mid(t, 3)
	End If
	
	If Len(t) = 0 Then Return False
	Dim As Boolean isValid, hasDot = False
	
	For i As Integer = 0 To Len(t) - 1
		isValid = False
		
		For j As Integer = 0 To base_ - 1
			If t[i] = symbols(j) Then
				isValid = True
				Exit For
			End If
			If t[i] = dot Then
				If CInt(Not hasDot) AndAlso (base_ = 10) Then
					hasDot = True
					isValid = True
					Exit For
				End If
				Return False ' either more than one dot or not base 10
			End If
		Next j
		
		If Not isValid Then Return False
	Next i
	
	Return True
End Function

Function utf16BeByte2wchars( ta() As UByte ) ByRef As WString
	Type mstring
		p As WString Ptr ' pointer to wstring buffer
		l As UInteger ' length of string
	End Type
	Dim a As UInteger = 0
	Dim tal As UInteger = UBound(ta)
	Dim mstr As mstring
	
	'this is never deallocated..
	mstr.p = _Allocate( 0.25 * (tal + 1) * Len(WString))
	
	' iterate array
	Do While a <= tal
		(*mstr.p)[mstr.l] = 256 * ta(a) + ta(a + 1)
		a += 2
		mstr.l += 1
	Loop
	
	(*mstr.p)[mstr.l] = 0
	Function = *mstr.p
End Function

Sub frmMain_Show(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	#ifdef __USE_GTK__
		tabItemHeight = tabLeft.ItemHeight(0) + 4 + 5
		If Not GetLeftClosedStyle Then pnlLeftPin.Top = tabItemHeight
		If Not GetRightClosedStyle Then pnlRightPin.Top = tabItemHeight
		pnlBottomPin.Width = tabItemHeight
		pnlPropertyValue.Visible = False
		tbBottom.Buttons.Item("EraseImmediateWindow")->Visible = False
		tbBottom.Buttons.Item("AddWatch")->Visible = False
		tbBottom.Buttons.Item("RemoveWatch")->Visible = False
		tbBottom.Buttons.Item("Update")->Visible = False
	#else
		
	#endif
	
	pfSplash->CloseForm
	
	Var File = Command(-1)
	Var Pos1 = InStr(File, "2>CON")
	Var bFileOpening = False
	If Pos1 > 0 Then File = Left(File, Pos1 - 1)
	If File <> "" AndAlso Right(LCase(File), 4) <> ".exe" Then
		bFileOpening = True
	End If
	If bSharedFind Then
		Select Case WhenVisualFBEditorStarts
		Case 1: If Not bFileOpening Then NewProject 'pfTemplates->ShowModal
		Case 2: If Not bFileOpening Then AddNew ExePath & Slash & "Templates" & Slash & WGet(DefaultProjectFile)
		Case 3:
			Select Case LastOpenedFileType
			Case 0: OpenFiles GetFullPath(*RecentFiles)
			Case 1: OpenFiles GetFullPath(*RecentSession)
			Case 2: OpenFiles GetFullPath(*RecentFolder)
			Case 3: OpenFiles GetFullPath(*RecentProject)
			Case 4: OpenFiles GetFullPath(*RecentFile)
			End Select
		End Select
	End If
	If bFileOpening Then
		OpenFiles GetFullPath(File)
	End If
	'	Var FILE = Command(-1)
	'	Var Pos1 = InStr(file, "2>CON")
	'	If Pos1 > 0 Then file = Left(file, Pos1 - 1)
	'	If FILE <> "" AndAlso Right(LCase(FILE), 4) <> ".exe" Then
	'		OpenFiles GetFullPath(FILE)
	'	ElseIf bFind Then
	'		WLet RecentFiles, iniSettings.ReadString("MainWindow", "RecentFiles", "")
	'		Select Case WhenVisualFBEditorStarts
	'		Case 1: NewProject 'pfTemplates->ShowModal
	'		Case 2: AddNew WGet(DefaultProjectFile)
	'		Case 3: WLet RecentFiles, iniSettings.ReadString("MainWindow", "RecentFiles", "")
	'			'Auto Load the last one.
	'			OpenFiles GetFullPath(*RecentFiles)
	'		End Select
	'	End If
	If ShowTipoftheDay Then frmTipOfDay.ShowModal *pfrmMain
	
End Sub

#ifndef __USE_GTK__
	Function FileTimeToVariantTime(ByRef FT As FILETIME) As DATE_
		Dim dt As DATE_, ST As SYSTEMTIME
		FileTimeToSystemTime(@FT, @ST)
		SystemTimeToVariantTime @ST, @dt
		Return dt
	End Function
	
	Function GetFileLastWriteTime(ByRef FileName As WString) As FILETIME
		Dim fd As WIN32_FIND_DATAW
		Dim hFind As HANDLE = FindFirstFile(FileName, @fd)
		If hFind <> INVALID_HANDLE_VALUE Then
			FindClose hFind
			Return fd.ftLastWriteTime
		End If
	End Function
#endif

Sub frmMain_ActivateApp(ByRef Designer As My.Sys.Object, ByRef Sender As Form)
	#ifndef __USE_GTK__
		Static bInActivateApp As Boolean
		If bInActivateApp Then Exit Sub
		bInActivateApp = True
		Dim tb As TabWindow Ptr
		For j As Integer = 0 To TabPanels.Count - 1
			Var ptabCode = @Cast(TabPanel Ptr, TabPanels.Item(j))->tabCode
			For i As Integer = 0 To ptabCode->TabCount - 1
				tb = Cast(TabWindow Ptr, ptabCode->Tab(i))
				If InStr(tb->FileName, "/") > 0 OrElse InStr(tb->FileName, "\") > 0 Then
					If FileTimeToVariantTime(GetFileLastWriteTime(tb->FileName)) <> FileTimeToVariantTime(tb->DateFileTime) Then
						If MsgBox(tb->FileName & !"\r" & ML("File was changed by another application. Reload it?"), ML("File Changed"), mtQuestion, btYesNo) = mrYes Then
							tb->txtCode.Changing "Reload"
							tb->txtCode.LoadFromFile(tb->FileName, tb->FileEncoding, tb->NewLineType)
							tb->txtCode.Changed "Reload"
						End If
					End If
					tb->DateFileTime = GetFileLastWriteTime(tb->FileName)
				End If
			Next i
		Next j
		bInActivateApp = False
	#endif
End Sub

Sub SaveMRU
	Dim As Integer i, MRUStart
	MRUStart = Max(MRUAIChat.Count - miRecentMax, 0)
	For i = MRUStart To MRUAIChat.Count - 1
		iniSettings.WriteString("MRUAIChat", "MRUAIChat_0" & WStr(i - MRUStart), MRUAIChat.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUAIChat", "MRUAIChat_0" & WStr(i))
	Next
	MRUStart = Max(MRUFiles.Count - miRecentMax, 0)
	For i = MRUStart To MRUFiles.Count - 1
		iniSettings.WriteString("MRUFiles", "MRUFile_0" & WStr(i - MRUStart), MRUFiles.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUFiles", "MRUFile_0" & WStr(i))
	Next
	MRUStart = Max(MRUFolders.Count - miRecentMax, 0)
	For i = MRUStart To MRUFolders.Count - 1
		iniSettings.WriteString("MRUFolders", "MRUFolder_0" & WStr(i - MRUStart), MRUFolders.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUFolders", "MRUFolder_0" & WStr(i))
	Next
	MRUStart = Max(MRUProjects.Count - miRecentMax, 0)
	For i = MRUStart To MRUProjects.Count - 1
		iniSettings.WriteString("MRUProjects", "MRUProject_0" & WStr(i - MRUStart), MRUProjects.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUProjects", "MRUProject_0" & WStr(i))
	Next
	MRUStart = Max(MRUSessions.Count - miRecentMax, 0)
	For i = MRUStart To MRUSessions.Count - 1
		iniSettings.WriteString("MRUSessions", "MRUSession_0" & WStr(i - MRUStart), MRUSessions.Item(i))
	Next
	For i = i To miRecentMax
		iniSettings.KeyRemove("MRUSessions", "MRUSession_0" & WStr(i))
	Next
End Sub

Sub frmMain_Close(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer)
	On Error Goto ErrorHandler
	_Deallocate(AISystem_PromoptPtr)
	_Deallocate(AIPostDataPtr_1st)
	_Deallocate(AIPostDataPtr_2nd)
	If AutoSaveSession AndAlso SessionOpened AndAlso Trim(*RecentSession) <> "" Then
		SaveSession(True)
	End If
	If Not CloseSession Then Action = 0: Return
	FormClosing = True
	If AIMessages.Count > 0 Then 
		Dim As WString * MAX_PATH FileName = IIf(RecentAIChat, *RecentAIChat, Mid(FormatFileName(Left(AIMessages.Item(0)->Key, 50)) & Format(Now, "yyyymmdd_hhmm") & ".md", 16))
		If Not MRUAIChat.Contains(FileName) Then
			MRUAIChat.Add FileName
			miRecentAIChat->Add(FileName, "", FileName, @mClickAIChat)
		End If
		AIMessages.SaveToFile(ExePath & "/AIChat/" & FileName)
	End If
	If frmMain.WindowState <> WindowStates.wsMaximized Then
		iniSettings.WriteInteger("MainWindow", "Width", frmMain.Width)
		iniSettings.WriteInteger("MainWindow", "Height", frmMain.Height)
	End If
	iniSettings.WriteBool("MainWindow", "Maximized", frmMain.WindowState = WindowStates.wsMaximized)
	iniSettings.WriteBool("MainWindow", "LeftClosed", GetLeftClosedStyle)
	iniSettings.WriteInteger("MainWindow", "LeftWidth", tabLeftWidth)
	iniSettings.WriteBool("MainWindow", "RightClosed", GetRightClosedStyle)
	iniSettings.WriteInteger("MainWindow", "RightWidth", tabRightWidth)
	iniSettings.WriteBool("MainWindow", "BottomClosed", GetBottomClosedStyle)
	iniSettings.WriteInteger("MainWindow", "BottomHeight", tabBottomHeight)
	iniSettings.WriteBool("MainWindow", "ProjectFolders", ShowProjectFolders)
	iniSettings.WriteBool("MainWindow", "ToolLabels", tbForm.Buttons.Item(0)->Checked)
	iniSettings.WriteBool("MainWindow", "UseDebugger", UseDebugger)
	'iniSettings.WriteInteger("MainWindow", "Subsystem", IIf(tbtConsole->Checked, 1, IIf(tbtGUI->Checked, 2, 0)))
	iniSettings.WriteBool("MainWindow", "ShowMainToolBar", ShowMainToolBar)
	iniSettings.WriteBool("MainWindow", "ShowStandardToolBar", ShowStandardToolBar)
	iniSettings.WriteBool("MainWindow", "ShowEditToolBar", ShowEditToolBar)
	iniSettings.WriteBool("MainWindow", "ShowProjectToolBar", ShowProjectToolBar)
	iniSettings.WriteBool("MainWindow", "ShowBuildToolBar", ShowBuildToolBar)
	iniSettings.WriteBool("MainWindow", "ShowRunToolBar", ShowRunToolBar)
	iniSettings.WriteInteger("MainWindow", "MainHeight", frmMain.Height)
	iniSettings.WriteInteger("MainWindow", "ShowTipoftheDayIndex", ShowTipoftheDayIndex)
	iniSettings.WriteBool("MainWindow", "ShowTipoftheDay", ShowTipoftheDay)
	iniSettings.WriteInteger "Options", "HistoryCodeCleanDay", HistoryCodeCleanDay
	
	SaveMRU
	
	iniSettings.WriteString("MainWindow", "RecentFiles", *RecentFiles)
	iniSettings.WriteString("MainWindow", "RecentFile", *RecentFile)
	iniSettings.WriteString("MainWindow", "RecentProject", *RecentProject)
	iniSettings.WriteString("MainWindow", "RecentFolder", *RecentFolder)
	iniSettings.WriteString("MainWindow", "RecentSession", *RecentSession)
	If mChangeLogEdited Then txtChangeLog.SaveToFile(ExePath & Slash & StringExtract(MainNode->Text, ".") & "_Change.log") '
	UnLoadAddins
	Exit Sub
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
End Sub

Sub frmMain_Message(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Msg As Message)
	#ifdef __USE_WINAPI__
		Select Case Msg.Msg
		Case WM_COPYDATA
			Dim pCDS As COPYDATASTRUCT Ptr = Cast(COPYDATASTRUCT Ptr, Msg.lParam)
			Dim As ZString Ptr FileNameFromCmdLine = Cast(ZString Ptr, pCDS->lpData)
			If FileNameFromCmdLine <> 0 Then
				OpenFiles *FileNameFromCmdLine
				If frmMain.WindowState = WindowStates.wsMinimized Then ShowWindow frmMain.Handle, SW_RESTORE
				SetForegroundWindow frmMain.Handle
				SetFocus frmMain.Handle
				Msg.Result = -1
				Return
			End If
		End Select
	#endif
End Sub

Sub ToolBar_MouseUp(ByRef Designer As My.Sys.Object, ByRef Sender As Control, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	If MouseButton <> 1 Then Exit Sub
	Sender.ContextMenu = miToolBars->SubMenu
End Sub

tbStandard.OnMouseUp = @ToolBar_MouseUp
tbEdit.OnMouseUp = @ToolBar_MouseUp
tbProject.OnMouseUp = @ToolBar_MouseUp
tbBuild.OnMouseUp = @ToolBar_MouseUp
tbRun.OnMouseUp = @ToolBar_MouseUp

MainReBar.Name = "MainReBar"
MainReBar.Align = DockStyle.alTop

frmMain.Name = "frmMain"
frmMain.KeyPreview = True
#ifdef __USE_GTK__
	frmMain.Icon.LoadFromFile(ExePath & "/Resources/VisualFBEditor.ico")
#else
	frmMain.Icon.LoadFromResourceID(1)
#endif
'frmMain.StartPosition = FormStartPosition.DefaultBounds
frmMain.MainForm = True
#ifdef __FB_64BIT__
	frmMain.Text = "Visual FB Editor (x64)"
#else
	frmMain.Text = "Visual FB Editor (x32)"
#endif
frmMain.OnActiveControlChange = @frmMain_ActiveControlChanged
frmMain.OnActivateApp = @frmMain_ActivateApp
frmMain.OnKeyDown = @frmMain_KeyDown
frmMain.OnResize = @frmMain_Resize
frmMain.OnCreate = @frmMain_Create
frmMain.OnShow = @frmMain_Show
frmMain.OnClose = @frmMain_Close
frmMain.OnDropFile = @frmMain_DropFile
frmMain.OnMessage = @frmMain_Message
frmMain.Menu = @mnuMain
'#ifndef __USE_GTK__
MainReBar.Add @tbStandard
MainReBar.Add @tbEdit
MainReBar.Add @tbProject
MainReBar.Add @tbBuild
MainReBar.Add @tbRun
frmMain.Add @MainReBar
'#else
'	tbStandard.Align = DockStyle.alTop
'	frmMain.Add @tbStandard
'#endif
frmMain.Add @stBar
frmMain.Add @pnlLeft
frmMain.Add @splLeft
frmMain.Add @pnlRight
frmMain.Add @splRight
frmMain.Add @pnlBottom
frmMain.Add @splBottom
frmMain.Add ptabPanel
frmMain.Show

Sub OnProgramStart() Constructor
	'	pfSplash = @fSplash
	'	pfSplash->Show
End Sub

Sub OnProgramQuit() Destructor
	If bQuitting Then Exit Sub
	WDeAllocate(ProjectsPath)
	WDeAllocate(LastOpenPath)
	WDeAllocate(DefaultMakeTool)
	WDeAllocate(CurrentMakeTool1)
	WDeAllocate(CurrentMakeTool2)
	WDeAllocate(MakeToolPath1)
	WDeAllocate(MakeToolPath2)
	WDeAllocate(DefaultAIAgent)
	WDeAllocate(CurrentAIAgent)
	WDeAllocate(DefaultDebugger32)
	WDeAllocate(DefaultDebugger64)
	WDeAllocate(GDBDebugger32)
	WDeAllocate(GDBDebugger64)
	WDeAllocate(CurrentDebugger32)
	WDeAllocate(CurrentDebugger64)
	WDeAllocate(Debugger32Path)
	WDeAllocate(Debugger64Path)
	WDeAllocate(GDBDebugger32Path)
	WDeAllocate(GDBDebugger64Path)
	WDeAllocate(DefaultTerminal)
	WDeAllocate(CurrentTerminal)
	WDeAllocate(TerminalPath)
	WDeAllocate(DefaultCompiler32)
	WDeAllocate(CurrentCompiler32)
	WDeAllocate(DefaultCompiler64)
	WDeAllocate(CurrentCompiler64)
	WDeAllocate(Compiler32Path)
	WDeAllocate(Compiler64Path)
	WDeAllocate(Compiler32Arguments)
	WDeAllocate(Compiler64Arguments)
	WDeAllocate(Make1Arguments)
	WDeAllocate(Make2Arguments)
	WDeAllocate(RunArguments)
	WDeAllocate(Debug32Arguments)
	WDeAllocate(Debug64Arguments)
	WDeAllocate(RecentAIChat)
	WDeAllocate(RecentFiles)
	WDeAllocate(RecentFile)
	WDeAllocate(RecentProject)
	WDeAllocate(RecentFolder)
	WDeAllocate(RecentSession)
	If AISystem_PromoptPtr Then Deallocate AISystem_PromoptPtr
	If AIPostDataPtr_1st Then Deallocate AIPostDataPtr_1st
	If AIPostDataPtr_2nd Then Deallocate AIPostDataPtr_2nd
	If AIBodyWStringPtr Then Deallocate AIBodyWStringPtr
	If AIBodyWStringSavePtr Then Deallocate AIBodyWStringSavePtr 
	If AIAssistantsAnswersPtr Then Deallocate AIAssistantsAnswersPtr
	WDeAllocate(DefaultHelp)
	WDeAllocate(HelpPath)
	WDeAllocate(DefaultBuildConfiguration)
	WDeAllocate(KeywordsHelpPath)
	WDeAllocate(AsmKeywordsHelpPath)
	WDeAllocate(CurrentTheme)
	WDeAllocate(DefaultProjectFile)
	WDeAllocate(EditorFontName)
	WDeAllocate(InterfaceFontName)
	WDeAllocate(MFFPath)
	WDeAllocate(MFFDll)
	WDeAllocate(gSearchSave)
	WDeAllocate(EnvironmentVariables)
	WDeAllocate(CommandPromptFolder)
	_Deallocate(filenumbers)
	'	For i As Integer = 0 To Threads.Count - 1
	'		If Threads.Item(i) <> 0 Then ThreadWait Threads.Item(i)
	'	Next
	MutexDestroy tlockToDo
	MutexDestroy tlock
	MutexDestroy tlockSave
	MutexDestroy tlockGDB
	MutexDestroy tlockSuggestions
	UnloadD2D1
	Dim As UserToolType Ptr tt
	#ifndef __USE_GTK__
		For i As Integer = 0 To Tools.Count - 1
			_Delete(Cast(UserToolType Ptr, Tools.Item(i)))
		Next
	#endif
	Dim As ToolType Ptr Tool
	For i As Integer = 0 To pCompilers->Count - 1
		Tool = pCompilers->Item(i)->Object
		_Delete(Tool)
	Next i
	For i As Integer = 0 To pMakeTools->Count - 1
		Tool = pMakeTools->Item(i)->Object
		_Delete(Tool)
	Next i
	For i As Integer = 0 To pDebuggers->Count - 1
		Tool = pDebuggers->Item(i)->Object
		_Delete(Tool)
	Next i
	For i As Integer = 0 To pTerminals->Count - 1
		Tool = pTerminals->Item(i)->Object
		_Delete(Tool)
	Next i
	For i As Integer = 0 To pOtherEditors->Count - 1
		Tool = pOtherEditors->Item(i)->Object
		_Delete(Tool)
	Next i
	Dim As ModelInfo Ptr Model
	For i As Integer = 0 To pAIAgents->Count - 1
		Model = pAIAgents->Item(i)->Object
		_Delete(Model)
	Next i
	Dim As WStringOrStringList Ptr keywordlist
	For i As Integer = 0 To KeywordLists.Count - 1
		keywordlist = KeywordLists.Object(i)
		_Delete(keywordlist)
	Next i
	Dim As TabPanel Ptr tp
	#ifndef __USE_GTK__
		For i As Integer = 0 To TabPanels.Count - 1
			tp = TabPanels.Item(i)
			_Delete(tp)
		Next i
	#endif
	Dim As EditControlContent Ptr File
	For i As Integer = IncludeFiles.Count - 1 To 0 Step -1
		File = IncludeFiles.Object(i)
		If File Then _Delete(File)
	Next
	IncludeFiles.Clear
	#ifndef __USE_GTK__
		Dim As Library Ptr CtlLibrary
		For i As Integer = 0 To ControlLibraries.Count - 1
			CtlLibrary = ControlLibraries.Item(i)
			_Delete(CtlLibrary)
		Next
	#endif
	Dim As TypeElement Ptr te, te1
	For i As Integer = pGlobalNamespaces->Count - 1 To 0 Step -1
		te = pGlobalNamespaces->Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			te1 = te->Elements.Object(j)
			te->Elements.Remove j
		Next
		_Delete( Cast(TypeElement Ptr, pGlobalNamespaces->Object(i)))
	Next
	For i As Integer = Snippets.Count - 1 To 0 Step -1
		te = Snippets.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, Snippets.Object(i)))
	Next
	For i As Integer = pComps->Count - 1 To 0 Step -1
		DeleteFromTypeElement(pComps->Object(i))
		'te = pComps->Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, pComps->Object(i)))
		''pComps->Remove i
	Next
	For i As Integer = pGlobalTypes->Count - 1 To 0 Step -1
		DeleteFromTypeElement(pGlobalTypes->Object(i))
		'te = pGlobalTypes->Object(i)
		'For j As Integer = te->Elements.Count - 1 To 0 Step -1
		'	_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		'Next
		'te->Elements.Clear
		'_Delete( Cast(TypeElement Ptr, pGlobalTypes->Object(i)))
		''pGlobalTypes->Remove i
	Next
	For i As Integer = TypesInFunc.Count - 1 To 0 Step -1
		te = TypesInFunc.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, TypesInFunc.Object(i)))
	Next
	For i As Integer = pGlobalEnums->Count - 1 To 0 Step -1
		te = pGlobalEnums->Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, pGlobalEnums->Object(i)))
		'pGlobalEnums->Remove i
	Next
	For i As Integer = EnumsInFunc.Count - 1 To 0 Step -1
		te = EnumsInFunc.Object(i)
		For j As Integer = te->Elements.Count - 1 To 0 Step -1
			_Delete( Cast(TypeElement Ptr, te->Elements.Object(j)))
		Next
		te->Elements.Clear
		_Delete( Cast(TypeElement Ptr, EnumsInFunc.Object(i)))
	Next
	For i As Integer = pGlobalFunctions->Count - 1 To 0 Step -1
		te = pGlobalFunctions->Object(i)
		_Delete( Cast(TypeElement Ptr, pGlobalFunctions->Object(i)))
		'pGlobalFunctions->Remove i
	Next
	For i As Integer = GlobalFunctionsHelp.Count - 1 To 0 Step -1
		te = GlobalFunctionsHelp.Object(i)
		_Delete( Cast(TypeElement Ptr, GlobalFunctionsHelp.Object(i)))
		'GlobalFunctionsHelp.Remove i
	Next
	For i As Integer = GlobalAsmFunctionsHelp.Count - 1 To 0 Step -1
		te = GlobalAsmFunctionsHelp.Object(i)
		_Delete( Cast(TypeElement Ptr, GlobalAsmFunctionsHelp.Object(i)))
		'GlobalAsmFunctionsHelp.Remove i
	Next
	For i As Integer = pGlobalTypeProcedures->Count - 1 To 0 Step -1
		te = pGlobalTypeProcedures->Object(i)
		_Delete( Cast(TypeElement Ptr, pGlobalTypeProcedures->Object(i)))
		'pGlobalFunctions->Remove i
	Next
	For i As Integer = pGlobalArgs->Count - 1 To 0 Step -1
		te = pGlobalArgs->Object(i)
		_Delete( Cast(TypeElement Ptr, pGlobalArgs->Object(i)))
		'pGlobalArgs->Remove i
	Next
End Sub
