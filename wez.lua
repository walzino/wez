-- ═══════════════════════════════════════════
--              WEZ HUB - EVIL EDITION
-- ═══════════════════════════════════════════

-- ANTI DOUBLE INJECTION
if game:GetService("CoreGui"):FindFirstChild("WezHub_Pro") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Wez Hub",
        Text = "Wez Hub is already running!",
        Duration = 3
    })
    return
end

-- SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- GLOBAL STATE
local NotificationSent = false
local IsVisible = true
local IsMinimized = false
local ActiveTab = "Home"

-- AIMLOCK STATE
local AimlockActive = false
local AimlockLocked = false
local AimlockTarget = nil

-- FLY STATE
local flying = false
local flyConn = nil
local noclipConn = nil

-- FLY SETTINGS
local FLY_SPEED = 350
local ARRIVE_DIST = 5
local Y_OFFSET = 3

-- INFO PANEL STAT KEYS
local STAT_KEYS = {
    "HealthMax", "KiDamage", "KiMax", "KiResist",
    "PhysDamage", "PhysResist", "Speed"
}

-- AUTOFARMER STATE
local AutoFarmer = {
    IsFarming = false,
    IsEscaping = false,
    IsChargingKi = false,
    CurrentTarget = nil,
    CurrentTargetModel = nil,
    OriginalTargetModel = nil,
    EscapePosition = nil,
    FlyConnection = nil,
    CameraConnection = nil,
    CombatConnection = nil,
    KeyPressConnection = nil,
    NoclipConnection = nil,
    HealthCheckConnection = nil,
    ChargingConnection = nil,
    LastM1Time = 0,
    LastM2Time = 0,
    LastKeyPressTime = 0,
    LastKeyIndex = 1,
    WaitingForRespawn = false,
    LastTargetName = nil,
    RespawnCheckConnection = nil,
}

local FarmerSettings = {
    CircleRadius = 12,
    CircleSpeed = 0.1,
    FlySpeed = 220,
    M1Delay = 0.08,
    M2Delay = 0.45,
    UseM2 = true,
    KeyPressDelay = 0.35,
    KeyPressDuration = 0.05,
    EscapeHPThreshold = 45,
    ReturnHPThreshold = 75,
    EscapeDistance = 3500,
    EscapeFlySpeed = 320,
    UpdateInterval = 0.5,
}

-- SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WezHub_Pro"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- ═══════════════════════════════════════════
--              EVIL MAIN FRAME
-- ═══════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 4, 12)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(156, 39, 176)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

local PulseStroke = Instance.new("UIStroke")
PulseStroke.Color = Color3.fromRGB(156, 39, 176)
PulseStroke.Thickness = 1.5
PulseStroke.Transparency = 0.7
PulseStroke.Parent = MainFrame

task.spawn(function()
    while MainFrame.Parent do
        TweenService:Create(PulseStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.2, Thickness = 2.5}):Play()
        task.wait(1.5)
        TweenService:Create(PulseStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.7, Thickness = 1.5}):Play()
        task.wait(1.5)
    end
end)

local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(1, -8, 1, -8)
GlowFrame.Position = UDim2.new(0, 4, 0, 4)
GlowFrame.BackgroundTransparency = 1
GlowFrame.BorderSizePixel = 0
GlowFrame.Parent = MainFrame

local GlowStroke = Instance.new("UIStroke")
GlowStroke.Color = Color3.fromRGB(128, 0, 255)
GlowStroke.Thickness = 1
GlowStroke.Transparency = 0.85
GlowStroke.Parent = GlowFrame
Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(0, 12)

-- ═══════════════════════════════════════════
--              HEADER
-- ═══════════════════════════════════════════
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
Header.BackgroundTransparency = 0.15
Header.BorderSizePixel = 0
Header.ZIndex = 5
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local HeaderGlow = Instance.new("Frame")
HeaderGlow.Size = UDim2.new(1, 0, 0, 2)
HeaderGlow.Position = UDim2.new(0, 0, 1, -2)
HeaderGlow.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
HeaderGlow.BackgroundTransparency = 0.4
HeaderGlow.BorderSizePixel = 0
HeaderGlow.ZIndex = 6
HeaderGlow.Parent = Header

task.spawn(function()
    while HeaderGlow.Parent do
        TweenService:Create(HeaderGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.1, Size = UDim2.new(0.8, 0, 0, 2)}):Play()
        task.wait(1)
        TweenService:Create(HeaderGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.4, Size = UDim2.new(1, 0, 0, 2)}):Play()
        task.wait(1)
    end
end)

local Logo = Instance.new("TextLabel")
Logo.Text = "◈ WEZ HUB ◈"
Logo.Size = UDim2.new(0, 220, 1, 0)
Logo.Position = UDim2.new(0, 18, 0, 0)
Logo.BackgroundTransparency = 1
Logo.TextColor3 = Color3.fromRGB(176, 48, 196)
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 16
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.ZIndex = 6
Logo.Parent = Header

local LogoShadow = Instance.new("TextLabel")
LogoShadow.Text = "◈ WEZ HUB ◈"
LogoShadow.Size = UDim2.new(0, 220, 1, 0)
LogoShadow.Position = UDim2.new(0, 20, 0, 1)
LogoShadow.BackgroundTransparency = 1
LogoShadow.TextColor3 = Color3.fromRGB(98, 0, 128)
LogoShadow.Font = Enum.Font.GothamBold
LogoShadow.TextSize = 16
LogoShadow.TextXAlignment = Enum.TextXAlignment.Left
LogoShadow.ZIndex = 5
LogoShadow.Parent = Header

local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Text = "⎇ RIGHT ALT"
KeybindLabel.Size = UDim2.new(0, 130, 1, 0)
KeybindLabel.Position = UDim2.new(0.5, -65, 0, 0)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextSize = 10
KeybindLabel.ZIndex = 6
KeybindLabel.Parent = Header

local function MakeHeaderBtn(txt, xOffset, col)
    local btn = Instance.new("TextButton")
    btn.Text = txt
    btn.Size = UDim2.new(0, 32, 0, 32)
    btn.Position = UDim2.new(1, xOffset, 0.5, -16)
    btn.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = col
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    btn.Parent = Header
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(156, 39, 176)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.6
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.2, Thickness = 1.5}):Play()
    end)
    btn.MouseLeave:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, TextColor3 = col}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.6, Thickness = 1}):Play()
    end)
    return btn
end

local MinBtn = MakeHeaderBtn("—", -80, Color3.fromRGB(176, 48, 196))
local CloseBtn = MakeHeaderBtn("✕", -42, Color3.fromRGB(255, 80, 120))

-- ═══════════════════════════════════════════
--              EVIL SIDEBAR
-- ═══════════════════════════════════════════
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -52)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = Color3.fromRGB(6, 2, 10)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarGlow = Instance.new("Frame")
SidebarGlow.Size = UDim2.new(0, 2, 1, 0)
SidebarGlow.Position = UDim2.new(1, -2, 0, 0)
SidebarGlow.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
SidebarGlow.BackgroundTransparency = 0.5
SidebarGlow.BorderSizePixel = 0
SidebarGlow.Parent = Sidebar

local ActiveIndicator = Instance.new("Frame")
ActiveIndicator.Size = UDim2.new(0, 4, 0, 36)
ActiveIndicator.Position = UDim2.new(0, 0, 0, 60)
ActiveIndicator.BackgroundColor3 = Color3.fromRGB(176, 48, 196)
ActiveIndicator.BorderSizePixel = 0
ActiveIndicator.Parent = Sidebar
Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(0, 4)

local TabDefs = {
    { name = "Home", icon = "⛧", yPos = 28 },
    { name = "Combat", icon = "⚔", yPos = 72 },
    { name = "Teleport", icon = "⌇", yPos = 116 },
    { name = "Info", icon = "◈", yPos = 160 },
    { name = "Auto", icon = "⟳", yPos = 204 },
    { name = "Interactables", icon = "⬚", yPos = 248 },
}
local TabButtons = {}
local ContentPanels = {}

-- ═══════════════════════════════════════════
--              CONTENT AREA
-- ═══════════════════════════════════════════
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -168, 1, -60)
ContentArea.Position = UDim2.new(0, 168, 0, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

-- ═══════════════════════════════════════════
--              SHARED UI HELPERS (EVIL THEMED)
-- ═══════════════════════════════════════════
local function MakeSection(parent, title, yOff)
    local lbl = Instance.new("TextLabel")
    lbl.Text = title
    lbl.Size = UDim2.new(1, -16, 0, 20)
    lbl.Position = UDim2.new(0, 8, 0, yOff)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(176, 48, 196)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent

    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -16, 0, 1)
    div.Position = UDim2.new(0, 8, 0, yOff + 22)
    div.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
    div.BackgroundTransparency = 0.6
    div.BorderSizePixel = 0
    div.Parent = parent
end

local function MakeToggle(parent, label, yOff, default, onChange)
    local state = default or false

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 30)
    row.Position = UDim2.new(0, 8, 0, yOff)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 180, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -44, 0.5, -10)
    track.BackgroundColor3 = state and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(40, 30, 45)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(40, 30, 45)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        if onChange then onChange(state) end
    end)

    return row, function() return state end
end

local function MakeOptionPicker(parent, label, options, default, yOff, onChange)
    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 8, 0, yOff)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 180, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent

    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -16, 0, 28)
    btnRow.Position = UDim2.new(0, 8, 0, yOff + 20)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = parent

    local selected = default
    local btns = {}
    local totalW = 1 / #options
    local spacing = 4

    for i, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(totalW, i < #options and -spacing or 0, 1, 0)
        b.Position = UDim2.new(totalW * (i-1), i > 1 and spacing or 0, 0, 0)
        b.BackgroundColor3 = (opt == default) and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(25, 20, 34)
        b.BackgroundTransparency = (opt == default) and 0.3 or 0.4
        b.TextColor3 = (opt == default) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 120, 180)
        b.Text = opt
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 11
        b.AutoButtonColor = false
        b.Parent = btnRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        btns[opt] = b

        b.MouseButton1Click:Connect(function()
            selected = opt
            for o, rb in pairs(btns) do
                local active = (o == opt)
                TweenService:Create(rb, TweenInfo.new(0.15), {
                    BackgroundColor3 = active and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(25, 20, 34),
                    BackgroundTransparency = active and 0.3 or 0.4,
                    TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,120,180),
                }):Play()
            end
            if onChange then onChange(opt) end
        end)
    end

    return function() return selected end
end

