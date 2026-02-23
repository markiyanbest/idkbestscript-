-- [[ V265.0: OMNI - ALL FIXED + NEW GUI ]]

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local Workspace      = game:GetService("Workspace")
local VirtualUser    = game:GetService("VirtualUser")
local PhysicsService = game:GetService("PhysicsService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- [[ 0. ПОДВІЙНИЙ ЗАПУСК ]]
-- ============================================================
pcall(function()
    for _, sg in pairs({ game:GetService("CoreGui"), LP:WaitForChild("PlayerGui") }) do
        for _, v in pairs(sg:GetChildren()) do
            if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then
                v:Destroy()
            end
        end
    end
end)

-- ============================================================
-- [[ 1. COLLISION GROUP ]]
-- ============================================================
local SafeGroup = "OmniSafeV265"
pcall(function()
    if not pcall(function() PhysicsService:GetCollisionGroupId(SafeGroup) end) then
        PhysicsService:RegisterCollisionGroup(SafeGroup)
    end
    PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Default", false)
end)

-- ============================================================
-- [[ 2. УТИЛІТИ ]]
-- ============================================================
local function RandomString(len)
    local t = table.create(len)
    for i = 1, len do t[i] = string.char(math.random(97, 122)) end
    return table.concat(t)
end

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 2
        })
    end)
end

local function SafeDestroy(obj)
    pcall(function() if obj and obj.Parent then obj:Destroy() end end)
end

-- ============================================================
-- [[ 3. ПЛАТФОРМА ]]
-- ============================================================
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsTablet = UIS.TouchEnabled

-- ============================================================
-- [[ 4. BLUR ]]
-- ============================================================
local Blur = Instance.new("BlurEffect")
Blur.Size = 0; Blur.Parent = Lighting

-- ============================================================
-- [[ 5. МОБІЛЬНІ КОНТРОЛЕРИ ]]
-- ============================================================
local Controls   = nil
local ControlsOK = false
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1.5)
    pcall(function()
        Controls   = require(LP.PlayerScripts:WaitForChild("PlayerModule", 8)):GetControls()
        ControlsOK = true
    end)
end)

-- ============================================================
-- [[ 6. КОНФІГ ]]
-- ============================================================
local Config = {
    FlySpeed  = 55,
    WalkSpeed = 30,
    JumpPower = 125,
}

local Binds = {
    Fly        = Enum.KeyCode.F,
    Aim        = Enum.KeyCode.G,
    Noclip     = Enum.KeyCode.V,
    SilentAim  = Enum.KeyCode.B,
    ToggleMenu = Enum.KeyCode.M,
}

local State = {
    Fly          = false,
    Aim          = false,
    SilentAim    = false,
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
    AntiKick     = false,
}

local LockedTarget  = nil
local Buttons       = {}
local BindButtons   = {}
local FC_Pitch      = 0
local FC_Yaw        = 0
local FrameLog      = {}
local lastPing      = 0
local pingTick      = 0
local silentActive  = false
local waitingBind   = nil
local MobileFlyUp   = false
local MobileFlyDown = false
local lastJump      = 0

-- ============================================================
-- [[ 7. ANTI-KICK - НАЙКРАЩИЙ МЕТОД ]]
-- ============================================================
-- Встановлюємо одразу при старті і тримаємо завжди
local antiKickEnabled = false
local originalNamecall = nil

local function SetupAntiKick()
    pcall(function()
        local mt = getrawmetatable(game)
        originalNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            -- Блокуємо Kick тільки якщо AntiKick увімкнений
            if antiKickEnabled then
                if method == "Kick" and self == LP then
                    Notify("ANTI-KICK", "Кік заблоковано! ✓", 2)
                    return
                end
                -- Блокуємо також FireServer з назвою kick
                if method == "FireServer" then
                    local args = {...}
                    if type(args[1]) == "string" then
                        local low = args[1]:lower()
                        if low:find("kick") or low:find("ban") then
                            return
                        end
                    end
                end
            end
            return originalNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

-- Встановлюємо одразу
SetupAntiKick()

-- ============================================================
-- [[ 8. HELPERS ]]
-- ============================================================
local function IsAlive(char)
    if not char or not char.Parent then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetClosestByDist()
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local best, bestD = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp and IsAlive(p.Character) then
            local d = (myHRP.Position - hrp.Position).Magnitude
            if d < bestD then bestD = d; best = p.Character end
        end
    end
    return best
end

local function GetClosestToScreen()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestD = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and IsAlive(p.Character) then
            local pos, on = Camera:WorldToViewportPoint(head.Position)
            if on then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < bestD then bestD = d; best = p.Character end
            end
        end
    end
    return best
end

-- ============================================================
-- [[ 9. SILENT AIM ]]
-- ============================================================
local hookInstalled = false
pcall(function()
    local mt  = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}
        -- AntiKick
        if antiKickEnabled then
            if method == "Kick" and self == LP then
                Notify("ANTI-KICK", "Кік заблоковано! ✓", 2)
                return
            end
        end
        -- Silent Aim
        if silentActive and self == Workspace then
            local target = GetClosestToScreen()
            local head   = target and target:FindFirstChild("Head")
            if head then
                local origin = Camera.CFrame.Position
                if method == "Raycast" and typeof(args[2]) == "Vector3" then
                    args[2] = (head.Position - origin).Unit * args[2].Magnitude
                elseif (method == "FindPartOnRayWithIgnoreList"
                     or method == "FindPartOnRay") and typeof(args[1]) == "Ray" then
                    args[1] = Ray.new(origin,
                        (head.Position - origin).Unit * args[1].Direction.Magnitude)
                end
            end
        end
        return old(self, unpack(args))
    end)
    setreadonly(mt, true)
    hookInstalled = true
end)

local lastSilentShot = 0
local function FallbackSilentAim()
    if not State.SilentAim or State.Freecam or State.Aim then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    local now = tick()
    if now - lastSilentShot < 0.1 then return end
    lastSilentShot = now
    local target = GetClosestToScreen()
    local head   = target and target:FindFirstChild("Head")
    if not head then return end
    Camera.CFrame = Camera.CFrame:Lerp(
        CFrame.new(Camera.CFrame.Position,
            head.Position + head.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.15)),
        0.3
    )
end

-- ============================================================
-- [[ 10. ESP ]]
-- ============================================================
local ESPCache = {}

local function ClearESP()
    for _, data in pairs(ESPCache) do
        pcall(function()
            if data.hl and data.hl.Parent then data.hl:Destroy() end
            if data.bb and data.bb.Parent then data.bb:Destroy() end
        end)
    end
    ESPCache = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP or not p.Character then continue end
        for _, v in pairs(p.Character:GetDescendants()) do
            if (v:IsA("Highlight") or v:IsA("BillboardGui"))
            and v:FindFirstChild("OmniESP") then v:Destroy() end
        end
    end
end

