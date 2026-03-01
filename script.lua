-- ██████████████████████████████████████████████████████████
-- ██  OMNI V300 — MONSTER EDITION  (rewritten & fixed)    ██
-- ██  Anti-Ban · Anti-Kick · Universal · Mobile+PC        ██
-- ██████████████████████████████████████████████████████████

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local Workspace      = game:GetService("Workspace")
local VirtualUser    = game:GetService("VirtualUser")
local PhysicsService = game:GetService("PhysicsService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")
local HttpService    = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- SAFE ENV DETECTION (визначаємо що доступно)
-- ============================================================
local ENV = {}
ENV.hasGetRawMeta   = (getrawmetatable ~= nil)
ENV.hasSetReadOnly  = (setreadonly ~= nil)
ENV.hasNewCClosure  = (newcclosure ~= nil)
ENV.hasGetNameCall  = (getnamecallmethod ~= nil)
ENV.hasSynapse      = (syn ~= nil) or (SENTINEL_V2 ~= nil)
ENV.hasHookFunction = (hookfunction ~= nil)

-- ============================================================
-- CLEANUP СТАРИХ ВЕРСІЙ
-- ============================================================
pcall(function()
    for _, sg in pairs({game:GetService("CoreGui"), LP:WaitForChild("PlayerGui", 5)}) do
        if not sg then continue end
        for _, v in pairs(sg:GetChildren()) do
            if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then v:Destroy() end
        end
    end
end)

-- ============================================================
-- COLLISION GROUP (безпечний noclip)
-- ============================================================
local SafeGroup = "OmniNC_" .. math.random(1000, 9999)
pcall(function()
    if PhysicsService.RegisterCollisionGroup then
        PhysicsService:RegisterCollisionGroup(SafeGroup)
    elseif PhysicsService.CreateCollisionGroup then
        -- Старий API
        pcall(function() PhysicsService:CreateCollisionGroup(SafeGroup) end)
    end
    pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Default", false) end)
    pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, SafeGroup, false) end)
end)

-- ============================================================
-- УТИЛІТИ
-- ============================================================
local function RndStr(n)
    local c = {}
    for i = 1, n do c[i] = string.char(math.random(97,122)) end
    return table.concat(c)
end

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 2})
    end)
end

local function SafeDel(o)
    pcall(function() if o and o.Parent then o:Destroy() end end)
end

local function SafeSet(obj, prop, val)
    pcall(function() obj[prop] = val end)
end

-- ============================================================
-- DEVICE DETECTION
-- ============================================================
local IsMob = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsTab = UIS.TouchEnabled

-- Blur effect
local Blur = Instance.new("BlurEffect")
Blur.Size   = 0
Blur.Parent = Lighting

-- ============================================================
-- PLAYER MODULE (для мобільного руху)
-- ============================================================
local Controls, ControlsOK = nil, false
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)
    pcall(function()
        local pm = require(LP.PlayerScripts:WaitForChild("PlayerModule", 10))
        Controls    = pm:GetControls()
        ControlsOK  = true
    end)
end)

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    FlySpeed     = 55,
    WalkSpeed    = 30,
    JumpPower    = 125,
    BhopPower    = 62,
    HitboxSize   = 5,
    AimFOV       = 200,
    AimSmooth    = 0.18,
    AimPart      = "Head",

    -- Антибан налаштування
    SpeedAntiBan      = true,   -- Рандомізує WalkSpeed щоб уникнути детекту
    FlyAntiBan        = true,   -- Нульова висота обмежена, емуляція стрибків
    HitboxRandomize   = true,   -- Рандомізує hitbox чуть-чуть щоб уникнути патернів
    AimAntiDetect     = true,   -- Додає мікро-шум до aim щоб виглядало людяно
    SpeedJitter       = 1.5,    -- ± швидкість jitter для обходу античіту
    FlyHeightMax      = 1800,   -- Максимальна висота польоту
}

local Binds = {
    Fly        = Enum.KeyCode.F,
    Aim        = Enum.KeyCode.G,
    Noclip     = Enum.KeyCode.V,
    SilentAim  = Enum.KeyCode.B,
    ToggleMenu = Enum.KeyCode.M,
}

local State = {
    Fly=false, Aim=false, SilentAim=false, ShadowLock=false,
    Noclip=false, Hitbox=false, Speed=false, Bhop=false,
    ESP=false, Spin=false, HighJump=false, Potato=false,
    FakeLag=false, Freecam=false, NoFallDamage=false,
    AntiAFK=false, AntiKick=false, InfiniteJump=false,
}

-- ============================================================
-- ЗМІННІ СТАНУ
-- ============================================================
local LockedTarget   = nil
local FrameLog       = {}
local lastPing, pingTk = 0, 0
local silentActive   = false
local waitingBind    = nil
local MobUp, MobDn   = false, false
local FC_P, FC_Y     = 0, 0
local spReset, lastSpCk = false, 0
local lastBhop       = 0
local ncStuck        = 0
local lastNcPos      = Vector3.zero
local fakeLagThr     = nil
local AllRows        = {}
local TabPages       = {}
local TabBtns        = {}
local CurTab         = "Combat"

local aimTarget      = nil
local aimLastSwitch  = 0
local aimLocked      = false
local aimSwitchCD    = 0.35
local aimLostFrames  = 0

-- Raycast params
local ncRay  = RaycastParams.new()
ncRay.FilterType  = Enum.RaycastFilterType.Exclude
local aimRay = RaycastParams.new()
aimRay.FilterType = Enum.RaycastFilterType.Exclude

-- ============================================================
-- ████  ANTI-KICK / ANTI-BAN HOOK  ████
-- Повністю переписаний — більш агресивний і надійний
-- ============================================================
local akOn = false

-- 1. Перехоплення Kick через метатаблицю
local _metaHooked = false
if ENV.hasGetRawMeta and ENV.hasSetReadOnly and ENV.hasNewCClosure and ENV.hasGetNameCall then
    pcall(function()
        local mt  = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()

            -- === ANTI-KICK ===
            if akOn then
                -- Блокуємо Kick на LocalPlayer
                if m == "Kick" and self == LP then
                    warn("[OMNI] Kick blocked!")
                    return
                end
                -- Блокуємо Kick через Character
                local char = LP.Character
                if char and m == "Kick" and self == char then
                    warn("[OMNI] Char-Kick blocked!")
                    return
                end
                -- Блокуємо підозрілі RemoteEvent:FireServer
                if m == "FireServer" then
                    local args = {...}
                    if type(args[1]) == "string" then
                        local l = string.lower(args[1])
                        if l:find("kick") or l:find("ban") or l:find("report") then
                            warn("[OMNI] Suspicious FireServer blocked: " .. args[1])
                            return
                        end
                    end
                end
                -- Блокуємо InvokeServer з kick-аргументами
                if m == "InvokeServer" then
                    local args = {...}
                    if type(args[1]) == "string" then
                        local l = string.lower(args[1])
                        if l:find("kick") or l:find("ban") then
                            warn("[OMNI] Suspicious InvokeServer blocked")
                            return
                        end
                    end
                end
            end

            -- === SILENT AIM ===
            if silentActive and self == Workspace then
                local args = {...}
                local tgt  = _GetBestTargetSilent and _GetBestTargetSilent()
                local hd   = tgt and FindAimPart and FindAimPart(tgt)
                if hd then
                    local o = Camera.CFrame.Position
                    if m == "Raycast" and typeof(args[2]) == "Vector3" then
                        args[2] = (hd.Position - o).Unit * args[2].Magnitude
                        return old(self, table.unpack(args))
                    elseif (m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRay") then
                        if typeof(args[1]) == "Ray" then
                            args[1] = Ray.new(o, (hd.Position - o).Unit * args[1].Direction.Magnitude)
                            return old(self, table.unpack(args))
                        end
                    end
                end
            end

            return old(self, ...)
        end)
        setreadonly(mt, true)
        _metaHooked = true
    end)
end

-- 2. Додатковий захист — патч через hookfunction якщо доступно
if ENV.hasHookFunction then
    pcall(function()
        local oldKick = LP.Kick
        hookfunction(oldKick, function(self, ...)
            if akOn and self == LP then
                warn("[OMNI] Kick blocked via hookfunction!")
                return
            end
            return oldKick(self, ...)
        end)
    end)
end

-- 3. Fallback — перевизначення Kick через pcall-щит
-- Якщо метатаблиця не доступна — ловимо через CharacterAdded щоб respawn не кікнув
LP.CharacterRemoving:Connect(function()
    -- Якщо антикік ввімкнений — скасовуємо respawn delay
    if akOn then
        task.delay(0.1, function()
            pcall(function() LP:LoadCharacter() end)
        end)
    end
end)

-- ============================================================
-- ████  SPEED ANTI-BAN  ████
-- Рандомізація WalkSpeed щоб не спрацьовував античіт
-- ============================================================
local function GetSafeSpeed()
    if not Config.SpeedAntiBan then return Config.WalkSpeed end
    local jit = Config.SpeedJitter
    return Config.WalkSpeed + (math.random() * jit * 2 - jit)
end

-- ============================================================
-- HELPERS
-- ============================================================
local function IsAlive(c)
    if not c or not c.Parent then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function FindHead(char)
    if not char then return nil end
    local h = char:FindFirstChild("Head")
    if h and h:IsA("BasePart") then return h end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Head" then return v end
    end
    return nil
