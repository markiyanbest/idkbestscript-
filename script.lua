-- [[ V260.53: OMNI-REBORN - ULTIMATE MOBILE & PC STABILITY ]] 
-- [[ TRUE NO PARALYZE HITBOX | NATIVE MOBILE THUMBSTICK FIX | FULL CODE ]] 

local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local UIS = game:GetService("UserInputService") 
local Lighting = game:GetService("Lighting") 
local Workspace = game:GetService("Workspace") 

local LP = Players.LocalPlayer 
local Camera = Workspace.CurrentCamera 

-- [[ MOBILE CONTROLS INTEGRATION ]]
local Controls = nil
task.spawn(function()
    pcall(function()
        local PlayerModule = require(LP.PlayerScripts:WaitForChild("PlayerModule", 5))
        Controls = PlayerModule:GetControls()
    end)
end)

-- [[ CONFIGURATION ]] 
local Config = {  
    FlySpeed = 55,  
    WalkSpeed = 85,  
    JumpPower = 125, 
    HitboxSize = Vector3.new(18, 18, 18) 
} 

local State = { 
    Fly = false, Aim = false, ShadowLock = false, Noclip = false,  
    Hitbox = false, Speed = false, Bhop = false, ESP = false,  
    Spin = false, HighJump = false, Potato = false,
    FakeLag = false, Freecam = false, NoFallDamage = false, VelocityCap = false
} 

local LockedTarget = nil 
local Buttons = {} 

-- [[ ЗМІННІ ДЛЯ ПРАВИЛЬНОГО ОБЕРТАННЯ FREECAM ]]
local FC_Pitch = 0
local FC_Yaw = 0

-- [[ 1. GUI SYSTEM - ADAPTIVE ]] 
pcall(function()  
    if game:GetService("CoreGui"):FindFirstChild("V259_Omni") then  
        game:GetService("CoreGui").V259_Omni:Destroy()  
    end  
end) 

local Screen = Instance.new("ScreenGui", game:GetService("CoreGui")) 
Screen.Name = "V259_Omni"; Screen.ResetOnSpawn = false 

-- Перевірка пристрою для адаптації розмірів
local IsMobile = UIS.TouchEnabled
local MainWidth = IsMobile and 200 or 230
local MainHeight = IsMobile and 360 or 520
local ButtonMSize = IsMobile and 55 or 45

local MToggle = Instance.new("TextButton", Screen) 
MToggle.Size = UDim2.new(0, ButtonMSize, 0, ButtonMSize); MToggle.Position = UDim2.new(0, 10, 0.45, 0) 
MToggle.BackgroundColor3 = Color3.new(1,1,1); MToggle.Text = "M"; MToggle.TextColor3 = Color3.new(0,0,0) 
MToggle.Font = Enum.Font.GothamBlack; MToggle.TextSize = IsMobile and 28 or 22; MToggle.ZIndex = 100
Instance.new("UICorner", MToggle) 

local StatsFrame = Instance.new("Frame", Screen) 
StatsFrame.Size = UDim2.new(0, 110, 0, 45); StatsFrame.Position = UDim2.new(1, -125, 0, 15) 
StatsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); StatsFrame.BackgroundTransparency = 0.2 
Instance.new("UICorner", StatsFrame); local StatsStroke = Instance.new("UIStroke", StatsFrame) 
StatsStroke.Color = Color3.new(1, 1, 1); StatsStroke.Thickness = 1.5 

local FPSLabel = Instance.new("TextLabel", StatsFrame) 
FPSLabel.Size = UDim2.new(1, 0, 0.5, 0); FPSLabel.Position = UDim2.new(0, 0, 0, 2) 
FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(1,1,1) 
FPSLabel.Font = Enum.Font.GothamBold; FPSLabel.TextSize = 13; FPSLabel.Text = "FPS: ..." 

local PingLabel = Instance.new("TextLabel", StatsFrame) 
PingLabel.Size = UDim2.new(1, 0, 0.5, 0); PingLabel.Position = UDim2.new(0, 0, 0.5, -2) 
PingLabel.BackgroundTransparency = 1; PingLabel.TextColor3 = Color3.new(1,1,1) 
PingLabel.Font = Enum.Font.GothamBold; PingLabel.TextSize = 13; PingLabel.Text = "Ping: ..." 