task.spawn(function()
    while task.wait(0.12) do
        if not State.ESP then continue end
        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            local char = p.Character
            local head = char and char:FindFirstChild("Head")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not head or not hum then
                if ESPCache[p] then
                    pcall(function()
                        if ESPCache[p].hl then ESPCache[p].hl:Destroy() end
                        if ESPCache[p].bb then ESPCache[p].bb:Destroy() end
                    end)
                    ESPCache[p] = nil
                end
                continue
            end
            local cache = ESPCache[p]
            local needRebuild = not cache
                or not cache.hl or not cache.hl.Parent
                or not cache.bb or not cache.bb.Parent
            if needRebuild then
                if cache then
                    pcall(function()
                        if cache.hl then cache.hl:Destroy() end
                        if cache.bb then cache.bb:Destroy() end
                    end)
                end
                local hl = Instance.new("Highlight", char)
                hl.FillColor           = Color3.fromRGB(220, 40, 40)
                hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency    = 0.5
                hl.OutlineTransparency = 0
                Instance.new("BoolValue", hl).Name = "OmniESP"
                local bb = Instance.new("BillboardGui", head)
                bb.Size        = UDim2.new(0, 190, 0, 58)
                bb.StudsOffset = Vector3.new(0, 3.4, 0)
                bb.AlwaysOnTop = true
                bb.MaxDistance = 500
                Instance.new("BoolValue", bb).Name = "OmniESP"
                local bg = Instance.new("Frame", bb)
                bg.Size                   = UDim2.new(1,0,1,0)
                bg.BackgroundColor3       = Color3.fromRGB(8,8,12)
                bg.BackgroundTransparency = 0.28
                bg.BorderSizePixel        = 0
                Instance.new("UICorner", bg).CornerRadius = UDim.new(0,8)
                local bgS = Instance.new("UIStroke", bg)
                bgS.Color = Color3.fromRGB(220,220,220); bgS.Thickness = 1.2
                local lbl = Instance.new("TextLabel", bg)
                lbl.Name               = "ESPText"
                lbl.Size               = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Font               = Enum.Font.GothamBold
                lbl.TextSize           = 12
                lbl.TextWrapped        = true
                lbl.TextColor3         = Color3.fromRGB(255,255,255)
                ESPCache[p] = { hl = hl, bb = bb, lbl = lbl }
                cache = ESPCache[p]
            end
            local hp    = math.floor(hum.Health)
            local maxHp = math.max(math.floor(hum.MaxHealth), 1)
            local dist  = myHRP
                and math.floor((myHRP.Position - head.Position).Magnitude) or 0
            local ratio = hp / maxHp
            cache.lbl.Text = string.format("[%s]\nHP: %d/%d | %dm", p.Name, hp, maxHp, dist)
            if ratio >= 0.6 then
                cache.lbl.TextColor3 = Color3.fromRGB(80,255,120)
            elseif ratio >= 0.3 then
                cache.lbl.TextColor3 = Color3.fromRGB(255,220,40)
            else
                cache.lbl.TextColor3 = Color3.fromRGB(255,60,60)
            end
            cache.hl.FillColor = ratio >= 0.5
                and Color3.fromRGB(40,180,80) or Color3.fromRGB(220,40,40)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        pcall(function()
            if ESPCache[p].hl then ESPCache[p].hl:Destroy() end
            if ESPCache[p].bb then ESPCache[p].bb:Destroy() end
        end)
        ESPCache[p] = nil
    end
end)

-- ============================================================
-- [[ 11. HITBOX ]]
-- ============================================================
local HITBOX_SIZE = 4.0
local hitboxParts = {}

local function ApplyHitbox(head)
    if not head or not head:IsA("BasePart") then return end
    head.Size = Vector3.new(HITBOX_SIZE,HITBOX_SIZE,HITBOX_SIZE)
    head.Transparency = 0.75
    head.CanTouch = true; head.CanQuery = true
    head.Massless = true; head.CanCollide = false
    hitboxParts[head] = true
end

local function RestoreHitbox()
    for head in pairs(hitboxParts) do
        pcall(function()
            if head and head.Parent then
                head.Size = Vector3.new(1.2,1.2,1.2)
                head.Transparency = 0
                head.CanCollide = true; head.Massless = false
            end
        end)
    end
    hitboxParts = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if not State.Hitbox then continue end
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or not IsAlive(p.Character) then continue end
            local head = p.Character:FindFirstChild("Head")
            if head and head.Size.X < HITBOX_SIZE - 0.1 then ApplyHitbox(head) end
        end
    end
end)

-- ============================================================
-- [[ 12. POTATO ]]
-- ============================================================
local savedShadows = true
local savedQuality = 1

local function ApplyPotato()
    savedShadows = Lighting.GlobalShadows
    savedQuality = settings().Rendering.QualityLevel
    Lighting.GlobalShadows = false
    settings().Rendering.QualityLevel = 1
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.CastShadow = false; v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end)
    end
    Notify("POTATO","Знижено ✓",2)
end

local function RestorePotato()
    Lighting.GlobalShadows = savedShadows
    settings().Rendering.QualityLevel = savedQuality
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then v.CastShadow = true
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = true
            end
        end)
    end
    Notify("POTATO","Відновлено ✓",2)
end

-- ============================================================
-- [[ 13. FORCE RESTORE ]]
-- ============================================================
local function ForceRestore()
    local Char = LP.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if Hum then
        Hum.PlatformStand = false
        Hum.WalkSpeed     = 16
        pcall(function() Hum.UseJumpPower = true; Hum.JumpPower = 50 end)
    end
    if HRP then
        HRP.Anchored = false
        for _, v in pairs(HRP:GetChildren()) do
            if v:IsA("BodyMover") then SafeDestroy(v) end
        end
    end
    if Char then
        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true; v.CollisionGroup = "Default"
            end
        end
    end
end

-- ============================================================
-- [[ 14. TOGGLE ]]
-- ============================================================
local fakeLagThread = nil

local function UpdateButtonVisual(Name)
    if Buttons[Name] then
        local btn = Buttons[Name]
        local dot = btn:FindFirstChild("StatusDot")
        if State[Name] then
            btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
            btn.TextColor3       = Color3.fromRGB(0,0,0)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(0,220,80) end
        else
            btn.BackgroundColor3 = Color3.fromRGB(28,28,35)
            btn.TextColor3       = Color3.fromRGB(235,235,235)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(220,50,50) end
        end
    end
    if BindButtons[Name] then
        local bd  = BindButtons[Name]
        local dot = bd.dot
        if State[Name] then
            bd.container.BackgroundColor3 = Color3.fromRGB(255,255,255)
            bd.mainBtn.TextColor3         = Color3.fromRGB(0,0,0)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(0,220,80) end
        else
            bd.container.BackgroundColor3 = Color3.fromRGB(28,28,35)
            bd.mainBtn.TextColor3         = Color3.fromRGB(235,235,235)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(220,50,50) end
        end
    end
end

