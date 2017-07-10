#NoTrayIcon
#RequireAdmin

#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WinAPIFiles.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include "GUIExtender.au3"
#include <File.au3>
#include <Array.au3>
#include <Date.au3>
#include <String.au3>
#include <GuiListView.au3>
#include <GuiComboBox.au3>
#include <ListViewConstants.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <ProcessEx.au3>
#include <Process.au3>
#include 'CSVSplit.au3'
#include "PrintMgr.au3"
#include "expiry.au3"
;#include "RestartCountdown.au3"
#Include "log.au3"
#include <SendMessage.au3>
#include <console.au3>
#include <AutoItConstants.au3>













Global Const $SC_DRAGMOVE = 0xF012






;---------------------------------------------------------------------------------------------------------------------------------
;												Author Harry Joseph
; First version storeBuild 6 10 April  and   StorebuildBeta1.3 version 2017 may 15 Gold
; May 26th 2017 added print management
; May 27, 2017 re-shuffle as separate function log   IP host, , oracle POS and Pinpad, receipt printer,samsung Printer,
; June 20, 2017 addded check  epson installation
; june 21, 2017 Wrote reg create flag for epson successful  printer installation
; June 22, 2017 resolved  error failed to load Java VM
; June 22, 2017 create ini registry to monitor training and cut over
; June 26, 2017 add extension for Vdocs automation
; June 27, 2017 add extension for BPT automation
; June 30, 2017 added activities log and error handling
; July 21  add countdown function to reboot POS
; July 1, 2017 adding event log and error
; July 6, 2017 adding Disable firewall for profile rssupport
;july  6 , 2017 aqdding check checking Jarvis rv07
;----------------------------------------------------------------------------------------------------------------------------------



While _Singleton("@script", 1) = 0 ;Ensuring only one instance of the program is running.
	$ret = MsgBox(1, "Warning", "An occurrence of the program is already running.")
	If $ret = 2 Then Exit
WEnd




DirCreate (@scriptdir &  '\DataStorage')
Global $var = RegRead("HKEY_CURRENT_USER\Software\StoreBuild", "epsonkey2") ; key for  epson printer installed 1 True 0 not True


Global $firstRun, $mydata, $ucs, $sChoice
Global $OracleRetail = FileGetShortName(@DesktopDir & "\POS Client Installer.exe")
Global $Pinpad = (@DesktopDir & "\Personalize.cmd") ;running  personalize desktop
Global $Direxist = "D:\APPs\OracleRetailStore"
Global $sDestination = 'D:\Installers\EpsonJavaPosAdk\'
Global $check_listview = False ;check if listview exist dont create other listviews

Global $Cmmd = @ScriptDir & '\Datastorage\RepairNetwork.cmd'  ; Network flush clear
Global $HostNGroup = @ScriptDir & '\DataStorage\HostNWGroup.cmd'
Global $Setmodule = @ScriptDir  & '\DataStorage\SetModules.bat'
;*************************************variable for timer****************************************************************************

Global $lblTimer, $timer = 0, $aggregateTime = 0, $jokeTimer ; stop watch timer
Dim $id, $oldId ; stop watch timer



;****************************** variable holding for $hGUI**********************************************************************
Global $Radio1 = False, $Radio2 = False, $TrainingCheckbox
Global $aListViews, $RegisterValueread, $Selection1, $selection2, $Checknum, $TempChecknum, $sChoice, $checkbox

Global $checkR = True, $tempi, $myglobdata, $oldinput3, $checkf = True, $Dealer, $ckRetail = False, $noprinter = 2 ;, $noip, $mobile,$receiptPrinter

; Array to hold button ControlIDs
;Global $aButton[11]    ; 4x 5 = 21
Global $cPink_aButton[21]
Global $cPink_aName[21] = ["0", "POS Name_", "POS IP_", "Personalize_", "CMD.Silent_", "App.Properties_", "PayMent.Manager_", "Recpt/Drawer_", "Recpt header BPT_", "Pinpnad_", "Fprinter_", "Bprinter_", _
		"available_", "available_", "available_", "available_", "available_", "available_", "available_", "available_", "available_"]



;***************************************ARRAY variable holding drop down list**************************************************************

Global $sList1 = ""
Global $aArray0[9] = ["01", "02", "03", "04", "05", "06", "07", "08"] ;, "09"] ;VALUE LIST0 live store
Global $aArray1[9] = ["50", "51", "52", "53", "54", "55", "56", "57"] ;, "58"] ;VALUE LIST1
Global $aArray2[9] = ["21", "22", "23", "24", "25", "26", "27", "28"] ;, "09"] ;VALUE LIST0  training store
Global $aArray3[16] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15"] ;, "09"] ;VALUE Legacy store
Global $aList[5] = ["9350", "9351", "9352", "9008"]


;**************************************** variable holding IP info, printers

Global $sComputerName = "", $NewIP = 0, $Gateaway = 0, $RecptPrinter = 0, $frontprinter = 0, $backprinter = 0, $TabPrinter = 0


;********************************************************making sure proper path is selected using regex  32  or 64 bit win10
Global $sHKLMRoot = @OSArch = "x64" ? "HKLM64" : "HKLM"


;Housekeeping
; same folder structure
If IsAdmin() Then FileInstall(".\DataStorage\SetModules.bat", @ScriptDir & '\DataStorage\SetModules.bat', 1) ;
If IsAdmin() Then FileInstall(".\DataStorage\RepairNetwork.cmd",  @ScriptDir & '\Datastorage\RepairNetwork.cmd', 1) ;===> Modify this path copyfile2.exe  copy 2 files a
If IsAdmin() Then FileInstall(".\DataStorage\HostNWGroup.cmd",  @ScriptDir & '\DataStorage\HostNWGroup.cmd', 1) ;===> Modify this path copyfile2.exe  copy 2 files a
If IsAdmin() Then  FileInstall(".\DataStorage\NewRetail1.txt", @TempDir & "\NewRetail1.txt", 1) ;

_FlatFile()











;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                     Error handling and actvities Log
;
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------

Global $sError = "" ;Error message
Global $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc") ;catch all






If $sError Then ;If an error exists
	 _Log_Report("Error:" & $sError)

	MsgBox(0, "Error", $sError)
EndIf















;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                     Error handling and actvities Log
;
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Opt('MustDeclareVars', 1)


Global $hLog, $Time
Global $sTimestamp = '[' & _NowDate() & ' ' & _NowTime(5) & ']'

Global $s


 $s &= "First time, Date: " & $sTimestamp & @CRLF
 $s &= "###********************************* ********Store Build site ***************************###" & @CRLF & @CRLF


 $hLog = _Log_Open(@TempDir & '\StoreBuild'& @YEAR &" "& @MON &" " & @MDAY &" "& @HOUR &"hr"& @MIN &'.log', '  )                      ''Event Log ' & $s)






;$iStyle2 = BitOR($WS_MAXIMIZEBOX, $WS_CAPTION, $WS_SYSMENU) ; Style without minimize box
GUISetFont(8, 400, 0, "Arial")

; Create parent GUI
;$hGUI = GUICreate("Store Build II", 1000, 300)
;GUISetState(@SW_HIDE, $hGUI)

$hGUI = GUICreate("Store Build II", 1000, 300, 100, 100, BitOR($WS_POPUP, $WS_BORDER))
GUISetState(@SW_HIDE, $hGUI)





; Create sections in main GUI
_GUIExtender_Init($hGUI, 1)


$iSection_1 = _GUIExtender_Section_Create($hGUI, 0, 500)

GUICtrlCreateLabel("", 0, 0, 500, 300)
GUICtrlSetBkColor(-1, 0xCE5D5D)
GUICtrlSetState(-1, $GUI_DISABLE) ;  disbale the lable - you forgot to move that line <<<<<<<<<<<<<<<<<<<<<
; Add some controls  can see which section is which

GUICtrlSetBkColor(-1, 0xCE5D5D)
;Global $cCombo = GUICtrlCreateCombo("", 340, 5, 49, 150,BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL)) ; The required styles are included by default
;GUICtrlSetState($cCombo, $GUI_DISABLE)
GUICtrlSetBkColor(-1, 0xCE5D5D)



$Group1 = GUICtrlCreateGroup("POS", 16, 8, 177, 49)
GUICtrlSetBkColor(-1, 0xCE5D5D)
Global $idCheckbox = GUICtrlCreateCheckbox("Training", 400, 5, 55, 15)
GUICtrlSetState ($idCheckbox, $GUI_DISABLE)
GUICtrlSetBkColor(-1, 0xCE5D5D)
;$cCombo = GUICtrlCreateCombo("", 340, 5, 53, 150) ; The required styles are included by default
;Global $Radio3 = GUICtrlCreateRadio("Training", 375, 0, 100, 15)



GUICtrlSetBkColor(-1, 0xCE5D5D)
$Radio1 = GUICtrlCreateRadio("Fixed", 32, 32, 65, 17)
GUICtrlSetBkColor(-1, 0xCE5D5D)
$Radio2 = GUICtrlCreateRadio("Tablet", 130, 32, 55, 17)
GUICtrlSetBkColor(-1, 0xCE5D5D)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$hCombo = GUICtrlCreateCombo("", 304, 80, 37, 25, BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL)) ; to stop user from entering number
GUICtrlSetData($hCombo, $sList1)

