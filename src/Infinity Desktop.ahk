/*
 * Name: Infinity Desktop
 * Author: Dara Kong
 * Creation Date: 7 July 2022
 */

#Requires AutoHotkey v2.0-beta
#SingleInstance

#include _JXON.ahk
#include utils.ahk

;@Ahk2Exe-SetName Infinity Desktop
;@Ahk2Exe-SetDescription Fast Monitor Selection for Remote Desktop Connection
;@Ahk2Exe-SetCopyright © 2022 Dara Kong. All rights reserved.
;@Ahk2Exe-SetCompanyName BRP
;@Ahk2Exe-SetVersion 1.1.1
;@Ahk2Exe-SetLanguage 0x1009
;@Ahk2Exe-SetOrigFilename Infinity Desktop.ahk

;@Ahk2Exe-Base C:\Users\kongda\AppData\Roaming\AutoHotkey_2.0-beta.6\AutoHotkey32.exe, C:\Users\kongda\Documents\GitHub\Infinity-Desktop\target\InfinityDesktop32
;@Ahk2Exe-Base C:\Users\kongda\AppData\Roaming\AutoHotkey_2.0-beta.6\AutoHotkey64.exe, C:\Users\kongda\Documents\GitHub\Infinity-Desktop\target\InfinityDesktop64

;@Ahk2Exe-SetMainIcon media\Icon.ico

;@Ahk2Exe-AddResource media\Icon.ico, 160
;@Ahk2Exe-AddResource media\IconS.ico, 206
;@Ahk2Exe-AddResource media\IconP.ico, 207
;@Ahk2Exe-AddResource media\IconSP.ico, 208

Config := {
		Fullscreen: True,
		EditConnection: True
	}

ResourcesPath := A_AppData "\Infinity Desktop"

Monitors := Array()
MstscList := Array()

SelectedIDs := Array()
LastIDs := Array()

HoveredMonitor := 0

MouseX := 0
MouseY := 0

If (!DirExist(ResourcesPath)) {
	DirCreate(ResourcesPath)
}

SetWorkingDir(ResourcesPath)

If (!FileExist("mstscReader.ps1")) {
	FileInstall("C:\Users\kongda\Documents\GitHub\Infinity-Desktop\src\mstscReader.ps1", "mstscReader.ps1", 1)
}

If (!FileExist("mstscMonitors.json")) {
	FileInstall("C:\Users\kongda\Documents\GitHub\Infinity-Desktop\src\mstscMonitors.json", "mstscMonitors.json", 1)
}

If (FileExist(A_MyDocuments "\Default.rdp")) {
	FileCopy(A_MyDocuments "\Default.rdp", "custom.rdp", 1)
	FileSetAttrib("-RSH", "custom.rdp")
} Else {
	FileInstall("C:\Users\kongda\Documents\GitHub\Infinity-Desktop\src\custom.rdp", "custom.rdp", 1)
}

If (FileExist("config.ini")) {
	LoadData("config.ini")
}

If (!DirExist("media")) {
	DirCreate("media")

	FileInstall("C:\Users\kongda\Documents\GitHub\Infinity-Desktop\src\media\Keyboard_Keys_Text.png", "media\KBK_T.png", 1)
	FileInstall("C:\Users\kongda\Documents\GitHub\Infinity-Desktop\src\media\Keyboard_Keys_Hovered_Text.png", "media\KBK_HT.png", 1)
	FileInstall("C:\Users\kongda\Documents\GitHub\Infinity-Desktop\src\media\Keyboard_Keys_Selected_Text.png", "media\KBK_ST.png", 1)
}

/*@Ahk2Exe-Keep
	RegExMatch(A_AhkPath, "im)(32|64)(?=\.exe$)", &match)
	U_Is64bitExe := match[] = "64"

	If (U_Is64bitExe != A_Is64bitOS) {
		MsgBox("Vous avez la mauvaise variante d'Infinity Desktop !`n`nVotre système d'exploitation est en " (A_Is64bitOS ? "64" : "32") " bits, mais cet exécutable est en " (U_Is64bitExe ? "64" : "32") " bits. Veuillez télécharger la bonne variante pour votre système.`n`nCet avertissement peut aussi apparaître après avoir renommé le fichier .exe. Utilisez un raccourci à la place de renommer ce fichier.`n`n---------------------------------------------`n`nYou have the wrong variant of Infinity Desktop!`n`nYour OS is " (A_Is64bitOS ? "64" : "32") "-bit but this executable is " (U_Is64bitExe ? "64" : "32") "-bit. Please download the right variant for your system.`n`nThis message might also appear because you renamed the .exe file. Use a shortcut instead of renaming this file.", , "Iconx")

		ExitApp
	}
 */

