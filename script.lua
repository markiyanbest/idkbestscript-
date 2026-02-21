-- [[ V262.00: OMNI-REBORN - 2026 BYFRON BYPASS EDITION ]] 
-- [[ POLYMORPHIC GUI | PING PREDICTION | MUTATED HITBOXES | SOFT FAKELAG | SILENT AIM | ANTI-SS ]] 

local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local UIS = game:GetService("UserInputService") 
local Lighting = game:GetService("Lighting") 
local Workspace = game:GetService("Workspace") 
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer 
local Camera = Workspace.CurrentCamera 

-- [[ GENERATE RANDOM STRINGS FOR BYPASS ]]
local function RandomString(length)
    local str = ""
    for i = 1, length do
        str = str .. string.char(math.random(97, 122))
    end
    return str
end

-- [[ ALWAYS-ON ANTI-SCREENSHOT / ANTI-F9 ]]
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local function SetBlur(active)
    Blur.Size = active and 36 or 0  -- 36 — сильний blur для захисту від скріншотів
end

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- Виявлення F9 (Developer Console)
    if input.KeyCode == Enum.KeyCode.F9 then
        SetBlur(true)
        task.delay(1.5, function() SetBlur(false) end)
    end
    -- Виявлення Roblox screenshot (F12 або Shift + F12)
    if input.KeyCode == Enum.KeyCode.F12 or (input.KeyCode == Enum.KeyCode.LeftShift and UIS:IsKeyDown(Enum.KeyCode.F12)) then
        SetBlur(true)
        task.delay(0.8, function() SetBlur(false) end)
    end
end)

-- [[ MOBILE CONTROLS INTEGRATION ]]
local Controls = nil
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1.5) 
    pcall(function()
        local PlayerModule = require(LP.PlayerScripts:WaitForChild("PlayerModule", 5))
        Controls = PlayerModule:GetControls()
    end)
end)

-- [[ CONFIGURATION ]] 
local Config = {  
    FlySpeed = 55,  
    WalkSpeed = 85,  
    JumpPower = 125
} 

local State = { 
    Fly = false, Aim = false, ShadowLock = false, Noclip = false,  
    Hitbox = false, Speed = false, Bhop = false, ESP = false,  
    Spin = false, HighJump = false, Potato = false,
    FakeLag = false, Freecam = false, NoFallDamage = false, AntiAFK = false,
    SilentAim = false
} 

local LockedTarget = nil 
local Buttons = {} 

local FC_Pitch = 0
local FC_Yaw = 0

-- [[ 1. GUI SYSTEM - POLYMORPHIC ADAPTIVE ]] 
local GuiParent
pcall(function() GuiParent = game:GetService("CoreGui") end)
if not GuiParent or not pcall(function() local _ = GuiParent.Name end) then
    GuiParent = LP:WaitForChild("PlayerGui")
end

pcall(function()  
    for _, v in pairs(GuiParent:GetChildren()) do
        if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then
            v:Destroy()
        end
    end
    if game:GetService("CoreGui"):FindFirstChild("V259_Omni") then
        game:GetService("CoreGui").V259_Omni:Destroy()
    end
end) 

local Screen = Instance.new("ScreenGui", GuiParent) 
Screen.Name = RandomString(12)
Screen.ResetOnSpawn = false 
local Marker = Instance.new("BoolValue", Screen)
Marker.Name = "OmniMarker"

local IsMobile = UIS.TouchEnabled
local MainWidth = IsMobile and 200 or 230
local MainHeight = IsMobile and 360 or 550
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
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 

local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 6); 
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center 

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)

-- [[ 2. HELPERS & CLEAUP ]] 
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
            for _, v in pairs(p.Character:GetChildren()) do
                if v:IsA("Highlight") and v:FindFirstChild("ESPMarker") then v:Destroy() end
            end
            local head = p.Character:FindFirstChild("Head")
            if head then
                for _, v in pairs(head:GetChildren()) do
                    if v:IsA("BillboardGui") and v:FindFirstChild("ESPMarker") then v:Destroy() end
                end
            end
        end 
    end 
end 

