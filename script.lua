-- [[ V265.4 FIXED — OMNI IMBA AIM ]]

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

pcall(function()
	for _, sg in pairs({game:GetService("CoreGui"), LP:WaitForChild("PlayerGui")}) do
		for _, v in pairs(sg:GetChildren()) do
			if v:IsA("ScreenGui") and v:FindFirstChild("OmniMarker") then v:Destroy() end
		end
	end
end)

local SafeGroup = "OmniSafe4"
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
-- CONFIG
-- ============================================================
local Config = {
	FlySpeed   = 55,
	WalkSpeed  = 30,
	JumpPower  = 125,
	BhopPower  = 62,
	HitboxSize = 5,
	AimFOV     = 200,
	AimSmooth  = 0.18,
	AimPart    = "Head",
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
			local tgt  = _GetBestTargetSilent()
			local hd   = tgt and FindAimPart(tgt)
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
					aimLostFrames = aimLostFrames + 1
					if aimLostFrames < 15 then return char end
				elseif sd > fov * 1.8 then
					aimLostFrames = aimLostFrames + 1
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

function _GetBestTargetSilent()
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
			local mx = math.max(math.floor(hm.MaxHealth), 1)
			local ds = my and math.floor((my.Position - hd.Position).Magnitude) or 0
			local r  = hp / mx
			ca.lbl.Text = string.format("[%s]\nHP:%d/%d %dm", p.Name, hp, mx, ds)
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
		for part in pairs(hbParts) do
			if part and part.Parent and math.abs(part.Size.X - s) > 0.3 then
				part.Size = Vector3.new(s, s, s)
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
			if v:IsA("BasePart") then
				v.CastShadow = false; v.Reflectance = 0
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Enabled = false
			end
		end)
	end
end
local function UndoPotato()
	Lighting.GlobalShadows = savedShd
	settings().Rendering.QualityLevel = savedQ
	for _, v in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if v:IsA("BasePart") then
				v.CastShadow = true
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
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
		H.PlatformStand = false
		H.WalkSpeed = 16
		pcall(function() H.UseJumpPower = true; H.JumpPower = 50 end)
	end
	if R then
		R.Anchored = false
		for _, v in pairs(R:GetChildren()) do
			if v:IsA("BodyMover") then SafeDel(v) end
		end
	end
	for _, v in pairs(C:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide     = true
			v.CollisionGroup = "Default"
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
			spReset = false
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
		if nm == "Freecam" then
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
		if nm == "InfiniteJump" and H then
			pcall(function() H:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
		end
		if nm == "Aim" then
			aimTarget = nil; aimLocked = false; aimLostFrames = 0
		end
	end

	if State[nm] then
		if nm == "SilentAim" then silentActive = true end
		if nm == "AntiKick"  then akOn = true end
		if nm == "Potato"    then DoPotato() end
		if nm == "ShadowLock" then LockedTarget = GetClosestDist() end
		if nm == "Fly" and H then H.PlatformStand = false end
		if nm == "Speed" and H then
			H.WalkSpeed = Config.WalkSpeed; spReset = false; lastSpCk = 0
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
	MobUp = false; MobDn = false; spReset = false; ncStuck = 0
	aimTarget = nil; aimLocked = false; aimLostFrames = 0
	for _, n in pairs({"Fly","Noclip","Freecam","Spin","FakeLag"}) do
		if State[n] then State[n] = false; UpdVis(n) end
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
				hum.JumpHeight   = Config.JumpPower * 0.14
			end)
		end
	end
end)

-- ============================================================
-- GUI
-- ============================================================
local GuiP = LP:WaitForChild("PlayerGui")
pcall(function() local c = game:GetService("CoreGui"); local _ = c.Name; GuiP = c end)

local Scr = Instance.new("ScreenGui", GuiP)
Scr.Name           = RndStr(10)
Scr.ResetOnSpawn   = false
Scr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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

local MW  = IsMob and 280 or 310
local MH  = IsMob and 520 or 520
local BH  = IsMob and 38 or 34
local FS  = IsMob and 12 or 11
local MBS = IsMob and 54 or 48

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
tTit.Text                 = "OMNI V265.4"
tTit.TextXAlignment       = Enum.TextXAlignment.Left
tTit.ZIndex               = 3

local tSub = Instance.new("TextLabel", TB)
tSub.Size                 = UDim2.new(1, -90, 0, 12)
tSub.Position             = UDim2.new(0, 40, 0, 24)
tSub.BackgroundTransparency = 1
tSub.TextColor3           = P.dim
tSub.Font                 = Enum.Font.Gotham
tSub.TextSize             = 9
tSub.Text                 = IsMob and "MOBILE" or "UNIVERSAL"
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
tabFr.Size             = UDim2.new(1, -12, 0, 26)
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
	b.TextSize               = IsMob and 10 or 9
	b.BorderSizePixel        = 0
	b.AutoButtonColor        = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	b.MouseButton1Click:Connect(function() SwitchTab(n) end)
	TabBtns[n] = b
