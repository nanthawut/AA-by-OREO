#Requires AutoHotkey v2.0

PlacingUnits(state?, wSlot := [1, 2, 3, 4, 5, 6]) {
    global tempPlace
    GetForm()
    pointCounts := Map()

    placementPoints := i.PlaceType = "Circle" ? GenerateCirclePoints() : i.PlaceType =
        "Grid" ? GenerateGridPoints() : i.PlaceType = "Spiral" ? GenerateMoreGridPoints(5) :
            i.PlaceType = "Up and Down" ? GenerateUpandDownPoints() : GenerateRandomPoints()
    slotNumCheck := 0
    ; Go through each slot
    tempPlace := []
    for slotNum in wSlot {
        ; Get number of placements wanted for this slot
        placements := i.%'Placement' slotNum%
        maxUnit := i.%'maxUnit' slotNum%
        placedCounts := 0
        for placed in successfulCoordinates {
            if (placed.slot = slotNum)
                placedCounts++
        }
        if CheckForXp()
            return MonitorStage()
        placements := state = 1 ? Integer(placements) : Integer(maxUnit) - placedCounts
        ; If enabled, place all units for this slot
        if (placements > 0) {

            ; Place all units for this slot
            while (placedCounts < placements) {
                if (slotNum = 6) {
                    SendInput(slotNum)
                    Sleep 1000
                    WinGetClientPos(&OutX, &OutY, &OutWidth, &OutHeight, rblxID)
                    width := OutWidth + OutX
                    height := OutHeight + OutY
                    if (ok := FindText(&X, &Y, OutX + 70, OutY + 100, width - 70, height - 80, 0, 0,
                        green)) {
                        val := false
                        for v in ok {
                            if (width / 2) + 100 < v.x || v.x < (width / 2) - 100 && (height / 2) - 100 > v.y || v.y >
                            (height / 2) +
                            100 {
                                val := v
                                break
                            }
                        }
                        if (val)
                            placementPoints := [{ x: val.x + 15, y: val.y + 15 }]
                    } else {
                        placementPoints := GenerateMoreGridPoints(5)
                    }
                    SendInput('q')
                }
                pointplacecount := 6
                for point in placementPoints {

                    ; CheckAbility()
                    strPoint := "" point.x point.y

                    ; Skip if this coordinate was already used successfully
                    alreadyUsed := false
                    for coord in successfulCoordinates {
                        if (coord.x = point.x && coord.y = point.y) {
                            alreadyUsed := true
                            break
                        }
                    }
                    if (pointCounts.Count >= placementPoints.Length) {
                        placementPoints := GenerateMoreGridPoints(pointplacecount)
                        pointplacecount++
                        pointCounts.Clear()
                        if (slotNumCheck = slotNum) {
                        } else {
                            slotNumCheck := slotNum
                        }
                    }

                    if !pointCounts.Has(strPoint)
                        pointCounts[strPoint] := 0

                    if (alreadyUsed || pointCounts[strPoint] > 0)
                        continue
                    if CheckForXp()
                        return MonitorStage()
                    CheckEndAndRoute()
                    CheckForCardSelection()
                    pointCounts[strPoint]++

                    SendInput(slotNum)
                    Sleep 50
                    MouseMove(point.x, point.y)
                    Sleep 500
                    pressQ := false
                    if (ok := FindText(&X, &Y, point.x, point.y, , , 0, 0,
                        canPlace, , , , 30, 30)) {
                        FindText().RangeTip(ok[1].1, ok[1].2, ok[1].3, ok[1].4, (A_Index & 1 ? "Red" : "Blue"),
                        2)

                        placeTime := A_TickCount
                        loop {
                            CheckForCardSelection()
                            SendInput(slotNum)
                            Sleep 500
                            if (!IFindText(AutoOff)) {
                                IClick(point.x, point.y, 0)
                            }
                            SendInput("q")
                            Sleep 50
                            if (ok := IFindText(UpgradeText)) {
                                successfulCoordinates.Push({ x: point.x, y: point.y, slot: slotNum,
                                    maxLevel: CheckAbility(point.x, point.y) })
                                AddLog("Unit Placed Successfully")
                                placedCounts++
                                AddLog("Placed Unit " slotNum " (" placedCounts "/" placements ")")
                                SendInput("q")
                                IClick(560, 560) ; Move Click

                                break
                            }
                            SendInput("q")
                            if (A_TickCount - placeTime > 5000) {
                                break
                            }
                        }
                        break
                    }
                }
                if (placedCounts = placements)
                    break

            }
            Reconnect()
            if (i.UpgradeDuring) {
                UpgradeUnits(2, true)
            }
        }

    }

    AddLog("All units placed to requested amounts")
    UpgradeUnits(state, false)
}