end

function FindAimPart(char)
    if not char then return nil end
    local name = Config.AimPart or "Head"
    local p = char:FindFirstChild(name)
    if p and p:IsA("BasePart") then return p end
    p = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if p and p:IsA("BasePart") then return p end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == name then return v end
    end
    return nil
end

local function IsVisible(char)
    if not char then return false end
    local myChar = LP.Character
    if not myChar then return false end
    local part = FindAimPart(char)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local target = part.Position
    local dir    = target - origin
    local dist   = dir.Magnitude
    if dist < 1 then return true end
    aimRay.FilterDescendantsInstances = {myChar, Camera}
    local ok, result = pcall(function()
        return Workspace:Raycast(origin, dir.Unit * (dist - 0.5), aimRay)
    end)
    if not ok then return true end -- при помилці рейкасту вважаємо видимим
    if not result then return true end
    if result.Instance:IsDescendantOf(char) then return true end
    if result.Instance.Transparency >= 0.8 then return true end
    return false
end

local function ScreenDist(part)
    if not part then return math.huge end
    local ok, pos, on = pcall(function()
        return Camera:WorldToViewportPoint(part.Position)
    end)
    if not ok then return math.huge end
    if not on then return math.huge end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - center).Magnitude
end

-- ============================================================
-- AIM TARGETING
-- ============================================================
local function FindNewTarget()
    local fov    = Config.AimFOV
    local best, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not IsAlive(char) then continue end
        local part = FindAimPart(char)
        if not part then continue end
        local sd = ScreenDist(part)
        if sd > fov then continue end
        if not IsVisible(char) then continue end
        if sd < bestDist then bestDist = sd; best = p end
    end
    return best
end

local function GetBestAimTarget()
    local now = tick()
    local fov = Config.AimFOV
    if aimTarget and aimLocked then
        local char = aimTarget.Character
        if IsAlive(char) then
            local part = FindAimPart(char)
            if part then
                local sd  = ScreenDist(part)
                local vis = IsVisible(char)
                if sd <= fov * 1.8 and vis then
                    aimLostFrames = 0
                    return char
                end
                if not vis then
                    aimLostFrames += 1
                    if aimLostFrames < 15 then return char end
                elseif sd > fov * 1.8 then
                    aimLostFrames += 1
                    if aimLostFrames < 8 then return char end
                end
            end
        end
        aimTarget = nil; aimLocked = false; aimLostFrames = 0
    end
    if now - aimLastSwitch < aimSwitchCD then return nil end
    local best = FindNewTarget()
    if best then
        aimTarget = best; aimLocked = true
        aimLostFrames = 0; aimLastSwitch = now
        return best.Character
    end
    return nil
end

_GetBestTargetSilent = function()
    return GetBestAimTarget()
end

local function GetClosestDist()
    local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not my then return nil end
    local best, bd = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp and IsAlive(p.Character) then
            local d = (my.Position - hrp.Position).Magnitude
            if d < bd then bd = d; best = p.Character end
        end
    end
    return best
end

-- ============================================================
-- ESP
-- ============================================================
local ESPCache = {}

local function ClearESP()
    for _, d in pairs(ESPCache) do
        pcall(function() d.hl:Destroy(); d.bb:Destroy() end)
    end
    ESPCache = {}
end

task.spawn(function()
    while task.wait(0.15) do
        if not State.ESP then continue end
        local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end
            local c  = p.Character
            local hd = FindHead(c)
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            if not c or not hd or not hm then
                if ESPCache[p] then
                    pcall(function() ESPCache[p].hl:Destroy(); ESPCache[p].bb:Destroy() end)
                    ESPCache[p] = nil
                end
                continue
            end
            local ca = ESPCache[p]
            if not ca or not ca.hl or not ca.hl.Parent or not ca.bb or not ca.bb.Parent then
                if ca then pcall(function() ca.hl:Destroy(); ca.bb:Destroy() end) end
                local hl = Instance.new("Highlight", c)
                hl.FillColor        = Color3.fromRGB(220, 40, 40)
                hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                local bb = Instance.new("BillboardGui", hd)
                bb.Size        = UDim2.new(0, 170, 0, 50)
                bb.StudsOffset = Vector3.new(0, 3.4, 0)
                bb.AlwaysOnTop = true
                bb.MaxDistance = 600
                local bg = Instance.new("Frame", bb)
                bg.Size                   = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3       = Color3.fromRGB(10, 10, 16)
                bg.BackgroundTransparency = 0.2
                bg.BorderSizePixel        = 0
                Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 7)
                Instance.new("UIStroke", bg).Color        = Color3.fromRGB(60, 60, 75)
                local lb = Instance.new("TextLabel", bg)
                lb.Name               = "T"
                lb.Size               = UDim2.new(1, -6, 1, 0)
                lb.Position           = UDim2.new(0, 3, 0, 0)
                lb.BackgroundTransparency = 1
                lb.Font               = Enum.Font.GothamBold
                lb.TextSize           = 10
                lb.TextWrapped        = true
                lb.TextColor3         = Color3.new(1, 1, 1)
                ESPCache[p] = {hl=hl, bb=bb, lbl=lb}
                ca = ESPCache[p]
            end
            local hp = math.floor(hm.Health)
            local mx = math.max(math.floor(hm.MaxHealth), 1)
            local ds = my and math.floor((my.Position - hd.Position).Magnitude) or 0
            local r  = hp / mx
            ca.lbl.Text = string.format("[%s]\nHP:%d/%d  %dm", p.Name, hp, mx, ds)
            ca.lbl.TextColor3 = r >= 0.6 and Color3.fromRGB(80, 255, 120)
                or r >= 0.3 and Color3.fromRGB(255, 220, 40)
                or Color3.fromRGB(255, 60, 60)
            ca.hl.FillColor = r >= 0.5 and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(220, 40, 40)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        pcall(function() ESPCache[p].hl:Destroy(); ESPCache[p].bb:Destroy() end)
        ESPCache[p] = nil
    end
end)

-- ============================================================
-- HITBOX
-- ============================================================
local hbParts = {}

local function ApplyHB(part)
    if not part or not part:IsA("BasePart") then return end
    if not hbParts[part] then
        hbParts[part] = {S=part.Size, T=part.Transparency, C=part.CanCollide, M=part.Massless}
    end
    local s = Config.HitboxSize
    -- Якщо HitboxRandomize — трошки варіюємо щоб не палитись
    if Config.HitboxRandomize then
        s = s + (math.random() * 0.4 - 0.2)
    end
    pcall(function()
        part.Size         = Vector3.new(s, s, s)
        part.Transparency = 0.7
        part.CanCollide   = false
        part.Massless     = true
    end)
end

local function RestoreHB()
    for p, o in pairs(hbParts) do
        pcall(function()
            if p and p.Parent then
                p.Size         = o.S
                p.Transparency = o.T
                p.CanCollide   = o.C
                p.Massless     = o.M
            end
        end)
    end
    hbParts = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if not State.Hitbox then continue end
        local s = Config.HitboxSize
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or not IsAlive(p.Character) then continue end
            for _, v in pairs(p.Character:GetDescendants()) do
                if v:IsA("BasePart")
                    and not (v.Parent and (v.Parent:IsA("Accessory") or v.Parent:IsA("Hat")))
                    and v.Size.Magnitude > 0.3
                    and v.Size.X < s - 0.2 then
                    ApplyHB(v)
                end
            end
        end
        -- Підтримуємо розмір
        for part in pairs(hbParts) do
            if part and part.Parent and math.abs(part.Size.X - s) > 0.5 then
                pcall(function() part.Size = Vector3.new(s, s, s) end)
            end
        end
    end
end)

-- ============================================================
-- POTATO MODE
-- ============================================================
local savedShd, savedQ = true, Enum.QualityLevel.Automatic
local function DoPotato()
    pcall(function()
        savedShd = Lighting.GlobalShadows
        savedQ   = settings().Rendering.QualityLevel
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.CastShadow = false
                v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("SpecialMesh") then
                -- нічого
            end
        end)
    end
end

local function UndoPotato()
    pcall(function()
        Lighting.GlobalShadows = savedShd
        settings().Rendering.QualityLevel = savedQ
    end)
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.CastShadow = true
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = true
            end
        end)
    end
end

-- ============================================================
-- FORCE RESTORE
-- ============================================================
local function ForceRestore()
    local C = LP.Character; if not C then return end
    local H = C:FindFirstChildOfClass("Humanoid")
    local R = C:FindFirstChild("HumanoidRootPart")
    if H then
        pcall(function()
            H.PlatformStand = false
            H.WalkSpeed     = 16
            H.UseJumpPower  = true
            H.JumpPower     = 50
        end)
    end
    if R then
        pcall(function() R.Anchored = false end)
        for _, v in pairs(R:GetChildren()) do
            if v:IsA("BodyMover") then SafeDel(v) end
        end
    end
    for _, v in pairs(C:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.CanCollide     = true
                v.CollisionGroup = "Default"
            end
        end)
    end
    ncStuck = 0; lastNcPos = Vector3.zero
end

