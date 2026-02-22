-- [[ V262.4: OMNI-REBORN - ULTIMATE MOBILE EDITION ]]
-- [[ FIXES: All bugs fixed | Mobile optimized | Smooth performance | Black-White GUI | Anti-Kick | Custom Binds ]]

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local Workspace      = game:GetService("Workspace")
local VirtualUser    = game:GetService("VirtualUser")
local PhysicsService = game:GetService("PhysicsService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- [[ 0. ЗАХИСТ ВІД ПОДВІЙНОГО ЗАПУСКУ ]]
-- ============================================================
pcall(function()
    for _, sg in pairs({
        game:GetService("CoreGui"),
        LP:WaitForChild("PlayerGui")
    }) do
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
local SafeGroup = "OmniSafeV262"
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
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 2
        })
    end)
end

-- ============================================================
-- [[ 3. BLUR ]]
-- ============================================================
local Blur = Instance.new("BlurEffect")
Blur.Size   = 0
Blur.Parent = Lighting

-- ============================================================
-- [[ 4. МОБІЛЬНІ КОНТРОЛЕРИ ]]
-- ============================================================
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1.5)
    pcall(function()
        Controls = require(
            LP.PlayerScripts:WaitForChild("PlayerModule", 5)
        ):GetControls()
    end)
end)

-- ============================================================
-- [[ 5. КОНФІГ + СТАН ]]
-- ============================================================
local Config = {
    FlySpeed  = 55,
    WalkSpeed = 85,
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

-- ============================================================
-- [[ 6. HELPERS ]]
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
    local center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )
    local best, bestD = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local head = p.Character and p.Character:FindFirstChild("Head")
        if head and IsAlive(p.Character) then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < bestD then bestD = d; best = p.Character end
            end
        end
    end
    return best
end

-- ============================================================
-- [[ 7. SILENT AIM HOOK ]]
-- ============================================================
local hookInstalled = false
local oldNamecall   = nil

pcall(function()
    local mt = getrawmetatable(game)
    oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if silentActive and self == Workspace then
            if method == "Raycast" then
                local target = GetClosestToScreen()
                if target then
                    local head = target:FindFirstChild("Head")
                    if head then
                        local origin = Camera.CFrame.Position
                        if typeof(args[2]) == "Vector3" then
                            local magnitude = args[2].Magnitude
                            args[2] = (head.Position - origin).Unit * magnitude
                        end
                    end
                end
            elseif method == "FindPartOnRayWithIgnoreList"
                or method == "FindPartOnRay" then
                local target = GetClosestToScreen()
                if target then
                    local head = target:FindFirstChild("Head")
                    if head then
                        local origin = Camera.CFrame.Position
                        if typeof(args[1]) == "Ray" then
                            local magnitude = args[1].Direction.Magnitude
                            args[1] = Ray.new(
                                origin,
                                (head.Position - origin).Unit * magnitude
                            )
                        end
                    end
                end
            end
        end

        return oldNamecall(self, unpack(args))
    end)

    setreadonly(mt, true)
    hookInstalled = true
end)

local lastSilentShot = 0
local function FallbackSilentAim()
    if not State.SilentAim or State.Freecam or State.Aim then return end
    local isLeftClick = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    if not isLeftClick then return end
    local now = tick()
    if now - lastSilentShot < 0.1 then return end
    lastSilentShot = now
    local target = GetClosestToScreen()
    if not target then return end
    local head = target:FindFirstChild("Head")
    if not head then return end
    local origin    = Camera.CFrame.Position
    local prediction = head.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.15)
    local targetPos  = head.Position + prediction
    local goal       = CFrame.new(origin, targetPos)
    Camera.CFrame    = Camera.CFrame:Lerp(goal, 0.3)
end

-- ============================================================
-- [[ 8. ESP СИСТЕМА ]]
-- ============================================================
local ESPCache = {}