local function MakeKeybindPicker(parent, label, defaultKey, yOff, onChange)
    local currentKey = defaultKey
    local listening = false

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 30)
    row.Position = UDim2.new(0, 8, 0, yOff)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(200, 180, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 80, 0, 24)
    keyBtn.Position = UDim2.new(1, -80, 0.5, -12)
    keyBtn.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
    keyBtn.BackgroundTransparency = 0.3
    keyBtn.TextColor3 = Color3.fromRGB(176, 48, 196)
    keyBtn.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.AutoButtonColor = false
    keyBtn.Parent = row
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(156, 39, 176)
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = keyBtn

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "[ ... ]"
        keyBtn.TextColor3 = Color3.fromRGB(255, 210, 60)
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keyBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            keyBtn.TextColor3 = Color3.fromRGB(176, 48, 196)
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
    lbl.TextColor3 = Color3.fromRGB(200, 180, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.3, 0, 1, -4)
    box.Position = UDim2.new(0.7, 0, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
    box.BackgroundTransparency = 0.3
    box.Text = tostring(defaultValue)
    box.TextColor3 = Color3.fromRGB(176, 48, 196)
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
--              HOME PANEL
-- ═══════════════════════════════════════════
local HomePanel = Instance.new("Frame")
HomePanel.Name = "HomePanel"
HomePanel.Size = UDim2.new(1, 0, 1, 0)
HomePanel.BackgroundTransparency = 1
HomePanel.Visible = true
HomePanel.Parent = ContentArea
ContentPanels["Home"] = HomePanel

MakeSection(HomePanel, "PLAYER", 8)

local noclipToggle = MakeToggle(HomePanel, "No Clip", 40, false, function(state)
    _G.Noclip = state
end)

local noslowToggle = MakeToggle(HomePanel, "No Slow", 80, false, function(state)
    _G.NoSlow = state
end)

-- Teleport Speed Input
local TeleSpeedRow = Instance.new("Frame")
TeleSpeedRow.Size = UDim2.new(1, -16, 0, 30)
TeleSpeedRow.Position = UDim2.new(0, 8, 0, 115)
TeleSpeedRow.BackgroundTransparency = 1
TeleSpeedRow.Parent = HomePanel

local TeleSpeedLbl = Instance.new("TextLabel")
TeleSpeedLbl.Size = UDim2.new(0.6, 0, 1, 0)
TeleSpeedLbl.BackgroundTransparency = 1
TeleSpeedLbl.Text = "Teleport Speed"
TeleSpeedLbl.TextColor3 = Color3.fromRGB(200, 180, 210)
TeleSpeedLbl.Font = Enum.Font.Gotham
TeleSpeedLbl.TextSize = 12
TeleSpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
TeleSpeedLbl.Parent = TeleSpeedRow

local TeleSpeedBox = Instance.new("TextBox")
TeleSpeedBox.Size = UDim2.new(0.3, 0, 1, -4)
TeleSpeedBox.Position = UDim2.new(0.7, 0, 0, 2)
TeleSpeedBox.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
TeleSpeedBox.BackgroundTransparency = 0.3
TeleSpeedBox.Text = tostring(FLY_SPEED)
TeleSpeedBox.TextColor3 = Color3.fromRGB(176, 48, 196)
TeleSpeedBox.Font = Enum.Font.GothamBold
TeleSpeedBox.TextSize = 11
TeleSpeedBox.Parent = TeleSpeedRow
Instance.new("UICorner", TeleSpeedBox).CornerRadius = UDim.new(0, 6)

TeleSpeedBox.FocusLost:Connect(function()
    local num = tonumber(TeleSpeedBox.Text)
    if num and num > 0 then
        FLY_SPEED = math.clamp(num, 50, 1000)
        TeleSpeedBox.Text = tostring(FLY_SPEED)
    else
        TeleSpeedBox.Text = tostring(FLY_SPEED)
    end
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

-- No Slow
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.NoSlow and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
    end
end)

-- ESP SYSTEM
local ESPTrackedPlayers = {}

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
    billboard.Size = UDim2.new(0, 100, 0, 32)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char

    local bg = Instance.new("Frame", billboard)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, -8, 0, 16)
    nameLabel.Position = UDim2.new(0, 4, 0, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = username
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 10
    nameLabel.TextColor3 = Color3.fromRGB(176, 48, 196)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center

    local hpText = Instance.new("TextLabel", billboard)
    hpText.Size = UDim2.new(1, -8, 0, 12)
    hpText.Position = UDim2.new(0, 4, 0, 18)
    hpText.BackgroundTransparency = 1
    hpText.Text = "❤️ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
    hpText.Font = Enum.Font.Gotham
    hpText.TextSize = 9
    hpText.TextColor3 = Color3.fromRGB(255, 100, 100)
    hpText.TextXAlignment = Enum.TextXAlignment.Center

    local conn = RunService.RenderStepped:Connect(function()
        if not char.Parent or hum.Health <= 0 then
            billboard.Enabled = false
            return
        end
        billboard.Enabled = true
        hpText.Text = "❤️ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
        local pct = hum.Health / hum.MaxHealth
        if pct > 0.6 then
            hpText.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif pct > 0.3 then
            hpText.TextColor3 = Color3.fromRGB(255, 200, 100)
        else
            hpText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)

    ESPTrackedPlayers[username] = {billboard = billboard, conn = conn}
end

MakeSection(HomePanel, "PLAYER ESP", 150)

do
    local function GetAllPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        return names
    end

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
    ESPSearchFrame.Position = UDim2.new(0, 8, 0, 180)
    ESPSearchFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
    ESPSearchFrame.BackgroundTransparency = 0.5
    ESPSearchFrame.BorderSizePixel = 0
    ESPSearchFrame.Parent = HomePanel
    Instance.new("UICorner", ESPSearchFrame).CornerRadius = UDim.new(0, 8)

    local ESPSearchBox = Instance.new("TextBox")
    ESPSearchBox.Size = UDim2.new(1, -80, 1, 0)
    ESPSearchBox.Position = UDim2.new(0, 8, 0, 0)
    ESPSearchBox.BackgroundTransparency = 1
    ESPSearchBox.PlaceholderText = "Search player..."
    ESPSearchBox.PlaceholderColor3 = Color3.fromRGB(128, 64, 144)
    ESPSearchBox.Text = ""
    ESPSearchBox.Font = Enum.Font.Gotham
    ESPSearchBox.TextSize = 11
    ESPSearchBox.TextColor3 = Color3.fromRGB(200, 180, 210)
    ESPSearchBox.TextXAlignment = Enum.TextXAlignment.Left
    ESPSearchBox.ClearTextOnFocus = false
    ESPSearchBox.Parent = ESPSearchFrame

    local ESPAddBtn = Instance.new("TextButton")
    ESPAddBtn.Size = UDim2.new(0, 64, 1, -8)
    ESPAddBtn.Position = UDim2.new(1, -70, 0, 4)
    ESPAddBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
    ESPAddBtn.BackgroundTransparency = 0.3
    ESPAddBtn.Text = "TRACK"
    ESPAddBtn.Font = Enum.Font.GothamBold
    ESPAddBtn.TextSize = 10
    ESPAddBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
    ESPAddBtn.AutoButtonColor = false
    ESPAddBtn.Parent = ESPSearchFrame
    Instance.new("UICorner", ESPAddBtn).CornerRadius = UDim.new(0, 6)

    -- Autocomplete dropdown
    local ESPDropFrame = Instance.new("Frame")
    ESPDropFrame.Size = UDim2.new(1, -16, 0, 0)
    ESPDropFrame.Position = UDim2.new(0, 8, 0, 214)
    ESPDropFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    ESPDropFrame.BorderSizePixel = 0
    ESPDropFrame.ClipsDescendants = true
    ESPDropFrame.ZIndex = 30
    ESPDropFrame.Visible = false
    ESPDropFrame.Parent = HomePanel
    Instance.new("UICorner", ESPDropFrame).CornerRadius = UDim.new(0, 7)

    local ESPDropStroke = Instance.new("UIStroke")
    ESPDropStroke.Color = Color3.fromRGB(156, 39, 176)
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
            btn.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
            btn.Text = ""
            btn.LayoutOrder = i
            btn.ZIndex = 31
            btn.Parent = ESPDropFrame

            local hl = Instance.new("Frame")
            hl.Size = UDim2.new(1, 0, 1, 0)
            hl.BackgroundColor3 = Color3.fromRGB(76, 48, 96)
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
            lbl.TextColor3 = Color3.fromRGB(176, 128, 196)
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

    -- Tracked list frame
    local ESPListFrame = Instance.new("ScrollingFrame")
    ESPListFrame.Size = UDim2.new(1, -16, 0, 120)
    ESPListFrame.Position = UDim2.new(0, 8, 0, 250)
    ESPListFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    ESPListFrame.BackgroundTransparency = 0.5
    ESPListFrame.BorderSizePixel = 0
    ESPListFrame.ScrollBarThickness = 2
    ESPListFrame.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
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
    ESPStatusLabel.Position = UDim2.new(0, 8, 0, 375)
    ESPStatusLabel.BackgroundTransparency = 1
    ESPStatusLabel.Text = ""
    ESPStatusLabel.Font = Enum.Font.Gotham
    ESPStatusLabel.TextSize = 10
    ESPStatusLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
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
            row.BackgroundColor3 = Color3.fromRGB(25, 16, 32)
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
            nameLbl.TextColor3 = Color3.fromRGB(176, 96, 216)
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
            emptyLbl.TextColor3 = Color3.fromRGB(128, 64, 144)
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
            ESPStatusLabel.TextColor3 = Color3.fromRGB(176, 96, 216)
            return
        end
        local targetPlayer = Players:FindFirstChild(exact)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
            ESPStatusLabel.Text = "✖ Character not ready."
            ESPStatusLabel.TextColor3 = Color3.fromRGB(220, 55, 38)
            return
        end
        CreateESPForPlayer(exact)
        RefreshESPList()
        ESPSearchBox.Text = ""
        HideESPDrop()
        ESPStatusLabel.Text = "✔ Tracking " .. exact
        ESPStatusLabel.TextColor3 = Color3.fromRGB(176, 96, 216)
        targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.8)
            if ESPTrackedPlayers[exact] then
                CreateESPForPlayer(exact)
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
CombatPanel.Name = "CombatPanel"
CombatPanel.Size = UDim2.new(1, 0, 1, 0)
CombatPanel.BackgroundTransparency = 1
CombatPanel.Visible = false
CombatPanel.Parent = ContentArea
ContentPanels["Combat"] = CombatPanel

local LockStatusLabel = Instance.new("TextLabel")
LockStatusLabel.Size = UDim2.new(1, -16, 0, 22)
LockStatusLabel.Position = UDim2.new(0, 8, 0, 6)
LockStatusLabel.BackgroundTransparency = 1
LockStatusLabel.Text = "● UNLOCKED"
LockStatusLabel.TextColor3 = Color3.fromRGB(180, 60, 60)
LockStatusLabel.Font = Enum.Font.GothamBold
LockStatusLabel.TextSize = 11
LockStatusLabel.TextXAlignment = Enum.TextXAlignment.Right
LockStatusLabel.Parent = CombatPanel

MakeSection(CombatPanel, "AIMLOCK", 8)
local _, GetAimlockEnabled = MakeToggle(CombatPanel, "Aimlock Enabled", 38, false)
local GetAimlockKey = MakeKeybindPicker(CombatPanel, "Toggle Keybind", Enum.KeyCode.Q, 76)

MakeSection(CombatPanel, "TARGET TYPE", 116)
local GetTargetType = MakeOptionPicker(CombatPanel, "Target", {"Players", "NPCs", "Both"}, "NPCs", 142)

MakeSection(CombatPanel, "HIT PART", 200)
local GetHitPart = MakeOptionPicker(CombatPanel, "Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", 226)

-- ═══════════════════════════════════════════
--              TELEPORT PANEL (EVIL EDITION)
-- ═══════════════════════════════════════════
local TeleportPanel = Instance.new("Frame")
TeleportPanel.Name = "TeleportPanel"
TeleportPanel.Size = UDim2.new(1, 0, 1, 0)
TeleportPanel.BackgroundTransparency = 1
TeleportPanel.Visible = false
TeleportPanel.Parent = ContentArea
ContentPanels["Teleport"] = TeleportPanel