local function Toggle(Name)
    State[Name] = not State[Name]
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

    if not State[Name] then
        if Name == "Fly" then
            if HRP then HRP.Anchored = false end
            if Hum then Hum.PlatformStand = false end
        end
        if Name == "Speed" and Hum then Hum.WalkSpeed = 16 end
        if Name == "HighJump" and Hum then
            pcall(function() Hum.UseJumpPower = true; Hum.JumpPower = 50 end)
        end
        if Name == "Noclip" or Name == "ShadowLock" then ForceRestore() end
        if Name == "ESP"       then ClearESP() end
        if Name == "Hitbox"    then RestoreHitbox() end
        if Name == "Potato"    then RestorePotato() end
        if Name == "SilentAim" then silentActive = false end
        if Name == "AntiKick"  then
            antiKickEnabled = false
            Notify("ANTI-KICK","Вимкнено ✗",2)
        end
        if Name == "Freecam" then
            Camera.CameraType = Enum.CameraType.Custom
            if Hum then Camera.CameraSubject = Hum end
            if HRP then HRP.Anchored = false end
        end
        if Name == "Spin" and HRP then
            for _, v in pairs(HRP:GetChildren()) do
                if v.Name == "SpinAV" then SafeDestroy(v) end
            end
        end
        if Name == "FakeLag" and HRP then HRP.Anchored = false end
    end

    if State[Name] then
        if Name == "SilentAim" then silentActive = true end
        if Name == "AntiKick"  then
            antiKickEnabled = true
            Notify("ANTI-KICK","Увімкнено ✓",2)
        end
        if Name == "Potato"    then ApplyPotato() end
        if Name == "ShadowLock" then LockedTarget = GetClosestByDist() end
        if Name == "Fly" and HRP then
            pcall(function() HRP:SetNetworkOwner(LP) end)
            if Hum then Hum.PlatformStand = false end
        end
        -- FIX: Speed застосовується одразу
        if Name == "Speed" and Hum then
            Hum.WalkSpeed = Config.WalkSpeed
        end
        -- FIX: HighJump застосовується одразу
        if Name == "HighJump" and Hum then
            pcall(function()
                Hum.UseJumpPower = true
                Hum.JumpPower    = Config.JumpPower
            end)
        end
        if Name == "Spin" and HRP then
            local av = Instance.new("BodyAngularVelocity", HRP)
            av.Name = "SpinAV"
            av.MaxTorque = Vector3.new(0, math.huge, 0)
            av.AngularVelocity = Vector3.new(0, 22, 0)
            av.P = 1500
        end
        if Name == "Freecam" then
            Camera.CameraSubject = nil
            Camera.CameraType    = Enum.CameraType.Scriptable
            local x, y, _ = Camera.CFrame:ToEulerAnglesYXZ()
            FC_Pitch = x; FC_Yaw = y
            if HRP then HRP.Anchored = true end
        end
        if Name == "FakeLag" and not fakeLagThread then
            fakeLagThread = task.spawn(function()
                while State.FakeLag do
                    local chr = LP.Character
                    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
                    local hum = chr and chr:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.MoveDirection.Magnitude > 0
                    and not State.Fly and not State.Freecam then
                        pcall(function() hrp.Anchored = true end)
                        task.wait(math.random(35,80)/1000)
                        pcall(function() hrp.Anchored = false end)
                        task.wait(math.random(90,200)/1000)
                    else
                        task.wait(0.15)
                    end
                end
                fakeLagThread = nil
            end)
        end
    end

    UpdateButtonVisual(Name)
    Notify(Name, State[Name] and "ON ✓" or "OFF ✗", 1.2)
end

-- ============================================================
-- [[ 15. ANTI-AFK ]]
-- ============================================================
LP.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
task.spawn(function()
    while task.wait(55) do
        if State.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- ============================================================
-- [[ 16. CHARACTER RESPAWN ]]
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    MobileFlyUp = false; MobileFlyDown = false
    for _, name in pairs({"Fly","Noclip","Freecam","Spin","FakeLag"}) do
        if State[name] then
            State[name] = false
            UpdateButtonVisual(name)
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        Camera.CameraType    = Enum.CameraType.Custom
        Camera.CameraSubject = hum
        task.wait(0.5)
        if State.Speed then hum.WalkSpeed = Config.WalkSpeed end
        if State.HighJump then
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower    = Config.JumpPower
            end)
        end
    end
end)

-- ============================================================
-- [[ 17. GUI ]]
-- ============================================================
local GuiParent = LP:WaitForChild("PlayerGui")
pcall(function()
    local cg = game:GetService("CoreGui")
    local _  = cg.Name
    GuiParent = cg
end)

local Screen = Instance.new("ScreenGui", GuiParent)
Screen.Name           = RandomString(12)
Screen.ResetOnSpawn   = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Instance.new("BoolValue", Screen).Name = "OmniMarker"

local IsMob = IsMobile
local MW    = IsMob and 250 or 265
local MH    = IsMob and 560 or 650
local MBS   = IsMob and 60  or 46
local BH    = IsMob and 40  or 34
local FS    = IsMob and 13  or 12

-- Кольори
local BG_MAIN  = Color3.fromRGB(10, 10, 14)
local BG_BTN   = Color3.fromRGB(22, 22, 28)
local BG_CAT   = Color3.fromRGB(16, 16, 20)
local COL_TEXT = Color3.fromRGB(235, 235, 235)
local COL_DIM  = Color3.fromRGB(140, 140, 150)
local COL_GRN  = Color3.fromRGB(0,   210, 75)
local COL_RED  = Color3.fromRGB(210, 45,  45)
local COL_WHT  = Color3.fromRGB(255, 255, 255)
local COL_BLK  = Color3.fromRGB(0,   0,   0)
local COL_BRD  = Color3.fromRGB(45,  45,  55)

-- ============================================================
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame", Screen)
Main.Name             = "OmniMain"
Main.Size             = UDim2.new(0, MW, 0, MH)
Main.Position         = UDim2.new(0.5, -MW/2, 0.5, -MH/2)
Main.BackgroundColor3 = BG_MAIN
Main.Visible          = false
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = COL_BRD; MainStroke.Thickness = 1.5

-- ============================================================
-- TITLE BAR - новий дизайн
-- ============================================================
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size             = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
TitleBar.BorderSizePixel  = 0

-- Нижня заглушка
local TFix = Instance.new("Frame", TitleBar)
TFix.Size = UDim2.new(1,0,0,12); TFix.Position = UDim2.new(0,0,1,-12)
TFix.BackgroundColor3 = Color3.fromRGB(14,14,18); TFix.BorderSizePixel = 0

-- Лівий кольоровий акцент (біла смуга)
local TitleAccent = Instance.new("Frame", TitleBar)
TitleAccent.Size             = UDim2.new(0, 3, 0.7, 0)
TitleAccent.Position         = UDim2.new(0, 0, 0.15, 0)
TitleAccent.BackgroundColor3 = COL_WHT
TitleAccent.BorderSizePixel  = 0
Instance.new("UICorner", TitleAccent).CornerRadius = UDim.new(0, 2)

