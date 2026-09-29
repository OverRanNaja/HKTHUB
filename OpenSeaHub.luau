--[[
    ==============================================================================
    2K SCRIPT — OPEN SEA FOR ANIMALS (เปิดทะเลล่าสัตว์เทพ)
    Edition: Pro Progression & Remote Automation Hub
    Discord: https://discord.gg/4Yg72kYT6s
    Theme: 2K Frost Glassmorphism | Cyber Neon 2K Logo Button
    Features:
      - Auto Sea Wave Sniping (Remote Packet Sniping - Best Item Instant Retrieve)
      - Priority Targeting: Best Overall, Eggs Only, Animals Only, Mutations Only
      - Auto Place Eggs on Plot & Auto Hatch when ready
      - Auto Place Animals & Auto Equip Best
      - Auto Collect Offline Cash
      - Auto Infinite Power Training (Dumbbell)
      - Auto Buy & Equip Best Dumbbell
      - Auto Buy & Equip Best Staff / Pickaxe
      - Auto Upgrade Character & Plot (PlotUpgrade, MovementSpeed, Carry)
      - Auto Rebirth with target level threshold & precondition cash check
      - Auto Claim Freebies (Playtime Gifts 1-12, Daily/VIP, Free Shop, Spin Wheel, Group)
      - Multi-layer Anti-AFK (Disable map kickers, block teleport kicks, hardware F15 heartbeat)
      - Full JSON Config System (Save, Load, Auto-load at boot, Delete)
      - Teleports to Plot, Sea Edge, Dumbbell Shop, Staff Shop
      - Cyber Neon 2K Mini Draggable Button with LED Pulse
    ==============================================================================
]]

-- ── 1. STRICT AUTO-CLEANUP ───────────────────────────────────────────────────────
if _G.OpenSeaCleanup then pcall(_G.OpenSeaCleanup) end
if _G.OpenSeaWindow and _G.OpenSeaWindow.Destroy then pcall(function() _G.OpenSeaWindow:Destroy() end) end
if _G.OpenSeaMinGui then pcall(function() _G.OpenSeaMinGui:Destroy() end) end
_G.OpenSeaRunning = false

-- Clean up any stuck Acrylic 3D glass models and DepthOfField effects
pcall(function()
    local cam = workspace.CurrentCamera
    if cam then
        for _, child in ipairs(cam:GetChildren()) do
            if child.Name:find("Acrylic") or child.Name:find("DepthOfField") or (child:IsA("Model") and child:FindFirstChildOfClass("MeshPart")) then
                pcall(function() child:Destroy() end)
            end
        end
    end
    local lighting = game:GetService("Lighting")
    for _, child in ipairs(lighting:GetChildren()) do
        if child:IsA("DepthOfFieldEffect") and child.InFocusRadius == 0.1 then
            pcall(function() child:Destroy() end)
        end
    end
end)

-- Immediate Dumbbell & Training Cleanup on Re-run
pcall(function()
    local char = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character
    if char then
        char:SetAttribute("DumbbellModel", nil)
        char:SetAttribute("IsTrainingLocal", nil)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                local nm = t.Name:lower()
                local id = (t.Animation and t.Animation.AnimationId or ""):lower()
                if nm:find("train") or nm:find("dumb") or id:find("train") or id:find("dumb") then
                    t:Stop()
                end
            end
            if hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
        end
    end
    if game:GetService("Players").LocalPlayer then
        game:GetService("Players").LocalPlayer:SetAttribute("IsTrainingLocal", nil)
    end
end)

-- Purge any leftover duplicate ScreenGuis in CoreGui & gethui
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local gethui = gethui or function() return CoreGui end
    local targets = { CoreGui, gethui() }
    for _, parent in ipairs(targets) do
        if parent then
            for _, c in ipairs(parent:GetChildren()) do
                if c:IsA("ScreenGui") and (c.Name == "ScreenGui" or c.Name == "OpenSeaMiniButton_2K" or c.Name == "Fluent") then
                    local isOurGui = false
                    if c.Name == "OpenSeaMiniButton_2K" then
                        isOurGui = true
                    else
                        for _, desc in ipairs(c:GetDescendants()) do
                            if desc:IsA("TextLabel") and (string.find(desc.Text, "2K") or string.find(desc.Text, "STATUS DASHBOARD") or string.find(desc.Text, "ล่าสัตว์ในทะเล") or string.find(desc.Text, "Open Sea")) then
                                isOurGui = true
                                break
                            end
                        end
                    end
                    if isOurGui then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
    end
end)

local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local RS                = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local thisRunId         = HttpService:GenerateGUID(false)
_G.OpenSeaRunId         = thisRunId
_G.OpenSeaRunning       = true

local _conns = {}
_G.OpenSeaCleanup = function()
    _G.OpenSeaRunning = false
    _G.OpenSeaRunId   = nil
    for _, c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    table.clear(_conns)
    if _G.OpenSeaWindow and _G.OpenSeaWindow.Destroy then
        pcall(function() _G.OpenSeaWindow:Destroy() end)
        _G.OpenSeaWindow = nil
    end
    if _G.OpenSeaMinGui then
        pcall(function() _G.OpenSeaMinGui:Destroy() end)
        _G.OpenSeaMinGui = nil
    end
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            for _, child in ipairs(cam:GetChildren()) do
                if child.Name:find("Acrylic") or child.Name:find("DepthOfField") or (child:IsA("Model") and child:FindFirstChildOfClass("MeshPart")) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
        local lighting = game:GetService("Lighting")
        for _, child in ipairs(lighting:GetChildren()) do
            if child:IsA("DepthOfFieldEffect") and (child.InFocusRadius == 0.1 or child.Name:find("Acrylic")) then
                pcall(function() child:Destroy() end)
            end
        end
    end)
    pcall(function()
        local char = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character
        if char then
            char:SetAttribute("DumbbellModel", nil)
            char:SetAttribute("IsTrainingLocal", nil)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
        end
        if game:GetService("Players").LocalPlayer then
            game:GetService("Players").LocalPlayer:SetAttribute("IsTrainingLocal", nil)
        end
    end)
end

-- ── 2. SERVICES, KNIT & REPLICATED STORAGE ───────────────────────────────────────
local LP = Players.LocalPlayer
while not LP do
    task.wait(0.05)
    LP = Players.LocalPlayer
end

-- Universal safeRequire: handles CoreScript/RobloxScript security context bypass
local function safeRequire(moduleObj)
    if not moduleObj then return nil end
    local ok, res

    -- Method 1: If running at thread identity 3 (RobloxScript), switch to 2 (LocalScript) temporarily
    local setIdent = setthreadidentity or setthreadcontext or (syn and syn.set_thread_identity)
    local getIdent = getthreadidentity or getthreadcontext or (syn and syn.get_thread_identity)
    local oldIdent = nil
    if getIdent and setIdent then
        pcall(function()
            oldIdent = getIdent()
            setIdent(2)
        end)
    end

    ok, res = pcall(require, moduleObj)

    if oldIdent and setIdent then
        pcall(setIdent, oldIdent)
    end

    if ok and res ~= nil then return res end

    -- Method 2: Use getrenv().require (native Roblox LocalScript require)
    if getrenv and getrenv().require then
        local okEnv, resEnv = pcall(getrenv().require, moduleObj)
        if okEnv and resEnv ~= nil then return resEnv end
    end

    -- Method 3: Direct pcall require
    ok, res = pcall(require, moduleObj)
    if ok and res ~= nil then return res end

    return nil
end

local Knit = nil
pcall(function()
    local knitPkg = RS:WaitForChild("Packages", 5) and RS.Packages:FindFirstChild("Knit")
    if knitPkg then
        Knit = safeRequire(knitPkg)
    end
end)

-- Fallback: Scan Lua heap (getgc) if require is blocked by executor
if not Knit and getgc then
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "GetController") and rawget(v, "GetService") then
                Knit = v
                break
            end
        end
    end)
end

local KnitServicesFolder = RS:WaitForChild("Packages"):WaitForChild("_Index"):FindFirstChild("sleitnick_knit@1.7.0")
    and RS.Packages._Index["sleitnick_knit@1.7.0"].knit:FindFirstChild("Services")

local function getServiceWrapper(sName)
    local knitProxy = nil
    if Knit and Knit.GetService then
        pcall(function() knitProxy = Knit.GetService(sName) end)
    end
    local sFolder = KnitServicesFolder and KnitServicesFolder:FindFirstChild(sName)
    local rfFolder = sFolder and sFolder:FindFirstChild("RF")
    local reFolder = sFolder and sFolder:FindFirstChild("RE")

    local wrapper = { RF = {}, RE = {} }

    setmetatable(wrapper, {
        __index = function(_, key)
            if knitProxy and knitProxy[key] then
                return function(self, ...)
                    return knitProxy[key](knitProxy, ...)
                end
            end
            if rfFolder and rfFolder:FindFirstChild(key) then
                return function(self, ...)
                    return rfFolder[key]:InvokeServer(...)
                end
            end
            if reFolder and reFolder:FindFirstChild(key) then
                return function(self, ...)
                    return reFolder[key]:FireServer(...)
                end
            end
            return nil
        end
    })

    if rfFolder then
        setmetatable(wrapper.RF, {
            __index = function(_, key)
                local rf = rfFolder:FindFirstChild(key)
                return rf
            end
        })
    end

    if reFolder then
        setmetatable(wrapper.RE, {
            __index = function(_, key)
                local re = reFolder:FindFirstChild(key)
                return re
            end
        })
    end

    return wrapper
end

local WaveService            = getServiceWrapper("WaveService")
local EggService             = getServiceWrapper("EggService")
local AnimalService          = getServiceWrapper("AnimalService")
local TrainingService        = getServiceWrapper("TrainingService")
local PickaxeService         = getServiceWrapper("PickaxeService")
local UpgradesService        = getServiceWrapper("UpgradesService")
local RebirthService         = getServiceWrapper("RebirthService")
local PlaytimeRewardService  = getServiceWrapper("PlaytimeRewardService")
local DailyRewardService     = getServiceWrapper("DailyRewardService")
local FreeShopService        = getServiceWrapper("FreeShopService")
local SpinWheelService       = getServiceWrapper("SpinWheelService")
local RewardService          = getServiceWrapper("RewardService")
local PlotService            = getServiceWrapper("PlotService")
local InventoryService       = getServiceWrapper("InventoryService")
local SeasonPassService      = getServiceWrapper("SeasonPassService")
local QuestService           = getServiceWrapper("QuestService")
local PotionService          = getServiceWrapper("PotionService")
local CodesService           = getServiceWrapper("CodesService")
local GiftingService         = getServiceWrapper("GiftingService")
local CollectEventService    = getServiceWrapper("CollectEventService")

local ReplicaController      = nil
local TrainingController     = nil
local WaveController         = nil
local PickupController       = nil
local GiftPopupController    = nil
local PlaytimeRewardController = nil

if Knit and Knit.GetController then
    pcall(function() ReplicaController = Knit.GetController("ReplicaController") end)
    pcall(function() TrainingController = Knit.GetController("TrainingController") end)
    pcall(function() WaveController = Knit.GetController("WaveController") end)
    pcall(function() PickupController = Knit.GetController("PickupController") end)
    pcall(function() GiftPopupController = Knit.GetController("GiftPopupController") end)
    pcall(function() PlaytimeRewardController = Knit.GetController("PlaytimeRewardController") end)
end

-- Fallback for controllers from getgc if Knit wasn't accessible
if getgc then
    if not ReplicaController then
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "GetPlayerData") then
                    ReplicaController = v
                    break
                end
            end
        end)
    end
    if not WaveController then
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "GetWaveIndex") then
                    WaveController = v
                    break
                end
            end
        end)
    end
end

local CollectEventConfig     = nil
pcall(function() CollectEventConfig = safeRequire(RS.Configs:FindFirstChild("CollectEventConfig")) end)
local TrainToolConfig        = nil
pcall(function() TrainToolConfig = safeRequire(RS.Configs:FindFirstChild("TrainToolConfig")) end)
local StaffConfig            = nil
pcall(function() StaffConfig = safeRequire(RS.Configs:FindFirstChild("StaffConfig")) end)
local UpgradeConfig          = nil
pcall(function() UpgradeConfig = safeRequire(RS.Configs:FindFirstChild("UpgradeConfig")) end)
local RebirthConfig          = nil
pcall(function() RebirthConfig = safeRequire(RS.Configs:FindFirstChild("RebirthConfig")) end)
local PlaytimeRewardConfig   = nil
pcall(function() PlaytimeRewardConfig = safeRequire(RS.Configs:FindFirstChild("PlaytimeRewardConfig")) end)
local FreeShopConfig         = nil
pcall(function() FreeShopConfig = safeRequire(RS.Configs:FindFirstChild("FreeShopConfig")) end)
local SpinWheelConfig        = nil
pcall(function() SpinWheelConfig = safeRequire(RS.Configs:FindFirstChild("SpinWheelConfig")) end)
local SeasonPassConfig       = nil
pcall(function() SeasonPassConfig = safeRequire(RS.Configs:FindFirstChild("SeasonPassConfig")) end)
local PotionsConfig          = nil
pcall(function() PotionsConfig = safeRequire(RS.Configs:FindFirstChild("PotionsConfig")) end)
local Modifiers              = nil
pcall(function() Modifiers = safeRequire(RS:FindFirstChild("Modifiers")) end)
local PlotUtils              = nil
pcall(function() PlotUtils = safeRequire(RS.GameShared:FindFirstChild("PlotUtils")) end)
local AbbreviationUtils      = nil
pcall(function() AbbreviationUtils = safeRequire(RS.Shared:FindFirstChild("AbbreviationUtils")) end)

-- ── 3. STATE & SETTINGS ──────────────────────────────────────────────────────────
local State = {
    -- Sea Wave & Egg Farming
    AutoWave            = false,
    MinEggRarity        = "ทุกระดับ (All Eggs - Common+)",
    SpecificEgg         = "ทั้งหมด (All Available)",
    EggMutationFilter   = { ["ทั้งหมด (All Status)"] = true },
    PrioritizeMutations = false,
    WaveDelay           = 2,
    AutoHatchEggs       = false,
    AutoSellSpecificEgg = false,
    SellEggRarity       = { ["ทุกระดับ Common - Rare"] = true },
    SellTargetEgg       = { ["ทุกระดับ Common - Rare"] = true },
    AutoEquipBest       = false,
    AutoSellAnimals     = false,
    AutoHuntEventBoss   = false,
    AutoCollectStars    = false,
    ShowStarEventHud    = false,
    AutoOfflineCash     = false,

    -- Bulk Trading & Gifting
    AutoBulkTrade       = false,
    AutoAcceptGifts     = false,
    TradeTargetPlayer   = "",
    TradeFilterAnimals  = { ["ทั้งหมด (All Animals)"] = true },
    TradeFilterAnimal   = "ทั้งหมด (All Animals)",
    TradeQuantity       = 10,
    TradeSpeedDelay     = 0.05,
    TradeInstantBurst   = false,

    -- Power & Gear
    AutoTrain           = false,
    AutoClaimBonus      = false,
    AutoBuyDumbbell     = false,
    AutoBuyStaff        = false,

    -- Upgrades & Rebirth
    AutoUpgradePlot     = false,
    AutoUpgradeSpeed    = false,
    AutoUpgradeCarry    = false,
    AutoRebirth         = false,
    TargetRebirth       = "ไม่จำกัด / สูงสุดตลอดเวลา",

    -- Free Rewards, Quests & Potions
    AutoPlaytimeGifts   = false,
    AutoDailyRewards    = false,
    AutoFreeShop        = false,
    AutoSpinWheel       = false,
    AutoGroupReward     = false,
    AutoSeasonPass      = false,
    AutoQuests          = false,
    AutoUsePotions      = false,
    AutoUseTrainPotion  = false,
    AutoUseCashPotion   = false,
    AutoUseLuckPotion   = false,

    -- Misc & Player Physics
    AntiAFK             = true,
    FPSBoost            = false,
    CustomSpeedEnabled  = false,
    CustomSpeedValue    = 46,
    CustomJumpEnabled   = false,
    CustomJumpValue     = 50,
    InfiniteJump        = false,
    Noclip              = false,

    -- Config
    SelectedConfig      = "",
    AutoLoadConfig      = false,
}
_G.OpenSeaState = State

local UIControls = {}

-- ── 4. UTILITY FUNCTIONS ─────────────────────────────────────────────────────────
local function getMyPlotModel()
    if PlotUtils and PlotUtils.GetPlayerPlot then
        local p = PlotUtils.GetPlayerPlot(LP)
        if p then return p end
    end
    local ok, plotId = pcall(function()
        return PlotService.RF.GetMyPlotId:InvokeServer()
    end)
    if ok and plotId then
        local p = workspace:WaitForChild("Plots"):FindFirstChild(tostring(plotId))
        if p then
            local inner = p:FindFirstChild(tostring(plotId))
            if inner then return inner end
            return p
        end
    end
    -- Fallback scan
    for _, p in ipairs(workspace.Plots:GetChildren()) do
        if p:GetAttribute("Owner") == LP.UserId then
            local m = p:FindFirstChild(p.Name)
            if m then return m end
            return p
        end
    end
    return nil
end

local function getMyPlotSurface()
    local plot = getMyPlotModel()
    if plot then
        return plot:FindFirstChild("PlotSurface", true)
    end
    return nil
end

local function safeTeleport(cframe)
    pcall(function()
        local char = LP.Character
        if char and char.PrimaryPart then
            char:PivotTo(cframe)
        end
    end)
end

local function clearNotificationSpam()
    pcall(function()
        local notifList = LP.PlayerGui:FindFirstChild("NotificationGui") and LP.PlayerGui.NotificationGui:FindFirstChild("NotificationList")
        if notifList then
            for _, c in ipairs(notifList:GetChildren()) do
                if c:IsA("GuiObject") and c.Name ~= "UIListLayout" and c.Name ~= "UIPadding" and not c.Name:lower():find("template") then
                    local lbl = c:FindFirstChildOfClass("TextLabel")
                    if lbl and (lbl.Text:find("maximum") or lbl.Text:find("already claimed") or lbl.Text:find("wait a little bit") or lbl.Text:find("offline")) then
                        c.Visible = false
                    end
                end
            end
        end
    end)
end

-- ── 5. CORE AUTOMATION LOGIC ─────────────────────────────────────────────────────

local EggRarityRanks = {
    ["Common"]    = 1,
    ["Uncommon"]  = 2,
    ["Rare"]      = 3,
    ["Epic"]      = 4,
    ["Legendary"] = 5,
    ["Mythic"]    = 6,
    ["Divine"]    = 7,
    ["Secret"]    = 8,
    ["Cosmic"]    = 9,
    ["Eternal"]   = 10,
    ["SPECIAL"]   = 11,
    ["CYBER"]     = 12,
    ["LAW"]       = 13,
    ["Titanium"]  = 14,
    ["Magical"]   = 15,
    ["Nightfall"] = 16,
    ["Frosty"]    = 17,
    ["Lightning"] = 18,
}

