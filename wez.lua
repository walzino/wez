-- ═══════════════════════════════════════════
--              ANTI DOUBLE INJECTION
-- ═══════════════════════════════════════════
if game:GetService("CoreGui"):FindFirstChild("WezHub_Pro") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Wez Hub",
        Text = "Wez Hub is already running!",
        Duration = 3
    })
    return
end

-- ═══════════════════════════════════════════
--              SERVICES
-- ═══════════════════════════════════════════
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Stats            = game:GetService("Stats")
local Workspace        = game:GetService("Workspace")
local Camera           = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ═══════════════════════════════════════════
--              GLOBAL STATE
-- ═══════════════════════════════════════════
local NotificationSent = false
local IsVisible        = true
local IsMinimized      = false
local ActiveTab        = "Home"
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════
--              AIMLOCK STATE
-- ═══════════════════════════════════════════
local AimlockActive = false
local AimlockLocked = false
local AimlockTarget = nil

-- ═══════════════════════════════════════════
--              FLY STATE
-- ═══════════════════════════════════════════
local flying     = false
local flyConn    = nil
local noclipConn = nil

-- ═══════════════════════════════════════════
--              FLY SETTINGS
-- ═══════════════════════════════════════════
local FLY_SPEED   = 350   -- studs per second (consistent the whole way)
local ARRIVE_DIST = 5
local Y_OFFSET    = 3

-- ═══════════════════════════════════════════
--              INFO PANEL STAT KEYS
-- ═══════════════════════════════════════════
local STAT_KEYS = {
    "HealthMax", "KiDamage", "KiMax", "KiResist",
    "PhysDamage", "PhysResist", "Speed"
}

-- ═══════════════════════════════════════════
--              AUTOFARMER STATE
-- ═══════════════════════════════════════════
local AutoFarmer = {
    IsFarming = false,
    IsEscaping = false,
    IsChargingKi = false,
    CurrentTarget = nil,
    CurrentTargetModel = nil,
    OriginalTargetModel = nil,
    EscapePosition = nil,
    
    -- Connections
    FlyConnection = nil,
    CameraConnection = nil,
    CombatConnection = nil,
    KeyPressConnection = nil,
    NoclipConnection = nil,
    HealthCheckConnection = nil,
    ChargingConnection = nil,
    
    -- Timers
    LastM1Time = 0,
    LastM2Time = 0,
    LastKeyPressTime = 0,
    LastKeyIndex = 1,
       WaitingForRespawn = false,
    LastTargetName = nil,
    RespawnCheckConnection = nil,
}

local FarmerSettings = {
    -- Movement Settings
    CircleRadius = 12,  -- Changed to 12 studs
    CircleSpeed = 0.1,  -- Much slower circling (was 0.25)
    FlySpeed = 220,
    
    -- Combat Settings
    M1Delay = 0.08,
    M2Delay = 0.45,
    UseM2 = true,
    
    -- Key Press Settings (R, T, Y)
    KeyPressDelay = 0.35,
    KeyPressDuration = 0.05,
    
    -- Escape Settings
    EscapeHPThreshold = 45,
    ReturnHPThreshold = 75,
    EscapeDistance = 3500,
    EscapeFlySpeed = 320,
    
    -- UI Settings
    UpdateInterval = 0.5,
    
}

-- ═══════════════════════════════════════════
--              SCREEN GUI
-- ═══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "WezHub_Pro"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = game:GetService("CoreGui")

-- ═══════════════════════════════════════════
--              MAIN FRAME
-- ═══════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name                  = "MainFrame"
MainFrame.Size                  = UDim2.new(0, 560, 0, 370)
MainFrame.Position              = UDim2.new(0.5, -280, 0.5, -185)
MainFrame.BackgroundColor3      = Color3.fromRGB(10, 18, 15)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel       = 0
MainFrame.ClipsDescendants      = true
MainFrame.Parent                = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color        = Color3.fromRGB(35, 190, 120)
MainStroke.Thickness    = 1.4
MainStroke.Transparency = 0.45
MainStroke.Parent       = MainFrame

local GlowFrame = Instance.new("Frame")
GlowFrame.Size                  = UDim2.new(1, -4, 1, -4)
GlowFrame.Position              = UDim2.new(0, 2, 0, 2)
GlowFrame.BackgroundTransparency = 1
GlowFrame.BorderSizePixel       = 0
GlowFrame.Parent                = MainFrame

local GlowStroke = Instance.new("UIStroke")
GlowStroke.Color        = Color3.fromRGB(35, 190, 120)
GlowStroke.Thickness    = 1
GlowStroke.Transparency = 0.85
GlowStroke.Parent       = GlowFrame

Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(0, 10)

-- Animated border pulse
task.spawn(function()
    while MainFrame.Parent do
        TweenService:Create(MainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Transparency = 0.2}):Play()
        task.wait(2)
        TweenService:Create(MainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Transparency = 0.6}):Play()
        task.wait(2)
    end
end)

-- ═══════════════════════════════════════════
--              HEADER
-- ═══════════════════════════════════════════
local Header = Instance.new("Frame")
Header.Name                  = "Header"
Header.Size                  = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3      = Color3.fromRGB(6, 14, 11)
Header.BackgroundTransparency = 0.1
Header.BorderSizePixel       = 0
Header.ZIndex                = 5
Header.Parent                = MainFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderFill = Instance.new("Frame")
HeaderFill.Size                  = UDim2.new(1, 0, 0, 12)
HeaderFill.Position              = UDim2.new(0, 0, 1, -12)
HeaderFill.BackgroundColor3      = Color3.fromRGB(6, 14, 11)
HeaderFill.BackgroundTransparency = 0.1
HeaderFill.BorderSizePixel       = 0
HeaderFill.ZIndex                = 4
HeaderFill.Parent                = Header

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size             = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position         = UDim2.new(0, 0, 1, -1)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
HeaderDivider.BackgroundTransparency = 0.6
HeaderDivider.BorderSizePixel  = 0
HeaderDivider.ZIndex           = 6
HeaderDivider.Parent           = Header

local Logo = Instance.new("TextLabel")
Logo.Text              = "⬡  WEZ HUB"
Logo.Size              = UDim2.new(0, 200, 1, 0)
Logo.Position          = UDim2.new(0, 14, 0, 0)
Logo.BackgroundTransparency = 1
Logo.TextColor3        = Color3.fromRGB(35, 210, 130)
Logo.Font              = Enum.Font.GothamBold
Logo.TextSize          = 15
Logo.TextXAlignment    = Enum.TextXAlignment.Left
Logo.ZIndex            = 6
Logo.Parent            = Header

local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Text              = "RightAlt  ·  Toggle"
KeybindLabel.Size              = UDim2.new(0, 160, 1, 0)
KeybindLabel.Position          = UDim2.new(0.5, -80, 0, 0)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.TextColor3        = Color3.fromRGB(100, 140, 120)
KeybindLabel.Font              = Enum.Font.Gotham
KeybindLabel.TextSize          = 11
KeybindLabel.ZIndex            = 6
KeybindLabel.Parent            = Header

-- Header buttons helper
local function MakeHeaderBtn(txt, xOffset, col)
    local btn = Instance.new("TextButton")
    btn.Text                  = txt
    btn.Size                  = UDim2.new(0, 28, 0, 28)
    btn.Position              = UDim2.new(1, xOffset, 0.5, -14)
    btn.BackgroundColor3      = Color3.fromRGB(20, 35, 28)
    btn.BackgroundTransparency = 0.4
    btn.TextColor3            = col
    btn.Font                  = Enum.Font.GothamBold
    btn.TextSize              = 14
    btn.AutoButtonColor       = false
    btn.ZIndex                = 7
    btn.Parent                = Header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play() end)
    return btn
end

local MinBtn   = MakeHeaderBtn("—", -70, Color3.fromRGB(180, 180, 180))
local CloseBtn = MakeHeaderBtn("✕", -36, Color3.fromRGB(255, 90, 90))

-- ═══════════════════════════════════════════
--              SIDEBAR
-- ═══════════════════════════════════════════
local Sidebar = Instance.new("Frame")
Sidebar.Name                  = "Sidebar"
Sidebar.Size                  = UDim2.new(0, 148, 1, -43)
Sidebar.Position              = UDim2.new(0, 0, 0, 43)
Sidebar.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
Sidebar.BackgroundTransparency = 0.92
Sidebar.BorderSizePixel       = 0
Sidebar.Parent                = MainFrame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size             = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position         = UDim2.new(1, 0, 0, 0)
SidebarDivider.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
SidebarDivider.BackgroundTransparency = 0.65
SidebarDivider.BorderSizePixel  = 0
SidebarDivider.Parent           = Sidebar

local ActiveIndicator = Instance.new("Frame")
ActiveIndicator.Size             = UDim2.new(0, 3, 0, 30)
ActiveIndicator.Position         = UDim2.new(0, 0, 0, 50)
ActiveIndicator.BackgroundColor3 = Color3.fromRGB(35, 210, 130)
ActiveIndicator.BorderSizePixel  = 0
ActiveIndicator.Parent           = Sidebar
Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(0, 4)

local TabDefs = {
    { name = "Home",         icon = "[H]", yPos = 25  },
    { name = "Combat",       icon = "[C]", yPos = 60  },
    { name = "Teleport",     icon = "[T]", yPos = 95  },
    { name = "Info",         icon = "[I]", yPos = 130 },
    { name = "Auto",         icon = "[A]", yPos = 165 },
    { name = "Interactables", icon = "[D]", yPos = 200 },
}
local TabButtons    = {}
local ContentPanels = {}

-- ═══════════════════════════════════════════
--              CONTENT AREA
-- ═══════════════════════════════════════════
local ContentArea = Instance.new("Frame")
ContentArea.Name                = "ContentArea"
ContentArea.Size                = UDim2.new(1, -156, 1, -51)
ContentArea.Position            = UDim2.new(0, 156, 0, 51)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel     = 0
ContentArea.Parent              = MainFrame

-- ═══════════════════════════════════════════
--              SHARED UI HELPERS
-- ═══════════════════════════════════════════
local function MakeSection(parent, title, yOff)
    local lbl = Instance.new("TextLabel")
    lbl.Text              = title
    lbl.Size              = UDim2.new(1, -16, 0, 20)
    lbl.Position          = UDim2.new(0, 8, 0, yOff)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3        = Color3.fromRGB(35, 210, 130)
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 11
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = parent

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -16, 0, 1)
    div.Position         = UDim2.new(0, 8, 0, yOff + 22)
    div.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
    div.BackgroundTransparency = 0.75
    div.BorderSizePixel  = 0
    div.Parent           = parent
end

local function MakeToggle(parent, label, yOff, default, onChange)
    local state = default or false

    local row = Instance.new("Frame")
    row.Size                = UDim2.new(1, -16, 0, 30)
    row.Position            = UDim2.new(0, 8, 0, yOff)
    row.BackgroundTransparency = 1
    row.Parent              = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text              = label
    lbl.Size              = UDim2.new(1, -54, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3        = Color3.fromRGB(200, 220, 210)
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 40, 0, 20)
    track.Position         = UDim2.new(1, -44, 0.5, -10)
    track.BackgroundColor3 = state and Color3.fromRGB(35, 190, 120) or Color3.fromRGB(40, 50, 45)
    track.BorderSizePixel  = 0
    track.Parent           = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.Parent           = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                = ""
    btn.Parent              = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Color3.fromRGB(35, 190, 120) or Color3.fromRGB(40, 50, 45)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        if onChange then onChange(state) end
    end)

    return row, function() return state end
end

local function MakeStatRow(parent, labelTxt, yOff)
    local row = Instance.new("Frame")
    row.Size                = UDim2.new(1, -16, 0, 26)
    row.Position            = UDim2.new(0, 8, 0, yOff)
    row.BackgroundColor3    = Color3.fromRGB(20, 35, 28)
    row.BackgroundTransparency = 0.5
    row.BorderSizePixel     = 0
    row.Parent              = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Text              = labelTxt
    lbl.Size              = UDim2.new(0.5, 0, 1, 0)
    lbl.Position          = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3        = Color3.fromRGB(100, 140, 120)
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 11
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local val = Instance.new("TextLabel")
    val.Text              = "—"
    val.Size              = UDim2.new(0.5, -8, 1, 0)
    val.Position          = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.TextColor3        = Color3.fromRGB(35, 210, 130)
    val.Font              = Enum.Font.GothamBold
    val.TextSize          = 11
    val.TextXAlignment    = Enum.TextXAlignment.Right
    val.Parent            = row

    return val
end

local function MakeOptionPicker(parent, label, options, default, yOff, onChange)
    local lbl = Instance.new("TextLabel")
    lbl.Text              = label
    lbl.Size              = UDim2.new(1, -16, 0, 18)
    lbl.Position          = UDim2.new(0, 8, 0, yOff)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3        = Color3.fromRGB(200, 220, 210)
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = parent

    local btnRow = Instance.new("Frame")
    btnRow.Size                = UDim2.new(1, -16, 0, 28)
    btnRow.Position            = UDim2.new(0, 8, 0, yOff + 20)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent              = parent

    local selected = default
    local btns     = {}
    local totalW   = 1 / #options
    local spacing  = 4

    for i, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size                = UDim2.new(totalW, i < #options and -spacing or 0, 1, 0)
        b.Position            = UDim2.new(totalW * (i-1), i > 1 and spacing or 0, 0, 0)
        b.BackgroundColor3    = (opt == default) and Color3.fromRGB(35, 190, 120) or Color3.fromRGB(25, 42, 34)
        b.BackgroundTransparency = (opt == default) and 0.3 or 0.4
        b.TextColor3          = (opt == default) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 160, 145)
        b.Text                = opt
        b.Font                = Enum.Font.GothamMedium
        b.TextSize            = 11
        b.AutoButtonColor     = false
        b.Parent              = btnRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        btns[opt] = b

        b.MouseButton1Click:Connect(function()
            selected = opt
            for o, rb in pairs(btns) do
                local active = (o == opt)
                TweenService:Create(rb, TweenInfo.new(0.15), {
                    BackgroundColor3     = active and Color3.fromRGB(35, 190, 120) or Color3.fromRGB(25, 42, 34),
                    BackgroundTransparency = active and 0.3 or 0.4,
                    TextColor3           = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,160,145),
                }):Play()
            end
            if onChange then onChange(opt) end
        end)
    end

    return function() return selected end
end

local function MakeKeybindPicker(parent, label, defaultKey, yOff, onChange)
    local currentKey = defaultKey
    local listening  = false

    local row = Instance.new("Frame")
    row.Size                = UDim2.new(1, -16, 0, 30)
    row.Position            = UDim2.new(0, 8, 0, yOff)
    row.BackgroundTransparency = 1
    row.Parent              = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text              = label
    lbl.Size              = UDim2.new(1, -90, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3        = Color3.fromRGB(200, 220, 210)
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size                = UDim2.new(0, 80, 0, 24)
    keyBtn.Position            = UDim2.new(1, -80, 0.5, -12)
    keyBtn.BackgroundColor3    = Color3.fromRGB(20, 38, 30)
    keyBtn.BackgroundTransparency = 0.3
    keyBtn.TextColor3          = Color3.fromRGB(35, 210, 130)
    keyBtn.Text                = tostring(currentKey):gsub("Enum.KeyCode.", "")
    keyBtn.Font                = Enum.Font.GothamBold
    keyBtn.TextSize            = 11
    keyBtn.AutoButtonColor     = false
    keyBtn.Parent              = row
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = Color3.fromRGB(35, 190, 120)
    stroke.Thickness    = 1
    stroke.Transparency = 0.6
    stroke.Parent       = keyBtn

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text      = "[ ... ]"
        keyBtn.TextColor3 = Color3.fromRGB(255, 210, 60)
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey        = input.KeyCode
            keyBtn.Text       = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            keyBtn.TextColor3 = Color3.fromRGB(35, 210, 130)
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
            listening = false
            if onChange then onChange(currentKey) end
        end
    end)

    return function() return currentKey end
end

local function MakeNumberInput(parent, label, defaultValue, minVal, maxVal, yOff, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 30)
    row.Position = UDim2.new(0, 8, 0, yOff)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 220, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.3, 0, 1, -4)
    box.Position = UDim2.new(0.7, 0, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(20, 38, 30)
    box.BackgroundTransparency = 0.3
    box.Text = tostring(defaultValue)
    box.TextColor3 = Color3.fromRGB(35, 210, 130)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local value = defaultValue

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            value = math.clamp(num, minVal, maxVal)
            box.Text = tostring(value)
            if onChange then onChange(value) end
        else
            box.Text = tostring(value)
        end
    end)

    return function() return value end