end

local cY = tabY + 30
local cH = MH - cY - 4
for _, n in ipairs(tNames) do
	local s = Instance.new("ScrollingFrame", Main)
	s.Name                   = n
	s.Size                   = UDim2.new(1, -6, 0, cH)
	s.Position               = UDim2.new(0, 3, 0, cY)
	s.BackgroundTransparency = 1
	s.ScrollBarThickness     = IsMob and 0 or 3
	s.ScrollBarImageColor3   = Color3.fromRGB(100, 100, 120)
	s.BorderSizePixel        = 0
	s.CanvasSize             = UDim2.new(0, 0, 0, 0)
	s.ScrollingDirection     = Enum.ScrollingDirection.Y
	s.Visible                = (n == "Combat")
	local ly = Instance.new("UIListLayout", s)
	ly.Padding             = UDim.new(0, 3)
	ly.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local pd = Instance.new("UIPadding", s)
	pd.PaddingTop    = UDim.new(0, 4)
	pd.PaddingBottom = UDim.new(0, 8)
	ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		s.CanvasSize = UDim2.new(0, 0, 0, ly.AbsoluteContentSize.Y + 14)
	end)
	TabPages[n] = s
end

-- DRAGGABLE MAIN
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
			Main.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
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
-- EXT STATS — КРАСИВА ПЕРЕТЯГУВАНА ПАНЕЛЬ FPS/PING
-- ============================================================
local exS = Instance.new("Frame", Scr)
exS.Size                   = UDim2.new(0, 130, 0, 58)
exS.Position               = UDim2.new(1, -142, 0, 10)
exS.BackgroundColor3       = Color3.fromRGB(10, 10, 16)
exS.BackgroundTransparency = 0
exS.BorderSizePixel        = 0
exS.ZIndex                 = 20
Instance.new("UICorner", exS).CornerRadius = UDim.new(0, 10)

-- Градієнт фону
local exGrad = Instance.new("UIGradient", exS)
exGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(16, 16, 28)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  8,  16)),
})
exGrad.Rotation = 135

local exStroke = Instance.new("UIStroke", exS)
exStroke.Color     = Color3.fromRGB(0, 200, 100)
exStroke.Thickness = 1.5
exStroke.Transparency = 0.4

-- Верхній рядок — FPS
local exFpsRow = Instance.new("Frame", exS)
exFpsRow.Size             = UDim2.new(1, -16, 0, 24)
exFpsRow.Position         = UDim2.new(0, 8, 0, 6)
exFpsRow.BackgroundTransparency = 1
exFpsRow.ZIndex           = 21

local exFpsIco = Instance.new("TextLabel", exFpsRow)
exFpsIco.Size                 = UDim2.new(0, 18, 1, 0)
exFpsIco.BackgroundTransparency = 1
exFpsIco.Text                 = "🖥"
exFpsIco.TextSize             = 12
exFpsIco.Font                 = Enum.Font.Gotham
exFpsIco.TextColor3           = Color3.fromRGB(100, 200, 255)
exFpsIco.ZIndex               = 22

local exFpsLbl = Instance.new("TextLabel", exFpsRow)
exFpsLbl.Size                 = UDim2.new(0, 42, 1, 0)
exFpsLbl.Position             = UDim2.new(0, 20, 0, 0)
exFpsLbl.BackgroundTransparency = 1
exFpsLbl.Text                 = "FPS"
exFpsLbl.TextSize             = 10
exFpsLbl.Font                 = Enum.Font.GothamBold
exFpsLbl.TextColor3           = Color3.fromRGB(160, 160, 180)
exFpsLbl.TextXAlignment       = Enum.TextXAlignment.Left
exFpsLbl.ZIndex               = 22

local eF = Instance.new("TextLabel", exFpsRow)
eF.Size                 = UDim2.new(1, -64, 1, 0)
eF.Position             = UDim2.new(0, 62, 0, 0)
eF.BackgroundTransparency = 1
eF.Text                 = "..."
eF.TextSize             = 12
eF.Font                 = Enum.Font.GothamBlack
eF.TextColor3           = Color3.fromRGB(130, 255, 170)
eF.TextXAlignment       = Enum.TextXAlignment.Right
eF.ZIndex               = 22

