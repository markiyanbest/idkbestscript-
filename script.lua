-- [[ V266.0 — OMNI REBORN | ANTI-DETECT + SAVE CONFIG + NEW UI ]]

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

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- SAVE SYSTEM
-- ============================================================
local SAVE_KEY = "OmniV266_Config"

local function SaveConfig(cfg, binds, state)
	pcall(function()
		local data = {
			Config = {
				FlySpeed    = cfg.FlySpeed,
				WalkSpeed   = cfg.WalkSpeed,
				CFrameSpeed = cfg.CFrameSpeed,
				StrafeMult  = cfg.StrafeMult,
				JumpPower   = cfg.JumpPower,
				BhopPower   = cfg.BhopPower,
				HitboxSize  = cfg.HitboxSize,
				AimFOV      = cfg.AimFOV,
				AimSmooth   = cfg.AimSmooth,
				AimPart     = cfg.AimPart,
				Humanize    = cfg.Humanize,
				AccelCurve  = cfg.AccelCurve,
			},
			Binds = {},
		}
		for k, v in pairs(binds) do
			data.Binds[k] = tostring(v):gsub("Enum.KeyCode.", "")
		end
		writefile(SAVE_KEY .. ".json", HttpService:JSONEncode(data))
	end)
end

local function LoadConfig()
	local ok, raw = pcall(readfile, SAVE_KEY .. ".json")
	if not ok or not raw then return nil end
	local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok2 or not data then return nil end
	return data
end

-- ============================================================
-- CLEANUP
-- ============================================================
pcall(function()
	for _, sg in pairs({game:GetService("CoreGui"), LP:WaitForChild("PlayerGui")}) do
		for _, v in pairs(sg:GetChildren()) do
			if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then v:Destroy() end
		end
	end
end)

local SafeGroup = "OmniSafe5"
pcall(function()
	if not pcall(function() PhysicsService:GetCollisionGroupId(SafeGroup) end) then
		PhysicsService:RegisterCollisionGroup(SafeGroup)
	end
	PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Default", false)
end)

local function RndStr(n)
	local t = {}
	for i = 1, n do t[i] = string.char(math.random(97, 122)) end
	return table.concat(t)
end
local function Notify(t, tx, d)
	pcall(function() StarterGui:SetCore("SendNotification", {Title=t, Text=tx, Duration=d or 2}) end)
end
local function SafeDel(o)
	pcall(function() if o and o.Parent then o:Destroy() end end)
end

local IsMob = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsTab = UIS.TouchEnabled
local Blur  = Instance.new("BlurEffect"); Blur.Size = 0; Blur.Parent = Lighting

local Controls, ControlsOK = nil, false
task.spawn(function()
	if not game:IsLoaded() then game.Loaded:Wait() end
	task.wait(1.5)
	pcall(function()
		Controls = require(LP.PlayerScripts:WaitForChild("PlayerModule", 8)):GetControls()
		ControlsOK = true
	end)
end)

-- ============================================================
-- CONFIG (defaults)
-- ============================================================
local Config = {
	FlySpeed    = 55,
	WalkSpeed   = 30,
	CFrameSpeed = 60,
	StrafeMult  = 0.75,
	JumpPower   = 125,
	BhopPower   = 62,
	HitboxSize  = 5,
	AimFOV      = 200,
	AimSmooth   = 0.18,
	AimPart     = "Head",
	Humanize    = true,
	AccelCurve  = true,
}

local Binds = {
	Fly        = Enum.KeyCode.F,
	Aim        = Enum.KeyCode.G,
	Noclip     = Enum.KeyCode.V,
	SilentAim  = Enum.KeyCode.B,
	ToggleMenu = Enum.KeyCode.M,
}

-- Load saved config
do
	local saved = LoadConfig()
	if saved then
		if saved.Config then
			for k, v in pairs(saved.Config) do
				if Config[k] ~= nil then Config[k] = v end
			end
		end
		if saved.Binds then
			for k, v in pairs(saved.Binds) do
				pcall(function()
					Binds[k] = Enum.KeyCode[v]
				end)
			end
		end
	end
end

local State = {
	Fly=false, Aim=false, SilentAim=false, ShadowLock=false,
	Noclip=false, Hitbox=false, Speed=false, Bhop=false,
	ESP=false, Spin=false, HighJump=false, Potato=false,
	FakeLag=false, Freecam=false, NoFallDamage=false,
	AntiAFK=false, AntiKick=false, InfiniteJump=false,
}

local LockedTarget  = nil
local FrameLog      = {}
local lastPing, pingTk = 0, 0
local silentActive  = false
local waitingBind   = nil
local MobUp, MobDn = false, false
local FC_P, FC_Y   = 0, 0
local spReset, lastSpCk = false, 0
local lastBhop      = 0
local ncStuck       = 0
local lastNcPos     = Vector3.zero
local fakeLagThr    = nil
local AllRows       = {}
local TabPages      = {}
local TabBtns       = {}
local CurTab        = "Combat"

-- Speed anti-detect vars
local curSpeed   = 16
local speedTimer = 0
local accel      = 0
local maxAccel   = 1.2

local aimTarget     = nil
local aimLastSwitch = 0
local aimLocked     = false
local aimSwitchCD   = 0.35
local aimLostFrames = 0

local ncRay  = RaycastParams.new(); ncRay.FilterType  = Enum.RaycastFilterType.Exclude
local aimRay = RaycastParams.new(); aimRay.FilterType = Enum.RaycastFilterType.Exclude

-- ============================================================
-- ANTI-KICK HOOK
-- ============================================================
local akOn = false
pcall(function()
	local mt  = getrawmetatable(game)
	local old = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = newcclosure(function(self, ...)
		local m = getnamecallmethod()
		if akOn then
			if m == "Kick" and self == LP then return end
			if m == "FireServer" then
				local a = {...}
				if type(a[1]) == "string" then
					local l = a[1]:lower()
					if l:find("kick") or l:find("ban") then return end
				end
			end
		end
		if silentActive and self == Workspace then
			local args = {...}
			local tgt  = _GetBestTargetSilent and _GetBestTargetSilent()
			local hd   = tgt and FindAimPart and FindAimPart(tgt)
			if hd then
				local o = Camera.CFrame.Position
				if m == "Raycast" and typeof(args[2]) == "Vector3" then
					args[2] = (hd.Position - o).Unit * args[2].Magnitude
				elseif (m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRay") and typeof(args[1]) == "Ray" then
					args[1] = Ray.new(o, (hd.Position - o).Unit * args[1].Direction.Magnitude)
				end
			end
			return old(self, unpack(args))
		end
		return old(self, ...)
	end)
	setreadonly(mt, true)
end)

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

local function FindAimPart(char)
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
	local result = Workspace:Raycast(origin, dir.Unit * (dist - 0.5), aimRay)
	if not result then return true end
	if result.Instance:IsDescendantOf(char) then return true end
	if result.Instance.Transparency >= 0.8 then return true end
	return false
end

local function ScreenDist(part)
	if not part then return math.huge end
	local pos, on = Camera:WorldToViewportPoint(part.Position)
	if not on then return math.huge end
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	return (Vector2.new(pos.X, pos.Y) - center).Magnitude
end

local function FindNewTarget()
	local fov  = Config.AimFOV
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

_GetBestTargetSilent = function() return GetBestAimTarget() end

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
				bb.Size        = UDim2.new(0, 170, 0, 46)
				bb.StudsOffset = Vector3.new(0, 3.4, 0)
				bb.AlwaysOnTop = true
				bb.MaxDistance = 500
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
			local mx2 = math.max(math.floor(hm.MaxHealth), 1)
			local ds = my and math.floor((my.Position - hd.Position).Magnitude) or 0
			local r  = hp / mx2
			ca.lbl.Text = string.format("[%s]\nHP:%d/%d %dm", p.Name, hp, mx2, ds)
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
	part.Size         = Vector3.new(s, s, s)
	part.Transparency = 0.7
	part.CanCollide   = false
	part.Massless     = true
end
local function RestoreHB()
	for p, o in pairs(hbParts) do
		pcall(function()
			if p and p.Parent then
				p.Size = o.S; p.Transparency = o.T
				p.CanCollide = o.C; p.Massless = o.M
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
					and v.Size.Magnitude > 0.3 and v.Size.X < s - 0.2 then
					ApplyHB(v)
				end
			end
		end
	end
end)

-- ============================================================
-- POTATO
-- ============================================================
local savedShd, savedQ = true, 1
local function DoPotato()
	savedShd = Lighting.GlobalShadows
	savedQ   = settings().Rendering.QualityLevel
	Lighting.GlobalShadows = false
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if v:IsA("BasePart") then v.CastShadow = false; v.Reflectance = 0
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
		end)
	end