local Main = Instance.new("Frame", Screen) 
Main.Size = UDim2.new(0, MainWidth, 0, MainHeight) 
Main.Position = UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2) 
Main.BackgroundColor3 = Color3.new(0,0,0); Main.Visible = false; Main.Active = true; Main.Draggable = true 

Instance.new("UICorner", Main); local Stroke = Instance.new("UIStroke", Main); 
Stroke.Color = Color3.new(1,1,1); Stroke.Thickness = 2 

local Scroll = Instance.new("ScrollingFrame", Main) 
Scroll.Size = UDim2.new(1, -10, 1, -20); Scroll.Position = UDim2.new(0, 5, 0, 10) 
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = IsMobile and 0 or 2 

local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 6); 
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center 

-- [[ ДИНАМІЧНЕ ОНОВЛЕННЯ GUI ]]
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)

-- [[ 2. HELPERS ]] 
local function GetClosestPlayer() 
    local target, minDistance = nil, math.huge 
    for _, p in pairs(Players:GetPlayers()) do 
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then 
            local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude 
            if dist < minDistance then minDistance = dist; target = p.Character end 
        end 
    end 
    return target 
end 

local function ClearESP() 
    for _, p in pairs(Players:GetPlayers()) do 
        if p.Character then 
            if p.Character:FindFirstChild("OmniHighlight") then p.Character.OmniHighlight:Destroy() end 
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("OmniTag") then 
                p.Character.Head.OmniTag:Destroy() 
            end 
        end 
    end 
end 

-- [[ 3. PHYSICAL MAGNET COMPONENTS ]] 
local MagBodyPos = Instance.new("BodyPosition") 
MagBodyPos.P = 45000; MagBodyPos.D = 800; MagBodyPos.MaxForce = Vector3.zero 
local MagBodyGyr = Instance.new("BodyGyro") 
MagBodyGyr.P = 45000; MagBodyGyr.MaxTorque = Vector3.zero 

-- [[ 4. TOGGLE SYSTEM ]] 
local function Toggle(Name) 
    State[Name] = not State[Name] 
    local Char = LP.Character 
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart") 
      
    if Name == "ESP" and not State.ESP then ClearESP() end 

    -- ФІКС ПАРАЛІЧУ
    if Name == "Hitbox" and not State.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character then 
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") then
                    hrp.Size = Vector3.new(2,2,1)
                    hrp.Transparency = 1 
                    hrp.CanCollide = false 
                    hrp.CanTouch = true 
                    hrp.CanQuery = true 
                    hrp.Massless = false 
                    hrp.CustomPhysicalProperties = nil 
                end
            end 
        end 
    end

    if Name == "Noclip" and not State.Noclip then 
        task.wait(0.05) 
        if Char then 
            for _, v in pairs(Char:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = true end 
            end 
        end 
    end 
    
    if Name == "Freecam" then
        if State.Freecam then
            Camera.CameraType = Enum.CameraType.Scriptable
            local x, y, z = Camera.CFrame:ToEulerAnglesYXZ()
            FC_Pitch = x
            FC_Yaw = y
            if HRP then HRP.Anchored = true end
        else
            Camera.CameraType = Enum.CameraType.Custom
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            if HRP and not State.FakeLag then HRP.Anchored = false end
            local Hum = Char and Char:FindFirstChild("Humanoid")
            if Hum then
                Camera.CameraSubject = Hum
            end
        end
    end

    if Name == "ShadowLock" then 
        if State.ShadowLock then 
            LockedTarget = GetClosestPlayer() 
            if HRP then MagBodyPos.Parent = HRP; MagBodyGyr.Parent = HRP end 
        else 
            LockedTarget = nil 
            MagBodyPos.MaxForce = Vector3.zero; MagBodyGyr.MaxTorque = Vector3.zero 
        end 
    end 

    if Name == "Potato" and State.Potato then 
        Lighting.GlobalShadows = false 
        for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.Plastic end end 
    end 
    
    if Name == "Speed" and not State.Speed then
        -- Відновлення стандартних швидкостей залишається недоторканим завдяки CFrame методу
    end
    
    if Name == "HighJump" and not State.HighJump then
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if Hum then Hum.JumpPower = 50 end
    end

    if Buttons[Name] then 
        Buttons[Name].BackgroundColor3 = State[Name] and Color3.new(1,1,1) or Color3.fromRGB(30, 30, 35) 
        Buttons[Name].TextColor3 = State[Name] and Color3.new(0,0,0) or Color3.new(1,1,1) 
    end 
end 

-- [[ 5. UI CONSTRUCTION ]] 
local function CreateSlider(Text, Min, Max, Default, Callback) 
    local Container = Instance.new("Frame", Scroll); Container.Size = UDim2.new(0.9, 0, 0, 50); Container.BackgroundTransparency = 1 

    local Label = Instance.new("TextLabel", Container); Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = Text .. ": " .. Default; 
    Label.TextColor3 = Color3.new(1,1,1); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.GothamBold; Label.TextSize = 10 

    local SliderBG = Instance.new("Frame", Container); SliderBG.Size = UDim2.new(1, 0, 0, 6); SliderBG.Position = UDim2.new(0, 0, 0, 30); 
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 55); Instance.new("UICorner", SliderBG) 

    local Fill = Instance.new("Frame", SliderBG); Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Fill) 
    
    local function Update(input) 
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1) 
        Fill.Size = UDim2.new(pos, 0, 1, 0); local value = math.floor(Min + (pos * (Max - Min))); Label.Text = Text .. ": " .. value; Callback(value) 
    end 
    
    local dragging = false 

    -- ФІКС ДЛЯ ТЕЛЕФОНІВ (Touch Support)
    SliderBG.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true; Update(input) 
        end 
    end) 
    UIS.InputChanged:Connect(function(input) 
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
            Update(input) 
        end 
    end) 
    UIS.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end 
    end) 
