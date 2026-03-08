-- ██████████████████████████████████████████████████████████
-- ██  OMNI V305 — PERFECT EDITION (EN/UA) [MOD]          ██
-- ██  Clean ESP · Better Noclip Bypass · Anti-Void        ██
-- ██  Language Toggle · Function Descriptions · Mobile+PC ██
-- ██████████████████████████████████████████████████████████

-- ============================================================
-- 1. SERVICES
-- ============================================================
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

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
-- 2. LANGUAGE SYSTEM
-- ============================================================
local CurrentLang = "EN"

local Strings = {
    EN = {
        title = "OMNI V305",
        subtitle_mobile = "MOBILE · PERFECT EDITION",
        subtitle_pc = "UNIVERSAL · PERFECT EDITION",
        tab_combat = "Combat",
        tab_move   = "Move",
        tab_misc   = "Misc",
        tab_config = "Config",
        hdr_aiming       = "AIMING",
        hdr_hitbox_esp   = "HITBOX & ESP",
        hdr_flight       = "FLIGHT",
        hdr_speed_jump   = "SPEED & JUMP",
        hdr_physics      = "PHYSICS",
        hdr_safe_speed   = "SAFE SPEED MODE",
        hdr_effects      = "EFFECTS",
        hdr_protection   = "PROTECTION",
        hdr_server_hop   = "SERVER HOP",
        hdr_save_config  = "SAVE CONFIG",
        hdr_speed_vals   = "SPEED VALUES",
        hdr_jump_vals    = "JUMP VALUES",
        hdr_hitbox_cfg   = "HITBOX",
        hdr_aim_settings = "AIM SETTINGS",
        hdr_anti_void    = "ANTI-VOID",
        hdr_anti_ban     = "ANTI-BAN",
        hdr_language     = "LANGUAGE",
        lbl_auto_aim      = "Auto Aim",
        lbl_silent_aim    = "Silent Aim",
        lbl_shadow_lock   = "Magnet (ShadowLock)",
        lbl_hitbox        = "Hitbox Expand",
        lbl_esp           = "ESP",
        lbl_fly           = "Fly",
        lbl_freecam       = "Freecam",
        lbl_speed         = "Speed",
        lbl_bhop          = "Bhop",
        lbl_high_jump     = "High Jump",
        lbl_infinite_jump = "Infinite Jump",
        lbl_noclip        = "Noclip",
        lbl_no_fall       = "No Fall Damage",
        lbl_anti_void     = "Anti-Void",
        lbl_safe_speed    = "Safe Speed (Anti Rubber-Band)",
        lbl_spin          = "Spin",
        lbl_potato        = "Potato Mode",
        lbl_fullbright    = "FullBright",
        desc_fullbright   = "Sets max brightness and removes all Lighting effects — everything is fully visible even in dark maps.",
        lbl_fake_lag      = "Fake Lag",
        lbl_anti_afk      = "Anti-AFK",
        lbl_speed_jitter  = "Speed Jitter",
        lbl_hitbox_rand   = "Hitbox Randomize",
        lbl_aim_anti      = "Aim Anti-Detect",
        desc_auto_aim      = "Automatically aims your camera at the nearest visible enemy within FOV radius.",
        desc_silent_aim    = "Redirects raycasts to enemies without moving your camera. Requires exploit hooks.",
        desc_shadow_lock   = "Teleports you behind the closest enemy, following their movement.",
        desc_hitbox        = "Expands enemy hitbox parts so they are easier to hit.",
        desc_esp           = "Shows player name, HP and distance as clean floating text above all players.",
        desc_fly           = "Allows free flight in any direction. Use W/A/S/D + Space/Ctrl.",
        desc_freecam       = "Detaches camera from character for free spectating.",
        desc_speed         = "Increases your walk speed beyond the game default.",
        desc_bhop          = "Auto-bunny hop: hold Space while moving to chain jumps with speed boost.",
        desc_high_jump     = "Increases your jump height/power significantly.",
        desc_infinite_jump = "Allows jumping in mid-air infinitely.",
        desc_noclip        = "Walk through walls. Uses multi-method bypass for all places.",
        desc_no_fall       = "Prevents fall damage by resetting state before landing.",
        desc_anti_void     = "Teleports you back to safety if you fall below the void threshold.",
        desc_safe_speed    = "Caps your speed relative to the game's base speed to avoid rubber-banding.",
        desc_spin          = "Spins your character rapidly around the Y axis.",
        desc_potato        = "Disables shadows, particles, and lowers quality for better FPS.",
        desc_fake_lag      = "Simulates lag by briefly anchoring your character while moving.",
        desc_anti_afk      = "Prevents the game from kicking you for being idle.",
        desc_speed_jitter  = "Adds small random variation to speed to avoid anti-cheat detection.",
        desc_hitbox_rand   = "Adds small random variation to hitbox size to avoid detection.",
        desc_aim_anti      = "Adds micro-jitter to aim direction to avoid pattern detection.",
        sl_fly_speed    = "Fly Speed",
        sl_walk_speed   = "Walk Speed",
        sl_jump_power   = "Jump Power",
        sl_bhop_power   = "Bhop Power",
        sl_hitbox_size  = "Hitbox Size",
        sl_esp_dist     = "ESP Radius (studs)",
        sl_aim_fov      = "Aim FOV (px)",
        sl_aim_smooth   = "Aim Smooth %",
        sl_anti_void_h  = "Anti-Void Height",
        sl_safe_mult    = "Multiplier (×base)",
        btn_save     = "💾 Save",
        btn_load     = "📂 Load",
        btn_reset    = "🔄 Reset",
        btn_rejoin   = "Rejoin (same server)",
        btn_random   = "Random server",
        btn_biggest  = "Biggest server",
        btn_smallest = "Smallest server",
        ntf_saved      = "💾 Saved",
        ntf_loaded     = "📂 Config loaded ✓",
        ntf_reset      = "🔄 Reset",
        ntf_no_write   = "❌ writefile unavailable",
        ntf_no_read    = "❌ readfile unavailable",
        ntf_no_file    = "📂 File not found",
        ntf_json_err   = "❌ JSON error",
        ntf_error      = "❌ Error: ",
        ntf_rejoin     = "🔄 Rejoining...",
        ntf_search_rnd = "🎲 Searching random...",
        ntf_search_big = "👥 Searching biggest...",
        ntf_search_sml = "🕵️ Searching smallest...",
        ntf_srv_fail   = "❌ Server list unavailable",
        ntf_players    = " players",
        ntf_wait       = "⏳ Please wait...",
        ntf_safe_on    = "🛡 ON · Cap: ",
        ntf_safe_off   = "🛡 OFF",
        ntf_hook_ok    = "🔇 Hook installed ✓",
        ntf_anti_void  = "🛡 Teleported to safe position",
        ntf_startup    = "✅ Perfect Edition · Clean ESP · Multi-Bypass Noclip",
        ntf_lang       = "Language changed to: ",
        stat_no_target = "No target",
        stat_auto_save = "⏱ Auto-save every 60s · OmniV305_Config.json",
        stat_safe_info = "📊 Game base: %d | Cap (×%.1f): %d%s\n⚡ Set: %d → Effective: %d",
        btn_lang_toggle = "🌐 Language: English → Українська",
    },
    UA = {
        title = "OMNI V305",
        subtitle_mobile = "МОБІЛЬНА · ІДЕАЛЬНА ВЕРСІЯ",
        subtitle_pc = "УНІВЕРСАЛЬНА · ІДЕАЛЬНА ВЕРСІЯ",
        tab_combat = "Бій",
        tab_move   = "Рух",
        tab_misc   = "Інше",
        tab_config = "Налашт.",
        hdr_aiming       = "ПРИЦІЛЮВАННЯ",
        hdr_hitbox_esp   = "ХІТБОКС & ESP",
        hdr_flight       = "ПОЛІТ",
        hdr_speed_jump   = "ШВИДКІСТЬ & СТРИБОК",
        hdr_physics      = "ФІЗИКА",
        hdr_safe_speed   = "БЕЗПЕЧНА ШВИДКІСТЬ",
        hdr_effects      = "ЕФЕКТИ",
        hdr_protection   = "ЗАХИСТ",
        hdr_server_hop   = "ЗМІНА СЕРВЕРА",
        hdr_save_config  = "ЗБЕРЕЖЕННЯ КОНФІГУ",
        hdr_speed_vals   = "ЗНАЧЕННЯ ШВИДКОСТІ",
        hdr_jump_vals    = "ЗНАЧЕННЯ СТРИБКА",
        hdr_hitbox_cfg   = "ХІТБОКС",
        hdr_aim_settings = "НАЛАШТУВАННЯ ПРИЦІЛУ",
        hdr_anti_void    = "АНТИ-ВОЙД",
        hdr_anti_ban     = "АНТИ-БАН",
        hdr_language     = "МОВА",
        lbl_auto_aim      = "Авто Прицілювання",
        lbl_silent_aim    = "Тихий Прицілювання",
        lbl_shadow_lock   = "Магніт (ShadowLock)",
        lbl_hitbox        = "Розширення хітбокса",
        lbl_esp           = "ESP",
        lbl_fly           = "Літання",
        lbl_freecam       = "Вільна камера",
        lbl_speed         = "Швидкість",
        lbl_bhop          = "Bhop",
        lbl_high_jump     = "Високий стрибок",
        lbl_infinite_jump = "Нескінченний стрибок",
        lbl_noclip        = "Нокліп",
        lbl_no_fall       = "Без пошкодження від падіння",
        lbl_anti_void     = "Анти-Войд",
        lbl_safe_speed    = "Безпечна швидкість (Анти Rubber-Band)",
        lbl_spin          = "Обертання",
        lbl_potato        = "Картопляний режим",
        lbl_fullbright    = "Фул Брайт",
        desc_fullbright   = "Максимальна яскравість і видалення всіх ефектів освітлення — все видно навіть на темних картах.",
        lbl_fake_lag      = "Фейк лаг",
        lbl_anti_afk      = "Анти-АФК",
        lbl_speed_jitter  = "Джиттер швидкості",
        lbl_hitbox_rand   = "Рандомізація хітбокса",
        lbl_aim_anti      = "Анти-детект прицілу",
        desc_auto_aim      = "Автоматично наводить камеру на найближчого видимого ворога в радіусі FOV.",
        desc_silent_aim    = "Перенаправляє рейкасти на ворогів без руху камери. Потрібні хуки.",
        desc_shadow_lock   = "Телепортує вас за найближчого ворога.",
        desc_hitbox        = "Збільшує хітбокс частини ворогів.",
        desc_esp           = "Показує нік, HP та відстань як чистий текст над усіма гравцями.",
        desc_fly           = "Вільний політ. W/A/S/D + Пробіл/Ctrl.",
        desc_freecam       = "Від'єднує камеру від персонажа.",
        desc_speed         = "Збільшує швидкість ходьби.",
        desc_bhop          = "Авто-банні хоп.",
        desc_high_jump     = "Збільшує висоту стрибка.",
        desc_infinite_jump = "Нескінченний стрибок у повітрі.",
        desc_noclip        = "Проходь крізь стіни. Мульти-метод обходу для всіх плейсів.",
        desc_no_fall       = "Запобігає пошкодженню від падіння.",
        desc_anti_void     = "Телепортує назад при падінні у войд.",
        desc_safe_speed    = "Обмежує швидкість для уникнення відкиду.",
        desc_spin          = "Обертає персонажа.",
        desc_potato        = "Знижує якість для кращого FPS.",
        desc_fake_lag      = "Імітує лаг.",
        desc_anti_afk      = "Запобігає кіку за бездіяльність.",
        desc_speed_jitter  = "Варіація швидкості для уникнення античіту.",
        desc_hitbox_rand   = "Варіація хітбокса для уникнення детекту.",
        desc_aim_anti      = "Мікро-тремтіння прицілу для уникнення детекту.",
        sl_fly_speed    = "Швидкість польоту",
        sl_walk_speed   = "Швидкість ходьби",
        sl_jump_power   = "Сила стрибка",
        sl_bhop_power   = "Сила Bhop",
        sl_hitbox_size  = "Розмір хітбокса",
        sl_esp_dist     = "Радіус ESP (стадів)",
        sl_aim_fov      = "FOV прицілу (пкс)",
        sl_aim_smooth   = "Плавність прицілу %",
        sl_anti_void_h  = "Висота Анти-Войд",
        sl_safe_mult    = "Множник (×база)",
        btn_save     = "💾 Зберегти",
        btn_load     = "📂 Завантажити",
        btn_reset    = "🔄 Скинути",
        btn_rejoin   = "Повторний вхід (той самий сервер)",
        btn_random   = "Рандомний сервер",
        btn_biggest  = "Найбільший сервер",
        btn_smallest = "Найменший сервер",
        ntf_saved      = "💾 Збережено",
        ntf_loaded     = "📂 Конфіг завантажено ✓",
        ntf_reset      = "🔄 Скинуто",
        ntf_no_write   = "❌ writefile недоступний",
        ntf_no_read    = "❌ readfile недоступний",
        ntf_no_file    = "📂 Файл не знайдено",
        ntf_json_err   = "❌ Помилка JSON",
        ntf_error      = "❌ Помилка: ",
        ntf_rejoin     = "🔄 Перезаходжу...",
        ntf_search_rnd = "🎲 Шукаю рандомний...",
        ntf_search_big = "👥 Шукаю найбільший...",
        ntf_search_sml = "🕵️ Шукаю найменший...",
        ntf_srv_fail   = "❌ Список серверів недоступний",
        ntf_players    = " гравців",
        ntf_wait       = "⏳ Зачекайте...",
        ntf_safe_on    = "🛡 ON · Ліміт: ",
        ntf_safe_off   = "🛡 OFF",
        ntf_hook_ok    = "🔇 Хук встановлено ✓",
        ntf_anti_void  = "🛡 Телепортовано на безпечну позицію",
        ntf_startup    = "✅ Ідеальна Версія · Чистий ESP · Мульти-Обхід Нокліп",
        ntf_lang       = "Мову змінено на: ",
        stat_no_target = "Ціль відсутня",
        stat_auto_save = "⏱ Авто-зберігання кожні 60 сек · OmniV305_Config.json",
        stat_safe_info = "📊 База: %d | Ліміт (×%.1f): %d%s\n⚡ Встановлено: %d → Ефективно: %d",
        btn_lang_toggle = "🌐 Мова: Українська → English",
    },
}

local function L(key)
    local tbl = Strings[CurrentLang]
    if tbl and tbl[key] then return tbl[key] end
    local en = Strings["EN"]
    if en and en[key] then return en[key] end
    return key
end

-- ============================================================
-- 3. ENVIRONMENT DETECTION
-- ============================================================
local ENV = {}
local function _envCheck(fn)
    local ok, v = pcall(fn)
    return ok and v == true
end
ENV.hasGetRawMeta   = _envCheck(function() return getrawmetatable ~= nil end)
ENV.hasSetReadOnly  = _envCheck(function() return setreadonly ~= nil end)
ENV.hasNewCClosure  = _envCheck(function() return newcclosure ~= nil end)
ENV.hasGetNameCall  = _envCheck(function() return getnamecallmethod ~= nil end)
ENV.hasHookFunction = _envCheck(function() return hookfunction ~= nil end)
ENV.hasSynapse      = _envCheck(function() return syn ~= nil end)
                   or _envCheck(function() return SENTINEL_V2 ~= nil end)

-- ============================================================
-- 4. ANTI-DETECTION: Cleanup old instances
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
-- 4B. NOCLIP COLLISION GROUP SETUP (Multi-method bypass)
-- ============================================================
-- We use a randomly-named group so game anti-cheats can't hardblock by name
local SafeGroup = "NC_" .. math.random(100000, 999999)
local ncGroupReady = false

pcall(function()
    -- Method 1: New API (2022+)
    if PhysicsService.RegisterCollisionGroup then
        local ok = pcall(function()
            PhysicsService:RegisterCollisionGroup(SafeGroup)
        end)
        if ok then
            pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Default", false) end)
            pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Players", false) end)
            pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, SafeGroup, false) end)
            ncGroupReady = true
        end
    end
    -- Method 2: Old API fallback
    if not ncGroupReady and PhysicsService.CreateCollisionGroup then
        local ok = pcall(function() PhysicsService:CreateCollisionGroup(SafeGroup) end)
        if ok then
            pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, "Default", false) end)
            pcall(function() PhysicsService:CollisionGroupSetCollidable(SafeGroup, SafeGroup, false) end)
            ncGroupReady = true
        end
    end
end)

-- ============================================================
-- 5. UTILITY FUNCTIONS
-- ============================================================
local function RndStr(n)
    local c = {}
    for i = 1, n do c[i] = string.char(math.random(97, 122)) end
    return table.concat(c)
end

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 2})
    end)
end

local function SafeDel(o)
    pcall(function() if o and o.Parent then o:Destroy() end end)