;$Setting = GUICtrlCreateButton("Setting", 80, 270, 65, 25)
;GUICtrlSetState($Setting, $GUI_DISABLE)
$Exit = GUICtrlCreateButton("Exit", 420, 270, 65, 25)
;$Button3 = GUICtrlCreateButton("Expand", 8, 270, 65, 25)
$Input1 = GUICtrlCreateInput("", 208, 80, 57, 24)
GUICtrlSetLimit(-1, 4) ; to limit the entry to 3 chars
GUICtrlSetTip(-1, "Enter Store Number")
$RE = GUICtrlCreateLabel("RE", 272, 80, 22, 24, $SS_SUNKEN)
$SREI = GUICtrlCreateLabel("SREI", 168, 80, 35, 28, BitOR($SS_CENTER, $SS_SUNKEN))
$start = GUICtrlCreateButton("Start", 200, 120, 97, 33)
Global $Progress1 = GUICtrlCreateProgress(160, 176, 193, 25)


$label = GUICtrlCreateLabel("Click START", 160, 209, 193, 25)
GUICtrlSetBkColor(-1, 0xCE5D5D)
$lblTimer = GUICtrlCreateLabel("     00:00.00", 225, 20, 400, 25)
GUICtrlSetFont(-1, 13, 400, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0xCE5D5D)
IF GUICtrlRead($radio1,$GUI_UNCHECKED ) Then
 $cCombo = GUICtrlCreateCombo("", 340, 5, 49, 150,BitOR($CBS_DROPDOWNLIST, $WS_VSCROLL)) ; The required styles are included by default
GUICtrlSetState($cCombo, $GUI_hIDE+ $GUI_DISABLE)
EndIf
;GUISetStyle($iStyle2)



_GUIExtender_Section_Activate($hGUI, $iSection_1 + 1, "", "", 470, 10, 20, 20)

; Create a button to action programatically a section of another GUI
$cSect_4 = GUICtrlCreateButton("Expand 4", 10, 270, 65, 25)

$iSection_2 = _GUIExtender_Section_Create($hGUI, 500, 500)

GUICtrlCreateLabel("", 500, 0, 500, 300)
GUICtrlSetBkColor(-1, 0xFFCCCC)
GUICtrlSetState(-1, $GUI_DISABLE)
;GUICtrlCreateLabel("I am the PINK section that opens and closes", 500, 100, 300, 20)


; A double loop to space out the buttons - but  easily have a single one instead
For $i = 0 To 3 ; 0 to 3  x4
	For $j = 1 To 5
		GUICtrlSetBkColor(-1, 0xFFCCCC)
		$cPink_iIndex = ($i * 5) + $j
		; Create button using a suitable algorithm to locate it
		$cPink_aButton[$cPink_iIndex] = GUICtrlCreateRadio($cPink_aName[$cPink_iIndex] & $cPink_iIndex, 525 + (125 * $i), ($j * 45) - 30, 120, 75) ; $index,20 125 = 150    45= 50
	Next
	GUICtrlSetBkColor(-1, 0xFFCCCC)
Next


; Add a control in the pink section <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;$cPink_Button = GUICtrlCreateButton("Pink Test", 510, 10, 80, 30)






; Close section creation structure
_GUIExtender_Section_Create($hGUI, -99)

; Create  and position child GUI
$aGUI_Pos = WinGetPos($hGUI)
$hGUI_Child = GUICreate("Follower", 500, 350, 0, 0, BitOR($WS_POPUP, $WS_BORDER), 0, $hGUI) ;color green
WinMove($hGUI_Child, "", $aGUI_Pos[0], $aGUI_Pos[1] + $aGUI_Pos[3])
GUISetState(@SW_HIDE, $hGUI_Child)

; Create section sin child GUI
_GUIExtender_Init($hGUI_Child)

$iSection_3 = _GUIExtender_Section_Create($hGUI_Child, 0, 1)
; I am the RED section that is static
GUICtrlCreateLabel("", 0, 0, 500, 1)
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetState(-1, $GUI_DISABLE)

$iSection_4 = _GUIExtender_Section_Create($hGUI_Child, 1)
GUICtrlCreateLabel("", 0, 1, 500, 510) ; color green
GUICtrlSetBkColor(-1, 0xffffff)
GUICtrlSetState(-1, $GUI_DISABLE)
;GUICtrlCreateLabel("I am the Green section that opens and closes", 0, 100, 300, 20)
; Activate this section with no visible button
_GUIExtender_Section_Activate($hGUI_Child, $iSection_4)
;~GUImenu0()
;~Sleep(100)

; Close section creation structure
_GUIExtender_Section_Create($hGUI_Child, -99)

; Close extendable sections
_GUIExtender_Section_Action($hGUI, $iSection_2, False)
_GUIExtender_Section_Action($hGUI_Child, $iSection_4, False)
; And display the GUI(s)



GUISetState(@SW_SHOW, $hGUI)
GUISetState(@SW_SHOW, $hGUI_Child)



 ;internetCheck()   ; check for internet

_expire("2017/07/25 00:00:00", 1) ; adding expiry




; Look for the main GUI moving
GUIRegisterMsg($WM_MOVE, "_WM_MOVE")

; access the control  $iMsg from each 3 menu ; Just as you would normally <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<