-- Анімований градієнт
local TitleGradient = Instance.new("UIGradient", TitleBar)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 18, 24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 35, 45)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(18, 18, 24)),
})

-- Іконка
local TIcon = Instance.new("TextLabel", TitleBar)
TIcon.Size = UDim2.new(0,36,0,36); TIcon.Position = UDim2.new(0,10,0.5,-18)
TIcon.BackgroundTransparency = 1; TIcon.Text = "⚡"
TIcon.TextSize = 20; TIcon.Font = Enum.Font.GothamBlack
TIcon.TextColor3 = COL_WHT; TIcon.ZIndex = 3

-- Назва
local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1,-90,0,22); TitleLbl.Position = UDim2.new(0,42,0,4)
TitleLbl.BackgroundTransparency = 1; TitleLbl.TextColor3 = COL_WHT
TitleLbl.Font = Enum.Font.GothamBlack; TitleLbl.TextSize = 15
TitleLbl.Text = "OMNI V265.0"
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 3

-- Підпис
local SubLbl = Instance.new("TextLabel", TitleBar)
SubLbl.Size = UDim2.new(1,-90,0,14); SubLbl.Position = UDim2.new(0,42,0,26)
SubLbl.BackgroundTransparency = 1; SubLbl.TextColor3 = COL_DIM
SubLbl.Font = Enum.Font.Gotham; SubLbl.TextSize = 9
SubLbl.Text = IsMob and "MOBILE" or "FIXED EDITION"
SubLbl.TextXAlignment = Enum.TextXAlignment.Left; SubLbl.ZIndex = 3

-- Close кнопка
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,28,0,28); CloseBtn.Position = UDim2.new(1,-34,0.5,-14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35,35,42)
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = COL_TEXT
CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0; CloseBtn.ZIndex = 4
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)
local clS = Instance.new("UIStroke", CloseBtn)
clS.Color = COL_BRD; clS.Thickness = 1

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main,
        TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        { Size = UDim2.new(0,MW,0,0), Position = UDim2.new(0.5,-MW/2,0.5,0) }
    ):Play()
    task.delay(0.18, function() Main.Visible = false end)
end)

-- Separator
local Sep = Instance.new("Frame", Main)
Sep.Size = UDim2.new(1,-20,0,1); Sep.Position = UDim2.new(0,10,0,45)
Sep.BackgroundColor3 = COL_BRD; Sep.BorderSizePixel = 0

-- ============================================================
-- STATS - компактний знизу title
-- ============================================================
local StatsBar = Instance.new("Frame", Main)
StatsBar.Size             = UDim2.new(1,0,0,24)
StatsBar.Position         = UDim2.new(0,0,0,46)
StatsBar.BackgroundColor3 = Color3.fromRGB(12,12,16)
StatsBar.BorderSizePixel  = 0

local FPSLabel = Instance.new("TextLabel", StatsBar)
FPSLabel.Size = UDim2.new(0.5,0,1,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = COL_TEXT
FPSLabel.Font = Enum.Font.GothamBold; FPSLabel.TextSize = 11
FPSLabel.Text = "FPS: ..."

local PingLabel = Instance.new("TextLabel", StatsBar)
PingLabel.Size = UDim2.new(0.5,0,1,0)
PingLabel.Position = UDim2.new(0.5,0,0,0)
PingLabel.BackgroundTransparency = 1
PingLabel.TextColor3 = COL_TEXT
PingLabel.Font = Enum.Font.GothamBold; PingLabel.TextSize = 11
PingLabel.Text = "Ping: ..."

-- Зовнішній stats (floating)
local StatsFrame = Instance.new("Frame", Screen)
StatsFrame.Size             = UDim2.new(0, 125, 0, 50)
StatsFrame.Position         = UDim2.new(1, -138, 0, 12)
StatsFrame.BackgroundColor3 = Color3.fromRGB(10,10,14)
StatsFrame.BackgroundTransparency = 0.1
StatsFrame.BorderSizePixel  = 0
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0,10)
local ss = Instance.new("UIStroke", StatsFrame)
ss.Color = COL_BRD; ss.Thickness = 1.5

local ExtFPS = Instance.new("TextLabel", StatsFrame)
ExtFPS.Size = UDim2.new(1,0,0.5,0)
ExtFPS.BackgroundTransparency = 1
ExtFPS.TextColor3 = COL_WHT
ExtFPS.Font = Enum.Font.GothamBold; ExtFPS.TextSize = 12
ExtFPS.Text = "FPS: ..."

local ExtPing = Instance.new("TextLabel", StatsFrame)
ExtPing.Size = UDim2.new(1,0,0.5,0)
ExtPing.Position = UDim2.new(0,0,0.5,0)
ExtPing.BackgroundTransparency = 1
ExtPing.TextColor3 = COL_WHT
ExtPing.Font = Enum.Font.GothamBold; ExtPing.TextSize = 12
ExtPing.Text = "Ping: ..."

-- ============================================================
-- SCROLL
-- ============================================================
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                  = UDim2.new(1,-6,1,-72)
Scroll.Position              = UDim2.new(0,3,0,70)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness    = IsMob and 0 or 3
Scroll.ScrollBarImageColor3  = Color3.fromRGB(180,180,180)
Scroll.BorderSizePixel       = 0
Scroll.CanvasSize            = UDim2.new(0,0,0,0)
Scroll.ScrollingDirection    = Enum.ScrollingDirection.Y

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding             = UDim.new(0,4)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local lpad = Instance.new("UIPadding", Scroll)
lpad.PaddingTop = UDim.new(0,4); lpad.PaddingBottom = UDim.new(0,10)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0,0,0, Layout.AbsoluteContentSize.Y + 16)
end)
task.spawn(function()
    task.wait(0.25)
    Scroll.CanvasSize = UDim2.new(0,0,0, Layout.AbsoluteContentSize.Y + 16)
end)

