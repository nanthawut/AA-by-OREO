#Requires AutoHotkey v2.0

hotKeySetting := [
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'
]
logName :=['Form']
slotU := ['1', '2', '3', '4', '5', '6']
menuTooltip := "F1 Process `nF2 Start Mode `nF3 Reload `nF4 Pause"
mAr := {
    mode: ["Story", "Legend", "Raid", "Infinity_Castle", "Contract", "Cursed_Womb", "Portal", "Winter_Event"],
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

pathCongif := A_ScriptDir "\Config\Setting.ini"