local TpStatusLabel = Instance.new("TextLabel")
TpStatusLabel.Size = UDim2.new(1, -16, 0, 22)
TpStatusLabel.Position = UDim2.new(0, 8, 0, 4)
TpStatusLabel.BackgroundTransparency = 1
TpStatusLabel.Text = "● IDLE"
TpStatusLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
TpStatusLabel.Font = Enum.Font.GothamBold
TpStatusLabel.TextSize = 11
TpStatusLabel.TextXAlignment = Enum.TextXAlignment.Right
TpStatusLabel.Parent = TeleportPanel

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(1, -16, 0, 26)
CancelBtn.Position = UDim2.new(0, 8, 1, -32)
CancelBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CancelBtn.BackgroundTransparency = 0.3
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.Text = "✕ Cancel Flight"
CancelBtn.Font = Enum.Font.GothamBold
CancelBtn.TextSize = 11
CancelBtn.AutoButtonColor = false
CancelBtn.Visible = false
CancelBtn.Parent = TeleportPanel
Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 7)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -62)
ScrollFrame.Position = UDim2.new(0, 0, 0, 28)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = TeleportPanel

-- Main container that holds everything
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(1, 0, 0, 0)
mainContainer.BackgroundTransparency = 1
mainContainer.Parent = ScrollFrame

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 8)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Parent = mainContainer

mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    mainContainer.Size = UDim2.new(1, 0, 0, mainLayout.AbsoluteContentSize.Y)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, mainLayout.AbsoluteContentSize.Y + 20)
end)

-- ═══════════════════════════════════════════
--              COLLAPSIBLE SECTION (FIXED)
-- ═══════════════════════════════════════════
local function CreateCollapsibleSection(parent, title, icon)
    local isExpanded = false
    local buttonList = {} -- Store buttons to calculate height
    
    -- Section Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    -- Header Button
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
    header.BackgroundTransparency = 0.4
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = container
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    
    local headerStroke = Instance.new("UIStroke")
    headerStroke.Color = Color3.fromRGB(156, 39, 176)
    headerStroke.Thickness = 1
    headerStroke.Transparency = 0.6
    headerStroke.Parent = header
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = icon .. "  " .. title
    titleLabel.TextColor3 = Color3.fromRGB(176, 48, 196)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Expand/Collapse Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -40, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▶"
    arrow.TextColor3 = Color3.fromRGB(156, 39, 176)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.Parent = header
    
    -- Content Container
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 52)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = container
    
    -- Scrolling Frame for content
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
    contentScroll.BackgroundTransparency = 0.3
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 3
    contentScroll.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.Parent = content
    Instance.new("UICorner", contentScroll).CornerRadius = UDim.new(0, 6)
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentScroll
    
    -- Function to update content height based on actual button count
    local function UpdateContentHeight()
        local buttonCount = #buttonList
        if buttonCount == 0 then
            contentHeight = 60 -- Height for "no locations" message
        else
            contentHeight = math.min(buttonCount * 40, 200) -- Max 200px, 40px per button
        end
        return contentHeight
    end
    
    -- Toggle Function
    local function ToggleSection()
        isExpanded = not isExpanded
        local targetArrow = isExpanded and "▼" or "▶"
        
        if isExpanded then
            local newHeight = UpdateContentHeight()
            content.Size = UDim2.new(1, 0, 0, newHeight)
            container.Size = UDim2.new(1, -16, 0, 48 + newHeight)
            TweenService:Create(content, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, 0, 0, newHeight)
            }):Play()
            TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -16, 0, 48 + newHeight)
            }):Play()
        else
            TweenService:Create(content, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -16, 0, 48)
            }):Play()
        end
        
        TweenService:Create(arrow, TweenInfo.new(0.2), {
            Text = targetArrow
        }):Play()
        
        TweenService:Create(header, TweenInfo.new(0.2), {
            BackgroundTransparency = isExpanded and 0.2 or 0.4
        }):Play()
        
        -- Force canvas update
        task.wait(0.3)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, mainLayout.AbsoluteContentSize.Y + 20)
    end
    
    header.MouseButton1Click:Connect(ToggleSection)
    
    -- Function to refresh content
    local function RefreshContent(buttons)
        buttonList = buttons
        -- Clear existing
        for _, child in ipairs(contentScroll:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        -- Add new buttons
        for _, btn in ipairs(buttons) do
            btn.Parent = contentScroll
        end
        
        -- Update canvas size for scrolling
        task.wait(0.1)
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentScroll.CanvasSize.Y.Offset)
        
        -- Update height if expanded
        if isExpanded then
            local newHeight = UpdateContentHeight()
            content.Size = UDim2.new(1, 0, 0, newHeight)
            container.Size = UDim2.new(1, -16, 0, 48 + newHeight)
        end
    end
    
    return container, contentScroll, RefreshContent, ToggleSection
end

-- ═══════════════════════════════════════════
--              TELEPORT HELPER FUNCTIONS
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
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    CancelBtn.Visible = false
    TpStatusLabel.Text = "● IDLE"
    TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(128, 64, 144)}):Play()
end

local function MoveStep(hrp, dest, dt)
    local dir = dest - hrp.Position
    local dist = dir.Magnitude
    if dist < 0.5 then return true end

    _SetPlatformStand(true)
    local step = math.min(FLY_SPEED * dt, dist)
    local newPos = hrp.Position + dir.Unit * step
    hrp.CFrame = CFrame.new(newPos, newPos + dir.Unit)
    hrp.AssemblyLinearVelocity = Vector3.zero
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
            TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(176, 96, 216)}):Play()
        end
    end)
end

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

-- ═══════════════════════════════════════════
--              EVIL THEMED TELEPORT BUTTONS
-- ═══════════════════════════════════════════
local function MakeTpButton(displayText, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
    btn.BackgroundTransparency = 0.4
    btn.TextColor3 = Color3.fromRGB(200, 160, 220)
    btn.Text = displayText
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(156, 39, 176)
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        if not flying then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.2, Thickness = 1.5}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.4, TextColor3 = Color3.fromRGB(200, 160, 220)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency = 0.7, Thickness = 1}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if flying then stopFly() else onClick() end
    end)

    return btn
end

-- ═══════════════════════════════════════════
--              DYNAMIC LOCATION COLLECTION
-- ═══════════════════════════════════════════
local raidItems = {}
local dungeonItems = {}
local worldItems = {}
local questItems = {}
local dragonBallQuests = {}

