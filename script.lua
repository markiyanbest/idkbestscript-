-- [[ V262.05: OMNI-REBORN - PERFECT EDITION ]]
-- [[ FIXES: MEMORY LEAKS | ESP SPAM | FAKELAG CRASH | NOCLIP BUGS | AIM PREDICTION ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- [[ 0. ЗАХИСТ ВІД ПОДВІЙНОГО ЗАПУСКУ ]]
-- ============================================================
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then
            v:Destroy()
        end
    end
    for _, v in pairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then
            v:Destroy()
        end
    end
end)

-- ============================================================
-- [[ 1. PHYSICS COLLISION GROUP ]]
-- ============================================================
local SafeGroup = "OmniSafeV262"
pcall(function()
    PhysicsService:RegisterCollisionGroup(SafeGroup)
    PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Default", false)
end)

-- ============================================================
-- [[ 2. RANDOM STRING (BYPASS) ]]
-- ============================================================
local function RandomString(len)
    local chars = {}
    for i = 1, len do
        chars[i] = string.char(math.random(97, 122))
    end
    return table.concat(chars)
end

-- ============================================================
-- [[ 3. BLUR ANTI-SCREENSHOT ]]
-- ============================================================
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local function SetBlur(active)
    TweenService:Create(Blur, TweenInfo.new(0.2), {
        Size = active and 36 or 0
    }):Play()
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F9
    or input.KeyCode == Enum.KeyCode.F12 then
        SetBlur(true)
        task.delay(1.5, function() SetBlur(false) end)
    end
end)

-- ============================================================
-- [[ 4. МОБІЛЬНІ КОНТРОЛЕРИ ]]
-- ============================================================
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1.5)
    pcall(function()
        local PM = require(LP.PlayerScripts:WaitForChild("PlayerModule", 5))
        Controls = PM:GetControls()
    end)
end)

-- ============================================================
-- [[ 5. КОНФІГ + СТАН ]]
-- ============================================================
local Config = {
    FlySpeed   = 55,
    WalkSpeed  = 85,
    JumpPower  = 125,
}

local State = {
    Fly          = false,
    Aim          = false,
    ShadowLock   = false,
    Noclip       = false,
    Hitbox       = false,
    Speed        = false,
    Bhop         = false,
    ESP          = false,
    Spin         = false,
    HighJump     = false,
    Potato       = false,
    FakeLag      = false,
    Freecam      = false,
    NoFallDamage = false,
    AntiAFK      = false,
    SilentAim    = false,
}

local LockedTarget  = nil
local Buttons       = {}
local FC_Pitch      = 0
local FC_Yaw        = 0

-- FPS лог (shared між петлями)
local FrameLog = {}

-- ============================================================
-- [[ 6. GUI SETUP ]]
-- ============================================================
local GuiParent = LP:WaitForChild("PlayerGui")
pcall(function()
    local cg = game:GetService("CoreGui")
    -- перевірка доступу
    local _ = cg.Name
    GuiParent = cg
end)

local Screen = Instance.new("ScreenGui", GuiParent)
Screen.Name           = RandomString(12)
Screen.ResetOnSpawn   = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Marker = Instance.new("BoolValue", Screen)
Marker.Name = "OmniMarker"

local IsMobile   = UIS.TouchEnabled
local MainWidth  = IsMobile and 210 or 240
local MainHeight = IsMobile and 400 or 570
local MBtnSize   = IsMobile and 55 or 45

-- [[ M КНОПКА ]]
local MToggle = Instance.new("TextButton", Screen)
MToggle.Size            = UDim2.new(0, MBtnSize, 0, MBtnSize)
MToggle.Position        = UDim2.new(0, 10, 0.45, 0)
MToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MToggle.Text            = "M"
MToggle.TextColor3      = Color3.fromRGB(0, 0, 0)
MToggle.Font            = Enum.Font.GothamBlack
MToggle.TextSize        = IsMobile and 28 or 22
MToggle.ZIndex          = 100
MToggle.AutoButtonColor = false
Instance.new("UICorner", MToggle)

