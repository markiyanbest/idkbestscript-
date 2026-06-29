-- ██████████████████████████████████████████████████████████
-- ██  OMNI V305 — ANTI-CHEAT BYPASS EDITION (UA)           ██
-- ██  Обходи: Da Hood, HUD, та інших плейсів               ██
-- ██  Universal Noclip, Speed, Fly, Hitbox bypasses       ██
-- ██████████████████████████████████████████████████████████

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local PhysicsService    = game:GetService("PhysicsService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats             = game:GetService("Stats")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- ВИЗНАЧЕННЯ ПЛЕЙСУ ТА АНТИЧІТУ
-- ============================================================
local PlaceInfo = {
    Name = "",
    PlaceId = game.PlaceId,
    DetectedAntiCheat = "none",
    HasVelocityCheck = false,
    HasPositionCheck = false,
    HasStateCheck = false,
    HasRemoteCheck = false,
    HasWalkSpeedCap = false,
    HasJumpPowerCap = false,
    HasNoclipDetection = false,
    HasFlyDetection = false,
    HasHitboxValidation = false,
}

local function DetectPlace()
    local placeId = game.PlaceId
    local placeName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
    PlaceInfo.Name = placeName
    
    -- Da Hood / Da Hood Courts
    if placeId == 2753915549 or placeId == 5608757539 or placeId == 6195473454 then
        PlaceInfo.DetectedAntiCheat = "dahood"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasPositionCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        PlaceInfo.HasJumpPowerCap = true
        PlaceInfo.HasNoclipDetection = true
        PlaceInfo.HasFlyDetection = true
        PlaceInfo.HasRemoteCheck = true
        return
    end
    
    -- Hood Customs / Hood Modded
    if placeId == 5608757539 or placeId == 7213786345 or placeId == 8827167950 then
        PlaceInfo.DetectedAntiCheat = "hoodcustoms"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasPositionCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        PlaceInfo.HasNoclipDetection = true
        return
    end
    
    -- Arsenal
    if placeId == 286090429 then
        PlaceInfo.DetectedAntiCheat = "arsenal"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasPositionCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        return
    end
    
    -- Phantom Forces
    if placeId == 11501128331 or placeId == 292439477 then
        PlaceInfo.DetectedAntiCheat = "phantomforces"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        PlaceInfo.HasNoclipDetection = true
        return
    end
    
    -- Bad Business
    if placeId == 331744221 or placeId == 333665177 then
        PlaceInfo.DetectedAntiCheat = "badbusiness"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        PlaceInfo.HasNoclipDetection = true
        PlaceInfo.HasFlyDetection = true
        return
    end
    
    -- Big Paintball
    if placeId == 2879342366 then
        PlaceInfo.DetectedAntiCheat = "bigpaintball"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        return
    end
    
    -- Blade Ball
    if placeId == 13772392625 then
        PlaceInfo.DetectedAntiCheat = "bladeball"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasPositionCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        PlaceInfo.HasNoclipDetection = true
        return
    end
    
    -- Murder Mystery 2
    if placeId == 142823291 then
        PlaceInfo.DetectedAntiCheat = "mm2"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        return
    end
    
    -- Tower of Hell
    if placeId == 1962086868 then
        PlaceInfo.DetectedAntiCheat = "toh"
        PlaceInfo.HasPositionCheck = true
        PlaceInfo.HasNoclipDetection = true
        return
    end
    
    -- Brookhaven
    if placeId == 4924922222 then
        PlaceInfo.DetectedAntiCheat = "brookhaven"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        return
    end
    
    -- Blox Fruits
    if placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635 then
        PlaceInfo.DetectedAntiCheat = "bloxfruits"
        PlaceInfo.HasVelocityCheck = true
        PlaceInfo.HasPositionCheck = true
        PlaceInfo.HasWalkSpeedCap = true
        PlaceInfo.HasRemoteCheck = true
        return
    end
    
    -- Universal fallback — скануємо на типові ознаки античіту
    PlaceInfo.DetectedAntiCheat = "universal"
    
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("anticheat") or n:find("anti_cheat") or n:find("security") or n:find("detection") then
                PlaceInfo.HasRemoteCheck = true
            end
            if n:find("speed") and n:find("check") then
                PlaceInfo.HasWalkSpeedCap = true
            end
            if n:find("velocity") and n:find("check") then
                PlaceInfo.HasVelocityCheck = true
            end
        end
    end)
    
    pcall(function()
        for _, v in pairs(LP.PlayerScripts:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("anticheat") or n:find("security") or n:find("detection") then
                PlaceInfo.HasStateCheck = true
            end
        end
    end)
end

DetectPlace()

-- ============================================================
-- ANTI-CHEAT BYPASS CORE
-- ============================================================
local BypassState = {
    SpeedHooksInstalled = false,
    NoclipHooksInstalled = false,
    FlyHooksInstalled = false,
    HitboxHooksInstalled = false,
    RemoteHooksInstalled = false,
    PositionHooksInstalled = false,
    OriginalWalkSpeed = 16,
    OriginalJumpPower = 50,
    VelocityCleanupRunning = false,
    LastValidPosition = Vector3.zero,
    PositionCheckBypassed = false,
}

-- ============================================================
-- BYPASS 1: WALKSPEED — хукаємо Humanoid.WalkSpeed через метатаблицю
-- ============================================================
local function BypassWalkSpeed()
    if BypassState.SpeedHooksInstalled then return end
    
    local mt = getrawmetatable(game)
    if not mt then return end
    
    local oldIdx = mt.__index
    local oldNewIdx = mt.__newindex
    
    setreadonly(mt, false)
    
    mt.__newindex = newcclosure(function(self, key, value)
        if self:IsA("Humanoid") then
            if key == "WalkSpeed" then
                if State.Speed and value ~= GetSafeSpeed() then
                    return -- блокуємо серверні спроби скинути швидкість
                end
            end
            if key == "JumpPower" and State.HighJump then
                return -- блокуємо скидання сили стрибка
            end
        end
        return oldNewIdx(self, key, value)
    end)
    
    setreadonly(mt, true)
    BypassState.SpeedHooksInstalled = true
end

-- ============================================================
-- BYPASS 2: VELOCITY CLEANUP — для Da Hood та подібних
-- Да Худ перевіряє velocity кожен кадр і кікає якщо занадто висока
-- ============================================================
local function StartVelocityCleanup()
    if BypassState.VelocityCleanupRunning then return end
    BypassState.VelocityCleanupRunning = true
    
    task.spawn(function()
        while task.wait() do
            if not State.Speed and not State.Fly and not State.Bhop then
                BypassState.VelocityCleanupRunning = false
                break
            end
            
            local char = LP.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local vel = hrp.AssemblyLinearVelocity
            local hVel = Vector2.new(vel.X, vel.Z).Magnitude
            
            -- Da Hood ліміт ~26-28 studs/s без Sprint
            -- Ми клампимо velocity щоб виглядати легально
            local maxAllowed = 32
            if PlaceInfo.DetectedAntiCheat == "dahood" or PlaceInfo.DetectedAntiCheat == "hoodcustoms" then
                maxAllowed = 34
            elseif PlaceInfo.DetectedAntiCheat == "arsenal" then
                maxAllowed = 28
            elseif PlaceInfo.DetectedAntiCheat == "phantomforces" then
                maxAllowed = 30
            end
            
            if State.Speed and hVel > maxAllowed then
                -- Згладжуємо velocity замість різкого скидання
                local factor = maxAllowed / hVel
                hrp.AssemblyLinearVelocity = Vector3.new(
                    vel.X * factor,
                    vel.Y, -- зберігаємо вертикальну
                    vel.Z * factor
                )
            end
            
            -- Fly bypass — имітуємо гравітацію у velocity
            if State.Fly then
                local yVel = vel.Y
                if yVel > 15 then
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 0.3, yVel * 0.4, vel.Z * 0.3)
                end
            end
        end
    end)
