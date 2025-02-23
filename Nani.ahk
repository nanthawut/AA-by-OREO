#Requires AutoHotkey v2.0.18+
#SingleInstance Force
#Include Lib\FindText.ahk
#Include Lib\SorryBabe.ahk
#Include Lib\Varliable.ahk
#Include Lib\GUI.ahk
#Include Lib\Fuction.ahk
#Include Lib\InPlay.ahk
#Include Lib\Lobby.ahk

SendMode('Event')

RegisterHotkey() {
    Hotkey(hotKeySetting[1], (*) => toggleEQ())
    Hotkey(hotKeySetting[2], (*) => StartSelectedMode())
    Hotkey(hotKeySetting[3], (*) => Reload())
    Hotkey(hotKeySetting[4], (*) => TogglePause())
    Hotkey(hotKeySetting[5], (*) => toggleProg())
    Hotkey(hotKeySetting[6], (*) => tester())
    return
}

RegisterHotkey()
loadSetting()
ModeChange()
loadSetting()
ProG.Show('x' A_ScreenWidth - 400 ' y' 45)
tester() {
    
    PlacingUnits(1, [1, 2, 3, 4])
}

StartSelectedMode() {
    GetForm()
    moveRobloxWindow()
    if (!IFindText(summon)) {
        RestartStage()
    }
    ClickUntilGone(0, 0, xlistplayer, 1000, -1, -35)
    ClickUntilGone(0, 0, xClose, 1000, -1, -35)
    if (i.AutoChallenge) {
        AddLog("Auto Challenge enabled - starting with challenge")

        if (GetChallengeReady() < 0) {
            global challengeReady := true
            AddLog("Time to Challenge")
        } else {
            AddLog("Next Challenge " GetChallengeReady() "Min")
            global challengeReady := false
        }
    }

    if (i.Mode = "Portal") {
        if (i.Type = "Creating") {

            IClick(33, 300, 1500)
            IClick(435, 230, 1500)
            IClick(510, 190, 1500)
            SendInput(i.Map)
            Sleep(1500)

            AddLog("Creating " i.Map)
            IClick(215, 285, 1500)
            if (ok := IFindText(UsePortal)) {
                IClick(ok[1].x - 20, ok[1].y - 20)
            }
            Sleep (1500)
            IClick(250, 350)  ; Click On Open
            AddLog("Waiting 15 seconds for others to join")
            ; Sleep(15000)
            IClick(400, 460)  ; Start portal
        } else {
            AddLog("Please join " i.Map " manually")
        }
    } else if (i.Mode = "Contract") {
        IClick(33, 400)
        Sleep(2500)
        HandleContractJoin()
        Sleep(2500)
        RestartStage()
    }

    MoveTo()
    while !(IFindText(ModeCancel) || IFindText(JoinMatchmaking)) {
        MoveTo()
    }
    if (i.Mode = "Infinity_Castle") {

        ; Get current difficulty
        currentDifficulty := i.Map
        AddLog("Starting Infinity Castle - " currentDifficulty)

        ; Select difficulty with direct clicks
        if (currentDifficulty = "Normal") {
            IClick(418, 375)  ; Click Easy Mode
        } else {
            IClick(485, 375)  ; Click Hard Mode
        }
        ClickUntilGone(0, 0, ModeCancel, , -10, -120)

        RestartStage()
    }
    if (i.Mode = 'Winter_Event') {
        AddLog("Starting Winter Event")
    } else {
        AddLog("Starting " i.Map " - " i.Type)
    }

    SelectMenu()

    if (i.Map != "Infinity") {
        PlayHere()  ; Always PlayHere for normal story acts
    } else {
        if (i.MatchMaking) {
            FindMatch()
        } else {
            PlayHere()
        }
    }

    RestartStage()

}
