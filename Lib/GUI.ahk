#Requires AutoHotkey v2.0

qwe := Gui("+AlwaysOnTop -Caption")
qwe.menubtn := qwe.Add('Picture', 'w80 h80 +BackgroundTrans cffffff', "Resource\dino.png")
qwe.menubtn.OnEvent('Click', (*) => OnMenu())
qwe.unitbtn := qwe.Add('Picture', 'xp+20 yp+80 w50 h50 Hidden', 'Resource\unit.png')
qwe.unitbtn.OnEvent('Click', (*) => toggleEQ())
qwe.card := qwe.Add('Picture', 'x25 yp+60 w50 h50 Hidden', 'Resource\card.png')
qwe.card.OnEvent('Click', (*) => PCS.Show())
qwe.exitbtn := qwe.Add('Picture', 'xp+5 yp+60 w50 h50 Hidden', 'Resource\cross.png')
qwe.exitbtn.OnEvent('Click', (*) => ExitApp())
qwe.BackColor := "0e0606"
qwe.Title:= "Macro OREO"
WinSetTransColor("0e0606", qwe)

; SetTimer () => !ToolTip() ? ToolTip() : '', -5000
qwe.Show("x" A_ScreenWidth - 100 " y30")
OnMenu() {
    qwe.unitbtn.Visible := !qwe.unitbtn.Visible
    qwe.exitbtn.Visible := !qwe.exitbtn.Visible
    qwe.card.Visible := !qwe.card.Visible
    eq.Hide()
}
;==============================================================================
eq := Gui("+AlwaysOnTop -Caption +Owner" qwe.Hwnd)
eq.OnEvent('Escape', (g, *) => g.Hide())
eq.AddGroupBox('xm Section w386', 'Select Mode')
eq.modeDropdown := eq.AddDropDownList('xs+10 ys+25 vMode Choose1', mAr.mode)
eq.modeDropdown.OnEvent('Change', (*) => ModeChange())
eq.mapDropdown := eq.AddDropDownList('x+3 vMap Choose1', mAr.%eq.modeDropdown.Text%[1])
eq.typeDropdown := eq.AddDropDownList('x+3 vType Choose1', mAr.%eq.modeDropdown.Text%[2])
eq.AddGroupBox('xm Section w386 h72', 'Option')
eq.AddCheckbox('xs+10 ys+25 vNextLevel', 'Next Level')
eq.AddCheckbox('x+0 vLobbyReturn', 'Lobby Return')
eq.AddCheckbox('x+0 vMatchMaking', 'MatchMaking')
eq.AddCheckbox('x+0 vUpgradeDuring', 'Upgrade during place')
eq.AddCheckbox('xs+10 yp+25 vAutoAbility', 'Auto Ability')
eq.AddCheckbox('x+0 vAutoChallenge', 'Auto Challenge')
eq.AddCheckbox('x+0 vSwitchUpgrade', 'Switch Upgrade')
eq.AddGroupBox('xm Section w386 h182', 'Unit Control')
eq.AddText('x65 y160', 'Placement')
eq.AddText('x+10', 'Priority')
eq.AddText('x+10', 'Max Unit')
eq.AddCheckbox('xs+10 ys+30 vEnable1', 'Unit1')
eq.AddDropDownList('x+10 w30 vPlacement1', slotU)
eq.AddDropDownList('x+18 w30 vPriority1', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit1', slotU)
eq.AddCheckbox('x+10 w30 vHill1')
eq.AddCheckbox('xs+10 yp+25 vEnable2', 'Unit2')
eq.AddDropDownList('x+10 w30 vPlacement2', slotU)
eq.AddDropDownList('x+18 w30 vPriority2', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit2', slotU)
eq.AddCheckbox('x+10 w30 vHill2')
eq.AddCheckbox('xs+10 yp+25 vEnable3', 'Unit3')
eq.AddDropDownList('x+10 w30 vPlacement3', slotU)
eq.AddDropDownList('x+18 w30 vPriority3', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit3', slotU)
eq.AddCheckbox('x+10 w30 vHill3')
eq.AddCheckbox('xs+10 yp+25 vEnable4', 'Unit4')
eq.AddDropDownList('x+10 w30 vPlacement4', slotU)
eq.AddDropDownList('x+18 w30 vPriority4', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit4', slotU)
eq.AddCheckbox('x+10 w30 vHill4')
eq.AddCheckbox('xs+10 yp+25 vEnable5', 'Unit5')
eq.AddDropDownList('x+10 w30 vPlacement5', slotU)
eq.AddDropDownList('x+18 w30 vPriority5', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit5', slotU)
eq.AddCheckbox('x+10 w30 vHill5')
eq.AddCheckbox('xs+10 yp+25 vEnable6', 'Unit6')
eq.AddDropDownList('x+10 w30 vPlacement6', slotU)
eq.AddDropDownList('x+18 w30 vPriority6', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit6', slotU)
eq.AddCheckbox('x+10 w30 vHill6')
eq.AddDDL('vPlaceSpeed', placeSpeed)
eq.AddDDL('x+8 vPlaceType', placeTpye)
toggleEQ() {
    WinExist('ahk_id' eq.Hwnd) ?
        eq.Hide() : eq.Show('x900')
        GetForm()
}
ModeChange() {
    ddl := eq.mapDropdown.Gui['Map']
    ddt := eq.typeDropdown.Gui['Type']
    ddl.Delete()
    ddt.Delete()
    if mAr.HasOwnProp(eq.modeDropdown.Text) {
        if IsObject(mAr.%eq.modeDropdown.Text%[1]) {
            ddl.Add(mAr.%eq.modeDropdown.Text%[1])
            ddt.Add(mAr.%eq.modeDropdown.Text%[2])
            ddt.Choose(1)
        } else {
            ddl.Add(mAr.%eq.modeDropdown.Text%)
        }
        ddl.Choose(1)
    }
}
;==============================================================================
PCS := Gui("+AlwaysOnTop +Owner" qwe.Hwnd)
PCS.SetFont("s10 bold", "Segoe UI")
PCS.MarginX := 20
PCS.MarginY := 20
PCS.Add("GroupBox", "x30 y25 w180 h570 Section", "Modifier Priority Order")

options := ["new_path", "range_3", "attack_3", "cooldown_3", "range_2", "attack_2", "cooldown_2", "blessing_2",
    "range_1", "attack_1", "cooldown_1", "blessing_1", "shield", "explosive_death_21", "explosive_death_3", "speed",
    "health", "regen", "yen"]

numDropDowns := 19
yStart := 50
ySpacing := 28

for index, card in options {
    if (index > numDropDowns)
        break
    yPos := yStart + ((index - 1) * ySpacing)
    PCS.Add("Text", Format("x38 y{} w30 h17", yPos), index)
    PCS.Add("DropDownList", Format("x60 y{} w135 Choose{} vPriority{}", yPos, index, index), options)

}

PCS.Add("GroupBox", "x30 y610 w180 h120", "Debuff Priority")
PCS.Add("Radio", "x54 y630 w120 h23 Checked", "Random Tier")
PCS.Add("Radio", "x54 y655 w120 h23 vHeighest", "Highest Tier")
PCS.Add("Text", "x12 x54 y680 w180 +BackgroundTrans", "Random = Pick any")
PCS.Add("Text", "x12 x54 y700 w180 +BackgroundTrans", "Highest = Tier 3>2>1")

;==============================================================================

ProG := Gui("+AlwaysOnTop -Caption +Owner" qwe.Hwnd)
ProG.Title := "Process Na ja. :P"
ProG.BackColor := '0e0606'
WinSetTransColor("0e0606", ProG)
ProG.SetFont("s11", "Segoe UI")
font := "16f306"
ProG.Process := ProG.AddEdit('w300 r10 ReadOnly Background1f1f1f c' font, menuTooltip)
toggleProg() {
    WinExist('ahk_id' ProG.Hwnd) ?
        ProG.Hide() : ProG.Show('x' A_ScreenWidth - 400 ' y' 45)
}