-- ============================================================
-- [[ 18. DRAGGABLE ]]
-- ============================================================
local function MakeDraggable(handle, target)
    local drag, dStart, dPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = inp.Position; dPos = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dStart
            target.Position = UDim2.new(
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
MakeDraggable(TitleBar, Main)

-- ============================================================
-- [[ 19. M КНОПКА ]]
-- ============================================================
local MToggle = Instance.new("TextButton", Screen)
MToggle.Size             = UDim2.new(0,MBS,0,MBS)
MToggle.Position         = UDim2.new(0,10,0.45,0)
MToggle.BackgroundColor3 = Color3.fromRGB(10,10,14)
MToggle.Text             = "M"
MToggle.TextColor3       = COL_WHT
MToggle.Font             = Enum.Font.GothamBlack
MToggle.TextSize         = IsMob and 26 or 20
MToggle.ZIndex           = 100
MToggle.AutoButtonColor  = false
Instance.new("UICorner", MToggle).CornerRadius = UDim.new(0,12)

local MStroke = Instance.new("UIStroke", MToggle)
MStroke.Thickness = 2; MStroke.Color = COL_BRD

local MCount = Instance.new("TextLabel", MToggle)
MCount.Size = UDim2.new(1,0,0,12); MCount.Position = UDim2.new(0,0,1,-12)
MCount.BackgroundTransparency = 1; MCount.Text = ""
MCount.TextSize = 8; MCount.Font = Enum.Font.GothamBold
MCount.TextColor3 = COL_GRN; MCount.ZIndex = 101

task.spawn(function()
    while task.wait(0.6) do
        local c = 0
        for _, v in pairs(State) do if v then c += 1 end end
        MCount.Text = c > 0 and ("●"..c) or ""
    end
end)

do
    local mDrag, mStart, mPos, mMoved, mTick = false, nil, nil, false, 0
    MToggle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            mDrag = true; mStart = inp.Position
            mPos = MToggle.Position; mMoved = false; mTick = tick()
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not mDrag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - mStart
            if d.Magnitude > 8 then mMoved = true end
            MToggle.Position = UDim2.new(
                mPos.X.Scale, mPos.X.Offset + d.X,
                mPos.Y.Scale, mPos.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if mDrag and not mMoved and (tick()-mTick) < 0.35 then
                if not Main.Visible then
                    Main.Size     = UDim2.new(0,MW,0,0)
                    Main.Position = UDim2.new(0.5,-MW/2,0.5,0)
                    Main.Visible  = true
                    TweenService:Create(Main,
                        TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        { Size = UDim2.new(0,MW,0,MH),
                          Position = UDim2.new(0.5,-MW/2,0.5,-MH/2) }
                    ):Play()
                else
                    TweenService:Create(Main,
                        TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                        { Size = UDim2.new(0,MW,0,0),
                          Position = UDim2.new(0.5,-MW/2,0.5,0) }
                    ):Play()
                    task.delay(0.18, function() Main.Visible = false end)
                end
            end
            mDrag = false
        end
    end)
end

-- ============================================================
-- [[ 20. МОБІЛЬНІ FLY КНОПКИ ]]
-- ============================================================
local FlyBtnHolder = Instance.new("Frame", Screen)
FlyBtnHolder.Size               = UDim2.new(0,134,0,60)
FlyBtnHolder.Position           = UDim2.new(1,-148,1,-76)
FlyBtnHolder.BackgroundTransparency = 1
FlyBtnHolder.Visible            = false
FlyBtnHolder.ZIndex             = 50

local function MakeFlyBtn(txt, xOff, cb)
    local btn = Instance.new("TextButton", FlyBtnHolder)
    btn.Size             = UDim2.new(0,60,0,56)
    btn.Position         = UDim2.new(0,xOff,0,0)
    btn.BackgroundColor3 = Color3.fromRGB(10,10,14)
    btn.Text             = txt
    btn.TextColor3       = COL_WHT
    btn.Font             = Enum.Font.GothamBlack
    btn.TextSize         = 26
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 51
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = COL_BRD; bs.Thickness = 1.5
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            cb(true); btn.BackgroundColor3 = Color3.fromRGB(45,45,58)
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            cb(false); btn.BackgroundColor3 = Color3.fromRGB(10,10,14)
        end
    end)
end

MakeFlyBtn("▲", 0,  function(v) MobileFlyUp   = v end)
MakeFlyBtn("▼", 70, function(v) MobileFlyDown = v end)

local function UpdateFlyBtns()
    FlyBtnHolder.Visible = State.Fly and IsTablet
end

-- Freecam touch zone
local FCZone = Instance.new("TextButton", Screen)
FCZone.Size               = UDim2.new(0.5,0,1,-100)
FCZone.Position           = UDim2.new(0.5,0,0,0)
FCZone.BackgroundTransparency = 1
FCZone.Text               = ""; FCZone.ZIndex = 5; FCZone.Visible = false

local fcLast = nil
FCZone.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch then fcLast = inp.Position end
end)
FCZone.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch and fcLast then
        local d = inp.Position - fcLast
        FC_Yaw   = FC_Yaw   - math.rad(d.X * 0.4)
        FC_Pitch = math.clamp(FC_Pitch - math.rad(d.Y * 0.4), -math.rad(89), math.rad(89))
        fcLast   = inp.Position
    end
end)
FCZone.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch then fcLast = nil end
end)

-- ============================================================
-- [[ 21. UI КОМПОНЕНТИ ]]
-- ============================================================
local function MakeRipple(parent)
    local r = Instance.new("Frame", parent)
    r.Size = UDim2.new(0,0,0,0)
    r.Position = UDim2.new(0.5,0,0.5,0)
    r.AnchorPoint = Vector2.new(0.5,0.5)
    r.BackgroundColor3 = COL_WHT
    r.BackgroundTransparency = 0.85
    r.BorderSizePixel = 0
    r.ZIndex = parent.ZIndex + 5
    Instance.new("UICorner", r).CornerRadius = UDim.new(1,0)
    TweenService:Create(r,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Size = UDim2.new(2,0,4,0), BackgroundTransparency = 1 }
    ):Play()
    task.delay(0.3, function() SafeDestroy(r) end)
end

-- Категорія - новий стиль (без лінійок)
local function AddCat(icon, text)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.95,0,0,24)
    f.BackgroundColor3 = BG_CAT
    f.BorderSizePixel  = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)

    -- Лівий акцент
    local acc = Instance.new("Frame", f)
    acc.Size             = UDim2.new(0,3,0.7,0)
    acc.Position         = UDim2.new(0,0,0.15,0)
    acc.BackgroundColor3 = COL_WHT
    acc.BorderSizePixel  = 0
    Instance.new("UICorner", acc).CornerRadius = UDim.new(0,2)

    local l = Instance.new("TextLabel", f)
    l.Size                   = UDim2.new(1,-12,1,0)
    l.Position               = UDim2.new(0,12,0,0)
    l.BackgroundTransparency = 1
    l.TextColor3             = COL_DIM
    l.Font                   = Enum.Font.GothamBold
    l.TextSize               = 10
    l.Text                   = icon .. "  " .. text
    l.TextXAlignment         = Enum.TextXAlignment.Left
end