end 

CreateSlider("🚀 FLY SPEED", 0, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end) 
CreateSlider("⚡ WALK SPEED", 16, 200, Config.WalkSpeed, function(v) Config.WalkSpeed = v end) 
CreateSlider("⬆️ JUMP POWER", 50, 500, Config.JumpPower, function(v) Config.JumpPower = v end) 

local function CreateBtn(Text, LogicName) 
    local Btn = Instance.new("TextButton", Scroll); Btn.Size = UDim2.new(0.9, 0, 0, 36); Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); 
    Btn.Text = Text; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Instance.new("UICorner", Btn) 
    Btn.MouseButton1Click:Connect(function() Toggle(LogicName) end); Buttons[LogicName] = Btn 
end 

-- ДОДАНО VELOCITY CAP ДО МЕНЮ
local Names = {"🕊️ FLY [F]", "🎯 AUTO AIM [G]", "💀 MAGNET", "👻 NOCLIP [V]", "🥊 HITBOX", "⚡ SPEED", "🐇 BHOP", "📦 ADVANCED ESP", "🌀 SPIN", "⬆️ HIGH JUMP", "🥔 POTATO", "📶 FAKE LAG", "🎥 FREECAM", "🛡️ NO FALL DAMAGE", "🛑 VELOCITY CAP"} 
local Logic = {"Fly", "Aim", "ShadowLock", "Noclip", "Hitbox", "Speed", "Bhop", "ESP", "Spin", "HighJump", "Potato", "FakeLag", "Freecam", "NoFallDamage", "VelocityCap"} 
for i, n in ipairs(Names) do CreateBtn(n, Logic[i]) end 

MToggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end) 
Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20) 

-- [[ ОБРОБКА ПОВОРОТУ КАМЕРИ FREECAM ]]
UIS.InputChanged:Connect(function(input, gameProcessed)
    if State.Freecam then
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                FC_Yaw = FC_Yaw - math.rad(input.Delta.X * 0.3)
                FC_Pitch = math.clamp(FC_Pitch - math.rad(input.Delta.Y * 0.3), -math.rad(89), math.rad(89))
            else
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
        elseif input.UserInputType == Enum.UserInputType.Touch then
            FC_Yaw = FC_Yaw - math.rad(input.Delta.X * 0.3)
            FC_Pitch = math.clamp(FC_Pitch - math.rad(input.Delta.Y * 0.3), -math.rad(89), math.rad(89))
        end
    end
end)