end

-- ============================================================
-- BYPASS 3: POSITION CHECK — для ігор що перевіряють телепортацію
-- Блокуємо зайві position оновлення через RemoteEvent
-- ============================================================
local function BypassPositionCheck()
    if BypassState.PositionHooksInstalled then return end
    
    local mt = getrawmetatable(game)
    if not mt or not hookmetamethod then return end
    
    local oldNamecall = mt.__namecall
    
    hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Блокуємо підозрілі remotes що передають позицію
        if method == "FireServer" and State.Speed or State.Fly or State.Noclip then
            local remoteName = self.Name:lower()
            if remoteName:find("position") or remoteName:find("pos") 
               or remoteName:find("teleport") or remoteName:find("coords")
               or remoteName:find("location") or remoteName:find("cframe") then
                -- Не відправляємо позицію якщо активний чит
                if #args >= 1 and typeof(args[1]) == "Vector3" then
                    return nil
                end
                if #args >= 1 and typeof(args[1]) == "CFrame" then
                    return nil
                end
            end
        end
        
        -- Блокуємо anti-cheat remotes
        if method == "FireServer" then
            local remoteName = self.Name:lower()
            if remoteName:find("anticheat") or remoteName:find("security")
               or remoteName:find("detection") or remoteName:find("violation")
               or remoteName:find("kick") or remoteName:find("punish")
               or remoteName:find("report") and remoteName:find("cheat") then
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end))
    
    BypassState.PositionHooksInstalled = true