-- ============================================================
-- TOGGLE VISUAL UPDATE
-- ============================================================
local function UpdVis(nm)
    local d = AllRows[nm]; if not d then return end
    local on = State[nm]
    if d.swBG then
        TweenService:Create(d.swBG, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 65)
        }):Play()
    end
    if d.swDot then
        TweenService:Create(d.swDot, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
    end
    if d.accent then
        d.accent.BackgroundColor3 = on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
    end
    if d.row then
        d.row.BackgroundColor3 = on and Color3.fromRGB(30, 38, 34) or Color3.fromRGB(24, 24, 36)
    end
end

-- ============================================================
-- TOGGLE LOGIC
-- ============================================================
local function Toggle(nm)
    State[nm] = not State[nm]
    local C = LP.Character
    local R = C and C:FindFirstChild("HumanoidRootPart")
    local H = C and C:FindFirstChildOfClass("Humanoid")

    -- === ВИМКНЕННЯ ===
    if not State[nm] then
        if nm == "Fly" then
            pcall(function()
                if R then R.Anchored = false; R.AssemblyLinearVelocity = Vector3.zero end
                if H then H.PlatformStand = false end
            end)
        end
        if nm == "Speed" then
            spReset = false
            pcall(function() if H then H.WalkSpeed = 16 end end)
        end
        if nm == "HighJump" and H then
            pcall(function() H.UseJumpPower = true; H.JumpPower = 50; H.JumpHeight = 7.2 end)
        end
        if nm == "Noclip" or nm == "ShadowLock" then ForceRestore() end
        if nm == "ESP"       then ClearESP() end
        if nm == "Hitbox"    then RestoreHB() end
        if nm == "Potato"    then UndoPotato() end
        if nm == "SilentAim" then silentActive = false end
        if nm == "AntiKick"  then akOn = false end
        if nm == "Freecam" then
            Camera.CameraType = Enum.CameraType.Custom
            if H then Camera.CameraSubject = H end
            pcall(function() if R then R.Anchored = false end end)
            task.delay(0.05, function()
                pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
            end)
        end
        if nm == "Spin" and R then
            for _, v in pairs(R:GetChildren()) do
                if v.Name == "SpinAV" then SafeDel(v) end
            end
        end
        if nm == "FakeLag" and R then
            pcall(function() R.Anchored = false end)
        end
        if nm == "InfiniteJump" and H then
            pcall(function() H:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
        end
        if nm == "Aim" then
            aimTarget = nil; aimLocked = false; aimLostFrames = 0
        end
    end

    -- === ВМИКАННЯ ===
    if State[nm] then
        if nm == "SilentAim" then silentActive = true end
        if nm == "AntiKick"  then akOn = true end
        if nm == "Potato"    then DoPotato() end
        if nm == "ShadowLock" then LockedTarget = GetClosestDist() end
        if nm == "Fly" and H then
            pcall(function() H.PlatformStand = false end)
        end
        if nm == "Speed" and H then
            pcall(function() H.WalkSpeed = GetSafeSpeed() end)
            spReset = false; lastSpCk = 0
        end
        if nm == "HighJump" and H then
            pcall(function()
                H.UseJumpPower = true
                H.JumpPower    = Config.JumpPower
                H.JumpHeight   = Config.JumpPower * 0.14
            end)
        end
        if nm == "Spin" and R then
            local av = Instance.new("BodyAngularVelocity", R)
            av.Name            = "SpinAV"
            av.MaxTorque       = Vector3.new(0, math.huge, 0)
            av.AngularVelocity = Vector3.new(0, 22, 0)
            av.P               = 1500
        end
        if nm == "Freecam" then
            Camera.CameraSubject = nil
            Camera.CameraType    = Enum.CameraType.Scriptable
            local x, y = Camera.CFrame:ToEulerAnglesYXZ()
            FC_P = x; FC_Y = y
            pcall(function() if R then R.Anchored = true end end)
        end
        if nm == "FakeLag" and not fakeLagThr then
            fakeLagThr = task.spawn(function()
                while State.FakeLag do
                    local cr = LP.Character
                    local rp = cr and cr:FindFirstChild("HumanoidRootPart")
                    local hm = cr and cr:FindFirstChildOfClass("Humanoid")
                    if rp and hm and hm.MoveDirection.Magnitude > 0
                        and not State.Fly and not State.Freecam then
                        pcall(function() rp.Anchored = true end)
                        task.wait(math.random(35, 80) / 1000)
                        pcall(function() rp.Anchored = false end)
                        task.wait(math.random(90, 200) / 1000)
                    else
                        task.wait(0.15)
                    end
                end
                fakeLagThr = nil
            end)
        end
        if nm == "Noclip" then ncStuck = 0; lastNcPos = Vector3.zero end
        if nm == "Aim" then
            aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimLastSwitch = 0
        end
    end

    UpdVis(nm)
    Notify(nm, State[nm] and "ON ✓" or "OFF ✗", 1)
end

-- ============================================================
-- ANTI-AFK (більш надійний)
-- ============================================================
LP.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

task.spawn(function()
    while task.wait(50 + math.random() * 10) do -- рандомний інтервал
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ============================================================
-- CHARACTER RESPAWN HANDLER
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    MobUp = false; MobDn = false; spReset = false; ncStuck = 0
    aimTarget = nil; aimLocked = false; aimLostFrames = 0

    -- При респауні вимикаємо проблемні фічі
    for _, n in pairs({"Fly","Noclip","Freecam","Spin","FakeLag"}) do
        if State[n] then State[n] = false; UpdVis(n) end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        Camera.CameraType    = Enum.CameraType.Custom
        Camera.CameraSubject = hum
        task.wait(0.5)
        if State.Speed  then pcall(function() hum.WalkSpeed = GetSafeSpeed() end) end
        if State.HighJump then
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower    = Config.JumpPower
                hum.JumpHeight   = Config.JumpPower * 0.14
            end)
        end
    end
end)

-- ============================================================
-- GUI SETUP
-- ============================================================
local GuiP = LP:WaitForChild("PlayerGui", 5)
pcall(function()
    local c = game:GetService("CoreGui")
    local _ = c.Name -- перевіряємо доступ
    GuiP = c
end)

local Scr = Instance.new("ScreenGui", GuiP)
Scr.Name           = RndStr(12)
Scr.ResetOnSpawn   = false
Scr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Scr.IgnoreGuiInset = true
Instance.new("BoolValue", Scr).Name = "OmniMarker"

local P = {
    bg    = Color3.fromRGB(12, 12, 18),
    card  = Color3.fromRGB(20, 20, 30),
    btn   = Color3.fromRGB(24, 24, 36),
    dark  = Color3.fromRGB(14, 14, 22),
    acc   = Color3.fromRGB(0, 190, 110),
    txt   = Color3.fromRGB(230, 230, 240),
    dim   = Color3.fromRGB(120, 120, 145),
    brd   = Color3.fromRGB(40, 40, 58),
    grn   = Color3.fromRGB(0, 200, 100),
    wht   = Color3.fromRGB(255, 255, 255),
    swOff = Color3.fromRGB(50, 50, 65),
    tabA  = Color3.fromRGB(32, 32, 48),
    onBg  = Color3.fromRGB(30, 38, 34),
}

local VP  = Camera.ViewportSize
local MW  = IsMob and math.min(325, VP.X - 20) or 315
local MH  = IsMob and math.min(570, VP.Y - 80) or 530
local BH  = IsMob and 44 or 34
local FS  = IsMob and 13 or 11
local MBS = IsMob and 58 or 48

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local fovCircle = Instance.new("Frame", Scr)
fovCircle.Size                   = UDim2.new(0, Config.AimFOV*2, 0, Config.AimFOV*2)
fovCircle.Position               = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel        = 0
fovCircle.Visible                = false
fovCircle.ZIndex                 = 10
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color        = Color3.fromRGB(0, 200, 100)
fovStroke.Thickness    = 1.5
fovStroke.Transparency = 0.3

local tgtInfo = Instance.new("TextLabel", Scr)
tgtInfo.Size                   = UDim2.new(0, 200, 0, 22)
tgtInfo.Position               = UDim2.new(0.5, -100, 0.5, -Config.AimFOV - 32)
tgtInfo.BackgroundColor3       = Color3.fromRGB(10, 10, 16)
tgtInfo.BackgroundTransparency = 0.2
tgtInfo.BorderSizePixel        = 0
tgtInfo.TextColor3             = P.grn
tgtInfo.Font                   = Enum.Font.GothamBold
tgtInfo.TextSize               = 11
tgtInfo.Text                   = ""
tgtInfo.Visible                = false
tgtInfo.ZIndex                 = 12
Instance.new("UICorner", tgtInfo).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tgtInfo).Color        = P.brd

local function UpdateFOVCircle()
    local r = Config.AimFOV
    fovCircle.Size     = UDim2.new(0, r*2, 0, r*2)
    fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r)
    tgtInfo.Position   = UDim2.new(0.5, -100, 0.5, -r - 32)
end

-- ============================================================
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame", Scr)
Main.Size             = UDim2.new(0, MW, 0, MH)
Main.Position         = UDim2.new(0.5, -MW/2, 0.5, -MH/2)
Main.BackgroundColor3 = P.bg
Main.Visible          = false
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local mainS = Instance.new("UIStroke", Main)
mainS.Color     = P.brd
mainS.Thickness = 1.5