While 1

	$iMsg = GUIGetMsg()
	Switch $iMsg
		Case $GUI_EVENT_PRIMARYDOWN
            _SendMessage($hGUI, $WM_SYSCOMMAND, $SC_DRAGMOVE, 0)



		Case $GUI_EVENT_CLOSE
			_Uninstall()
			RestartCountdown(30)
			Exit

		Case $Exit
			_Uninstall()
			RestartCountdown(30)
			Exit
		Case $cSect_4
			; Toggle the section in the child GUI programatically
			_GUIExtender_Section_Action($hGUI_Child, $iSection_4, 9)





		Case $start
			;******************************************************************Error Checking start****************************************
              _Log_Report($hLog, 'Program Start', 1)

			If GUICtrlRead($Input1) = "" Then
				MsgBox(0, "WarNing", "StoreNumber is blank", 3)
			ElseIf GUICtrlRead($Radio1) = $GUI_UNCHECKED And GUICtrlRead($Radio2) = $GUI_UNCHECKED Then
				MsgBox(0, "WarNing", "must select Tablet or Fixed POS", 3)
			ElseIf GUICtrlRead($hCombo) = "" Then
				MsgBox(0, "WarNing", "must Select register number", 3)


			ElseIf StringLeft($Checknum, 1) = 9 And GUICtrlRead($Radio2) = $GUI_CHECKED Then
				MsgBox(0, "Warning", " tablet store number don't start with a 9")
				GUICtrlSetState($Input1, $GUI_FOCUS)
				GUICtrlSetData($Input1, "") ;Reset input


			ElseIf StringLeft($Checknum, 1) = 9 And BitAND(GUICtrlRead($idCheckbox), $GUI_UNCHECKED) And GUICtrlRead($Radio1) = $GUI_CHECKED Then
				MsgBox(0, "Warning", " Live store number don't start with a 9")
				GUICtrlSetState($Input1, $GUI_FOCUS)
				GUICtrlSetData($Input1, "") ;Reset input



			ElseIf  StringLeft($tempChecknum,1) = 9  Then  ; training label store name can not start with  $tempChecknum,
				MsgBox(0, "Warning", " Live store number don't start with a 9")
				GUICtrlSetState($Input1, $GUI_FOCUS)
				GUICtrlSetData($Input1, "") ;Reset input

			ElseIf  $sChoice = ""   And BitAND(GUICtrlRead($idCheckbox), $GUI_CHECKED) And GUICtrlRead($Radio1) = $GUI_CHECKED Then
				MsgBox(0, "Warning", " must select a training RIAB")
				GUICtrlSetState($cCombo , $GUI_FOCUS)
				;GUICtrlSetData($Input1, "") ;Reset input



			Else


				$ret = MsgBox(1, "Ready", ",press on [Ok]  or [Cancel] to exit") ; give user last change to change his or her mind
				If $ret = 2 Then
					SetError(1) ;Set error
					$sError = "User selected to exit the script." ;Set error message
					_Uninstall()
					Exit
					;Return ;(-1) ;return to main
				 EndIf


	           ;
				;_KZB_on() ; turn off keyboard and mouse
				 AddEpsonSilentFiles()
				 ;MsgBox($MB_SYSTEMMODAL, "Hi", "Start blue section pressed")
				GUICtrlSetState($start, $GUI_DISABLE)
				GUICtrlSetData($lblTimer, "      00:00.00")
				$timer = TimerInit()
				SRandom(@SEC)
				AdlibRegister("_UpdateTimer", 251) ;,250)

			   	If $Selection1 = True Then Fixedpos() ; function call fixed PO
				If $selection2 = True Then Wireless() ; Funtion call  Tablet


                _Log_Report($hLog, 'Program Finish', 100)
				_Log_Close($hLog)


               GUICtrlSetState($Input1, $GUI_FOCUS)
                GUICtrlSetData($Input1, "") ;Reset input
                GUICtrlSetData($hCombo,"")  ;clear list
				GUICtrlSetData($hCombo, $sList1)  ; re-add the list



				GUICtrlSetState($start, $GUI_ENABLE)
				GUICtrlSetData($Progress1, 0)
				GUICtrlSetData($label, "Click START")
				;_GUICtrlListView_Destroy($aListViews)

				AdlibUnRegister("_UpdateTimer")
				;RestartCountdown(30)

			EndIf


		Case $idCheckbox
			;training
			Checkbox()
			_FillCombo()

			If $checkbox = True And $Radio1 = True Then
				GUICtrlSetState($cCombo, $GUI_ENABLE)
				GUICtrlSetState($cCombo, $GUI_SHOW)

			ElseIf $checkbox = False Or $Radio1 = True Then

				GUICtrlSetState($cCombo, $GUI_hIDE) ; $GUI_DISABLE)

			EndIf






		case $cCombo
			 ;$sList = SetList($alist)
	    $sChoice= _ActionCombo(GUICtrlRead($cCombo))
	     ConsoleWrite($schoice & "$sChoice")


		Case $Radio1

			If GUICtrlRead($Radio1) = $GUI_CHECKED Then GUICtrlSetState($idCheckbox, $GUI_ENABLE) ;$sList1 = SetList($aArray0)


			If  GUICtrlRead($Radio1, $GUI_UNCHECKED) Then
			 ;GUICtrlSetState($cCombo, $GUI_SHOW)
             GUICtrlSetState($idCheckbox, $GUI_SHOW)
             EndIf

			;if $checkbox= True and $radio1 = True  Then		GUICtrlSetState($cCombo, $GUI_SHOW)



			If BitAND(GUICtrlRead($Radio1), $GUI_CHECKED) Then $sList1 = SetList($aArray0)



			$Selection1 = True
			$selection2 = False
			;GUICtrlSetData($hCombo, $sList1)
			ConsoleWrite($Selection1 & "=$Radio1" & @CRLF)
			Checkbox()


		Case $Radio2
			;tablet

			;If GUICtrlRead($Radio2) = $GUI_CHECKED Then $sList1 = SetList($aArray1)
			If BitAND(GUICtrlRead($Radio2), $GUI_CHECKED) Then $sList1 = SetList($aArray1)
			$selection2 = True
			$Selection1 = False
			GUICtrlSetData($hCombo, $sList1)
			ConsoleWrite($selection2 & "$Radio2" & @CRLF)

			If GUICtrlRead($Radio2, $GUI_CHECKED) Then
			  GUICtrlSetState($cCombo, $GUI_hIDE)
			   GUICtrlSetState($idCheckbox, $GUI_UNCHECKED)
             GUICtrlSetState($idCheckbox, $GUI_hIDE)

            EndIf





		Case $Input1




			If $Radio1 = True And $checkbox = True Then  ; generate ip base on training swtich black and white
				$Checknum = $sChoice ; training riab
				;$TempChecknum = GUICtrlRead($Input1)

			Elseif $checkbox = False Then
				$Checknum = GUICtrlRead($Input1) ; Generate ip on base live  store network black  and white
			EndIf

			ConsoleWrite($Checknum & '$Checknum2' & @CRLF)
			ConsoleWrite($TempChecknum & '$TempChecknum' & @CRLF)





		Case $hCombo
			$sValueread = ""
			$sValueread = GUICtrlRead($hCombo)
			MsgBox(0, "You Selected Register", $sValueread & @CRLF)



		Case Else
			;Case $cPink_Button

			;See if a button was pressed
			For $i = 1 To 20 ;20
				If $iMsg = $cPink_aButton[$i] Then
					;Call(Rename & $i)
					; Do what is necessary
					MsgBox($MB_SYSTEMMODAL, "Pressed", "Button " & $i)
					; No point in looking further
					ExitLoop
				EndIf
			Next


			; MsgBox($MB_SYSTEMMODAL, "Hi", "Test button in pink section pressed")
	EndSwitch

	; Pass main GUI handle and event message to the UDF so it can action its extendable section automatically
	_GUIExtender_EventMonitor($hGUI, $iMsg)

WEnd






Func SetList($aArray)
	If Not UBound($aArray) Then Return ""
	Local $sList = ""
	For $i = 0 To UBound($aArray) - 1
		$sList &= "|" & $aArray[$i]
	Next
	Return $sList

EndFunc   ;==>SetList




Func _ActionCombo($sChoice)

	; Get index of choice in array
	$iIndex = _ArraySearch($aList, $sChoice)
	; And delete it
	; _ArrayDelete($aList, $iIndex)
	; Refill combo
	;_FillCombo()

	MsgBox($MB_SYSTEMMODAL, "Training RIAB", "You selected " & $sChoice & @CRLF)
	Return $sChoice
EndFunc   ;==>_ActionCombo




Func _FillCombo()

    $sData = ""
    For $i = 0 To UBound($aList) - 1
        $sData &= "|" & $aList[$i]
    Next
    GUICtrlSetData($cCombo, $sData)

EndFunc





Func Checkbox()

	If BitAND(GUICtrlRead($idCheckbox), $GUI_CHECKED) And $Selection1 = True Then
		;training fixed

		$sList1 = SetList($aArray2)
		GUICtrlSetData($hCombo, $sList1)
		$Checkbox = True
		ConsoleWrite("Checkbox" & $Checkbox & @CRLF)


	ElseIf BitAND(GUICtrlRead($idCheckbox), $GUI_UNCHECKED) And $Selection1 = True Then
		;live store
		$sList1 = SetList($aArray0)
		GUICtrlSetData($hCombo, $sList1)
		$Checkbox = False
		ConsoleWrite("Checkbox" & $Checkbox & @CRLF)



	ElseIf $selection2 = True Or Checkbox = True Or Checkbox = False Then
		;tablet
		if GUICtrlRead($radio2,  $GUI_CHECKED) Then
      GUICtrlSetState ($idCheckbox, $GUI_UNCHECKED)
	  GUICtrlSetState($cCombo, $GUI_DISABLE)
	  EndIf
		$sList1 = SetList($aArray1)
		GUICtrlSetData($hCombo, $sList1)

	EndIf




EndFunc   ;==>Checkbox












Func _WM_MOVE($hWnd, $iMsg, $wParam, $lParam)
	; If the main GUI moves
	If $hWnd = $hGUI Then
		; Move the child to follow
		Local $aGUI_Pos = WinGetPos($hWnd)
		WinMove($hGUI_Child, "", $aGUI_Pos[0], $aGUI_Pos[1] + $aGUI_Pos[3])
	EndIf
EndFunc   ;==>_WM_MOVE











Func _GUICtrlListView__SetBGColor($hWnd, $Item_index, $Color_RGB)
	Local $ctrlID = _GUICtrlListView_GetItemParam($hWnd, $Item_index)
	GUICtrlSetBkColor($ctrlID, $Color_RGB)
	;GUICtrlSetFont($ctrlID, 12, 700)
EndFunc   ;==>_GUICtrlListView__SetBGColor



Func _GUICtrlListView_CreateArray($hListView, $sDelimeter = '|')
	Local $iColumnCount = _GUICtrlListView_GetColumnCount($hListView), $iDim = 0, $iItemCount = _GUICtrlListView_GetItemCount($hListView)
	If $iColumnCount < 3 Then
		$iDim = 3 - $iColumnCount
	EndIf
	If $sDelimeter = Default Then
		$sDelimeter = '|'
	EndIf

	Local $aColumns = 0, $aReturn[$iItemCount + 1][$iColumnCount + $iDim] = [[$iItemCount, $iColumnCount, '']]
	For $i = 0 To $iColumnCount - 1
		$aColumns = _GUICtrlListView_GetColumn($hListView, $i)
		$aReturn[0][2] &= $aColumns[5] & $sDelimeter
	Next
	$aReturn[0][2] = StringTrimRight($aReturn[0][2], StringLen($sDelimeter))

	For $i = 0 To $iItemCount - 1
		For $j = 0 To $iColumnCount - 1
			$aReturn[$i + 1][$j] = _GUICtrlListView_GetItemText($hListView, $i, $j)
		Next
	Next
	Return SetError(Number($aReturn[0][0] = 0), 0, $aReturn)
EndFunc   ;==>_GUICtrlListView_CreateArray




















Func _ErrFunc($oError)
	; Do anything here.

    ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
            @TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
            @TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
            @TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
            @TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
            @TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
            @TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
            @TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
            @TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
            @TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc






;**********************************************************Main Subsroutine********************************************************** April 30, 2017