end

-- ============================================================
-- BYPASS 4: NOCLIP UNIVERSAL — обходимо всі типи детекту
-- CollisionGroup + CanCollide + BodyVelocity мінімізація
-- ============================================================
local NC_Groups = {}
local NC_Active = false
local NC_CycleCount = 0

local function UniversalNoclip()
    if not NC_Active then return end
    
    local char = LP.Character
    if not char then return end
    
    NC_CycleCount = NC_CycleCount + 1
    
    -- Метод 1: CollisionGroup (найнадійніший)
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function()
                v.CollisionGroup = SafeGroup
                v.CanCollide = false
            end)
        end
    end
    
    -- Метод 2: Для ігор що перевіряють CollisionGroup зміни
    -- Чергуємо між методами щоб не тригерити детект паттерн
    if NC_CycleCount % 30 == 0 then
        -- Коротко повертаємо CanCollide щоб виглядало легально
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.CanCollide = true
                    v.CollisionGroup = SafeGroup
                    task.wait(0.01)
                    v.CanCollide = false
                end)
            end
        end
    end
    
    -- Метод 3: Блокуємо підозрілі ремоти при ноукліпі
    if PlaceInfo.HasNoclipDetection and NC_CycleCount % 10 == 0 then
        pcall(function()
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    local n = v.Name:lower()
                    if n:find("noclip") or n:find("collision") or n:find("clip") or n:find("phase") then
                        -- Hook щоб блокувати звіти
                        if not NC_Groups[v] then
                            NC_Groups[v] = true
                            pcall(function()
                                hookfunction(v.FireServer, function(...)
                                    if NC_Active then return nil end
                                    return oldFireServer(v, ...)
                                end)
                            end)
                        end
                    end
                end
            end
        end)
    end
end

-- ============================================================
-- BYPASS 5: FLY ANTI-DETECT — імітуємо нормальний рух
-- ============================================================
local Fly_BypassActive = false
local Fly_LastGroundTime = 0
local Fly_FakeGroundCheck = false

local function BypassFlyDetection()
    if not Fly_BypassActive then return end
    
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    -- Імітуємо що ми на землі через стан Humanoid
    if tick() - Fly_LastGroundTime > 0.5 then
        hum:ChangeState(Enum.HumanoidStateType.Running)
        Fly_LastGroundTime = tick()
    end
    
    -- Блокуємо занадто високу Y velocity для детекту
    local vel = hrp.AssemblyLinearVelocity
    if math.abs(vel.Y) > 50 then
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.clamp(vel.Y, -50, 50), vel.Z)
    end
    
    -- Підкидуємо fake "на землі" подію кожні кілька секунд
    Fly_FakeGroundCheck = not Fly_FakeGroundCheck
    if Fly_FakeGroundCheck then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        end)
    end
end

-- ============================================================
-- BYPASS 6: HITBOX ANTI-VALIDATION — для ігор що перевіряють розмір
-- ============================================================
local HB_OriginalSizes = {}
local HB_BypassActive = false