end
local function UndoPotato()
	Lighting.GlobalShadows = savedShd
	settings().Rendering.QualityLevel = savedQ
	for _, v in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if v:IsA("BasePart") then v.CastShadow = true
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = true end
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
		H.PlatformStand = false
		H.WalkSpeed = 16
		pcall(function() H.UseJumpPower = true; H.JumpPower = 50; H.JumpHeight = 7.2 end)
	end
	if R then
		R.Anchored = false
		for _, v in pairs(R:GetChildren()) do
			if v:IsA("BodyMover") then SafeDel(v) end
		end
	end
	for _, v in pairs(C:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = true; v.CollisionGroup = "Default"
		end
	end
	ncStuck = 0; lastNcPos = Vector3.zero
end

-- ============================================================
-- TOGGLE
-- ============================================================
local function UpdVis(nm)
	local d = AllRows[nm]; if not d then return end
	local on = State[nm]
	if d.swBG then
		TweenService:Create(d.swBG, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
			BackgroundColor3 = on and Color3.fromRGB(0, 210, 110) or Color3.fromRGB(45, 45, 60)
		}):Play()
	end
	if d.swDot then
		TweenService:Create(d.swDot, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
			Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		}):Play()
	end
	if d.accent then
		TweenService:Create(d.accent, TweenInfo.new(0.18), {
			BackgroundColor3 = on and Color3.fromRGB(0, 210, 110) or Color3.fromRGB(55, 55, 72)
		}):Play()
	end
	if d.row then
		TweenService:Create(d.row, TweenInfo.new(0.18), {
			BackgroundColor3 = on and Color3.fromRGB(22, 38, 30) or Color3.fromRGB(18, 18, 28)
		}):Play()
	end
	if d.lbl then
		d.lbl.TextColor3 = on and Color3.fromRGB(220, 255, 235) or Color3.fromRGB(190, 190, 210)
	end
end

local function Toggle(nm)
	State[nm] = not State[nm]
	local C = LP.Character
	local R = C and C:FindFirstChild("HumanoidRootPart")
	local H = C and C:FindFirstChildOfClass("Humanoid")

	if not State[nm] then
		if nm == "Fly" then
			if R then R.Anchored = false; R.AssemblyLinearVelocity = Vector3.zero end
			if H then H.PlatformStand = false end
		end
		if nm == "Speed" then
			spReset = false; accel = 0
			if H then H.WalkSpeed = 16 end
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
		if nm == "Freecam"   then
			Camera.CameraType = Enum.CameraType.Custom
			if H then Camera.CameraSubject = H end
			if R then R.Anchored = false end
		end
		if nm == "Spin" and R then
			for _, v in pairs(R:GetChildren()) do
				if v.Name == "SpinAV" then SafeDel(v) end
			end
		end
		if nm == "FakeLag" and R then R.Anchored = false end
		if nm == "Aim" then aimTarget = nil; aimLocked = false; aimLostFrames = 0 end
	end

	if State[nm] then
		if nm == "SilentAim" then silentActive = true end
		if nm == "AntiKick"  then akOn = true end
		if nm == "Potato"    then DoPotato() end
		if nm == "ShadowLock" then LockedTarget = GetClosestDist() end
		if nm == "Fly" and H then H.PlatformStand = false end
		if nm == "Speed" and H then H.WalkSpeed = 16; spReset = false; lastSpCk = 0; accel = 0 end
		if nm == "HighJump" and H then
			pcall(function() H.UseJumpPower = false; H.JumpHeight = 7.2 end)
		end
		if nm == "Spin" and R then
			local av = Instance.new("BodyAngularVelocity", R)
			av.Name = "SpinAV"
			av.MaxTorque = Vector3.new(0, math.huge, 0)
			av.AngularVelocity = Vector3.new(0, 22, 0)
			av.P = 1500
		end
		if nm == "Freecam" then
			Camera.CameraSubject = nil
			Camera.CameraType    = Enum.CameraType.Scriptable
			local x, y = Camera.CFrame:ToEulerAnglesYXZ()
			FC_P = x; FC_Y = y
			if R then R.Anchored = true end
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
					else task.wait(0.15) end
				end
				fakeLagThr = nil
			end)
		end
		if nm == "Noclip" then ncStuck = 0; lastNcPos = Vector3.zero end
		if nm == "Aim" then aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimLastSwitch = 0 end
	end

	UpdVis(nm)
	-- Автозбереження
	SaveConfig(Config, Binds, State)
	Notify(nm, State[nm] and "ON ✓" or "OFF ✗", 1)
end

-- ============================================================
-- ANTI-AFK
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

LP.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart", 5)
	MobUp = false; MobDn = false; spReset = false; ncStuck = 0; accel = 0
	aimTarget = nil; aimLocked = false; aimLostFrames = 0
	for _, n in pairs({"Fly","Noclip","Freecam","Spin","FakeLag"}) do
		if State[n] then State[n] = false; UpdVis(n) end
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		Camera.CameraType    = Enum.CameraType.Custom
		Camera.CameraSubject = hum
		task.wait(0.5)
		if State.Speed    then hum.WalkSpeed = 16 end
		if State.HighJump then
			pcall(function() hum.UseJumpPower = false; hum.JumpHeight = 7.2 end)
		end
	end
end)

-- ============================================================
-- DIRECTION HELPER
-- ============================================================
local function GetDir()
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
	return mx, mz
end

-- ============================================================
-- GUI PALETTE (темна неонова тема)
-- ============================================================
local GuiP = LP:WaitForChild("PlayerGui")
pcall(function() local c = game:GetService("CoreGui"); local _ = c.Name; GuiP = c end)

local Scr = Instance.new("ScreenGui", GuiP)
Scr.Name           = RndStr(10)
Scr.ResetOnSpawn   = false
Scr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Scr.IgnoreGuiInset = true
Instance.new("BoolValue", Scr).Name = "OmniMarker"

-- Кольорова схема: темно-синьо-фіолетова + неоново-зелений акцент
local C0 = {
	BG      = Color3.fromRGB(8,   9,  15),   -- основний фон
	CARD    = Color3.fromRGB(14,  15, 24),   -- картка
	BTN     = Color3.fromRGB(19,  20, 32),   -- кнопка
	DARK    = Color3.fromRGB(10,  11, 18),   -- темна зона
	ACC     = Color3.fromRGB(0,  220, 120),  -- акцент зелений
	ACC2    = Color3.fromRGB(90, 120, 255),  -- акцент синій
	TXT     = Color3.fromRGB(220, 225, 240), -- основний текст
	DIM     = Color3.fromRGB(100, 105, 130), -- другорядний текст
	BRD     = Color3.fromRGB(35,  36,  55),  -- бордер
	GRN     = Color3.fromRGB(0,  220, 110),
	WHT     = Color3.fromRGB(255, 255, 255),
	SWOFF   = Color3.fromRGB(40,  40,  58),
	TABA    = Color3.fromRGB(24,  25,  40),
	ONBG    = Color3.fromRGB(14,  30,  22),
	HDR     = Color3.fromRGB(12,  13,  20),
	TRACK   = Color3.fromRGB(28,  29,  45),
	DANGER  = Color3.fromRGB(220,  60, 60),
	WARN    = Color3.fromRGB(255, 190, 40),
}

local VP  = Camera.ViewportSize
local MW  = IsMob and math.min(320, VP.X - 20) or 318
local MH  = IsMob and math.min(580, VP.Y - 80) or 540
local BH  = IsMob and 46 or 38
local FS  = IsMob and 13 or 11
local MBS = IsMob and 56 or 46

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
fovStroke.Color     = C0.ACC
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.25

-- crosshair dots
for _, ang in ipairs({0, 90, 180, 270}) do
	local d = Instance.new("Frame", fovCircle)
	local rad = math.rad(ang)
	local r = Config.AimFOV
	d.Size             = UDim2.new(0, 4, 0, 4)
	d.Position         = UDim2.new(0.5, math.cos(rad)*r - 2, 0.5, math.sin(rad)*r - 2)
	d.BackgroundColor3 = C0.ACC
	d.BorderSizePixel  = 0
	d.ZIndex           = 11
	Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
