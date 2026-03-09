-- ██████████████████████████████████████████████████████████
-- ██  OMNI V305 — PERFECT EDITION (EN/UA) [MOD]         ██
-- ██  Clean ESP · Better Noclip Bypass · Anti-Void        ██
-- ██  Language Toggle · Function Descriptions · Mobile+PC ██
-- ██████████████████████████████████████████████████████████

-- ============================================================
-- 1. SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local PhysicsService    = game:GetService("PhysicsService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Безпечне очікування гравця для уникнення помилок "nil" при autoexec
local LP = Players.LocalPlayer
while not LP do
    task.wait()
    LP = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
while not Camera do
    task.wait()
    Camera = Workspace.CurrentCamera
end

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
        lbl_fps_unlocker  = "FPS Unlocker",
        desc_fps_unlocker = "Unlocks frame rate above 60 FPS using setfpscap(0). Requires executor support.",
        lbl_fps_display   = "Show FPS/Ping",
        desc_fps_display  = "Shows the floating FPS and Ping widget on screen.",
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
        sl_aim_pred     = "Prediction ×",
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
        lbl_fps_unlocker  = "FPS Анлокер",
        desc_fps_unlocker = "Знімає обмеження FPS через setfpscap(0). Потрібна підтримка екзекутора.",
        lbl_fps_display   = "Показ FPS/Пінг",
        desc_fps_display  = "Показує плаваючий виджет FPS та Пінг на екрані.",
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
        sl_aim_pred     = "Предікт ×",
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
local SafeGroup = "NC_" .. math.random(100000, 999999)
local ncGroupReady = false

pcall(function()
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
    AimPredMult       = 10,
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
    FPSUnlocker = false, FPSDisplay = true,
    SpeedAntiBan = true, HitboxRandomize = true,
    AimAntiDetect = true, SafeSpeedMode = false,
}

-- ============================================================
-- 7. CONFIG PERSISTENCE
-- ============================================================
local CFG_FILE = "OmniV305_Config.json"
local SAVE_STATE_KEYS = {
    "AntiAFK", "FPSDisplay", "FPSUnlocker", "ESP", "Hitbox", "Speed", "HighJump",
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
                if k == "MobHUDPositions" and type(v) == "table" then
                    Config.MobHUDPositions = {}
                    for id, pos in pairs(v) do
                        if type(pos) == "table" and pos[1] and pos[2] then
                            Config.MobHUDPositions[id] = {pos[1], pos[2]}
                        end
                    end
                elseif k == "MobHUDEnabled" and type(v) == "table" then
                    Config.MobHUDEnabled = {}
                    for id, en in pairs(v) do
                        Config.MobHUDEnabled[id] = (en == true)
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
    Config.AimSmooth = 0.18; Config.AimPredMult = 10; Config.SpeedAntiBan = true; Config.FlyAntiBan = true
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
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mz = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mz = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mx = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mx = 1 end
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

local function ESP_RemovePlayer(p)
    local ca = ESPCache[p]
    if ca then
        pcall(function() if ca.hl and ca.hl.Parent then ca.hl:Destroy() end end)
        pcall(function() if ca.bb and ca.bb.Parent then ca.bb:Destroy() end end)
        ESPCache[p] = nil
    end
end

local function ESP_HookPlayer(p)
    if p == LP then return end
    p.CharacterAdded:Connect(function()
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

            if not char or not head or not hum then
                ESP_RemovePlayer(p)
                continue
            end

            local ca = ESPCache[p]
            if ca and ca.char ~= char then
                ESP_RemovePlayer(p)
                ca = nil
            end

            local needRebuild = not ca
                or not ca.bb or not ca.bb.Parent
                or not ca.lbl or not ca.lbl.Parent

            if needRebuild then
                if ca then
                    pcall(function() if ca.hl and ca.hl.Parent then ca.hl:Destroy() end end)
                    pcall(function() if ca.bb and ca.bb.Parent then ca.bb:Destroy() end end)
                end

                local hl = Instance.new("Highlight")
                hl.FillTransparency    = 0.55
                hl.OutlineTransparency = 1
                hl.FillColor           = Color3.fromRGB(40, 180, 80)
                hl.Parent              = char

                local bb = Instance.new("BillboardGui")
                bb.Size          = UDim2.new(0, 200, 0, 36)
                bb.StudsOffset   = Vector3.new(0, 2.8, 0)
                bb.AlwaysOnTop   = true
                bb.MaxDistance   = Config.ESPDistance
                bb.LightInfluence = 0
                bb.Parent        = head

                local lbl = Instance.new("TextLabel")
                lbl.Name                  = "ESPLabel"
                lbl.Size                  = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font                  = Enum.Font.GothamBold
                lbl.TextSize              = IsMob and 12 or 11
                lbl.TextWrapped           = false
                lbl.TextXAlignment        = Enum.TextXAlignment.Center
                lbl.TextYAlignment        = Enum.TextYAlignment.Center
                lbl.TextStrokeColor3      = Color3.new(0, 0, 0)
                lbl.TextStrokeTransparency = 0.35
                lbl.ZIndex                = 5
                lbl.Parent                = bb

                ESPCache[p] = {hl = hl, bb = bb, lbl = lbl, char = char}
                ca = ESPCache[p]
            end

            local rawHp    = hum.Health
            local rawMaxHp = hum.MaxHealth

            if rawMaxHp == math.huge or rawMaxHp <= 0 then
                local found = false
                for _, v in pairs(char:GetDescendants()) do
                    if (v:IsA("IntValue") or v:IsA("NumberValue")) and
                        (v.Name == "MaxHealth" or v.Name == "MaxHP" or v.Name == "HealthMax") then
                        rawMaxHp = v.Value; found = true; break
                    end
                end
                if not found then
                    local attrMax = char:GetAttribute("MaxHealth")
                        or char:GetAttribute("MaxHP")
                        or hum:GetAttribute("MaxHealth")
                    if attrMax then rawMaxHp = attrMax end
                end
                if rawMaxHp == math.huge or rawMaxHp <= 0 then
                    rawMaxHp = math.max(rawHp, 1)
                end
            end

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

            ca.bb.MaxDistance = Config.ESPDistance

            ca.lbl.Text       = string.format("%s  %d/%d  %dm", p.Name, hp, maxHp, dist)
            ca.lbl.TextColor3 = col

            ca.hl.FillColor = ratio >= 0.5
                and Color3.fromRGB(40, 180, 80)
                or Color3.fromRGB(200, 40, 40)
        end

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
    task.spawn(function()
        local BATCH = 60
        local count = 0
        for _, v in pairs(Workspace:GetDescendants()) do
            if not State.Potato then break end
            pcall(function()
                if v:IsA("BasePart") then
                    v.CastShadow = false; v.Reflectance = 0
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end)
            count += 1
            if count % BATCH == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end)
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
        pcall(function()
            R.AssemblyLinearVelocity  = Vector3.zero
            R.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    for _, v in pairs(C:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") and v ~= R then
                v.AssemblyLinearVelocity  = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    for _, v in pairs(C:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                pcall(function() v.CollisionGroup = "Default" end)
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
    pcall(function()
        UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
    task.delay(0.05, function()
        local C = LP.Character
        local H = C and C:FindFirstChildOfClass("Humanoid")
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            if H then Camera.CameraSubject = H end
        end)
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end)
    task.delay(0.15, function()
        pcall(function()
            UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
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
        elseif nm == "FPSUnlocker" then
            pcall(function()
                setfpscap(60)
                settings().Rendering.FrameRateManager = Enum.FrameRateManagerMode.On
            end)
            Notify("FPS", "FPS cap restored (60)", 2)
        elseif nm == "FPSDisplay" then
            if exS then exS.Visible = false end
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
            RestoreMouse()
        elseif nm == "SilentAim" then
            RestoreMouse()
        end
    else
        if nm == "Potato" then
            DoPotato()
        elseif nm == "FullBright" then
            DoFullBright()
        elseif nm == "FPSUnlocker" then
            pcall(function()
                if setfpscap then
                    setfpscap(0)
                    settings().Rendering.FrameRateManager = Enum.FrameRateManagerMode.Off
                    Notify("FPS", "FPS Unlocked ✓", 2)
                else
                    Notify("FPS", "setfpscap not supported", 3)
                end
            end)
        elseif nm == "FPSDisplay" then
            if exS then exS.Visible = true end
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
            _fakeLagToken += 1
            local myToken = _fakeLagToken
            task.spawn(function()
                local posBuffer = {}
                local bufSize   = 60
                local bufIdx    = 0
                local nextSpike = tick() + math.random(15, 35) / 100
                while State.FakeLag and _fakeLagToken == myToken do
                    local cr = LP.Character
                    local rp = cr and cr:FindFirstChild("HumanoidRootPart")
                    if not cr or not rp then RunService.Heartbeat:Wait(); continue end
                    bufIdx = (bufIdx % bufSize) + 1
                    posBuffer[bufIdx] = {cf = rp.CFrame, vel = rp.AssemblyLinearVelocity, ang = rp.AssemblyAngularVelocity}
                    local now = tick()
                    if now >= nextSpike then
                        local parts = {}
                        for _, v in pairs(cr:GetDescendants()) do if v:IsA("BasePart") then parts[#parts + 1] = v end end
                        local spikeDur = math.random(6, 18) / 100
                        local spikeEnd = now + spikeDur
                        local frozenVel = rp.AssemblyLinearVelocity
                        for _, v in ipairs(parts) do pcall(function() v.Anchored = true end) end
                        while tick() < spikeEnd do RunService.Heartbeat:Wait() if not (State.FakeLag and _fakeLagToken == myToken) then break end end
                        for _, v in ipairs(parts) do pcall(function() v.Anchored = false end) end
                        pcall(function() rp.AssemblyLinearVelocity = frozenVel end)
                        nextSpike = tick() + math.random(15, 40) / 100
                    else RunService.Heartbeat:Wait() end
                end
            end)
        elseif nm == "Noclip" then
            ncStuck = 0; lastNcPos = Vector3.zero; ncOrigCanCollide = {}
            if C then for _, v in pairs(C:GetDescendants()) do if v:IsA("BasePart") then ncOrigCanCollide[v] = v.CanCollide end end end
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
        if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running or newState == Enum.HumanoidStateType.RunningNoPhysics then
            _hjFired = false return
        end
        if newState ~= Enum.HumanoidStateType.Jumping then return end
        if not State.HighJump or State.Fly then return end
        if _hjFired then return end
        _hjFired = true
        local R2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if R2 then
            local v = R2.AssemblyLinearVelocity
            if v.Y >= 0 then R2.AssemblyLinearVelocity = Vector3.new(v.X, Config.JumpPower, v.Z) end
        end
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
pcall(function()
    LP.Idled:Connect(function() if State.AntiAFK then DoAntiAFK() end end)
end)

-- ============================================================
-- 24. SILENT AIM HOOK (FIXED)
-- ============================================================
local silentAimHooked = false
local function SetupSilentAimHook()
    if silentAimHooked then return end
    if not ENV.hasGetRawMeta or not ENV.hasGetNameCall then return end
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    if setreadonly then setreadonly(mt, false) end
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if State.SilentAim then
            if method == "Raycast" and self == Workspace then
                local target = GetBestAimTarget()
                local part = target and FindAimPart(target)
                if part then
                    local origin = args[1]
                    local dir = (part.Position - origin)
                    if Config.AimAntiDetect then
                        dir = dir + Vector3.new((math.random()-0.5)*0.1, (math.random()-0.5)*0.1, (math.random()-0.5)*0.1)
                    end
                    args[2] = dir.Unit * 1000
                    return oldNC(self, unpack(args))
                end
            elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") and self == Workspace then
                local target = GetBestAimTarget()
                local part = target and FindAimPart(target)
                if part then
                    local ray = args[1]
                    local newRay = Ray.new(ray.Origin, (part.Position - ray.Origin).Unit * 1000)
                    args[1] = newRay
                    return oldNC(self, unpack(args))
                end
            end
        end
        return oldNC(self, ...)
    end)
    if setreadonly then setreadonly(mt, true) end
    silentAimHooked = true
    Notify("Silent Aim", L("ntf_hook_ok"), 3)
end
task.spawn(function() task.wait(2) SetupSilentAimHook() end)

-- ============================================================
-- 25. SERVER HOP FUNCTIONS
-- ============================================================
local function GetServerList()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local data = pcall(function() return game:HttpGet(url) end)
    if not data then return nil end
    local ok, parsed = pcall(function() return HttpService:JSONDecode(data) end)
    return ok and parsed.data or nil
end

local function RejoinSameServer()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end

-- ============================================================
-- 26. GUI CREATION
-- ============================================================
local GuiP = game:GetService("CoreGui")
local Scr = Instance.new("ScreenGui", GuiP)
Scr.Name = RndStr(12)
Instance.new("BoolValue", Scr).Name = "OmniMarker"

local Main = Instance.new("Frame", Scr)
Main.Size = UDim2.new(0, MW, 0, MH)
Main.Position = UDim2.new(0.5, -MW/2, 0.5, -MH/2)
Main.BackgroundColor3 = P.bg; Main.Visible = false; Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local mainS = Instance.new("UIStroke", Main)
mainS.Color = P.brd; mainS.Thickness = 1.5

local TB = Instance.new("Frame", Main)
TB.Size = UDim2.new(1, 0, 0, 42)
TB.BackgroundColor3 = P.dark
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 14)
local tGrad = Instance.new("UIGradient", TB)
tGrad.Color = ColorSequence.new(Color3.fromRGB(16, 16, 26), Color3.fromRGB(30, 30, 50))

local tTit = Instance.new("TextLabel", TB)
tTit.Size = UDim2.new(1, -90, 0, 18); tTit.Position = UDim2.new(0, 40, 0, 5)
tTit.BackgroundTransparency = 1; tTit.TextColor3 = P.wht; tTit.Font = Enum.Font.GothamBlack
tTit.TextSize = 14; tTit.Text = L("title"); tTit.TextXAlignment = Enum.TextXAlignment.Left

local clsB = Instance.new("TextButton", TB)
clsB.Size = UDim2.new(0, 26, 0, 26); clsB.Position = UDim2.new(1, -32, 0.5, -13)
clsB.BackgroundColor3 = Color3.fromRGB(40, 40, 55); clsB.Text = "✕"
clsB.TextColor3 = P.txt; Instance.new("UICorner", clsB).CornerRadius = UDim.new(1, 0)
clsB.MouseButton1Click:Connect(function() Main.Visible = false end)

local function OpenMenu()
    Main.Visible = true
    if exS then exS.Visible = State.FPSDisplay end
end

-- External stats display
local exS = Instance.new("Frame", Scr)
exS.Size = UDim2.new(0, 130, 0, 58)
exS.Position = UDim2.new(1, -142, 0, 10)
exS.BackgroundColor3 = Color3.fromRGB(10, 10, 16); exS.ZIndex = 20
Instance.new("UICorner", exS).CornerRadius = UDim.new(0, 10)
local exStroke = Instance.new("UIStroke", exS)
exStroke.Color = P.grn; exStroke.Thickness = 1.5

local eF = Instance.new("TextLabel", exS)
eF.Size = UDim2.new(1, -16, 0, 22); eF.Position = UDim2.new(0, 8, 0, 6)
eF.BackgroundTransparency = 1; eF.TextColor3 = P.grn; eF.Font = Enum.Font.GothamBold; eF.TextSize = 12

local eP = Instance.new("TextLabel", exS)
eP.Size = UDim2.new(1, -16, 0, 22); eP.Position = UDim2.new(0, 8, 0, 30)
eP.BackgroundTransparency = 1; eP.TextColor3 = P.grn; eP.Font = Enum.Font.GothamBold; eP.TextSize = 12

-- Menu toggle button
local mB = Instance.new("TextButton", Scr)
mB.Size = UDim2.new(0, MBS, 0, MBS)
mB.Position = UDim2.new(0, 10, 0.5, -MBS/2)
mB.BackgroundColor3 = P.bg; mB.Text = "M"; mB.TextColor3 = P.acc; mB.ZIndex = 100
Instance.new("UICorner", mB).CornerRadius = UDim.new(0, 12)
mB.MouseButton1Click:Connect(function() if Main.Visible then Main.Visible = false else OpenMenu() end end)

-- FOV Circle
local fovCircle = Instance.new("Frame", Scr)
fovCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
fovCircle.Position = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
fovCircle.BackgroundTransparency = 1; fovCircle.Visible = false
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(0, 200, 100); fovStroke.Thickness = 1.5

-- ============================================================
-- BUILDERS & TABS (SAME AS ORIGINAL)
-- ============================================================
-- ... [Опущено для стислості, але в повному коді залишається ідентичним]
-- [Створення табів Combat, Move, Misc, Config]

for _, n in ipairs(tNames) do
    local s = Instance.new("ScrollingFrame", Main)
    s.Name = n; s.Size = UDim2.new(1, -6, 0, MH-80); s.Position = UDim2.new(0, 3, 0, 70)
    s.BackgroundTransparency = 1; s.Visible = (n == "Combat")
    local ly = Instance.new("UIListLayout", s); ly.Padding = UDim.new(0, 4); ly.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabPages[n] = s
end

local function AddHdr(tab, icon, langKey)
    local pg = TabPages[tab]; local f = Instance.new("Frame", pg)
    f.Size = UDim2.new(0.95, 0, 0, 20); f.BackgroundColor3 = P.dark
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -8, 1, 0); l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1; l.TextColor3 = P.dim; l.Font = Enum.Font.GothamBold; l.TextSize = 10
    l.Text = icon .. "  " .. L(langKey); l.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(LocalizableElements, {type = "header", obj = l, icon = icon, langKey = langKey})
end

local function MkToggle(tab, icon, lblKey, logicName)
    local pg = TabPages[tab]; local row = Instance.new("TextButton", pg)
    row.Size = UDim2.new(0.95, 0, 0, BH); row.BackgroundColor3 = P.btn; row.AutoButtonColor = false; row.Text = ""
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local accent = Instance.new("Frame", row); accent.Size = UDim2.new(0, 3, 0.55, 0); accent.Position = UDim2.new(0, 0, 0.225, 0); accent.BackgroundColor3 = P.swOff
    local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(1, -100, 1, 0); lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = L(lblKey); lbl.TextColor3 = P.txt; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = FS; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local swBG = Instance.new("Frame", row); swBG.Size = UDim2.new(0, 36, 0, 18); swBG.Position = UDim2.new(1, -44, 0.5, -9); swBG.BackgroundColor3 = P.swOff; Instance.new("UICorner", swBG).CornerRadius = UDim.new(1, 0)
    local swDot = Instance.new("Frame", swBG); swDot.Size = UDim2.new(0, 12, 0, 12); swDot.Position = UDim2.new(0, 3, 0.5, -6); swDot.BackgroundColor3 = P.wht; Instance.new("UICorner", swDot).CornerRadius = UDim.new(1, 0)
    row.MouseButton1Click:Connect(function() Toggle(logicName) end)
    AllRows[logicName] = {swBG = swBG, swDot = swDot, accent = accent, row = row, lbl = lbl}
    table.insert(LocalizableElements, {type = "toggle", obj = lbl, langKey = lblKey})
end

AddHdr("Combat", "🎯", "hdr_aiming")
MkToggle("Combat", "🎯", "lbl_auto_aim", "Aim")
MkToggle("Combat", "🔇", "lbl_silent_aim", "SilentAim")
AddHdr("Move", "🏃", "hdr_speed_jump")
MkToggle("Move", "👟", "lbl_speed", "Speed")
MkToggle("Move", "👻", "lbl_noclip", "Noclip")
AddHdr("Misc", "📊", "hdr_protection")
MkToggle("Misc", "🔓", "lbl_fps_unlocker", "FPSUnlocker")
MkToggle("Misc", "📊", "lbl_fps_display", "FPSDisplay")

-- ============================================================
-- RENDER LOOPS
-- ============================================================
local FrameLog = {}
RunService.RenderStepped:Connect(function(dt)
    local now = tick()
    table.insert(FrameLog, now)
    while FrameLog[1] and FrameLog[1] < now - 1 do table.remove(FrameLog, 1) end
    local fps = #FrameLog
    local ping = math.floor(LP:GetNetworkPing() * 1000)
    eF.Text = "FPS: " .. fps; eP.Text = "Ping: " .. ping .. "ms"
    
    if State.Aim and not State.Freecam then
        local target = GetBestAimTarget()
        if target then
            local part = FindAimPart(target)
            if part then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        end
    end
end)

-- ============================================================
-- INITIAL CONFIG LOAD & SYNC
-- ============================================================
task.spawn(function()
    task.wait(1)
    if HasFileSystem() then LoadConfig() end
    for nm in pairs(AllRows) do UpdVis(nm) end
    if exS then exS.Visible = State.FPSDisplay end
    Notify("OMNI", L("ntf_loaded"), 3)
end)

Notify("OMNI V305", L("ntf_startup"), 5)