UpgradeUnits(state, oneTick) {
    global successfulCoordinates
    GetForm()
    totalUnits := Map()
    upgradedCount := Map()
    hasSuccessAll := true
    for coord in successfulCoordinates {
        if (!coord.maxLevel) {
            hasSuccessAll := false
        }
        ; Initialize counters
        if (!totalUnits.Has(coord.slot)) {
            totalUnits[coord.slot] := 0
            upgradedCount[coord.slot] := 0
        }
        totalUnits[coord.slot]++
    }

    if (hasSuccessAll)
        return

    for priorityNum in [1, 2, 3, 4, 5, 6] {
        ; Find which slot has this priority number
        loop {
            unitFinish := true
            for index, coord in successfulCoordinates {
                tPrority := 'Priority' coord.slot
                if (i.%tPrority% = priorityNum) {

                    if CheckForXp() {
                        AddLog("Stage ended during upgrades, proceeding to results")
                        successfulCoordinates := []
                        return
                    }
                    Reconnect()
                    CheckEndAndRoute()

                    if (!coord.maxLevel) {
                        CheckForCardSelection()
                        ; CheckAbility()
                        UpgradeUnit(coord.x, coord.y)
                        unitFinish := false
                        if MaxUpgrade() {
                            upgradedCount[coord.slot]++
                            AddLog("Max upgrade reached for Unit " coord.slot " (" upgradedCount[coord.slot
                                ] "/" totalUnits[coord.slot] ")")
                            successfulCoordinates[index].maxLevel := true
                            ; Sleep (100)
                            IClick(325, 185) ;Close upg menu
                            if (oneTick)
                                return

                            break
                        }
                        if (oneTick) {
                            IClick(560, 560)
                            return
                        }

                        IClick(560, 560) ; Move Click
                        Reconnect()
                        CheckEndAndRoute()
                        if (!i.SwitchUpgrade) {
                            break
                        }
                    }
                }
            }
            if unitFinish {
                break

            }
        }
    }
    if (state = 0) {
        AddLog("Priority upgrading completed")
    }
    return
}

RestartStage() {
    GetForm()
    moveRobloxWindow()
    if (challengeReady || i.Mode = "Challenge")
        global inChallengeMode := true
    currentMap := DetectMap()

    ; Wait for loading
    CheckLoaded()

    ; Do initial setup and map-specific movement during vote timer
    BasicSetup()
    if (currentMap != "no map found") {
        HandleMapMovement(currentMap, i)
    }

    ; Wait for game to actually start
    StartedGame()
    Sleep 1000
    ; Begin unit placement and management
    loop 6 {
        txt := 'Enable' A_Index
        txt := i.%txt%
        if (txt) {
            firstplace.Push(A_Index)
        }
    }
    PlacingUnits(1, firstplace)
    PlacingUnits("l")
    loop 3 {
        for value IN successfulCoordinates
            value.levelMax := false
    }

    ; Monitor stage progress
    MonitorStage()
}