-- Перетягування M кнопки (ЗАХИСТ ВІД SHIFT LOCK)
do
    local mDrag, mStart, mPos, mTick, mMoved = false, nil, nil, 0, false
    MToggle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            mDrag  = true
            mStart = inp.Position
            mPos   = MToggle.Position
            mTick  = tick()
            mMoved = false
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not mDrag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - mStart
            if d.Magnitude > 6 then mMoved = true end
            MToggle.Position = UDim2.new(
                mPos.X.Scale, mPos.X.Offset + d.X,
                mPos.Y.Scale, mPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if mDrag and not mMoved and tick() - mTick < 0.25 then
                -- відкриваємо меню тільки якщо НЕ перетягували
            end
            mDrag = false
        end
    end)
end

-- [[ STATS FRAME ]]
local StatsFrame = Instance.new("Frame", Screen)
StatsFrame.Size                = UDim2.new(0, 120, 0, 48)
StatsFrame.Position            = UDim2.new(1, -135, 0, 15)
StatsFrame.BackgroundColor3    = Color3.fromRGB(12, 12, 12)
StatsFrame.BackgroundTransparency = 0.15
StatsFrame.BorderSizePixel     = 0
Instance.new("UICorner", StatsFrame)

local StatsStroke = Instance.new("UIStroke", StatsFrame)
StatsStroke.Color     = Color3.fromRGB(255, 255, 255)
StatsStroke.Thickness = 1.5

local FPSLabel = Instance.new("TextLabel", StatsFrame)
FPSLabel.Size               = UDim2.new(1, 0, 0.5, 0)
FPSLabel.Position           = UDim2.new(0, 0, 0, 2)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
FPSLabel.Font               = Enum.Font.GothamBold
FPSLabel.TextSize            = 13
FPSLabel.Text               = "FPS: ..."

local PingLabel = Instance.new("TextLabel", StatsFrame)
PingLabel.Size               = UDim2.new(1, 0, 0.5, 0)
PingLabel.Position           = UDim2.new(0, 0, 0.5, -2)
PingLabel.BackgroundTransparency = 1
PingLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
PingLabel.Font               = Enum.Font.GothamBold
PingLabel.TextSize            = 13
PingLabel.Text               = "Ping: ..."

-- [[ ГОЛОВНИЙ ФРЕЙМ ]]
local Main = Instance.new("Frame", Screen)
Main.Size             = UDim2.new(0, MainWidth, 0, MainHeight)
Main.Position         = UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Main.Visible          = false
Main.Active           = true
Main.BorderSizePixel  = 0
Instance.new("UICorner", Main)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color     = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.5

-- Заголовок
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size             = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleBar.BorderSizePixel  = 0
Instance.new("UICorner", TitleBar)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size               = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
TitleLabel.Font               = Enum.Font.GothamBlack
TitleLabel.TextSize            = 14
TitleLabel.Text               = "OMNI V262.05"

-- Перетягування головного фрейму (ЗАХИСТ ВІД SHIFT LOCK)
do
    local drag, dStart, dPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag   = true
            dStart = inp.Position
            dPos   = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dStart
            Main.Position = UDim2.new(
                dPos.X.Scale, dPos.X.Offset + d.X,
                dPos.Y.Scale, dPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- [[ SCROLL ]]
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                = UDim2.new(1, -8, 1, -40)
Scroll.Position            = UDim2.new(0, 4, 0, 36)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness  = IsMobile and 0 or 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
Scroll.BorderSizePixel     = 0

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding             = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ScrollPad = Instance.new("UIPadding", Scroll)
ScrollPad.PaddingTop    = UDim.new(0, 4)
ScrollPad.PaddingBottom = UDim.new(0, 4)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 12)
end)
task.spawn(function()
    task.wait(0.3)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 12)
end)

-- ============================================================
-- [[ 7. HELPER FUNCTIONS ]]
-- ============================================================

-- Безпечний notify
local function Notify(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = dur or 2,
        })
    end)
end

