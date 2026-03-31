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
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = TeleportPanel

-- ═══════════════════════════════════════════
--              COLLAPSIBLE SECTIONS SYSTEM
-- ═══════════════════════════════════════════
local CollapsibleSections = {}

local function CreateCollapsibleSection(parent, title, icon, yOffset)
    local sectionHeight = 40
    local isExpanded = false
    
    -- Section Container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, sectionHeight)
    container.Position = UDim2.new(0, 8, 0, yOffset)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.Parent = parent
    
    -- Header Button
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, sectionHeight)
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
    
    -- Content Container (starts collapsed)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, sectionHeight + 4)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = container
    
    -- Content Scrolling Frame
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Size = UDim2.new(1, 0, 1, 0)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 2
    contentScroll.ScrollBarImageColor3 = Color3.fromRGB(156, 39, 176)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroll.Parent = content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentScroll
    
    -- Toggle Function
    local function ToggleSection()
        isExpanded = not isExpanded
        local targetHeight = isExpanded and 200 or 0
        local targetArrow = isExpanded and "▼" or "▶"
        
        TweenService:Create(content, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
        
        TweenService:Create(arrow, TweenInfo.new(0.2), {
            Text = targetArrow
        }):Play()
        
        TweenService:Create(header, TweenInfo.new(0.2), {
            BackgroundTransparency = isExpanded and 0.2 or 0.4
        }):Play()
    end
    
    header.MouseButton1Click:Connect(ToggleSection)
    
    return container, contentScroll, contentLayout, function()
        return isExpanded
    end
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
local function MakeTpButton(parent, displayText, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
    btn.BackgroundTransparency = 0.4
    btn.TextColor3 = Color3.fromRGB(200, 160, 220)
    btn.Text = displayText
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.Parent = parent
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
    -- Clear existing
    raidItems = {}
    dungeonItems = {}
    worldItems = {}
    questItems = {}
    dragonBallQuests = {}
    
    -- Scan Interactable folder
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
    
    -- Scan FriendlyNpcs for Quest Givers and Dragon Ball Quests
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
    
    -- Sort all lists alphabetically
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
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(1, 0, 1, 0)
mainContainer.BackgroundTransparency = 1
mainContainer.Parent = ScrollFrame

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 8)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Parent = mainContainer

-- Quick Teleport Section (always visible, no collapse needed)
local quickHeader = Instance.new("Frame")
quickHeader.Size = UDim2.new(1, -16, 0, 40)
quickHeader.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
quickHeader.BackgroundTransparency = 0.4
quickHeader.Parent = mainContainer
Instance.new("UICorner", quickHeader).CornerRadius = UDim.new(0, 8)

local quickTitle = Instance.new("TextLabel")
quickTitle.Size = UDim2.new(1, 0, 1, 0)
quickTitle.Position = UDim2.new(0, 12, 0, 0)
quickTitle.BackgroundTransparency = 1
quickTitle.Text = "⚡  QUICK TELEPORTS"
quickTitle.TextColor3 = Color3.fromRGB(176, 48, 196)
quickTitle.Font = Enum.Font.GothamBold
quickTitle.TextSize = 13
quickTitle.TextXAlignment = Enum.TextXAlignment.Left
quickTitle.Parent = quickHeader

-- Namekian Ship
local shipBtn = MakeTpButton(mainContainer, "🚀  Namekian Ship", function()
    local interactFolder = Workspace:FindFirstChild("Interactable")
    local ship = interactFolder and interactFolder:FindFirstChild("NamekianShip")
    if ship then
        local pos = GetObjPos(ship)
        if pos then StartTravel("Namekian Ship", pos) end
    end
end)
shipBtn.Size = UDim2.new(1, -16, 0, 32)

-- Create Collapsible Sections
local raidSection, raidContent, raidLayout, isRaidExpanded = CreateCollapsibleSection(mainContainer, "RAIDS", "⚔️", 0)
local dungeonSection, dungeonContent, dungeonLayout, isDungeonExpanded = CreateCollapsibleSection(mainContainer, "DUNGEONS", "🏰", 0)
local worldSection, worldContent, worldLayout, isWorldExpanded = CreateCollapsibleSection(mainContainer, "WORLD LOCATIONS", "🌍", 0)
local questSection, questContent, questLayout, isQuestExpanded = CreateCollapsibleSection(mainContainer, "QUEST GIVERS", "📜", 0)
local dragonSection, dragonContent, dragonLayout, isDragonExpanded = CreateCollapsibleSection(mainContainer, "DRAGON BALL QUESTS", "🐉", 0)

-- Custom Teleport Section (always visible)
local customHeader = Instance.new("Frame")
customHeader.Size = UDim2.new(1, -16, 0, 40)
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
customFrame.Size = UDim2.new(1, -16, 0, 70)
customFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
customFrame.BackgroundTransparency = 0.4
customFrame.Parent = mainContainer
Instance.new("UICorner", customFrame).CornerRadius = UDim.new(0, 8)

local CustomInput = Instance.new("TextBox")
CustomInput.Size = UDim2.new(1, -20, 0, 32)
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
CustomBtn.Size = UDim2.new(1, -20, 0, 28)
CustomBtn.Position = UDim2.new(0, 10, 0, 44)
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
    
    -- Clear all content containers
    for _, child in ipairs(raidContent:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, child in ipairs(dungeonContent:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, child in ipairs(worldContent:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, child in ipairs(questContent:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, child in ipairs(dragonContent:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Add "No locations found" labels if empty
    if #raidItems == 0 then
        local noLabel = Instance.new("TextLabel")
        noLabel.Size = UDim2.new(1, 0, 0, 32)
        noLabel.BackgroundTransparency = 1
        noLabel.Text = "  ⚠ No raid locations found"
        noLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
        noLabel.Font = Enum.Font.Gotham
        noLabel.TextSize = 11
        noLabel.TextXAlignment = Enum.TextXAlignment.Left
        noLabel.Parent = raidContent
    else
        for _, item in ipairs(raidItems) do
            MakeTpButton(raidContent, "🗡️  " .. item.name, function()
                StartTravel(item.name, item.getPos())
            end)
        end
    end
    
    if #dungeonItems == 0 then
        local noLabel = Instance.new("TextLabel")
        noLabel.Size = UDim2.new(1, 0, 0, 32)
        noLabel.BackgroundTransparency = 1
        noLabel.Text = "  ⚠ No dungeon locations found"
        noLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
        noLabel.Font = Enum.Font.Gotham
        noLabel.TextSize = 11
        noLabel.TextXAlignment = Enum.TextXAlignment.Left
        noLabel.Parent = dungeonContent
    else
        for _, item in ipairs(dungeonItems) do
            MakeTpButton(dungeonContent, "🔮  " .. item.name, function()
                StartTravel(item.name, item.getPos())
            end)
        end
    end
    
    if #worldItems == 0 then
        local noLabel = Instance.new("TextLabel")
        noLabel.Size = UDim2.new(1, 0, 0, 32)
        noLabel.BackgroundTransparency = 1
        noLabel.Text = "  ⚠ No world locations found"
        noLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
        noLabel.Font = Enum.Font.Gotham
        noLabel.TextSize = 11
        noLabel.TextXAlignment = Enum.TextXAlignment.Left
        noLabel.Parent = worldContent
    else
        for _, item in ipairs(worldItems) do
            MakeTpButton(worldContent, "📍  " .. item.name, function()
                StartTravel(item.name, item.getPos())
            end)
        end
    end
    
    if #questItems == 0 then
        local noLabel = Instance.new("TextLabel")
        noLabel.Size = UDim2.new(1, 0, 0, 32)
        noLabel.BackgroundTransparency = 1
        noLabel.Text = "  ⚠ No quest givers found"
        noLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
        noLabel.Font = Enum.Font.Gotham
        noLabel.TextSize = 11
        noLabel.TextXAlignment = Enum.TextXAlignment.Left
        noLabel.Parent = questContent
    else
        for _, item in ipairs(questItems) do
            MakeTpButton(questContent, "❓  " .. item.name, function()
                StartTravel(item.name, item.getPos())
            end)
        end
    end
    
    if #dragonBallQuests == 0 then
        local noLabel = Instance.new("TextLabel")
        noLabel.Size = UDim2.new(1, 0, 0, 32)
        noLabel.BackgroundTransparency = 1
        noLabel.Text = "  ⚠ No Dragon Ball quests available"
        noLabel.TextColor3 = Color3.fromRGB(128, 64, 144)
        noLabel.Font = Enum.Font.Gotham
        noLabel.TextSize = 11
        noLabel.TextXAlignment = Enum.TextXAlignment.Left
        noLabel.Parent = dragonContent
    else
        for _, item in ipairs(dragonBallQuests) do
            MakeTpButton(dragonContent, "⭐  " .. item.name, function()
                StartTravel(item.name, item.getPos())
            end)
        end
    end
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
--              INFO PANEL
-- ═══════════════════════════════════════════
local InfoPanel = Instance.new("Frame")
InfoPanel.Name = "InfoPanel"
InfoPanel.Size = UDim2.new(1, 0, 1, 0)
InfoPanel.BackgroundTransparency = 1
InfoPanel.Visible = false
InfoPanel.Parent = ContentArea
ContentPanels["Info"] = InfoPanel

-- [INFO PANEL CONTENT - Same as original but with evil colors]

-- ═══════════════════════════════════════════
--              AUTO PANEL
-- ═══════════════════════════════════════════
local AutoPanel = Instance.new("Frame")
AutoPanel.Name = "AutoPanel"
AutoPanel.Size = UDim2.new(1, 0, 1, 0)
AutoPanel.BackgroundTransparency = 1
AutoPanel.Visible = false
AutoPanel.Parent = ContentArea
ContentPanels["Auto"] = AutoPanel

-- [AUTO PANEL CONTENT - Same as original but with evil colors]

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