local function ClearESP()
    for p, data in pairs(ESPCache) do
        pcall(function()
            if data.hl and data.hl.Parent then data.hl:Destroy() end
            if data.bb and data.bb.Parent then data.bb:Destroy() end
        end)
    end
    ESPCache = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not char then continue end
        for _, v in pairs(char:GetDescendants()) do
            if (v:IsA("Highlight") or v:IsA("BillboardGui"))
            and v:FindFirstChild("OmniESP") then
                v:Destroy()
            end
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
            local cache      = ESPCache[p]
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
                hl.FillColor         = Color3.fromRGB(220, 40, 40)
                hl.OutlineColor      = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency  = 0.5
                hl.OutlineTransparency = 0
                Instance.new("BoolValue", hl).Name = "OmniESP"

                local bb = Instance.new("BillboardGui", head)
                bb.Size        = UDim2.new(0, 180, 0, 52)
                bb.StudsOffset = Vector3.new(0, 3.2, 0)
                bb.AlwaysOnTop = true
                bb.MaxDistance = 500
                Instance.new("BoolValue", bb).Name = "OmniESP"

                local bg = Instance.new("Frame", bb)
                bg.Size                   = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                bg.BackgroundTransparency = 0.45
                bg.BorderSizePixel        = 0
                Instance.new("UICorner", bg)

                local lbl = Instance.new("TextLabel", bg)
                lbl.Name                = "ESPText"
                lbl.Size                = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font                = Enum.Font.GothamBold
                lbl.TextSize            = 12
                lbl.TextWrapped         = true
                lbl.TextColor3          = Color3.fromRGB(255, 255, 255)

                ESPCache[p] = { hl = hl, bb = bb, lbl = lbl }
                cache = ESPCache[p]
            end
            local lbl   = cache.lbl
            local hp    = math.floor(hum.Health)
            local maxHp = math.max(math.floor(hum.MaxHealth), 1)
            local dist  = myHRP
                and math.floor((myHRP.Position - head.Position).Magnitude)
                or 0
            local ratio = hp / maxHp
            lbl.Text = string.format(
                "[%s]\nHP: %d/%d | %dm", p.Name, hp, maxHp, dist
            )
            if ratio >= 0.6 then
                lbl.TextColor3 = Color3.fromRGB(80, 255, 120)
            elseif ratio >= 0.3 then
                lbl.TextColor3 = Color3.fromRGB(255, 220, 40)
            else
                lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
            end
            cache.hl.FillColor = ratio >= 0.5
                and Color3.fromRGB(40, 180, 80)
                or  Color3.fromRGB(220, 40, 40)
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
-- [[ 9. HITBOX ]]
-- ============================================================
local HITBOX_SIZE = 4.0
local hitboxParts = {}

local function ApplyHitbox(head)
    if not head or not head:IsA("BasePart") then return end
    local sz = HITBOX_SIZE + math.random(-10, 10) / 100 * 0.3
    head.Size        = Vector3.new(sz, sz, sz)
    head.Transparency = 0.75
    head.Material    = Enum.Material.SmoothPlastic
    head.Color       = Color3.fromRGB(255, 100, 100)
    head.CanTouch    = true
    head.CanQuery    = true
    head.Massless    = true
    head.CanCollide  = false
    hitboxParts[head] = true
end

local function RestoreHitbox()
    for head, _ in pairs(hitboxParts) do
        pcall(function()
            if head and head.Parent then
                head.Size        = Vector3.new(1.2, 1.2, 1.2)
                head.Transparency = 0
                head.Material    = Enum.Material.Plastic
                head.Color       = Color3.fromRGB(163, 162, 155)
                head.CanCollide  = true
                head.Massless    = false
            end
        end)
    end
    hitboxParts = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if not State.Hitbox then continue end
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            if not IsAlive(p.Character) then continue end
            local head = p.Character:FindFirstChild("Head")
            if head and head.Size.X < HITBOX_SIZE - 0.1 then
                ApplyHitbox(head)
            end
        end
    end
end)

-- ============================================================
-- [[ 10. ANTI-KICK ]]
-- ============================================================
local antiKickConn = nil

local function EnableAntiKick()
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == LP then
                return
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
    Notify("ANTI-KICK", "Захист від кіку увімкнено ✓", 2)
end

local function DisableAntiKick()
    if antiKickConn then
        antiKickConn:Disconnect()
        antiKickConn = nil
    end
    Notify("ANTI-KICK", "Захист від кіку вимкнено ✗", 2)
end

-- ============================================================
-- [[ 11. POTATO MODE ]]
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
                v.CastShadow  = false
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end)
    end
    Notify("POTATO", "Графіку знижено ✓", 2)
end