end

-- ═══════════════════════════════════════════
--              HOME PANEL (REMADE)
-- ═══════════════════════════════════════════

local HomePanel = Instance.new("Frame")
HomePanel.Name = "HomePanel"
HomePanel.Size = UDim2.new(1, 0, 1, 0)
HomePanel.BackgroundTransparency = 1
HomePanel.Visible = true
HomePanel.Parent = ContentArea
ContentPanels["Home"] = HomePanel

-- ═══════════════════════════════════════════
--              Home Panel Buttons n stuff
-- ═══════════════════════════════════════════

MakeSection(HomePanel, "PLAYER", 8)

local noclipToggle = MakeToggle(HomePanel, "No Clip", 40, false, function(state)
    _G.Noclip = state
end)

local noslowToggle = MakeToggle(HomePanel, "No Slow", 80, false, function(state)
    _G.NoSlow = state
end)


-- Noclip loop
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- No Slow (basic example)
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.NoSlow and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESPTrackedPlayers = {}

-- [[ THE CLEANED FUNCTION ]] --
local function DestroyESPForPlayer(username)
    local data = ESPTrackedPlayers[username]
    if not data then return end
    if data.conn then data.conn:Disconnect() end
    if data.billboard then data.billboard:Destroy() end
    ESPTrackedPlayers[username] = nil
end

local function CreateESPForPlayer(username)
    DestroyESPForPlayer(username)
    
    local target = Players:FindFirstChild(username)
    local char = target and target.Character
    local head = char and char:FindFirstChild("Head")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not head or not hum then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. username
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 60, 0, 7) -- Sleek, thin bar
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char

    local bg = Instance.new("Frame", billboard)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 2)

    local hpFill = Instance.new("Frame", bg)
    hpFill.Size = UDim2.new(1, -2, 1, -2)
    hpFill.Position = UDim2.new(0, 1, 0, 1)
    hpFill.BorderSizePixel = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

    local conn = RunService.RenderStepped:Connect(function()
        if not char.Parent or hum.Health <= 0 then
            billboard.Enabled = false
            return
        end

        billboard.Enabled = true
        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        hpFill.Size = UDim2.new(pct, -2, 1, -2)
        
        -- Transitions from Green (0.35) to Red (0)
        hpFill.BackgroundColor3 = Color3.fromHSV(pct * 0.35, 0.8, 0.9)
    end)

    ESPTrackedPlayers[username] = {billboard = billboard, conn = conn}
end
-- ═══════════════════════════════════════════
--              HOME PANEL - SELECTIVE ESP UI
-- ═══════════════════════════════════════════

MakeSection(HomePanel, "ESP", 130)

do
    -- Shared settings (per-session defaults)
    local globalESPSettings = { showHP = true, showKi = true }

    -- Helper: get all online player names
    local function GetAllPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        return names
    end

    -- Fuzzy match: returns players whose name contains the query (case insensitive)
    local function FuzzyMatch(query, names)
        query = query:lower()
        local starts, contains = {}, {}
        for _, name in ipairs(names) do
            local lower = name:lower()
            if lower:sub(1, #query) == query then
                table.insert(starts, name)
            elseif lower:find(query, 1, true) then
                table.insert(contains, name)
            end
        end
        for _, v in ipairs(contains) do table.insert(starts, v) end
        return starts
    end

    -- Search box
    local ESPSearchFrame = Instance.new("Frame")
    ESPSearchFrame.Size = UDim2.new(1, -16, 0, 32)
    ESPSearchFrame.Position = UDim2.new(0, 8, 0, 160)
    ESPSearchFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 28)
    ESPSearchFrame.BackgroundTransparency = 0.5
    ESPSearchFrame.BorderSizePixel = 0
    ESPSearchFrame.Parent = HomePanel
    Instance.new("UICorner", ESPSearchFrame).CornerRadius = UDim.new(0, 8)

    local ESPSearchBox = Instance.new("TextBox")
    ESPSearchBox.Size = UDim2.new(1, -80, 1, 0)
    ESPSearchBox.Position = UDim2.new(0, 8, 0, 0)
    ESPSearchBox.BackgroundTransparency = 1
    ESPSearchBox.PlaceholderText = "Search player..."
    ESPSearchBox.PlaceholderColor3 = Color3.fromRGB(100, 140, 120)
    ESPSearchBox.Text = ""
    ESPSearchBox.Font = Enum.Font.Gotham
    ESPSearchBox.TextSize = 11
    ESPSearchBox.TextColor3 = Color3.fromRGB(200, 220, 210)
    ESPSearchBox.TextXAlignment = Enum.TextXAlignment.Left
    ESPSearchBox.ClearTextOnFocus = false
    ESPSearchBox.Parent = ESPSearchFrame

    local ESPAddBtn = Instance.new("TextButton")
    ESPAddBtn.Size = UDim2.new(0, 64, 1, -8)
    ESPAddBtn.Position = UDim2.new(1, -70, 0, 4)
    ESPAddBtn.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
    ESPAddBtn.BackgroundTransparency = 0.3
    ESPAddBtn.Text = "TRACK"
    ESPAddBtn.Font = Enum.Font.GothamBold
    ESPAddBtn.TextSize = 10
    ESPAddBtn.TextColor3 = Color3.fromRGB(35, 210, 130)
    ESPAddBtn.AutoButtonColor = false
    ESPAddBtn.Parent = ESPSearchFrame
    Instance.new("UICorner", ESPAddBtn).CornerRadius = UDim.new(0, 6)

    -- Autocomplete dropdown
    local ESPDropFrame = Instance.new("Frame")
    ESPDropFrame.Size = UDim2.new(1, -16, 0, 0)
    ESPDropFrame.Position = UDim2.new(0, 8, 0, 194)
    ESPDropFrame.BackgroundColor3 = Color3.fromRGB(12, 22, 18)
    ESPDropFrame.BorderSizePixel = 0
    ESPDropFrame.ClipsDescendants = true
    ESPDropFrame.ZIndex = 30
    ESPDropFrame.Visible = false
    ESPDropFrame.Parent = HomePanel
    Instance.new("UICorner", ESPDropFrame).CornerRadius = UDim.new(0, 7)

    local ESPDropStroke = Instance.new("UIStroke")
    ESPDropStroke.Color = Color3.fromRGB(35, 190, 120)
    ESPDropStroke.Thickness = 1
    ESPDropStroke.Transparency = 0.4
    ESPDropStroke.Parent = ESPDropFrame

    local ESPDropLayout = Instance.new("UIListLayout")
    ESPDropLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ESPDropLayout.Parent = ESPDropFrame

    local ESPDropBtns = {}

    local function HideESPDrop()
        ESPDropFrame.Visible = false
        ESPDropFrame.Size = UDim2.new(1, -16, 0, 0)
        for _, b in ipairs(ESPDropBtns) do pcall(function() b:Destroy() end) end
        ESPDropBtns = {}
    end

    local function ShowESPDrop(matches)
        for _, b in ipairs(ESPDropBtns) do pcall(function() b:Destroy() end) end
        ESPDropBtns = {}
        if #matches == 0 then ESPDropFrame.Visible = false return end
        local show = math.min(#matches, 5)
        for i = 1, show do
            local name = matches[i]
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(12, 22, 18)
            btn.Text = ""
            btn.LayoutOrder = i
            btn.ZIndex = 31
            btn.Parent = ESPDropFrame

            local hl = Instance.new("Frame")
            hl.Size = UDim2.new(1, 0, 1, 0)
            hl.BackgroundColor3 = Color3.fromRGB(32, 58, 32)
            hl.BackgroundTransparency = 1
            hl.BorderSizePixel = 0
            hl.ZIndex = 31
            hl.Parent = btn

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 12
            lbl.TextColor3 = Color3.fromRGB(155, 228, 135)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 32
            lbl.Parent = btn

            btn.MouseEnter:Connect(function()
                TweenService:Create(hl, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(hl, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            end)
            local capName = name
            btn.MouseButton1Click:Connect(function()
                ESPSearchBox.Text = capName
                HideESPDrop()
            end)
            table.insert(ESPDropBtns, btn)
        end
        ESPDropFrame.Size = UDim2.new(1, -16, 0, show * 28)
        ESPDropFrame.Visible = true
    end

    ESPSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = ESPSearchBox.Text
        if q == "" then HideESPDrop() return end
        ShowESPDrop(FuzzyMatch(q, GetAllPlayerNames()))
    end)

    -- Global toggle row: HP ESP
    local HPToggleRow = Instance.new("Frame")
    HPToggleRow.Size = UDim2.new(1, -16, 0, 28)
    HPToggleRow.Position = UDim2.new(0, 8, 0, 338)
    HPToggleRow.BackgroundTransparency = 1
    HPToggleRow.Parent = HomePanel

    local HPToggleLbl = Instance.new("TextLabel")
    HPToggleLbl.Size = UDim2.new(0.65, 0, 1, 0)
    HPToggleLbl.BackgroundTransparency = 1
    HPToggleLbl.Text = "Show HP Bar"
    HPToggleLbl.TextColor3 = Color3.fromRGB(200, 220, 210)
    HPToggleLbl.Font = Enum.Font.Gotham
    HPToggleLbl.TextSize = 11
    HPToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
    HPToggleLbl.Parent = HPToggleRow

    local HPTrack = Instance.new("Frame")
    HPTrack.Size = UDim2.new(0, 40, 0, 20)
    HPTrack.Position = UDim2.new(1, -44, 0.5, -10)
    HPTrack.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
    HPTrack.BorderSizePixel = 0
    HPTrack.Parent = HPToggleRow
    Instance.new("UICorner", HPTrack).CornerRadius = UDim.new(1, 0)

    local HPKnob = Instance.new("Frame")
    HPKnob.Size = UDim2.new(0, 14, 0, 14)
    HPKnob.Position = UDim2.new(0, 23, 0.5, -7)
    HPKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HPKnob.BorderSizePixel = 0
    HPKnob.Parent = HPTrack
    Instance.new("UICorner", HPKnob).CornerRadius = UDim.new(1, 0)

    local HPToggleBtn = Instance.new("TextButton")
    HPToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    HPToggleBtn.BackgroundTransparency = 1
    HPToggleBtn.Text = ""
    HPToggleBtn.Parent = HPToggleRow

    HPToggleBtn.MouseButton1Click:Connect(function()
        globalESPSettings.showHP = not globalESPSettings.showHP
        local on = globalESPSettings.showHP
        TweenService:Create(HPTrack, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(35, 190, 120) or Color3.fromRGB(40, 50, 45)
        }):Play()
        TweenService:Create(HPKnob, TweenInfo.new(0.2), {
            Position = on and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        for _, data in pairs(ESPTrackedPlayers) do
            data.settings.showHP = on
        end
    end)

    -- Global toggle row: Ki ESP
    local KiToggleRow = Instance.new("Frame")
    KiToggleRow.Size = UDim2.new(1, -16, 0, 28)
    KiToggleRow.Position = UDim2.new(0, 8, 0, 368)
    KiToggleRow.BackgroundTransparency = 1
    KiToggleRow.Parent = HomePanel

    local KiToggleLbl = Instance.new("TextLabel")
    KiToggleLbl.Size = UDim2.new(0.65, 0, 1, 0)
    KiToggleLbl.BackgroundTransparency = 1
    KiToggleLbl.Text = "Show Ki Bar"
    KiToggleLbl.TextColor3 = Color3.fromRGB(200, 220, 210)
    KiToggleLbl.Font = Enum.Font.Gotham
    KiToggleLbl.TextSize = 11
    KiToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
    KiToggleLbl.Parent = KiToggleRow

    local KiTrack = Instance.new("Frame")
    KiTrack.Size = UDim2.new(0, 40, 0, 20)
    KiTrack.Position = UDim2.new(1, -44, 0.5, -10)
    KiTrack.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
    KiTrack.BorderSizePixel = 0
    KiTrack.Parent = KiToggleRow
    Instance.new("UICorner", KiTrack).CornerRadius = UDim.new(1, 0)

    local KiKnob = Instance.new("Frame")
    KiKnob.Size = UDim2.new(0, 14, 0, 14)
    KiKnob.Position = UDim2.new(0, 23, 0.5, -7)
    KiKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KiKnob.BorderSizePixel = 0
    KiKnob.Parent = KiTrack
    Instance.new("UICorner", KiKnob).CornerRadius = UDim.new(1, 0)

    local KiToggleBtn = Instance.new("TextButton")
    KiToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    KiToggleBtn.BackgroundTransparency = 1
    KiToggleBtn.Text = ""
    KiToggleBtn.Parent = KiToggleRow

    KiToggleBtn.MouseButton1Click:Connect(function()
        globalESPSettings.showKi = not globalESPSettings.showKi
        local on = globalESPSettings.showKi
        TweenService:Create(KiTrack, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(35, 190, 120) or Color3.fromRGB(40, 50, 45)
        }):Play()
        TweenService:Create(KiKnob, TweenInfo.new(0.2), {
            Position = on and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        for _, data in pairs(ESPTrackedPlayers) do
            data.settings.showKi = on
        end
    end)

    -- Tracked list frame
    local ESPListFrame = Instance.new("ScrollingFrame")
    ESPListFrame.Size = UDim2.new(1, -16, 0, 100)
    ESPListFrame.Position = UDim2.new(0, 8, 0, 230)
    ESPListFrame.BackgroundColor3 = Color3.fromRGB(18, 28, 22)
    ESPListFrame.BackgroundTransparency = 0.5
    ESPListFrame.BorderSizePixel = 0
    ESPListFrame.ScrollBarThickness = 2
    ESPListFrame.ScrollBarImageColor3 = Color3.fromRGB(35, 190, 120)
    ESPListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ESPListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ESPListFrame.Parent = HomePanel
    Instance.new("UICorner", ESPListFrame).CornerRadius = UDim.new(0, 8)

    local ESPListLayout = Instance.new("UIListLayout")
    ESPListLayout.Padding = UDim.new(0, 2)
    ESPListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ESPListLayout.Parent = ESPListFrame

    local ESPStatusLabel = Instance.new("TextLabel")
    ESPStatusLabel.Size = UDim2.new(1, -16, 0, 16)
    ESPStatusLabel.Position = UDim2.new(0, 8, 0, 334)
    ESPStatusLabel.BackgroundTransparency = 1
    ESPStatusLabel.Text = ""
    ESPStatusLabel.Font = Enum.Font.Gotham
    ESPStatusLabel.TextSize = 10
    ESPStatusLabel.TextColor3 = Color3.fromRGB(100, 140, 120)
    ESPStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    ESPStatusLabel.Parent = HomePanel

    local ESPRowButtons = {}

    local function RefreshESPList()
        for _, btn in ipairs(ESPRowButtons) do
            pcall(function() btn:Destroy() end)
        end
        ESPRowButtons = {}
        local i = 0
        for username in pairs(ESPTrackedPlayers) do
            i = i + 1
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundColor3 = Color3.fromRGB(25, 40, 32)
            row.BackgroundTransparency = 0.4
            row.BorderSizePixel = 0
            row.LayoutOrder = i
            row.Parent = ESPListFrame
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -38, 1, 0)
            nameLbl.Position = UDim2.new(0, 8, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = username
            nameLbl.Font = Enum.Font.GothamSemibold
            nameLbl.TextSize = 11
            nameLbl.TextColor3 = Color3.fromRGB(35, 210, 130)
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = row

            local removeBtn = Instance.new("TextButton")
            removeBtn.Size = UDim2.new(0, 28, 0, 20)
            removeBtn.Position = UDim2.new(1, -32, 0.5, -10)
            removeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            removeBtn.BackgroundTransparency = 0.4
            removeBtn.Text = "✕"
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = 10
            removeBtn.TextColor3 = Color3.fromRGB(255, 140, 140)
            removeBtn.AutoButtonColor = false
            removeBtn.Parent = row
            Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)

            local capName = username
            removeBtn.MouseButton1Click:Connect(function()
                DestroyESPForPlayer(capName)
                RefreshESPList()
                ESPStatusLabel.Text = "✖ Removed " .. capName
                ESPStatusLabel.TextColor3 = Color3.fromRGB(220, 100, 100)
            end)
            table.insert(ESPRowButtons, row)
        end
        if i == 0 then
            local emptyLbl = Instance.new("TextLabel")
            emptyLbl.Size = UDim2.new(1, 0, 0, 28)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Text = "  No players tracked"
            emptyLbl.Font = Enum.Font.Gotham
            emptyLbl.TextSize = 10
            emptyLbl.TextColor3 = Color3.fromRGB(100, 140, 120)
            emptyLbl.TextXAlignment = Enum.TextXAlignment.Left
            emptyLbl.Parent = ESPListFrame
            table.insert(ESPRowButtons, emptyLbl)
        end
    end

    RefreshESPList()

    local function TryAddESP(username)
        username = tostring(username):match("^%s*(.-)%s*$")
        if username == "" then
            ESPStatusLabel.Text = "⚠ Enter a username."
            ESPStatusLabel.TextColor3 = Color3.fromRGB(220, 180, 50)
            return
        end
        -- Fuzzy resolve to exact name if needed
        local exact = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower() == username:lower() then
                exact = p.Name break
            end
        end
        if not exact then
            local matches = FuzzyMatch(username, GetAllPlayerNames())
            if #matches > 0 then exact = matches[1] end
        end
        if not exact then
            ESPStatusLabel.Text = "✖ No player matching '" .. username .. "'"
            ESPStatusLabel.TextColor3 = Color3.fromRGB(220, 55, 38)
            return
        end
        if ESPTrackedPlayers[exact] then
            ESPStatusLabel.Text = "● Already tracking " .. exact
            ESPStatusLabel.TextColor3 = Color3.fromRGB(35, 210, 130)
            return
        end
        local targetPlayer = Players:FindFirstChild(exact)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
            ESPStatusLabel.Text = "✖ Character not ready."
            ESPStatusLabel.TextColor3 = Color3.fromRGB(220, 55, 38)
            return
        end
        local settings = { showHP = globalESPSettings.showHP, showKi = globalESPSettings.showKi }
        CreateESPForPlayer(exact, settings)
        RefreshESPList()
        ESPSearchBox.Text = ""
        HideESPDrop()
        ESPStatusLabel.Text = "✔ Tracking " .. exact
        ESPStatusLabel.TextColor3 = Color3.fromRGB(35, 210, 130)
        targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.8)
            if ESPTrackedPlayers[exact] then
                CreateESPForPlayer(exact, settings)
            end
        end)
    end

    ESPAddBtn.MouseButton1Click:Connect(function() TryAddESP(ESPSearchBox.Text) end)
    ESPSearchBox.FocusLost:Connect(function(enter)
        task.wait(0.12)
        HideESPDrop()
        if enter then TryAddESP(ESPSearchBox.Text) end
    end)

    Players.PlayerRemoving:Connect(function(player)
        local n = player.Name
        if ESPTrackedPlayers[n] then
            DestroyESPForPlayer(n)
            RefreshESPList()
        end
    end)
end

-- ═══════════════════════════════════════════
--              COMBAT PANEL
-- ═══════════════════════════════════════════
local CombatPanel = Instance.new("Frame")
CombatPanel.Name                = "CombatPanel"
CombatPanel.Size                = UDim2.new(1, 0, 1, 0)
CombatPanel.BackgroundTransparency = 1
CombatPanel.Visible             = false
CombatPanel.Parent              = ContentArea
ContentPanels["Combat"]         = CombatPanel

local LockStatusLabel = Instance.new("TextLabel")
LockStatusLabel.Size              = UDim2.new(1, -16, 0, 22)
LockStatusLabel.Position          = UDim2.new(0, 8, 0, 6)
LockStatusLabel.BackgroundTransparency = 1
LockStatusLabel.Text              = "● UNLOCKED"
LockStatusLabel.TextColor3        = Color3.fromRGB(180, 60, 60)
LockStatusLabel.Font              = Enum.Font.GothamBold
LockStatusLabel.TextSize          = 11
LockStatusLabel.TextXAlignment    = Enum.TextXAlignment.Right
LockStatusLabel.Parent            = CombatPanel

MakeSection(CombatPanel, "AIMLOCK", 8)
local _, GetAimlockEnabled = MakeToggle(CombatPanel, "Aimlock Enabled", 38, false)
local GetAimlockKey        = MakeKeybindPicker(CombatPanel, "Toggle Keybind", Enum.KeyCode.Q, 76)

MakeSection(CombatPanel, "TARGET TYPE", 116)
local GetTargetType = MakeOptionPicker(CombatPanel, "Target", {"Players", "NPCs", "Both"}, "NPCs", 142)

MakeSection(CombatPanel, "HIT PART", 200)
local GetHitPart = MakeOptionPicker(CombatPanel, "Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", 226)

-- ═══════════════════════════════════════════
--              TELEPORT PANEL
-- ═══════════════════════════════════════════
local TeleportPanel = Instance.new("Frame")
TeleportPanel.Name = "TeleportPanel"
TeleportPanel.Size = UDim2.new(1, 0, 1, 0)
TeleportPanel.BackgroundTransparency = 1
TeleportPanel.Visible = false
TeleportPanel.Parent = ContentArea
ContentPanels["Teleport"] = TeleportPanel

local TpStatusLabel = Instance.new("TextLabel")
TpStatusLabel.Size              = UDim2.new(1, -16, 0, 22)
TpStatusLabel.Position          = UDim2.new(0, 8, 0, 4)
TpStatusLabel.BackgroundTransparency = 1
TpStatusLabel.Text              = "● IDLE"
TpStatusLabel.TextColor3        = Color3.fromRGB(100, 140, 120)
TpStatusLabel.Font              = Enum.Font.GothamBold
TpStatusLabel.TextSize          = 11
TpStatusLabel.TextXAlignment    = Enum.TextXAlignment.Right
TpStatusLabel.Parent            = TeleportPanel

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size                = UDim2.new(1, -16, 0, 26)
CancelBtn.Position            = UDim2.new(0, 8, 1, -32)
CancelBtn.BackgroundColor3    = Color3.fromRGB(180, 50, 50)
CancelBtn.BackgroundTransparency = 0.3
CancelBtn.TextColor3          = Color3.fromRGB(255, 255, 255)
CancelBtn.Text                = "✕  Cancel Flight"
CancelBtn.Font                = Enum.Font.GothamBold
CancelBtn.TextSize            = 11
CancelBtn.AutoButtonColor     = false
CancelBtn.Visible             = false
CancelBtn.Parent              = TeleportPanel
Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 7)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size                  = UDim2.new(1, 0, 1, -62)
ScrollFrame.Position              = UDim2.new(0, 0, 0, 28)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel       = 0
ScrollFrame.ScrollBarThickness    = 3
ScrollFrame.ScrollBarImageColor3  = Color3.fromRGB(35, 190, 120)
ScrollFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y
ScrollFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent                = TeleportPanel