end

local tgtInfo = Instance.new("TextLabel", Scr)
tgtInfo.Size                   = UDim2.new(0, 210, 0, 24)
tgtInfo.Position               = UDim2.new(0.5, -105, 0.5, -Config.AimFOV - 36)
tgtInfo.BackgroundColor3       = Color3.fromRGB(8, 8, 14)
tgtInfo.BackgroundTransparency = 0.1
tgtInfo.BorderSizePixel        = 0
tgtInfo.TextColor3             = C0.GRN
tgtInfo.Font                   = Enum.Font.GothamBold
tgtInfo.TextSize               = 11
tgtInfo.Text                   = ""
tgtInfo.Visible                = false
tgtInfo.ZIndex                 = 12
Instance.new("UICorner", tgtInfo).CornerRadius = UDim.new(0, 7)
local tgtStroke = Instance.new("UIStroke", tgtInfo)
tgtStroke.Color     = C0.ACC
tgtStroke.Thickness = 1

local function UpdateFOVCircle()
	local r = Config.AimFOV
	fovCircle.Size     = UDim2.new(0, r*2, 0, r*2)
	fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r)
	tgtInfo.Position   = UDim2.new(0.5, -105, 0.5, -r - 36)
end

-- ============================================================
-- MAIN FRAME
-- ============================================================
local Main = Instance.new("Frame", Scr)
Main.Size             = UDim2.new(0, MW, 0, MH)
Main.Position         = UDim2.new(0.5, -MW/2, 0.5, -MH/2)
Main.BackgroundColor3 = C0.BG
Main.Visible          = false
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color     = C0.BRD
mainStroke.Thickness = 1.5

-- Фонові лінії (декоративно)
local bgLines = Instance.new("Frame", Main)
bgLines.Size = UDim2.new(1, 0, 1, 0)
bgLines.BackgroundTransparency = 1
bgLines.BorderSizePixel = 0
bgLines.ZIndex = 0
for i = 1, 8 do
	local ln = Instance.new("Frame", bgLines)
	ln.Size = UDim2.new(0, 1, 1, 0)
	ln.Position = UDim2.new(i / 9, 0, 0, 0)
	ln.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	ln.BackgroundTransparency = 0.85
	ln.BorderSizePixel = 0
	ln.ZIndex = 0
end

-- TITLEBAR
local TB = Instance.new("Frame", Main)
TB.Size             = UDim2.new(1, 0, 0, 50)
TB.BackgroundColor3 = C0.DARK
TB.BorderSizePixel  = 0
TB.ZIndex           = 5
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 16)
local tbFix = Instance.new("Frame", TB)
tbFix.Size             = UDim2.new(1, 0, 0, 16)
tbFix.Position         = UDim2.new(0, 0, 1, -16)
tbFix.BackgroundColor3 = C0.DARK
tbFix.BorderSizePixel  = 0
tbFix.ZIndex           = 5

-- Горизонтальна лінія під тайтлбаром
local tbLine = Instance.new("Frame", TB)
tbLine.Size             = UDim2.new(1, 0, 0, 1)
tbLine.Position         = UDim2.new(0, 0, 1, -1)
tbLine.BackgroundColor3 = C0.BRD
tbLine.BorderSizePixel  = 0
tbLine.ZIndex           = 6

-- Акцент зліва (вертикальна смуга)
local tAcc = Instance.new("Frame", TB)
tAcc.Size             = UDim2.new(0, 3, 0.6, 0)
tAcc.Position         = UDim2.new(0, 0, 0.2, 0)
tAcc.BackgroundColor3 = C0.ACC
tAcc.BorderSizePixel  = 0
tAcc.ZIndex           = 6
Instance.new("UICorner", tAcc).CornerRadius = UDim.new(0, 2)

-- Іконка + назва
local tIco = Instance.new("TextLabel", TB)
tIco.Size             = UDim2.new(0, 34, 0, 34)
tIco.Position         = UDim2.new(0, 10, 0.5, -17)
tIco.BackgroundTransparency = 1
tIco.Text             = "⚡"
tIco.TextSize         = 20
tIco.Font             = Enum.Font.GothamBlack
tIco.TextColor3       = C0.ACC
tIco.ZIndex           = 6

local tTit = Instance.new("TextLabel", TB)
tTit.Size             = UDim2.new(1, -100, 0, 20)
tTit.Position         = UDim2.new(0, 46, 0, 5)
tTit.BackgroundTransparency = 1
tTit.TextColor3       = C0.WHT
tTit.Font             = Enum.Font.GothamBlack
tTit.TextSize         = 15
tTit.Text             = "OMNI V266"
tTit.TextXAlignment   = Enum.TextXAlignment.Left
tTit.ZIndex           = 6

local tSub = Instance.new("TextLabel", TB)
tSub.Size             = UDim2.new(1, -100, 0, 14)
tSub.Position         = UDim2.new(0, 46, 0, 26)
tSub.BackgroundTransparency = 1
tSub.TextColor3       = C0.DIM
tSub.Font             = Enum.Font.Gotham
tSub.TextSize         = 9
tSub.Text             = IsMob and "MOBILE EDITION" or "ANTI-DETECT EDITION"
tSub.TextXAlignment   = Enum.TextXAlignment.Left
tSub.ZIndex           = 6

-- Close button
local clsB = Instance.new("TextButton", TB)
clsB.Size             = UDim2.new(0, 28, 0, 28)
clsB.Position         = UDim2.new(1, -36, 0.5, -14)
clsB.BackgroundColor3 = Color3.fromRGB(50, 25, 28)
clsB.Text             = "✕"
clsB.TextColor3       = Color3.fromRGB(220, 80, 80)
clsB.Font             = Enum.Font.GothamBold
clsB.TextSize         = 12
clsB.BorderSizePixel  = 0
clsB.AutoButtonColor  = false
clsB.ZIndex           = 8
Instance.new("UICorner", clsB).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", clsB).Color = Color3.fromRGB(180, 40, 40)

local function CloseMenu()
	TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Size     = UDim2.new(0, MW, 0, 0),
		Position = UDim2.new(0.5, -MW/2, 0.5, 0),
	}):Play()
	task.delay(0.18, function() Main.Visible = false end)
end
local function OpenMenu()
	Main.Size     = UDim2.new(0, MW, 0, 0)
	Main.Position = UDim2.new(0.5, -MW/2, 0.5, 0)
	Main.Visible  = true
	TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size     = UDim2.new(0, MW, 0, MH),
		Position = UDim2.new(0.5, -MW/2, 0.5, -MH/2),
	}):Play()
end
clsB.MouseButton1Click:Connect(CloseMenu)

-- STATS BAR
local stB = Instance.new("Frame", Main)
stB.Size             = UDim2.new(1, -16, 0, 22)
stB.Position         = UDim2.new(0, 8, 0, 52)
stB.BackgroundColor3 = C0.CARD
stB.BorderSizePixel  = 0
stB.ZIndex           = 4
Instance.new("UICorner", stB).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", stB).Color        = C0.BRD

local fpsL = Instance.new("TextLabel", stB)
fpsL.Size  = UDim2.new(0.5, 0, 1, 0)
fpsL.BackgroundTransparency = 1
fpsL.TextColor3 = C0.TXT
fpsL.Font       = Enum.Font.GothamBold
fpsL.TextSize   = 10
fpsL.Text       = "FPS: ..."
fpsL.ZIndex     = 5

local pngL = Instance.new("TextLabel", stB)
pngL.Size     = UDim2.new(0.5, 0, 1, 0)
pngL.Position = UDim2.new(0.5, 0, 0, 0)
pngL.BackgroundTransparency = 1
pngL.TextColor3 = C0.TXT
pngL.Font       = Enum.Font.GothamBold
pngL.TextSize   = 10
pngL.Text       = "Ping: ..."
pngL.ZIndex     = 5

-- TABS
local tabY  = 76
local tabFr = Instance.new("Frame", Main)
tabFr.Size             = UDim2.new(1, -12, 0, 34)
tabFr.Position         = UDim2.new(0, 6, 0, tabY)
tabFr.BackgroundColor3 = C0.DARK
tabFr.BorderSizePixel  = 0
tabFr.ZIndex           = 4
Instance.new("UICorner", tabFr).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", tabFr).Color        = C0.BRD