local function BypassHitboxValidation()
    if not HB_BypassActive then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP or not IsAlive(p.Character) then continue end
        
        for _, v in pairs(p.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.Size.Magnitude > 0.3 then
                -- Зберігаємо оригінальний розмір для відновлення при перевірці
                if not HB_OriginalSizes[v] then
                    HB_OriginalSizes[v] = v.Size
                end
                
                -- Створюємо невидимий "overlay" part замість зміни оригіналу
                -- Це обходить перевірки що порівнюють розмір з оригінальним
                local overlayName = "OmniHB_" .. v.Name
                local overlay = v:FindFirstChild(overlayName)
                
                if not overlay then
                    overlay = Instance.new("Part")
                    overlay.Name = overlayName
                    overlay.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    overlay.Transparency = 1
                    overlay.CanCollide = false
                    overlay.Massless = true
                    overlay.Anchored = false
                    overlay.CollisionGroup = SafeGroup
                    overlay.Parent = v
                end
                
                overlay.CFrame = v.CFrame
                overlay.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                
                if Config.HitboxRandomize then
                    local r = math.random() * 0.4 - 0.2
                    overlay.Size = overlay.Size + Vector3.new(r, r, r)
                end
            end
        end
    end
end

local function CleanupHitboxBypass()
    for v, _ in pairs(HB_OriginalSizes) do
        pcall(function()
            if v and v.Parent then
                local overlay = v:FindFirstChild("OmniHB_" .. v.Name)
                if overlay then overlay:Destroy() end
            end
        end)
    end
    HB_OriginalSizes = {}
end

-- ============================================================
-- BYPASS 7: DA HOOD SPECIFIC — обходить їхній специфічний античіт
-- ============================================================
local DH_BypassActive = false
local DH_LastSprintState = false

local function DaHoodBypass()
    if PlaceInfo.DetectedAntiCheat ~= "dahood" and PlaceInfo.DetectedAntiCheat ~= "hoodcustoms" then
        return
    end
    
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    -- Da Hood перевіряє WalkSpeed vs actual velocity
    -- Ми синхронізуємо їх
    if State.Speed then
        local targetSpeed = GetSafeSpeed()
        hum.WalkSpeed = targetSpeed
        
        -- Da Hood дозволяє ~28 зі спринтом, ми тримаємося близько
        local vel = hrp.AssemblyLinearVelocity
        local hVel = Vector2.new(vel.X, vel.Z).Magnitude
        
        -- Імітуємо спринт
        if hVel > 20 and not DH_LastSprintState then
            DH_LastSprintState = true
            pcall(function()
                local sprintRemote = ReplicatedStorage:FindFirstChild("Sprint")
                if sprintRemote then sprintRemote:FireServer(true) end
            end)
        elseif hVel <= 20 and DH_LastSprintState then
            DH_LastSprintState = false
            pcall(function()
                local sprintRemote = ReplicatedStorage:FindFirstChild("Sprint")
                if sprintRemote then sprintRemote:FireServer(false) end
            end)
        end
    end
    
    -- Da Hood перевіряє стан Humanoid для ноукліпу
    if State.Noclip then
        -- Тримаємо Running стан замість Freefall
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    
    -- Block їх anti-cheat remote
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = v.Name:lower()
                if n:find("anticheat") or n:find("violation") or n:find("detect") then
                    if not DH_BypassActive then
                        local oldFire = hookfunction(v.FireServer, function(...) return nil end)
                        DH_BypassActive = true
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- BYPASS 8: HUD / GENERIC — для більшості HUD ігор
-- ============================================================
local function HUDBypass()
    -- Багато HUD ігор перевіряють через прості LocalScript'и
    -- Хукаємо getstate щоб повертати "безпечні" стани
    
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if State.Fly or State.Noclip then
        local currentState = hum:GetState()
        -- Замінюємо підозрілі стани
        if currentState == Enum.HumanoidStateType.Freefall 
           or currentState == Enum.HumanoidStateType.FallingDown
           or currentState == Enum.HumanoidStateType.PlatformStanding then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end

-- ============================================================
-- MAIN BYPASS LOOP — об'єднує всі обходи
-- ============================================================
local BypassLoopRunning = false

local function StartBypassLoop()
    if BypassLoopRunning then return end
    BypassLoopRunning = true
    
    task.spawn(function()
        while task.wait(0.033) do -- ~30fps для bypass loop
            local anyActive = State.Speed or State.Fly or State.Noclip 
                            or State.Bhop or State.Hitbox or State.HighJump
            
            if not anyActive then
                task.wait(0.5)
                continue
            end
            
            -- Velocity cleanup для ігор з такою перевіркою
            if PlaceInfo.HasVelocityCheck and (State.Speed or State.Fly) then
                StartVelocityCleanup()
            end
            
            -- Noclip bypass
            if State.Noclip then
                UniversalNoclip()
            end
            
            -- Fly bypass
            if State.Fly then
                BypassFlyDetection()
            end
            
            -- Hitbox bypass
            if State.Hitbox then
                HB_BypassActive = true
                BypassHitboxValidation()
            else
                if HB_BypassActive then
                    CleanupHitboxBypass()
                    HB_BypassActive = false
                end
            end
            
            -- Da Hood специфічний
            if PlaceInfo.DetectedAntiCheat == "dahood" or PlaceInfo.DetectedAntiCheat == "hoodcustoms" then
                DaHoodBypass()
            end
            
            -- HUD/Generic
            HUDBypass()
        end
    end)
end

-- ============================================================
-- ІНІЦІАЛІЗАЦІЯ БАЙПАСІВ
-- ============================================================
local function InitBypasses()
    -- Встановлюємо хуки що потрібні одразу
    if PlaceInfo.HasWalkSpeedCap or PlaceInfo.HasJumpPowerCap then
        BypassWalkSpeed()
    end
    
    if PlaceInfo.HasPositionCheck or PlaceInfo.HasRemoteCheck then
        BypassPositionCheck()
    end
    
    -- Запускаємо головний цикл
    StartBypassLoop()
end

-- Чекаємо завантаження гри
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)
    InitBypasses()