-- ═══════════════════════════════════════════
--              INFO PANEL (Player Info Check)
-- ═══════════════════════════════════════════
local InfoPanel = Instance.new("Frame")
InfoPanel.Name = "InfoPanel"
InfoPanel.Size = UDim2.new(1, 0, 1, 0)
InfoPanel.BackgroundTransparency = 1
InfoPanel.Visible = false
InfoPanel.Parent = ContentArea
ContentPanels["Info"] = InfoPanel

-- Search section
local SearchSection = Instance.new("Frame")
SearchSection.Size = UDim2.new(1, -16, 0, 70)
SearchSection.Position = UDim2.new(0, 8, 0, 8)
SearchSection.BackgroundTransparency = 1
SearchSection.Parent = InfoPanel

local SearchLabel = Instance.new("TextLabel")
SearchLabel.Size = UDim2.new(1, 0, 0, 20)
SearchLabel.Position = UDim2.new(0, 0, 0, 0)
SearchLabel.BackgroundTransparency = 1
SearchLabel.Text = "PLAYER SEARCH"
SearchLabel.TextColor3 = Color3.fromRGB(35, 210, 130)
SearchLabel.Font = Enum.Font.GothamBold
SearchLabel.TextSize = 11
SearchLabel.TextXAlignment = Enum.TextXAlignment.Left
SearchLabel.Parent = SearchSection

local SearchDivider = Instance.new("Frame")
SearchDivider.Size = UDim2.new(1, 0, 0, 1)
SearchDivider.Position = UDim2.new(0, 0, 0, 22)
SearchDivider.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
SearchDivider.BackgroundTransparency = 0.75
SearchDivider.BorderSizePixel = 0
SearchDivider.Parent = SearchSection

local SearchInputFrame = Instance.new("Frame")
SearchInputFrame.Size = UDim2.new(1, 0, 0, 36)
SearchInputFrame.Position = UDim2.new(0, 0, 0, 28)
SearchInputFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 28)
SearchInputFrame.BackgroundTransparency = 0.5
SearchInputFrame.BorderSizePixel = 0
SearchInputFrame.Parent = SearchSection
Instance.new("UICorner", SearchInputFrame).CornerRadius = UDim.new(0, 8)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -90, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Enter username..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 140, 120)
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextColor3 = Color3.fromRGB(200, 220, 210)
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchInputFrame

local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 74, 1, -8)
SearchBtn.Position = UDim2.new(1, -80, 0, 4)
SearchBtn.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
SearchBtn.BackgroundTransparency = 0.3
SearchBtn.Text = "CHECK"
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 11
SearchBtn.TextColor3 = Color3.fromRGB(35, 210, 130)
SearchBtn.AutoButtonColor = false
SearchBtn.Parent = SearchInputFrame
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 6)

-- Autocomplete Dropdown
local DROP_ROW_H = 30
local DropFrame = Instance.new("Frame")
DropFrame.Name = "Dropdown"
DropFrame.Size = UDim2.new(0, 0, 0, 0)
DropFrame.Position = UDim2.new(0, 8, 0, 106)
DropFrame.BackgroundColor3 = Color3.fromRGB(12, 22, 12)
DropFrame.BorderSizePixel = 0
DropFrame.ClipsDescendants = true
DropFrame.ZIndex = 30
DropFrame.Visible = false
DropFrame.Parent = InfoPanel
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 7)

local DropStroke = Instance.new("UIStroke")
DropStroke.Color = Color3.fromRGB(35, 190, 120)
DropStroke.Thickness = 1
DropStroke.Transparency = 0.3
DropStroke.Parent = DropFrame

local DropListLayout = Instance.new("UIListLayout")
DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropListLayout.Parent = DropFrame

local dropButtons = {}

local function getLiveNames()
    local names = {}
    local Live = workspace:FindFirstChild("Live")
    if Live then
        for _, child in ipairs(Live:GetChildren()) do
            table.insert(names, child.Name)
        end
    end
    return names
end

