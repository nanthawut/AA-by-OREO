#Requires AutoHotkey v2.0
#Include OCR-main\Lib\OCR.ahk

OnExit ExitFunc

CheckDir() {
    if !DirExist(A_ScriptDir "\Config")
        DirCreate(A_ScriptDir "\Config")
}

ResetStoragePlay() {
    global successfulCoordinates, firstplace, unitBuff, buffTime
    successfulCoordinates := []
    firstplace := []
    unitBuff := []
    buffTime := 0
}

TogglePause(*) {
    Pause -1
    if (A_IsPaused) {
        AddLog("Macro Paused")
        Sleep(1000)
    } else {
        AddLog("Macro Resumed")
        moveRobloxWindow()
        Sleep(1000)
    }
}

PlacementSpeed() {
    GetForm()
    if i.PlaceSpeed = "2.25 sec" {
        return 2250
    }
    else if i.PlaceSpeed = "2 sec" {
        return 2000
    }
    else if i.PlaceSpeed = "2.5 sec" {
        return 2500
    }
    else if i.PlaceSpeed = "2.75 sec" {
        return 2.75
    }
    else if i.PlaceSpeed = "3 sec" {
        return 3000
    }
}

GetForm() {
    global i := eq.Submit()
    global card := PCS.Submit()
}

saveSetting() {
    myform := eq.Submit(0)
    for key, value in myform.OwnProps() {
        IniWrite value, pathCongif, logName[1], key
    }

    for id, value IN PCS.Submit().OwnProps() {
        if (value != '')
            IniWrite value, pathCongif, logName[2], id
    }
}

loadSetting() {
    formLoad := [eq, PCS]
    for index, form in formLoad
        for hwnd, item in form {
            if (Type(item) = "Gui.Checkbox" && item.Name) {
                try {
                    readed := IniRead(pathCongif, logName[index], item.Name)
                    item.Value := Integer(readed)
                }
            } else if Type(item) = "Gui.DDL" && item.Name {
                try {
                    readed := IniRead(pathCongif, logName[index], item.Name)
                    item.Text := readed
                }
            }
        }
    ModeChange()
}

ExitFunc(ExitReason, ExitCode) {
    saveSetting()
}

IClick(x, y, time := 50, LR := "Left") {
    WinActivate(rblxID)
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    MouseClick(LR, -1, 0, , , , "R")
    Sleep(time)
}

Process := ["", "", "", "", "", "", ""]

AddLog(Text) {
    Process[7] := StrReplace(Process[6], "➤ ", "")
    Process[6] := StrReplace(Process[5], "➤ ", "")
    Process[5] := StrReplace(Process[4], "➤ ", "")
    Process[4] := StrReplace(Process[3], "➤ ", "")
    Process[3] := StrReplace(Process[2], "➤ ", "")
    Process[2] := StrReplace(Process[1], "➤ ", "")
    Process[1] := "➤ " . text
    textTool := ""
    for id, value IN Process {
        textTool .= value '`n'
    }
    ToolTip(textTool, 800, 50)
    IniWrite(Text, pathLog, FormatTime(A_Now, 'MM/dd/yyyy'), FormatTime(A_Now, "'H'HH'M'mm'S'ss"))
}

ClickUntilGone(x, y, textToFind, time := 100, offsetX := 0, offsetY := 0,
    textToFind2 := "") {
    WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, rblxID)
    while (ok := FindText(&X, &Y, OutX, OutY, OutWidth + OutX, OutHeight + OutY, 0, 0, textToFind) ||
    textToFind2 && ok := FindText(&X, &Y, OutX, OutY, OutWidth + OutX, OutHeight + OutY, 0, 0, textToFind2)) {
        if (offsetX != 0 || offsetY != 0) {
            if (offsetX = -1) {
                calX := ok[1].1
                calY := ok[1].2 - (ok[1].4 * 2)
                IClick(calX, calY)
            } else {
                IClick(X + offsetX, Y + offsetY)
            }
        } else {
            IClick(x, y)
        }
        Sleep time
    }
}

IFindText(Text, time := 0) {
    tick := A_TickCount
    loop {
        WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, rblxID)
        ok := FindText(&X, &Y, OutX, OutY, OutWidth + OutX, OutHeight + OutY, 0, 0, Text)
        if (A_TickCount - tick > time || ok)
            return ok
    }
    return ok
}

sizeDown() {

    if !WinExist(rblxID)
        return

    WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)

    ; Exit fullscreen if needed
    if (OutWidth >= A_ScreenWidth && OutHeight >= A_ScreenHeight) {
        Send "{F11}"
        Sleep(100)
    }

    ; Force the window size and retry if needed
    loop 3 {
        WinMove(X, Y, 816, 638, rblxID)
        Sleep(100)
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth == 816 && OutHeight == 638)
            break
    }
}

moveRobloxWindow() {

    if !WinExist(rblxID) {
        AddLog("Waiting for Roblox window...")
        return
    }
    ; First ensure correct size
    sizeDown()

    ; Then move relative to main UI
    WinMove(0, 1, , , rblxID)
    WinActivate(rblxID)
}

forceRobloxSize() {
    if !WinExist(rblxID) {
        checkCount := 0
        while !WinExist(rblxID) {
            Sleep(5000)
            if (checkCount >= 5) {
                AddLog("Attempting to locate the Roblox window")
            }
            checkCount += 1
            if (checkCount > 12) { ; Give up after 1 minute
                AddLog("Could not find Roblox window")
                return
            }
        }
        AddLog("Found Roblox window")
    }

    WinActivate(rblxID)
    sizeDown()
    moveRobloxWindow()
}

checkRobloxSize() {
    if WinExist(rblxID) {
        WinGetPos(&X, &Y, &OutWidth, &OutHeight, rblxID)
        if (OutWidth != 816 || OutHeight != 638) {
            sizeDown()
            moveRobloxWindow()
        }
    }
}

FormatStageTime(ms) {
    seconds := Floor(ms / 1000)
    minutes := Floor(seconds / 60)
    hours := Floor(minutes / 60)

    minutes := Mod(minutes, 60)
    seconds := Mod(seconds, 60)

    return Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
}

GetWindowCenter(WinTitle) {
    x := 0 y := 0 Width := 0 Height := 0
    WinGetPos(&X, &Y, &Width, &Height, WinTitle)

    centerX := X + (Width / 2)
    centerY := Y + (Height / 2)

    return { x: centerX, y: centerY, width: Width, height: Height }
}

IsColorInRange(color, targetColor, tolerance := 50) {
    ; Extract RGB components
    r1 := (color >> 16) & 0xFF
    g1 := (color >> 8) & 0xFF
    b1 := color & 0xFF

    ; Extract target RGB components
    r2 := (targetColor >> 16) & 0xFF
    g2 := (targetColor >> 8) & 0xFF
    b2 := targetColor & 0xFF

    ; Check if within tolerance range
    return Abs(r1 - r2) <= tolerance
    && Abs(g1 - g2) <= tolerance
    && Abs(b1 - b2) <= tolerance
}