local EggToRarity = {
    ["basic_egg"]     = "Common",
    ["frogs_egg"]     = "Uncommon",
    ["bats_egg"]      = "Rare",
    ["tigers_egg"]    = "Epic",
    ["trex_egg"]      = "Legendary",
    ["snails_egg"]    = "Mythic",
    ["capybara_egg"]  = "Divine",
    ["osctrich_egg"]  = "Secret",
    ["snake_egg"]     = "Cosmic",
    ["sphinx_egg"]    = "Eternal",
    ["mouse_egg"]     = "Eternal",
    ["dragon_egg"]    = "SPECIAL",
    ["polarbear_egg"] = "SPECIAL",
    ["seal_egg"]      = "SPECIAL",
    ["gorilla_egg"]   = "CYBER",
    ["mamut_egg"]     = "LAW",
    ["ocean_egg"]     = "Titanium",
    ["deer_egg"]      = "Magical",
    ["sleepy_egg"]    = "Nightfall",
    ["glacial_egg"]   = "Frosty",
    ["volt_egg"]      = "Lightning",
    ["flame_egg"]     = "SPECIAL",
    ["angelic_egg"]   = "SPECIAL",
    ["unicorn_egg"]   = "SPECIAL",
    ["talon_egg"]     = "SPECIAL",
    ["magician_egg"]  = "SPECIAL",
    ["la_everything_egg"] = "Secret",
}

local MinRarityThresholds = {
    ["ทุกระดับ (All Eggs - Common+)"]        = 1,
    ["Uncommon ขึ้นไป (Frog+)"]              = 2,
    ["Rare ขึ้นไป (Bat+)"]                  = 3,
    ["Epic ขึ้นไป (Tiger+)"]                = 4,
    ["Legendary ขึ้นไป (Trex+)"]            = 5,
    ["Mythic ขึ้นไป (Snails+)"]             = 6,
    ["Divine ขึ้นไป (Capybara+)"]           = 7,
    ["Secret ขึ้นไป (Ostrich+)"]            = 8,
    ["Cosmic ขึ้นไป (Snake+)"]              = 9,
    ["Eternal ขึ้นไป (Sphinx+)"]            = 10,
    ["SPECIAL ขึ้นไป (Dragon / Polarbear+)"] = 11,
    ["CYBER ขึ้นไป (Gorilla+)"]             = 12,
    ["LAW ขึ้นไป (Mamut+)"]                 = 13,
    ["Titanium ขึ้นไป (Ocean+)"]            = 14,
    ["Magical ขึ้นไป (Corals+)"]            = 15,
    ["Nightfall ขึ้นไป (Sleepy+)"]          = 16,
    ["Frosty ขึ้นไป (Glacial+)"]            = 17,
    ["Lightning ขึ้นไป (Volt+)"]            = 18,
}

local EggNameMapping = {
    ["Basic Egg"]          = "basic_egg",
    ["Frog Egg"]           = "frogs_egg",
    ["Bat Egg"]            = "bats_egg",
    ["Tiger Egg"]          = "tigers_egg",
    ["Trex Egg"]           = "trex_egg",
    ["Snails Egg"]         = "snails_egg",
    ["Capybara Egg"]       = "capybara_egg",
    ["Osctrich Egg"]       = "osctrich_egg",
    ["Snake Egg"]          = "snake_egg",
    ["Sphinx Egg"]         = "sphinx_egg",
    ["Dragon Egg"]         = "dragon_egg",
    ["Mouse Egg"]          = "mouse_egg",
    ["Polarbear Egg"]      = "polarbear_egg",
    ["Seal Egg"]           = "seal_egg",
    ["Gorilla Egg"]        = "gorilla_egg",
    ["Mamut Egg"]          = "mamut_egg",
    ["Ocean Egg"]          = "ocean_egg",
    ["Corals Egg"]         = "deer_egg",
    ["Sleepy Egg"]         = "sleepy_egg",
    ["Glacial Egg"]        = "glacial_egg",
    ["Volt Egg"]           = "volt_egg",
    ["Flame Egg"]          = "flame_egg",
    ["Angelic Egg"]        = "angelic_egg",
    ["Unicorn Egg"]        = "unicorn_egg",
    ["Talon Egg"]          = "talon_egg",
    ["Magician Egg"]       = "magician_egg",
    ["La Everything Egg"]  = "la_everything_egg",
}

local ALL_EGG_DISPLAY_NAMES = {
    "Basic Egg",
    "Frog Egg",
    "Bat Egg",
    "Tiger Egg",
    "Trex Egg",
    "Snails Egg",
    "Capybara Egg",
    "Osctrich Egg",
    "Snake Egg",
    "Sphinx Egg",
    "Dragon Egg",
    "Mouse Egg",
    "Polarbear Egg",
    "Seal Egg",
    "Gorilla Egg",
    "Mamut Egg",
    "Ocean Egg",
    "Corals Egg",
    "Sleepy Egg",
    "Glacial Egg",
    "Volt Egg",
    "Flame Egg",
    "Angelic Egg",
    "Unicorn Egg",
    "Talon Egg",
    "Magician Egg",
    "La Everything Egg"
}

-- 1. Wave Egg Sniping & Teleport Collector
local function isMutationMatching(mutFilter, mutation)
    if not mutFilter then return true end
    if type(mutFilter) == "string" then
        if mutFilter == "ทั้งหมด (All Status)" then return true end
        if mutFilter == "เฉพาะตัวกลายพันธุ์ (Any Mutation)" then
            return (mutation and mutation ~= "NORMAL")
        elseif mutFilter == "Normal (ธรรมดา)" then
            return (not mutation or mutation == "NORMAL")
        elseif mutFilter == "Gold (ทอง)" then
            return (mutation == "GOLD")
        elseif mutFilter == "Diamond (เพชร)" then
            return (mutation == "DIAMOND")
        elseif mutFilter == "Radioactive (กัมมันตรังสี)" then
            return (mutation == "RADIOACTIVE")
        elseif mutFilter == "Rainbow (สายรุ้ง)" then
            return (mutation == "RAINBOW")
        end
        return true
    elseif type(mutFilter) == "table" then
        local hasAny = false
        for k, v in pairs(mutFilter) do
            if v == true or type(k) == "number" then
                hasAny = true
                local opt = (type(k) == "string" and v == true) and k or tostring(v)
                if opt == "ทั้งหมด (All Status)" then return true end
                if opt == "เฉพาะตัวกลายพันธุ์ (Any Mutation)" and (mutation and mutation ~= "NORMAL") then
                    return true
                elseif opt == "Normal (ธรรมดา)" and (not mutation or mutation == "NORMAL") then
                    return true
                elseif opt == "Gold (ทอง)" and (mutation == "GOLD") then
                    return true
                elseif opt == "Diamond (เพชร)" and (mutation == "DIAMOND") then
                    return true
                elseif opt == "Radioactive (กัมมันตรังสี)" and (mutation == "RADIOACTIVE") then
                    return true
                elseif opt == "Rainbow (สายรุ้ง)" and (mutation == "RAINBOW") then
                    return true
                end
            end
        end
        if not hasAny then return true end
        return false
    end
    return true
end

local isSnipingWave = false
local function runWaveSniping()
    if not State.AutoWave or isSnipingWave then return end
    if not WaveService then return end
    if LP:GetAttribute("IsWaveActive") then return end

    local char = LP.Character
    if not char or not char.PrimaryPart then return end

    isSnipingWave = true
    task.spawn(function()
        pcall(function()
            -- Pure Silent Packet Sniping Mode
            local ok, res = pcall(function()
                return WaveService.RF.Start:InvokeServer(5)
            end)
            if ok and res and res.spawns then
                local spawns = res.spawns
                local bestId = nil
                local bestScore = -1
                local minRank = MinRarityThresholds[State.MinEggRarity] or 1
                local specificId = EggNameMapping[State.SpecificEgg]
                local mutFilter = State.EggMutationFilter or "ทั้งหมด (All Status)"
                if UIControls.EggMutationFilter and UIControls.EggMutationFilter.Value then
                    mutFilter = UIControls.EggMutationFilter.Value
                end

                for id, sData in pairs(spawns) do
                    local entity = sData.entity or {}
                    local eggType = entity.eggType
                    if eggType then
                        local rarityName = EggToRarity[eggType] or "Common"
                        local rank = EggRarityRanks[rarityName] or 1
                        local mutation = entity.mutation
                        local size = entity.size
                        local isBoss = (sData.bossId ~= nil) or (eggType == "dragon_egg" or eggType == "polarbear_egg" or eggType == "mouse_egg" or eggType == "magician_egg")

                        local matchSpecific = (specificId == nil or eggType == specificId)
                        local matchRarity = (rank >= minRank)
                        local matchMutation = isMutationMatching(mutFilter, mutation)

                        if matchSpecific and matchRarity and matchMutation then
                            local score = rank * 10000
                            if isBoss then
                                score = score + (State.AutoHuntEventBoss and 200000 or 50000)
                            end
                            if mutation and mutation ~= "NORMAL" then
                                score = score + (State.PrioritizeMutations and 30000 or 5000)
                            end
                            if size == "huge" then score = score + 20000
                            elseif size == "big" then score = score + 10000 end

                            if score > bestScore then
                                bestScore = score
                                bestId = id
                            end
                        end
                    end
                end

                if bestId then
                    task.wait(0.12)
                    pcall(function()
                        WaveService.RF.Finished:InvokeServer({ bestId })
                    end)
                else
                    -- ไม่มีไข่ที่ตรงตามเงื่อนไข ปิดคลื่นทันทีโดยไม่เก็บไข่ขยะ
                    pcall(function()
                        WaveService.RF.Finished:InvokeServer({})
                    end)
                end
            end
        end)

        task.wait(State.WaveDelay or 2)
        isSnipingWave = false
    end)
end

-- 2. Egg & Animal Plot Manager
local lastEquipBestTime = 0
local lastEggFullTime = 0

local function isRarityMatching(targetRarity, eggRank, eggRarity)
    if not targetRarity then return false end
    if type(targetRarity) == "string" then
        if targetRarity == "ทุกระดับ Common - Rare" then
            return eggRank <= 3
        elseif targetRarity == "ทุกระดับ Common - Epic" then
            return eggRank <= 4
        elseif targetRarity == "ทุกระดับ Common - Legendary" then
            return eggRank <= 5
        else
            local cleanTarget = targetRarity:match("^([%w_]+)") or targetRarity
            return cleanTarget:upper() == eggRarity:upper()
        end
    elseif type(targetRarity) == "table" then
        local hasAny = false
        for k, v in pairs(targetRarity) do
            if v == true or type(k) == "number" then
                hasAny = true
                local opt = (type(k) == "string" and v == true) and k or tostring(v)
                if opt == "ทุกระดับ Common - Rare" and eggRank <= 3 then
                    return true
                elseif opt == "ทุกระดับ Common - Epic" and eggRank <= 4 then
                    return true
                elseif opt == "ทุกระดับ Common - Legendary" and eggRank <= 5 then
                    return true
                else
                    local cleanTarget = opt:match("^([%w_]+)") or opt
                    if cleanTarget:upper() == eggRarity:upper() then
                        return true
                    end
                end
            end
        end
        if not hasAny then return false end
        return false
    end
    return false
end

local function sellSelectedEggs()
    local targetRarity = State.SellEggRarity or State.SellTargetEgg or "ทุกระดับ Common - Rare"
    if UIControls.SellEggRarity and UIControls.SellEggRarity.Value then
        targetRarity = UIControls.SellEggRarity.Value
    end
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data or not data.Inventory then return 0 end

    local soldCount = 0

    for id, it in pairs(data.Inventory) do
        if it.itemType == "Egg" and it.innerEntity and it.innerEntity.eggType then
            local eggType = it.innerEntity.eggType
            local eggRarity = EggToRarity[eggType] or "Common"
            local eggRank = EggRarityRanks[eggRarity] or 1

            if isRarityMatching(targetRarity, eggRank, eggRarity) then
                local ok = pcall(function()
                    InventoryService.RF.SellEgg:InvokeServer(id)
                end)
                if ok then
                    soldCount = soldCount + 1
                end
                task.wait(0.05)
            end
        end
    end
    return soldCount
end

local isCollectingStars = false
local function handleCollectStars()
    if not State.AutoCollectStars or isCollectingStars then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pickupsFolder = workspace:FindFirstChild("CollectEventPickups")
    if not pickupsFolder or #pickupsFolder:GetChildren() == 0 then return end

    isCollectingStars = true
    task.spawn(function()
        for _, model in ipairs(pickupsFolder:GetChildren()) do
            if not State.AutoCollectStars then break end
            if model:IsA("Model") and model.Parent then
                local eventId, id = model.Name:match("^([%w_]+)_(%w+)$")
                if not eventId then
                    eventId = "STARS"
                    id = model.Name:match("%d+")
                end

                pcall(function()
                    model:PivotTo(hrp.CFrame)
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CFrame = hrp.CFrame
                        end
                    end
                end)

                if id and CollectEventService and CollectEventService.RF and CollectEventService.RF.Collect then
                    pcall(function()
                        CollectEventService.RF.Collect:InvokeServer(eventId or "STARS", tonumber(id) or id)
                    end)
                end
                task.wait(0.08)
            end
        end
        isCollectingStars = false
    end)
end

local function handleEggsAndAnimals()
    local data = nil
    pcall(function()
        data = ReplicaController:GetPlayerData()
    end)
    if not data then return end

    -- Auto collect event stars (Magnet suction)
    if State.AutoCollectStars then
        handleCollectStars()
    end

    if State.ShowStarEventHud then
        pcall(function()
            local starEvent = LP.PlayerGui.HUD:FindFirstChild("StarEvent")
            if starEvent and not starEvent.Visible then
                starEvent.Visible = true
            end
        end)
    end

    -- Auto sell selected eggs
    if State.AutoSellSpecificEgg then
        sellSelectedEggs()
    end

    -- Place Eggs from Inventory onto Plot (with Max Limit Guard & Backoff)
    if State.AutoHatchEggs and data.Inventory and (os.clock() - lastEggFullTime > 20) then
        local placedEggsCount = 0
        if data.PlacedEggs then
            for _ in pairs(data.PlacedEggs) do
                placedEggsCount = placedEggsCount + 1
            end
        end

        -- If plot already has maximum eggs placed (10), back off and wait for them to hatch
        if placedEggsCount >= 10 then
            lastEggFullTime = os.clock()
        else
            local surface = getMyPlotSurface()
            if surface then
                for id, it in pairs(data.Inventory) do
                    if it.itemType == "Egg" or (it.innerEntity and it.innerEntity.eggType) then
                        local rx = math.random(-15, 15)
                        local rz = math.random(-15, 15)
                        local targetCF = surface.CFrame * CFrame.new(rx, 1.5, rz)
                        local ok, res = pcall(function()
                            return EggService.RF.PlaceEgg:InvokeServer(id, targetCF)
                        end)
                        if ok and res == false then
                            lastEggFullTime = os.clock()
                            break
                        end
                        placedEggsCount = placedEggsCount + 1
                        if placedEggsCount >= 10 then
                            lastEggFullTime = os.clock()
                            break
                        end
                        task.wait(0.15)
                    end
                end
            end
        end
    end

    -- Hatch Placed Eggs from Plot
    if State.AutoHatchEggs then
        local plot = getMyPlotModel()
        local eggsFolder = plot and plot:FindFirstChild("Eggs", true)
        if eggsFolder then
            local now = workspace:GetServerTimeNow()
            for _, eggModel in ipairs(eggsFolder:GetChildren()) do
                local duration = eggModel:GetAttribute("Duration") or 120
                local startTime = eggModel:GetAttribute("StartTime") or 0
                local eggId = eggModel:GetAttribute("EggId")
                if eggId and (startTime + duration) <= now then
                    pcall(function()
                        EggService.RF.HatchEgg:InvokeServer(eggId)
                    end)
                    task.wait(0.12)
                end
            end
        end
    end

    -- Equip Best (Rate limited to avoid spamming server)
    if State.AutoEquipBest then
        local now = os.clock()
        if (now - lastEquipBestTime) >= 15 then
            lastEquipBestTime = now
            pcall(function()
                AnimalService.RF.EquipBest:InvokeServer()
            end)
        end
    end

    -- Auto Sell Unused Animals from Inventory (liquidates leftover unplaced animals)
    if State.AutoSellAnimals and data.Inventory then
        local hasUnusedAnimal = false
        for id, it in pairs(data.Inventory) do
            if it.itemType == "Brainrot" or (it.innerEntity and it.innerEntity.brainrotType) then
                hasUnusedAnimal = true
                break
            end
        end
        if hasUnusedAnimal then
            pcall(function()
                AnimalService.RF.EquipBest:InvokeServer()
                task.wait(0.2)
                InventoryService.RF.SellAllBrainrots:InvokeServer()
            end)
        end
    end

    -- Collect Offline Cash
    if State.AutoOfflineCash then
        pcall(function()
            AnimalService.RF.CollectOfflineCash:InvokeServer()
        end)
    end
end

-- 3. Dumbbell & Gear Auto Purchaser
local function buyBestDumbbell()
    if not State.AutoBuyDumbbell or not TrainToolConfig or not TrainToolConfig.TRAIN_TOOLS then return end
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data or not data.Currencies or not data.Currencies.Cash then return end
    local cash = data.Currencies.Cash
    local owned = data.OwnedTrainTools or {}
    local equipped = data.EquippedTrainTool

    local bestToBuy = nil
    local maxGain = -1

    for id, tool in pairs(TrainToolConfig.TRAIN_TOOLS) do
        if not tool.isSpecial and tool.cost and tool.cost > 0 then
            if not owned[id] and cash >= tool.cost then
                local gain = tool.gainPerTrain or 0
                if gain > maxGain then
                    maxGain = gain
                    bestToBuy = id
                end
            end
        end
    end

    if bestToBuy then
        pcall(function()
            TrainingService.RF.BuyTrainTool:InvokeServer(bestToBuy)
            task.wait(0.15)
            TrainingService.RF.EquipTrainTool:InvokeServer(bestToBuy)
        end)
    else
        -- Ensure highest owned dumbbell is equipped
        local bestOwned = nil
        local highestOwnedGain = -1
        for id, tool in pairs(TrainToolConfig.TRAIN_TOOLS) do
            if owned[id] then
                local gain = tool.gainPerTrain or 0
                if gain > highestOwnedGain then
                    highestOwnedGain = gain
                    bestOwned = id
                end
            end
        end
        if bestOwned and bestOwned ~= equipped then
            pcall(function()
                TrainingService.RF.EquipTrainTool:InvokeServer(bestOwned)
            end)
        end
    end
end

