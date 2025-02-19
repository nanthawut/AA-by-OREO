#Requires AutoHotkey v2.0

OnExit ExitFunc

if !DirExist(A_ScriptDir "\Config")
    DirCreate(A_ScriptDir "\Config")

RegisterHotkey() {
    Hotkey(hotKeySetting[3], (*) => Reload())
    Hotkey(hotKeySetting[2], (*) => saveSetting())
    return
}

OnMessage(0x0200, On_WM_MOUSEMOVE)
On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd) {
        Text := "", ToolTip() ; Turn off any previous tooltip.
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if !CurrControl.HasProp("ToolTip")
                return ; No tooltip for this control.
            Text := CurrControl.ToolTip
            SetTimer () => ToolTip(Text), -1500
            SetTimer () => ToolTip() PrevHwnd := 0, -4000 ; Remove the tooltip.
        }
        PrevHwnd := Hwnd
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
}

ExitFunc(ExitReason, ExitCode) {
    saveSetting()
}