local function RefreshLocations()
    raidItems = {}
    dungeonItems = {}
    worldItems = {}
    questItems = {}
    dragonBallQuests = {}
    
    local interactFolder = Workspace:FindFirstChild("Interactable")
    if interactFolder then
        for _, obj in ipairs(interactFolder:GetChildren()) do
            local pos = GetObjPos(obj)
            if pos then
                local capturedName = obj.Name
                local capturedPos = pos
                
                if capturedName:sub(1, 4):lower() == "raid" then
                    local cleanName = capturedName:gsub("^[Rr]aid[_ ]?", "")
                    table.insert(raidItems, {
                        name = cleanName,
                        getPos = function()
                            local f = Workspace:FindFirstChild("Interactable")
                            local o = f and f:FindFirstChild(capturedName)
                            return (o and GetObjPos(o)) or capturedPos
                        end,
                    })
                elseif capturedName:sub(1, 15):lower() == "dungeonentrance" or capturedName:lower():find("dungeon") then
                    local cleanName = capturedName:gsub("^[Dd]ungeon[Ee]ntrance[_ ]?", ""):gsub("^[Dd]ungeon[_ ]?", "")
                    table.insert(dungeonItems, {
                        name = cleanName,
                        getPos = function()
                            local f = Workspace:FindFirstChild("Interactable")
                            local o = f and f:FindFirstChild(capturedName)
                            return (o and GetObjPos(o)) or capturedPos
                        end,
                    })
                else
                    table.insert(worldItems, {
                        name = capturedName,
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
    
    local friendlyNpcs = Workspace:FindFirstChild("FriendlyNpcs")
    if friendlyNpcs then
        for _, npc in ipairs(friendlyNpcs:GetDescendants()) do
            if npc:IsA("Model") or npc:IsA("BasePart") then
                local name = npc.Name
                local nameLow = name:lower()
                local isQuest = nameLow:find("questgive") or nameLow:find("quest give") or nameLow:find("quest")
                local isDragonBall = nameLow:find("dragonball") or nameLow:find("dragon ball") or nameLow:find("dragon")
                
                local pos = GetObjPos(npc)
                if pos then
                    local capturedName = name
                    local capturedPos = pos
                    local entry = {
                        name = capturedName,
                        getPos = function()
                            local f = Workspace:FindFirstChild("FriendlyNpcs")
                            local o = f and f:FindFirstChild(capturedName, true)
                            return (o and GetObjPos(o)) or capturedPos
                        end,
                    }
                    if isDragonBall then
                        table.insert(dragonBallQuests, entry)
                    elseif isQuest then
                        table.insert(questItems, entry)
                    end
                end
            end
        end
    end
    
    local function sortItems(items)
        table.sort(items, function(a, b) return a.name:lower() < b.name:lower() end)
    end
    
    sortItems(raidItems)
    sortItems(dungeonItems)
    sortItems(worldItems)
    sortItems(questItems)
    sortItems(dragonBallQuests)
end

-- ═══════════════════════════════════════════
--              BUILD TELEPORT UI
-- ═══════════════════════════════════════════

-- Quick Teleport Section (always visible)
local quickHeader = Instance.new("Frame")
quickHeader.Size = UDim2.new(1, -16, 0, 48)
quickHeader.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
quickHeader.BackgroundTransparency = 0.4
quickHeader.Parent = mainContainer
Instance.new("UICorner", quickHeader).CornerRadius = UDim.new(0, 8)

local quickTitle = Instance.new("TextLabel")
quickTitle.Size = UDim2.new(1, 0, 1, 0)
quickTitle.Position = UDim2.new(0, 12, 0, 0)
quickTitle.BackgroundTransparency = 1
quickTitle.Text = " QUICK TELEPORTS"
quickTitle.TextColor3 = Color3.fromRGB(176, 48, 196)
quickTitle.Font = Enum.Font.GothamBold
quickTitle.TextSize = 13
quickTitle.TextXAlignment = Enum.TextXAlignment.Left
quickTitle.Parent = quickHeader

-- Namekian Ship Button
local shipBtn = MakeTpButton(" Namekian Ship", function()
    local interactFolder = Workspace:FindFirstChild("Interactable")
    local ship = interactFolder and interactFolder:FindFirstChild("NamekianShip")
    if ship then
        local pos = GetObjPos(ship)
        if pos then StartTravel("Namekian Ship", pos) end
    end
end)
shipBtn.Parent = mainContainer

-- Create Collapsible Sections
local raidContainer, raidScroll, RefreshRaid = CreateCollapsibleSection(mainContainer, "RAIDS", "⚔️")
local dungeonContainer, dungeonScroll, RefreshDungeon = CreateCollapsibleSection(mainContainer, "DUNGEONS", "🏰")
local worldContainer, worldScroll, RefreshWorld = CreateCollapsibleSection(mainContainer, "WORLD LOCATIONS", "🌍")
local questContainer, questScroll, RefreshQuest = CreateCollapsibleSection(mainContainer, "QUEST GIVERS", "📜")
local dragonContainer, dragonScroll, RefreshDragon = CreateCollapsibleSection(mainContainer, "DRAGON BALL QUESTS", "🐉")

-- Custom Teleport Section
local customHeader = Instance.new("Frame")
customHeader.Size = UDim2.new(1, -16, 0, 48)
customHeader.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
customHeader.BackgroundTransparency = 0.4
customHeader.Parent = mainContainer
Instance.new("UICorner", customHeader).CornerRadius = UDim.new(0, 8)

local customTitle = Instance.new("TextLabel")
customTitle.Size = UDim2.new(1, 0, 1, 0)
customTitle.Position = UDim2.new(0, 12, 0, 0)
customTitle.BackgroundTransparency = 1
customTitle.Text = "🔧  CUSTOM TELEPORT"
customTitle.TextColor3 = Color3.fromRGB(176, 48, 196)
customTitle.Font = Enum.Font.GothamBold
customTitle.TextSize = 13
customTitle.TextXAlignment = Enum.TextXAlignment.Left
customTitle.Parent = customHeader

local customFrame = Instance.new("Frame")
customFrame.Size = UDim2.new(1, -16, 0, 88)
customFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
customFrame.BackgroundTransparency = 0.4
customFrame.Parent = mainContainer
Instance.new("UICorner", customFrame).CornerRadius = UDim.new(0, 8)

local CustomInput = Instance.new("TextBox")
CustomInput.Size = UDim2.new(1, -20, 0, 40)
CustomInput.Position = UDim2.new(0, 10, 0, 8)
CustomInput.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
CustomInput.BackgroundTransparency = 0.3
CustomInput.PlaceholderText = "Enter coordinates (X, Y, Z) or player name..."
CustomInput.PlaceholderColor3 = Color3.fromRGB(128, 64, 144)
CustomInput.Text = ""
CustomInput.TextColor3 = Color3.fromRGB(200, 180, 210)
CustomInput.Font = Enum.Font.Gotham
CustomInput.TextSize = 11
CustomInput.Parent = customFrame
Instance.new("UICorner", CustomInput).CornerRadius = UDim.new(0, 6)

local CustomBtn = Instance.new("TextButton")
CustomBtn.Size = UDim2.new(1, -20, 0, 36)
CustomBtn.Position = UDim2.new(0, 10, 0, 52)
CustomBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
CustomBtn.BackgroundTransparency = 0.3
CustomBtn.Text = "TELEPORT TO COORDINATES"
CustomBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
CustomBtn.Font = Enum.Font.GothamBold
CustomBtn.TextSize = 11
CustomBtn.AutoButtonColor = false
CustomBtn.Parent = customFrame
Instance.new("UICorner", CustomBtn).CornerRadius = UDim.new(0, 6)

CustomBtn.MouseButton1Click:Connect(function()
    local input = CustomInput.Text
    local coords = {}
    for num in input:gmatch("[-]?%d+[.]?%d*") do
        table.insert(coords, tonumber(num))
    end
    
    if #coords >= 3 then
        StartTravel("Custom", Vector3.new(coords[1], coords[2], coords[3]))
    else
        local targetPlayer = Players:FindFirstChild(input)
        if targetPlayer and targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                StartTravel(targetPlayer.Name, hrp.Position)
            end
        else
            TpStatusLabel.Text = "✖ Invalid coordinates or player"
            TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
            task.delay(2, function()
                if TpStatusLabel.Text == "✖ Invalid coordinates or player" then
                    TpStatusLabel.Text = "● IDLE"
                    TweenService:Create(TpStatusLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(128, 64, 144)}):Play()
                end
            end)
        end
    end
end)

-- Function to refresh all section content
local function RefreshAllSections()
    RefreshLocations()
    
    -- Helper to create button list
    local function CreateButtonList(items, icon)
        local buttons = {}
        if #items == 0 then
            local noLabel = Instance.new("TextLabel")
            noLabel.Size = UDim2.new(1, 0, 0, 36)
            noLabel.BackgroundTransparency = 1
            noLabel.Text = "  ⚠ No locations found"
            noLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
            noLabel.Font = Enum.Font.Gotham
            noLabel.TextSize = 11
            noLabel.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(buttons, noLabel)
        else
            for _, item in ipairs(items) do
                table.insert(buttons, MakeTpButton(icon .. "  " .. item.name, function()
                    StartTravel(item.name, item.getPos())
                end))
            end
        end
        return buttons
    end
    
    RefreshRaid(CreateButtonList(raidItems, "🗡️"))
    RefreshDungeon(CreateButtonList(dungeonItems, "🔮"))
    RefreshWorld(CreateButtonList(worldItems, "📍"))
    RefreshQuest(CreateButtonList(questItems, "❓"))
    RefreshDragon(CreateButtonList(dragonBallQuests, "⭐"))
end

-- Initial refresh
RefreshAllSections()

-- Auto-refresh world locations every 5 seconds
task.spawn(function()
    while TeleportPanel and TeleportPanel.Parent do
        task.wait(5)
        if TeleportPanel.Visible then
            RefreshAllSections()
        end
    end
end)

-- Cancel Flight Button
CancelBtn.MouseButton1Click:Connect(function()
    stopFly()
end)

-- Add floating particles effect
local TeleportParticles = Instance.new("Frame")
TeleportParticles.Size = UDim2.new(1, 0, 1, 0)
TeleportParticles.BackgroundTransparency = 1
TeleportParticles.Parent = TeleportPanel

task.spawn(function()
    while TeleportPanel and TeleportPanel.Parent and TeleportPanel.Visible do
        task.wait(0.8)
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, 1, 0, 1)
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        particle.BackgroundTransparency = 0.3
        particle.BorderSizePixel = 0
        particle.Parent = TeleportParticles
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(particle, TweenInfo.new(3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(particle.Position.X.Scale + (math.random() - 0.5) * 0.1, 0,
                                   particle.Position.Y.Scale + (math.random() - 0.5) * 0.1, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(3, function() particle:Destroy() end)
    end
end)
-- ═══════════════════════════════════════════
--              INFO PANEL STAT KEYS
-- ═══════════════════════════════════════════
local STAT_KEYS = {
    "HealthMax", "KiDamage", "KiMax", "KiResist",
    "PhysDamage", "PhysResist", "Speed"
}

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
SearchLabel.TextColor3 = Color3.fromRGB(176, 48, 196)
SearchLabel.Font = Enum.Font.GothamBold
SearchLabel.TextSize = 11
SearchLabel.TextXAlignment = Enum.TextXAlignment.Left
SearchLabel.Parent = SearchSection

local SearchDivider = Instance.new("Frame")
SearchDivider.Size = UDim2.new(1, 0, 0, 1)
SearchDivider.Position = UDim2.new(0, 0, 0, 22)
SearchDivider.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
SearchDivider.BackgroundTransparency = 0.75
SearchDivider.BorderSizePixel = 0
SearchDivider.Parent = SearchSection

local SearchInputFrame = Instance.new("Frame")
SearchInputFrame.Size = UDim2.new(1, 0, 0, 36)
SearchInputFrame.Position = UDim2.new(0, 0, 0, 28)
SearchInputFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
SearchInputFrame.BackgroundTransparency = 0.5
SearchInputFrame.BorderSizePixel = 0
SearchInputFrame.Parent = SearchSection
Instance.new("UICorner", SearchInputFrame).CornerRadius = UDim.new(0, 8)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -90, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Enter username..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(128, 64, 144)
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextColor3 = Color3.fromRGB(200, 180, 210)
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchInputFrame

local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 74, 1, -8)
SearchBtn.Position = UDim2.new(1, -80, 0, 4)
SearchBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
SearchBtn.BackgroundTransparency = 0.3
SearchBtn.Text = "CHECK"
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 11
SearchBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
SearchBtn.AutoButtonColor = false
SearchBtn.Parent = SearchInputFrame
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 6)

-- Autocomplete Dropdown
local DROP_ROW_H = 30
local DropFrame = Instance.new("Frame")
DropFrame.Name = "Dropdown"
DropFrame.Size = UDim2.new(0, 0, 0, 0)
DropFrame.Position = UDim2.new(0, 8, 0, 106)
DropFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
DropFrame.BorderSizePixel = 0
DropFrame.ClipsDescendants = true
DropFrame.ZIndex = 30
DropFrame.Visible = false
DropFrame.Parent = InfoPanel
Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 7)

local DropStroke = Instance.new("UIStroke")
DropStroke.Color = Color3.fromRGB(156, 39, 176)
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
        Btn.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
        Btn.Text = ""
        Btn.LayoutOrder = i
        Btn.ZIndex = 31
        Btn.Parent = DropFrame

        local Highlight = Instance.new("Frame")
        Highlight.Size = UDim2.new(1, 0, 1, 0)
        Highlight.BackgroundColor3 = Color3.fromRGB(76, 48, 96)
        Highlight.BackgroundTransparency = 1
        Highlight.BorderSizePixel = 0
        Highlight.ZIndex = 31
        Highlight.Parent = Btn

        local Pip = Instance.new("Frame")
        Pip.Size = UDim2.new(0, 3, 0.5, 0)
        Pip.Position = UDim2.new(0, 0, 0.25, 0)
        Pip.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
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
        NameLbl.TextColor3 = Color3.fromRGB(176, 128, 196)
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.ZIndex = 33
        NameLbl.Parent = Btn

        if i < maxShow then
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, -16, 0, 1)
            Div.Position = UDim2.new(0, 8, 1, -1)
            Div.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
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
InfoStatusLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
InfoStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoStatusLabel.Parent = InfoPanel

-- Scroll frame for player stats (FIXED - uses a container frame for proper dynamic sizing)
local InfoScrollContainer = Instance.new("Frame")
InfoScrollContainer.Size = UDim2.new(1, -16, 1, -108)
InfoScrollContainer.Position = UDim2.new(0, 8, 0, 102)
InfoScrollContainer.BackgroundTransparency = 1
InfoScrollContainer.ClipsDescendants = true
InfoScrollContainer.Parent = InfoPanel

local InfoScrollFrame = Instance.new("ScrollingFrame")
InfoScrollFrame.Size = UDim2.new(1, 0, 1, 0)
InfoScrollFrame.BackgroundTransparency = 1
InfoScrollFrame.BorderSizePixel = 0
InfoScrollFrame.ScrollBarThickness = 3
InfoScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
InfoScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
InfoScrollFrame.Parent = InfoScrollContainer

-- Content container inside scroll frame (for proper dynamic sizing)
local InfoContentContainer = Instance.new("Frame")
InfoContentContainer.Size = UDim2.new(1, 0, 0, 0)
InfoContentContainer.BackgroundTransparency = 1
InfoContentContainer.Parent = InfoScrollFrame

local InfoContentLayout = Instance.new("UIListLayout")
InfoContentLayout.Padding = UDim.new(0, 4)
InfoContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoContentLayout.Parent = InfoContentContainer

-- Update canvas size when content changes
InfoContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local contentHeight = InfoContentLayout.AbsoluteContentSize.Y
    InfoContentContainer.Size = UDim2.new(1, 0, 0, contentHeight)
    InfoScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
end)

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

    for k, v in raw:gmatch('"([^"]+)"%s*:%s*"([^"]+)"') do
        table.insert(lines, k .. "  →  " .. v)
    end

    if #lines > 0 then return lines end

    for v in raw:gmatch('"([^"]+)"') do
        table.insert(lines, v)
    end

    if #lines > 0 then return lines end

    for part in raw:gmatch("[^,]+") do
        local trimmed = part:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            table.insert(lines, trimmed)
        end
    end

    return lines
