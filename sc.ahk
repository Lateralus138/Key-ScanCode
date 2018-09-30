;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                       ;
; Original concept found here:                                                          ;
; https://autohotkey.com/board/topic/21105-crazy-scripting-scriptlet-to-find-scancode-of-a-key/		;
; I beleive credit should be given to: Skan (please correct me if I am wrong)			;
; for his original script. Original parts marked with ***								;
; Everything else is written by me, but of course, I am very grateful to the original 	;
; author.																				;
; This was not aimed to improve anything Skan has done, he actually has a more thorough ;
; script out there, but I need something with more simplicity and something I can run	;
; without installing AutoHotkey on every system.										;
;                                                                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                       ;
; Key ScanCode is a small gui utility to view the corresponding scan codes and virtual	;
; key codes of any idividual button you press on a keyboard. This can be useful for		;
; any programmer looking to hook into Microsofts APIs; esepcially for scripting 		;
; languages like AutoHotkey, to manipulate or detect key pressess.						;
;                                                                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#NoTrayIcon
#SingleInstance,Force
SetBatchLines,-1
SetFormat, Integer, Hex ; ***
METRO:=	{	"DARK"		:	0x1D1D1D
		,	"SHADE"		:	0x000000
		,	"LIGHT"		:	0xFEFEFE
		,	"HILIGHT"	:	0xFFFFFF 
		,	"RED"		:	0xEE1111	}
WM_:=	{	"WM_LBUTTONDOWN"	:0x201
		,	"WM_MOUSEMOVE"		:0x200
		,	"WM_MOUSEMOVING"	:0x216	}
For FUNC, MSG in WM_
	OnMessage(MSG,FUNC)
TITLE:="Key ScanCode"
PREC:="SC :: "
PREK:="VK :: "
PREN:="Name :: "
MAINMSG=
(
Activate this window and press a key to see its'
corresponding scan and virtual key code
)
pToggle:=New toggle
Gui, Font,%  "s14 q5  c" METRO.LIGHT, Segoe UI
Gui, Margin, 0, 0
Gui, +AlwaysOnTop -Caption +Border  ; *** parts
Gui, Color, %DARK%, %LIGHT%
GuiButton(TITLE,"tTxt","tbTxt","tbHwnd","tbTxtHwnd",,METRO.DARK,METRO.HILIGHT,,,300,32)
Gui, Font,% "s10 c" METRO.DARK
Gui, Add, Text, +Center xp y+0 w300,% MAINMSG
Gui, Add, Picture, +BackgroundTrans x114 y+4 w32 h32 Icon216,%A_WinDir%\System32\shell32.dll
Gui,Font,% "s8 c" METRO.RED
Gui, Add, Text,x+0 yp h32 0x200 w40 vPauseV,Pause
;Gui, Add, Picture, +BackgroundTrans x272 yp+16 w24 h24 Icon211,%A_WinDir%\System32\shell32.dll
MinButton(252,22,METRO.LIGHT,METRO.HILIGHT)
CloseButton(276,6,METRO.LIGHT,METRO.HILIGHT)
Gui,Font, s11
Gui, Add, StatusBar,vSTATUS
SB_SetParts(160,65,75)
SB_SetText(PREN,1,1)
SB_SetText(PREC,2,1)
SB_SetText(PREK,3,1)
Gui, Show,AutoSize, % TITLE  ; *** parts
Gui,+LastFound
SCRIPT_ID:=WinExist()
Loop 9  ; ***
	OnMessage( 255+A_Index, "ScanCode" ) ; 0x100 to 0x108  ; ***