local tNames = {"Combat","Move","Misc","Config"}
local tIcons = {"⚔️","🚀","🔧","⚙️"}
local tW     = 1 / #tNames

local function SwitchTab(name)
	CurTab = name
	for n, pg in pairs(TabPages) do pg.Visible = (n == name) end
	for n, bt in pairs(TabBtns) do
		local a = (n == name)
		TweenService:Create(bt, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
			BackgroundColor3       = a and C0.TABA or Color3.fromRGB(0,0,0),
			BackgroundTransparency = a and 0 or 1,
		}):Play()
		bt.TextColor3 = a and C0.ACC or C0.DIM
		bt.FontFace   = a and Font.fromEnum(Enum.Font.GothamBlack) or Font.fromEnum(Enum.Font.GothamBold)
	end
end

for i, n in ipairs(tNames) do
	local b = Instance.new("TextButton", tabFr)
	b.Size                   = UDim2.new(tW, -3, 1, -6)
	b.Position               = UDim2.new((i-1)*tW, 2, 0, 3)
	b.BackgroundColor3       = C0.TABA
	b.BackgroundTransparency = i == 1 and 0 or 1
	b.Text                   = tIcons[i] .. " " .. n
	b.TextColor3             = i == 1 and C0.ACC or C0.DIM
	b.Font                   = i == 1 and Enum.Font.GothamBlack or Enum.Font.GothamBold
	b.TextSize               = IsMob and 11 or 10
	b.BorderSizePixel        = 0
	b.AutoButtonColor        = false
	b.ZIndex                 = 5
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.MouseButton1Click:Connect(function() SwitchTab(n) end)

	-- Підкреслення активного таба
	local underline = Instance.new("Frame", b)
	underline.Name             = "UL"
	underline.Size             = UDim2.new(0.5, 0, 0, 2)
	underline.Position         = UDim2.new(0.25, 0, 1, -3)
	underline.BackgroundColor3 = C0.ACC
	underline.BorderSizePixel  = 0
	underline.BackgroundTransparency = i == 1 and 0 or 1
	underline.ZIndex           = 6
	Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)

	TabBtns[n] = b
end

-- Оновлення підкреслень при перемиканні
local origSwitch = SwitchTab
SwitchTab = function(name)
	origSwitch(name)
	for n, bt in pairs(TabBtns) do
		local ul = bt:FindFirstChild("UL")
		if ul then
			TweenService:Create(ul, TweenInfo.new(0.15), {
				BackgroundTransparency = n == name and 0 or 1
			}):Play()
		end
	end
end

-- ============================================================
-- CONTENT AREA (scrolling)
-- ============================================================
local cY = tabY + 38
local cH = MH - cY - 4

for _, n in ipairs(tNames) do
	local s = Instance.new("ScrollingFrame", Main)
	s.Name                   = n
	s.Size                   = UDim2.new(1, -8, 0, cH)
	s.Position               = UDim2.new(0, 4, 0, cY)
	s.BackgroundTransparency = 1
	s.ScrollBarThickness     = IsMob and 3 or 2
	s.ScrollBarImageColor3   = Color3.fromRGB(80, 80, 110)
	s.BorderSizePixel        = 0
	s.CanvasSize             = UDim2.new(0, 0, 0, 0)
	s.ScrollingDirection     = Enum.ScrollingDirection.Y
	s.Visible                = (n == "Combat")
	s.ElasticBehavior        = Enum.ElasticBehavior.WhenScrollable
	s.ZIndex                 = 3

	local ly = Instance.new("UIListLayout", s)
	ly.Padding             = UDim.new(0, IsMob and 5 or 4)
	ly.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local pd = Instance.new("UIPadding", s)
	pd.PaddingTop    = UDim.new(0, 5)
	pd.PaddingBottom = UDim.new(0, IsMob and 20 or 10)

	ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		s.CanvasSize = UDim2.new(0, 0, 0, ly.AbsoluteContentSize.Y + 24)
	end)
	TabPages[n] = s
end

-- ============================================================
-- DRAGGABLE MAIN
-- ============================================================
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
			local d = inp.Position - ds
			local vp = Camera.ViewportSize
			local nx = math.clamp(dp.X.Offset + d.X, -MW/2, vp.X - MW/2)
			local ny = math.clamp(dp.Y.Offset + d.Y, -MH/2, vp.Y - MH/2)
			Main.Position = UDim2.new(dp.X.Scale, nx, dp.Y.Scale, ny)
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

-- ============================================================
-- EXT STATS PANEL
-- ============================================================
local exS = Instance.new("Frame", Scr)
exS.Size                   = UDim2.new(0, 136, 0, 62)
exS.Position               = UDim2.new(1, -148, 0, 12)
exS.BackgroundColor3       = C0.BG
exS.BackgroundTransparency = 0
exS.BorderSizePixel        = 0
exS.ZIndex                 = 20
Instance.new("UICorner", exS).CornerRadius = UDim.new(0, 12)
local exStroke = Instance.new("UIStroke", exS)
exStroke.Color     = C0.ACC
exStroke.Thickness = 1.5
exStroke.Transparency = 0.3

-- FPS row
local function MkStatRow(parent, ico, lbl, yPos)
	local row = Instance.new("Frame", parent)
	row.Size  = UDim2.new(1, -14, 0, 24)
	row.Position = UDim2.new(0, 7, 0, yPos)
	row.BackgroundTransparency = 1
	row.ZIndex = 21

	local icoL = Instance.new("TextLabel", row)
	icoL.Size  = UDim2.new(0, 18, 1, 0)
	icoL.BackgroundTransparency = 1
	icoL.Text  = ico
	icoL.TextSize = 12
	icoL.Font  = Enum.Font.Gotham
	icoL.TextColor3 = C0.ACC2
	icoL.ZIndex = 22

	local nameL = Instance.new("TextLabel", row)
	nameL.Size  = UDim2.new(0, 38, 1, 0)
	nameL.Position = UDim2.new(0, 20, 0, 0)
	nameL.BackgroundTransparency = 1
	nameL.Text = lbl
	nameL.TextSize = 9
	nameL.Font = Enum.Font.GothamBold
	nameL.TextColor3 = C0.DIM
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.ZIndex = 22

	local valL = Instance.new("TextLabel", row)
	valL.Size  = UDim2.new(1, -60, 1, 0)
	valL.Position = UDim2.new(0, 60, 0, 0)
	valL.BackgroundTransparency = 1
	valL.Text = "..."
	valL.TextSize = 13
	valL.Font = Enum.Font.GothamBlack
	valL.TextColor3 = C0.GRN
	valL.TextXAlignment = Enum.TextXAlignment.Right
	valL.ZIndex = 22

	return valL
end

local eF = MkStatRow(exS, "🖥", "FPS",  6)
local exDiv = Instance.new("Frame", exS)
exDiv.Size = UDim2.new(1, -14, 0, 1)
exDiv.Position = UDim2.new(0, 7, 0, 33)
exDiv.BackgroundColor3 = C0.BRD
exDiv.BorderSizePixel = 0
exDiv.ZIndex = 21
local eP = MkStatRow(exS, "📶", "PING", 36)

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
			local d = inp.Position - exDs
			local nx = exDp.X.Offset + d.X
			local ny = exDp.Y.Offset + d.Y
			exS.Position = UDim2.new(exDp.X.Scale, nx, exDp.Y.Scale, ny)
		end
	end)
	exS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then exDr = false end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then exDr = false end
	end)
end

-- ============================================================
-- M BUTTON (меню)
-- ============================================================
local mB = Instance.new("TextButton", Scr)
mB.Size             = UDim2.new(0, MBS, 0, MBS)
mB.Position         = UDim2.new(0, 10, 0.5, -MBS/2)
mB.BackgroundColor3 = C0.BG
mB.Text             = "M"
mB.TextColor3       = C0.ACC
mB.Font             = Enum.Font.GothamBlack
mB.TextSize         = IsMob and 22 or 18
mB.ZIndex           = 100
mB.AutoButtonColor  = false
mB.BorderSizePixel  = 0
Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 13)
local mSt = Instance.new("UIStroke", mB)
mSt.Thickness = 2; mSt.Color = C0.ACC