end

-- Expandable row for capsules/hotbar (FIXED - updates canvas size when expanded)
local function makeExpandableRow(statName, rawValue, order, pipColor)
    local lines = parseToLines(rawValue)
    local isEmpty = (#lines == 0)

    local LINE_H = 20
    local PAD_V = 10
    local contentH = isEmpty and 40 or (#lines * LINE_H + PAD_V * 2)

    local Wrapper = Instance.new("Frame")
    Wrapper.Size = UDim2.new(1, 0, 0, 38)
    Wrapper.BackgroundTransparency = 1
    Wrapper.BorderSizePixel = 0
    Wrapper.LayoutOrder = order
    Wrapper.ClipsDescendants = true
    Wrapper.Parent = InfoContentContainer
    table.insert(infoRows, Wrapper)

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = Color3.fromRGB(25, 16, 32)
    Header.BackgroundTransparency = 0.4
    Header.Text = ""
    Header.BorderSizePixel = 0
    Header.ZIndex = 4
    Header.Parent = Wrapper
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)

    local hStroke = Instance.new("UIStroke")
    hStroke.Color = Color3.fromRGB(156, 39, 176)
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

    local Badge = Instance.new("Frame")
    Badge.Size = UDim2.new(0, 28, 0, 20)
    Badge.Position = UDim2.new(1, -72, 0.5, -10)
    Badge.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
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
    HintLbl.TextColor3 = Color3.fromRGB(128, 64, 144)
    HintLbl.TextXAlignment = Enum.TextXAlignment.Right
    HintLbl.Parent = Header

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(1, 0, 0, 0)
    Panel.Position = UDim2.new(0, 0, 0, 40)
    Panel.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
    Panel.BorderSizePixel = 0
    Panel.ClipsDescendants = true
    Panel.Parent = Wrapper

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(128, 0, 255)
    pStroke.Thickness = 1
    pStroke.Transparency = 0.7
    pStroke.Parent = Panel

    if not isEmpty then
        for li, line in ipairs(lines) do
            local EL = Instance.new("TextLabel")
            EL.Size = UDim2.new(1, -20, 0, LINE_H)
            EL.Position = UDim2.new(0, 10, 0, PAD_V + (li - 1) * LINE_H)
            EL.BackgroundTransparency = 1
            EL.Text = "• " .. line
            EL.Font = Enum.Font.Gotham
            EL.TextSize = 11
            EL.TextColor3 = Color3.fromRGB(196, 160, 216)
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

    local expanded = false
    Header.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            Wrapper.Size = UDim2.new(1, 0, 0, 38 + 4 + contentH)
            TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, contentH)}):Play()
            HintLbl.Text = "▼  collapse"
            TweenService:Create(HintLbl, TweenInfo.new(0.15), {TextColor3 = pipColor}):Play()
            TweenService:Create(Header, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 8, 28)}):Play()
            hStroke.Color = Color3.fromRGB(128, 0, 255)
            hStroke.Transparency = 0.3
        else
            TweenService:Create(Panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(0.19, function()
                if not expanded then
                    Wrapper.Size = UDim2.new(1, 0, 0, 38)
                end
            end)
            HintLbl.Text = "▶  expand"
            TweenService:Create(HintLbl, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(128, 64, 144)}):Play()
            TweenService:Create(Header, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 16, 32)}):Play()
            hStroke.Color = Color3.fromRGB(156, 39, 176)
            hStroke.Transparency = 0.7
        end
        
        -- Force canvas update after animation
        task.wait(0.25)
        local contentHeight = InfoContentLayout.AbsoluteContentSize.Y
        InfoContentContainer.Size = UDim2.new(1, 0, 0, contentHeight)
        InfoScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
    end)

    Header.MouseEnter:Connect(function()
        if not expanded then
            TweenService:Create(Header, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 20, 38)}):Play()
        end
    end)
    Header.MouseLeave:Connect(function()
        if not expanded then
            TweenService:Create(Header, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 16, 32)}):Play()
        end
    end)

    return Wrapper
end

local function makeInfoStatRow(statName, statValue, order, labelColor)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(25, 16, 32)
    Row.BackgroundTransparency = 0.4
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = InfoContentContainer
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(156, 39, 176)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.Parent = Row

    local Pip = Instance.new("Frame")
    Pip.Size = UDim2.new(0, 3, 0.6, 0)
    Pip.Position = UDim2.new(0, 0, 0.2, 0)
    Pip.BackgroundColor3 = labelColor or Color3.fromRGB(156, 39, 176)
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
    ValLbl.TextColor3 = (displayVal == "None" or displayVal == "—") and Color3.fromRGB(160, 80, 80) or Color3.fromRGB(200, 180, 210)
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Parent = Row

    table.insert(infoRows, Row)
    return Row
end

local function makeInfoLevelBanner(level, order)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 48)
    Row.BackgroundColor3 = Color3.fromRGB(20, 8, 28)
    Row.BackgroundTransparency = 0.3
    Row.BorderSizePixel = 0
    Row.LayoutOrder = order
    Row.Parent = InfoContentContainer
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(156, 39, 176)
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
    Stars.TextColor3 = Color3.fromRGB(176, 48, 196)
    Stars.TextXAlignment = Enum.TextXAlignment.Left
    Stars.Parent = Row

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0, 80, 1, 0)
    Lbl.Position = UDim2.new(0, 70, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "LEVEL"
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 13
    Lbl.TextColor3 = Color3.fromRGB(196, 96, 216)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Row

    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0, 110, 1, 0)
    Val.Position = UDim2.new(1, -118, 0, 0)
    Val.BackgroundTransparency = 1
    Val.Text = tostring(level)
    Val.Font = Enum.Font.GothamBold
    Val.TextSize = 22
    Val.TextColor3 = Color3.fromRGB(216, 128, 255)
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
    InfoStatusLabel.TextColor3 = Color3.fromRGB(128, 64, 144)

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
    InfoStatusLabel.TextColor3 = Color3.fromRGB(176, 48, 196)
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
            makeInfoStatRow(key, v and tostring(v.Value) or "—", order, Color3.fromRGB(156, 39, 176))
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
            makeInfoStatRow(key, display, order, Color3.fromRGB(216, 96, 196))
        end

        -- Zenni
        order = order + 1
        local zv = RepStats:FindFirstChild("Zenni")
        makeInfoStatRow("Zenni", zv and tostring(zv.Value) or "—", order, Color3.fromRGB(240, 190, 40))

        -- EquippedCapsules (Expandable)
        order = order + 1
        local cv = RepStats:FindFirstChild("EquippedCapsules")
        makeExpandableRow("Equipped Capsules", cv and cv.Value or "", order, Color3.fromRGB(176, 96, 255))

        -- Hotbar (Expandable)
        order = order + 1
        local hv = RepStats:FindFirstChild("Hotbar")
        makeExpandableRow("Hotbar", hv and hv.Value or "", order, Color3.fromRGB(196, 96, 216))
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
--              AUTO PANEL (EVIL EDITION)
-- ═══════════════════════════════════════════
local AutoPanel = Instance.new("Frame")
AutoPanel.Name = "AutoPanel"
AutoPanel.Size = UDim2.new(1, 0, 1, 0)
AutoPanel.BackgroundTransparency = 1
AutoPanel.Visible = false
AutoPanel.Parent = ContentArea
ContentPanels["Auto"] = AutoPanel

local VirtualInputManager = game:GetService("VirtualInputManager")

-- Create a scrolling frame for the autofarmer UI
local AutoScroll = Instance.new("ScrollingFrame")
AutoScroll.Size = UDim2.new(1, 0, 1, 0)
AutoScroll.BackgroundTransparency = 1
AutoScroll.BorderSizePixel = 0
AutoScroll.ScrollBarThickness = 3
AutoScroll.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
AutoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
AutoScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AutoScroll.Parent = AutoPanel

local AutoLayout = Instance.new("UIListLayout")
AutoLayout.Padding = UDim.new(0, 8)
AutoLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoLayout.Parent = AutoScroll

-- Status Display
local StatusFrameAuto = Instance.new("Frame")
StatusFrameAuto.Size = UDim2.new(1, -16, 0, 52)
StatusFrameAuto.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
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
TargetFrameAuto.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
TargetFrameAuto.BackgroundTransparency = 0.4
TargetFrameAuto.Parent = AutoScroll
Instance.new("UICorner", TargetFrameAuto).CornerRadius = UDim.new(0, 8)

local TargetTextAuto = Instance.new("TextLabel")
TargetTextAuto.Size = UDim2.new(1, 0, 1, 0)
TargetTextAuto.BackgroundTransparency = 1
TargetTextAuto.Text = "🎯 Target: None"
TargetTextAuto.TextColor3 = Color3.fromRGB(176, 128, 196)
TargetTextAuto.Font = Enum.Font.GothamSemibold
TargetTextAuto.TextSize = 12
TargetTextAuto.Parent = TargetFrameAuto

-- HP Bar
local HPFrameAuto = Instance.new("Frame")
HPFrameAuto.Size = UDim2.new(1, -16, 0, 42)
HPFrameAuto.BackgroundTransparency = 1
HPFrameAuto.Parent = AutoScroll

local HPLabelAuto = Instance.new("TextLabel")
HPLabelAuto.Size = UDim2.new(1, 0, 0, 20)
HPLabelAuto.BackgroundTransparency = 1
HPLabelAuto.Text = "❤️ HP: 100%"
HPLabelAuto.TextColor3 = Color3.fromRGB(176, 128, 196)
HPLabelAuto.Font = Enum.Font.Gotham
HPLabelAuto.TextSize = 11
HPLabelAuto.TextXAlignment = Enum.TextXAlignment.Left
HPLabelAuto.Parent = HPFrameAuto

local HPBarBG = Instance.new("Frame")
HPBarBG.Size = UDim2.new(1, 0, 0, 6)
HPBarBG.Position = UDim2.new(0, 0, 0, 24)
HPBarBG.BackgroundColor3 = Color3.fromRGB(40, 30, 45)
HPBarBG.BorderSizePixel = 0
HPBarBG.Parent = HPFrameAuto
Instance.new("UICorner", HPBarBG).CornerRadius = UDim.new(1, 0)

local HPBarFill = Instance.new("Frame")
HPBarFill.Size = UDim2.new(1, 0, 0, 6)
HPBarFill.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
HPBarFill.BorderSizePixel = 0
HPBarFill.Parent = HPBarBG
Instance.new("UICorner", HPBarFill).CornerRadius = UDim.new(1, 0)

-- ========== MAIN CONTROLS ==========
local ControlsSection = Instance.new("Frame")
ControlsSection.Size = UDim2.new(1, -16, 0, 140)
ControlsSection.BackgroundTransparency = 1
ControlsSection.Parent = AutoScroll

local ControlsHeader = Instance.new("TextLabel")
ControlsHeader.Size = UDim2.new(1, 0, 0, 24)
ControlsHeader.BackgroundTransparency = 1
ControlsHeader.Text = "⚡ MAIN CONTROLS"
ControlsHeader.TextColor3 = Color3.fromRGB(176, 48, 196)
ControlsHeader.Font = Enum.Font.GothamBold
ControlsHeader.TextSize = 13
ControlsHeader.TextXAlignment = Enum.TextXAlignment.Left
ControlsHeader.Parent = ControlsSection

