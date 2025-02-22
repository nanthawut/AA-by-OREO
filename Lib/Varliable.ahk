#Requires AutoHotkey v2.0

hotKeySetting := [
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'
]
logName := ['Form', 'Card']
successfulCoordinates := []
firstplace := []
inChallengeMode := false
challengeReady := false
Wins := 0
loss := 0
unitBuff := []
buffTime := 0
slotU := ['1', '2', '3', '4', '5', '6']
i := Map()
placeSpeed := ["2.25 sec", "1.5 sec", "2 sec", "2.5 sec", "2.75 sec", "3 sec"]
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

GetCountMode := {
    Map: {
        Story: {
            Planet_Greenie: 2,
            Walled_City: 3,
            Snowy_Town: 4,
            Sand_Village: 5,
            Navy_Bay: 6,
            Fiend_City: 7,
            Spirit_World: 8,
            Ant_Kingdom: 9,
            Magic_Town: 10,
            Haunted_Academy: 11,
            Magic_Hills: 12,
            Space_Center: 13,
            Alien_Spaceship: 14,
            Fabled_Kingdom: 15,
            Ruined_City: 16,
            Puppet_Island: 17,
            Virtual_Dungeon: 18,
            Snowy_Kingdom: 19,
            Dungeon_Throne: 20,
            Mountain_Temple: 21,
            Rain_Village: 22,
        },
        Legend: {
            The_Spider: 1,
            Sacred_Planet: 2,
            Strange_Town: 3,
            Ruined_City: 4
        },
        Raid: {
            Magic_Hills: 1,
            Space_Center: 3,
            Fabled_Kingdom: 4,
            Virtual_Dungeon: 6,
            Dungeon_Throne: 7,
            Rain_Village: 8,
        }
    },
    Story: {
        Infinity: 1,
        Act_1: 2,
        Act_2: 3,
        Act_3: 4,
        Act_4: 5,
        Act_5: 6,
        Act_6: 7
    },
    Legend: {
        Act_1: 1,
        Act_2: 2,
        Act_3: 3
    },
    Raid: {
        Act_1: 1,
        Act_2: 2,
        Act_3: 3,
        Act_4: 4,
        Act_5: 5
    }
}

rblxID := "ahk_exe RobloxPlayerBeta.exe"
pathCongif := A_ScriptDir "\Config\Setting.ini"
pathLog := A_ScriptDir "\Log.ini"