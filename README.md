-- [[ V260.40: OMNI-REBORN - SUPREME HITBOX ENFORCER ]]
-- [[ AUTO-RESPAWN CATCH | REAL PING | AUTO-MAGNET SWITCH ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ CONFIGURATION ]]
local Config = { 
    FlySpeed = 55, 
    WalkSpeed = 85, 
    JumpPower = 125,
    HitboxSize = Vector3.new(18, 18, 18) -- Оптимальний розмір
}

local State = {
    Fly = false, 
    Aim = false, 
    ShadowLock = false, 
    Noclip = false, 
    Hitbox = false, 
    Speed = false, 
    Bhop = false, 
    ESP = false, 
    Spin = false, 
    HighJump = false, 
    Potato = false
}

local LockedTarget = nil
local Buttons = {}

-- [[ 1. GUI SYSTEM ]]
pcall(function() 
    if game:GetService("CoreGui"):FindFirstChild("V259_Omni") then 
        game:GetService("CoreGui").V259_Omni:Destroy() 
    end 
end)

local Screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
Screen.Name = "V259_Omni"
Screen.ResetOnSpawn = false

-- >>> КНОПКА "M" <<<
local MToggle = Instance.new("TextButton", Screen)
MToggle.Size = UDim2.new(0, 45, 0, 45); MToggle.Position = UDim2.new(0, 10, 0.45, 0)
MToggle.BackgroundColor3 = Color3.new(1,1,1); MToggle.Text = "M"; MToggle.TextColor3 = Color3.new(0,0,0)
MToggle.Font = Enum.Font.GothamBlack; MToggle.TextSize = 22; Instance.new("UICorner", MToggle)

-- >>> ПАНЕЛЬ СТАТИСТИКИ <<<
local StatsFrame = Instance.new("Frame", Screen)
StatsFrame.Size = UDim2.new(0, 110, 0, 45)
StatsFrame.Position = UDim2.new(1, -125, 0, 15)
StatsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StatsFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", StatsFrame)
local StatsStroke = Instance.new("UIStroke", StatsFrame)
StatsStroke.Color = Color3.new(1, 1, 1); StatsStroke.Thickness = 1.5

local FPSLabel = Instance.new("TextLabel", StatsFrame)
FPSLabel.Size = UDim2.new(1, 0, 0.5, 0); FPSLabel.Position = UDim2.new(0, 0, 0, 2)
FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.new(1,1,1)
FPSLabel.Font = Enum.Font.GothamBold; FPSLabel.TextSize = 13; FPSLabel.Text = "FPS: ..."

local PingLabel = Instance.new("TextLabel", StatsFrame)
PingLabel.Size = UDim2.new(1, 0, 0.5, 0); PingLabel.Position = UDim2.new(0, 0, 0.5, -2)
PingLabel.BackgroundTransparency = 1; PingLabel.TextColor3 = Color3.new(1,1,1)
PingLabel.Font = Enum.Font.GothamBold; PingLabel.TextSize = 13; PingLabel.Text = "Ping: ..."

-- >>> ГОЛОВНЕ МЕНЮ <<<
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 230, 0, 520); Main.Position = UDim2.new(0.5, -115, 0.5, -260)
Main.BackgroundColor3 = Color3.new(0,0,0); Main.Visible = false; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Color3.new(1,1,1); Stroke.Thickness = 2

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -10, 1, -20); Scroll.Position = UDim2.new(0, 5, 0, 10)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 6); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [[ 2. CORE ENGINES (FPS / PING / HITBOX) ]]
local FrameLog = {}
task.spawn(function()
    while true do
        -- Stats Update
        local now = tick()
        for i = #FrameLog, 1, -1 do if FrameLog[i] < now - 1 then table.remove(FrameLog, i) end end
        local fps = #FrameLog
        local ping = math.floor(LP:GetNetworkPing() * 1000)
        
        FPSLabel.Text = "FPS: " .. fps
        PingLabel.Text = "Ping: " .. ping .. "ms"
        
        -- Hitbox Enforcement (Force Loop)
        if State.Hitbox then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head and head:IsA("BasePart") then
                        head.Size = Config.HitboxSize
                        head.Transparency = 0.5
                        head.CanCollide = false
                        head.Massless = true
                    end
                end
            end
        end
        task.wait(0.1) -- Висока частота перевірки для стабільності
    end
end)