-- Enable AutoFarmer Button
local EnableBtn = Instance.new("TextButton")
EnableBtn.Size = UDim2.new(1, 0, 0, 48)
EnableBtn.Position = UDim2.new(0, 0, 0, 32)
EnableBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
EnableBtn.BackgroundTransparency = 0.3
EnableBtn.Text = "▶ ENABLE AUTOFARMER"
EnableBtn.TextColor3 = Color3.fromRGB(216, 128, 255)
EnableBtn.Font = Enum.Font.GothamBold
EnableBtn.TextSize = 14
EnableBtn.AutoButtonColor = false
EnableBtn.Parent = ControlsSection
Instance.new("UICorner", EnableBtn).CornerRadius = UDim.new(0, 8)

local EnableStroke = Instance.new("UIStroke")
EnableStroke.Color = Color3.fromRGB(176, 48, 196)
EnableStroke.Thickness = 1
EnableStroke.Transparency = 0.5
EnableStroke.Parent = EnableBtn

-- Status LED Indicator
local StatusLED = Instance.new("Frame")
StatusLED.Size = UDim2.new(0, 12, 0, 12)
StatusLED.Position = UDim2.new(1, -28, 0.5, -6)
StatusLED.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
StatusLED.BorderSizePixel = 0
StatusLED.Parent = EnableBtn
Instance.new("UICorner", StatusLED).CornerRadius = UDim.new(1, 0)

-- Stop Button
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, 0, 0, 48)
StopBtn.Position = UDim2.new(0, 0, 0, 88)
StopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
StopBtn.BackgroundTransparency = 0.4
StopBtn.Text = "⏹ STOP FARMING"
StopBtn.TextColor3 = Color3.fromRGB(255, 140, 140)
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
StopBtn.AutoButtonColor = false
StopBtn.Parent = ControlsSection
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

-- ========== COMBAT TOGGLES ==========
local CombatTogglesSection = Instance.new("Frame")
CombatTogglesSection.Size = UDim2.new(1, -16, 0, 140)
CombatTogglesSection.BackgroundTransparency = 1
CombatTogglesSection.Parent = AutoScroll

local CombatTogglesHeader = Instance.new("TextLabel")
CombatTogglesHeader.Size = UDim2.new(1, 0, 0, 24)
CombatTogglesHeader.BackgroundTransparency = 1
CombatTogglesHeader.Text = "⚔️ COMBAT TOGGLES"
CombatTogglesHeader.TextColor3 = Color3.fromRGB(176, 48, 196)
CombatTogglesHeader.Font = Enum.Font.GothamBold
CombatTogglesHeader.TextSize = 13
CombatTogglesHeader.TextXAlignment = Enum.TextXAlignment.Left
CombatTogglesHeader.Parent = CombatTogglesSection

-- M1 Toggle
local M1Row = Instance.new("Frame")
M1Row.Size = UDim2.new(1, 0, 0, 36)
M1Row.Position = UDim2.new(0, 0, 0, 32)
M1Row.BackgroundTransparency = 1
M1Row.Parent = CombatTogglesSection

local M1Label = Instance.new("TextLabel")
M1Label.Size = UDim2.new(0.6, 0, 1, 0)
M1Label.BackgroundTransparency = 1
M1Label.Text = "✊ M1 Attacks"
M1Label.TextColor3 = Color3.fromRGB(200, 180, 210)
M1Label.Font = Enum.Font.Gotham
M1Label.TextSize = 12
M1Label.TextXAlignment = Enum.TextXAlignment.Left
M1Label.Parent = M1Row

local M1ToggleBtn = Instance.new("TextButton")
M1ToggleBtn.Size = UDim2.new(0.25, 0, 1, -8)
M1ToggleBtn.Position = UDim2.new(0.75, 0, 0, 4)
M1ToggleBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
M1ToggleBtn.BackgroundTransparency = 0.3
M1ToggleBtn.Text = "ON"
M1ToggleBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
M1ToggleBtn.Font = Enum.Font.GothamBold
M1ToggleBtn.TextSize = 11
M1ToggleBtn.AutoButtonColor = false
M1ToggleBtn.Parent = M1Row
Instance.new("UICorner", M1ToggleBtn).CornerRadius = UDim.new(0, 6)

local M1Enabled = true
M1ToggleBtn.MouseButton1Click:Connect(function()
    M1Enabled = not M1Enabled
    if M1Enabled then
        M1ToggleBtn.Text = "ON"
        M1ToggleBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        M1ToggleBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
    else
        M1ToggleBtn.Text = "OFF"
        M1ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 80)
        M1ToggleBtn.TextColor3 = Color3.fromRGB(160, 100, 160)
    end
end)

-- M2 Toggle
local M2Row = Instance.new("Frame")
M2Row.Size = UDim2.new(1, 0, 0, 36)
M2Row.Position = UDim2.new(0, 0, 0, 72)
M2Row.BackgroundTransparency = 1
M2Row.Parent = CombatTogglesSection

local M2Label = Instance.new("TextLabel")
M2Label.Size = UDim2.new(0.6, 0, 1, 0)
M2Label.BackgroundTransparency = 1
M2Label.Text = "💥 M2 Attacks"
M2Label.TextColor3 = Color3.fromRGB(200, 180, 210)
M2Label.Font = Enum.Font.Gotham
M2Label.TextSize = 12
M2Label.TextXAlignment = Enum.TextXAlignment.Left
M2Label.Parent = M2Row

local M2ToggleBtn = Instance.new("TextButton")
M2ToggleBtn.Size = UDim2.new(0.25, 0, 1, -8)
M2ToggleBtn.Position = UDim2.new(0.75, 0, 0, 4)
M2ToggleBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
M2ToggleBtn.BackgroundTransparency = 0.3
M2ToggleBtn.Text = "ON"
M2ToggleBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
M2ToggleBtn.Font = Enum.Font.GothamBold
M2ToggleBtn.TextSize = 11
M2ToggleBtn.AutoButtonColor = false
M2ToggleBtn.Parent = M2Row
Instance.new("UICorner", M2ToggleBtn).CornerRadius = UDim.new(0, 6)

local M2Enabled = true
M2ToggleBtn.MouseButton1Click:Connect(function()
    M2Enabled = not M2Enabled
    if M2Enabled then
        M2ToggleBtn.Text = "ON"
        M2ToggleBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        M2ToggleBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
    else
        M2ToggleBtn.Text = "OFF"
        M2ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 80)
        M2ToggleBtn.TextColor3 = Color3.fromRGB(160, 100, 160)
    end
end)

-- Ability Keys Toggle (R, T, Y)
local AbilityRow = Instance.new("Frame")
AbilityRow.Size = UDim2.new(1, 0, 0, 36)
AbilityRow.Position = UDim2.new(0, 0, 0, 112)
AbilityRow.BackgroundTransparency = 1
AbilityRow.Parent = CombatTogglesSection

local AbilityLabel = Instance.new("TextLabel")
AbilityLabel.Size = UDim2.new(0.6, 0, 1, 0)
AbilityLabel.BackgroundTransparency = 1
AbilityLabel.Text = "⌨️ Ability Keys (R, T, Y)"
AbilityLabel.TextColor3 = Color3.fromRGB(200, 180, 210)
AbilityLabel.Font = Enum.Font.Gotham
AbilityLabel.TextSize = 12
AbilityLabel.TextXAlignment = Enum.TextXAlignment.Left
AbilityLabel.Parent = AbilityRow

local AbilityToggleBtn = Instance.new("TextButton")
AbilityToggleBtn.Size = UDim2.new(0.25, 0, 1, -8)
AbilityToggleBtn.Position = UDim2.new(0.75, 0, 0, 4)
AbilityToggleBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
AbilityToggleBtn.BackgroundTransparency = 0.3
AbilityToggleBtn.Text = "ON"
AbilityToggleBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
AbilityToggleBtn.Font = Enum.Font.GothamBold
AbilityToggleBtn.TextSize = 11
AbilityToggleBtn.AutoButtonColor = false
AbilityToggleBtn.Parent = AbilityRow
Instance.new("UICorner", AbilityToggleBtn).CornerRadius = UDim.new(0, 6)

local AbilityEnabled = true
AbilityToggleBtn.MouseButton1Click:Connect(function()
    AbilityEnabled = not AbilityEnabled
    if AbilityEnabled then
        AbilityToggleBtn.Text = "ON"
        AbilityToggleBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        AbilityToggleBtn.TextColor3 = Color3.fromRGB(196, 96, 216)
    else
        AbilityToggleBtn.Text = "OFF"
        AbilityToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 80)
        AbilityToggleBtn.TextColor3 = Color3.fromRGB(160, 100, 160)
    end
end)

-- ========== NPC SELECTION ==========
local NPCSelectionSection = Instance.new("Frame")
NPCSelectionSection.Size = UDim2.new(1, -16, 0, 240)
NPCSelectionSection.BackgroundTransparency = 1
NPCSelectionSection.Parent = AutoScroll

local NPCHeaderAuto = Instance.new("TextLabel")
NPCHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
NPCHeaderAuto.BackgroundTransparency = 1
NPCHeaderAuto.Text = "🎯 SELECT NPCS TO FARM (MAX 4)"
NPCHeaderAuto.TextColor3 = Color3.fromRGB(176, 48, 196)
NPCHeaderAuto.Font = Enum.Font.GothamBold
NPCHeaderAuto.TextSize = 12
NPCHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
NPCHeaderAuto.Parent = NPCSelectionSection

local NPCCountLabel = Instance.new("TextLabel")
NPCCountLabel.Size = UDim2.new(1, 0, 0, 18)
NPCCountLabel.Position = UDim2.new(0, 0, 0, 28)
NPCCountLabel.BackgroundTransparency = 1
NPCCountLabel.Text = "Selected: 0/4"
NPCCountLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
NPCCountLabel.Font = Enum.Font.Gotham
NPCCountLabel.TextSize = 10
NPCCountLabel.TextXAlignment = Enum.TextXAlignment.Left
NPCCountLabel.Parent = NPCSelectionSection

local NPCScrollFrame = Instance.new("ScrollingFrame")
NPCScrollFrame.Size = UDim2.new(1, 0, 0, 180)
NPCScrollFrame.Position = UDim2.new(0, 0, 0, 50)
NPCScrollFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
NPCScrollFrame.BackgroundTransparency = 0.5
NPCScrollFrame.BorderSizePixel = 0
NPCScrollFrame.ScrollBarThickness = 3
NPCScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
NPCScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
NPCScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
NPCScrollFrame.Parent = NPCSelectionSection
Instance.new("UICorner", NPCScrollFrame).CornerRadius = UDim.new(0, 8)

local NPCListLayoutAuto = Instance.new("UIListLayout")
NPCListLayoutAuto.Padding = UDim.new(0, 4)
NPCListLayoutAuto.SortOrder = Enum.SortOrder.LayoutOrder
NPCListLayoutAuto.Parent = NPCScrollFrame

local SelectedNPCs = {}
local NPCToggleButtons = {}

-- ========== ESCAPE SETTINGS ==========
local EscapeSectionAuto = Instance.new("Frame")
EscapeSectionAuto.Size = UDim2.new(1, -16, 0, 140)
EscapeSectionAuto.BackgroundTransparency = 1
EscapeSectionAuto.Parent = AutoScroll