-- Кнопка - новий стиль
local function CreateBtn(text, logicName)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size             = UDim2.new(0.95,0,0,BH)
    btn.BackgroundColor3 = BG_BTN
    btn.TextColor3       = COL_TEXT
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = FS
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Text             = "    " .. text
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.ClipsDescendants = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local bS = Instance.new("UIStroke", btn)
    bS.Color = COL_BRD; bS.Thickness = 1

    -- Лівий акцент
    local acc = Instance.new("Frame", btn)
    acc.Name             = "Accent"
    acc.Size             = UDim2.new(0,3,0.6,0)
    acc.Position         = UDim2.new(0,0,0.2,0)
    acc.BackgroundColor3 = COL_RED
    acc.BorderSizePixel  = 0
    Instance.new("UICorner", acc).CornerRadius = UDim.new(0,2)

    local dot = Instance.new("Frame", btn)
    dot.Name             = "StatusDot"
    dot.Size             = UDim2.new(0,6,0,6)
    dot.Position         = UDim2.new(1,-14,0.5,-3)
    dot.BackgroundColor3 = COL_RED
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot)

    Buttons[logicName] = btn

    btn.MouseEnter:Connect(function()
        if not State[logicName] then
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(30,30,38)
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not State[logicName] then
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = BG_BTN
            }):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        MakeRipple(btn); Toggle(logicName)
        if logicName == "Fly"     then UpdateFlyBtns() end
        if logicName == "Freecam" then FCZone.Visible = State.Freecam and IsTablet end
    end)
    return btn
end

-- Bind кнопка
local function CreateBindBtn(text, logicName)
    if IsMob then return CreateBtn(text, logicName) end

    local container = Instance.new("Frame", Scroll)
    container.Size             = UDim2.new(0.95,0,0,BH)
    container.BackgroundColor3 = BG_BTN
    container.BorderSizePixel  = 0
    container.ClipsDescendants = true
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)

    local cS = Instance.new("UIStroke", container)
    cS.Color = COL_BRD; cS.Thickness = 1

    local acc = Instance.new("Frame", container)
    acc.Name = "Accent"; acc.Size = UDim2.new(0,3,0.6,0)
    acc.Position = UDim2.new(0,0,0.2,0)
    acc.BackgroundColor3 = COL_RED; acc.BorderSizePixel = 0
    Instance.new("UICorner", acc).CornerRadius = UDim.new(0,2)

    local dot = Instance.new("Frame", container)
    dot.Name = "StatusDot"; dot.Size = UDim2.new(0,6,0,6)
    dot.Position = UDim2.new(1,-76,0.5,-3)
    dot.BackgroundColor3 = COL_RED; dot.BorderSizePixel = 0
    Instance.new("UICorner", dot)

    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size                   = UDim2.new(1,-72,1,0)
    mainBtn.BackgroundTransparency = 1
    mainBtn.TextColor3             = COL_TEXT
    mainBtn.Font                   = Enum.Font.GothamBold
    mainBtn.TextSize               = FS
    mainBtn.Text                   = "    " .. text
    mainBtn.TextXAlignment         = Enum.TextXAlignment.Left

    local bindBtn = Instance.new("TextButton", container)
    bindBtn.Size             = UDim2.new(0,60,0,22)
    bindBtn.Position         = UDim2.new(1,-66,0.5,-11)
    bindBtn.BackgroundColor3 = Color3.fromRGB(16,16,20)
    bindBtn.TextColor3       = COL_DIM
    bindBtn.Font             = Enum.Font.GothamBold
    bindBtn.TextSize         = 9
    bindBtn.BorderSizePixel  = 0
    bindBtn.AutoButtonColor  = false
    bindBtn.Text             = Binds[logicName]
        and tostring(Binds[logicName]):gsub("Enum.KeyCode.","") or "NONE"
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0,6)
    local bS = Instance.new("UIStroke", bindBtn)
    bS.Color = COL_BRD; bS.Thickness = 1

    mainBtn.MouseButton1Click:Connect(function()
        if waitingBind == logicName then return end
        MakeRipple(container); Toggle(logicName)
        if logicName == "Fly"     then UpdateFlyBtns() end
        if logicName == "Freecam" then FCZone.Visible = State.Freecam and IsTablet end
    end)
    bindBtn.MouseButton1Click:Connect(function()
        if waitingBind then return end
        waitingBind        = logicName
        bindBtn.Text       = "..."
        bindBtn.TextColor3 = Color3.fromRGB(255,230,80)
        Notify("BIND","Натисни клавішу: "..text,3)
    end)

    BindButtons[logicName] = {
        container = container, dot = dot,
        mainBtn = mainBtn, bindBtn = bindBtn,
    }
    return container
end

-- ============================================================
-- СЛАЙДЕР - горизонтальний всередині, без лінійки вгорі
-- ============================================================
local function CreateSlider(icon, text, minV, maxV, default, callback)
    local container = Instance.new("Frame", Scroll)
    container.Size             = UDim2.new(0.95,0,0, IsMob and 58 or 52)
    container.BackgroundColor3 = BG_BTN
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,8)
    local sS = Instance.new("UIStroke", container)
    sS.Color = COL_BRD; sS.Thickness = 1

    -- Іконка
    local ic = Instance.new("TextLabel", container)
    ic.Size = UDim2.new(0,28,0,22); ic.Position = UDim2.new(0,4,0,4)
    ic.BackgroundTransparency = 1
    ic.Text = icon; ic.TextSize = 14; ic.Font = Enum.Font.Gotham
    ic.TextColor3 = COL_DIM

    -- Назва
    local nameLbl = Instance.new("TextLabel", container)
    nameLbl.Size = UDim2.new(0.55,0,0,22); nameLbl.Position = UDim2.new(0,30,0,4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = COL_TEXT
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = FS
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Text = text

    -- Значення - справа жирно
    local valBox = Instance.new("Frame", container)
    valBox.Size             = UDim2.new(0,44,0,22)
    valBox.Position         = UDim2.new(1,-48,0,4)
    valBox.BackgroundColor3 = Color3.fromRGB(16,16,20)
    valBox.BorderSizePixel  = 0
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0,5)

    local valLbl = Instance.new("TextLabel", valBox)
    valLbl.Size = UDim2.new(1,0,1,0)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = COL_WHT
    valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 12
    valLbl.Text = tostring(default)

    -- Track
    local trackY = IsMob and 38 or 33
    local track = Instance.new("Frame", container)
    track.Size             = UDim2.new(0.9,0,0,5)
    track.Position         = UDim2.new(0.05,0,0,trackY)
    track.BackgroundColor3 = Color3.fromRGB(32,32,40)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((default-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(200,200,200)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local fG = Instance.new("UIGradient", fill)
    fG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70,70,85)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })

    local KS = IsMob and 16 or 13
    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0,KS,0,KS)
    knob.Position         = UDim2.new((default-minV)/(maxV-minV),-KS/2,0.5,-KS/2)
    knob.BackgroundColor3 = COL_WHT
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local kS = Instance.new("UIStroke", knob)
    kS.Color = Color3.fromRGB(100,100,115); kS.Thickness = 1.5

    local dragging   = false
    local currentVal = default

    local function Update(inp)
        local rel = math.clamp(
            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        local val = math.floor(minV + rel * (maxV - minV))
        if val == currentVal then return end
        currentVal    = val
        fill.Size     = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -KS/2, 0.5, -KS/2)
        valLbl.Text   = tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; Update(inp)
        end
    end)
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
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
-- [[ 22. НАПОВНЕННЯ GUI ]]
-- ============================================================
AddCat("⚡","ШВИДКІСТЬ")
CreateSlider("🚀","Fly Speed",    0,   300, Config.FlySpeed,  function(v)
    Config.FlySpeed = v
end)
CreateSlider("👟","Walk Speed",   16,  200, Config.WalkSpeed, function(v)
    Config.WalkSpeed = v
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if State.Speed and hum then hum.WalkSpeed = v end
end)
CreateSlider("⬆️","Jump Power",   50,  500, Config.JumpPower, function(v)
    Config.JumpPower = v
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if State.HighJump and hum then
        pcall(function() hum.UseJumpPower = true; hum.JumpPower = v end)
    end
end)