MonitorEndScreen() {
    global inChallengeMode
    lastResult := ''
    ResetStoragePlay()
    loop {
        if (IFindText(itemrecive)) {
            ClickUntilGone(560, 560, itemrecive, , -1, 0)
        }

        IClick(560, 560)

        if (IFindText(UnitExit)) {
            ClickUntilGone(0, 0, UnitExit, 500, -1, -35)
        }

        if (IFindText(NextText)) {
            ClickUntilGone(0, 0, NextText, 500, -1, -40)
        }

        ; Now handle each mode
        if (IFindText(LobbyText)) {
            AddLog("Found Lobby Text - Current Mode: " (inChallengeMode ? "Challenge" : i.Mode))
            Sleep(2000)

            ; Challenge mode logic first
            if (inChallengeMode) {
                if (GetChallengeReady() < 0) {
                    AddLog("30 minutes passed - switching to Challenge mode")
                }
                AddLog("Challenge completed - returning to " i.Mode " mode")
                inChallengeMode := false
                challengeStartTime := A_TickCount
                ClickUntilGone(0, 0, LobbyText, , 0, -35)
                return CheckLobby()
            }

            ; Check if it's time for challenge mode
            if (!inChallengeMode && i.AutoChallenge) {
                try {
                    if (GetChallengeReady() < 0) {
                        AddLog("30 minutes passed - switching to Challenge mode")
                    }
                }
                inChallengeMode := false
                ClickUntilGone(0, 0, LobbyText, , 0, -35)
                return CheckLobby()
            }

            if (i.Mode = "Portal") {
                if (i.Type = "Creating") {
                    IClick(485, 120, 1500) ;Select New Portal
                    IClick(510, 190, 1500) ; Click search
                    SendInput(i.Map)
                    IClick(215, 285, 1500)  ; Click On Portal
                    if (ok := IFindText(selectText)) {
                        IClick(ok[1].x - 20, ok[1].y - 20)
                    }
                } else {
                    AddLog("Waiting for next portal")
                }
                return RestartStage()
            }
            if (i.Mode = "Contract") {
                if (i.LobbyReturn) {
                    AddLog("Contract complete - returning to lobby")
                    Sleep(1500)
                    ClickUntilGone(0, 0, LobbyText, 0, -35)
                    CheckLobby()
                    return StartSelectedMode()
                } else {
                    AddLog("Starting next contract")
                    Sleep(1500)
                    ClickUntilGone(0, 0, LobbyText, +120, -35)
                    return HandleNextContract()
                }
            }

            if (i.Mode = "Story") {
                AddLog("Handling Story mode end")
                if (i.Map != "Infinity") {
                    if (i.NextLevel && lastResult = "win") {
                        AddLog("Next level")
                        ClickUntilGone(0, 0, LobbyText, , +260, -35)
                    } else {
                        AddLog("Replay level")
                        ClickUntilGone(0, 0, LobbyText, , +120, -35)
                    }
                } else {
                    AddLog("Story Infinity replay")
                    ClickUntilGone(0, 0, LobbyText, , +120, -35)
                }
                return RestartStage()
            }
            else if (i.Mode = "Raid") {
                AddLog("Handling Raid end")
                if (i.LobbyReturn) {
                    AddLog("Return to lobby")
                    ClickUntilGone(0, 0, LobbyText, , 0, -35,)
                    return CheckLobby()
                } else {
                    AddLog("Replay raid")
                    ClickUntilGone(0, 0, LobbyText, , +120, -35)
                    return RestartStage()
                }
            }
            else if (i.Mode = "Infinity Castle") {
                AddLog("Handling Infinity Castle end")
                if (lastResult = "win") {
                    AddLog("Next floor")
                    ClickUntilGone(0, 0, LobbyText, , +120, -35)
                } else {
                    AddLog("Restart floor")
                    ClickUntilGone(0, 0, LobbyText, , +120, -35)
                }
                return RestartStage()
            }
            else if (i.Mode = "Cursed Womb") {
                AddLog("Handling Cursed Womb End")
                AddLog("Returning to lobby")
                ClickUntilGone(0, 0, LobbyText, , 0, -35)
                return CheckLobby()
            }
            else {
                AddLog("Handling end case")
                if (i.LobbyReturn) {
                    AddLog("Return to lobby enabled")
                    ClickUntilGone(0, 0, LobbyText, , 0, -35)
                    return CheckLobby()
                } else {
                    AddLog("Replaying")
                    ClickUntilGone(0, 0, LobbyText, , +120, -35)
                    return RestartStage()
                }
            }

        }

        Reconnect()
    }
}

MonitorStage() {
    global Wins, loss

    lastClickTime := A_TickCount

    GetForm()

    loop {
        Sleep(1000)

        timeElapsed := A_TickCount - lastClickTime
        if (timeElapsed >= 300000) {  ; 5 minutes
            AddLog("Performing anti-AFK click")
            IClick(560, 560)  ; Move click
            lastClickTime := A_TickCount
        }

        if (i.Mode = "Winter_Event") {
            CheckForCardSelection()
        }

        ; Check for XP screen
        if CheckForXp() {
            AddLog("Checking win/loss status")

            ; Calculate stage end time here, before checking win/loss
            stageEndTime := A_TickCount
            try {
                stageLength := FormatStageTime(stageEndTime - stageStartTime)
            }

            if (IFindText(UnitExit)) {
                ClickUntilGone(0, 0, UnitExit, , -1, -35)
            }

            ; Check for Victory or Defeat
            if (IFindText(VictoryText)) {
                try {
                    AddLog("Victory detected - Stage Length: " stageLength)
                }
                Wins++
                AddLog('Total Stats  Wins: ' Wins '  Lose: ' loss)
                if (challengeReady || inChallengeMode) {
                    sst := DateAdd(A_Now, FormatTime(A_Now, 'ss') * 2 - FormatTime(A_Now, 'ss'), 'S')
                    mmt := 30 - FormatTime(sst, 'mm')
                    if mmt < 1 {
                        mmt += 30
                    } else {
                        mmt := 30 - FormatTime(sst, 'mm')
                    }
                    mmt := DateAdd(sst, mmt, 'M')
                    IniWrite(mmt, pathCongif, 'Challenge', 'NextTime')
                    AddLog("Save next time Challege")
                }
                return MonitorEndScreen()
            }
            else if (IFindText(DefeatText)) {
                try {
                    AddLog("Defeat detected - Stage Length: " stageLength)
                }
                loss++
                ; SendWebhookWithTime(false, stageLength)
                AddLog('Total Stats  Wins: ' Wins '  Lose: ' loss)
                return MonitorEndScreen()
            }
        }
        Reconnect()
    }
}