local function filterNames(query, allNames)
    query = query:lower()
    local starts, contains = {}, {}
    for _, name in ipairs(allNames) do
        local lower = name:lower()
        if lower:sub(1, #query) == query then
            table.insert(starts, name)
        elseif lower:find(query, 1, true) then
            table.insert(contains, name)
        end
    end
    for _, v in ipairs(contains) do 
        table.insert(starts, v) 
    end
    return starts
end

local function hideDropdown()
    if not DropFrame.Visible then return end
    TweenService:Create(DropFrame, TweenInfo.new(0.14), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(0.15, function()
        DropFrame.Visible = false
        for _, b in ipairs(dropButtons) do 
            b:Destroy() 
        end
        dropButtons = {}
    end)
end

local function showDropdown(names)
    for _, b in ipairs(dropButtons) do 
        b:Destroy() 
    end
    dropButtons = {}
    if #names == 0 then 
        DropFrame.Visible = false 
        return 
    end
    local maxShow = math.min(#names, 6)
    for i = 1, maxShow do
        local name = names[i]
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, DROP_ROW_H)
        Btn.BackgroundColor3 = Color3.fromRGB(12, 22, 12)
        Btn.Text = ""
        Btn.LayoutOrder = i
        Btn.ZIndex = 31
        Btn.Parent = DropFrame

        local Highlight = Instance.new("Frame")
        Highlight.Size = UDim2.new(1, 0, 1, 0)
        Highlight.BackgroundColor3 = Color3.fromRGB(32, 58, 32)
        Highlight.BackgroundTransparency = 1
        Highlight.BorderSizePixel = 0
        Highlight.ZIndex = 31
        Highlight.Parent = Btn

        local Pip = Instance.new("Frame")
        Pip.Size = UDim2.new(0, 3, 0.5, 0)
        Pip.Position = UDim2.new(0, 0, 0.25, 0)
        Pip.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
        Pip.BorderSizePixel = 0
        Pip.ZIndex = 32
        Pip.Parent = Btn
        Instance.new("UICorner", Pip).CornerRadius = UDim.new(0, 2)

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -16, 1, 0)
        NameLbl.Position = UDim2.new(0, 12, 0, 0)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text = name
        NameLbl.Font = Enum.Font.Gotham
        NameLbl.TextSize = 13
        NameLbl.TextColor3 = Color3.fromRGB(155, 228, 135)
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.ZIndex = 33
        NameLbl.Parent = Btn

        if i < maxShow then
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, -16, 0, 1)
            Div.Position = UDim2.new(0, 8, 1, -1)
            Div.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
            Div.BackgroundTransparency = 0.5
            Div.BorderSizePixel = 0
            Div.ZIndex = 32
            Div.Parent = Btn
        end

        Btn.MouseEnter:Connect(function() 
            TweenService:Create(Highlight, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play() 
        end)
        Btn.MouseLeave:Connect(function() 
            TweenService:Create(Highlight, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play() 
        end)
        Btn.MouseButton1Click:Connect(function()
            SearchBox.Text = name
            hideDropdown()
            task.spawn(lookupPlayer, name)
        end)
        table.insert(dropButtons, Btn)
    end

    local targetH = maxShow * DROP_ROW_H
    DropFrame.Size = UDim2.new(0, 380, 0, 0)
    DropFrame.Visible = true
    TweenService:Create(DropFrame, TweenInfo.new(0.18), {Size = UDim2.new(0, 380, 0, targetH)}):Play()
end

local InfoStatusLabel = Instance.new("TextLabel")
InfoStatusLabel.Size = UDim2.new(1, -16, 0, 16)
InfoStatusLabel.Position = UDim2.new(0, 8, 0, 82)
InfoStatusLabel.BackgroundTransparency = 1
InfoStatusLabel.Text = ""
InfoStatusLabel.Font = Enum.Font.Gotham
InfoStatusLabel.TextSize = 11
InfoStatusLabel.TextColor3 = Color3.fromRGB(100, 140, 120)
InfoStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoStatusLabel.Parent = InfoPanel

-- Scroll frame for player stats
local InfoScrollFrame = Instance.new("ScrollingFrame")
InfoScrollFrame.Size = UDim2.new(1, -16, 1, -108)
InfoScrollFrame.Position = UDim2.new(0, 8, 0, 102)
InfoScrollFrame.BackgroundTransparency = 1
InfoScrollFrame.BorderSizePixel = 0
InfoScrollFrame.ScrollBarThickness = 3
InfoScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(35, 190, 120)
InfoScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
InfoScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
InfoScrollFrame.Parent = InfoPanel

local InfoListLayout = Instance.new("UIListLayout")
InfoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoListLayout.Padding = UDim.new(0, 4)
InfoListLayout.Parent = InfoScrollFrame

-- Stats display helpers
local infoRows = {}

local function clearInfoRows()
    for _, row in ipairs(infoRows) do
        row:Destroy()
    end
    infoRows = {}
end

-- Parse JSON-like string to table
local function parseToLines(raw)
    local lines = {}
    if not raw or raw == "" or raw == "0" or raw == "nil" then
        return lines
    end
    
    -- Try to parse as {"key":"value","key2":"value2"} format
    for k, v in raw:gmatch('"([^"]+)"%s*:%s*"([^"]+)"') do
        table.insert(lines, k .. "  →  " .. v)
    end
    
    if #lines > 0 then return lines end
    
    -- Try to parse as ["item1","item2","item3"] format
    for v in raw:gmatch('"([^"]+)"') do
        table.insert(lines, v)
    end
    
    if #lines > 0 then return lines end
    
    -- Try to parse as comma-separated values
    for part in raw:gmatch("[^,]+") do
        local trimmed = part:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            table.insert(lines, trimmed)
        end
    end
    
    return lines
end

-- Expandable row for capsules/hotbar
local function makeExpandableRow(statName, rawValue, order, pipColor)
    local lines = parseToLines(rawValue)
    local isEmpty = (#lines == 0)
    
    local LINE_H = 20
    local PAD_V = 10
    local contentH = isEmpty and 40 or (#lines * LINE_H + PAD_V * 2)
    
    -- Outer wrapper
    local Wrapper = Instance.new("Frame")
    Wrapper.Size = UDim2.new(1, 0, 0, 38)
    Wrapper.BackgroundTransparency = 1
    Wrapper.BorderSizePixel = 0
    Wrapper.LayoutOrder = order
    Wrapper.ClipsDescendants = false
    Wrapper.Parent = InfoScrollFrame
    table.insert(infoRows, Wrapper)
    
    -- Header button
    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = Color3.fromRGB(22, 36, 22)
    Header.BackgroundTransparency = 0.4
    Header.Text = ""
    Header.BorderSizePixel = 0
    Header.ZIndex = 4
    Header.Parent = Wrapper
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)
    
    local hStroke = Instance.new("UIStroke")
    hStroke.Color = Color3.fromRGB(35, 190, 120)
    hStroke.Thickness = 1
    hStroke.Transparency = 0.7
    hStroke.Parent = Header
    
    local Pip = Instance.new("Frame")
    Pip.Size = UDim2.new(0, 3, 0.6, 0)
    Pip.Position = UDim2.new(0, 0, 0.2, 0)
    Pip.BackgroundColor3 = pipColor
    Pip.BorderSizePixel = 0
    Pip.Parent = Header
    Instance.new("UICorner", Pip).CornerRadius = UDim.new(0, 2)
    
    local HLbl = Instance.new("TextLabel")
    HLbl.Size = UDim2.new(0.65, -14, 1, 0)
    HLbl.Position = UDim2.new(0, 12, 0, 0)
    HLbl.BackgroundTransparency = 1
    HLbl.Text = statName
    HLbl.Font = Enum.Font.GothamBold
    HLbl.TextSize = 12
    HLbl.TextColor3 = pipColor
    HLbl.TextXAlignment = Enum.TextXAlignment.Left
    HLbl.Parent = Header
    
    -- Badge showing count
    local Badge = Instance.new("Frame")
    Badge.Size = UDim2.new(0, 28, 0, 20)
    Badge.Position = UDim2.new(1, -72, 0.5, -10)
    Badge.BackgroundColor3 = Color3.fromRGB(15, 35, 55)
    Badge.BorderSizePixel = 0
    Badge.Parent = Header
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 4)
    
    local BadgeStroke = Instance.new("UIStroke")
    BadgeStroke.Color = pipColor
    BadgeStroke.Thickness = 1
    BadgeStroke.Transparency = 0.6
    BadgeStroke.Parent = Badge
    
    local BadgeLbl = Instance.new("TextLabel")
    BadgeLbl.Size = UDim2.new(1, 0, 1, 0)
    BadgeLbl.BackgroundTransparency = 1
    BadgeLbl.Text = tostring(#lines)
    BadgeLbl.Font = Enum.Font.GothamBold
    BadgeLbl.TextSize = 10
    BadgeLbl.TextColor3 = pipColor
    BadgeLbl.TextXAlignment = Enum.TextXAlignment.Center
    BadgeLbl.Parent = Badge
    
    local HintLbl = Instance.new("TextLabel")
    HintLbl.Size = UDim2.new(0, 52, 1, 0)
    HintLbl.Position = UDim2.new(1, -52, 0, 0)
    HintLbl.BackgroundTransparency = 1
    HintLbl.Text = "▶  expand"
    HintLbl.Font = Enum.Font.Gotham
    HintLbl.TextSize = 10
    HintLbl.TextColor3 = Color3.fromRGB(100, 140, 120)
    HintLbl.TextXAlignment = Enum.TextXAlignment.Right
    HintLbl.Parent = Header
    
    -- Expandable panel
    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(1, 0, 0, 0)
    Panel.Position = UDim2.new(0, 0, 0, 40)
    Panel.BackgroundColor3 = Color3.fromRGB(10, 22, 32)
    Panel.BorderSizePixel = 0
    Panel.ClipsDescendants = true
    Panel.Parent = Wrapper
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 6)
    
    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(55, 130, 190)
    pStroke.Thickness = 1
    pStroke.Transparency = 0.7
    pStroke.Parent = Panel
    
    -- Populate panel lines
    if not isEmpty then
        for li, line in ipairs(lines) do
            local EL = Instance.new("TextLabel")
            EL.Size = UDim2.new(1, -20, 0, LINE_H)
            EL.Position = UDim2.new(0, 10, 0, PAD_V + (li - 1) * LINE_H)
            EL.BackgroundTransparency = 1
            EL.Text = "• " .. line
            EL.Font = Enum.Font.Gotham
            EL.TextSize = 11
            EL.TextColor3 = Color3.fromRGB(180, 228, 255)
            EL.TextXAlignment = Enum.TextXAlignment.Left
            EL.TextWrapped = true
            EL.TextTruncate = Enum.TextTruncate.AtEnd
            EL.Parent = Panel
        end
    else
        local NL = Instance.new("TextLabel")
        NL.Size = UDim2.new(1, -20, 0, 36)
        NL.Position = UDim2.new(0, 10, 0, 0)
        NL.BackgroundTransparency = 1
        NL.Text = "No items found"
        NL.Font = Enum.Font.Gotham
        NL.TextSize = 11
        NL.TextColor3 = Color3.fromRGB(160, 80, 80)
        NL.TextXAlignment = Enum.TextXAlignment.Left
        NL.Parent = Panel
    end
    
    -- Toggle functionality
    local expanded = false
    Header.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            Wrapper.Size = UDim2.new(1, 0, 0, 38 + 4 + contentH)
            TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, contentH)}):Play()
            HintLbl.Text = "▼  collapse"
            TweenService:Create(HintLbl, TweenInfo.new(0.15), {TextColor3 = pipColor}):Play()
            TweenService:Create(Header, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(12, 25, 40)}):Play()
            hStroke.Color = Color3.fromRGB(55, 130, 190)
            hStroke.Transparency = 0.3
        else
            TweenService:Create(Panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(0.19, function() 
                if not expanded then
                    Wrapper.Size = UDim2.new(1, 0, 0, 38)
                end
            end)
            HintLbl.Text = "▶  expand"
            TweenService:Create(HintLbl, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(100, 140, 120)}):Play()
            TweenService:Create(Header, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 36, 22)}):Play()
            hStroke.Color = Color3.fromRGB(35, 190, 120)
            hStroke.Transparency = 0.7
        end
    end)
    
    Header.MouseEnter:Connect(function()
        if not expanded then 
            TweenService:Create(Header, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 40, 26)}):Play()
        end
    end)
    Header.MouseLeave:Connect(function()
        if not expanded then 
            TweenService:Create(Header, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 36, 22)}):Play()
        end
    end)
    
    return Wrapper
end

local function makeInfoStatRow(statName, statValue, order, labelColor)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(22, 36, 22)
    Row.BackgroundTransparency = 0.4
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = InfoScrollFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(35, 190, 120)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.Parent = Row
    
    local Pip = Instance.new("Frame")
    Pip.Size = UDim2.new(0, 3, 0.6, 0)
    Pip.Position = UDim2.new(0, 0, 0.2, 0)
    Pip.BackgroundColor3 = labelColor or Color3.fromRGB(80, 220, 60)
    Pip.BorderSizePixel = 0
    Pip.Parent = Row
    Instance.new("UICorner", Pip).CornerRadius = UDim.new(0, 2)
    
    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size = UDim2.new(0.52, -16, 1, 0)
    NameLbl.Position = UDim2.new(0, 12, 0, 0)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = statName
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 12
    NameLbl.TextColor3 = Color3.fromRGB(240, 190, 50)
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.Parent = Row
    
    local displayVal = tostring(statValue)
    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size = UDim2.new(0.48, -10, 1, 0)
    ValLbl.Position = UDim2.new(0.52, 0, 0, 0)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text = displayVal
    ValLbl.Font = Enum.Font.Gotham
    ValLbl.TextSize = 12
    ValLbl.TextColor3 = (displayVal == "None" or displayVal == "—") and Color3.fromRGB(160, 80, 80) or Color3.fromRGB(225, 240, 225)
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Parent = Row
    
    table.insert(infoRows, Row)
    return Row
end

local function makeInfoLevelBanner(level, order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 48)
    Row.BackgroundColor3 = Color3.fromRGB(30, 20, 5)
    Row.BackgroundTransparency = 0.3
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = InfoScrollFrame
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(200, 160, 30)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.3
    Stroke.Parent = Row
    
    local Stars = Instance.new("TextLabel")
    Stars.Size = UDim2.new(0, 60, 1, 0)
    Stars.Position = UDim2.new(0, 10, 0, 0)
    Stars.BackgroundTransparency = 1
    Stars.Text = "★  ★  ★"
    Stars.Font = Enum.Font.GothamBold
    Stars.TextSize = 10
    Stars.TextColor3 = Color3.fromRGB(200, 155, 25)
    Stars.TextXAlignment = Enum.TextXAlignment.Left
    Stars.Parent = Row
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0, 80, 1, 0)
    Lbl.Position = UDim2.new(0, 70, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "LEVEL"
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 13
    Lbl.TextColor3 = Color3.fromRGB(240, 190, 40)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row
    
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0, 110, 1, 0)
    Val.Position = UDim2.new(1, -118, 0, 0)
    Val.BackgroundTransparency = 1
    Val.Text = tostring(level)
    Val.Font = Enum.Font.GothamBold
    Val.TextSize = 22
    Val.TextColor3 = Color3.fromRGB(255, 215, 50)
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.Parent = Row
    
    table.insert(infoRows, Row)
    return Row
end

-- Main lookup function
local function lookupPlayer(username)
    username = tostring(username):match("^%s*(.-)%s*$")
    if username == "" then
        InfoStatusLabel.Text = "⚠ Enter a username."
        InfoStatusLabel.TextColor3 = Color3.fromRGB(220, 55, 38)
        return
    end
    
    clearInfoRows()
    InfoStatusLabel.Text = "Searching..."
    InfoStatusLabel.TextColor3 = Color3.fromRGB(100, 140, 120)
    
    local Live = workspace:FindFirstChild("Live")
    if not Live then
        InfoStatusLabel.Text = "✖ 'Live' not found in Workspace."
        InfoStatusLabel.TextColor3 = Color3.fromRGB(220, 55, 38)
        return
    end
    
    local pFolder = Live:FindFirstChild(username)
    if not pFolder then
        InfoStatusLabel.Text = "✖ '" .. username .. "' not in Workspace.Live."
        InfoStatusLabel.TextColor3 = Color3.fromRGB(220, 55, 38)
        return
    end
    
    InfoStatusLabel.Text = "✔ " .. username
    InfoStatusLabel.TextColor3 = Color3.fromRGB(35, 210, 130)
    local order = 0
    
    -- Level
    local LevelVal = pFolder:FindFirstChild("Level")
    order = order + 1
    makeInfoLevelBanner(LevelVal and LevelVal.Value or "?", order)
    
    -- Combat Stats
    local StatsFolder = pFolder:FindFirstChild("Stats")
    if StatsFolder then
        for i, key in ipairs(STAT_KEYS) do
            order = order + 1
            local v = StatsFolder:FindFirstChild(key)
            makeInfoStatRow(key, v and tostring(v.Value) or "—", order, Color3.fromRGB(80, 220, 60))
        end
    else
        order = order + 1
        makeInfoStatRow("Stats", "— folder not found —", order, Color3.fromRGB(220, 55, 38))
    end
    
    -- ReplicatedStats
    local rPlayer = Players:FindFirstChild(username)
    local RepStats = rPlayer and rPlayer:FindFirstChild("ReplicatedStats")
    
    if RepStats then
        -- Accessories
        for i, key in ipairs({"Accessory1", "Accessory2", "Accessory3"}) do
            order = order + 1
            local v = RepStats:FindFirstChild(key)
            local raw = v and tostring(v.Value) or ""
            local display = (raw == "" or raw == "0" or raw == "nil") and "None" or raw
            makeInfoStatRow(key, display, order, Color3.fromRGB(255, 140, 200))
        end
        
        -- Zenni
        order = order + 1
        local zv = RepStats:FindFirstChild("Zenni")
        makeInfoStatRow("Zenni", zv and tostring(zv.Value) or "—", order, Color3.fromRGB(240, 190, 40))
        
        -- EquippedCapsules (Expandable)
        order = order + 1
        local cv = RepStats:FindFirstChild("EquippedCapsules")
        makeExpandableRow("Equipped Capsules", cv and cv.Value or "", order, Color3.fromRGB(100, 200, 255))
        
        -- Hotbar (Expandable)
        order = order + 1
        local hv = RepStats:FindFirstChild("Hotbar")
        makeExpandableRow("Hotbar", hv and hv.Value or "", order, Color3.fromRGB(140, 220, 140))
    else
        order = order + 1
        makeInfoStatRow("ReplicatedStats", "— not accessible —", order, Color3.fromRGB(220, 55, 38))
    end
end

-- Search box events with autocomplete
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text
    if q == "" then 
        hideDropdown() 
        return 
    end
    showDropdown(filterNames(q, getLiveNames()))
end)

SearchBox.FocusLost:Connect(function(enter)
    if enter then 
        hideDropdown() 
        lookupPlayer(SearchBox.Text) 
    end
end)

SearchBtn.MouseButton1Click:Connect(function()
    hideDropdown() 
    lookupPlayer(SearchBox.Text)
end)

-- Click outside to hide dropdown
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local dropAbsPos = DropFrame.AbsolutePosition
        local dropSize = DropFrame.AbsoluteSize
        
        if not (mousePos.X >= dropAbsPos.X and mousePos.X <= dropAbsPos.X + dropSize.X and
                mousePos.Y >= dropAbsPos.Y and mousePos.Y <= dropAbsPos.Y + dropSize.Y) then
            hideDropdown()
        end
    end
end)

-- ═══════════════════════════════════════════
--              AUTO PANEL (AUTOFARMER)
-- ═══════════════════════════════════════════
local AutoPanel = Instance.new("Frame")
AutoPanel.Name = "AutoPanel"
AutoPanel.Size = UDim2.new(1, 0, 1, 0)
AutoPanel.BackgroundTransparency = 1
AutoPanel.Visible = false
AutoPanel.Parent = ContentArea
ContentPanels["Auto"] = AutoPanel

-- Create a scrolling frame for the autofarmer UI
local AutoScroll = Instance.new("ScrollingFrame")
AutoScroll.Size = UDim2.new(1, 0, 1, 0)
AutoScroll.BackgroundTransparency = 1
AutoScroll.BorderSizePixel = 0
AutoScroll.ScrollBarThickness = 3
AutoScroll.ScrollBarImageColor3 = Color3.fromRGB(35, 190, 120)
AutoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
AutoScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AutoScroll.Parent = AutoPanel

local AutoLayout = Instance.new("UIListLayout")
AutoLayout.Padding = UDim.new(0, 8)
AutoLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoLayout.Parent = AutoScroll

-- Status Display
local StatusFrameAuto = Instance.new("Frame")
StatusFrameAuto.Size = UDim2.new(1, -16, 0, 48)
StatusFrameAuto.BackgroundColor3 = Color3.fromRGB(22, 36, 22)
StatusFrameAuto.BackgroundTransparency = 0.4
StatusFrameAuto.Parent = AutoScroll
Instance.new("UICorner", StatusFrameAuto).CornerRadius = UDim.new(0, 8)

local StatusTextAuto = Instance.new("TextLabel")
StatusTextAuto.Size = UDim2.new(1, 0, 1, 0)
StatusTextAuto.BackgroundTransparency = 1
StatusTextAuto.Text = "● SYSTEM: IDLE"
StatusTextAuto.TextColor3 = Color3.fromRGB(220, 100, 100)
StatusTextAuto.Font = Enum.Font.GothamBold
StatusTextAuto.TextSize = 13
StatusTextAuto.Parent = StatusFrameAuto

-- Target Display
local TargetFrameAuto = Instance.new("Frame")
TargetFrameAuto.Size = UDim2.new(1, -16, 0, 48)
TargetFrameAuto.BackgroundColor3 = Color3.fromRGB(22, 36, 22)
TargetFrameAuto.BackgroundTransparency = 0.4
TargetFrameAuto.Parent = AutoScroll
Instance.new("UICorner", TargetFrameAuto).CornerRadius = UDim.new(0, 8)