local function RestorePotato()
    Lighting.GlobalShadows = savedShadows
    settings().Rendering.QualityLevel = savedQuality
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.CastShadow = true
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = true
            end
        end)
    end
    Notify("POTATO", "Графіку відновлено ✓", 2)
end

-- ============================================================
-- [[ 12. FORCE RESTORE ]]
-- ============================================================
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
        local av = HRP:FindFirstChild("SpinAV")
        if av then av:Destroy() end
        HRP.Anchored = false
    end
    for _, v in pairs(Char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide    = true
            v.CollisionGroup = "Default"
        end
    end
end

-- ============================================================
-- [[ 13. TOGGLE SYSTEM ]]
-- ============================================================
local fakeLagThread = nil

local function Toggle(Name)
    State[Name] = not State[Name]
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

    -- ВИМКНЕННЯ
    if not State[Name] then
        if Name == "Fly" or Name == "Noclip" or Name == "ShadowLock" then
            ForceRestore()
        end
        if Name == "ESP"       then ClearESP()       end
        if Name == "Hitbox"    then RestoreHitbox()   end
        if Name == "Potato"    then RestorePotato()   end
        if Name == "AntiKick"  then DisableAntiKick() end
        if Name == "SilentAim" then silentActive = false end
        if Name == "Speed" and Hum then Hum.WalkSpeed = 16 end
        if Name == "Freecam" then
            Camera.CameraType    = Enum.CameraType.Custom
            UIS.MouseBehavior    = Enum.MouseBehavior.Default
            if Hum then Camera.CameraSubject = Hum end
            if HRP then HRP.Anchored = false end
        end
        if Name == "Spin" and HRP then
            local av = HRP:FindFirstChild("SpinAV")
            if av then av:Destroy() end
        end
        if Name == "FakeLag" and HRP then
            HRP.Anchored = false
        end
    end

    -- ВВІМКНЕННЯ
    if State[Name] then
        if Name == "SilentAim" then silentActive = true end
        if Name == "AntiKick"  then EnableAntiKick()   end
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
            LockedTarget = GetClosestByDist()
        end
        if Name == "Freecam" then
            Camera.CameraSubject = nil
            Camera.CameraType    = Enum.CameraType.Scriptable
            local x, y, _       = Camera.CFrame:ToEulerAnglesYXZ()
            FC_Pitch = x
            FC_Yaw   = y
            if HRP then HRP.Anchored = true end
        end
        if Name == "Potato" then ApplyPotato() end
        if Name == "FakeLag" and not fakeLagThread then
            fakeLagThread = task.spawn(function()
                while State.FakeLag do
                    local chr = LP.Character
                    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
                    local hum = chr and chr:FindFirstChildOfClass("Humanoid")
                    if hrp and hum
                    and hum.MoveDirection.Magnitude > 0
                    and not State.Fly
                    and not State.Freecam then
                        pcall(function() hrp.Anchored = true end)
                        task.wait(math.random(35, 80) / 1000)
                        pcall(function() hrp.Anchored = false end)
                        task.wait(math.random(90, 200) / 1000)
                    else
                        task.wait(0.15)
                    end
                end
                fakeLagThread = nil
            end)
        end
    end

    -- Оновлення звичайних кнопок
    if Buttons[Name] and not BindButtons[Name] then
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

    -- Оновлення bind-кнопок
    if BindButtons[Name] then
        local bd  = BindButtons[Name]
        local dot = bd.dot
        if State[Name] then
            bd.container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            bd.mainBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(0, 220, 80) end
        else
            bd.container.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            bd.mainBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
            if dot then dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50) end
        end
    end

    Notify(Name, State[Name] and "ON ✓" or "OFF ✗", 1.5)
end

-- ============================================================
-- [[ 14. ANTI-AFK ]]
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
-- [[ 15. CHARACTER CLEANUP ]]
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    for _, name in pairs({"Fly","Noclip","Freecam","Spin","FakeLag"}) do
        if State[name] then
            State[name] = false
            if BindButtons[name] then
                local bd  = BindButtons[name]
                local dot = bd.dot
                bd.container.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
                bd.mainBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
                if dot then dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50) end
            elseif Buttons[name] then
                local btn = Buttons[name]
                btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
                btn.TextColor3       = Color3.fromRGB(255, 255, 255)
                local dot = btn:FindFirstChild("StatusDot")
                if dot then dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50) end
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and Camera.CameraType ~= Enum.CameraType.Custom then
        Camera.CameraType    = Enum.CameraType.Custom
        Camera.CameraSubject = hum
    end