-- Роздільник
local exDiv = Instance.new("Frame", exS)
exDiv.Size             = UDim2.new(1, -16, 0, 1)
exDiv.Position         = UDim2.new(0, 8, 0, 31)
exDiv.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
exDiv.BorderSizePixel  = 0
exDiv.ZIndex           = 21

-- Нижній рядок — Ping
local exPingRow = Instance.new("Frame", exS)
exPingRow.Size             = UDim2.new(1, -16, 0, 22)
exPingRow.Position         = UDim2.new(0, 8, 0, 33)
exPingRow.BackgroundTransparency = 1
exPingRow.ZIndex           = 21

local exPingIco = Instance.new("TextLabel", exPingRow)
exPingIco.Size                 = UDim2.new(0, 18, 1, 0)
exPingIco.BackgroundTransparency = 1
exPingIco.Text                 = "📶"
exPingIco.TextSize             = 11
exPingIco.Font                 = Enum.Font.Gotham
exPingIco.TextColor3           = Color3.fromRGB(255, 200, 80)
exPingIco.ZIndex               = 22

local exPingLbl = Instance.new("TextLabel", exPingRow)
exPingLbl.Size                 = UDim2.new(0, 42, 1, 0)
exPingLbl.Position             = UDim2.new(0, 20, 0, 0)
exPingLbl.BackgroundTransparency = 1
exPingLbl.Text                 = "PING"
exPingLbl.TextSize             = 10
exPingLbl.Font                 = Enum.Font.GothamBold
exPingLbl.TextColor3           = Color3.fromRGB(160, 160, 180)
exPingLbl.TextXAlignment       = Enum.TextXAlignment.Left
exPingLbl.ZIndex               = 22

local eP = Instance.new("TextLabel", exPingRow)
eP.Size                 = UDim2.new(1, -64, 1, 0)
eP.Position             = UDim2.new(0, 62, 0, 0)
eP.BackgroundTransparency = 1
eP.Text                 = "..."
eP.TextSize             = 12
eP.Font                 = Enum.Font.GothamBlack
eP.TextColor3           = Color3.fromRGB(130, 255, 170)
eP.TextXAlignment       = Enum.TextXAlignment.Right
eP.ZIndex               = 22

-- Drag іконка (⠿)
local exDragIco = Instance.new("TextLabel", exS)
exDragIco.Size                 = UDim2.new(0, 12, 0, 12)
exDragIco.Position             = UDim2.new(1, -14, 0, 2)
exDragIco.BackgroundTransparency = 1
exDragIco.Text                 = "⠿"
exDragIco.TextSize             = 9
exDragIco.Font                 = Enum.Font.GothamBold
exDragIco.TextColor3           = Color3.fromRGB(60, 60, 80)
exDragIco.ZIndex               = 22

-- ============================================================
-- DRAG ЛОГІКА — ПОВНІСТЮ ЛОКАЛЬНА (не залежить від UIS global)
-- ============================================================
do
	local exDr  = false
	local exDs  = nil
	local exDp  = nil

	-- Використовуємо InputBegan/Changed/Ended на самому фреймі
	exS.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			exDr = true
			exDs = inp.Position
			exDp = exS.Position
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
			newX = math.clamp(newX, -exDp.X.Scale * vp.X, vp.X * (1 - exDp.X.Scale) - exS.AbsoluteSize.X)
			newY = math.clamp(newY, -exDp.Y.Scale * vp.Y, vp.Y * (1 - exDp.Y.Scale) - exS.AbsoluteSize.Y)
			exS.Position = UDim2.new(exDp.X.Scale, newX, exDp.Y.Scale, newY)
		end
	end)

	exS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			exDr = false
		end
	end)

	-- Запасний — щоб drag не завис
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
			exDr = false
		end
	end)
end

-- ============================================================
-- M BUTTON
-- ============================================================
local mB = Instance.new("TextButton", Scr)
mB.Size             = UDim2.new(0, MBS, 0, MBS)
mB.Position         = UDim2.new(0, 10, 0.45, 0)
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
mCnt.Size                 = UDim2.new(1, 0, 0, 12)
mCnt.Position             = UDim2.new(0, 0, 1, -13)
mCnt.BackgroundTransparency = 1
mCnt.TextSize             = 8
mCnt.Font                 = Enum.Font.GothamBold
mCnt.TextColor3           = P.grn
mCnt.ZIndex               = 101
mCnt.Text                 = ""
task.spawn(function()
	while task.wait(0.6) do
		local c = 0
		for _, v in pairs(State) do if v then c += 1 end end
		mCnt.Text = c > 0 and ("●" .. c) or ""
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
			or inp.UserInputType == Enum.UserInputType.Touch then
			dr = false
		end
	end)
end