-- [[ 3. HELPERS & ESP ]]
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
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("OmniTag") then p.Character.Head.OmniTag:Destroy() end
        end
    end
end

local function UpdateESP(Player)
    if not Player.Character or not State.ESP then return end
    local Highlight = Player.Character:FindFirstChild("OmniHighlight") or Instance.new("Highlight", Player.Character)
    Highlight.Name = "OmniHighlight"; Highlight.FillColor = Color3.new(1, 0, 0); Highlight.Enabled = true

    local Head = Player.Character:FindFirstChild("Head")
    if Head then
        local Billboard = Head:FindFirstChild("OmniTag") or Instance.new("BillboardGui", Head)
        Billboard.Name = "OmniTag"; Billboard.Size = UDim2.new(0, 200, 0, 50); Billboard.AlwaysOnTop = true
        local TagLabel = Billboard:FindFirstChild("Label") or Instance.new("TextLabel", Billboard)
        TagLabel.Name = "Label"; TagLabel.BackgroundTransparency = 1; TagLabel.Size = UDim2.new(1, 0, 1, 0)
        TagLabel.TextColor3 = Color3.new(1, 1, 1); TagLabel.Font = Enum.Font.GothamBold
        local hum = Player.Character:FindFirstChild("Humanoid")
        local health = hum and math.floor(hum.Health) or 0
        local dist = math.floor((LP.Character.HumanoidRootPart.Position - Head.Position).Magnitude)
        TagLabel.Text = Player.Name .. "\n[" .. health .. " HP] [" .. dist .. "m]"
    end
end

-- [[ 4. PHYSICAL MAGNET ]]
local MagBodyPos = Instance.new("BodyPosition")
MagBodyPos.P = 45000; MagBodyPos.D = 800; MagBodyPos.MaxForce = Vector3.zero
local MagBodyGyr = Instance.new("BodyGyro")
MagBodyGyr.P = 45000; MagBodyGyr.MaxTorque = Vector3.zero

-- [[ 5. TOGGLE SYSTEM ]]
local function Toggle(Name)
    State[Name] = not State[Name]
    local Char = LP.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    
    if Name == "ESP" and not State.ESP then ClearESP() end

    -- Повернення нормальних хітбоксів при вимкненні
    if Name == "Hitbox" and not State.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(1,1,1)
                p.Character.Head.Transparency = 0
                p.Character.Head.CanCollide = true
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

    if Name == "Noclip" and not State.Noclip and Char then
        for _, v in pairs(Char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end
    end

    if Name == "Potato" and State.Potato then
        Lighting.GlobalShadows = false
        for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.Plastic end end
    end

    if Buttons[Name] then
        Buttons[Name].BackgroundColor3 = State[Name] and Color3.new(1,1,1) or Color3.fromRGB(30, 30, 35)
        Buttons[Name].TextColor3 = State[Name] and Color3.new(0,0,0) or Color3.new(1,1,1)
    end
end

-- [[ 6. UI CONSTRUCTION ]]
local function CreateSlider(Text, Min, Max, Default, Callback)
    local Container = Instance.new("Frame", Scroll); Container.Size = UDim2.new(0.9, 0, 0, 50); Container.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Container); Label.Size = UDim2.new(1, 0, 0, 20); Label.Text = Text .. ": " .. Default; Label.TextColor3 = Color3.new(1,1,1); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.GothamBold; Label.TextSize = 10
    local SliderBG = Instance.new("Frame", Container); SliderBG.Size = UDim2.new(1, 0, 0, 6); SliderBG.Position = UDim2.new(0, 0, 0, 30); SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 55); Instance.new("UICorner", SliderBG)
    local Fill = Instance.new("Frame", SliderBG); Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Fill)
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0); local value = math.floor(Min + (pos * (Max - Min))); Label.Text = Text .. ": " .. value; Callback(value)
    end
    local dragging = false
    SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(input) end end)
    UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