;@Ahk2Exe-IgnoreBegin
CoordMode "ToolTip", "Screen"

Console := Gui("-DPIScale +AlwaysOnTop -Caption -Border")
ConsoleSize := [1200, 30]
Console.BackColor := "FFFFFF"
ConsoleText := Console.Add("Text", "xm ym 0x200 x0 y0 w" ConsoleSize[1] " h" ConsoleSize[2], "Hide")
ConsoleText.SetFont("c000000 s12 q4", "Calibri")

Log(Txt) {
	ConsoleText.Text := Txt
	Console.Show("x0 y0 w" ConsoleSize[1] " h" ConsoleSize[2])
}
;@Ahk2Exe-IgnoreEnd

CoordMode "Mouse", "Screen"

DisableHotkeys()

Loop MonitorGetCount() {
	MonitorGet A_Index, &L, &T, &R, &B
	MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB

	Monitors.Push({
		ID: -1,
		Left: L,
		Top: T,
		Right: R,
		Bottom: B,
		WLeft: WL,
		WTop: WT,
		WRight: WR,
		WBottom: WB,
		CX: (L + R) / 2,
		CY: (T + B) / 2,
		Gui: Gui(),
		Ctrls: Array(),
		Hovered: False,
		Selected: False
	})
}

Monitors := SortArray(Monitors, CompareMonitors)

For Monitor in Monitors {
	Monitor.Gui.Opt("-DPIScale +AlwaysOnTop -Caption -Resize -Border" . (A_Index > 1 ? (" +Owner" Monitors[1].Gui.Hwnd) : ""))
	Monitor.Gui.BackColor := "000000"

	If (Config.Fullscreen) {
		mLeft := Monitor.Left
		mTop := Monitor.Top
		mRight := Monitor.Right
		mBottom := Monitor.Bottom
	} Else {
		mLeft := Monitor.WLeft
		mTop := Monitor.WTop
		mRight := Monitor.WRight
		mBottom := Monitor.WBottom
	}

	mWidth := mRight - mLeft
	mHeight := mBottom - mTop

	Monitor.Ctrls.Push({
			c: Monitor.Gui.Add("Text", "Center xm ym 0x200"),
			x: 0,
			y: 0,
			w: mHeight / 4,
			h: mHeight / 4
		})

	Monitor.Ctrls[1].c.SetFont("s" (Monitor.Ctrls[1].h / 2) * 3 / 4 " w700 q4", "Arial")

	Monitor.Ctrls.Push({
			c: [
				Monitor.Gui.Add("Picture", "BackgroundTrans", "media\KBK_T.png"),
				Monitor.Gui.Add("Picture", "BackgroundTrans", "media\KBK_HT.png"),
				Monitor.Gui.Add("Picture", "BackgroundTrans", "media\KBK_ST.png")
			],
			x: 0,
			y: 0,
			w: mHeight / 16 * (1957 / 104),
			h: mHeight / 16
		})

	For Control in Monitor.Ctrls[2].c {
		Control.Visible := False
	}

	CenterControl(Monitor.Ctrls[1], mLeft, mTop, mRight, mBottom)
	CenterControl(Monitor.Ctrls[2], mLeft, mTop - (mBottom - mTop) * 0.9, mRight, mBottom)

	UpdateControls(Monitor)

	Monitor.Gui.OnEvent("Close", ExitApp)

	Monitor.Gui.Show("x" mLeft " y" mTop " w" mWidth " h" mHeight)
}

MstscList := FindMstscList()
UpdateIDs()
EnableHotkeys()

SetTimer UpdateLoop, 50

OnExit(BeforeExit, 1)

~LButton:: {
	ToggleSelection(HoveredMonitor)
}

Space::
Enter:: {
	StartRemoteDesktop()
}

Backspace::
Delete::
Escape:: {
	ExitApp
}