-- 4. Staff / Pickaxe Auto Purchaser
local function buyBestStaff()
    if not State.AutoBuyStaff or not StaffConfig then return end
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data or not data.Currencies or not data.Currencies.Cash then return end
    local cash = data.Currencies.Cash
    local owned = data.OwnedPickaxes or {}
    local equipped = data.EquippedPickaxe

    local bestToBuy = nil
    local maxReach = -1

    for id, staff in pairs(StaffConfig) do
        if not staff.isSpecial and staff.cost and staff.cost > 0 then
            if not owned[id] and cash >= staff.cost then
                local reach = staff.reach or 0
                if reach > maxReach then
                    maxReach = reach
                    bestToBuy = id
                end
            end
        end
    end

    if bestToBuy then
        pcall(function()
            PickaxeService.RF.BuyPickaxe:InvokeServer(bestToBuy)
            task.wait(0.15)
            PickaxeService.RF.EquipPickaxe:InvokeServer(bestToBuy)
        end)
    else
        local bestOwned = nil
        local highestReach = -1
        for id, staff in pairs(StaffConfig) do
            if owned[id] then
                local reach = staff.reach or 0
                if reach > highestReach then
                    highestReach = reach
                    bestOwned = id
                end
            end
        end
        if bestOwned and bestOwned ~= equipped then
            pcall(function()
                PickaxeService.RF.EquipPickaxe:InvokeServer(bestOwned)
            end)
        end
    end
end

-- 5. Upgrades & Rebirth
local function handleUpgrades()
    if not UpgradeConfig then return end
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data or not data.Currencies or not data.Currencies.Cash then return end
    local cash = data.Currencies.Cash
    local upgs = data.Upgrades or {}

    -- PlotUpgrade
    if State.AutoUpgradePlot then
        local currentLvl = upgs.PlotUpgrade or 0
        local nextPrice = UpgradeConfig.GetPrice("PlotUpgrade", currentLvl + 1)
        if nextPrice and cash >= nextPrice then
            pcall(function()
                UpgradesService.RF.Upgrade:InvokeServer("PlotUpgrade", 1)
            end)
            task.wait(0.15)
        end
    end

    -- Carry
    if State.AutoUpgradeCarry then
        local currentLvl = upgs.Carry or 0
        local nextPrice = UpgradeConfig.GetPrice("Carry", currentLvl + 1)
        if nextPrice and cash >= nextPrice then
            pcall(function()
                UpgradesService.RF.Upgrade:InvokeServer("Carry", 1)
            end)
            task.wait(0.15)
        end
    end

    -- Speed
    if State.AutoUpgradeSpeed then
        local currentLvl = upgs.MovementSpeed or 0
        local maxBuy = UpgradeConfig.GetMaxBuyable("MovementSpeed", currentLvl, cash)
        if maxBuy and maxBuy > 0 then
            pcall(function()
                UpgradesService.RF.Upgrade:InvokeServer("MovementSpeed", math.min(maxBuy, 10))
            end)
            task.wait(0.15)
        end
    end
end

local function handleRebirth()
    if not State.AutoRebirth or not RebirthConfig or not RebirthConfig.REBIRTH then return end
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data or not data.Currencies or not data.Currencies.Cash then return end
    local curRebirth = data.Rebirth or 0
    local cash = data.Currencies.Cash

    if State.TargetRebirth ~= "ไม่จำกัด / สูงสุดตลอดเวลา" then
        local targetNum = tonumber(State.TargetRebirth:match("%d+"))
        if targetNum and curRebirth >= targetNum then
            return
        end
    end

    local nextTier = RebirthConfig.REBIRTH[curRebirth + 1]
    if nextTier and nextTier.Cost and nextTier.Cost.Cash then
        if cash >= nextTier.Cost.Cash then
            pcall(function()
                RebirthService.RF.Rebirth:InvokeServer()
            end)
        end
    end
end

-- 6. Freebies & Rewards (Intelligent Precondition Validation & Cooldown Guards)
local lastDailyCheck = 0
local lastPlaytimeCheck = 0

local function handleFreebies()
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data then return end

    -- Offline cash: only collect if offline cash > 0 (prevents "You do not have any cash earned offline")
    if State.AutoOfflineCash and (data.OfflineCash or 0) > 0 then
        pcall(function() AnimalService.RF.CollectOfflineCash:InvokeServer() end)
    end

    -- Free shop: only claim if current index has not been claimed yet
    if State.AutoFreeShop and FreeShopConfig then
        local lastClaim = data.LastFreeShopClaim or 0
        local targetIndex = FreeShopConfig.CURRENT_CLAIM_INDEX or 1
        if lastClaim < targetIndex then
            pcall(function() FreeShopService.RF.Claim:InvokeServer() end)
        end
    end

    -- Spin wheel: only spin if player has enough tickets (LuminousCoins >= 25)
    if State.AutoSpinWheel and data.Currencies and (data.Currencies.LuminousCoins or 0) >= 25 then
        pcall(function() SpinWheelService.RF.SpinAll:InvokeServer() end)
    end

    -- Playtime gifts: uses PlaytimeRewardController to claim ONLY available gifts (prevents "You have already claimed this gift")
    if State.AutoPlaytimeGifts then
        local now = os.clock()
        if (now - lastPlaytimeCheck) >= 10 then
            lastPlaytimeCheck = now
            pcall(function()
                if PlaytimeRewardController and PlaytimeRewardController.GetAvailableGiftsCount then
                    if PlaytimeRewardController:GetAvailableGiftsCount() > 0 then
                        local nextGift = PlaytimeRewardController:GetNextClaimableGift()
                        if nextGift then
                            PlaytimeRewardController:ClaimGift(nextGift)
                        end
                    end
                end
            end)
        end
    end

    -- Daily rewards: checks cooldown (24h) and only claims nextDay; NEVER calls VIP without owning VIP (prevents Robux popup)
    if State.AutoDailyRewards then
        local now = os.clock()
        if (now - lastDailyCheck) >= 60 then
            lastDailyCheck = now
            local daily = data.DailyReward
            local serverTime = workspace:GetServerTimeNow()
            if daily and daily.LastClaimedDate then
                if (serverTime - daily.LastClaimedDate) >= 86400 then
                    local nextDay = (daily.LastClaimedDay or 0) + 1
                    if nextDay <= 7 then
                        pcall(function() DailyRewardService.RF.ClaimReward:InvokeServer(nextDay) end)
                    end
                end
            end
            -- VIP reward: ONLY claim if player ACTUALLY OWNS the VIP gamepass! (prevents Robux popup)
            local hasVip = data.Gamepasses and (data.Gamepasses.VIP or data.Gamepasses["VIP"] or data.Gamepasses["vip"])
            if hasVip then
                pcall(function() DailyRewardService.RF.ClaimVIPReward:InvokeServer() end)
            end
        end
    end

    -- Group reward: only claim if not yet redeemed
    if State.AutoGroupReward and not data.RedeemedGroupReward then
        pcall(function() RewardService.RF.GroupReward:InvokeServer() end)
    end

    -- Season Pass Free Tier Auto-Claiming
    if State.AutoSeasonPass and SeasonPassConfig and SeasonPassConfig.Level then
        local sp = data.SeasonPass
        if sp then
            local exp = sp.Exp or 0
            local curLvl = 0
            for lvl, reqExp in ipairs(SeasonPassConfig.Level) do
                if exp >= reqExp then curLvl = lvl end
            end
            local freeClaimed = sp.Free or {}
            for tier = 1, curLvl do
                if not freeClaimed[tostring(tier)] then
                    pcall(function()
                        SeasonPassService.RF.ClaimPassReward:InvokeServer("Free", tier)
                    end)
                end
            end
        end
    end

    -- Quests Auto-Claiming (Daily, Hourly, SeasonPass)
    if State.AutoQuests and data.Quests then
        for qType, qList in pairs(data.Quests) do
            if type(qList) == "table" then
                for _, q in pairs(qList) do
                    if type(q) == "table" and q.id and q.isCompleted and not q.isClaimed then
                        pcall(function()
                            QuestService.RF.ClaimReward:InvokeServer(qType, q.id)
                        end)
                    end
                end
            end
        end
    end

    -- Auto Potions (Train / Cash / Luck)
    if State.AutoUsePotions and data.PotionInventory then
        local active = data.ActivePotions or {}
        -- Train Potion (x2 Power)
        if State.AutoUseTrainPotion and (data.PotionInventory.Train or 0) > 0 and not active.Train then
            pcall(function()
                PotionService.RF.UsePotion:InvokeServer("Train")
            end)
        end
        -- Cash Potion (x2 Cash)
        if State.AutoUseCashPotion and (data.PotionInventory.Cash or 0) > 0 and not active.Cash then
            pcall(function()
                PotionService.RF.UsePotion:InvokeServer("Cash")
            end)
        end
        -- Luck Potion (x2 Luck)
        if State.AutoUseLuckPotion and (data.PotionInventory.Luck or 0) > 0 and not active.Luck then
            pcall(function()
                PotionService.RF.UsePotion:InvokeServer("Luck")
            end)
        end
    end
end

-- 7. Power Training Loop (Silent Server Training - Bypasses WalkSpeed 0 Lock)
local function updateHUDPower(powerVal)
    pcall(function()
        local speedLabel = LP.PlayerGui:FindFirstChild("HUD")
            and LP.PlayerGui.HUD:FindFirstChild("LeftContainer")
            and LP.PlayerGui.HUD.LeftContainer:FindFirstChild("Currency")
            and LP.PlayerGui.HUD.LeftContainer.Currency:FindFirstChild("Speed")
            and LP.PlayerGui.HUD.LeftContainer.Currency.Speed:FindFirstChild("Speed")
            and LP.PlayerGui.HUD.LeftContainer.Currency.Speed.Speed:FindFirstChild("SpeedLabel")
        if speedLabel then
            local formatted = AbbreviationUtils and AbbreviationUtils:AbbreviateNumber(powerVal, 1) or formatNum(powerVal)
            speedLabel.Text = formatted
            local inner = speedLabel:FindFirstChild("Speed")
            if inner then inner.Text = formatted end
        end
    end)
end

local function stopTraining()
    pcall(function()
        if TrainingService and TrainingService.RF and TrainingService.RF.StopTraining then
            TrainingService.RF.StopTraining:InvokeServer()
        end
    end)
    pcall(function()
        if TrainingController and TrainingController.StopTraining then
            TrainingController:StopTraining(true)
        end
    end)
    pcall(function()
        local char = LP.Character
        if char then
            char:SetAttribute("IsTrainingLocal", nil)
            char:SetAttribute("DumbbellModel", nil)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                    local tName = track.Name:lower()
                    local aId = (track.Animation and track.Animation.AnimationId or ""):lower()
                    if tName:find("train") or tName:find("dumb") or aId:find("train") or aId:find("dumb") then
                        track:Stop()
                    end
                end
                if hum.WalkSpeed == 0 then
                    hum.WalkSpeed = 16
                end
            end
        end
        LP:SetAttribute("IsTrainingLocal", nil)
    end)
end

local function ensureTraining()
    if not State.AutoTrain then return end
    if LP:GetAttribute("IsWaveActive") then return end

    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    local equippedTool = data and data.EquippedTrainTool or "anvildumbbell"
    local char = LP.Character

    -- Visually attach the real best dumbbell to the player
    if char then
        if char:GetAttribute("DumbbellModel") ~= equippedTool then
            char:SetAttribute("DumbbellModel", equippedTool)
        end
        char:SetAttribute("IsTrainingLocal", true)
    end
    LP:SetAttribute("IsTrainingLocal", true)

    -- Invoke server training directly
    pcall(function()
        TrainingService.RF.StartTraining:InvokeServer()
    end)

    -- Update Power display on HUD & Fire TrainGain for visual popup
    local curPower = LP.leaderstats and LP.leaderstats:FindFirstChild("Power") and LP.leaderstats.Power.Value or 0
    local toolConf = TrainToolConfig and TrainToolConfig.TRAIN_TOOLS and TrainToolConfig.TRAIN_TOOLS[equippedTool]
    local gain = toolConf and toolConf.gainPerTrain or 7500000

    local TrainGain = RS:FindFirstChild("TrainGain")
    if TrainGain then
        pcall(function()
            TrainGain:Fire(gain, curPower)
        end)
    end
    updateHUDPower(curPower)

    -- Auto-claim bonus x2 button when spawned or visible
    if State.AutoClaimBonus then
        pcall(function()
            local x2Speed = LP.PlayerGui:FindFirstChild("SpeedEffect")
                and LP.PlayerGui.SpeedEffect:FindFirstChild("LeftContainer")
                and LP.PlayerGui.SpeedEffect.LeftContainer:FindFirstChild("Currency")
                and LP.PlayerGui.SpeedEffect.LeftContainer.Currency:FindFirstChild("Speed")
                and LP.PlayerGui.SpeedEffect.LeftContainer.Currency.Speed:FindFirstChild("x2Speed")
            if x2Speed and x2Speed.Visible then
                local Button = safeRequire(Knit and Knit.UIComponents and Knit.UIComponents.Button)
                local btnObj = Button and Button:FromInstance(x2Speed)
                if btnObj and btnObj.Callbacks then
                    for _, cb in ipairs(btnObj.Callbacks) do
                        pcall(cb)
                    end
                end
                x2Speed.Visible = false
            end
        end)
    end
end

-- Hook SpawnBonus Remote & GUI for Instant Zero-Latency X2 Claiming
local lastClaimedBonusId = ""
pcall(function()
    local knitTraining = nil
    pcall(function() knitTraining = Knit.GetService("TrainingService") end)
    if knitTraining and knitTraining.SpawnBonus then
        local bonusConn = knitTraining.SpawnBonus:Connect(function(bonusId)
            if State.AutoClaimBonus and bonusId and bonusId ~= lastClaimedBonusId then
                lastClaimedBonusId = bonusId
                task.wait(0.05)
                pcall(function() knitTraining:ClaimBonus(bonusId) end)
                pcall(function() TrainingService.RF.ClaimBonus:InvokeServer(bonusId) end)
                pcall(function()
                    local x2Speed = LP.PlayerGui:FindFirstChild("SpeedEffect")
                        and LP.PlayerGui.SpeedEffect:FindFirstChild("LeftContainer")
                        and LP.PlayerGui.SpeedEffect.LeftContainer:FindFirstChild("Currency")
                        and LP.PlayerGui.SpeedEffect.LeftContainer.Currency:FindFirstChild("Speed")
                        and LP.PlayerGui.SpeedEffect.LeftContainer.Currency.Speed:FindFirstChild("x2Speed")
                    if x2Speed then x2Speed.Visible = false end
                end)
            end
        end)
        table.insert(_conns, bonusConn)
    end
end)

pcall(function()
    local x2Speed = LP.PlayerGui:FindFirstChild("SpeedEffect")
        and LP.PlayerGui.SpeedEffect:FindFirstChild("LeftContainer")
        and LP.PlayerGui.SpeedEffect.LeftContainer:FindFirstChild("Currency")
        and LP.PlayerGui.SpeedEffect.LeftContainer.Currency:FindFirstChild("Speed")
        and LP.PlayerGui.SpeedEffect.LeftContainer.Currency.Speed:FindFirstChild("x2Speed")
    if x2Speed then
        local visConn = x2Speed:GetPropertyChangedSignal("Visible"):Connect(function()
            if State.AutoClaimBonus and x2Speed.Visible then
                task.wait(0.03)
                pcall(function()
                    local Button = safeRequire(Knit and Knit.UIComponents and Knit.UIComponents.Button)
                    local btnObj = Button and Button:FromInstance(x2Speed)
                    if btnObj and btnObj.Callbacks then
                        for _, cb in ipairs(btnObj.Callbacks) do
                            pcall(cb)
                        end
                    end
                end)
                x2Speed.Visible = false
            end
        end)
        table.insert(_conns, visConn)
    end
end)

-- ── 6. BACKGROUND THREADS ────────────────────────────────────────────────────────

-- Thread 1: Wave Sniping
task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(1)
        if State.AutoWave then
            pcall(runWaveSniping)
        end
    end
end)

-- Thread 2: Eggs & Animals Plot Automation
task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(2)
        pcall(handleEggsAndAnimals)
        pcall(clearNotificationSpam)
    end
end)

-- Thread 3: Power Training & Gear
task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(2)
        pcall(ensureTraining)
        pcall(buyBestDumbbell)
        pcall(buyBestStaff)
    end
end)

-- Thread 4: Upgrades, Rebirth & Freebies
task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(2)
        pcall(handleUpgrades)
        pcall(handleRebirth)
        pcall(handleFreebies)
    end
end)

-- Thread 5: Anti-AFK & Hardware Heartbeat (24/7 kick protection)
task.spawn(function()
    -- Scan and disable map afk scripts
    local ps = LP:FindFirstChild("PlayerScripts")
    if ps then
        for _, desc in ipairs(ps:GetDescendants()) do
            if desc:IsA("LocalScript") and desc.Name:lower():find("afk") then
                pcall(function()
                    desc.Disabled = true
                    desc:Destroy()
                end)
            end
        end
        local c = ps.DescendantAdded:Connect(function(desc)
            if desc:IsA("LocalScript") and desc.Name:lower():find("afk") then
                pcall(function()
                    desc.Disabled = true
                    desc:Destroy()
                end)
            end
        end)
        table.insert(_conns, c)
    end

    local idledConn = LP.Idled:Connect(function()
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end)
    table.insert(_conns, idledConn)

    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(35)
        if State.AntiAFK then
            pcall(function()
                if VirtualInputManager then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F15, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F15, false, game)
                end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end
end)

-- Physics & Movement Helpers
local infJumpConn = nil
local function updateInfiniteJump()
    if infJumpConn then
        pcall(function() infJumpConn:Disconnect() end)
        infJumpConn = nil
    end
    if State.InfiniteJump then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            if State.InfiniteJump and LP.Character then
                local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        table.insert(_conns, infJumpConn)
    end
end