local TargetTextAuto = Instance.new("TextLabel")
TargetTextAuto.Size = UDim2.new(1, 0, 1, 0)
TargetTextAuto.BackgroundTransparency = 1
TargetTextAuto.Text = "🎯 Target: None"
TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
TargetTextAuto.Font = Enum.Font.GothamSemibold
TargetTextAuto.TextSize = 12
TargetTextAuto.Parent = TargetFrameAuto

-- HP Bar
local HPFrameAuto = Instance.new("Frame")
HPFrameAuto.Size = UDim2.new(1, -16, 0, 38)
HPFrameAuto.BackgroundTransparency = 1
HPFrameAuto.Parent = AutoScroll

local HPLabelAuto = Instance.new("TextLabel")
HPLabelAuto.Size = UDim2.new(1, 0, 0, 20)
HPLabelAuto.BackgroundTransparency = 1
HPLabelAuto.Text = "❤️ HP: 100%"
HPLabelAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
HPLabelAuto.Font = Enum.Font.Gotham
HPLabelAuto.TextSize = 11
HPLabelAuto.TextXAlignment = Enum.TextXAlignment.Left
HPLabelAuto.Parent = HPFrameAuto

local HPBarBG = Instance.new("Frame")
HPBarBG.Size = UDim2.new(1, 0, 0, 6)
HPBarBG.Position = UDim2.new(0, 0, 0, 22)
HPBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
HPBarBG.BorderSizePixel = 0
HPBarBG.Parent = HPFrameAuto
Instance.new("UICorner", HPBarBG).CornerRadius = UDim.new(1, 0)

local HPBarFill = Instance.new("Frame")
HPBarFill.Size = UDim2.new(1, 0, 0, 6)
HPBarFill.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
HPBarFill.BorderSizePixel = 0
HPBarFill.Parent = HPBarBG
Instance.new("UICorner", HPBarFill).CornerRadius = UDim.new(1, 0)

-- Movement Settings Section
local MoveSection = Instance.new("Frame")
MoveSection.Size = UDim2.new(1, -16, 0, 80)
MoveSection.BackgroundTransparency = 1
MoveSection.Parent = AutoScroll

local MoveHeaderAuto = Instance.new("TextLabel")
MoveHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
MoveHeaderAuto.BackgroundTransparency = 1
MoveHeaderAuto.Text = "🌀 MOVEMENT SETTINGS"
MoveHeaderAuto.TextColor3 = Color3.fromRGB(100, 200, 255)
MoveHeaderAuto.Font = Enum.Font.GothamBold
MoveHeaderAuto.TextSize = 12
MoveHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
MoveHeaderAuto.Parent = MoveSection

local CircleRadiusInput = MakeNumberInput(MoveSection, "Circle Radius", 12, 5, 30, 28, function(v) FarmerSettings.CircleRadius = v end)
local CircleSpeedInput = MakeNumberInput(MoveSection, "Circle Speed", 0.25, 0.1, 2, 54, function(v) FarmerSettings.CircleSpeed = v end)

-- Combat Settings Section
local CombatSection = Instance.new("Frame")
CombatSection.Size = UDim2.new(1, -16, 0, 110)
CombatSection.BackgroundTransparency = 1
CombatSection.Parent = AutoScroll

local CombatHeaderAuto = Instance.new("TextLabel")
CombatHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
CombatHeaderAuto.BackgroundTransparency = 1
CombatHeaderAuto.Text = "⚔️ COMBAT SETTINGS"
CombatHeaderAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
CombatHeaderAuto.Font = Enum.Font.GothamBold
CombatHeaderAuto.TextSize = 12
CombatHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
CombatHeaderAuto.Parent = CombatSection

local M1DelayInput = MakeNumberInput(CombatSection, "M1 Delay (ms)", 80, 20, 500, 28, function(v) FarmerSettings.M1Delay = v / 1000 end)
local M2DelayInput = MakeNumberInput(CombatSection, "M2 Delay (ms)", 450, 100, 1000, 54, function(v) FarmerSettings.M2Delay = v / 1000 end)

-- M2 Toggle
local M2Row = Instance.new("Frame")
M2Row.Size = UDim2.new(1, -16, 0, 30)
M2Row.Position = UDim2.new(0, 8, 0, 80)
M2Row.BackgroundTransparency = 1
M2Row.Parent = CombatSection

local M2Label = Instance.new("TextLabel")
M2Label.Size = UDim2.new(0.6, 0, 1, 0)
M2Label.BackgroundTransparency = 1
M2Label.Text = "Use M2 Attacks"
M2Label.TextColor3 = Color3.fromRGB(200, 220, 210)
M2Label.Font = Enum.Font.Gotham
M2Label.TextSize = 12
M2Label.TextXAlignment = Enum.TextXAlignment.Left
M2Label.Parent = M2Row

local M2ToggleBtn = Instance.new("TextButton")
M2ToggleBtn.Size = UDim2.new(0.3, 0, 1, -4)
M2ToggleBtn.Position = UDim2.new(0.7, 0, 0, 2)
M2ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
M2ToggleBtn.BackgroundTransparency = 0.3
M2ToggleBtn.Text = "ON"
M2ToggleBtn.TextColor3 = Color3.fromRGB(35, 210, 130)
M2ToggleBtn.Font = Enum.Font.GothamBold
M2ToggleBtn.TextSize = 11
M2ToggleBtn.AutoButtonColor = false
M2ToggleBtn.Parent = M2Row
Instance.new("UICorner", M2ToggleBtn).CornerRadius = UDim.new(0, 6)

M2ToggleBtn.MouseButton1Click:Connect(function()
    FarmerSettings.UseM2 = not FarmerSettings.UseM2
    if FarmerSettings.UseM2 then
        M2ToggleBtn.Text = "ON"
        M2ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
        M2ToggleBtn.TextColor3 = Color3.fromRGB(35, 210, 130)
    else
        M2ToggleBtn.Text = "OFF"
        M2ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        M2ToggleBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
    end
end)

-- Key Press Settings Section
local KeySection = Instance.new("Frame")
KeySection.Size = UDim2.new(1, -16, 0, 60)
KeySection.BackgroundTransparency = 1
KeySection.Parent = AutoScroll

local KeyHeaderAuto = Instance.new("TextLabel")
KeyHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
KeyHeaderAuto.BackgroundTransparency = 1
KeyHeaderAuto.Text = "⌨️ ABILITY KEY PRESSES (R, T, Y)"
KeyHeaderAuto.TextColor3 = Color3.fromRGB(255, 200, 100)
KeyHeaderAuto.Font = Enum.Font.GothamBold
KeyHeaderAuto.TextSize = 11
KeyHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
KeyHeaderAuto.Parent = KeySection

local KeyDelayInput = MakeNumberInput(KeySection, "Key Press Delay (ms)", 350, 100, 1000, 28, function(v) FarmerSettings.KeyPressDelay = v / 1000 end)

-- Escape Settings Section
local EscapeSection = Instance.new("Frame")
EscapeSection.Size = UDim2.new(1, -16, 0, 120)
EscapeSection.BackgroundTransparency = 1
EscapeSection.Parent = AutoScroll

local EscapeHeaderAuto = Instance.new("TextLabel")
EscapeHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
EscapeHeaderAuto.BackgroundTransparency = 1
EscapeHeaderAuto.Text = "🛡️ ESCAPE PROTOCOL"
EscapeHeaderAuto.TextColor3 = Color3.fromRGB(255, 120, 120)
EscapeHeaderAuto.Font = Enum.Font.GothamBold
EscapeHeaderAuto.TextSize = 12
EscapeHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
EscapeHeaderAuto.Parent = EscapeSection

local EscapeHPInput = MakeNumberInput(EscapeSection, "Escape when HP <", 45, 10, 90, 28, function(v) FarmerSettings.EscapeHPThreshold = v end)
local ReturnHPInput = MakeNumberInput(EscapeSection, "Return when HP >", 75, 30, 100, 54, function(v) FarmerSettings.ReturnHPThreshold = v end)
local EscapeDistInput = MakeNumberInput(EscapeSection, "Escape Distance", 3500, 1000, 10000, 80, function(v) FarmerSettings.EscapeDistance = v end)

-- NPC List Section
local NPCListSection = Instance.new("Frame")
NPCListSection.Size = UDim2.new(1, -16, 0, 180)
NPCListSection.BackgroundTransparency = 1
NPCListSection.Parent = AutoScroll

local NPCHeaderAuto = Instance.new("TextLabel")
NPCHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
NPCHeaderAuto.BackgroundTransparency = 1
NPCHeaderAuto.Text = "📋 NEARBY NPCS"
NPCHeaderAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
NPCHeaderAuto.Font = Enum.Font.GothamBold
NPCHeaderAuto.TextSize = 12
NPCHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
NPCHeaderAuto.Parent = NPCListSection

local NPCScrollFrame = Instance.new("ScrollingFrame")
NPCScrollFrame.Size = UDim2.new(1, 0, 0, 150)
NPCScrollFrame.Position = UDim2.new(0, 0, 0, 28)
NPCScrollFrame.BackgroundColor3 = Color3.fromRGB(18, 28, 22)
NPCScrollFrame.BackgroundTransparency = 0.5
NPCScrollFrame.BorderSizePixel = 0
NPCScrollFrame.ScrollBarThickness = 3
NPCScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(35, 190, 120)
NPCScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
NPCScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
NPCScrollFrame.Parent = NPCListSection
Instance.new("UICorner", NPCScrollFrame).CornerRadius = UDim.new(0, 8)

local NPCListLayoutAuto = Instance.new("UIListLayout")
NPCListLayoutAuto.Padding = UDim.new(0, 4)
NPCListLayoutAuto.SortOrder = Enum.SortOrder.LayoutOrder
NPCListLayoutAuto.Parent = NPCScrollFrame

local NPCToggleButtons = {}

-- Control Button
local ControlBtnAuto = Instance.new("TextButton")
ControlBtnAuto.Size = UDim2.new(1, -16, 0, 48)
ControlBtnAuto.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ControlBtnAuto.Text = "▶ START FARMING"
ControlBtnAuto.TextColor3 = Color3.fromRGB(255, 255, 255)
ControlBtnAuto.Font = Enum.Font.GothamBold
ControlBtnAuto.TextSize = 14
ControlBtnAuto.AutoButtonColor = false
ControlBtnAuto.Parent = AutoScroll
Instance.new("UICorner", ControlBtnAuto).CornerRadius = UDim.new(0, 12)

-- AutoFarmer Helper Functions
local function GetAutoChar()
    return LocalPlayer.Character
end

local function GetAutoHRP()
    local c = GetAutoChar()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local function GetAutoHumanoid()
    local c = GetAutoChar()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

local function GetPlayerHealthAuto()
    local hum = GetAutoHumanoid()
    if hum and hum.MaxHealth > 0 then
        return (hum.Health / hum.MaxHealth) * 100
    end
    return 100
end

local function UpdateHPBarAuto()
    local hp = GetPlayerHealthAuto()
    local width = (hp / 100)
    HPBarFill.Size = UDim2.new(width, 0, 0, 6)
    HPLabelAuto.Text = "❤️ HP: " .. string.format("%.1f", hp) .. "%"
    
    if hp < 40 then
        HPBarFill.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    elseif hp < 70 then
        HPBarFill.BackgroundColor3 = Color3.fromRGB(220, 180, 60)
    else
        HPBarFill.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    end
end

-- Press key function
local function PressKeyAuto(keyCode)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(FarmerSettings.KeyPressDuration)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

-- M1 Attack
local function PressM1Auto()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- M2 Attack
local function PressM2Auto()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

-- Ki charge toggle
local function ToggleKiChargeAuto()
    PressKeyAuto(Enum.KeyCode.X)
end

-- Get sorted NPCs
local function GetSortedNPCsAuto()
    local npcs = {}
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return npcs end
    
    local hrp = GetAutoHRP()
    if not hrp then return npcs end
    
    for _, model in ipairs(enemiesFolder:GetChildren()) do
        if model:IsA("Model") then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
                if targetPart then
                    local dist = (targetPart.Position - hrp.Position).Magnitude
                    table.insert(npcs, {
                        model = model,
                        part = targetPart,
                        name = model.Name,
                        distance = dist
                    })
                end
            end
        end
    end
    
    table.sort(npcs, function(a, b) return a.distance < b.distance end)
    return npcs
end


-- Add this AFTER GetSortedNPCsAuto() function
local function FindNextSameNPC(currentTargetModel)
    if not currentTargetModel then return nil end
    
    local targetName = currentTargetModel.Name
    local npcs = GetSortedNPCsAuto()
    
    -- Find the index of the current target
    local currentIndex = nil
    for i, npc in ipairs(npcs) do
        if npc.model == currentTargetModel then
            currentIndex = i
            break
        end
    end
    
    -- Look for next NPC with same name (starting after current)
    if currentIndex then
        for i = currentIndex + 1, #npcs do
            if npcs[i].name == targetName and npcs[i].model:FindFirstChildOfClass("Humanoid") 
               and npcs[i].model:FindFirstChildOfClass("Humanoid").Health > 0 then
                return npcs[i]
            end
        end
        
        -- If none found after, loop back to the beginning
        for i = 1, currentIndex - 1 do
            if npcs[i].name == targetName and npcs[i].model:FindFirstChildOfClass("Humanoid") 
               and npcs[i].model:FindFirstChildOfClass("Humanoid").Health > 0 then
                return npcs[i]
            end
        end
    end
    
    return nil
end

-- Add this function after FindNextSameNPC
local function WaitForRespawnAuto(targetName)
    if AutoFarmer.WaitingForRespawn then return end
    
    AutoFarmer.WaitingForRespawn = true
    AutoFarmer.LastTargetName = targetName
    
    StatusTextAuto.Text = "⏳ WAITING FOR " .. targetName .. " TO RESPAWN"
    StatusTextAuto.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Stop combat loop while waiting
    StopCombatLoopAuto()
    
    -- Check periodically for respawn
    local checkConnection = RunService.Heartbeat:Connect(function()
        local npcs = GetSortedNPCsAuto()
        for _, npc in ipairs(npcs) do
            if npc.name == targetName then
                -- Found respawned NPC
                checkConnection:Disconnect()
                AutoFarmer.WaitingForRespawn = false
                AutoFarmer.CurrentTarget = npc.part
                AutoFarmer.CurrentTargetModel = npc.model
                TargetTextAuto.Text = "🎯 Target: " .. npc.name
                TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                StatusTextAuto.Text = "● FARMING: ACTIVE"
                StatusTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                StartCombatLoopAuto()
                return
            end
        end
    end)
    
    -- Store connection to clean up later
    AutoFarmer.RespawnCheckConnection = checkConnection