CheckForXp() {
    ; Check for lobby text
    if (IFindText(XpText) or (IFindText(XpText2))) {
        ; IClick(325, 185)
        ; IClick(560, 560)
        return true
    }
    return false
}

CheckAbility(x?, y?) {
    global unitBuff, buffTime
    if (i.AutoAbility) {
        cd := [0, 23200, 7000, 7000]
        found := false
        if (IFindText(AutoOff) && unitBuff.Length < 4) {
            unitBuff.Push({ x: x, y: y, num: unitBuff.Length + 2, cd: cd[unitBuff.Length + 1], on: false })
            AddLog("Ability Add " unitBuff.Length)
            found := true
        }

        if (unitBuff.Length = 4) {
            buffTime := A_TickCount
            for start IN [1, 3, 2, 4] {
                while (!unitBuff[start].on) {
                    CheckForCardSelection()
                    UpgradeUnits(2, true)
                    if (unitBuff[start].cd <= A_TickCount - buffTime) {
                        IClick(unitBuff[start].x, unitBuff[start].y)
                        if (IFindText(AutoOff)) {
                            buffTime := A_TickCount
                            IClick(373, 237)
                            unitBuff[start].on := true
                            AddLog('Ability ' unitBuff[start].num - 1 ' is On')
                            IClick(560, 560)
                        }
                    }
                }

            }
        }
        return found

    }
    return false
}

Reconnect() {
    ; Check for Disconnected Screen using FindText
    if (IFindText(Disconnect)) {
        AddLog("Lost Connection! Attempting To Reconnect To Private Server...")

        psLink := FileExist("Settings\PrivateServer.txt") ? FileRead("Settings\PrivateServer.txt", "UTF-8") : ""
        if FileExist("Settings\PrivateServer.txt") && (psLink := FileRead("Settings\PrivateServer.txt", "UTF-8")) {
            AddLog("Connecting to private server...")
            Run(psLink)
        } else {
            Run("roblox://placeID=8304191830")  ; Public server if no PS file or empty
        }
        Sleep(300000)

        if WinExist(rblxID) {
            forceRobloxSize()
            Sleep(1000)
        }

        loop {
            AddLog("Reconnecting to Roblox...")
            Sleep(5000)

            if (IFindText(AreaText)) {
                AddLog("Reconnected Successfully!")
                return StartSelectedMode() ; Return to raids
            }
            else {
                Reconnect()
            }
        }
    }
}

MaxUpgrade() {
    if (IFindText(MaxText, 1000)) {
        return true
    }
    ; Check for max text
    return false
}

CheckEndAndRoute() {
    if (IFindText(LobbyText)) {
        AddLog("Found end screen")
        return MonitorEndScreen()
    }
    return false
}

UpgradeUnit(x, y) {
    IClick(x, y - 3)
    SendInput("r")
    SendInput("r")
}

CheckLoaded() {
    loop {
        Sleep(500)

        ; Check for vote screen
        if (IFindText(VoteStart)) {
            AddLog("Successfully Loaded In")
            Sleep(500)
            break
        }

        Reconnect()
    }
}

StartedGame() {
    loop {
        Sleep(500)
        if (IFindText(VoteStart)) {
            IClick(350, 103) ; click yes
            IClick(350, 100)
            IClick(350, 97)
            continue  ; Keep waiting if vote screen is still there
        }

        ; If we don't see vote screen anymore the game has started
        AddLog("Game started")
        global stageStartTime := A_TickCount
        break
    }
}

DetectMap() {
    AddLog("Determining Movement Necessity on Map...")
    startTime := A_TickCount

    loop {
        ; Check if we waited more than 5 minute for votestart
        if (A_TickCount - startTime > 300000) {
            if (IFindText(AreaText)) {
                AddLog("Found in lobby - restarting selected mode")
                return StartSelectedMode()
            }
            AddLog("Could not detect map after 5 minutes - proceeding without movement")
            return "no map found"
        }

        ; Check for vote screen
        if (IFindText(VoteStart) or (IFindText(Yen))) {
            AddLog("No Map Found or Movement Unnecessary")
            return "no map found"
        }

        mapPatterns := Map(
            "Ant Kingdom", Ant,
            "Sand Village", Sand,
            "Magic Town", MagicTown,
            "Magic Hill", MagicHills,
            "Navy Bay", Navy,
            "Snowy Town", SnowyTown,
            "Fiend City", Fiend,
            "Spirit World", Spirit,
            "Haunted Academy", Academy,
            "Space Center", SpaceCenter,
            "Mountain Temple", Mount,
            "Cursed Festival", Cursed,
            "Nightmare Train", Nightmare,
            "Air Craft", AirCraft,
            "Hellish City", Hellish,
            "Contracts", ContractLoadingScreen,
            "Winter_Event", Winter
        )

        for mapName, pattern in mapPatterns {
            if (i.Mode = "Winter_Event" or i.Mode = "Contracts") {
                if (IFindText(pattern)) {
                    AddLog("Detected map: " mapName)
                    return mapName
                }
            } else {
                if (IFindText(pattern)) {
                    AddLog("Detected map: " mapName)
                    return mapName
                }
            }
        }

        Sleep 1000
        Reconnect()
    }
}