local noclipConn = nil
local function updateNoclip()
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
    if State.Noclip then
        noclipConn = RunService.Stepped:Connect(function()
            if State.Noclip and LP.Character then
                for _, part in ipairs(LP.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        table.insert(_conns, noclipConn)
    end
end

-- Thread 6: Custom Speed & Jump Enforcer
task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(0.4)
        if State.CustomSpeedEnabled then
            pcall(function()
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= State.CustomSpeedValue then
                    hum.WalkSpeed = State.CustomSpeedValue
                end
            end)
        end
        if State.CustomJumpEnabled then
            pcall(function()
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.UseJumpPower = true
                    if hum.JumpPower ~= State.CustomJumpValue then
                        hum.JumpPower = State.CustomJumpValue
                    end
                end
            end)
        end
    end
end)

-- Thread 7: Event Boss Watcher (Devil / Zeus / Dragon Egg Auto-Sniper)
task.spawn(function()
    local ae = RS:FindFirstChild("ActiveEvents")
    if ae then
        local evConn = ae.ChildAdded:Connect(function(child)
            if child.Name == "DEVIL" or child.Name == "ZEUS" then
                pcall(function()
                    Fluent:Notify({
                        Title = "บอสอีเวนต์เกิด!",
                        Content = string.format("ตรวจพบบอส %s! ระบบกำลังเปิดโหมดล่า Dragon Egg ทันที", child.Name),
                        Duration = 6
                    })
                end)
                if State.AutoHuntEventBoss then
                    task.wait(0.5)
                    pcall(runWaveSniping)
                end
            end
        end)
        table.insert(_conns, evConn)
    end

    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        task.wait(3)
        if State.AutoHuntEventBoss then
            local activeEvents = RS:FindFirstChild("ActiveEvents")
            local isBossActive = false
            if activeEvents then
                for _, ev in ipairs(activeEvents:GetChildren()) do
                    local evNameUpper = string.upper(ev.Name)
                    if string.find(evNameUpper, "DEVIL") or string.find(evNameUpper, "ZEUS") then
                        isBossActive = true
                        break
                    end
                end
            end
            if isBossActive then
                -- Base Event is active! Ensure wave is run to snipe the Dragon Egg
                if not isSnipingWave and not LP:GetAttribute("IsWaveActive") then
                    pcall(runWaveSniping)
                end
            end
        end
    end
end)

-- ── 6.5 BULK TRADING & GIFTING SYSTEM ─────────────────────────────────────────────
local isBulkTrading = false

local function getOnlinePlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        table.insert(names, "ไม่มีผู้เล่นอื่นในห้อง (No Other Players)")
    end
    table.sort(names)
    return names
end

local function getAnimalFilterList()
    local list = { "ทั้งหมด (All Animals)" }
    local seen = {}

    -- 1. Animals currently in player's inventory first
    pcall(function()
        local data = ReplicaController:GetPlayerData()
        if data and data.Inventory then
            for _, item in pairs(data.Inventory) do
                if item.itemType == "Brainrot" and item.innerEntity and item.innerEntity.brainrotType then
                    local rawName = item.innerEntity.brainrotType
                    local formatted = rawName:gsub("_", " ")
                    formatted = formatted:gsub("(%a)([%w_']*)", function(first, rest)
                        return first:upper() .. rest:lower()
                    end)
                    if not seen[formatted:lower()] then
                        seen[formatted:lower()] = true
                        table.insert(list, formatted)
                    end
                end
            end
        end
    end)

    -- 2. All other game animals from BrainrotsConfig
    pcall(function()
        local cfg = safeRequire(RS.Configs:FindFirstChild("BrainrotsConfig"))
        local allGame = {}
        if cfg and cfg.CONFIG then
            for k, _ in pairs(cfg.CONFIG) do
                local rawName = tostring(k)
                local formatted = rawName:gsub("_", " ")
                formatted = formatted:gsub("(%a)([%w_']*)", function(first, rest)
                    return first:upper() .. rest:lower()
                end)
                if not seen[formatted:lower()] then
                    seen[formatted:lower()] = true
                    table.insert(allGame, formatted)
                end
            end
        end
        table.sort(allGame)
        for _, name in ipairs(allGame) do
            table.insert(list, name)
        end
    end)

    return list
end

-- Double-layer Auto-Accept Receiver Engine
pcall(function()
    local knitGifting = nil
    pcall(function() knitGifting = Knit.GetService("GiftingService") end)
    if knitGifting and knitGifting.GiftReceived then
        local giftConn = knitGifting.GiftReceived:Connect(function(sender, itemInfo)
            if State.AutoAcceptGifts and itemInfo and itemInfo.id then
                pcall(function()
                    GiftingService.RF.ClaimGift:InvokeServer(itemInfo.id)
                end)
                pcall(function()
                    local wc = Knit.GetController("WindowController")
                    if wc and wc.currentWindow == "GiftReceivePopup" then
                        wc:CloseCurrentWindow()
                    end
                end)
                Fluent:Notify({
                    Title = "รับสัตว์สำเร็จ",
                    Content = "รับสัตว์จาก @" .. tostring(sender and sender.DisplayName or "ผู้เล่นอื่น") .. " เรียบร้อยแล้ว",
                    Duration = 2.5
                })
            end
        end)
        table.insert(_conns, giftConn)
    end
end)

pcall(function()
    local popup = LP:WaitForChild("PlayerGui", 5)
        and LP.PlayerGui:WaitForChild("Windows", 5)
        and LP.PlayerGui.Windows:WaitForChild("GiftReceivePopup", 5)
    if popup then
        local popupConn = popup:GetPropertyChangedSignal("Visible"):Connect(function()
            if popup.Visible and State.AutoAcceptGifts then
                local acceptBtn = popup:FindFirstChild("Accept")
                if acceptBtn then
                    local Button = safeRequire(Knit and Knit.UIComponents and Knit.UIComponents.Button)
                    local btnObj = Button and Button:FromInstance(acceptBtn)
                    if btnObj and btnObj.Callbacks then
                        for _, cb in ipairs(btnObj.Callbacks) do
                            pcall(cb)
                        end
                    end
                end
            end
        end)
        table.insert(_conns, popupConn)
    end
end)

local function startBulkTrade(silent)
    if isBulkTrading then
        if not silent then
            Fluent:Notify({ Title = "ระบบกำลังทำงาน", Content = "การส่งสัตว์รอบก่อนหน้ายังทำงานอยู่ กรุณากดหยุดก่อน", Duration = 3 })
        end
        return
    end

    -- 1. Resolve Target Player Name
    local targetName = State.TradeTargetPlayer
    if (not targetName or targetName == "" or targetName:find("ไม่มีผู้เล่นอื่น")) and UIControls.TradeTargetPlayer then
        local uiVal = UIControls.TradeTargetPlayer.Value
        if type(uiVal) == "string" and uiVal ~= "" and not uiVal:find("ไม่มีผู้เล่นอื่น") then
            targetName = uiVal
            State.TradeTargetPlayer = uiVal
        elseif type(uiVal) == "table" and uiVal[1] and not tostring(uiVal[1]):find("ไม่มีผู้เล่นอื่น") then
            targetName = tostring(uiVal[1])
            State.TradeTargetPlayer = targetName
        end
    end

    -- 2. Locate Target Player instance
    local targetPlayer = nil
    if targetName and targetName ~= "" and not targetName:find("ไม่มีผู้เล่นอื่น") then
        targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and (p.Name == targetName or p.DisplayName == targetName or targetName:find(p.Name, 1, true)) then
                    targetPlayer = p
                    break
                end
            end
        end
    end

    -- Fallback: If still not resolved, pick the first valid other player in server
    if not targetPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                targetPlayer = p
                targetName = p.Name
                State.TradeTargetPlayer = p.Name
                if UIControls.TradeTargetPlayer then
                    pcall(function() UIControls.TradeTargetPlayer:SetValue(p.Name) end)
                end
                break
            end
        end
    end

    if not targetPlayer then
        if not silent then
            Fluent:Notify({ Title = "ไม่พบผู้เล่น", Content = "ไม่พบผู้เล่นอื่นในห้อง กรุณารอผู้เล่นอื่นเข้าเซิร์ฟเวอร์", Duration = 3.5 })
        end
        return
    end

    -- 3. Fetch Player Inventory
    local data = nil
    pcall(function() data = ReplicaController:GetPlayerData() end)
    if not data or not data.Inventory then
        if not silent then
            Fluent:Notify({ Title = "ข้อผิดพลาด", Content = "ไม่สามารถดึงข้อมูลกระเป๋าได้", Duration = 3 })
        end
        return
    end

    -- Build placed IDs lookup to prevent gifting placed base animals
    local placedLookup = {}
    if data.PlacedAnimals then
        for _, info in pairs(data.PlacedAnimals) do
            if info and info.id then
                placedLookup[info.id] = true
            end
        end
    end

    -- 4. Find matching animals (supports Multi-Select table and single select)
    local candidates = {}
    local filter = State.TradeFilterAnimals or State.TradeFilterAnimal or "ทั้งหมด (All Animals)"
    if UIControls.TradeFilterAnimals and UIControls.TradeFilterAnimals.Value then
        filter = UIControls.TradeFilterAnimals.Value
    end

    local function checkMatch(bClean)
        if type(filter) == "string" then
            if filter == "ทั้งหมด (All Animals)" or filter == "ทั้งหมดในกระเป๋า (All Available)" then
                return true
            end
            local targetClean = filter:lower():gsub("[%s_%-]", "")
            return targetClean == bClean or bClean:find(targetClean, 1, true) or targetClean:find(bClean, 1, true)
        elseif type(filter) == "table" then
            if filter["ทั้งหมด (All Animals)"] or filter["ทั้งหมดในกระเป๋า (All Available)"] then
                return true
            end
            for k, v in pairs(filter) do
                local nameToCheck = (type(k) == "string" and v == true) and k or (type(k) == "number" and tostring(v) or nil)
                if nameToCheck then
                    if nameToCheck == "ทั้งหมด (All Animals)" or nameToCheck == "ทั้งหมดในกระเป๋า (All Available)" then
                        return true
                    end
                    local targetClean = nameToCheck:lower():gsub("[%s_%-]", "")
                    if targetClean == bClean or bClean:find(targetClean, 1, true) or targetClean:find(bClean, 1, true) then
                        return true
                    end
                end
            end
        end
        return false
    end

    for id, item in pairs(data.Inventory) do
        if item.itemType == "Brainrot" and item.innerEntity and not placedLookup[id] then
            local bType = (item.innerEntity.brainrotType or ""):lower()
            local bClean = bType:gsub("[%s_%-]", "")
            local mutation = item.innerEntity.mutation or "NORMAL"

            if checkMatch(bClean) then
                table.insert(candidates, {
                    id = id,
                    name = item.innerEntity.brainrotType or "Animal",
                    mutation = mutation,
                    level = item.innerEntity.level or 1
                })
            end
        end
    end

    if #candidates == 0 then
        if not silent then
            Fluent:Notify({ Title = "ไม่พบสัตว์ที่ตรงเงื่อนไข", Content = "ไม่มีสัตว์ในกระเป๋าที่ตรงกับหมวดที่เลือก", Duration = 3.5 })
        end
        return
    end

    local quantity = tonumber(State.TradeQuantity)
    if not quantity and UIControls.TradeQuantity then
        quantity = tonumber(UIControls.TradeQuantity.Value)
    end
    local maxToSend = math.min(#candidates, quantity or 10)
    isBulkTrading = true

    task.spawn(function()
        local isBurst = State.TradeInstantBurst
        if UIControls.TradeInstantBurst then
            isBurst = UIControls.TradeInstantBurst.Value
        end

        Fluent:Notify({
            Title = "เริ่มส่งสัตว์ทีละเยอะๆ",
            Content = string.format("เตรียมส่ง %d ตัว ไปยัง @%s (%s)...", maxToSend, targetPlayer.DisplayName, isBurst and "โหมด Burst รวดเดียว" or "โหมดเรียงคิว"),
            Duration = 3
        })

        local sentCount = 0

        if isBurst then
            -- INSTANT BURST: ส่งขนานพร้อมกันรวดเดียว (Parallel Coroutines)
            for i = 1, maxToSend do
                if not isBulkTrading or not _G.OpenSeaRunning then break end
                if not targetPlayer or not targetPlayer.Parent then break end

                local c = candidates[i]
                task.spawn(function()
                    pcall(function()
                        local knitGifting = nil
                        pcall(function() knitGifting = Knit.GetService("GiftingService") end)
                        if knitGifting and knitGifting.GiftBrainrot then
                            knitGifting:GiftBrainrot(c.id, targetPlayer)
                        else
                            local rf = RS:FindFirstChild("Packages")
                                and RS.Packages._Index:FindFirstChild("sleitnick_knit@1.7.0")
                                and RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services:FindFirstChild("GiftingService")
                                and RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.GiftingService.RF:FindFirstChild("GiftBrainrot")
                            if rf then
                                rf:InvokeServer(c.id, targetPlayer)
                            end
                        end
                    end)
                    pcall(function()
                        local wc = Knit.GetController("WindowController")
                        if wc and (wc.currentWindow == "GiftSendPopup" or wc.currentWindow == "GiftReceivePopup") then
                            wc:CloseCurrentWindow()
                        end
                    end)
                end)
                sentCount = sentCount + 1
                task.wait(0.015) -- Micro-tick to prevent socket buffer congestion
            end
        else
            -- SEQUENTIAL QUEUE: เรียงคิวตามดีเลย์ที่ตั้งไว้
            local speed = tonumber(State.TradeSpeedDelay)
            if not speed and UIControls.TradeSpeedDelay then
                speed = tonumber(UIControls.TradeSpeedDelay.Value)
            end
            local delayTime = math.max(0.01, speed or 0.05)

            for i = 1, maxToSend do
                if not isBulkTrading or not _G.OpenSeaRunning then break end

                if not targetPlayer or not targetPlayer.Parent then
                    Fluent:Notify({ Title = "ผู้เล่นหลุดจากห้อง", Content = "ผู้เล่นปลายทางออกจากเซิร์ฟเวอร์แล้ว หยุดการส่ง", Duration = 4 })
                    break
                end

                local c = candidates[i]
                local ok = false

                pcall(function()
                    local knitGifting = nil
                    pcall(function() knitGifting = Knit.GetService("GiftingService") end)
                    if knitGifting and knitGifting.GiftBrainrot then
                        local s = pcall(function()
                            knitGifting:GiftBrainrot(c.id, targetPlayer)
                        end)
                        ok = s
                    end
                    if not ok then
                        local rf = RS:FindFirstChild("Packages")
                            and RS.Packages._Index:FindFirstChild("sleitnick_knit@1.7.0")
                            and RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services:FindFirstChild("GiftingService")
                            and RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.GiftingService.RF:FindFirstChild("GiftBrainrot")
                        if rf then
                            local s = pcall(function()
                                rf:InvokeServer(c.id, targetPlayer)
                            end)
                            ok = s
                        end
                    end
                end)

                if ok then
                    sentCount = sentCount + 1
                end

                pcall(function()
                    local wc = Knit.GetController("WindowController")
                    if wc and (wc.currentWindow == "GiftSendPopup" or wc.currentWindow == "GiftReceivePopup") then
                        wc:CloseCurrentWindow()
                    end
                end)

                task.wait(delayTime)
            end
        end

        isBulkTrading = false
        Fluent:Notify({
            Title = "ส่งสัตว์เสร็จสิ้น",
            Content = string.format("ส่งสัตว์สำเร็จทั้งหมด %d/%d ตัว ให้ @%s เรียบร้อยแล้ว", sentCount, maxToSend, targetPlayer.DisplayName),
            Duration = 5
        })
    end)
end

local function stopBulkTrade()
    if isBulkTrading then
        isBulkTrading = false
        Fluent:Notify({ Title = "หยุดการส่งสัตว์", Content = "ยกเลิกกระบวนการส่งสัตว์เรียบร้อยแล้ว", Duration = 3 })
    end
end

-- Background Auto Bulk Trade Loop
task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        if State.AutoBulkTrade and not isBulkTrading then
            pcall(function()
                startBulkTrade(true)
            end)
        end
        task.wait(3)
    end
end)

-- ── 7. CONFIGURATION SYSTEM (JSON STORAGE) ───────────────────────────────────────
local CONFIG_FOLDER = "2K_Scripts/OpenSea"
local AUTOLOAD_FILE = CONFIG_FOLDER .. "/autoload.txt"

local function ensureConfigFolder()
    pcall(function()
        if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
            if not isfolder("2K_Scripts") then makefolder("2K_Scripts") end
            if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        end
    end)
end

local function listSavedConfigs()
    ensureConfigFolder()
    local configs = {}
    pcall(function()
        if typeof(listfiles) == "function" and typeof(isfolder) == "function" and isfolder(CONFIG_FOLDER) then
            local files = listfiles(CONFIG_FOLDER)
            if type(files) == "table" then
                for _, path in ipairs(files) do
                    local file = tostring(path):match("([^/\\]+)%.json$")
                    if file and file ~= "" then
                        table.insert(configs, file)
                    end
                end
            end
        end
    end)
    if #configs == 0 then
        table.insert(configs, "ไม่มีคอนฟิก")
    end
    return configs
end

local function saveConfig(name)
    if not name or name == "" or name == "ไม่มีคอนฟิก" then return false end
    ensureConfigFolder()
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local dataToSave = {
        AutoWave            = State.AutoWave,
        MinEggRarity        = State.MinEggRarity,
        SpecificEgg         = State.SpecificEgg,
        EggMutationFilter   = State.EggMutationFilter,
        PrioritizeMutations = State.PrioritizeMutations,
        WaveTarget          = State.WaveTarget,
        WaveDelay           = State.WaveDelay,
        AutoHatchEggs       = State.AutoHatchEggs,
        AutoSellSpecificEgg = State.AutoSellSpecificEgg,
        SellEggRarity       = State.SellEggRarity,
        SellTargetEgg       = State.SellEggRarity,
        AutoEquipBest       = State.AutoEquipBest,
        AutoSellAnimals     = State.AutoSellAnimals,
        AutoHuntEventBoss   = State.AutoHuntEventBoss,
        AutoCollectStars    = State.AutoCollectStars,
        ShowStarEventHud    = State.ShowStarEventHud,
        AutoOfflineCash     = State.AutoOfflineCash,
        AutoTrain           = State.AutoTrain,
        AutoClaimBonus      = State.AutoClaimBonus,
        AutoBuyDumbbell     = State.AutoBuyDumbbell,
        AutoBuyStaff        = State.AutoBuyStaff,
        AutoUpgradePlot     = State.AutoUpgradePlot,
        AutoUpgradeSpeed    = State.AutoUpgradeSpeed,
        AutoUpgradeCarry    = State.AutoUpgradeCarry,
        AutoRebirth         = State.AutoRebirth,
        TargetRebirth       = State.TargetRebirth,
        AutoPlaytimeGifts   = State.AutoPlaytimeGifts,
        AutoDailyRewards    = State.AutoDailyRewards,
        AutoFreeShop        = State.AutoFreeShop,
        AutoSpinWheel       = State.AutoSpinWheel,
        AutoGroupReward     = State.AutoGroupReward,
        AutoSeasonPass      = State.AutoSeasonPass,
        AutoQuests          = State.AutoQuests,
        AutoUsePotions      = State.AutoUsePotions,
        AutoUseTrainPotion  = State.AutoUseTrainPotion,
        AutoUseCashPotion   = State.AutoUseCashPotion,
        AutoUseLuckPotion   = State.AutoUseLuckPotion,
        AntiAFK             = State.AntiAFK,
        FPSBoost            = State.FPSBoost,
        CustomSpeedEnabled  = State.CustomSpeedEnabled,
        CustomSpeedValue    = State.CustomSpeedValue,
        CustomJumpEnabled   = State.CustomJumpEnabled,
        CustomJumpValue     = State.CustomJumpValue,
        InfiniteJump        = State.InfiniteJump,
        Noclip              = State.Noclip,
        AutoBulkTrade       = State.AutoBulkTrade,
        AutoAcceptGifts     = State.AutoAcceptGifts,
        TradeFilterAnimals  = State.TradeFilterAnimals,
        TradeFilterAnimal   = State.TradeFilterAnimal,
        TradeQuantity       = State.TradeQuantity,
        TradeSpeedDelay     = State.TradeSpeedDelay,
        TradeInstantBurst   = State.TradeInstantBurst,
    }
    local ok = pcall(function()
        if typeof(writefile) == "function" then
            writefile(path, HttpService:JSONEncode(dataToSave))
        end
    end)
    return ok
end

local function loadConfig(name)
    if not name or name == "" or name == "ไม่มีคอนฟิก" then return false end
    ensureConfigFolder()
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if typeof(isfile) ~= "function" or not isfile(path) then return false end
    local ok, content = pcall(function() return readfile(path) end)
    if not ok or not content then return false end
    local parseOk, parsed = pcall(function() return HttpService:JSONDecode(content) end)
    if not parseOk or type(parsed) ~= "table" then return false end

    for key, val in pairs(parsed) do
        if State[key] ~= nil then
            State[key] = val
            if UIControls[key] then
                pcall(function()
                    if UIControls[key].SetValue then
                        UIControls[key]:SetValue(val)
                    end
                end)
            end
        end
    end
    if parsed.SellTargetEgg and not parsed.SellEggRarity then
        State.SellEggRarity = parsed.SellTargetEgg
        if UIControls.SellEggRarity then
            pcall(function() UIControls.SellEggRarity:SetValue(parsed.SellTargetEgg) end)
        end
    end
    if parsed.InfiniteJump ~= nil then
        State.InfiniteJump = parsed.InfiniteJump
        if updateInfiniteJump then updateInfiniteJump() end
    end
    if parsed.Noclip ~= nil then
        State.Noclip = parsed.Noclip
        if updateNoclip then updateNoclip() end
    end
    return true
end

local function deleteConfig(name)
    if not name or name == "" then return false end
    ensureConfigFolder()
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile(path) then
        return pcall(function() delfile(path) end)
    end
    return false
end

-- ── 8. FLUENT UI INITIALIZATION (FAST CACHED MIRROR) ──────────────────────────────
local Fluent
pcall(function()
    if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile("2K_Fluent.lua") then
        local cached = readfile("2K_Fluent.lua")
        if cached and #cached > 100000 then
            Fluent = loadstring(cached)()
        end
    end
end)
if not Fluent then
    local urls = {
        "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/fluent.lua",
        "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
    }
    for _, u in ipairs(urls) do
        local ok, src = pcall(game.HttpGet, game, u)
        if ok and src and #src > 100000 then
            pcall(function()
                if typeof(writefile) == "function" then
                    writefile("2K_Fluent.lua", src)
                end
            end)
            local fn = loadstring(src)
            if fn then Fluent = fn(); break end
        end
    end
end
if not Fluent then
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end
_G.OpenSeaFluent = Fluent

-- Hook Creator for Strict Bold Typography
local uv = debug.getupvalues(Fluent.SetTheme)
local creator = uv[2]
local uvTheme = debug.getupvalues(creator.GetThemeProperty)
local themeTable = uvTheme[1]

local origNew = creator.New
creator.New = function(className, properties, children)
    if properties and (className == "TextLabel" or className == "TextBox" or className == "TextButton") then
        pcall(function()
            properties.Font = Enum.Font.GothamBold
            if properties.TextSize and properties.TextSize <= 12 then
                properties.TextSize = 13
            end
            if properties.TextTransparency and properties.TextTransparency > 0.25 then
                properties.TextTransparency = 0.15
            end
        end)
    end
    return origNew(className, properties, children)
end

themeTable["2K_Frost"] = {
    Name = "2K_Frost",
    Accent = Color3.fromRGB(0, 240, 255),
    AcrylicMain = Color3.fromRGB(9, 15, 26),
    AcrylicBorder = Color3.fromRGB(0, 210, 255),
    AcrylicGradient = ColorSequence.new(
        Color3.fromRGB(14, 24, 42),
        Color3.fromRGB(6, 11, 20)
    ),
    AcrylicNoise = 0.94,
    Element = Color3.fromRGB(18, 30, 48),
    ElementBorder = Color3.fromRGB(0, 180, 255),
    InElementBorder = Color3.fromRGB(0, 220, 255),
    ElementTransparency = 0.65,
    ToggleSlider = Color3.fromRGB(0, 240, 255),
    ToggleToggled = Color3.fromRGB(255, 255, 255),
    SliderRail = Color3.fromRGB(0, 220, 255),
    DropdownHolder = Color3.fromRGB(14, 24, 42),
    DropdownBorder = Color3.fromRGB(0, 180, 255),
    DropdownOption = Color3.fromRGB(24, 42, 68),
    DropdownFrame = Color3.fromRGB(0, 220, 255),
    Input = Color3.fromRGB(20, 34, 56),
    InputFocused = Color3.fromRGB(32, 56, 90),
    InputIndicator = Color3.fromRGB(0, 240, 255),
    Dialog = Color3.fromRGB(14, 24, 42),
    DialogHolder = Color3.fromRGB(10, 17, 30),
    DialogHolderLine = Color3.fromRGB(0, 180, 255),
    DialogBorder = Color3.fromRGB(0, 210, 255),
    DialogButton = Color3.fromRGB(22, 38, 62),
    DialogButtonBorder = Color3.fromRGB(0, 180, 255),
    DialogInput = Color3.fromRGB(18, 32, 52),
    DialogInputLine = Color3.fromRGB(0, 220, 255),
    TitleBarLine = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(190, 235, 255),
    Hover = Color3.fromRGB(35, 60, 96),
    HoverChange = 0.05,
    Keybind = Color3.fromRGB(28, 48, 78),
    Tab = Color3.fromRGB(0, 220, 255)
}
if not table.find(Fluent.Themes, "2K_Frost") then
    table.insert(Fluent.Themes, "2K_Frost")
end

-- ── 2K CYBER NEON LOGO EMBEDDING ────────────────────────────────────────────────
local LOGO_B64 = "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"
local function get2KLogoAsset()
    local fileName = "2k_logo_transparent.png"
    pcall(function()
        local crypt = crypt or (syn and syn.crypt)
        local b64decode = (crypt and (crypt.base64decode or crypt.base64_decode))
            or (base64 and (base64.decode or base64_decode))
            or (syn and syn.crypt and syn.crypt.base64_decode)
        if b64decode and writefile then
            local decoded = b64decode(LOGO_B64)
            if not isfile or not isfile(fileName) or (readfile and #readfile(fileName) ~= #decoded) then
                writefile(fileName, decoded)
            end
        end
    end)
    local getAsset = getcustomasset or getsynasset
    if getAsset and isfile and isfile(fileName) then
        local ok, asset = pcall(function() return getAsset(fileName) end)
        if ok and asset then return asset end
    end
    return nil
end

local Window = Fluent:CreateWindow({
    Title       = "2K Script",
    SubTitle    = "Open Sea For Animals | discord.gg/4Yg72kYT6s",
    TabWidth    = 165,
    Size        = UDim2.fromOffset(590, 450),
    Acrylic     = false,
    Theme       = "2K_Frost",
    MinimizeKey = Enum.KeyCode.RightControl
})
_G.OpenSeaWindow = Window

-- Guarantee Window ScreenGui has a valid Parent in CoreGui / gethui
pcall(function()
    local gui = Window.Root and Window.Root.Parent
    if gui and gui:IsA("ScreenGui") and (not gui.Parent or gui.Parent == nil) then
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        gui.Parent = (ok and cg) or (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Anti-Blank & CanvasGroup Persistence Protector (Guarantees tabs never disappear or turn invisible)
pcall(function()
    if Window.ContainerHolder then
        Window.ContainerHolder.GroupTransparency = 0
        Window.ContainerHolder.Position = UDim2.fromOffset(165 + 26, 94)
        local transConn = Window.ContainerHolder:GetPropertyChangedSignal("GroupTransparency"):Connect(function()
            if Window.ContainerHolder.GroupTransparency > 0.01 then
                Window.ContainerHolder.GroupTransparency = 0
            end
        end)
        table.insert(_conns, transConn)
        local visConn = Window.ContainerHolder:GetPropertyChangedSignal("Visible"):Connect(function()
            if not Window.ContainerHolder.Visible then
                Window.ContainerHolder.Visible = true
            end
        end)
        table.insert(_conns, visConn)
    end
end)

-- Prevent full-screen maximize glitch
pcall(function()
    if Window.TitleBar and Window.TitleBar.MaxButton and Window.TitleBar.MaxButton.Frame then
        Window.TitleBar.MaxButton.Frame.Visible = false
    end
end)

-- TitleBar 2K Glowing Logo Icon
pcall(function()
    local logoAsset = get2KLogoAsset()
    if logoAsset and Window.TitleBar and Window.TitleBar.Frame then
        local tb = Window.TitleBar.Frame
        local tbLogo = Instance.new("ImageLabel")
        tbLogo.Name = "TitleBar2KLogo"
        tbLogo.Size = UDim2.fromOffset(24, 24)
        tbLogo.Position = UDim2.new(0, 10, 0.5, -12)
        tbLogo.BackgroundTransparency = 1
        tbLogo.ScaleType = Enum.ScaleType.Fit
        tbLogo.Image = logoAsset
        tbLogo.ZIndex = 10
        tbLogo.Parent = tb

        for _, desc in ipairs(tb:GetChildren()) do
            if desc:IsA("Frame") and desc ~= tbLogo and desc.Position.X.Offset < 36 then
                desc.Position = UDim2.new(0, 38, desc.Position.Y.Scale, desc.Position.Y.Offset)
            end
        end
    end
end)

-- Main Window Animated Rotating Border (Clean Glass - NO ugly outer glow!)
pcall(function()
    local bgFrame = Window.Root and Window.Root:GetChildren()[1]
    if bgFrame then
        local windowStroke = Instance.new("UIStroke")
        windowStroke.Name = "NeonCyberBorder"
        windowStroke.Thickness = 1.8
        windowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local windowGrad = Instance.new("UIGradient")
        windowGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 245, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(175, 0, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 180)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 245, 255))
        })
        windowGrad.Parent = windowStroke
        windowStroke.Parent = bgFrame
        
        local winRotConn = RunService.RenderStepped:Connect(function()
            if windowGrad and windowGrad.Parent then
                windowGrad.Rotation = (windowGrad.Rotation + 1.8) % 360
            end
        end)
        table.insert(_conns, winRotConn)
    end
end)