end

local IsMob = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsTab = UIS.TouchEnabled

local Blur = Instance.new("BlurEffect")
Blur.Size   = 0
Blur.Parent = Lighting

local Controls, ControlsOK = nil, false
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)
    pcall(function()
        local pm = require(LP.PlayerScripts:WaitForChild("PlayerModule", 10))
        Controls   = pm:GetControls()
        ControlsOK = true
    end)
end)

-- ============================================================
-- 6. CONFIGURATION & STATE
-- ============================================================
local Config = {
    FlySpeed          = 55,
    WalkSpeed         = 30,
    JumpPower         = 125,
    BhopPower         = 62,
    HitboxSize        = 5,
    AimFOV            = 200,
    AimSmooth         = 0.18,
    AimPart           = "Head",
    ESPDistance       = 700,
    SpeedAntiBan      = true,
    FlyAntiBan        = true,
    HitboxRandomize   = true,
    AimAntiDetect     = true,
    SpeedJitter       = 1.5,
    FlyHeightMax      = 1800,
    SafeSpeedMode     = false,
    SafeSpeedMult     = 1.8,
    AntiVoidHeight    = -180,
    MobHUDPositions   = {},
}

local Binds = {
    Fly        = Enum.KeyCode.F,
    Aim        = Enum.KeyCode.G,
    Noclip     = Enum.KeyCode.V,
    SilentAim  = Enum.KeyCode.B,
    FakeLag    = Enum.KeyCode.H,
    ToggleMenu = Enum.KeyCode.M,
}

local State = {
    Fly = false, Aim = false, SilentAim = false, ShadowLock = false,
    Noclip = false, Hitbox = false, Speed = false, Bhop = false,
    ESP = false, Spin = false, HighJump = false, Potato = false, FullBright = false,
    FakeLag = false, Freecam = false, NoFallDamage = false,
    AntiAFK = false, InfiniteJump = false, AntiVoid = false,
    SpeedAntiBan = true, HitboxRandomize = true,
    AimAntiDetect = true, SafeSpeedMode = false,
}

-- ============================================================
-- 7. CONFIG PERSISTENCE
-- ============================================================
local CFG_FILE = "OmniV305_Config.json"
local SAVE_STATE_KEYS = {
    "AntiAFK", "ESP", "Hitbox", "Speed", "HighJump",
    "Bhop", "NoFallDamage", "InfiniteJump", "Potato",
    "AntiVoid",
}
local SAVE_CFG_KEYS = {
    "SpeedAntiBan", "HitboxRandomize", "AimAntiDetect", "SafeSpeedMode",
}

local function HasFileSystem()
    return (writefile ~= nil and readfile ~= nil)
end

local function SerializeBinds()
    local t = {}
    for k, v in pairs(Binds) do
        t[k] = tostring(v):gsub("Enum%.KeyCode%.", "")
    end
    return t
end

local function DeserializeBinds(t)
    for k, v in pairs(t) do
        local ok, kc = pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then Binds[k] = kc end
    end
end

local SliderRefs = {}

local function SaveConfig()
    if not HasFileSystem() then
        Notify("Config", L("ntf_no_write"), 3)
        return false
    end
    local data = {
        version = "v305",
        config = {},
        binds  = SerializeBinds(),
        state  = {},
        lang   = CurrentLang,
    }
    for k, v in pairs(Config) do data.config[k] = v end
    for _, k in pairs(SAVE_STATE_KEYS) do data.state[k] = State[k] or false end
    for _, k in pairs(SAVE_CFG_KEYS) do data.state[k] = State[k] or false end

    local ok, err = pcall(function()
        writefile(CFG_FILE, HttpService:JSONEncode(data))
    end)
    if ok then
        Notify("Config", L("ntf_saved"), 2)
        return true
    else
        Notify("Config", L("ntf_error") .. (err or "?"), 3)
        return false
    end
end

local function ApplyLoadedConfig(data)
    if data.config then
        for k, v in pairs(data.config) do
            if Config[k] ~= nil then
                -- MobHUDPositions is a nested table — merge it, don't replace whole Config entry with a raw JSON table
                if k == "MobHUDPositions" and type(v) == "table" then
                    Config.MobHUDPositions = {}
                    for id, pos in pairs(v) do
                        if type(pos) == "table" and pos[1] and pos[2] then
                            Config.MobHUDPositions[id] = {pos[1], pos[2]}
                        end
                    end
                else
                    Config[k] = v
                end
            end
        end
    end
    if data.binds then DeserializeBinds(data.binds) end
    for _, k in pairs(SAVE_CFG_KEYS) do
        if data.state and data.state[k] ~= nil then
            State[k] = data.state[k]
            Config[k] = data.state[k]
        end
    end
    if data.lang and (data.lang == "EN" or data.lang == "UA") then
        CurrentLang = data.lang
    end
end

local function UpdateAllSliders()
    for key, ref in pairs(SliderRefs) do
        if ref and ref.update then
            pcall(ref.update, Config[key] or ref.default)
        end
    end
end

local function LoadConfig()
    if not HasFileSystem() then
        Notify("Config", L("ntf_no_read"), 3)
        return false
    end
    local ok, content = pcall(readfile, CFG_FILE)
    if not ok or not content or content == "" then
        Notify("Config", L("ntf_no_file"), 2)
        return false
    end
    local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or not data then
        Notify("Config", L("ntf_json_err"), 3)
        return false
    end
    ApplyLoadedConfig(data)
    UpdateAllSliders()
    Notify("Config", L("ntf_loaded"), 2)
    return true
end

local function ResetConfig()
    Config.FlySpeed = 55; Config.WalkSpeed = 30; Config.JumpPower = 125
    Config.BhopPower = 62; Config.HitboxSize = 5; Config.AimFOV = 200
    Config.AimSmooth = 0.18; Config.SpeedAntiBan = true; Config.FlyAntiBan = true
    Config.HitboxRandomize = true; Config.AimAntiDetect = true
    Config.SpeedJitter = 1.5; Config.FlyHeightMax = 1800
    Config.SafeSpeedMode = false; Config.SafeSpeedMult = 1.8
    Config.AntiVoidHeight = -180; Config.ESPDistance = 700
    Binds.Fly = Enum.KeyCode.F; Binds.Aim = Enum.KeyCode.G
    Binds.Noclip = Enum.KeyCode.V; Binds.SilentAim = Enum.KeyCode.B
    Binds.FakeLag = Enum.KeyCode.H; Binds.ToggleMenu = Enum.KeyCode.M
    State.SpeedAntiBan = true; State.HitboxRandomize = true
    State.AimAntiDetect = true; State.SafeSpeedMode = false
    UpdateAllSliders()
    Notify("Config", L("ntf_reset"), 2)
end

task.spawn(function()
    while task.wait(60) do
        if HasFileSystem() then pcall(SaveConfig) end
    end
end)

-- ============================================================
-- 8. NOISE GENERATOR
-- ============================================================
local _pSeed = math.random(1, 99999)
local function PseudoNoise(x)
    local xi = math.floor(x) % 256
    local xf = x - math.floor(x)
    local u  = xf * xf * (3 - 2 * xf)
    local a  = (xi * 1664525 + 1013904223 + _pSeed) % 2 ^ 32
    local b  = ((xi + 1) * 1664525 + 1013904223 + _pSeed) % 2 ^ 32
    local na = (a / 2 ^ 32) * 2 - 1
    local nb = (b / 2 ^ 32) * 2 - 1
    return na + u * (nb - na)
end

local _speedNoiseT = 0
local _flyNoiseT   = 100

-- ============================================================
-- 9. SPEED SYSTEM
-- ============================================================
local gameBaseSpeed = 16

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(1.5)
    pcall(function()
        local C = LP.Character or LP.CharacterAdded:Wait()
        local H = C:WaitForChild("Humanoid", 5)
        if H then
            local samples = {}
            for i = 1, 5 do
                task.wait(0.3)
                if H and H.Parent and not State.Speed then
                    table.insert(samples, H.WalkSpeed)
                end
            end
            if #samples > 0 then
                local maxSpd = 0
                for _, v in pairs(samples) do
                    if v > maxSpd then maxSpd = v end
                end
                if maxSpd >= 4 and maxSpd <= 100 then gameBaseSpeed = maxSpd end
            end
        end
    end)
end)

local function GetSafeSpeed()
    local base = Config.WalkSpeed
    if State.SafeSpeedMode then
        local cap = gameBaseSpeed * Config.SafeSpeedMult
        base = math.min(base, cap)
    end
    if not Config.SpeedAntiBan then return base end
    _speedNoiseT = _speedNoiseT + 0.008
    local n   = PseudoNoise(_speedNoiseT)
    local jit = Config.SpeedJitter
    if math.random(1, 220) == 1 then return math.max(base * 0.82, 14) end
    return math.clamp(base + n * jit, base * 0.9, base * 1.12)
end

-- ============================================================
-- 10. CORE HELPER FUNCTIONS
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

local aimRay = RaycastParams.new()
aimRay.FilterType = Enum.RaycastFilterType.Exclude

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

local function GetClosestEnemy()
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

local function GetDir()
    local mx, mz = 0, 0
    if not IsMob then
        if UIS:IsKeyDown(Enum.KeyCode.W) then mz = -1 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mz = 1 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mx = -1 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mx = 1 end
    elseif ControlsOK and Controls then
        local ok, mv = pcall(function() return Controls:GetMoveVector() end)
        if ok and mv then mx = mv.X; mz = mv.Z end
    end
    return mx, mz
end

-- ============================================================
-- 11. AIM TARGETING SYSTEM
-- ============================================================
local aimTarget      = nil
local aimLastSwitch  = 0
local aimLocked      = false
local aimLostFrames  = 0
local aimSwitchCD    = 0.35

local function FindNewTarget()
    local fov = Config.AimFOV
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
                aimLostFrames += 1
                if aimLostFrames < (vis and 8 or 15) then return char end
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

-- ============================================================
-- 12. ESP SYSTEM — CLEAN FLOATING TEXT, NO BOX, LOW LAG
-- ============================================================
-- Design: no background frame, just shadow text floating above head
-- Shows: "PlayerName  HP/MaxHP  Xm" colour-coded by health
-- Uses a single TextLabel per player, cached, updated every 0.2s

local ESPCache = {}

local function GetESPColor(ratio)
    if ratio >= 0.6 then
        return Color3.fromRGB(80, 255, 120)
    elseif ratio >= 0.3 then
        return Color3.fromRGB(255, 220, 40)
    else
        return Color3.fromRGB(255, 60, 60)
    end
end

local function ClearESP()
    for _, d in pairs(ESPCache) do
        pcall(function() if d.hl and d.hl.Parent then d.hl:Destroy() end end)
        pcall(function() if d.bb and d.bb.Parent then d.bb:Destroy() end end)
    end
    ESPCache = {}
end

-- ESP update loop — runs every 0.2s to avoid lag
-- Also listens to CharacterAdded so ESP rebuilds instantly on respawn

local function ESP_RemovePlayer(p)
    local ca = ESPCache[p]
    if ca then
        pcall(function() if ca.hl and ca.hl.Parent then ca.hl:Destroy() end end)
        pcall(function() if ca.bb and ca.bb.Parent then ca.bb:Destroy() end end)
        ESPCache[p] = nil
    end
end

-- Hook CharacterAdded for all current + future players
local function ESP_HookPlayer(p)
    if p == LP then return end
    p.CharacterAdded:Connect(function()
        -- Wipe old ESP entry so the update loop rebuilds it for the new character
        ESP_RemovePlayer(p)
    end)
    p.CharacterRemoving:Connect(function()
        ESP_RemovePlayer(p)
    end)
end

for _, p in pairs(Players:GetPlayers()) do
    ESP_HookPlayer(p)
end
Players.PlayerAdded:Connect(ESP_HookPlayer)

task.spawn(function()
    while task.wait(0.2) do
        if not State.ESP then continue end

        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

        for _, p in pairs(Players:GetPlayers()) do
            if p == LP then continue end

            local char = p.Character
            local head = char and FindHead(char)
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            -- Player has no valid character → remove entry
            if not char or not head or not hum then
                ESP_RemovePlayer(p)
                continue
            end

            -- Detect character swap (respawn = new char object)
            local ca = ESPCache[p]
            if ca and ca.char ~= char then
                -- Character changed — wipe and rebuild
                ESP_RemovePlayer(p)
                ca = nil
            end

            -- Check if cache is still valid
            local needRebuild = not ca
                or not ca.bb or not ca.bb.Parent
                or not ca.lbl or not ca.lbl.Parent

            if needRebuild then
                -- Clean up old
                if ca then
                    pcall(function() if ca.hl and ca.hl.Parent then ca.hl:Destroy() end end)
                    pcall(function() if ca.bb and ca.bb.Parent then ca.bb:Destroy() end end)
                end

                -- Highlight (fills character with colour, no outline box on screen)
                local hl = Instance.new("Highlight")
                hl.FillTransparency    = 0.55
                hl.OutlineTransparency = 1     -- no outline = less visual clutter
                hl.FillColor           = Color3.fromRGB(40, 180, 80)
                hl.Parent              = char

                -- BillboardGui: wide enough for text, no background
                local bb = Instance.new("BillboardGui")
                bb.Size          = UDim2.new(0, 200, 0, 36)
                bb.StudsOffset   = Vector3.new(0, 2.8, 0)
                bb.AlwaysOnTop   = true
                bb.MaxDistance   = Config.ESPDistance
                bb.LightInfluence = 0
                bb.Parent        = head

                -- Single TextLabel — no background frame
                local lbl = Instance.new("TextLabel")
                lbl.Name                  = "ESPLabel"
                lbl.Size                  = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font                  = Enum.Font.GothamBold
                lbl.TextSize              = IsMob and 12 or 11
                lbl.TextWrapped           = false
                lbl.TextXAlignment        = Enum.TextXAlignment.Center
                lbl.TextYAlignment        = Enum.TextYAlignment.Center
                -- Shadow for readability (built-in stroke)
                lbl.TextStrokeColor3      = Color3.new(0, 0, 0)
                lbl.TextStrokeTransparency = 0.35
                lbl.ZIndex                = 5
                lbl.Parent                = bb

                ESPCache[p] = {hl = hl, bb = bb, lbl = lbl, char = char}
                ca = ESPCache[p]
            end

            -- Update values
            -- Smart HP read: handles MaxHealth=math.huge, custom attributes, IntValues
            local rawHp    = hum.Health
            local rawMaxHp = hum.MaxHealth

            -- If MaxHealth is infinite/huge, try to find a custom max from character
            if rawMaxHp == math.huge or rawMaxHp <= 0 then
                -- look for IntValue/NumberValue named MaxHealth/MaxHP/HealthMax inside char
                local found = false
                for _, v in pairs(char:GetDescendants()) do
                    if (v:IsA("IntValue") or v:IsA("NumberValue")) and
                        (v.Name == "MaxHealth" or v.Name == "MaxHP" or v.Name == "HealthMax") then
                        rawMaxHp = v.Value; found = true; break
                    end
                end
                -- check attributes too
                if not found then
                    local attrMax = char:GetAttribute("MaxHealth")
                        or char:GetAttribute("MaxHP")
                        or hum:GetAttribute("MaxHealth")
                    if attrMax then rawMaxHp = attrMax end
                end
                -- last resort: use current HP as max so ratio = 1
                if rawMaxHp == math.huge or rawMaxHp <= 0 then
                    rawMaxHp = math.max(rawHp, 1)
                end
            end

            -- Try attribute-based current HP (some games store real HP in attributes)
            local attrHp = char:GetAttribute("Health")
                or char:GetAttribute("HP")
                or hum:GetAttribute("Health")
            if attrHp and type(attrHp) == "number" then
                rawHp = attrHp
            end

            local hp    = math.floor(rawHp)
            local maxHp = math.max(math.floor(rawMaxHp), 1)
            local dist  = myHRP
                and math.floor((myHRP.Position - head.Position).Magnitude)
                or 0
            local ratio = math.clamp(hp / maxHp, 0, 1)
            local col   = GetESPColor(ratio)

            -- Keep MaxDistance in sync with slider (instant effect, no rebuild)
            ca.bb.MaxDistance = Config.ESPDistance

            -- Format: "PlayerName  HP/MaxHP  Xm"
            ca.lbl.Text       = string.format("%s  %d/%d  %dm", p.Name, hp, maxHp, dist)
            ca.lbl.TextColor3 = col

            -- Update highlight colour to match health
            ca.hl.FillColor = ratio >= 0.5
                and Color3.fromRGB(40, 180, 80)
                or Color3.fromRGB(200, 40, 40)
        end

        -- Prune players who left but weren't caught by PlayerRemoving
        for p, ca in pairs(ESPCache) do
            if not p or not p.Parent then
                pcall(function() if ca.hl and ca.hl.Parent then ca.hl:Destroy() end end)
                pcall(function() if ca.bb and ca.bb.Parent then ca.bb:Destroy() end end)
                ESPCache[p] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    ESP_RemovePlayer(p)
end)