-- TITLE BAR
local TB = Instance.new("Frame", Main)
TB.Size             = UDim2.new(1, 0, 0, 42)
TB.BackgroundColor3 = P.dark
TB.BorderSizePixel  = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 14)
local tbF = Instance.new("Frame", TB)
tbF.Size             = UDim2.new(1, 0, 0, 14)
tbF.Position         = UDim2.new(0, 0, 1, -14)
tbF.BackgroundColor3 = P.dark
tbF.BorderSizePixel  = 0

local tGrad = Instance.new("UIGradient", TB)
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(16, 16, 26)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(16, 16, 26)),
})

local tAcc = Instance.new("Frame", TB)
tAcc.Size             = UDim2.new(0, 3, 0.55, 0)
tAcc.Position         = UDim2.new(0, 0, 0.225, 0)
tAcc.BackgroundColor3 = P.acc
tAcc.BorderSizePixel  = 0
Instance.new("UICorner", tAcc).CornerRadius = UDim.new(0, 2)

local tIco = Instance.new("TextLabel", TB)
tIco.Size                 = UDim2.new(0, 32, 0, 32)
tIco.Position             = UDim2.new(0, 10, 0.5, -16)
tIco.BackgroundTransparency = 1
tIco.Text                 = "⚡"
tIco.TextSize             = 18
tIco.Font                 = Enum.Font.GothamBlack
tIco.TextColor3           = P.acc
tIco.ZIndex               = 3

local tTit = Instance.new("TextLabel", TB)
tTit.Size                 = UDim2.new(1, -90, 0, 18)
tTit.Position             = UDim2.new(0, 40, 0, 5)
tTit.BackgroundTransparency = 1
tTit.TextColor3           = P.wht
tTit.Font                 = Enum.Font.GothamBlack
tTit.TextSize             = 14
tTit.Text                 = "OMNI V300 MONSTER"
tTit.TextXAlignment       = Enum.TextXAlignment.Left
tTit.ZIndex               = 3

local tSub = Instance.new("TextLabel", TB)
tSub.Size                 = UDim2.new(1, -90, 0, 12)
tSub.Position             = UDim2.new(0, 40, 0, 24)
tSub.BackgroundTransparency = 1
tSub.TextColor3           = P.dim
tSub.Font                 = Enum.Font.Gotham
tSub.TextSize             = 9
tSub.Text                 = IsMob and "MOBILE · ANTI-BAN" or "UNIVERSAL · ANTI-BAN"
tSub.TextXAlignment       = Enum.TextXAlignment.Left
tSub.ZIndex               = 3

local clsB = Instance.new("TextButton", TB)
clsB.Size             = UDim2.new(0, 26, 0, 26)
clsB.Position         = UDim2.new(1, -32, 0.5, -13)
clsB.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
clsB.Text             = "✕"
clsB.TextColor3       = P.txt
clsB.Font             = Enum.Font.GothamBold
clsB.TextSize         = 11
clsB.BorderSizePixel  = 0
clsB.ZIndex           = 4
clsB.AutoButtonColor  = false
Instance.new("UICorner", clsB).CornerRadius = UDim.new(1, 0)

local function CloseMenu()
    TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size     = UDim2.new(0, MW, 0, 0),
        Position = UDim2.new(0.5, -MW/2, 0.5, 0),
    }):Play()
    task.delay(0.15, function() Main.Visible = false end)
end

local function OpenMenu()
    Main.Size     = UDim2.new(0, MW, 0, 0)
    Main.Position = UDim2.new(0.5, -MW/2, 0.5, 0)
    Main.Visible  = true
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size     = UDim2.new(0, MW, 0, MH),
        Position = UDim2.new(0.5, -MW/2, 0.5, -MH/2),
    }):Play()
end

clsB.MouseButton1Click:Connect(CloseMenu)

-- STATS BAR
local stB = Instance.new("Frame", Main)
stB.Size             = UDim2.new(1, -16, 0, 18)
stB.Position         = UDim2.new(0, 8, 0, 44)
stB.BackgroundColor3 = P.card
stB.BorderSizePixel  = 0
Instance.new("UICorner", stB).CornerRadius = UDim.new(0, 5)

local fpsL = Instance.new("TextLabel", stB)
fpsL.Size                 = UDim2.new(0.5, 0, 1, 0)
fpsL.BackgroundTransparency = 1
fpsL.TextColor3           = P.txt
fpsL.Font                 = Enum.Font.GothamBold
fpsL.TextSize             = 10
fpsL.Text                 = "FPS: ..."

local pngL = Instance.new("TextLabel", stB)
pngL.Size                 = UDim2.new(0.5, 0, 1, 0)
pngL.Position             = UDim2.new(0.5, 0, 0, 0)
pngL.BackgroundTransparency = 1
pngL.TextColor3           = P.txt
pngL.Font                 = Enum.Font.GothamBold
pngL.TextSize             = 10
pngL.Text                 = "Ping: ..."

-- TABS
local tabY  = 64
local tabFr = Instance.new("Frame", Main)
tabFr.Size             = UDim2.new(1, -12, 0, 30)
tabFr.Position         = UDim2.new(0, 6, 0, tabY)
tabFr.BackgroundColor3 = P.dark
tabFr.BorderSizePixel  = 0
Instance.new("UICorner", tabFr).CornerRadius = UDim.new(0, 6)

local tNames = {"Combat","Move","Misc","Config"}
local tIcons = {"⚔","🏃","🔧","⚙"}
local tW     = 1 / #tNames

local function SwitchTab(name)
    CurTab = name
    for n, pg in pairs(TabPages) do pg.Visible = (n == name) end
    for n, bt in pairs(TabBtns) do
        local a = (n == name)
        TweenService:Create(bt, TweenInfo.new(0.12), {
            BackgroundColor3       = a and P.tabA or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = a and 0 or 1,
        }):Play()
        bt.TextColor3 = a and P.acc or P.dim
    end
end

for i, n in ipairs(tNames) do
    local b = Instance.new("TextButton", tabFr)
    b.Size                   = UDim2.new(tW, -2, 1, -4)
    b.Position               = UDim2.new((i-1)*tW, 1, 0, 2)
    b.BackgroundColor3       = P.tabA
    b.BackgroundTransparency = i == 1 and 0 or 1
    b.Text                   = tIcons[i] .. " " .. n
    b.TextColor3             = i == 1 and P.acc or P.dim
    b.Font                   = Enum.Font.GothamBold
    b.TextSize               = IsMob and 11 or 9
    b.BorderSizePixel        = 0
    b.AutoButtonColor        = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function() SwitchTab(n) end)
    TabBtns[n] = b
end

-- CONTENT SCROLL AREA
local cY = tabY + 34
local cH = MH - cY - 4

for _, n in ipairs(tNames) do
    local s = Instance.new("ScrollingFrame", Main)
    s.Name                   = n
    s.Size                   = UDim2.new(1, -6, 0, cH)
    s.Position               = UDim2.new(0, 3, 0, cY)
    s.BackgroundTransparency = 1
    s.ScrollBarThickness     = IsMob and 4 or 3
    s.ScrollBarImageColor3   = Color3.fromRGB(100, 100, 120)
    s.BorderSizePixel        = 0
    s.CanvasSize             = UDim2.new(0, 0, 0, 0)
    s.ScrollingDirection     = Enum.ScrollingDirection.Y
    s.Visible                = (n == "Combat")
    s.ScrollingEnabled       = true
    s.ElasticBehavior        = Enum.ElasticBehavior.WhenScrollable
    local ly = Instance.new("UIListLayout", s)
    ly.Padding             = UDim.new(0, IsMob and 4 or 3)
    ly.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pd = Instance.new("UIPadding", s)
    pd.PaddingTop    = UDim.new(0, 4)
    pd.PaddingBottom = UDim.new(0, IsMob and 16 or 8)
    ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0, 0, 0, ly.AbsoluteContentSize.Y + 20)
    end)
    TabPages[n] = s
end

-- DRAGGABLE MAIN (тільки по title bar)
do
    local dr, ds, dp = false, nil, nil
    TB.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dr = true; ds = inp.Position; dp = Main.Position
        end
    end)
    TB.InputChanged:Connect(function(inp)
        if not dr then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
            local d   = inp.Position - ds
            local newX = dp.X.Offset + d.X
            local newY = dp.Y.Offset + d.Y
            local vp   = Camera.ViewportSize
            newX = math.clamp(newX, -MW/2, vp.X - MW/2)
            newY = math.clamp(newY, -MH/2, vp.Y - MH/2)
            Main.Position = UDim2.new(dp.X.Scale, newX, dp.Y.Scale, newY)
        end
    end)
    TB.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
end

-- EXT STATS PANEL (FPS/Ping)
local exS = Instance.new("Frame", Scr)
exS.Size                   = UDim2.new(0, 130, 0, 58)
exS.Position               = UDim2.new(1, -142, 0, 10)
exS.BackgroundColor3       = Color3.fromRGB(10, 10, 16)
exS.BackgroundTransparency = 0
exS.BorderSizePixel        = 0
exS.ZIndex                 = 20
Instance.new("UICorner", exS).CornerRadius = UDim.new(0, 10)
local exGrad = Instance.new("UIGradient", exS)
exGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16,16,28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,8,16)),
})
exGrad.Rotation = 135
local exStroke = Instance.new("UIStroke", exS)
exStroke.Color        = Color3.fromRGB(0, 200, 100)
exStroke.Thickness    = 1.5
exStroke.Transparency = 0.4