-- ── 9. ROCK-SOLID TOGGLE ENGINE (DEBOUNCED & NATIVE MINIMIZE) ──────────────────────
local lastToggleTick = 0
local function toggleUI()
    local now = tick()
    if now - lastToggleTick < 0.35 then return end
    lastToggleTick = now
    
    pcall(function()
        if not Window or not Window.Root then return end
        local gui = Window.Root
        while gui and not gui:IsA("ScreenGui") do
            gui = gui.Parent
        end
        if gui then
            if not gui.Parent then
                local ok, cg = pcall(function() return game:GetService("CoreGui") end)
                gui.Parent = (ok and cg) or (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")
            end
            gui.Enabled = true
        end
        
        if Window.Minimized then
            Window:Minimize() -- Smooth native restore
        elseif not Window.Root.Visible then
            Window:Minimize()
        else
            Window:Minimize() -- Smooth native minimize
        end

        -- Safeguard: Ensure no Acrylic blur parts linger in Camera when minimized
        if Window.Minimized or not Window.Root.Visible then
            pcall(function()
                if Window.AcrylicPaint and Window.AcrylicPaint.Model then
                    Window.AcrylicPaint.Model.Transparency = 1
                end
                local cam = workspace.CurrentCamera
                if cam then
                    for _, child in ipairs(cam:GetChildren()) do
                        if child.Name:find("Acrylic") or child.Name:find("DepthOfField") then
                            pcall(function() child:Destroy() end)
                        end
                    end
                end
            end)
        end
    end)
end

-- Keybind support (F4 as quick toggle)
local keyConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F4 then
        toggleUI()
    end
end)
table.insert(_conns, keyConn)

-- ── 10. PERSISTENT 2K MINI FLOATING CYBER BADGE (CLEAN TRANSPARENT BG) ─────────────
local function getGuiContainer()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg and cg.ClassName == "CoreGui" then
        return cg
    end
    if gethui then
        local ok2, h = pcall(gethui)
        if ok2 and h then
            if h:IsA("ScreenGui") and h.Parent then
                return h.Parent
            end
            return h
        end
    end
    return LP:WaitForChild("PlayerGui")
end

local minGui = Instance.new("ScreenGui")
minGui.Name = "OpenSeaMiniButton_2K"
minGui.ResetOnSpawn = false
minGui.DisplayOrder = 2147483647 -- Always on top of all game & core GUIs
minGui.IgnoreGuiInset = true
minGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
minGui.Parent = getGuiContainer()
_G.OpenSeaMinGui = minGui

-- Cyber Button Frame (Clean Dark Glass - NO UGLY SQUARES)
local minBtn = Instance.new("TextButton")
minBtn.Name = "MiniPill"
minBtn.Size = UDim2.fromOffset(66, 66)
minBtn.Position = UDim2.new(0, 32, 0.5, -33)
minBtn.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
minBtn.BorderSizePixel = 0
minBtn.Text = ""
minBtn.AutoButtonColor = false
minBtn.Active = true
minBtn.ClipsDescendants = true
minBtn.ZIndex = 2
minBtn.Parent = minGui

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 18)
minCorner.Parent = minBtn

local minBgGrad = Instance.new("UIGradient")
minBgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 45, 78)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 20, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 10, 18))
})
minBgGrad.Rotation = 45
minBgGrad.Parent = minBtn

local minStroke = Instance.new("UIStroke")
minStroke.Thickness = 2.2
minStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
minStroke.Color = Color3.fromRGB(255, 255, 255)
minStroke.Parent = minBtn

local strokeGrad = Instance.new("UIGradient")
strokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 245, 255)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(175, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 245, 255))
})
strokeGrad.Parent = minStroke

-- Rotating animated cyber neon stroke
local strokeRotConn = RunService.RenderStepped:Connect(function()
    if strokeGrad and strokeGrad.Parent then
        strokeGrad.Rotation = (strokeGrad.Rotation + 2.5) % 360
    end
end)
table.insert(_conns, strokeRotConn)

local logoAsset = get2KLogoAsset()
if logoAsset then
    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "LogoImage"
    logoImg.Size = UDim2.new(1, -6, 1, -6)
    logoImg.Position = UDim2.new(0, 3, 0, 3)
    logoImg.BackgroundTransparency = 1
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.Image = logoAsset
    logoImg.ZIndex = 4
    logoImg.Parent = minBtn

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 16)
    logoCorner.Parent = logoImg
else
    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, 0, 0, 32)
    logoText.Position = UDim2.new(0, 0, 0, 8)
    logoText.BackgroundTransparency = 1
    logoText.RichText = true
    logoText.Text = '<font color="#FFFFFF">2</font><font color="#00F0FF">K</font>'
    logoText.TextSize = 28
    logoText.Font = Enum.Font.GothamBlack
    logoText.ZIndex = 4
    logoText.Parent = minBtn

    local subBadge = Instance.new("TextLabel")
    subBadge.Name = "ProBadge"
    subBadge.Size = UDim2.new(1, 0, 0, 14)
    subBadge.Position = UDim2.new(0, 0, 1, -20)
    subBadge.BackgroundTransparency = 1
    subBadge.Text = "PRO HUB"
    subBadge.TextColor3 = Color3.fromRGB(0, 220, 255)
    subBadge.TextSize = 9
    subBadge.Font = Enum.Font.GothamBold
    subBadge.ZIndex = 4
    subBadge.Parent = minBtn
end

local dot = Instance.new("Frame")
dot.Name = "LedDot"
dot.Size = UDim2.fromOffset(8, 8)
dot.Position = UDim2.new(1, -15, 0, 8)
dot.BackgroundColor3 = Color3.fromRGB(0, 255, 190)
dot.BorderSizePixel = 0
dot.ZIndex = 5
dot.Parent = minBtn

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local dotStroke = Instance.new("UIStroke")
dotStroke.Thickness = 1.2
dotStroke.Color = Color3.fromRGB(0, 255, 230)
dotStroke.Transparency = 0.2
dotStroke.Parent = dot

-- Breathing LED pulse animation
local dotTween = TweenService:Create(dot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    BackgroundColor3 = Color3.fromRGB(0, 140, 255),
    Size = UDim2.fromOffset(10, 10),
    Position = UDim2.new(1, -16, 0, 7)
})
dotTween:Play()

-- Interactive Hover animations
minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(72, 72)
    }):Play()
end)

minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(66, 66)
    }):Play()
end)

-- Custom High-Reliability Draggable + Click Detection
local isDragging = false
local dragStartPos = nil
local btnStartPos = nil
local hasMoved = false
local downTime = 0

minBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
        btnStartPos = minBtn.Position
        hasMoved = false
        downTime = tick()
        
        TweenService:Create(minBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(60, 60)
        }):Play()
    end
end)

local dragChangeConn = UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
            hasMoved = true
            minBtn.Position = UDim2.new(
                btnStartPos.X.Scale,
                btnStartPos.X.Offset + delta.X,
                btnStartPos.Y.Scale,
                btnStartPos.Y.Offset + delta.Y
            )
        end
    end
end)
table.insert(_conns, dragChangeConn)

local function onRelease()
    if isDragging then
        isDragging = false
        TweenService:Create(minBtn, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(66, 66)
        }):Play()
        
        if not hasMoved and (tick() - downTime) < 0.5 then
            toggleUI()
        end
    end
end

local dragEndConn = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        onRelease()
    end
end)
table.insert(_conns, dragEndConn)

minBtn.Activated:Connect(function()
    if not hasMoved then
        toggleUI()
    end
end)

-- ── 10. TABS & UI CONTROLS ───────────────────────────────────────────────────────
local Tabs = {
    Main        = Window:AddTab({ Title = "หน้าหลัก", Icon = "home" }),
    Progression = Window:AddTab({ Title = "อัปเกรด & จุติ", Icon = "trending-up" }),
    Trade       = Window:AddTab({ Title = "ส่งต่อ & เทรด", Icon = "repeat" }),
    Rewards     = Window:AddTab({ Title = "ของรางวัล", Icon = "gift" }),
    Misc        = Window:AddTab({ Title = "วาร์ป & ทั่วไป", Icon = "navigation" }),
    Settings    = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
}
_G.OpenSeaTabs = Tabs