-- MOBILE FLY BUTTONS
local flyH = Instance.new("Frame", Scr)
flyH.Size                   = UDim2.new(0, 134, 0, 60)
flyH.Position               = UDim2.new(1, -148, 1, -76)
flyH.BackgroundTransparency = 1
flyH.Visible                = false
flyH.ZIndex                 = 50

local function MkFlyB(t, x, cb)
	local b = Instance.new("TextButton", flyH)
	b.Size             = UDim2.new(0, 60, 0, 56)
	b.Position         = UDim2.new(0, x, 0, 0)
	b.BackgroundColor3 = P.bg
	b.Text             = t
	b.TextColor3       = P.wht
	b.Font             = Enum.Font.GothamBlack
	b.TextSize         = 26
	b.BorderSizePixel  = 0
	b.ZIndex           = 51
	b.AutoButtonColor  = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", b).Color        = P.brd
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch
			or i.UserInputType == Enum.UserInputType.MouseButton1 then
			cb(true); b.BackgroundColor3 = P.tabA
		end
	end)
	b.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch
			or i.UserInputType == Enum.UserInputType.MouseButton1 then
			cb(false); b.BackgroundColor3 = P.bg
		end
	end)
end
MkFlyB("▲", 0,  function(v) MobUp = v end)
MkFlyB("▼", 70, function(v) MobDn = v end)
local function UpdFly() flyH.Visible = State.Fly and IsTab end

local fcZ = Instance.new("TextButton", Scr)
fcZ.Size                   = UDim2.new(0.5, 0, 1, -100)
fcZ.Position               = UDim2.new(0.5, 0, 0, 0)
fcZ.BackgroundTransparency = 1
fcZ.Text                   = ""
fcZ.ZIndex                 = 5
fcZ.Visible                = false
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
-- UI COMPONENT BUILDERS
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

local function AddHdr(tab, icon, text)
	local pg = TabPages[tab]; if not pg then return end
	local f  = Instance.new("Frame", pg)
	f.Size             = UDim2.new(0.95, 0, 0, 18)
	f.BackgroundColor3 = P.dark
	f.BorderSizePixel  = 0
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
	local l = Instance.new("TextLabel", f)
	l.Size                 = UDim2.new(1, -8, 1, 0)
	l.Position             = UDim2.new(0, 8, 0, 0)
	l.BackgroundTransparency = 1
	l.TextColor3           = P.dim
	l.Font                 = Enum.Font.GothamBold
	l.TextSize             = 9
	l.Text                 = icon .. "  " .. text
	l.TextXAlignment       = Enum.TextXAlignment.Left
end

local function MkToggle(tab, icon, text, logicName)
	local pg = TabPages[tab]; if not pg then return end
	local row = Instance.new("TextButton", pg)
	row.Size             = UDim2.new(0.95, 0, 0, BH)
	row.BackgroundColor3 = P.btn
	row.BorderSizePixel  = 0
	row.AutoButtonColor  = false
	row.Text             = ""
	row.ClipsDescendants = true
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", row).Color        = P.brd

	local accent = Instance.new("Frame", row)
	accent.Size             = UDim2.new(0, 3, 0.55, 0)
	accent.Position         = UDim2.new(0, 0, 0.225, 0)
	accent.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
	accent.BorderSizePixel  = 0
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	local ic = Instance.new("TextLabel", row)
	ic.Size                 = UDim2.new(0, 24, 1, 0)
	ic.Position             = UDim2.new(0, 8, 0, 0)
	ic.BackgroundTransparency = 1
	ic.Text                 = icon
	ic.TextSize             = 13
	ic.Font                 = Enum.Font.Gotham
	ic.TextColor3           = P.dim

	local lbl = Instance.new("TextLabel", row)
	lbl.Size                 = UDim2.new(1, -80, 1, 0)
	lbl.Position             = UDim2.new(0, 34, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text                 = text
	lbl.TextColor3           = P.txt
	lbl.Font                 = Enum.Font.GothamBold
	lbl.TextSize             = FS
	lbl.TextXAlignment       = Enum.TextXAlignment.Left

	local swBG = Instance.new("Frame", row)
	swBG.Size             = UDim2.new(0, 36, 0, 18)
	swBG.Position         = UDim2.new(1, -44, 0.5, -9)
	swBG.BackgroundColor3 = P.swOff
	swBG.BorderSizePixel  = 0
	Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)

	local swDot = Instance.new("Frame", swBG)
	swDot.Size             = UDim2.new(0, 12, 0, 12)
	swDot.Position         = UDim2.new(0, 3, 0.5, -6)
	swDot.BackgroundColor3 = P.wht
	swDot.BorderSizePixel  = 0
	Instance.new("UICorner", swDot).CornerRadius = UDim.new(1, 0)

	row.MouseButton1Click:Connect(function()
		if waitingBind then return end
		Toggle(logicName)
		if logicName == "Fly"     then UpdFly() end
		if logicName == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
	end)
	AllRows[logicName] = {row=row, accent=accent, swBG=swBG, swDot=swDot}