local EscapeHeaderAuto = Instance.new("TextLabel")
EscapeHeaderAuto.Size = UDim2.new(1, 0, 0, 24)
EscapeHeaderAuto.BackgroundTransparency = 1
EscapeHeaderAuto.Text = "🛡️ ESCAPE PROTOCOL"
EscapeHeaderAuto.TextColor3 = Color3.fromRGB(176, 48, 196)
EscapeHeaderAuto.Font = Enum.Font.GothamBold
EscapeHeaderAuto.TextSize = 12
EscapeHeaderAuto.TextXAlignment = Enum.TextXAlignment.Left
EscapeHeaderAuto.Parent = EscapeSectionAuto

-- Escape HP Threshold
local EscapeHPRow = Instance.new("Frame")
EscapeHPRow.Size = UDim2.new(1, 0, 0, 36)
EscapeHPRow.Position = UDim2.new(0, 0, 0, 32)
EscapeHPRow.BackgroundTransparency = 1
EscapeHPRow.Parent = EscapeSectionAuto

local EscapeHPLabel = Instance.new("TextLabel")
EscapeHPLabel.Size = UDim2.new(0.6, 0, 1, 0)
EscapeHPLabel.BackgroundTransparency = 1
EscapeHPLabel.Text = "Escape when HP <"
EscapeHPLabel.TextColor3 = Color3.fromRGB(200, 180, 210)
EscapeHPLabel.Font = Enum.Font.Gotham
EscapeHPLabel.TextSize = 12
EscapeHPLabel.TextXAlignment = Enum.TextXAlignment.Left
EscapeHPLabel.Parent = EscapeHPRow

local EscapeHPBox = Instance.new("TextBox")
EscapeHPBox.Size = UDim2.new(0.25, 0, 1, -8)
EscapeHPBox.Position = UDim2.new(0.75, 0, 0, 4)
EscapeHPBox.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
EscapeHPBox.BackgroundTransparency = 0.3
EscapeHPBox.Text = "45"
EscapeHPBox.TextColor3 = Color3.fromRGB(176, 48, 196)
EscapeHPBox.Font = Enum.Font.GothamBold
EscapeHPBox.TextSize = 11
EscapeHPBox.Parent = EscapeHPRow
Instance.new("UICorner", EscapeHPBox).CornerRadius = UDim.new(0, 6)

-- Return HP Threshold
local ReturnHPRow = Instance.new("Frame")
ReturnHPRow.Size = UDim2.new(1, 0, 0, 36)
ReturnHPRow.Position = UDim2.new(0, 0, 0, 72)
ReturnHPRow.BackgroundTransparency = 1
ReturnHPRow.Parent = EscapeSectionAuto

local ReturnHPLabel = Instance.new("TextLabel")
ReturnHPLabel.Size = UDim2.new(0.6, 0, 1, 0)
ReturnHPLabel.BackgroundTransparency = 1
ReturnHPLabel.Text = "Return when HP >"
ReturnHPLabel.TextColor3 = Color3.fromRGB(200, 180, 210)
ReturnHPLabel.Font = Enum.Font.Gotham
ReturnHPLabel.TextSize = 12
ReturnHPLabel.TextXAlignment = Enum.TextXAlignment.Left
ReturnHPLabel.Parent = ReturnHPRow

local ReturnHPBox = Instance.new("TextBox")
ReturnHPBox.Size = UDim2.new(0.25, 0, 1, -8)
ReturnHPBox.Position = UDim2.new(0.75, 0, 0, 4)
ReturnHPBox.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
ReturnHPBox.BackgroundTransparency = 0.3
ReturnHPBox.Text = "75"
ReturnHPBox.TextColor3 = Color3.fromRGB(176, 48, 196)
ReturnHPBox.Font = Enum.Font.GothamBold
ReturnHPBox.TextSize = 11
ReturnHPBox.Parent = ReturnHPRow
Instance.new("UICorner", ReturnHPBox).CornerRadius = UDim.new(0, 6)

-- Escape Distance
local EscapeDistRow = Instance.new("Frame")
EscapeDistRow.Size = UDim2.new(1, 0, 0, 36)
EscapeDistRow.Position = UDim2.new(0, 0, 0, 112)
EscapeDistRow.BackgroundTransparency = 1
EscapeDistRow.Parent = EscapeSectionAuto

local EscapeDistLabel = Instance.new("TextLabel")
EscapeDistLabel.Size = UDim2.new(0.6, 0, 1, 0)
EscapeDistLabel.BackgroundTransparency = 1
EscapeDistLabel.Text = "Escape Distance"
EscapeDistLabel.TextColor3 = Color3.fromRGB(200, 180, 210)
EscapeDistLabel.Font = Enum.Font.Gotham
EscapeDistLabel.TextSize = 12
EscapeDistLabel.TextXAlignment = Enum.TextXAlignment.Left
EscapeDistLabel.Parent = EscapeDistRow

local EscapeDistBox = Instance.new("TextBox")
EscapeDistBox.Size = UDim2.new(0.25, 0, 1, -8)
EscapeDistBox.Position = UDim2.new(0.75, 0, 0, 4)
EscapeDistBox.BackgroundColor3 = Color3.fromRGB(20, 12, 30)
EscapeDistBox.BackgroundTransparency = 0.3
EscapeDistBox.Text = "3500"
EscapeDistBox.TextColor3 = Color3.fromRGB(176, 48, 196)
EscapeDistBox.Font = Enum.Font.GothamBold
EscapeDistBox.TextSize = 11
EscapeDistBox.Parent = EscapeDistRow
Instance.new("UICorner", EscapeDistBox).CornerRadius = UDim.new(0, 6)

-- ========== AUTOFARMER STATE ==========
local AutoFarmerState = {
    IsFarming = false,
    CurrentTargetIndex = 1,
    CurrentTarget = nil,
    CurrentTargetModel = nil,
    LastM1Time = 0,
    LastM2Time = 0,
    LastKeyPressTime = 0,
    LastKeyIndex = 1,
    IsEscaping = false,
    EscapePosition = nil,
    FlyConnection = nil,
    CombatConnection = nil,
    HealthCheckConnection = nil,
}

-- Update NPC List
local function UpdateNPCListAuto()
    for _, btn in ipairs(NPCToggleButtons) do
        pcall(function() btn:Destroy() end)
    end
    NPCToggleButtons = {}
    
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local npcs = {}
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
                        distance = dist,
                        selected = false
                    })
                end
            end
        end
    end
    
    table.sort(npcs, function(a, b) return a.distance < b.distance end)
    
    for _, npc in ipairs(npcs) do
        local isSelected = false
        for _, selected in ipairs(SelectedNPCs) do
            if selected.name == npc.name then
                isSelected = true
                break
            end
        end
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = isSelected and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(25, 16, 32)
        btn.BackgroundTransparency = isSelected and 0.5 or 0.6
        btn.Text = ""
        btn.Parent = NPCScrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(1, -10, 1, 0)
        nameText.Position = UDim2.new(0, 12, 0, 0)
        nameText.BackgroundTransparency = 1
        nameText.Text = npc.name .. "  [" .. math.floor(npc.distance) .. "s]"
        nameText.TextColor3 = isSelected and Color3.fromRGB(216, 128, 255) or Color3.fromRGB(176, 128, 196)
        nameText.Font = Enum.Font.GothamSemibold
        nameText.TextSize = 11
        nameText.TextXAlignment = Enum.TextXAlignment.Left
        nameText.Parent = btn
        
        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.new(0, 30, 1, 0)
        checkMark.Position = UDim2.new(1, -35, 0, 0)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = isSelected and "✓" or ""
        checkMark.TextColor3 = Color3.fromRGB(176, 48, 196)
        checkMark.Font = Enum.Font.GothamBold
        checkMark.TextSize = 16
        checkMark.TextXAlignment = Enum.TextXAlignment.Center
        checkMark.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if isSelected then
                for i, s in ipairs(SelectedNPCs) do
                    if s.name == npc.name then
                        table.remove(SelectedNPCs, i)
                        break
                    end
                end
                checkMark.Text = ""
                btn.BackgroundColor3 = Color3.fromRGB(25, 16, 32)
                btn.BackgroundTransparency = 0.6
                nameText.TextColor3 = Color3.fromRGB(176, 128, 196)
            elseif #SelectedNPCs < 4 then
                table.insert(SelectedNPCs, npc)
                checkMark.Text = "✓"
                btn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
                btn.BackgroundTransparency = 0.5
                nameText.TextColor3 = Color3.fromRGB(216, 128, 255)
            end
            NPCCountLabel.Text = "Selected: " .. #SelectedNPCs .. "/4"
        end)
        
        table.insert(NPCToggleButtons, btn)
    end
end

-- Update HP Bar
local function UpdateHPBarAuto()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.MaxHealth > 0 then
        local hp = (hum.Health / hum.MaxHealth) * 100
        local width = hp / 100
        HPBarFill.Size = UDim2.new(width, 0, 0, 6)
        HPLabelAuto.Text = "❤️ HP: " .. string.format("%.1f", hp) .. "%"
        
        if hp < 40 then
            HPBarFill.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
        elseif hp < 70 then
            HPBarFill.BackgroundColor3 = Color3.fromRGB(220, 180, 60)
        else
            HPBarFill.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        end
    end
end

-- Main Farming Logic
local function StartFarming()
    if AutoFarmerState.IsFarming then return end
    if #SelectedNPCs == 0 then
        StatusTextAuto.Text = "⚠ Select NPCs to farm first!"
        StatusTextAuto.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end
    
    AutoFarmerState.IsFarming = true
    AutoFarmerState.CurrentTargetIndex = 1
    AutoFarmerState.CurrentTarget = SelectedNPCs[1]
    AutoFarmerState.CurrentTargetModel = SelectedNPCs[1].model
    
    StatusTextAuto.Text = "● FARMING: ACTIVE"
    StatusTextAuto.TextColor3 = Color3.fromRGB(176, 96, 216)
    TargetTextAuto.Text = "🎯 Target: " .. SelectedNPCs[1].name
    TargetTextAuto.TextColor3 = Color3.fromRGB(176, 96, 216)
    StatusLED.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    EnableBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 120)
    
    -- Start loops
    StartCombatLoop()
    StartMovementLoop()
end

local function StopFarming()
    AutoFarmerState.IsFarming = false
    AutoFarmerState.IsEscaping = false
    
    if AutoFarmerState.CombatConnection then
        AutoFarmerState.CombatConnection:Disconnect()
        AutoFarmerState.CombatConnection = nil
    end
    if AutoFarmerState.FlyConnection then
        AutoFarmerState.FlyConnection:Disconnect()
        AutoFarmerState.FlyConnection = nil
    end
    if AutoFarmerState.HealthCheckConnection then
        AutoFarmerState.HealthCheckConnection:Disconnect()
        AutoFarmerState.HealthCheckConnection = nil
    end
    
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
    end
    
    StatusTextAuto.Text = "● SYSTEM: IDLE"
    StatusTextAuto.TextColor3 = Color3.fromRGB(220, 100, 100)
    TargetTextAuto.Text = "🎯 Target: None"
    TargetTextAuto.TextColor3 = Color3.fromRGB(176, 128, 196)
    StatusLED.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    EnableBtn.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
end

local function GetNextTarget()
    AutoFarmerState.CurrentTargetIndex = AutoFarmerState.CurrentTargetIndex % #SelectedNPCs + 1
    AutoFarmerState.CurrentTarget = SelectedNPCs[AutoFarmerState.CurrentTargetIndex]
    AutoFarmerState.CurrentTargetModel = AutoFarmerState.CurrentTarget.model
    TargetTextAuto.Text = "🎯 Target: " .. AutoFarmerState.CurrentTarget.name