-- Пульс-бейдж
local mCnt = Instance.new("Frame", mB)
mCnt.Size             = UDim2.new(0, 18, 0, 18)
mCnt.Position         = UDim2.new(1, -10, 0, -8)
mCnt.BackgroundColor3 = C0.ACC
mCnt.BorderSizePixel  = 0
mCnt.ZIndex           = 102
mCnt.Visible          = false
Instance.new("UICorner", mCnt).CornerRadius = UDim.new(1, 0)
local mCntL = Instance.new("TextLabel", mCnt)
mCntL.Size = UDim2.new(1, 0, 1, 0)
mCntL.BackgroundTransparency = 1
mCntL.TextColor3 = C0.BG
mCntL.Font = Enum.Font.GothamBlack
mCntL.TextSize = 10
mCntL.Text = "0"
mCntL.ZIndex = 103

task.spawn(function()
	while task.wait(0.6) do
		local c = 0
		for _, v in pairs(State) do if v then c += 1 end end
		mCnt.Visible = c > 0
		mCntL.Text = tostring(c)
	end
end)

do
	local dr, ds, dp, mv, mt = false, nil, nil, false, 0
	mB.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dr = true; ds = inp.Position; dp = mB.Position; mv = false; mt = tick()
		end
	end)
	mB.InputChanged:Connect(function(inp)
		if not dr then return end
		if inp.UserInputType == Enum.UserInputType.MouseMovement
			or inp.UserInputType == Enum.UserInputType.Touch then
			local d = inp.Position - ds
			if d.Magnitude > 8 then mv = true end
			mB.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
		end
	end)
	mB.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			if dr and not mv and (tick() - mt) < 0.35 then
				if Main.Visible then CloseMenu() else OpenMenu() end
			end
			dr = false
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then dr = false end
	end)
end

-- ============================================================
-- MOBILE FLY BUTTONS
-- ============================================================
local flyH = Instance.new("Frame", Scr)
flyH.Size                   = UDim2.new(0, 148, 0, 70)
flyH.Position               = UDim2.new(1, -162, 1, -170)
flyH.BackgroundTransparency = 1
flyH.Visible                = false
flyH.ZIndex                 = 50

local flyBG = Instance.new("Frame", flyH)
flyBG.Size                   = UDim2.new(1, 0, 1, 0)
flyBG.BackgroundColor3       = Color3.fromRGB(8, 9, 15)
flyBG.BackgroundTransparency = 0.2
flyBG.BorderSizePixel        = 0
flyBG.ZIndex                 = 49
Instance.new("UICorner", flyBG).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", flyBG).Color        = C0.ACC

local function MkFlyB(t, x, cb)
	local b = Instance.new("TextButton", flyH)
	b.Size             = UDim2.new(0, 65, 0, 62)
	b.Position         = UDim2.new(0, x, 0, 4)
	b.BackgroundColor3 = C0.BTN
	b.Text             = t
	b.TextColor3       = C0.WHT
	b.Font             = Enum.Font.GothamBlack
	b.TextSize         = 28
	b.BorderSizePixel  = 0
	b.ZIndex           = 51
	b.AutoButtonColor  = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)
	Instance.new("UIStroke", b).Color        = C0.ACC

	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch
			or i.UserInputType == Enum.UserInputType.MouseButton1 then
			cb(true)
			TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = C0.TABA}):Play()
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch
			or i.UserInputType == Enum.UserInputType.MouseButton1 then
			cb(false)
			TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = C0.BTN}):Play()
		end
	end)
end

MkFlyB("▲", 4,  function(v) MobUp = v end)
MkFlyB("▼", 76, function(v) MobDn = v end)

local function UpdFly()
	flyH.Visible = State.Fly and IsTab
end

-- Freecam touch
local fcZ = Instance.new("TextButton", Scr)
fcZ.Size = UDim2.new(0.5, 0, 1, -100)
fcZ.Position = UDim2.new(0.5, 0, 0, 0)
fcZ.BackgroundTransparency = 1
fcZ.Text = ""
fcZ.ZIndex = 5
fcZ.Visible = false
local fcL = nil
fcZ.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch then fcL = i.Position end
end)
fcZ.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch and fcL then
		local d = i.Position - fcL
		FC_Y = FC_Y - math.rad(d.X * 0.4)
		FC_P = math.clamp(FC_P - math.rad(d.Y * 0.4), -math.rad(89), math.rad(89))
		fcL = i.Position
	end
end)
fcZ.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch then fcL = nil end
end)

-- ============================================================
-- UI COMPONENTS
-- ============================================================

-- Section header
local function AddHdr(tab, icon, text)
	local pg = TabPages[tab]; if not pg then return end
	local f = Instance.new("Frame", pg)
	f.Size             = UDim2.new(0.96, 0, 0, IsMob and 24 or 20)
	f.BackgroundColor3 = C0.HDR
	f.BorderSizePixel  = 0
	f.ZIndex           = 4
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

	local accent = Instance.new("Frame", f)
	accent.Size             = UDim2.new(0, 2, 0.7, 0)
	accent.Position         = UDim2.new(0, 0, 0.15, 0)
	accent.BackgroundColor3 = C0.ACC2
	accent.BorderSizePixel  = 0
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(1, -12, 1, 0)
	l.Position = UDim2.new(0, 10, 0, 0)
	l.BackgroundTransparency = 1
	l.TextColor3 = C0.ACC2
	l.Font = Enum.Font.GothamBold
	l.TextSize = IsMob and 10 or 9
	l.Text = icon .. "  " .. string.upper(text)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 5
end

-- Toggle row
local function MkToggle(tab, icon, text, logicName)
	local pg = TabPages[tab]; if not pg then return end

	local row = Instance.new("TextButton", pg)
	row.Size             = UDim2.new(0.96, 0, 0, BH)
	row.BackgroundColor3 = C0.BTN
	row.BorderSizePixel  = 0
	row.AutoButtonColor  = false
	row.Text             = ""
	row.ClipsDescendants = true
	row.ZIndex           = 4
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
	local rowStroke = Instance.new("UIStroke", row)
	rowStroke.Color     = C0.BRD
	rowStroke.Thickness = 1

	local accent = Instance.new("Frame", row)
	accent.Size             = UDim2.new(0, 3, 0.6, 0)
	accent.Position         = UDim2.new(0, 0, 0.2, 0)
	accent.BackgroundColor3 = Color3.fromRGB(55, 55, 72)
	accent.BorderSizePixel  = 0
	accent.ZIndex           = 5
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	local ic = Instance.new("TextLabel", row)
	ic.Size             = UDim2.new(0, 28, 1, 0)
	ic.Position         = UDim2.new(0, 6, 0, 0)
	ic.BackgroundTransparency = 1
	ic.Text             = icon
	ic.TextSize         = IsMob and 15 or 14
	ic.Font             = Enum.Font.Gotham
	ic.TextColor3       = C0.DIM
	ic.ZIndex           = 5

	local lbl = Instance.new("TextLabel", row)
	lbl.Size             = UDim2.new(1, -85, 1, 0)
	lbl.Position         = UDim2.new(0, 36, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text             = text
	lbl.TextColor3       = C0.TXT
	lbl.Font             = Enum.Font.GothamBold
	lbl.TextSize         = FS
	lbl.TextXAlignment   = Enum.TextXAlignment.Left
	lbl.ZIndex           = 5

	-- Switch
	local swW = IsMob and 44 or 38
	local swH = IsMob and 24 or 20
	local swBG = Instance.new("Frame", row)
	swBG.Size             = UDim2.new(0, swW, 0, swH)
	swBG.Position         = UDim2.new(1, -(swW+8), 0.5, -swH/2)
	swBG.BackgroundColor3 = C0.SWOFF
	swBG.BorderSizePixel  = 0
	swBG.ZIndex           = 5
	Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)

	local dotS  = IsMob and 18 or 14
	local swDot = Instance.new("Frame", swBG)
	swDot.Size             = UDim2.new(0, dotS, 0, dotS)
	swDot.Position         = UDim2.new(0, 3, 0.5, -dotS/2)
	swDot.BackgroundColor3 = C0.WHT
	swDot.BorderSizePixel  = 0
	swDot.ZIndex           = 6
	Instance.new("UICorner", swDot).CornerRadius = UDim.new(1, 0)

	-- Hover effect
	row.MouseEnter:Connect(function()
		if not State[logicName] then
			TweenService:Create(row, TweenInfo.new(0.12), {
				BackgroundColor3 = Color3.fromRGB(24, 25, 38)
			}):Play()
		end
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.12), {
			BackgroundColor3 = State[logicName] and C0.ONBG or C0.BTN
		}):Play()
	end)

	row.MouseButton1Click:Connect(function()
		if waitingBind then return end
		Toggle(logicName)
		if logicName == "Fly"     then UpdFly() end
		if logicName == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
	end)
	AllRows[logicName] = {row=row, accent=accent, swBG=swBG, swDot=swDot, lbl=lbl}