end

local function MkToggleBind(tab, icon, text, logicName)
	if IsMob then return MkToggle(tab, icon, text, logicName) end
	local pg = TabPages[tab]; if not pg then return end
	local row = Instance.new("Frame", pg)
	row.Size             = UDim2.new(0.95, 0, 0, BH)
	row.BackgroundColor3 = P.btn
	row.BorderSizePixel  = 0
	row.ClipsDescendants = true
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", row).Color        = P.brd

	local accent = Instance.new("Frame", row)
	accent.Size             = UDim2.new(0, 3, 0.55, 0)
	accent.Position         = UDim2.new(0, 0, 0.225, 0)
	accent.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
	accent.BorderSizePixel  = 0
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	local ic = Instance.new("TextLabel", row)
	ic.Size                 = UDim2.new(0, 24, 1, 0)
	ic.Position             = UDim2.new(0, 8, 0, 0)
	ic.BackgroundTransparency = 1
	ic.Text                 = icon
	ic.TextSize             = 13
	ic.Font                 = Enum.Font.Gotham
	ic.TextColor3           = P.dim

	local lbl = Instance.new("TextLabel", row)
	lbl.Size                 = UDim2.new(1, -120, 1, 0)
	lbl.Position             = UDim2.new(0, 34, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text                 = text
	lbl.TextColor3           = P.txt
	lbl.Font                 = Enum.Font.GothamBold
	lbl.TextSize             = FS
	lbl.TextXAlignment       = Enum.TextXAlignment.Left

	local bindB = Instance.new("TextButton", row)
	bindB.Size             = UDim2.new(0, 44, 0, 16)
	bindB.Position         = UDim2.new(1, -94, 0.5, -8)
	bindB.BackgroundColor3 = P.dark
	bindB.TextColor3       = P.dim
	bindB.Font             = Enum.Font.GothamBold
	bindB.TextSize         = 8
	bindB.BorderSizePixel  = 0
	bindB.AutoButtonColor  = false
	bindB.ZIndex           = 5
	bindB.Text = Binds[logicName]
		and tostring(Binds[logicName]):gsub("Enum.KeyCode.", "")
		or "NONE"
	Instance.new("UICorner", bindB).CornerRadius = UDim.new(0, 4)
	bindB.MouseButton1Click:Connect(function()
		if waitingBind then return end
		waitingBind       = logicName
		bindB.Text        = "..."
		bindB.TextColor3  = Color3.fromRGB(255, 230, 80)
		Notify("BIND", "Натисни клавішу: " .. text, 3)
	end)

	local swBG = Instance.new("Frame", row)
	swBG.Size             = UDim2.new(0, 36, 0, 18)
	swBG.Position         = UDim2.new(1, -44, 0.5, -9)
	swBG.BackgroundColor3 = P.swOff
	swBG.BorderSizePixel  = 0
	Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)

	local swDot = Instance.new("Frame", swBG)
	swDot.Size             = UDim2.new(0, 12, 0, 12)
	swDot.Position         = UDim2.new(0, 3, 0.5, -6)
	swDot.BackgroundColor3 = P.wht
	swDot.BorderSizePixel  = 0
	Instance.new("UICorner", swDot).CornerRadius = UDim.new(1, 0)

	local tBtn = Instance.new("TextButton", row)
	tBtn.Size                 = UDim2.new(1, 0, 1, 0)
	tBtn.BackgroundTransparency = 1
	tBtn.Text                 = ""
	tBtn.ZIndex               = 3
	tBtn.MouseButton1Click:Connect(function()
		if waitingBind == logicName then return end
		Toggle(logicName)
		if logicName == "Fly"     then UpdFly() end
		if logicName == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
	end)

	AllRows[logicName] = {row=row, accent=accent, swBG=swBG, swDot=swDot, bindBtn=bindB}
end