AddCat("🎯","БОЙОВІ")
CreateBindBtn("Auto Aim",   "Aim")
CreateBindBtn("Silent Aim", "SilentAim")
CreateBtn("Magnet",         "ShadowLock")
CreateBtn("Hitbox",         "Hitbox")
CreateBtn("ESP",            "ESP")

AddCat("🏃","РУХ")
CreateBindBtn("Fly",        "Fly")
CreateBtn("Speed",          "Speed")
CreateBtn("Bhop",           "Bhop")
CreateBtn("High Jump",      "HighJump")
CreateBindBtn("Noclip",     "Noclip")
CreateBtn("No Fall Dmg",    "NoFallDamage")

AddCat("🔧","MISC")
CreateBtn("Spin",           "Spin")
CreateBtn("Potato Mode",    "Potato")
CreateBtn("Fake Lag",       "FakeLag")
CreateBtn("Freecam",        "Freecam")
CreateBtn("Anti-AFK",       "AntiAFK")
CreateBtn("Anti-Kick",      "AntiKick")

-- ============================================================
-- [[ 23. BIND HANDLER ]]
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
    if waitingBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local key  = inp.KeyCode
            local name = waitingBind
            Binds[name] = key
            if BindButtons[name] then
                BindButtons[name].bindBtn.Text =
                    tostring(key):gsub("Enum.KeyCode.","")
                BindButtons[name].bindBtn.TextColor3 = COL_DIM
            end
            Notify("BIND", name.." → "..tostring(key):gsub("Enum.KeyCode.",""), 2)
            waitingBind = nil
        end
        return
    end
    if gpe then return end
    for action, key in pairs(Binds) do
        if inp.KeyCode == key then
            if action == "ToggleMenu" then
                if not Main.Visible then
                    Main.Size = UDim2.new(0,MW,0,0)
                    Main.Position = UDim2.new(0.5,-MW/2,0.5,0)
                    Main.Visible = true
                    TweenService:Create(Main,
                        TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                        { Size = UDim2.new(0,MW,0,MH),
                          Position = UDim2.new(0.5,-MW/2,0.5,-MH/2) }
                    ):Play()
                else
                    TweenService:Create(Main,
                        TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
                        { Size = UDim2.new(0,MW,0,0),
                          Position = UDim2.new(0.5,-MW/2,0.5,0) }
                    ):Play()
                    task.delay(0.18, function() Main.Visible = false end)
                end
            else
                Toggle(action)
                if action == "Fly"     then UpdateFlyBtns() end
                if action == "Freecam" then FCZone.Visible = State.Freecam and IsTablet end
            end
        end
    end
    if inp.KeyCode == Enum.KeyCode.F9
    or inp.KeyCode == Enum.KeyCode.F12 then
        TweenService:Create(Blur, TweenInfo.new(0.15), { Size = 36 }):Play()
        task.delay(1.5, function()
            TweenService:Create(Blur, TweenInfo.new(0.3), { Size = 0 }):Play()
        end)
    end
end)

-- ============================================================
-- [[ 24. АНІМАЦІЯ ]]
-- ============================================================
task.spawn(function()
    local t = 0
    while true do
        task.wait(0.033)
        t += 0.022
        local v    = (math.sin(t) + 1) / 2
        local vInv = 1 - v
        local bv   = math.floor(v    * 255)
        local bInv = math.floor(vInv * 255)
        local col    = Color3.fromRGB(bv,   bv,   bv)
        local colInv = Color3.fromRGB(bInv, bInv, bInv)

        -- Main stroke пульс
        local sv = math.floor(42 + v * 40)
        MainStroke.Color = Color3.fromRGB(sv,sv,sv)

        -- Stats stroke
        local sv2 = math.floor(38 + ((math.sin(t+1.2)+1)/2)*36)
        ss.Color = Color3.fromRGB(sv2,sv2,sv2)

        -- M button
        MToggle.BackgroundColor3 = colInv
        MToggle.TextColor3       = col
        MStroke.Color            = col

        -- Title gradient
        local g1 = math.floor(14 + v*30)
        TitleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(g1,   g1,   g1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(g1+25,g1+25,g1+30)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(g1,   g1,   g1)),
        })
        TitleGradient.Rotation = (t * 25) % 360

        -- Title text
        local tg = math.floor(190 + v * 65)
        TitleLbl.TextColor3 = Color3.fromRGB(tg,tg,tg)

        -- Активні кнопки
        for name, btn in pairs(Buttons) do
            if State[name] then
                btn.BackgroundColor3 = col
                btn.TextColor3       = colInv
                local acc = btn:FindFirstChild("Accent")
                if acc then acc.BackgroundColor3 = Color3.fromRGB(0, math.floor(180+v*30), 55) end
            end
        end
        for name, bd in pairs(BindButtons) do
            if State[name] then
                local shade = math.floor(v * 255)
                bd.container.BackgroundColor3 = Color3.fromRGB(shade,shade,shade)
                bd.mainBtn.TextColor3 = colInv
                local acc = bd.container:FindFirstChild("Accent")
                if acc then acc.BackgroundColor3 = Color3.fromRGB(0, math.floor(180+v*30), 55) end
            end
        end
    end
end)