end)

-- ============================================================
-- МОДИФІКОВАНИЙ SPEED — з обходом
-- ============================================================
local function ApplySpeedBypass()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local targetSpeed = GetSafeSpeed()
    
    -- Da Hood: використовуємо їхній механізм спринту
    if PlaceInfo.DetectedAntiCheat == "dahood" or PlaceInfo.DetectedAntiCheat == "hoodcustoms" then
        -- Не змінюємо WalkSpeed напряму, використовуємо BodyVelocity
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local existingBV = hrp:FindFirstChild("OmniSpeedBV")
            if not existingBV then
                existingBV = Instance.new("BodyVelocity")
                existingBV.Name = "OmniSpeedBV"
                existingBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
                existingBV.P = 1500
                existingBV.Parent = hrp
            end
            
            local mx, mz = GetDir()
            local moveDir = Vector3.new(mx, 0, mz)
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
            
            local camCF = Camera.CFrame
            local relDir = (camCF.RightVector * moveDir.X + camCF.LookVector * moveDir.Z) * Vector3.new(1, 0, 1)
            if relDir.Magnitude > 0 then relDir = relDir.Unit end
            
            existingBV.Velocity = relDir * targetSpeed
        end
    else
        -- Для інших ігор — пряма зміна WalkSpeed
        hum.WalkSpeed = targetSpeed
    end
end

-- ============================================================
-- МОДИФІКОВАНИЙ FLY — з обходом
-- ============================================================
local Fly_BV = nil
local Fly_BG = nil
local Fly_LastCFrame = CFrame.new()

local function ApplyFlyBypass()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    if not Fly_BV or not Fly_BV.Parent then
        Fly_BV = Instance.new("BodyVelocity")
        Fly_BV.Name = "OmniFlyBV"
        Fly_BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        Fly_BV.Velocity = Vector3.zero
        Fly_BV.P = 2000
        Fly_BV.Parent = hrp
    end
    
    if not Fly_BG or not Fly_BG.Parent then
        Fly_BG = Instance.new("BodyGyro")
        Fly_BG.Name = "OmniFlyBG"
        Fly_BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        Fly_BG.P = 9000
        Fly_BG.Parent = hrp
    end
    
    local mx, mz = GetDir()
    local my = 0
    if UIS:IsKeyDown(Enum.KeyCode.Space) then my = 1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then my = -1 end
    
    local moveDir = Vector3.new(mx, my, mz)
    if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
    
    local camCF = Camera.CFrame
    local relDir = camCF.RightVector * moveDir.X + camCF.UpVector * moveDir.Y + camCF.LookVector * moveDir.Z
    if relDir.Magnitude > 0 then relDir = relDir.Unit end
    
    local flySpeed = Config.FlySpeed
    
    -- Для античітів що перевіряють Y velocity — обмежуємо
    if PlaceInfo.HasFlyDetection then
        flySpeed = math.min(flySpeed, 60)
        relDir = Vector3.new(relDir.X * flySpeed, math.clamp(relDir.Y * flySpeed, -40, 40), relDir.Z * flySpeed)
    else
        relDir = relDir * flySpeed
    end
    
    Fly_BV.Velocity = relDir
    Fly_BG.CFrame = camCF
    
    Fly_LastCFrame = hrp.CFrame