end
-- Update NPC list in Auto panel
local function UpdateNPCListAuto()
    for _, btn in ipairs(NPCToggleButtons) do
        pcall(function() btn:Destroy() end)
    end
    NPCToggleButtons = {}
    
    local npcs = GetSortedNPCsAuto()
    local canvasHeight = math.max(150, #npcs * 38)
    NPCScrollFrame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    if #npcs == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 35)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "  🔍 No NPCs found in vicinity"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 11
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.Parent = NPCScrollFrame
        table.insert(NPCToggleButtons, emptyLabel)
        return
    end
    
    for _, npc in ipairs(npcs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(30, 38, 34)
        btn.BackgroundTransparency = 0.4
        btn.Text = ""
        btn.Parent = NPCScrollFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(1, -10, 1, 0)
        nameText.Position = UDim2.new(0, 8, 0, 0)
        nameText.BackgroundTransparency = 1
        nameText.Text = npc.name .. "  [" .. math.floor(npc.distance) .. "s]"
        nameText.TextColor3 = Color3.fromRGB(210, 210, 230)
        nameText.Font = Enum.Font.GothamSemibold
        nameText.TextSize = 11
        nameText.TextXAlignment = Enum.TextXAlignment.Left
        nameText.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if not AutoFarmer.IsFarming then
                AutoFarmer.CurrentTarget = npc.part
                AutoFarmer.CurrentTargetModel = npc.model
                AutoFarmer.OriginalTargetModel = npc.model
                TargetTextAuto.Text = "🎯 Target: " .. npc.name
                TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
            end
        end)
        
        table.insert(NPCToggleButtons, btn)
    end
end

-- Combat Loop
local function StartCombatLoopAuto()
    if AutoFarmer.CombatConnection then AutoFarmer.CombatConnection:Disconnect() end
    
    AutoFarmer.CombatConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmer.IsFarming or AutoFarmer.IsEscaping then return end
        
        -- CHECK IF TARGET EXISTS AND IS ALIVE
        if not AutoFarmer.CurrentTargetModel or not AutoFarmer.CurrentTargetModel.Parent then
            -- Try to find next target before stopping
            local nextTarget = AutoFarmer.CurrentTargetModel and FindNextSameNPC(AutoFarmer.CurrentTargetModel) or nil
            
            if nextTarget then
                AutoFarmer.CurrentTarget = nextTarget.part
                AutoFarmer.CurrentTargetModel = nextTarget.model
                TargetTextAuto.Text = "🎯 Target: " .. nextTarget.name
                TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                return
            else
                StopFarmingAuto()
                StatusTextAuto.Text = "● TARGET LOST - STOPPED"
                StatusTextAuto.TextColor3 = Color3.fromRGB(255, 165, 0)
                TargetTextAuto.Text = "🎯 Target: None"
                TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
                return
            end
        end
        
        local targetHum = AutoFarmer.CurrentTargetModel:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            -- Target dead, find next
            local nextTarget = FindNextSameNPC(AutoFarmer.CurrentTargetModel)
            
            if nextTarget then
                AutoFarmer.CurrentTarget = nextTarget.part
                AutoFarmer.CurrentTargetModel = nextTarget.model
                TargetTextAuto.Text = "🎯 Target: " .. nextTarget.name
                TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                StatusTextAuto.Text = "● FARMING: MOVING TO NEXT " .. nextTarget.name
                StatusTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
            else
                -- No more NPCs of this type found
                local targetName = AutoFarmer.CurrentTargetModel.Name
                local anyNPC = GetSortedNPCsAuto()
                
                -- Check if there are any NPCs with the same name (even if dead)
                local hasSameName = false
                local enemiesFolder = workspace:FindFirstChild("Enemies")
                if enemiesFolder then
                    for _, model in ipairs(enemiesFolder:GetChildren()) do
                        if model.Name == targetName then
                            hasSameName = true
                            break
                        end
                    end
                end
                
                if hasSameName then
                    -- There are others but they're dead, wait for respawn
                    WaitForRespawnAuto(targetName)
                elseif #anyNPC > 0 then
                    -- Look for any NPC
                    AutoFarmer.CurrentTarget = anyNPC[1].part
                    AutoFarmer.CurrentTargetModel = anyNPC[1].model
                    TargetTextAuto.Text = "🎯 Target: " .. anyNPC[1].name
                    TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                    StatusTextAuto.Text = "● FARMING: TARGETING NEW NPC"
                else
                    StopFarmingAuto()
                    StatusTextAuto.Text = "● TARGET DEFEATED - STOPPED"
                    StatusTextAuto.TextColor3 = Color3.fromRGB(255, 165, 0)
                    TargetTextAuto.Text = "🎯 Target: None"
                    TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
                    return
                end
            end
            return
        end
        
        local now = tick()
        
        -- M1 Attacks
        if now - AutoFarmer.LastM1Time >= FarmerSettings.M1Delay then
            PressM1Auto()
            AutoFarmer.LastM1Time = now
        end
        
        -- M2 Attacks (if enabled)
        if FarmerSettings.UseM2 and now - AutoFarmer.LastM2Time >= FarmerSettings.M2Delay then
            PressM2Auto()
            AutoFarmer.LastM2Time = now
        end
        
        -- Key Presses for R, T, Y
        if now - AutoFarmer.LastKeyPressTime >= FarmerSettings.KeyPressDelay then
            local keys = {Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y}
            PressKeyAuto(keys[AutoFarmer.LastKeyIndex])
            
            AutoFarmer.LastKeyIndex = AutoFarmer.LastKeyIndex % 3 + 1
            AutoFarmer.LastKeyPressTime = now
        end
    end)
end

local function StopCombatLoopAuto()
    if AutoFarmer.CombatConnection then
        AutoFarmer.CombatConnection:Disconnect()
        AutoFarmer.CombatConnection = nil
    end
end