Func Fixedpos()


	GUICtrlSetData($Progress1, 1) ;searching ip
	GUICtrlSetData($label, "" & "Searching IP Info...")
	Sleep(700)
	SearchIPInfo()

	GUICtrlSetData($Progress1, 10) ; retreiving ip info
	GUICtrlSetData($label, "" & "Retreiving IP Info...")
	Sleep(700)
	RetreivingIPInfo()
	;if $var <> 1 Then
    Personalize($Setmodule, 'SetModulesBat Realtime  Streaming')

	GUICtrlSetData($Progress1, 20) ; adding POs name
	GUICtrlSetData($label, "" & "Adding POS Name...")
	personalize($Cmmd, 'HOSTNAME CACHE CLEARING')
	Sleep(700)
	AddPOSname()



	GUICtrlSetData($Progress1, 30) ; Adding Static  ip info
	GUICtrlSetData($label, "" & "Adding Static IP's...")
	Sleep(700)
	AddStaticIPInfo($NewIP, $Gateaway)



	If $RegisterValueread = 01 Or $RegisterValueread = 21 Then ; or  $RegisterValueread = 21  Then ; if register is 01 live  or 21 for training then add back office printer only
		GUICtrlSetData($label, "" & "adding Samsung Back printer...")
		Sleep(1000)
	;	AddSamsungBackPrinter($backprinter)
;

	Else ;otherwise add service printer for all registers

		GUICtrlSetData($Progress1, 50) ; adding recptprinter
		GUICtrlSetData($label, "" & "adding Samsung front printer...")
		Sleep(1000)
		;AddSamsungFrontPrinter($frontprinter)

	EndIf






	GUICtrlSetData($Progress1,65) ; Personalzing Register
	$sX = "waiting for internet !" & @LF & "------------------" & @LF
	ToolTip($sX, "", "Continue", "Internet", 1, 4)
	GUICtrlSetData($label, "" & "Personalzing Register...")
	_IsinternetCheck()
	Sleep(1000)
	if IsAdmin() Then Personalize($OracleRetail,'JARVIS POS INSTALLER MONITOR REALTIME STREAMING')
	;RunWait($OracleRetail, "", @SW_HIDE)





	GUICtrlSetData($Progress1, 75) ; "Checking Com Port 2
	GUICtrlSetData($label, "" & "Checking Com Port 2 ...")
	Sleep(500)
	ToolTip("")
	;checkcomport2



	If  $Checkbox = True Then   ; training check  True
     ; do nothing  do not run pinpad
        Else
		$sX = "Processing Be Patient !" & @LF & "------------------" & @LF
		ToolTip($sX, "", "Pinpad", "Update..", 1, 4)
		GUICtrlSetData($Progress1, 85) ; updating $Pinpad
		GUICtrlSetData($label, "" & "updating Pinpad...")
		Sleep(1000)
		Personalize($Pinpad, 'PINPAD INSTALLER MONITOR REALTIME STREAMING')
		ToolTip("")
	 	EndIf



	If $RegisterValueread = 01 Or $RegisterValueread = 21 Then

		; do nothing
	Else
		GUICtrlSetData($Progress1, 95) ; adding recptprinter
		GUICtrlSetData($label, "" & "adding recptprinter...")
		Sleep(1000)
		addEpson($RecptPrinter)
	EndIf



	;
	GUICtrlSetData($Progress1, 100) ;DONE!
	GUICtrlSetData($label, "Done!")
	Sleep(1000)





EndFunc   ;==>Fixedpos







Func Wireless()



	GUICtrlSetData($Progress1, 1) ;searching ip
	GUICtrlSetData($label, "" & "Searching IP Info...")
	Sleep(500)
	SearchIPInfo()

	GUICtrlSetData($Progress1, 20) ; retreiving ip info
	GUICtrlSetData($label, "" & "Retreiving IP Info...")
	Sleep(500)
	RetreivingIPInfo()




	GUICtrlSetData($Progress1, 40) ;  activating DHCP
	GUICtrlSetData($label, "" & "Activating DHCP...")
	Sleep(500)
	ActivateDhcp()




	GUICtrlSetData($Progress1, 55) ; adding POs name
	GUICtrlSetData($label, "" & "Adding POS Name...")
	Sleep(500)
	AddPOSname()





	GUICtrlSetData($Progress1, 65) ; adding recptprinter
	GUICtrlSetData($label, "" & "adding Samsung front printer...")
	Sleep(1000)
	;AddSamsungFrontPrinter($frontprinter)



	GUICtrlSetData($Progress1, 80) ; Personalzing Register
	$sX = "waiting for internet !" & @LF & "------------------" & @LF
	ToolTip($sX, "", "Continue", "Internet", 1, 4)
	GUICtrlSetData($label, "" & "Personalzing Register...")
	Sleep(1000)
	_IsinternetCheck()
	Sleep(1000)
	If IsAdmin() Then personalize($OracleRetail, 'JARVIS POS INSTALLER MONITOR REALTIME STREAMING')




	GUICtrlSetData($Progress1, 85) ; adding recptprinter
	GUICtrlSetData($label, "" & "adding Tab printer...")
	Sleep(1000)
	;addEpson($TabPrinter)



	; GUICtrlSetData($Progress1, 90); updating $Pinpad  ; not needed
	;GUICtrlSetData($label, "" & "updating Pinpad...")
	;Sleep(500)
	;if IsAdmin() Then Personalize($Pinpad,'PiNPAD INSTALLER MONITOR REALTIME STREAMING')



	GUICtrlSetData($Progress1, 100) ;DONE!
	GUICtrlSetData($label, "Done!")
	Sleep(1000)

EndFunc   ;==>Wireless






Func EventStore()
EndFunc   ;==>EventStore





;**************************************************************search ip**************************************************************************** April 10 2017
Func SearchIPInfo()

		_GUICtrlListView_DeleteAllItems($aListViews)
		;GUICtrlCreateListViewItem('Subnet|IP Range|SVR-LAN', $aListViews)