local function MkSlider(tab, icon, text, mn, mx, def, cb)
	local pg = TabPages[tab]; if not pg then return end
	local ct = Instance.new("Frame", pg)
	ct.Size             = UDim2.new(0.95, 0, 0, IsMob and 52 or 46)
	ct.BackgroundColor3 = P.btn
	ct.BorderSizePixel  = 0
	Instance.new("UICorner", ct).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", ct).Color        = P.brd

	local ic = Instance.new("TextLabel", ct)
	ic.Size                 = UDim2.new(0, 22, 0, 18)
	ic.Position             = UDim2.new(0, 6, 0, 3)
	ic.BackgroundTransparency = 1
	ic.Text                 = icon
	ic.TextSize             = 11
	ic.Font                 = Enum.Font.Gotham
	ic.TextColor3           = P.dim

	local nm2 = Instance.new("TextLabel", ct)
	nm2.Size                 = UDim2.new(0.5, 0, 0, 18)
	nm2.Position             = UDim2.new(0, 28, 0, 3)
	nm2.BackgroundTransparency = 1
	nm2.TextColor3           = P.txt
	nm2.Font                 = Enum.Font.GothamBold
	nm2.TextSize             = FS
	nm2.TextXAlignment       = Enum.TextXAlignment.Left
	nm2.Text                 = text

	local vBox = Instance.new("Frame", ct)
	vBox.Size             = UDim2.new(0, 38, 0, 16)
	vBox.Position         = UDim2.new(1, -44, 0, 4)
	vBox.BackgroundColor3 = P.dark
	vBox.BorderSizePixel  = 0
	Instance.new("UICorner", vBox).CornerRadius = UDim.new(0, 4)

	local vLbl = Instance.new("TextLabel", vBox)
	vLbl.Size                 = UDim2.new(1, 0, 1, 0)
	vLbl.BackgroundTransparency = 1
	vLbl.TextColor3           = P.acc
	vLbl.Font                 = Enum.Font.GothamBold
	vLbl.TextSize             = 11
	vLbl.Text                 = tostring(def)

	local tY    = IsMob and 32 or 28
	local track = Instance.new("TextButton", ct)
	track.Text             = ""
	track.AutoButtonColor  = false
	track.Size             = UDim2.new(0.88, 0, 0, 8)
	track.Position         = UDim2.new(0.06, 0, 0, tY)
	track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	track.BorderSizePixel  = 0
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.Size             = UDim2.new((def - mn) / (mx - mn), 0, 1, 0)
	fill.BackgroundColor3 = P.acc
	fill.BorderSizePixel  = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local KS   = IsMob and 16 or 14
	local knob = Instance.new("TextButton", track)
	knob.Text             = ""
	knob.AutoButtonColor  = false
	knob.Size             = UDim2.new(0, KS, 0, KS)
	knob.Position         = UDim2.new((def - mn) / (mx - mn), -KS/2, 0.5, -KS/2)
	knob.BackgroundColor3 = P.wht
	knob.BorderSizePixel  = 0
	knob.ZIndex           = 3
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
	local kS = Instance.new("UIStroke", knob)
	kS.Color = P.acc; kS.Thickness = 1.5

	local dragging = false
	local curVal   = def
	local function Upd(inp)
		local rel = math.clamp(
			(inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
			0, 1
		)
		local val = math.floor(mn + rel * (mx - mn))
		if val == curVal then return end
		curVal = val
		fill.Size     = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -KS/2, 0.5, -KS/2)
		vLbl.Text     = tostring(val)
		cb(val)
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
			or inp.UserInputType == Enum.UserInputType.Touch then
			Upd(inp)
		end
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
MkToggleBind("Combat","🎯","Auto Aim","Aim")
MkToggleBind("Combat","🔇","Silent Aim","SilentAim")
MkToggle("Combat","🧲","Magnet","ShadowLock")
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
MkToggle("Move","♾️","∞ Jump","InfiniteJump")
AddHdr("Move","👻","PHYSICS")
MkToggleBind("Move","👻","Noclip","Noclip")
MkToggle("Move","🛡","No Fall Dmg","NoFallDamage")

AddHdr("Misc","🔧","EFFECTS")
MkToggle("Misc","🌀","Spin","Spin")
MkToggle("Misc","🥔","Potato Mode","Potato")
MkToggle("Misc","📡","Fake Lag","FakeLag")
AddHdr("Misc","🛡","PROTECTION")
MkToggle("Misc","💤","Anti-AFK","AntiAFK")
MkToggle("Misc","🚫","Anti-Kick","AntiKick")