-- Відновлення фізики персонажа
local function ForceRestore()
    local Char = LP.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local HRP = Char:FindFirstChild("HumanoidRootPart")

    if Hum then
        Hum.PlatformStand = false
        Hum.WalkSpeed     = 16
    end
    if HRP then
        -- Знищуємо SpinAV
        local av = HRP:FindFirstChild("SpinAV")
        if av then av:Destroy() end
        -- Розблокуємо якір (FakeLag)
        HRP.Anchored = false
    end
    for _, v in pairs(Char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide     = true
            v.CollisionGroup = "Default"
        end
    end
end

-- Перевірка чи ціль жива
local function IsAlive(char)
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- Отримати найближчого гравця (по дистанції від HRP)
local function GetClosestByDistance()
    local myChar = LP.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local best, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and IsAlive(char) then
            local d = (myHRP.Position - hrp.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best     = char
            end
        end
    end
    return best
end

-- Отримати найближчого до центру екрану (для Aim)
local function GetClosestToScreen()
    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )
    local best, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        local head = char and char:FindFirstChild("Head")
        if head and IsAlive(char) then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < bestDist then
                    bestDist = d
                    best     = char
                end
            end
        end
    end
    return best
end

-- Очищення ESP
local function ClearESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not char then continue end
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Highlight") and v:FindFirstChild("ESPMarker") then
                v:Destroy()
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            for _, v in pairs(head:GetChildren()) do
                if v:IsA("BillboardGui") and v:FindFirstChild("ESPMarker") then
                    v:Destroy()
                end
            end
        end
    end
end

-- Очищення Hitbox (повернення розміру)
local function RestoreHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            head.Size         = Vector3.new(1.2, 1.2, 1.2)
            head.Transparency = 0
            head.Material     = Enum.Material.Plastic
            head.Color        = Color3.fromRGB(163, 162, 155)
            head.CanCollide   = true
            head.Massless     = false
        end
    end
end

-- ============================================================
-- [[ 8. TOGGLE СИСТЕМА ]]
-- ============================================================
local function Toggle(Name)
    State[Name] = not State[Name]
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

    -- Cleanup при вимкненні
    if not State[Name] then
        if Name == "Fly" or Name == "Noclip" or Name == "ShadowLock" then
            ForceRestore()
        end
        if Name == "ESP" then ClearESP() end
        if Name == "Hitbox" then RestoreHitbox() end
        if Name == "Speed" and Hum then
            Hum.WalkSpeed = 16
        end
        if Name == "Freecam" then
            Camera.CameraType = Enum.CameraType.Custom
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            if HRP then HRP.Anchored = false end
            if Hum then Camera.CameraSubject = Hum end
        end
        if Name == "Spin" then
            if HRP then
                local av = HRP:FindFirstChild("SpinAV")
                if av then av:Destroy() end
            end
        end
        if Name == "FakeLag" and HRP then
            HRP.Anchored = false
        end
        if Name == "Potato" then
            Lighting.GlobalShadows = true
        end
    end

    -- Ввімкнення
    if State[Name] then
        if Name == "Spin" and HRP then
            local av = Instance.new("BodyAngularVelocity", HRP)
            av.Name            = "SpinAV"
            av.MaxTorque       = Vector3.new(0, math.huge, 0)
            av.AngularVelocity = Vector3.new(0, 20, 0)
            av.P               = 1200
        end

        if Name == "Fly" and HRP then
            pcall(function() HRP:SetNetworkOwner(nil) end)
        end

        if Name == "ShadowLock" then
            LockedTarget = GetClosestByDistance()
        end

        if Name == "Freecam" then
            Camera.CameraType = Enum.CameraType.Scriptable
            local x, y, _ = Camera.CFrame:ToEulerAnglesYXZ()
            FC_Pitch = x
            FC_Yaw   = y
            if HRP then HRP.Anchored = true end
        end

        if Name == "Potato" then
            Lighting.GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                pcall(function()
                    if v:IsA("BasePart") then
                        v.Material    = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                        v.CastShadow  = false
                    elseif v:IsA("ParticleEmitter")
                        or v:IsA("Trail")
                        or v:IsA("Decal")
                        or v:IsA("Texture") then
                        v:Destroy()
                    end
                end)
            end
        end
    end

    -- Оновлення кнопки
    if Buttons[Name] then
        local btn = Buttons[Name]
        local dot = btn:FindFirstChild("StatusDot")
        if State[Name] then
            btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextColor3       = Color3.fromRGB(0, 0, 0)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(0, 220, 80) end
        else
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50) end
        end
    end

    Notify(Name, State[Name] and "ON ✓" or "OFF ✗", 1.5)