local function MkStat(parent, ico, lbl, zI)
    local row = Instance.new("Frame", parent)
    row.Size                 = UDim2.new(1, -16, 0, 22)
    row.BackgroundTransparency = 1
    row.ZIndex               = zI
    local iL = Instance.new("TextLabel", row)
    iL.Size = UDim2.new(0,18,1,0); iL.BackgroundTransparency=1; iL.Text=ico; iL.TextSize=12
    iL.Font=Enum.Font.Gotham; iL.ZIndex=zI+1; iL.TextColor3=Color3.fromRGB(100,200,255)
    local nL = Instance.new("TextLabel", row)
    nL.Size=UDim2.new(0,42,1,0); nL.Position=UDim2.new(0,20,0,0); nL.BackgroundTransparency=1
    nL.Text=lbl; nL.TextSize=10; nL.Font=Enum.Font.GothamBold
    nL.TextColor3=Color3.fromRGB(160,160,180); nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=zI+1
    local vL = Instance.new("TextLabel", row)
    vL.Size=UDim2.new(1,-64,1,0); vL.Position=UDim2.new(0,62,0,0); vL.BackgroundTransparency=1
    vL.Text="..."; vL.TextSize=12; vL.Font=Enum.Font.GothamBlack
    vL.TextColor3=Color3.fromRGB(130,255,170); vL.TextXAlignment=Enum.TextXAlignment.Right; vL.ZIndex=zI+1
    return row, vL
end

local exFpsRow, eF = MkStat(exS, "🖥", "FPS", 21)
exFpsRow.Position = UDim2.new(0, 8, 0, 6)
local exDiv = Instance.new("Frame", exS)
exDiv.Size=UDim2.new(1,-16,0,1); exDiv.Position=UDim2.new(0,8,0,31)
exDiv.BackgroundColor3=Color3.fromRGB(40,40,60); exDiv.BorderSizePixel=0; exDiv.ZIndex=21
local exPingRow, eP = MkStat(exS, "📶", "PING", 21)
exPingRow.Position = UDim2.new(0, 8, 0, 33)

-- Drag для stats panel
do
    local exDr, exDs, exDp = false, nil, nil
    exS.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            exDr = true; exDs = inp.Position; exDp = exS.Position
        end
    end)
    exS.InputChanged:Connect(function(inp)
        if not exDr then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
            local d    = inp.Position - exDs
            local newX = exDp.X.Offset + d.X
            local newY = exDp.Y.Offset + d.Y
            local vp   = Camera.ViewportSize
            newX = math.clamp(newX, 0, vp.X - 130)
            newY = math.clamp(newY, 0, vp.Y - 58)
            exS.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    exS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            exDr = false
        end
    end)
end

-- M BUTTON
local mB = Instance.new("TextButton", Scr)
mB.Size             = UDim2.new(0, MBS, 0, MBS)
mB.Position         = UDim2.new(0, 10, 0.5, -MBS/2)
mB.BackgroundColor3 = P.bg
mB.Text             = "M"
mB.TextColor3       = P.acc
mB.Font             = Enum.Font.GothamBlack
mB.TextSize         = IsMob and 22 or 18
mB.ZIndex           = 100
mB.AutoButtonColor  = false
Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 12)
local mSt = Instance.new("UIStroke", mB)
mSt.Thickness = 2; mSt.Color = P.acc

local mCnt = Instance.new("TextLabel", mB)
mCnt.Size=UDim2.new(1,0,0,12); mCnt.Position=UDim2.new(0,0,1,-13)
mCnt.BackgroundTransparency=1; mCnt.TextSize=8; mCnt.Font=Enum.Font.GothamBold
mCnt.TextColor3=P.grn; mCnt.ZIndex=101; mCnt.Text=""

task.spawn(function()
    while task.wait(0.6) do
        local c = 0
        for _, v in pairs(State) do if v then c += 1 end end
        mCnt.Text = c > 0 and ("●"..c) or ""
    end
end)

-- M Button drag+tap
do
    local dr, ds, dp, mv, mt = false, nil, nil, false, 0
    mB.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dr=true; ds=inp.Position; dp=mB.Position; mv=false; mt=tick()
        end
    end)
    mB.InputChanged:Connect(function(inp)
        if not dr then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - ds
            if d.Magnitude > 8 then mv = true end
            mB.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
        end
    end)
    mB.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            if dr and not mv and (tick()-mt) < 0.35 then
                if Main.Visible then CloseMenu() else OpenMenu() end
            end
            dr = false
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dr = false
        end
    end)
end

-- FLY BUTTONS (мобіл)
local flyH = Instance.new("Frame", Scr)
flyH.Size                   = UDim2.new(0, 140, 0, 64)
flyH.Position               = UDim2.new(1, -154, 1, -160)
flyH.BackgroundTransparency = 1
flyH.Visible                = false
flyH.ZIndex                 = 50

local flyBG = Instance.new("Frame", flyH)
flyBG.Size                   = UDim2.new(1, 0, 1, 0)
flyBG.BackgroundColor3       = Color3.fromRGB(8, 8, 14)
flyBG.BackgroundTransparency = 0.3
flyBG.BorderSizePixel        = 0
flyBG.ZIndex                 = 49
Instance.new("UICorner", flyBG).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", flyBG).Color        = P.brd

local function MkFlyB(t, x, cb)
    local b = Instance.new("TextButton", flyH)
    b.Size=UDim2.new(0,62,0,58); b.Position=UDim2.new(0,x,0,3)
    b.BackgroundColor3=P.btn; b.Text=t; b.TextColor3=P.wht
    b.Font=Enum.Font.GothamBlack; b.TextSize=28; b.BorderSizePixel=0; b.ZIndex=51; b.AutoButtonColor=false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", b).Color        = P.acc
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            cb(true); TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=P.tabA}):Play()
        end
    end)
    b.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            cb(false); TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=P.btn}):Play()
        end
    end)
    -- Слідкуємо за виходом пальця за межі
    b.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then
            local abs=b.AbsolutePosition; local sz=b.AbsoluteSize
            local px=i.Position.X; local py=i.Position.Y
            if px<abs.X or px>abs.X+sz.X or py<abs.Y or py>abs.Y+sz.Y then
                cb(false); TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=P.btn}):Play()
            end
        end
    end)
end

MkFlyB("▲", 4,  function(v) MobUp = v end)
MkFlyB("▼", 72, function(v) MobDn = v end)

local function UpdFly() flyH.Visible = State.Fly and IsTab end

-- Freecam touch zone
local fcZ = Instance.new("TextButton", Scr)
fcZ.Size=UDim2.new(0.5,0,1,-100); fcZ.Position=UDim2.new(0.5,0,0,0)
fcZ.BackgroundTransparency=1; fcZ.Text=""; fcZ.ZIndex=5; fcZ.Visible=false
local fcL = nil
fcZ.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then fcL=i.Position end
end)
fcZ.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch and fcL then
        local d=i.Position-fcL
        FC_Y=FC_Y-math.rad(d.X*0.4)
        FC_P=math.clamp(FC_P-math.rad(d.Y*0.4),-math.rad(89),math.rad(89))
        fcL=i.Position
    end
end)
fcZ.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch then fcL=nil end
end)

-- DIRECTION HELPER
local function GetDir()
    local mx, mz = 0, 0
    if not IsMob then
        if UIS:IsKeyDown(Enum.KeyCode.W) then mz = -1 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mz =  1 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mx = -1 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mx =  1 end
    elseif ControlsOK and Controls then
        local ok, mv = pcall(function() return Controls:GetMoveVector() end)
        if ok and mv then mx = mv.X; mz = mv.Z end
    end
    return mx, mz
end

-- ============================================================
-- UI BUILDERS
-- ============================================================
local function AddHdr(tab, icon, text)
    local pg = TabPages[tab]; if not pg then return end
    local f  = Instance.new("Frame", pg)
    f.Size=UDim2.new(0.95,0,0,IsMob and 22 or 18); f.BackgroundColor3=P.dark; f.BorderSizePixel=0
    Instance.new("UICorner", f).CornerRadius=UDim.new(0,5)
    local l = Instance.new("TextLabel", f)
    l.Size=UDim2.new(1,-8,1,0); l.Position=UDim2.new(0,8,0,0); l.BackgroundTransparency=1
    l.TextColor3=P.dim; l.Font=Enum.Font.GothamBold; l.TextSize=IsMob and 10 or 9
    l.Text=icon.."  "..text; l.TextXAlignment=Enum.TextXAlignment.Left
end