-- [[ 3. УНІВЕРСАЛЬНИЙ SILENT AIM ДЛЯ XENO (БЕЗ HOOK) ]]
local function SimpleSilentAim()
    if State.SilentAim and State.Aim then
        local target = GetClosestPlayer()
        if target and target:FindFirstChild("Head") then
            -- Направляємо камеру на голову цілі перед пострілом
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.new(camPos, target.Head.Position)
        end
    end
end

-- Додаємо виклик у RenderStepped для миттєвої реакції
RunService.RenderStepped:Connect(function()
    if State.SilentAim then
        SimpleSilentAim()
    end
end)

-- [[ 4. TOGGLE SYSTEM ]] 
local function Toggle(Name) 
    State[Name] = not State[Name] 
    local Char = LP.Character 
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart") 
      
    if Name == "ESP" and not State.ESP then ClearESP() end 

    if Name == "Hitbox" and not State.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character then 
                local head = p.Character:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    head.Size = Vector3.new(1.2, 1.2, 1.2)
                    head.Transparency = 0 
                    head.CanCollide = true 
                    head.CanTouch = true 
                    head.CanQuery = true 
                    head.Massless = false 
                    head.Material = Enum.Material.Plastic
                    head.Color = Color3.new(0.639216, 0.635294, 0.607843) -- Стандартний колір голови (приблизний)
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

    if Name == "Speed" and not State.Speed then
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if Hum then Hum.WalkSpeed = 16 end
    end
    
    if Name == "Fly" and HRP then
        if State.Fly then
            pcall(function() HRP:SetNetworkOwner(nil) end)
        else
            pcall(function() HRP:SetNetworkOwner(LP) end)
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
            if UIS.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
            if HRP then HRP.Anchored = false end
            local Hum = Char and Char:FindFirstChild("Humanoid")
            if Hum then
                Camera.CameraSubject = Hum
            end
        end
    end

    if Name == "ShadowLock" then 
        if State.ShadowLock then 
            LockedTarget = GetClosestPlayer() 
        else 
            LockedTarget = nil 
        end 
    end 

    if Name == "Potato" and State.Potato then 
        Lighting.GlobalShadows = false 
        for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.Plastic end end 
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

-- [[ НАДІЙНИЙ ANTI-IDLE ]]
LP.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

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

local Names = {"🕊️ FLY [F]", "🎯 AUTO AIM [G]", "🔫 SILENT AIM", "💀 MAGNET", "👻 NOCLIP [V]", "🥊 HITBOX", "⚡ SPEED", "🐇 BHOP", "📦 ADVANCED ESP", "🌀 SPIN", "⬆️ HIGH JUMP", "🥔 POTATO", "📶 FAKE LAG", "🎥 FREECAM", "🛡️ NO FALL DAMAGE", "🛡️ ANTI-AFK"} 
local Logic = {"Fly", "Aim", "SilentAim", "ShadowLock", "Noclip", "Hitbox", "Speed", "Bhop", "ESP", "Spin", "HighJump", "Potato", "FakeLag", "Freecam", "NoFallDamage", "AntiAFK"} 
for i, n in ipairs(Names) do CreateBtn(n, Logic[i]) end 

MToggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end) 
Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20) 

-- [[ FREECAM INPUT ]]
UIS.InputChanged:Connect(function(input, gameProcessed)
    if State.Freecam then
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                FC_Yaw = FC_Yaw - math.rad(input.Delta.X * 0.3)
                FC_Pitch = math.clamp(FC_Pitch - math.rad(input.Delta.Y * 0.3), -math.rad(89), math.rad(89))
            else
                if UIS.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
                    UIS.MouseBehavior = Enum.MouseBehavior.Default
                end
            end
        elseif input.UserInputType == Enum.UserInputType.Touch then
            FC_Yaw = FC_Yaw - math.rad(input.Delta.X * 0.3)
            FC_Pitch = math.clamp(FC_Pitch - math.rad(input.Delta.Y * 0.3), -math.rad(89), math.rad(89))
        end
    end
end)