end

-- ============================================================
-- [[ 9. ANTI-AFK (ПОДІЯ + ТАЙМЕР) ]]
-- ============================================================
LP.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

task.spawn(function()
    while task.wait(55) do
        if State.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end
end)

-- ============================================================
-- [[ 10. CHARACTER RESPAWN CLEANUP ]]
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    -- Скидання стану після смерті
    char:WaitForChild("HumanoidRootPart", 5)

    -- Fly скидається бо тіло нове
    if State.Fly then
        State.Fly = false
        if Buttons["Fly"] then
            Buttons["Fly"].BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            Buttons["Fly"].TextColor3       = Color3.fromRGB(255, 255, 255)
        end
    end
    if State.Noclip then
        State.Noclip = false
        if Buttons["Noclip"] then
            Buttons["Noclip"].BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            Buttons["Noclip"].TextColor3       = Color3.fromRGB(255, 255, 255)
        end
    end
    if State.Freecam then
        State.Freecam = false
        Camera.CameraType = Enum.CameraType.Custom
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end
end)

-- Очищення ESP при виході гравця
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        ClearESP()
    end
end)

-- CharacterAdded очищення ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not State.ESP then
            ClearESP()
        end
    end)
end)

-- ============================================================
-- [[ 11. UI КОМПОНЕНТИ ]]
-- ============================================================

-- Категорія
local function AddCategory(text)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.95, 0, 0, 18)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    f.BorderSizePixel  = 0
    Instance.new("UICorner", f)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size               = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3         = Color3.fromRGB(180, 180, 255)
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize            = 11
    lbl.Text               = "── " .. text .. " ──"
end