CheckForCardSelection() {
    if (i.Mode = "Winter_Event") {
        if (IFindText(pick_card)) {
            cardSelector()
        }
    }
}

cardSelector() {
    AddLog("Picking card in priority order")
    if (IFindText(UnitExistence)) {
        IClick(560, 560) ; close upg menu
        sleep 100
    }
    SendInput('q')
    ; IClick(59, 572) ; Untarget Mouse
    sleep 100
    list := []
    loop 19 {
        text := 'Priority' A_Index
        list.Push(card.%text%)
    }
    for index, priority in list {
        if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, %priority%)) {

            if (priority == "shield") {
                if (card.Heighest == 1) {
                    AddLog("Picking highest shield debuff")
                    if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, shield3)) {
                        AddLog("Found shield 3")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, shield2)) {
                        AddLog("Found shield 2")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, shield1)) {
                        AddLog("Found shield 1")
                    }
                }

            }
            else if (priority == "speed") {
                if (card.Heighest == 1) {
                    AddLog("Picking highest speed debuff")
                    if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, speed_3)) {
                        AddLog("Found speed 3")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, speed_2)) {
                        AddLog("Found speed 2")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, speed_1)) {
                        AddLog("Found speed 1")
                    }
                }
            }
            else if (priority == "health") {
                if (card.Heighest == 1) {
                    AddLog("Picking highest health debuff")
                    if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, health3)) {
                        AddLog("Found health 3")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, health2)) {
                        AddLog("Found health 2")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, health1)) {
                        AddLog("Found health 1")
                    }
                }
            }
            else if (priority == "regen") {
                if (card.Heighest == 1) {
                    AddLog("Picking highest regen debuff")
                    if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, regen3)) {
                        AddLog("Found regen 3")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, regen2)) {
                        AddLog("Found regen 2")
                    }
                    else if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, regen1)) {
                        AddLog("Found regen 1")
                    }
                }
            }
            else if (priority == "yen") {
                if (FindText(&cardX, &cardY, 209, 203, 652, 404, 0, 0, yen2)) {
                    AddLog("Found yen 2")
                }
                else {
                    AddLog("Found yen 1")
                }
            }

            FindText().Click(cardX, cardY, 0)
            MouseMove 0, 10, 2, "R"
            Click 2
            sleep 1000
            MouseMove 0, 120, 2, "R"
            Click 2
            AddLog(Format("Picked card: {}", priority))
            sleep 1000

            loop {
                if !IFindText(pick_card)
                    break
            }
            return
        }
    }
    AddLog("Failed to pick a card")
}

GenerateCirclePoints() {
    global centerX := 408
    global centerY := 320
    points := []

    ; Define each circle's radius
    radius1 := 45    ; First circle
    radius2 := 90    ; Second circle
    radius3 := 135   ; Third circle
    radius4 := 180   ; Fourth circle

    ; Angles for 8 evenly spaced points (in degrees)
    angles := [0, 45, 90, 135, 180, 225, 270, 315]

    ; First circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius1 * Cos(radians)
        y := centerY + radius1 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }

    ; second circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius2 * Cos(radians)
        y := centerY + radius2 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }

    ; third circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius3 * Cos(radians)
        y := centerY + radius3 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }

    ;  fourth circle points
    for angle in angles {
        radians := angle * 3.14159 / 180
        x := centerX + radius4 * Cos(radians)
        y := centerY + radius4 * Sin(radians)
        points.Push({ x: Round(x), y: Round(y) })
    }

    return points
}