-- ============================================================
-- [[ 25. RENDER LOOP ]]
-- ============================================================
RunService.RenderStepped:Connect(function()
    local now = tick()
    table.insert(FrameLog, now)
    while FrameLog[1] and FrameLog[1] < now - 1 do
        table.remove(FrameLog, 1)
    end
    local fps = #FrameLog

    local pingMs = math.floor(lastPing * 1000)
    if now - pingTick > 2 then
        pingTick = now
        pcall(function() lastPing = LP:GetNetworkPing() end)
    end

    local fpsCol = fps >= 55
        and Color3.fromRGB(180,255,180)
        or fps >= 30 and Color3.fromRGB(255,220,80)
        or Color3.fromRGB(255,90,90)
    local pingCol = pingMs <= 80
        and Color3.fromRGB(180,255,180)
        or pingMs <= 150 and Color3.fromRGB(255,220,80)
        or Color3.fromRGB(255,90,90)

    local fpsT  = "FPS: "..fps
    local pingT = "Ping: "..pingMs.."ms"

    FPSLabel.Text  = fpsT;  FPSLabel.TextColor3  = fpsCol
    PingLabel.Text = pingT; PingLabel.TextColor3 = pingCol
    ExtFPS.Text    = fpsT;  ExtFPS.TextColor3    = fpsCol
    ExtPing.Text   = pingT; ExtPing.TextColor3   = pingCol

    -- ============================================================
    -- FREECAM
    -- ============================================================
    if State.Freecam then
        local mx, mz = 0, 0
        if not IsMob then
            if UIS:IsKeyDown(Enum.KeyCode.W) then mz = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then mz =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then mx = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then mx =  1 end
        elseif ControlsOK and Controls then
            local mv = Controls:GetMoveVector()
            mx = mv.X; mz = mv.Z
        end
        local dir = Camera.CFrame.LookVector * -mz + Camera.CFrame.RightVector * mx
        if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space)
        or MobileFlyUp   then dir += Camera.CFrame.UpVector end
        if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl)
        or MobileFlyDown then dir -= Camera.CFrame.UpVector end
        if dir.Magnitude > 1 then dir = dir.Unit end
        Camera.CFrame = CFrame.new(
            Camera.CFrame.Position + dir * (Config.FlySpeed/25) * (60/math.max(fps,1))
        ) * CFrame.fromEulerAnglesYXZ(FC_Pitch, FC_Yaw, 0)
    end

    -- AUTO AIM
    if State.Aim and not State.Freecam then
        local target = GetClosestToScreen()
        local head   = target and target:FindFirstChild("Head")
        if head then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position,
                head.Position + head.AssemblyLinearVelocity * math.clamp(lastPing,0,0.2))
        end
    end

    if State.SilentAim and not State.Aim and not State.Freecam then
        if not hookInstalled then FallbackSilentAim() end
    end
end)

-- FIX МИШКА: тільки для freecam, не впливає на звичайну мишку
UIS.InputChanged:Connect(function(inp, gpe)
    if gpe then return end
    if not State.Freecam then return end
    -- PC - тільки при затисненій ПКМ
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            FC_Yaw   = FC_Yaw   - math.rad(inp.Delta.X * 0.35)
            FC_Pitch = math.clamp(
                FC_Pitch - math.rad(inp.Delta.Y * 0.35),
                -math.rad(89), math.rad(89)
            )
        end
    end
end)

-- ============================================================
-- [[ 26. HEARTBEAT ]]
-- ============================================================
RunService.Heartbeat:Connect(function()
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum then return end

    local fps = math.max(#FrameLog, 1)

    -- MAGNET
    if State.ShadowLock then
        if not IsAlive(LockedTarget) then LockedTarget = GetClosestByDist() end
        if LockedTarget then
            local tHRP = LockedTarget:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local pred = tHRP.AssemblyLinearVelocity * math.clamp(lastPing,0,0.2)
                HRP.CFrame = HRP.CFrame:Lerp(
                    CFrame.new(tHRP.Position+pred)*tHRP.CFrame.Rotation*CFrame.new(0,0,3), 0.4
                )
                HRP.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
            end
        end
    end

    -- ============================================================
    -- FLY - оригінальний метод
    -- ============================================================
    if State.Fly and not State.Freecam then
        Hum.PlatformStand = false
        local mx, mz = 0, 0
        if not IsMob then
            if UIS:IsKeyDown(Enum.KeyCode.W) then mz = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then mz =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then mx = -1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then mx =  1 end
        elseif ControlsOK and Controls then
            local mv = Controls:GetMoveVector()
            mx = mv.X; mz = mv.Z
        end
        local camCF = Camera.CFrame
        local dir   = camCF.LookVector * -mz + camCF.RightVector * mx
        local upD   = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space)       or MobileFlyUp   then upD =  1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobileFlyDown then upD = -1 end
        dir = dir + Vector3.new(0, upD, 0)
        if dir.Magnitude > 1 then dir = dir.Unit end

        local speed = Config.FlySpeed * (60 / fps)
        local t     = tick()
        local jx    = math.noise(t * 18) * 1.1
        local jy    = math.sin(t  * 40) * 0.4
        local jz    = math.noise(t * 22) * 0.9

        HRP.AssemblyLinearVelocity = dir * speed + Vector3.new(jx, jy, jz)
        if not State.Spin then HRP.AssemblyAngularVelocity = Vector3.zero end
        if HRP.Position.Y > 1900 then
            HRP.AssemblyLinearVelocity -= Vector3.new(0, 28, 0)
        end
    end

    -- ============================================================
    -- SPEED - FIX: перевіряємо і застосовуємо кожен кадр
    -- ============================================================
    if State.Speed and not State.Fly and not State.Freecam then
        if Hum.WalkSpeed ~= Config.WalkSpeed then
            Hum.WalkSpeed = Config.WalkSpeed
        end
    end

    -- ============================================================
    -- HIGH JUMP - FIX: перевіряємо кожен кадр
    -- ============================================================
    if State.HighJump and not State.Fly then
        pcall(function()
            if not Hum.UseJumpPower then Hum.UseJumpPower = true end
            if math.abs(Hum.JumpPower - Config.JumpPower) > 1 then
                Hum.JumpPower = Config.JumpPower
            end
        end)
    end

    -- BHOP
    if State.Bhop and not State.Fly and not State.Freecam then
        if Hum.FloorMaterial ~= Enum.Material.Air
        and Hum.MoveDirection.Magnitude > 0 then
            local now = tick()
            if now - lastJump > 0.07 + math.random(-4,4)/1000 then
                Hum.Jump = true
                HRP.AssemblyLinearVelocity = Vector3.new(
                    HRP.AssemblyLinearVelocity.X,
                    60 + math.random(-8,8),
                    HRP.AssemblyLinearVelocity.Z
                )
                lastJump = now
            end
        end
    end

    -- NO FALL DAMAGE
    if State.NoFallDamage then
        if Hum:GetState() == Enum.HumanoidStateType.Freefall
        and HRP.AssemblyLinearVelocity.Y < -28 then
            Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            HRP.AssemblyLinearVelocity = Vector3.new(
                HRP.AssemblyLinearVelocity.X, -4, HRP.AssemblyLinearVelocity.Z
            )
        end
    end
end)

-- ============================================================
-- [[ 27. NOCLIP ]]
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
                    v.CanCollide     = true
                    v.CollisionGroup = "Default"
                end
            end
        end
        if moving and (HRP.Position - lastNoclipPos).Magnitude < 0.04 then
            HRP.CFrame = HRP.CFrame + Hum.MoveDirection * 0.35 + Vector3.new(0,0.12,0)
        end
        lastNoclipPos = HRP.Position
    elseif Char and HRP then
        lastNoclipPos = HRP.Position
    end
end)

-- ============================================================
Notify("OMNI V265.0","✅ Fixed Mouse | AntiKick | Speed/Jump | New GUI ✓",5)