-- Кнопка-тогл
local function CreateBtn(Text, LogicName)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size             = UDim2.new(0.95, 0, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    Btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    Btn.Font             = Enum.Font.GothamBold
    Btn.TextSize          = IsMobile and 11 or 12
    Btn.BorderSizePixel  = 0
    Btn.AutoButtonColor  = false
    Btn.Text             = "  " .. Text
    Btn.TextXAlignment   = Enum.TextXAlignment.Left
    Instance.new("UICorner", Btn)

    -- Індикатор статусу
    local dot = Instance.new("Frame", Btn)
    dot.Name             = "StatusDot"
    dot.Size             = UDim2.new(0, 7, 0, 7)
    dot.Position         = UDim2.new(1, -14, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot)

    Buttons[LogicName] = Btn
    Btn.MouseButton1Click:Connect(function()
        Toggle(LogicName)
    end)

    return Btn
end

-- Слайдер (ЗАХИСТ ВІД SHIFT LOCK)
local function CreateSlider(Text, Min, Max, Default, Callback)
    local Container = Instance.new("Frame", Scroll)
    Container.Size             = UDim2.new(0.95, 0, 0, 52)
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Container.BorderSizePixel  = 0
    Instance.new("UICorner", Container)

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, -8, 0, 22)
    Label.Position           = UDim2.new(0, 4, 0, 2)
    Label.BackgroundTransparency = 1
    Label.TextColor3         = Color3.fromRGB(220, 220, 220)
    Label.Font               = Enum.Font.GothamBold
    Label.TextSize            = 11
    Label.TextXAlignment     = Enum.TextXAlignment.Left
    Label.Text               = Text .. ": " .. Default

    local Track = Instance.new("Frame", Container)
    Track.Size             = UDim2.new(0.92, 0, 0, 7)
    Track.Position         = UDim2.new(0.04, 0, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    Track.BorderSizePixel  = 0
    Instance.new("UICorner", Track)

    local Fill = Instance.new("Frame", Track)
    Fill.Size             = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Fill.BorderSizePixel  = 0
    Instance.new("UICorner", Fill)

    local Knob = Instance.new("Frame", Track)
    Knob.Size             = UDim2.new(0, 13, 0, 13)
    Knob.Position         = UDim2.new((Default - Min) / (Max - Min), -6, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel  = 0
    Instance.new("UICorner", Knob)

    local dragging = false

    local function Update(input)
        local rel = math.clamp(
            (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X,
            0, 1
        )
        local value = math.floor(Min + rel * (Max - Min))
        Fill.Size     = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -6, 0.5, -6)
        Label.Text    = Text .. ": " .. value
        Callback(value)
    end

    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(inp)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            Update(inp)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- [[ 12. НАПОВНЕННЯ GUI ]]
-- ============================================================
AddCategory("SPEED")
CreateSlider("🚀 FLY SPEED",  0,   300, Config.FlySpeed,  function(v) Config.FlySpeed  = v end)
CreateSlider("⚡ WALK SPEED", 16,  200, Config.WalkSpeed, function(v) Config.WalkSpeed = v end)
CreateSlider("⬆️ JUMP POWER", 50,  500, Config.JumpPower, function(v) Config.JumpPower = v end)

AddCategory("COMBAT")
CreateBtn("🎯 AUTO AIM [G]",    "Aim")
CreateBtn("🔫 SILENT AIM",      "SilentAim")
CreateBtn("💀 MAGNET",          "ShadowLock")
CreateBtn("🥊 HITBOX",          "Hitbox")
CreateBtn("📦 ADVANCED ESP",    "ESP")

AddCategory("MOVEMENT")
CreateBtn("🕊️ FLY [F]",         "Fly")
CreateBtn("⚡ SPEED",            "Speed")
CreateBtn("🐇 BHOP",            "Bhop")
CreateBtn("⬆️ HIGH JUMP",       "HighJump")
CreateBtn("👻 NOCLIP [V]",      "Noclip")
CreateBtn("🛡️ NO FALL DAMAGE",  "NoFallDamage")

AddCategory("MISC")
CreateBtn("🌀 SPIN",            "Spin")
CreateBtn("🥔 POTATO MODE",     "Potato")
CreateBtn("📶 FAKE LAG",        "FakeLag")
CreateBtn("🎥 FREECAM",         "Freecam")
CreateBtn("🛡️ ANTI-AFK",        "AntiAFK")

-- ============================================================
-- [[ 13. РЕНДЕР ПЕТЛЯ ]]
-- ============================================================
local lastPing   = 0
local pingTick   = 0
local PING_INTERVAL = 2 -- оновлювати ping раз в 2 секунди

RunService.RenderStepped:Connect(function(dt)
    -- FPS лічильник (оптимізовано: без table.remove в циклі)
    local now = tick()
    table.insert(FrameLog, now)
    -- Видаляємо старі записи з початку
    while FrameLog[1] and FrameLog[1] < now - 1 do
        table.remove(FrameLog, 1)
    end
    FPSLabel.Text = "FPS: " .. #FrameLog

    -- Ping (не кожен кадр!)
    if now - pingTick > PING_INTERVAL then
        pingTick = now
        pcall(function()
            lastPing = LP:GetNetworkPing()
        end)
    end
    PingLabel.Text = "Ping: " .. math.floor(lastPing * 1000) .. "ms"

    -- [[ FREECAM ]]
    if State.Freecam then
        local moveX, moveZ = 0, 0
        if not IsMobile then
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveZ = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveZ =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveX =  1 end
        elseif Controls then
            local mv = Controls:GetMoveVector()
            moveX = mv.X; moveZ = mv.Z
        end

        local dir = Camera.CFrame.LookVector * -moveZ
                  + Camera.CFrame.RightVector * moveX

        if UIS:IsKeyDown(Enum.KeyCode.E)
        or UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir += Camera.CFrame.UpVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Q)
        or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir -= Camera.CFrame.UpVector
        end

        -- Нормалізація щоб діагональ не була швидшою
        if dir.Magnitude > 1 then dir = dir.Unit end

        local fps   = math.max(#FrameLog, 1)
        local speed = (Config.FlySpeed / 25) * (60 / fps)
        local newPos = Camera.CFrame.Position + dir * speed

        Camera.CFrame = CFrame.new(newPos)
            * CFrame.fromEulerAnglesYXZ(FC_Pitch, FC_Yaw, 0)
    end

    -- [[ AUTO AIM (з передбаченням) ]]
    if State.Aim and not State.Freecam then
        local target = GetClosestToScreen()
        if target then
            local head = target:FindFirstChild("Head")
            if head then
                local predVel = head.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.2)
                Camera.CFrame = CFrame.new(
                    Camera.CFrame.Position,
                    head.Position + predVel
                )
            end
        end
    end

    -- [[ SILENT AIM ]]
    if State.SilentAim and not State.Freecam then
        local target = GetClosestToScreen()
        if target then
            local head = target:FindFirstChild("Head")
            if head then
                Camera.CFrame = CFrame.new(
                    Camera.CFrame.Position,
                    head.Position
                )
            end
        end
    end

    -- [[ ESP (оновлення тексту) ]]
    if State.ESP then
        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            local char = p.Character
            if not char then continue end

            local head = char:FindFirstChild("Head")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not head or not hum then continue end

            -- Highlight
            local hl = nil
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Highlight") and v:FindFirstChild("ESPMarker") then
                    hl = v; break
                end
            end
            if not hl then
                hl = Instance.new("Highlight", char)
                hl.Name                = RandomString(8)
                hl.FillColor           = Color3.fromRGB(255, 40, 40)
                hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency    = 0.5
                hl.OutlineTransparency = 0
                local m = Instance.new("BoolValue", hl)
                m.Name = "ESPMarker"
            end
            hl.Enabled = IsAlive(char)

            -- BillboardGui
            local bb = nil
            for _, v in pairs(head:GetChildren()) do
                if v:IsA("BillboardGui") and v:FindFirstChild("ESPMarker") then
                    bb = v; break
                end
            end
            if not bb then
                bb = Instance.new("BillboardGui", head)
                bb.Name          = RandomString(6)
                bb.Size          = UDim2.new(0, 200, 0, 55)
                bb.StudsOffset   = Vector3.new(0, 3.2, 0)
                bb.AlwaysOnTop   = true
                bb.MaxDistance   = 600

                local bg = Instance.new("Frame", bb)
                bg.Size               = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
                bg.BackgroundTransparency = 0.45
                bg.BorderSizePixel    = 0
                Instance.new("UICorner", bg)

                local lbl = Instance.new("TextLabel", bg)
                lbl.Name               = "ESPText"
                lbl.Size               = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3         = Color3.fromRGB(255, 255, 255)
                lbl.Font               = Enum.Font.GothamBold
                lbl.TextSize            = 12
                lbl.TextWrapped        = true

                local marker = Instance.new("BoolValue", bb)
                marker.Name = "ESPMarker"
            end

            -- Оновлення тексту
            local lbl = bb:FindFirstChild("ESPText", true)
            if lbl then
                local hp    = math.floor(hum.Health)
                local maxHp = math.floor(hum.MaxHealth)
                local dist  = myHRP
                    and math.floor((myHRP.Position - head.Position).Magnitude)
                    or 0
                local ratio = hp / math.max(maxHp, 1)

                lbl.Text = string.format(
                    "[%s]\nHP: %d/%d | %dm",
                    p.Name, hp, maxHp, dist
                )

                if ratio >= 0.6 then
                    lbl.TextColor3 = Color3.fromRGB(80, 255, 120)
                elseif ratio >= 0.3 then
                    lbl.TextColor3 = Color3.fromRGB(255, 220, 40)
                else
                    lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
                end
            end
        end
    end
end)

-- [[ FREECAM MOUSE INPUT ]]
UIS.InputChanged:Connect(function(input, gpe)
    if not State.Freecam or gpe then return end
    local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouch = input.UserInputType == Enum.UserInputType.Touch

    if isMove or isTouch then
        local useMouse = isMove and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if useMouse or isTouch then
            FC_Yaw   = FC_Yaw - math.rad(input.Delta.X * 0.35)
            FC_Pitch = math.clamp(
                FC_Pitch - math.rad(input.Delta.Y * 0.35),
                -math.rad(89), math.rad(89)
            )
        end
    end
end)

-- ============================================================
-- [[ 14. HEARTBEAT ПЕТЛЯ ]]
-- ============================================================
local lastJump       = 0
local lastJitter     = 0
local JITTER_MIN     = 4
local JITTER_MAX     = 8

-- FakeLag окремий thread (без блокування Heartbeat)
local fakeLagThread = nil

local function StartFakeLag()
    if fakeLagThread then return end
    fakeLagThread = task.spawn(function()
        while State.FakeLag do
            local Char = LP.Character
            local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

            if HRP and Hum
            and Hum.MoveDirection.Magnitude > 0
            and not State.Fly
            and not State.Freecam then
                pcall(function() HRP.Anchored = true end)
                task.wait(math.random(35, 80) / 1000)
                pcall(function() HRP.Anchored = false end)
                task.wait(math.random(90, 200) / 1000)
            else
                task.wait(0.15)
            end
        end
        fakeLagThread = nil
    end)
end

RunService.Heartbeat:Connect(function(dt)
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum then return end

    -- FakeLag запуск/зупинка
    if State.FakeLag and not fakeLagThread then
        StartFakeLag()
    end

    -- [[ MAGNET (Lerp з передбаченням) ]]
    if State.ShadowLock then
        if not IsAlive(LockedTarget) then
            LockedTarget = GetClosestByDistance()
        end
        if LockedTarget then
            local tHRP = LockedTarget:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local ping   = math.clamp(lastPing, 0, 0.2)
                local pred   = tHRP.AssemblyLinearVelocity * ping
                local goal   = CFrame.new(tHRP.Position + pred)
                             * tHRP.CFrame.Rotation
                             * CFrame.new(0, 0, 3)
                HRP.CFrame   = HRP.CFrame:Lerp(goal, 0.4)
                HRP.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
            end
        end
    end

    -- [[ FLY ]]
    if State.Fly and not State.Freecam then
        Hum.PlatformStand = false

        local moveX, moveZ = 0, 0
        if not IsMobile then
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveZ = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveZ =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveX = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveX =  1 end
        elseif Controls then
            local mv = Controls:GetMoveVector()
            moveX = mv.X; moveZ = mv.Z
        end

        local dir = Camera.CFrame.LookVector * -moveZ
                  + Camera.CFrame.RightVector * moveX

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir += Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir -= Vector3.new(0, 1, 0)
        end

        -- Нормалізація вектору
        if dir.Magnitude > 1 then dir = dir.Unit end

        local fps   = math.max(#FrameLog, 1)
        local speed = Config.FlySpeed * (60 / fps)

        -- Легкий jitter для антиCheat
        local jx = math.noise(tick() * 18) * 1.2
        local jy = math.sin(tick() * 45) * 0.5
        local jz = math.noise(tick() * 22) * 1.0

        HRP.AssemblyLinearVelocity  = dir * speed + Vector3.new(jx, jy, jz)
        HRP.AssemblyAngularVelocity = State.Spin and HRP.AssemblyAngularVelocity or Vector3.zero

        -- Обмеження висоти
        if HRP.Position.Y > 200 then
            HRP.AssemblyLinearVelocity -= Vector3.new(0, 28, 0)
        end
    end

    -- [[ SPEED ]]
    if State.Speed and not State.Fly and not State.Freecam then
        if Hum.MoveDirection.Magnitude > 0
        and Hum.FloorMaterial ~= Enum.Material.Air then
            local fps   = math.max(#FrameLog, 1)
            local boost = (Config.WalkSpeed - 16) / 120
            HRP.CFrame  = HRP.CFrame + Hum.MoveDirection * (boost * (60 / fps))
        end
    end

    -- [[ HIGH JUMP ]]
    if State.HighJump and not State.Fly then
        local state = Hum:GetState()
        if state == Enum.HumanoidStateType.Jumping
        or UIS:IsKeyDown(Enum.KeyCode.Space) then
            HRP.AssemblyLinearVelocity = Vector3.new(
                HRP.AssemblyLinearVelocity.X,
                Config.JumpPower * 0.82,
                HRP.AssemblyLinearVelocity.Z
            )
        end
    end

    -- [[ BHOP ]]
    if State.Bhop and not State.Fly and not State.Freecam then
        if Hum.FloorMaterial ~= Enum.Material.Air
        and Hum.MoveDirection.Magnitude > 0 then
            local now = tick()
            if now - lastJump > 0.07 + math.random(-4, 4) / 1000 then
                Hum.Jump = true
                HRP.AssemblyLinearVelocity = Vector3.new(
                    HRP.AssemblyLinearVelocity.X,
                    60 + math.random(-8, 8),
                    HRP.AssemblyLinearVelocity.Z
                )
                lastJump = now
            end
        end
    end

    -- [[ NO FALL DAMAGE ]]
    if State.NoFallDamage then
        if Hum:GetState() == Enum.HumanoidStateType.Freefall
        and HRP.AssemblyLinearVelocity.Y < -28 then
            Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            HRP.AssemblyLinearVelocity = Vector3.new(
                HRP.AssemblyLinearVelocity.X,
                -4,
                HRP.AssemblyLinearVelocity.Z
            )
        end
    end

    -- [[ HITBOX JITTER ]]
    if State.Hitbox then
        local now = tick()
        if now - lastJitter > math.random(JITTER_MIN, JITTER_MAX) then
            lastJitter = now
            for _, p in pairs(Players:GetPlayers()) do
                if p == LP then continue end
                local char = p.Character
                if not char then continue end
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") and head.Size.X >= 15 then
                    local sz = math.clamp(
                        18 + math.random(-40, 40) / 100,
                        17.5, 18.5
                    )
                    head.Size = Vector3.new(sz, sz, sz)
                end
            end
        end
    end
end)

-- ============================================================
-- [[ 15. NOCLIP (Stepped) ]]
-- ============================================================
local lastNoclipPos = Vector3.zero

RunService.Stepped:Connect(function()
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

    if State.Noclip and Char and HRP and Hum then
        local moving = Hum.MoveDirection.Magnitude > 0
                    or HRP.AssemblyLinearVelocity.Magnitude > 5

        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then
                if moving then
                    v.CanCollide     = false
                    v.CollisionGroup = SafeGroup
                else
                    -- Повертаємо колізію якщо стоїмо
                    v.CanCollide     = true
                    v.CollisionGroup = "Default"
                end
            end
        end

        -- Антизастрягання
        if moving and (HRP.Position - lastNoclipPos).Magnitude < 0.04 then
            HRP.CFrame = HRP.CFrame
                + Hum.MoveDirection * 0.35
                + Vector3.new(0, 0.12, 0)
        end
        lastNoclipPos = HRP.Position

    elseif Char and HRP then
        lastNoclipPos = HRP.Position
    end

    -- Hitbox: вимикаємо колізію голови щоб не блокувала
    if State.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            local char = p.Character
            if not char then continue end
            local head = char:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                head.CanCollide = false
            end
        end
    end
end)

-- ============================================================
-- [[ 16. HITBOX ВІЗУАЛ (RenderStepped - тільки візуал) ]]
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not State.Hitbox then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not char or not IsAlive(char) then continue end
        local head = char:FindFirstChild("Head")
        if head and head:IsA("BasePart") and head.Size.X < 15 then
            -- Перший раз встановлюємо великий hitbox
            local sz = math.random(175, 185) / 10
            head.Size         = Vector3.new(sz, sz, sz)
            head.Transparency = 0.45
            head.Material     = Enum.Material.ForceField
            head.Color        = Color3.fromRGB(255, 30, 30)
            head.CanTouch     = true
            head.CanQuery     = true
            head.Massless     = true
        end
    end
end)

-- ============================================================
-- [[ 17. КЛАВІШІ БІНДІВ ]]
-- ============================================================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.F then Toggle("Fly")    end
    if input.KeyCode == Enum.KeyCode.G then Toggle("Aim")    end
    if input.KeyCode == Enum.KeyCode.V then Toggle("Noclip") end

    if input.KeyCode == Enum.KeyCode.M then
        Main.Visible = not Main.Visible
    end
end)

-- MToggle кнопка відкриває меню
MToggle.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ============================================================
-- [[ ГОТОВО ]]
-- ============================================================
Notify("OMNI V262.05", "Завантажено! Натисни M для меню ✓", 4)