sleep(500)

	;MsgBox(0, '1', $check_listview)
	if $check_listview = False Then
		$aListViews = GUICtrlCreateListView("| UCS Subnet/ 28||", 76, 8, 361, 473, -1, BitOR($WS_EX_CLIENTEDGE, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT)) ;56
		$check_listview=True
		;MsgBox(0, '12','')
	EndIf

	ToolTip("", 500, 0)

	;$Checknum = GUICtrlRead($Input1)

	;$tempChecknum= $Checknum
	Local $noip ;GUICtrlRead($Input4)
	; $newmobile= StringTrimLeft($mobile,1)+1
	Local $mobile ;=0	 Then  $mobile = 1; GUICtrlRead($Input1) ; tablet
	$receiptPrinter = $noip ;   GUICtrlRead($Input2 )  ; receipt printer
	$TabPrinter = 3 ; GUICtrlRead($input6)    ;receipt tab printer

       ;$checknum = $sChoice

	If $Checknum <> "" Then

		;_ArrayDisplay($mydata)
		For $i = 1 To UBound($mydata) - 1
			$check = False
			$notFound = ($mydata[$i][0] ) ; & "Notfound")
			;WinSetTitle($hGUI ,"",ToolTip($notFound))
			If $mydata[$i][0] = $Checknum Then
				ConsoleWrite('found' & @CRLF)
				$check = True
				Global	$found = ($mydata[$i][0]) ; & "found")
				;	WinSetTitle($hGUI ,"",ToolTip($Found))

				$blackLAN = $mydata[$i][19]
				$srvLAN = $mydata[$i][34]

				;MsgBox(0, '2', '')
				$ip1 = StringSplit($srvLAN, ".")
				$ip2 = StringSplit($blackLAN, ".")
				Global $strsvlan = _ArrayToString($ip1, ".", 1, UBound($ip1) - 2)
				ConsoleWrite($strsvlan & "$srvLAN")

				$DefaultGateway = $strsvlan & '.' & $ip1[UBound($ip1) - 1] + 1
				$subnetMask = '255.255.255.240'
				$SubnetMask2 = '255.255.255.192'

				$WinIPAddress = $strsvlan & '.' & $ip1[UBound($ip1) - 1] + 6
				$ESXiIPAddress = $strsvlan & '.' & $ip1[UBound($ip1) - 1] + 3

				$i = UBound($mydata) + 1



				;===================create list view=======================================================
				GUICtrlCreateListViewItem('Subnet|IP Range|SVR-LAN', $aListViews)
				GUICtrlCreateListViewItem($subnetMask & '||' & $srvLAN, $aListViews)
								;MsgBox(0, '1', '')

				if $radio1 = True and $checkbox = True Then
				GUICtrlCreateListViewItem('SREI' & StringFormat('%05d', $schoice) & 'RE00|Win IPAdress|' & $ip1[UBound($ip1) - 1] + 6, $aListViews)
                EndIf


				if $checkbox = false Then
				GUICtrlCreateListViewItem('SREI' & StringFormat('%05d', $Checknum) & 'RE00|Win IPAdress|' & $ip1[UBound($ip1) - 1] + 6, $aListViews)
				EndIf

				GUICtrlCreateListViewItem('Register Subnet /26||', $aListViews)
				GUICtrlCreateListViewItem('||', $aListViews)

				GUICtrlCreateListViewItem('Subnet|IP Range|Black-LAN', $aListViews)
				GUICtrlCreateListViewItem($SubnetMask2 & '||' & $blackLAN, $aListViews)


				;GUICtrlCreateListViewItem('|Device Type|Last Octet', $alistviews)
				GUICtrlCreateListViewItem('|Default Gateway >|' & $ip2[UBound($ip2) - 1] + 1, $aListViews)


				; value for  noip or mobile
				If $Selection1 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_UNCHECKED) Then
					$noip = $sValueread
					; load row in listview
				EndIf

				If $Selection1 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_CHECKED) Then
					$noip = StringTrimLeft($sValueread, 1) ; get the actual count ie  50 remove 5 then add 1
				EndIf


				For $j = 1 To $noip ; value fixed pos

					If $Selection1 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_CHECKED) Then
						             $TempChecknum =GUICtrlRead($input1) ; ensure the store name is use as host on training although the IP will be base on swtich 9350, 9351, ect..
						GUICtrlCreateListViewItem('Static|SREI' & StringFormat('%05d', $tempChecknum) & 'RE' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 15 + $j, $aListViews) ; training listviews


					ElseIf $Selection1 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_UNCHECKED) Then
						GUICtrlCreateListViewItem('Static|SREI' & StringFormat('%05d', $Checknum) & 'RE0' & $j & '|' & $ip2[UBound($ip2) - 1] + 15 + $j, $aListViews) ; live listviews


					EndIf
					;GUICtrlCreateListViewItem('Static|Register ' & $j & '|' & $ip2[UBound($ip2) - 1] + 15 + $j, $alistviews)
					ConsoleWrite($j & "$noip" & @CRLF)
				Next
				ConsoleWrite(@CRLF)

				_IPtable($noip) ; subroutine to select and clear non wanted ip

				;EndIf





				If $selection2 = True Then ;  value mobile
					$mobile = StringTrimLeft($sValueread, 1) + 1 ; get the actual count ie  50 remove 5 then add 1

					For $j = 1 To $mobile ; display value mobile
						GUICtrlCreateListViewItem('DHCP|SREI' & StringFormat('%05d', $Checknum) & 'RE' & $j + 49 & '|' & "_", $aListViews)
						;GUICtrlCreateListViewItem('DHCP|Tablet' & $j + 49 & '|' & "_", $alistviews)
						ConsoleWrite($j & "$mobile" & @CRLF)
					Next


					_IPtable($mobile) ; subroutine to select and clear non wanted ip

				EndIf





				If $Radio1 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_CHECKED) Then

					Local $j = $noip

					If $j = 8 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 24, $aListViews)
					If $j = 7 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 25, $aListViews)
					If $j = 6 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 26, $aListViews)
					If $j = 5 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 27, $aListViews)
					If $j = 4 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 28, $aListViews)
					If $j = 3 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 29, $aListViews)
					If $j = 2 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & 2 & $j & '|' & $ip2[UBound($ip2) - 1] + 30, $aListViews)


				EndIf





				If $Radio1 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_UNCHECKED) Then

					Local $j = $noip

					If $j = 8 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 24, $aListViews)
					If $j = 7 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 25, $aListViews)
					If $j = 6 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 26, $aListViews)
					If $j = 5 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 27, $aListViews)
					If $j = 4 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 28, $aListViews)
					If $j = 3 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 29, $aListViews)
					If $j = 2 Then GUICtrlCreateListViewItem('Static|Recpt Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 30, $aListViews)

				EndIf




				If $Radio2 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_UNCHECKED) Then

					$j = $mobile

					Switch ($j)

						;;for $j= $tabprinter to 1 step -1

						Case 12 To 15
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 4 & '|' & $ip2[UBound($ip2) - 1] + 31, $aListViews)

						Case 8 To 11
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 3 & '|' & $ip2[UBound($ip2) - 1] + 32, $aListViews)

						Case 4 To 7
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 2 & '|' & $ip2[UBound($ip2) - 1] + 33, $aListViews)

						Case 1 To 3
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 1 & '|' & $ip2[UBound($ip2) - 1] + 34, $aListViews)
							;Next
						Case Else
					EndSwitch

				EndIf






				If $Radio2 = True And BitAND(GUICtrlRead($idCheckbox), $GUI_CHECKED) Then

					$j = $mobile

					Switch ($j)

						;;for $j= $tabprinter to 1 step -1

						Case 12 To 15
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 24 & '|' & $ip2[UBound($ip2) - 1] + 31, $aListViews)

						Case 8 To 11
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 23 & '|' & $ip2[UBound($ip2) - 1] + 32, $aListViews)

						Case 4 To 7
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 22 & '|' & $ip2[UBound($ip2) - 1] + 33, $aListViews)

						Case 1 To 3
							GUICtrlCreateListViewItem('Static|Tab Printer ' & 21 & '|' & $ip2[UBound($ip2) - 1] + 34, $aListViews)
							;Next
						Case Else
					EndSwitch

				EndIf




				For $j = $noprinter To 1 Step -1

					If $j = 2 Then GUICtrlCreateListViewItem('Static|Front Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 35, $aListViews)
					If $j = 1 Then GUICtrlCreateListViewItem('Last Static|Back Printer ' & $j & '|' & $ip2[UBound($ip2) - 1] + 36, $aListViews)
				Next






				GUICtrlCreateListViewItem('Last Usable (DHCP)||' & $ip2[UBound($ip2) - 1] + 61 + 1, $aListViews) ; added a one last was short by one
				GUICtrlCreateListViewItem('DNS|P: 10.1.246.40|S: 10.224.41.40', $aListViews)
				GUICtrlCreateListViewItem('WINS|P: 10.1.40.68|S: 10.224.40.68', $aListViews)

				EndIf
				If $i < UBound($mydata) - 1 Then
				If $mydata[$i][0] = "" And $mydata[$i + 1][0] = "" Then $i = UBound($mydata) + 1 ;exit when 2 empty row
				if $mydata[$i][0]= ""  Then $i = UBound($mydata)+1 ;exit when 2 empty row
			EndIf
		Next




If $check = False Then
	MsgBox(0,   'not found',$checknum,10)
exit

EndIf


		$n = _GUICtrlListView_GetItemCount($aListViews)
		ConsoleWrite($n & "$n" & @CRLF)
		For $i = 0 To $n
			_GUICtrlListView__SetBGColor($aListViews, $i, "0xDCE6F1")
		Next
		_GUICtrlListView__SetBGColor($aListViews, 0, "0x95B3D7")
		_GUICtrlListView__SetBGColor($aListViews, 1, "0x95B3D7")
		_GUICtrlListView__SetBGColor($aListViews, 11, "0x95B3D7")
		_GUICtrlListView__SetBGColor($aListViews, $n - 1, "0x95B3D7")
		_GUICtrlListView__SetBGColor($aListViews, $n - 2, "0xC0C0C0")
		_GUICtrlListView_SetColumnWidth($aListViews, 0, $LVSCW_AUTOSIZE)
		ResizeEight_listview()

	EndIf

	;ToolTip("", 0, 0)
EndFunc   ;==>SearchIPInfo







Func _IPtable($value) ;fixed AND MOBILE


	$counter = 1

	For $j = _GUICtrlListView_GetItemCount($aListViews) - 2 To 0 Step -1
		If $counter > $value - 1 Then ExitLoop ; exit

		_GUICtrlListView_DeleteItem($aListViews, $j)
		$counter += 1
		ConsoleWrite($counter & "$counter" & @CRLF)

	Next

	Return $RegisterValueread

EndFunc   ;==>_IPtable




;;*************************************************************************Run Installer POS and PINDPAD overloaded Function************************** added May 10, 2017

Func personalize($JarvisORPinpadOREpson, $Title)
	Local $hTimer = TimerInit() ;  time starting of process
	Local $valueJarPinEPS = $JarvisORPinpadOREpson

	$hProcessHandle = _Process_RunCommand($PROCESS_RUN, $PROCESS_COMMAND & $valueJarPinEPS, @WorkingDir) ; Capture the Process Handle
	$iPID = @extended ; Note the PID
	;$iMode1=_Process_DebugRunCommand($hProcessHandle, $iPID) ; Display the results in real-time
	$iMode1 = _Process_DebugRunCommand($hProcessHandle, $iPID, $Title)
	$iExitCode = @extended ;
	Local $fDiff = TimerDiff($hTimer); time difference in MS
    $EndTimer= ($fDiff *  0.001) ; convert to ms
	$RoundEntimer= Round($EndTimer)

	If Not @error And $iExitCode = 0 Then

	_Process_WaitUntil($iMode1, $hProcessHandle)
 _Log_Report($hLog, $Title &"----- "& $RoundEntimer& "ms------ "&'success----#', $iPID& "   "  )
   ConsoleWrite($RoundEntimer)
	Else
	 ; error
     _Log_Report($hLog, $Title &"----- "& $RoundEntimer& "ms------ "&'Failed----#', $ID& "   "  )
EndIf

$hTimer =0 ; res

EndFunc   ;==>personalize







Func addEpson($RecptPrinter)

   if @OSVersion = 'win10' Then
	$var = RegRead("HKEY_CURRENT_USER\Software\StoreBuild", "epsonkey2") ; read the key again redundancy
	Local $sUpdateIP = $RecptPrinter
	Local $sEpsonUpdate = '"' & $sDestination & '\copyfilex.exe" ' & $sUpdateIP
	Local $sEpsonSilent = '"' & $sDestination & '\epson.exe -f silent.properties LAX_VM "D:\Apps\Java\jre\bin\java.exe"'




	If $var <> 1 And $Selection1 = True Then ; wired epson printer
		If IsAdmin() Then FileInstall(".\DataStorage\Ethernet\Jpos.xml", $sDestination & "Jpos.xml", 1) ;===> Modify this path
		personalize($sEpsonSilent, 'INSTALLING EPSON PRINTER REALTIME STREAMING')
		Sleep(3 * 5000)
		personalize($sEpsonUpdate, ' ADDING IP EPSON PRINTER REALTIME STREAMING')
		Sleep(1000)
		Epsonvalidate()

	ElseIf $var = 1 And $Selection1 = True Then
		If IsAdmin() Then FileInstall(".\DataStorage\Ethernet\Jpos.xml", $sDestination & "Jpos.xml", 1) ;===> Modify this path
		Sleep(500)
		personalize($sEpsonUpdate, 'ADDING IP EPSON PRINTER REALTIME STREAMING')
		Sleep(500)
		Epsonvalidate()
	EndIf




	If Not $var <> 1 And $selection2 = True Then ; wired epson printer	  ; wireless epson printer
		If IsAdmin() Then FileInstall(".\DataStorage\Wireless\Jpos.xml", $sDestination & "Jpos.xml", 1) ;===> Modify this path
		personalize($sEpsonSilent, 'INSTALLING WIRELESS EPSON PRINTER REALTIME STREAMING')
		Sleep(3* 5000)
		personalize($sEpsonUpdate, 'ADDING IP  WIRELESS EPSON PRINTER REALTIME STREAMING')
		Sleep(1000)
		Epsonvalidate()

	ElseIf $var = 1 And $selection2 = True Then
		If IsAdmin() Then FileInstall(".\DataStorage\Wireless\Jpos.xml", $sDestination & "Jpos.xml", 1) ;===> Modify this path
		Sleep(500)
		personalize($sEpsonUpdate, 'ADDING IP WIRELESS EPSON PRINTER REALTIME STREAMING')
		Sleep(500)
		Epsonvalidate()
	EndIf

EndIf

	;If IsAdmin Then
	; RunWait(@ComSpec & ' /c ' & $sEpsonSilent, "", @SW_HIDE)
	; RunWait(@ComSpec & ' /c ' & $sEpsonUpdate, "", @SW_HIDE)
	; Runwait(@Comspec & ' /c ' & $sEpsonIPconfig, "",@sw_HIDE)





EndFunc   ;==>addEpson



Func Epsonvalidate()
;Global $sHKLMRoot = @OSArch = "x64" ? "HKLM64" : "HKLM"
local $value1= false, $value2= False
;Checks to see if Epson JavaPOS ADK and  EPSON Port Communication Service client are installed

$epsonApp="Epson JavaPOS ADK"
$key1App= $sHKLMRoot& "\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"


$epsonPort ="EPSON Port Communication Service"
$key2Port =$sHKLMRoot&"\SYSTEM\ControlSet001\Services\"
For $j = 1 To 500

        $AppKey = RegEnumKey($key1App, $j)

        If @error <> 0 Then Exitloop

       If StringInStr(RegRead($key1App & "\" & $AppKey, "DisplayName"), $epsonApp) Then
		   $value1 = True
		  ;  MsgBox(0, $AppKey, RegRead($key1App & "\" & $AppKey, "DisplayName"))
		  ; it is installed

	    EndIf

Next


for $j = 1 to 500
		  $AppKey = RegEnumKey($key2Port, $j)

		   If @error <> 0 Then Exitloop


       If StringInStr(RegRead($key2Port & "\" & $AppKey, "DisplayName"), $epsonPort) Then
         $value2 = True
      ; MsgBox(0, $AppKey, RegRead($key2Port & "\" & $AppKey, "DisplayName"))
	  ; it is installed
	  EndIf

Next



if  $value1 = true and $value2 = true then
  RegWrite("HKEY_CURRENT_USER\Software\StoreBuild", "EpsonKey2", "REG_SZ", 1 )
  ;msgBox(0, "Info", "Epson printer was  sucessfully installed ", 5)

  __Console__CreateConsole()

       ; Cout("Enter your name: ")
       ; cout($Name)
        Cout("Epson printer was  sucessfully installed "& @LF, @LF & $FOREGROUND_GREEN)
       ; cout($Age)
       ; Cout("Do you want your answers printed in red? y/n: ")
		Sleep(500)
__Console__KillConsole()

Else

;MsgBox(0, "error", "Epson printer was not installed sucessfully.... try to install manually ", 5)

 __Console__CreateConsole()

       ; Cout("Enter your name: ")
       ; cout($Name)
        Cout("Epson printer was not installed .... try to install manually"& @LF,@LF &$FOREGROUND_RED)
       ; cout($Age)
       ; Cout("Do you want your answers printed in red? y/n: ")
		Sleep(500)
__Console__KillConsole()
 EndIf

EndFunc









;***************************************************************delete oraclefolder  routine**************************

Func _DirRemoveContents($folder)
	Local $search, $file
	If StringRight($folder, 1) <> "\" Then $folder = $folder & "\"
	If Not FileExists($folder) Then Return 0
	FileSetAttrib($folder & "*", "-RSH")
	FileDelete($folder & "*.*")
	$search = FileFindFirstFile($folder & "*")
	If $search = -1 Then Return 0
	While 1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		If StringRight($file, 1) = "." Then ContinueLoop
		DirRemove($folder & $file, 1)
	WEnd
	Return FileClose($search)
EndFunc   ;==>_DirRemoveContents






Func _Uninstall()


	#NoTrayIcon
	;ProcessWaitClose("StoreBuild4ew.exe")
	Sleep(1000)
	;FileDelete($cmdline[7])
	;FileDelete($sDestination&"\INSTALL.CMD")
	FileDelete($sDestination & "\jpos.xml")
	FileDelete($sDestination & "\jpos1141.jar")
	FileDelete($sDestination & "\pcs.properties")
	FileDelete($sDestination & "\silent.properties")
	FileDelete($sDestination & "\copyfilex.exe")
	;FileDelete($sDestination & "\Ipconfig.exe")


EndFunc   ;==>_Uninstall







Func _KZB_on()
	;Send ("{VOLUME_MUTE}")
	BlockInput(1)
EndFunc   ;==>_KZB_on



Func _KZB_off()

	BlockInput(0)
	DllCall("Kernel32.dll", "bool", "Beep", "dword", 500, "dword", 1000)
	;Beep(500, 1000) ; sound beep completed
	;Send ("#d")
EndFunc   ;==>_KZB_off
















Func ResizeListview()
	ConsoleWrite("-!" & @CRLF)
	$colwidth = ControlGetPos($hGUI_Child, '', $aListViews)
	;If $colwidth > 10 Then ;18nov
	_GUICtrlListView_SetColumnWidth($aListViews, 0, $colwidth[2] / 3)
	_GUICtrlListView_SetColumnWidth($aListViews, 1, $colwidth[2] / 3)
	_GUICtrlListView_SetColumnWidth($aListViews, 2, $colwidth[2] / 3 - 4)
	;EndIf

	;18Nov


EndFunc   ;==>ResizeListview



Func ResizeEight_listview()
	$iY = _GUICtrlListView_ApproximateViewHeight($aListViews)
	_WinAPI_SetWindowPos(GUICtrlGetHandle($aListViews), 0, 02, 02, 350, $iY, $SWP_NOMOVE) ; 394
	GUICtrlSetPos($aListViews, Default, Default, Default, $iY)
	ResizeListview()
EndFunc   ;==>ResizeEight_listview



;******************************************************************************retreive IP info*******************************april 17, 2017

Func RetreivingIPInfo()

	$n = _GUICtrlListView_GetItemCount($aListViews)
	 sleep(1000)
	If $n > 5 Then

		$tmp = _GUICtrlListView_CreateArray($aListViews, @TAB)
		;_ArrayDisplay($tmp)
		$pip = ""
		$pgate = ""

		For $j = 0 To UBound($tmp) - 1
			If StringInStr($tmp[$j][2], 'black-lan') Then
				$pip = $tmp[$j + 1][2]
			EndIf
			If StringInStr($tmp[$j][2], 'svr-lan') Then
				$pgate = $tmp[$j + 1][2]
			EndIf
			If $pip <> "" And $pgate <> "" Then ExitLoop
		Next

		If $pip <> "" Then
			$A = StringSplit($pip, ".")
			If Not @error Then
				$pip = _ArrayToString($A, ".", 1, UBound($A) - 2)
				ConsoleWrite("$pip" & $pip & @CRLF)
			EndIf
		EndIf
		If $pgate <> "" Then
			$A = StringSplit($pgate, ".")
			If Not @error Then
				$pgate = _ArrayToString($A, ".", 1, UBound($A) - 2)
				ConsoleWrite("$pgate" & $pgate)
			EndIf
		EndIf


		If $Radio1 = True Then

			For $j = 7 To UBound($tmp) - 1

				If StringInStr($tmp[$j][1], 'Default Gateway >') Then $Gateaway = $pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'SREI') Then $sComputerName = $tmp[$j][1] ; ('SREI' & StringFormat('%05d', $Checknum) & 'RE0' & $j )) ; Then  $NewIP
				If $sComputerName = $tmp[$j][1] Then $NewIP = $pip & "." & $tmp[$j][2] ;
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Recpt Printer') Then $RecptPrinter = $pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Front Printer 2') Then $frontprinter = $pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Back Printer 1') Then $backprinter = $pip & "." & $tmp[$j][2]


			Next
		EndIf


		If $Radio2 = True Then

			For $j = 7 To UBound($tmp) - 1

				;If StringInStr($tmp[$j][1], 'Default Gateway >') Then $Gateaway ="" ;$pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'DHCP') And StringInStr($tmp[$j][1], 'SREI') Then $sComputerName = $tmp[$j][1] ; ('SREI' & StringFormat('%05d', $Checknum) & 'RE0' & $j )) ; Then  $NewIP
				;If $sComputerName = $tmp[$j][1] Then $NewIP = ""  ; $pip & "." & $tmp[$j][2];
				;If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Recpt Printer') Then $RecptPrinter = $pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Tab Printer ') Then $TabPrinter = $pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Front Printer 2') Then $frontprinter = $pip & "." & $tmp[$j][2]
				If StringInStr($tmp[$j][0], 'static') And StringInStr($tmp[$j][1], 'Back Printer 1') Then $backprinter = $pip & "." & $tmp[$j][2]

				;ConsoleWrite("tablet1")
			Next
		EndIf




	EndIf

	ConsoleWrite(@CRLF & $Gateaway & "$Gateaway" & @CRLF)
	ConsoleWrite($sComputerName & "$sComputerName" & @CRLF)
	ConsoleWrite($NewIP & "$NewIP" & @CRLF)
	ConsoleWrite($RecptPrinter & "$RecptPrinter" & @CRLF)
	ConsoleWrite($TabPrinter & "$Tabprinter" & @CRLF)
	ConsoleWrite($frontprinter & "$frontprinter" & @CRLF)
	ConsoleWrite($backprinter & "$backprinter" & @CRLF)
	ConsoleWrite($ucs & "ucs" & @CRLF)


EndFunc   ;==>RetreivingIPInfo




Func AddStaticIPInfo($NewIP, $Gateaway)
;set static Ip for windows 10  ethernet connection
Local $subnetMask = "255.255.255.192", $DnsPrimary = "10.1.246.40", $DnsSecondary = "10.224.41.40"
Local $WinsPrimary = " 10.1.40.68", $WinsSecondary = "10.224.40.68"


RunWait('netsh interface ipv4 set address name="Ethernet" source=static address=' & $NewIP & ' mask=' & $subnetMask & ' gateway=' & $Gateaway, "", @SW_HIDE) ; gwmetric=1
;ConsoleWrite("newIPtest" & $NewIP &' mask=' & $subnetMask & ' gateway=' & $Gateaway)





		RunWait('netsh interface ipv4 set address name="Ethernet" source=static address=' & $NewIP & ' mask=' & $subnetMask & ' gateway=' & $Gateaway, "", @SW_HIDE) ; gwmetric=1
		;ConsoleWrite("newIPtest" & $NewIP &' mask=' & $subnetMask & ' gateway=' & $Gateaway)

		RunWait('netsh interface ip set dns name= "Ethernet" source="static" address= ' & $DnsPrimary, "", @SW_HIDE)
		RunWait('netsh interface ip add dns name="Ethernet" index=2 addr=' & $DnsSecondary, "", @SW_HIDE)
		RegWrite($sHKLMRoot & '\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'SearchList', 'REG_SZ', 'rogers.com,Network.rogers.com,rci.rogers.com')
        ;~RunWait(@Comspec & ' /c Reg Add HKLM\system\currentcontrolset\services\tcpip\parameters /v "SearchList" /d "domain1.com,domain2.com" /f')
        RunWait('netsh interface ip set winsservers name= "Ethernet" source="static" address= ' & $WinsPrimary, "", @SW_HIDE)
		RunWait('netsh interface ip add winsservers name="Ethernet" index=2 addr=' & $WinsSecondary, "", @SW_HIDE)





EndFunc   ;==>AddStaticIPInfo



Func AddPOSname()
    local $sName = $sComputerName
	local $sWorkGroup = "WORKGROUP"
	Local $CMD = 'net config server /srvcomment:"'



     ; Make some registry changes to also change the name now
    RegDelete ($sHKLMRoot & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Hostname")
    RegDelete ($sHKLMRoot & "\CurrentControlSet\Services\Tcpip\Parameters", "NV Hostname")


	RegWrite($sHKLMRoot & "\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName", "ComputerName", "REG_SZ", StringUpper($sName))
	RegWrite($sHKLMRoot & "\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName", "ComputerName", "REG_SZ", StringUpper($sName))
	RegWrite($sHKLMRoot & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "Hostname", "REG_SZ", StringUpper($sName))
	RegWrite($sHKLMRoot & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "NV Hostname", "REG_SZ", StringUpper($sName))

	RunWait(@ComSpec & " /c " & $CMD & StringUpper($sName), "", "", @SW_HIDE) ; adding computer description name


	If @OSArch = "x64" Then
		DllCall("kernel32.dll", "boolean", "Wow64DisableWow64FsRedirection", "boolean", 1) ;~ Turns On 64 Bit Redirection

		RunWait('PowerShell.exe -Command "& {Add-Computer -WorkGroupName "' & StringUpper($sWorkGroup) & '"}"', "", @SW_HIDE) ; adding to workgroup

		DllCall("kernel32.dll", "boolean", "Wow64DisableWow64FsRedirection", "boolean", 0) ;~ Turns Off 64 Bit Redirection
	Else

		RunWait('PowerShell.exe -Command "& {Add-Computer -WorkGroupName "' & StringUpper($sWorkGroup) & '"}"', "", @SW_HIDE) ; adding to workgroup

	EndIf

if not @error Then

	  personalize($HostNGroup,'ADDING NEW HOST NAME AND WORKGROUP')


MsgBox(0, "Done", "Computer was renamed to """ & $sName & """ and workgroup was set to """ & $sWorkgroup & """.",4)
Else
MsgBox(0, "Error", "Computer was not renamed to """ & $sName & """ and workgroup was  not set to """ & $sWorkgroup & """.")
EndIf
EndFunc   ;==>AddPOSname




;****************************************************************Tablet set ethernet dhcp and default to wifi ******************* April 30th 2017
Func ActivateDhcp()
;~	RunWait('netsh int ipv4 reset reset.log', "", @SW_HIDE)
	_DosRun('netsh interface ip set address "Ethernet" dhcp')
;~	RunWait('netsh interface ipv4 set address name= "Ethernet" dhcp', "", @SW_HIDE)
;~	RunWait('netsh interface ipv4 set dns "Ethernet" dhcp') ;,"",@SW_HIDE)
;~	RunWait('netsh interface ipv4 set wins "Ethernet" dhcp', "", @SW_HIDE)
;~	;RunWait('netsh interface ipv4 set address name="Ethernet" source=" dhcp', "", @SW_HIDE)
;~	ShellExecuteWait("suffxbat.bat", "", @ScriptDir, "", @SW_HIDE) ;clear suffixes
	RunWait('netsh interface ipv4 set address name="WI-FI" source =dhcp', "", @SW_HIDE) ;set wifi default
EndFunc   ;==>ActivateDhcp






Func _DosRun($sCommand)
	Local $nResult = Run('"' & @ComSpec & '" /c ' & $sCommand, @SystemDir, @SW_HIDE, 6)
	ProcessWaitClose($nResult, 150)
;~Return StdoutRead($nResult)
EndFunc   ;==>_DosRun







Func AddEpsonSilentFiles()
DirMove($Direxist, "D:\APPs\OracleRetailStore\Training Client", 1) ; june 5, 2017  no longer delete folder oracle store just renmae
If  $var = 1 Then
	;_DirRemoveContents($Direxist) ;delete content
	;DirRemove($Direxist) ; delete folder



	If IsAdmin() Then FileInstall(".\DataStorage\copyfilex.exe", $sDestination & "copyfilex.exe", 1) ;===> Modify this path copyfile2.exe  copy 2 files and update(jpos.xlm,pcs.properties)
	If IsAdmin() Then FileInstall(".\DataStorage\pcs.properties", $sDestination & "pcs.properties", 1) ;===> Modify this path     pcs.properties  2
	If IsAdmin() Then FileInstall(".\DataStorage\Jpos1141.jar", $sDestination & "Jpos1141.jar", 1) ;===> Modify this path       Jpo1141.jar  4



Else

	If IsAdmin() Then FileInstall(".\DataStorage\Install.ini", $sDestination & "Install.ini", 1) ; need to load ini file  to ensure right printer tm-10 is added on Jpos.xml
	If IsAdmin() Then FileInstall(".\DataStorage\copyfilex.exe", $sDestination & "copyfilex.exe", 1) ;===> Modify this path copyfile.exe  3 files copy 2 files and update(jpos.xlm,pcs.properties,jar)
	If IsAdmin() Then FileInstall(".\DataStorage\Jpos1141.jar", $sDestination & "Jpos1141.jar", 1) ;===> Modify this path       Jpo1141.jar  4
	If IsAdmin() Then FileInstall(".\DataStorage\pcs.properties", $sDestination & "pcs.properties", 1) ;===> Modify this path     pcs.properties 5
	If IsAdmin() Then FileInstall(".\DataStorage\silent.properties", $sDestination & "silent.properties", 1) ;===> Modify this path  silent.properties 7


EndIf

EndFunc








Func _UpdateTimer()
	Local $temp = _FormatTime(TimerDiff($timer) + $aggregateTime)
	GUICtrlSetData($lblTimer, $temp)

EndFunc   ;==>_UpdateTimer




;*********************************************************************************************time Counter********************************************************
Func _FormatTime($inputTime)
	Local $time[4] = [0]

	Local $originalTime = Round($inputTime / 1000, 2) ;legacy

	$time[0] = StringFormat("%.2d", Int($inputTime / 1000 / 60 / 60))

	If $time[0] >= 1 Then
		$inputTime -= Int($time[0] * 1000 * 60 * 60)
	EndIf

	$time[1] = StringFormat("%.2d", Int($inputTime / 1000 / 60))
	If $time[1] >= 1 Then
		$inputTime -= Int($time[1] * 1000 * 60)
	EndIf

	$time[2] = StringFormat("%.2d", Int($inputTime / 1000))
	If $time[2] >= 1 Then
		$inputTime -= Int($time[2] * 1000)
	EndIf

	$time[3] = StringFormat("%.2d", Int($inputTime / 10))

	Return $time[0] & ":" & $time[1] & ":" & $time[2] & "." & $time[3] ;legacy
EndFunc   ;==>_FormatTime




Func _IsinternetCheck()
	Local $sX
if $checkbox = false Then
	$ucs = 'SREI' & StringFormat('%05d', $checknum)&'RE00'
Else
	$ucs =  $ucs = 'SREI' & StringFormat('%05d', $TempChecknum)&'RE00'
EndIf

	$ping = Ping($ucs)

	$IsCon = DllCall("WinInet.dll", "int", "InternetGetConnectedState", "int_ptr", 0, "int", 0)



	If $IsCon[0] = 1 And $ping > 0 Then
		$sX = "Connected !" & $ucs & @LF & "------------------" & @LF
		ToolTip($sX, "", "Continue", "Internet", 1, 4)


	Else

		$IsCon[0] = 0

		$sX = "Not Connected" & $ucs

		ToolTip($sX, "", "Continue", "Internet", 2, 4)
	EndIf

EndFunc   ;==>_IsinternetCheck










Func _FlatFile()

	If FileExists(@TempDir & "\NewRetail1.txt") Then ; if  file already exist
		$mydata = _FileText() ; calling function  read _FileText  then dump reading data into return value my $mydata array
	Else
		If IsAdmin() Then FileInstall(".\DataStorage\NewRetail1.txt", @TempDir & "\NewRetail1.txt", 1) ; elseif file does not exist then install at temp directory
		$mydata = _FileText() ;  calling function  read _FileText  then dump reading data into return value my $mydata array
	EndIf
EndFunc   ;==>_FlatFile








Func _FileText()


	Local $sFilePath = @TempDir & "\NewRetail1.txt" ; Change this to you own file path

	Local $hFile = FileOpen($sFilePath)
	If $hFile = -1 Then
		MsgBox(0, "", "Unable to open file")
		Exit
	EndIf

	Local $sString = FileRead($hFile)
	If @error Then
		MsgBox(0, "", "Unable to read file")
		FileClose($hFile)
		Exit
	EndIf
	FileClose($hFile)

	Local $data = _CSVSplit($sString, ",") ; Parse coma Separated Values (TSV)
	If IsArray($data) Then Return $data

EndFunc   ;==>_FileText




Func AddSamsungFrontPrinter($frontprinter)
	$TransitionORContractPrinter = $frontprinter

	$TransitionORContract = @OSVersion = "win_10" ? "TRANSITION" : "CONTRACT" ; IF WIN10 THEN "TRANSITION" ELSE WIN7  "CONTRACT"

	If Not @error Then

		; Remove a printer called "Samsung Front Printer" :
		_PrintMgr_RemovePrinter($TransitionORContract)

		; Remove the TCP/IP printer port called "fronttrainingPort"
		_PrintMgr_RemoveTCPIPPrinterPort("FPort")





		; Add a TCP/IP printer port, called "frontTCPIPPrinterPort", with IPAddress = $frontprinter and Port = 9100
		_PrintMgr_AddTCPIPPrinterPort("FPort", $TransitionORContractPrinter, 9100)


		; Add a printer, give it the name "Samsung Back Printer", use the driver called samsung universal print driver and the port called "backTCPIPPrinterPort"
		_PrintMgr_AddPrinter($TransitionORContract, "Samsung Universal Print Driver", "FPort")

	EndIf

EndFunc   ;==>AddSamsungFrontPrinter





Func AddSamsungBackPrinter($backprinter)

	$MFPorBackOfficeprinter = $backprinter

	$MFPorBackOffice = @OSVersion = "win_10" ? "MFP" : "BACK OFFICE" ; IF WIN10 THEN MFP  ELSE WIN7 BACK OFFICE


	If Not @error Then

		; Remove a printer called "Samsung Back Printer" :
		_PrintMgr_RemovePrinter($MFPorBackOffice)

		; Remove the TCP/IP printer port called "BacktrainingPort"
		_PrintMgr_RemoveTCPIPPrinterPort("BPort")






		; Add a TCP/IP printer port, called "frontTCPIPPrinterPort", with IPAddress = $frontprinter and Port = 9100
		_PrintMgr_AddTCPIPPrinterPort("BPort", $MFPorBackOfficeprinter, 9100)


		; Add a printer, give it the name "Samsung Back Printer", use the driver called samsung universal print driver and the port called "backTCPIPPrinterPort"
		_PrintMgr_AddPrinter($MFPorBackOffice, "Samsung Universal Print Driver", "BPort")

	EndIf



EndFunc   ;==>AddSamsungBackPrinter












; #FUNCTION# ====================================================================================================================
; Name ..........: RestartCountdown
; Description ...: Shows a countdown popup for restarting the computer
; Syntax ........: RestartCountdown($iSeconds[, $sIniFile = Default[, $bForce = False]])
; Parameters ....: $iSeconds            - Seconds until restart.
;                  $sIniFile            - [optional] Location of the ini file to store the last restart time.
;                  $bForce              - [optional] Force restart. Default is False.
; Return values .: Success: True
;                  Failure: False. @error is set to Shutdown()'s @error
;                  Special: When the user closes the GUI before the countdown ends, False is returned and @extended is set to 1
; ===============================================================================================================================
Func RestartCountdown($iSeconds, $sIniFile = Default, $bForce = False)
	If $sIniFile = Default Then $sIniFile = @TempDir & '\LastRestart_' & @ScriptName & '.ini'
	Local $sLastRestart = IniRead($sIniFile, "main", "last_restart", "Never")
	Local $iWidth = 200, $iHeight = 200
	Local $hGUI = GUICreate("Restart Countdown", $iWidth, $iHeight, -1, -1, $WS_SIZEBOX)
	Local $iTextWidth = 80, $iTextHeight = 35
	Local $iTextLeft = ($iWidth / 2) - ($iTextWidth / 2), $iTextTop = ($iHeight / 2.45) - ($iTextHeight / 2)
	Local $idSeconds = GUICtrlCreateLabel($iSeconds, $iTextLeft, $iTextTop, $iTextWidth, $iTextHeight, $SS_CENTER + $SS_SUNKEN)
	Local $iTextSize = 20
	GUICtrlSetFont($idSeconds, $iTextSize)
	Local $idLastRestart = GUICtrlCreateLabel('Last Restart: ' & $sLastRestart, 0, $iTextTop + $iTextHeight + 15, $iWidth, 25, $SS_CENTER)
	GUISetState()
	Local $iRemainingTime = $iSeconds
	Local $hTimer = TimerInit()
	While True
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($hGUI)
				Return SetExtended(1, False)
		EndSwitch
		$iRemainingTime = $iSeconds - Round(TimerDiff($hTimer) / 1000)
		;~$iRemainingTime = $iSeconds - Round((TimerDiff($hTimer) / 1000))
		If Not (GUICtrlRead($idSeconds) = String($iRemainingTime)) Then GUICtrlSetData($idSeconds, $iRemainingTime)
		If $iRemainingTime = 0 Then ExitLoop
		Sleep(10)
	WEnd
	GUIDelete($hGUI)
	IniWrite($sIniFile, "main", "last_restart", _NowDate() & ' ' & _NowTime())
	If $bForce Then
		Shutdown($SD_REBOOT + $SD_FORCE)
	Else
		Shutdown($SD_REBOOT)
	EndIf
	If @error Then Return SetError(@error, 0, False)
	Return True
EndFunc