end)

-- ============================================================
-- [[ 16. GUI CREATION ]]
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

local IsMobile  = UIS.TouchEnabled
local MainWidth  = IsMobile and 240 or 255
local MainHeight = IsMobile and 530 or 650
local MBtnSize   = IsMobile and 60 or 45

-- Головний фрейм
local Main = Instance.new("Frame", Screen)
Main.Size             = UDim2.new(0, MainWidth, 0, MainHeight)
Main.Position         = UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Main.Visible          = false
Main.BorderSizePixel  = 0
Instance.new("UICorner", Main)

local ms = Instance.new("UIStroke", Main)
ms.Color     = Color3.fromRGB(255, 255, 255)
ms.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size             = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TitleBar.BorderSizePixel  = 0
Instance.new("UICorner", TitleBar)

local TitleGradient = Instance.new("UIGradient", TitleBar)
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,   0,   0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,   0,   0)),
})
TitleGradient.Rotation = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3          = Color3.fromRGB(255, 255, 255)
TitleLbl.Font                = Enum.Font.GothamBlack
TitleLbl.TextSize            = 15
TitleLbl.Text                = "⚡ OMNI V262.4"
TitleLbl.ZIndex              = 2

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 13
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 3
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- Stats Frame
local StatsFrame = Instance.new("Frame", Screen)
StatsFrame.Size                   = UDim2.new(0, 120, 0, 48)
StatsFrame.Position               = UDim2.new(1, -135, 0, 15)
StatsFrame.BackgroundColor3       = Color3.fromRGB(12, 12, 12)
StatsFrame.BackgroundTransparency = 0.15
StatsFrame.BorderSizePixel        = 0
Instance.new("UICorner", StatsFrame)

local ss = Instance.new("UIStroke", StatsFrame)
ss.Color     = Color3.fromRGB(255, 255, 255)
ss.Thickness = 1.5

local FPSLabel = Instance.new("TextLabel", StatsFrame)
FPSLabel.Size                = UDim2.new(1, 0, 0.5, 0)
FPSLabel.Position            = UDim2.new(0, 0, 0, 2)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3          = Color3.fromRGB(255, 255, 255)
FPSLabel.Font                = Enum.Font.GothamBold
FPSLabel.TextSize            = 13
FPSLabel.Text                = "FPS: ..."

local PingLabel = Instance.new("TextLabel", StatsFrame)
PingLabel.Size                = UDim2.new(1, 0, 0.5, 0)
PingLabel.Position            = UDim2.new(0, 0, 0.5, -2)
PingLabel.BackgroundTransparency = 1
PingLabel.TextColor3          = Color3.fromRGB(255, 255, 255)
PingLabel.Font                = Enum.Font.GothamBold
PingLabel.TextSize            = 13
PingLabel.Text                = "Ping: ..."

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                  = UDim2.new(1, -8, 1, -44)
Scroll.Position              = UDim2.new(0, 4, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness    = IsMobile and 0 or 3
Scroll.ScrollBarImageColor3  = Color3.fromRGB(200, 200, 200)
Scroll.BorderSizePixel       = 0

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding              = UDim.new(0, 5)
Layout.HorizontalAlignment  = Enum.HorizontalAlignment.Center

local lpad = Instance.new("UIPadding", Scroll)
lpad.PaddingTop    = UDim.new(0, 4)
lpad.PaddingBottom = UDim.new(0, 4)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 12)
end)

task.spawn(function()
    task.wait(0.25)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 12)
end)

-- ============================================================
-- [[ 17. DRAGGABLE ]]
-- ============================================================
local function MakeDraggable(handle, target)
    local drag, dStart, dPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag   = true
            dStart = inp.Position
            dPos   = target.Position
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
-- [[ 18. M BUTTON ]]
-- ============================================================
local MToggle = Instance.new("TextButton", Screen)
MToggle.Size             = UDim2.new(0, MBtnSize, 0, MBtnSize)
MToggle.Position         = UDim2.new(0, 10, 0.45, 0)
MToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MToggle.Text             = "M"
MToggle.TextColor3       = Color3.fromRGB(255, 255, 255)
MToggle.Font             = Enum.Font.GothamBlack
MToggle.TextSize         = IsMobile and 30 or 22
MToggle.ZIndex           = 100
MToggle.AutoButtonColor  = false
Instance.new("UICorner", MToggle)