-- ============================================================
-- 13. HITBOX SYSTEM
-- ============================================================
local hbParts = {}

local function ApplyHB(part)
    if not part or not part:IsA("BasePart") then return end
    if not hbParts[part] then
        hbParts[part] = {
            S = part.Size, T = part.Transparency,
            C = part.CanCollide, M = part.Massless,
        }
    end
    local s = Config.HitboxSize
    if Config.HitboxRandomize then s = s + (math.random() * 0.4 - 0.2) end
    part.Size = Vector3.new(s, s, s)
    part.Transparency = 0.7
    part.CanCollide = false
    part.Massless = true
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
                    and v.Size.Magnitude > 0.3
                    and v.Size.X < s - 0.2 then
                    pcall(ApplyHB, v)
                end
            end
        end
        for part in pairs(hbParts) do
            if part and part.Parent and math.abs(part.Size.X - s) > 0.5 then
                pcall(function() part.Size = Vector3.new(s, s, s) end)
            end
        end
    end
end)

-- ============================================================
-- 14. POTATO MODE
-- ============================================================
local savedShd, savedQ = true, Enum.QualityLevel.Automatic

local function DoPotato()
    pcall(function()
        savedShd = Lighting.GlobalShadows
        savedQ = settings().Rendering.QualityLevel
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    for _, v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.CastShadow = false; v.Reflectance = 0
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
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
            if v:IsA("BasePart") then v.CastShadow = true
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = true
            end
        end)
    end
end

-- ============================================================
-- 14B. FULLBRIGHT SYSTEM
-- ============================================================
local _fbSaved = {}

local function DoFullBright()
    _fbSaved = {
        Ambient              = Lighting.Ambient,
        OutdoorAmbient       = Lighting.OutdoorAmbient,
        Brightness           = Lighting.Brightness,
        ClockTime            = Lighting.ClockTime,
        FogEnd               = Lighting.FogEnd,
        FogStart             = Lighting.FogStart,
        GlobalShadows        = Lighting.GlobalShadows,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
    pcall(function()
        Lighting.Ambient              = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient       = Color3.fromRGB(178, 178, 178)
        Lighting.Brightness           = 10
        Lighting.ClockTime            = 14
        Lighting.FogEnd               = 100000
        Lighting.FogStart             = 100000
        Lighting.GlobalShadows        = false
        Lighting.EnvironmentDiffuseScale  = 0
        Lighting.EnvironmentSpecularScale = 0
    end)
    -- Disable all Lighting post-effects (Blur, Bloom, ColorCorrection, etc.)
    for _, v in pairs(Lighting:GetChildren()) do
        pcall(function()
            if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
                v.Enabled = false
            end
        end)
    end
end

local function UndoFullBright()
    for k, v in pairs(_fbSaved) do
        pcall(function() Lighting[k] = v end)
    end
    _fbSaved = {}
    for _, v in pairs(Lighting:GetChildren()) do
        pcall(function()
            if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
                v.Enabled = true
            end
        end)
    end
end
local ncStuck        = 0
local lastNcPos      = Vector3.zero
local ncOrigCanCollide = {}
local ncRay          = RaycastParams.new()
ncRay.FilterType     = Enum.RaycastFilterType.Exclude

-- ============================================================
-- 16. FORCE RESTORE
-- ============================================================
local function ForceRestore()
    local C = LP.Character
    if not C then return end
    local H = C:FindFirstChildOfClass("Humanoid")
    local R = C:FindFirstChild("HumanoidRootPart")

    if H then
        pcall(function()
            H.PlatformStand = false
            if not State.Speed then
                H.WalkSpeed = gameBaseSpeed
            end
            if not State.HighJump then
                H.UseJumpPower = true
                H.JumpPower = 50
            end
        end)
    end

    if R then
        pcall(function() R.Anchored = false end)
        for _, v in pairs(R:GetChildren()) do
            if v:IsA("BodyMover") then SafeDel(v) end
        end
        -- Kill any accumulated velocity from noclip movement
        pcall(function()
            R.AssemblyLinearVelocity  = Vector3.zero
            R.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- Also zero velocity on all other parts so ragdoll/limbs don't fly
    for _, v in pairs(C:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") and v ~= R then
                v.AssemblyLinearVelocity  = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    -- Restore all parts: collision group back to Default, CanCollide restored
    for _, v in pairs(C:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                -- Method 1: collision group reset
                pcall(function() v.CollisionGroup = "Default" end)
                -- Method 2: restore original CanCollide
                local orig = ncOrigCanCollide[v]
                if orig ~= nil then
                    v.CanCollide = orig
                else
                    local isLimb = v.Parent == C or v.Name == "HumanoidRootPart"
                    v.CanCollide = isLimb
                end
            end
        end)
    end
    ncOrigCanCollide = {}

    if R then
        task.spawn(function()
            task.wait(0.05)
            pcall(function()
                if R and R.Parent then
                    local vel = R.AssemblyLinearVelocity
                    if math.abs(vel.Y) < 1 then
                        R.CFrame = R.CFrame + Vector3.new(0, 2.5, 0)
                        R.AssemblyLinearVelocity = Vector3.new(vel.X, -1, vel.Z)
                    end
                end
            end)
        end)
    end

    ncStuck = 0
    lastNcPos = Vector3.zero
end

-- ============================================================
-- 17. FAKELAG TOKEN & MOBILE FLY & FREECAM
-- ============================================================
local _fakeLagToken = 0
local MobUp, MobDn = false, false
local FC_P, FC_Y = 0, 0

-- ============================================================
-- 18. UI VISUAL STATE
-- ============================================================
local AllRows  = {}
local TabPages = {}
local TabBtns  = {}
local CurTab   = "Combat"

local LocalizableElements = {}

local function UpdVis(nm)
    local d = AllRows[nm]
    if not d then return end
    local on = State[nm]
    if d.swBG then
        TweenService:Create(d.swBG, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 65),
        }):Play()
    end
    if d.swDot then
        TweenService:Create(d.swDot, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
        }):Play()
    end
    if d.accent then
        d.accent.BackgroundColor3 = on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
    end
    if d.row then
        d.row.BackgroundColor3 = on and Color3.fromRGB(30, 38, 34) or Color3.fromRGB(24, 24, 36)
    end
end

local function RestoreMouse()
    -- Step 1: immediately unlock mouse behavior to prevent freeze
    pcall(function()
        UIS.MouseBehavior    = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end)
    task.delay(0.05, function()
        -- Step 2: restore camera to follow humanoid
        local C = LP.Character
        local H = C and C:FindFirstChildOfClass("Humanoid")
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            if H then Camera.CameraSubject = H end
        end)
        -- Step 3: send a tiny neutral mouse delta so shift-lock snaps back correctly
        pcall(function()
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end)
    task.delay(0.15, function()
        -- Step 4: final safety reset after camera settles
        pcall(function()
            UIS.MouseBehavior    = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end)
    end)
end

local UpdFly

-- ============================================================
-- 19. UNIFIED TOGGLE FUNCTION
-- ============================================================
local LockedTarget = nil
local lastBhop     = 0

local function Toggle(nm)
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
            Notify("Safe Speed", L("ntf_safe_on") .. cap, 3)
        else
            Notify("Safe Speed", L("ntf_safe_off"), 2)
        end
        return
    end

    State[nm] = not State[nm]
    local C = LP.Character
    local R = C and C:FindFirstChild("HumanoidRootPart")
    local H = C and C:FindFirstChildOfClass("Humanoid")

    if not State[nm] then
        if nm == "Fly" then
            pcall(function()
                if R then R.Anchored = false; R.AssemblyLinearVelocity = Vector3.zero end
                if H then H.PlatformStand = false end
            end)
        elseif nm == "Speed" then
            pcall(function()
                if H then H.WalkSpeed = gameBaseSpeed end
                if R then
                    local vel = R.AssemblyLinearVelocity
                    R.AssemblyLinearVelocity = Vector3.new(vel.X * 0.15, vel.Y, vel.Z * 0.15)
                end
            end)
        elseif nm == "HighJump" and H then
            pcall(function()
                H.UseJumpPower = true; H.JumpPower = 50; H.JumpHeight = 7.2
            end)
        elseif nm == "Noclip" or nm == "ShadowLock" then
            ForceRestore()
        elseif nm == "ESP" then
            ClearESP()
        elseif nm == "Hitbox" then
            RestoreHB()
        elseif nm == "Potato" then
            UndoPotato()
        elseif nm == "FullBright" then
            UndoFullBright()
        elseif nm == "Freecam" then
            pcall(function() if R then R.Anchored = false end end)
            RestoreMouse()
        elseif nm == "Spin" and R then
            for _, v in pairs(R:GetChildren()) do
                if v.Name == "OmniSpin" then SafeDel(v) end
            end
        elseif nm == "FakeLag" then
            _fakeLagToken += 1
            local cr = LP.Character
            if cr then
                for _, v in pairs(cr:GetDescendants()) do
                    if v:IsA("BasePart") then
                        pcall(function() v.Anchored = false end)
                    end
                end
                local hm = cr:FindFirstChildOfClass("Humanoid")
                if hm then
                    pcall(function() hm.PlatformStand = false end)
                end
            end
        elseif nm == "InfiniteJump" and H then
            pcall(function() H:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
        elseif nm == "Aim" then
            aimTarget = nil; aimLocked = false; aimLostFrames = 0
            -- Restore camera/mouse so shift-lock doesn't stay broken
            RestoreMouse()
        elseif nm == "SilentAim" then
            -- nothing extra, but also fix mouse if shift-lock was affected
            RestoreMouse()
        end
    else
        if nm == "Potato" then
            DoPotato()
        elseif nm == "FullBright" then
            DoFullBright()
        elseif nm == "ShadowLock" then
            LockedTarget = GetClosestEnemy()
        elseif nm == "Fly" and H then
            pcall(function() H.PlatformStand = false end)
        elseif nm == "Speed" and H then
            pcall(function() H.WalkSpeed = GetSafeSpeed() end)
        elseif nm == "HighJump" and H then
            pcall(function()
                H.UseJumpPower = true
                H.JumpPower = Config.JumpPower
                H.JumpHeight = Config.JumpPower * 0.35
            end)
        elseif nm == "Spin" and R then
            local att = R:FindFirstChild("OmniSpinAtt")
            if not att then
                att = Instance.new("Attachment", R)
                att.Name = "OmniSpinAtt"
            end
            local av = Instance.new("AngularVelocity", R)
            av.Name = "OmniSpin"
            av.Attachment0 = att
            av.MaxTorque = math.huge
            av.AngularVelocity = Vector3.new(0, 22, 0)
        elseif nm == "Freecam" then
            Camera.CameraSubject = nil
            Camera.CameraType = Enum.CameraType.Scriptable
            local x, y = Camera.CFrame:ToEulerAnglesYXZ()
            FC_P = x; FC_Y = y
            pcall(function() if R then R.Anchored = true end end)
        elseif nm == "FakeLag" then
            -- RUBBER-BAND LAG SIMULATION
            -- You move normally. Every N frames a saved "server position" is broadcast
            -- (by teleporting you there for 1 frame then back) creating a rubber-band pop.
            -- To others on the server your position update packet is delayed/jumpy.
            _fakeLagToken += 1
            local myToken = _fakeLagToken
            task.spawn(function()
                local cr    = LP.Character
                local rp    = cr and cr:FindFirstChild("HumanoidRootPart")
                if not rp then return end

                -- "Server" remembers where you were ~200-400ms ago
                local serverCF   = rp.CFrame
                local serverVel  = Vector3.zero
                local lastSave   = tick()
                local saveInterval = math.random(18, 35) / 100  -- 180-350ms lag

                while State.FakeLag and _fakeLagToken == myToken do
                    cr = LP.Character
                    rp = cr and cr:FindFirstChild("HumanoidRootPart")
                    if not rp then task.wait(0.05) continue end

                    local now = tick()
                    if now - lastSave >= saveInterval then
                        -- "Server" gets your old position, then rubber-bands you there for 1 frame
                        local realCF  = rp.CFrame
                        local realVel = rp.AssemblyLinearVelocity

                        -- Brief snap to server position (1 frame = rubberbanding flicker)
                        pcall(function()
                            rp.CFrame                 = serverCF
                            rp.AssemblyLinearVelocity = serverVel
                        end)
                        RunService.Heartbeat:Wait()

                        -- Snap back to real position immediately
                        pcall(function()
                            rp.CFrame                 = realCF
                            rp.AssemblyLinearVelocity = realVel
                        end)

                        -- Save current as new "server checkpoint"
                        serverCF       = realCF
                        serverVel      = realVel
                        lastSave       = now
                        saveInterval   = math.random(14, 40) / 100  -- vary next lag interval
                    else
                        RunService.Heartbeat:Wait()
                    end
                end
            end)
        elseif nm == "Noclip" then
            -- Fresh noclip init: store originals
            ncStuck = 0; lastNcPos = Vector3.zero; ncOrigCanCollide = {}
            if C then
                for _, v in pairs(C:GetDescendants()) do
                    pcall(function()
                        if v:IsA("BasePart") then
                            ncOrigCanCollide[v] = v.CanCollide
                        end
                    end)
                end
            end
        elseif nm == "Aim" then
            aimTarget = nil; aimLocked = false; aimLostFrames = 0; aimLastSwitch = 0
        end
    end

    UpdVis(nm)
    Notify(nm, State[nm] and "ON ✓" or "OFF ✗", 1)
end

-- ============================================================
-- 20. HIGH JUMP DETECTOR
-- ============================================================
local _hjConn = nil
local _hjFired = false

local function SetupHJDetector()
    if _hjConn then _hjConn:Disconnect(); _hjConn = nil end
    _hjFired = false
    local C = LP.Character
    if not C then return end
    local H = C:FindFirstChildOfClass("Humanoid")
    if not H then return end

    _hjConn = H.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed
            or newState == Enum.HumanoidStateType.Running
            or newState == Enum.HumanoidStateType.RunningNoPhysics then
            _hjFired = false
            return
        end
        if newState ~= Enum.HumanoidStateType.Jumping then return end
        if not State.HighJump or State.Fly then return end
        if _hjFired then return end
        _hjFired = true

        local R2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if R2 then
            local v = R2.AssemblyLinearVelocity
            if v.Y >= 0 then
                R2.AssemblyLinearVelocity = Vector3.new(v.X, Config.JumpPower, v.Z)
            end
        end
        task.delay(0.03, function()
            if not State.HighJump then return end
            local R3 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if R3 then
                local v2 = R3.AssemblyLinearVelocity
                if v2.Y >= 0 and v2.Y < Config.JumpPower * 0.7 then
                    R3.AssemblyLinearVelocity = Vector3.new(v2.X, Config.JumpPower, v2.Z)
                end
            end
        end)
        task.delay(0.5, function() _hjFired = false end)
    end)
end
task.spawn(SetupHJDetector)

-- ============================================================
-- 21. ANTI-AFK
-- ============================================================
local _afkFlip = false
local function DoAntiAFK()
    pcall(function()
        VirtualUser:CaptureController()
        _afkFlip = not _afkFlip
        VirtualUser:MoveMouse(_afkFlip and Vector2.new(1, 0) or Vector2.new(-1, 0))
    end)
end

LP.Idled:Connect(function()
    if State.AntiAFK then DoAntiAFK() end
end)

task.spawn(function()
    while task.wait(48 + math.random() * 14) do
        if State.AntiAFK then DoAntiAFK() end
    end
end)

-- ============================================================
-- 22. ANTI-VOID
-- ============================================================
local _lastSafePos = nil

task.spawn(function()
    while task.wait(0.5) do
        local C = LP.Character
        local R = C and C:FindFirstChild("HumanoidRootPart")
        local H = C and C:FindFirstChildOfClass("Humanoid")
        if R and H and H.Health > 0 then
            if H.FloorMaterial ~= Enum.Material.Air then
                _lastSafePos = R.CFrame
            end
            if State.AntiVoid and R.Position.Y < Config.AntiVoidHeight then
                if _lastSafePos then
                    pcall(function()
                        R.CFrame = _lastSafePos + Vector3.new(0, 3, 0)
                        R.AssemblyLinearVelocity = Vector3.zero
                    end)
                    Notify("Anti-Void", L("ntf_anti_void"), 2)
                end
            end
        end
    end
end)