local function MkToggle(tab, icon, text, logicName)
    local pg = TabPages[tab]; if not pg then return end
    local row = Instance.new("TextButton", pg)
    row.Size=UDim2.new(0.95,0,0,BH); row.BackgroundColor3=P.btn
    row.BorderSizePixel=0; row.AutoButtonColor=false; row.Text=""; row.ClipsDescendants=true
    Instance.new("UICorner", row).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke", row).Color=P.brd

    local accent = Instance.new("Frame", row)
    accent.Size=UDim2.new(0,3,0.55,0); accent.Position=UDim2.new(0,0,0.225,0)
    accent.BackgroundColor3=Color3.fromRGB(60,60,75); accent.BorderSizePixel=0
    Instance.new("UICorner", accent).CornerRadius=UDim.new(0,2)

    local ic = Instance.new("TextLabel", row)
    ic.Size=UDim2.new(0,24,1,0); ic.Position=UDim2.new(0,8,0,0); ic.BackgroundTransparency=1
    ic.Text=icon; ic.TextSize=IsMob and 15 or 13; ic.Font=Enum.Font.Gotham; ic.TextColor3=P.dim

    local lbl = Instance.new("TextLabel", row)
    lbl.Size=UDim2.new(1,-80,1,0); lbl.Position=UDim2.new(0,36,0,0); lbl.BackgroundTransparency=1
    lbl.Text=text; lbl.TextColor3=P.txt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=FS
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local swBG = Instance.new("Frame", row)
    swBG.Size=UDim2.new(0,IsMob and 42 or 36,0,IsMob and 22 or 18)
    swBG.Position=UDim2.new(1,IsMob and -50 or -44,0.5,IsMob and -11 or -9)
    swBG.BackgroundColor3=P.swOff; swBG.BorderSizePixel=0
    Instance.new("UICorner", swBG).CornerRadius=UDim.new(1,0)

    local swDot = Instance.new("Frame", swBG)
    local dotS  = IsMob and 16 or 12
    swDot.Size=UDim2.new(0,dotS,0,dotS); swDot.Position=UDim2.new(0,3,0.5,-dotS/2)
    swDot.BackgroundColor3=P.wht; swDot.BorderSizePixel=0
    Instance.new("UICorner", swDot).CornerRadius=UDim.new(1,0)

    row.MouseButton1Click:Connect(function()
        if waitingBind then return end
        Toggle(logicName)
        if logicName == "Fly"     then UpdFly() end
        if logicName == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
    end)

    AllRows[logicName] = {swBG=swBG, swDot=swDot, accent=accent, row=row}
    return row
end

local function MkToggleBind(tab, icon, text, logicName)
    local row = MkToggle(tab, icon, text, logicName)
    if not row then return end
    local bindBtn = Instance.new("TextButton", row)
    bindBtn.Size=UDim2.new(0,42,0,IsMob and 22 or 18)
    bindBtn.Position=UDim2.new(1,IsMob and -98 or -90,0.5,IsMob and -11 or -9)
    bindBtn.BackgroundColor3=P.dark; bindBtn.BorderSizePixel=0
    bindBtn.Text=tostring(Binds[logicName] or ""):gsub("Enum.KeyCode.","")
    bindBtn.TextColor3=P.dim; bindBtn.Font=Enum.Font.GothamBold; bindBtn.TextSize=9
    bindBtn.AutoButtonColor=false
    Instance.new("UICorner", bindBtn).CornerRadius=UDim.new(0,5)
    bindBtn.MouseButton1Click:Connect(function()
        if waitingBind then return end
        waitingBind = logicName
        bindBtn.Text="?"; bindBtn.TextColor3=P.grn
    end)
    AllRows[logicName].bindBtn = bindBtn
end

-- SLIDER
local function MkSlider(tab, icon, text, minV, maxV, def, onChange)
    local pg = TabPages[tab]; if not pg then return end
    local h  = IsMob and 56 or 48
    local row = Instance.new("Frame", pg)
    row.Size=UDim2.new(0.95,0,0,h); row.BackgroundColor3=P.btn; row.BorderSizePixel=0
    Instance.new("UICorner", row).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke", row).Color=P.brd

    local ic=Instance.new("TextLabel",row); ic.Size=UDim2.new(0,22,0,20); ic.Position=UDim2.new(0,6,0,4)
    ic.BackgroundTransparency=1; ic.Text=icon; ic.TextSize=IsMob and 14 or 12
    ic.Font=Enum.Font.Gotham; ic.TextColor3=P.dim

    local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(1,-80,0,18); tl.Position=UDim2.new(0,28,0,3)
    tl.BackgroundTransparency=1; tl.Text=text; tl.Font=Enum.Font.GothamBold; tl.TextSize=FS
    tl.TextColor3=P.txt; tl.TextXAlignment=Enum.TextXAlignment.Left

    local vl=Instance.new("TextLabel",row); vl.Size=UDim2.new(0,50,0,18); vl.Position=UDim2.new(1,-54,0,3)
    vl.BackgroundTransparency=1; vl.Text=tostring(def); vl.Font=Enum.Font.GothamBold; vl.TextSize=FS
    vl.TextColor3=P.grn; vl.TextXAlignment=Enum.TextXAlignment.Right

    local trk=Instance.new("Frame",row); trk.Size=UDim2.new(1,-16,0,6); trk.Position=UDim2.new(0,8,0,h-16)
    trk.BackgroundColor3=P.dark; trk.BorderSizePixel=0
    Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",trk); fill.Size=UDim2.new((def-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3=P.acc; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local dot=Instance.new("Frame",trk)
    dot.Size=UDim2.new(0,14,0,14); dot.AnchorPoint=Vector2.new(0.5,0.5)
    dot.Position=UDim2.new((def-minV)/(maxV-minV),0,0.5,0)
    dot.BackgroundColor3=P.wht; dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local cur = def
    local dragging = false

    local function Upd(inp)
        local abs = trk.AbsolutePosition
        local sz  = trk.AbsoluteSize
        local t   = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
        cur = math.floor(minV + t * (maxV - minV))
        fill.Size     = UDim2.new(t, 0, 1, 0)
        dot.Position  = UDim2.new(t, 0, 0.5, 0)
        vl.Text       = tostring(cur)
        if onChange then pcall(onChange, cur) end
    end

    trk.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            pg.ScrollingEnabled = false
            Upd(inp)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
            Upd(inp)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then dragging=false; pg.ScrollingEnabled=true end
        end
    end)
end

-- ============================================================
-- POPULATE TABS
-- ============================================================
AddHdr("Combat","🎯","AIMING")
MkToggleBind("Combat","🎯","Auto Aim","Aim")
MkToggleBind("Combat","🔇","Silent Aim","SilentAim")
MkToggle("Combat","🧲","Magnet (ShadowLock)","ShadowLock")
AddHdr("Combat","💥","HITBOX & ESP")
MkToggle("Combat","📦","Hitbox Expand","Hitbox")
MkToggle("Combat","👁","ESP","ESP")

AddHdr("Move","✈️","FLIGHT")
MkToggleBind("Move","✈️","Fly","Fly")
MkToggle("Move","📷","Freecam","Freecam")
AddHdr("Move","🏃","SPEED & JUMP")
MkToggle("Move","👟","Speed","Speed")
MkToggle("Move","🐇","Bhop","Bhop")
MkToggle("Move","⬆️","High Jump","HighJump")
MkToggle("Move","♾️","Infinite Jump","InfiniteJump")
AddHdr("Move","👻","PHYSICS")
MkToggleBind("Move","👻","Noclip","Noclip")
MkToggle("Move","🛡","No Fall Damage","NoFallDamage")

AddHdr("Misc","🔧","EFFECTS")
MkToggle("Misc","🌀","Spin","Spin")
MkToggle("Misc","🥔","Potato Mode","Potato")
MkToggle("Misc","📡","Fake Lag","FakeLag")
AddHdr("Misc","🛡","PROTECTION")
MkToggle("Misc","💤","Anti-AFK","AntiAFK")
MkToggle("Misc","🚫","Anti-Kick","AntiKick")

AddHdr("Config","🚀","SPEED VALUES")
MkSlider("Config","✈️","Fly Speed",0,300,Config.FlySpeed,function(v) Config.FlySpeed=v end)
MkSlider("Config","👟","Walk Speed",16,200,Config.WalkSpeed,function(v)
    Config.WalkSpeed=v
    local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if State.Speed and h then pcall(function() h.WalkSpeed=GetSafeSpeed() end) end
end)
AddHdr("Config","⬆️","JUMP VALUES")
MkSlider("Config","⬆️","Jump Power",50,500,Config.JumpPower,function(v)
    Config.JumpPower=v
    local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if State.HighJump and h then
        pcall(function() h.UseJumpPower=true; h.JumpPower=v; h.JumpHeight=v*0.14 end)
    end
end)
MkSlider("Config","🐇","Bhop Power",20,150,Config.BhopPower,function(v) Config.BhopPower=v end)
AddHdr("Config","📦","HITBOX")
MkSlider("Config","📦","Hitbox Size",2,15,Config.HitboxSize,function(v) Config.HitboxSize=v end)
AddHdr("Config","🎯","AIM SETTINGS")
MkSlider("Config","⭕","Aim FOV (px)",50,500,Config.AimFOV,function(v)
    Config.AimFOV=v; UpdateFOVCircle()
end)
MkSlider("Config","🎚","Aim Smooth %",5,100,math.floor(Config.AimSmooth*100),function(v)
    Config.AimSmooth=v/100
end)
AddHdr("Config","🛡","ANTI-BAN")
MkToggle("Config","🎲","Speed Jitter","SpeedAntiBan") -- додаємо до State
MkToggle("Config","📦","Hitbox Randomize","HitboxRandomize")
MkToggle("Config","🎯","Aim Anti-Detect","AimAntiDetect")