-- Circle Movement (Slower, maintains 12 stud distance)
local function CircleTargetAuto(dt)
    if not AutoFarmer.CurrentTarget or not AutoFarmer.CurrentTarget.Parent then
        return false
    end
    
    local hrp = GetAutoHRP()
    local hum = GetAutoHumanoid()
    if not hrp or not hum then return false end
    
    -- CHECK IF TARGET IS DEAD
    local targetHum = AutoFarmer.CurrentTargetModel and AutoFarmer.CurrentTargetModel:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        StopFarmingAuto()
        StatusTextAuto.Text = "● TARGET DEFEATED - STOPPED"
        StatusTextAuto.TextColor3 = Color3.fromRGB(255, 165, 0)
        TargetTextAuto.Text = "🎯 Target: None"
        TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
        return false
    end
    
    local hp = GetPlayerHealthAuto()
    UpdateHPBarAuto()
    
    -- ... keep the rest of your function below this unchanged ...
    
    local targetHum = AutoFarmer.CurrentTargetModel and AutoFarmer.CurrentTargetModel:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        -- NPC is dead - stop farming immediately
        StopFarmingAuto()
        StatusTextAuto.Text = "● TARGET DEFEATED - STOPPED"
        StatusTextAuto.TextColor3 = Color3.fromRGB(255, 165, 0)
        TargetTextAuto.Text = "🎯 Target: None"
        TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
        return false
    end
    
    local targetPart = AutoFarmer.CurrentTargetModel and (AutoFarmer.CurrentTargetModel:FindFirstChild("HumanoidRootPart") or AutoFarmer.CurrentTargetModel:FindFirstChild("Head"))
    if not targetPart then
        targetPart = AutoFarmer.CurrentTarget
    end
    
    local targetPos = targetPart.Position
    local currentPos = hrp.Position
    
    -- Calculate desired position at exactly 12 studs distance
    local desiredDistance = 12
    local dirToTarget = (targetPos - currentPos).Unit
    local distance = (targetPos - currentPos).Magnitude
    
    -- If too close, move away to exactly 12 studs
    if distance < desiredDistance - 1 then
        -- Move away from target
        local awayDir = (currentPos - targetPos).Unit
        local newPos = targetPos + awayDir * desiredDistance
        newPos = Vector3.new(newPos.X, targetPos.Y + 2, newPos.Z)
        
        local step = FarmerSettings.FlySpeed * dt
        local moveDir = (newPos - currentPos).Unit
        local finalPos = currentPos + moveDir * math.min(step, (newPos - currentPos).Magnitude)
        
        hrp.CFrame = CFrame.new(finalPos, targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        return true
    end
    
    -- If too far, move closer to exactly 12 studs
    if distance > desiredDistance + 1 then
        local newPos = targetPos + dirToTarget * desiredDistance
        newPos = Vector3.new(newPos.X, targetPos.Y + 2, newPos.Z)
        
        local step = FarmerSettings.FlySpeed * dt
        local moveDir = (newPos - currentPos).Unit
        local finalPos = currentPos + moveDir * math.min(step, (newPos - currentPos).Magnitude)
        
        hrp.CFrame = CFrame.new(finalPos, targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        return true
    end
    
    -- At correct distance, circle very slowly around the target
    -- Much slower circling speed (0.1 instead of 0.25, can be adjusted via UI)
    local circleSpeed = FarmerSettings.CircleSpeed  -- This will be set from UI input
    
    -- Calculate circle position
    local time = tick()
    local angle = (time * circleSpeed) % (math.pi * 2)
    
    -- Calculate perpendicular directions
    local rightVector = Vector3.new(0, 1, 0):Cross(dirToTarget).Unit
    local forwardVector = dirToTarget:Cross(rightVector).Unit
    
    -- Circle position at exactly 12 studs radius
    local circlePos = targetPos + (rightVector * math.cos(angle) * desiredDistance) + (forwardVector * math.sin(angle) * desiredDistance)
    circlePos = Vector3.new(circlePos.X, targetPos.Y + 2, circlePos.Z)
    
    -- Smooth movement to circle position
    local moveDir = (circlePos - currentPos).Unit
    local step = FarmerSettings.FlySpeed * dt
    local newPos = currentPos + moveDir * math.min(step, (circlePos - currentPos).Magnitude)
    
    hrp.CFrame = CFrame.new(newPos, targetPos)
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    hum.PlatformStand = true
    hum.AutoRotate = false
    
    return true
end
-- Escape Functions
local function EscapeToSafetyAuto()
    if AutoFarmer.IsEscaping then return end
    AutoFarmer.IsEscaping = true
    
    StopCombatLoopAuto()
    
    StatusTextAuto.Text = "⚠️ ESCAPE MODE ACTIVE ⚠️"
    StatusTextAuto.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    local hrp = GetAutoHRP()
    if not hrp then return end
    
    AutoFarmer.OriginalTargetModel = AutoFarmer.CurrentTargetModel
    
    local randomAngle = math.random() * math.pi * 2
    local randomDir = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
    AutoFarmer.EscapePosition = hrp.Position + (randomDir * FarmerSettings.EscapeDistance)
    AutoFarmer.EscapePosition = Vector3.new(AutoFarmer.EscapePosition.X, hrp.Position.Y + 5, AutoFarmer.EscapePosition.Z)
    
    local startPos = hrp.Position
    local distance = (AutoFarmer.EscapePosition - startPos).Magnitude
    local duration = distance / FarmerSettings.EscapeFlySpeed
    local startTime = tick()
    
    if AutoFarmer.FlyConnection then AutoFarmer.FlyConnection:Disconnect() end
    
    AutoFarmer.FlyConnection = RunService.Heartbeat:Connect(function()
        local hrpCurrent = GetAutoHRP()
        if not hrpCurrent or not hrpCurrent.Parent then return end
        
        local elapsed = tick() - startTime
        local t = math.min(1, elapsed / duration)
        
        local newPos = startPos:lerp(AutoFarmer.EscapePosition, t)
        hrpCurrent.CFrame = CFrame.new(newPos)
        hrpCurrent.AssemblyLinearVelocity = Vector3.zero
        
        if t >= 1 then
            AutoFarmer.FlyConnection:Disconnect()
            AutoFarmer.FlyConnection = nil
            ToggleKiChargeAuto()
            WaitForHealthRecoveryAuto()
        end
    end)
end

local function WaitForHealthRecoveryAuto()
    StatusTextAuto.Text = "💚 RECOVERING - CHARGING KI 💚"
    StatusTextAuto.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    if AutoFarmer.HealthCheckConnection then AutoFarmer.HealthCheckConnection:Disconnect() end
    
    AutoFarmer.HealthCheckConnection = RunService.Heartbeat:Connect(function()
        local hp = GetPlayerHealthAuto()
        UpdateHPBarAuto()
        
        if hp >= FarmerSettings.ReturnHPThreshold then
            AutoFarmer.HealthCheckConnection:Disconnect()
            AutoFarmer.HealthCheckConnection = nil
            ReturnToNPCAuto()
        end
    end)
end

local function ReturnToNPCAuto()
    ToggleKiChargeAuto()
    
    if AutoFarmer.OriginalTargetModel and AutoFarmer.OriginalTargetModel.Parent then
        local hum = AutoFarmer.OriginalTargetModel:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            AutoFarmer.CurrentTargetModel = AutoFarmer.OriginalTargetModel
            AutoFarmer.CurrentTarget = AutoFarmer.OriginalTargetModel:FindFirstChild("HumanoidRootPart") or AutoFarmer.OriginalTargetModel:FindFirstChild("Head")
            TargetTextAuto.Text = "🎯 Target: " .. (AutoFarmer.OriginalTargetModel.Name or "Unknown")
            TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
        else
            local npcs = GetSortedNPCsAuto()
            if #npcs > 0 then
                AutoFarmer.CurrentTargetModel = npcs[1].model
                AutoFarmer.CurrentTarget = npcs[1].part
                AutoFarmer.OriginalTargetModel = npcs[1].model
                TargetTextAuto.Text = "🎯 Target: " .. npcs[1].name
            else
                StopFarmingAuto()
                StatusTextAuto.Text = "● NO NPC FOUND"
                return
            end
        end
    else
        local npcs = GetSortedNPCsAuto()
        if #npcs > 0 then
            AutoFarmer.CurrentTargetModel = npcs[1].model
            AutoFarmer.CurrentTarget = npcs[1].part
            AutoFarmer.OriginalTargetModel = npcs[1].model
            TargetTextAuto.Text = "🎯 Target: " .. npcs[1].name
        else
            StopFarmingAuto()
            StatusTextAuto.Text = "● NO NPC FOUND"
            return
        end
    end
    
    StatusTextAuto.Text = "🚀 RETURNING TO COMBAT 🚀"
    StatusTextAuto.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local hrp = GetAutoHRP()
    if not hrp then
        StopFarmingAuto()
        return
    end
    
    local targetPart = AutoFarmer.CurrentTarget
    if not targetPart then
        StopFarmingAuto()
        return
    end
    
    local startPos = hrp.Position
    local targetPos = targetPart.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = distance / FarmerSettings.EscapeFlySpeed
    local startTime = tick()
    
    local returnConnection = RunService.Heartbeat:Connect(function()
        if not targetPart or not targetPart.Parent or not hrp or not hrp.Parent then
            returnConnection:Disconnect()
            StopFarmingAuto()
            return
        end
        
        targetPos = targetPart.Position
        local elapsed = tick() - startTime
        local t = math.min(1, elapsed / duration)
        
        local newPos = startPos:lerp(targetPos, t)
        hrp.CFrame = CFrame.new(newPos, targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        
        if t >= 1 then
            returnConnection:Disconnect()
            AutoFarmer.IsEscaping = false
            
            if AutoFarmer.IsFarming then
                StatusTextAuto.Text = "● FARMING: ACTIVE"
                StatusTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                StartCombatLoopAuto()
                StartFarmingLoopAuto()
            end
        end
    end)
end

-- Farming Loop
local function StartFarmingLoopAuto()
    if AutoFarmer.CameraConnection then AutoFarmer.CameraConnection:Disconnect() end
    if AutoFarmer.FlyConnection then AutoFarmer.FlyConnection:Disconnect() end
    
    AutoFarmer.CameraConnection = RunService.RenderStepped:Connect(function()
        if AutoFarmer.CurrentTarget and AutoFarmer.CurrentTarget.Parent and AutoFarmer.IsFarming and not AutoFarmer.IsEscaping then
            local targetPart = AutoFarmer.CurrentTargetModel and (AutoFarmer.CurrentTargetModel:FindFirstChild("Head") or AutoFarmer.CurrentTargetModel:FindFirstChild("HumanoidRootPart"))
            if targetPart then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end)
    
    AutoFarmer.FlyConnection = RunService.Heartbeat:Connect(function(dt)
        if not AutoFarmer.IsFarming or AutoFarmer.IsEscaping then return end
        
        -- Check if current target still exists and is alive
        if AutoFarmer.CurrentTargetModel and AutoFarmer.CurrentTargetModel.Parent then
            local targetHum = AutoFarmer.CurrentTargetModel:FindFirstChildOfClass("Humanoid")
            if not targetHum or targetHum.Health <= 0 then
                -- Target is dead, find next NPC
                local nextTarget = FindNextSameNPC(AutoFarmer.CurrentTargetModel)
                
                if nextTarget then
                    -- Switch to next target
                    AutoFarmer.CurrentTarget = nextTarget.part
                    AutoFarmer.CurrentTargetModel = nextTarget.model
                    TargetTextAuto.Text = "🎯 Target: " .. nextTarget.name
                    TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                    StatusTextAuto.Text = "● FARMING: MOVING TO NEXT " .. nextTarget.name
                    StatusTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                else
                    -- No more NPCs of this type found
                    local targetName = AutoFarmer.CurrentTargetModel.Name
                    local anyNPC = GetSortedNPCsAuto()
                    
                    -- Check if there are any NPCs with the same name (even if dead)
                    local hasSameName = false
                    local enemiesFolder = workspace:FindFirstChild("Enemies")
                    if enemiesFolder then
                        for _, model in ipairs(enemiesFolder:GetChildren()) do
                            if model.Name == targetName then
                                hasSameName = true
                                break
                            end
                        end
                    end
                    
                    if hasSameName then
                        -- There are others but they're dead, wait for respawn
                        WaitForRespawnAuto(targetName)
                    elseif #anyNPC > 0 then
                        -- Look for any NPC
                        AutoFarmer.CurrentTarget = anyNPC[1].part
                        AutoFarmer.CurrentTargetModel = anyNPC[1].model
                        TargetTextAuto.Text = "🎯 Target: " .. anyNPC[1].name
                        TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                        StatusTextAuto.Text = "● FARMING: TARGETING NEW NPC"
                        StatusTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                    else
                        StopFarmingAuto()
                        StatusTextAuto.Text = "● NO NPCS AVAILABLE - STOPPED"
                        StatusTextAuto.TextColor3 = Color3.fromRGB(255, 165, 0)
                        TargetTextAuto.Text = "🎯 Target: None"
                        TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
                        return
                    end
                end
                return
            end
        else
            -- Target model is missing - try to find next target
            local nextTarget = AutoFarmer.CurrentTargetModel and FindNextSameNPC(AutoFarmer.CurrentTargetModel) or nil
            
            if nextTarget then
                AutoFarmer.CurrentTarget = nextTarget.part
                AutoFarmer.CurrentTargetModel = nextTarget.model
                TargetTextAuto.Text = "🎯 Target: " .. nextTarget.name
                TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
                StatusTextAuto.Text = "● FARMING: TARGETING NEXT NPC"
            else
                StopFarmingAuto()
                StatusTextAuto.Text = "● TARGET LOST - STOPPED"
                StatusTextAuto.TextColor3 = Color3.fromRGB(255, 165, 0)
                TargetTextAuto.Text = "🎯 Target: None"
                TargetTextAuto.TextColor3 = Color3.fromRGB(180, 180, 200)
                return
            end
        end
        
        -- Check HP for escape
        local hp = GetPlayerHealthAuto()
        if hp < FarmerSettings.EscapeHPThreshold and not AutoFarmer.IsEscaping then
            EscapeToSafetyAuto()
            return
        end
        
        -- Circle the target
        CircleTargetAuto(dt)
    end)
end

-- NoClip
local function StartNoClipAuto()
    if AutoFarmer.NoclipConnection then AutoFarmer.NoclipConnection:Disconnect() end
    AutoFarmer.NoclipConnection = RunService.Stepped:Connect(function()
        local char = GetAutoChar()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function StopNoClipAuto()
    if AutoFarmer.NoclipConnection then
        AutoFarmer.NoclipConnection:Disconnect()
        AutoFarmer.NoclipConnection = nil
    end
    local char = GetAutoChar()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Main Control Functions
local function StartFarmingAuto()
    if AutoFarmer.IsFarming then return end
    
    if not AutoFarmer.CurrentTarget then
        local npcs = GetSortedNPCsAuto()
        if #npcs > 0 then
            AutoFarmer.CurrentTarget = npcs[1].part
            AutoFarmer.CurrentTargetModel = npcs[1].model
            AutoFarmer.OriginalTargetModel = npcs[1].model
            TargetTextAuto.Text = "🎯 Target: " .. npcs[1].name
            TargetTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
        else
            StatusTextAuto.Text = "● NO NPC FOUND"
            StatusTextAuto.TextColor3 = Color3.fromRGB(220, 100, 100)
            return
        end
    end
    
    AutoFarmer.IsFarming = true
    AutoFarmer.IsEscaping = false
    StatusTextAuto.Text = "● FARMING: ACTIVE"
    StatusTextAuto.TextColor3 = Color3.fromRGB(100, 220, 100)
    ControlBtnAuto.Text = "⏹ STOP FARMING"
    ControlBtnAuto.BackgroundColor3 = Color3.fromRGB(80, 55, 55)
    
    StartNoClipAuto()
    StartCombatLoopAuto()
    StartFarmingLoopAuto()
end

local function StopFarmingAuto()
    AutoFarmer.IsFarming = false
    AutoFarmer.IsEscaping = false

    if AutoFarmer.RespawnCheckConnection then
        AutoFarmer.RespawnCheckConnection:Disconnect()
        AutoFarmer.RespawnCheckConnection = nil
    end
    AutoFarmer.WaitingForRespawn = false
    -- Clear target references
    AutoFarmer.CurrentTarget = nil
    AutoFarmer.CurrentTargetModel = nil
    AutoFarmer.OriginalTargetModel = nil
    
    StopCombatLoopAuto()
    
    if AutoFarmer.FlyConnection then 
        AutoFarmer.FlyConnection:Disconnect()
        AutoFarmer.FlyConnection = nil
    end
    if AutoFarmer.CameraConnection then 
        AutoFarmer.CameraConnection:Disconnect()
        AutoFarmer.CameraConnection = nil
    end
    if AutoFarmer.HealthCheckConnection then 
        AutoFarmer.HealthCheckConnection:Disconnect()
        AutoFarmer.HealthCheckConnection = nil
    end
    
    StopNoClipAuto()
    
    local hum = GetAutoHumanoid()
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
    end
    
    StatusTextAuto.Text = "● SYSTEM: IDLE"
    StatusTextAuto.TextColor3 = Color3.fromRGB(220, 100, 100)
    ControlBtnAuto.Text = "▶ START FARMING"
    ControlBtnAuto.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Camera.CameraType = Enum.CameraType.Custom
end

ControlBtnAuto.MouseButton1Click:Connect(function()
    if AutoFarmer.IsFarming then
        StopFarmingAuto()
    else
        StartFarmingAuto()
    end
end)

-- ADD THESE LINES AFTER THE ABOVE CONNECTION:
-- Release mouse capture when GUI is interacted with
UserInputService.MouseBehavior = Enum.MouseBehavior.Default

-- Add event handlers for GUI focus
MainFrame.MouseEnter:Connect(function()
    if AutoFarmer.IsFarming then
        -- When mouse enters GUI while farming, release mouse control
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- Update NPC list periodically
task.spawn(function()
    while AutoPanel and AutoPanel.Parent do
        if not AutoFarmer.IsFarming then
            pcall(UpdateNPCListAuto)
        end
        pcall(UpdateHPBarAuto)
        task.wait(FarmerSettings.UpdateInterval)
    end
end)

-- Character added cleanup
LocalPlayer.CharacterAdded:Connect(function()
    StopFarmingAuto()
    task.wait(1)
    UpdateNPCListAuto()
end)
-- ═══════════════════════════════════════════
--              INTERACTABLES PANEL
-- ═══════════════════════════════════════════
local InteractablesPanel = Instance.new("Frame")
InteractablesPanel.Name = "InteractablesPanel"
InteractablesPanel.Size = UDim2.new(1, 0, 1, 0)
InteractablesPanel.BackgroundTransparency = 1
InteractablesPanel.Visible = false
InteractablesPanel.Parent = ContentArea
ContentPanels["Interactables"] = InteractablesPanel

-- Create a scrolling frame for the interactables panel
local InteractablesScroll = Instance.new("ScrollingFrame")
InteractablesScroll.Size = UDim2.new(1, 0, 1, 0)
InteractablesScroll.BackgroundTransparency = 1
InteractablesScroll.BorderSizePixel = 0
InteractablesScroll.ScrollBarThickness = 3
InteractablesScroll.ScrollBarImageColor3 = Color3.fromRGB(35, 190, 120)
InteractablesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
InteractablesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InteractablesScroll.Parent = InteractablesPanel

local InteractablesLayout = Instance.new("UIListLayout")
InteractablesLayout.Padding = UDim.new(0, 6)
InteractablesLayout.SortOrder = Enum.SortOrder.LayoutOrder
InteractablesLayout.Parent = InteractablesScroll

-- Function to get position from a model (looks inside for any part)
local function GetTeleportPosition(obj)
    if not obj then return nil end
    
    -- If it's a BasePart, teleport to it
    if obj:IsA("BasePart") then
        print("[Interactables] Found BasePart:", obj.Name, "Position:", obj.Position)
        return obj.Position
    end
    
    -- If it's a Model, look for parts inside it
    if obj:IsA("Model") then
        -- Try to get any BasePart inside the model
        local anyPart = obj:FindFirstChildWhichIsA("BasePart")
        if anyPart then
            print("[Interactables] Found part in model:", anyPart.Name, "Position:", anyPart.Position)
            return anyPart.Position
        end
        
        -- If no direct parts, search deeper
        for _, descendant in ipairs(obj:GetDescendants()) do
            if descendant:IsA("BasePart") then
                print("[Interactables] Found descendant part:", descendant.Name, "Position:", descendant.Position)
                return descendant.Position
            end
        end
    end
    
    print("[Interactables] No part found in:", obj.Name)
    return nil
end

-- Function to add interactable teleport button
local function AddInteractableButton(parent, displayName, locationName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(22, 36, 28)
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 190, 120)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = btn
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -20, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = displayName
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextColor3 = Color3.fromRGB(220, 240, 230)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(35, 190, 120)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.2, Color = Color3.fromRGB(255, 255, 255)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(22, 36, 28)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.6, Color = Color3.fromRGB(35, 190, 120)}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        print("[Interactables] Clicked:", displayName)
        
        -- Find the current object in workspace
        local interactFolder = Workspace:FindFirstChild("Interactable")
        local currentObj = interactFolder and interactFolder:FindFirstChild(locationName)
        
        if currentObj then
            print("[Interactables] Found object:", currentObj.Name)
            
            -- Get the position from inside the model
            local pos = GetTeleportPosition(currentObj)
            
            if pos then
                print("[Interactables] Flying to:", pos)
                
                -- Stop any existing flight
                if flying then 
                    print("[Interactables] Stopping existing flight")
                    stopFly()
                    task.wait(0.1)
                end
                
                -- Use the existing fly system (fast fly, not instant)
                if type(StartTravel) == "function" then
                    StartTravel(locationName, pos)
                else
                    -- Fallback: Use direct fly function if StartTravel doesn't exist
                    print("[Interactables] StartTravel not found, using fallback")
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Enable noclip
                        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        -- Teleport directly (fast but not instant)
                        hrp.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
                    end
                end
            else
                print("[Interactables] ERROR: Could not find any part inside:", locationName)
                -- Visual feedback
                local originalColor = nameLbl.TextColor3
                nameLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                nameLbl.Text = "No part: " .. displayName
                task.delay(2, function()
                    nameLbl.TextColor3 = originalColor
                    nameLbl.Text = displayName
                end)
            end
        else
            print("[Interactables] ERROR: Object not found:", locationName)
            -- Visual feedback
            local originalColor = nameLbl.TextColor3
            nameLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            nameLbl.Text = "Not found: " .. displayName
            task.delay(2, function()
                nameLbl.TextColor3 = originalColor
                nameLbl.Text = displayName
            end)
        end
    end)
    
    return btn
end

-- Populate Interactables Panel with ALL interactables from Workspace.Interactable
task.spawn(function()
    task.wait(1)
    
    local interactFolder = Workspace:FindFirstChild("Interactable")
    local interactableItems = {}
    
    if interactFolder then
        print("[Interactables] Scanning Interactable folder...")
        
        for _, obj in ipairs(interactFolder:GetChildren()) do
            -- Get the position (looks inside the model for any part)
            local pos = GetTeleportPosition(obj)
            
            if pos then
                local objName = obj.Name
                print("[Interactables] ✓ Found:", objName, "Position:", pos)
                table.insert(interactableItems, {
                    name = objName
                })
            else
                print("[Interactables] ✗ Could not get position for:", obj.Name, "- No parts found inside")
            end
        end
    else
        print("[Interactables] Workspace.Interactable not found")
    end
    
    -- Sort alphabetically
    table.sort(interactableItems, function(a, b)
        return a.name:lower() < b.name:lower()
    end)
    
    print("[Interactables] Total items found:", #interactableItems)
    
    -- Add header
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, -16, 0, 50)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = InteractablesScroll
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 30)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "INTERACTABLES"
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = Color3.fromRGB(35, 210, 130)
    titleLbl.Parent = headerFrame
    
    local subtitleLbl = Instance.new("TextLabel")
    subtitleLbl.Size = UDim2.new(1, 0, 0, 20)
    subtitleLbl.Position = UDim2.new(0, 0, 0, 30)
    subtitleLbl.BackgroundTransparency = 1
    subtitleLbl.Text = #interactableItems .. " locations available"
    subtitleLbl.Font = Enum.Font.Gotham
    subtitleLbl.TextSize = 10
    subtitleLbl.TextColor3 = Color3.fromRGB(120, 160, 140)
    subtitleLbl.Parent = headerFrame
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 48)
    divider.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = headerFrame
    
    if #interactableItems == 0 then
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Size = UDim2.new(1, -16, 0, 60)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.Text = "No interactable locations found"
        emptyLbl.Font = Enum.Font.Gotham
        emptyLbl.TextSize = 11
        emptyLbl.TextColor3 = Color3.fromRGB(200, 80, 80)
        emptyLbl.TextWrapped = true
        emptyLbl.Parent = InteractablesScroll
    else
        for _, item in ipairs(interactableItems) do
            AddInteractableButton(InteractablesScroll, item.name, item.name)
        end
    end
end)
-- ═══════════════════════════════════════════
--              FLY / NOCLIP HELPERS
-- ═══════════════════════════════════════════
local function _GetChar() return LocalPlayer.Character end
local function _GetHRP()
    local c = _GetChar(); return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function _GetHum()
    local c = _GetChar(); return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function _SetPlatformStand(on)
    local h = _GetHum(); if h then pcall(function() h.PlatformStand = on end) end
end
local function _SetNoclip(en)
    local c = _GetChar(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = not en end
    end
end

local function _StartNoclipLoop()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not flying then
            noclipConn:Disconnect()
            noclipConn = nil
            return
        end
        _SetNoclip(true)
    end)
end

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    _SetNoclip(false)
    _SetPlatformStand(false)
    local hrp = _GetHRP()
    if hrp then
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    CancelBtn.Visible   = false
    TpStatusLabel.Text  = "● IDLE"
    TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(100, 140, 120)}):Play()
end

-- ═══════════════════════════════════════════
--              FIXED MOVE STEP
-- ═══════════════════════════════════════════
local function MoveStep(hrp, dest, dt)
    local dir  = dest - hrp.Position
    local dist = dir.Magnitude
    if dist < 0.5 then return true end

    _SetPlatformStand(true)
    local step   = math.min(FLY_SPEED * dt, dist)
    local newPos = hrp.Position + dir.Unit * step
    hrp.CFrame                  = CFrame.new(newPos, newPos + dir.Unit)
    hrp.AssemblyLinearVelocity  = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    return dist - step < ARRIVE_DIST
end

local function StartTravel(label, exactPos)
    local hrp = _GetHRP(); if not hrp then return end
    if flying then stopFly() end
    local dest = Vector3.new(exactPos.X, exactPos.Y + Y_OFFSET, exactPos.Z)
    TpStatusLabel.Text = "◈ " .. label:upper():sub(1, 24)
    TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 210, 60)}):Play()
    CancelBtn.Visible = true
    flying = true
    _SetNoclip(true)
    _StartNoclipLoop()
    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not flying then return end
        local h = _GetHRP()
        if not h or not h.Parent then stopFly(); return end
        if MoveStep(h, dest, dt) then
            stopFly()
            TpStatusLabel.Text = "✓ " .. label:upper():sub(1, 24)
            TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(35, 210, 130)}):Play()
        end
    end)
end

-- ═══════════════════════════════════════════
--              TELEPORT UI HELPERS
-- ═══════════════════════════════════════════
local function GetObjPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
        if p then return p.Position end
        local ok, cf = pcall(function() return obj:GetModelCFrame() end)
        if ok then return cf.Position end
    end
    return nil
end