-- [[ 6. MAIN RENDER LOOP ]] 
local FrameLog = {} 
RunService.RenderStepped:Connect(function(dt) 
    table.insert(FrameLog, tick()) 
    for i = #FrameLog, 1, -1 do if FrameLog[i] < tick() - 1 then table.remove(FrameLog, i) end end 
    FPSLabel.Text = "FPS: " .. #FrameLog 
    
    local safePing = 0
    pcall(function()
        safePing = LP:GetNetworkPing()
        PingLabel.Text = "Ping: " .. math.floor(safePing * 1000) .. "ms" 
    end)

    local moveX, moveZ = 0, 0
    if Controls then
        local mv = Controls:GetMoveVector()
        moveX, moveZ = mv.X, mv.Z
    end

    -- [[ FLY ]]
    if State.Fly and not State.Freecam and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LP.Character.HumanoidRootPart
        local camLook = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        local speed = Config.FlySpeed
        local velocityPrediction = HRP.AssemblyLinearVelocity * dt

        local cf = HRP.CFrame
        cf += camLook * (-moveZ * speed * dt * 0.92)  
        cf += right * (moveX * speed * dt * 0.88)     
        
        if UIS:IsKeyDown(Enum.KeyCode.Space) then cf += Vector3.new(0, speed * dt, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then cf -= Vector3.new(0, speed * dt, 0) end

        HRP.CFrame = cf:Lerp(HRP.CFrame + velocityPrediction, 0.35)
        HRP.AssemblyLinearVelocity = Vector3.new(0,0,0) 

        local downRay = Ray.new(HRP.Position, Vector3.new(0, -9, 0))
        local hit, pos = Workspace:FindPartOnRayWithIgnoreList(downRay, {LP.Character})
        if not hit then
            HRP.CFrame = HRP.CFrame + Vector3.new(0, 0.08 + math.random(-3,3)/100, 0)
        end
    end

    if State.Freecam then
        local camMove = Vector3.zero
        camMove += Camera.CFrame.LookVector * -moveZ
        camMove += Camera.CFrame.RightVector * moveX
        
        if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then camMove += Camera.CFrame.UpVector end  
        if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then camMove -= Camera.CFrame.UpVector end  
        
        local speed = Config.FlySpeed / 25
        local newPos = Camera.CFrame.Position + (camMove * speed)
        Camera.CFrame = CFrame.new(newPos) * CFrame.fromEulerAnglesYXZ(FC_Pitch, FC_Yaw, 0)
    end

    -- [[ MUTATED HEAD HITBOX ]] 
    if State.Hitbox then 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then 
                local head = p.Character:FindFirstChild("Head")
                if head and head:IsA("BasePart") then 
                    -- Замість точної перевірки 18, дивимось чи голова стандартного розміру (< 15)
                    -- Якщо так, генеруємо унікальний розмір від 17.5 до 18.5
                    if head.Size.X < 15 then 
                        local rSize = math.random(175, 185) / 10
                        head.Size = Vector3.new(rSize, rSize, rSize) 
                        head.Transparency = 0.5 -- Зроблено напівпрозорим для видимості розміру
                        head.Material = Enum.Material.ForceField
                        head.Color = Color3.new(1, 0, 0) -- Червоний колір для візуалізації
                        head.CanTouch = true 
                        head.CanQuery = true 
                        head.Massless = true 
                    end 
                end 
            end 
        end 
    end 

    -- [[ POLYMORPHIC ESP ]] 
    if State.ESP then 
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character then 
                local highlight = nil
                for _, v in pairs(p.Character:GetChildren()) do
                    if v:IsA("Highlight") and v:FindFirstChild("ESPMarker") then highlight = v; break end
                end

                if not highlight then
                    highlight = Instance.new("Highlight", p.Character) 
                    highlight.Name = RandomString(10)
                    local m = Instance.new("BoolValue", highlight); m.Name = "ESPMarker"
                    highlight.FillColor = Color3.new(1, 0, 0) 
                    highlight.OutlineColor = Color3.new(1, 1, 1) 
                    highlight.FillTransparency = 0.5 
                    highlight.OutlineTransparency = 0 
                end
                highlight.Enabled = true 
                 
                local head = p.Character:FindFirstChild("Head") 
                if head then 
                    local billboard = nil
                    for _, v in pairs(head:GetChildren()) do
                        if v:IsA("BillboardGui") and v:FindFirstChild("ESPMarker") then billboard = v; break end
                    end

                    if not billboard then
                        billboard = Instance.new("BillboardGui", head) 
                        billboard.Name = RandomString(8)
                        local m = Instance.new("BoolValue", billboard); m.Name = "ESPMarker"
                        billboard.Size = UDim2.new(0, 200, 0, 50) 
                        billboard.StudsOffset = Vector3.new(0, 3, 0) 
                        billboard.AlwaysOnTop = true 
                          
                        local tag = Instance.new("TextLabel", billboard) 
                        tag.Name = RandomString(5)
                        tag.Size = UDim2.new(1, 0, 1, 0) 
                        tag.BackgroundTransparency = 1 
                        tag.TextColor3 = Color3.new(1, 1, 1) 
                        tag.Font = Enum.Font.GothamBold 
                        tag.TextSize = 14 
                    end

                    local tagLabel = billboard:FindFirstChildWhichIsA("TextLabel")
                    if tagLabel then
                        local hum = p.Character:FindFirstChild("Humanoid") 
                        local health = hum and math.floor(hum.Health) or 0 
                        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") 
                        local dist = root and math.floor((root.Position - head.Position).Magnitude) or 0 
                        
                        -- Відображення розміру хітбоксу в ESP
                        local hbSizeText = (State.Hitbox and head.Size.X > 15) and string.format("%.2f", head.Size.X) or "Standard"
                        
                        tagLabel.Text = p.Name .. "\nHP: " .. health .. " | Dist: " .. dist .. "m\nHitbox Size: " .. hbSizeText 
                    end
                end 
            end 
        end 
    end 

    local Char = LP.Character; local HRP = Char and Char:FindFirstChild("HumanoidRootPart") 
    if not HRP then return end 

    -- [[ PING-PREDICTED CFRAME MAGNET ]]
    if State.ShadowLock then 
        local IsAlive = LockedTarget and LockedTarget.Parent and LockedTarget:FindFirstChild("Humanoid") and LockedTarget.Humanoid.Health > 0 
        if not IsAlive then LockedTarget = GetClosestPlayer() end 
        
        if LockedTarget and LockedTarget:FindFirstChild("HumanoidRootPart") then 
            local targetHRP = LockedTarget.HumanoidRootPart
            local clampedPing = math.clamp(safePing, 0, 0.25) -- Макс 250мс передбачення
            local predictionVector = targetHRP.AssemblyLinearVelocity * clampedPing
            
            local goalCFrame = CFrame.new(targetHRP.Position + predictionVector) * targetHRP.CFrame.Rotation * CFrame.new(0, 0, 3) 
            HRP.CFrame = HRP.CFrame:Lerp(goalCFrame, 0.45) 
            
            HRP.AssemblyLinearVelocity = targetHRP.AssemblyLinearVelocity
            HRP.AssemblyAngularVelocity = Vector3.zero
        end 
    end 

    -- [[ PING-PREDICTED AUTO AIM ]]
    if State.Aim then 
        local target = GetClosestPlayer() 
        if target and target:FindFirstChild("Head") then 
            local clampedPing = math.clamp(safePing, 0, 0.25)
            local predictionVector = target.Head.AssemblyLinearVelocity * clampedPing
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position + predictionVector) 
        end 
    end 
end) 