-- Додаємо нові ключі до State
State.SpeedAntiBan    = Config.SpeedAntiBan
State.HitboxRandomize = Config.HitboxRandomize
State.AimAntiDetect   = Config.AimAntiDetect

-- Підключаємо toggle для конфіг-стейтів
do
    local orig = Toggle
    Toggle = function(nm)
        if nm == "SpeedAntiBan" then
            Config.SpeedAntiBan = not Config.SpeedAntiBan
            State.SpeedAntiBan  = Config.SpeedAntiBan
            UpdVis(nm)
            Notify(nm, Config.SpeedAntiBan and "ON ✓" or "OFF ✗", 1)
            return
        end
        if nm == "HitboxRandomize" then
            Config.HitboxRandomize = not Config.HitboxRandomize
            State.HitboxRandomize  = Config.HitboxRandomize
            UpdVis(nm)
            Notify(nm, Config.HitboxRandomize and "ON ✓" or "OFF ✗", 1)
            return
        end
        if nm == "AimAntiDetect" then
            Config.AimAntiDetect = not Config.AimAntiDetect
            State.AimAntiDetect  = Config.AimAntiDetect
            UpdVis(nm)
            Notify(nm, Config.AimAntiDetect and "ON ✓" or "OFF ✗", 1)
            return
        end
        orig(nm)
    end
end

-- ============================================================
-- KEYBIND HANDLER
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
    if waitingBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local key = inp.KeyCode
            local nm  = waitingBind
            Binds[nm] = key
            local d   = AllRows[nm]
            if d and d.bindBtn then
                d.bindBtn.Text       = tostring(key):gsub("Enum.KeyCode.","")
                d.bindBtn.TextColor3 = P.dim
            end
            Notify("BIND", nm.." → "..tostring(key):gsub("Enum.KeyCode.",""), 2)
            waitingBind = nil
        end
        return
    end
    if gpe then return end
    for act, key in pairs(Binds) do
        if inp.KeyCode == key then
            if act == "ToggleMenu" then
                if Main.Visible then CloseMenu() else OpenMenu() end
            else
                Toggle(act)
                if act == "Fly"     then UpdFly() end
                if act == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
            end
        end
    end
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UIS.JumpRequest:Connect(function()
    if not State.InfiniteJump then return end
    local C = LP.Character
    local H = C and C:FindFirstChildOfClass("Humanoid")
    local R = C and C:FindFirstChild("HumanoidRootPart")
    if not H or not R or H.Health <= 0 or State.Fly or State.Freecam then return end
    pcall(function()
        H:ChangeState(Enum.HumanoidStateType.Jumping)
        local pw = State.HighJump and Config.JumpPower or 50
        local v  = R.AssemblyLinearVelocity
        R.AssemblyLinearVelocity = Vector3.new(v.X, math.max(pw*0.82, 42)+math.random(-2,2), v.Z)
    end)
end)

-- ============================================================
-- SHIFT LOCK / MOUSE FIX
-- ============================================================
do
    -- Захист MouseBehavior коли Freecam активний
    if ENV.hasGetRawMeta and ENV.hasSetReadOnly then
        pcall(function()
            local mt = getrawmetatable(UIS)
            if mt then
                local oldNI = rawget(mt, "__newindex")
                setreadonly(mt, false)
                mt.__newindex = newcclosure(function(self, key, value)
                    if key == "MouseBehavior" and State.Freecam then
                        return -- блокуємо зміну поведінки миші під час Freecam
                    end
                    if oldNI then
                        return oldNI(self, key, value)
                    else
                        rawset(self, key, value)
                    end
                end)
                setreadonly(mt, true)
            end
        end)
    end
end

-- ============================================================
-- ANIMATION LOOP
-- ============================================================
task.spawn(function()
    local t = 0
    while true do
        task.wait(0.033); t += 0.02
        local pulse = (math.sin(t*2)+1)/2
        local aR = math.floor(0   + pulse*15)
        local aG = math.floor(180 + pulse*30)
        local aB = math.floor(95  + pulse*20)
        local acol = Color3.fromRGB(aR, aG, aB)

        pcall(function()
            mSt.Color             = acol
            mB.TextColor3         = acol
            tGrad.Rotation        = (t*15) % 360
            tAcc.BackgroundColor3 = acol
            tIco.TextColor3       = acol
            exStroke.Color        = acol
            mainS.Color = Color3.fromRGB(
                math.floor(38+pulse*20), math.floor(38+pulse*20), math.floor(48+pulse*20)
            )
            for nm, d in pairs(AllRows) do
                if State[nm] and d.accent then
                    d.accent.BackgroundColor3 = acol
                end
            end
            if State.Aim or State.SilentAim then
                if not (aimLocked and aimTarget) then
                    fovStroke.Color = Color3.fromRGB(180,180,200)
                end
            end
        end)
    end
end)

-- ============================================================
-- RENDER STEPPED (FPS / Ping / Aim / Fly / Freecam)
-- ============================================================
RunService.RenderStepped:Connect(function(dt)
    local now = tick()
    table.insert(FrameLog, now)
    while FrameLog[1] and FrameLog[1] < now - 1 do table.remove(FrameLog, 1) end
    local fps = #FrameLog

    if now - pingTk > 2 then
        pingTk = now
        pcall(function() lastPing = LP:GetNetworkPing() end)
    end
    local pm = math.floor(lastPing * 1000)

    local fc = fps>=55 and Color3.fromRGB(130,255,170) or fps>=30 and Color3.fromRGB(255,220,80) or Color3.fromRGB(255,90,90)
    local pc = pm<=80 and Color3.fromRGB(130,255,170) or pm<=150 and Color3.fromRGB(255,220,80) or Color3.fromRGB(255,90,90)

    fpsL.Text = "FPS: "..fps;           fpsL.TextColor3 = fc
    pngL.Text = "Ping: "..pm.."ms";     pngL.TextColor3 = pc
    eF.Text   = tostring(fps);          eF.TextColor3   = fc
    eP.Text   = pm.." ms";             eP.TextColor3   = pc

    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

    local showFOV = (State.Aim or State.SilentAim) and not State.Freecam
    fovCircle.Visible = showFOV
    tgtInfo.Visible   = false

    -- FLY
    if State.Fly and not State.Freecam and HRP and Hum then
        pcall(function()
            Hum.PlatformStand = false
            local mx, mz = GetDir()
            local camCF  = Camera.CFrame
            local dir    = camCF.LookVector * -mz + camCF.RightVector * mx
            local upD    = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space)       or MobUp then upD =  1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD = -1 end
            dir = dir + Vector3.new(0, upD, 0)
            if dir.Magnitude > 1 then dir = dir.Unit end

            -- Обмеження висоти (анти-бан)
            local curY = HRP.Position.Y
            if curY > Config.FlyHeightMax then
                HRP.CFrame -= Vector3.new(0, 3, 0)
            end

            -- Емуляція "природного" руху при польоті
            if Config.FlyAntiBan then
                local jitter = Vector3.new(
                    (math.random()-0.5)*0.08,
                    (math.random()-0.5)*0.04,
                    (math.random()-0.5)*0.08
                )
                HRP.CFrame += (dir * Config.FlySpeed + jitter) * dt
            else
                HRP.CFrame += dir * Config.FlySpeed * dt
            end

            HRP.AssemblyLinearVelocity = Vector3.zero
            if not State.Spin then HRP.AssemblyAngularVelocity = Vector3.zero end
        end)
    end

    -- FREECAM
    if State.Freecam then
        pcall(function()
            local mx, mz = GetDir()
            local dir = Camera.CFrame.LookVector * -mz + Camera.CFrame.RightVector * mx
            if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp then
                dir += Camera.CFrame.UpVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then
                dir -= Camera.CFrame.UpVector
            end
            if dir.Magnitude > 1 then dir = dir.Unit end
            Camera.CFrame = CFrame.new(Camera.CFrame.Position + dir*(Config.FlySpeed/25)*dt*60)
                * CFrame.fromEulerAnglesYXZ(FC_P, FC_Y, 0)
        end)
    end

    -- AUTO AIM
    if State.Aim and not State.Freecam and Char and HRP then
        pcall(function()
            local target = GetBestAimTarget()
            local part   = target and FindAimPart(target)
            if part then
                local predTime     = math.clamp(lastPing, 0.01, 0.25)
                local vel          = part.AssemblyLinearVelocity
                local dist         = (Camera.CFrame.Position - part.Position).Magnitude
                local predMul      = math.clamp(dist/100, 0.3, 1.5)
                local predictedPos = part.Position + vel*predTime*predMul
                if vel.Y < -5 then
                    predictedPos += Vector3.new(0, -4.9*predTime*predTime, 0)
                end

                local smooth = Config.AimSmooth
                local sd     = ScreenDist(part)
                if sd < 30 then smooth = smooth*0.3
                elseif sd < 80 then smooth = smooth*0.6 end

                -- Анти-детект: мікро-шум щоб aim виглядав людяно
                if Config.AimAntiDetect then
                    local noise = Vector3.new(
                        (math.random()-0.5)*0.12,
                        (math.random()-0.5)*0.08,
                        (math.random()-0.5)*0.12
                    )
                    predictedPos += noise
                end

                local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                Camera.CFrame  = Camera.CFrame:Lerp(targetCF, smooth)

                local plr   = Players:GetPlayerFromCharacter(target)
                local dist2 = math.floor(dist)
                tgtInfo.Text       = "🔒 "..(plr and plr.Name or "?").." ["..dist2.."m]"
                tgtInfo.TextColor3 = Color3.fromRGB(0,230,120)
                tgtInfo.Visible    = true
                fovStroke.Color    = Color3.fromRGB(0,230,100)
                fovStroke.Thickness = 2
            else
                if showFOV then
                    tgtInfo.Text       = "No target"
                    tgtInfo.TextColor3 = P.dim
                    tgtInfo.Visible    = true
                end
                fovStroke.Color     = Color3.fromRGB(180,180,200)
                fovStroke.Thickness = 1.5
            end
        end)
    end

    -- SILENT AIM VISUAL
    if State.SilentAim and not State.Aim and not State.Freecam then
        pcall(function()
            local tgt  = GetBestAimTarget()
            local part = tgt and FindAimPart(tgt)
            if part then
                local plr  = Players:GetPlayerFromCharacter(tgt)
                local dist = math.floor((Camera.CFrame.Position-part.Position).Magnitude)
                tgtInfo.Text       = "🔇 "..(plr and plr.Name or "?").." ["..dist.."m]"
                tgtInfo.TextColor3 = Color3.fromRGB(255,200,50)
                tgtInfo.Visible    = true
                fovStroke.Color    = Color3.fromRGB(255,200,50)
            else
                if showFOV then
                    tgtInfo.Text       = "No target"
                    tgtInfo.TextColor3 = P.dim
                    tgtInfo.Visible    = true
                end
                fovStroke.Color = Color3.fromRGB(180,180,200)
            end
        end)
    end