UpdateLoop() {
	global HoveredMonitor

	MouseGetPos(&MouseX, &MouseY)

	HoverDetermined := False

	For Monitor in Monitors {
		If (!HoverDetermined && MouseX >= Monitor.Left && MouseX <= Monitor.Right && MouseY >= Monitor.Top && MouseY <= Monitor.Bottom) {
			If (!Monitor.Hovered) {
				Monitor.Hovered := True
				Refresh()
			}

			HoveredMonitor := A_Index

			HoverDetermined := True
		} Else {
			If (Monitor.Hovered) {
				Monitor.Hovered := False
				Refresh()
			}
		}
	}

	If (!HoverDetermined) {
		ClosestMonitor := 0
		ClosestDistance := 16777216

		For Monitor in Monitors {
			Center := [(Monitor.Right + Monitor.Left) / 2, (Monitor.Bottom + Monitor.Top) / 2]
			Distance := Dist([MouseX, MouseY], Center)

			If (Distance < ClosestDistance) {
				ClosestMonitor := A_Index
				ClosestDistance := Distance
			}
		}

		For Monitor in Monitors {
			If (A_Index == ClosestMonitor) {
				If (!Monitor.Hovered) {
					Monitor.Hovered := True
					Refresh()
				}

				HoveredMonitor := A_Index

				HoverDetermined := True
			} Else {
				If (Monitor.Hovered) {
					Monitor.Hovered := False
					Refresh()
				}
			}
		}
	}
}

Refresh() {
	For Monitor in Monitors {
		For Control in Monitor.Ctrls[2].c {
			Control.Visible := False
		}

		If (Monitor.Selected) {
			If (Monitor.Hovered) {
				Monitor.Ctrls[1].c.Opt("Background1B2021")
				Monitor.Ctrls[1].c.SetFont("cFFFFFF")
			} Else {
				Monitor.Ctrls[1].c.Opt("BackgroundFFFFFF")
				Monitor.Ctrls[1].c.SetFont("c000000")
			}

			Monitor.Gui.BackColor := "FCCA04"
			Monitor.Ctrls[2].c[3].Visible := True
		} Else {
			If (Monitor.Hovered) {
				Monitor.Gui.BackColor := "1B2021"
				Monitor.Ctrls[1].c.Opt("Background8693AB")
				Monitor.Ctrls[1].c.SetFont("cFAFAFF")
				Monitor.Ctrls[2].c[2].Visible := True
			} Else {
				Monitor.Gui.BackColor := "000000"
				Monitor.Ctrls[1].c.Opt("Background1B2021")
				Monitor.Ctrls[1].c.SetFont("cFAFAFF")
				Monitor.Ctrls[2].c[1].Visible := True
			}
		}

		If (Config.Fullscreen) {
			mLeft := Monitor.Left
			mTop := Monitor.Top
			mRight := Monitor.Right
			mBottom := Monitor.Bottom
		} Else {
			mLeft := Monitor.WLeft
			mTop := Monitor.WTop
			mRight := Monitor.WRight
			mBottom := Monitor.WBottom
		}

		If (Monitor.Hovered) {
			Monitor.Ctrls[1].w := (mBottom - mTop) / 4 + 20
			Monitor.Ctrls[1].h := Monitor.Ctrls[1].w
		} Else {
			Monitor.Ctrls[1].w := (mBottom - mTop) / 4
			Monitor.Ctrls[1].h := Monitor.Ctrls[1].w
		}

		Monitor.Ctrls[1].c.SetFont("s" (Monitor.Ctrls[1].h / 2) * 3 / 4)

		If (Monitor.ID >= 0) {
			Monitor.Ctrls[1].c.Text := Monitor.ID
		} Else {
			Monitor.Ctrls[1].c.Text := ""
		}

		CenterControl(Monitor.Ctrls[1], mLeft, mTop, mRight, mBottom)
		UpdateControl(Monitor.Ctrls[1])
	}
}

ToggleSelection(monitor) {
	If (monitor > 0) {
		If (Monitors[monitor].ID >= 0) {
			Monitors[monitor].Selected := !Monitors[monitor].Selected

			UpdateIDs()
			Refresh()
		}
	}
}

EnableHotkeys() {
	HotKey("~LButton", "On")
	HotKey("Space", "On")
	HotKey("Enter", "On")
}

DisableHotkeys() {
	HotKey("~LButton", "Off")
	HotKey("Space", "Off")
	HotKey("Enter", "Off")
}

CenterControl(ctrl, l, t, r, b) {
	ctrl.x := (r - l - ctrl.w) / 2
	ctrl.y := (b - t - ctrl.h) / 2
}