-- ============================================================
-- 23. CHARACTER RESPAWN HANDLER
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    MobUp = false; MobDn = false; ncStuck = 0
    aimTarget = nil; aimLocked = false; aimLostFrames = 0
    ncOrigCanCollide = {}; _lastSafePos = nil

    for _, n in pairs({"Fly", "Noclip", "Freecam", "Spin", "FakeLag", "FullBright"}) do
        if State[n] then
            State[n] = false
            UpdVis(n)
        end
    end
    _fakeLagToken += 1

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = hum

        task.spawn(function()
            task.wait(1.2)
            pcall(function()
                if hum and hum.Parent and not State.Speed then
                    local spd = hum.WalkSpeed
                    if spd >= 4 and spd <= 100 then gameBaseSpeed = spd end
                end
            end)
        end)

        task.wait(0.5)
        if State.Speed then
            pcall(function() hum.WalkSpeed = GetSafeSpeed() end)
        end
        if State.HighJump then
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
                hum.JumpHeight = Config.JumpPower * 0.35
            end)
        end
        task.spawn(function()
            task.wait(0.3)
            SetupHJDetector()
        end)
    end
end)

-- ============================================================
-- 24. SILENT AIM HOOK
-- ============================================================
local silentAimHooked = false

local function SetupSilentAimHook()
    if silentAimHooked then return end
    if not ENV.hasGetRawMeta or not ENV.hasGetNameCall then return end

    local ok = pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        local oldNC = mt.__namecall
        if not oldNC then return end
        if setreadonly then setreadonly(mt, false) end

        local newNC
        if newcclosure then
            newNC = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if not State.SilentAim then return oldNC(self, ...) end

                if method == "Raycast" and self == Workspace then
                    local target = GetBestAimTarget()
                    local part = target and FindAimPart(target)
                    if part then
                        local args = {...}
                        local origin = args[1]
                        if typeof(origin) == "Vector3" then
                            local vel = part.AssemblyLinearVelocity
                            local predPos = part.Position + vel * 0.05
                            local dir = (predPos - origin)
                            if Config.AimAntiDetect then
                                dir = dir + Vector3.new(
                                    (math.random() - 0.5) * 0.15,
                                    (math.random() - 0.5) * 0.10,
                                    (math.random() - 0.5) * 0.15
                                )
                            end
                            args[2] = dir.Unit * dir.Magnitude
                            return oldNC(self, unpack(args))
                        end
                    end
                end

                if (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList")
                    and self == Workspace then
                    local target = GetBestAimTarget()
                    local part = target and FindAimPart(target)
                    if part then
                        local args = {...}
                        local ray = args[1]
                        if typeof(ray) == "Ray" then
                            local origin = ray.Origin
                            local dir = (part.Position - origin)
                            if Config.AimAntiDetect then
                                dir = dir + Vector3.new(
                                    (math.random() - 0.5) * 0.15,
                                    (math.random() - 0.5) * 0.10,
                                    (math.random() - 0.5) * 0.15
                                )
                            end
                            args[1] = Ray.new(origin, dir.Unit * 5000)
                            return oldNC(self, unpack(args))
                        end
                    end
                end
                return oldNC(self, ...)
            end)
        else
            newNC = function(self, ...)
                local method = getnamecallmethod()
                if State.SilentAim and method == "Raycast" and self == Workspace then
                    local target = GetBestAimTarget()
                    local part = target and FindAimPart(target)
                    if part then
                        local args = {...}
                        local origin = args[1]
                        if typeof(origin) == "Vector3" then
                            local dir = (part.Position - origin)
                            args[2] = dir.Unit * dir.Magnitude
                            return oldNC(self, unpack(args))
                        end
                    end
                end
                return oldNC(self, ...)
            end
        end

        mt.__namecall = newNC
        if setreadonly then setreadonly(mt, true) end
        silentAimHooked = true
    end)

    if ok and silentAimHooked then
        Notify("Silent Aim", L("ntf_hook_ok"), 3)
    end
end

task.spawn(function()
    task.wait(2)
    SetupSilentAimHook()
end)

-- ============================================================
-- 25. SERVER HOP FUNCTIONS
-- ============================================================
local function GetHTTP(url)
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if ok and result then return result end
    ok, result = pcall(function()
        if syn then return syn.request({Url = url, Method = "GET"}).Body end
    end)
    if ok and result then return result end
    ok, result = pcall(function()
        if request then return request({Url = url, Method = "GET"}).Body end
    end)
    if ok and result then return result end
    return nil
end

local function GetServerList()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
        .. "/servers/Public?sortOrder=Asc&excludeFullGames=false&limit=100"
    local data = GetHTTP(url)
    if not data then return nil end
    local ok, parsed = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok or not parsed or not parsed.data then return nil end
    return parsed.data
end

local serverActionCooldown = false
local function ServerCooldown()
    if serverActionCooldown then
        Notify("Server Hop", L("ntf_wait"), 2)
        return true
    end
    serverActionCooldown = true
    task.delay(3, function() serverActionCooldown = false end)
    return false
end

local function RejoinSameServer()
    if ServerCooldown() then return end
    Notify("Rejoin", L("ntf_rejoin"), 3)
    task.delay(1.5, function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end)
    end)
end

local function JoinRandomServer()
    if ServerCooldown() then return end
    Notify("Server Hop", L("ntf_search_rnd"), 3)
    task.spawn(function()
        local servers = GetServerList()
        if servers and #servers > 0 then
            local filtered = {}
            for _, s in pairs(servers) do
                if s.id ~= game.JobId and s.playing and s.playing > 0 then
                    table.insert(filtered, s)
                end
            end
            if #filtered > 0 then
                local chosen = filtered[math.random(1, #filtered)]
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, LP)
                end)
                return
            end
        end
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end)
end

local function JoinBiggestServer()
    if ServerCooldown() then return end
    Notify("Server Hop", L("ntf_search_big"), 3)
    task.spawn(function()
        local servers = GetServerList()
        if servers and #servers > 0 then
            local best, bestCount = nil, -1
            for _, s in pairs(servers) do
                if s.id ~= game.JobId and s.playing and s.playing > bestCount then
                    bestCount = s.playing; best = s
                end
            end
            if best then
                Notify("Server Hop", "👥 " .. bestCount .. L("ntf_players"), 2)
                task.wait(1)
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LP)
                end)
                return
            end
        end
        Notify("Server Hop", L("ntf_srv_fail"), 3)
    end)
end

local function JoinSmallestServer()
    if ServerCooldown() then return end
    Notify("Server Hop", L("ntf_search_sml"), 3)
    task.spawn(function()
        local servers = GetServerList()
        if servers and #servers > 0 then
            local best, bestCount = nil, math.huge
            for _, s in pairs(servers) do
                if s.id ~= game.JobId and s.playing and s.playing < bestCount then
                    bestCount = s.playing; best = s
                end
            end
            if best then
                Notify("Server Hop", "🕵️ " .. bestCount .. L("ntf_players"), 2)
                task.wait(1)
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LP)
                end)
                return
            end
        end
        Notify("Server Hop", L("ntf_srv_fail"), 3)
    end)
end

-- ============================================================
-- 26. GUI CREATION
-- ============================================================
local GuiP = LP:WaitForChild("PlayerGui", 5)
pcall(function()
    local c = game:GetService("CoreGui")
    local _ = c.Name
    GuiP = c
end)

local Scr = Instance.new("ScreenGui", GuiP)
Scr.Name = RndStr(12)
Scr.ResetOnSpawn = false
Scr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Scr.IgnoreGuiInset = true
Instance.new("BoolValue", Scr).Name = "OmniMarker"

local P = {
    bg   = Color3.fromRGB(12, 12, 18),
    card = Color3.fromRGB(20, 20, 30),
    btn  = Color3.fromRGB(24, 24, 36),
    dark = Color3.fromRGB(14, 14, 22),
    acc  = Color3.fromRGB(0, 190, 110),
    txt  = Color3.fromRGB(230, 230, 240),
    dim  = Color3.fromRGB(120, 120, 145),
    brd  = Color3.fromRGB(40, 40, 58),
    grn  = Color3.fromRGB(0, 200, 100),
    wht  = Color3.fromRGB(255, 255, 255),
    swOff = Color3.fromRGB(50, 50, 65),
    tabA  = Color3.fromRGB(32, 32, 48),
    onBg  = Color3.fromRGB(30, 38, 34),
    srvBtn = Color3.fromRGB(28, 28, 44),
}

local VP  = Camera.ViewportSize
local MW  = IsMob and math.min(325, VP.X - 20) or 315
local MH  = IsMob and math.min(590, VP.Y - 80) or 555
local BH  = IsMob and 44 or 34
local FS  = IsMob and 13 or 11
local MBS = IsMob and 58 or 48

-- FOV Circle
local fovCircle = Instance.new("Frame", Scr)
fovCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
fovCircle.Position = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
fovCircle.BackgroundTransparency = 1; fovCircle.BorderSizePixel = 0
fovCircle.Visible = false; fovCircle.ZIndex = 10
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(0, 200, 100)
fovStroke.Thickness = 1.5; fovStroke.Transparency = 0.3

local tgtInfo = Instance.new("TextLabel", Scr)
tgtInfo.Size = UDim2.new(0, 200, 0, 22)
tgtInfo.Position = UDim2.new(0.5, -100, 0.5, -Config.AimFOV - 32)
tgtInfo.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
tgtInfo.BackgroundTransparency = 0.2; tgtInfo.BorderSizePixel = 0
tgtInfo.TextColor3 = P.grn; tgtInfo.Font = Enum.Font.GothamBold
tgtInfo.TextSize = 11; tgtInfo.Text = ""; tgtInfo.Visible = false; tgtInfo.ZIndex = 12
Instance.new("UICorner", tgtInfo).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tgtInfo).Color = P.brd

local function UpdateFOVCircle()
    local r = Config.AimFOV
    fovCircle.Size = UDim2.new(0, r * 2, 0, r * 2)
    fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r)
    tgtInfo.Position = UDim2.new(0.5, -100, 0.5, -r - 32)
end

-- Main frame
local Main = Instance.new("Frame", Scr)
Main.Size = UDim2.new(0, MW, 0, MH)
Main.Position = UDim2.new(0.5, -MW / 2, 0.5, -MH / 2)
Main.BackgroundColor3 = P.bg; Main.Visible = false; Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local mainS = Instance.new("UIStroke", Main)
mainS.Color = P.brd; mainS.Thickness = 1.5

-- Title bar
local TB = Instance.new("Frame", Main)
TB.Size = UDim2.new(1, 0, 0, 42)
TB.BackgroundColor3 = P.dark; TB.BorderSizePixel = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 14)
local tbF = Instance.new("Frame", TB)
tbF.Size = UDim2.new(1, 0, 0, 14); tbF.Position = UDim2.new(0, 0, 1, -14)
tbF.BackgroundColor3 = P.dark; tbF.BorderSizePixel = 0

local tGrad = Instance.new("UIGradient", TB)
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 26)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 26)),
})

local tAcc = Instance.new("Frame", TB)
tAcc.Size = UDim2.new(0, 3, 0.55, 0); tAcc.Position = UDim2.new(0, 0, 0.225, 0)
tAcc.BackgroundColor3 = P.acc; tAcc.BorderSizePixel = 0
Instance.new("UICorner", tAcc).CornerRadius = UDim.new(0, 2)

local tIco = Instance.new("TextLabel", TB)
tIco.Size = UDim2.new(0, 32, 0, 32); tIco.Position = UDim2.new(0, 10, 0.5, -16)
tIco.BackgroundTransparency = 1; tIco.Text = "⚡"; tIco.TextSize = 18
tIco.Font = Enum.Font.GothamBlack; tIco.TextColor3 = P.acc; tIco.ZIndex = 3

local tTit = Instance.new("TextLabel", TB)
tTit.Size = UDim2.new(1, -90, 0, 18); tTit.Position = UDim2.new(0, 40, 0, 5)
tTit.BackgroundTransparency = 1; tTit.TextColor3 = P.wht; tTit.Font = Enum.Font.GothamBlack
tTit.TextSize = 14; tTit.Text = L("title"); tTit.TextXAlignment = Enum.TextXAlignment.Left
tTit.ZIndex = 3

local tSub = Instance.new("TextLabel", TB)
tSub.Size = UDim2.new(1, -90, 0, 12); tSub.Position = UDim2.new(0, 40, 0, 24)
tSub.BackgroundTransparency = 1; tSub.TextColor3 = P.dim; tSub.Font = Enum.Font.Gotham
tSub.TextSize = 9
tSub.Text = IsMob and L("subtitle_mobile") or L("subtitle_pc")
tSub.TextXAlignment = Enum.TextXAlignment.Left; tSub.ZIndex = 3

-- Close button
local clsB = Instance.new("TextButton", TB)
clsB.Size = UDim2.new(0, 26, 0, 26); clsB.Position = UDim2.new(1, -32, 0.5, -13)
clsB.BackgroundColor3 = Color3.fromRGB(40, 40, 55); clsB.Text = "✕"
clsB.TextColor3 = P.txt; clsB.Font = Enum.Font.GothamBold; clsB.TextSize = 11
clsB.BorderSizePixel = 0; clsB.ZIndex = 4; clsB.AutoButtonColor = false
Instance.new("UICorner", clsB).CornerRadius = UDim.new(1, 0)

local function CloseMenu()
    TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, MW, 0, 0),
        Position = UDim2.new(0.5, -MW / 2, 0.5, 0),
    }):Play()
    task.delay(0.15, function() Main.Visible = false end)
end

local function OpenMenu()
    Main.Size = UDim2.new(0, MW, 0, 0)
    Main.Position = UDim2.new(0.5, -MW / 2, 0.5, 0)
    Main.Visible = true
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, MW, 0, MH),
        Position = UDim2.new(0.5, -MW / 2, 0.5, -MH / 2),
    }):Play()
end

clsB.MouseButton1Click:Connect(CloseMenu)

-- Status bar
local stB = Instance.new("Frame", Main)
stB.Size = UDim2.new(1, -16, 0, 18); stB.Position = UDim2.new(0, 8, 0, 44)
stB.BackgroundColor3 = P.card; stB.BorderSizePixel = 0
Instance.new("UICorner", stB).CornerRadius = UDim.new(0, 5)
local fpsL = Instance.new("TextLabel", stB)
fpsL.Size = UDim2.new(0.5, 0, 1, 0); fpsL.BackgroundTransparency = 1
fpsL.TextColor3 = P.txt; fpsL.Font = Enum.Font.GothamBold; fpsL.TextSize = 10
fpsL.Text = "FPS: ..."
local pngL = Instance.new("TextLabel", stB)
pngL.Size = UDim2.new(0.5, 0, 1, 0); pngL.Position = UDim2.new(0.5, 0, 0, 0)
pngL.BackgroundTransparency = 1; pngL.TextColor3 = P.txt; pngL.Font = Enum.Font.GothamBold
pngL.TextSize = 10; pngL.Text = "Ping: ..."

-- Tab bar
local tabY  = 64
local tabFr = Instance.new("Frame", Main)
tabFr.Size = UDim2.new(1, -12, 0, 30); tabFr.Position = UDim2.new(0, 6, 0, tabY)
tabFr.BackgroundColor3 = P.dark; tabFr.BorderSizePixel = 0
Instance.new("UICorner", tabFr).CornerRadius = UDim.new(0, 6)

local tNames    = {"Combat", "Move", "Misc", "Config"}
local tIcons    = {"⚔", "🏃", "🔧", "⚙"}
local tLangKeys = {"tab_combat", "tab_move", "tab_misc", "tab_config"}
local tW = 1 / #tNames

local function SwitchTab(name)
    CurTab = name
    for n, pg in pairs(TabPages) do pg.Visible = (n == name) end
    for n, bt in pairs(TabBtns) do
        local a = (n == name)
        TweenService:Create(bt, TweenInfo.new(0.12), {
            BackgroundColor3 = a and P.tabA or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = a and 0 or 1,
        }):Play()
        bt.TextColor3 = a and P.acc or P.dim
    end
end

for i, n in ipairs(tNames) do
    local b = Instance.new("TextButton", tabFr)
    b.Size = UDim2.new(tW, -2, 1, -4)
    b.Position = UDim2.new((i - 1) * tW, 1, 0, 2)
    b.BackgroundColor3 = P.tabA
    b.BackgroundTransparency = i == 1 and 0 or 1
    b.Text = tIcons[i] .. " " .. L(tLangKeys[i])
    b.TextColor3 = i == 1 and P.acc or P.dim
    b.Font = Enum.Font.GothamBold; b.TextSize = IsMob and 11 or 9
    b.BorderSizePixel = 0; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function() SwitchTab(n) end)
    TabBtns[n] = b
    table.insert(LocalizableElements, {type = "tab", obj = b, icon = tIcons[i], langKey = tLangKeys[i]})
end