-- [[ 6. MAIN RENDER LOOP ]] 
local FrameLog = {} 
RunService.RenderStepped:Connect(function() 
    table.insert(FrameLog, tick()) 
    for i = #FrameLog, 1, -1 do if FrameLog[i] < tick() - 1 then table.remove(FrameLog, i) end end 
    FPSLabel.Text = "FPS: " .. #FrameLog 
    
    pcall(function()
        PingLabel.Text = "Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. "ms" 
    end)

    -- Читання джойстика для руху (ПК WASD теж працює)
    local moveX, moveZ = 0, 0
    if Controls then
        local mv = Controls:GetMoveVector()
        moveX, moveZ = mv.X, mv.Z
    end

    if State.Freecam then
        local camMove = Vector3.zero
        -- Підтримка мобільного джойстика і WASD
        camMove += Camera.CFrame.LookVector * -moveZ
        camMove += Camera.CFrame.RightVector * moveX
        
        -- ПК клавіші для підйому/спуску
        if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then camMove += Camera.CFrame.UpVector end  
        if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then camMove -= Camera.CFrame.UpVector end  
        
        local speed = Config.FlySpeed / 25
        local newPos = Camera.CFrame.Position + (camMove * speed)
        Camera.CFrame = CFrame.new(newPos) * CFrame.fromEulerAnglesYXZ(FC_Pitch, FC_Yaw, 0)
    end

    -- [[ 🥊 HITBOX BLOCK ]] 
    if State.Hitbox then 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then 
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:IsA("BasePart") and hrp.Size.X ~= Config.HitboxSize.X then 
                    hrp.Size = Config.HitboxSize 
                    hrp.Transparency = 0.5 
                    hrp.CanCollide = false 
                    hrp.CanTouch = true 
                    hrp.CanQuery = true 
                    hrp.Massless = false 
                    hrp.Material = Enum.Material.Neon 
                    hrp.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0) 
                end 
            end 
        end 
    end 

    -- [[ 📦 ESP BLOCK ]] 
    if State.ESP then 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character then 
                local highlight = p.Character:FindFirstChild("OmniHighlight") or Instance.new("Highlight", p.Character) 
                highlight.Name = "OmniHighlight" 
                highlight.FillColor = Color3.new(1, 0, 0) 
                highlight.OutlineColor = Color3.new(1, 1, 1) 
                highlight.FillTransparency = 0.5 
                highlight.OutlineTransparency = 0 
                highlight.Enabled = true 
                 
                local head = p.Character:FindFirstChild("Head") 
                if head then 
                    local billboard = head:FindFirstChild("OmniTag") or Instance.new("BillboardGui", head) 
                    billboard.Name = "OmniTag" 
                    billboard.Size = UDim2.new(0, 200, 0, 50) 
                    billboard.StudsOffset = Vector3.new(0, 3, 0) 
                    billboard.AlwaysOnTop = true 
                      
                    local tag = billboard:FindFirstChild("Label") or Instance.new("TextLabel", billboard) 
                    tag.Name = "Label" 
                    tag.Size = UDim2.new(1, 0, 1, 0) 
                    tag.BackgroundTransparency = 1 
                    tag.TextColor3 = Color3.new(1, 1, 1) 
                    tag.Font = Enum.Font.GothamBold 
                    tag.TextSize = 14 
                      
                    local hum = p.Character:FindFirstChild("Humanoid") 
                    local health = hum and math.floor(hum.Health) or 0 
                    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") 
                    local dist = root and math.floor((root.Position - head.Position).Magnitude) or 0 
                    tag.Text = p.Name .. "\nHP: " .. health .. " | Dist: " .. dist .. "m" 
                end 
            end 
        end 
    end 

    local Char = LP.Character; local HRP = Char and Char:FindFirstChild("HumanoidRootPart") 
    if not HRP then return end 

    if State.ShadowLock then 
        local IsAlive = LockedTarget and LockedTarget.Parent and LockedTarget:FindFirstChild("Humanoid") and LockedTarget.Humanoid.Health > 0 
        if not IsAlive then LockedTarget = GetClosestPlayer() end 
        if LockedTarget and LockedTarget:FindFirstChild("HumanoidRootPart") then 
            MagBodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge); MagBodyGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
            MagBodyPos.Position = LockedTarget.HumanoidRootPart.Position + (LockedTarget.HumanoidRootPart.CFrame.LookVector * -3) 
            MagBodyGyr.CFrame = LockedTarget.HumanoidRootPart.CFrame; HRP.RotVelocity = Vector3.zero 
        else 
            MagBodyPos.MaxForce = Vector3.zero; MagBodyGyr.MaxTorque = Vector3.zero 
        end 
    end 

    if State.Aim then 
        local target = GetClosestPlayer() 
        if target and target:FindFirstChild("Head") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position) end 
    end 

    if State.Fly then 
        local move = Vector3.zero 
        -- Підтримка мобільного джойстика і WASD для Fly
        move += Camera.CFrame.LookVector * -moveZ
        move += Camera.CFrame.RightVector * moveX
        
        -- ПК клавіші для підйому/спуску в Fly
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Camera.CFrame.UpVector end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then move -= Camera.CFrame.UpVector end
        
        HRP.Velocity = move * Config.FlySpeed 
    end 