AddHdr("Config","🚀","SPEED")
MkSlider("Config","✈️","Fly Speed", 0, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
MkSlider("Config","👟","Walk Speed", 16, 200, Config.WalkSpeed, function(v)
	Config.WalkSpeed = v
	local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if State.Speed and h then h.WalkSpeed = v end
end)
AddHdr("Config","⬆️","JUMP")
MkSlider("Config","⬆️","Jump Power", 50, 500, Config.JumpPower, function(v)
	Config.JumpPower = v
	local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
	if State.HighJump and h then
		pcall(function() h.UseJumpPower = true; h.JumpPower = v; h.JumpHeight = v * 0.14 end)
	end
end)
MkSlider("Config","🐇","Bhop Power", 20, 150, Config.BhopPower, function(v) Config.BhopPower = v end)
AddHdr("Config","📦","HITBOX")
MkSlider("Config","📦","Hitbox Size", 2, 15, Config.HitboxSize, function(v) Config.HitboxSize = v end)
AddHdr("Config","🎯","AIM SETTINGS")
MkSlider("Config","⭕","Aim FOV (px)", 50, 500, Config.AimFOV, function(v)
	Config.AimFOV = v; UpdateFOVCircle()
end)
MkSlider("Config","🎚","Aim Smooth %", 5, 100, math.floor(Config.AimSmooth * 100), function(v)
	Config.AimSmooth = v / 100
end)

-- ============================================================
-- KEYBIND
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
	if waitingBind then
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			local key = inp.KeyCode
			local nm  = waitingBind
			Binds[nm] = key
			local d   = AllRows[nm]
			if d and d.bindBtn then
				d.bindBtn.Text       = tostring(key):gsub("Enum.KeyCode.", "")
				d.bindBtn.TextColor3 = P.dim
			end
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
	local pw = State.HighJump and Config.JumpPower or 50
	local v  = R.AssemblyLinearVelocity
	R.AssemblyLinearVelocity = Vector3.new(v.X, math.max(pw * 0.82, 42) + math.random(-2, 2), v.Z)
end)