end

local function DisableFlyBypass()
    if Fly_BV then SafeDel(Fly_BV) end
    if Fly_BG then SafeDel(Fly_BG) end
    Fly_BV = nil
    Fly_BG = nil
    
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.Anchored = false
                hrp.AssemblyLinearVelocity = Vector3.zero
            end)
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.PlatformStand = false end)
        end
    end
end

-- ============================================================
-- МОДИФІКОВАНИЙ TOGGLE — інтегрує обхід
-- ============================================================
local OriginalToggle = nil

local function BypassToggle(nm)
    -- Конфіги
    if nm == "SpeedAntiBan" then
        Config.SpeedAntiBan = not Config.SpeedAntiBan
        State.SpeedAntiBan = Config.SpeedAntiBan
        UpdVis(nm)
        Notify(nm, Config.SpeedAntiBan and "ON ✓" or "OFF ✗", 1)
        return
    end
    if nm == "HitboxRandomize" then
        Config.HitboxRandomize = not Config.HitboxRandomize
        State.HitboxRandomize = Config.HitboxRandomize
        UpdVis(nm)
        Notify(nm, Config.HitboxRandomize and "ON ✓" or "OFF ✗", 1)
        return
    end
    if nm == "AimAntiDetect" then
        Config.AimAntiDetect = not Config.AimAntiDetect
        State.AimAntiDetect = Config.AimAntiDetect
        UpdVis(nm)
        Notify(nm, Config.AimAntiDetect and "ON ✓" or "OFF ✗", 1)
        return
    end
    if nm == "SafeSpeedMode" then
        Config.SafeSpeedMode = not Config.SafeSpeedMode
        State.SafeSpeedMode = Config.SafeSpeedMode
        UpdVis(nm)
        if Config.SafeSpeedMode then
            local cap = math.floor(gameBaseSpeed * Config.SafeSpeedMult)
            Notify("Safe Speed", "🛡 ON · Ліміт: " .. cap, 3)
        else
            Notify("Safe Speed", "🛡 OFF", 2)
        end
        return
    end
    
    State[nm] = not State[nm]
    local C = LP.Character
    local R = C and C:FindFirstChild("HumanoidRootPart")
    local H = C and C:FindFirstChildOfClass("Humanoid")
    
    if not State[nm] then
        -- ВИМКНЕННЯ
        
        if nm == "Fly" then
            DisableFlyBypass()
            Fly_BypassActive = false
        elseif nm == "Speed" then
            -- Миттєва зупинка з обходом
            if R then
                pcall(function()
                    R.AssemblyLinearVelocity = Vector3.zero
                end)
            end
            if H and not State.SafeSpeedMode then
                pcall(function() H.WalkSpeed = gameBaseSpeed end)
            end
            -- Прибираємо BodyVelocity для Da Hood
            if R then
                local bv = R:FindFirstChild("OmniSpeedBV")
                if bv then SafeDel(bv) end
            end
        elseif nm == "Noclip" then
            NC_Active = false
            ForceRestore()
        elseif nm == "Hitbox" then
            RestoreHB()
            CleanupHitboxBypass()
        elseif nm == "Bhop" then
            if H then pcall(function() H.WalkSpeed = gameBaseSpeed end) end
        elseif nm == "HighJump" then
            if H then pcall(function() H.JumpPower = 50 end) end
        elseif nm == "Spin" then
            if R then pcall(function() R.AssemblyAngularVelocity = Vector3.zero end) end
        elseif nm == "FullBright" then
            RemoveFullBright()
        elseif nm == "Potato" then
            UndoPotato()
        elseif nm == "Freecam" then
            pcall(function()
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = H or R
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end)
            fcZ = nil
        end
    else
        -- УВІМКНЕННЯ
        
        if nm == "Fly" then
            Fly_BypassActive = true
            Fly_LastGroundTime = tick()
        elseif nm == "Speed" then
            -- Ініціалізуємо байпаси якщо ще ні
            if not BypassState.SpeedHooksInstalled then
                BypassWalkSpeed()
            end
            if not BypassLoopRunning then
                StartBypassLoop()
            end
        elseif nm == "Noclip" then
            NC_Active = true
            NC_CycleCount = 0
        elseif nm == "Hitbox" then
            HB_BypassActive = true
        elseif nm == "FullBright" then
            ApplyFullBright()
        elseif nm == "Potato" then
            DoPotato()
        elseif nm == "Freecam" then
            pcall(function()
                Camera.CameraType = Enum.CameraType.Scriptable
                UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            end)
            fcZ = (R and R.Position.Y) or 10
        end
    end
    
    UpdVis(nm)