-- [[ 7. HEARTBEAT LOOP ]] 
local lastAntiAfkTick = 0
local lastJump = 0 
local lastJitterTime = 0
local JITTER_INTERVAL_MIN = 5
local JITTER_INTERVAL_MAX = 10

RunService.Heartbeat:Connect(function(deltaTime) 
    local Char = LP.Character; local HRP = Char and Char:FindFirstChild("HumanoidRootPart"); local Hum = Char and Char:FindFirstChild("Humanoid") 
    if not HRP or not Hum then return end 
    
    if State.Spin then HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(30), 0) end 
    
    if State.Speed and not State.Fly and not State.Freecam then
        Hum.WalkSpeed = Config.WalkSpeed 
        
        if Hum.MoveDirection.Magnitude > 0 and Hum.FloorMaterial ~= Enum.Material.Air then
            local targetSpeed = Config.WalkSpeed
            local jitter = Vector3.new(
                math.random(-4, 4) / 10,
                0,
                math.random(-4, 4) / 10
            )
            local jitterDir = jitter.Magnitude > 0 and jitter.Unit or Vector3.zero
            local wishVel = (Hum.MoveDirection + jitterDir * 0.15) * targetSpeed
            
            local current = HRP.AssemblyLinearVelocity
            
            local ping = LP:GetNetworkPing() * 1000
            local alpha = 0.18 - (ping / 2000)  
            alpha = math.clamp(alpha, 0.09, 0.22)
            
            local newVel = current:Lerp(Vector3.new(wishVel.X, current.Y, wishVel.Z), alpha)
            HRP.AssemblyLinearVelocity = newVel
        end
    end
    
    if State.HighJump and not State.Fly then
        Hum.UseJumpPower = true
        Hum.JumpPower = Config.JumpPower
    elseif not State.HighJump and Hum.JumpPower == Config.JumpPower then
        Hum.UseJumpPower = true
        Hum.JumpPower = 50
    end
    
    if State.Bhop and not State.Fly and not State.Freecam and Hum.FloorMaterial ~= Enum.Material.Air and Hum.MoveDirection.Magnitude > 0 then
        if tick() - lastJump > 0.085 + math.random(-10, 10) / 1000 then
            Hum.Jump = true
            lastJump = tick()
        end
    end
    
    if State.NoFallDamage then
        if Hum:GetState() == Enum.HumanoidStateType.Freefall then
            if HRP.AssemblyLinearVelocity.Y < -45 then
                HRP.AssemblyLinearVelocity = Vector3.new(
                    HRP.AssemblyLinearVelocity.X,
                    -5,  
                    HRP.AssemblyLinearVelocity.Z
                )
            end
        end
    end

    if State.AntiAFK and Hum.MoveDirection.Magnitude == 0 then
        if tick() - lastAntiAfkTick > 1 then
            Hum:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
            lastAntiAfkTick = tick()
        end
    end

    -- [[ JITTER HITBOX SIZE ]]
    if State.Hitbox then
        local now = tick()
        if now - lastJitterTime > math.random(JITTER_INTERVAL_MIN, JITTER_INTERVAL_MAX) then
            lastJitterTime = now
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head and head:IsA("BasePart") and head.Size.X >= 15 then 
                        local baseSize = 18 
                        local jitterAmount = math.random(-50, 50) / 100 -- Від -0.5 до +0.5
                        local newSize = math.clamp(baseSize + jitterAmount, 17.5, 18.5)
                        head.Size = Vector3.new(newSize, newSize, newSize)
                    end
                end
            end
        end
    end