-- Hook each Tab to guarantee elements render on all executors
pcall(function()
    for _, tabObj in pairs(Tabs) do
        if tabObj and tabObj.Frame then
            local btn = tabObj.Frame
            local cConn = btn.MouseButton1Click:Connect(function()
                pcall(function()
                    if Window.ContainerHolder then
                        Window.ContainerHolder.GroupTransparency = 0
                        Window.ContainerHolder.Position = UDim2.fromOffset(165 + 26, 94)
                    end
                end)
                task.delay(0.18, function()
                    pcall(function()
                        if Window.ContainerHolder then
                            Window.ContainerHolder.GroupTransparency = 0
                            Window.ContainerHolder.Position = UDim2.fromOffset(165 + 26, 94)
                        end
                        if tabObj.Container then
                            tabObj.Container.Visible = true
                            local layout = tabObj.Container:FindFirstChildOfClass("UIListLayout")
                            if layout then
                                tabObj.Container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 35)
                            end
                        end
                    end)
                end)
            end)
            table.insert(_conns, cConn)
        end
    end
end)

local function formatNum(n)
    if not n or type(n) ~= "number" then return "0" end
    if n >= 1e12 then return string.format("%.2fT", n / 1e12) end
    if n >= 1e9  then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6  then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3  then return string.format("%.1fK", n / 1e3) end
    return string.format("%.0f", n)
end

-- ─────────────────────────────────────────────────────────────────────────────────
-- TAB 1: MAIN (แดชบอร์ด & ล่าสัตว์ทะเล)
-- ─────────────────────────────────────────────────────────────────────────────────
Tabs.Main:AddSection("สถานะและข้อมูลสด (Live Dashboard)")

local statusDashboard = Tabs.Main:AddParagraph({
    Title = "[ 2K STATUS DASHBOARD ]",
    Content = "กำลังเชื่อมต่อและโหลดข้อมูลผู้เล่น..."
})
if statusDashboard.TitleLabel then
    statusDashboard.TitleLabel.TextColor3 = Color3.fromRGB(0, 245, 255)
end

local function formatSeconds(sec)
    if not sec or sec <= 0 then return "00:00" end
    local m = math.floor(sec / 60)
    local s = math.floor(sec % 60)
    if m >= 60 then
        local h = math.floor(m / 60)
        m = m % 60
        return string.format("%02d:%02d:%02d", h, m, s)
    end
    return string.format("%02d:%02d", m, s)
end

task.spawn(function()
    while _G.OpenSeaRunning and _G.OpenSeaRunId == thisRunId do
        pcall(function()
            local cash = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Cash") and LP.leaderstats.Cash.Value or 0
            local power = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Power") and LP.leaderstats.Power.Value or 0
            local speed = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Speed") and LP.leaderstats.Speed.Value or 16
            
            local farmText = State.AutoWave and "ONLINE (ACTIVE)" or "STANDBY (IDLE)"
            local targetEgg = State.SpecificEgg or "ทั้งหมด"
            local minRarity = State.MinEggRarity or "ทุกระดับ"

            local activeEvents = RS:FindFirstChild("ActiveEvents")
            local activeEvText = "ไม่มี (Normal)"
            if activeEvents and #activeEvents:GetChildren() > 0 then
                local evNames = {}
                for _, ev in ipairs(activeEvents:GetChildren()) do
                    table.insert(evNames, ev.Name)
                end
                activeEvText = table.concat(evNames, ", ") .. " (ACTIVE!)"
            end

            local nwt = RS:FindFirstChild("NextWeatherTime")
            local nextEvTimer = (nwt and nwt.Value and nwt.Value > 0) and formatSeconds(nwt.Value) or "N/A"
            
            local descText = string.format(
                " [ผู้เล่น] %s  |  [สถานะบอท] %s\n" ..
                " [เงินสด] $%s  |  [พลังฝึก] %s  |  [ความเร็ว] %s\n" ..
                " [ล่าสัตว์ทะเล] %s  |  [โหมด] Packet Sniping\n" ..
                " [เป้าหมายไข่] %s  |  [ขั้นต่ำ] %s\n" ..
                " [บอสอีเวนต์] %s  |  [อีเวนต์ถัดไป] ใน %s\n" ..
                " [กลายพันธุ์] %s  |  [ระบบกันหลุด 24 ชม.] ทำงานปกติ",
                LP.DisplayName or LP.Name, farmText,
                formatNum(cash), formatNum(power), tostring(speed),
                State.AutoWave and "เปิดใช้งาน" or "ปิดใช้งาน",
                tostring(targetEgg), tostring(minRarity),
                tostring(activeEvText), tostring(nextEvTimer),
                State.PrioritizeMutations and "เน้นเก็บอันดับ 1" or "ปกติ"
            )

            if statusDashboard then
                pcall(function() statusDashboard:SetDesc(descText) end)
                if statusDashboard.DescLabel then
                    pcall(function() statusDashboard.DescLabel.Text = descText end)
                end
            end
        end)
        task.wait(1)
    end
end)

Tabs.Main:AddSection("ล่าสัตว์ในทะเล (Sea Wave & Hunting)")

UIControls.AutoWave = Tabs.Main:AddToggle("AutoWave", {
    Title = "ล่าสัตว์ในทะเลอัตโนมัติ (Auto Sea Wave)",
    Description = "เปิดระบบล่าสัตว์และไข่ในทะเลอัตโนมัติตามโหมดที่เลือก",
    Default = State.AutoWave,
    Callback = function(val) State.AutoWave = val end
})

UIControls.AutoHuntEventBoss = Tabs.Main:AddToggle("AutoHuntEventBoss", {
    Title = "ล่าบอสอีเวนต์อัตโนมัติ (Auto Hunt Event Boss)",
    Description = "ล่า Dragon Egg จากบอส Devil / Zeus และล่าบอส 5 อัตโนมัติ",
    Default = State.AutoHuntEventBoss,
    Callback = function(val) State.AutoHuntEventBoss = val end
})

Tabs.Main:AddButton({
    Title = "เช็คเวลาบอสอีเวนต์ (Check Event Schedule)",
    Description = "ดูเวลานับถอยหลังของอีเวนต์และบอสถัดไป",
    Callback = function()
        local nwt = RS:FindFirstChild("NextWeatherTime")
        local WeatherUtils = nil
        pcall(function() WeatherUtils = safeRequire(RS.Shared:FindFirstChild("WeatherUtils")) end)
        local baseEv = WeatherUtils and WeatherUtils.GetActiveBaseEvent and WeatherUtils.GetActiveBaseEvent()
        local timeStr = (nwt and nwt.Value and AbbreviationUtils) and AbbreviationUtils:AbbreviateTime(nwt.Value) or "เร็วๆ นี้"
        local title = baseEv and ("บอส " .. baseEv .. " กำลังทำงาน!") or "ตารางอีเวนต์"
        local desc = baseEv and "บอสอีเวนต์เปิดอยู่บนเซิร์ฟเวอร์ ระบบพร้อมเข้าตี!" or ("อีเวนต์ถัดไปจะเริ่มในอีก: " .. timeStr)
        Fluent:Notify({ Title = title, Content = desc, Duration = 4 })
    end
})

UIControls.MinEggRarity = Tabs.Main:AddDropdown("MinEggRarity", {
    Title = "ระดับไข่ขั้นต่ำ (Min Egg Rarity)",
    Description = "กรองเฉพาะไข่ระดับที่ต้องการขึ้นไปเท่านั้น",
    Values = {
        "ทุกระดับ (All Eggs - Common+)",
        "Uncommon ขึ้นไป (Frog+)",
        "Rare ขึ้นไป (Bat+)",
        "Epic ขึ้นไป (Tiger+)",
        "Legendary ขึ้นไป (Trex+)",
        "Mythic ขึ้นไป (Snails+)",
        "Divine ขึ้นไป (Capybara+)",
        "Secret ขึ้นไป (Ostrich+)",
        "Cosmic ขึ้นไป (Snake+)",
        "Eternal ขึ้นไป (Sphinx+)",
        "SPECIAL ขึ้นไป (Dragon / Polarbear+)",
        "CYBER ขึ้นไป (Gorilla+)",
        "LAW ขึ้นไป (Mamut+)",
        "Titanium ขึ้นไป (Ocean+)",
        "Magical ขึ้นไป (Corals+)",
        "Nightfall ขึ้นไป (Sleepy+)",
        "Frosty ขึ้นไป (Glacial+)",
        "Lightning ขึ้นไป (Volt+)"
    },
    Default = State.MinEggRarity,
    Callback = function(val) State.MinEggRarity = val end
})

local specificEggList = { "ทั้งหมด (All Available)" }
for _, name in ipairs(ALL_EGG_DISPLAY_NAMES) do
    table.insert(specificEggList, name)
end

UIControls.SpecificEgg = Tabs.Main:AddDropdown("SpecificEgg", {
    Title = "เจาะจงชนิดไข่ (Target Specific Egg)",
    Description = "เลือกเจาะจงไข่สายพันธุ์ที่ต้องการ หรือเลือกทั้งหมด",
    Values = specificEggList,
    Default = State.SpecificEgg,
    Callback = function(val) State.SpecificEgg = val end
})

local EggMutationOptions = {
    "ทั้งหมด (All Status)",
    "เฉพาะตัวกลายพันธุ์ (Any Mutation)",
    "Normal (ธรรมดา)",
    "Gold (ทอง)",
    "Diamond (เพชร)",
    "Radioactive (กัมมันตรังสี)",
    "Rainbow (สายรุ้ง)"
}

UIControls.EggMutationFilter = Tabs.Main:AddDropdown("EggMutationFilter", {
    Title = "เลือกสถานะไข่ (Egg Mutation Filter - เลือกได้มากกว่า 1)",
    Description = "ติ๊กเลือกสถานะไข่ที่ต้องการเก็บหลายสถานะพร้อมกัน หรือเลือกทั้งหมด",
    Values = EggMutationOptions,
    Multi = true,
    Default = State.EggMutationFilter or { ["ทั้งหมด (All Status)"] = true },
    Callback = function(val) State.EggMutationFilter = val end
})

UIControls.PrioritizeMutations = Tabs.Main:AddToggle("PrioritizeMutations", {
    Title = "เน้นตัวกลายพันธุ์ (Prioritize Mutations)",
    Description = "จัดลำดับความสำคัญสูงสุดให้ไข่หรือสัตว์ที่กลายพันธุ์",
    Default = State.PrioritizeMutations,
    Callback = function(val) State.PrioritizeMutations = val end
})

UIControls.WaveDelay = Tabs.Main:AddSlider("WaveDelay", {
    Title = "หน่วงเวลาเปิดคลื่น (Wave Delay)",
    Description = "ระยะเวลารอระหว่างรอบการเปิดคลื่นทะเล (วินาที)",
    Default = State.WaveDelay,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(val) State.WaveDelay = val end
})

Tabs.Main:AddSection("อีเวนต์ดวงดาว (Stars Event & Magnet)")

UIControls.AutoCollectStars = Tabs.Main:AddToggle("AutoCollectStars", {
    Title = "ดูดเก็บดาวอัตโนมัติ (Auto Collect Stars Magnet)",
    Description = "ดูดดาวตกทั่วแผนที่เข้าตัวและปลดล็อครางวัลไมล์สโตนอัตโนมัติ",
    Default = State.AutoCollectStars,
    Callback = function(val) State.AutoCollectStars = val end
})

Tabs.Main:AddButton({
    Title = "ดูดเก็บดาวตอนนี้ทันที (Collect Stars Now)",
    Description = "ดูดดาวที่เกิดอยู่บนแผนที่รอบนี้เข้าตัวทันที",
    Callback = function()
        local count = 0
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local pickupsFolder = workspace:FindFirstChild("CollectEventPickups")
        if pickupsFolder and hrp then
            for _, model in ipairs(pickupsFolder:GetChildren()) do
                if model:IsA("Model") and model.Parent then
                    local eventId, id = model.Name:match("^([%w_]+)_(%w+)$")
                    if not eventId then eventId = "STARS" id = model.Name:match("%d+") end
                    pcall(function()
                        model:PivotTo(hrp.CFrame)
                        for _, part in ipairs(model:GetDescendants()) do
                            if part:IsA("BasePart") then part.CFrame = hrp.CFrame end
                        end
                    end)
                    if id and CollectEventService and CollectEventService.RF and CollectEventService.RF.Collect then
                        pcall(function()
                            CollectEventService.RF.Collect:InvokeServer(eventId or "STARS", tonumber(id) or id)
                        end)
                    end
                    count = count + 1
                    task.wait(0.06)
                end
            end
        end
        Fluent:Notify({
            Title = "ดูดดาวสำเร็จ",
            Content = string.format("ดูดเก็บดาวเข้าตัวทั้งหมด %d ดวงเรียบร้อย", count),
            Duration = 3
        })
    end
})

UIControls.ShowStarEventHud = Tabs.Main:AddToggle("ShowStarEventHud", {
    Title = "เปิด/ปิด ป้ายรางวัลดาว (Toggle Stars HUD)",
    Description = "แสดงหรือซ่อนแถบของรางวัลและแต้มดาวสะสมบนหน้าจอ",
    Default = State.ShowStarEventHud,
    Callback = function(val)
        State.ShowStarEventHud = val
        pcall(function()
            local starEvent = LP.PlayerGui.HUD:FindFirstChild("StarEvent")
            if starEvent then
                starEvent.Visible = val
            end
        end)
    end
})

Tabs.Main:AddButton({
    Title = "สลับเปิด/ปิด ป้ายรางวัลดาว (Toggle Stars HUD)",
    Description = "กดเพื่อสลับการแสดงผลป้ายรางวัลอีเวนต์ดาวบนหน้าจอทันที",
    Callback = function()
        pcall(function()
            local starEvent = LP.PlayerGui.HUD:FindFirstChild("StarEvent")
            if starEvent then
                starEvent.Visible = not starEvent.Visible
                State.ShowStarEventHud = starEvent.Visible
                if UIControls.ShowStarEventHud then
                    pcall(function() UIControls.ShowStarEventHud:SetValue(starEvent.Visible) end)
                end
                Fluent:Notify({
                    Title = "ป้ายรางวัลอีเวนต์ดาว",
                    Content = starEvent.Visible and "เปิดการแสดงผลป้ายรางวัลเรียบร้อย" or "ซ่อนป้ายรางวัลเรียบร้อย",
                    Duration = 2.5
                })
            end
        end)
    end
})

Tabs.Main:AddSection("ขายไข่ตามระดับ (Sell Eggs by Rarity)")

local SellEggRarityOptions = {
    "ทุกระดับ Common - Rare",
    "ทุกระดับ Common - Epic",
    "ทุกระดับ Common - Legendary",
    "Common (Basic)",
    "Uncommon (Frog)",
    "Rare (Bat)",
    "Epic (Tiger)",
    "Legendary (Trex)",
    "Mythic (Snails)",
    "Divine (Capybara)",
    "Secret (Ostrich)",
    "Cosmic (Snake)",
    "Eternal (Sphinx / Mouse)",
    "SPECIAL (Dragon / Polarbear / Seal...)",
    "CYBER (Gorilla)",
    "LAW (Mamut)",
    "Titanium (Ocean)",
    "Magical (Corals)",
    "Nightfall (Sleepy)",
    "Frosty (Glacial)",
    "Lightning (Volt)"
}

UIControls.SellEggRarity = Tabs.Main:AddDropdown("SellEggRarity", {
    Title = "เลือกระดับไข่ที่จะขาย (Select Rarity to Sell - เลือกได้มากกว่า 1)",
    Description = "ติ๊กเลือกระดับไข่ที่ต้องการขายได้หลายระดับพร้อมกัน",
    Values = SellEggRarityOptions,
    Multi = true,
    Default = State.SellEggRarity or { ["ทุกระดับ Common - Rare"] = true },
    Callback = function(val) State.SellEggRarity = val end
})

UIControls.AutoSellSpecificEgg = Tabs.Main:AddToggle("AutoSellSpecificEgg", {
    Title = "ขายไข่อัตโนมัติตามระดับ (Auto Sell by Rarity)",
    Description = "ขายไข่ระดับที่เลือกในกระเป๋าทันทีที่ได้รับมาเปลี่ยนเป็นเงินสด",
    Default = State.AutoSellSpecificEgg,
    Callback = function(val) State.AutoSellSpecificEgg = val end
})

Tabs.Main:AddButton({
    Title = "ขายไข่ระดับที่เลือกตอนนี้ (Sell Selected Rarity Now)",
    Description = "กดขายไข่ตามระดับที่เลือกจากกระเป๋าทันที 1 รอบ",
    Callback = function()
        local count = sellSelectedEggs()
        local rarityDisplay = "ที่เลือก"
        local curRarity = State.SellEggRarity or (UIControls.SellEggRarity and UIControls.SellEggRarity.Value)
        if type(curRarity) == "string" then
            rarityDisplay = curRarity
        elseif type(curRarity) == "table" then
            local picked = {}
            for k, v in pairs(curRarity) do
                if v == true or type(k) == "number" then
                    table.insert(picked, (type(k) == "string" and v == true) and k or tostring(v))
                end
            end
            if #picked > 0 then
                rarityDisplay = table.concat(picked, ", ")
            end
        end
        Fluent:Notify({
            Title = "ขายไข่สำเร็จ",
            Content = string.format("ขายไข่ระดับ '%s' ออกจากตัวทั้งหมด %d ฟองเรียบร้อยแล้ว", rarityDisplay, count),
            Duration = 3.5
        })
    end
})

Tabs.Main:AddSection("ฟักไข่และสัตว์ในลาน (Hatchery & Base Plot)")

UIControls.AutoHatchEggs = Tabs.Main:AddToggle("AutoHatchEggs", {
    Title = "ฟักไข่อัตโนมัติ (Auto Hatch Eggs)",
    Description = "วางไข่ลงลานและกดฟักตัวทันทีที่หมดเวลา",
    Default = State.AutoHatchEggs,
    Callback = function(val) State.AutoHatchEggs = val end
})

UIControls.AutoEquipBest = Tabs.Main:AddToggle("AutoEquipBest", {
    Title = "ใส่ตัวเก่งสุดอัตโนมัติ (Auto Equip Best)",
    Description = "สวมใส่ตัวคูณเงินสูงสุดลงแท่นตลอดเวลา",
    Default = State.AutoEquipBest,
    Callback = function(val) State.AutoEquipBest = val end
})

UIControls.AutoSellAnimals = Tabs.Main:AddToggle("AutoSellAnimals", {
    Title = "ขายสัตว์ที่ไม่ได้ใช้อัตโนมัติ (Auto Sell Unused)",
    Description = "ใส่ตัวเก่งสุดลงลานแล้วขายสัตว์ส่วนเกินในตัวทิ้งอัตโนมัติ",
    Default = State.AutoSellAnimals,
    Callback = function(val) State.AutoSellAnimals = val end
})

Tabs.Main:AddButton({
    Title = "ขายสัตว์ที่ไม่ได้ใช้ทันที (Sell Unused Now)",
    Description = "ใส่ตัวเก่งสุดลงลานแล้วล้างสัตว์ที่เหลือในตัวเป็นเงินสด",
    Callback = function()
        pcall(function()
            AnimalService.RF.EquipBest:InvokeServer()
            task.wait(0.25)
            InventoryService.RF.SellAllBrainrots:InvokeServer()
        end)
        Fluent:Notify({ Title = "ขายสัตว์สำเร็จ", Content = "ใส่ตัวเก่งสุดและขายสัตว์ที่เหลือเรียบร้อยแล้ว", Duration = 3 })
    end
})