end

-- Toggle with bind (desktop)
local function MkToggleBind(tab, icon, text, logicName)
	if IsMob then return MkToggle(tab, icon, text, logicName) end
	local pg = TabPages[tab]; if not pg then return end

	local row = Instance.new("Frame", pg)
	row.Size             = UDim2.new(0.96, 0, 0, BH)
	row.BackgroundColor3 = C0.BTN
	row.BorderSizePixel  = 0
	row.ClipsDescendants = true
	row.ZIndex           = 4
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
	local rowStroke = Instance.new("UIStroke", row)
	rowStroke.Color     = C0.BRD
	rowStroke.Thickness = 1

	local accent = Instance.new("Frame", row)
	accent.Size             = UDim2.new(0, 3, 0.6, 0)
	accent.Position         = UDim2.new(0, 0, 0.2, 0)
	accent.BackgroundColor3 = Color3.fromRGB(55, 55, 72)
	accent.BorderSizePixel  = 0
	accent.ZIndex           = 5
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	local ic = Instance.new("TextLabel", row)
	ic.Size  = UDim2.new(0, 28, 1, 0)
	ic.Position = UDim2.new(0, 6, 0, 0)
	ic.BackgroundTransparency = 1
	ic.Text  = icon
	ic.TextSize = 14
	ic.Font  = Enum.Font.Gotham
	ic.TextColor3 = C0.DIM
	ic.ZIndex = 5

	local lbl = Instance.new("TextLabel", row)
	lbl.Size  = UDim2.new(1, -130, 1, 0)
	lbl.Position = UDim2.new(0, 36, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text  = text
	lbl.TextColor3 = C0.TXT
	lbl.Font  = Enum.Font.GothamBold
	lbl.TextSize = FS
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 5

	-- Bind button
	local bindB = Instance.new("TextButton", row)
	bindB.Size             = UDim2.new(0, 46, 0, 18)
	bindB.Position         = UDim2.new(1, -100, 0.5, -9)
	bindB.BackgroundColor3 = C0.DARK
	bindB.TextColor3       = C0.DIM
	bindB.Font             = Enum.Font.GothamBold
	bindB.TextSize         = 9
	bindB.BorderSizePixel  = 0
	bindB.AutoButtonColor  = false
	bindB.ZIndex           = 7
	bindB.Text = Binds[logicName]
		and tostring(Binds[logicName]):gsub("Enum.KeyCode.", "")
		or "NONE"
	Instance.new("UICorner", bindB).CornerRadius = UDim.new(0, 5)
	Instance.new("UIStroke", bindB).Color        = C0.BRD
	bindB.MouseButton1Click:Connect(function()
		if waitingBind then return end
		waitingBind = logicName
		bindB.Text  = "·  ·  ·"
		bindB.TextColor3 = C0.WARN
		Notify("BIND", "Press key: " .. text, 3)
	end)

	-- Switch
	local swBG = Instance.new("Frame", row)
	swBG.Size             = UDim2.new(0, 38, 0, 20)
	swBG.Position         = UDim2.new(1, -46, 0.5, -10)
	swBG.BackgroundColor3 = C0.SWOFF
	swBG.BorderSizePixel  = 0
	swBG.ZIndex           = 5
	Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)

	local swDot = Instance.new("Frame", swBG)
	swDot.Size             = UDim2.new(0, 14, 0, 14)
	swDot.Position         = UDim2.new(0, 3, 0.5, -7)
	swDot.BackgroundColor3 = C0.WHT
	swDot.BorderSizePixel  = 0
	swDot.ZIndex           = 6
	Instance.new("UICorner", swDot).CornerRadius = UDim.new(1, 0)

	local tBtn = Instance.new("TextButton", row)
	tBtn.Size                 = UDim2.new(1, -50, 1, 0)
	tBtn.BackgroundTransparency = 1
	tBtn.Text                 = ""
	tBtn.ZIndex               = 3

	tBtn.MouseButton1Click:Connect(function()
		if waitingBind == logicName then return end
		Toggle(logicName)
		if logicName == "Fly"     then UpdFly() end
		if logicName == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
	end)

	AllRows[logicName] = {row=row, accent=accent, swBG=swBG, swDot=swDot, lbl=lbl, bindBtn=bindB}
end

-- Slider
local function MkSlider(tab, icon, text, mn, mx2, def, cb)
	local pg = TabPages[tab]; if not pg then return end

	local ct = Instance.new("Frame", pg)
	ct.Size             = UDim2.new(0.96, 0, 0, IsMob and 62 or 52)
	ct.BackgroundColor3 = C0.BTN
	ct.BorderSizePixel  = 0
	ct.ZIndex           = 4
	Instance.new("UICorner", ct).CornerRadius = UDim.new(0, 9)
	Instance.new("UIStroke", ct).Color        = C0.BRD

	local ic = Instance.new("TextLabel", ct)
	ic.Size  = UDim2.new(0, 24, 0, 22)
	ic.Position = UDim2.new(0, 6, 0, 3)
	ic.BackgroundTransparency = 1
	ic.Text  = icon
	ic.TextSize = IsMob and 13 or 12
	ic.Font  = Enum.Font.Gotham
	ic.TextColor3 = C0.DIM
	ic.ZIndex = 5

	local nm2L = Instance.new("TextLabel", ct)
	nm2L.Size  = UDim2.new(0.55, 0, 0, 22)
	nm2L.Position = UDim2.new(0, 32, 0, 3)
	nm2L.BackgroundTransparency = 1
	nm2L.TextColor3 = C0.TXT
	nm2L.Font = Enum.Font.GothamBold
	nm2L.TextSize = FS
	nm2L.TextXAlignment = Enum.TextXAlignment.Left
	nm2L.Text = text
	nm2L.ZIndex = 5

	-- Value box (красивий)
	local vBox = Instance.new("Frame", ct)
	vBox.Size             = UDim2.new(0, 52, 0, 22)
	vBox.Position         = UDim2.new(1, -58, 0, 3)
	vBox.BackgroundColor3 = C0.DARK
	vBox.BorderSizePixel  = 0
	vBox.ZIndex           = 5
	Instance.new("UICorner", vBox).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", vBox).Color        = C0.ACC

	local vLbl = Instance.new("TextLabel", vBox)
	vLbl.Size  = UDim2.new(1, 0, 1, 0)
	vLbl.BackgroundTransparency = 1
	vLbl.TextColor3 = C0.ACC
	vLbl.Font = Enum.Font.GothamBlack
	vLbl.TextSize = IsMob and 13 or 12
	vLbl.Text = tostring(def)
	vLbl.ZIndex = 6

	local tY    = IsMob and 36 or 30
	local trackH = IsMob and 12 or 9

	local track = Instance.new("TextButton", ct)
	track.Text            = ""
	track.AutoButtonColor = false
	track.Size            = UDim2.new(0.9, 0, 0, trackH)
	track.Position        = UDim2.new(0.05, 0, 0, tY)
	track.BackgroundColor3 = C0.TRACK
	track.BorderSizePixel  = 0
	track.ZIndex           = 5
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	-- Filled portion
	local fill = Instance.new("Frame", track)
	fill.Size             = UDim2.new((def - mn) / (mx2 - mn), 0, 1, 0)
	fill.BackgroundColor3 = C0.ACC
	fill.BorderSizePixel  = 0
	fill.ZIndex           = 6
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	-- Glow under fill
	local fillGlow = Instance.new("Frame", fill)
	fillGlow.Size = UDim2.new(1, 0, 0, 3)
	fillGlow.Position = UDim2.new(0, 0, 1, -1)
	fillGlow.BackgroundColor3 = C0.ACC
	fillGlow.BackgroundTransparency = 0.7
	fillGlow.BorderSizePixel = 0
	Instance.new("UICorner", fillGlow).CornerRadius = UDim.new(1, 0)

	local KS   = IsMob and 22 or 16
	local knob = Instance.new("TextButton", track)
	knob.Text            = ""
	knob.AutoButtonColor = false
	knob.Size            = UDim2.new(0, KS, 0, KS)
	knob.Position        = UDim2.new((def - mn)/(mx2-mn), -KS/2, 0.5, -KS/2)
	knob.BackgroundColor3 = C0.WHT
	knob.BorderSizePixel  = 0
	knob.ZIndex           = 8
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	local kS = Instance.new("UIStroke", knob)
	kS.Color = C0.ACC; kS.Thickness = 2

	local dragging = false
	local curVal   = def

	local function Upd(inp)
		local rel = math.clamp(
			(inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
		)
		local val = math.floor(mn + rel * (mx2 - mn))
		if val == curVal then return end
		curVal = val
		fill.Size     = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -KS/2, 0.5, -KS/2)
		vLbl.Text     = tostring(val)
		cb(val)
		-- Autosave throttled
		task.delay(0.5, function() SaveConfig(Config, Binds, State) end)
	end

	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true; pg.ScrollingEnabled = false; Upd(inp)
		end
	end)
	knob.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true; pg.ScrollingEnabled = false
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if not dragging then return end
		if inp.UserInputType == Enum.UserInputType.MouseMovement
			or inp.UserInputType == Enum.UserInputType.Touch then Upd(inp) end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			if dragging then dragging = false; pg.ScrollingEnabled = true end
		end
	end)