end

-- Замінюємо оригінальний Toggle
Toggle = BypassToggle

-- ============================================================
-- МОДИФІКОВАНИЙ MAIN LOOP
-- ============================================================
task.spawn(function()
    while task.wait() do
        local char = LP.Character
        if not char then task.wait(0.5); continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then task.wait(0.3); continue end
        
        -- SPEED з обходом
        if State.Speed then
            ApplySpeedBypass()
        end
        
        -- FLY з обходом
        if State.Fly then
            ApplyFlyBypass()
        end
        
        -- BHOP з обходом
        if State.Bhop then
            local mx, mz = GetDir()
            local moving = math.abs(mx) + math.abs(mz) > 0.1
            if moving and UIS:IsKeyDown(Enum.KeyCode.Space) then
                local now = tick()
                if now - lastBhop > 0.05 then
                    lastBhop = now
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        hum.JumpPower = Config.BhopPower
                    end)
                end
            end
        end
        
        -- NOCLIP з обходом (вже в UniversalNoclip через loop)
        
        -- SPIN
        if State.Spin then
            pcall(function()
                hrp.AssemblyAngularVelocity = Vector3.new(0, 20, 0)
            end)
        end
        
        -- HIGH JUMP з обходом
        if State.HighJump then
            pcall(function()
                hum.JumpPower = Config.JumpPower
                hum.UseJumpPower = true
            end)
        end
        
        -- NO FALL DAMAGE
        if State.NoFallDamage then
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                end)
            end
        end
        
        -- INFINITE JUMP
        if State.InfiniteJump then
            -- Обробляється через UIS.JumpRequest
        end
        
        -- ANTI-AFK
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0, 0))
            end)
            task.wait(60)
        end
        
        -- ANTI-VOID
        if State.AntiVoid then
            if hrp.Position.Y < Config.AntiVoidHeight then
                pcall(function()
                    hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end)
                Notify("Anti-Void", "🛡 Телепортовано на безпечну позицію", 2)
            end
        end
        
        -- ESP
        UpdateESP()
        
        -- SAFE SPEED
        if State.SafeSpeedMode and State.Speed then
            local cap = math.floor(gameBaseSpeed * Config.SafeSpeedMult)
            Config.WalkSpeed = math.min(Config.WalkSpeed, cap)
        end
    end
end)

-- Infinite Jump handler
UIS.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- Notify про плейс
task.spawn(function()
    task.wait(3)
    local placeName = PlaceInfo.DetectedAntiCheat
    local msg = "✅ Байпаси активні · "
    if placeName == "dahood" then
        msg = msg .. "Da Hood: Velocity + Position + Remote"
    elseif placeName == "hoodcustoms" then
        msg = msg .. "Hood Customs: Velocity + Position"
    elseif placeName == "arsenal" then
        msg = msg .. "Arsenal: Velocity + WalkSpeed"
    elseif placeName == "phantomforces" then
        msg = msg .. "Phantom Forces: Velocity + Noclip"
    elseif placeName == "badbusiness" then
        msg = msg .. "Bad Business: Velocity + Fly + Noclip"
    elseif placeName == "universal" then
        msg = msg .. "Universal: Auto-detect"
    else
        msg = msg .. placeName .. ": Auto-bypass"
    end
    Notify("OMNI V305", msg, 4)
end)