GenerateRandomPoints() {
    points := []
    gridSize := 40  ; Minimum spacing between units

    ; Center point coordinates
    centerX := 408
    centerY := 320

    ; Define placement area boundaries (adjust these as needed)
    minX := centerX - 180  ; Left boundary
    maxX := centerX + 180  ; Right boundary
    minY := centerY - 140  ; Top boundary
    maxY := centerY + 140  ; Bottom boundary

    ; Generate 40 random points
    loop 40 {
        ; Generate random coordinates
        x := Random(minX, maxX)
        y := Random(minY, maxY)

        ; Check if point is too close to existing points
        tooClose := false
        for existingPoint in points {
            ; Calculate distance to existing point
            distance := Sqrt((x - existingPoint.x) ** 2 + (y - existingPoint.y) ** 2)
            if (distance < gridSize) {
                tooClose := true
                break
            }
        }

        ; If point is not too close to others, add it
        if (!tooClose)
            points.Push({ x: x, y: y })
    }

    ; Always add center point last (so it's used last)
    points.Push({ x: centerX, y: centerY })

    return points
}

GenerateGridPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)

    ; Center point coordinates
    centerX := 408
    centerY := 320

    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)

    ; Generate grid points row by row
    loop squaresPerSide {
        currentRow := A_Index
        y := startY + ((currentRow - 1) * gridSize)

        ; Generate each point in the current row
        loop squaresPerSide {
            x := startX + ((A_Index - 1) * gridSize)
            points.Push({ x: x, y: y })
        }
    }

    return points
}

GenerateMoreGridPoints(gridWidth := 5, x := 0, y := 0) {  ; Adjust grid width (must be an odd number)
    points := []
    gridSize := 30  ; Space between points

    centerX := x ? x : GetWindowCenter(rblxID).x
    centerY := y ? y : GetWindowCenter(rblxID).y

    directions := [[1, 0], [0, 1], [-1, 0], [0, -1]]  ; Right, Down, Left, Up (1-based index)

    x := centerX
    y := centerY
    step := 1
    dirIndex := 1  ; Start at index 1 (AutoHotkey is 1-based)
    moves := 0
    stepsTaken := 0

    points.Push({ x: x, y: y })  ; Start at center

    loop (gridWidth * gridWidth - 1) {  ; Fill remaining slots
        dx := directions[dirIndex][1] * gridSize
        dy := directions[dirIndex][2] * gridSize
        x += dx
        y += dy
        points.Push({ x: x, y: y })

        moves++
        stepsTaken++

        if (moves = step) {  ; Change direction
            moves := 0
            dirIndex := (dirIndex = 4) ? 1 : dirIndex + 1  ; Rotate through 1-4

            if (stepsTaken // 2 = step) {  ; Expand step after two full cycles
                step++
                stepsTaken := 0
            }
        }
    }

    return points
}

GetContractPage() {
    global contractPageCounter, contractSwitchPattern

    if (contractSwitchPattern = 0) {  ; During page 4 phase
        contractPageCounter++
        if (contractPageCounter >= 6) {  ; After 6 times on page 4
            contractPageCounter := 0
            contractSwitchPattern := 1  ; Switch to page 5
            return "Page 5"
        }
        return "Page 4"
    } else {  ; During page 5 phase
        contractPageCounter := 0
        contractSwitchPattern := 0  ; Switch back to page 4 pattern
        return "Page 4"
    }
}

GenerateUpandDownPoints() {
    points := []
    gridSize := 40  ; Space between points
    squaresPerSide := 7  ; How many points per row/column (odd number recommended)

    ; Center point coordinates
    centerX := 408
    centerY := 320

    ; Calculate starting position for top-left point of the grid
    startX := centerX - ((squaresPerSide - 1) / 2 * gridSize)
    startY := centerY - ((squaresPerSide - 1) / 2 * gridSize)

    ; Generate grid points column by column (left to right)
    loop squaresPerSide {
        currentColumn := A_Index
        x := startX + ((currentColumn - 1) * gridSize)

        ; Generate each point in the current column
        loop squaresPerSide {
            y := startY + ((A_Index - 1) * gridSize)
            points.Push({ x: x, y: y })
        }
    }

    return points
}