GetControls(TITLE)
WinSet,Transparent,223,% TITLE
Return  ; ***
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkeys                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!Space::pToggle.toggle()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions                                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WM_MOUSEMOVE(){
	Global
	If MouseOver(S3X,S3Y,S3X2,S3Y2,"Client")
		SetTimer,HELPTT,-1250
	Else ToolTip
}
WM_MOUSEMOVING(){
	ToolTip
}
ScanCode( wParam, lParam ){  ; ***
	Global
	Local tmp
	If ! pToggle.state {
		Clipboard :="SC" SubStr((((lParam>>16) & 0xFF)+0xF000),-2)  ; ***
		tmp:=SubStr(Clipboard,3),cn:=GetKeyName(Clipboard),cv:=GetKeyVK(Clipboard)
		;GuiControl,, SC,% cn " : " ci  ; *** parts
		SB_SetText(PREN cn,1,1)
		SB_SetText(PREC tmp,2,1)
		SB_SetText(PREK cv,3,1)
	}
}
WM_LBUTTONDOWN(){
	Global
	ToolTip
	If WinActive("ahk_id " SCRIPT_ID) {
		If MouseOver(S1X,S1Y,S1X2,S1Y2,"Client")
			PostMessage, 0xA1, 2,,,ahk_id %SCRIPT_ID%
		If MouseOver(MP2X,MP7Y,MP6X2,MP6Y2,"Client")
			WinMinimize,ahk_id %SCRIPT_ID%
		If MouseOver(MP7X,MP7Y,MP15X2,MP15Y2,"Client")
			Gosub,GuiClose
		If MouseOver(S3X,S3Y,S3X2,S3Y2,"Client") {
				If pToggle.toggle()
					GuiControl,Text,PauseV,Paused
				Else
					GuiControl,Text,PauseV,Pause
		}
	}
}
CloseButton(x,y,lcolor,dcolor,subWin:="",small:=False){
	Global
	Local big
	small:=small?3:4
	big:=small*3
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% x%x% y%y% w%small% h%small% vClose1, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 x+0 w%small% h%small% vClose2, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 x+0 w%small% h%small% vClose3, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 xp-%small% w%small% h%small% vClose4, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 xp-%small% w%small% h%small% vClose5, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp-%big% xp+%big% w%small% h%small% vClose6, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp-%small% x+0 w%small% h%small% vClose7, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp+%big% xp-%small% w%small% h%small% vClose8, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% y+0 x+0 w%small% h%small% vClose9, 100
}
MinButton(x,y,lcolor,dcolor,subWin:="",small:=False){
	Global
	Local big
	small:=small?3:4
	big:=small*3
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% x%x% y%y% w%small% h%small% vMin1, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin2, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin3, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin4, 100
	Gui, %subWin%Add, Progress, Background%lcolor% c%dcolor% yp x+0 w%small% h%small% vMin5, 100
}
GuiButton(title,txtvar,prgssvar,buttonHwnd,bTxtHwnd,subWin:="",color:="0x1D1D1D",border:="0x1D1D1D",x:="+0",y:="+0",w:="",h="",center:="Center"){ 
	Global
	%txtvar%:=title
	%prgssvar%:=100
	Gui,%subWin%Add,Progress,v%prgssvar% x%x% y%y% w%w% h%h% Background%border% c%color% Hwnd%buttonHwnd%,100
	Gui,%subWin%Add,Text,w%w% h%h% xp yp %center% +BackgroundTrans 0x200 v%txtvar% Hwnd%bTxtHwnd%,%title%
}
MouseOver(x1,y1,x2,y2,coordmode:="Screen"){
	CoordMode,Mouse,%coordmode%
	MouseGetPos,_x,_y
	Return (_x>=x1 AND _x<=x2 AND _y>=y1 AND _y<=y2)
}
GetControls(title,control:=0,posvar:=0){
	If (control && posvar)
		{
			namenum:=EnumVarName(control)
			ControlGetPos,x,y,w,h,%control%,%title%
			pos:=(posvar == "X")?x
			:(posvar == "Y")?y
			:(posvar == "W")?w
			:(posvar == "H")?h
			:(posvar == "X2")?x+w
			:(posvar == "Y2")?Y+H
			:0
			Globals.SetGlobal(namenum posvar,pos)
			Return pos
		}
	Else If !(control && posvar)
		{
			WinGet,a,ControlList,%title%
			Loop,Parse,a,`n
				{
					namenum:=EnumVarName(A_LoopField)
					If namenum
						{
							ControlGetPos,x,y,w,h,%A_LoopField%,%title%
							Globals.SetGlobal(namenum "X",x)
							Globals.SetGlobal(namenum "Y",y)
							Globals.SetGlobal(namenum "W",w)
							Globals.SetGlobal(namenum "H",h)
							Globals.SetGlobal(namenum "X2",x+w)
							Globals.SetGlobal(namenum "Y2",y+h)				
						}
				}
			Return a
		}
}
EnumVarName(control){
	name:=InStr(control,"msctls_p")?"MP"
	:InStr(control,"Static")?"S"
	:InStr(control,"Button")?"B"
	:InStr(control,"Edit")?"E"
	:InStr(control,"ListBox")?"LB"
	:InStr(control,"msctls_u")?"UD"
	:InStr(control,"ComboBox")?"CB"
	:InStr(control,"ListView")?"LV"
	:InStr(control,"SysTreeView")?"TV"
	:InStr(control,"SysLink")?"L"
	:InStr(control,"msctls_h")?"H"
	:InStr(control,"SysDate")?"TD"
	:InStr(control,"SysMonthCal")?"MC"
	:InStr(control,"msctls_t")?"SL"
	:InStr(control,"msctls_s")?"SB"
	:InStr(control,"327701")?"AX"
	:InStr(control,"SysTabC")?"T"
	:0
	num:=(name == "MP")?SubStr(control,18)
	:(name == "S")?SubStr(control,7)
	:(name == "B")?SubStr(control,7)
	:(name == "E")?SubStr(control,5)
	:(name == "LB")?SubStr(control,8)
	:(name == "UD")?SubStr(control,15)
	:(name == "CB")?SubStr(control,9)
	:(name == "LV")?SubStr(control,14)
	:(name == "TV")?SubStr(control,14)
	:(name == "L")?SubStr(control,8)
	:(name == "H")?SubStr(control,16)
	:(name == "TD")?SubStr(control,18)
	:(name == "MC")?SubStr(control,14)
	:(name == "SL")?SubStr(control,18)
	:(name == "SB")?SubStr(control,19)
	:(name == "AX")?SubStr(control,5)
	:(name == "T")?SubStr(control,16)
	:0
	Return name num
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Classes                                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Class Globals { ; my favorite way to set and retrive global variables. Good for
	SetGlobal(name,value=""){ ; setting globals from other functions.
		Global
		%name%:=value
		Return
	}
	GetGlobal(name){	
		Global
		Local var:=%name%
		Return var
	}
}
Class toggle {
	__New(init:=0){
		this.state:=!init?False:True
	}
	toggle(){
		Return this.state:=!this.state
	}
	off(){
		Return !(this.state:=False)
	}
	on(){
		Return this.state:=True
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subs                                                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HELPTT:
	If MouseOver(S3X,S3Y,S3X2,S3Y2,"Client") {
		SetFormat,Integer,Dec
		ToolTip,Press to pause catching input
		SetFormat,Integer,Hex
	}	Else	ToolTip
Return
GuiClose:
	ExitApp