-- Content pages
local cY = tabY + 34
local cH = MH - cY - 4
for _, n in ipairs(tNames) do
    local s = Instance.new("ScrollingFrame", Main)
    s.Name = n; s.Size = UDim2.new(1, -6, 0, cH)
    s.Position = UDim2.new(0, 3, 0, cY)
    s.BackgroundTransparency = 1; s.ScrollBarThickness = IsMob and 4 or 3
    s.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    s.BorderSizePixel = 0; s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.ScrollingDirection = Enum.ScrollingDirection.Y
    s.Visible = (n == "Combat"); s.ScrollingEnabled = true
    s.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    local ly = Instance.new("UIListLayout", s)
    ly.Padding = UDim.new(0, IsMob and 4 or 3)
    ly.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pd = Instance.new("UIPadding", s)
    pd.PaddingTop = UDim.new(0, 4)
    pd.PaddingBottom = UDim.new(0, IsMob and 16 or 8)
    ly:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0, 0, 0, ly.AbsoluteContentSize.Y + 20)
    end)
    TabPages[n] = s
end

-- Draggable title bar
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
            local newX = math.clamp(dp.X.Offset + d.X, -MW / 2, Camera.ViewportSize.X - MW / 2)
            local newY = math.clamp(dp.Y.Offset + d.Y, -MH / 2, Camera.ViewportSize.Y - MH / 2)
            Main.Position = UDim2.new(dp.X.Scale, newX, dp.Y.Scale, newY)
        end
    end)
    TB.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

-- External stats display
local exS = Instance.new("Frame", Scr)
exS.Size = UDim2.new(0, 130, 0, 58)
exS.Position = UDim2.new(1, -142, 0, 10)
exS.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
exS.BackgroundTransparency = 0; exS.BorderSizePixel = 0; exS.ZIndex = 20
Instance.new("UICorner", exS).CornerRadius = UDim.new(0, 10)
local exGrad = Instance.new("UIGradient", exS)
exGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 16)),
}); exGrad.Rotation = 135
local exStroke = Instance.new("UIStroke", exS)
exStroke.Color = Color3.fromRGB(0, 200, 100)
exStroke.Thickness = 1.5; exStroke.Transparency = 0.4

local function MkStat(parent, ico, lbl, zI)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -16, 0, 22)
    row.BackgroundTransparency = 1; row.ZIndex = zI
    local iL = Instance.new("TextLabel", row)
    iL.Size = UDim2.new(0, 18, 1, 0); iL.BackgroundTransparency = 1
    iL.Text = ico; iL.TextSize = 12; iL.Font = Enum.Font.Gotham
    iL.ZIndex = zI + 1; iL.TextColor3 = Color3.fromRGB(100, 200, 255)
    local nL = Instance.new("TextLabel", row)
    nL.Size = UDim2.new(0, 42, 1, 0); nL.Position = UDim2.new(0, 20, 0, 0)
    nL.BackgroundTransparency = 1; nL.Text = lbl; nL.TextSize = 10
    nL.Font = Enum.Font.GothamBold; nL.TextColor3 = Color3.fromRGB(160, 160, 180)
    nL.TextXAlignment = Enum.TextXAlignment.Left; nL.ZIndex = zI + 1
    local vL = Instance.new("TextLabel", row)
    vL.Size = UDim2.new(1, -64, 1, 0); vL.Position = UDim2.new(0, 62, 0, 0)
    vL.BackgroundTransparency = 1; vL.Text = "..."; vL.TextSize = 12
    vL.Font = Enum.Font.GothamBlack; vL.TextColor3 = Color3.fromRGB(130, 255, 170)
    vL.TextXAlignment = Enum.TextXAlignment.Right; vL.ZIndex = zI + 1
    return row, vL
end

local exFpsRow, eF = MkStat(exS, "🖥", "FPS", 21)
exFpsRow.Position = UDim2.new(0, 8, 0, 6)
local exDiv = Instance.new("Frame", exS)
exDiv.Size = UDim2.new(1, -16, 0, 1); exDiv.Position = UDim2.new(0, 8, 0, 31)
exDiv.BackgroundColor3 = Color3.fromRGB(40, 40, 60); exDiv.BorderSizePixel = 0; exDiv.ZIndex = 21
local exPingRow, eP = MkStat(exS, "📶", "PING", 21)
exPingRow.Position = UDim2.new(0, 8, 0, 33)

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
            local newX = math.clamp(exDp.X.Offset + d.X, 0, Camera.ViewportSize.X - 130)
            local newY = math.clamp(exDp.Y.Offset + d.Y, 0, Camera.ViewportSize.Y - 58)
            exS.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    exS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then exDr = false end
    end)
end

-- Menu toggle button
local mB = Instance.new("TextButton", Scr)
mB.Size = UDim2.new(0, MBS, 0, MBS)
mB.Position = UDim2.new(0, 10, 0.5, -MBS / 2)
mB.BackgroundColor3 = P.bg; mB.Text = "M"; mB.TextColor3 = P.acc
mB.Font = Enum.Font.GothamBlack; mB.TextSize = IsMob and 22 or 18
mB.ZIndex = 100; mB.AutoButtonColor = false
Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 12)
local mSt = Instance.new("UIStroke", mB)
mSt.Thickness = 2; mSt.Color = P.acc

local mCnt = Instance.new("TextLabel", mB)
mCnt.Size = UDim2.new(1, 0, 0, 12); mCnt.Position = UDim2.new(0, 0, 1, -13)
mCnt.BackgroundTransparency = 1; mCnt.TextSize = 8; mCnt.Font = Enum.Font.GothamBold
mCnt.TextColor3 = P.grn; mCnt.ZIndex = 101; mCnt.Text = ""

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
            or inp.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

-- Fly mobile buttons
local flyH = Instance.new("Frame", Scr)
flyH.Size = UDim2.new(0, 140, 0, 64)
flyH.Position = UDim2.new(1, -154, 1, -160)
flyH.BackgroundTransparency = 1; flyH.Visible = false; flyH.ZIndex = 50
local flyBG = Instance.new("Frame", flyH)
flyBG.Size = UDim2.new(1, 0, 1, 0)
flyBG.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
flyBG.BackgroundTransparency = 0.3; flyBG.BorderSizePixel = 0; flyBG.ZIndex = 49
Instance.new("UICorner", flyBG).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", flyBG).Color = P.brd

local function MkFlyB(t, x, cb)
    local b = Instance.new("TextButton", flyH)
    b.Size = UDim2.new(0, 62, 0, 58); b.Position = UDim2.new(0, x, 0, 3)
    b.BackgroundColor3 = P.btn; b.Text = t; b.TextColor3 = P.wht
    b.Font = Enum.Font.GothamBlack; b.TextSize = 28
    b.BorderSizePixel = 0; b.ZIndex = 51; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", b).Color = P.acc
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            cb(true)
            TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = P.tabA}):Play()
        end
    end)
    b.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            cb(false)
            TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = P.btn}):Play()
        end
    end)
    b.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            local abs = b.AbsolutePosition; local sz = b.AbsoluteSize
            if i.Position.X < abs.X or i.Position.X > abs.X + sz.X
                or i.Position.Y < abs.Y or i.Position.Y > abs.Y + sz.Y then
                cb(false)
                TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = P.btn}):Play()
            end
        end
    end)
end
MkFlyB("▲", 4, function(v) MobUp = v end)
MkFlyB("▼", 72, function(v) MobDn = v end)

function UpdFly()
    flyH.Visible = State.Fly and IsTab
end

-- Freecam touch zone
local fcZ = Instance.new("TextButton", Scr)
fcZ.Size = UDim2.new(0.5, 0, 1, -100); fcZ.Position = UDim2.new(0.5, 0, 0, 0)
fcZ.BackgroundTransparency = 1; fcZ.Text = ""; fcZ.ZIndex = 5; fcZ.Visible = false
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
-- 26B. MOBILE HUD BUTTONS (touch only)
-- ============================================================
-- "HUD" button (bottom-left, above M) opens a chooser panel.
-- In the panel: tap any feature chip to show/hide its button.
-- "✏ Move" = enter drag mode to reposition visible buttons.
-- "✓ Done" = close panel + save.
-- By default ALL buttons are hidden — user picks what they want.
-- ============================================================

local MobHUDEditMode  = false
local MobHUDBtns      = {}   -- keyed by id, stores {btn, btnSt, dot, editOverlay}

local HUD_SZ          = 58
local HUD_COL_OFF     = Color3.fromRGB(18, 18, 30)
local HUD_COL_ON      = Color3.fromRGB(14, 58, 36)
local HUD_COL_EDT     = Color3.fromRGB(42, 36, 8)

-- Which buttons are shown on screen (persisted in Config.MobHUDEnabled)
if not Config.MobHUDEnabled then Config.MobHUDEnabled = {} end

local MobHUDDefs = {
    {id = "Fly",          icon = "✈",  short = "Fly"},
    {id = "Speed",        icon = "👟", short = "Speed"},
    {id = "Bhop",         icon = "🐇", short = "Bhop"},
    {id = "Aim",          icon = "🎯", short = "Aim"},
    {id = "SilentAim",    icon = "🔇", short = "S.Aim"},
    {id = "Noclip",       icon = "👻", short = "NC"},
    {id = "ESP",          icon = "👁",  short = "ESP"},
    {id = "Hitbox",       icon = "📦", short = "HBox"},
    {id = "HighJump",     icon = "⬆",  short = "HJump"},
    {id = "InfiniteJump", icon = "♾",  short = "∞Jump"},
    {id = "AntiVoid",     icon = "🌊", short = "AVoid"},
    {id = "FakeLag",      icon = "📡", short = "FLag"},
    {id = "ShadowLock",   icon = "🧲", short = "SLock"},
    {id = "FullBright",   icon = "☀",  short = "FBrt"},
}

-- Default positions: stacked right edge, spacing from top
local function GetHUDDefaultPos(idx)
    local vp = Camera.ViewportSize
    return vp.X - HUD_SZ - 8, 120 + (idx - 1) * (HUD_SZ + 6)
end

local function ApplyHUDBtnColor(entry)
    if MobHUDEditMode then
        entry.btn.BackgroundColor3     = HUD_COL_EDT
        entry.btnSt.Color              = Color3.fromRGB(255, 200, 50)
        entry.dot.TextColor3           = Color3.fromRGB(255, 200, 50)
        entry.editOverlay.Visible      = true
    else
        local on = State[entry.id]
        entry.btn.BackgroundColor3     = on and HUD_COL_ON or HUD_COL_OFF
        entry.btnSt.Color              = on and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(44, 44, 62)
        entry.dot.TextColor3           = on and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(50, 50, 68)
        entry.editOverlay.Visible      = false
    end
end

local function SetHUDBtnVisible(id, visible)
    local entry = MobHUDBtns[id]
    if entry then entry.btn.Visible = visible end
end

local function RefreshHUDVisibility()
    for _, def in ipairs(MobHUDDefs) do
        SetHUDBtnVisible(def.id, Config.MobHUDEnabled[def.id] == true)
    end
end