GenerateSpiralPoints(rectX := 4, rectY := 123, rectWidth := 795, rectHeight := 433) {
    points := []

    ; Calculate center of the rectangle
    centerX := rectX + rectWidth // 2
    centerY := rectY + rectHeight // 2

    ; Angle increment per step (in degrees)
    angleStep := 30
    ; Distance increment per step (tighter spacing)
    radiusStep := 10
    ; Initial radius
    radius := 20

    ; Maximum radius allowed (smallest distance from center to edge)
    maxRadiusX := (rectWidth // 2) - 1
    maxRadiusY := (rectHeight // 2) - 1
    maxRadius := Min(maxRadiusX, maxRadiusY)

    ; Generate spiral points until reaching max boundary
    loop {
        ; Stop if the radius exceeds the max boundary
        if (radius > maxRadius)
            break

        angle := A_Index * angleStep
        radians := angle * 3.14159 / 180
        x := centerX + radius * Cos(radians)
        y := centerY + radius * Sin(radians)

        ; Check if point is inside the rectangle
        if (x < rectX || x > rectX + rectWidth || y < rectY || y > rectY + rectHeight)
            break ; Stop if a point goes out of bounds

        points.Push({ x: Round(x), y: Round(y) })

        ; Increase radius for next point
        radius += radiusStep
    }

    return points
}

CheckLobby() {
    loop {
        Sleep 1000
        if (IFindText(AreaText)) {
            break
        }
        Reconnect()
    }
    AddLog("Returned to lobby, restarting selected mode")
    return StartSelectedMode()
}

HandleNextContract() {
    selectedPage := i.Type
    if (selectedPage = "Page 4-5") {
        selectedPage := GetContractPage()
    }

    pageNum := Integer(RegExReplace(selectedPage, "Page ", ""))

    ; Define click coordinates to vote
    clickCoords := Map(
        1, { x: 205, y: 470 },
        2, { x: 365, y: 470 },
        3, { x: 525, y: 470 },
        4, { x: 272, y: 470 },
        5, { x: 432, y: 470 },
        6, { x: 592, y: 470 }
    )

    ; First scroll if needed for pages 4-6
    if (pageNum >= 4) {
        IClick(400, 300)
        Sleep(200)
        loop 5 {
            SendInput("{WheelDown}")
            Sleep(150)
        }
        Sleep(300)
    }

    ; Click the Open Here button for the selected page
    AddLog("Opening contract on page " selectedPage)
    IClick(clickCoords[pageNum].x, clickCoords[pageNum].y)
    Sleep(500)

    return RestartStage()
}

BasicSetup() {
    ; SendInput("{Tab}") ; Closes Player leaderboard
    ; Sleep 300
    ClickUntilGone(0, 0, xlistplayer, 300, -1, 1)
    ; IClick(564, 72) ; Closes Player leaderboard
    CloseChat()
    Sleep 300
    Zoom()
    Sleep 300
    TpSpawn()
}

CloseChat() {
    if (IFindText(OpenChat)) {
        AddLog "Closing Chat"
        IClick(138, 30) ;close chat
    }
}

Zoom() {
    MouseMove(400, 300)
    Sleep 100
    loop 10 {
        Send "{WheelUp}"
        Sleep 50
    }
    Click
    MouseMove(400, 400)
    loop 20 {
        Send "{WheelDown}"
        Sleep 50
    }
    MouseMove(400, 300)
}

TpSpawn() {
    IClick(26, 570) ;click settings
    Sleep 300
    IClick(400, 215)
    Sleep 300
    loop 4 {
        Sleep 150
        SendInput("{WheelDown 1}") ;scroll
    }
    Sleep 300
    if (ok := IFindText(Spawn)) {
        AddLog("Found Teleport to Spawn button")
        ; IClick(X + 100, Y - 30)
        calX := ok[1].1 + 100
        calY := ok[1].2 - (ok[1].4 * 2) + 30
        IClick(calX, calY)
    } else {
        AddLog("Could not find Teleport button")
    }
    Sleep 300
    IClick(583, 147)
    Sleep 300

    ;

}

HandleMapMovement(MapName, i) {
    AddLog("Executing Movement for: " MapName)

    switch MapName {
        case "Snowy Town":
            MoveForSnowyTown()
        case "Sand Village":
            MoveForSandVillage()
        case "Ant Kingdom":
            MoveForAntKingdom()
        case "Magic Town":
            MoveForMagicTown()
        case "Magic Hill":
            MoveForMagicHill()
        case "Navy Bay":
            MoveForNavyBay()
        case "Fiend City":
            MoveForFiendCity()
        case "Spirit World":
            MoveForSpiritWorld()
        case "Haunted Academy":
            MoveForHauntedAcademy()
        case "Space Center":
            MoveForSpaceCenter()
        case "Mountain Temple":
            MoveForMountainTemple()
        case "Cursed Festival":
            MoveForCursedFestival()
        case "Nightmare Train":
            MoveForNightmareTrain()
        case "Air Craft":
            MoveForAirCraft()
        case "Hellish City":
            MoveForHellish()
        case "Winter_Event":
            MoveForWinterEvent()
        case "Contracts":
            MoveForContracts()
    }
}

FindAndClickColor(targetColor?, searchArea := [0, 0, GetWindowCenter(rblxID).Width, GetWindowCenter(rblxID).Height]) { ;

    targetColor := (i.Mode = "Winter_Event" ? 0x006783 : 0xFAFF4D)
    x1 := searchArea[1], y1 := searchArea[2], x2 := searchArea[3], y2 := searchArea[4]

    ; Perform the pixel search
    if (PixelSearch(&foundX, &foundY, x1, y1, x2, y2, targetColor, 0)) {
        ; Color found, click on the detected coordinates
        IClick(foundX, foundY, , "Right")
        AddLog("Color found and clicked at: X" foundX " Y" foundY)
        Sleep 2000
        return true

    }
}

MoveForHauntedAcademy() {
    color := PixelGetColor(647, 187)
    if (!IsColorInRange(color, 0xFDF0B3)) {
        SendInput ("{s down}")
        sleep (3500)
        SendInput ("{s up}")
    } else {
        SendInput ("{d down}")
        sleep (3500)
        SendInput ("{d up}")
    }
}

MoveForSpaceCenter() {
    IClick(160, 280, , "Right")
    Sleep (7000)
}

MoveForMountainTemple() {
    IClick(40, 500, , "Right")
    Sleep (4000)
}

MoveForCursedFestival() {
    SendInput ("{d down}")
    sleep (1800)
    SendInput ("{d up}")
}

MoveForNightmareTrain() {
    SendInput ("{a down}")
    sleep (1800)
    SendInput ("{a up}")
}

MoveForAirCraft() {
    SendInput ("{s down}")
    sleep (800)
    SendInput ("{s up}")
}

MoveForHellish() {
    IClick(600, 300, , "Right")
    Sleep (7000)
}

MoveForWinterEvent() {
    loop {
        if FindAndClickColor() {
            break
        }
        else {
            AddLog("Color not found. Turning again.")
            SendInput ("{Left up}")
            Sleep 200
            SendInput ("{Left down}")
            Sleep 750
            SendInput ("{Left up}")
            KeyWait "Left" ; Wait for key to be fully processed
            Sleep 200
        }
    }
}

MoveForContracts() {
    IClick(590, 15) ; click on paths
    loop {
        if FindAndClickColor() {
            IClick(590, 15) ; click on paths
            break
        }
        else {
            AddLog("Color not found. Turning again.")
            SendInput ("{Left up}")
            Sleep 200
            SendInput ("{Left down}")
            Sleep 750
            SendInput ("{Left up}")
            KeyWait "Left" ; Wait for key to be fully processed
            Sleep 200
        }
    }
}

MoveForSnowyTown() {
    IClick(700, 125, , "Right")
    Sleep (6000)
    IClick(615, 115, , "Right")
    Sleep (3000)
    IClick(725, 300, , "Right")
    Sleep (3000)
    IClick(715, 395, , "Right")
    Sleep (3000)
}

MoveForNavyBay() {
    SendInput ("{a down}")
    SendInput ("{w down}")
    Sleep (1700)
    SendInput ("{a up}")
    SendInput ("{w up}")
}

MoveForSandVillage() {
    IClick(777, 415, , "Right")
    Sleep (3000)
    IClick(560, 555, , "Right")
    Sleep (3000)
    IClick(125, 570, , "Right")
    Sleep (3000)
    IClick(200, 540, , "Right")
    Sleep (3000)
}

MoveForFiendCity() {
    IClick(185, 410, , "Right")
    Sleep (3000)
    SendInput ("{a down}")
    Sleep (3000)
    SendInput ("{a up}")
    Sleep (500)
    SendInput ("{s down}")
    Sleep (2000)
    SendInput ("{s up}")
}

MoveForSpiritWorld() {
    SendInput ("{d down}")
    SendInput ("{w down}")
    Sleep(7000)
    SendInput ("{d up}")
    SendInput ("{w up}")
    sleep(500)
    IClick(400, 15, , "Right")
    sleep(4000)
}

MoveForAntKingdom() {
    IClick(130, 550, , "Right")
    Sleep (3000)
    IClick(130, 550, , "Right")
    Sleep (4000)
    IClick(30, 450, , "Right")
    Sleep (3000)
    IClick(120, 100, , "Right")
    sleep (3000)
}

MoveForMagicTown() {
    IClick(700, 315, , "Right")
    Sleep (2500)
    IClick(585, 535, , "Right")
    Sleep (3000)
    SendInput ("{d down}")
    Sleep (3800)
    SendInput ("{d up}")
}

MoveForMagicHill() {
    color := PixelGetColor(630, 125)
    if (!IsColorInRange(color, 0xFFD100)) {
        IClick(500, 20, , "Right")
        Sleep (3000)
        IClick(500, 20, , "Right")
        Sleep (3500)
        IClick(285, 15, , "Right")
        Sleep (2500)
        IClick(285, 25, , "Right")
        Sleep (3000)
        IClick(410, 25, , "Right")
        Sleep (3000)
        IClick(765, 150, , "Right")
        Sleep (3000)
        IClick(545, 30, , "Right")
        Sleep (3000)
    } else {
        IClick(45, 185, , "Right")
        Sleep (3000)
        IClick(140, 250, , "Right")
        Sleep (2500)
        IClick(25, 485, , "Right")
        Sleep (3000)
        IClick(110, 455, , "Right")
        Sleep (3000)
        IClick(40, 340, , "Right")
        Sleep (3000)
        IClick(250, 80, , "Right")
        Sleep (3000)
        IClick(230, 110, , "Right")
        Sleep (3000)
    }
}
