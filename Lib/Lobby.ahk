#Requires AutoHotkey v2.0


HandleContractJoin() {

    ; Handle 4-5 Page pattern selection
    if (selectedPage = "Page 4-5") {
        selectedPage := GetContractPage()
        AddLog("Pattern selected: " selectedPage)
    }

    pageNum := selectedPage = "Page 4-5" ? GetContractPage() : selectedPage
    pageNum := Integer(RegExReplace(RegExReplace(pageNum, "Page\s*", ""), "-.*", ""))

    ; Define click coordinates for each page
    clickCoords := Map(
        1, { openHere: { x: 170, y: 420 }, matchmaking: { x: 240, y: 420 } },  ; Example coords for page 1
        2, { openHere: { x: 330, y: 420 }, matchmaking: { x: 400, y: 420 } },  ; Example coords for page 2
        3, { openHere: { x: 490, y: 420 }, matchmaking: { x: 560, y: 420 } }, ; Example coords for page 3
        4, { openHere: { x: 237, y: 420 }, matchmaking: { x: 305, y: 420 } },  ; Example coords for page 4
        5, { openHere: { x: 397, y: 420 }, matchmaking: { x: 465, y: 420 } },  ; Example coords for page 5
        6, { openHere: { x: 557, y: 420 }, matchmaking: { x: 625, y: 420 } }  ; Example coords for page 6
    )

    ; First scroll if needed for pages 4-6
    if (pageNum >= 4) {
        IClick(445, 300)
        Sleep(200)
        loop 5 {
            SendInput("{WheelDown}")
            Sleep(150)
        }
        Sleep(300)
    }

    ; Get coordinates for the selected page
    pageCoords := clickCoords[pageNum]

    ; Handle different join types
    if (i.Type = "Creating") {
        AddLog("Creating contract portal on page " pageNum)
        IClick(pageCoords.openHere.x, pageCoords.openHere.y)
        Sleep(300)
        IClick(255, 355)
        Sleep(20000)
        AddLog("Waiting 20 seconds for others to join")
        IClick(400, 460)
    } else if (i.Type = "Joining") {
        AddLog("Attempting to join by holding E")
        SendInput("{e down}")
        Sleep(5000)
        SendInput("{e up}")
    } else if (i.Type = "Solo") {
        AddLog("Attempting to start solo")
        IClick(pageCoords.openHere.x, pageCoords.openHere.y)
        Sleep(300)
        IClick(255, 355)
        Sleep 300
        IClick(400, 468) ; Start Contract
    } else if (i.Type = "Matchmaking") {
        AddLog("Joining matchmaking for contract on page " pageNum)
        IClick(pageCoords.matchmaking.x, pageCoords.matchmaking.y)  ; Click matchmaking button
        Sleep(300)

        ; Try captcha
        if (!CaptchaDetect(252, 292, 300, 50, 400, 335)) {
            AddLog("Captcha not detected, retrying...")
            IClick(585, 190)  ; Click close
            return
        }
        IClick(300, 385)  ; Enter captcha

        startTime := A_TickCount
        while (A_TickCount - startTime < 20000) {  ; Check for 20 seconds
            if !(IFindText(AreaText)) {
                AddLog("Area text gone - matchmaking successful")
                return true
            }
            Sleep(200)  ; Check every 200ms
        }

        AddLog("Matchmaking failed - still on area screen after 20s, retrying...")
        IClick(445, 220)
        Sleep(1000)
        loop 5 {
            SendInput("{WheelUp}")
            Sleep(150)
        }
        Sleep(1000)
        return HandleContractJoin()
    }

    AddLog("Joining Contract Mode")
    return true
}

MoveTo() {
    AddLog("Moving to position for " i.Mode)
    switch i.Mode {
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
            IClick(592, 204, 200) 
            IClick(85, 295, 1000)
            SendInput ("{a up}")
            Sleep 100
            SendInput ("{a down}")
            Sleep 6000
            SendInput ("{a up}")
            KeyWait "a"
            Sleep 1200
    }

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