CreateSlider("🚀 FLY SPEED", 0, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
CreateSlider("⚡ WALK SPEED", 16, 200, Config.WalkSpeed, function(v) Config.WalkSpeed = v end)
CreateSlider("⬆️ JUMP POWER", 50, 500, Config.JumpPower, function(v) Config.JumpPower = v end)

local function CreateBtn(Text, LogicName)
    local Btn = Instance.new("TextButton", Scroll); Btn.Size = UDim2.new(0.9, 0, 0, 36); Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Btn.Text = Text; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function() Toggle(LogicName) end); Buttons[LogicName] = Btn
end

local Names = {"🕊️ FLY [F]", "🎯 AUTO AIM [G]", "💀 MAGNET", "👻 NOCLIP [V]", "🥊 HITBOX", "⚡ SPEED", "🐇 BHOP", "📦 ADVANCED ESP", "🌀 SPIN", "⬆️ HIGH JUMP", "🥔 POTATO"}
local Logic = {"Fly", "Aim", "ShadowLock", "Noclip", "Hitbox", "Speed", "Bhop", "ESP", "Spin", "HighJump", "Potato"}
for i, n in ipairs(Names) do CreateBtn(n, Logic[i]) end

MToggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

-- [[ 7. FINAL LOGIC LOOP ]]
RunService.RenderStepped:Connect(function()
    table.insert(FrameLog, tick())
    local Char = LP.Character; local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    -- [[ AUTO-SWITCH MAGNET LOGIC ]]
    if State.ShadowLock then
        -- Перевіряємо, чи жива ціль
        local IsAlive = LockedTarget 
                        and LockedTarget.Parent 
                        and LockedTarget:FindFirstChild("Humanoid") 
                        and LockedTarget.Humanoid.Health > 0
        
        -- Якщо цілі немає або вона померла, шукаємо нову
        if not IsAlive then
            LockedTarget = GetClosestPlayer()
        end

        -- Якщо ціль знайдена і жива - притягуємося
        if LockedTarget and LockedTarget:FindFirstChild("HumanoidRootPart") then
            MagBodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            MagBodyGyr.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            MagBodyPos.Position = LockedTarget.HumanoidRootPart.Position + (LockedTarget.HumanoidRootPart.CFrame.LookVector * -3)
            MagBodyGyr.CFrame = LockedTarget.HumanoidRootPart.CFrame
            HRP.RotVelocity = Vector3.zero
        else
            -- Якщо нікого немає поруч, вимикаємо силу, щоб не застрягти
            MagBodyPos.MaxForce = Vector3.zero
            MagBodyGyr.MaxTorque = Vector3.zero
        end
    end

    if State.Aim then
        local target = GetClosestPlayer()
        if target and target:FindFirstChild("Head") then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position) end
    end

    if State.Fly then
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        HRP.Velocity = move * Config.FlySpeed
    end

    if State.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then UpdateESP(p) end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local Char = LP.Character; local HRP = Char and Char:FindFirstChild("HumanoidRootPart"); local Hum = Char and Char:FindFirstChild("Humanoid")
    if not HRP or not Hum then return end
    if State.Spin then HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(30), 0) end
    if UIS:IsKeyDown(Enum.KeyCode.Space) and Hum.FloorMaterial ~= Enum.Material.Air then
        if State.HighJump then HRP.Velocity = Vector3.new(HRP.Velocity.X, Config.JumpPower, HRP.Velocity.Z)
        elseif State.Bhop then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    if State.Speed and Hum.MoveDirection.Magnitude > 0 and not State.Fly then
        local s = (Hum.FloorMaterial == Enum.Material.Air) and 16 or Config.WalkSpeed
        HRP.Velocity = Vector3.new(Hum.MoveDirection.X * s, HRP.Velocity.Y, Hum.MoveDirection.Z * s)
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- Keybinds
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.F then Toggle("Fly") end
    if i.KeyCode == Enum.KeyCode.G then Toggle("Aim") end
    if i.KeyCode == Enum.KeyCode.V then Toggle("Noclip") end
    if i.KeyCode == Enum.KeyCode.M then Main.Visible = not Main.Visible end
end)