end) 

-- [[ 7. HEARTBEAT LOOP ]] 
RunService.Heartbeat:Connect(function(deltaTime) 
    local Char = LP.Character; local HRP = Char and Char:FindFirstChild("HumanoidRootPart"); local Hum = Char and Char:FindFirstChild("Humanoid") 
    if not HRP or not Hum then return end 
    
    if State.Spin then HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(30), 0) end 
    
    -- НАТИВНИЙ КОНТРОЛЬ ШВИДКОСТІ (CFrame Адаптивний метод)
    if State.Speed then
        if Hum.MoveDirection.Magnitude > 0 then
            local speedBoost = Config.WalkSpeed - Hum.WalkSpeed
            if speedBoost > 0 then
                HRP.CFrame = HRP.CFrame + (Hum.MoveDirection * speedBoost * deltaTime)
            end
        end
    end
    
    -- НАТИВНИЙ КОНТРОЛЬ СТРИБКА
    if State.HighJump then
        Hum.UseJumpPower = true
        Hum.JumpPower = Config.JumpPower
    elseif not State.HighJump and Hum.JumpPower == Config.JumpPower then
        Hum.UseJumpPower = true
        Hum.JumpPower = 50
    end
    
    -- BHOP
    if State.Bhop and Hum.FloorMaterial ~= Enum.Material.Air and Hum.MoveDirection.Magnitude > 0 then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- [[ ФІЗИКА: БЕЗПЕЧНИЙ NO FALL DAMAGE ТА VELOCITY CAP ]]
    local currentVelocity = HRP.AssemblyLinearVelocity

    if State.NoFallDamage then
        if Hum:GetState() == Enum.HumanoidStateType.Freefall and currentVelocity.Y < -45 then
            HRP.AssemblyLinearVelocity = Vector3.new(currentVelocity.X, -5, currentVelocity.Z)
            currentVelocity = HRP.AssemblyLinearVelocity -- Оновлюємо вектор для наступної перевірки
        end
    end

    if State.VelocityCap then
        local horizontalVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
        if horizontalVelocity.Magnitude > 35 then
            local cappedHorizontal = horizontalVelocity.Unit * 28
            HRP.AssemblyLinearVelocity = Vector3.new(cappedHorizontal.X, currentVelocity.Y, cappedHorizontal.Z)
        end
    end
end) 

-- [[ 📶 FAKE LAG ]]
task.spawn(function()
    while task.wait() do
        if State.FakeLag then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            if HRP then
                HRP.Anchored = true
                task.wait(math.random(5, 15) / 100) 
                
                if HRP and not State.Freecam then HRP.Anchored = false end
                task.wait(math.random(10, 25) / 100) 
            end
        else
            task.wait(0.5) 
        end
    end
end)

RunService.Stepped:Connect(function() 
    if State.Noclip and LP.Character then 
        for _, v in pairs(LP.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end 
    end 
end) 

UIS.InputBegan:Connect(function(i, g) 
    if g then return end 
    if i.KeyCode == Enum.KeyCode.F then Toggle("Fly") end 
    if i.KeyCode == Enum.KeyCode.G then Toggle("Aim") end 
    if i.KeyCode == Enum.KeyCode.V then Toggle("Noclip") end 
    if i.KeyCode == Enum.KeyCode.M then Main.Visible = not Main.Visible end 
end)