UIControls.AutoOfflineCash = Tabs.Main:AddToggle("AutoOfflineCash", {
    Title = "ดูดเงินออฟไลน์อัตโนมัติ (Auto Offline Cash)",
    Description = "กดรับเงินสะสมออฟไลน์อัตโนมัติ",
    Default = State.AutoOfflineCash,
    Callback = function(val) State.AutoOfflineCash = val end
})

-- ─────────────────────────────────────────────────────────────────────────────────
-- TAB 2: PROGRESSION (ฝึกพลัง & อัปเกรด & จุติ)
-- ─────────────────────────────────────────────────────────────────────────────────
Tabs.Progression:AddSection("ฝึกพลังและอุปกรณ์ (Power Training & Gears)")

UIControls.AutoTrain = Tabs.Progression:AddToggle("AutoTrain", {
    Title = "ฝึกพลังอัตโนมัติ (Auto Train Power)",
    Description = "ปั๊มค่าพลังในพื้นหลัง เดินไปไหนมาไหนได้อิสระ ไม่ล็อกตัว",
    Default = State.AutoTrain,
    Callback = function(val)
        State.AutoTrain = val
        if not val then
            stopTraining()
        end
    end
})

Tabs.Progression:AddButton({
    Title = "หยุดยกดัมเบลทันที (Stop Training Now)",
    Description = "หยุดยกดัมเบลและเก็บโมเดลออกจากมือทันที",
    Callback = function()
        State.AutoTrain = false
        if UIControls.AutoTrain then
            UIControls.AutoTrain:SetValue(false)
        end
        stopTraining()
        Fluent:Notify({ Title = "หยุดฝึกพลัง", Content = "เก็บดัมเบลและหยุดการฝึกพลังเรียบร้อยแล้ว", Duration = 3 })
    end
})

UIControls.AutoClaimBonus = Tabs.Progression:AddToggle("AutoClaimBonus", {
    Title = "กดรับบัฟ X2 อัตโนมัติ (Auto Claim X2 Bonus)",
    Description = "กดรับพลังฝึกคูณสองทันทีที่โบนัสโผล่มา",
    Default = State.AutoClaimBonus,
    Callback = function(val) State.AutoClaimBonus = val end
})

UIControls.AutoBuyDumbbell = Tabs.Progression:AddToggle("AutoBuyDumbbell", {
    Title = "ซื้อดัมเบลที่ดีที่สุด (Auto Buy Dumbbell)",
    Description = "อัปเกรดดัมเบลขั้นถัดไปอัตโนมัติเมื่อเงินพอ",
    Default = State.AutoBuyDumbbell,
    Callback = function(val) State.AutoBuyDumbbell = val end
})

UIControls.AutoBuyStaff = Tabs.Progression:AddToggle("AutoBuyStaff", {
    Title = "ซื้อคทาที่ดีที่สุด (Auto Buy Staff)",
    Description = "ซื้อคทาขยายระยะและเพิ่มดวงอัตโนมัติ",
    Default = State.AutoBuyStaff,
    Callback = function(val) State.AutoBuyStaff = val end
})

Tabs.Progression:AddSection("อัปเกรดตัวละครและลาน (Character & Plot Upgrades)")

UIControls.AutoUpgradePlot = Tabs.Progression:AddToggle("AutoUpgradePlot", {
    Title = "อัปเกรดช่องสัตว์ (Auto Upgrade Plot)",
    Description = "ขยายพื้นที่วางสัตว์บนลานเพิ่มรายได้",
    Default = State.AutoUpgradePlot,
    Callback = function(val) State.AutoUpgradePlot = val end
})

UIControls.AutoUpgradeSpeed = Tabs.Progression:AddToggle("AutoUpgradeSpeed", {
    Title = "อัปเกรดความเร็วเดิน (Auto Speed Upgrade)",
    Description = "ซื้อความเร็วเดินตามเงินที่มี",
    Default = State.AutoUpgradeSpeed,
    Callback = function(val) State.AutoUpgradeSpeed = val end
})

UIControls.AutoUpgradeCarry = Tabs.Progression:AddToggle("AutoUpgradeCarry", {
    Title = "อัปเกรดแบกของ (Auto Carry Upgrade)",
    Description = "ซื้อช่องแบกของเพิ่มเมื่อเงินพอ",
    Default = State.AutoUpgradeCarry,
    Callback = function(val) State.AutoUpgradeCarry = val end
})

Tabs.Progression:AddSection("ระบบจุติอัตโนมัติ (Rebirth Engine)")

UIControls.AutoRebirth = Tabs.Progression:AddToggle("AutoRebirth", {
    Title = "จุติอัตโนมัติ (Auto Rebirth)",
    Description = "เช็คเงินก่อนจุติ เพิ่มตัวคูณเงินถาวร",
    Default = State.AutoRebirth,
    Callback = function(val) State.AutoRebirth = val end
})

UIControls.TargetRebirth = Tabs.Progression:AddDropdown("TargetRebirth", {
    Title = "เป้าหมายการจุติ (Target Rebirth)",
    Description = "หยุดจุติเมื่อถึงระดับที่เลือก",
    Values = {
        "Rebirth 1", "Rebirth 2", "Rebirth 3", "Rebirth 4", "Rebirth 5",
        "Rebirth 6", "Rebirth 7", "Rebirth 8", "Rebirth 9", "Rebirth 10",
        "ไม่จำกัด / สูงสุดตลอดเวลา"
    },
    Default = State.TargetRebirth,
    Callback = function(val) State.TargetRebirth = val end
})

Tabs.Progression:AddButton({
    Title = "จุติทันที 1 ครั้ง (Manual Rebirth Now)",
    Description = "ตรวจสอบเงินและสั่งจุติตอนนี้ทันที",
    Callback = function()
        local ok = pcall(function()
            RebirthService.RF.Rebirth:InvokeServer()
        end)
        if ok then
            Fluent:Notify({ Title = "จุติสำเร็จ", Content = "ทำรายการจุติเรียบร้อยแล้ว", Duration = 3 })
        else
            Fluent:Notify({ Title = "จุติไม่สำเร็จ", Content = "เงินไม่พอหรือยังไม่ถึงเกณฑ์", Duration = 3 })
        end
    end
})

-- ─────────────────────────────────────────────────────────────────────────────────
-- TAB: TRADE & GIFTING (ส่งต่อ & เทรดสัตว์ทีละเยอะๆ)
-- ─────────────────────────────────────────────────────────────────────────────────
Tabs.Trade:AddSection("รับสัตว์อัตโนมัติ (Auto Accept Receiver)")

UIControls.AutoAcceptGifts = Tabs.Trade:AddToggle("AutoAcceptGifts", {
    Title = "รับสัตว์/ของขวัญอัตโนมัติ (Auto Accept Gifts)",
    Description = "กดรับสัตว์ที่ผู้เล่นอื่นส่งมาให้ทันที ไร้ดีเลย์ ไม่ต้องรอกดป๊อปอัป",
    Default = State.AutoAcceptGifts,
    Callback = function(val) State.AutoAcceptGifts = val end
})

Tabs.Trade:AddSection("ส่งสัตว์ให้ผู้เล่นอื่นทีละเยอะๆ (Bulk Send / Gift)")

local playerNames = getOnlinePlayerNames()
local initialPlayer = playerNames[1] or ""
if initialPlayer:find("ไม่มีผู้เล่นอื่น") then
    initialPlayer = ""
end
State.TradeTargetPlayer = initialPlayer

UIControls.TradeTargetPlayer = Tabs.Trade:AddDropdown("TradeTargetPlayer", {
    Title = "เลือกผู้เล่นปลายทาง (Target Player)",
    Values = playerNames,
    Default = initialPlayer ~= "" and initialPlayer or (playerNames[1] or ""),
    Callback = function(val)
        if val and not val:find("ไม่มีผู้เล่นอื่น") then
            State.TradeTargetPlayer = val
        else
            State.TradeTargetPlayer = ""
        end
    end
})