end) 

-- [[ 📶 SOFT VELOCITY SPOOFING FAKE LAG ]]
task.spawn(function()
    while true do
        if State.FakeLag then
            local Char = LP.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChild("Humanoid")
            
            if HRP and Hum and Hum.MoveDirection.Magnitude > 0 then
                local realVel = HRP.AssemblyLinearVelocity
                
                -- Soft spoof: не різкий стоп на -150, а м'який глайд в протилежну сторону або сповільнення
                -- Це виглядає як типова втрата пакетів, а не очевидний експлоїт
                local spoofVector = Hum.MoveDirection * -math.random(15, 30) 
                HRP.AssemblyLinearVelocity = spoofVector
                
                -- Зменшений час спуфінгу (50-60% uptime замість 100%)
                task.wait(math.random(30, 60) / 1000) 
                
                if HRP then HRP.AssemblyLinearVelocity = realVel end
                
                -- Нормальний рух між лагами
                task.wait(math.random(100, 200) / 1000) 
            else
                task.wait(0.1)
            end
        else
            task.wait(0.5) 
        end
    end
end)

-- [[ ⚙️ ФІЗИЧНИЙ ЦИКЛ (ВИРІШЕННЯ ПРОБЛЕМИ З ПАРАЛІЧЕМ) ]]
local lastPos = Vector3.zero
RunService.Stepped:Connect(function() 
    local Char = LP.Character
    
    if State.Noclip and Char then 
        local HRP = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChild("Humanoid")
        
        for _, v in pairs(Char:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end 
        
        if HRP and Hum then
            if (HRP.Position - lastPos).Magnitude < 0.1 and Hum.MoveDirection.Magnitude > 0 then
                HRP.CFrame = HRP.CFrame + Hum.MoveDirection * 0.4
            end
            lastPos = HRP.Position
        end
    elseif Char and Char:FindFirstChild("HumanoidRootPart") then
        lastPos = Char.HumanoidRootPart.Position
    end 
    
    if State.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LP and p.Character then 
                local head = p.Character:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    head.CanCollide = false
                end
            end
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
