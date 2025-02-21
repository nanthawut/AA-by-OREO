#Requires AutoHotkey v2.0
#Include OCR-main\Lib\OCR.ahk

OnExit ExitFunc

CheckDir() {
    if !DirExist(A_ScriptDir "\Config")
        DirCreate(A_ScriptDir "\Config")
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

saveSetting() {
    myform := eq.Submit(0)
    for key, value in myform.OwnProps() {
        IniWrite value, pathCongif, logName[1], key
    }
}

loadSetting() {
    for hwnd, item in eq {

        if (Type(item) = "Gui.Checkbox" && item.Name) {
            try {
                readed := IniRead(pathCongif, logName[1], item.Name)
                item.Value := Integer(readed)
            }
        } else if Type(item) = "Gui.DDL" && item.Name {
            try {
                readed := IniRead(pathCongif, logName[1], item.Name)
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

FindMatch() {
    startTime := A_TickCount

    loop {
        if (A_TickCount - startTime > 50000) {
            AddLog("Matchmaking timeout, restarting mode")
            IClick(400, 520)
            return StartSelectedMode()
        }

        IClick(400, 435)  ; Play Here or Find Match
        Sleep(300)
        IClick(460, 330)  ; Click Find Match
        Sleep(300)

        ; Try captcha
        if (!CaptchaDetect(252, 292, 300, 50, 400, 335)) {
            AddLog("Captcha not detected, retrying...")
            IClick(585, 190)  ; Click close
            Sleep(1000)
            continue
        }
        IClick(300, 385)  ; Enter captcha
        return true
    }
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
    IniWrite(Text, pathLog, FormatTime(A_Now, 'MM/dd/yyyy'), FormatTime(A_Now, 'MM/dd/yyyy HH:mm:ss'))
}

CaptchaDetect(x, y, w, h, inputX, inputY) {
    detectionCount := 0
    AddLog("Checking for numbers...")
    loop 10 {
        try {
            result := OCR.FromRect(x, y, w, h, "FirstFromAvailableLanguages", {
                grayscale: true,
                scale: 2.0
            })

            if result {
                ; Get text before any linebreak
                number := StrSplit(result.Text, "`n")[1]

                ; Clean to just get numbers
                number := RegExReplace(number, "[^\d]")

                if (StrLen(number) >= 5 && StrLen(number) <= 7) {
                    detectionCount++

                    if (detectionCount >= 1) {
                        ; Send exactly what we detected in the green text
                        IClick(inputX, inputY)
                        Sleep(300)

                        AddLog("Sending number: " number)
                        SendInput(number)
                        Sleep(200)
                        return true
                    }
                }
            }
        }
        Sleep(200)
    }
    AddLog("Could not detect valid captcha")
    return false
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

IFindText(Text) {
    WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, rblxID)
    ok := FindText(&X, &Y, OutX, OutY, OutWidth + OutX, OutHeight + OutY, 0, 0, Text)
    return ok
}

MoveTo(i) {

    switch i {
        case "Story", "Legend":
            IClick(85, 295)
            sleep (1000)
            SendInput ("{w down}")
            Sleep(300)
            SendInput ("{w up}")
            Sleep(300)
            SendInput ("{d down}")
            SendInput ("{w down}")
            Sleep(4500)
            SendInput ("{d up}")
            SendInput ("{w up}")
            Sleep(500)
        case "Challenge":
            IClick(765, 475, 500)
            IClick(300, 415)
            SendInput ("{a down}")
            sleep (7000)
            SendInput ("{a up}")
        case "Raid":
            IClick(765, 475, 300) ; Click Area
            IClick(495, 410, 500)
            SendInput ("{a down}")
            Sleep(400)
            SendInput ("{a up}")
            Sleep(500)
            SendInput ("{w down}")
            Sleep(5000)
            SendInput ("{w up}")
        case "Infinity_Castle":
            IClick(765, 475, 300)
            IClick(370, 330, 500)
            SendInput ("{w down}")
            Sleep (500)
            SendInput ("{w up}")
            Sleep (500)
            SendInput ("{a down}")
            sleep (4000)
            SendInput ("{a up}")
            Sleep (500)
        case "Cursed_Womb":
            IClick(85, 295, 500)
            SendInput ("{a down}")
            sleep (3000)
            SendInput ("{a up}")
            sleep (1000)
            SendInput ("{s down}")
            sleep (4000)
            SendInput ("{s up}")
        case "Winter_Event":
            IClick(592, 204, 200) ; Close Matchmaking UI (Just in case)
            IClick(85, 295, 1000) ; Click Play
            SendInput ("{a up}")
            Sleep 100
            SendInput ("{a down}")
            Sleep 6000
            SendInput ("{a up}")
            KeyWait "a" ; Wait for "d" to be fully processed
            Sleep 1200
    }

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