local MStroke = Instance.new("UIStroke", MToggle)
MStroke.Thickness = 2.5
MStroke.Color     = Color3.fromRGB(255, 255, 255)

do
    local mDrag, mStart, mPos, mMoved, mTick = false, nil, nil, false, 0
    MToggle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            mDrag  = true
            mStart = inp.Position
            mPos   = MToggle.Position
            mMoved = false
            mTick  = tick()
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not mDrag then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - mStart
            if delta.Magnitude > 8 then mMoved = true end
            MToggle.Position = UDim2.new(
                mPos.X.Scale, mPos.X.Offset + delta.X,
                mPos.Y.Scale, mPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if mDrag and not mMoved and (tick() - mTick) < 0.3 then
                Main.Visible = not Main.Visible
                if Main.Visible then Notify("OMNI", "Меню відкрито ✓", 1) end
            end
            mDrag = false
        end
    end)
end

-- ============================================================
-- [[ 19. UI COMPONENTS ]]
-- ============================================================
local function AddCat(text)
    local f = Instance.new("Frame", Scroll)
    f.Size             = UDim2.new(0.95, 0, 0, 20)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    f.BorderSizePixel  = 0
    Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f)
    l.Size                = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3          = Color3.fromRGB(200, 200, 200)
    l.Font                = Enum.Font.GothamBold
    l.TextSize            = 11
    l.Text                = "── " .. text .. " ──"
end