end

local function StartCombatLoop()
    if AutoFarmerState.CombatConnection then AutoFarmerState.CombatConnection:Disconnect() end
    
    AutoFarmerState.CombatConnection = RunService.Heartbeat:Connect(function()
        if not AutoFarmerState.IsFarming or AutoFarmerState.IsEscaping then return end
        
        local targetModel = AutoFarmerState.CurrentTargetModel
        if not targetModel or not targetModel.Parent then
            GetNextTarget()
            return
        end
        
        local targetHum = targetModel:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            GetNextTarget()
            return
        end
        
        local now = tick()
        
        if M1Enabled and now - AutoFarmerState.LastM1Time >= 0.08 then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
            AutoFarmerState.LastM1Time = now
        end
        
        if M2Enabled and now - AutoFarmerState.LastM2Time >= 0.45 then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
            end)
            AutoFarmerState.LastM2Time = now
        end
        
        if AbilityEnabled and now - AutoFarmerState.LastKeyPressTime >= 0.35 then
            local keys = {Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y}
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, keys[AutoFarmerState.LastKeyIndex], false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, keys[AutoFarmerState.LastKeyIndex], false, game)
            end)
            AutoFarmerState.LastKeyIndex = AutoFarmerState.LastKeyIndex % 3 + 1
            AutoFarmerState.LastKeyPressTime = now
        end
    end)
end

local function StartMovementLoop()
    if AutoFarmerState.FlyConnection then AutoFarmerState.FlyConnection:Disconnect() end
    
    AutoFarmerState.FlyConnection = RunService.Heartbeat:Connect(function(dt)
        if not AutoFarmerState.IsFarming or AutoFarmerState.IsEscaping then return end
        
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        
        local targetPart = AutoFarmerState.CurrentTarget and AutoFarmerState.CurrentTarget.part
        if not targetPart or not targetPart.Parent then
            GetNextTarget()
            return
        end
        
        local targetHum = AutoFarmerState.CurrentTargetModel and AutoFarmerState.CurrentTargetModel:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            GetNextTarget()
            return
        end
        
        -- Check HP for escape
        local char = LocalPlayer.Character
        local playerHum = char and char:FindFirstChildOfClass("Humanoid")
        local escapeHP = tonumber(EscapeHPBox.Text) or 45
        if playerHum and (playerHum.Health / playerHum.MaxHealth) * 100 < escapeHP and not AutoFarmerState.IsEscaping then
            EscapeToSafety()
            return
        end
        
        local targetPos = targetPart.Position
        local currentPos = hrp.Position
        local dirToTarget = (targetPos - currentPos).Unit
        local distance = (targetPos - currentPos).Magnitude
        local desiredDistance = 12
        
        hum.PlatformStand = true
        hum.AutoRotate = false
        
        -- Circle movement
        local time = tick()
        local angle = time * 0.1
        local rightVector = Vector3.new(0, 1, 0):Cross(dirToTarget).Unit
        local forwardVector = dirToTarget:Cross(rightVector).Unit
        local circlePos = targetPos + (rightVector * math.cos(angle) * desiredDistance) + (forwardVector * math.sin(angle) * desiredDistance)
        circlePos = Vector3.new(circlePos.X, targetPos.Y + 2, circlePos.Z)
        
        local moveDir = (circlePos - currentPos).Unit
        local speed = 220
        local step = speed * dt
        local newPos = currentPos + moveDir * math.min(step, (circlePos - currentPos).Magnitude)
        
        hrp.CFrame = CFrame.new(newPos, targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        
        -- Face target
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    end)
end

local function EscapeToSafety()
    if AutoFarmerState.IsEscaping then return end
    AutoFarmerState.IsEscaping = true
    
    if AutoFarmerState.CombatConnection then
        AutoFarmerState.CombatConnection:Disconnect()
        AutoFarmerState.CombatConnection = nil
    end
    
    StatusTextAuto.Text = "⚠️ ESCAPE MODE ACTIVE ⚠️"
    StatusTextAuto.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local escapeDist = tonumber(EscapeDistBox.Text) or 3500
    local randomAngle = math.random() * math.pi * 2
    local randomDir = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
    local escapePos = hrp.Position + (randomDir * escapeDist)
    escapePos = Vector3.new(escapePos.X, hrp.Position.Y + 5, escapePos.Z)
    
    local startPos = hrp.Position
    local distance = (escapePos - startPos).Magnitude
    local duration = distance / 320
    local startTime = tick()
    
    local escapeConnection = RunService.Heartbeat:Connect(function()
        local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not currentHrp then return end
        
        local elapsed = tick() - startTime
        local t = math.min(1, elapsed / duration)
        local newPos = startPos:lerp(escapePos, t)
        currentHrp.CFrame = CFrame.new(newPos)
        currentHrp.AssemblyLinearVelocity = Vector3.zero
        
        if t >= 1 then
            escapeConnection:Disconnect()
            WaitForHealthRecovery()
        end
    end)
end

local function WaitForHealthRecovery()
    StatusTextAuto.Text = "💚 RECOVERING - CHARGING KI 💚"
    StatusTextAuto.TextColor3 = Color3.fromRGB(176, 96, 216)
    
    -- Charge Ki
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
    end)
    
    local returnHP = tonumber(ReturnHPBox.Text) or 75
    AutoFarmerState.HealthCheckConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and (hum.Health / hum.MaxHealth) * 100 >= returnHP then
            AutoFarmerState.HealthCheckConnection:Disconnect()
            AutoFarmerState.HealthCheckConnection = nil
            ReturnToCombat()
        end
        UpdateHPBarAuto()
    end)
end

local function ReturnToCombat()
    StatusTextAuto.Text = "🚀 RETURNING TO COMBAT 🚀"
    StatusTextAuto.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetPart = AutoFarmerState.CurrentTarget and AutoFarmerState.CurrentTarget.part
    if not hrp or not targetPart then
        AutoFarmerState.IsEscaping = false
        StartCombatLoop()
        return
    end
    
    local startPos = hrp.Position
    local targetPos = targetPart.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = distance / 320
    local startTime = tick()
    
    local returnConnection = RunService.Heartbeat:Connect(function()
        local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not currentHrp or not targetPart.Parent then
            returnConnection:Disconnect()
            AutoFarmerState.IsEscaping = false
            StartCombatLoop()
            return
        end
        
        local elapsed = tick() - startTime
        local t = math.min(1, elapsed / duration)
        local newPos = startPos:lerp(targetPart.Position, t)
        currentHrp.CFrame = CFrame.new(newPos, targetPart.Position)
        currentHrp.AssemblyLinearVelocity = Vector3.zero
        
        if t >= 1 then
            returnConnection:Disconnect()
            AutoFarmerState.IsEscaping = false
            StatusTextAuto.Text = "● FARMING: ACTIVE"
            StatusTextAuto.TextColor3 = Color3.fromRGB(176, 96, 216)
            StartCombatLoop()
        end
    end)
end

-- Button Connections
EnableBtn.MouseButton1Click:Connect(StartFarming)
StopBtn.MouseButton1Click:Connect(StopFarming)

-- Update NPC list periodically
task.spawn(function()
    while AutoPanel and AutoPanel.Parent do
        if not AutoFarmerState.IsFarming then
            pcall(UpdateNPCListAuto)
        end
        pcall(UpdateHPBarAuto)
        task.wait(2)
    end
end)

-- Character added cleanup
LocalPlayer.CharacterAdded:Connect(function()
    StopFarming()
    task.wait(1)
    UpdateNPCListAuto()
end)

-- Initial update
task.wait(1)
UpdateNPCListAuto()
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

-- [INTERACTABLES PANEL CONTENT - Same as original but with evil colors]

-- ═══════════════════════════════════════════
--              SIDEBAR TAB LOGIC
-- ═══════════════════════════════════════════
local function SwitchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name
    for _, td in ipairs(TabDefs) do
        local btn = TabButtons[td.name]
        local isActive = (td.name == name)
        if btn then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = isActive and 0.6 or 1,
                TextColor3 = isActive and Color3.fromRGB(196, 96, 216) or Color3.fromRGB(128, 96, 144),
            }):Play()
        end
        if ContentPanels[td.name] then
            ContentPanels[td.name].Visible = isActive
        end
    end
    for _, td in ipairs(TabDefs) do
        if td.name == name then
            TweenService:Create(ActiveIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0, 0, 0, td.yPos + 2)
            }):Play()
            break
        end
    end
end

-- Create Sidebar Buttons
for _, td in ipairs(TabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 38)
    btn.Position = UDim2.new(0.06, 0, 0, td.yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 20, 45)
    btn.BackgroundTransparency = (td.name == "Home") and 0.6 or 1
    btn.Text = "  " .. td.icon .. "   " .. td.name
    btn.TextColor3 = (td.name == "Home") and Color3.fromRGB(196, 96, 216) or Color3.fromRGB(128, 96, 144)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(156, 39, 176)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.8
    btnStroke.Parent = btn
    
    TabButtons[td.name] = btn
    btn.MouseButton1Click:Connect(function() SwitchTab(td.name) end)
end

-- Footer
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 28)
Footer.Position = UDim2.new(0, 0, 1, -28)
Footer.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
Footer.BackgroundTransparency = 0.2
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterGlow = Instance.new("Frame")
FooterGlow.Size = UDim2.new(1, 0, 0, 1)
FooterGlow.Position = UDim2.new(0, 0, 0, 0)
FooterGlow.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
FooterGlow.BackgroundTransparency = 0.5
FooterGlow.BorderSizePixel = 0
FooterGlow.Parent = Footer

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(1, 0, 1, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "WEZ HUB ◆ EVIL EDITION"
FooterText.TextColor3 = Color3.fromRGB(128, 64, 144)
FooterText.Font = Enum.Font.Gotham
FooterText.TextSize = 10
FooterText.Parent = Footer

-- UI Functions
local function HideUI()
    IsVisible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.2)
    MainFrame.Visible = false
    StarterGui:SetCore("SendNotification", {
        Title = "Wez Hub",
        Text = "Press RightAlt to show again.",
        Duration = 3
    })
end

local function ShowUI()
    IsVisible = true
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 580, 0, 420),
        BackgroundTransparency = 0.05
    }):Play()
end

local function ToggleUI()
    if IsVisible then HideUI() else ShowUI() end
end

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.15)
    ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    HideUI()
end)

-- Input Handler
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        ToggleUI()
    end
end)

-- Header Dragging
local dragging, dragStart, startPos = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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

-- Particle Effect
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.Parent = MainFrame

task.spawn(function()
    while MainFrame.Parent do
        task.wait(0.5)
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, 2, 0, 2)
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        particle.BackgroundTransparency = 0.5
        particle.BorderSizePixel = 0
        particle.Parent = ParticleContainer
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(particle, TweenInfo.new(2, Enum.EasingStyle.Quad), {
            Position = UDim2.new(particle.Position.X.Scale + (math.random() - 0.5) * 0.2, 0, 
                                   particle.Position.Y.Scale + (math.random() - 0.5) * 0.2, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(2, function() particle:Destroy() end)
    end
end)

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Wez Hub",
    Text = "Evil Edition Loaded | RightAlt to toggle",
    Duration = 4
})