Tabs.Trade:AddButton({
    Title = "รีเฟรชรายชื่อผู้เล่น (Refresh Player List)",
    Description = "อัปเดตรายชื่อผู้เล่นในห้องปัจจุบัน",
    Callback = function()
        local refreshed = getOnlinePlayerNames()
        if UIControls.TradeTargetPlayer then
            pcall(function() UIControls.TradeTargetPlayer:SetValues(refreshed) end)
        end
        local current = State.TradeTargetPlayer
        local found = false
        for _, n in ipairs(refreshed) do
            if n == current then
                found = true
                break
            end
        end
        if not found then
            if refreshed[1] and not refreshed[1]:find("ไม่มีผู้เล่นอื่น") then
                State.TradeTargetPlayer = refreshed[1]
                pcall(function() UIControls.TradeTargetPlayer:SetValue(refreshed[1]) end)
            else
                State.TradeTargetPlayer = ""
            end
        end
        Fluent:Notify({ Title = "อัปเดตรายชื่อสำเร็จ", Content = "พบผู้เล่นในห้องทั้งหมด " .. tostring(#refreshed) .. " คน", Duration = 2.5 })
    end
})

UIControls.AutoBulkTrade = Tabs.Trade:AddToggle("AutoBulkTrade", {
    Title = "ส่ง/แลกสัตว์อัตโนมัติ (Auto Bulk Send / Trade)",
    Description = "ส่งสัตว์ตามชนิดที่เลือกไปยังผู้เล่นเป้าหมายอัตโนมัติตลอดเวลา",
    Default = State.AutoBulkTrade,
    Callback = function(val) State.AutoBulkTrade = val end
})

local animalFilters = getAnimalFilterList()
State.TradeFilterAnimals = State.TradeFilterAnimals or { ["ทั้งหมด (All Animals)"] = true }

UIControls.TradeFilterAnimals = Tabs.Trade:AddDropdown("TradeFilterAnimals", {
    Title = "เลือกชื่อสัตว์ที่ต้องการส่ง (Animal Filter - เลือกได้มากกว่า 1)",
    Description = "ติ๊กเลือกสัตว์ได้หลายชนิดพร้อมกัน หรือเลือกทั้งหมด",
    Values = animalFilters,
    Multi = true,
    Default = State.TradeFilterAnimals,
    Callback = function(val) State.TradeFilterAnimals = val end
})
UIControls.TradeFilterAnimal = UIControls.TradeFilterAnimals

Tabs.Trade:AddButton({
    Title = "รีเฟรชรายชื่อสัตว์ (Refresh Animal List)",
    Description = "ดึงรายชื่อสัตว์ที่มีในกระเป๋ามาแสดงด้านบนสุดของรายการ",
    Callback = function()
        local refreshed = getAnimalFilterList()
        if UIControls.TradeFilterAnimals then
            pcall(function() UIControls.TradeFilterAnimals:SetValues(refreshed) end)
        end
        Fluent:Notify({ Title = "อัปเดตรายชื่อสัตว์สำเร็จ", Content = "โหลดรายชื่อสัตว์ทั้งหมด " .. tostring(#refreshed) .. " ชนิดเรียบร้อย", Duration = 2.5 })
    end
})

UIControls.TradeQuantity = Tabs.Trade:AddSlider("TradeQuantity", {
    Title = "จำนวนที่ต้องการส่ง (Amount to Send)",
    Description = "กำหนดจำนวนสัตว์ที่จะส่งในรอบนี้",
    Default = State.TradeQuantity,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(val) State.TradeQuantity = val end
})

UIControls.TradeInstantBurst = Tabs.Trade:AddToggle("TradeInstantBurst", {
    Title = "โหมดส่งรวดเดียวพร้อมกัน (Instant Burst Mode)",
    Description = "ยิงส่งทุกตัวพร้อมกันทันที ไร้ดีเลย์ (เหมาะสำหรับไอดีบอทที่เปิด Auto Accept)",
    Default = State.TradeInstantBurst,
    Callback = function(val) State.TradeInstantBurst = val end
})

UIControls.TradeSpeedDelay = Tabs.Trade:AddSlider("TradeSpeedDelay", {
    Title = "หน่วงเวลาการส่ง (Send Delay Seconds)",
    Description = "หน่วงเวลาสำหรับโหมดคิวปกติ (วินาที) ปรับเร็วสุดได้ถึง 0.01s",
    Default = State.TradeSpeedDelay,
    Min = 0.01,
    Max = 1.0,
    Rounding = 2,
    Callback = function(val) State.TradeSpeedDelay = val end
})

Tabs.Trade:AddButton({
    Title = "เริ่มส่งสัตว์ทีละเยอะๆ (Start Bulk Trade)",
    Description = "ส่งสัตว์ตามจำนวนและหมวดที่เลือกไปยังผู้เล่นเป้าหมายอัตโนมัติ",
    Callback = function()
        startBulkTrade()
    end
})

Tabs.Trade:AddButton({
    Title = "หยุดการส่งทันที (Stop Bulk Trade)",
    Description = "ยกเลิกกระบวนการส่งสัตว์รอบปัจจุบันทันที",
    Callback = function()
        stopBulkTrade()
    end
})

-- ─────────────────────────────────────────────────────────────────────────────────
-- TAB 4: REWARDS (ของรางวัล & เควสต์)
-- ─────────────────────────────────────────────────────────────────────────────────
Tabs.Rewards:AddSection("เปิด/ปิด หน้าต่างของรางวัล (Reward Windows)")

Tabs.Rewards:AddButton({
    Title = "เปิด/ปิด ป้ายรางวัลดาว (Toggle Stars HUD)",
    Description = "กดเพื่อสลับเปิดหรือปิดแถบของรางวัลอีเวนต์ดาวบนหน้าจอ",
    Callback = function()
        pcall(function()
            local starEvent = LP.PlayerGui.HUD:FindFirstChild("StarEvent")
            if starEvent then
                starEvent.Visible = not starEvent.Visible
                State.ShowStarEventHud = starEvent.Visible
                if UIControls.ShowStarEventHud then
                    pcall(function() UIControls.ShowStarEventHud:SetValue(starEvent.Visible) end)
                end
                Fluent:Notify({
                    Title = "ป้ายรางวัลอีเวนต์ดาว",
                    Content = starEvent.Visible and "เปิดป้ายรางวัลเรียบร้อย" or "ซ่อนป้ายรางวัลเรียบร้อย",
                    Duration = 2.5
                })
            end
        end)
    end
})

Tabs.Rewards:AddButton({
    Title = "เปิด/ปิด หน้าต่าง Event Pass (Toggle Event Pass Window)",
    Description = "กดเพื่อสลับเปิดหรือปิดหน้าต่าง Season 8 Event Pass",
    Callback = function()
        pcall(function()
            local WindowController = Knit.GetController("WindowController")
            if WindowController then
                if WindowController.currentWindow == "Event" then
                    WindowController:CloseCurrentWindow()
                else
                    WindowController:SetCurrentWindow("Event")
                end
            end
        end)
    end
})

Tabs.Rewards:AddButton({
    Title = "เปิด/ปิด หน้าต่างของขวัญออนไลน์ (Toggle Playtime Gifts)",
    Description = "กดเพื่อสลับเปิดหรือปิดหน้าต่างกล่องของขวัญออนไลน์",
    Callback = function()
        pcall(function()
            local WindowController = Knit.GetController("WindowController")
            if WindowController then
                if WindowController.currentWindow == "PlaytimeReward" then
                    WindowController:CloseCurrentWindow()
                else
                    WindowController:SetCurrentWindow("PlaytimeReward")
                end
            end
        end)
    end
})

Tabs.Rewards:AddButton({
    Title = "เปิด/ปิด หน้าต่างรางวัลรายวัน (Toggle Daily Rewards)",
    Description = "กดเพื่อสลับเปิดหรือปิดหน้าต่างรางวัลล็อกอินประจำวัน",
    Callback = function()
        pcall(function()
            local WindowController = Knit.GetController("WindowController")
            if WindowController then
                if WindowController.currentWindow == "DailyRewards" then
                    WindowController:CloseCurrentWindow()
                else
                    WindowController:SetCurrentWindow("DailyRewards")
                end
            end
        end)
    end
})

Tabs.Rewards:AddSection("รับของฟรีทั้งหมด")

UIControls.AutoPlaytimeGifts = Tabs.Rewards:AddToggle("AutoPlaytimeGifts", {
    Title = "รับของขวัญเวลาเล่น (Auto Playtime Gifts)",
    Description = "รับกล่องของขวัญ 1-12 อัตโนมัติ",
    Default = State.AutoPlaytimeGifts,
    Callback = function(val) State.AutoPlaytimeGifts = val end
})

UIControls.AutoDailyRewards = Tabs.Rewards:AddToggle("AutoDailyRewards", {
    Title = "รับของรางวัลรายวัน (Auto Daily Rewards)",
    Description = "รับของรางวัลล็อกอินรายวัน",
    Default = State.AutoDailyRewards,
    Callback = function(val) State.AutoDailyRewards = val end
})

UIControls.AutoFreeShop = Tabs.Rewards:AddToggle("AutoFreeShop", {
    Title = "รับร้านค้าฟรี (Auto Free Shop)",
    Description = "กดรับไอเทมฟรีในร้านค้า",
    Default = State.AutoFreeShop,
    Callback = function(val) State.AutoFreeShop = val end
})

UIControls.AutoSpinWheel = Tabs.Rewards:AddToggle("AutoSpinWheel", {
    Title = "หมุนวงล้อฟรี (Auto Spin Wheel)",
    Description = "หมุนวงล้อเมื่อมีสิทธิ์หมุน",
    Default = State.AutoSpinWheel,
    Callback = function(val) State.AutoSpinWheel = val end
})

UIControls.AutoGroupReward = Tabs.Rewards:AddToggle("AutoGroupReward", {
    Title = "รับรางวัลกลุ่ม (Auto Group Reward)",
    Description = "กดรับรางวัลสมาชิกกลุ่มอัตโนมัติ",
    Default = State.AutoGroupReward,
    Callback = function(val) State.AutoGroupReward = val end
})

Tabs.Rewards:AddSection("พาสและเควสต์ (Season Pass & Quests)")

UIControls.AutoSeasonPass = Tabs.Rewards:AddToggle("AutoSeasonPass", {
    Title = "เคลมของขวัญ Event Pass (Auto Season Pass)",
    Description = "รับรางวัลขั้น Free เมื่อเลเวลถึงอัตโนมัติ (สัตว์/ไข่/ไม้เท้า)",
    Default = State.AutoSeasonPass,
    Callback = function(val) State.AutoSeasonPass = val end
})

UIControls.AutoQuests = Tabs.Rewards:AddToggle("AutoQuests", {
    Title = "เคลมเควสต์อัตโนมัติ (Auto Claim Quests)",
    Description = "กดรับรางวัลเควสต์ Daily และ Hourly ทันทีที่ทำสำเร็จ",
    Default = State.AutoQuests,
    Callback = function(val) State.AutoQuests = val end
})

Tabs.Rewards:AddSection("ระบบน้ำยาบัฟ (Potions & Boosts)")

UIControls.AutoUsePotions = Tabs.Rewards:AddToggle("AutoUsePotions", {
    Title = "ดื่มน้ำยาอัตโนมัติ (Auto Use Potions)",
    Description = "ดื่มน้ำยาจากคลังอัตโนมัติเมื่อเวลาบัฟหมด",
    Default = State.AutoUsePotions,
    Callback = function(val) State.AutoUsePotions = val end
})

UIControls.AutoUseTrainPotion = Tabs.Rewards:AddToggle("AutoUseTrainPotion", {
    Title = "เน้นยาพลัง x2 (Auto Train Potion)",
    Description = "กดใช้ Training Potion เมื่อไม่มีบัฟพลัง",
    Default = State.AutoUseTrainPotion,
    Callback = function(val) State.AutoUseTrainPotion = val end
})

UIControls.AutoUseCashPotion = Tabs.Rewards:AddToggle("AutoUseCashPotion", {
    Title = "เน้นยาเงิน x2 (Auto Cash Potion)",
    Description = "กดใช้ Cash Potion เมื่อไม่มีบัฟเงิน",
    Default = State.AutoUseCashPotion,
    Callback = function(val) State.AutoUseCashPotion = val end
})

UIControls.AutoUseLuckPotion = Tabs.Rewards:AddToggle("AutoUseLuckPotion", {
    Title = "เน้นยาโชค x2 (Auto Luck Potion)",
    Description = "กดใช้ Luck Potion เมื่อไม่มีบัฟโชค",
    Default = State.AutoUseLuckPotion,
    Callback = function(val) State.AutoUseLuckPotion = val end
})

Tabs.Rewards:AddButton({
    Title = "ดื่มยาพลัง x2 ทันที (Drink Train Potion Now)",
    Description = "ใช้ Training Potion 1 ขวดเพื่อรับบัฟพลังฝึก x2 นาน 10 นาที",
    Callback = function()
        local ok = pcall(function() PotionService.RF.UsePotion:InvokeServer("Train") end)
        if ok then
            Fluent:Notify({ Title = "ใช้งานสำเร็จ", Content = "เริ่มใช้งาน Training Potion x2 แล้ว!", Duration = 3 })
        else
            Fluent:Notify({ Title = "ใช้ไม่สำเร็จ", Content = "ไม่มีน้ำยาชนิดนี้ในคลัง", Duration = 3 })
        end
    end
})

Tabs.Rewards:AddButton({
    Title = "ดื่มยาเงิน x2 ทันที (Drink Cash Potion Now)",
    Description = "ใช้ Cash Potion 1 ขวดเพื่อรับบัฟเงิน x2 นาน 10 นาที",
    Callback = function()
        local ok = pcall(function() PotionService.RF.UsePotion:InvokeServer("Cash") end)
        if ok then
            Fluent:Notify({ Title = "ใช้งานสำเร็จ", Content = "เริ่มใช้งาน Cash Potion x2 แล้ว!", Duration = 3 })
        else
            Fluent:Notify({ Title = "ใช้ไม่สำเร็จ", Content = "ไม่มีน้ำยาชนิดนี้ในคลัง", Duration = 3 })
        end
    end
})

Tabs.Rewards:AddButton({
    Title = "ดื่มยาโชค x2 ทันที (Drink Luck Potion Now)",
    Description = "ใช้ Luck Potion 1 ขวดเพื่อรับบัฟโชค x2 นาน 10 นาที",
    Callback = function()
        local ok = pcall(function() PotionService.RF.UsePotion:InvokeServer("Luck") end)
        if ok then
            Fluent:Notify({ Title = "ใช้งานสำเร็จ", Content = "เริ่มใช้งาน Luck Potion x2 แล้ว!", Duration = 3 })
        else
            Fluent:Notify({ Title = "ใช้ไม่สำเร็จ", Content = "ไม่มีน้ำยาชนิดนี้ในคลัง", Duration = 3 })
        end
    end
})

Tabs.Rewards:AddSection("โค้ดของแจก (Promo Codes)")

Tabs.Rewards:AddButton({
    Title = "แลกโค้ดทั้งหมดทันที (Redeem All Promo Codes)",
    Description = "กรอกโค้ดของเกมทั้งหมด (RELEASE, 100K, SEA, etc.) อัตโนมัติ",
    Callback = function()
        local count = 0
        local codes = { "RELEASE", "OPENSEA", "SEA", "ANIMALS", "UPDATE1", "UPDATE2", "TRAIN", "POWER", "100K", "50K", "10K", "LIKE", "DISCORD" }
        for _, c in ipairs(codes) do
            local ok, res = pcall(function() return CodesService.RF.RedeemCode:InvokeServer(c) end)
            if ok and res == true then count = count + 1 end
        end
        Fluent:Notify({
            Title = "แลกโค้ดเสร็จสิ้น",
            Content = "แลกรับโค้ดสำเร็จ " .. count .. " โค้ด (โค้ดที่เคยใช้แล้วจะไม่นับซ้ำ)",
            Duration = 4
        })
    end
})

Tabs.Rewards:AddInput("CustomPromoCode", {
    Title = "กรอกโค้ดเอง (Custom Code)",
    Description = "พิมพ์โค้ดแล้วกด Enter เพื่อแลกของรางวัลทันที",
    Default = "",
    Placeholder = "ใส่โค้ดที่นี่...",
    Finished = true,
    Callback = function(code)
        if code and code ~= "" then
            local ok, res = pcall(function() return CodesService.RF.RedeemCode:InvokeServer(code) end)
            if ok and res == true then
                Fluent:Notify({ Title = "สำเร็จ!", Content = "แลกรับโค้ด " .. code .. " สำเร็จเรียบร้อย", Duration = 3 })
            else
                Fluent:Notify({ Title = "แลกไม่สำเร็จ", Content = "โค้ด " .. code .. " ไม่ถูกต้องหรือถูกใช้ไปแล้ว", Duration = 3 })
            end
        end
    end
})

-- ─────────────────────────────────────────────────────────────────────────────────
-- TAB 4: MISC (วาร์ป & ทั่วไป)
-- ─────────────────────────────────────────────────────────────────────────────────
Tabs.Misc:AddSection("วาร์ปสถานที่สำคัญ")

Tabs.Misc:AddButton({
    Title = "วาร์ปไปลานของฉัน (Teleport to My Plot)",
    Description = "วาร์ปกลับลานพักของคุณทันที",
    Callback = function()
        local myPlot = getMyPlotModel()
        local warp = myPlot and (myPlot:FindFirstChild(myPlot.Name .. "_WarpPart") or myPlot:FindFirstChild("PlotSurface"))
        if warp then
            safeTeleport(warp.CFrame * CFrame.new(0, 3, 0))
        else
            safeTeleport(CFrame.new(733.8, 80.0, 398.2))
        end
    end
})

Tabs.Misc:AddButton({
    Title = "วาร์ปไปหน้าทะเล (Teleport to Sea Edge)",
    Description = "วาร์ปไปจุดเริ่มต้นหน้าชายหาด",
    Callback = function()
        safeTeleport(CFrame.new(661.8, 77.0, 325.2))
    end
})

Tabs.Misc:AddButton({
    Title = "วาร์ปไปร้านดัมเบล (Teleport to Dumbbell Shop)",
    Description = "วาร์ปไปหน้าร้านซื้ออุปกรณ์ฝึกพลัง",
    Callback = function()
        safeTeleport(CFrame.new(667.6, 73.0, 281.8))
    end
})

Tabs.Misc:AddButton({
    Title = "วาร์ปไปร้านคทา (Teleport to Staff Shop)",
    Description = "วาร์ปไปหน้าร้านซื้อคทาเปิดทะเล",
    Callback = function()
        safeTeleport(CFrame.new(664.1, 72.0, 363.2))
    end
})

Tabs.Misc:AddSection("ระบบช่วยเหลือผู้เล่น")

Tabs.Misc:AddButton({
    Title = "ปลดล็อกการเดิน / แก้ติดบั๊ก (Unlock Walk / Unstuck)",
    Description = "สั่งหยุดฝึกและคืนค่าการเคลื่อนไหวให้ตัวละครทันที",
    Callback = function()
        pcall(function()
            TrainingService.RF.StopTraining:InvokeServer()
            if TrainingController and TrainingController.StopTraining then
                TrainingController:StopTraining()
            end
            local hum = getHum()
            if hum then
                hum.PlatformStand = false
                hum.WalkSpeed = State.CustomSpeedEnabled and State.CustomSpeedValue or 16
                hum.JumpPower = State.CustomJumpEnabled and State.CustomJumpValue or 50
            end
            local hrp = getHRP()
            if hrp then
                for _, child in ipairs(hrp:GetChildren()) do
                    if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            end
        end)
        Fluent:Notify({ Title = "ปลดล็อกสำเร็จ", Content = "คืนค่าการเคลื่อนไหวแล้ว", Duration = 3 })
    end
})

-- ─────────────────────────────────────────────────────────────────────────────────
-- TAB 5: SETTINGS (ตั้งค่า & ผู้เล่น)
-- ─────────────────────────────────────────────────────────────────────────────────
Tabs.Settings:AddSection("การเคลื่อนไหว & ฟิสิกส์ตัวละคร (Player Movement)")

UIControls.CustomSpeedEnabled = Tabs.Settings:AddToggle("CustomSpeedEnabled", {
    Title = "เปิดใช้ความเร็วเดิน (Enable Custom Speed)",
    Description = "ล็อกค่าความเร็วเดินของตัวละคร",
    Default = State.CustomSpeedEnabled,
    Callback = function(val) State.CustomSpeedEnabled = val end
})

UIControls.CustomSpeedValue = Tabs.Settings:AddSlider("CustomSpeedValue", {
    Title = "ความเร็วเดินปรับแต่ง (Custom Speed)",
    Description = "ปรับค่าความเร็วเดินของตัวละคร (16 - 200)",
    Default = State.CustomSpeedValue,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(val) State.CustomSpeedValue = val end
})

UIControls.CustomJumpEnabled = Tabs.Settings:AddToggle("CustomJumpEnabled", {
    Title = "เปิดใช้พลังกระโดดสูง (Enable Custom Jump)",
    Description = "ล็อกค่าพลังกระโดดของตัวละคร",
    Default = State.CustomJumpEnabled,
    Callback = function(val) State.CustomJumpEnabled = val end
})

UIControls.CustomJumpValue = Tabs.Settings:AddSlider("CustomJumpValue", {
    Title = "พลังกระโดดปรับแต่ง (Custom Jump Power)",
    Description = "ปรับค่าพลังกระโดดของตัวละคร (50 - 300)",
    Default = State.CustomJumpValue,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(val) State.CustomJumpValue = val end
})

UIControls.InfiniteJump = Tabs.Settings:AddToggle("InfiniteJump", {
    Title = "กระโดดได้ตลอดเวลา (Infinite Jump)",
    Description = "กระโดดกลางอากาศได้ไม่จำกัดครั้ง",
    Default = State.InfiniteJump,
    Callback = function(val)
        State.InfiniteJump = val
        if updateInfiniteJump then updateInfiniteJump() end
    end
})

UIControls.Noclip = Tabs.Settings:AddToggle("Noclip", {
    Title = "เดินทะลุกำแพง (Noclip Mode)",
    Description = "เดินทะลุสิ่งกีดขวางและโมเดลทั้งหมดในเกม",
    Default = State.Noclip,
    Callback = function(val)
        State.Noclip = val
        if updateNoclip then updateNoclip() end
    end
})

Tabs.Settings:AddButton({
    Title = "ปลดล็อกการเดิน / แก้ติดบั๊ก (Unlock Walk / Unstuck)",
    Description = "สั่งหยุดฝึกและคืนค่าการเคลื่อนไหวให้ตัวละครทันที",
    Callback = function()
        pcall(function()
            TrainingService.RF.StopTraining:InvokeServer()
            if TrainingController and TrainingController.StopTraining then
                TrainingController:StopTraining()
            end
            local hum = getHum()
            if hum then
                hum.PlatformStand = false
                hum.WalkSpeed = State.CustomSpeedEnabled and State.CustomSpeedValue or 16
                hum.JumpPower = State.CustomJumpEnabled and State.CustomJumpValue or 50
            end
            local hrp = getHRP()
            if hrp then
                for _, child in ipairs(hrp:GetChildren()) do
                    if child:IsA("BodyVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            end
        end)
        Fluent:Notify({ Title = "ปลดล็อกสำเร็จ", Content = "คืนค่าการเคลื่อนไหวแล้ว", Duration = 3 })
    end
})

Tabs.Settings:AddSection("ระบบกันหลุด (Anti-AFK System)")

UIControls.AntiAFK = Tabs.Settings:AddToggle("AntiAFK", {
    Title = "ระบบกันหลุด 24/7 (Anti-AFK System)",
    Description = "บล็อกสคริปต์เตะแมพและส่งสัญญาณฮาร์ดแวร์",
    Default = State.AntiAFK,
    Callback = function(val) State.AntiAFK = val end
})

Tabs.Settings:AddSection("จัดการโปรไฟล์คอนฟิก (Config Profiles)")

local configNameInput = ""
Tabs.Settings:AddInput("ConfigName", {
    Title = "ชื่อคอนฟิก (Config Name)",
    Default = "Default",
    Placeholder = "พิมพ์ชื่อคอนฟิกที่นี่...",
    Numeric = false,
    Finished = true,
    Callback = function(val) configNameInput = val end
})

local configDropdown = nil
local function refreshConfigList()
    local list = listSavedConfigs()
    if #list == 0 then table.insert(list, "ไม่มีคอนฟิก") end
    if configDropdown then
        pcall(function() configDropdown:SetValues(list) end)
    end
end

Tabs.Settings:AddButton({
    Title = "บันทึกคอนฟิก (Save Config)",
    Description = "บันทึกการตั้งค่าปัจจุบันลงไฟล์ JSON",
    Callback = function()
        local name = (configNameInput and configNameInput ~= "") and configNameInput or "Default"
        local ok = saveConfig(name)
        if ok then
            Fluent:Notify({ Title = "บันทึกสำเร็จ", Content = "บันทึกคอนฟิก " .. name .. " เรียบร้อยแล้ว", Duration = 3 })
            refreshConfigList()
        else
            Fluent:Notify({ Title = "เกิดข้อผิดพลาด", Content = "ไม่สามารถบันทึกคอนฟิกได้ (อาจไม่มีสิทธิ์เขียนไฟล์)", Duration = 3 })
        end
    end
})

local initialConfigs = listSavedConfigs()
if #initialConfigs == 0 then initialConfigs = { "ไม่มีคอนฟิก" } end

configDropdown = Tabs.Settings:AddDropdown("SelectConfig", {
    Title = "เลือกคอนฟิก (Select Config)",
    Values = initialConfigs,
    Default = initialConfigs[1] or "ไม่มีคอนฟิก",
    Callback = function(val)
        if val ~= "ไม่มีคอนฟิก" then
            State.SelectedConfig = val
        end
    end
})

Tabs.Settings:AddButton({
    Title = "โหลดคอนฟิก (Load Config)",
    Description = "โหลดการตั้งค่าจากคอนฟิกที่เลือก",
    Callback = function()
        if State.SelectedConfig and State.SelectedConfig ~= "" and State.SelectedConfig ~= "ไม่มีคอนฟิก" then
            local ok = loadConfig(State.SelectedConfig)
            if ok then
                Fluent:Notify({ Title = "โหลดสำเร็จ", Content = "โหลดคอนฟิก " .. State.SelectedConfig .. " เรียบร้อยแล้ว", Duration = 3 })
            else
                Fluent:Notify({ Title = "เกิดข้อผิดพลาด", Content = "ไม่สามารถโหลดคอนฟิกได้", Duration = 3 })
            end
        else
            Fluent:Notify({ Title = "แจ้งเตือน", Content = "กรุณาเลือกไฟล์คอนฟิกก่อนโหลด", Duration = 3 })
        end
    end
})

Tabs.Settings:AddButton({
    Title = "ลบคอนฟิก (Delete Config)",
    Description = "ลบไฟล์คอนฟิกที่เลือกออกจากระบบ",
    Callback = function()
        if State.SelectedConfig and State.SelectedConfig ~= "" and State.SelectedConfig ~= "ไม่มีคอนฟิก" then
            local ok = deleteConfig(State.SelectedConfig)
            if ok then
                Fluent:Notify({ Title = "ลบสำเร็จ", Content = "ลบคอนฟิก " .. State.SelectedConfig .. " เรียบร้อยแล้ว", Duration = 3 })
                refreshConfigList()
            end
        end
    end
})

UIControls.AutoLoadConfig = Tabs.Settings:AddToggle("AutoLoadConfig", {
    Title = "โหลดอัตโนมัติเมื่อเริ่มรัน (Auto Load on Boot)",
    Description = "บันทึกคอนฟิกที่เลือกให้โหลดอัตโนมัติเมื่อเปิดสคริปต์",
    Default = State.AutoLoadConfig,
    Callback = function(val)
        State.AutoLoadConfig = val
        ensureConfigFolder()
        if val and State.SelectedConfig and State.SelectedConfig ~= "" and State.SelectedConfig ~= "ไม่มีคอนฟิก" then
            pcall(function() writefile(AUTOLOAD_FILE, State.SelectedConfig) end)
        else
            pcall(function() if typeof(isfile) == "function" and isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end end)
        end
    end
})

Tabs.Settings:AddSection("คอมมูนิตี้ (Community)")

Tabs.Settings:AddButton({
    Title = "คัดลอกลิงก์ Discord (Copy Discord Link)",
    Description = "https://discord.gg/4Yg72kYT6s",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/4Yg72kYT6s")
            Fluent:Notify({ Title = "คัดลอกสำเร็จ", Content = "คัดลอกลิงก์ Discord ลงคลิปบอร์ดแล้ว!", Duration = 3 })
        elseif toclipboard then
            toclipboard("https://discord.gg/4Yg72kYT6s")
            Fluent:Notify({ Title = "คัดลอกสำเร็จ", Content = "คัดลอกลิงก์ Discord ลงคลิปบอร์ดแล้ว!", Duration = 3 })
        end
    end
})

-- ── 11. BOOT SEQUENCE ────────────────────────────────────────────────────────────
-- Check Auto Load on Boot
pcall(function()
    ensureConfigFolder()
    if isfile(AUTOLOAD_FILE) then
        local target = readfile(AUTOLOAD_FILE)
        if target and target ~= "" then
            task.delay(0.5, function()
                loadConfig(target)
            end)
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({
    Title = "2K Script Loaded",
    Content = "Open Sea For Animals พร้อมใช้งานเรียบร้อยแล้ว!",
    Duration = 5
})