local function CreateBtn(text, logicName)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size             = UDim2.new(0.95, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Text             = "  " .. text
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    local dot = Instance.new("Frame", btn)
    dot.Name             = "StatusDot"
    dot.Size             = UDim2.new(0, 7, 0, 7)
    dot.Position         = UDim2.new(1, -14, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot)

    Buttons[logicName] = btn
    btn.MouseButton1Click:Connect(function() Toggle(logicName) end)
    return btn
end

local function CreateBindBtn(text, logicName)
    local container = Instance.new("Frame", Scroll)
    container.Size             = UDim2.new(0.95, 0, 0, 34)
    container.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container)

    local dot = Instance.new("Frame", container)
    dot.Name             = "StatusDot"
    dot.Size             = UDim2.new(0, 7, 0, 7)
    dot.Position         = UDim2.new(1, -80, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    dot.BorderSizePixel  = 0
    Instance.new("UICorner", dot)

    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size                = UDim2.new(1, -72, 1, 0)
    mainBtn.Position            = UDim2.new(0, 0, 0, 0)
    mainBtn.BackgroundTransparency = 1
    mainBtn.TextColor3          = Color3.fromRGB(255, 255, 255)
    mainBtn.Font                = Enum.Font.GothamBold
    mainBtn.TextSize            = 12
    mainBtn.Text                = "  " .. text
    mainBtn.TextXAlignment      = Enum.TextXAlignment.Left

    local bindBtn = Instance.new("TextButton", container)
    bindBtn.Size             = UDim2.new(0, 62, 0, 22)
    bindBtn.Position         = UDim2.new(1, -68, 0.5, -11)
    bindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bindBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
    bindBtn.Font             = Enum.Font.GothamBold
    bindBtn.TextSize         = 10
    bindBtn.BorderSizePixel  = 0
    bindBtn.AutoButtonColor  = false
    bindBtn.Text = Binds[logicName]
        and tostring(Binds[logicName]):gsub("Enum.KeyCode.", "")
        or "NONE"
    Instance.new("UICorner", bindBtn)

    local bStroke = Instance.new("UIStroke", bindBtn)
    bStroke.Color     = Color3.fromRGB(150, 150, 150)
    bStroke.Thickness = 1

    mainBtn.MouseButton1Click:Connect(function()
        if waitingBind == logicName then return end
        Toggle(logicName)
    end)

    bindBtn.MouseButton1Click:Connect(function()
        if waitingBind then return end
        waitingBind = logicName
        bindBtn.Text      = "..."
        bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Notify("BIND", "Натисни клавішу для: " .. text, 3)
    end)

    BindButtons[logicName] = {
        container = container,
        dot       = dot,
        mainBtn   = mainBtn,
        bindBtn   = bindBtn,
    }

    return container
end

local function CreateSlider(text, min, max, default, callback)
    local container = Instance.new("Frame", Scroll)
    container.Size             = UDim2.new(0.95, 0, 0, 52)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container)

    local label = Instance.new("TextLabel", container)
    label.Size                = UDim2.new(1, -8, 0, 22)
    label.Position            = UDim2.new(0, 4, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3          = Color3.fromRGB(220, 220, 220)
    label.Font                = Enum.Font.GothamBold
    label.TextSize            = 11
    label.TextXAlignment      = Enum.TextXAlignment.Left
    label.Text                = text .. ": " .. default

    local track = Instance.new("Frame", container)
    track.Size             = UDim2.new(0.92, 0, 0, 7)
    track.Position         = UDim2.new(0.04, 0, 0, 32)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill)

    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(80,  80,  80)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
    })

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 13, 0, 13)
    knob.Position         = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob)

    local dragging = false

    local function Update(inp)
        local rel = math.clamp(
            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        local val = math.floor(min + rel * (max - min))
        fill.Size       = UDim2.new(rel, 0, 1, 0)
        knob.Position   = UDim2.new(rel, -6, 0.5, -6)
        label.Text      = text .. ": " .. val
        callback(val)
    end

    track.InputBegan:Connect(function(inp)
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
-- [[ 20. GUI CONTENT ]]
-- ============================================================
AddCat("SPEED")
CreateSlider("🚀 FLY SPEED",  0,   300, Config.FlySpeed,
    function(v) Config.FlySpeed  = v end)
CreateSlider("⚡ WALK SPEED", 16,  200, Config.WalkSpeed,
    function(v) Config.WalkSpeed = v end)
CreateSlider("⬆️ JUMP POWER", 50,  500, Config.JumpPower,
    function(v) Config.JumpPower = v end)

AddCat("COMBAT")
CreateBindBtn("🎯 AUTO AIM",    "Aim")
CreateBindBtn("🔫 SILENT AIM",  "SilentAim")
CreateBtn("💀 MAGNET",          "ShadowLock")
CreateBtn("🥊 HITBOX",          "Hitbox")
CreateBtn("📦 ESP",             "ESP")

AddCat("MOVEMENT")
CreateBindBtn("🕊️ FLY",         "Fly")
CreateBtn("⚡ SPEED",           "Speed")
CreateBtn("🐇 BHOP",            "Bhop")
CreateBtn("⬆️ HIGH JUMP",       "HighJump")
CreateBindBtn("👻 NOCLIP",       "Noclip")
CreateBtn("🛡️ NO FALL DMG",     "NoFallDamage")

AddCat("MISC")
CreateBtn("🌀 SPIN",            "Spin")
CreateBtn("🥔 POTATO",          "Potato")
CreateBtn("📶 FAKE LAG",        "FakeLag")
CreateBtn("🎥 FREECAM",         "Freecam")
CreateBtn("🛡️ ANTI-AFK",        "AntiAFK")
CreateBtn("🔒 ANTI-KICK",       "AntiKick")

-- ============================================================
-- [[ 21. BIND INPUT HANDLER ]]
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
    -- Чекаємо бінд
    if waitingBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local key  = inp.KeyCode
            local name = waitingBind
            Binds[name] = key
            if BindButtons[name] then
                BindButtons[name].bindBtn.Text      =
                    tostring(key):gsub("Enum.KeyCode.", "")
                BindButtons[name].bindBtn.TextColor3 =
                    Color3.fromRGB(200, 200, 200)
            end
            Notify("BIND", name .. " → " .. tostring(key):gsub("Enum.KeyCode.", ""), 2)
            waitingBind = nil
        end
        return
    end

    if gpe then return end

    -- Перевірка бінд-дій
    for action, key in pairs(Binds) do
        if inp.KeyCode == key then
            if action == "ToggleMenu" then
                Main.Visible = not Main.Visible
            else
                Toggle(action)
            end
        end
    end

    -- F9 / F12 blur
    if inp.KeyCode == Enum.KeyCode.F9
    or inp.KeyCode == Enum.KeyCode.F12 then
        TweenService:Create(Blur, TweenInfo.new(0.15), { Size = 36 }):Play()
        task.delay(1.5, function()
            TweenService:Create(Blur, TweenInfo.new(0.3), { Size = 0 }):Play()
        end)
    end
end)

-- ============================================================
-- [[ 22. BLACK-WHITE ANIMATION LOOP ]]
-- ============================================================
task.spawn(function()
    local t = 0
    while true do
        task.wait(0.03)
        t = t + 0.025

        -- Плавне значення 0..1
        local v    = (math.sin(t) + 1) / 2
        local vInv = 1 - v

        local bv   = math.floor(v    * 255)
        local bInv = math.floor(vInv * 255)

        local col    = Color3.fromRGB(bv,   bv,   bv)
        local colInv = Color3.fromRGB(bInv, bInv, bInv)

        -- Stroke головного фрейму
        ms.Color = col

        -- Stats stroke (зміщена фаза)
        local v2  = (math.sin(t + 1.5) + 1) / 2
        local bv2 = math.floor(v2 * 255)
        ss.Color  = Color3.fromRGB(bv2, bv2, bv2)

        -- M кнопка фон <-> текст контрастні
        MToggle.BackgroundColor3 = col
        MToggle.TextColor3       = colInv
        MStroke.Color            = colInv

        -- Title gradient переливається
        local vA  = math.floor(v    * 255)
        local vB  = math.floor(vInv * 255)
        TitleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(vA,  vA,  vA)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(vB,  vB,  vB)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(vA,  vA,  vA)),
        })
        TitleGradient.Rotation = (t * 30) % 360

        -- Активні звичайні кнопки переливаються
        for name, btn in pairs(Buttons) do
            if State[name] and btn:IsA("TextButton") then
                btn.BackgroundColor3 = col
                btn.TextColor3       = colInv
            end
        end

        -- Активні bind-кнопки переливаються
        for name, bd in pairs(BindButtons) do
            if State[name] then
                local shade = math.floor(v * 70)
                bd.container.BackgroundColor3 =
                    Color3.fromRGB(shade, shade, shade)
                bd.mainBtn.TextColor3 = col
            end
        end

        -- Заголовок тексту пульсує
        local tShade = math.floor(180 + v * 75)
        TitleLbl.TextColor3 = Color3.fromRGB(tShade, tShade, tShade)
    end