-- ============================================================
-- ANIMATION LOOP
-- ============================================================
task.spawn(function()
	local t = 0
	while true do
		task.wait(0.033); t += 0.02
		local pulse = (math.sin(t * 2) + 1) / 2
		local aR    = math.floor(0   + pulse * 15)
		local aG    = math.floor(180 + pulse * 30)
		local aB    = math.floor(95  + pulse * 20)
		local acol  = Color3.fromRGB(aR, aG, aB)

		mSt.Color             = acol
		mB.TextColor3         = acol
		tGrad.Rotation        = (t * 15) % 360
		tAcc.BackgroundColor3 = acol
		tIco.TextColor3       = acol
		exStroke.Color        = acol

		mainS.Color = Color3.fromRGB(
			math.floor(38 + pulse * 20),
			math.floor(38 + pulse * 20),
			math.floor(48 + pulse * 20)
		)
		for nm, d in pairs(AllRows) do
			if State[nm] and d.accent then d.accent.BackgroundColor3 = acol end
		end
		if State.Aim or State.SilentAim then
			if not (aimLocked and aimTarget) then
				fovStroke.Color = Color3.fromRGB(180, 180, 200)
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

	local fc = fps >= 55 and Color3.fromRGB(130, 255, 170)
		or fps >= 30 and Color3.fromRGB(255, 220, 80)
		or Color3.fromRGB(255, 90, 90)
	local pc = pm <= 80 and Color3.fromRGB(130, 255, 170)
		or pm <= 150 and Color3.fromRGB(255, 220, 80)
		or Color3.fromRGB(255, 90, 90)

	-- Внутрішня панель меню
	fpsL.Text       = "FPS: " .. fps;       fpsL.TextColor3 = fc
	pngL.Text       = "Ping: " .. pm .. "ms"; pngL.TextColor3 = pc

	-- Зовнішня панель
	eF.Text         = tostring(fps);        eF.TextColor3   = fc
	eP.Text         = pm .. " ms";          eP.TextColor3   = pc

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
		if HRP.Position.Y > 2000 then HRP.CFrame -= Vector3.new(0, 2, 0) end
	end

	-- FREECAM
	if State.Freecam then
		local mx, mz = GetDir()
		local dir    = Camera.CFrame.LookVector * -mz + Camera.CFrame.RightVector * mx
		if UIS:IsKeyDown(Enum.KeyCode.E)           or UIS:IsKeyDown(Enum.KeyCode.Space)       or MobUp then dir += Camera.CFrame.UpVector end
		if UIS:IsKeyDown(Enum.KeyCode.Q)           or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then dir -= Camera.CFrame.UpVector end
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
			local sd     = ScreenDist(part)
			if sd < 30 then smooth = smooth * 0.3
			elseif sd < 80 then smooth = smooth * 0.6 end
			local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
			Camera.CFrame  = Camera.CFrame:Lerp(targetCF, smooth)
			local plr   = Players:GetPlayerFromCharacter(target)
			local dist2 = math.floor(dist)
			tgtInfo.Text       = "🔒 " .. (plr and plr.Name or "?") .. " [" .. dist2 .. "m]"
			tgtInfo.TextColor3 = Color3.fromRGB(0, 230, 120)
			tgtInfo.Visible    = true
			fovStroke.Color    = Color3.fromRGB(0, 230, 100)
			fovStroke.Thickness = 2
		else
			if showFOV then
				tgtInfo.Text       = "No target"
				tgtInfo.TextColor3 = P.dim
				tgtInfo.Visible    = true
			end
			fovStroke.Color     = Color3.fromRGB(180, 180, 200)
			fovStroke.Thickness = 1.5
		end
	end

	-- SILENT AIM VISUAL
	if State.SilentAim and not State.Aim and not State.Freecam then
		local tgt  = GetBestAimTarget()
		local part = tgt and FindAimPart(tgt)
		if part then
			local plr  = Players:GetPlayerFromCharacter(tgt)
			local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
			tgtInfo.Text       = "🔇 " .. (plr and plr.Name or "?") .. " [" .. dist .. "m]"
			tgtInfo.TextColor3 = Color3.fromRGB(255, 200, 50)
			tgtInfo.Visible    = true
			fovStroke.Color    = Color3.fromRGB(255, 200, 50)
		else
			if showFOV then
				tgtInfo.Text       = "No target"
				tgtInfo.TextColor3 = P.dim
				tgtInfo.Visible    = true
			end
			fovStroke.Color = Color3.fromRGB(180, 180, 200)
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

	if State.ShadowLock then
		if not IsAlive(LockedTarget) then LockedTarget = GetClosestDist() end
		if LockedTarget then
			local tR = LockedTarget:FindFirstChild("HumanoidRootPart")
			if tR then
				local pr = tR.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.2)
				HRP.CFrame = HRP.CFrame:Lerp(
					CFrame.new(tR.Position + pr) * tR.CFrame.Rotation * CFrame.new(0, 0, 3),
					0.4
				)
				HRP.AssemblyLinearVelocity = tR.AssemblyLinearVelocity
			end
		end
	end

	if State.Speed and not State.Fly and not State.Freecam then
		Hum.WalkSpeed = Config.WalkSpeed
		local now     = tick()
		if now - lastSpCk > 0.4 then
			lastSpCk = now
			task.delay(0.08, function()
				if Hum and Hum.Parent then
					spReset = math.abs(Hum.WalkSpeed - Config.WalkSpeed) > 4
				end
			end)
		end
		if spReset and Hum.MoveDirection.Magnitude > 0.1 then
			HRP.CFrame += Hum.MoveDirection.Unit * (Config.WalkSpeed - math.max(Hum.WalkSpeed, 16)) * dt
			local vel  = HRP.AssemblyLinearVelocity
			local hs   = Vector3.new(vel.X, 0, vel.Z).Magnitude
			if hs < Config.WalkSpeed * 0.7 then
				local pv = Hum.MoveDirection.Unit * Config.WalkSpeed
				HRP.AssemblyLinearVelocity = Vector3.new(pv.X, vel.Y, pv.Z)
			end
		end
	end

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

	if State.Bhop and not State.Fly and not State.Freecam then
		if Hum.MoveDirection.Magnitude > 0.1 then
			local now = tick()
			if Hum.FloorMaterial ~= Enum.Material.Air and now - lastBhop > 0.06 then
				Hum:ChangeState(Enum.HumanoidStateType.Jumping)
				local v  = HRP.AssemblyLinearVelocity
				local md = Hum.MoveDirection.Unit
				HRP.AssemblyLinearVelocity = Vector3.new(
					v.X + md.X * (4 + math.random() * 3),
					Config.BhopPower + math.random(-6, 6),
					v.Z + md.Z * (4 + math.random() * 3)
				)
				lastBhop = now
			end
		end
	end

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
			ncStuck = ncStuck + 1
		else
			ncStuck = 0
		end
		if ncStuck >= 3 then
			local md = Hum.MoveDirection.Magnitude > 0.05
				and Hum.MoveDirection.Unit
				or HRP.CFrame.LookVector
			ncRay.FilterDescendantsInstances = {Char}
			local r = Workspace:Raycast(HRP.Position, md * 8, ncRay)
			if r then
				HRP.CFrame += md * (r.Distance + 2.5)
			else
				HRP.CFrame += md * 0.6 + Vector3.new(0, 0.15, 0)
			end
			if ncStuck >= 6 then
				HRP.AssemblyLinearVelocity = Vector3.new(
					md.X * 18, HRP.AssemblyLinearVelocity.Y + 3, md.Z * 18
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

Notify("OMNI V265.4", "✅ Drag FPS panel (local events) · AimBot · Wall Check ✓", 5)