end)

-- Freecam mouse rotation
UIS.InputChanged:Connect(function(inp, gpe)
    if gpe or not State.Freecam then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            FC_Y = FC_Y - math.rad(inp.Delta.X * 0.35)
            FC_P = math.clamp(FC_P - math.rad(inp.Delta.Y * 0.35), -math.rad(89), math.rad(89))
        end
    end
end)

-- ============================================================
-- HEARTBEAT (Speed / HighJump / Bhop / NoFallDmg / ShadowLock)
-- ============================================================
RunService.Heartbeat:Connect(function(dt)
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum or Hum.Health <= 0 then return end

    -- SHADOW LOCK (Magnet)
    if State.ShadowLock then
        if not IsAlive(LockedTarget) then LockedTarget = GetClosestDist() end
        if LockedTarget then
            local tR = LockedTarget:FindFirstChild("HumanoidRootPart")
            if tR then
                pcall(function()
                    local pr = tR.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.2)
                    HRP.CFrame = HRP.CFrame:Lerp(
                        CFrame.new(tR.Position + pr) * tR.CFrame.Rotation * CFrame.new(0,0,3),
                        0.4
                    )
                    HRP.AssemblyLinearVelocity = tR.AssemblyLinearVelocity
                end)
            end
        end
    end

    -- SPEED (з антибан-рандомізацією)
    if State.Speed and not State.Fly and not State.Freecam then
        pcall(function()
            local safeSpd = GetSafeSpeed()
            Hum.WalkSpeed = safeSpd
            local now = tick()
            if now - lastSpCk > 0.4 then
                lastSpCk = now
                task.delay(0.08, function()
                    if Hum and Hum.Parent then
                        spReset = math.abs(Hum.WalkSpeed - safeSpd) > 4
                    end
                end)
            end
            if spReset and Hum.MoveDirection.Magnitude > 0.1 then
                local speed = Config.WalkSpeed
                HRP.CFrame += Hum.MoveDirection.Unit * (speed - math.max(Hum.WalkSpeed, 16)) * dt
                local vel  = HRP.AssemblyLinearVelocity
                local hs   = Vector3.new(vel.X, 0, vel.Z).Magnitude
                if hs < speed * 0.7 then
                    local pv = Hum.MoveDirection.Unit * speed
                    HRP.AssemblyLinearVelocity = Vector3.new(pv.X, vel.Y, pv.Z)
                end
            end
        end)
    end

    -- HIGH JUMP
    if State.HighJump and not State.Fly then
        pcall(function()
            Hum.UseJumpPower = true
            Hum.JumpPower    = Config.JumpPower
            pcall(function() Hum.JumpHeight = Config.JumpPower * 0.14 end)
            if math.abs(Hum.JumpPower - Config.JumpPower) > 8 then
                local st = Hum:GetState()
                if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then
                    local v  = HRP.AssemblyLinearVelocity
                    local tY = Config.JumpPower * 0.82
                    if v.Y > 0 and v.Y < tY then
                        HRP.AssemblyLinearVelocity = Vector3.new(v.X, tY, v.Z)
                    end
                end
            end
        end)
    end

    -- BHOP
    if State.Bhop and not State.Fly and not State.Freecam then
        pcall(function()
            if Hum.MoveDirection.Magnitude > 0.1 then
                local now = tick()
                if Hum.FloorMaterial ~= Enum.Material.Air and now - lastBhop > 0.06 then
                    Hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    local v  = HRP.AssemblyLinearVelocity
                    local md = Hum.MoveDirection.Unit
                    HRP.AssemblyLinearVelocity = Vector3.new(
                        v.X + md.X*(4+math.random()*3),
                        Config.BhopPower + math.random(-6,6),
                        v.Z + md.Z*(4+math.random()*3)
                    )
                    lastBhop = now
                end
            end
        end)
    end

    -- NO FALL DAMAGE
    if State.NoFallDamage then
        pcall(function()
            if Hum:GetState() == Enum.HumanoidStateType.Freefall
                and HRP.AssemblyLinearVelocity.Y < -28 then
                Hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                HRP.AssemblyLinearVelocity = Vector3.new(
                    HRP.AssemblyLinearVelocity.X, -4, HRP.AssemblyLinearVelocity.Z
                )
            end
        end)
    end
end)

-- ============================================================
-- STEPPED — NOCLIP (більш надійний)
-- ============================================================
RunService.Stepped:Connect(function()
    local Char = LP.Character
    local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

    if State.Noclip and Char and HRP and Hum then
        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.CollisionGroup = SafeGroup
                    v.CanCollide     = false
                end)
            end
        end
        local moving = Hum.MoveDirection.Magnitude > 0.05 or HRP.AssemblyLinearVelocity.Magnitude > 5
        local delta  = (HRP.Position - lastNcPos).Magnitude
        if moving and delta < 0.06 then
            ncStuck += 1
        else
            ncStuck = 0
        end
        if ncStuck >= 3 then
            local md = Hum.MoveDirection.Magnitude > 0.05
                and Hum.MoveDirection.Unit
                or HRP.CFrame.LookVector
            ncRay.FilterDescendantsInstances = {Char}
            local ok, r = pcall(function()
                return Workspace:Raycast(HRP.Position, md*8, ncRay)
            end)
            if ok and r then
                HRP.CFrame += md*(r.Distance+2.5)
            else
                HRP.CFrame += md*0.6 + Vector3.new(0,0.15,0)
            end
            if ncStuck >= 6 then
                HRP.AssemblyLinearVelocity = Vector3.new(
                    md.X*18, HRP.AssemblyLinearVelocity.Y+3, md.Z*18
                )
                ncStuck = 0
            end
        end
        lastNcPos = HRP.Position
    elseif Char and HRP then
        lastNcPos = HRP.Position
        ncStuck   = 0
    end
end)

-- ============================================================
-- ФІНАЛЬНЕ ПОВІДОМЛЕННЯ
-- ============================================================
Notify("OMNI V300 MONSTER", "✅ Anti-Ban · Anti-Kick · Universal · All fixes applied", 6)

--[[
ЗМІНИ V300 MONSTER:
✅ Виправлено: всі pcall захисти навколо критичних операцій
✅ Виправлено: toggle для Config-параметрів (SpeedAntiBan, HitboxRandomize, AimAntiDetect)
✅ Виправлено: drag для stats panel (правильні межі екрану)
✅ Виправлено: MkStat переписана (не дублювала код)
✅ Виправлено: noclip raycast тепер захищений pcall
✅ Нові anti-ban функції:
   - SpeedAntiBan: рандомний jitter до WalkSpeed
   - FlyAntiBan: мікро-шум при польоті
   - HitboxRandomize: ±0.2 варіація hitbox розміру
   - AimAntiDetect: мікро-шум до predicted position
   - FlyHeightMax: обмеження висоти польоту
✅ Anti-Kick посилений:
   - Блокує Kick через метатаблицю (game + char)
   - Блокує FireServer з "kick"/"ban"/"report"
   - Блокує InvokeServer з kick-аргументами
   - hookfunction fallback якщо доступно
   - CharacterRemoving fallback respawn
✅ Anti-AFK: рандомний інтервал 50-60 сек
✅ Collision group рандомний суфікс (анти-детект по імені)
✅ Всі RunService callbacks захищені від помилок
]]