end)

-- ============================================================
-- [[ 23. MAIN RENDER LOOP ]]
-- ============================================================
RunService.RenderStepped:Connect(function()
    local now = tick()
    table.insert(FrameLog, now)
    while FrameLog[1] and FrameLog[1] < now - 1 do
        table.remove(FrameLog, 1)
    end

    local fps = #FrameLog
    FPSLabel.Text = "FPS: " .. fps

    if now - pingTick > 2 then
        pingTick = now
        pcall(function() lastPing = LP:GetNetworkPing() end)
    end
    local pingMs = math.floor(lastPing * 1000)
    PingLabel.Text = "Ping: " .. pingMs .. "ms"

    -- FPS колір
    if fps >= 55 then
        FPSLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    elseif fps >= 30 then
        FPSLabel.TextColor3 = Color3.fromRGB(220, 220, 150)
    else
        FPSLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end

    -- Ping колір
    if pingMs <= 80 then
        PingLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    elseif pingMs <= 150 then
        PingLabel.TextColor3 = Color3.fromRGB(220, 220, 150)
    else
        PingLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    end

    -- FREECAM
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
        local dir = Camera.CFrame.LookVector  * -moveZ
                  + Camera.CFrame.RightVector *  moveX
        if UIS:IsKeyDown(Enum.KeyCode.E)
        or UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir += Camera.CFrame.UpVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Q)
        or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir -= Camera.CFrame.UpVector
        end
        if dir.Magnitude > 1 then dir = dir.Unit end
        local speed = (Config.FlySpeed / 25) * (60 / math.max(fps, 1))
        Camera.CFrame = CFrame.new(Camera.CFrame.Position + dir * speed)
            * CFrame.fromEulerAnglesYXZ(FC_Pitch, FC_Yaw, 0)
    end

    -- AUTO AIM
    if State.Aim and not State.Freecam then
        local target = GetClosestToScreen()
        if target then
            local head = target:FindFirstChild("Head")
            if head then
                local pred = head.AssemblyLinearVelocity
                           * math.clamp(lastPing, 0, 0.2)
                Camera.CFrame = CFrame.new(
                    Camera.CFrame.Position,
                    head.Position + pred
                )
            end
        end
    end

    -- SILENT AIM FALLBACK
    if State.SilentAim and not State.Aim and not State.Freecam then
        if not hookInstalled then FallbackSilentAim() end
    end
