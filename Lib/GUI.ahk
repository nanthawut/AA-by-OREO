#Requires AutoHotkey v2.0

qwe := Gui("+AlwaysOnTop -Caption")
qwe.menubtn := qwe.Add('Button', 'w50 h50', 'Menu')
qwe.menubtn.OnEvent('Click', (*) => OnMenu())
qwe.menubtn.ToolTip := menuTooltip
qwe.unitbtn := qwe.Add('Button', 'xp yp+55 w50 h20 Hidden', 'Unit')
qwe.unitbtn.OnEvent('Click', (*) => toggleEQ())
qwe.exitbtn := qwe.Add('Button', 'xp yp+25 w50 h20 Hidden', 'Exit')
qwe.exitbtn.OnEvent('Click', (*) => ExitApp())

qwe.BackColor := "0e0606"
WinSetTransColor("0e0606", qwe)

qwe.Show("y300 x" A_ScreenWidth - 70 " y30")

OnMenu() {
    qwe.unitbtn.Visible := !qwe.unitbtn.Visible
    qwe.exitbtn.Visible := !qwe.exitbtn.Visible
}
toggleEQ() {
    WinExist('ahk_id' eq.Hwnd) ?
        eq.Hide() : eq.Show()
}

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
eq.AddCheckbox('xs+10 yp+25 vEnable2', 'Unit2')
eq.AddDropDownList('x+10 w30 vPlacement2', slotU)
eq.AddDropDownList('x+18 w30 vPriority2', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit2', slotU)
eq.AddCheckbox('xs+10 yp+25 vEnable3', 'Unit3')
eq.AddDropDownList('x+10 w30 vPlacement3', slotU)
eq.AddDropDownList('x+18 w30 vPriority3', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit3', slotU)
eq.AddCheckbox('xs+10 yp+25 vEnable4', 'Unit4')
eq.AddDropDownList('x+10 w30 vPlacement4', slotU)
eq.AddDropDownList('x+18 w30 vPriority4', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit4', slotU)
eq.AddCheckbox('xs+10 yp+25 vEnable5', 'Unit5')
eq.AddDropDownList('x+10 w30 vPlacement5', slotU)
eq.AddDropDownList('x+18 w30 vPriority5', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit5', slotU)
eq.AddCheckbox('xs+10 yp+25 vEnable6', 'Unit6')
eq.AddDropDownList('x+10 w30 vPlacement6', slotU)
eq.AddDropDownList('x+18 w30 vPriority6', slotU)
eq.AddDropDownList('x+10 w30 vMaxUnit6', slotU)
; eq.Show()

loadSetting()

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


