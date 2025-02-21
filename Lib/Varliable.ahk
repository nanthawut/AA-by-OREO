#Requires AutoHotkey v2.0

hotKeySetting := [
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'
]
logName := ['Form']
successfulCoordinates := []
firstplace := []
inChallengeMode := false
Wins := 0
loss := 0
slotU := ['1', '2', '3', '4', '5', '6']
placeSpeed := ["2.25 sec", "2 sec", "2.5 sec", "2.75 sec", "3 sec"]
placeTpye := ["Random", "Grid", "Circle", "Spiral", "Up and Down"]
menuTooltip := "Hi! Click me!! `nF1 Process `nF2 Start Mode `nF3 Reload `nF4 Pause"
mAr := {
    mode: ["Story", "Legend", "Raid", "Infinity_Castle", "Contract", "Cursed_Womb", "Portal", "Winter_Event",
        "Challenge"],
    Story: [
        ["Planet Greenie", "Walled City", "Snowy Town", "Sand Village", "Navy Bay", "Fiend City", "Spirit World",
            "Ant Kingdom", "Magic Town", "Haunted Academy", "Magic Hills", "Space Center", "Alien Spaceship",
            "Fabled Kingdom", "Ruined City", "Puppet Island", "Virtual Dungeon", "Snowy Kingdom", "Dungeon Throne",
            "Mountain Temple", "Rain Village"],
        ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinity"]
    ],
    Legend: [
        ["Magic Hills", "Space Center", "Fabled Kingdom", "Virtual Dungeon", "Dungeon Throne", "Rain Village"],
        ["Act 1", "Act 2", "Act 3"]
    ],
    Raid: [
        ["The Spider", "Sacred Planet", "Strange Town", "Ruined City"],
        ["Act 1", "Act 2", "Act 3", "Act 4", "Act 5"]
    ],
    Infinity_Castle: ["Normal", "Hard"],
    Contract: [
        ["Page 1", "Page 2", "Page 3", "Page 4", "Page 5", "Page 6", "Page 4-5"],
        ["Creating", "Joining", "Matchmaking", "Solo"]
    ],
    Portal: [
        ["Alien Portal", "Puppet Portal", "Demon Leader's Portal", "Eclipse Portal", "Noble Portal"],
        ["Creating", "Joining"]
    ]
}
rblxID := "ahk_exe RobloxPlayerBeta.exe"
pathCongif := A_ScriptDir "\Config\Setting.ini"
pathLog := A_ScriptDir "\Log.ini"