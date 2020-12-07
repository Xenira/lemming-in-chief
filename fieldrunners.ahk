SetWorkingDir %A_ScriptDir%
SetKeyDelay, 100

MsgBox, Please open Fieldrunners to the main menu. Make sure you have no current game and the resume option is not available.
While, Not isWindowActive()
        Sleep, 500


While True
{
    ToolTip, Starting game

    findObject("play", targetX, targetY)
    click(targetX, targetY)
    findObject("left", targetX, targetY)
    click(targetX, targetY)
    findObject("start", targetX, targetY)
    click(targetX, targetY)

    Sleep 10000
    MouseMove, 32, 64
    Click

    Send, {Click}f{WheelDown}{WheelDown}{WheelDown}

    Loop, read, lava_classic_easy.build
    {
        command := StrSplit(A_LoopReadLine, ",")

        ExecuteCommand(command)
    }

    ToolTip, Done. Waiting to finish.

    findObject("highscore", targetX, targetY)
    Send, RIP{ENTER}
    findObject("close", targetX, targetY)
    click(targetX, targetY)
}


ExecuteCommand(command)
{
    switch command[1]
    {
        case "build":
            BuildTower(command[2], command[3], command[4])
        case "upgrade":
            UpgradeTower(command[2], command[3])
        case "sell":
            SellTower(command[2], command[3])
        case "replace":
            ReplaceTower(command[2], command[3], command[4])
    }
}

BuildTower(name, x, y)
{
    ToolTip, Placing %name% at %x% - %y%
    fieldToPos(x - 1, y - 1, fieldPosX, fieldPosY)
    findObject(name, targetX, targetY)
    click(targetX, targetY, False)

    click(fieldPosX, fieldPosY)
}

UpgradeTower(x, y)
{
    ToolTip, Upgrading %name% at %x% - %y%
    fieldToPos(x - 1, y - 1, fieldPosX, fieldPosY)
    click(fieldPosX, fieldPosY)

    isAvailable := False
    While not isAvailable
    {
        PixelGetColor, detectedColor, fieldPosX + 64, fieldPosY, RGB
        hexToRgb(detectedColor,,g,b)

        if (b > 200 && g > 200) {
            isAvailable = true
        } else {
            Sleep, 1000
        }
    }

    click(fieldPosX + 64, fieldPosY)
}

SellTower(x, y)
{
    ToolTip, Selling %name% at %x% - %y%
    fieldToPos(x - 1, y - 1, fieldPosX, fieldPosY)
    click(fieldPosX, fieldPosY)

    isAvailable := False
    While not isAvailable
    {
        PixelGetColor, detectedColor, fieldPosX - 64, fieldPosY, RGB
        hexToRgb(detectedColor,r,g,b)

        if (r > 200 && g > 200) {
            isAvailable = true
        } else {
            Sleep, 1000
        }
    }

    click(fieldPosX - 64, fieldPosY)
}

ReplaceTower(name, x, y)
{
    ToolTip, Replacing %name% at %x% - %y%
    findObject(name, targetX, targetY)
    SellTower(x, y)
    BuildTower(name, x, y)
}

click(x, y, rest := True)
{
    MouseMove, x, y
    Click, x, y
    Sleep 150
    if (rest) {
        MouseMove, 32, 96
        Sleep 100
    }
}

findObject(name, ByRef targetX, ByRef targetY)
{
    While, Not isWindowActive()
        Sleep, 500
    WinGetPos,,, WindowWidth, WindowHeight, A
    foundResult := False
    While not foundResult
    {
        ImageSearch, targetX, targetY, 32, 32, WindowWidth, WindowHeight, images/%name%.png
        foundResult := ErrorLevel = 0
        if not foundResult
            Sleep 1000
    }
    targetX += 8
    targetY += 8
}

isWindowActive()
{
    WinGetActiveTitle, windowTitle
    return windowTitle == "Fieldrunners"
}

fieldToPos(x, y, ByRef posX, ByRef posY)
{
    OFFSET_X := 120
    OFFSET_Y := 180
    FIELD_SIZE := 45
    posX := x * FIELD_SIZE + OFFSET_X
    posY := y * FIELD_SIZE + OFFSET_Y
}

posToField(x, y, ByRef fieldX, ByRef fieldY)
{
    OFFSET_X := 120
    OFFSET_Y := 180
    FIELD_SIZE := 45
    fieldX := Round(x - OFFSET_X / FIELD_SIZE)
    fieldY := Round(y - OFFSET_Y / FIELD_SIZE)
}

hexToRgb(hex, ByRef r := 0, ByRef g := 0, ByRef b := 0)
{
    r := Format("{1:u}", "0x" . SubStr(hex, 3, 2))
    g := Format("{1:u}", "0x" . SubStr(hex, 5, 2))
    b := Format("{1:u}", "0x" . SubStr(hex, 7, 2))
}