if IsTab then

    -- ── Build all 13 HUD buttons (hidden by default) ─────────
    for idx, def in ipairs(MobHUDDefs) do
        local saved = Config.MobHUDPositions and Config.MobHUDPositions[def.id]
        local defX, defY = GetHUDDefaultPos(idx)
        local posX = (saved and saved[1]) or defX
        local posY = (saved and saved[2]) or defY
        local vp = Camera.ViewportSize
        posX = math.clamp(posX, 0, vp.X - HUD_SZ)
        posY = math.clamp(posY, 0, vp.Y - HUD_SZ)

        local btn = Instance.new("TextButton", Scr)
        btn.Size               = UDim2.new(0, HUD_SZ, 0, HUD_SZ)
        btn.Position           = UDim2.new(0, posX, 0, posY)
        btn.BackgroundColor3   = HUD_COL_OFF
        btn.BorderSizePixel    = 0
        btn.AutoButtonColor    = false
        btn.Text               = ""
        btn.ZIndex             = 62
        btn.Visible            = false   -- hidden until user enables it
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        local btnSt = Instance.new("UIStroke", btn)
        btnSt.Color = Color3.fromRGB(44, 44, 62); btnSt.Thickness = 1.5

        local icoLbl = Instance.new("TextLabel", btn)
        icoLbl.Size               = UDim2.new(1, 0, 0, 32)
        icoLbl.Position           = UDim2.new(0, 0, 0, 4)
        icoLbl.BackgroundTransparency = 1
        icoLbl.Text               = def.icon
        icoLbl.TextSize           = 22
        icoLbl.Font               = Enum.Font.Gotham
        icoLbl.TextColor3         = P.txt
        icoLbl.ZIndex             = 63

        local shortLbl = Instance.new("TextLabel", btn)
        shortLbl.Size             = UDim2.new(1, 0, 0, 14)
        shortLbl.Position         = UDim2.new(0, 0, 1, -16)
        shortLbl.BackgroundTransparency = 1
        shortLbl.Text             = def.short
        shortLbl.TextSize         = 8
        shortLbl.Font             = Enum.Font.GothamBold
        shortLbl.TextColor3       = Color3.fromRGB(120, 120, 150)
        shortLbl.ZIndex           = 63

        local dot = Instance.new("TextLabel", btn)
        dot.Size                  = UDim2.new(0, 10, 0, 10)
        dot.Position              = UDim2.new(1, -13, 0, 3)
        dot.BackgroundTransparency = 1
        dot.Text                  = "●"
        dot.TextSize              = 9
        dot.Font                  = Enum.Font.GothamBold
        dot.TextColor3            = Color3.fromRGB(50, 50, 68)
        dot.ZIndex                = 64

        local editOverlay = Instance.new("TextLabel", btn)
        editOverlay.Size          = UDim2.new(1, 0, 1, 0)
        editOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        editOverlay.BackgroundTransparency = 0.42
        editOverlay.Text          = "✥"
        editOverlay.TextSize      = 26
        editOverlay.Font          = Enum.Font.GothamBlack
        editOverlay.TextColor3    = Color3.fromRGB(255, 200, 50)
        editOverlay.ZIndex        = 65
        editOverlay.Visible       = false
        Instance.new("UICorner", editOverlay).CornerRadius = UDim.new(0, 12)

        local entry = {id = def.id, btn = btn, btnSt = btnSt, dot = dot, editOverlay = editOverlay}
        MobHUDBtns[def.id] = entry
        ApplyHUDBtnColor(entry)

        local tStart, tMoved, tOrigin, tBtnOrigin = nil, false, nil, nil
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch then return end
            tStart = tick(); tMoved = false
            tOrigin = inp.Position
            tBtnOrigin = Vector2.new(btn.Position.X.Offset, btn.Position.Y.Offset)
        end)
        btn.InputChanged:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch or not MobHUDEditMode or not tStart then return end
            local delta = inp.Position - tOrigin
            if delta.Magnitude > 5 then tMoved = true end
            local vp2 = Camera.ViewportSize
            btn.Position = UDim2.new(0,
                math.clamp(tBtnOrigin.X + delta.X, 0, vp2.X - HUD_SZ), 0,
                math.clamp(tBtnOrigin.Y + delta.Y, 0, vp2.Y - HUD_SZ))
        end)
        btn.InputEnded:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch then return end
            if MobHUDEditMode then
                if not Config.MobHUDPositions then Config.MobHUDPositions = {} end
                Config.MobHUDPositions[def.id] = {btn.Position.X.Offset, btn.Position.Y.Offset}
            elseif tStart and not tMoved and (tick() - tStart) < 0.35 then
                Toggle(def.id)
                if def.id == "Fly" then UpdFly() end
                if def.id == "Freecam" then fcZ.Visible = State.Freecam end
                ApplyHUDBtnColor(entry)
            end
            tStart = nil; tMoved = false
        end)
    end

    -- Apply saved visibility
    RefreshHUDVisibility()

    -- ── Sync colors every 0.3s ────────────────────────────────
    task.spawn(function()
        while task.wait(0.3) do
            if not MobHUDEditMode then
                for _, entry in pairs(MobHUDBtns) do
                    if entry.btn.Visible then pcall(ApplyHUDBtnColor, entry) end
                end
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════════
    -- HUD CHOOSER PANEL
    -- ═══════════════════════════════════════════════════════════
    local hudPanel = Instance.new("Frame", Scr)
    hudPanel.Size               = UDim2.new(0, 300, 0, 0)
    hudPanel.Position           = UDim2.new(0.5, -150, 1, -10)
    hudPanel.BackgroundColor3   = Color3.fromRGB(12, 12, 20)
    hudPanel.BorderSizePixel    = 0
    hudPanel.Visible            = false
    hudPanel.ZIndex             = 300
    hudPanel.ClipsDescendants   = true
    Instance.new("UICorner", hudPanel).CornerRadius = UDim.new(0, 14)
    local hudPanelSt = Instance.new("UIStroke", hudPanel)
    hudPanelSt.Color = P.acc; hudPanelSt.Thickness = 1.5

    -- Panel title bar
    local hudTitleBar = Instance.new("Frame", hudPanel)
    hudTitleBar.Size             = UDim2.new(1, 0, 0, 38)
    hudTitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    hudTitleBar.BorderSizePixel  = 0
    hudTitleBar.ZIndex           = 301
    Instance.new("UICorner", hudTitleBar).CornerRadius = UDim.new(0, 14)
    local hudTitleFix = Instance.new("Frame", hudTitleBar)
    hudTitleFix.Size = UDim2.new(1, 0, 0, 14); hudTitleFix.Position = UDim2.new(0, 0, 1, -14)
    hudTitleFix.BackgroundColor3 = Color3.fromRGB(18, 18, 30); hudTitleFix.BorderSizePixel = 0

    local hudTitleLbl = Instance.new("TextLabel", hudTitleBar)
    hudTitleLbl.Size              = UDim2.new(1, -80, 1, 0)
    hudTitleLbl.Position          = UDim2.new(0, 12, 0, 0)
    hudTitleLbl.BackgroundTransparency = 1
    hudTitleLbl.Text              = "⚙  HUD Buttons"
    hudTitleLbl.TextColor3        = P.acc
    hudTitleLbl.Font              = Enum.Font.GothamBlack
    hudTitleLbl.TextSize          = 13
    hudTitleLbl.TextXAlignment    = Enum.TextXAlignment.Left
    hudTitleLbl.ZIndex            = 302

    -- "✏ Move" toggle inside panel title bar
    local moveTogBtn = Instance.new("TextButton", hudTitleBar)
    moveTogBtn.Size             = UDim2.new(0, 64, 0, 26)
    moveTogBtn.Position         = UDim2.new(1, -130, 0.5, -13)
    moveTogBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 44)
    moveTogBtn.Text             = "✏ Move"
    moveTogBtn.TextColor3       = P.dim
    moveTogBtn.Font             = Enum.Font.GothamBold
    moveTogBtn.TextSize         = 10
    moveTogBtn.BorderSizePixel  = 0
    moveTogBtn.AutoButtonColor  = false
    moveTogBtn.ZIndex           = 303
    Instance.new("UICorner", moveTogBtn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIStroke", moveTogBtn).Color = P.dim

    -- "✓ Done" close button
    local hudDoneBtn = Instance.new("TextButton", hudTitleBar)
    hudDoneBtn.Size             = UDim2.new(0, 54, 0, 26)
    hudDoneBtn.Position         = UDim2.new(1, -62, 0.5, -13)
    hudDoneBtn.BackgroundColor3 = Color3.fromRGB(16, 55, 28)
    hudDoneBtn.Text             = "✓ Done"
    hudDoneBtn.TextColor3       = Color3.fromRGB(0, 220, 100)
    hudDoneBtn.Font             = Enum.Font.GothamBold
    hudDoneBtn.TextSize         = 10
    hudDoneBtn.BorderSizePixel  = 0
    hudDoneBtn.AutoButtonColor  = false
    hudDoneBtn.ZIndex           = 303
    Instance.new("UICorner", hudDoneBtn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIStroke", hudDoneBtn).Color = Color3.fromRGB(0, 180, 80)

    -- Chips grid
    local chipsFrame = Instance.new("Frame", hudPanel)
    chipsFrame.Position          = UDim2.new(0, 0, 0, 40)
    chipsFrame.Size              = UDim2.new(1, 0, 1, -40)
    chipsFrame.BackgroundTransparency = 1
    chipsFrame.ZIndex            = 301
    local chipsGrid = Instance.new("UIGridLayout", chipsFrame)
    chipsGrid.CellSize           = UDim2.new(0, 84, 0, 38)
    chipsGrid.CellPadding        = UDim2.new(0, 7, 0, 6)
    chipsGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    chipsGrid.SortOrder          = Enum.SortOrder.LayoutOrder
    local chipsPad = Instance.new("UIPadding", chipsFrame)
    chipsPad.PaddingTop    = UDim.new(0, 6)
    chipsPad.PaddingBottom = UDim.new(0, 8)
    chipsPad.PaddingLeft   = UDim.new(0, 6)
    chipsPad.PaddingRight  = UDim.new(0, 6)

    local ChipRefs = {}   -- {chip, dot} keyed by id

    for _, def in ipairs(MobHUDDefs) do
        local chip = Instance.new("TextButton", chipsFrame)
        chip.Size               = UDim2.new(0, 84, 0, 38)
        chip.BackgroundColor3   = Color3.fromRGB(22, 22, 36)
        chip.BorderSizePixel    = 0
        chip.AutoButtonColor    = false
        chip.Text               = ""
        chip.ZIndex             = 302
        Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 9)
        local chipSt = Instance.new("UIStroke", chip)
        chipSt.Color = Color3.fromRGB(44, 44, 62); chipSt.Thickness = 1.2

        local chipIco = Instance.new("TextLabel", chip)
        chipIco.Size              = UDim2.new(0, 28, 1, 0)
        chipIco.Position          = UDim2.new(0, 4, 0, 0)
        chipIco.BackgroundTransparency = 1
        chipIco.Text              = def.icon
        chipIco.TextSize          = 18
        chipIco.Font              = Enum.Font.Gotham
        chipIco.TextColor3        = P.txt
        chipIco.ZIndex            = 303

        local chipLbl = Instance.new("TextLabel", chip)
        chipLbl.Size              = UDim2.new(1, -32, 1, 0)
        chipLbl.Position          = UDim2.new(0, 30, 0, 0)
        chipLbl.BackgroundTransparency = 1
        chipLbl.Text              = def.short
        chipLbl.TextSize          = 9
        chipLbl.Font              = Enum.Font.GothamBold
        chipLbl.TextColor3        = P.txt
        chipLbl.TextXAlignment    = Enum.TextXAlignment.Left
        chipLbl.ZIndex            = 303

        -- small toggle indicator (right side)
        local chipDot = Instance.new("Frame", chip)
        chipDot.Size              = UDim2.new(0, 8, 0, 8)
        chipDot.Position          = UDim2.new(1, -11, 0.5, -4)
        chipDot.BackgroundColor3  = Color3.fromRGB(44, 44, 62)
        chipDot.BorderSizePixel   = 0
        chipDot.ZIndex            = 303
        Instance.new("UICorner", chipDot).CornerRadius = UDim.new(1, 0)

        ChipRefs[def.id] = {chip = chip, chipSt = chipSt, chipDot = chipDot}

        local function RefreshChip()
            local en = Config.MobHUDEnabled[def.id] == true
            chip.BackgroundColor3 = en and Color3.fromRGB(16, 52, 30) or Color3.fromRGB(22, 22, 36)
            chipSt.Color          = en and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(44, 44, 62)
            chipDot.BackgroundColor3 = en and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(44, 44, 62)
        end
        RefreshChip()

        chip.MouseButton1Click:Connect(function()
            Config.MobHUDEnabled[def.id] = not (Config.MobHUDEnabled[def.id] == true)
            RefreshChip()
            RefreshHUDVisibility()
        end)
    end

    -- Auto-size panel height based on chips grid
    local function ResizeHudPanel()
        local rows = math.ceil(#MobHUDDefs / 3)
        local contentH = 40 + rows * 38 + (rows - 1) * 6 + 20
        local vp = Camera.ViewportSize
        local h = math.min(contentH, vp.Y * 0.55)
        hudPanel.Size = UDim2.new(0, 300, 0, h)
        hudPanel.Position = UDim2.new(0.5, -150, 1, -(h + 72))
        chipsFrame.Size = UDim2.new(1, 0, 0, h - 40)
    end

    -- ── "HUD" open button ─────────────────────────────────────
    local hudOpenBtn = Instance.new("TextButton", Scr)
    hudOpenBtn.Size             = UDim2.new(0, MBS, 0, 34)
    hudOpenBtn.Position         = UDim2.new(0, 10, 0.5, MBS / 2 + 8)
    hudOpenBtn.BackgroundColor3 = P.bg
    hudOpenBtn.Text             = "HUD"
    hudOpenBtn.TextColor3       = P.acc
    hudOpenBtn.Font             = Enum.Font.GothamBlack
    hudOpenBtn.TextSize         = 11
    hudOpenBtn.ZIndex           = 100
    hudOpenBtn.AutoButtonColor  = false
    Instance.new("UICorner", hudOpenBtn).CornerRadius = UDim.new(0, 10)
    local hudOpenBtnSt = Instance.new("UIStroke", hudOpenBtn)
    hudOpenBtnSt.Thickness = 1.5; hudOpenBtnSt.Color = P.acc

    local hudPanelOpen = false
    local function OpenHUDPanel()
        hudPanelOpen = true
        ResizeHudPanel()
        hudPanel.Visible = true
        hudPanel.Size = UDim2.new(0, 300, 0, 0)
        local finalH = math.min(40 + math.ceil(#MobHUDDefs / 3) * 44 + 20, Camera.ViewportSize.Y * 0.55)
        TweenService:Create(hudPanel, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 300, 0, finalH),
        }):Play()
        hudOpenBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
        hudOpenBtnSt.Color    = Color3.fromRGB(255, 200, 50)
    end
    local function CloseHUDPanel()
        hudPanelOpen = false
        TweenService:Create(hudPanel, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 300, 0, 0),
        }):Play()
        task.delay(0.15, function() hudPanel.Visible = false end)
        hudOpenBtn.TextColor3 = P.acc
        hudOpenBtnSt.Color    = P.acc
        -- exit move mode too
        if MobHUDEditMode then
            MobHUDEditMode = false
            moveTogBtn.Text             = "✏ Move"
            moveTogBtn.TextColor3       = P.dim
            moveTogBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 44)
            for _, entry in pairs(MobHUDBtns) do pcall(ApplyHUDBtnColor, entry) end
        end
        if HasFileSystem() then pcall(SaveConfig) end
    end

    hudOpenBtn.MouseButton1Click:Connect(function()
        if hudPanelOpen then CloseHUDPanel() else OpenHUDPanel() end
    end)

    hudDoneBtn.MouseButton1Click:Connect(CloseHUDPanel)

    moveTogBtn.MouseButton1Click:Connect(function()
        MobHUDEditMode = not MobHUDEditMode
        if MobHUDEditMode then
            moveTogBtn.Text             = "● Moving"
            moveTogBtn.TextColor3       = Color3.fromRGB(255, 200, 50)
            moveTogBtn.BackgroundColor3 = Color3.fromRGB(40, 34, 8)
        else
            moveTogBtn.Text             = "✏ Move"
            moveTogBtn.TextColor3       = P.dim
            moveTogBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 44)
        end
        for _, entry in pairs(MobHUDBtns) do
            if entry.btn.Visible then pcall(ApplyHUDBtnColor, entry) end
        end
    end)

end -- IsTab

-- ============================================================
-- 27. DESCRIPTION POPUP
-- ============================================================
local descPopup = Instance.new("Frame", Scr)
descPopup.Size = UDim2.new(0, MW - 30, 0, 0)
descPopup.Position = UDim2.new(0.5, -(MW - 30) / 2, 0.5, -50)
descPopup.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
descPopup.BorderSizePixel = 0; descPopup.Visible = false; descPopup.ZIndex = 200
descPopup.ClipsDescendants = true
Instance.new("UICorner", descPopup).CornerRadius = UDim.new(0, 12)
local descStroke = Instance.new("UIStroke", descPopup)
descStroke.Color = P.acc; descStroke.Thickness = 2

local descTitle = Instance.new("TextLabel", descPopup)
descTitle.Size = UDim2.new(1, -10, 0, 24)
descTitle.Position = UDim2.new(0, 5, 0, 8)
descTitle.BackgroundTransparency = 1; descTitle.TextColor3 = P.acc
descTitle.Font = Enum.Font.GothamBlack; descTitle.TextSize = 13
descTitle.TextXAlignment = Enum.TextXAlignment.Left; descTitle.ZIndex = 201

local descBody = Instance.new("TextLabel", descPopup)
descBody.Size = UDim2.new(1, -14, 0, 60)
descBody.Position = UDim2.new(0, 7, 0, 34)
descBody.BackgroundTransparency = 1; descBody.TextColor3 = P.txt
descBody.Font = Enum.Font.Gotham; descBody.TextSize = IsMob and 11 or 10
descBody.TextWrapped = true; descBody.TextXAlignment = Enum.TextXAlignment.Left
descBody.TextYAlignment = Enum.TextYAlignment.Top; descBody.ZIndex = 201

local descClose = Instance.new("TextButton", descPopup)
descClose.Size = UDim2.new(0, 24, 0, 24); descClose.Position = UDim2.new(1, -30, 0, 6)
descClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65); descClose.Text = "✕"
descClose.TextColor3 = P.txt; descClose.Font = Enum.Font.GothamBold; descClose.TextSize = 11
descClose.BorderSizePixel = 0; descClose.ZIndex = 202; descClose.AutoButtonColor = false
Instance.new("UICorner", descClose).CornerRadius = UDim.new(1, 0)

local function ShowDesc(title, descKey)
    descTitle.Text = title
    descBody.Text = L(descKey)
    local textH = math.max(60, math.min(descBody.TextBounds.Y + 10, 160))
    local totalH = textH + 48
    descPopup.Size = UDim2.new(0, MW - 30, 0, 0)
    descPopup.Visible = true
    TweenService:Create(descPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, MW - 30, 0, totalH)
    }):Play()
    descBody.Size = UDim2.new(1, -14, 0, textH)
end

local function HideDesc()
    TweenService:Create(descPopup, TweenInfo.new(0.12), {
        Size = UDim2.new(0, MW - 30, 0, 0)
    }):Play()
    task.delay(0.12, function() descPopup.Visible = false end)
end

descClose.MouseButton1Click:Connect(HideDesc)

-- ============================================================
-- 28. UI ELEMENT BUILDERS
-- ============================================================
local waitingBind = nil

local function AddHdr(tab, icon, langKey)
    local pg = TabPages[tab]; if not pg then return end
    local f = Instance.new("Frame", pg)
    f.Size = UDim2.new(0.95, 0, 0, IsMob and 22 or 18)
    f.BackgroundColor3 = P.dark; f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -8, 1, 0); l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1; l.TextColor3 = P.dim
    l.Font = Enum.Font.GothamBold; l.TextSize = IsMob and 10 or 9
    l.Text = icon .. "  " .. L(langKey); l.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(LocalizableElements, {type = "header", obj = l, icon = icon, langKey = langKey})
end

local function MkToggle(tab, icon, lblKey, logicName, descKey)
    local pg = TabPages[tab]; if not pg then return end
    local row = Instance.new("TextButton", pg)
    row.Size = UDim2.new(0.95, 0, 0, BH)
    row.BackgroundColor3 = P.btn; row.BorderSizePixel = 0
    row.AutoButtonColor = false; row.Text = ""; row.ClipsDescendants = true
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", row).Color = P.brd

    local accent = Instance.new("Frame", row)
    accent.Size = UDim2.new(0, 3, 0.55, 0); accent.Position = UDim2.new(0, 0, 0.225, 0)
    accent.BackgroundColor3 = Color3.fromRGB(60, 60, 75); accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

    local ic = Instance.new("TextLabel", row)
    ic.Size = UDim2.new(0, 24, 1, 0); ic.Position = UDim2.new(0, 8, 0, 0)
    ic.BackgroundTransparency = 1; ic.Text = icon
    ic.TextSize = IsMob and 15 or 13; ic.Font = Enum.Font.Gotham; ic.TextColor3 = P.dim

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -100, 1, 0); lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = L(lblKey); lbl.TextColor3 = P.txt
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = FS
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    if descKey then
        local infoBtn = Instance.new("TextButton", row)
        infoBtn.Size = UDim2.new(0, IsMob and 22 or 18, 0, IsMob and 22 or 18)
        infoBtn.Position = UDim2.new(1, IsMob and -100 or -92, 0.5, IsMob and -11 or -9)
        infoBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        infoBtn.Text = "?"; infoBtn.TextColor3 = P.acc
        infoBtn.Font = Enum.Font.GothamBold; infoBtn.TextSize = IsMob and 12 or 10
        infoBtn.BorderSizePixel = 0; infoBtn.AutoButtonColor = false; infoBtn.ZIndex = 5
        Instance.new("UICorner", infoBtn).CornerRadius = UDim.new(1, 0)
        infoBtn.MouseButton1Click:Connect(function()
            ShowDesc(L(lblKey), descKey)
        end)
    end

    local swBG = Instance.new("Frame", row)
    swBG.Size = UDim2.new(0, IsMob and 42 or 36, 0, IsMob and 22 or 18)
    swBG.Position = UDim2.new(1, IsMob and -50 or -44, 0.5, IsMob and -11 or -9)
    swBG.BackgroundColor3 = P.swOff; swBG.BorderSizePixel = 0
    Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)

    local swDot = Instance.new("Frame", swBG)
    local dotS = IsMob and 16 or 12
    swDot.Size = UDim2.new(0, dotS, 0, dotS)
    swDot.Position = UDim2.new(0, 3, 0.5, -dotS / 2)
    swDot.BackgroundColor3 = P.wht; swDot.BorderSizePixel = 0
    Instance.new("UICorner", swDot).CornerRadius = UDim.new(1, 0)

    row.MouseButton1Click:Connect(function()
        if waitingBind then return end
        Toggle(logicName)
        if logicName == "Fly" then UpdFly() end
        if logicName == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
    end)

    AllRows[logicName] = {swBG = swBG, swDot = swDot, accent = accent, row = row, lbl = lbl}
    table.insert(LocalizableElements, {type = "toggle", obj = lbl, langKey = lblKey})
    return row
