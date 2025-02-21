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
    Hotkey(hotKeySetting[1], (*) => RestartStage())
    Hotkey(hotKeySetting[2], (*) => StartSelectedMode())
    Hotkey(hotKeySetting[3], (*) => Reload())
    Hotkey(hotKeySetting[4], (*) => TogglePause())
    return
}

RegisterHotkey()
loadSetting()

StartSelectedMode() {
    GetForm()
    moveRobloxWindow()
    ClickUntilGone(0, 0, xlistplayer, 1000, -1, -35)
    ClickUntilGone(0, 0, xClose, 1000, -1, -35)

    if (i.AutoChallenge) {
        AddLog("Auto Challenge enabled - starting with challenge")
        inChallengeMode := true
        firstStartup := false
        challengeStartTime := A_TickCount  ; Set initial challenge time
    }
    
    MoveTo()
    while !(IFindText(ModeCancel) || IFindText(JoinMatchmaking)) {
        MoveTo()
    }

    AddLog("Starting " i.Map " - " i.Type)
}