local function MakeTpButton(parent, displayText, yOffset, onClick)
    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(1, -16, 0, 26)
    btn.Position            = UDim2.new(0, 8, 0, yOffset)
    btn.BackgroundColor3    = Color3.fromRGB(18, 32, 25)
    btn.BackgroundTransparency = 0.35
    btn.TextColor3          = Color3.fromRGB(180, 210, 195)
    btn.Text                = displayText
    btn.Font                = Enum.Font.GothamMedium
    btn.TextSize            = 11
    btn.TextXAlignment      = Enum.TextXAlignment.Left
    btn.AutoButtonColor     = false
    btn.ClipsDescendants    = true
    btn.Parent              = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent      = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color        = Color3.fromRGB(35, 190, 120)
    stroke.Thickness    = 1
    stroke.Transparency = 0.82
    stroke.Parent       = btn

    btn.MouseEnter:Connect(function()
        if not flying then
            TweenService:Create(btn,    TweenInfo.new(0.12), {BackgroundTransparency = 0.1,  TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.4}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,    TweenInfo.new(0.12), {BackgroundTransparency = 0.35, TextColor3 = Color3.fromRGB(180, 210, 195)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.82}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if flying then stopFly() else onClick() end
    end)

    return btn
end

local function MakeSectionLabel(parent, title, yOffset)
    local lbl = Instance.new("TextLabel")
    lbl.Text              = title
    lbl.Size              = UDim2.new(1, -16, 0, 16)
    lbl.Position          = UDim2.new(0, 8, 0, yOffset)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3        = Color3.fromRGB(35, 210, 130)
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 11
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = parent

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -16, 0, 1)
    div.Position         = UDim2.new(0, 8, 0, yOffset + 18)
    div.BackgroundColor3 = Color3.fromRGB(35, 190, 120)
    div.BackgroundTransparency = 0.75
    div.BorderSizePixel  = 0
    div.Parent           = parent

    return yOffset + 26
end

-- ═══════════════════════════════════════════
--              SEARCH + SCROLLING LIST BUILDER
-- ═══════════════════════════════════════════
local ITEM_H      = 28
local ITEM_GAP    = 4
local VISIBLE_MAX = 4

local function BuildSearchSection(outerScroll, headerTitle, icon, items, outerYOff)
    outerYOff = MakeSectionLabel(outerScroll, headerTitle, outerYOff)

    local visibleItems = math.min(#items, VISIBLE_MAX)
    local innerH       = visibleItems * (ITEM_H + ITEM_GAP) - ITEM_GAP

    local innerScroll = Instance.new("ScrollingFrame")
    innerScroll.Size                = UDim2.new(1, -16, 0, innerH)
    innerScroll.Position            = UDim2.new(0, 8, 0, outerYOff)
    innerScroll.BackgroundTransparency = 1
    innerScroll.BorderSizePixel     = 0
    innerScroll.ScrollBarThickness  = 2
    innerScroll.ScrollBarImageColor3 = Color3.fromRGB(35, 190, 120)
    innerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    innerScroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
    innerScroll.Parent              = outerScroll

    outerYOff = outerYOff + innerH + 10

    local btnY = 0
    for _, item in ipairs(items) do
        local capturedName   = item.name
        local capturedGetPos = item.getPos
        local btn = MakeTpButton(innerScroll, icon .. "  " .. capturedName, btnY, function()
            StartTravel(capturedName, capturedGetPos())
        end)
        btn.Size = UDim2.new(1, 0, 0, ITEM_H)
        btnY = btnY + ITEM_H + ITEM_GAP
    end

    return outerYOff
end

-- ═══════════════════════════════════════════
--              RAID & DUNGEON DATA
-- ═══════════════════════════════════════════
local raidItems    = {}
local dungeonItems = {}
local specialItems = {}
local interactFolder = Workspace:FindFirstChild("Interactable")

if interactFolder then
    for _, obj in ipairs(interactFolder:GetChildren()) do
        local pos = GetObjPos(obj)
        if pos then
            local capturedName = obj.Name
            local capturedPos  = pos

            -- Raids: names starting with "Raid"
            if capturedName:sub(1, 4) == "Raid" then
                local cleanName = capturedName:gsub("^Raid_", "")
                table.insert(raidItems, {
                    name   = cleanName,
                    getPos = function()
                        local f = Workspace:FindFirstChild("Interactable")
                        local o = f and f:FindFirstChild(capturedName)
                        return (o and GetObjPos(o)) or capturedPos
                    end,
                })

            -- Dungeons: names starting with "DungeonEntrance"
            elseif capturedName:sub(1, 15) == "DungeonEntrance" then
                local cleanName = capturedName:gsub("^DungeonEntrance_", "")
                table.insert(dungeonItems, {
                    name   = cleanName,
                    getPos = function()
                        local f = Workspace:FindFirstChild("Interactable")
                        local o = f and f:FindFirstChild(capturedName)
                        return (o and GetObjPos(o)) or capturedPos
                    end,
                })
            end
        end
    end
end

-- ═══════════════════════════════════════════
--              POPULATE TELEPORT SCROLL
-- ═══════════════════════════════════════════
local yOff = 6

-- Namekian Ship teleport (simple button)
do
    local interactFolder = Workspace:FindFirstChild("Interactable")
    local ship = interactFolder and interactFolder:FindFirstChild("NamekianShip")

    if ship then
        local pos = GetObjPos(ship)
        if pos then
            MakeTpButton(ScrollFrame, "🚀  Teleport To Namekian Ship", yOff, function()
                local f = Workspace:FindFirstChild("Interactable")
                local s = f and f:FindFirstChild("NamekianShip")
                local newPos = (s and GetObjPos(s)) or pos
                StartTravel("Namekian Ship", newPos)
            end)
            yOff = yOff + 30
        end
    end
end
-- Raids section
if #raidItems > 0 then
    yOff = BuildSearchSection(ScrollFrame, "RAIDS", "⚔️", raidItems, yOff)
else
    local noLabel = Instance.new("TextLabel")
    noLabel.Size                = UDim2.new(1, -16, 0, 24)
    noLabel.Position            = UDim2.new(0, 8, 0, yOff)
    noLabel.BackgroundTransparency = 1
    noLabel.Text                = "No raid locations found."
    noLabel.TextColor3          = Color3.fromRGB(120, 140, 130)
    noLabel.Font                = Enum.Font.Gotham
    noLabel.TextSize            = 11
    noLabel.Parent              = ScrollFrame
    yOff = yOff + 30
end

-- Dungeons section
if #dungeonItems > 0 then
    yOff = BuildSearchSection(ScrollFrame, "DUNGEONS", "🏰", dungeonItems, yOff)
else
    local noLabel = Instance.new("TextLabel")
    noLabel.Size                = UDim2.new(1, -16, 0, 24)
    noLabel.Position            = UDim2.new(0, 8, 0, yOff)
    noLabel.BackgroundTransparency = 1
    noLabel.Text                = "No dungeon entrances found."
    noLabel.TextColor3          = Color3.fromRGB(120, 140, 130)
    noLabel.Font                = Enum.Font.Gotham
    noLabel.TextSize            = 11
    noLabel.Parent              = ScrollFrame
    yOff = yOff + 30
end

-- ═══════════════════════════════════════════
--              QUEST DATA
-- ═══════════════════════════════════════════
local questItems       = {}
local dragonBallQuests = {}
local friendlyNpcs     = Workspace:FindFirstChild("FriendlyNpcs")

if friendlyNpcs then
    for _, npc in ipairs(friendlyNpcs:GetDescendants()) do
        if npc:IsA("Model") or npc:IsA("BasePart") then
            local name    = npc.Name
            local nameLow = name:lower()
            local isQuest = nameLow:find("questgive") or nameLow:find("quest give")
            local isDragonBall = nameLow:find("dragonball") or nameLow:find("dragon ball")

            if isQuest or isDragonBall then
                local pos = GetObjPos(npc)
                if pos then
                    local capturedName = name
                    local capturedPos  = pos
                    local entry = {
                        name   = capturedName,
                        getPos = function()
                            local f = Workspace:FindFirstChild("FriendlyNpcs")
                            local o = f and f:FindFirstChild(capturedName, true)
                            return (o and GetObjPos(o)) or capturedPos
                        end,
                    }
                    if isDragonBall then
                        table.insert(dragonBallQuests, entry)
                    else
                        table.insert(questItems, entry)
                    end
                end
            end
        end
    end
end

-- Quest Teleport section
if #questItems > 0 then
    yOff = BuildSearchSection(ScrollFrame, "QUESTS", "📜", questItems, yOff)
else
    yOff = MakeSectionLabel(ScrollFrame, "QUESTS", yOff)
    local noLabel = Instance.new("TextLabel")
    noLabel.Size                = UDim2.new(1, -16, 0, 24)
    noLabel.Position            = UDim2.new(0, 8, 0, yOff)
    noLabel.BackgroundTransparency = 1
    noLabel.Text                = "No quest givers found."
    noLabel.TextColor3          = Color3.fromRGB(120, 140, 130)
    noLabel.Font                = Enum.Font.Gotham
    noLabel.TextSize            = 11
    noLabel.Parent              = ScrollFrame
    yOff = yOff + 30
end

-- Dragon Ball Quests section
if #dragonBallQuests > 0 then
    yOff = BuildSearchSection(ScrollFrame, "DRAGON BALL QUESTS", "🐉", dragonBallQuests, yOff)
else
    yOff = MakeSectionLabel(ScrollFrame, "DRAGON BALL QUESTS", yOff)
    local noLabel = Instance.new("TextLabel")
    noLabel.Size                = UDim2.new(1, -16, 0, 24)
    noLabel.Position            = UDim2.new(0, 8, 0, yOff)
    noLabel.BackgroundTransparency = 1
    noLabel.Text                = "No Dragon Ball quests found."
    noLabel.TextColor3          = Color3.fromRGB(120, 140, 130)
    noLabel.Font                = Enum.Font.Gotham
    noLabel.TextSize            = 11
    noLabel.Parent              = ScrollFrame
end

CancelBtn.MouseButton1Click:Connect(function() stopFly() end)

-- ═══════════════════════════════════════════
--              SIDEBAR TAB LOGIC
-- ═══════════════════════════════════════════
local function SwitchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name
    for _, td in ipairs(TabDefs) do
        local btn      = TabButtons[td.name]
        local isActive = (td.name == name)
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundTransparency = isActive and 0.7 or 1,
            TextColor3             = isActive and Color3.fromRGB(50, 220, 145) or Color3.fromRGB(160, 180, 170),
        }):Play()
        if ContentPanels[td.name] then
            ContentPanels[td.name].Visible = isActive
        end
    end
    for _, td in ipairs(TabDefs) do
        if td.name == name then
            TweenService:Create(ActiveIndicator, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 0, 0, td.yPos + 2)
            }):Play()
            break
        end
    end
end

for _, td in ipairs(TabDefs) do
    local btn = Instance.new("TextButton")
    btn.Name                = td.name .. "Tab"
    btn.Size                = UDim2.new(0.88, 0, 0, 32)
    btn.Position            = UDim2.new(0.06, 0, 0, td.yPos)
    btn.BackgroundColor3    = Color3.fromRGB(35, 200, 130)
    btn.BackgroundTransparency = (td.name == "Home") and 0.7 or 1
    btn.Text                = "  " .. td.icon .. "  " .. td.name
    btn.TextColor3          = (td.name == "Home") and Color3.fromRGB(50, 220, 145) or Color3.fromRGB(160, 180, 170)
    btn.Font                = Enum.Font.GothamMedium
    btn.TextSize            = 12
    btn.TextXAlignment      = Enum.TextXAlignment.Left
    btn.AutoButtonColor     = false
    btn.Parent              = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    TabButtons[td.name] = btn

    btn.MouseButton1Click:Connect(function() SwitchTab(td.name) end)
    btn.MouseEnter:Connect(function()
        if ActiveTab ~= td.name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 220, 210)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= td.name then
            TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(160, 180, 170)}):Play()
        end
    end)
end

local UserInfo = Instance.new("TextLabel")
UserInfo.Text              = (LocalPlayer and LocalPlayer.Name or "Player") .. "\nv2.0"
UserInfo.Size              = UDim2.new(1, 0, 0, 34)
UserInfo.Position          = UDim2.new(0, 0, 1, -40)
UserInfo.BackgroundTransparency = 1
UserInfo.TextColor3        = Color3.fromRGB(80, 110, 95)
UserInfo.Font              = Enum.Font.Gotham
UserInfo.TextSize          = 10
UserInfo.LineHeight         = 1.4
UserInfo.Parent            = Sidebar

-- ═══════════════════════════════════════════
--              AIMLOCK CORE
-- ═══════════════════════════════════════════
local function GetCandidates()
    local mode       = GetTargetType()
    local candidates = {}

    if mode == "Players" or mode == "Both" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(candidates, p.Character)
                end
            end
        end
    end

    if mode == "NPCs" or mode == "Both" then
        local enemyFolder = Workspace:FindFirstChild("Enemies")
        if enemyFolder then
            for _, model in ipairs(enemyFolder:GetChildren()) do
                if model:IsA("Model") then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        table.insert(candidates, model)
                    end
                end
            end
        end
    end

    return candidates
end

local function GetTargetPart(model)
    local partName = GetHitPart()
    return model:FindFirstChild(partName)
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildOfClass("BasePart")
end

local function FindNearestTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, model in ipairs(GetCandidates()) do
        local part = GetTargetPart(model)
        if part then
            local dist = (part.Position - root.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest     = part
            end
        end
    end
    return nearest
end

local function Unlock()
    AimlockLocked        = false
    AimlockTarget        = nil
    Camera.CameraType    = Enum.CameraType.Custom
    LockStatusLabel.Text = "● UNLOCKED"
    TweenService:Create(LockStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 60, 60)}):Play()
end

local function TryLock()
    local target = FindNearestTarget()
    if not target then return end
    AimlockTarget        = target
    AimlockLocked        = true
    Camera.CameraType    = Enum.CameraType.Custom
    LockStatusLabel.Text = "● LOCKED"
    TweenService:Create(LockStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(35, 210, 130)}):Play()
end

RunService.RenderStepped:Connect(function()
    if not AimlockLocked or not AimlockTarget then return end
    local model = AimlockTarget:FindFirstAncestorOfClass("Model")
    local hum   = model and model:FindFirstChildOfClass("Humanoid")
    if not AimlockTarget.Parent or not hum or hum.Health <= 0 then Unlock(); return end
    local char      = LocalPlayer.Character
    if not char then return end
    local root      = char:FindFirstChild("HumanoidRootPart")
    local targetPos = AimlockTarget.Position
    local camPos    = Camera.CFrame.Position
    Camera.CFrame   = Camera.CFrame:Lerp(CFrame.lookAt(camPos, targetPos), 0.3)
    if root then
        local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        root.CFrame      = root.CFrame:Lerp(CFrame.lookAt(root.Position, flatTarget), 0.25)
    end
end)

-- ═══════════════════════════════════════════
--              UI VISIBILITY / MINIMIZE
-- ═══════════════════════════════════════════
local function Notify(title, text)
    if not NotificationSent then
        StarterGui:SetCore("SendNotification", {
            Title    = title or "Wez Hub Active",
            Text     = text  or "Press RightAlt to toggle.",
            Duration = 6
        })
        NotificationSent = true
    end
end

local function FullUnhook()
    -- Stop all flying
    if flying then
        stopFly()
    end
    
    -- Disconnect all connections
    if flyConn then flyConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    
    -- Stop autofarmer if running
    if AutoFarmer and AutoFarmer.IsFarming then
        StopFarmingAuto()
    end
    
    -- Destroy the entire GUI
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    -- Clear all global references
    flying = false
    flyConn = nil
    noclipConn = nil
end

local function HideUI()
    IsVisible = false
    IsMinimized = false
    MainFrame.Visible = false
    MainFrame.Size = UDim2.new(0, 560, 0, 0)
    
    -- Send notification
    StarterGui:SetCore("SendNotification", {
        Title = "Wez Hub",
        Text = "Press RightAlt to show the hub again.",
        Duration = 3
    })
end

local function ShowUI()
    IsVisible = true
    IsMinimized = false
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 560, 0, 370)
    }):Play()
end

local function ToggleUI()
    if IsVisible then
        HideUI()
    else
        ShowUI()
    end
end

-- Close button = FULL UNHOOK (stops everything and destroys script)
CloseBtn.MouseButton1Click:Connect(function()
    FullUnhook()
end)

-- Minimize button = just hide the GUI
MinBtn.MouseButton1Click:Connect(function()
    HideUI()
end)

Notify("Wez Hub Loaded", "Press RightAlt to toggle visibility.")

-- ═══════════════════════════════════════════
--              INPUT HANDLER
-- ═══════════════════════════════════════════
local inputConnection = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.RightAlt then
        ToggleUI()
        return
    end

    if input.KeyCode == Enum.KeyCode.X then
        stopFly()
        return
    end

    if input.KeyCode == GetAimlockKey() then
        if not GetAimlockEnabled() then return end
        if AimlockLocked then Unlock() else TryLock() end
    end
end)

-- ═══════════════════════════════════════════
--              HEADER DRAG
-- ═══════════════════════════════════════════
local dragging, dragStart, startPos = false, nil, nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