end

-- ============================================================
-- POPULATE TABS
-- ============================================================
AddHdr("Combat","🎯","AIMING")
MkToggleBind("Combat","🎯","Auto Aim",    "Aim")
MkToggleBind("Combat","🔇","Silent Aim",  "SilentAim")
MkToggle("Combat","🧲","Magnet Target",   "ShadowLock")
AddHdr("Combat","💥","COMBAT")
MkToggle("Combat","📦","Hitbox Expand",   "Hitbox")
MkToggle("Combat","👁","ESP / Highlight", "ESP")

AddHdr("Move","✈️","FLIGHT")
MkToggleBind("Move","✈️","Fly",           "Fly")
MkToggle("Move","📷","Freecam",           "Freecam")
AddHdr("Move","🏃","MOVEMENT")
MkToggle("Move","👟","Speed Hack",        "Speed")
MkToggle("Move","🐇","Bunny Hop",         "Bhop")
MkToggle("Move","⬆️","High Jump",         "HighJump")
MkToggle("Move","♾️","Infinite Jump",     "InfiniteJump")
AddHdr("Move","👻","PHYSICS")
MkToggleBind("Move","👻","Noclip",         "Noclip")
MkToggle("Move","🛡","No Fall Damage",    "NoFallDamage")

AddHdr("Misc","🌀","VISUAL")
MkToggle("Misc","🌀","Spin Bot",          "Spin")
MkToggle("Misc","🥔","Potato Mode",       "Potato")
AddHdr("Misc","🛡","NETWORK")
MkToggle("Misc","📡","Fake Lag",          "FakeLag")
MkToggle("Misc","💤","Anti-AFK",          "AntiAFK")
MkToggle("Misc","🚫","Anti-Kick",         "AntiKick")

AddHdr("Config","✈️","FLIGHT SPEED")
MkSlider("Config","✈️","Fly Speed",   0,300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
AddHdr("Config","🏃","MOVEMENT")
MkSlider("Config","👟","CFrame Speed", 20,200, Config.CFrameSpeed, function(v)
	Config.CFrameSpeed = v; Config.WalkSpeed = v
	local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if State.Speed and h then h.WalkSpeed = 16 end
end)
MkSlider("Config","↔️","Strafe Mult (x10)", 4, 15, math.floor(Config.StrafeMult * 10), function(v)
	Config.StrafeMult = v / 10
end)
AddHdr("Config","⬆️","JUMP")
MkSlider("Config","⬆️","Jump Power", 50,500, Config.JumpPower, function(v)
	Config.JumpPower = v
	local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if State.HighJump and h then
		pcall(function() h.UseJumpPower = false; h.JumpHeight = 7.2 end)
	end
end)
MkSlider("Config","🐇","Bhop Power", 20,150, Config.BhopPower, function(v) Config.BhopPower = v end)
AddHdr("Config","📦","HITBOX")
MkSlider("Config","📦","Hitbox Size", 2, 15, Config.HitboxSize, function(v) Config.HitboxSize = v end)
AddHdr("Config","🎯","AIM SETTINGS")
MkSlider("Config","⭕","Aim FOV (px)", 50,500, Config.AimFOV, function(v)
	Config.AimFOV = v; UpdateFOVCircle()
end)
MkSlider("Config","🎚","Aim Smooth %", 5,100, math.floor(Config.AimSmooth*100), function(v)
	Config.AimSmooth = v / 100
end)

-- ============================================================
-- KEYBIND LISTENER
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
	if waitingBind then
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			local key = inp.KeyCode
			local nm  = waitingBind
			Binds[nm] = key
			local d = AllRows[nm]
			if d and d.bindBtn then
				d.bindBtn.Text       = tostring(key):gsub("Enum.KeyCode.", "")
				d.bindBtn.TextColor3 = C0.DIM
			end
			SaveConfig(Config, Binds, State)
			Notify("BIND", nm .. " → " .. tostring(key):gsub("Enum.KeyCode.", ""), 2)
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
	H:ChangeState(Enum.HumanoidStateType.Jumping)
	local pw = State.HighJump and Config.JumpPower * 0.7 or 50
	local v  = R.AssemblyLinearVelocity
	R.AssemblyLinearVelocity = Vector3.new(v.X, pw + math.random(-3, 3), v.Z)
end)

-- ============================================================
-- ANIMATION LOOP (пульс)
-- ============================================================
task.spawn(function()
	local t = 0
	while true do
		task.wait(0.033); t += 0.022
		local pulse = (math.sin(t * 2.2) + 1) / 2

		-- Акцент пульсує від зеленого до синювато-зеленого
		local aR = math.floor(0   + pulse * 40)
		local aG = math.floor(195 + pulse * 30)
		local aB = math.floor(100 + pulse * 60)
		local acol = Color3.fromRGB(aR, aG, aB)

		mSt.Color      = acol
		mB.TextColor3  = acol
		tAcc.BackgroundColor3 = acol
		tIco.TextColor3       = acol
		exStroke.Color        = acol
		fovStroke.Color       = (State.Aim or State.SilentAim)
			and (aimLocked and acol or Color3.fromRGB(140, 140, 170))
			or acol

		-- Main stroke subtle pulse
		mainStroke.Color = Color3.fromRGB(
			math.floor(30 + pulse * 18),
			math.floor(30 + pulse * 18),
			math.floor(50 + pulse * 18)
		)
		-- Активні рядки — акцент
		for nm, d in pairs(AllRows) do
			if State[nm] and d.accent then
				d.accent.BackgroundColor3 = acol
			end
		end
	end
end)