end

local function MkToggleBind(tab, icon, lblKey, logicName, descKey)
    local row = MkToggle(tab, icon, lblKey, logicName, descKey)
    if not row then return end
    local bindBtn = Instance.new("TextButton", row)
    bindBtn.Size = UDim2.new(0, 42, 0, IsMob and 22 or 18)
    bindBtn.Position = UDim2.new(1, IsMob and -148 or -138, 0.5, IsMob and -11 or -9)
    bindBtn.BackgroundColor3 = P.dark; bindBtn.BorderSizePixel = 0
    bindBtn.Text = tostring(Binds[logicName] or ""):gsub("Enum.KeyCode.", "")
    bindBtn.TextColor3 = P.dim; bindBtn.Font = Enum.Font.GothamBold; bindBtn.TextSize = 9
    bindBtn.AutoButtonColor = false
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 5)
    bindBtn.MouseButton1Click:Connect(function()
        if waitingBind then return end
        waitingBind = logicName; bindBtn.Text = "?"; bindBtn.TextColor3 = P.grn
    end)
    AllRows[logicName].bindBtn = bindBtn
end

local function MkButton(tab, icon, lblKey, color, onClick)
    local pg = TabPages[tab]; if not pg then return end
    local row = Instance.new("TextButton", pg)
    row.Size = UDim2.new(0.95, 0, 0, BH)
    row.BackgroundColor3 = color or P.srvBtn
    row.BorderSizePixel = 0; row.AutoButtonColor = false; row.Text = ""
    row.ClipsDescendants = true
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = color or P.acc; stroke.Transparency = 0.5

    local ic = Instance.new("TextLabel", row)
    ic.Size = UDim2.new(0, 26, 1, 0); ic.Position = UDim2.new(0, 8, 0, 0)
    ic.BackgroundTransparency = 1; ic.Text = icon
    ic.TextSize = IsMob and 16 or 14; ic.Font = Enum.Font.Gotham; ic.TextColor3 = P.acc

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -40, 1, 0); lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = L(lblKey); lbl.TextColor3 = P.txt
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = FS
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local arr = Instance.new("TextLabel", row)
    arr.Size = UDim2.new(0, 20, 1, 0); arr.Position = UDim2.new(1, -24, 0, 0)
    arr.BackgroundTransparency = 1; arr.Text = "▶"; arr.TextSize = 10
    arr.Font = Enum.Font.GothamBold; arr.TextColor3 = P.dim

    row.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = P.tabA}):Play()
        task.delay(0.12, function()
            TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = color or P.srvBtn}):Play()
        end)
        if onClick then pcall(onClick) end
    end)
    table.insert(LocalizableElements, {type = "button", obj = lbl, langKey = lblKey})
    return row
end

local function MkSlider(tab, icon, lblKey, minV, maxV, def, configKey, onChange)
    local pg = TabPages[tab]; if not pg then return end
    local h = IsMob and 56 or 48
    local row = Instance.new("Frame", pg)
    row.Size = UDim2.new(0.95, 0, 0, h)
    row.BackgroundColor3 = P.btn; row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", row).Color = P.brd

    local ic = Instance.new("TextLabel", row)
    ic.Size = UDim2.new(0, 22, 0, 20); ic.Position = UDim2.new(0, 6, 0, 4)
    ic.BackgroundTransparency = 1; ic.Text = icon
    ic.TextSize = IsMob and 14 or 12; ic.Font = Enum.Font.Gotham; ic.TextColor3 = P.dim

    local tl = Instance.new("TextLabel", row)
    tl.Size = UDim2.new(1, -80, 0, 18); tl.Position = UDim2.new(0, 28, 0, 3)
    tl.BackgroundTransparency = 1; tl.Text = L(lblKey); tl.Font = Enum.Font.GothamBold
    tl.TextSize = FS; tl.TextColor3 = P.txt; tl.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", row)
    vl.Size = UDim2.new(0, 50, 0, 18); vl.Position = UDim2.new(1, -54, 0, 3)
    vl.BackgroundTransparency = 1; vl.Text = tostring(def); vl.Font = Enum.Font.GothamBold
    vl.TextSize = FS; vl.TextColor3 = P.grn; vl.TextXAlignment = Enum.TextXAlignment.Right

    local trk = Instance.new("Frame", row)
    trk.Size = UDim2.new(1, -16, 0, 6); trk.Position = UDim2.new(0, 8, 0, h - 16)
    trk.BackgroundColor3 = P.dark; trk.BorderSizePixel = 0
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", trk)
    fill.Size = UDim2.new((def - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = P.acc; fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", trk)
    dot.Size = UDim2.new(0, 14, 0, 14); dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = UDim2.new((def - minV) / (maxV - minV), 0, 0.5, 0)
    dot.BackgroundColor3 = P.wht; dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function SetValue(val)
        local t = math.clamp((val - minV) / (maxV - minV), 0, 1)
        fill.Size = UDim2.new(t, 0, 1, 0)
        dot.Position = UDim2.new(t, 0, 0.5, 0)
        vl.Text = tostring(math.floor(val))
    end

    local function Upd(inp)
        local abs = trk.AbsolutePosition; local sz = trk.AbsoluteSize
        local t = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
        local cur = math.floor(minV + t * (maxV - minV))
        SetValue(cur)
        if onChange then pcall(onChange, cur) end
    end

    trk.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; pg.ScrollingEnabled = false; Upd(inp)
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

    if configKey then
        SliderRefs[configKey] = {
            default = def,
            update = function(val)
                val = math.clamp(val, minV, maxV)
                SetValue(val)
            end,
        }
    end
    table.insert(LocalizableElements, {type = "slider", obj = tl, langKey = lblKey})
end

-- ============================================================
-- 29. LANGUAGE REFRESH
-- ============================================================
local langBtnRef    = nil
local autoSaveLblRef = nil
local safeInfoLblRef = nil

local function RefreshLanguage()
    for _, el in pairs(LocalizableElements) do
        pcall(function()
            if el.type == "header" then
                el.obj.Text = el.icon .. "  " .. L(el.langKey)
            elseif el.type == "toggle" or el.type == "button" or el.type == "slider" then
                el.obj.Text = L(el.langKey)
            elseif el.type == "tab" then
                el.obj.Text = el.icon .. " " .. L(el.langKey)
            end
        end)
    end
    pcall(function()
        tTit.Text = L("title")
        tSub.Text = IsMob and L("subtitle_mobile") or L("subtitle_pc")
    end)
    if langBtnRef then pcall(function() langBtnRef.Text = L("btn_lang_toggle") end) end
    if autoSaveLblRef then pcall(function() autoSaveLblRef.Text = L("stat_auto_save") end) end
end

-- ============================================================
-- 30. POPULATE UI TABS
-- ============================================================
AddHdr("Combat", "🎯", "hdr_aiming")
MkToggleBind("Combat", "🎯", "lbl_auto_aim", "Aim", "desc_auto_aim")
MkToggleBind("Combat", "🔇", "lbl_silent_aim", "SilentAim", "desc_silent_aim")
MkToggle("Combat", "🧲", "lbl_shadow_lock", "ShadowLock", "desc_shadow_lock")
AddHdr("Combat", "💥", "hdr_hitbox_esp")
MkToggle("Combat", "📦", "lbl_hitbox", "Hitbox", "desc_hitbox")
MkToggle("Combat", "👁", "lbl_esp", "ESP", "desc_esp")

AddHdr("Move", "✈️", "hdr_flight")
MkToggleBind("Move", "✈️", "lbl_fly", "Fly", "desc_fly")
MkToggle("Move", "📷", "lbl_freecam", "Freecam", "desc_freecam")
AddHdr("Move", "🏃", "hdr_speed_jump")
MkToggle("Move", "👟", "lbl_speed", "Speed", "desc_speed")
MkToggle("Move", "🐇", "lbl_bhop", "Bhop", "desc_bhop")
MkToggle("Move", "⬆️", "lbl_high_jump", "HighJump", "desc_high_jump")
MkToggle("Move", "♾️", "lbl_infinite_jump", "InfiniteJump", "desc_infinite_jump")
AddHdr("Move", "👻", "hdr_physics")
MkToggleBind("Move", "👻", "lbl_noclip", "Noclip", "desc_noclip")
MkToggle("Move", "🛡", "lbl_no_fall", "NoFallDamage", "desc_no_fall")
MkToggle("Move", "🌊", "lbl_anti_void", "AntiVoid", "desc_anti_void")
AddHdr("Move", "🛡", "hdr_safe_speed")
MkToggle("Move", "🛡", "lbl_safe_speed", "SafeSpeedMode", "desc_safe_speed")
MkSlider("Move", "✖", "sl_safe_mult", 10, 40, math.floor(Config.SafeSpeedMult * 10), "SafeSpeedMult_slider", function(v)
    Config.SafeSpeedMult = v / 10
end)

do
    local pg = TabPages["Move"]
    local infoF = Instance.new("Frame", pg)
    infoF.Size = UDim2.new(0.95, 0, 0, IsMob and 44 or 36)
    infoF.BackgroundColor3 = Color3.fromRGB(14, 18, 14); infoF.BorderSizePixel = 0
    Instance.new("UICorner", infoF).CornerRadius = UDim.new(0, 8)
    local infoSt = Instance.new("UIStroke", infoF)
    infoSt.Color = Color3.fromRGB(0, 160, 80); infoSt.Transparency = 0.5
    local infoLbl = Instance.new("TextLabel", infoF)
    infoLbl.Size = UDim2.new(1, -10, 1, 0); infoLbl.Position = UDim2.new(0, 5, 0, 0)
    infoLbl.BackgroundTransparency = 1; infoLbl.TextColor3 = Color3.fromRGB(100, 230, 140)
    infoLbl.Font = Enum.Font.GothamBold; infoLbl.TextSize = IsMob and 10 or 9
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.TextWrapped = true
    infoLbl.Text = ""
    safeInfoLblRef = infoLbl

    task.spawn(function()
        while task.wait(0.8) do
            pcall(function()
                local cap = math.floor(gameBaseSpeed * Config.SafeSpeedMult)
                local setSpd = Config.WalkSpeed
                local active = State.SafeSpeedMode
                local eff = active and math.min(setSpd, cap) or setSpd
                local warn = (setSpd > cap and active) and " ⚠️" or ""
                infoLbl.Text = string.format(
                    L("stat_safe_info"),
                    math.floor(gameBaseSpeed), Config.SafeSpeedMult, cap, warn, setSpd, eff
                )
                infoLbl.TextColor3 = (setSpd > cap and active)
                    and Color3.fromRGB(255, 180, 50)
                    or Color3.fromRGB(100, 230, 140)
            end)
        end
    end)
end

AddHdr("Misc", "🔧", "hdr_effects")
MkToggle("Misc", "🌀", "lbl_spin", "Spin", "desc_spin")
MkToggle("Misc", "🥔", "lbl_potato", "Potato", "desc_potato")
MkToggle("Misc", "☀️", "lbl_fullbright", "FullBright", "desc_fullbright")
MkToggleBind("Misc", "📡", "lbl_fake_lag", "FakeLag", "desc_fake_lag")
AddHdr("Misc", "🛡", "hdr_protection")
MkToggle("Misc", "💤", "lbl_anti_afk", "AntiAFK", "desc_anti_afk")
AddHdr("Misc", "🌐", "hdr_server_hop")
MkButton("Misc", "🔄", "btn_rejoin", Color3.fromRGB(22, 28, 38), RejoinSameServer)
MkButton("Misc", "🎲", "btn_random", Color3.fromRGB(22, 28, 38), JoinRandomServer)
MkButton("Misc", "👥", "btn_biggest", Color3.fromRGB(22, 28, 38), JoinBiggestServer)
MkButton("Misc", "🕵️", "btn_smallest", Color3.fromRGB(22, 28, 38), JoinSmallestServer)

AddHdr("Config", "🌐", "hdr_language")
do
    local pg = TabPages["Config"]
    local langRow = Instance.new("TextButton", pg)
    langRow.Size = UDim2.new(0.95, 0, 0, BH)
    langRow.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
    langRow.BorderSizePixel = 0; langRow.AutoButtonColor = false
    langRow.Text = L("btn_lang_toggle"); langRow.TextColor3 = P.acc
    langRow.Font = Enum.Font.GothamBold; langRow.TextSize = IsMob and 12 or 10
    Instance.new("UICorner", langRow).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", langRow).Color = P.acc
    langBtnRef = langRow
    langRow.MouseButton1Click:Connect(function()
        CurrentLang = (CurrentLang == "EN") and "UA" or "EN"
        RefreshLanguage()
        local langName = CurrentLang == "EN" and "English" or "Українська"
        Notify("Language", L("ntf_lang") .. langName, 2)
    end)
end

AddHdr("Config", "💾", "hdr_save_config")
do
    local pg = TabPages["Config"]
    local btnRow = Instance.new("Frame", pg)
    btnRow.Size = UDim2.new(0.95, 0, 0, BH)
    btnRow.BackgroundTransparency = 1; btnRow.BorderSizePixel = 0

    local function MkCfgBtn(lblKey, col, xPos, xSize, onClick)
        local b = Instance.new("TextButton", btnRow)
        b.Size = UDim2.new(xSize, -3, 1, 0); b.Position = UDim2.new(xPos, 2, 0, 0)
        b.BackgroundColor3 = col; b.Text = L(lblKey); b.TextColor3 = P.wht
        b.Font = Enum.Font.GothamBold; b.TextSize = IsMob and 12 or 10
        b.BorderSizePixel = 0; b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        Instance.new("UIStroke", b).Color = col
        b.MouseButton1Click:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
            task.delay(0.15, function()
                TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = col}):Play()
            end)
            if onClick then pcall(onClick) end
        end)
        table.insert(LocalizableElements, {type = "button", obj = b, langKey = lblKey})
    end

    MkCfgBtn("btn_save", Color3.fromRGB(20, 100, 55), 0, 1 / 3, SaveConfig)
    MkCfgBtn("btn_load", Color3.fromRGB(20, 60, 120), 1 / 3, 1 / 3, function()
        LoadConfig()
        task.delay(0.15, function()
            for nm in pairs(AllRows) do pcall(UpdVis, nm) end
            for nm, d in pairs(AllRows) do
                if d.bindBtn and Binds[nm] then
                    d.bindBtn.Text = tostring(Binds[nm]):gsub("Enum%.KeyCode%.", "")
                end
            end
            RefreshLanguage()
        end)
    end)
    MkCfgBtn("btn_reset", Color3.fromRGB(100, 35, 20), 2 / 3, 1 / 3, function()
        ResetConfig()
        task.delay(0.15, function()
            for nm in pairs(AllRows) do pcall(UpdVis, nm) end
            for nm, d in pairs(AllRows) do
                if d.bindBtn and Binds[nm] then
                    d.bindBtn.Text = tostring(Binds[nm]):gsub("Enum%.KeyCode%.", "")
                end
            end
        end)
    end)

    local autoLbl = Instance.new("TextLabel", pg)
    autoLbl.Size = UDim2.new(0.95, 0, 0, IsMob and 18 or 14)
    autoLbl.BackgroundTransparency = 1; autoLbl.TextColor3 = P.dim
    autoLbl.Font = Enum.Font.Gotham; autoLbl.TextSize = IsMob and 10 or 9
    autoLbl.Text = L("stat_auto_save")
    autoLbl.TextXAlignment = Enum.TextXAlignment.Center; autoLbl.TextWrapped = true
    autoSaveLblRef = autoLbl
end

AddHdr("Config", "🚀", "hdr_speed_vals")
MkSlider("Config", "✈️", "sl_fly_speed", 0, 300, Config.FlySpeed, "FlySpeed", function(v)
    Config.FlySpeed = v
end)
MkSlider("Config", "👟", "sl_walk_speed", 16, 200, Config.WalkSpeed, "WalkSpeed", function(v)
    Config.WalkSpeed = v
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if State.Speed and h then pcall(function() h.WalkSpeed = GetSafeSpeed() end) end
end)