end)

-- Freecam Mouse
UIS.InputChanged:Connect(function(inp, gpe)
    if not State.Freecam or gpe then return end
    local isMove  = inp.UserInputType == Enum.UserInputType.MouseMovement
    local isTouch = inp.UserInputType == Enum.UserInputType.Touch
    if isMove or isTouch then
        local useMouse = isMove
            and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if useMouse or isTouch then
            FC_Yaw   = FC_Yaw - math.rad(inp.Delta.X * 0.35)
            FC_Pitch = math.clamp(
                FC_Pitch - math.rad(inp.Delta.Y * 0.35),
                -math.rad(89), math.rad(89)
            )
        end
    end
end)

-- ============================================================
-- [[ 24. HEARTBEAT LOOP ]]
-- ============================================================
local lastJump = 0

RunService.Heartbeat:Connect(function()
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum then return end

    -- MAGNET
    if State.ShadowLock then
        if not IsAlive(LockedTarget) then
            LockedTarget = GetClosestByDist()
        end
        if LockedTarget then
            local tHRP = LockedTarget:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local pred = tHRP.AssemblyLinearVelocity
                           * math.clamp(lastPing, 0, 0.2)
                local goal = CFrame.new(tHRP.Position + pred)
                           * tHRP.CFrame.Rotation
                           * CFrame.new(0, 0, 3)
                HRP.CFrame = HRP.CFrame:Lerp(goal, 0.4)
                HRP.AssemblyLinearVelocity = tHRP.AssemblyLinearVelocity
            end
        end
    end

    -- FLY
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
        local dir = Camera.CFrame.LookVector  * -moveZ
                  + Camera.CFrame.RightVector *  moveX
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir += Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir -= Vector3.new(0, 1, 0)
        end
        if dir.Magnitude > 1 then dir = dir.Unit end
        local fps   = math.max(#FrameLog, 1)
        local speed = Config.FlySpeed * (60 / fps)
        local jx    = math.noise(tick() * 18) * 1.1
        local jy    = math.sin(tick()  * 40) * 0.4
        local jz    = math.noise(tick() * 22) * 0.9
        HRP.AssemblyLinearVelocity = dir * speed + Vector3.new(jx, jy, jz)
        if not State.Spin then
            HRP.AssemblyAngularVelocity = Vector3.zero
        end
        if HRP.Position.Y > 200 then
            HRP.AssemblyLinearVelocity -= Vector3.new(0, 28, 0)
        end
    end

    -- SPEED
    if State.Speed and not State.Fly and not State.Freecam then
        if Hum.MoveDirection.Magnitude > 0
        and Hum.FloorMaterial ~= Enum.Material.Air then
            local fps   = math.max(#FrameLog, 1)
            local boost = (Config.WalkSpeed - 16) / 120
            HRP.CFrame  = HRP.CFrame + Hum.MoveDirection * (boost * (60 / fps))
        end
    end

    -- HIGH JUMP
    if State.HighJump and not State.Fly then
        local s = Hum:GetState()
        if s == Enum.HumanoidStateType.Jumping
        or UIS:IsKeyDown(Enum.KeyCode.Space) then
            HRP.AssemblyLinearVelocity = Vector3.new(
                HRP.AssemblyLinearVelocity.X,
                Config.JumpPower * 0.82,
                HRP.AssemblyLinearVelocity.Z
            )
        end
    end

    -- BHOP
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

    -- NO FALL DAMAGE
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
end)

-- ============================================================
-- [[ 25. NOCLIP ]]
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
                    v.CanCollide    = false
                    v.CollisionGroup = SafeGroup
                else
                    v.CanCollide    = true
                    v.CollisionGroup = "Default"
                end
            end
        end
        if moving and (HRP.Position - lastNoclipPos).Magnitude < 0.04 then
            HRP.CFrame = HRP.CFrame
                + Hum.MoveDirection * 0.35
                + Vector3.new(0, 0.12, 0)
        end
        lastNoclipPos = HRP.Position
    elseif Char and HRP then
        lastNoclipPos = HRP.Position
    end
end)

-- ============================================================
Notify("OMNI V262.4", "✅ Ready! M=menu | Binds у меню | B&W GUI ✓", 5)