-- ============================================================
-- RENDER STEPPED
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

	local fc = fps >= 55 and Color3.fromRGB(80, 255, 150)
		or fps >= 30 and Color3.fromRGB(255, 210, 60)
		or Color3.fromRGB(255, 80, 80)
	local pc = pm <= 80 and Color3.fromRGB(80, 255, 150)
		or pm <= 150 and Color3.fromRGB(255, 210, 60)
		or Color3.fromRGB(255, 80, 80)

	fpsL.Text      = "FPS: " .. fps
	fpsL.TextColor3 = fc
	pngL.Text      = "Ping: " .. pm .. "ms"
	pngL.TextColor3 = pc
	eF.Text        = tostring(fps)
	eF.TextColor3  = fc
	eP.Text        = pm .. " ms"
	eP.TextColor3  = pc

	local Char = LP.Character
	local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
	local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

	local showFOV = (State.Aim or State.SilentAim) and not State.Freecam
	fovCircle.Visible = showFOV
	tgtInfo.Visible   = false

	-- FLY
	if State.Fly and not State.Freecam and HRP and Hum then
		Hum.PlatformStand = false
		local mx, mz = GetDir()
		local camCF  = Camera.CFrame
		local dir    = camCF.LookVector * -mz + camCF.RightVector * mx
		local upD    = 0
		if UIS:IsKeyDown(Enum.KeyCode.Space)       or MobUp then upD =  1 end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD = -1 end
		dir = dir + Vector3.new(0, upD, 0)
		if dir.Magnitude > 1 then dir = dir.Unit end
		HRP.CFrame += dir * Config.FlySpeed * dt
		HRP.AssemblyLinearVelocity = Vector3.zero
		if not State.Spin then HRP.AssemblyAngularVelocity = Vector3.zero end
	end

	-- FREECAM
	if State.Freecam then
		local mx, mz = GetDir()
		local dir    = Camera.CFrame.LookVector * -mz + Camera.CFrame.RightVector * mx
		if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp then
			dir += Camera.CFrame.UpVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then
			dir -= Camera.CFrame.UpVector
		end
		if dir.Magnitude > 1 then dir = dir.Unit end
		Camera.CFrame = CFrame.new(Camera.CFrame.Position + dir * (Config.FlySpeed / 25) * dt * 60)
			* CFrame.fromEulerAnglesYXZ(FC_P, FC_Y, 0)
	end

	-- AUTO AIM
	if State.Aim and not State.Freecam and Char and HRP then
		local target = GetBestAimTarget()
		local part   = target and FindAimPart(target)
		if part then
			local predTime     = math.clamp(lastPing, 0.01, 0.25)
			local vel          = part.AssemblyLinearVelocity
			local dist         = (Camera.CFrame.Position - part.Position).Magnitude
			local predMul      = math.clamp(dist / 100, 0.3, 1.5)
			local predictedPos = part.Position + vel * predTime * predMul
			if vel.Y < -5 then
				predictedPos += Vector3.new(0, -4.9 * predTime * predTime, 0)
			end
			local smooth = Config.AimSmooth
			local sd = ScreenDist(part)
			if sd < 30  then smooth = smooth * 0.3
			elseif sd < 80 then smooth = smooth * 0.6 end
			local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
			Camera.CFrame  = Camera.CFrame:Lerp(targetCF, smooth)
			local plr  = Players:GetPlayerFromCharacter(target)
			local dist2 = math.floor(dist)
			tgtInfo.Text       = "🔒 " .. (plr and plr.Name or "?") .. "  [" .. dist2 .. "m]"
			tgtInfo.TextColor3 = Color3.fromRGB(60, 245, 130)
			tgtStroke.Color    = Color3.fromRGB(60, 245, 130)
			tgtInfo.Visible    = true
		else
			if showFOV then
				tgtInfo.Text       = "No target in range"
				tgtInfo.TextColor3 = C0.DIM
				tgtStroke.Color    = C0.BRD
				tgtInfo.Visible    = true
			end
		end
	end

	-- SILENT AIM VISUAL
	if State.SilentAim and not State.Aim and not State.Freecam then
		local tgt  = GetBestAimTarget()
		local part = tgt and FindAimPart(tgt)
		if part then
			local plr  = Players:GetPlayerFromCharacter(tgt)
			local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
			tgtInfo.Text       = "🔇 " .. (plr and plr.Name or "?") .. "  [" .. dist .. "m]"
			tgtInfo.TextColor3 = C0.WARN
			tgtStroke.Color    = C0.WARN
			tgtInfo.Visible    = true
		elseif showFOV then
			tgtInfo.Text       = "No target in range"
			tgtInfo.TextColor3 = C0.DIM
			tgtStroke.Color    = C0.BRD
			tgtInfo.Visible    = true
		end
	end
end)

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
-- HEARTBEAT
-- ============================================================
RunService.Heartbeat:Connect(function(dt)
	local Char = LP.Character
	local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
	local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")
	if not HRP or not Hum or Hum.Health <= 0 then return end

	-- SHADOW LOCK
	if State.ShadowLock then
		if not IsAlive(LockedTarget) then LockedTarget = GetClosestDist() end
		if LockedTarget then
			local tR = LockedTarget:FindFirstChild("HumanoidRootPart")
			if tR then
				local pr = tR.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.2)
				HRP.CFrame = HRP.CFrame:Lerp(
					CFrame.new(tR.Position + pr) * tR.CFrame.Rotation * CFrame.new(0, 0, 3), 0.4
				)
				HRP.AssemblyLinearVelocity = tR.AssemblyLinearVelocity
			end
		end
	end

	-- SPEED (ANTI-DETECT CFRAME METHOD)
	if State.Speed and not State.Fly and not State.Freecam then
		-- Тримаємо WalkSpeed 16 для сервера
		if Hum.WalkSpeed ~= 16 then Hum.WalkSpeed = 16 end

		-- Humanize speed (рандом кожні 0.3с)
		local now2 = tick()
		if Config.Humanize and now2 - speedTimer > 0.3 then
			curSpeed = Config.CFrameSpeed + math.random(-6, 6)
			speedTimer = now2
		elseif not Config.Humanize then
			curSpeed = Config.CFrameSpeed
		end

		local moveDir = Hum.MoveDirection
		if moveDir.Magnitude > 0.05 then
			local cam = Camera.CFrame
			local dir = (cam.LookVector * moveDir.Z + cam.RightVector * moveDir.X)
			if dir.Magnitude > 0.01 then dir = dir.Unit end

			-- Strafe limit
			local isStrafe = math.abs(moveDir.X) > math.abs(moveDir.Z)
			local sMult = isStrafe and Config.StrafeMult or 1.0

			-- Accel curve
			if Config.AccelCurve then
				accel = math.min(accel + dt * 10, maxAccel)
			else
				accel = maxAccel
			end

			-- CFrame push
			local push = dir * curSpeed * sMult * accel * dt
			HRP.CFrame = HRP.CFrame + push

			-- Velocity assist
			local vel = HRP.AssemblyLinearVelocity
			local tVel = Vector3.new(
				dir.X * curSpeed * sMult * 0.75,
				vel.Y,
				dir.Z * curSpeed * sMult * 0.75
			)
			HRP.AssemblyLinearVelocity = tVel
		else
			accel = math.max(accel - dt * 20, 0)
		end
	end

	-- HIGH JUMP (velocity-based, без JumpPower детекту)
	if State.HighJump and not State.Fly then
		pcall(function()
			Hum.UseJumpPower = false
			Hum.JumpHeight   = 7.2
		end)
	end

	-- BHOP + HIGH JUMP velocity boost
	if (State.Bhop or State.HighJump) and not State.Fly and not State.Freecam then
		local onGround = Hum.FloorMaterial ~= Enum.Material.Air
		if onGround and Hum.MoveDirection.Magnitude > 0.05 then
			local now3 = tick()
			if now3 - lastBhop > 0.06 then
				lastBhop = now3
				Hum:ChangeState(Enum.HumanoidStateType.Jumping)
				local jumpP = State.HighJump and Config.JumpPower * 0.7 or Config.BhopPower
				local vel = HRP.AssemblyLinearVelocity
				local md  = Hum.MoveDirection.Unit
				HRP.AssemblyLinearVelocity = Vector3.new(
					vel.X + md.X * (8 + math.random(-2, 3)),
					jumpP + math.random(-4, 4),
					vel.Z + md.Z * (8 + math.random(-2, 3))
				)
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
-- STEPPED — NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
	local Char = LP.Character
	local HRP  = Char and Char:FindFirstChild("HumanoidRootPart")
	local Hum  = Char and Char:FindFirstChildOfClass("Humanoid")

	if State.Noclip and Char and HRP and Hum then
		for _, v in pairs(Char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CollisionGroup = SafeGroup
				v.CanCollide     = false
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
			local r = Workspace:Raycast(HRP.Position, md * 8, ncRay)
			if r then HRP.CFrame += md * (r.Distance + 2.5)
			else HRP.CFrame += md * 0.6 + Vector3.new(0, 0.15, 0) end
			if ncStuck >= 6 then
				HRP.AssemblyLinearVelocity = Vector3.new(
					md.X * 18, HRP.AssemblyLinearVelocity.Y + 3, md.Z * 18
				)
				ncStuck = 0
			end
		end
		lastNcPos = HRP.Position
	elseif Char and HRP then
		lastNcPos = HRP.Position; ncStuck = 0
	end
end)

-- ============================================================
-- INIT: apply loaded states visually
-- ============================================================
task.delay(0.5, function()
	for nm in pairs(State) do UpdVis(nm) end
	SwitchTab("Combat")
end)

Notify("OMNI V266", "✅ Loaded | Config saved | Anti-detect Speed | New UI", 5)