AddHdr("Config", "⬆️", "hdr_jump_vals")
MkSlider("Config", "⬆️", "sl_jump_power", 50, 500, Config.JumpPower, "JumpPower", function(v)
    Config.JumpPower = v
    local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if State.HighJump and h then
        pcall(function()
            h.UseJumpPower = true; h.JumpPower = v; h.JumpHeight = v * 0.35
        end)
    end
end)
MkSlider("Config", "🐇", "sl_bhop_power", 20, 150, Config.BhopPower, "BhopPower", function(v)
    Config.BhopPower = v
end)

AddHdr("Config", "📦", "hdr_hitbox_cfg")
MkSlider("Config", "📦", "sl_hitbox_size", 2, 15, Config.HitboxSize, "HitboxSize", function(v)
    Config.HitboxSize = v
end)

AddHdr("Config", "👁", "hdr_hitbox_esp")
MkSlider("Config", "👁", "sl_esp_dist", 50, 2000, Config.ESPDistance, "ESPDistance", function(v)
    Config.ESPDistance = v
    -- apply instantly to all active ESP entries
    for _, ca in pairs(ESPCache) do
        pcall(function()
            if ca.bb and ca.bb.Parent then
                ca.bb.MaxDistance = v
            end
        end)
    end
end)

AddHdr("Config", "🎯", "hdr_aim_settings")
MkSlider("Config", "⭕", "sl_aim_fov", 50, 500, Config.AimFOV, "AimFOV", function(v)
    Config.AimFOV = v; UpdateFOVCircle()
end)
MkSlider("Config", "🎚", "sl_aim_smooth", 5, 100, math.floor(Config.AimSmooth * 100), "AimSmooth_slider", function(v)
    Config.AimSmooth = v / 100
end)

AddHdr("Config", "🌊", "hdr_anti_void")
MkSlider("Config", "🌊", "sl_anti_void_h", -500, -50, Config.AntiVoidHeight, "AntiVoidHeight", function(v)
    Config.AntiVoidHeight = v
end)

AddHdr("Config", "🛡", "hdr_anti_ban")
MkToggle("Config", "🎲", "lbl_speed_jitter", "SpeedAntiBan", "desc_speed_jitter")
MkToggle("Config", "📦", "lbl_hitbox_rand", "HitboxRandomize", "desc_hitbox_rand")
MkToggle("Config", "🎯", "lbl_aim_anti", "AimAntiDetect", "desc_aim_anti")

-- ============================================================
-- 31. INPUT HANDLING
-- ============================================================
UIS.InputBegan:Connect(function(inp, gpe)
    if waitingBind then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local key = inp.KeyCode; local nm = waitingBind
            Binds[nm] = key
            local d = AllRows[nm]
            if d and d.bindBtn then
                d.bindBtn.Text = tostring(key):gsub("Enum.KeyCode.", "")
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
                if act == "Fly" then UpdFly() end
                if act == "Freecam" then fcZ.Visible = State.Freecam and IsTab end
            end
        end
    end
end)

UIS.InputChanged:Connect(function(inp, gpe)
    if gpe or not State.Freecam then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        FC_Y = FC_Y - math.rad(inp.Delta.X * 0.35)
        FC_P = math.clamp(FC_P - math.rad(inp.Delta.Y * 0.35), -math.rad(89), math.rad(89))
    end
end)

-- ============================================================
-- 32. JUMP REQUESTS
-- ============================================================
UIS.JumpRequest:Connect(function()
    local C = LP.Character
    local H = C and C:FindFirstChildOfClass("Humanoid")
    local R = C and C:FindFirstChild("HumanoidRootPart")
    if not H or not R or H.Health <= 0 or State.Fly or State.Freecam then return end

    if State.FakeLag then
        local cr = LP.Character
        if cr then
            for _, v in pairs(cr:GetDescendants()) do
                if v:IsA("BasePart") then pcall(function() v.Anchored = false end) end
            end
        end
    end

    if State.HighJump then
        pcall(function()
            H.UseJumpPower = true
            H.JumpPower = Config.JumpPower
            H.JumpHeight = Config.JumpPower * 0.35
        end)
    end

    if not State.InfiniteJump then return end

    pcall(function()
        H:ChangeState(Enum.HumanoidStateType.Jumping)
        local pw = State.HighJump and Config.JumpPower or 50
        local v = R.AssemblyLinearVelocity
        local jumpVel = math.max(pw * 0.82, 42) + math.random(-2, 2)
        R.AssemblyLinearVelocity = Vector3.new(v.X, jumpVel, v.Z)
    end)
end)

-- ============================================================
-- 33. ANIMATION LOOP
-- ============================================================
task.spawn(function()
    local t = 0
    while true do
        task.wait(0.033)
        t += 0.02
        local pulse = (math.sin(t * 2) + 1) / 2
        local aR = math.floor(0 + pulse * 15)
        local aG = math.floor(180 + pulse * 30)
        local aB = math.floor(95 + pulse * 20)
        local acol = Color3.fromRGB(aR, aG, aB)
        pcall(function()
            mSt.Color = acol; mB.TextColor3 = acol
            tGrad.Rotation = (t * 15) % 360
            tAcc.BackgroundColor3 = acol; tIco.TextColor3 = acol
            exStroke.Color = acol
            mainS.Color = Color3.fromRGB(
                math.floor(38 + pulse * 20),
                math.floor(38 + pulse * 20),
                math.floor(48 + pulse * 20)
            )
            for nm, d in pairs(AllRows) do
                if State[nm] and d.accent then d.accent.BackgroundColor3 = acol end
            end
            if (State.Aim or State.SilentAim) and not (aimLocked and aimTarget) then
                fovStroke.Color = Color3.fromRGB(180, 180, 200)
            end
        end)
    end
end)

-- ============================================================
-- 34. RENDER STEPPED
-- ============================================================
local FrameLog  = {}
local lastPing  = 0
local pingTk    = 0

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
    fpsL.Text = "FPS: " .. fps; fpsL.TextColor3 = fc
    pngL.Text = "Ping: " .. pm .. "ms"; pngL.TextColor3 = pc
    eF.Text = tostring(fps); eF.TextColor3 = fc
    eP.Text = pm .. " ms"; eP.TextColor3 = pc

    local Char = LP.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local showFOV = (State.Aim or State.SilentAim) and not State.Freecam
    fovCircle.Visible = showFOV; tgtInfo.Visible = false

    -- FLY
    if State.Fly and not State.Freecam and HRP and Hum then
        pcall(function()
            Hum.PlatformStand = false
            local mx, mz = GetDir()
            local camCF = Camera.CFrame
            local dir = camCF.LookVector * -mz + camCF.RightVector * mx
            local upD = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp then upD = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or MobDn then upD = -1 end
            dir = dir + Vector3.new(0, upD, 0)
            if dir.Magnitude > 1 then dir = dir.Unit end
            if HRP.Position.Y > Config.FlyHeightMax then
                dir = Vector3.new(dir.X, math.min(dir.Y, -0.1), dir.Z)
            end
            if Config.FlyAntiBan then
                _flyNoiseT = _flyNoiseT + 0.005
                local nx = PseudoNoise(_flyNoiseT) * 0.12
                local ny = PseudoNoise(_flyNoiseT + 100) * 0.06
                local nz = PseudoNoise(_flyNoiseT + 200) * 0.12
                local target_vel = dir * Config.FlySpeed + Vector3.new(nx, ny, nz)
                local cur_vel = HRP.AssemblyLinearVelocity
                local lerp_vel = cur_vel:Lerp(target_vel, math.clamp(dt * 18, 0, 1))
                HRP.AssemblyLinearVelocity = lerp_vel
                HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0,
                    math.atan2(-camCF.LookVector.X, -camCF.LookVector.Z), 0)
            else
                HRP.AssemblyLinearVelocity = dir * Config.FlySpeed
            end
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
            Camera.CFrame = CFrame.new(Camera.CFrame.Position + dir * (Config.FlySpeed / 25) * dt * 60)
                * CFrame.fromEulerAnglesYXZ(FC_P, FC_Y, 0)
        end)
    end

    -- AUTO AIM
    if State.Aim and not State.Freecam and Char and HRP then
        pcall(function()
            local target = GetBestAimTarget()
            local part = target and FindAimPart(target)
            if part then
                local predTime = math.clamp(lastPing, 0.01, 0.25)
                local vel = part.AssemblyLinearVelocity
                local dist = (Camera.CFrame.Position - part.Position).Magnitude
                local predMul = math.clamp(dist / 100, 0.3, 1.5)
                local predictedPos = part.Position + vel * predTime * predMul
                if vel.Y < -5 then
                    predictedPos += Vector3.new(0, -4.9 * predTime * predTime, 0)
                end
                local smooth = Config.AimSmooth
                local sd = ScreenDist(part)
                if sd < 30 then smooth = smooth * 0.3
                elseif sd < 80 then smooth = smooth * 0.6 end
                if Config.AimAntiDetect then
                    predictedPos += Vector3.new(
                        (math.random() - 0.5) * 0.12,
                        (math.random() - 0.5) * 0.08,
                        (math.random() - 0.5) * 0.12
                    )
                end
                local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, smooth)
                local plr = Players:GetPlayerFromCharacter(target)
                tgtInfo.Text = "🔒 " .. (plr and plr.Name or "?") .. " [" .. math.floor(dist) .. "m]"
                tgtInfo.TextColor3 = Color3.fromRGB(0, 230, 120); tgtInfo.Visible = true
                fovStroke.Color = Color3.fromRGB(0, 230, 100); fovStroke.Thickness = 2
            else
                if showFOV then
                    tgtInfo.Text = L("stat_no_target"); tgtInfo.TextColor3 = P.dim; tgtInfo.Visible = true
                end
                fovStroke.Color = Color3.fromRGB(180, 180, 200); fovStroke.Thickness = 1.5
            end
        end)
    end

    -- SILENT AIM INDICATOR
    if State.SilentAim and not State.Aim and not State.Freecam then
        pcall(function()
            local tgt = GetBestAimTarget()
            local part = tgt and FindAimPart(tgt)
            if part then
                local plr = Players:GetPlayerFromCharacter(tgt)
                local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
                tgtInfo.Text = "🔇 " .. (plr and plr.Name or "?") .. " [" .. dist .. "m]"
                tgtInfo.TextColor3 = Color3.fromRGB(255, 200, 50); tgtInfo.Visible = true
                fovStroke.Color = Color3.fromRGB(255, 200, 50)
            else
                if showFOV then
                    tgtInfo.Text = L("stat_no_target"); tgtInfo.TextColor3 = P.dim; tgtInfo.Visible = true
                end
                fovStroke.Color = Color3.fromRGB(180, 180, 200)
            end
        end)
    end
end)

-- ============================================================
-- 35. HEARTBEAT
-- ============================================================
RunService.Heartbeat:Connect(function(dt)
    local Char = LP.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum or Hum.Health <= 0 then return end

    -- SHADOW LOCK
    if State.ShadowLock then
        if not IsAlive(LockedTarget) then LockedTarget = GetClosestEnemy() end
        if LockedTarget then
            local tR = LockedTarget:FindFirstChild("HumanoidRootPart")
            if tR then
                pcall(function()
                    local pr = tR.AssemblyLinearVelocity * math.clamp(lastPing, 0, 0.2)
                    HRP.CFrame = HRP.CFrame:Lerp(
                        CFrame.new(tR.Position + pr) * tR.CFrame.Rotation * CFrame.new(0, 0, 3), 0.4
                    )
                    HRP.AssemblyLinearVelocity = tR.AssemblyLinearVelocity
                end)
            end
        end
    end

    -- SPEED
    if State.Speed and not State.Fly and not State.Freecam then
        pcall(function()
            local targetSpd = GetSafeSpeed()
            Hum.WalkSpeed = targetSpd
            if Hum.MoveDirection.Magnitude > 0.1 then
                local md = Hum.MoveDirection.Unit
                local vel = HRP.AssemblyLinearVelocity
                local flatVel = Vector3.new(vel.X, 0, vel.Z)
                if State.SafeSpeedMode then
                    local cycle = tick() % 0.60
                    local onTime = 0.60 * 0.82
                    if cycle > onTime then
                        local brake = 1 - ((cycle - onTime) / (0.60 - onTime))
                        local want = md * targetSpd * math.max(brake, 0.15)
                        HRP.AssemblyLinearVelocity = Vector3.new(
                            vel.X + (want.X - vel.X) * 0.30, vel.Y,
                            vel.Z + (want.Z - vel.Z) * 0.30
                        )
                    else
                        if flatVel.Magnitude < targetSpd * 0.9 then
                            local want = md * targetSpd
                            HRP.AssemblyLinearVelocity = Vector3.new(want.X, vel.Y, want.Z)
                        end
                    end
                else
                    if flatVel.Magnitude < targetSpd * 0.9 then
                        local want = md * targetSpd
                        HRP.AssemblyLinearVelocity = Vector3.new(want.X, vel.Y, want.Z)
                    end
                end
            end
        end)
    end

    -- HIGH JUMP
    if State.HighJump and not State.Fly then
        pcall(function()
            Hum.UseJumpPower = true
            Hum.JumpPower = Config.JumpPower
            Hum.JumpHeight = Config.JumpPower * 0.35
        end)
    end

    -- BHOP
    if State.Bhop and not State.Fly and not State.Freecam then
        pcall(function()
            if Hum.MoveDirection.Magnitude > 0.1
                and (UIS:IsKeyDown(Enum.KeyCode.Space) or MobUp) then
                local now2 = tick()
                if Hum.FloorMaterial ~= Enum.Material.Air and now2 - lastBhop > 0.06 then
                    Hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    local v = HRP.AssemblyLinearVelocity
                    local md = Hum.MoveDirection.Unit
                    HRP.AssemblyLinearVelocity = Vector3.new(
                        v.X + md.X * (4 + math.random() * 3),
                        Config.BhopPower + math.random(-6, 6),
                        v.Z + md.Z * (4 + math.random() * 3)
                    )
                    lastBhop = now2
                end
            end
        end)
    end

    -- NO FALL DAMAGE
    if State.NoFallDamage then
        pcall(function()
            local state = Hum:GetState()
            if state == Enum.HumanoidStateType.Freefall
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
-- 36. STEPPED — NOCLIP (MULTI-METHOD BYPASS)
-- ============================================================
--[[
  Three-layer bypass to handle all places:
  Layer 1 (best): CollisionGroup method — character assigned to a group
                  that doesn't collide with Default. Works on most places.
  Layer 2 (fallback): Direct CanCollide = false on every BasePart every frame.
                      Works when collision groups aren't available.
  Layer 3 (anti-stuck): If character stops moving but inputs are pressed,
                        raycast forward and nudge CFrame through the wall.
]]

RunService.Stepped:Connect(function()
    local Char = LP.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")

    if State.Noclip and Char and HRP and Hum then
        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    -- Layer 1: collision group (random name, unblockable by name filter)
                    if ncGroupReady then
                        v.CollisionGroup = SafeGroup
                    end
                    -- Layer 2: direct CanCollide override (belt-and-suspenders)
                    if ncOrigCanCollide[v] == nil then
                        ncOrigCanCollide[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end)
            end
        end

        -- Layer 3: anti-stuck nudge
        local moving = Hum.MoveDirection.Magnitude > 0.05
            or HRP.AssemblyLinearVelocity.Magnitude > 5
        local delta = (HRP.Position - lastNcPos).Magnitude

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
                return Workspace:Raycast(HRP.Position, md * 8, ncRay)
            end)
            if ok and r then
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
        lastNcPos = HRP.Position; ncStuck = 0
    end
end)

-- ============================================================
-- 37. INITIAL CONFIG LOAD
-- ============================================================
task.spawn(function()
    task.wait(0.6)
    if not HasFileSystem() then return end
    local ok, raw = pcall(readfile, CFG_FILE)
    if not ok or not raw or raw == "" then return end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or not data then return end
    ApplyLoadedConfig(data)
    task.wait(0.1)
    UpdateAllSliders()
    for nm in pairs(AllRows) do pcall(UpdVis, nm) end
    for nm, d in pairs(AllRows) do
        if d.bindBtn and Binds[nm] then
            d.bindBtn.Text = tostring(Binds[nm]):gsub("Enum%.KeyCode%.", "")
        end
    end
    UpdateFOVCircle()
    RefreshLanguage()
    -- Restore mobile HUD button positions if available
    if IsTab then
        local vp = Camera.ViewportSize
        for id, entry in pairs(MobHUDBtns) do
            local saved = Config.MobHUDPositions and Config.MobHUDPositions[id]
            if saved and saved[1] and saved[2] then
                local nx = math.clamp(saved[1], 0, vp.X - HUD_SZ)
                local ny = math.clamp(saved[2], 0, vp.Y - HUD_SZ)
                entry.btn.Position = UDim2.new(0, nx, 0, ny)
            end
        end
    end
    Notify("OMNI", L("ntf_loaded"), 3)
end)

-- ============================================================
-- 38. STARTUP
-- ============================================================
Notify("OMNI V305", L("ntf_startup"), 5)