UpdateControl(ctrl) {
	If (Type(ctrl.c) = "Array") {
		For Control in ctrl.c {
			Control.Move(ctrl.x, ctrl.y, ctrl.w, ctrl.h)
		}
	} Else {
		ctrl.c.Move(ctrl.x, ctrl.y, ctrl.w, ctrl.h)
	}
}

UpdateControls(monitor) {
	For ctrl in monitor.Ctrls {
		UpdateControl(ctrl)
	}
}

UpdateIDs() {
	global SelectedIDs := Array()
	global LastIDs

	For Monitor in Monitors {
		Monitor.ID := MstscList[A_Index]["Index"]

		If (LastIDs.Length > 0 && HasVal(LastIDs, Monitor.ID) > 0) {
			Monitor.Selected := True
		}

		If (Monitor.Selected) {
			SelectedIDs.Push(Monitor.ID)
		}
	}

	LastIDs := Array()
}

CompareMonitors(mon1, mon2) {
	vOffset := mon2.CY - mon1.CY
	hOffset := mon2.CX - mon1.CX

	If (hOffset == 0) {
		Return vOffset
	} Else {
		Return hOffset
	}
}

CompareMstsc(mstsc1, mstsc2) {
	vOffset := (mstsc2["Top"] + mstsc2["Bottom"]) / 2 - (mstsc1["Top"] + mstsc1["Bottom"]) / 2
	hOffset := (mstsc2["Left"] + mstsc2["Right"]) / 2 - (mstsc1["Left"] + mstsc1["Right"]) / 2

	If (hOffset == 0) {
		Return vOffset
	} Else {
		Return hOffset
	}
}

LoadData(filePath) {
	global Config

	Config.Fullscreen := Integer(IniRead(filePath, "Configuration", "Fullscreen", "1"))
	Config.EditConnection := Integer(IniRead(filePath, "Configuration", "EditConnection", "1"))

	global LastIDs := StrSplit(IniRead(filePath, "LocalData", "LastIDs", ""), ",", "`t")
}

SaveData(filePath) {
	IniWrite(String(Config.Fullscreen), filePath, "Configuration", "Fullscreen")
	IniWrite(String(Config.EditConnection), filePath, "Configuration", "EditConnection")

	IniWrite(Join(",", SelectedIDs*), filePath, "LocalData", "LastIDs")
}

BeforeExit(exitReason, exitCode) {
	SaveData("config.ini")
	RestoreSystemSound("SystemAsterisk")
}

SetRDPMultimon(filePath, value) {
	RDPText := FileRead(filePath)

	If (RegExMatch(RDPText, "im)(?<=use\smultimon:i:).*$") > 0) {
		RDPText := RegExReplace(RDPText, "im)(?<=use\smultimon:i:).*$", String(value))
	} Else {
		RDPText .= "use multimon:i:" value "`n"
	}

	RDPFile := FileOpen(filePath, "w")
	RDPFile.Write(RDPText)
	RDPFile.Close()
}

SetRDPSelectedMonitors(filePath, IDs) {
	RDPText := FileRead(filePath)

	If (RegExMatch(RDPText, "im)^selectedmonitors:s:.*$") > 0) {
		RDPText := RegExReplace(RDPText, "im)(?<=selectedmonitors:s:).*$", Join(",", IDs*))
	} Else {
		RDPText .= "selectedmonitors:s:" Join(",", IDs*) "`n"
	}

	RDPFile := FileOpen(filePath, "w")
	RDPFile.Write(RDPText)
	RDPFile.Close()
}

FindMstscList() {
	DisableSystemSound("SystemAsterisk")

	DllCall("Shell32\SHChangeNotify", "UInt", 0x08000000, "UInt", 0, "Int", 0, "Int", 0)

	RunWait("PowerShell.exe -ExecutionPolicy Bypass -Command .\mstscReader.ps1", A_WorkingDir, "Hide")

	MstscText := FileRead("mstscMonitors.json")
	Return SortArray(Jxon_Load(&MstscText), CompareMstsc)
}

StartRemoteDesktop() {
	SetRDPMultimon("custom.rdp", 1)
	SetRDPSelectedMonitors("custom.rdp", SelectedIDs)

	Parameters := Config.EditConnection ? "/edit " : ""

	Run('mstsc.exe ' Parameters '"' A_WorkingDir '\custom.rdp"')

	ExitApp
}