if _G.MeridianHubRunning then return end
_G.MeridianHubRunning = true

repeat task.wait() until game:IsLoaded()

-- ============================================================
-- MERIDIAN HUB
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

local _tick          = tick
local _clamp         = math.clamp
local _floor         = math.floor
local _huge          = math.huge
local _sqrt          = math.sqrt
local _V3new         = Vector3.new
local _V3zero        = Vector3.zero
local _CFnew         = CFrame.new
local _CFlookAt      = CFrame.lookAt
local _RayParams_new = RaycastParams.new

local _GetPlayersCached
do
    local cache, cacheTime = nil, 0
    _GetPlayersCached = function()
        local now = _tick()
        if cache and now - cacheTime < 0.03 then return cache end
        cache = Players:GetPlayers()
        cacheTime = now
        return cache
    end
end

local function waitForCharReady(char, timeout)
    timeout = timeout or 5
    local deadline = _tick() + timeout
    while (not char) or (not char.Parent)
          or (not char:FindFirstChild("HumanoidRootPart"))
          or (not char:FindFirstChildOfClass("Humanoid")) do
        if _tick() > deadline then return false end
        task.wait(0.05)
    end
    return true
end

NS = 60
CS = 29
LAGGER_SPEED = 15
LAGGER_CARRY_SPEED = 24.5
MEDUSA_COOLDOWN = 25
BAT_AIMBOT_SPEED = 58
CONFIG_FILE = "MeridianHub.json"
BAT_V2_HIT_DIST = 4.5
_isDraggingButton = false

backgroundIndex = 1
backgroundImageTransparency = 0.35
floatingButtonScale = 1
progressBarScale = 1
_floatingUIScales = {}

local COLOR_THEMES = {
    ["Gray"] = Color3.fromRGB(30, 30, 35),
}

currentColorTheme = "Gray"
selectedColor = COLOR_THEMES["Gray"]

function getThemeColor() return selectedColor end

local _lastThemeUpdate = 0
local _lastThemeColor = nil


function updateAllUIThemeColors(color)
    local now = _tick()
    if color == _lastThemeColor and now - _lastThemeUpdate < 0.1 then return end
    _lastThemeUpdate = now
    _lastThemeColor = color

    if progressFill then
        progressFill.BackgroundColor3 = Color3.fromRGB(210, 210, 220)
        local fs = progressFill:FindFirstChild("FillStroke")
        if fs then fs.Color = Color3.fromRGB(210, 210, 220) end
    end
    if pbFrame then
        local pr = pbFrame:FindFirstChild("ProgressRow")
        if pr then
            local fr = pr:FindFirstChild("FillRegion")
            if fr then
                local s = fr:FindFirstChild("FillRegionStroke")
                if s then s.Color = Color3.fromRGB(210, 210, 220) end
            end
        end
        local discordLabel = pbFrame:FindFirstChild("DiscordLabel")
        if discordLabel then discordLabel.TextColor3 = Color3.fromRGB(210, 210, 220) end
        local fpsNeon = pbFrame:FindFirstChild("FPSNeon")
        if fpsNeon then fpsNeon.TextColor3 = Color3.fromRGB(210, 210, 220) end
    end
    local function searchAndUpdateText(parent)
        for _, child in ipairs(parent:GetDescendants()) do
            if child:IsA("TextLabel") then
                if child.Text:find("discord.gg") or child.Text:find("Spd:") or child.Name == "DiscordText" or
                   child.Name == "MeridianHubSpeedIndicator" or child.Text:find("FPS") or child.Text:find("speed") then
                    child.TextColor3 = Color3.fromRGB(210, 210, 220)
                end
            end
            if child:IsA("UIStroke") then
                if child.Color == Color3.fromRGB(95, 95, 105) or child.Color == Color3.fromRGB(180, 180, 190) then child.Color = color end
            end
        end
    end
    if gui then searchAndUpdateText(gui) end
    if tpBatFloatingButton then
        paintFloatingBtn(tpBatFloatingButton:FindFirstChild("Frame"), batDesyncTpEnabled)
    end
    for _, tab in ipairs(tabButtons or {}) do
        if tab.TextColor3 == Color3.fromRGB(180, 180, 190) or tab.TextColor3 == Color3.fromRGB(95, 95, 105) then tab.TextColor3 = color end
    end
    for _, hl in pairs(espHighlightCache) do
        if hl then hl.FillColor = color; hl.OutlineColor = color end
    end
    for _, lines in pairs(espTracerCache) do
        if lines then
            for _, ln in ipairs(lines) do
                if ln then ln.Color = color end
            end
        end
    end
    for _, bb in pairs(espBillboardCache) do
        if bb then
            local img = bb:FindFirstChildOfClass("ImageLabel")
            if img then
                local stroke = img:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Color = color end
            end
        end
    end
    if main then
        local titleFrame = main:FindFirstChild("TitleFrame")
        if titleFrame then
            for _, child in ipairs(titleFrame:GetDescendants()) do
                if child:IsA("UIStroke") and (child.Color == Color3.fromRGB(95, 95, 105) or child.Color == Color3.fromRGB(180, 180, 190)) then
                    child.Color = color
                end
            end
        end
    end
    if miniBtn then
        miniBtn.TextColor3 = Color3.fromRGB(210, 210, 220)
    end

    local pGui = LP:FindFirstChild("PlayerGui")
    if pGui then
        local bb = pGui:FindFirstChild("RagCountdownBillboard")
        if bb then
            local lbl = bb:FindFirstChildOfClass("TextLabel")
            if lbl then
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                local grad = lbl:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 210)),
                        ColorSequenceKeypoint.new(0.3, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.7, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210)),
                    })
                end
            end
        end
    end

    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        if container then
            local btnContainer = container:FindFirstChild("ButtonsContainer")
            if btnContainer then
                for _, btn in ipairs(btnContainer:GetChildren()) do
                    if btn:IsA("TextButton") and btn:FindFirstChild("BtnGrad") then
                        paintFloatingBtn(btn, btn:GetAttribute("MobActive") == true)
                    end
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- OUTFITS
-- ═══════════════════════════════════════════════════════════════
local ECLIPSE_SKIN_PRESETS = {
    V1 = { shirt = 74707712629633, pants = 12405320750, hair = 140188532534398 },
    V2 = { shirt = 101796619834594, pants = 18975891159, hair = 115520061093937 },
    V3 = { shirt = 18552805597,   pants = 5414143509,  hair = 84008082880128  },
}

local function eclipseAssetUrl(id)
    return "http://www.roblox.com/asset/?id=" .. tostring(id)
end

local TAG = "LocalOutfit_"

-- Meridian (ADAPT) outfits live in one table so we only spend a single chunk-level local
local AdaptOutfit = { attr = "MeridianAdaptOutfit" }

function AdaptOutfit.remove(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:GetAttribute(AdaptOutfit.attr) then
            pcall(function() child:Destroy() end)
        end
    end
end


local function applyNoOutfit(char)
    if not char then char = LP.Character end
    if not char then return end
    AdaptOutfit.remove(char)
    for _, d in ipairs(char:GetChildren()) do
        if d.Name:sub(1, #TAG) == TAG then pcall(function() d:Destroy() end) end
    end
    local oldAcc = char:FindFirstChild("AuFfitAccessory")
    if oldAcc then pcall(function() oldAcc:Destroy() end) end
    local oldKorblox = char:FindFirstChild("Korblox_RightLeg")
    if oldKorblox then pcall(function() oldKorblox:Destroy() end) end
    for _, d in ipairs(char:GetChildren()) do
        if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
            pcall(function() d:Destroy() end)
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        head.CanCollide = true
        head.LocalTransparencyModifier = 0
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 0 end
        local sm = head:FindFirstChildWhichIsA("SpecialMesh")
        if sm then pcall(function() sm:Destroy() end) end
    end
    pcall(function()
        local neck = char:FindFirstChild("Neck")
        if neck then neck.Enabled = true end
    end)
    for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local limb = char:FindFirstChild(partName)
        if limb then limb.Transparency = 0 end
    end
    local shirt = char:FindFirstChildWhichIsA("Shirt")
    if shirt then pcall(function() shirt:Destroy() end) end
    local pants = char:FindFirstChildWhichIsA("Pants")
    if pants then pcall(function() pants:Destroy() end) end
    for _, a in ipairs(char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then h.Transparency = 0 end
        end
    end
end

local OUTFITS = {
    {
        label = "Off",
        customApply = applyNoOutfit,
    },
    {
        accessory = 10159600649,
        offset = _V3new(0, 1, -0.2),
        shirt = "http://www.roblox.com/asset/?id=9683332638",
        pants = "http://www.roblox.com/asset/?id=93182020184041",
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918 ",
        korblox = "none",
        label = "Outfit 1",
        headlessKorblox = true,
    },
    {
        accessory = 1744060292,
        offset = _V3new(0, 1.3, -0.2),
        shirt = "http://www.roblox.com/asset/?id=9683332638",
        pants = "http://www.roblox.com/asset/?id=93182020184041",
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918 ",
        korblox = "none",
        label = "Outfit 2",
        headlessKorblox = true,
    },
    {
        accessory = 121097973925756,
        offset = _V3new(0, 0.9, 0),
        shirt = eclipseAssetUrl(ECLIPSE_SKIN_PRESETS.V1.shirt),
        pants = eclipseAssetUrl(ECLIPSE_SKIN_PRESETS.V1.pants),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        korblox = "none",
        label = "Outfit 3",
        headlessKorblox = true,
    },
    {
        accessory = 10159600649,
        offset = _V3new(0, 1, -0.2),
        shirt = eclipseAssetUrl(ECLIPSE_SKIN_PRESETS.V2.shirt),
        pants = eclipseAssetUrl(ECLIPSE_SKIN_PRESETS.V2.pants),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        korblox = "none",
        label = "Outfit 4",
        headlessKorblox = true,
    },
    {
        accessory = 1744060292,
        offset = _V3new(0, 1.3, -0.2),
        shirt = eclipseAssetUrl(ECLIPSE_SKIN_PRESETS.V3.shirt),
        pants = eclipseAssetUrl(ECLIPSE_SKIN_PRESETS.V3.pants),
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918",
        korblox = "none",
        label = "Outfit 5",
        headlessKorblox = true,
    },
    { label = "Outfit 6",      adaptPreset = "ADAPT"  },
    { label = "Outfit 7",      adaptPreset = "RED"    },
    { label = "Outfit 8",      adaptPreset = "BLUE"   },
    { label = "Outfit 9",      adaptPreset = "GALAXY" },
}
local currentOutfitIndex = 2   -- 1 = Off, 2 = Outfit 1
local outfitSelectorLabel = nil

BACKGROUND_IMAGES = {
    { label = "Off",  id = nil },
    { label = "BG 1", id = "rbxassetid://77785523954153" },
    { label = "BG 2", id = "rbxassetid://122815453745063" },
    { label = "BG 3", id = "rbxassetid://110738643340954" },
    { label = "BG 4", id = "rbxassetid://106293024545373" },
    { label = "BG 5", id = "rbxassetid://129896693396363" },
    { label = "BG 6", id = "rbxassetid://106565148963503" },
    { label = "BG 7", id = "rbxassetid://128853142134614" },
    { label = "BG 8", id = "rbxassetid://140032897760829" },
    { label = "BG 9", id = "rbxassetid://111340412039703" },
    { label = "BG 10", id = "rbxassetid://76507946954818" },
}
BUTTON_IMAGES = {
    { label = "Off", id = nil },
    { label = "Img 1", id = "rbxassetid://77785523954153" },
    { label = "Img 2", id = "rbxassetid://122815453745063" },
    { label = "Img 3", id = "rbxassetid://104540837462600" },
    { label = "Img 4", id = "rbxassetid://138083690800326" },
    { label = "Img 5", id = "rbxassetid://98447749356251" },
    { label = "Img 6", id = "rbxassetid://125573386004845" },
    { label = "Img 7", id = "rbxassetid://128792996479359" },
    { label = "Img 8", id = "rbxassetid://114319093849600" },
}
backgroundSelectorLabel = nil
backgroundImage = nil
backgroundImagePB = nil

function applyBackground(index)
    backgroundIndex = _clamp(index or 1, 1, #BACKGROUND_IMAGES)
    local cfg = BACKGROUND_IMAGES[backgroundIndex]
    if not cfg then return end
    local targetImg = cfg.id or ""
    local targetTrans = cfg.id and backgroundImageTransparency or 1
    if backgroundImage and backgroundImage.Parent then
        backgroundImage.Image = targetImg
        backgroundImage.ImageTransparency = targetTrans
    end
    if backgroundImagePB and backgroundImagePB.Parent then
        backgroundImagePB.Image = targetImg
        backgroundImagePB.ImageTransparency = targetImg ~= "" and math.min(targetTrans + 0.15, 1) or 1
    end
    if backgroundSelectorLabel then
        backgroundSelectorLabel.Text = cfg.label
    end
end

-- ===== floating button image changer =====
buttonImageIndex = 1
buttonImageCustomId = ""
buttonImageSelectorLabel = nil
BUTTON_IMAGE_OPTIONS = {}
for _, bi in ipairs(BUTTON_IMAGES) do
    BUTTON_IMAGE_OPTIONS[#BUTTON_IMAGE_OPTIONS + 1] = { label = bi.label, id = bi.id }
end

function getButtonImageId()
    local cfg = BUTTON_IMAGE_OPTIONS[buttonImageIndex]
    if not cfg then return nil end
    return cfg.id
end

function buttonImageSync(btnFrame, active)
    if not btnFrame then return end
    local id = getButtonImageId()
    local img = btnFrame:FindFirstChild("BtnImage")
    local label = btnFrame:FindFirstChild("TextLabel")
    if not id then
        if img then img:Destroy() end
        if label then label.TextStrokeTransparency = 1 end
        return
    end
    if not img then
        img = Instance.new("ImageLabel")
        img.Name = "BtnImage"
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.Size = UDim2.new(1, 0, 1, 0)
        img.ScaleType = Enum.ScaleType.Crop
        Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
        img.Parent = btnFrame
    end
    img.ZIndex = (label and label.ZIndex or 11) - 1
    img.Image = id
    img.ImageTransparency = active and 0.45 or 0
    if label then
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0
        local streak = label:FindFirstChild("TextStreak")
        if streak then streak.Enabled = false end
    end
end

function buttonImageApplyAll()
    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        local btnCont = container and container:FindFirstChild("ButtonsContainer")
        if btnCont then
            for _, btn in ipairs(btnCont:GetChildren()) do
                if btn:IsA("TextButton") then
                    buttonImageSync(btn, btn:GetAttribute("MobActive") == true)
                end
            end
        end
    end
    if tpBatFloatingButton then buttonImageSync(tpBatFloatingButton:FindFirstChild("Frame"), batDesyncTpEnabled == true) end
    if instaResetFloatingButton then buttonImageSync(instaResetFloatingButton:FindFirstChild("Frame"), false) end
end

local function loadObjectsStd(id)
    local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
    if ok and typeof(res) == "table" and #res > 0 then return res end
    ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
    if ok and res then return {res} end
    return nil
end

local function applyHeadlessKorblox(char)
    if not char then return end
    pcall(function() LP.CharacterAvatarType = Enum.AvatarType.R6 end)
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        head.CanCollide = false
        head.LocalTransparencyModifier = 1
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 1 end
    end
    pcall(function()
        local neck = char:FindFirstChild("Neck")
        if neck then neck.Enabled = false end
    end)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Accessory") then
            local w = v:FindFirstChildWhichIsA("Weld") or v:FindFirstChildWhichIsA("WeldConstraint") or v:FindFirstChildWhichIsA("Motor6D")
            if w then
                local p0, p1 = w.Part0, w.Part1
                if (p0 and p0.Name == "Head") or (p1 and p1.Name == "Head") then
                    v.Parent = nil
                end
            end
        end
    end
    local rightLegConfig = {
        id = "rbxassetid://139607718",
        targetBodyPart = "RightUpperLeg",
        partsToHide = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        scale = _V3new(1, 1, 1),
        offset = _CFnew(0, 0, 0)
    }
    local targetPart = char:FindFirstChild(rightLegConfig.targetBodyPart)
    if targetPart then
        local oldAsset = char:FindFirstChild("Korblox_RightLeg")
        if oldAsset then oldAsset:Destroy() end
        for _, partName in ipairs(rightLegConfig.partsToHide) do
            local limb = char:FindFirstChild(partName)
            if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
        end
        local success, objects = pcall(function() return game:GetObjects(rightLegConfig.id) end)
        if success and objects and #objects > 0 then
            local assetModel = objects[1]
            assetModel.Name = "Korblox_RightLeg"
            local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
            if mainMesh then
                mainMesh.Size = mainMesh.Size * rightLegConfig.scale
                mainMesh.CanCollide = false
                mainMesh.CFrame = targetPart.CFrame * rightLegConfig.offset
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = targetPart
                weld.Part1 = mainMesh
                weld.Parent = mainMesh
                assetModel.Parent = char
            end
        end
    end
end

-- ── Meridian (ADAPT) outfit presets: ADAPT / RED / BLUE / GALAXY ──────────────────────────
AdaptOutfit.presets = {
    ADAPT  = { ids = { 10928435480, 6913613757, 9683332649 }, bundles = { 263995361762992 } },
    RED    = { ids = { 107377896731216, 215718515, 82831174733357, 122851471549264, 139051312584295, 124572458012582, 105029428205930 } },
    BLUE   = { ids = { 76059443, 74891470, 1180433861, 8781331764, 8682542843 } },
    GALAXY = { ids = { 82831174733357, 139051312584295, 107062966543626, 71184246276344, 111383282415116, 78289009309744, 71017311084699 } },
}
AdaptOutfit.assetCache = {}
AdaptOutfit.bundleCache = {}

function AdaptOutfit.isItem(inst)
    return inst:IsA("Accessory") or inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic")
end

-- preset ids + the asset ids inside its bundles
function AdaptOutfit.assetIds(preset)
    local ids = {}
    for _, id in ipairs(preset.ids or {}) do ids[#ids + 1] = id end
    for _, bundleId in ipairs(preset.bundles or {}) do
        local list = AdaptOutfit.bundleCache[bundleId]
        if not list then
            list = {}
            local ok, details = pcall(function()
                return game:GetService("AssetService"):GetBundleDetailsAsync(bundleId)
            end)
            if ok and details and type(details.Items) == "table" then
                for _, item in ipairs(details.Items) do
                    if item.Type == "Asset" and tonumber(item.Id) then list[#list + 1] = tonumber(item.Id) end
                end
            end
            if #list > 0 then AdaptOutfit.bundleCache[bundleId] = list end
        end
        for _, id in ipairs(list) do ids[#ids + 1] = id end
    end
    return ids
end

-- accessories / clothes inside one asset id (cached, so respawn re-applies instantly)
function AdaptOutfit.items(id)
    local cached = AdaptOutfit.assetCache[id]
    if cached then return cached end
    local items = {}
    local objs = loadObjectsStd(id)
    if objs then
        for _, root in ipairs(objs) do
            if AdaptOutfit.isItem(root) then
                items[#items + 1] = root
            else
                for _, d in ipairs(root:GetDescendants()) do
                    if AdaptOutfit.isItem(d) then items[#items + 1] = d end
                end
            end
        end
    end
    if #items > 0 then AdaptOutfit.assetCache[id] = items end
    return items
end

function AdaptOutfit.attachAccessory(char, humanoid, acc)
    pcall(function() humanoid:AddAccessory(acc) end)
    if acc.Parent ~= char then acc.Parent = char end
    local handle = acc:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") or handle:FindFirstChild("AccessoryWeld") then return end
    local attachment = handle:FindFirstChildWhichIsA("Attachment")
    if not attachment then return end
    local target
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Attachment") and d.Name == attachment.Name and not d:IsDescendantOf(acc) then
            target = d
            break
        end
    end
    local targetPart = target and target.Parent
    if targetPart and targetPart:IsA("BasePart") then
        handle.Anchored = false
        handle.CanCollide = false
        handle.CanTouch = false
        handle.CanQuery = false
        handle.Massless = true
        handle.CFrame = targetPart.CFrame * target.CFrame * attachment.CFrame:Inverse()
        local weld = Instance.new("WeldConstraint")
        weld.Name = "MeridianAccessoryWeld"
        weld.Part0 = targetPart
        weld.Part1 = handle
        weld.Parent = handle
    end
end

function AdaptOutfit.apply(char, key)
    local preset = AdaptOutfit.presets[key]
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not preset or not humanoid then return end

    applyNoOutfit(char) -- clears the previous outfit (and earlier Meridian pieces)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("ShirtGraphic") then
            pcall(function() child:Destroy() end)
        end
    end
    applyHeadlessKorblox(char)

    for _, id in ipairs(AdaptOutfit.assetIds(preset)) do
        if LP.Character ~= char or not char.Parent then return end
        for _, template in ipairs(AdaptOutfit.items(id)) do
            local clone = template:Clone()
            clone:SetAttribute(AdaptOutfit.attr, true)
            if clone:IsA("Accessory") then
                AdaptOutfit.attachAccessory(char, humanoid, clone)
            else
                for _, existing in ipairs(char:GetChildren()) do
                    if existing.ClassName == clone.ClassName then pcall(function() existing:Destroy() end) end
                end
                clone.Parent = char
            end
        end
    end
end

for _, outfit in ipairs(OUTFITS) do
    if outfit.adaptPreset then
        local presetKey = outfit.adaptPreset
        outfit.customApply = function(char) AdaptOutfit.apply(char, presetKey) end
    end
end

function applyOutfitByIndex(index)
    local cfg = OUTFITS[index]
    if not cfg then return end
    local char = LP.Character
    if not char then return end
    if cfg.customApply then
        cfg.customApply(char)
        if outfitSelectorLabel then outfitSelectorLabel.Text = cfg.label end
        return
    end
    AdaptOutfit.remove(char)
    char:WaitForChild("Head", 5)
    local head = char:FindFirstChild("Head")
    if not head then return end
    for _, d in ipairs(char:GetChildren()) do
        if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
            pcall(function() d:Destroy() end)
        end
    end
    local done = false
    if head:IsA("MeshPart") then
        done = pcall(function()
            head.MeshId = cfg.headMesh
            if cfg.headTexture then head.TextureID = cfg.headTexture end
        end)
    end
    if not done then
        local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
        sm.Parent = head
        sm.MeshType = Enum.MeshType.FileMesh
        sm.MeshId = cfg.headMesh
        sm.TextureId = cfg.headTexture or ""
    end
    if cfg.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"
        s.ShirtTemplate = cfg.shirt
        s.Parent = char
    end
    if cfg.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"
        p.PantsTemplate = cfg.pants
        p.Parent = char
    end
    local old = char:FindFirstChild("AuFfitAccessory")
    if old then old:Destroy() end
    if cfg.accessory and head then
        local objs = loadObjectsStd(cfg.accessory)
        if objs then
            local handle
            for _, o in ipairs(objs) do
                if o:IsA("BasePart") then handle = o; break end
                local f = o:FindFirstChildWhichIsA("BasePart", true)
                if f then handle = f; break end
            end
            if handle then
                local h = handle:Clone()
                h.Name = "AuFfitAccessory"
                h.CanCollide = false
                h.Anchored = false
                h.Massless = true
                h.Parent = char
                local weld = Instance.new("Weld")
                weld.Part0 = head
                weld.Part1 = h
                weld.C0 = _CFnew(cfg.offset)
                weld.Parent = h
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end
    if cfg.headlessKorblox then
        applyHeadlessKorblox(char)
    else
        if char then
            local head2 = char:FindFirstChild("Head")
            if head2 then
                head2.Transparency = 0
                head2.CanCollide = true
                head2.LocalTransparencyModifier = 0
                local face2 = head2:FindFirstChild("face")
                if face2 then face2.Transparency = 0 end
            end
            pcall(function()
                local neck = char:FindFirstChild("Neck")
                if neck then neck.Enabled = true end
            end)
            for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
                local limb = char:FindFirstChild(partName)
                if limb then limb.Transparency = 0 end
            end
            local oldKorblox = char:FindFirstChild("Korblox_RightLeg")
            if oldKorblox then oldKorblox:Destroy() end
        end
    end
    if outfitSelectorLabel then outfitSelectorLabel.Text = cfg.label end
end

speedMode = false
antiRagdollMode = "off"
antiDieEnabled = true
antiFlingEnabled = false
laggerToggled = false
laggerCarryToggled = false
medusaCounterEnabled = false
batCounterEnabled = false
unwalkEnabled = false
autoLeftEnabled = false
autoRightEnabled = false
autoBatEnabled = false
dropMode = 1
antiLagEnabled = false
removeAccessoriesEnabled = false
stretchEnabled = false
stretchFOV = 120
uiLocked = true
uiScaleValue = 78
espEnabled = false

antiKickEnabled = true  -- Safe Mode: always on
setSafeModeVisual = nil

mirrorTPDownEnabled = false
mirrorTPDownSetVisual = nil

infJumpEnabled = false
infJumpMode    = "HOLD"

bodyLockEnabled = false
bodyLockRange = 20
bodyLockRangeBox = nil
_bodyLockConn = nil
_blSuppressCount = 0
_blWasEnabled = false
_blRestoreTimer = nil
_blSmoothRestore = false

savedProgressBarPos = nil
savedButtonPositions = {}
savedMobilePanelPos = nil
tpBatFloatingPos = nil
batV2FloatingPos = nil
instaResetFloatingPos = nil
instaResetFloatingButton = nil

neonWeatherEnabled = false
skyTheme = "Off"
skySelectorLabel = nil
_originalLighting = nil
setNeonWeatherVisual = nil

currentAnimPack = "Off"
originalTryardAnims = nil
tryardHeartbeatConn = nil
animSelectorLabel = nil

-- ═══════════════════════════════════════════════════════════════
-- BAT BYPASS (antes Anti Bypass Aimbot) — Persecución con predicción de ping
-- ═══════════════════════════════════════════════════════════════
autoBatV2Enabled      = false
autoBatV2SetVisual    = nil

selectedAimbotMode    = "Normal"

_G.AceAntiBypassAimbotSpeed       = _G.AceAntiBypassAimbotSpeed or 60
_G.AceAntiBypassLaggerAimbotSpeed = _G.AceAntiBypassLaggerAimbotSpeed or 40
_G.AceAntiBypassAimbotOn          = _G.AceAntiBypassAimbotOn or false
_G.AceNormalAimbotOn              = _G.AceNormalAimbotOn or false
_G.AceCurrentSpeedMode            = _G.AceCurrentSpeedMode or "Normal"

_G.AceAntiBypassAimbot = _G.AceAntiBypassAimbot or {
    conn           = nil,
    swingCooldown  = false,
    prevAutoRotate = nil,
}

_G.AceAntiBypassSlapList = _G.AceAntiBypassSlapList or {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap",
    "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

_G.AceSafeModeTryStart      = _G.AceSafeModeTryStart      or _G.MeridianSafeModeTryStart
_G.AceStopAutoTPForAction   = _G.AceStopAutoTPForAction   or function()
    if batDesyncTpEnabled and type(stopBatDesyncTp) == "function" then
        stopBatDesyncTp()
    end
end
_G.AceStopNormalAimbot      = _G.AceStopNormalAimbot      or function()
    if autoBatEnabled and type(disableAutoBat) == "function" then
        disableAutoBat()
    end
end

lastMoveDir = _V3zero

-- TP Bat legacy vars (compat)
tpBatVersion = 1 -- 1 = V1 (current), 2 = V2 (MVP)
tpBatSpin = 40 -- V2 Spin Speed 10-80
_G.__tpBatV2Distance = 8


_G.MeridianNormalInfJump = _G.MeridianNormalInfJump or {
    holdPressed = false, holdActive = false,
    controllerActive = false, mobilePressed = false,
    mobileActive = false, hooked = {}
}

function _G._jumpEnsureProxy()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function _G.MeridianApplyNormalInfJumpBoost(boost)
    if not infJumpEnabled then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local proxy = _G._jumpEnsureProxy()
    if not proxy then return end
    local curVel = proxy.Velocity
    proxy.Velocity = _V3new(curVel.X, boost or 50, curVel.Z)
end

function _G.MeridianStopNormalInfJumpHoldState()
    local S = _G.MeridianNormalInfJump
    S.holdPressed = false
    S.holdActive = false
    S.controllerActive = false
    S.mobilePressed = false
    S.mobileActive = false
end

UIS.JumpRequest:Connect(function()
    _G.MeridianApplyNormalInfJumpBoost(50)
end)

UIS.InputBegan:Connect(function(input)
    if UIS:GetFocusedTextBox() then return end
    local S = _G.MeridianNormalInfJump

    if input.UserInputType == Enum.UserInputType.Keyboard
       and input.KeyCode == Enum.KeyCode.Space then
        if infJumpMode == "MANUAL" then return end
        S.holdPressed = true
        task.delay(0.12, function()
            if _G.MeridianNormalInfJump.holdPressed and infJumpEnabled then
                _G.MeridianNormalInfJump.holdActive = true
                _G.MeridianApplyNormalInfJumpBoost(50)
            end
        end)
    elseif input.KeyCode == Enum.KeyCode.ButtonA
       and input.UserInputType.Name:match("^Gamepad") then
        if infJumpMode ~= "MANUAL" then S.controllerActive = true end
    end
end)

UIS.InputEnded:Connect(function(input)
    local S = _G.MeridianNormalInfJump
    if input.UserInputType == Enum.UserInputType.Keyboard
       and input.KeyCode == Enum.KeyCode.Space then
        S.holdPressed = false
        S.holdActive  = false
    end
    if input.KeyCode == Enum.KeyCode.ButtonA
       and input.UserInputType.Name:match("^Gamepad") then
        S.controllerActive = false
    end
end)

function _G.MeridianHookNormalInfMobileJumpButton(obj)
    local S = _G.MeridianNormalInfJump
    if not obj or obj.Name ~= "JumpButton"
       or not obj:IsA("GuiButton") or S.hooked[obj] then return end
    S.hooked[obj] = true
    obj.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
           or not infJumpEnabled then return end
        if infJumpMode == "MANUAL" then return end
        S.mobilePressed = true
        task.delay(0.12, function()
            if S.mobilePressed and infJumpEnabled then
                S.mobileActive = true
                _G.MeridianApplyNormalInfJumpBoost(50)
            end
        end)
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            S.mobilePressed = false
            S.mobileActive  = false
        end
    end)
end

do
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            _G.MeridianHookNormalInfMobileJumpButton(obj)
        end
        pg.DescendantAdded:Connect(function(obj)
            task.defer(_G.MeridianHookNormalInfMobileJumpButton, obj)
        end)
    end
end

RunService.Heartbeat:Connect(function()
    local S = _G.MeridianNormalInfJump
    if infJumpEnabled and infJumpMode == "HOLD"
       and (S.holdActive or S.mobileActive or S.controllerActive) then
        _G.MeridianApplyNormalInfJumpBoost(50)
    end
end)

function _G.setInfJumpInternal(on)
    infJumpEnabled = on and true or false
    if not infJumpEnabled then
        _G.MeridianStopNormalInfJumpHoldState()
        local ch = LP.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then pcall(function() hrp.Velocity = _V3zero end) end
    end
end

function getActiveMoveSpeed()
    if laggerCarryToggled then return LAGGER_CARRY_SPEED
    elseif laggerToggled then return LAGGER_SPEED
    elseif speedMode then return CS
    else return NS end
end

local function _isRagdollState(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand
        or st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
end

local function _applyVelocitySpeed(dir, speed, hrp)
    if not hrp or not hrp.Parent then return end
    if autoBatV2Enabled or batDesyncTpEnabled or autoBatEnabled then return end
    if dir and dir.Magnitude > 0.05 then
        pcall(function()
            if hrp.SetNetworkOwner then hrp:SetNetworkOwner(LP) end
        end)
        local unit = dir.Unit
        local vy = hrp.AssemblyLinearVelocity.Y
        hrp.AssemblyLinearVelocity = _V3new(unit.X * speed, vy, unit.Z * speed)
    else
        local vy = hrp.AssemblyLinearVelocity.Y
        hrp.AssemblyLinearVelocity = _V3new(0, vy, 0)
    end
end


ANIM_PACKS = {
    ["Zombie"] = { idle1="rbxassetid://616158929", idle2="rbxassetid://616160636", walk="rbxassetid://616168032", run="rbxassetid://616163682", jump="rbxassetid://616161997", fall="rbxassetid://616157476", climb="rbxassetid://616156119", swim="rbxassetid://616165109", swimidle="rbxassetid://616166655" },
    ["Ninja"] = { idle1="rbxassetid://656117400", idle2="rbxassetid://656117400", walk="rbxassetid://656121766", run="rbxassetid://656118852", jump="rbxassetid://656117878", fall="rbxassetid://656115606", climb="rbxassetid://656114359", swim="rbxassetid://656117400", swimidle="rbxassetid://656117400" },
    ["Knight"] = { idle1="rbxassetid://657595757", idle2="rbxassetid://657595757", walk="rbxassetid://657552124", run="rbxassetid://657564596", jump="rbxassetid://658409194", fall="rbxassetid://657600338", climb="rbxassetid://658360781", swim="rbxassetid://657595757", swimidle="rbxassetid://657595757" },
    ["Elder"] = { idle1="rbxassetid://845397899", idle2="rbxassetid://845397899", walk="rbxassetid://845403856", run="rbxassetid://845386501", jump="rbxassetid://845398858", fall="rbxassetid://845397673", climb="rbxassetid://845392038", swim="rbxassetid://845397899", swimidle="rbxassetid://845397899" },
    ["Levitate"] = { idle1="rbxassetid://616006778", idle2="rbxassetid://616006778", walk="rbxassetid://616013216", run="rbxassetid://616013216", jump="rbxassetid://616008936", fall="rbxassetid://616005863", climb="rbxassetid://616003713", swim="rbxassetid://616006778", swimidle="rbxassetid://616006778" },
    ["Astronaut"] = { idle1="rbxassetid://891621366", idle2="rbxassetid://891621366", walk="rbxassetid://891636393", run="rbxassetid://891636393", jump="rbxassetid://891627522", fall="rbxassetid://891617961", climb="rbxassetid://891609353", swim="rbxassetid://891621366", swimidle="rbxassetid://891621366" },
    ["Pirate"] = { idle1="rbxassetid://750781874", idle2="rbxassetid://750781874", walk="rbxassetid://750785693", run="rbxassetid://750783738", jump="rbxassetid://750782230", fall="rbxassetid://750780242", climb="rbxassetid://750779899", swim="rbxassetid://750781874", swimidle="rbxassetid://750781874" },
    ["Toy"] = { idle1="rbxassetid://782841498", idle2="rbxassetid://782841498", walk="rbxassetid://782843345", run="rbxassetid://782842708", jump="rbxassetid://782847020", fall="rbxassetid://782846423", climb="rbxassetid://782843869", swim="rbxassetid://782841498", swimidle="rbxassetid://782841498" },
    ["Vampire"] = { idle1="rbxassetid://1083445855", idle2="rbxassetid://1083445855", walk="rbxassetid://1083473930", run="rbxassetid://1083462077", jump="rbxassetid://1083455352", fall="rbxassetid://1083443587", climb="rbxassetid://1083439238", swim="rbxassetid://1083445855", swimidle="rbxassetid://1083445855" },
    ["Werewolf"] = { idle1="rbxassetid://1083195517", idle2="rbxassetid://1083195517", walk="rbxassetid://1083178339", run="rbxassetid://1083216690", jump="rbxassetid://1083218792", fall="rbxassetid://1083189019", climb="rbxassetid://1083182000", swim="rbxassetid://1083195517", swimidle="rbxassetid://1083195517" },
    ["Rthro"] = { idle1="rbxassetid://2510196951", idle2="rbxassetid://2510196951", walk="rbxassetid://2510202577", run="rbxassetid://2510198475", jump="rbxassetid://2510197830", fall="rbxassetid://2510195892", climb="rbxassetid://2510192778", swim="rbxassetid://2510196951", swimidle="rbxassetid://2510196951" },
    ["Stylish"] = { idle1="rbxassetid://616136790", idle2="rbxassetid://616136790", walk="rbxassetid://616146177", run="rbxassetid://616140816", jump="rbxassetid://616139451", fall="rbxassetid://616134815", climb="rbxassetid://616133594", swim="rbxassetid://616136790", swimidle="rbxassetid://616136790" },
}

ANIM_PACK_ORDER = {{"Off", "Off"}, {"Zombie", "Zombie"}, {"Ninja", "Ninja"}, {"Knight", "Knight"}, {"Elder", "Elder"}, {"Levitate", "Levitate"}, {"Astronaut", "Astronaut"}, {"Pirate", "Pirate"}, {"Toy", "Toy"}, {"Vampire", "Vampire"}, {"Werewolf", "Werewolf"}, {"Rthro", "Rthro"}, {"Stylish", "Stylish"}}

local function isPackAnim(id)
    for _, pack in pairs(ANIM_PACKS) do
        for _, v in pairs(pack) do
            if v == id then return true end
        end
    end
    return false
end

local function saveOriginalAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    local ids = {
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        walk  = g(animate.walk and animate.walk.WalkAnim),
        run   = g(animate.run  and animate.run.RunAnim),
        jump  = g(animate.jump and animate.jump.JumpAnim),
        fall  = g(animate.fall and animate.fall.FallAnim),
        climb = g(animate.climb and animate.climb.ClimbAnim),
        swim  = g(animate.swim and animate.swim.Swim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
    }
    if not isPackAnim(ids.walk) then originalTryardAnims = ids end
end

local function applyAnimPack(packName)
    currentAnimPack = packName
    if animSelectorLabel then animSelectorLabel.Text = packName end
    if packName == "Off" then
        if originalTryardAnims and LP.Character then
            local animate = LP.Character:FindFirstChild("Animate")
            if animate then
                local function s(obj,id) if obj then obj.AnimationId = id end end
                s(animate.idle and animate.idle.Animation1, originalTryardAnims.idle1)
                s(animate.idle and animate.idle.Animation2, originalTryardAnims.idle2)
                s(animate.walk and animate.walk.WalkAnim, originalTryardAnims.walk)
                s(animate.run  and animate.run.RunAnim,   originalTryardAnims.run)
                s(animate.jump and animate.jump.JumpAnim, originalTryardAnims.jump)
                s(animate.fall and animate.fall.FallAnim, originalTryardAnims.fall)
                s(animate.climb and animate.climb.ClimbAnim, originalTryardAnims.climb)
                s(animate.swim and animate.swim.Swim, originalTryardAnims.swim)
                s(animate.swimidle and animate.swimidle.SwimIdle, originalTryardAnims.swimidle)
            end
        end
        if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect(); tryardHeartbeatConn = nil end
        return
    end
    local pack = ANIM_PACKS[packName]
    if not pack then return end
    if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect() end
    tryardHeartbeatConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        if not c then return end
        local animate = c:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj,id) if obj then obj.AnimationId = id end end
        s(animate.idle and animate.idle.Animation1, pack.idle1)
        s(animate.idle and animate.idle.Animation2, pack.idle2)
        s(animate.walk and animate.walk.WalkAnim, pack.walk)
        s(animate.run  and animate.run.RunAnim,   pack.run)
        s(animate.jump and animate.jump.JumpAnim, pack.jump)
        s(animate.fall and animate.fall.FallAnim, pack.fall)
        s(animate.climb and animate.climb.ClimbAnim, pack.climb)
        s(animate.swim and animate.swim.Swim, pack.swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, pack.swimidle)
    end)
end

local function startAnimPack(packName)
    local char = LP.Character
    if char then
        saveOriginalAnims(char)
        applyAnimPack(packName)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    else
        applyAnimPack(packName)
    end
    currentAnimPack = packName
end

local function stopAnimPack()
    currentAnimPack = "Off"
    if animSelectorLabel then animSelectorLabel.Text = "Off" end
    applyAnimPack("Off")
end

-- ═══════════════════════════════════════════════════════════════
-- KEYBINDS: TPBat en X, DropBrainrot en J (liberamos X)
-- ═══════════════════════════════════════════════════════════════
DEFAULT_KB = {
    DropBrainrot = {kb = Enum.KeyCode.J, gp = nil},
    AutoLeft     = {kb = Enum.KeyCode.Z, gp = nil},
    AutoRight    = {kb = Enum.KeyCode.C, gp = nil},
    AutoBat      = {kb = Enum.KeyCode.E, gp = nil},
    TPFloor      = {kb = Enum.KeyCode.F, gp = nil},
    GuiHide      = {kb = Enum.KeyCode.LeftControl, gp = nil},
    CarryToggle  = {kb = Enum.KeyCode.Q, gp = nil},
    LaggerMode   = {kb = Enum.KeyCode.R, gp = nil},
    TPBat        = {kb = Enum.KeyCode.X, gp = nil},
    BatV2        = {kb = Enum.KeyCode.V, gp = nil},
    InstaReset   = {kb = Enum.KeyCode.H, gp = nil},
}

KB = {
    DropBrainrot = {kb = DEFAULT_KB.DropBrainrot.kb, gp = DEFAULT_KB.DropBrainrot.gp},
    AutoLeft     = {kb = DEFAULT_KB.AutoLeft.kb, gp = DEFAULT_KB.AutoLeft.gp},
    AutoRight    = {kb = DEFAULT_KB.AutoRight.kb, gp = DEFAULT_KB.AutoRight.gp},
    AutoBat      = {kb = DEFAULT_KB.AutoBat.kb, gp = DEFAULT_KB.AutoBat.gp},
    TPFloor      = {kb = DEFAULT_KB.TPFloor.kb, gp = DEFAULT_KB.TPFloor.gp},
    GuiHide      = {kb = DEFAULT_KB.GuiHide.kb, gp = DEFAULT_KB.GuiHide.gp},
    CarryToggle  = {kb = DEFAULT_KB.CarryToggle.kb, gp = DEFAULT_KB.CarryToggle.gp},
    LaggerMode   = {kb = DEFAULT_KB.LaggerMode.kb, gp = DEFAULT_KB.LaggerMode.gp},
    TPBat        = {kb = DEFAULT_KB.TPBat.kb, gp = DEFAULT_KB.TPBat.gp},
    BatV2        = {kb = DEFAULT_KB.BatV2.kb, gp = DEFAULT_KB.BatV2.gp},
    InstaReset   = {kb = DEFAULT_KB.InstaReset.kb, gp = DEFAULT_KB.InstaReset.gp},
}

_isResetting = false
_lastSavedJSON = nil
_isLoading = false
_configReady = false

CONFIG = {
    AUTO_STEAL_ENABLED = false,
    STEAL_RANGE = 61,
}

local stealConnection = nil

local Steal = {
    AutoStealEnabled = false,
    StealRadius = CONFIG.STEAL_RANGE,
    StealDuration = 1.3,
    StealDelay = 0.25,
    Data = {}
}

local isStealing = false
autoStealVariant = 2
autoStealSemiRadius = 10
autoStealSemiNormalPct = 75
refreshStealModeRows = nil

AUTO_STEAL_VARIANT_NAMES = { "Semi", "Semi Normal" }

local function autoStealVariantName(n)
    n = _clamp((tonumber(n) or 2) - 1, 1, #AUTO_STEAL_VARIANT_NAMES)
    return AUTO_STEAL_VARIANT_NAMES[n]
end

local function autoStealVariantFromName(name)
    for i, v in ipairs(AUTO_STEAL_VARIANT_NAMES) do
        if v == tostring(name) then return i + 1 end
    end
    return 2
end

local _plotsCache = nil
local _plotsCacheTime = 0
local function getPlotsRoot()
    local now = _tick()
    if _plotsCache and now - _plotsCacheTime < 2 and _plotsCache.Parent then
        return _plotsCache
    end
    _plotsCache = workspace:FindFirstChild("Plots")
    _plotsCacheTime = now
    return _plotsCache
end

local function isMyPlotByName(plotName)
    local plotsRoot = getPlotsRoot()
    if not plotsRoot then return false end
    local plot = plotsRoot:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local char = LP.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local plotsRoot = getPlotsRoot()
    if not plotsRoot then return nil, nil end
    local nearestPrompt, nearestDist, nearestName = nil, _huge, nil
    local rpos = root.Position
    for _, plot in ipairs(plotsRoot:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local sp = spawn.Position
                    local dx = sp.X - rpos.X
                    local dy = sp.Y - rpos.Y
                    local dz = sp.Z - rpos.Z
                    local dist = _sqrt(dx*dx + dy*dy + dz*dz)
                    if dist < nearestDist and dist <= Steal.StealRadius then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, child in ipairs(att:GetChildren()) do
                                if child:IsA("ProximityPrompt") and child.ActionText and child.ActionText:find("Steal") then
                                    nearestPrompt = child
                                    nearestDist = dist
                                    nearestName = pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return nearestPrompt, nearestName
end

do
    local ragdollConns = nil
    local function bindStealRagdoll(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        if ragdollConns then
            for _, c in ipairs(ragdollConns) do c:Disconnect() end
            ragdollConns = nil
        end
        local lastStateChange = 0
        local function markRagdoll()
            if Steal.Ragdolled then return end
            Steal.Ragdolled = true
            Steal.BarRagdollUntil = _tick() + 1.45
            lastStateChange = _tick()
            Steal.RagdollCount = (Steal.RagdollCount or 0) + 1
            local snapshot = Steal.RagdollCount
            task.spawn(function()
                task.wait(0.5)
                if Steal.RagdollCount == snapshot then Steal.Ragdolled = false end
            end)
        end
        local function clearRagdoll()
            if _tick() - lastStateChange < 1 then return end
            if Steal.Ragdolled then Steal.Ragdolled = false end
        end
        local conn1 = humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll then
                markRagdoll()
            elseif newState == Enum.HumanoidStateType.GettingUp then
                clearRagdoll()
            end
        end)
        local conn2 = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if humanoid.PlatformStand then markRagdoll() else clearRagdoll() end
        end)
        ragdollConns = { conn1, conn2 }
    end
    if LP.Character then task.spawn(bindStealRagdoll, LP.Character) end
    LP.CharacterAdded:Connect(function(character)
        task.wait(1)
        bindStealRagdoll(character)
    end)
end

local function executeSteal(prompt, podName)
    if isStealing then return end
    if Steal.Ragdolled then return end
    if math.random(30) == 1 then
        for p in pairs(Steal.Data) do
            if not p.Parent then Steal.Data[p] = nil end
        end
    end
    if not Steal.Data[prompt] then
        Steal.Data[prompt] = { hold = {}, trigger = {}, ready = true }
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(Steal.Data[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(Steal.Data[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = Steal.Data[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
    if progressPct then progressPct.Text = "0%" end
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        local startTime = _tick()
        local duration = Steal.StealDuration

        local function setFill(ratio)
            if _tick() < (Steal.BarRagdollUntil or 0) then ratio = 0 end
            if progressFill then progressFill.Size = UDim2.new(ratio, 0, 1, 0) end
            if progressPct then progressPct.Text = _floor(ratio * 100) .. "%" end
        end

        local function promptDist()
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and prompt.Parent and prompt.Parent.Parent then
                return (hrp.Position - prompt.Parent.Parent.Position).Magnitude
            end
            return nil
        end

        local function fireSteal()
            pcall(function()
                for _, f in ipairs(data.trigger) do task.spawn(f) end
                local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                if remote and podName then remote:FireServer(podName) end
                if prompt then prompt:Fire() end
            end)
        end

        if autoStealVariant == 2 then
            -- SEMI: fills while inside the steal radius, grabs only once inside the Semi radius
            local holdMin = 1.3
            local holdMax = 2.6
            local entryDelay = 0.3
            local semiCooldown = 0.05
            local continueRadius = autoStealSemiRadius
            local d0 = promptDist()
            local inRangeAtStart = d0 ~= nil and d0 <= continueRadius
            local phase = "holding"
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = _tick() - startTime
                setFill(_clamp(elapsed / holdMin, 0, 1))
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local dist = promptDist()
                if dist and dist > Steal.StealRadius then break end
                if phase == "holding" then
                    if elapsed >= holdMin then phase = "waitingRange" end
                else
                    if elapsed > holdMax then break end
                    if dist and dist <= continueRadius then
                        if not inRangeAtStart then task.wait(entryDelay) end
                        fireSteal()
                        setFill(1)
                        task.wait(semiCooldown)
                        break
                    end
                end
                task.wait()
            end
        else
            -- SEMI NORMAL: fills to the stop %, waits until inside the continue radius (or timeout), then finishes
            local pauseRatio = autoStealSemiNormalPct / 100
            local waitTimeout = 1.7
            local continueRadius = 10
            local isPaused = false
            local pauseSnapshot = false
            local pauseStart = 0
            local pausedRatio = 0
            while isStealing and Steal.AutoStealEnabled do
                if not prompt.Parent or not prompt.Parent.Parent then break end
                if Steal.Ragdolled then break end
                local dist = promptDist()
                if dist and dist > Steal.StealRadius then break end
                if not isPaused then
                    local ratio = _clamp((_tick() - startTime) / duration, 0, 1)
                    if ratio >= pauseRatio and not pauseSnapshot then
                        isPaused = true
                        pauseSnapshot = true
                        pausedRatio = pauseRatio
                        pauseStart = _tick()
                        setFill(pauseRatio)
                    else
                        setFill(ratio)
                        if ratio >= 1 then
                            fireSteal()
                            break
                        end
                    end
                else
                    if _tick() - pauseStart >= waitTimeout or (dist and dist <= continueRadius) then
                        isPaused = false
                        startTime = _tick() - pausedRatio * duration
                    end
                end
                task.wait()
            end
        end
        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
        if progressPct then progressPct.Text = "0%" end
        data.ready = true
        isStealing = false
    end)
end

function startAutoSteal()
    if stealConnection then
        local connected = false
        pcall(function() connected = stealConnection.Connected == true end)
        if connected then
            Steal.StealRadius = CONFIG.STEAL_RANGE
            Steal.AutoStealEnabled = true
            CONFIG.AUTO_STEAL_ENABLED = true
            return true
        end
        pcall(function() stealConnection:Disconnect() end)
        stealConnection = nil
    end
    Steal.StealRadius = CONFIG.STEAL_RANGE
    Steal.AutoStealEnabled = true
    CONFIG.AUTO_STEAL_ENABLED = true
    local lastStealScan = 0
    stealConnection = RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        local nowScan = _tick()
        if nowScan - lastStealScan < 0.05 then return end
        lastStealScan = nowScan
        local p, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
    return true
end

function stopAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
    isStealing = false
    Steal.AutoStealEnabled = false
    CONFIG.AUTO_STEAL_ENABLED = false
    if progressFill then
        TS:Create(progressFill, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 1, 0) }):Play()
    end
    if progressPct then progressPct.Text = "0%" end
end

medusaDebounce = false
medusaLastUsed = 0
dropActive = false
lastDropTime = 0
lastMoveDir = _V3new(0,0,0)
origFOV = nil
fovEnabled = false
fovValue = 70
customFovConn = nil
setFovVisual = nil
fovSliderSet = nil

_anyKeyListening = false
_aimbotConn = nil
_prevAutoRotate = nil
tpBatFloatingButton = nil

enemySpeedConn = nil
movementLoop = nil
steppedConn = nil
alConn = nil
arConn = nil
stretchConn = nil
stretchFovConn = nil
dropConnections = {}
enemySpeedLabels = {}
Conns = {autoSteal = nil, batCounter = nil, anchor = {}, progress = nil, autoLeft = nil, autoRight = nil}
keyButtonRefs = {}
progressFill = nil
progressPct = nil
pbFrame = nil
speedLabel = nil
modeValLbl = nil
normalBox, carryBox, laggerBox, lagger2Box, radInput, batSpeedBox, uiScaleBox = nil, nil, nil, nil, nil, nil, nil
floatScaleBox, pbScaleBox = nil, nil
dropModeBtnRef = nil
autoBatSetVisual, autoLeftSetVisual, autoRightSetVisual, setBatCounterVisual, setMedusaVisual = nil, nil, nil, nil, nil
setUnwalkVisual, setAntiLagVisual, setLockUIVisual, setInstaGrab = nil, nil, nil, nil
setAntiDieVisual = nil
setESPVIsual = nil
mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight, mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2 = nil, nil, nil, nil, nil, nil, nil, nil
autoBatV2SetVisual = nil
miniBtn, main, gui = nil, nil, nil
MobilePanel = nil
instaResetFloatingButton = nil
showGui = nil
hideGui = nil
mainUIScale = nil
animSelectorLabel = nil
pbScale = nil
tabButtons = nil

autoStealVariantLabel = nil
aimModeLabel = nil
tpBatVersionLabel = nil
tpBatSpinRow = nil
tpBatSpinBox = nil
tpBatRefreshUI = nil
stealSemiRadiusRow, stealSemiRadiusBox, stealSemiPctRow, stealSemiPctValue = nil, nil, nil, nil

setSafeModeVisual           = nil
mirrorTPDownSetVisual       = nil
infJumpSetVisual            = nil
infJumpModeSetVisual        = nil

-- ═══════════════════════════════════════════════════════════════
-- NUEVO MÓDULO: NO CAMERA COLLISION
-- ═══════════════════════════════════════════════════════════════
noCamCollisionEnabled = false
setNoCamCollisionVisual = nil

GAMEPAD_KEYS = {
    [Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true,
    [Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true,
    [Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true,
    [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true,
    [Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true,
    [Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true,
    [Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true,
    [Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true,
}

MOVE_KEYS = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
    [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
}

BAT_COUNTER_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

AP = {
    L1 = _V3new(-476.48, -6.28, 92.73),
    L2 = _V3new(-483.12, -4.95, 94.80),
    L_FACE = _V3new(-482.25, -4.96, 92.09),
    R1 = _V3new(-476.16, -6.52, 25.62),
    R2 = _V3new(-483.06, -5.03, 25.48),
    R_FACE = _V3new(-482.06, -6.93, 35.47),
}

function isGamepadInput(inp)
    return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil
end

function isBindableInput(inp)
    if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
    if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
    return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
end

function kbMatch(entry, kc)
    return kc and (kc == entry.kb or (entry.gp and kc == entry.gp))
end


local function doTpDown()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        root.CFrame = _CFnew(root.Position.X, -7, root.Position.Z) * CFrame.Angles(0, select(2, root.CFrame:ToEulerAnglesYXZ()), 0)
        root.Velocity = _V3zero
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MIRROR TP DOWN
-- ═══════════════════════════════════════════════════════════════
do
    local MIRROR_TP_DROP_THRESHOLD = 3
    local MIRROR_TP_DOWN_Y         = -7.00
    local mirrorTPPreviousY        = {}
    local mirrorTPLastTeleport     = 0

    local function mirrorTPAimbotActive()
        return (_G.MeridianNormalAimbotOn == true)
            or (_G.MeridianBatAimbotV2On == true)
            or (_G.MeridianTPBatOn == true)
            or (_G.AlvaroTP and _G.AlvaroTP.on == true)
            or (autoBatEnabled == true)
            or (autoBatV2Enabled == true)
            or (batDesyncTpEnabled == true)
    end

    local function mirrorTPTeleportDown()
        local character = LP.Character
        local root      = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid  = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or humanoid.Health <= 0 then return end
        local now = _tick()
        if now - mirrorTPLastTeleport < 0.08 then return end
        mirrorTPLastTeleport = now
        local _, yaw = root.CFrame:ToEulerAnglesYXZ()
        root.CFrame = _CFnew(root.Position.X, MIRROR_TP_DOWN_Y, root.Position.Z)
                   * CFrame.Angles(0, yaw, 0)
        root.Velocity = _V3zero
        pcall(function() root.AssemblyLinearVelocity = _V3zero end)
    end

    RunService.Heartbeat:Connect(function()
        if not mirrorTPDownEnabled or not mirrorTPAimbotActive() then
            table.clear(mirrorTPPreviousY)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local currentY  = root.Position.Y
                    local previousY = mirrorTPPreviousY[player.UserId]
                    if previousY
                       and previousY - currentY >= MIRROR_TP_DROP_THRESHOLD then
                        pcall(mirrorTPTeleportDown)
                        table.clear(mirrorTPPreviousY)
                        return
                    end
                    mirrorTPPreviousY[player.UserId] = currentY
                end
            end
        end
    end)

    function _G.MeridianSetMirrorTPDown(enabled)
        mirrorTPDownEnabled = enabled == true
        if not mirrorTPDownEnabled then table.clear(mirrorTPPreviousY) end
        if mirrorTPDownSetVisual then
            mirrorTPDownSetVisual(mirrorTPDownEnabled)
        end
        pcall(saveAllSettings)
    end
end

-- ============================================================
-- SAFE MODE (ADAPT logic): round-countdown detection, brainrot detection and
-- a pending queue. While the round countdown runs (or a brainrot is held) any
-- action you turn ON stays ON but idle, then starts when the lock ends.
-- ============================================================
_G.MeridianSafeModeState = {
    countdown = false,
    holding   = false,
    pending   = { autoLeft = false, autoRight = false, autoBat = false, batV2 = false, tpBat = false },
    queuedAt  = { autoLeft = 0, autoRight = 0, autoBat = 0, batV2 = 0, tpBat = 0 },
    timerPhase = "unknown",
}

function _G.MeridianSafeModeCountdownActive()
    local st = _G.MeridianSafeModeState

    local function inactive()
        if st then
            st.timerLastNumber = nil
            if st.timerPhase == "round" or st.timerRoundSeen then
                st.timerInactiveSince = st.timerInactiveSince or os.clock()
                if os.clock() - st.timerInactiveSince >= 0.75 then
                    st.timerPhase = "inactive"
                    st.timerStartUsed = false
                    st.timerRoundSeen = false
                    st.timerSawInactive = true
                end
            elseif st.timerPhase == "unknown" then
                st.timerPhase = "inactive"
                st.timerSawInactive = true
            end
        end
        return false
    end

    local pg = LP:FindFirstChild("PlayerGui")
    local label = pg and pg:FindFirstChild("DuelsMachineTopFrame", true)
    label = label and label:FindFirstChild("Timer", true)
    label = label and label:FindFirstChild("Label", true)
    if not label or not label:IsA("TextLabel") then
        return inactive()
    end

    local parent = label
    while parent and parent ~= pg do
        if parent:IsA("GuiObject") and parent.Visible == false then return inactive() end
        if parent:IsA("ScreenGui") and parent.Enabled == false then return inactive() end
        parent = parent.Parent
    end

    local text = tostring(label.Text or ""):upper():gsub("<.->", ""):gsub("%s+", "")
    if st then st.timerInactiveSince = nil end

    if text == "READY" or text == "STARTING" or text == "GETREADY" then
        if st then
            if st.timerPhase ~= "starting" then st.timerStartUsed = false end
            st.timerPhase = "starting"
            st.timerLastNumber = nil
            st.timerSawInactive = false
            st.timerStartUsed = true
        end
        return true
    end

    if text == "GO" or text == "FIGHT" then
        if st then
            st.timerPhase = "round"
            st.timerRoundSeen = true
            st.timerStartUsed = true
            st.timerLastNumber = nil
        end
        return false
    end

    local mm, ss = text:match("^(%d+):(%d+)$")
    if mm and ss then
        local total = tonumber(mm) * 60 + tonumber(ss)
        if st then
            if total <= 0 and st.timerRoundSeen then
                st.timerPhase = "inactive"
                st.timerStartUsed = false
                st.timerRoundSeen = false
                st.timerSawInactive = true
            else
                st.timerPhase = "round"
                st.timerRoundSeen = true
                st.timerStartUsed = true
                st.timerSawInactive = false
            end
            st.timerLastNumber = total
        end
        return false
    end

    local n = tonumber(text)
    if not n then return false end

    if n > 10 then
        if st then
            st.timerPhase = "round"
            st.timerRoundSeen = true
            st.timerStartUsed = true
            st.timerLastNumber = n
            st.timerSawInactive = false
        end
        return false
    end

    if n <= 0 then
        if st then
            st.timerLastNumber = n
            if st.timerPhase == "round" or st.timerRoundSeen then
                st.timerPhase = "inactive"
                st.timerStartUsed = false
                st.timerRoundSeen = false
                st.timerSawInactive = true
            end
        end
        return false
    end

    local roundSeen = st and (st.timerRoundSeen or st.timerStartUsed)
    if roundSeen and st.timerPhase ~= "starting" then
        st.timerLastNumber = n
        return false
    end
    if st and st.timerPhase == "starting" then
        st.timerLastNumber = n
        return true
    end
    if st and st.timerStartUsed ~= true and st.timerSawInactive then
        st.timerPhase = "starting"
        st.timerStartUsed = true
        st.timerLastNumber = n
        st.timerSawInactive = false
        return true
    end
    if st then st.timerLastNumber = n end
    return false
end
_G.MeridianSafeModeInDuelCountdown = _G.MeridianSafeModeCountdownActive

_G.MeridianSafeModeCarryNames = { "Stealing", "Carrying", "IsCarrying", "HoldingBrainrot", "HasBrainrot" }

function _G.MeridianSafeModeHoldingBrainrot()
    for _, name in ipairs(_G.MeridianSafeModeCarryNames) do
        local ok, result = pcall(function() return LP:GetAttribute(name) end)
        if ok and result == true then return true end
    end
    local char = LP.Character
    if not char then return false end
    for _, name in ipairs(_G.MeridianSafeModeCarryNames) do
        local ok, result = pcall(function() return char:GetAttribute(name) end)
        if ok and result == true then return true end
        local v = char:FindFirstChild(name, true)
        if v and v:IsA("BoolValue") and v.Value then return true end
    end
    return false
end


do
    -- ═══════════════════════════════════════════════════════════
    -- PILL NOTIFICATIONS
    -- ═══════════════════════════════════════════════════════════
    local notifyGui, notifyHolder = nil, nil
    local notifyActive = {}
    local notifySerial = 0
    local NOTIFY_MAX  = 3
    local NOTIFY_LIFE = 2.4
    local NOTIFY_COLORS = {
        ok   = Color3.fromRGB(61, 220, 132),
        info = Color3.fromRGB(90, 169, 255),
        warn = Color3.fromRGB(255, 176, 32),
    }

    local function notifyEnsure()
        if notifyGui and notifyGui.Parent and notifyHolder and notifyHolder.Parent then return end
        pcall(function() if notifyGui then notifyGui:Destroy() end end)
        local gui = Instance.new("ScreenGui")
        gui.Name = "MeridianHubNotify"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 50
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
        local parented = pcall(function() gui.Parent = game:GetService("CoreGui") end)
        if not parented or not gui.Parent then
            gui.Parent = LP:WaitForChild("PlayerGui")
        end
        local holder = Instance.new("Frame")
        holder.Name = "Holder"
        holder.AnchorPoint = Vector2.new(1, 0)
        holder.Position = UDim2.new(1, -12, 0, 56)
        holder.Size = UDim2.new(0, 380, 0, 0)
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.BackgroundTransparency = 1
        holder.Parent = gui
        local list = Instance.new("UIListLayout")
        list.FillDirection = Enum.FillDirection.Vertical
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 6)
        list.Parent = holder
        notifyGui, notifyHolder = gui, holder
    end

    local function notifyRemove(entry, instant)
        if entry.removed then return end
        entry.removed = true
        for i, e in ipairs(notifyActive) do
            if e == entry then
                table.remove(notifyActive, i)
                break
            end
        end
        if instant then
            pcall(function() entry.slot:Destroy() end)
            return
        end
        local ti = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        pcall(function()
            TS:Create(entry.card, ti, { Position = UDim2.new(1, 0, 0, -14), GroupTransparency = 1 }):Play()
        end)
        task.delay(0.27, function() pcall(function() entry.slot:Destroy() end) end)
    end

    local NOTIFY_TITLES = { ok = "DONE", info = "INFO", warn = "WARNING" }
    local NOTIFY_ICONS  = { ok = "\u{2713}", info = "i", warn = "!" }

    ---Banner Card notification (kind: "ok" | "info" | "warn", optional custom title).
    function _G.MeridianNotify(text, kind, title)
        text = tostring(text or "")
        if text == "" then return end
        if not pcall(notifyEnsure) or not notifyHolder then return end
        kind = NOTIFY_COLORS[kind or "info"] and (kind or "info") or "info"

        -- same message already on screen: just keep it alive longer
        for _, e in ipairs(notifyActive) do
            if e.text == text then
                e.token = e.token + 1
                local tok = e.token
                task.delay(NOTIFY_LIFE, function()
                    if e.token == tok then notifyRemove(e) end
                end)
                return
            end
        end
        while #notifyActive >= NOTIFY_MAX do
            notifyRemove(notifyActive[1], true)
        end

        notifySerial = notifySerial + 1
        local color = NOTIFY_COLORS[kind]

        local slot = Instance.new("Frame")
        slot.BackgroundTransparency = 1
        slot.Size = UDim2.new(1, 0, 0, 46)
        slot.LayoutOrder = notifySerial
        slot.Parent = notifyHolder

        local card = Instance.new("CanvasGroup")
        card.Name = "Card"
        card.AnchorPoint = Vector2.new(1, 0)
        card.Position = UDim2.new(1, 80, 0, 0)
        card.Size = UDim2.new(0, 0, 0, 44)
        card.AutomaticSize = Enum.AutomaticSize.X
        card.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
        card.BackgroundTransparency = 0.06
        card.BorderSizePixel = 0
        card.GroupTransparency = 1
        card.Parent = slot
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        local sizeLimit = Instance.new("UISizeConstraint", card)
        sizeLimit.MinSize = Vector2.new(210, 0)

        local bar = Instance.new("Frame", card)
        bar.Name = "AccentBar"
        bar.Size = UDim2.new(0, 4, 1, 0)
        bar.BackgroundColor3 = color
        bar.BorderSizePixel = 0

        local content = Instance.new("Frame", card)
        content.Name = "Content"
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(0, 0, 1, -2)
        content.AutomaticSize = Enum.AutomaticSize.X
        local pad = Instance.new("UIPadding", content)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        local row = Instance.new("UIListLayout", content)
        row.FillDirection = Enum.FillDirection.Horizontal
        row.VerticalAlignment = Enum.VerticalAlignment.Center
        row.SortOrder = Enum.SortOrder.LayoutOrder
        row.Padding = UDim.new(0, 10)

        local icon = Instance.new("TextLabel", content)
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.BackgroundColor3 = color
        icon.BorderSizePixel = 0
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 13
        icon.TextColor3 = Color3.fromRGB(11, 12, 16)
        icon.Text = NOTIFY_ICONS[kind]
        icon.LayoutOrder = 1
        Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

        local col = Instance.new("Frame", content)
        col.Name = "Text"
        col.BackgroundTransparency = 1
        col.Size = UDim2.new(0, 0, 0, 26)
        col.AutomaticSize = Enum.AutomaticSize.X
        col.LayoutOrder = 2
        local colList = Instance.new("UIListLayout", col)
        colList.FillDirection = Enum.FillDirection.Vertical
        colList.VerticalAlignment = Enum.VerticalAlignment.Center
        colList.SortOrder = Enum.SortOrder.LayoutOrder
        colList.Padding = UDim.new(0, 1)

        local small = Instance.new("TextLabel", col)
        small.Name = "Title"
        small.AutomaticSize = Enum.AutomaticSize.X
        small.Size = UDim2.new(0, 0, 0, 11)
        small.BackgroundTransparency = 1
        small.Font = Enum.Font.GothamBold
        small.TextSize = 9
        small.TextColor3 = color
        small.TextXAlignment = Enum.TextXAlignment.Left
        small.Text = tostring(title or NOTIFY_TITLES[kind])
        small.LayoutOrder = 1

        local label = Instance.new("TextLabel", col)
        label.Name = "Message"
        label.AutomaticSize = Enum.AutomaticSize.X
        label.Size = UDim2.new(0, 0, 0, 14)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.LayoutOrder = 2

        local life = Instance.new("Frame", card)
        life.Name = "LifeBar"
        life.Position = UDim2.new(0, 4, 1, -2)
        life.Size = UDim2.new(1, -4, 0, 2)
        life.BackgroundColor3 = color
        life.BorderSizePixel = 0

        local entry = { text = text, slot = slot, card = card, token = 1 }
        table.insert(notifyActive, entry)

        pcall(function()
            TS:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Position = UDim2.new(1, 0, 0, 0) }):Play()
            TS:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { GroupTransparency = 0 }):Play()
            TS:Create(life, TweenInfo.new(NOTIFY_LIFE, Enum.EasingStyle.Linear),
                { Size = UDim2.new(0, 0, 0, 2) }):Play()
        end)
        task.delay(NOTIFY_LIFE, function()
            if entry.token == 1 then notifyRemove(entry) end
        end)
    end

    -- ============================================================
    -- SAFE MODE QUEUE (ADAPT logic, pending map)
    -- ============================================================
    local SM = {}
    _G.MeridianSM = SM
    local S = _G.MeridianSafeModeState
    local SM_DEBOUNCE = 0.25

    local SM_IDS = { "autoLeft", "autoRight", "autoBat", "batV2", "tpBat" }
    local SM_LABELS = {
        autoLeft  = "AUTO LEFT",
        autoRight = "AUTO RIGHT",
        autoBat   = "AUTO BAT",
        batV2     = "BAT BYPASS",
        tpBat     = "TP BAT",
    }

    local function smFloatPaint()
        pcall(function()
            if tpBatFloatingButton then
                local f = tpBatFloatingButton:FindFirstChild("Frame")
                if f then paintFloatingBtn(f, batDesyncTpEnabled == true) end
            end
        end)
    end

    local function smVisual(id, on)
        pcall(function()
            if id == "autoLeft" then
                if autoLeftSetVisual then autoLeftSetVisual(on) end
                if mobSetAutoLeft then mobSetAutoLeft(on) end
            elseif id == "autoRight" then
                if autoRightSetVisual then autoRightSetVisual(on) end
                if mobSetAutoRight then mobSetAutoRight(on) end
            elseif id == "autoBat" then
                if autoBatSetVisual then autoBatSetVisual(on) end
                if mobSetAutoBat then mobSetAutoBat(on) end
            elseif id == "batV2" then
                if autoBatV2SetVisual then autoBatV2SetVisual(on) end
            elseif id == "tpBat" then
                if batDesyncTpSetVisual then batDesyncTpSetVisual(on) end
            end
        end)
        if id == "batV2" or id == "tpBat" then smFloatPaint() end
    end

    local function smSetFlag(id, on)
        if id == "autoLeft" then autoLeftEnabled = on
        elseif id == "autoRight" then autoRightEnabled = on
        elseif id == "autoBat" then autoBatEnabled = on
        elseif id == "batV2" then autoBatV2Enabled = on end
    end

    local function smIsOn(id)
        if id == "autoLeft" then return autoLeftEnabled == true end
        if id == "autoRight" then return autoRightEnabled == true end
        if id == "autoBat" then return autoBatEnabled == true end
        if id == "batV2" then return autoBatV2Enabled == true end
        if id == "tpBat" then return batDesyncTpEnabled == true end
        return false
    end

    -- stop the loop only (the toggle keeps showing ON while the action waits)
    local function smSoftStop(id)
        pcall(function()
            if id == "autoLeft" then stopAutoLeft()
            elseif id == "autoRight" then stopAutoRight()
            elseif id == "autoBat" then stopAimbotAdapt()
            elseif id == "batV2" then _G.AceStopAntiBypassAimbot(false)
            elseif id == "tpBat" then stopBatDesyncTp() end
        end)
        smSetFlag(id, false)
    end

    local function smStart(id)
        if id == "autoLeft" then startAutoLeft()
        elseif id == "autoRight" then startAutoRight()
        elseif id == "autoBat" then enableAutoBat()
        elseif id == "batV2" then enableBatV2()
        elseif id == "tpBat" then startBatDesyncTp() end
    end

    -- actions never run together (each start function turns the others off),
    -- so queuing one drops whatever else was waiting
    local function smDropOthers(id)
        for _, other in ipairs(SM_IDS) do
            if other ~= id and S.pending[other] then
                S.pending[other] = false
                S.queuedAt[other] = 0
                smSetFlag(other, false)
                smVisual(other, false)
            end
        end
    end

    function SM.queue(id, reason)
        if S.pending[id] then
            -- pressed again while waiting: cancel (small debounce so the same press cannot cancel itself)
            if os.clock() - (S.queuedAt[id] or 0) >= SM_DEBOUNCE then SM.cancel(id) end
            return
        end
        smDropOthers(id)
        S.pending[id] = true
        S.queuedAt[id] = os.clock()
        smSetFlag(id, false)
        smVisual(id, true)
        _G.MeridianNotify(SM_LABELS[id] .. " QUEUED - " .. tostring(reason or "ROUND COUNTDOWN"), "info", "QUEUED")
    end

    function SM.cancel(id, silent)
        if not S.pending[id] then return end
        S.pending[id] = false
        S.queuedAt[id] = 0
        smSetFlag(id, false)
        smVisual(id, false)
        if not silent then
            _G.MeridianNotify(SM_LABELS[id] .. " QUEUE CANCELED", "warn")
        end
    end

    function SM.clear()
        for _, id in ipairs(SM_IDS) do SM.cancel(id, true) end
    end

    -- something running when the lock starts is paused and waits in the queue
    local function smPauseActive()
        for _, id in ipairs(SM_IDS) do
            if smIsOn(id) then
                smSoftStop(id)
                S.pending[id] = true
                S.queuedAt[id] = os.clock()
                smVisual(id, true)
            end
        end
    end

    local function smApplyOn(id)
        smSetFlag(id, true)
        smStart(id)
        if smIsOn(id) then
            smVisual(id, true)
        else
            smSetFlag(id, false)
            smVisual(id, false)
        end
    end

    function _G.MeridianSafeModeBlockReason()
        if not antiKickEnabled then return nil end
        if S.countdown then return "ROUND COUNTDOWN" end
        if S.holding then return "BRAINROT HELD" end
        return nil
    end

    function _G.MeridianSafeModeIsQueued(id)
        return S.pending[id] == true
    end

    function _G.MeridianSafeModeIsLocked()
        return _G.MeridianSafeModeBlockReason() ~= nil
    end

    -- true when the action may start now; otherwise it is queued and this returns false, reason
    function _G.MeridianSafeModeTryStart(id)
        if not antiKickEnabled then return true end
        local reason = _G.MeridianSafeModeBlockReason()
        if reason then
            if id and SM_LABELS[id] then SM.queue(id, reason) end
            return false, reason
        end
        if id and S.pending[id] then
            S.pending[id] = false
            S.queuedAt[id] = 0
        end
        return true
    end
    _G.AceSafeModeTryStart = _G.MeridianSafeModeTryStart

    function _G.MeridianSafeModeEvaluate()
        local countdown = _G.MeridianSafeModeCountdownActive() == true
        local holding = _G.MeridianSafeModeHoldingBrainrot() == true
        local cdStart = countdown and not S.countdown
        local cdEnd = S.countdown and not countdown
        local holdStart = holding and not S.holding
        S.countdown = countdown
        S.holding = holding

        if not antiKickEnabled then
            for _, id in ipairs(SM_IDS) do
                if S.pending[id] then
                    S.pending[id] = false
                    S.queuedAt[id] = 0
                    smApplyOn(id)
                end
            end
            return
        end

        if cdStart then
            _G.MeridianNotify("ROUND COUNTDOWN - ACTIONS LOCKED", "warn")
            smPauseActive()
        end
        if holdStart then smPauseActive() end
        if cdEnd then _G.MeridianNotify("ROUND COUNTDOWN ENDED", "ok") end

        for _, id in ipairs(SM_IDS) do
            if S.pending[id] and not _G.MeridianSafeModeBlockReason() then
                S.pending[id] = false
                S.queuedAt[id] = 0
                smApplyOn(id)
                _G.MeridianNotify(SM_LABELS[id] .. " ENABLED", "ok")
            end
        end
    end

    -- monitor: re-evaluate 10x per second and on every carry attribute change
    do
        pcall(function()
            if _G.MeridianSafeModeMonitor then _G.MeridianSafeModeMonitor:Disconnect() end
            if type(_G.MeridianSafeModeCarryConns) == "table" then
                for _, c in pairs(_G.MeridianSafeModeCarryConns) do pcall(function() c:Disconnect() end) end
            end
        end)
        local conns = {}
        _G.MeridianSafeModeCarryConns = conns

        local function kick()
            task.defer(function() pcall(_G.MeridianSafeModeEvaluate) end)
        end

        local function watchChar(char)
            for k in pairs(conns) do
                if tostring(k):sub(1, 5) == "char_" then
                    pcall(function() conns[k]:Disconnect() end)
                    conns[k] = nil
                end
            end
            if not char then return end
            for _, name in ipairs(_G.MeridianSafeModeCarryNames) do
                conns["char_attr_" .. name] = char:GetAttributeChangedSignal(name):Connect(kick)
                local v = char:FindFirstChild(name, true)
                if v and v:IsA("BoolValue") then
                    conns["char_value_" .. name] = v:GetPropertyChangedSignal("Value"):Connect(kick)
                end
            end
            conns.char_added = char.DescendantAdded:Connect(function(d)
                if table.find(_G.MeridianSafeModeCarryNames, d.Name) then
                    if d:IsA("BoolValue") then
                        conns["char_value_" .. d.Name] = d:GetPropertyChangedSignal("Value"):Connect(kick)
                    end
                    kick()
                elseif d:IsA("Tool") then
                    kick()
                end
            end)
            conns.char_removed = char.DescendantRemoving:Connect(function(d)
                if table.find(_G.MeridianSafeModeCarryNames, d.Name) or d:IsA("Tool") then kick() end
            end)
        end

        for _, name in ipairs(_G.MeridianSafeModeCarryNames) do
            conns["player_attr_" .. name] = LP:GetAttributeChangedSignal(name):Connect(kick)
        end
        conns.character = LP.CharacterAdded:Connect(function(char)
            watchChar(char)
            kick()
        end)
        watchChar(LP.Character)

        _G.MeridianSafeModeMonitor = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if now - (S.lastCheck or 0) < 0.1 then return end
            S.lastCheck = now
            pcall(_G.MeridianSafeModeEvaluate)
        end)
    end
end

local AntiRagdollV1 = {}
AntiRagdollV1.__index = AntiRagdollV1


local stateV1 = {
    active = false,
    isBoosting = false,
    cachedChar = nil,
    ragdollConnections = {},
    _lastBoostTime = 0,
}

local function getAntiRagdollRecoverySpeed()
    if laggerCarryToggled then return LAGGER_CARRY_SPEED
    elseif laggerToggled then return LAGGER_SPEED
    elseif speedMode then return CS
    else return NS end
end

local function disconnectAllV1()
    for _, conn in ipairs(stateV1.ragdollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    stateV1.ragdollConnections = {}
end

local function cacheCharacterV1()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    stateV1.cachedChar = { character = char, humanoid = hum, root = root }
    return true
end

local function isRagdolledV1()
    if not stateV1.cachedChar or not stateV1.cachedChar.humanoid then return false end
    local hum = stateV1.cachedChar.humanoid
    if not hum.Parent then return false end
    local st = hum:GetState()
    local ragdollStates = {
        [Enum.HumanoidStateType.Physics] = true,
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    return ragdollStates[st] or false
end

local function forceExitRagdollV1()
    if not stateV1.cachedChar or not stateV1.cachedChar.humanoid or not stateV1.cachedChar.root then return end
    local hum = stateV1.cachedChar.humanoid
    local root = stateV1.cachedChar.root
    if not hum.Parent or not root.Parent then return end
    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    for _, descendant in ipairs(stateV1.cachedChar.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or
           (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            pcall(function() descendant:Destroy() end)
        end
    end
    local spd = getAntiRagdollRecoverySpeed()
    if not stateV1.isBoosting then
        stateV1.isBoosting = true
        stateV1._lastBoostTime = _tick()
    end
    pcall(function() hum.WalkSpeed = spd end)
    if hum.Health > 0 then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    pcall(function() root.Anchored = false end)
end

local function heartbeatLoopV1()
    while stateV1.active do
        task.wait(0.05)
        if isRagdolledV1() then
            forceExitRagdollV1()
        elseif stateV1.isBoosting then
            local elapsed = _tick() - (stateV1._lastBoostTime or 0)
            if elapsed > 0.35 or not isRagdolledV1() then
                stateV1.isBoosting = false
                if stateV1.cachedChar and stateV1.cachedChar.humanoid then
                    pcall(function()
                        stateV1.cachedChar.humanoid.WalkSpeed = getAntiRagdollRecoverySpeed()
                    end)
                end
            end
        end
    end
end

function AntiRagdollV1.start()
    if stateV1.active then return end
    AntiRagdollV1.stop()
    if not cacheCharacterV1() then
        warn("[AntiRagdollV1] No se pudo cachear el personaje")
        return
    end
    stateV1.active = true
    stateV1.isBoosting = false
    local camConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam and stateV1.cachedChar and stateV1.cachedChar.humanoid then
            cam.CameraSubject = stateV1.cachedChar.humanoid
        end
    end)
    table.insert(stateV1.ragdollConnections, camConn)
    local respawnConn = LP.CharacterAdded:Connect(function()
        stateV1.isBoosting = false
        task.wait(0.5)
        cacheCharacterV1()
    end)
    table.insert(stateV1.ragdollConnections, respawnConn)
    task.spawn(heartbeatLoopV1)
end

function AntiRagdollV1.stop()
    stateV1.active = false
    if stateV1.isBoosting and stateV1.cachedChar and stateV1.cachedChar.humanoid then
        pcall(function()
            stateV1.cachedChar.humanoid.WalkSpeed = getAntiRagdollRecoverySpeed()
        end)
    end
    stateV1.isBoosting = false
    disconnectAllV1()
    stateV1.cachedChar = nil
end

function AntiRagdollV1.isRunning() return stateV1.active end

local AntiRagdollV2 = {
    Enabled = false,
    Connection = nil,
    ResetCooldown = 0,
}

local function startAntiRagdollV2()
    if AntiRagdollV2.Connection then return end
    AntiRagdollV2.Enabled = true
    AntiRagdollV2.Connection = RunService.Heartbeat:Connect(function()
        if not AntiRagdollV2.Enabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return end
        local state = hum:GetState()
        local now = _tick()
        if state == Enum.HumanoidStateType.Physics or
           state == Enum.HumanoidStateType.Ragdoll or
           state == Enum.HumanoidStateType.FallingDown then
            if now - AntiRagdollV2.ResetCooldown > 0.15 then
                AntiRagdollV2.ResetCooldown = now
                pcall(function()
                    if hum:GetState() == Enum.HumanoidStateType.GettingUp then return end
                    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return end
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    root.Velocity = _V3zero
                    root.RotVelocity = _V3zero
                    root.AssemblyLinearVelocity = _V3zero
                    root.AssemblyAngularVelocity = _V3zero
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("Motor6D") then obj.Enabled = true end
                        if obj:IsA("Constraint") then obj.Enabled = true end
                    end
                    workspace.CurrentCamera.CameraSubject = hum
                    local PM = LP.PlayerScripts:FindFirstChild("PlayerModule")
                    if PM then
                        local CM = require(PM:FindFirstChild("ControlModule"))
                        if CM then CM:Enable() end
                    end
                    hum.AutoRotate = true
                    hum.PlatformStand = false
                    hum.Sit = false
                end)
            end
        end
    end)
end

local function stopAntiRagdollV2()
    AntiRagdollV2.Enabled = false
    if AntiRagdollV2.Connection then
        AntiRagdollV2.Connection:Disconnect()
        AntiRagdollV2.Connection = nil
    end
    AntiRagdollV2.ResetCooldown = 0
end

function setAntiRagdollMode(mode)
    if AntiRagdollV1.isRunning() then AntiRagdollV1.stop() end
    if AntiRagdollV2.Enabled then stopAntiRagdollV2() end
    antiRagdollMode = mode
    if mode == "v1" then AntiRagdollV1.start()
    elseif mode == "v2" then startAntiRagdollV2() end
    if _G.updateAntiRagdollUI then _G.updateAntiRagdollUI(mode) end
    saveAllSettings()
end

local AntiDieModule = {
    enabled      = false,
    heartConn    = nil,
    deathConns   = {},
    charConn     = nil,
    humanoid     = nil,
}

local function disconnectAntiDieAll()
    for _, c in ipairs(AntiDieModule.deathConns) do
        pcall(function() c:Disconnect() end)
    end
    AntiDieModule.deathConns = {}
    if AntiDieModule.heartConn then
        pcall(function() AntiDieModule.heartConn:Disconnect() end)
        AntiDieModule.heartConn = nil
    end
end

local function protectAntiDieChar(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    hum.MaxHealth = math.huge
    hum.Health    = math.huge
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum.BreakJointsOnDeath = false
    end)
    AntiDieModule.humanoid = hum

    table.insert(AntiDieModule.deathConns, hum.StateChanged:Connect(function(_, new)
        if not AntiDieModule.enabled then return end
        if new == Enum.HumanoidStateType.Dead then
            hum.Health = math.huge
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end)
        end
    end))

    table.insert(AntiDieModule.deathConns, hum:GetPropertyChangedSignal("Health"):Connect(function()
        if AntiDieModule.enabled and hum.Health < hum.MaxHealth then
            hum.Health = math.huge
        end
    end))

    if AntiDieModule.heartConn then
        pcall(function() AntiDieModule.heartConn:Disconnect() end)
    end
    AntiDieModule.heartConn = RunService.Heartbeat:Connect(function()
        if AntiDieModule.enabled and hum and hum.Parent and hum.Health < hum.MaxHealth then
            hum.Health = math.huge
        end
    end)
end

local function activateOnCharacter(char)
    if not AntiDieModule.enabled then return end
    protectAntiDieChar(char or LP.Character)
end

function AntiDieModule.start()
    AntiDieModule.enabled = true
    disconnectAntiDieAll()
    protectAntiDieChar(LP.Character)

    if AntiDieModule.charConn then
        pcall(function() AntiDieModule.charConn:Disconnect() end)
    end
    AntiDieModule.charConn = LP.CharacterAdded:Connect(function(char)
        if not AntiDieModule.enabled then return end
        task.wait(0.1)
        disconnectAntiDieAll()
        protectAntiDieChar(char)
    end)
end

function AntiDieModule.stop()
    AntiDieModule.enabled = false
    disconnectAntiDieAll()
    if AntiDieModule.charConn then
        pcall(function() AntiDieModule.charConn:Disconnect() end)
        AntiDieModule.charConn = nil
    end

    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum.MaxHealth = 100
            hum.Health    = 100
        end)
    end
    AntiDieModule.humanoid = nil
end

_G.AntiDie = AntiDieModule

local AntiFlingShieldModule = {
    enabled = false,
    loop = nil,
    velocityThreshold = 80,
}

local function stabilizeRoot(root)
    if not root or not root.Parent then return end
    if batDesyncTpEnabled then return end
    local velocity
    local ok = pcall(function() velocity = root.AssemblyLinearVelocity end)
    if not ok or typeof(velocity) ~= "Vector3" then
        local legacyOk
        legacyOk, velocity = pcall(function() return root.Velocity end)
        if not legacyOk or typeof(velocity) ~= "Vector3" then return end
    end
    if velocity.Magnitude <= AntiFlingShieldModule.velocityThreshold then return end
    local stabilized = _V3new(0, velocity.Y, 0)
    pcall(function() root.AssemblyLinearVelocity = stabilized end)
    pcall(function() root.AssemblyAngularVelocity = _V3zero end)
    pcall(function() root.Velocity = stabilized end)
    pcall(function() root.RotVelocity = _V3zero end)
end

function AntiFlingShieldModule.start()
    AntiFlingShieldModule.enabled = true
    if AntiFlingShieldModule.loop then AntiFlingShieldModule.loop:Disconnect() end
    AntiFlingShieldModule.loop = RunService.Heartbeat:Connect(function()
        if not AntiFlingShieldModule.enabled then return end
        local char = LP.Character
        stabilizeRoot(char and char:FindFirstChild("HumanoidRootPart"))
    end)
end

function AntiFlingShieldModule.stop()
    AntiFlingShieldModule.enabled = false
    if AntiFlingShieldModule.loop then
        AntiFlingShieldModule.loop:Disconnect()
        AntiFlingShieldModule.loop = nil
    end
end

_G.AntiFlingShield = AntiFlingShieldModule

do
    local _ragCountdownRunning = false
    local function _getRagBillboard()
        local char = LP.Character
        if not char then return nil, nil end
        local head = char:FindFirstChild("Head")
        if not head then return nil, nil end
        local pGui = LP.PlayerGui
        local existing = pGui:FindFirstChild("RagCountdownBillboard")
        if existing then existing:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "RagCountdownBillboard"
        bb.Size = UDim2.new(0, 84, 0, 42)
        bb.StudsOffset = _V3new(0, 7.0, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = pGui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextScaled = true
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        lbl.TextStrokeTransparency = 1
        lbl.Text = ""
        lbl.Parent = bb
        local grad = Instance.new("UIGradient", lbl)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 210)),
            ColorSequenceKeypoint.new(0.3, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.7, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210)),
        })
        grad.Rotation = 45
        grad.Offset = Vector2.new(0,0)
        return bb, lbl
    end

    local function _ragPunch(lbl, text)
        if not (lbl and lbl.Parent) then return end
        lbl.Text = text
    end

    local function _startRagCountdown()
        if _ragCountdownRunning then return end
        _ragCountdownRunning = true
        task.spawn(function()
            local bb, lbl = _getRagBillboard()
            if not bb then _ragCountdownRunning = false; return end
            local timeLeft = 2.5
            local step = 0.1
            while timeLeft > 0 and bb.Parent do
                _ragPunch(lbl, string.format("%.1f", timeLeft))
                task.wait(step)
                timeLeft = timeLeft - step
            end
            if bb and bb.Parent then
                _ragPunch(lbl, "READY!")
                task.wait(0.5)
                if bb and bb.Parent then bb:Destroy() end
            end
            _ragCountdownRunning = false
        end)
    end

    local _wasRagdolled = false
    RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then _wasRagdolled = false; return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then _wasRagdolled = false; return end
        local st = hum:GetState()
        local inRag = st == Enum.HumanoidStateType.Physics
                   or st == Enum.HumanoidStateType.Ragdoll
                   or st == Enum.HumanoidStateType.FallingDown
        if inRag and not _wasRagdolled then
            _wasRagdolled = true
            _startRagCountdown()
        elseif not inRag then
            _wasRagdolled = false
        end
    end)
end

local espHighlightCache = {}
local espBillboardCache = {}
local espTracerCache = {}
local espConn = nil
local _espLastRun = 0
profileImageCache = {}

local function clearESP()
    for plr in pairs(espHighlightCache) do
        pcall(function() espHighlightCache[plr]:Destroy() end)
    end
    for plr in pairs(espBillboardCache) do
        pcall(function() espBillboardCache[plr]:Destroy() end)
    end
    for plr in pairs(espTracerCache) do
        for _, ln in ipairs(espTracerCache[plr]) do
            pcall(function() ln.Visible = false; ln:Remove() end)
        end
    end
    espHighlightCache = {}
    espBillboardCache = {}
    espTracerCache = {}
end

local function makeESPTracers()
    if not (Drawing and type(Drawing.new) == "function") then return nil end
    local color = getThemeColor()
    local outer = Drawing.new("Line")
    outer.Color = color
    outer.Thickness = 2.2
    outer.Transparency = 0.90
    outer.Visible = false
    local mid = Drawing.new("Line")
    mid.Color = color
    mid.Thickness = 1.2
    mid.Transparency = 0.74
    mid.Visible = false
    local core = Drawing.new("Line")
    core.Color = color
    core.Thickness = 0.6
    core.Transparency = 0.10
    core.Visible = false
    return {outer, mid, core}
end

local function updateESP()
    local now = _tick()
    if now - _espLastRun < 0.05 then return end
    _espLastRun = now
    if not espEnabled then clearESP(); return end
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    local myScreenPos, myOnScreen = camera:WorldToViewportPoint(myPos)
    local myVec = Vector2.new(myScreenPos.X, myScreenPos.Y)
    local currentPlayers = _GetPlayersCached()
    local plrSet = {}
    for _, p in ipairs(currentPlayers) do plrSet[p] = true end
    for plr in pairs(espHighlightCache) do
        if not plrSet[plr] then
            pcall(function() espHighlightCache[plr]:Destroy() end)
            espHighlightCache[plr] = nil
        end
    end
    for plr in pairs(espBillboardCache) do
        if not plrSet[plr] then
            pcall(function() espBillboardCache[plr]:Destroy() end)
            espBillboardCache[plr] = nil
        end
    end
    for plr in pairs(espTracerCache) do
        if not plrSet[plr] then
            for _, ln in ipairs(espTracerCache[plr]) do
                pcall(function() ln.Visible = false; ln:Remove() end)
            end
            espTracerCache[plr] = nil
        end
    end
    local color = getThemeColor()
    for _, plr in ipairs(currentPlayers) do
        if plr == LP then continue end
        local char = plr.Character
        if not char then
            if espHighlightCache[plr] then
                pcall(function() espHighlightCache[plr]:Destroy() end)
                espHighlightCache[plr] = nil
            end
            if espBillboardCache[plr] then
                pcall(function() espBillboardCache[plr]:Destroy() end)
                espBillboardCache[plr] = nil
            end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do
                    pcall(function() ln.Visible = false end)
                end
            end
            continue
        end
        local tRoot = char:FindFirstChild("HumanoidRootPart")
        local tHead = char:FindFirstChild("Head")
        local tHum = char:FindFirstChildOfClass("Humanoid")
        local alive = tRoot and tHead and tHum and tHum.Health > 0
        if alive then
            local hl = espHighlightCache[plr]
            if not hl or not hl.Parent or hl.Parent ~= char then
                if hl then pcall(function() hl:Destroy() end) end
                hl = Instance.new("Highlight")
                hl.Name = "MeridianHubESP"
                hl.FillColor = color
                hl.FillTransparency = 0.72
                hl.OutlineColor = color
                hl.OutlineTransparency = 0.05
                hl.Adornee = char
                hl.Parent = char
                espHighlightCache[plr] = hl
            end
            local bb = espBillboardCache[plr]
            if not bb or not bb.Parent then
                if bb then pcall(function() bb:Destroy() end) end
                bb = Instance.new("BillboardGui")
                bb.Name = "ProfilePic"
                bb.Size = UDim2.new(0, 56, 0, 56)
                bb.StudsOffset = _V3new(0, 3.8, 0)
                bb.Adornee = tHead
                bb.AlwaysOnTop = true
                bb.Parent = tHead
                local img = Instance.new("ImageLabel", bb)
                img.Size = UDim2.new(1, -6, 1, -6)
                img.Position = UDim2.new(0, 3, 0, 3)
                img.BackgroundTransparency = 1
                img.Image = "rbxassetid://0"
                img.ScaleType = Enum.ScaleType.Fit
                local circle = Instance.new("UICorner", img)
                circle.CornerRadius = UDim.new(1, 0)
                local stroke = Instance.new("UIStroke", img)
                stroke.Color = color
                stroke.Thickness = 1.5
                espBillboardCache[plr] = bb
                task.spawn(function()
                    local userId = plr.UserId
                    local url = profileImageCache[userId]
                    if not url then
                        local success, u = pcall(function()
                            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                        end)
                        if success and u and u ~= "" then
                            url = u
                            profileImageCache[userId] = url
                        else
                            url = "rbxassetid://0"
                        end
                    end
                    if img then img.Image = url end
                end)
            else
                if bb.Adornee ~= tHead then bb.Adornee = tHead end
                bb.Enabled = true
            end
            local lines = espTracerCache[plr]
            if not lines then
                lines = makeESPTracers()
                espTracerCache[plr] = lines or {}
            end
            if lines and #lines > 0 then
                local destPos = tRoot.Position
                local pos, onScreen = camera:WorldToViewportPoint(destPos)
                if onScreen and pos.Z > 0 and myOnScreen then
                    local tVec = Vector2.new(pos.X, pos.Y)
                    for _, ln in ipairs(lines) do
                        ln.From = myVec
                        ln.To = tVec
                        ln.Visible = true
                    end
                else
                    for _, ln in ipairs(lines) do ln.Visible = false end
                end
            end
        else
            if espHighlightCache[plr] then
                pcall(function() espHighlightCache[plr]:Destroy() end)
                espHighlightCache[plr] = nil
            end
            if espBillboardCache[plr] then
                pcall(function() espBillboardCache[plr]:Destroy() end)
                espBillboardCache[plr] = nil
            end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do
                    pcall(function() ln.Visible = false end)
                end
            end
        end
    end
end

local function startESPLoop()
    if espConn then espConn:Disconnect() end
    espConn = RunService.RenderStepped:Connect(updateESP)
end

local function stopESPLoop()
    if espConn then espConn:Disconnect(); espConn = nil end
    clearESP()
end

function toggleESP(on)
    espEnabled = on
    if on then startESPLoop() else stopESPLoop() end
    if setESPVIsual then setESPVIsual(on) end
end

local _enemySpeedAcc = 0
function updateEnemySpeedLabels()
    _enemySpeedAcc = _enemySpeedAcc + 1
    if _enemySpeedAcc < 6 then return end
    _enemySpeedAcc = 0
    local color = getThemeColor()
    local players = _GetPlayersCached()
    for i = 1, #players do
        local player = players[i]
        if player ~= LP then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local v = hrp.AssemblyLinearVelocity
                local speed = _sqrt(v.X*v.X + v.Z*v.Z)
                local label = enemySpeedLabels[player]
                if not label then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 100, 0, 25)
                        bb.StudsOffset = _V3new(0, 5.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Name = "EnemySpeedGui"
                        bb.Parent = head
                        local tl = Instance.new("TextLabel", bb)
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.TextColor3 = color
                        tl.Font = Enum.Font.GothamBold
                        tl.TextScaled = true
                        tl.TextStrokeTransparency = 1
                        tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        enemySpeedLabels[player] = tl
                        label = tl
                    end
                elseif label.Parent and label.Parent.Parent ~= char then
                    local head = char:FindFirstChild("Head")
                    if head then label.Parent.Parent = head end
                end
                if label then
                    label.Text = string.format("%.1f", speed)
                    if label.TextColor3 ~= color then label.TextColor3 = color end
                end
            else
                local label = enemySpeedLabels[player]
                if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
                enemySpeedLabels[player] = nil
            end
        end
    end
end

function startEnemySpeed()
    if enemySpeedConn then enemySpeedConn:Disconnect() end
    enemySpeedConn = RunService.Heartbeat:Connect(updateEnemySpeedLabels)
end

function stopEnemySpeed()
    if enemySpeedConn then enemySpeedConn:Disconnect(); enemySpeedConn = nil end
end

local function getClosestTargetBody()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local rpos = root.Position
    local closest, minDist = nil, _huge
    local plist = _GetPlayersCached()
    for i = 1, #plist do
        local plr = plist[i]
        if plr ~= LP then
            local c = plr.Character
            if c then
                local tRoot = c:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dx = tRoot.Position.X - rpos.X
                        local dy = tRoot.Position.Y - rpos.Y
                        local dz = tRoot.Position.Z - rpos.Z
                        local d = dx*dx + dy*dy + dz*dz
                        if d < minDist then minDist = d; closest = tRoot end
                    end
                end
            end
        end
    end
    return closest
end

local function _bodyLockTick()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local target = getClosestTargetBody()
    if not target then
        if not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    local dist = (target.Position - root.Position).Magnitude
    if dist > bodyLockRange then
        if not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    if hum.AutoRotate then hum.AutoRotate = false end
    local targetVel = target.AssemblyLinearVelocity
    local speed3 = targetVel.Magnitude
    local predictTime = _clamp(speed3 / 80, 0.08, 0.35)
    local predictedPos = target.Position + targetVel * predictTime
    local targetHead = target.Parent and target.Parent:FindFirstChild("Head")
    local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y
    local myHeight = root.Position.Y + (hum.HipHeight or 0)
    local heightDiff = targetHeight - myHeight
    local verticalCorrection = _clamp(heightDiff * 0.15, -1.5, 1.5)
    local flatTarget = _V3new(predictedPos.X, root.Position.Y + verticalCorrection, predictedPos.Z)
    local toPredict = flatTarget - root.Position
    if toPredict.Magnitude > 0.1 then
        local goalCF = _CFlookAt(root.Position, flatTarget)
        local diffCF = root.CFrame:Inverse() * goalCF
        local _, ry, _ = diffCF:ToEulerAnglesXYZ()
        ry = _clamp(ry, -2.5, 2.5)
        root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(_V3new(0, ry * 42, 0))
    end
end

function startBodyLock()
    if _bodyLockConn then _bodyLockConn:Disconnect() end
    local acc = 0
    _bodyLockConn = RunService.Heartbeat:Connect(function(dt)
        if not bodyLockEnabled then return end
        if _blSuppressCount > 0 then return end
        acc = acc + dt
        if acc < 0.033 then return end
        acc = 0
        _bodyLockTick()
    end)
end

function stopBodyLock()
    if _bodyLockConn then
        _bodyLockConn:Disconnect()
        _bodyLockConn = nil
    end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyAngularVelocity = _V3zero
        root.AssemblyLinearVelocity = _V3new(root.AssemblyLinearVelocity.X, -0.1, root.AssemblyLinearVelocity.Z)
    end
    local hum2 = c and c:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate = true end
end

function _suppressBodyLock()
    _blSuppressCount = _blSuppressCount + 1
    if _blSuppressCount == 1 and bodyLockEnabled then
        _blWasEnabled = true
        stopBodyLock()
        if bodyLockSetVisual then bodyLockSetVisual(false) end
        if _blRestoreTimer then
            task.cancel(_blRestoreTimer)
            _blRestoreTimer = nil
        end
        _blSmoothRestore = false
    end
end

function _unsuppressBodyLock(delayed)
    if _blSuppressCount > 0 then
        _blSuppressCount = _blSuppressCount - 1
    end
    if _blSuppressCount == 0 and _blWasEnabled then
        _blWasEnabled = false
        if _blRestoreTimer then
            pcall(task.cancel, _blRestoreTimer)
            _blRestoreTimer = nil
        end
        local function restore()
            _blRestoreTimer = nil
            if bodyLockEnabled then
                _blSmoothRestore = true
                startBodyLock()
                if bodyLockSetVisual then bodyLockSetVisual(true) end
                task.delay(0.5, function() _blSmoothRestore = false end)
            end
        end
        if delayed then
            _blRestoreTimer = task.delay(1, restore)
        else
            restore()
        end
    end
end

function setupSpeedIndicator(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local oldBB = head:FindFirstChild("MeridianHubSpeedIndicator")
    if oldBB then oldBB:Destroy() end
    local oldDiscord = head:FindFirstChild("DiscordText")
    if oldDiscord then oldDiscord:Destroy() end

    local bb = Instance.new("BillboardGui", head)
    bb.Name = "MeridianHubSpeedIndicator"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.StudsOffset = _V3new(0, 2.5, 0)
    bb.MaxDistance = math.huge -- pixel-sized (offset only): same size at any camera zoom
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0

    local function flowGradient(parent, dur)
        local g = Instance.new("UIGradient", parent)
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(95, 95, 100)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(95, 95, 100)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(95, 95, 100)),
        })
        g.Offset = Vector2.new(-0.5, 0)
        TS:Create(g, TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false), {
            Offset = Vector2.new(0.5, 0),
        }):Play()
        return g
    end

    local title = Instance.new("TextLabel", bb)
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "MERIDIAN DUEL'S"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.TextStrokeTransparency = 0.1
    title.Font = Enum.Font.Bangers
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 10
    flowGradient(title, 3)

    local line = Instance.new("Frame", bb)
    line.Name = "TitleLine"
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 21)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.ZIndex = 10
    flowGradient(line, 3)

    speedLabel = Instance.new("TextLabel", bb)
    speedLabel.Name = "Speed"
    speedLabel.Size = UDim2.new(1, 0, 0, 16)
    speedLabel.Position = UDim2.new(0, 0, 0, 24)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "SPEED: 0"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    speedLabel.TextStrokeTransparency = 0.1
    speedLabel.Font = Enum.Font.Bangers
    speedLabel.TextSize = 14
    speedLabel.TextXAlignment = Enum.TextXAlignment.Center
    speedLabel.ZIndex = 10
    flowGradient(speedLabel, 3)
end

local unwalkSavedAnimate = nil

function startUnwalk()
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() t:Stop() end) end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        unwalkSavedAnimate = anim:Clone()
        anim:Destroy()
    end
end

function stopUnwalk()
    local c = LP.Character
    if c then
        local existing = c:FindFirstChild("Animate")
        if not existing then
            local src = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterCharacterScripts")
            local starterAnim = src and src:FindFirstChild("Animate")
            if starterAnim then
                starterAnim:Clone().Parent = c
            elseif unwalkSavedAnimate then
                unwalkSavedAnimate:Clone().Parent = c
            end
        end
    end
    unwalkSavedAnimate = nil
end

function refreshSpeedModeLabel()
    if modeValLbl then
        if laggerCarryToggled then modeValLbl.Text = "Lagger Carry"
        elseif laggerToggled then modeValLbl.Text = "Lagger"
        elseif speedMode then modeValLbl.Text = "Carry"
        else modeValLbl.Text = "Normal" end
    end
    if laggerCarryToggled then _G.AceCurrentSpeedMode = "Lagger Carry"
    elseif laggerToggled then _G.AceCurrentSpeedMode = "Lagger"
    elseif speedMode then _G.AceCurrentSpeedMode = "Carry"
    else _G.AceCurrentSpeedMode = "Normal" end

    if setCarryModeVisual then setCarryModeVisual(speedMode) end
    if setLaggerModeVisual then setLaggerModeVisual(laggerToggled) end
    if setLaggerCarryVisual then setLaggerCarryVisual(laggerCarryToggled) end

end

function resetMovementState()
    if AutoCarry and AutoCarry.active and not AutoCarry.applying then
        AutoCarry.onManualChange()
    end
    refreshSpeedModeLabel()
    if mobSetCarry then mobSetCarry(speedMode) end
    if setLaggerModeVisual then setLaggerModeVisual(laggerToggled) end
    if setLaggerCarryVisual then setLaggerCarryVisual(laggerCarryToggled) end
end

function toggleCarryMode()
    if laggerToggled or laggerCarryToggled then
        laggerToggled = false; laggerCarryToggled = false; speedMode = true
    else speedMode = not speedMode end
    resetMovementState()
end

function toggleLaggerMode()
    if laggerCarryToggled then laggerCarryToggled = false end
    speedMode = false; laggerToggled = not laggerToggled
    resetMovementState()
end

function toggleLaggerCycle()
    if speedMode then
        speedMode = false
        laggerToggled = true
        laggerCarryToggled = false
    elseif laggerToggled then
        speedMode = false
        laggerToggled = false
        laggerCarryToggled = true
    else
        speedMode = true
        laggerToggled = false
        laggerCarryToggled = false
    end
    resetMovementState()
end

AutoCarry = {
    enabled = false,
    mode = "WHEN NEAR",
    active = false,
    prev = nil,
    applying = false,
    conn = nil,
    charConn = nil,
    nextScan = 0,
    setVisual = nil,
    modeLabel = nil,
}

local function _acSnapshot()
    return { speedMode, laggerToggled, laggerCarryToggled }
end

local function _acCarryize()
    if laggerToggled or laggerCarryToggled then
        laggerToggled = false; laggerCarryToggled = true; speedMode = false
    else
        speedMode = true
    end
end

function AutoCarry._nearDist()
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
    local plots = getPlotsRoot()
    if not root or not plots then return nil end
    local rpos = root.Position
    local best = _huge
    for _, plot in ipairs(plots:GetChildren()) do
        if not isMyPlotByName(plot.Name) then
            local pods = plot:FindFirstChild("AnimalPodiums")
            if pods then
                for _, pod in ipairs(pods:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local spawn = base and base:FindFirstChild("Spawn")
                    if spawn then
                        local d = (spawn.Position - rpos).Magnitude
                        if d < best then
                            local att = spawn:FindFirstChild("PromptAttachment")
                            if att then
                                for _, pr in ipairs(att:GetChildren()) do
                                    if pr:IsA("ProximityPrompt") and tostring(pr.ActionText):find("Steal") then
                                        best = d
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if best == _huge then return nil end
    return best
end

function AutoCarry._activate()
    if AutoCarry.active then
        if not (speedMode or laggerCarryToggled) then
            AutoCarry.applying = true
            _acCarryize()
            resetMovementState()
            AutoCarry.applying = false
        end
        return
    end
    AutoCarry.prev = _acSnapshot()
    AutoCarry.active = true
    AutoCarry.applying = true
    _acCarryize()
    resetMovementState()
    AutoCarry.applying = false
end

function AutoCarry._deactivate()
    if not AutoCarry.active then return end
    local prev = AutoCarry.prev
    AutoCarry.active = false
    AutoCarry.prev = nil
    if prev then
        AutoCarry.applying = true
        speedMode, laggerToggled, laggerCarryToggled = prev[1], prev[2], prev[3]
        resetMovementState()
        AutoCarry.applying = false
    end
end

function AutoCarry.onManualChange()
    AutoCarry.prev = _acSnapshot()
    _acCarryize()
end

function AutoCarry._evaluate()
    if autoLeftEnabled or autoRightEnabled then
        AutoCarry._deactivate()
        return
    end
    local want = LP:GetAttribute("Stealing") == true
    if not want and AutoCarry.mode == "WHEN NEAR" then
        local d = AutoCarry._nearDist()
        want = d ~= nil and d <= 10
    end
    if want then AutoCarry._activate() else AutoCarry._deactivate() end
end

function AutoCarry.start()
    if AutoCarry.conn then AutoCarry.conn:Disconnect(); AutoCarry.conn = nil end
    if AutoCarry.charConn then AutoCarry.charConn:Disconnect(); AutoCarry.charConn = nil end
    AutoCarry.charConn = LP.CharacterAdded:Connect(function()
        AutoCarry._deactivate()
    end)
    if AutoCarry.mode == "WHEN NEAR" then
        AutoCarry.conn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if now < AutoCarry.nextScan then return end
            AutoCarry.nextScan = now + 0.08
            AutoCarry._evaluate()
        end)
    else
        AutoCarry.conn = LP:GetAttributeChangedSignal("Stealing"):Connect(AutoCarry._evaluate)
    end
    AutoCarry._evaluate()
end

function AutoCarry.stop()
    if AutoCarry.conn then AutoCarry.conn:Disconnect(); AutoCarry.conn = nil end
    if AutoCarry.charConn then AutoCarry.charConn:Disconnect(); AutoCarry.charConn = nil end
    AutoCarry._deactivate()
end

function AutoCarry.setEnabled(on)
    AutoCarry.enabled = on and true or false
    if AutoCarry.enabled then AutoCarry.start() else AutoCarry.stop() end
end

function AutoCarry.syncUI()
    if AutoCarry.setVisual then AutoCarry.setVisual(AutoCarry.enabled) end
    if AutoCarry.modeLabel then AutoCarry.modeLabel.Text = AutoCarry.mode end
end

function stopAutoLeft()
    if _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoLeft") then _G.MeridianSM.cancel("autoLeft") end
    if alConn then alConn:Disconnect(); alConn = nil end
    alPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(_V3zero, false) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobSetAutoLeft then mobSetAutoLeft(false) end
    _unsuppressBodyLock(true)
end

-- One-at-a-time rule: Auto Left / Auto Right / Aimbot (Normal + Bypass) / TP BAT.
-- Starting one turns the other three off (and drops anything they have queued in Safe Mode).
function MeridianExclusive(keep)
    local SM = _G.MeridianSM
    local isQ = _G.MeridianSafeModeIsQueued
    if keep ~= "autoLeft" then
        if isQ and SM and isQ("autoLeft") then SM.cancel("autoLeft") end
        if autoLeftEnabled then
            autoLeftEnabled = false
            stopAutoLeft()
        end
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
    end
    if keep ~= "autoRight" then
        if isQ and SM and isQ("autoRight") then SM.cancel("autoRight") end
        if autoRightEnabled then
            autoRightEnabled = false
            stopAutoRight()
        end
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
    end
    if keep ~= "aimbot" then
        if isQ and SM and isQ("autoBat") then SM.cancel("autoBat") end
        if isQ and SM and isQ("batV2") then SM.cancel("batV2") end
        if autoBatEnabled or autoBatV2Enabled then disableAutoBat() end
        if autoBatSetVisual then autoBatSetVisual(false) end
        if mobSetAutoBat then mobSetAutoBat(false) end
    end
    if keep ~= "tpBat" then
        if isQ and SM and isQ("tpBat") then SM.cancel("tpBat") end
        if batDesyncTpEnabled then stopBatDesyncTp() end
        if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
    end
end

function startAutoLeft()
    if not _G.MeridianSafeModeTryStart("autoLeft") then
        local q = _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoLeft") or false
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(q) end
        if mobSetAutoLeft then mobSetAutoLeft(q) end
        return
    end
    MeridianExclusive("autoLeft")
    _suppressBodyLock()
    if alConn then alConn:Disconnect() end
    alPhase = 1
    alConn = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if alPhase == 1 then
            local tgt = _V3new(AP.L1.X, root.Position.Y, AP.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP.L2 - root.Position
                local mv = _V3new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.L1 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = _V3new(AP.L2.X, root.Position.Y, AP.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(_V3zero, false)
                root.AssemblyLinearVelocity = _V3zero
                autoLeftEnabled = false
                if alConn then alConn:Disconnect(); alConn = nil end
                alPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if mobSetAutoLeft then mobSetAutoLeft(false) end
                _unsuppressBodyLock(true)
                local facePos = _V3new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = _CFnew(root.Position, facePos)
                end
                return
            end
            local d = AP.L2 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

function stopAutoRight()
    if _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoRight") then _G.MeridianSM.cancel("autoRight") end
    if arConn then arConn:Disconnect(); arConn = nil end
    arPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(_V3zero, false) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobSetAutoRight then mobSetAutoRight(false) end
    _unsuppressBodyLock(true)
end

function startAutoRight()
    if not _G.MeridianSafeModeTryStart("autoRight") then
        local q = _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoRight") or false
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(q) end
        if mobSetAutoRight then mobSetAutoRight(q) end
        return
    end
    MeridianExclusive("autoRight")
    _suppressBodyLock()
    if arConn then arConn:Disconnect() end
    arPhase = 1
    arConn = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if arPhase == 1 then
            local tgt = _V3new(AP.R1.X, root.Position.Y, AP.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP.R2 - root.Position
                local mv = _V3new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.R1 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = _V3new(AP.R2.X, root.Position.Y, AP.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(_V3zero, false)
                root.AssemblyLinearVelocity = _V3zero
                autoRightEnabled = false
                if arConn then arConn:Disconnect(); arConn = nil end
                arPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if mobSetAutoRight then mobSetAutoRight(false) end
                _unsuppressBodyLock(true)
                local facePos = _V3new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = _CFnew(root.Position, facePos)
                end
                return
            end
            local d = AP.R2 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

function getClosestTarget()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local rpos = root.Position
    local closest, minDist = nil, _huge
    local plist = _GetPlayersCached()
    for i = 1, #plist do
        local plr = plist[i]
        if plr ~= LP then
            local c = plr.Character
            if c then
                local tRoot = c:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dx = tRoot.Position.X - rpos.X
                        local dy = tRoot.Position.Y - rpos.Y
                        local dz = tRoot.Position.Z - rpos.Z
                        local d = dx*dx + dy*dy + dz*dz
                        if d < minDist then minDist = d; closest = tRoot end
                    end
                end
            end
        end
    end
    return closest
end

function trySwing()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool and not isBatTool(currentTool) then return end
        local bat = findBat()
        if bat then
            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            pcall(function() bat:Activate() end)
        end
    end)
end

function stopAimbotAdapt()
    if _aimbotConn then
        pcall(function() _aimbotConn:Disconnect() end)
        _aimbotConn = nil
    end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    if root then
        root.AssemblyLinearVelocity = _V3new(0, -0.1, 0)
        root.AssemblyAngularVelocity = _V3zero
    end
    _prevAutoRotate = nil
    lastMoveDir = _V3zero
    _unsuppressBodyLock(true)
end

function startAimbotAdapt()
    if _aimbotConn then return end
    _suppressBodyLock()
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
        hum0.AutoRotate = false
    end
    _aimbotConn = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target = getClosestTarget()
        if not target then return end
        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = _V3new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = _V3new(0,0,0) end
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = _clamp(yVel, -70, 110)
        local desiredVel = _V3new(flatDir.X * BAT_AIMBOT_SPEED, yVel, flatDir.Z * BAT_AIMBOT_SPEED)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        local speed3 = targetVel.Magnitude
        local predictTime = _clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = _CFlookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = _clamp(rx, -2.5, 2.5)
            ry = _clamp(ry, -2.5, 2.5)
            rz = _clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(_V3new(rx * 42, ry * 42, rz * 42))
        end
        local distToTarget = (root.Position - target.Position).Magnitude
        if distToTarget <= 8 then trySwing() end
    end)
end

function disableAutoBatNormal()
    if _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoBat") then _G.MeridianSM.cancel("autoBat") end
    autoBatEnabled = false
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobSetAutoBat then mobSetAutoBat(false) end
    stopAimbotAdapt()
end

function enableAutoBatNormal()
    if not _G.MeridianSafeModeTryStart("autoBat") then
        local q = _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoBat") or false
        autoBatEnabled = false
        if autoBatSetVisual then autoBatSetVisual(q) end
        if mobSetAutoBat then mobSetAutoBat(q) end
        return
    end
    MeridianExclusive("aimbot")
    if autoBatV2Enabled then disableBatV2() end
    autoBatEnabled = true
    if autoBatSetVisual then autoBatSetVisual(true) end
    if mobSetAutoBat then mobSetAutoBat(true) end
    startAimbotAdapt()
end

-- Auto Bat follows the Aim Mode switcher: Normal = the classic aimbot, Bypass = the ping-prediction chase (enableBatV2)
function aimModeName()
    return selectedAimbotMode == "Bat Bypass" and "Bypass" or "Normal"
end

function disableAutoBat()
    if _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("batV2") then _G.MeridianSM.cancel("batV2") end
    if autoBatV2Enabled then disableBatV2() end
    disableAutoBatNormal()
end

function enableAutoBat()
    if selectedAimbotMode == "Bat Bypass" then
        if autoBatEnabled then disableAutoBatNormal() end
        enableBatV2()
        local on = autoBatV2Enabled == true
        local q = (not on) and _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("batV2") or false
        if autoBatSetVisual then autoBatSetVisual(on or q) end
        if mobSetAutoBat then mobSetAutoBat(on or q) end
    else
        enableAutoBatNormal()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- BAT BYPASS — Persecución autónoma con predicción de ping
-- (Reemplaza el módulo Anti Bypass anterior. Antes BAT V2.)
-- ═══════════════════════════════════════════════════════════════

BAT_V2_SPEED           = BAT_V2_SPEED           or 55
BAT_V2_HIT_DIST        = BAT_V2_HIT_DIST        or 13
BAT_V2_LEAD_STUDS      = BAT_V2_LEAD_STUDS      or 3
BAT_V2_BODY_LOCK_RANGE = BAT_V2_BODY_LOCK_RANGE or 60

local SnowVS = _G.SnowVS or {}
_G.SnowVS = SnowVS

SnowVS.BatBypass = SnowVS.BatBypass or {}
-- Alias legado para no romper referencias externas existentes
SnowVS.AimbotBypassV2 = SnowVS.BatBypass

local BB = SnowVS.BatBypass

BB.Enabled    = BB.Enabled    or false
BB.Connection = BB.Connection or nil

BB.Z = BB.Z or {
    targetPlayer          = nil,
    lastTargetPos         = nil,
    targetVelocity        = Vector3.zero,
    smoothedVelocity      = Vector3.zero,
    velocityHistory       = {},
    accelerationHistory   = {},
    aerialVelocityHistory = {},
    previousDirection     = nil,
    lastDirectionChangeTime = 0,
    airborneTime          = 0,
    lastActivationTime    = 0,
    currentPing           = 0.1,
    realPingMs            = 0,
}

BB.ZCFG = BB.ZCFG or {
    FOLLOW_SPEED                    = BAT_V2_SPEED,
    ACTIVATE_DISTANCE               = BAT_V2_HIT_DIST,
    MIN_FOLLOW_DISTANCE             = 1,
    PREDICTION_TIME                 = 0.22,
    PREDICT_AHEAD                   = BAT_V2_LEAD_STUDS,
    MAX_VELOCITY_CHANGE             = 150,
    VELOCITY_SMOOTHING              = 0.2,
    MAX_HORIZONTAL_VELOCITY         = 80,
    SERVER_TICKRATE                 = 1 / 60,
    MIN_PING_COMPENSATION           = 0.03,
    MAX_PING_COMPENSATION           = 0.25,
    ACCELERATION_PREDICTION_WEIGHT  = 0.3,
    DIRECTION_CHANGE_DETECTION_TIME = 0.12,
    QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
    GRAVITY                         = 196.2,
    AIR_CONTROL_FACTOR              = 0.8,
    MIN_AIRBORNE_TIME               = 0.08,
}

local function bbAverageVector(history)
    if #history == 0 then return Vector3.zero end
    local total = Vector3.zero
    for _, v in ipairs(history) do total += v end
    return total / #history
end

local function bbPushHistory(history, value, maximum)
    table.insert(history, value)
    if #history > maximum then table.remove(history, 1) end
end

function BB.FindBat()
    local char = LP.Character
    if not char then return nil end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then
        local n = equipped.Name:lower()
        if n:find("bat", 1, true) or n:find("slap", 1, true) then
            return equipped
        end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("bat", 1, true) or n:find("slap", 1, true) then
                    return tool
                end
            end
        end
    end
    return nil
end

local function bbResetTarget()
    local Z = BB.Z
    Z.targetPlayer          = nil
    Z.lastTargetPos         = nil
    Z.targetVelocity        = Vector3.zero
    Z.smoothedVelocity      = Vector3.zero
    Z.velocityHistory       = {}
    Z.accelerationHistory   = {}
    Z.aerialVelocityHistory = {}
    Z.previousDirection     = nil
    Z.airborneTime          = 0
end

local function bbNearestTarget(root)
    local nearest, nearestDistance = nil, math.huge
    for _, candidate in ipairs(Players:GetPlayers()) do
        if candidate ~= LP and candidate.Character then
            local targetRoot     = candidate.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = candidate.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (root.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearest, nearestDistance = candidate, distance
                end
            end
        end
    end
    return nearest
end

local function bbRotateRoot(root, direction)
    if direction.Magnitude < 0.01 then return end
    local axis  = root.CFrame.LookVector:Cross(direction.Unit)
    local angle = math.asin(math.clamp(axis.Magnitude, -1, 1))
    root.AssemblyAngularVelocity = axis.Magnitude > 0.01
        and axis.Unit * angle * 80
        or  Vector3.zero
end

local function bbSamplePing()
    local ok, value = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    local Z = BB.Z
    if ok and type(value) == "number" then Z.realPingMs = math.floor(value) end
    Z.currentPing = math.clamp(
        Z.realPingMs / 1000,
        BB.ZCFG.MIN_PING_COMPENSATION,
        BB.ZCFG.MAX_PING_COMPENSATION
    )
end

BB.PingLoopStarted = BB.PingLoopStarted or false
if not BB.PingLoopStarted then
    BB.PingLoopStarted = true
    task.spawn(function()
        while true do
            pcall(bbSamplePing)
            task.wait(0.5)
        end
    end)
end

-- Stubs para compatibilidad con la API antigua (Body Lock ya no se usa aparte)
function BB.StartBodyLock() end
function BB.StopBodyLock()  end

function BB.Stop()
    local Z = BB.Z
    BB.Enabled = false
    if BB.Connection then
        BB.Connection:Disconnect()
        BB.Connection = nil
    end
    local char     = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root     = char and char:FindFirstChild("HumanoidRootPart")
    if humanoid then humanoid.AutoRotate = true end
    if root     then root.AssemblyAngularVelocity = Vector3.zero end
    bbResetTarget()
    Z.lastActivationTime = 0
end

function BB.Start()
    if BB.Connection then return end

    local char     = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root     = char and char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    BB.Enabled = true
    humanoid.AutoRotate = false

    local bat = BB.FindBat()
    if bat and bat.Parent ~= char then
        pcall(function() humanoid:EquipTool(bat) end)
    end

    BB.Connection = RunService.RenderStepped:Connect(function(dt)
        if not BB.Enabled then BB.Stop(); return end
        local Z     = BB.Z
        local ZCFG  = BB.ZCFG

        -- Refresca velocidad según modo actual (Normal/Lagger/Lagger Carry)
        if _G.AceGetAntiBypassAimbotSpeed then
            ZCFG.FOLLOW_SPEED = _G.AceGetAntiBypassAimbotSpeed()
        end

        local currentChar     = LP.Character
        local currentRoot     = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local currentHumanoid = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        if not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then return end

        currentHumanoid.AutoRotate = false
        root, humanoid = currentRoot, currentHumanoid

        bat = currentChar:FindFirstChildOfClass("Tool") or BB.FindBat()
        if bat and bat.Parent ~= currentChar then
            pcall(currentHumanoid.EquipTool, currentHumanoid, bat)
        end

        Z.targetPlayer  = bbNearestTarget(root)
        local targetChar = Z.targetPlayer and Z.targetPlayer.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
            bbResetTarget(); return
        end

        local targetPos = targetRoot.Position
        local safeDt    = math.max(dt, 1 / 240)

        -- Estima velocidad del rival filtrando outliers
        if Z.lastTargetPos then
            local rawVelocity   = (targetPos - Z.lastTargetPos) / safeDt
            local velocityDelta = rawVelocity - Z.targetVelocity
            if velocityDelta.Magnitude > ZCFG.MAX_VELOCITY_CHANGE then
                rawVelocity = Z.targetVelocity + velocityDelta.Unit * ZCFG.MAX_VELOCITY_CHANGE
            end
            local horizontal = Vector3.new(rawVelocity.X, 0, rawVelocity.Z)
            if horizontal.Magnitude > ZCFG.MAX_HORIZONTAL_VELOCITY then
                horizontal  = horizontal.Unit * ZCFG.MAX_HORIZONTAL_VELOCITY
                rawVelocity = Vector3.new(horizontal.X, rawVelocity.Y, horizontal.Z)
            end
            bbPushHistory(Z.accelerationHistory, (rawVelocity - Z.targetVelocity) / safeDt, 4)
            bbPushHistory(Z.velocityHistory,     rawVelocity, 8)
            Z.targetVelocity   = rawVelocity
            Z.smoothedVelocity = Z.smoothedVelocity:Lerp(rawVelocity, ZCFG.VELOCITY_SMOOTHING)
        end
        Z.lastTargetPos = targetPos

        -- Estado aéreo
        local airborne = targetHumanoid.FloorMaterial == Enum.Material.Air
        Z.airborneTime = airborne and (Z.airborneTime + safeDt) or 0
        if airborne and Z.airborneTime >= ZCFG.MIN_AIRBORNE_TIME then
            bbPushHistory(Z.aerialVelocityHistory, Z.targetVelocity, 6)
        elseif not airborne then
            Z.aerialVelocityHistory = {}
        end

        local predictionVelocity = Z.smoothedVelocity
        if airborne and #Z.aerialVelocityHistory > 0 then
            local aerial = bbAverageVector(Z.aerialVelocityHistory)
            predictionVelocity = Vector3.new(aerial.X, Z.targetVelocity.Y, aerial.Z) * ZCFG.AIR_CONTROL_FACTOR
        end

        -- Detecta cambios bruscos de dirección
        local quickTurn = false
        local horizontalVelocity = Vector3.new(Z.targetVelocity.X, 0, Z.targetVelocity.Z)
        if horizontalVelocity.Magnitude > 5 then
            local direction = horizontalVelocity.Unit
            if Z.previousDirection and Z.previousDirection:Dot(direction) < 0.5 then
                quickTurn = tick() - Z.lastDirectionChangeTime < ZCFG.DIRECTION_CHANGE_DETECTION_TIME
                Z.lastDirectionChangeTime = tick()
            end
            Z.previousDirection = direction
        end

        local serverDelay = Z.currentPing + ZCFG.SERVER_TICKRATE
        if quickTurn then serverDelay *= ZCFG.QUICK_DIRECTION_CHANGE_MULTIPLIER end

        local predicted    = targetPos + predictionVelocity * serverDelay
        local acceleration = bbAverageVector(Z.accelerationHistory)
        predicted += acceleration * ZCFG.ACCELERATION_PREDICTION_WEIGHT * (serverDelay * serverDelay * 0.5)

        local predictionTime = ZCFG.PREDICTION_TIME * 1.1
        if airborne then
            predicted += predictionVelocity * predictionTime
            predicted += Vector3.new(0, -0.5 * ZCFG.GRAVITY * predictionTime * predictionTime, 0)
        else
            predicted += predictionVelocity * predictionTime
        end

        local flatPrediction = Vector3.new(predictionVelocity.X, 0, predictionVelocity.Z)
        if flatPrediction.Magnitude > 1 then
            predicted += flatPrediction.Unit * ZCFG.PREDICT_AHEAD
        end

        local toTarget = predicted - root.Position
        bbRotateRoot(root, toTarget)

        if (targetPos - root.Position).Magnitude <= ZCFG.ACTIVATE_DISTANCE
        and tick() - Z.lastActivationTime >= 0.3 then
            if bat then pcall(bat.Activate, bat) end
            Z.lastActivationTime = tick()
        end

        if toTarget.Magnitude > ZCFG.MIN_FOLLOW_DISTANCE then
            root.AssemblyLinearVelocity = toTarget.Unit * ZCFG.FOLLOW_SPEED
        else
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y * 0.5, 0)
        end
    end)
end

function BB.Toggle()
    if BB.Enabled then BB.Stop() else BB.Start() end
end

-- ═══════════════════════════════════════════════════════════════
-- Compat wrappers (API externa usada por UI / config / visuales)
-- ═══════════════════════════════════════════════════════════════

local function _aceSafeSave()
    if type(saveAllSettings) == "function" then pcall(saveAllSettings) end
end

local function _aceCurrentSpeedMode()
    if laggerCarryToggled then return "Lagger Carry" end
    if laggerToggled      then return "Lagger" end
    if speedMode          then return "Carry"  end
    return "Normal"
end

_G.AceGetAntiBypassAimbotSpeed = function()
    local mode = _aceCurrentSpeedMode()
    if mode == "Lagger" or mode == "Lagger Carry" then
        return tonumber(_G.AceAntiBypassLaggerAimbotSpeed) or 40
    end
    return tonumber(_G.AceAntiBypassAimbotSpeed) or 60
end

_G.AceRefreshAimbotVisual = function()
    if _G.AceAimbotSetVisual then
        _G.AceAimbotSetVisual(_G.AceAntiBypassAimbotOn == true)
    end
end

_G.AceStartAntiBypassAimbot = function()
    if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart("batV2") then
        return false
    end
    if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end
    if _G.AceStopNormalAimbot    then _G.AceStopNormalAimbot()    end

    selectedAimbotMode = "Bat Bypass"
    _G.AceAntiBypassAimbotOn = true
    SnowVS.BatBypass.ZCFG.FOLLOW_SPEED = _G.AceGetAntiBypassAimbotSpeed()
    SnowVS.BatBypass.Start()

    if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
    _aceSafeSave()
    return true
end

_G.AceStopAntiBypassAimbot = function(keepVisual)
    SnowVS.BatBypass.Stop()
    _G.AceAntiBypassAimbotOn = false
    if keepVisual ~= false and _G.AceRefreshAimbotVisual then
        _G.AceRefreshAimbotVisual()
    end
    _aceSafeSave()
end

_G.AceToggleSelectedAimbot = function()
    if selectedAimbotMode == "Bat Bypass" then
        if _G.AceAntiBypassAimbotOn then
            _G.AceStopAntiBypassAimbot()
        else
            _G.AceStartAntiBypassAimbot()
        end
    end
    if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
    _aceSafeSave()
end

_G.AceAntiBypassStart = _G.AceStartAntiBypassAimbot
_G.AceAntiBypassStop  = _G.AceStopAntiBypassAimbot

function enableBatV2()
    selectedAimbotMode = "Bat Bypass"
    MeridianExclusive("aimbot")
    local ok = _G.AceStartAntiBypassAimbot()
    if ok ~= false then
        autoBatV2Enabled = true
        if autoBatV2SetVisual then autoBatV2SetVisual(true) end
    else
        autoBatV2Enabled = false
        if autoBatV2SetVisual then autoBatV2SetVisual(false) end
    end
end

function disableBatV2()
    _G.AceStopAntiBypassAimbot()
    autoBatV2Enabled = false
    if autoBatV2SetVisual then autoBatV2SetVisual(false) end
end

_G.AceAntiBypassSaveToConfig = function(t)
    t = t or {}
    t.selectedAimbotMode              = selectedAimbotMode
    t.ANTI_BYPASS_AIMBOT_SPEED        = _G.AceAntiBypassAimbotSpeed
    t.ANTI_BYPASS_LAGGER_AIMBOT_SPEED = _G.AceAntiBypassLaggerAimbotSpeed
    t.antiBypassAimbotEnabled         = _G.AceAntiBypassAimbotOn == true
    return t
end

_G.AceAntiBypassLoadFromConfig = function(data)
    if type(data) ~= "table" then return end
    selectedAimbotMode = data.selectedAimbotMode or selectedAimbotMode
    -- Migración de configs antiguas "Anti Bypass" → "Bat Bypass"
    if selectedAimbotMode == "Anti Bypass" then
        selectedAimbotMode = "Bat Bypass"
    end
    if selectedAimbotMode ~= "Bat Bypass" then
        selectedAimbotMode = "Normal"
    end
    _G.AceAntiBypassAimbotSpeed =
        tonumber(data.ANTI_BYPASS_AIMBOT_SPEED) or _G.AceAntiBypassAimbotSpeed or 60

    if data.ANTI_BYPASS_LAGGER_AIMBOT_SPEED == nil
       or tonumber(data.ANTI_BYPASS_LAGGER_AIMBOT_SPEED) == 58 then
        _G.AceAntiBypassLaggerAimbotSpeed = 40
    else
        _G.AceAntiBypassLaggerAimbotSpeed =
            tonumber(data.ANTI_BYPASS_LAGGER_AIMBOT_SPEED) or 40
    end

    _G.AceAntiBypassAimbotOn = data.antiBypassAimbotEnabled == true
end

-- ═══════════════════════════════════════════════════════════════
-- TP BAT — Network Owner Teleport + Anti-Die + Lagger
-- Keybind: KB.TPBat (default X)  |  Botón: createTpBatFloatingButton
-- ═══════════════════════════════════════════════════════════════
batDesyncTpEnabled = false
batDesyncTpConn    = nil
batDesyncTpSetVisual = nil
local _tpBatUnwalkForced = false

-- Compat externa (UI, safe mode, teclas, carga de config, etc.)
_G.AlvaroTP = _G.AlvaroTP or {
    conn           = nil,
    on             = false,
    h              = nil,
    hrp            = nil,
    hittingCooldown= false,
    _charConn      = nil,
}

local _tpBatHitCooldown = false
local _tpBatMaxRange    = 100

-- ──────────────────────────────────────────────────────────────
-- ANTI-DIE + LAGGER (integrados al TP BAT)
-- ──────────────────────────────────────────────────────────────
local _tpBatAntiDieThread = nil
local function tpBatStartAntiDie()
    if _tpBatAntiDieThread then return end
    _tpBatAntiDieThread = task.spawn(function()
        while batDesyncTpEnabled do
            pcall(function()
                local char = LP.Character
                if not char then task.wait(0.1) return end
                local hum  = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum then
                    if hum.Health <= 0 then
                        hum.Health = hum.MaxHealth
                    end
                    if hum.PlatformStand then hum.PlatformStand = false end
                    if hum.Sit then hum.Sit = false end
                    local st = hum:GetState()
                    if st == Enum.HumanoidStateType.Physics
                       or st == Enum.HumanoidStateType.Ragdoll
                       or st == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
                if root and sethiddenproperty and tpBatVersion ~= 2 then
                    pcall(sethiddenproperty, root, "PhysicsRepRootPart", nil)
                end
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
            task.wait(0.05)
        end
        _tpBatAntiDieThread = nil
    end)
end

local function tpBatStopAntiDie()
    if _tpBatAntiDieThread then
        pcall(task.cancel, _tpBatAntiDieThread)
        _tpBatAntiDieThread = nil
    end
end

-- ══════════════════════════════════════════════════════
-- BAT
-- ══════════════════════════════════════════════════════
local function tpBatGetBat()
    local character = LP.Character
    if not character then return nil end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("bat") or name:find("slap") then return tool end
        end
    end
    local backpack = LP:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("bat") or name:find("slap") then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then pcall(function() humanoid:EquipTool(tool) end) end
                return tool
            end
        end
    end
    return nil
end

local function tpBatHit()
    if _tpBatHitCooldown then return end
    _tpBatHitCooldown = true
    local v2 = (tpBatVersion == 2)
    pcall(function()
        local bat = tpBatGetBat()
        if not bat then return end
        bat:Activate()
        if v2 then
            for _, d in ipairs(bat:GetDescendants()) do
                if d:IsA("RemoteEvent") then pcall(function() d:FireServer() end) end
            end
        else
            local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
            if remote then remote:FireServer() end
        end
    end)
    task.delay(v2 and math.clamp(0.12 - (((tonumber(tpBatSpin) or 40) - 10) / 70) * 0.105, 0.015, 0.12) or 0.08, function() _tpBatHitCooldown = false end)
end

-- ══════════════════════════════════════════════════════
-- TARGETING
-- ══════════════════════════════════════════════════════
local function tpBatClosestPlayer(root)
    local closest, distance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local character  = player ~= LP and player.Character
        local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid   = character and character:FindFirstChildOfClass("Humanoid")
        if targetRoot and humanoid and humanoid.Health > 0 then
            local candidateDistance = (root.Position - targetRoot.Position).Magnitude
            if candidateDistance < distance then
                closest, distance = player, candidateDistance
            end
        end
    end
    return closest, distance
end

-- ══════════════════════════════════════════════════════
-- NETWORK OWNER TELEPORT
-- ══════════════════════════════════════════════════════
local function tpBatNetworkOwnerTeleport(root, targetRoot)
    pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(nil) end end)
    task.wait()
    local targetPosition = targetRoot.Position + _V3new(0, 0.9, 0)
    root.CFrame = _CFnew(targetPosition)
    root.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
    pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end)
end

-- ══════════════════════════════════════════════════════
-- UPDATE LOOP
-- ══════════════════════════════════════════════════════
local function tpBatUpdate()
    if not batDesyncTpEnabled then return end
    local character = LP.Character
    local root      = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid  = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:Stop() end
        end)
    end

    local bat = tpBatGetBat()
    if bat and bat.Parent ~= character then
        pcall(function() humanoid:EquipTool(bat) end)
    end

    local target, distance = tpBatClosestPlayer(root)
    if not target then return end
    local isV2 = (tpBatVersion == 2)
    if not isV2 and distance > _tpBatMaxRange then return end
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    if isV2 then
        -- MVP TP BATE: PhysicsRepRootPart desync + teleport on top of the target
        if humanoid.Health <= 0 then return end
        if sethiddenproperty then pcall(sethiddenproperty, root, "PhysicsRepRootPart", targetRoot) end
        local tp = targetRoot.Position + _V3new(0, 0.9, 0)
        if distance > 4 then
            root.CFrame = _CFnew(tp, targetRoot.Position)
        elseif distance > 1.5 then
            root.CFrame = _CFnew(root.Position:Lerp(tp, 0.55), targetRoot.Position)
        else
            root.CFrame = _CFnew(tp, targetRoot.Position)
        end
        pcall(function() root.AssemblyAngularVelocity = _V3zero end)
    else
        tpBatNetworkOwnerTeleport(root, targetRoot)
    end

    local camera = workspace.CurrentCamera
    if camera then
        camera.CFrame = _CFnew(camera.CFrame.Position, targetRoot.Position)
    end
    tpBatHit()

    pcall(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

-- ══════════════════════════════════════════════════════
-- START / STOP / TOGGLE
-- ══════════════════════════════════════════════════════
function startAlvaroTP()
    if batDesyncTpConn then
        batDesyncTpConn:Disconnect()
        batDesyncTpConn = nil
    end

    batDesyncTpEnabled = true
    _G.AlvaroTP.on     = true
    _G.AlvaroTP.conn   = nil
    _tpBatHitCooldown  = false

    local char = LP.Character
    if char then
        _G.AlvaroTP.h   = char:FindFirstChildOfClass("Humanoid")
        _G.AlvaroTP.hrp = char:FindFirstChild("HumanoidRootPart")
    end

    batDesyncTpConn  = RunService.Heartbeat:Connect(tpBatUpdate)
    _G.AlvaroTP.conn = batDesyncTpConn

    -- Anti-Die integrado
    tpBatStartAntiDie()

    if batDesyncTpSetVisual then batDesyncTpSetVisual(true) end
    updateTpBatButtonWithAntiDie(true)
end

function stopAlvaroTP()
    batDesyncTpEnabled = false
    _G.AlvaroTP.on     = false

    if batDesyncTpConn then
        batDesyncTpConn:Disconnect()
        batDesyncTpConn = nil
    end
    _G.AlvaroTP.conn            = nil
    _G.AlvaroTP.hittingCooldown = false
    _tpBatHitCooldown           = false

    -- Apagar Anti-Die
    tpBatStopAntiDie()
    do
        local r = _G.AlvaroTP.hrp
        if r and r.Parent and sethiddenproperty then pcall(sethiddenproperty, r, "PhysicsRepRootPart", nil) end
    end

    local meRoot = _G.AlvaroTP.hrp
    if meRoot and meRoot.Parent then
        pcall(function()
            if meRoot.SetNetworkOwner then meRoot:SetNetworkOwner(LP) end
        end)
    end

    if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
    updateTpBatButtonWithAntiDie(false)
end

function toggleAlvaroTP()
    if batDesyncTpEnabled then stopAlvaroTP() else startAlvaroTP() end
end

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if _G.AlvaroTP.on then
        if inp.KeyCode == Enum.KeyCode.LeftShift or inp.KeyCode == Enum.KeyCode.RightShift then
            pcall(function()
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end)
        end
    end
end)

-- Reenganche al respawn (guarda referencias de HRP/Humanoid)
if _G.AlvaroTP._charConn then
    pcall(function() _G.AlvaroTP._charConn:Disconnect() end)
    _G.AlvaroTP._charConn = nil
end
local function tpBatSetupChar(char)
    task.wait(0.15)
    _G.AlvaroTP.h   = char and char:FindFirstChildOfClass("Humanoid") or nil
    _G.AlvaroTP.hrp = char and char:FindFirstChild("HumanoidRootPart") or nil
    if batDesyncTpEnabled and not batDesyncTpConn then
        startAlvaroTP()
    end
end
_G.AlvaroTP._charConn = LP.CharacterAdded:Connect(function(char)
    pcall(function() tpBatSetupChar(char) end)
end)
if LP.Character then
    task.spawn(function() pcall(function() tpBatSetupChar(LP.Character) end) end)
end

function startBatDesyncTp()
    if not _G.MeridianSafeModeTryStart("tpBat") then
        local q = _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("tpBat") or false
        batDesyncTpEnabled = false
        if batDesyncTpSetVisual then batDesyncTpSetVisual(q) end
        return
    end
    MeridianExclusive("tpBat")
    if not unwalkEnabled then
        startUnwalk()
        unwalkEnabled = true
        _tpBatUnwalkForced = true
        if setUnwalkVisual then setUnwalkVisual(true) end
    end
    startAlvaroTP()
end

function stopBatDesyncTp()
    stopAlvaroTP()
    if _tpBatUnwalkForced then
        stopUnwalk()
        unwalkEnabled = false
        _tpBatUnwalkForced = false
        if setUnwalkVisual then setUnwalkVisual(false) end
    end
end

function toggleBatDesyncTp()
    if _G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("tpBat") then
        _G.MeridianSM.cancel("tpBat")
        return
    end
    if batDesyncTpEnabled then
        stopBatDesyncTp()
    else
        disableAllAimbots()
        if autoLeftEnabled then
            autoLeftEnabled = false; stopAutoLeft()
            if autoLeftSetVisual then autoLeftSetVisual(false) end
            if mobSetAutoLeft then mobSetAutoLeft(false) end
        end
        if autoRightEnabled then
            autoRightEnabled = false; stopAutoRight()
            if autoRightSetVisual then autoRightSetVisual(false) end
            if mobSetAutoRight then mobSetAutoRight(false) end
        end
        startBatDesyncTp()
    end
    saveAllSettings()
end


function updateTpBatButtonWithAntiDie(state)
    if batDesyncTpSetVisual then batDesyncTpSetVisual(state) end
end

_G.AlvaroTPBat = {
    toggle    = toggleAlvaroTP,
    start     = startAlvaroTP,
    stop      = stopAlvaroTP,
    getStatus = function() return _G.AlvaroTP.on end,
}

-- ────────────────────────────────────────────────────────────────

function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = char:FindFirstChild(name)
        if t and t:IsA("Tool") then return t end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(t) end) end
                return t
            end
        end
    end
    for _, ch in ipairs(char:GetChildren()) do
        if ch:IsA("Tool") and (ch.Name:lower():find("bat") or ch.Name:lower():find("slap")) then
            return ch
        end
    end
    return nil
end

function isBatTool(tool)
    if not tool then return false end
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        if tool.Name == name then return true end
    end
    return tool.Name:lower():find("bat") or tool.Name:lower():find("slap")
end

function findBatForCounter()
    local char = LP.Character
    if not char then return nil end
    local backpack = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local tool = char:FindFirstChild(name) or (backpack and backpack:FindFirstChild(name))
        if tool then return tool end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
            return child
        end
    end
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and (child.Name:lower():find("bat") or child.Name:lower():find("slap")) then
                return child
            end
        end
    end
    return nil
end

function swingBatForCounter(bat, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= character and humanoid then
        pcall(function() humanoid:EquipTool(bat) end)
        task.wait(0.05)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end)
        task.wait(0.1)
        pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end)
        task.wait(0.1)
        pcall(function() bat:Activate() end)
    end
end

batCounterDebounce = false

function stopBatCounter()
    if Conns.batCounter then
        Conns.batCounter:Disconnect()
        Conns.batCounter = nil
    end
    batCounterDebounce = false
end

function startBatCounter()
    if Conns.batCounter then return end
    Conns.batCounter = RunService.Heartbeat:Connect(function()
        if not batCounterEnabled then return end
        if batCounterDebounce then return end
        local character = LP.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
            batCounterDebounce = true
            _suppressBodyLock()
            task.spawn(function()
                task.wait(0.15)
                local bat = findBatForCounter()
                if bat then swingBatForCounter(bat, character) end
                task.wait(0.3)
                batCounterDebounce = false
                _unsuppressBodyLock(true)
            end)
        end
    end)
end

function findMedusa()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("medusa") or n:find("head") or n:find("stone") then return t end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("medusa") or n:find("head") or n:find("stone") then return t end
            end
        end
    end
    return nil
end

function useMedusaCounter()
    if medusaDebounce then return end
    if _tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = LP.Character
    if not c then return end
    medusaDebounce = true
    local med = findMedusa()
    if not med then medusaDebounce = false; return end
    if med.Parent ~= c then
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:EquipTool(med) end
    end
    pcall(function() med:Activate() end)
    medusaLastUsed = _tick()
    medusaDebounce = false
end

function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then useMedusaCounter() end
    end)
end

function setupMedusaCounter(char)
    for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
    Conns.anchor = {}
    if not char or not medusaCounterEnabled then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(Conns.anchor, onAnchorChanged(part))
        end
    end
    table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(Conns.anchor, onAnchorChanged(part))
        end
    end))
end

function stopMedusaCounter()
    for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
    Conns.anchor = {}
end

local DROP_ASCEND_DURATION = 0.22
local DROP_ASCEND_SPEED = 160
local _dropConn = nil

function stopDropBrainrot()
    dropActive = false
    if _dropConn then
        _dropConn:Disconnect()
        _dropConn = nil
    end
    for _, t in ipairs(dropConnections) do
        if type(t) == "thread" then pcall(task.cancel, t)
        elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    dropConnections = {}
    local c = LP.Character
    if c then
        local root = c:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity = _V3zero end
    end
    if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
    if mobSetDropBR then mobSetDropBR(false) end
end

function runDropBrainrot()
    if dropActive then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if dropMode == 1 then
        local speedH = 0
        if root then
            local vel = root.AssemblyLinearVelocity
            speedH = _V3new(vel.X, 0, vel.Z).Magnitude
        end
        local cooldown = (speedH > 5) and 0.6 or 0.25
        if _tick() - lastDropTime < cooldown then return end
        lastDropTime = _tick()
        dropActive = true
        if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
        if mobSetDropBR then mobSetDropBR(true) end
        local wasAutoBat = false
        if autoBatEnabled then
            wasAutoBat = true
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end
        local function finishDrop(threadRef)
            if threadRef and dropConnections then
                for i = #dropConnections, 1, -1 do
                    if dropConnections[i] == threadRef then
                        table.remove(dropConnections, i)
                        break
                    end
                end
            end
            dropActive = false
            local c = LP.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if r then
                    r.AssemblyLinearVelocity = _V3zero
                    r.AssemblyAngularVelocity = _V3zero
                    if r.Position.Y < -100 then
                        r.CFrame = _CFnew(r.Position.X, 5, r.Position.Z)
                    end
                    local rp = RaycastParams.new()
                    rp.FilterDescendantsInstances = {c}
                    rp.FilterType = Enum.RaycastFilterType.Exclude
                    local rr = workspace:Raycast(r.Position, _V3new(0, -2000, 0), rp)
                    if rr then
                        local off = (h and h.HipHeight or 2) + (r.Size.Y / 2)
                        r.CFrame = _CFnew(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    end
                    if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Running) end
                end
            end
            if wasAutoBat then
                enableAutoBat()
                if autoBatSetVisual then autoBatSetVisual(true) end
                if mobSetAutoBat then mobSetAutoBat(true) end
            end
            if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
            if mobSetDropBR then mobSetDropBR(false) end
        end
        local flingThread = nil
        flingThread = task.spawn(function()
            local startTime = _tick()
            while dropActive and (_tick() - startTime) < 0.25 do
                RunService.Heartbeat:Wait()
                local c = LP.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if not r then break end
                local vel = r.AssemblyLinearVelocity
                vel = _V3new(0, vel.Y, 0)
                r.AssemblyLinearVelocity = vel * 10000 + _V3new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if r and r.Parent then r.AssemblyLinearVelocity = vel end
                RunService.Stepped:Wait()
                if r and r.Parent then r.AssemblyLinearVelocity = vel + _V3new(0, 0.1, 0) end
            end
            finishDrop(flingThread)
        end)
        table.insert(dropConnections, flingThread)
        task.delay(0.35, function()
            if dropActive then finishDrop(flingThread) end
        end)
        return
    end
    dropActive = true
    if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
    if mobSetDropBR then mobSetDropBR(true) end
    local t0 = _tick()
    if _dropConn then _dropConn:Disconnect() end
    _dropConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            dropActive = false
            if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
            if mobSetDropBR then mobSetDropBR(false) end
            return
        end
        if not dropActive then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
            if mobSetDropBR then mobSetDropBR(false) end
            return
        end
        if _tick() - t0 >= DROP_ASCEND_DURATION then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            pcall(function()
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {c}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(r.Position, _V3new(0, -3000, 0), rp)
                if rr then
                    local hum2 = c:FindFirstChildOfClass("Humanoid")
                    local off = ((hum2 and hum2.HipHeight) or 2) + (r.Size.Y / 2)
                    r.CFrame = _CFnew(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    r.AssemblyLinearVelocity = _V3zero
                    r.AssemblyAngularVelocity = _V3zero
                end
                if hum2 and hum2.Health > 0 then hum2:ChangeState(Enum.HumanoidStateType.Running) end
            end)
            dropActive = false
            if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
            if mobSetDropBR then mobSetDropBR(false) end
            return
        end
        local lv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = _V3new(lv.X, DROP_ASCEND_SPEED, lv.Z)
    end)
end

function executeDropWithToggle(setVisual)
    if dropActive then return end
    task.spawn(function()
        if setVisual then setVisual(true) end
        runDropBrainrot()
        while dropActive do task.wait() end
        task.wait(0.1)
        if setVisual then setVisual(false) end
    end)
end

local function applyAntiLagDerender(obj)
    pcall(function()
        if obj:GetAttribute("_MeridianHubSky") ~= nil then return end
        if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then return end
        if skyTheme ~= "Off" and obj.Parent == Lighting then
            if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect")
            or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect")
            or obj:IsA("DepthOfFieldEffect") or obj:IsA("BrightnessEffect")
            or obj:IsA("DitheringEffect") then return end
        end
        if obj:IsA("Accessory") or obj:IsA("Hat") then
            local char = LP.Character
            if char and obj:IsDescendantOf(char) then return end
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.Material      = Enum.Material.Plastic
            obj.Reflectance   = 0
            obj.CastShadow    = false
            obj.TopSurface    = Enum.SurfaceType.Smooth
            obj.BottomSurface = Enum.SurfaceType.Smooth
            obj.FrontSurface  = Enum.SurfaceType.Smooth
            obj.BackSurface   = Enum.SurfaceType.Smooth
            obj.LeftSurface   = Enum.SurfaceType.Smooth
            obj.RightSurface  = Enum.SurfaceType.Smooth
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    child.Transparency = 0.5
                end
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0.5
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight")
            or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        elseif obj:IsA("SelectionBox") and obj.Name ~= "MeridianHubESP" then
            pcall(function() obj:Destroy() end)
        end
    end)
end

function enableAntiLag()
    antiLagEnabled           = true
    removeAccessoriesEnabled = true

    _G._MeridianDefLightBrightness = _G._MeridianDefLightBrightness or Lighting.Brightness
    _G._MeridianDefLightClock      = _G._MeridianDefLightClock      or Lighting.ClockTime
    _G._MeridianDefLightAmbient    = _G._MeridianDefLightAmbient    or Lighting.OutdoorAmbient

    pcall(function()
        settings().Rendering.QualityLevel        = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Disabled
    end)

    if skyTheme == "Off" then
        Lighting.GlobalShadows            = false
        Lighting.FogEnd                   = 1e10
        Lighting.FogStart                 = 0
        Lighting.Brightness               = 1
        Lighting.EnvironmentDiffuseScale  = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ShadowSoftness           = 0
        Lighting.ExposureCompensation     = 0
        pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)

        for _, e in pairs(Lighting:GetChildren()) do
            pcall(function()
                if e:GetAttribute("_MeridianVivid") then return end
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect")
                or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect")
                or e:IsA("DepthOfFieldEffect") or e:IsA("BrightnessEffect")
                or e:IsA("DitheringEffect") then
                    e.Enabled = false
                end
            end)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        applyAntiLagDerender(obj)
    end

    for _, descendant in pairs(workspace:GetDescendants()) do
        pcall(function()
            if descendant:IsA("ParticleEmitter") then
                descendant.Enabled = false
            elseif descendant:IsA("Decal") then
                descendant.Transparency = 1
            elseif descendant:IsA("BasePart") then
                local char = LP.Character
                if char and descendant:IsDescendantOf(char) then return end
                descendant.Material      = Enum.Material.Plastic
                descendant.Reflectance   = 0
                descendant.CastShadow    = false
                descendant.TopSurface    = Enum.SurfaceType.Smooth
                descendant.BottomSurface = Enum.SurfaceType.Smooth
                descendant.FrontSurface  = Enum.SurfaceType.Smooth
                descendant.BackSurface   = Enum.SurfaceType.Smooth
                descendant.LeftSurface   = Enum.SurfaceType.Smooth
                descendant.RightSurface  = Enum.SurfaceType.Smooth
            end
        end)
    end

    pcall(function()
        workspace.Terrain.WaterWaveSize     = 0
        workspace.Terrain.WaterWaveSpeed    = 0
        workspace.Terrain.WaterReflectance  = 0
        workspace.Terrain.WaterTransparency = 0
        workspace.Terrain.Decoration        = false
    end)

    if antiLagDescConn then antiLagDescConn:Disconnect() end
    antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
        if obj:GetAttribute("_MeridianHubSky") then return end
        if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then return end
        if removeAccessoriesEnabled then applyAntiLagDerender(obj) end
    end)
end

function disableAntiLag()
    antiLagEnabled           = false
    removeAccessoriesEnabled = false
    if antiLagDescConn then
        antiLagDescConn:Disconnect()
        antiLagDescConn = nil
    end
    if skyTheme == "Off" then
        pcall(function()
            if _G._MeridianDefLightBrightness then
                Lighting.Brightness = _G._MeridianDefLightBrightness
            end
            if _G._MeridianDefLightClock then
                Lighting.ClockTime = _G._MeridianDefLightClock
            end
            if _G._MeridianDefLightAmbient then
                Lighting.OutdoorAmbient = _G._MeridianDefLightAmbient
            end
            Lighting.ExposureCompensation = 0
            Lighting.GlobalShadows = true
        end)
    end
end

CUSTOM_FOV_BIND = "MeridianHubCustomFOV"

function enableCustomFov()
    local cam = workspace.CurrentCamera
    if cam and origFOV == nil then origFOV = cam.FieldOfView end
    fovEnabled = true
    if cam then
        pcall(function() cam.FieldOfViewMode = Enum.FieldOfViewMode.Diagonal end)
        pcall(function() cam.FieldOfView = fovValue end)
    end
    if customFovConn then customFovConn:Disconnect(); customFovConn = nil end
    pcall(function() RunService:UnbindFromRenderStep(CUSTOM_FOV_BIND) end)
    local prio = 200
    pcall(function() prio = Enum.RenderPriority.Camera.Value + 10 end)
    local ok = pcall(function()
        RunService:BindToRenderStep(CUSTOM_FOV_BIND, prio, function()
            if not fovEnabled then return end
            local c = workspace.CurrentCamera
            if c and c.FieldOfView ~= fovValue then
                c.FieldOfView = fovValue
            end
        end)
    end)
    if not ok then
        customFovConn = RunService.RenderStepped:Connect(function()
            if not fovEnabled then
                if customFovConn then customFovConn:Disconnect(); customFovConn = nil end
                return
            end
            local c = workspace.CurrentCamera
            if c then c.FieldOfView = fovValue end
        end)
    end
end

function disableCustomFov()
    fovEnabled = false
    pcall(function() RunService:UnbindFromRenderStep(CUSTOM_FOV_BIND) end)
    if customFovConn then customFovConn:Disconnect(); customFovConn = nil end
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfViewMode = Enum.FieldOfViewMode.Vertical end)
        pcall(function() cam.FieldOfView = origFOV or 70 end)
    end
end

function applyStretchFOV(val)
    local cam = workspace.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = val end) end
end

function enableStretch()
    if stretchConn then return end
    stretchEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    origFOV = cam.FieldOfView or 70
    applyStretchFOV(stretchFOV)
    stretchConn = RunService.RenderStepped:Connect(function()
        if not stretchEnabled then
            stretchConn:Disconnect()
            stretchConn = nil
            return
        end
        local c = workspace.CurrentCamera
        if c then c.CFrame = c.CFrame * _CFnew(0,0,0,1,0,0,0,0.7,0,0,0,1) end
    end)
    if stretchFovConn then stretchFovConn:Disconnect() end
    stretchFovConn = RunService.RenderStepped:Connect(function()
        if stretchEnabled then applyStretchFOV(stretchFOV)
        else stretchFovConn:Disconnect(); stretchFovConn = nil end
    end)
end

function disableStretch()
    stretchEnabled = false
    if stretchConn then stretchConn:Disconnect(); stretchConn = nil end
    if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end
    local cam = workspace.CurrentCamera
    if cam then pcall(function() cam.FieldOfView = origFOV or 70 end) end
end

local function saveLightingState()
    if _originalLighting then return end
    _originalLighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        FogColor = Lighting.FogColor,
        Ambient = Lighting.Ambient,
        ColorCorrection = nil,
        Bloom = nil,
    }
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("ColorCorrectionEffect") then
            _originalLighting.ColorCorrection = {
                Enabled = e.Enabled,
                Brightness = e.Brightness,
                Contrast = e.Contrast,
                Saturation = e.Saturation,
                TintColor = e.TintColor,
            }
        elseif e:IsA("BloomEffect") then
            _originalLighting.Bloom = {
                Enabled = e.Enabled,
                Intensity = e.Intensity,
                Size = e.Size,
                Threshold = e.Threshold,
            }
        end
    end
end

local function restoreLightingState()
    if not _originalLighting then return end
    local old = _originalLighting
    Lighting.Brightness = old.Brightness
    Lighting.ClockTime = old.ClockTime
    Lighting.OutdoorAmbient = old.OutdoorAmbient
    Lighting.GlobalShadows = old.GlobalShadows
    Lighting.FogEnd = old.FogEnd
    Lighting.FogStart = old.FogStart
    Lighting.FogColor = old.FogColor
    Lighting.Ambient = old.Ambient
    if old.ColorCorrection then
        local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
        if cc then
            cc.Enabled = old.ColorCorrection.Enabled
            cc.Brightness = old.ColorCorrection.Brightness
            cc.Contrast = old.ColorCorrection.Contrast
            cc.Saturation = old.ColorCorrection.Saturation
            cc.TintColor = old.ColorCorrection.TintColor
        end
    end
    if old.Bloom then
        local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
        if bloom then
            bloom.Enabled = old.Bloom.Enabled
            bloom.Intensity = old.Bloom.Intensity
            bloom.Size = old.Bloom.Size
            bloom.Threshold = old.Bloom.Threshold
        end
    end
end

SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}

SKY_PRESETS = {
    ["Off"]={kind="off"},
    ["Night"]={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}},
    ["Aurora"]={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
    ["Sunset"]={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}},
    ["Galaxy"]={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
    ["Cyber"]={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}},
    ["Sakura"]={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
    ["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4},clouds={cover=0.3,dens=0.5,color={180,90,150}}},
    ["Blood Moon"]={clock=22.5,brightness=1.8,ambient={130,70,70},outAmb={150,80,80},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.45,color={220,80,80},decay={120,40,40},glare=1.0,haze=1.5},clouds={cover=0.45,dens=0.55,color={120,60,60}}},
    ["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18,moon=0,stars=0},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2},clouds={cover=0.5,dens=0.5,color={200,255,220}}},
    ["Volcanic"]={clock=19,brightness=2.2,ambient={180,110,80},outAmb={200,120,90},sky={stars=200,sun=12,moon=0},atm={dens=0.55,color={255,110,60},decay={180,70,40},glare=2.0,haze=2.2},clouds={cover=0.65,dens=0.7,color={120,70,50}}},
    ["Arctic"]={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10,stars=0,moon=0},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7,dens=0.6,color={250,253,255}}},
    ["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
    ["Vaporwave"]={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.55,dens=0.55,color={200,150,255}}},
    ["Toxic"]={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.45,color={100,220,40},decay={60,150,20},glare=1.5,haze=1.8},clouds={cover=0.55,dens=0.55,color={180,255,120}}},
    ["Solar Eclipse"]={clock=12,brightness=1.2,ambient={70,60,80},outAmb={80,70,90},sky={stars=3500,sun=22,moon=0},atm={dens=0.4,color={255,180,90},decay={50,40,60},glare=2.0,haze=1.5}},
    ["Hellscape"]={clock=18,brightness=2.2,ambient={200,100,80},outAmb={220,110,90},sky={stars=100,sun=30,moon=0},atm={dens=0.6,color={255,90,60},decay={140,50,40},glare=2.2,haze=2.4},clouds={cover=0.8,dens=0.8,color={90,50,40}}},
    ["Heaven"]={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16,moon=0,stars=0},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5},clouds={cover=0.85,dens=0.5,color={255,255,255}}},
    ["Storm"]={clock=15,brightness=1.6,ambient={105,105,125},outAmb={115,115,135},sky={stars=0,sun=6,moon=0},atm={dens=0.55,color={90,100,130},decay={55,65,90},glare=0.5,haze=2.2},clouds={cover=0.85,dens=0.75,color={70,75,90}}},
    ["Sunrise"]={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22,stars=0,moon=0},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4,dens=0.4,color={255,220,180}}},
    ["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}},
    ["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16,sun=0},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5,color={220,200,255}}},
    ["Inferno"]={clock=17.5,brightness=2.4,ambient={220,140,90},outAmb={235,150,100},sky={sun=26,moon=0,stars=0},atm={dens=0.5,color={255,130,70},decay={200,80,40},glare=2.2,haze=2.2},clouds={cover=0.6,dens=0.6,color={200,110,80}}},
    ["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}

local function _vC3(t) return Color3.fromRGB(t[1], t[2], t[3]) end

function _v4mpClearSky()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute("_AdaptDuelsSky") then
            pcall(function() child:Destroy() end)
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute("_AdaptDuelsSky") then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

function applyCustomSky(mode)
    _v4mpClearSky()
    local preset = SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        Lighting.Ambient = Color3.fromRGB(127,127,127)
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        skyTheme = "Off"
        return
    end
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(200,200,200)
    Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
    Lighting.GlobalShadows = true
    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = _vC3(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = _vC3(preset.ambient) end
    if preset.sky then
        local skyInst = Instance.new("Sky")
        skyInst:SetAttribute("_AdaptDuelsSky", true)
        if preset.sky.stars then skyInst.StarCount = preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId = "rbxasset://sky/moon.jpg" end
        skyInst.Parent = Lighting
    end
    if preset.atm then
        local atm = Instance.new("Atmosphere")
        atm:SetAttribute("_AdaptDuelsSky", true)
        atm.Density = preset.atm.dens or 0.3
        atm.Color = _vC3(preset.atm.color)
        atm.Decay = _vC3(preset.atm.decay)
        atm.Glare = preset.atm.glare or 1
        atm.Haze = preset.atm.haze or 1
        atm.Parent = Lighting
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if preset.clouds and terrain then
        local clouds = Instance.new("Clouds")
        clouds:SetAttribute("_AdaptDuelsSky", true)
        clouds.Cover = preset.clouds.cover or 0.5
        clouds.Density = preset.clouds.dens or 0.5
        clouds.Color = _vC3(preset.clouds.color)
        clouds.Parent = terrain
    end
    skyTheme = mode
end

local function applyNeonWeather()
    if not neonWeatherEnabled then
        restoreLightingState()
        return
    end
    if not _originalLighting then saveLightingState() end
    Lighting.Brightness = 2.2
    Lighting.ClockTime = 20
    Lighting.OutdoorAmbient = Color3.fromRGB(60, 80, 120)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 800
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.fromRGB(60, 120, 200)
    Lighting.Ambient = Color3.fromRGB(60, 90, 140)
    local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Parent = Lighting
    end
    cc.Enabled = true
    cc.Brightness = 0.1
    cc.Contrast = 0.08
    cc.Saturation = 0.08
    cc.TintColor = Color3.fromRGB(200, 200, 210)
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = Lighting
    end
    bloom.Enabled = true
    bloom.Intensity = 0.4
    bloom.Size = 20
    bloom.Threshold = 0.9
end

function toggleNeonWeather(state)
    if state == nil then
        neonWeatherEnabled = not neonWeatherEnabled
    else
        neonWeatherEnabled = state
    end
    applyNeonWeather()
    if setNeonWeatherVisual then setNeonWeatherVisual(neonWeatherEnabled) end
end

function paintFloatingBtn(btnFrame, active)
    if not btnFrame then return end
    local bg = btnFrame:FindFirstChild("BtnGrad")
    local label = btnFrame:FindFirstChild("TextLabel")
    local stroke = btnFrame:FindFirstChildOfClass("UIStroke")
    btnFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    -- style C: brushed-silver streak on the name; ON = silver plate with dark name
    local streak = label and label:FindFirstChild("TextStreak")
    if label and not streak then
        streak = Instance.new("UIGradient", label)
        streak.Name = "TextStreak"
        streak.Rotation = 100
        streak.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(155, 155, 166)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(155, 155, 166)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
        })
    end

    if active then
        if bg then
            bg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(233, 233, 238)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(140, 140, 150)),
            })
        end
        if label then
            label.TextColor3 = Color3.fromRGB(10, 10, 12)
            if streak then streak.Enabled = false end
        end
        if stroke then
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 1.8
            stroke.Transparency = 0.05
        end
    else
        if bg then
            bg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(38, 38, 43)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(7, 7, 10)),
            })
        end
        if label then
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            if streak then streak.Enabled = true end
        end
        if stroke then
            stroke.Color = Color3.fromRGB(70, 70, 78)
            stroke.Thickness = 1
            stroke.Transparency = 0.45
        end
    end
    buttonImageSync(btnFrame, active)
end

function applyFloatingButtonScale()
    for _, uiScale in ipairs(_floatingUIScales) do
        if uiScale and uiScale.Parent then
            uiScale.Scale = floatingButtonScale
        end
    end
end

function clampProgressBar()
    if not pbFrame or not pbFrame.Parent then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return end
    local sc = pbScale and pbScale.Scale or 1
    -- cap the bar at 70% of the screen width (an absurd saved scale would cover the screen)
    local baseW = pbFrame.Size.X.Offset
    local baseH = pbFrame.Size.Y.Offset
    if pbScale and baseW * sc > vp.X * 0.7 then
        sc = math.max(0.5, (vp.X * 0.7) / baseW)
        pbScale.Scale = sc
        progressBarScale = sc
    end
    local w, h = baseW * sc, baseH * sc
    local pos = pbFrame.AbsolutePosition
    local dx, dy = 0, 0
    if pos.X < 0 then dx = -pos.X elseif pos.X + w > vp.X then dx = vp.X - (pos.X + w) end
    if pos.Y < 0 then dy = -pos.Y elseif pos.Y + h > vp.Y then dy = vp.Y - (pos.Y + h) end
    if dx ~= 0 or dy ~= 0 then
        local p = pbFrame.Position
        pbFrame.Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset + dy)
    end
end

local function drag(f)
    local dn, ds, sp, di = false, nil, nil, nil
    local endConn = nil
    local function stopDrag()
        dn = false
        di = nil
        if endConn then
            endConn:Disconnect()
            endConn = nil
        end
        if f == pbFrame then pcall(clampProgressBar) end
        pcall(saveAllSettings)
    end
    f.InputBegan:Connect(function(i)
        if uiLocked then return end
        if _isDraggingButton then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dn = true; ds = i.Position; sp = f.Position
            if endConn then endConn:Disconnect() end
            endConn = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then stopDrag() end
            end)
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            stopDrag()
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            stopDrag()
        end
    end)
    f.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == di and dn then
            if uiLocked then stopDrag(); return end
            if _isDraggingButton then return end
            if not ds or not sp then return end
            local nX = sp.X.Offset + (i.Position.X - ds.X)
            local nY = sp.Y.Offset + (i.Position.Y - ds.Y)
            f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
        end
    end)
end

function setupMovementAndIndicators(char)
    if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    if movementLoop then movementLoop:Disconnect(); movementLoop = nil end

    local ccAcc = 0
    steppedConn = RunService.Heartbeat:Connect(function(dt)
        ccAcc = ccAcc + dt
        if ccAcc < 0.05 then return end
        ccAcc = 0
        local plist = _GetPlayersCached()
        for i = 1, #plist do
            local p = plist[i]
            if p ~= LP then
                local ch = p.Character
                if ch then
                    local parts = ch:GetChildren()
                    for j = 1, #parts do
                        local part = parts[j]
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end)

    movementLoop = RunService.RenderStepped:Connect(function()
        local char2 = LP.Character
        if not char2 then return end
        local hum = char2:FindFirstChildOfClass("Humanoid")
        local hrp = char2:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled
           and not autoBatV2Enabled and not batDesyncTpEnabled then
            if _isRagdollState(hum) then
                lastMoveDir = _V3zero
            else
                local md = hum.MoveDirection
                local spd = getActiveMoveSpeed()
                local dir = nil
                if md.Magnitude > 0 then
                    lastMoveDir = md
                    dir = md
                elseif lastMoveDir.Magnitude > 0 then
                    for key in pairs(MOVE_KEYS) do
                        if UIS:IsKeyDown(key) then dir = lastMoveDir; break end
                    end
                end
                _applyVelocitySpeed(dir, spd, hrp)
            end
        end

        if speedLabel then
            local v = hrp.AssemblyLinearVelocity
            local s = _sqrt(v.X*v.X + v.Z*v.Z)
            if s < 0.05 then s = 0 end
            speedLabel.Text = string.format("SPEED: %.1f", s)
        end
    end)
    setupSpeedIndicator(char)
    startEnemySpeed()
end

function toggleLockUI(state)
    if state == nil then uiLocked = not uiLocked else uiLocked = state end
    if setLockUIVisual then setLockUIVisual(uiLocked) end
    if _G.MeridianRefreshLockIcon then pcall(_G.MeridianRefreshLockIcon) end
end

function disableAllAimbots()
    if autoBatEnabled then
        disableAutoBat()
        if autoBatSetVisual then autoBatSetVisual(false) end
        if mobSetAutoBat then mobSetAutoBat(false) end
    end
    if batDesyncTpEnabled then stopBatDesyncTp() end
    if autoBatV2Enabled then
        disableBatV2()
        if autoBatV2SetVisual then autoBatV2SetVisual(false) end
    end
end

function stopAllBackgroundTasks()
    if movementLoop then movementLoop:Disconnect(); movementLoop = nil end
    if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    stopEnemySpeed()
    if stretchEnabled then disableStretch() end
    if stretchConn then stretchConn:Disconnect(); stretchConn = nil end
    if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end
    if AntiRagdollV1.isRunning() then AntiRagdollV1.stop() end
    if AntiRagdollV2.Enabled then stopAntiRagdollV2() end
    if antiFlingEnabled then AntiFlingShieldModule.stop() end
    stopBatCounter()
    stopMedusaCounter()
    stopAutoSteal()
    disableAutoBat()
    if batDesyncTpEnabled then stopBatDesyncTp() end
    if autoBatV2Enabled then disableBatV2() end
    stopAutoLeft()
    stopAutoRight()
    if unwalkEnabled and not _tpBatUnwalkForced then stopUnwalk() end
    if antiLagEnabled then disableAntiLag() end
    if espEnabled then toggleESP(false) end
    if dropActive then stopDropBrainrot() end
    if bodyLockEnabled then stopBodyLock() end
    _blSuppressCount = 0
    _blWasEnabled = false
    if _blRestoreTimer then
        pcall(task.cancel, _blRestoreTimer)
        _blRestoreTimer = nil
    end
    if _bodyLockConn then
        _bodyLockConn:Disconnect()
        _bodyLockConn = nil
    end
    for _, t in ipairs(dropConnections) do
        if type(t) == "thread" then pcall(task.cancel, t)
        elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    dropConnections = {}
    dropActive = false
    alPhase = 1
    arPhase = 1
    lastDropTime = 0
    medusaDebounce = false
    medusaLastUsed = 0
end

-- ═══════════════════════════════════════════════════════════════════════════
-- NO CAMERA COLLISION
-- ═══════════════════════════════════════════════════════════════════════════
_G._NoCamCollision = _G._NoCamCollision or {
    targetZoom = 10,
    currentZoom = 10,
    zoomConn = nil,
    watchConns = {},
    resync = true,
}

function enableNoCamCollision()
    noCamCollisionEnabled = true
    local NC = _G._NoCamCollision
    local cam0 = workspace.CurrentCamera
    NC.targetZoom  = math.clamp(10, LP.CameraMinZoomDistance, LP.CameraMaxZoomDistance)
    NC.currentZoom = NC.targetZoom
    NC.resync = true

    if NC.zoomConn then NC.zoomConn:Disconnect() end
    NC.zoomConn = UIS.InputChanged:Connect(function(input, gameProcessed)
        if not noCamCollisionEnabled then return end
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local curMin = LP.CameraMinZoomDistance
            local curMax = LP.CameraMaxZoomDistance
            NC.targetZoom = math.clamp(NC.targetZoom - (input.Position.Z * 4), curMin, curMax)
        end
    end)

    for _, c in ipairs(NC.watchConns or {}) do pcall(function() c:Disconnect() end) end
    NC.watchConns = {}
    local function askResync() NC.resync = true end
    table.insert(NC.watchConns, LP:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(askResync))
    table.insert(NC.watchConns, LP:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(askResync))
    table.insert(NC.watchConns, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(askResync))
    table.insert(NC.watchConns, LP.CharacterAdded:Connect(askResync))
    if cam0 then
        table.insert(NC.watchConns, cam0:GetPropertyChangedSignal("CameraType"):Connect(askResync))
        table.insert(NC.watchConns, cam0:GetPropertyChangedSignal("CameraSubject"):Connect(askResync))
    end

    pcall(function() RunService:UnbindFromRenderStep("MeridianNoCamCollision") end)
    RunService:BindToRenderStep("MeridianNoCamCollision", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
        if not noCamCollisionEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        if cam.CameraType == Enum.CameraType.Scriptable then NC.resync = true return end
        if cam.CameraSubject == nil then NC.resync = true return end

        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then NC.resync = true return end

        local curMin = LP.CameraMinZoomDistance
        local curMax = LP.CameraMaxZoomDistance
        if curMax <= 1 then NC.resync = true return end

        local realZoom = (cam.CFrame.Position - cam.Focus.Position).Magnitude
        if realZoom < 0.6 then NC.resync = true return end

        if NC.resync or realZoom > NC.currentZoom + 0.5 then
            NC.targetZoom  = math.clamp(realZoom, curMin, curMax)
            NC.currentZoom = NC.targetZoom
            NC.resync = false
        end

        NC.targetZoom  = math.clamp(NC.targetZoom, curMin, curMax)
        NC.currentZoom = NC.currentZoom + (NC.targetZoom - NC.currentZoom) * math.min(deltaTime * 15, 1)
        cam.CFrame = cam.Focus * cam.CFrame.Rotation * _CFnew(0, 0, NC.currentZoom)
    end)
end

function disableNoCamCollision()
    noCamCollisionEnabled = false
    pcall(function() RunService:UnbindFromRenderStep("MeridianNoCamCollision") end)
    if _G._NoCamCollision.zoomConn then _G._NoCamCollision.zoomConn:Disconnect(); _G._NoCamCollision.zoomConn = nil end
    for _, c in ipairs(_G._NoCamCollision.watchConns or {}) do pcall(function() c:Disconnect() end) end
    _G._NoCamCollision.watchConns = {}
end

-- ═══════════════════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════════════════
function buildConfigTable()
    local config = {
        normalSpeed = NS,
        carrySpeed = CS,
        laggerSpeed1 = LAGGER_SPEED,
        laggerSpeed2 = LAGGER_CARRY_SPEED,
        stealRadius = CONFIG.STEAL_RANGE,
        antiRagdollMode = antiRagdollMode,
        antiDieEnabled = antiDieEnabled,
        autoSteal = CONFIG.AUTO_STEAL_ENABLED,
        medusaCounter = medusaCounterEnabled,
        batCounter = batCounterEnabled,
        laggerToggled = laggerToggled,
        laggerCarryToggled = laggerCarryToggled,
        carryMode = speedMode,
        batAimbotSpeed = BAT_AIMBOT_SPEED,
        dropMode = dropMode,
        stretchEnabled = stretchEnabled,
        stretchFOV = stretchFOV,
        fovEnabled = fovEnabled,
        fovValue = fovValue,
        uiScale = uiScaleValue,
        animPack = currentAnimPack,
        espEnabled = espEnabled,
        antiLag = antiLagEnabled,
        tpBatEnabled = batDesyncTpEnabled,
        neonWeather = neonWeatherEnabled,
        skyTheme = skyTheme,
        autoBatV2Enabled = autoBatV2Enabled,
        selectedAimbotMode              = selectedAimbotMode,
        ANTI_BYPASS_AIMBOT_SPEED        = _G.AceAntiBypassAimbotSpeed,
        ANTI_BYPASS_LAGGER_AIMBOT_SPEED = _G.AceAntiBypassLaggerAimbotSpeed,
        antiBypassAimbotEnabled         = _G.AceAntiBypassAimbotOn == true,
        tpBatVersion                    = tpBatVersion,
        tpBatSpin                       = tpBatSpin,
        meridianHubAutoTPDown = MeridianHubAutoTPDown,
        meridianHubAutoTPDownHeight = MeridianHubAutoTPDownHeight,
        meridianHubShowE01Warning = MeridianHubShowE01Warning,
        unwalk = unwalkEnabled,
        holdJumpEnabled = infJumpEnabled,
        holdJumpMode    = infJumpMode,
        mirrorTPDown    = mirrorTPDownEnabled,
        safeMode        = antiKickEnabled,
        noCamCollision    = noCamCollisionEnabled == true,
        mobileButtonPositions = savedButtonPositions,
        floatLayout = currentFloatLayoutName(),
        dropBrainrotKey = {kb = KB.DropBrainrot.kb and KB.DropBrainrot.kb.Name, gp = KB.DropBrainrot.gp and KB.DropBrainrot.gp.Name},
        autoLeftKey = {kb = KB.AutoLeft.kb and KB.AutoLeft.kb.Name, gp = KB.AutoLeft.gp and KB.AutoLeft.gp.Name},
        autoRightKey = {kb = KB.AutoRight.kb and KB.AutoRight.kb.Name, gp = KB.AutoRight.gp and KB.AutoRight.gp.Name},
        autoBatKey = {kb = KB.AutoBat.kb and KB.AutoBat.kb.Name, gp = KB.AutoBat.gp and KB.AutoBat.gp.Name},
        tpFloorKey = {kb = KB.TPFloor.kb and KB.TPFloor.kb.Name, gp = KB.TPFloor.gp and KB.TPFloor.gp.Name},
        carryToggleKey = {kb = KB.CarryToggle.kb and KB.CarryToggle.kb.Name, gp = KB.CarryToggle.gp and KB.CarryToggle.gp.Name},
        laggerModeKey = {kb = KB.LaggerMode.kb and KB.LaggerMode.kb.Name, gp = KB.LaggerMode.gp and KB.LaggerMode.gp.Name},
        tpBatKey = {kb = KB.TPBat.kb and KB.TPBat.kb.Name, gp = KB.TPBat.gp and KB.TPBat.gp.Name},
        batV2Key = {kb = KB.BatV2.kb and KB.BatV2.kb.Name, gp = KB.BatV2.gp and KB.BatV2.gp.Name},
        instaResetKey = {kb = KB.InstaReset.kb and KB.InstaReset.kb.Name, gp = KB.InstaReset.gp and KB.InstaReset.gp.Name},
        tpBatFloatingPos = tpBatFloatingPos,
        batV2FloatingPos = batV2FloatingPos,
        instaResetFloatingPos = instaResetFloatingPos,
        bodyLockEnabled = bodyLockEnabled,
        bodyLockRange = bodyLockRange,
        progressBarPos = savedProgressBarPos,
        progressBarScale = progressBarScale,
        lockUI = uiLocked,
        floatingButtonScale = floatingButtonScale,
        outfitIndex = currentOutfitIndex,
        outfitOrder = 2,
        backgroundIndex = backgroundIndex,
        buttonImageIndex = buttonImageIndex,
        buttonImageCustomId = buttonImageCustomId,
        backgroundImageTransparency = backgroundImageTransparency,
        themeColor = currentColorTheme,
        autoStealVariant = autoStealVariant,
        autoStealSemiRadius = autoStealSemiRadius,
        autoStealSemiNormalPct = autoStealSemiNormalPct,
        autoCarry = AutoCarry.enabled,
        autoCarryMode = AutoCarry.mode,
    }
    if pbFrame then
        config.progressBarPos = {
            XScale = pbFrame.Position.X.Scale,
            XOffset = pbFrame.Position.X.Offset,
            YScale = pbFrame.Position.Y.Scale,
            YOffset = pbFrame.Position.Y.Offset
        }
    end
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        config.mobilePanelPos = {
            XScale = container.Position.X.Scale,
            XOffset = container.Position.X.Offset,
            YScale = container.Position.Y.Scale,
            YOffset = container.Position.Y.Offset
        }
    end
    return config
end

function saveAllSettings()
    if _isResetting then return true end
    if _isLoading or not _configReady then return true end
    local config = buildConfigTable()
    local json = HS:JSONEncode(config)
    if json == _lastSavedJSON then return true end
    local success, err = pcall(function() writefile(CONFIG_FILE, json) end)
    if success then _lastSavedJSON = json end
    return success
end

function loadAllSettings()
    if not isfile or not isfile(CONFIG_FILE) then return false end
    local success, data = pcall(function() return HS:JSONDecode(readfile(CONFIG_FILE)) end)
    if not success or not data then return false end
    _isLoading = true
    NS = data.normalSpeed or NS
    CS = data.carrySpeed or CS
    LAGGER_SPEED = data.laggerSpeed1 or LAGGER_SPEED
    LAGGER_CARRY_SPEED = data.laggerSpeed2 or LAGGER_CARRY_SPEED
    CONFIG.STEAL_RANGE = data.stealRadius or CONFIG.STEAL_RANGE
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if data.lockUI ~= nil then uiLocked = data.lockUI == true end
    if data.antiRagdollMode then
        antiRagdollMode = data.antiRagdollMode
    else
        antiRagdollMode = data.antiRagdoll and "v2" or "off"
    end
    antiDieEnabled = true
    antiFlingEnabled = data.antiFlingEnabled or false
    CONFIG.AUTO_STEAL_ENABLED = data.autoSteal or false
    medusaCounterEnabled = data.medusaCounter or false
    batCounterEnabled = data.batCounter or false
    unwalkEnabled = data.unwalk or false
    antiLagEnabled = data.antiLag or false
    laggerToggled = data.laggerToggled or false
    speedMode = data.carryMode or false
    laggerCarryToggled = data.laggerCarryToggled or false
    AutoCarry.mode = (data.autoCarryMode == "ON STEAL") and "ON STEAL" or "WHEN NEAR"
    AutoCarry.setEnabled(data.autoCarry == true)

    uiScaleValue = data.uiScale or 78
    if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
    progressBarScale = tonumber(data.progressBarScale) or 1
    if progressBarScale > 2 or progressBarScale < 0.5 then progressBarScale = 1 end
    if pbScale then pbScale.Scale = progressBarScale end
    if pbFrame then task.defer(clampProgressBar) end
    espEnabled = data.espEnabled or false
    if espEnabled then toggleESP(true) else toggleESP(false) end
    currentColorTheme = "Gray"
    selectedColor = COLOR_THEMES["Gray"]

    _G.AceAntiBypassLoadFromConfig(data)
    autoBatV2Enabled = _G.AceAntiBypassAimbotOn == true
    if autoBatV2Enabled then
        task.defer(function()
            enableBatV2()
            if autoBatV2SetVisual then autoBatV2SetVisual(true) end
        end)
    else
        if autoBatV2SetVisual then autoBatV2SetVisual(false) end
    end

MeridianHubAutoTPDown = (data.meridianHubAutoTPDown or data.cleanHubAutoTPDown) == true
    MeridianHubAutoTPDownHeight = math.clamp(tonumber(data.meridianHubAutoTPDownHeight or data.cleanHubAutoTPDownHeight) or MeridianHubAutoTPDownHeight, 0, 500)
    MeridianHubShowE01Warning = (data.meridianHubShowE01Warning or data.cleanHubShowE01Warning) == true
    if MeridianHubAutoTPDownSetVisual then MeridianHubAutoTPDownSetVisual(MeridianHubAutoTPDown) end
    if MeridianHubShowE01WarningSetVisual then MeridianHubShowE01WarningSetVisual(MeridianHubShowE01Warning) end
    tpBatVersion = (tonumber(data.tpBatVersion) == 2) and 2 or 1
    tpBatSpin = math.clamp(math.floor(tonumber(data.tpBatSpin) or 40), 10, 80)
    _G.__tpBatV2Distance = 8
    if tpBatRefreshUI then tpBatRefreshUI() end

    infJumpEnabled      = data.holdJumpEnabled == true
    infJumpMode         = "HOLD"
    mirrorTPDownEnabled = data.mirrorTPDown == true
    antiKickEnabled     = true  -- Safe Mode: always on, ignores saved value

    noCamCollisionEnabled    = data.noCamCollision == true
    if noCamCollisionEnabled then
        enableNoCamCollision()
    end
    if setNoCamCollisionVisual then
        setNoCamCollisionVisual(noCamCollisionEnabled)
    end

    local tpBatStateLoaded = data.tpBatEnabled or false
    if tpBatStateLoaded then
        task.defer(function()
            startBatDesyncTp()
            if batDesyncTpSetVisual then batDesyncTpSetVisual(true) end
        end)
    else
        if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
    end
    skyTheme = data.skyTheme or "Off"
    if skyTheme ~= "Off" then pcall(applyCustomSky, skyTheme) end
    if skySelectorLabel then skySelectorLabel.Text = skyTheme end
    neonWeatherEnabled = data.neonWeather or false
    if neonWeatherEnabled then
        task.defer(function() toggleNeonWeather(true) end)
    else
        toggleNeonWeather(false)
        skyTheme = "Off"
        pcall(applyCustomSky, "Off")
        if skySelectorLabel then skySelectorLabel.Text = "Off" end
    end
    if data.animPack and ANIM_PACKS[data.animPack] then
        startAnimPack(data.animPack)
    else
        currentAnimPack = "Off"
        stopAnimPack()
    end
    local function lk(e, d)
        if not d then return end
        if d.kb and Enum.KeyCode[d.kb] then e.kb = Enum.KeyCode[d.kb] end
        if d.gp and Enum.KeyCode[d.gp] then e.gp = Enum.KeyCode[d.gp] end
    end
    lk(KB.DropBrainrot, data.dropBrainrotKey)
    lk(KB.AutoLeft, data.autoLeftKey)
    lk(KB.AutoRight, data.autoRightKey)
    lk(KB.AutoBat, data.autoBatKey)
    lk(KB.TPFloor, data.tpFloorKey)
    lk(KB.CarryToggle, data.carryToggleKey)
    lk(KB.LaggerMode, data.laggerModeKey)
    lk(KB.TPBat, data.tpBatKey)
    lk(KB.BatV2, data.batV2Key)
    lk(KB.InstaReset, data.instaResetKey)
    if (data.floatLayout or "classic") == currentFloatLayoutName() then
        if data.mobileButtonPositions then savedButtonPositions = data.mobileButtonPositions end
        if data.mobilePanelPos then savedMobilePanelPos = data.mobilePanelPos end
        if data.tpBatFloatingPos then tpBatFloatingPos = data.tpBatFloatingPos end
        if data.batV2FloatingPos then batV2FloatingPos = data.batV2FloatingPos end
        if data.instaResetFloatingPos then instaResetFloatingPos = data.instaResetFloatingPos end
    end
    if data.progressBarPos then savedProgressBarPos = data.progressBarPos end
    if data.bodyLockEnabled ~= nil then
        bodyLockEnabled = data.bodyLockEnabled
        if bodyLockEnabled then
            task.defer(function()
                if bodyLockSetVisual then bodyLockSetVisual(true) end
                startBodyLock()
            end)
        end
    end
    if data.bodyLockRange then
        bodyLockRange = data.bodyLockRange
        if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
    end
    dropMode = data.dropMode or 1
    stretchEnabled = data.stretchEnabled or false
    fovValue = data.fovValue or 70
    fovEnabled = data.fovEnabled or false
    if fovSliderSet then fovSliderSet(fovValue) end
    if fovEnabled then enableCustomFov() end
    if setFovVisual then setFovVisual(fovEnabled) end
    stretchFOV = data.stretchFOV or 120
    BAT_AIMBOT_SPEED = data.batAimbotSpeed or BAT_AIMBOT_SPEED
    floatingButtonScale = tonumber(data.floatingButtonScale) or 1
    if floatingButtonScale > 2 or floatingButtonScale < 0.5 then floatingButtonScale = 1 end
    pcall(applyFloatingButtonScale)
    if floatScaleBox then floatScaleBox.Text = tostring(_floor(floatingButtonScale * 100 + 0.5)) end
    if pbScaleBox then pbScaleBox.Text = tostring(_floor(progressBarScale * 100 + 0.5)) end
    local savedOutfit = tonumber(data.outfitIndex)
    if savedOutfit and data.outfitOrder ~= 2 then
        -- old list had no Off entry up front: old 1-5 -> 2-6, old 6 (the "no outfit" slot) -> 1, 7-10 unchanged
        savedOutfit = ({ [1] = 2, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 1, [7] = 7, [8] = 8, [9] = 9, [10] = 10 })[savedOutfit]
    end
    if savedOutfit and savedOutfit >= 1 and savedOutfit <= #OUTFITS then
        currentOutfitIndex = savedOutfit
        task.defer(function()
            pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
            if outfitSelectorLabel then
                outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label
            end
        end)
    end

    if data.backgroundIndex then
        backgroundIndex = _clamp(data.backgroundIndex, 1, #BACKGROUND_IMAGES)
    end
    if data.backgroundImageTransparency ~= nil then
        backgroundImageTransparency = _clamp(data.backgroundImageTransparency, 0, 1)
    end
    if data.buttonImageIndex then
        buttonImageIndex = _floor(tonumber(data.buttonImageIndex) or 1)
        if buttonImageIndex < 1 or buttonImageIndex > #BUTTON_IMAGE_OPTIONS then buttonImageIndex = 1 end
    end
    if type(data.buttonImageCustomId) == "string" then
        buttonImageCustomId = data.buttonImageCustomId
    end

    autoStealVariant = _clamp(tonumber(data.autoStealVariant) or 2, 2, 3)
    autoStealSemiRadius = _clamp(_floor((tonumber(data.autoStealSemiRadius) or 10) + 0.5), 1, 50)
    autoStealSemiNormalPct = _clamp(_floor(((tonumber(data.autoStealSemiNormalPct) or 75) / 5) + 0.5) * 5, 70, 95)
    if refreshStealModeRows then refreshStealModeRows() end
    if autoStealVariantLabel then
        autoStealVariantLabel.Text = autoStealVariantName(autoStealVariant)
    end

    autoBatEnabled = false
    autoLeftEnabled = false
    autoRightEnabled = false
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    refreshSpeedModeLabel()

    if unwalkEnabled then
        task.defer(function()
            startUnwalk()
            if setUnwalkVisual then setUnwalkVisual(true) end
        end)
    else
        if setUnwalkVisual then setUnwalkVisual(false) end
    end

    _lastSavedJSON = HS:JSONEncode(buildConfigTable())
    _isLoading = false
    return true
end

function forceResetUI()
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_CARRY_SPEED) end
    if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end
    if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
    if floatScaleBox then floatScaleBox.Text = tostring(_floor(floatingButtonScale * 100 + 0.5)) end
    if pbScaleBox then pbScaleBox.Text = tostring(_floor(progressBarScale * 100 + 0.5)) end
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
    AutoCarry.syncUI()
    local function safeSet(fn, val) if fn then fn(val) end end
    safeSet(autoBatSetVisual, false)
    safeSet(autoLeftSetVisual, false)
    safeSet(autoRightSetVisual, false)
    safeSet(setBatCounterVisual, false)
    safeSet(setMedusaVisual, false)
    safeSet(setUnwalkVisual, false)
    safeSet(setAntiLagVisual, false)
    safeSet(setLockUIVisual, false)
    safeSet(setInstaGrab, false)
    safeSet(batDesyncTpSetVisual, false)
    safeSet(setESPVIsual, false)
    safeSet(bodyLockSetVisual, false)
    safeSet(setNeonWeatherVisual, false)
    safeSet(autoBatV2SetVisual, false)
    safeSet(setAntiDieVisual, false)
    safeSet(mirrorTPDownSetVisual, false)
    safeSet(infJumpSetVisual, false)
    safeSet(infJumpModeSetVisual, nil)
    noCamCollisionEnabled = false
    disableNoCamCollision()
    safeSet(setNoCamCollisionVisual, false)
    if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
    safeSet(mobSetAutoBat, false)
    safeSet(mobSetAutoLeft, false)
    safeSet(mobSetAutoRight, false)
    safeSet(mobSetDropBR, false)
    safeSet(mobSetTpDown, false)
    safeSet(mobSetCarry, false)
    safeSet(mobSetLagger1, false)
    safeSet(mobSetLagger2, false)
    autoStealVariant = 2
    autoStealSemiRadius = 10
    autoStealSemiNormalPct = 75
    if autoStealVariantLabel then autoStealVariantLabel.Text = autoStealVariantName(2) end
    if refreshStealModeRows then refreshStealModeRows() end
    tpBatVersion = 1
    tpBatSpin = 40
    if tpBatRefreshUI then tpBatRefreshUI() end
    _G.__tpBatV2Distance = 8
    refreshSpeedModeLabel()
    updateProgressBarVisibility()
    disableAntiLag()
    toggleNeonWeather(false)
    skyTheme = "Off"
    pcall(applyCustomSky, "Off")
    if skySelectorLabel then skySelectorLabel.Text = "Off" end
    disableBatV2()
    antiDieEnabled = true
    if antiFlingEnabled then
        AntiFlingShieldModule.stop()
        antiFlingEnabled = false
    end
    for _, ref in ipairs(keyButtonRefs) do
        local entry = ref.entry
        local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
        ref.btn.Text = label
    end
    currentColorTheme = "Gray"
    selectedColor = COLOR_THEMES["Gray"]
    updateAllUIThemeColors(selectedColor)
    backgroundIndex = 1
    buttonImageIndex = 1
    buttonImageCustomId = ""
    pcall(buttonImageApplyAll)
    if _G.updateButtonImageUI then pcall(_G.updateButtonImageUI) end
    if backgroundImage then
        applyBackground(1)
    end
    if contentPages and contentPages["Visual"] then
        local vPage = contentPages["Visual"]
        for _, child in ipairs(vPage:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("BackgroundPreview") then
                local previewImage = child.BackgroundPreview:FindFirstChild("PreviewImage")
                local previewPlaceholder = child.BackgroundPreview:FindFirstChild("PreviewPlaceholder")
                if previewImage then previewImage.Image = "" end
                if previewPlaceholder then previewPlaceholder.Visible = true end
                break
            end
        end
    end
    if miniBtn then miniBtn.TextColor3 = Color3.fromRGB(210, 210, 220) end
    local pGui = LP:FindFirstChild("PlayerGui")
    if pGui then
        local bb = pGui:FindFirstChild("RagCountdownBillboard")
        if bb then
            local lbl = bb:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end
    end
    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        if container then
            local btnContainer = container:FindFirstChild("ButtonsContainer")
            if btnContainer then
                for _, btn in ipairs(btnContainer:GetChildren()) do
                    if btn:IsA("TextButton") then
                        local label = btn:FindFirstChildOfClass("TextLabel")
                        if label then
                            local isActive = btn.BackgroundColor3 == selectedColor
                            if not isActive then label.TextColor3 = selectedColor end
                        end
                    end
                end
            end
        end
    end
    saveAllSettings()
end

function resetFloatingPositions()
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        container.Position = getFloatingLayout().containerPos
        savedButtonPositions = {}
        if container:FindFirstChild("ButtonsContainer") then
            for _, btn in ipairs(container.ButtonsContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn.Name then
                    local defX, defY = getDefaultButtonPosition(btn.Name)
                    btn.Position = UDim2.new(0, defX, 0, defY)
                end
            end
        end
    end
    if tpBatFloatingButton and tpBatFloatingButton:FindFirstChild("Frame") then
        local btnFrame = tpBatFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = getFloatingLayout().tpBat
        tpBatFloatingPos = nil
    end
    if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then
        instaResetFloatingButton.Frame.Position = getFloatingLayout().insta
        instaResetFloatingPos = nil
    end
    if pbFrame then
        pbFrame.Position = UDim2.new(0.5, -125, 1, -60)
        savedProgressBarPos = nil
    end
    savedMobilePanelPos = nil
    tpBatFloatingPos = nil
    batV2FloatingPos = nil
end

function resetToFactoryDefaults()
    _isResetting = true
    local ok, err = pcall(function()
        stopAllBackgroundTasks()
        stopAutoSteal()
        stopBatCounter()
            stopMedusaCounter()
        if AntiRagdollV1.isRunning() then AntiRagdollV1.stop() end
        if AntiRagdollV2.Enabled then stopAntiRagdollV2() end
        if antiFlingEnabled then AntiFlingShieldModule.stop() end
        stopUnwalk()
        disableAutoBat()
        if batDesyncTpEnabled then stopBatDesyncTp() end
        disableBatV2()
        stopBodyLock()
        if espEnabled then toggleESP(false) end
        if stretchEnabled then disableStretch() end
        if antiLagEnabled then disableAntiLag() end
        if dropActive then stopDropBrainrot() end
        toggleNeonWeather(false)
        skyTheme = "Off"
        pcall(applyCustomSky, "Off")
        if skySelectorLabel then skySelectorLabel.Text = "Off" end
        antiDieEnabled = true
        if antiFlingEnabled then
            AntiFlingShieldModule.stop()
            antiFlingEnabled = false
        end
        noCamCollisionEnabled = false
        disableNoCamCollision()
        if setNoCamCollisionVisual then setNoCamCollisionVisual(false) end
        NS = 60
        CS = 29
        LAGGER_SPEED = 15
        LAGGER_CARRY_SPEED = 24.5
        CONFIG.STEAL_RANGE = 61
        speedMode = false
        laggerToggled = false
        laggerCarryToggled = false
        antiRagdollMode = "off"
        antiDieEnabled = true
        antiFlingEnabled = false
        medusaCounterEnabled = false
        batCounterEnabled = false
        autoBatEnabled = false
        autoLeftEnabled = false
        autoRightEnabled = false
        unwalkEnabled = false
        antiLagEnabled = false
        uiLocked = true
        if _G.MeridianRefreshLockIcon then pcall(_G.MeridianRefreshLockIcon) end
        CONFIG.AUTO_STEAL_ENABLED = false
        autoStealVariant = 2
        autoStealSemiRadius = 10
        autoStealSemiNormalPct = 75
        BAT_AIMBOT_SPEED = 58
        dropMode = 1
        stretchEnabled = false
        stretchFOV = 120
        fovValue = 70
        disableCustomFov()
        if fovSliderSet then fovSliderSet(70) end
        if setFovVisual then setFovVisual(false) end
        uiScaleValue = 78
        if mainUIScale then mainUIScale.Scale = 1 end
        progressBarScale = 1
        if pbScale then pbScale.Scale = progressBarScale end
        espEnabled = false
        bodyLockEnabled = false
        bodyLockRange = 20
        autoBatV2Enabled = false
        floatingButtonScale = 1
        if batDesyncTpEnabled then stopBatDesyncTp() end
        tpBatVersion = 1
        tpBatSpin = 40
        if tpBatRefreshUI then tpBatRefreshUI() end
        _G.__tpBatV2Distance = 8
        currentAnimPack = "Off"
        stopAnimPack()
        currentOutfitIndex = 2
        currentColorTheme = "Gray"
        selectedColor = COLOR_THEMES["Gray"]
        backgroundIndex = 1
        backgroundImageTransparency = 0.35
        buttonImageIndex = 1
        buttonImageCustomId = ""
        pcall(buttonImageApplyAll)
        if _G.updateButtonImageUI then pcall(_G.updateButtonImageUI) end
        applyBackground(1)
        for key, val in pairs(DEFAULT_KB) do
            if KB[key] then
                KB[key].kb = val.kb
                KB[key].gp = val.gp
            end
        end
        AutoCarry.setEnabled(false)
        AutoCarry.mode = "WHEN NEAR"
        AutoCarry.syncUI()
        infJumpEnabled      = false
        infJumpMode         = "HOLD"
        mirrorTPDownEnabled = false
        antiKickEnabled     = true  -- Safe Mode: always on
        pcall(applyFloatingButtonScale)
        if floatScaleBox then floatScaleBox.Text = tostring(_floor(floatingButtonScale * 100 + 0.5)) end
        if pbScaleBox then pbScaleBox.Text = tostring(_floor(progressBarScale * 100 + 0.5)) end
        if isfile and isfile(CONFIG_FILE) then
            pcall(delfile, CONFIG_FILE)
        end
        resetFloatingPositions()
        forceResetUI()
        updateProgressBarVisibility()
        refreshSpeedModeLabel()
        _lastSavedJSON = nil
        saveAllSettings()
    end)
    _isResetting = false
    if not ok then warn("[resetToFactoryDefaults]", err) end
    return ok
end

function updateProgressBarVisibility()
    if pbFrame then pbFrame.Visible = true end
end


function isMobileFloatingLayout()
    if not UIS.TouchEnabled then return false end
    local cam = workspace.CurrentCamera
    local vh = cam and cam.ViewportSize.Y or 0
    return vh <= 1 or vh < 520
end

function currentFloatLayoutName()
    return isMobileFloatingLayout() and "m4" or "classic"
end

-- one source of truth for default floating-button spots; phones get a compact 4x3 block in the top-right that clears the jump button
function getFloatingLayout()
    if isMobileFloatingLayout() then
        local s = tonumber(floatingButtonScale) or 1
        local pitch = 68 * s
        local left = -(60 * s + pitch * 3 + 12)
        local top = 8
        return {
            mobile = true,
            panelW = 60 + 68 * 3,
            panelH = 60 + 68,
            containerPos = UDim2.new(1, left, 0, top),
            tpBat = UDim2.new(1, left, 0, top + pitch * 2),
            insta = UDim2.new(1, left + pitch, 0, top + pitch * 2),
        }
    end
    return {
        mobile = false,
        containerPos = UDim2.new(1, -144, 0, 70),
        tpBat = UDim2.new(1, -144, 0, 376),
        insta = UDim2.new(1, -212, 0, 376),
    }
end

function getDefaultButtonPosition(btnName)
    local BTN_W, BTN_H = 60, 60
    local GAP = 8
    local orderMap = {
        DropBR = 0, AutoLeft = 1, AutoBat = 2, AutoRight = 3,
        TpDown = 4, Carry = 5, Lagger1 = 6, Lagger2 = 7
    }
    local order = orderMap[btnName] or 0
    if isMobileFloatingLayout() then
        return (order % 4) * (BTN_W + GAP), _floor(order / 4) * (BTN_H + GAP)
    end
    local row = _floor(order / 2)
    local col = order % 2
    return col * (BTN_W + GAP), row * (BTN_H + GAP + 10)
end

do

    if not _G.InstaResetLoaded then
        _G.InstaResetLoaded = true

        local RunService      = game:GetService("RunService")
        local CAM_BIND        = "MeridianInstaResetCam"
        local FLING_TIME      = 0.4
        local FLING_POWER     = 50000
        local USE_VOID        = true
        local VOID_TIME       = 0.6
        local TIMEOUT         = 6
        local resetting       = false

        local function hide_locally(obj)
            if obj:IsA("BasePart") or obj:IsA("Decal") then
                obj.LocalTransparencyModifier = 1
            end
        end

        local function instaReset()
            if resetting then return end
            local char = LP.Character
            if not char or not char.Parent then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local hrp = hum.RootPart or char:FindFirstChild("HumanoidRootPart")
            resetting = true

            task.spawn(function()
                local cam = workspace.CurrentCamera
                local frozen = cam.CFrame
                local old_type = cam.CameraType
                pcall(function()
                    cam.CameraType = Enum.CameraType.Scriptable
                    RunService:BindToRenderStep(CAM_BIND, Enum.RenderPriority.Camera.Value + 1, function()
                        cam.CFrame = frozen
                    end)
                end)

                local added
                pcall(function()
                    for _, obj in ipairs(char:GetDescendants()) do pcall(hide_locally, obj) end
                    added = char.DescendantAdded:Connect(function(obj) pcall(hide_locally, obj) end)
                end)

                local new_char
                local respawned = LP.CharacterAdded:Connect(function(c) new_char = c end)

                local function unlock()
                    pcall(function() hum.PlatformStand = false end)
                    pcall(function() hum.Sit = false end)
                    pcall(function() hum.AutoRotate = true end)
                end
                unlock()

                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        pcall(function() obj.Anchored = false end)
                        pcall(function() obj.CanCollide = false end)
                    elseif obj.Name == "SeatWeld" then
                        pcall(function() obj:Destroy() end)
                    end
                end

                local started = os.clock()
                local function alive_hrp()
                    if hrp and hrp.Parent then return hrp end
                    hrp = hum.RootPart or char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Parent then return hrp end
                    return nil
                end

                local fling_until = os.clock() + FLING_TIME
                while not new_char and os.clock() < fling_until and hum.Parent do
                    unlock()
                    pcall(function() hum.HipHeight = 1e30 end)
                    local root = alive_hrp()
                    if root then
                        pcall(function() root.Anchored = false end)
                        pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, FLING_POWER, 0) end)
                        pcall(function() root.Velocity = Vector3.new(0, FLING_POWER, 0) end)
                    end
                    RunService.Heartbeat:Wait()
                end

                if USE_VOID and not new_char then
                    local floor = -500
                    pcall(function() floor = workspace.FallenPartsDestroyHeight end)
                    local void_until = os.clock() + VOID_TIME
                    while not new_char and os.clock() < void_until do
                        local root = alive_hrp()
                        if not root then break end
                        pcall(function() root.CFrame = CFrame.new(0, floor - 500, 0) end)
                        pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, -FLING_POWER, 0) end)
                        RunService.Heartbeat:Wait()
                    end
                end

                while not new_char and os.clock() - started < TIMEOUT do
                    if hum.Parent then
                        pcall(function() hum.Health = 0 end)
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                    end
                    if char.Parent then pcall(function() char:BreakJoints() end) end
                    task.wait(0.1)
                end

                pcall(function() respawned:Disconnect() end)
                if added then pcall(function() added:Disconnect() end) end
                pcall(function() RunService:UnbindFromRenderStep(CAM_BIND) end)
                pcall(function()
                    cam.CameraType = old_type == Enum.CameraType.Scriptable and Enum.CameraType.Custom or old_type
                    if new_char then
                        local new_hum = new_char:FindFirstChildOfClass("Humanoid")
                            or new_char:WaitForChild("Humanoid", 5)
                        if new_hum then cam.CameraSubject = new_hum end
                    end
                end)
                resetting = false
            end)
        end

        _G.InstaReset = { Trigger = instaReset }
    end
end

function buildGui()
    local SILVER_DARK = Color3.fromRGB(170, 170, 180)
    local ROW_BG = Color3.fromRGB(10,10,10)
    local ROW_BORDER = Color3.fromRGB(50,50,50)
    local WHITE = Color3.fromRGB(255,255,255)
    local INP = Color3.fromRGB(15,15,15)
    local TAB_INACT = SILVER_DARK
    local GUI_W, GUI_H = 330, 430

    local old = game:GetService("CoreGui"):FindFirstChild("MeridianHub")
    if old then old:Destroy() end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then local o = pg:FindFirstChild("MeridianHub"); if o then o:Destroy() end end

    gui = Instance.new("ScreenGui")
    gui.Name = "MeridianHub"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local guiOk = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not guiOk then gui.Parent = LP:WaitForChild("PlayerGui") end

    main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
    main.Position = UDim2.new(0, 20, 0, 2)
    main.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    main.BackgroundTransparency = 0
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

    backgroundImage = Instance.new("ImageLabel", main)
    backgroundImage.Name = "BackgroundImage"
    backgroundImage.Size = UDim2.new(1, 0, 1, 0)
    backgroundImage.Position = UDim2.new(0, 0, 0, 0)
    backgroundImage.BackgroundTransparency = 1
    backgroundImage.BorderSizePixel = 0
    backgroundImage.Image = ""
    backgroundImage.ScaleType = Enum.ScaleType.Stretch
    backgroundImage.ImageTransparency = 1
    backgroundImage.ZIndex = 1
    Instance.new("UICorner", backgroundImage).CornerRadius = UDim.new(0, 18)

    mainUIScale = Instance.new("UIScale", main)
    mainUIScale.Scale = uiScaleValue / 100

    local titleFrame = Instance.new("Frame", main)
    titleFrame.Name = "TitleFrame"
    titleFrame.Size = UDim2.new(1, -24, 0, 116)
    titleFrame.Position = UDim2.new(0, 12, 0, 6)
    titleFrame.BackgroundTransparency = 1
    titleFrame.ZIndex = 20

    local titleImage = Instance.new("ImageLabel", titleFrame)
    titleImage.Name = "TitleImage"
    titleImage.AnchorPoint = Vector2.new(0.5, 0.5)
    titleImage.Size = UDim2.new(0.9, 0, 0.67, 0)
    titleImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    titleImage.BackgroundTransparency = 1
    titleImage.Image = "rbxassetid://108618808419193"
    titleImage.ScaleType = Enum.ScaleType.Fit
    titleImage.ZIndex = 21

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    closeBtn.BackgroundTransparency = 0.6
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "−"
    closeBtn.TextColor3 = WHITE
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 26
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 200
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseEnter:Connect(function()
        TS:Create(closeBtn, TweenInfo.new(0.12), {TextColor3 = WHITE, BackgroundColor3 = getThemeColor()}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TS:Create(closeBtn, TweenInfo.new(0.12), {TextColor3 = WHITE, BackgroundColor3 = Color3.fromRGB(30,30,35)}):Play()
    end)

    local lockBtn = Instance.new("TextButton", main)
    lockBtn.Name = "LockShortcut"
    lockBtn.Size = UDim2.new(0, 32, 0, 32)
    lockBtn.Position = UDim2.new(1, -42, 0, 44)
    lockBtn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    lockBtn.BackgroundTransparency = 0.6
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = uiLocked and "\u{1F510}" or "\u{1F513}"
    lockBtn.TextColor3 = WHITE
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 18
    lockBtn.AutoButtonColor = false
    lockBtn.ZIndex = 200
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 8)
    _G.MeridianRefreshLockIcon = function()
        lockBtn.Text = uiLocked and "\u{1F510}" or "\u{1F513}"
    end
    lockBtn.MouseButton1Click:Connect(function()
        toggleLockUI()
    end)
    lockBtn.MouseEnter:Connect(function()
        TS:Create(lockBtn, TweenInfo.new(0.12), {BackgroundColor3 = getThemeColor()}):Play()
    end)
    lockBtn.MouseLeave:Connect(function()
        TS:Create(lockBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,30,35)}):Play()
    end)

    miniBtn = Instance.new("TextButton", gui)
    miniBtn.Size = UDim2.new(0, 112, 0, 30)
    miniBtn.Position = UDim2.new(0, 16, 0, 64) -- default: right under the Roblox menu opener, PC and mobile (never saved)
    miniBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    miniBtn.BackgroundTransparency = 0
    miniBtn.BorderSizePixel = 0
    miniBtn.ClipsDescendants = true
    miniBtn.Text = ""
    miniBtn.TextColor3 = Color3.fromRGB(210, 210, 220)
    miniBtn.Font = Enum.Font.SciFi
    miniBtn.TextSize = 16
    miniBtn.ZIndex = 20
    miniBtn.Visible = false
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1, 0)

    local miniTitleImage = Instance.new("ImageLabel", miniBtn)
    miniTitleImage.Name = "MiniTitleImage"
    miniTitleImage.AnchorPoint = Vector2.new(0.5, 0.5)
    miniTitleImage.Size = UDim2.new(0.92, 0, 0.8, 0)
    miniTitleImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    miniTitleImage.BackgroundTransparency = 1
    miniTitleImage.Image = "rbxassetid://108618808419193"
    miniTitleImage.ScaleType = Enum.ScaleType.Fit
    miniTitleImage.ZIndex = 21

    local slideTween = nil
    local mainOriginalPos = main.Position

    showGui = function()
        if slideTween then slideTween:Cancel() end
        if not main then return end
        main.Visible = true
        miniBtn.Visible = false
        main.Position = UDim2.new(0, -GUI_W - 20, 0, 2)
        slideTween = TS:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = mainOriginalPos})
        slideTween:Play()
        slideTween.Completed:Connect(function() slideTween = nil end)
    end

    hideGui = function()
        if slideTween then slideTween:Cancel() end
        if not main or not main.Visible then return end
        local targetPos = UDim2.new(0, -GUI_W - 20, 0, 2)
        slideTween = TS:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
        slideTween:Play()
        slideTween.Completed:Connect(function()
            main.Visible = false
            miniBtn.Visible = true
            slideTween = nil
        end)
    end

    closeBtn.MouseButton1Click:Connect(hideGui)
    do
        local dragging, moved, dragStart, startPos = false, false, nil, nil
        miniBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging, moved, dragStart, startPos = true, false, inp.Position, miniBtn.Position
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dragStart
                if d.Magnitude > 6 then moved = true end
                if moved then
                    local nx, ny = startPos.X.Offset + d.X, startPos.Y.Offset + d.Y
                    local cam = workspace.CurrentCamera
                    if cam then
                        local vp = cam.ViewportSize
                        nx = math.clamp(nx, 0, math.max(0, vp.X - miniBtn.AbsoluteSize.X))
                        ny = math.clamp(ny, 0, math.max(0, vp.Y - miniBtn.AbsoluteSize.Y))
                    end
                    miniBtn.Position = UDim2.new(0, nx, 0, ny)
                end
            end
        end)
        miniBtn.InputEnded:Connect(function(inp)
            if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and dragging then
                dragging = false
                if not moved then showGui() end
            end
        end)
    end

    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(1, -32, 0, 34)
    local tabsDivider = Instance.new("Frame", main)
    tabsDivider.Name = "TabsDivider"
    tabsDivider.Size = UDim2.new(1, -32, 0, 1)
    tabsDivider.Position = UDim2.new(0, 16, 0, 136)
    tabsDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabsDivider.BackgroundTransparency = 0.25
    tabsDivider.BorderSizePixel = 0
    tabsDivider.ZIndex = 11

    tabBar.Position = UDim2.new(0, 16, 0, 98)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 10

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 4)

    local tabContent = Instance.new("Frame", main)
    tabContent.Size = UDim2.new(1, -16, 1, -150)
    tabContent.Position = UDim2.new(0, 8, 0, 142)
    tabContent.BackgroundTransparency = 1
    tabContent.ClipsDescendants = true
    tabContent.ZIndex = 5

    local tabs = {"Speed", "Combat", "Visual", "Settings", "Keybinds"}
    tabButtons = {}
    local contentPages = {}

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0.19, 0, 1, -6)
        btn.BackgroundColor3 = Color3.fromRGB(18,18,22)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = TAB_INACT
        btn.Font = Enum.Font.Oswald
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = ROW_BORDER
        stroke.Thickness = 1
        stroke.Transparency = 1
        btn:SetAttribute("PillStroke", true)

        local page = Instance.new("ScrollingFrame", tabContent)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Position = UDim2.new(0, 0, 0, 0)
        page.BackgroundColor3 = Color3.fromRGB(5,5,5)
        page.BackgroundTransparency = 0.6
        page.BorderSizePixel = 0
        page.ClipsDescendants = true
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(30,30,35)
        page.ScrollBarImageTransparency = 0.3
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ZIndex = 6
        Instance.new("UICorner", page).CornerRadius = UDim.new(0, 16)
        page.Visible = (i == 1)

        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local padding = Instance.new("UIPadding", page)
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 20)

        contentPages[name] = page

        btn.MouseButton1Click:Connect(function()
            for _, pg in pairs(contentPages) do pg.Visible = false end
            page.Visible = true
            for _, b in ipairs(tabButtons) do
                b.TextColor3 = TAB_INACT
                b.BackgroundColor3 = Color3.fromRGB(18,18,22)
                b.BackgroundTransparency = 1
                local st = b:FindFirstChildOfClass("UIStroke")
                if st then st.Transparency = 1 end
            end
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
            btn.BackgroundTransparency = 0.35
            local bst = btn:FindFirstChildOfClass("UIStroke")
            if bst then bst.Transparency = 0 end
        end)

        table.insert(tabButtons, btn)
    end

    if tabButtons[1] then
        tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButtons[1].BackgroundColor3 = Color3.fromRGB(30,30,35)
        tabButtons[1].BackgroundTransparency = 0.35
        local st1 = tabButtons[1]:FindFirstChildOfClass("UIStroke")
        if st1 then st1.Transparency = 0 end
    end

    local pageCounters = {}

    local function getNextOrder(page)
        if not pageCounters[page] then pageCounters[page] = 0 end
        pageCounters[page] = pageCounters[page] + 1
        return pageCounters[page]
    end

    local function mkSect(page, txt)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1, 0, 0, 26)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder = getNextOrder(page)
        f.ZIndex = 7
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -16, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt:upper()
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.Michroma
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Position = UDim2.new(0, 18, 0, 0)
        l.Size = UDim2.new(1, -26, 1, 0)
        local secGrad = Instance.new("UIGradient", l)
        secGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(126, 126, 136)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
        local secBar = Instance.new("Frame", f)
        secBar.Size = UDim2.new(0, 3, 0, 12)
        secBar.Position = UDim2.new(0, 8, 0.5, -8)
        secBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        secBar.BorderSizePixel = 0
        secBar.ZIndex = 8
        l.TextStrokeColor3 = Color3.fromRGB(60,60,60)
        l.TextStrokeTransparency = 1
        l.ZIndex = 8
        local line = Instance.new("Frame", f)
        line.Size = UDim2.new(1, -24, 0, 1.5)
        line.Position = UDim2.new(0, 12, 1, -4)
        line.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
        line.BackgroundTransparency = 0.6
        line.BorderSizePixel = 0
        line.ZIndex = 8
        return f
    end

    local function mkRow(page, h)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1, -4, 0, h or 38)
        f.BackgroundColor3 = ROW_BG
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder = getNextOrder(page)
        f.ZIndex = 7
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local rowStroke = Instance.new("UIStroke", f)
        rowStroke.Color = ROW_BORDER
        rowStroke.Thickness = 1
        rowStroke.Transparency = 1
        return f
    end

    local function mkLabel(row, txt)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.55, 0, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(214, 214, 220)
        l.Font = Enum.Font.Oswald
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        l.TextStrokeTransparency = 1
        l.ZIndex = 8
        return l
    end

    local function mkPill(row, offset)
        local pill = Instance.new("Frame", row)
        pill.Name = "Track"
        pill.Size = UDim2.new(0, 34, 0, 18)
        pill.AnchorPoint = Vector2.new(0.5, 0.5)
        pill.Position = UDim2.new(1, -(offset or 48), 0.5, 0)
        pill.BackgroundColor3 = Color3.fromRGB(255,255,255)
        pill.BackgroundTransparency = 0
        pill.BorderSizePixel = 0
        pill.ZIndex = 8
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 9)
        local stroke = Instance.new("UIStroke", pill)
        stroke.Color = ROW_BORDER
        stroke.Thickness = 1
        stroke.Transparency = 0.45
        stroke.Name = "PillStroke"

        local dot = Instance.new("Frame", pill)
        dot.Name = "Knob"
        dot.Size = UDim2.new(0, 13, 0, 13)
        dot.AnchorPoint = Vector2.new(0, 0)
        dot.Position = UDim2.new(0, 3, 0.5, -6)
        dot.BackgroundColor3 = Color3.fromRGB(18,18,22)
        dot.BorderSizePixel = 0
        dot.ZIndex = 9
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local shine = Instance.new("Frame", dot)
        shine.Name = "Shine"
        shine.Size = UDim2.new(1, -4, 0, 4)
        shine.Position = UDim2.new(0, 2, 0, 2)
        shine.BackgroundColor3 = WHITE
        shine.BackgroundTransparency = 0.72
        shine.BorderSizePixel = 0
        shine.ZIndex = 10
        Instance.new("UICorner", shine).CornerRadius = UDim.new(0, 4)

        return pill, dot
    end

    local function animPill(pill, dot, on)
        local stroke = pill:FindFirstChildOfClass("UIStroke")
        local info = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TS:Create(dot, info, {
            Position = on and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(18,18,22),
        }):Play()
        TS:Create(pill, info, {
            BackgroundColor3 = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255),
            BackgroundTransparency = 0,
        }):Play()
        if stroke then
            TS:Create(stroke, info, {
                Color = on and Color3.fromRGB(255,255,255) or ROW_BORDER,
                Transparency = on and 0.2 or 0.45,
                Thickness = on and 1.5 or 1,
            }):Play()
        end
    end

    local function mkSlider(row, minV, maxV, default, cb)
        local W = 118
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(0, W, 0, 4)
        track.Position = UDim2.new(1, -(W + 44), 0.5, -2)
        track.BackgroundColor3 = INP
        track.BackgroundTransparency = 0.3
        track.BorderSizePixel = 0
        track.ZIndex = 8
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = getThemeColor()
        fill.BorderSizePixel = 0
        fill.ZIndex = 9
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 13, 0, 13)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = WHITE
        knob.BorderSizePixel = 0
        knob.ZIndex = 11
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local kStroke = Instance.new("UIStroke", knob)
        kStroke.Color = getThemeColor()
        kStroke.Thickness = 2

        local valLabel = Instance.new("TextLabel", row)
        valLabel.Size = UDim2.new(0, 34, 0, 20)
        valLabel.Position = UDim2.new(1, -38, 0.5, -10)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = WHITE
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 11
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.ZIndex = 9

        local hit = Instance.new("TextButton", row)
        hit.Size = UDim2.new(0, W + 16, 0, 26)
        hit.Position = UDim2.new(1, -(W + 52), 0.5, -13)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.AutoButtonColor = false
        hit.ZIndex = 12


        local function render(a)
            a = _clamp(a, 0, 1)
            fill.Size = UDim2.new(a, 0, 1, 0)
            knob.Position = UDim2.new(a, 0, 0.5, 0)
            fill.BackgroundColor3 = getThemeColor()
            kStroke.Color = getThemeColor()
        end

        local function applyFromX(px)
            local left = track.AbsolutePosition.X
            local width = track.AbsoluteSize.X
            if width <= 0 then width = W end
            if left <= 0 then return end
            local a = (px - left) / width
            a = _clamp(a, 0, 1)
            local v = _floor(minV + (maxV - minV) * a + 0.5)
            valLabel.Text = tostring(v)
            render(a)
            if cb then pcall(cb, v) end
        end

        local dragging = false

        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                _isDraggingButton = true
                applyFromX(i.Position.X)
            end
        end)

        hit.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                _isDraggingButton = false
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                applyFromX(i.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if not dragging then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                _isDraggingButton = false
            end
        end)

        local function setValue(v)
            v = _clamp(tonumber(v) or minV, minV, maxV)
            valLabel.Text = tostring(v)
            render((v - minV) / (maxV - minV))
        end

        setValue(default)
        return setValue
    end

    local function mkToggle(page, txt, cb)
        local row = mkRow(page, 38)
        mkLabel(row, txt)
        local pill, dot = mkPill(row, 48)
        local on = false
        local function sv(s) on = s; animPill(pill, dot, s) end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1,0,1,0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.AutoButtonColor = false
        clk.ZIndex = 10
        clk.MouseButton1Click:Connect(function()
            on = not on
            sv(on)
            pcall(cb, on)
            pcall(saveAllSettings)
        end)
        return sv
    end

    local function mkBox(parent, default, w, xOff, cb)
        local tb = Instance.new("TextBox", parent)
        local bw = w or 50
        local xo = math.max(xOff or 56, bw + 12)
        tb.Size = UDim2.new(0, bw, 0, 24)
        tb.Position = UDim2.new(1, -xo, 0.5, -12)
        tb.BackgroundColor3 = INP
        tb.BackgroundTransparency = 0.7
        tb.BorderSizePixel = 0
        tb.Text = tostring(default)
        tb.TextColor3 = WHITE
        tb.Font = Enum.Font.GothamBold
        tb.TextSize = 11
        tb.ClearTextOnFocus = false
        tb.ZIndex = 8
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", tb)
        bs.Color = ROW_BORDER
        bs.Thickness = 1.2
        bs.Transparency = 0.25
        tb.Focused:Connect(function() TS:Create(bs, TweenInfo.new(0.12), {Color = getThemeColor(), Transparency = 0}):Play() end)
        tb.FocusLost:Connect(function()
            TS:Create(bs, TweenInfo.new(0.12), {Color = ROW_BORDER, Transparency = 0.25}):Play()
            if cb then local n = tonumber(tb.Text); if n then cb(n) else tb.Text = tostring(default) end end
        end)
        return tb
    end

    local function mkKeyButton(parent, kbEntry)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 80, 0, 24)
        btn.Position = UDim2.new(1, -88, 0.5, -12)
        btn.BackgroundColor3 = INP
        btn.BackgroundTransparency = 0.5
        btn.BorderSizePixel = 0
        local function getLabel() return (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None" end
        btn.Text = getLabel()
        btn.TextColor3 = WHITE
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.ZIndex = 8
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = ROW_BORDER
        bs.Thickness = 1
        local li = false; local lc; local pv = btn.Text; local listenStart = 0
        btn.Activated:Connect(function()
            if li then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end
            pv = btn.Text; li = true; _anyKeyListening = true; listenStart = _tick(); btn.Text = "..."; btn.TextColor3 = WHITE
            lc = UIS.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode == Enum.KeyCode.Escape then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = WHITE; return end
                local isGp = isGamepadInput(inp)
                if isGp and _tick()-listenStart < 0.15 then return end
                if not isBindableInput(inp) then return end
                btn.Text = inp.KeyCode.Name; pv = inp.KeyCode.Name; btn.TextColor3 = WHITE
                li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end
                if isGp then kbEntry.gp = inp.KeyCode; kbEntry.kb = nil else kbEntry.kb = inp.KeyCode; kbEntry.gp = nil end
            end)
        end)
        table.insert(keyButtonRefs, {btn = btn, entry = kbEntry})
        return btn
    end

    -- Wheel picker (names only): swipe / scroll / tap above or below the centre line
    local function mkNeoSelector(parent, defaultText, options, cb)
        -- Every switcher outside the Visual tab = Meridian-style arrow-down switcher:
        --   row:    label + current mode + chevron pill (arrow DOWN)
        --   tap it: a panel rolls DOWN under the row with every mode as a pill side by side
        --           (a lit highlight slides to the picked one) and the arrow flips to UP
        --   tap again: the panel rolls UP and hides
        local page = parent.Parent
        if parent:FindFirstAncestorOfClass("ScrollingFrame") ~= contentPages["Visual"] and page and page:IsA("ScrollingFrame") then
            local PANEL_H, N = 34, #options

            local currentIdx = 1
            for i, opt in ipairs(options) do
                if tostring(opt) == tostring(defaultText) then currentIdx = i; break end
            end

            -- current mode shown on the row so it is readable while the panel is rolled up
            local modeText = Instance.new("TextLabel", parent)
            modeText.Name = "CurrentModeText"
            modeText.Size = UDim2.new(0, 120, 1, 0)
            modeText.Position = UDim2.new(1, -8 - 38 - 6 - 120, 0, 0)
            modeText.BackgroundTransparency = 1
            modeText.Text = tostring(options[currentIdx])
            modeText.TextColor3 = Color3.fromRGB(150, 150, 162)
            modeText.Font = Enum.Font.GothamBold
            modeText.TextSize = 10
            modeText.TextXAlignment = Enum.TextXAlignment.Right
            modeText.TextTruncate = Enum.TextTruncate.AtEnd
            modeText.ZIndex = 8

            -- tween helper that cancels the previous tween on the same property group
            local running = setmetatable({}, { __mode = "k" })
            local function tween(obj, key, t, props)
                local per = running[obj]
                if not per then per = {}; running[obj] = per end
                if per[key] then per[key]:Cancel() end
                local tw = TS:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
                per[key] = tw
                tw:Play()
                return tw
            end

            -- chevron pill (same look as the Meridian arrow button)
            local arrow = Instance.new("TextButton", parent)
            arrow.Name = "ArrowButton"
            arrow.Size = UDim2.new(0, 38, 0, 26)
            arrow.Position = UDim2.new(1, -46, 0.5, -13)
            arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            arrow.BackgroundTransparency = 0.1
            arrow.BorderSizePixel = 0
            arrow.AutoButtonColor = false
            arrow.Text = ""
            arrow.ZIndex = 9
            Instance.new("UICorner", arrow).CornerRadius = UDim.new(1, 0)
            local arrowStroke = Instance.new("UIStroke", arrow)
            arrowStroke.Color = Color3.fromRGB(235, 235, 240)
            arrowStroke.Thickness = 2
            arrowStroke.Transparency = 0.1
            arrowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            local arrowGrad = Instance.new("UIGradient", arrow)
            arrowGrad.Rotation = 90
            arrowGrad.Color = ColorSequence.new(Color3.fromRGB(86, 86, 96), Color3.fromRGB(14, 14, 18))

            local chevron = Instance.new("Frame", arrow)
            chevron.Name = "Chevron"
            chevron.BackgroundTransparency = 1
            chevron.Size = UDim2.fromOffset(20, 24)
            chevron.AnchorPoint = Vector2.new(0.5, 0.5)
            chevron.Position = UDim2.fromScale(0.5, 0.5)
            chevron.ZIndex = 10
            for i = 1, 2 do
                local line = Instance.new("Frame", chevron)
                line.Name = "ChevronLine"
                line.AnchorPoint = Vector2.new(0.5, 0.5)
                line.Size = UDim2.fromOffset(9, 3.5)
                line.Position = UDim2.new(0.5, i == 1 and -3 or 3, 0.5, 0)
                line.Rotation = i == 1 and 35 or -40
                line.BorderSizePixel = 0
                line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                line.ZIndex = 10
                Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
                local lineGrad = Instance.new("UIGradient", line)
                lineGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 165, 175))
            end
            arrow.MouseEnter:Connect(function() tween(arrow, "hover", 0.14, { BackgroundTransparency = 0.3 }) end)
            arrow.MouseLeave:Connect(function() tween(arrow, "hover", 0.14, { BackgroundTransparency = 0.1 }) end)

            -- the roll-down panel: sits directly under the row (same page, next LayoutOrder)
            local panel = Instance.new("Frame", page)
            panel.Name = (parent.Name ~= "" and parent.Name or "Row") .. "_Modes"
            panel.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, 0, 0)
            panel.BackgroundColor3 = ROW_BG
            panel.BackgroundTransparency = 1
            panel.BorderSizePixel = 0
            panel.ClipsDescendants = true
            panel.Visible = false
            panel.LayoutOrder = getNextOrder(page)
            panel.ZIndex = 7
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
            local panelStroke = Instance.new("UIStroke", panel)
            panelStroke.Color = ROW_BORDER
            panelStroke.Thickness = 1
            panelStroke.Transparency = 1

            local light = Instance.new("Frame", panel)
            light.Name = "Highlight"
            light.Size = UDim2.new(1 / N, -6, 0, PANEL_H - 8)
            light.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            light.BackgroundTransparency = 0
            light.BorderSizePixel = 0
            light.ZIndex = 8
            Instance.new("UICorner", light).CornerRadius = UDim.new(0, 8)
            -- dark brushed-metal pill (not plain white): bright top sheen, steel body, near-black bottom
            local lightGrad = Instance.new("UIGradient", light)
            lightGrad.Rotation = 90
            lightGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(138, 140, 152)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(86, 88, 99)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(48, 50, 58)),
                ColorSequenceKeypoint.new(0.82, Color3.fromRGB(30, 31, 37)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(58, 60, 68)),
            })
            local lightStroke = Instance.new("UIStroke", light)
            lightStroke.Color = Color3.fromRGB(190, 192, 204)
            lightStroke.Thickness = 1
            lightStroke.Transparency = 0.35
            lightStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local function lightPos(idx)
                return UDim2.new((idx - 1) / N, 3, 0, 4)
            end
            light.Position = lightPos(currentIdx)

            local pills = {}
            local function paint(animate)
                for idx, b in pairs(pills) do
                    local col = idx == currentIdx and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 162)
                    if animate then
                        tween(b, "color", 0.14, { TextColor3 = col })
                    else
                        b.TextColor3 = col
                    end
                end
                modeText.Text = tostring(options[currentIdx])
            end

            for idx, opt in ipairs(options) do
                local b = Instance.new("TextButton", panel)
                b.Name = "Mode" .. idx
                b.Size = UDim2.new(1 / N, 0, 1, 0)
                b.Position = UDim2.new((idx - 1) / N, 0, 0, 0)
                b.BackgroundTransparency = 1
                b.BorderSizePixel = 0
                b.AutoButtonColor = false
                b.Text = tostring(opt)
                b.Font = Enum.Font.GothamBold
                b.TextSize = 11
                b.TextTruncate = Enum.TextTruncate.AtEnd
                b.ZIndex = 9
                b.Activated:Connect(function()
                    if currentIdx == idx then return end
                    currentIdx = idx
                    tween(light, "slide", 0.14, { Position = lightPos(idx) })
                    paint(true)
                    if cb then pcall(cb, options[currentIdx], currentIdx) end
                end)
                pills[idx] = b
            end
            paint(false)

            local expanded, token = false, 0
            arrow.Activated:Connect(function()
                expanded = not expanded
                token = token + 1
                local mine = token
                tween(chevron, "rotate", 0.18, { Rotation = expanded and 180 or 0 })
                if expanded then panel.Visible = true end
                tween(panel, "roll", 0.18, {
                    Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, 0, expanded and PANEL_H or 0),
                }).Completed:Once(function()
                    if token == mine and not expanded then panel.Visible = false end
                end)
            end)

            local pillProxy = {}
            setmetatable(pillProxy, {
                __index = function(_, k)
                    if k == "Text" then return tostring(options[currentIdx]) end
                    return parent[k]
                end,
                __newindex = function(_, k, v)
                    if k == "Text" then
                        local newText = tostring(v)
                        for i, opt in ipairs(options) do
                            if tostring(opt) == newText then
                                currentIdx = i
                                light.Position = lightPos(i)
                                paint(false)
                                return
                            end
                        end
                    end
                end,
            })
            return pillProxy
        end

        local LINE_H, WHEEL_H = 20, 60
        pcall(function()
            parent.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, 0, math.max(parent.Size.Y.Offset, WHEEL_H + 4))
        end)

        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(0, 175, 0, WHEEL_H)
        container.Position = UDim2.new(1, -183, 0.5, -WHEEL_H / 2)
        container.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        container.BackgroundTransparency = 0.35
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        container.ZIndex = 8
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

        local contStroke = Instance.new("UIStroke", container)
        contStroke.Color = ROW_BORDER
        contStroke.Thickness = 1
        contStroke.Transparency = 0.35

        local band = Instance.new("Frame", container)
        band.Size = UDim2.new(1, -8, 0, LINE_H + 2)
        band.Position = UDim2.new(0, 4, 0.5, -(LINE_H + 2) / 2)
        band.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        band.BackgroundTransparency = 0.9
        band.BorderSizePixel = 0
        band.ZIndex = 9
        Instance.new("UICorner", band).CornerRadius = UDim.new(0, 8)
        local bandStroke = Instance.new("UIStroke", band)
        bandStroke.Color = Color3.fromRGB(220, 220, 230)
        bandStroke.Thickness = 1
        bandStroke.Transparency = 0.45

        local function mkLine(yOff, ts, font, color)
            local l = Instance.new("TextLabel", container)
            l.Size = UDim2.new(1, -16, 0, LINE_H)
            l.Position = UDim2.new(0, 8, 0.5, yOff - LINE_H / 2)
            l.BackgroundTransparency = 1
            l.Text = ""
            l.TextColor3 = color
            l.Font = font
            l.TextSize = ts
            l.TextXAlignment = Enum.TextXAlignment.Center
            l.TextTruncate = Enum.TextTruncate.AtEnd
            l.ZIndex = 10
            return l
        end
        local dim = Color3.fromRGB(135, 135, 148)
        local prevLbl = mkLine(-LINE_H, 10, Enum.Font.GothamMedium, dim)
        local label = mkLine(0, 13, Enum.Font.GothamBold, Color3.fromRGB(255, 255, 255))
        local nextLbl = mkLine(LINE_H, 10, Enum.Font.GothamMedium, dim)
        local baseY = { [prevLbl] = -LINE_H, [label] = 0, [nextLbl] = LINE_H }

        local currentIdx = 1
        for i, opt in ipairs(options) do
            if tostring(opt) == tostring(defaultText) then currentIdx = i; break end
        end

        local function nameAt(i)
            return tostring(options[((i - 1) % #options) + 1])
        end

        local function render(animDir)
            local n = #options
            prevLbl.Text = n >= 3 and nameAt(currentIdx - 1) or ""
            label.Text = nameAt(currentIdx)
            nextLbl.Text = n >= 2 and nameAt(currentIdx + 1) or ""
            if animDir then
                for l, y in pairs(baseY) do
                    l.Position = UDim2.new(0, 8, 0.5, y - LINE_H / 2 + animDir * LINE_H)
                    TS:Create(l, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 8, 0.5, y - LINE_H / 2),
                    }):Play()
                end
            end
        end

        local function step(dir)
            if #options < 2 then return end
            currentIdx = ((currentIdx - 1 + dir) % #options) + 1
            render(dir)
            if cb then pcall(cb, options[currentIdx], currentIdx) end
        end

        local hit = Instance.new("TextButton", container)
        hit.Size = UDim2.new(1, 0, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.AutoButtonColor = false
        hit.ZIndex = 12

        local pageScroll = parent:FindFirstAncestorOfClass("ScrollingFrame")
        local dragging, lastY, acc, moved = false, 0, 0, 0
        local function unlockScroll()
            if pageScroll then pcall(function() pageScroll.ScrollingEnabled = true end) end
        end

        hit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging, lastY, acc, moved = true, inp.Position.Y, 0, 0
                if pageScroll then pcall(function() pageScroll.ScrollingEnabled = false end) end
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                local dy = inp.Position.Y - lastY
                lastY = inp.Position.Y
                moved = moved + math.abs(dy)
                acc = acc + dy
                while acc <= -LINE_H do acc = acc + LINE_H; step(1) end
                while acc >= LINE_H do acc = acc - LINE_H; step(-1) end
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                unlockScroll()
                if moved < 6 then
                    local rel = inp.Position.Y - (container.AbsolutePosition.Y + container.AbsoluteSize.Y / 2)
                    step(rel < -LINE_H / 2 and -1 or 1)
                end
            end
        end)
        container.Destroying:Connect(unlockScroll)
        hit.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseWheel then
                step(inp.Position.Z > 0 and -1 or 1)
            end
        end)

        container.MouseEnter:Connect(function()
            TS:Create(contStroke, TweenInfo.new(0.12), { Color = Color3.fromRGB(220, 220, 230), Transparency = 0 }):Play()
        end)
        container.MouseLeave:Connect(function()
            TS:Create(contStroke, TweenInfo.new(0.12), { Color = ROW_BORDER, Transparency = 0.35 }):Play()
        end)

        render(nil)

        local proxy = {}
        setmetatable(proxy, {
            __index = function(_, k) return label[k] end,
            __newindex = function(_, k, v)
                if k == "Text" then
                    local newText = tostring(v)
                    for i, opt in ipairs(options) do
                        if tostring(opt) == newText then
                            currentIdx = i
                            render(nil)
                            return
                        end
                    end
                    label.Text = newText
                else
                    label[k] = v
                end
            end,
        })
        return proxy
    end

    local function addKeybindRow(page, labelText, kbEntry)
        local row = mkRow(page, 36)
        mkLabel(row, labelText)
        mkKeyButton(row, kbEntry)
    end

    local speedPage = contentPages["Speed"]

    mkSect(speedPage, "Base Speeds")
    -- one row per speed, two editors each (NORM | CARRY) with a header marker above the columns
    do
        local hdr = Instance.new("Frame", speedPage)
        hdr.Size = UDim2.new(1, -4, 0, 14)
        hdr.BackgroundTransparency = 1
        hdr.BorderSizePixel = 0
        hdr.LayoutOrder = getNextOrder(speedPage)
        hdr.ZIndex = 8
        for _, col in ipairs({ { "NORM", 124 }, { "CARRY", 64 } }) do
            local t = Instance.new("TextLabel", hdr)
            t.Size = UDim2.new(0, 52, 1, 0)
            t.Position = UDim2.new(1, -col[2], 0, 0)
            t.BackgroundTransparency = 1
            t.Text = col[1]
            t.TextColor3 = Color3.fromRGB(200, 200, 210)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 9
            t.TextXAlignment = Enum.TextXAlignment.Center
            t.ZIndex = 9
        end
    end
    do local row = mkRow(speedPage, 38); mkLabel(row, "Normal Speed")
        normalBox  = mkBox(row, NS, 52, 124, function(v) if v > 0 and v <= 500 then NS = v end end)
        carryBox   = mkBox(row, CS, 52, 64,  function(v) if v > 0 and v <= 500 then CS = v end end)
    end
    do local row = mkRow(speedPage, 38); mkLabel(row, "Lagger Speed")
        laggerBox  = mkBox(row, LAGGER_SPEED, 52, 124, function(v) if v > 0 and v <= 500 then LAGGER_SPEED = v end end)
        lagger2Box = mkBox(row, LAGGER_CARRY_SPEED, 52, 64, function(v) if v > 0 and v <= 500 then LAGGER_CARRY_SPEED = v end end)
    end

    mkSect(speedPage, "Auto Carry")
    AutoCarry.setVisual = mkToggle(speedPage, "Auto Carry", function(on)
        AutoCarry.setEnabled(on)
        saveAllSettings()
    end)
    do
        local row = mkRow(speedPage, 38)
        mkLabel(row, "Auto Carry Mode")
        AutoCarry.modeLabel = mkNeoSelector(row, AutoCarry.mode, {"WHEN NEAR", "ON STEAL"}, function(sel)
            AutoCarry.mode = sel
            if AutoCarry.enabled then AutoCarry.stop(); AutoCarry.start() end
            saveAllSettings()
        end)
    end
    AutoCarry.syncUI()

    mkSect(speedPage, "Auto Movement")
    autoLeftSetVisual = mkToggle(speedPage, "Auto Left", function(on)
        autoLeftEnabled = on
        if on then startAutoLeft() else stopAutoLeft() end
        if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled or (_G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoLeft")) or false) end
    end)
    autoRightSetVisual = mkToggle(speedPage, "Auto Right", function(on)
        autoRightEnabled = on
        if on then startAutoRight() else stopAutoRight() end
        if mobSetAutoRight then mobSetAutoRight(autoRightEnabled or (_G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoRight")) or false) end
    end)

    mkSect(speedPage, "Teleport")
    do
        local row = mkRow(speedPage, 38)
        mkLabel(row, "TP Down")
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(0.58, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.AutoButtonColor = false
        clk.ZIndex = 8
        clk.MouseButton1Click:Connect(function() doTpDown() end)
        local actLbl = Instance.new("TextLabel", row)
        actLbl.Size = UDim2.new(0, 70, 1, 0)
        actLbl.Position = UDim2.new(1, -78, 0, 0)
        actLbl.BackgroundTransparency = 1
        actLbl.Text = "ACTIVATE"
        actLbl.TextColor3 = Color3.fromRGB(230, 230, 235)
        actLbl.Font = Enum.Font.GothamBold
        actLbl.TextSize = 9
        actLbl.TextXAlignment = Enum.TextXAlignment.Right
        actLbl.ZIndex = 8
    end
    MeridianHubAutoTPDownSetVisual = mkToggle(speedPage, "Auto TP Down", function(on)
        MeridianHubAutoTPDown = on
        saveAllSettings()
    end)
    do
        local row = mkRow(speedPage, 38)
        mkLabel(row, "TP Down Height")
        mkBox(row, MeridianHubAutoTPDownHeight, 50, 56, function(value)
            MeridianHubAutoTPDownHeight = math.clamp(value, 0, 500)
            saveAllSettings()
        end)
    end

    mirrorTPDownSetVisual = mkToggle(speedPage, "Mirror TP Down", function(on)
        _G.MeridianSetMirrorTPDown(on)
    end)

    infJumpSetVisual = mkToggle(speedPage, "Inf Jump", function(on)
        _G.setInfJumpInternal(on)
        saveAllSettings()
    end)

    local combatPage = contentPages["Combat"]

    mkSect(combatPage, "Auto Steal")
    setInstaGrab = mkToggle(combatPage, "Auto Steal", function(on)
        CONFIG.AUTO_STEAL_ENABLED = on
        if on then pcall(startAutoSteal) else stopAutoSteal() end
        updateProgressBarVisibility()
    end)

    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Steal Radius")
        radInput = mkBox(row, CONFIG.STEAL_RANGE, 50, 56, function(v)
            if v and v >= 5 and v <= 300 then
                CONFIG.STEAL_RANGE = _floor(v+0.5)
                Steal.StealRadius = CONFIG.STEAL_RANGE
                radInput.Text = tostring(CONFIG.STEAL_RANGE)
                saveAllSettings()
            end
        end)
    end

    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Semi Radius")
        stealSemiRadiusRow = row
        stealSemiRadiusBox = mkBox(row, autoStealSemiRadius, 50, 56, function(v)
            autoStealSemiRadius = _clamp(_floor(v + 0.5), 1, 50)
            stealSemiRadiusBox.Text = tostring(autoStealSemiRadius)
            saveAllSettings()
        end)
    end

    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Semi Normal Stop %")
        stealSemiPctRow = row
        local function mkStep(txt, xOff, delta)
            local b = Instance.new("TextButton", row)
            b.Size = UDim2.new(0, 28, 0, 24)
            b.Position = UDim2.new(1, xOff, 0.5, -12)
            b.BackgroundColor3 = INP
            b.BackgroundTransparency = 0.7
            b.BorderSizePixel = 0
            b.Text = txt
            b.TextColor3 = WHITE
            b.Font = Enum.Font.GothamBlack
            b.TextSize = 14
            b.AutoButtonColor = false
            b.ZIndex = 8
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            local bs = Instance.new("UIStroke", b)
            bs.Color = ROW_BORDER
            bs.Thickness = 1.2
            bs.Transparency = 0.25
            b.MouseButton1Click:Connect(function()
                autoStealSemiNormalPct = _clamp(autoStealSemiNormalPct + delta, 70, 95)
                stealSemiPctValue.Text = tostring(autoStealSemiNormalPct)
                saveAllSettings()
            end)
        end
        stealSemiPctValue = Instance.new("TextLabel", row)
        stealSemiPctValue.Size = UDim2.new(0, 40, 0, 24)
        stealSemiPctValue.Position = UDim2.new(1, -78, 0.5, -12)
        stealSemiPctValue.BackgroundTransparency = 1
        stealSemiPctValue.Text = tostring(autoStealSemiNormalPct)
        stealSemiPctValue.TextColor3 = WHITE
        stealSemiPctValue.Font = Enum.Font.GothamBold
        stealSemiPctValue.TextSize = 12
        stealSemiPctValue.ZIndex = 8
        mkStep("-", -112, -5)
        mkStep("+", -38, 5)
    end

    refreshStealModeRows = function()
        if stealSemiRadiusRow then stealSemiRadiusRow.Visible = (autoStealVariant == 2) end
        if stealSemiPctRow then stealSemiPctRow.Visible = (autoStealVariant == 3) end
        if stealSemiRadiusBox then stealSemiRadiusBox.Text = tostring(autoStealSemiRadius) end
        if stealSemiPctValue then stealSemiPctValue.Text = tostring(autoStealSemiNormalPct) end
    end
    refreshStealModeRows()

    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Steal Version")
        autoStealVariantLabel = mkNeoSelector(row, autoStealVariantName(autoStealVariant), AUTO_STEAL_VARIANT_NAMES, function(selected)
            autoStealVariant = autoStealVariantFromName(selected)
            if refreshStealModeRows then refreshStealModeRows() end
            saveAllSettings()
        end)
    end

    mkSect(combatPage, "Aimbots")
    autoBatSetVisual = mkToggle(combatPage, "Auto Bat", function(on)
        if on then enableAutoBat() else disableAutoBat() end
        if mobSetAutoBat then mobSetAutoBat(autoBatEnabled or autoBatV2Enabled) end
    end)
    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Aim Mode")
        aimModeLabel = mkNeoSelector(row, aimModeName(), { "Normal", "Bypass" }, function(selected)
            local wasOn = (autoBatEnabled == true) or (autoBatV2Enabled == true)
            if wasOn then disableAutoBat() end
            selectedAimbotMode = (selected == "Bypass") and "Bat Bypass" or "Normal"
            if wasOn then enableAutoBat() end
            saveAllSettings()
        end)
    end
    do local row = mkRow(combatPage, 38); mkLabel(row, "Bat Aimbot Speed"); batSpeedBox = mkBox(row, BAT_AIMBOT_SPEED, 50, 56, function(v) if v > 0 and v <= 200 then BAT_AIMBOT_SPEED = v end end) end

    batDesyncTpSetVisual = mkToggle(combatPage, "TP BAT", function(on)
        if on then
            if not batDesyncTpEnabled then toggleBatDesyncTp() end
        else
            if _G.MeridianSM then _G.MeridianSM.cancel("tpBat") end
            if batDesyncTpEnabled then toggleBatDesyncTp() end
        end
    end)
    if batDesyncTpSetVisual then batDesyncTpSetVisual(batDesyncTpEnabled) end
    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "TP BAT Version")
        tpBatVersionLabel = mkNeoSelector(row, (tpBatVersion == 2) and "V2" or "V1", { "V1", "V2" }, function(selected)
            local wasOn = batDesyncTpEnabled == true
            if wasOn then stopBatDesyncTp() end
            tpBatVersion = (selected == "V2") and 2 or 1
            if tpBatRefreshUI then tpBatRefreshUI() end
            if wasOn then startBatDesyncTp() end
            saveAllSettings()
        end)
    end
    tpBatSpinRow = mkRow(combatPage, 38)
    mkLabel(tpBatSpinRow, "Spin Speed")
    tpBatSpinBox = mkBox(tpBatSpinRow, tpBatSpin, 50, 56, function(v)
        tpBatSpin = math.clamp(math.floor(v), 10, 80)
        if tpBatSpinBox then tpBatSpinBox.Text = tostring(tpBatSpin) end
        saveAllSettings()
    end)
    tpBatRefreshUI = function()
        if tpBatVersionLabel then tpBatVersionLabel.Text = (tpBatVersion == 2) and "V2" or "V1" end
        if tpBatSpinRow then tpBatSpinRow.Visible = (tpBatVersion == 2) end
        if tpBatSpinBox then tpBatSpinBox.Text = tostring(tpBatSpin) end
    end
    tpBatRefreshUI()

    -- Bypass is now a mode of Auto Bat: its visual drives the Auto Bat toggle and the BAT AIMBOT button
    autoBatV2SetVisual = function(on)
        if on or selectedAimbotMode == "Bat Bypass" then
            if autoBatSetVisual then autoBatSetVisual(on) end
            if mobSetAutoBat then mobSetAutoBat(on) end
        end
    end
    _G.AceAimbotSetVisual = autoBatV2SetVisual

    mkSect(combatPage, "Counters")
    setBatCounterVisual = mkToggle(combatPage, "Bat Counter", function(on)
        batCounterEnabled = on
        if on then startBatCounter() else stopBatCounter() end
    end)

    setMedusaVisual = mkToggle(combatPage, "Medusa Counter", function(on)
        medusaCounterEnabled = on
        if on then
            if LP.Character then setupMedusaCounter(LP.Character) else stopMedusaCounter() end
        else
            stopMedusaCounter()
        end
        if setMedusaVisual then setMedusaVisual(on) end
    end)

    mkSect(combatPage, "Defense")
    bodyLockSetVisual = mkToggle(combatPage, "Body Lock", function(on)
        bodyLockEnabled = on
        if on then
            if _blSuppressCount == 0 then startBodyLock() end
        else
            stopBodyLock()
        end
    end)
    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Body Lock Range")
        bodyLockRangeBox = mkBox(row, bodyLockRange, 50, 56, function(v)
            if v and v > 0 then
                bodyLockRange = _clamp(_floor(v), 5, 200)
                if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
            end
        end)
    end

    -- Safe Mode is always on (no toggle). Pill shows once at load.
    antiKickEnabled = true

    mkSect(combatPage, "Survival")
    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Anti Ragdoll")

        local initialLabel = "Off"
        if antiRagdollMode == "v1" then initialLabel = "V1"
        elseif antiRagdollMode == "v2" then initialLabel = "V2" end

        local antiRagdollSelector = mkNeoSelector(row, initialLabel, {"Off", "V1", "V2"}, function(selected)
            local mode = selected:lower()
            setAntiRagdollMode(mode)
        end)

        _G.updateAntiRagdollUI = function(mode)
            local label = "Off"
            if mode == "v1" then label = "V1"
            elseif mode == "v2" then label = "V2" end
            if antiRagdollSelector then antiRagdollSelector.Text = label end
        end

        _G.updateAntiRagdollUI(antiRagdollMode)
    end

    setUnwalkVisual = mkToggle(combatPage, "Unwalk", function(on)
        unwalkEnabled = on
        if on then startUnwalk() else stopUnwalk() end
        saveAllSettings()
    end)

    antiDieEnabled = true
    pcall(AntiDieModule.start)

    mkSect(combatPage, "Drop")
    dropBrainrotSetVisual = mkToggle(combatPage, "Drop Brainrot", function(on)
        if on then
            executeDropWithToggle(function(v)
                dropBrainrotSetVisual(v)
                if mobSetDropBR then mobSetDropBR(v) end
            end)
        end
    end)

    do
        local row = mkRow(combatPage, 38)
        mkLabel(row, "Drop Mode")
        dropModeBtnRef = mkNeoSelector(row, dropMode == 1 and "Fling" or "Jump Drop", {"Fling", "Jump Drop"}, function(sel)
            if dropActive then stopDropBrainrot() end
            dropMode = (sel == "Fling") and 1 or 2
        end)
    end

    local visualPage = contentPages["Visual"]

    mkSect(visualPage, "Interface")
    setLockUIVisual = mkToggle(visualPage, "Lock UI", function(on)
        toggleLockUI(on)
    end)
    do
        local _lockVisualRaw = setLockUIVisual
        setLockUIVisual = function(v)
            _lockVisualRaw(v)
            if _G.MeridianRefreshLockIcon then pcall(_G.MeridianRefreshLockIcon) end
        end
    end

    setESPVIsual = mkToggle(visualPage, "Player ESP", function(on) toggleESP(on) end)

    mkSect(visualPage, "Camera")
    setFovVisual = mkToggle(visualPage, "FOV", function(on)
        if on then enableCustomFov() else disableCustomFov() end
    end)
    if setFovVisual then setFovVisual(fovEnabled) end

    do
        local row = mkRow(visualPage, 38)
        mkLabel(row, "FOV Value")
        fovSliderSet = mkSlider(row, 20, 120, fovValue, function(v)
            fovValue = v
            if not fovEnabled then
                enableCustomFov()
                if setFovVisual then setFovVisual(true) end
            end
            local cam = workspace.CurrentCamera
            if cam then pcall(function() cam.FieldOfView = fovValue end) end
        end)
    end

    setNoCamCollisionVisual = mkToggle(visualPage, "No Cam Collision", function(on)
        if on then
            enableNoCamCollision()
        else
            disableNoCamCollision()
        end
        saveAllSettings()
    end)
    if setNoCamCollisionVisual then setNoCamCollisionVisual(noCamCollisionEnabled) end

    do
        local row = mkRow(visualPage, 38)
        mkLabel(row, "Stretch Rez")
        local stretchPill, stretchDot = mkPill(row, 48)
        local stretchOn = false
        local function setStretch(s)
            stretchOn = s
            animPill(stretchPill, stretchDot, s)
            if s then enableStretch() else disableStretch() end
            stretchEnabled = s
        end
        local stretchClk = Instance.new("TextButton", stretchPill)
        stretchClk.Size = UDim2.new(1,0,1,0)
        stretchClk.BackgroundTransparency = 1
        stretchClk.Text = ""
        stretchClk.AutoButtonColor = false
        stretchClk.ZIndex = 10
        stretchClk.MouseButton1Click:Connect(function() setStretch(not stretchOn) end)
        _G.stretchToggleSetter = setStretch
    end

    mkSect(visualPage, "Performance")
    setAntiLagVisual = mkToggle(visualPage, "Anti Lag", function(on)
        if on then enableAntiLag() else disableAntiLag() end
    end)
    MeridianHubShowE01WarningSetVisual = mkToggle(visualPage, "Show E01 Warning", function(on)
        MeridianHubShowE01Warning = on
        saveAllSettings()
    end)

    mkSect(visualPage, "Environment")
    do
        local row = mkRow(visualPage, 38)
        mkLabel(row, "Sky")
        skySelectorLabel = mkNeoSelector(row, skyTheme, SKY_PRESETS_LIST, function(selected)
            skyTheme = selected
            pcall(applyCustomSky, selected)
            pcall(saveAllSettings)
        end)
    end

    mkSect(visualPage, "Personalization")

    do
        local row = mkRow(visualPage, 38)
        mkLabel(row, "Anim")
        local options = {}
        for _, entry in ipairs(ANIM_PACK_ORDER) do
            table.insert(options, entry[2])
        end
        animSelectorLabel = mkNeoSelector(row, currentAnimPack, options, function(selected)
            if selected == "Off" then
                stopAnimPack()
            else
                startAnimPack(selected)
            end
        end)
    end

    do
        local row = mkRow(visualPage, 38)
        mkLabel(row, "Outfit")
        local options = {}
        for _, o in ipairs(OUTFITS) do table.insert(options, o.label) end
        outfitSelectorLabel = mkNeoSelector(row, OUTFITS[currentOutfitIndex].label, options, function(selected)
            for i, o in ipairs(OUTFITS) do
                if o.label == selected then
                    currentOutfitIndex = i
                    pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
                    saveAllSettings()
                    break
                end
            end
        end)
    end

    do
        local row = mkRow(visualPage, 56)
        mkLabel(row, "BG")

        local previewFrame = Instance.new("Frame", row)
        previewFrame.Name = "BackgroundPreview"
        previewFrame.Size = UDim2.new(0, 56, 0, 44)
        previewFrame.Position = UDim2.new(1, -250, 0.5, -22)
        previewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        previewFrame.BackgroundTransparency = 0.15
        previewFrame.BorderSizePixel = 0
        previewFrame.ClipsDescendants = true
        previewFrame.ZIndex = 8
        Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 8)

        local previewStroke = Instance.new("UIStroke", previewFrame)
        previewStroke.Color = ROW_BORDER
        previewStroke.Thickness = 1.2
        previewStroke.Transparency = 0.35

        local previewImage = Instance.new("ImageLabel", previewFrame)
        previewImage.Name = "PreviewImage"
        previewImage.Size = UDim2.new(1, 0, 1, 0)
        previewImage.Position = UDim2.new(0, 0, 0, 0)
        previewImage.BackgroundTransparency = 1
        previewImage.Image = ""
        previewImage.ScaleType = Enum.ScaleType.Crop
        previewImage.ZIndex = 9
        Instance.new("UICorner", previewImage).CornerRadius = UDim.new(0, 8)

        local previewPlaceholder = Instance.new("TextLabel", previewFrame)
        previewPlaceholder.Name = "PreviewPlaceholder"
        previewPlaceholder.Size = UDim2.new(1, 0, 1, 0)
        previewPlaceholder.BackgroundTransparency = 1
        previewPlaceholder.Text = "OFF"
        previewPlaceholder.TextColor3 = Color3.fromRGB(160, 160, 170)
        previewPlaceholder.Font = Enum.Font.GothamBlack
        previewPlaceholder.TextSize = 12
        previewPlaceholder.ZIndex = 10

        local function updateBackgroundPreview(idx)
            local cfg = BACKGROUND_IMAGES[idx]
            if not cfg or not cfg.id or cfg.id == "" then
                previewImage.Image = ""
                previewPlaceholder.Visible = true
                previewStroke.Color = ROW_BORDER
            else
                previewImage.Image = cfg.id
                previewPlaceholder.Visible = false
                previewStroke.Color = getThemeColor()
            end
        end

        local function animatePreview()
            previewFrame.Size = UDim2.new(0, 56, 0, 44)
            TS:Create(previewFrame, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 60, 0, 47),
            }):Play()
            task.delay(0.15, function()
                TS:Create(previewFrame, TweenInfo.new(0.15), {
                    Size = UDim2.new(0, 56, 0, 44),
                }):Play()
            end)
        end

        previewFrame.MouseEnter:Connect(function()
            TS:Create(previewStroke, TweenInfo.new(0.12), {
                Color = getThemeColor(),
                Transparency = 0.05,
            }):Play()
        end)
        previewFrame.MouseLeave:Connect(function()
            local cfg = BACKGROUND_IMAGES[backgroundIndex]
            local isOff = (not cfg) or (not cfg.id) or (cfg.id == "")
            TS:Create(previewStroke, TweenInfo.new(0.12), {
                Color = isOff and ROW_BORDER or getThemeColor(),
                Transparency = isOff and 0.35 or 0.2,
            }):Play()
        end)

        local options = {}
        for _, bg in ipairs(BACKGROUND_IMAGES) do
            table.insert(options, bg.label)
        end

        backgroundSelectorLabel = mkNeoSelector(row, BACKGROUND_IMAGES[backgroundIndex].label, options, function(selected)
            for i, bg in ipairs(BACKGROUND_IMAGES) do
                if bg.label == selected then
                    applyBackground(i)
                    updateBackgroundPreview(i)
                    animatePreview()
                    saveAllSettings()
                    break
                end
            end
        end)

        if backgroundSelectorLabel then
            local selContainer = backgroundSelectorLabel.Parent
            if selContainer and selContainer:IsA("Frame") then
                selContainer.Size = UDim2.new(0, 175, 0, 30)
                selContainer.Position = UDim2.new(1, -183, 0.5, -15)
            end
        end

        updateBackgroundPreview(backgroundIndex)
        _G.updateBackgroundUI = function()
            if backgroundSelectorLabel and BACKGROUND_IMAGES[backgroundIndex] then
                backgroundSelectorLabel.Text = BACKGROUND_IMAGES[backgroundIndex].label
            end
            updateBackgroundPreview(backgroundIndex)
        end
    end

    do
        local row = mkRow(visualPage, 56)
        mkLabel(row, "Btn Img")

        local previewFrame = Instance.new("Frame", row)
        previewFrame.Name = "ButtonImagePreview"
        previewFrame.Size = UDim2.new(0, 56, 0, 44)
        previewFrame.Position = UDim2.new(1, -250, 0.5, -22)
        previewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        previewFrame.BackgroundTransparency = 0.15
        previewFrame.BorderSizePixel = 0
        previewFrame.ClipsDescendants = true
        previewFrame.ZIndex = 8
        Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 8)
        local previewStroke = Instance.new("UIStroke", previewFrame)
        previewStroke.Color = ROW_BORDER
        previewStroke.Thickness = 1.2
        previewStroke.Transparency = 0.35

        local previewImage = Instance.new("ImageLabel", previewFrame)
        previewImage.Size = UDim2.new(1, 0, 1, 0)
        previewImage.BackgroundTransparency = 1
        previewImage.Image = ""
        previewImage.ScaleType = Enum.ScaleType.Crop
        previewImage.ZIndex = 9
        Instance.new("UICorner", previewImage).CornerRadius = UDim.new(0, 8)

        local previewText = Instance.new("TextLabel", previewFrame)
        previewText.Size = UDim2.new(1, 0, 1, 0)
        previewText.BackgroundTransparency = 1
        previewText.Text = "OFF"
        previewText.TextColor3 = Color3.fromRGB(160, 160, 170)
        previewText.Font = Enum.Font.GothamBlack
        previewText.TextSize = 12
        previewText.ZIndex = 10

        local function updatePreview()
            local id = getButtonImageId()
            previewImage.Image = id or ""
            previewText.Visible = id == nil
            previewStroke.Color = id and getThemeColor() or ROW_BORDER
        end

        local options = {}
        for _, o in ipairs(BUTTON_IMAGE_OPTIONS) do
            options[#options + 1] = o.label
        end

        buttonImageSelectorLabel = mkNeoSelector(row, BUTTON_IMAGE_OPTIONS[buttonImageIndex].label, options, function(selected)
            for i, o in ipairs(BUTTON_IMAGE_OPTIONS) do
                if o.label == selected then
                    buttonImageIndex = i
                    updatePreview()
                    buttonImageApplyAll()
                    saveAllSettings()
                    break
                end
            end
        end)

        if buttonImageSelectorLabel then
            local selContainer = buttonImageSelectorLabel.Parent
            if selContainer and selContainer:IsA("Frame") then
                selContainer.Size = UDim2.new(0, 175, 0, 30)
                selContainer.Position = UDim2.new(1, -183, 0.5, -15)
            end
        end

        updatePreview()
        _G.updateButtonImageUI = function()
            if buttonImageSelectorLabel then
                buttonImageSelectorLabel.Text = BUTTON_IMAGE_OPTIONS[buttonImageIndex].label
            end
            updatePreview()
        end
    end

    local configPage = contentPages["Settings"]

    mkSect(configPage, "UI Settings")
    do
        local row = mkRow(configPage, 38)
        mkLabel(row, "UI Scale")
        uiScaleBox = mkBox(row, uiScaleValue, 50, 56, function(v)
            local n = _clamp(_floor(v+0.5), 50, 150)
            uiScaleValue = n
            if mainUIScale then mainUIScale.Scale = n/100 end
            saveAllSettings()
        end)
    end

    do
        local row = mkRow(configPage, 38)
        mkLabel(row, "Float Scale")
        floatScaleBox = mkBox(row, _floor(floatingButtonScale * 100 + 0.5), 50, 56, function(v)
            local val = _clamp(v, 50, 200)
            floatingButtonScale = val / 100
            applyFloatingButtonScale()
            saveAllSettings()
        end)
    end

    do
        local row = mkRow(configPage, 38)
        mkLabel(row, "Steal Bar Scale")
        pbScaleBox = mkBox(row, _floor(progressBarScale * 100 + 0.5), 50, 56, function(v)
            local val = _clamp(v, 50, 200)
            progressBarScale = val / 100
            if pbScale then pbScale.Scale = progressBarScale end
            task.defer(clampProgressBar)
            saveAllSettings()
        end)
    end

    mkSect(configPage, "Config Management")

    do
        local CFG_LIGHT = Color3.fromRGB(255, 255, 255)
        local CFG_DARK  = Color3.fromRGB(30, 30, 36)
        local CFG_ARMED = Color3.fromRGB(125, 125, 135)
        local CFG_INK   = Color3.fromRGB(12, 12, 14)

        -- Style B: one pill dock with 3 segments (SAVE | POSITIONS | RESET CONFIG) + status line
        local dockRow = mkRow(configPage, 54)
        dockRow.Size = UDim2.new(1, 0, 0, 54)

        local dock = Instance.new("Frame", dockRow)
        dock.Size = UDim2.new(1, -20, 0, 40)
        dock.Position = UDim2.new(0, 10, 0.5, -20)
        dock.BackgroundTransparency = 1
        dock.BorderSizePixel = 0
        dock.ZIndex = 8

        local statusRow = mkRow(configPage, 22)
        statusRow.Size = UDim2.new(1, 0, 0, 22)
        local statusDot = Instance.new("Frame", statusRow)
        statusDot.Size = UDim2.new(0, 7, 0, 7)
        statusDot.Position = UDim2.new(0, 14, 0.5, -3)
        statusDot.BackgroundColor3 = CFG_LIGHT
        statusDot.BorderSizePixel = 0
        statusDot.ZIndex = 8
        Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
        local statusLbl = Instance.new("TextLabel", statusRow)
        statusLbl.Size = UDim2.new(1, -34, 1, 0)
        statusLbl.Position = UDim2.new(0, 28, 0, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Auto-saved"
        statusLbl.TextColor3 = Color3.fromRGB(154, 154, 163)
        statusLbl.Font = Enum.Font.Code
        statusLbl.TextSize = 11
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.ZIndex = 8

        local function mkSeg(idx, text, primary, onClick)
            local btn = Instance.new("TextButton", dock)
            btn.Size = UDim2.new(1 / 3, -4, 1, 0)
            btn.Position = UDim2.new((idx - 1) / 3, (idx - 1) * 2, 0, 0)
            btn.BackgroundColor3 = primary and CFG_LIGHT or CFG_DARK
            btn.BackgroundTransparency = 0
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 9
            local idleBg = primary and CFG_LIGHT or CFG_DARK
            local idleT = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local segStroke = Instance.new("UIStroke", btn)
            segStroke.Color = Color3.fromRGB(240, 240, 245)
            segStroke.Thickness = 1.5
            segStroke.Transparency = 0.45
            local idleTxt = primary and CFG_INK or CFG_LIGHT

            if primary then
                local grad = Instance.new("UIGradient", btn)
                grad.Rotation = 90
                grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(168, 168, 178))
            end
            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = idleTxt
            lbl.Font = Enum.Font.GothamBlack
            lbl.TextSize = 11
            lbl.TextStrokeTransparency = 1
            lbl.ZIndex = 11

            local token = 0
            local api = {}
            local function paint(bg, bgT, ink, caption)
                lbl.Text = caption
                TS:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = bg}):Play()
                TS:Create(lbl, TweenInfo.new(0.18), {TextColor3 = ink}):Play()
            end
            function api.hold(caption, bg, bgT, ink, seconds, onDone)
                token = token + 1
                local mine = token
                paint(bg, bgT, ink, caption)
                task.delay(seconds, function()
                    if mine ~= token or not btn.Parent then return end
                    paint(idleBg, idleT, idleTxt, text)
                    if onDone then onDone() end
                end)
            end
            function api.flash(caption, seconds, onDone)
                if primary then
                    api.hold(caption, CFG_DARK, 0, CFG_LIGHT, seconds, onDone)
                else
                    api.hold(caption, CFG_LIGHT, 0.05, CFG_INK, seconds, onDone)
                end
            end

            btn.MouseButton1Click:Connect(function() onClick(api) end)
        end

        mkSeg(1, "SAVE", true, function(b)
            local ok = saveAllSettings()
            statusLbl.Text = ok and "Saved · just now" or "Save failed"
            b.flash(ok and "SAVED ✓" or "ERROR", 1.2)
        end)

        local resetDebounce = false
        mkSeg(2, "POSITIONS", false, function(b)
            if resetDebounce then return end
            resetDebounce = true
            resetFloatingPositions()
            b.flash("RESET ✓", 1.2, function() resetDebounce = false end)
        end)

        local resetState = 0
        local resetBusy = false
        mkSeg(3, "RESET CONFIG", false, function(b)
            if resetBusy then return end
            if resetState == 0 then
                resetState = 1
                b.hold("CONFIRM?", CFG_ARMED, 0, CFG_LIGHT, 2, function() resetState = 0 end)
            elseif resetState == 1 then
                resetBusy = true
                local success = pcall(resetToFactoryDefaults)
                resetState = 0
                statusLbl.Text = success and "Config reset" or "Reset failed"
                b.flash(success and "CONFIG RESET ✓" or "ERROR", 1.5, function() resetBusy = false end)
            end
        end)
    end

    local keyPage = contentPages["Keybinds"]
    mkSect(keyPage, "Keybinds")
    addKeybindRow(keyPage, "Carry Mode", KB.CarryToggle)
    addKeybindRow(keyPage, "Lagger Mode", KB.LaggerMode)
    addKeybindRow(keyPage, "Auto Left", KB.AutoLeft)
    addKeybindRow(keyPage, "Auto Right", KB.AutoRight)
    addKeybindRow(keyPage, "Auto Bat", KB.AutoBat)
    addKeybindRow(keyPage, "TP BAT", KB.TPBat)
    addKeybindRow(keyPage, "Insta Reset", KB.InstaReset)
    addKeybindRow(keyPage, "TP Down", KB.TPFloor)
    addKeybindRow(keyPage, "Drop Brainrot", KB.DropBrainrot)
    addKeybindRow(keyPage, "Hide GUI", KB.GuiHide)

    local spacer = Instance.new("Frame", keyPage)
    spacer.Size = UDim2.new(1, 0, 0, 16)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = getNextOrder(keyPage)
    spacer.ZIndex = 7

    pbFrame = Instance.new("Frame", gui)
    pbFrame.Size = UDim2.new(0, 250, 0, 36)
    pbFrame.Position = UDim2.new(0.5, -125, 1, -60)
    pbFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    pbFrame.BackgroundTransparency = 0
    pbFrame.BorderSizePixel = 0
    pbFrame.Active = true
    pbFrame.ClipsDescendants = true
    pbFrame.Visible = true
    pbFrame.ZIndex = 10

    backgroundImagePB = Instance.new("ImageLabel", pbFrame)
    backgroundImagePB.Name = "BackgroundImagePB"
    backgroundImagePB.Size = UDim2.new(1, 0, 1, 0)
    backgroundImagePB.Position = UDim2.new(0, 0, 0, 0)
    backgroundImagePB.BackgroundTransparency = 1
    backgroundImagePB.BorderSizePixel = 0
    backgroundImagePB.Image = ""
    backgroundImagePB.ScaleType = Enum.ScaleType.Crop
    backgroundImagePB.ImageTransparency = 1
    backgroundImagePB.ZIndex = 1
    Instance.new("UICorner", backgroundImagePB).CornerRadius = UDim.new(0, 14)

    pbScale = Instance.new("UIScale", pbFrame)
    pbScale.Scale = progressBarScale

    if savedProgressBarPos then
        pbFrame.Position = UDim2.new(
            savedProgressBarPos.XScale or 0.5,
            savedProgressBarPos.XOffset or -125,
            savedProgressBarPos.YScale or 1,
            savedProgressBarPos.YOffset or -60
        )
    end

    local corner = Instance.new("UICorner", pbFrame)
    corner.CornerRadius = UDim.new(0, 18)

    -- identity row sits on top of the progress bar: avatar + name (left), STEAL | % (centre), FPS | PING (right)
    local avatar = Instance.new("ImageLabel", pbFrame)
    avatar.Name = "Avatar"
    avatar.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    avatar.BorderSizePixel = 0
    avatar.Size = UDim2.new(0, 20, 0, 20)
    avatar.Position = UDim2.new(0, 9, 0, 8)
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150"
    avatar.ZIndex = 18
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    local avatarStroke = Instance.new("UIStroke", avatar)
    avatarStroke.Thickness = 1.2
    avatarStroke.Color = Color3.fromRGB(210, 210, 220)

    local nameLabel = Instance.new("TextLabel", pbFrame)
    nameLabel.Name = "PlayerName"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0, 56, 0, 24)
    nameLabel.Position = UDim2.new(0, 34, 0, 6)
    nameLabel.Text = string.upper(LP.DisplayName)
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextYAlignment = Enum.TextYAlignment.Center
    nameLabel.TextWrapped = false
    nameLabel.TextTruncate = Enum.TextTruncate.None
    nameLabel.ZIndex = 18
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.35
    do
        local fitBusy = false
        local function fitName()
            if fitBusy then return end
            fitBusy = true
            pcall(function()
                if nameLabel.AbsoluteSize.X <= 4 then return end
                for size = 10, 6, -1 do
                    nameLabel.TextSize = size
                    if nameLabel.TextBounds.X <= nameLabel.AbsoluteSize.X then break end
                end
            end)
            fitBusy = false
        end
        nameLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitName)
        pbFrame:GetPropertyChangedSignal("Visible"):Connect(fitName)
        task.defer(fitName)
    end

    progressPct = Instance.new("TextLabel", pbFrame)
    progressPct.Name = "StealPct"
    progressPct.Size = UDim2.new(0, 60, 0, 24)
    progressPct.Position = UDim2.new(0.5, -30, 0, 6)
    progressPct.BackgroundTransparency = 1
    progressPct.RichText = true
    progressPct.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressPct.Font = Enum.Font.GothamBold
    progressPct.TextSize = 10
    progressPct.TextXAlignment = Enum.TextXAlignment.Center
    progressPct.TextYAlignment = Enum.TextYAlignment.Center
    progressPct.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    progressPct.TextStrokeTransparency = 0.35
    progressPct.ZIndex = 18
    progressPct:GetPropertyChangedSignal("Text"):Connect(function()
        local t = progressPct.Text
        if t:find("STEAL", 1, true) then return end
        progressPct.Text = '<font color="rgb(210,210,220)">STEAL</font> | ' .. t
    end)
    progressPct.Text = "0%"

    fpsNeon = Instance.new("TextLabel", pbFrame)
    fpsNeon.Name = "FPSNeon"
    fpsNeon.Size = UDim2.new(0, 92, 0, 24)
    fpsNeon.Position = UDim2.new(1, -100, 0, 6)
    fpsNeon.BackgroundTransparency = 1
    fpsNeon.Text = "FPS: -- \u{2503} PING: --ms"
    fpsNeon.TextColor3 = Color3.fromRGB(210, 210, 220)
    fpsNeon.Font = Enum.Font.GothamBold
    fpsNeon.TextSize = 8
    fpsNeon.TextXAlignment = Enum.TextXAlignment.Right
    fpsNeon.TextYAlignment = Enum.TextYAlignment.Center
    fpsNeon.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    fpsNeon.TextStrokeTransparency = 0.35
    fpsNeon.ZIndex = 18

    local progressRow = Instance.new("Frame", pbFrame)
    progressRow.Name = "ProgressRow"
    progressRow.Size = UDim2.new(1, -12, 0, 24)
    progressRow.Position = UDim2.new(0, 6, 0, 6)
    progressRow.BackgroundTransparency = 1
    progressRow.ZIndex = 11

    local fillRegion = Instance.new("Frame", progressRow)
    fillRegion.Name = "FillRegion"
    fillRegion.Size = UDim2.new(1, 0, 1, 0)
    fillRegion.BackgroundColor3 = Color3.fromRGB(20,20,25)
    fillRegion.BackgroundTransparency = 0.25
    fillRegion.BorderSizePixel = 0
    fillRegion.ClipsDescendants = true
    fillRegion.ZIndex = 12
    Instance.new("UICorner", fillRegion).CornerRadius = UDim.new(0, 12)

    progressFill = Instance.new("Frame", fillRegion)
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(210, 210, 220)
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 13
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 12)

    local fillGrad = Instance.new("UIGradient", progressFill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(150, 150, 160)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(210, 210, 220)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(230, 230, 235)),
    })
    fillGrad.Rotation = 0

    -- fill animation (chrome shimmer): highlight band sweeps inside the pill, clipped by the gradient itself
    do
        fillGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(150, 150, 160)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(190, 190, 200)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(190, 190, 200)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 160)),
        })
        fillGrad.Offset = Vector2.new(-1, 0)
        TS:Create(fillGrad, TweenInfo.new(1.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false), {
            Offset = Vector2.new(1, 0),
        }):Play()

        local shown, target, setting = 0, 0, false
        progressFill:GetPropertyChangedSignal("Size"):Connect(function()
            if setting then return end
            target = progressFill.Size.X.Scale
            setting = true
            progressFill.Size = UDim2.new(shown, 0, 1, 0)
            setting = false
        end)
        RunService.Heartbeat:Connect(function(dt)
            if shown == target then return end
            if math.abs(target - shown) < 0.002 then
                shown = target
            else
                shown = shown + (target - shown) * math.min(1, dt * 12)
            end
            setting = true
            progressFill.Size = UDim2.new(shown, 0, 1, 0)
            setting = false
        end)
    end

    drag(pbFrame)
    task.defer(clampProgressBar)
    do
        local cam = workspace.CurrentCamera
        if cam then
            cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                task.defer(clampProgressBar)
            end)
        end
    end

    task.spawn(function()
        local fpsFrames = 0
        local fpsAvg = 60
        local fpsSince = _tick()
        RunService.RenderStepped:Connect(function()
            fpsFrames = fpsFrames + 1
        end)
        while true do
            local fpsNow = _tick()
            if fpsNow > fpsSince then
                fpsAvg = fpsFrames / (fpsNow - fpsSince)
            end
            fpsFrames = 0
            fpsSince = fpsNow
            local ping = 0
            pcall(function() ping = LP:GetNetworkPing() * 1000 end)
            if fpsNeon then
                fpsNeon.Text = string.format("FPS: %d \u{2503} PING: %dms", _floor(fpsAvg + 0.5), _floor(ping + 0.5))
            end
            task.wait(0.75)
        end
    end)

    drag(main)
end

function createMobilePanel()
    local panel = Instance.new("ScreenGui")
    panel.Name = "MeridianHubMobilePanel"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    local okPanel = pcall(function() panel.Parent = game:GetService("CoreGui") end)
    if not okPanel then panel.Parent = LP:WaitForChild("PlayerGui") end

    local BTN_W, BTN_H = 60, 60
    local GAP = 8
    local COLUMNS = 2
    local ROWS = 4
    local PANEL_W = BTN_W * COLUMNS + GAP * (COLUMNS - 1)
    local PANEL_H = BTN_H * ROWS + (GAP + 10) * (ROWS - 1)
    local floatLayout = getFloatingLayout()
    if floatLayout.mobile then
        PANEL_W, PANEL_H = floatLayout.panelW, floatLayout.panelH
    end

    local container = Instance.new("Frame", panel)
    container.Name = "FloatingPanel"
    container.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    container.Position = floatLayout.containerPos -- default: right side (phones: compact top-right block)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Active = false -- invisible holder must not eat touches around/between the floating buttons
    container.Selectable = false
    container.ClipsDescendants = false

    local containerScale = Instance.new("UIScale", container)
    containerScale.Scale = floatingButtonScale
    table.insert(_floatingUIScales, containerScale)

    local btnContainer = Instance.new("Frame", container)
    btnContainer.Name = "ButtonsContainer"
    btnContainer.Size = UDim2.new(1, 0, 1, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ClipsDescendants = false

    local INACTIVE_BG = Color3.fromRGB(8,8,10)

    local buttons = {}
    local buttonNames = {"DropBR", "AutoLeft", "AutoBat", "AutoRight", "TpDown", "Carry", "Lagger1", "Lagger2"}
    local buttonTexts = {"DROP\nBR", "AUTO\nLEFT", "BAT\nAIMBOT", "AUTO\nRIGHT", "TP\nDOWN", "CARRY\nSPD", "LAGGER\nNORMAL", "LAGGER\nCARRY"}

    local function createButton(name, text, order, isToggle, callback)
        local btn = Instance.new("TextButton", btnContainer)
        btn.Name = name
        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        btn.BackgroundColor3 = INACTIVE_BG
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 10

        local savedPos = savedButtonPositions[name]
        if savedPos then
            btn.Position = UDim2.new(0, savedPos.X or 0, 0, savedPos.Y or 0)
        else
            local defX, defY = getDefaultButtonPosition(name)
            btn.Position = UDim2.new(0, defX, 0, defY)
        end

        btn.BackgroundColor3 = INACTIVE_BG
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        local bgGrad = Instance.new("UIGradient", btn)
        bgGrad.Name = "BtnGrad"
        bgGrad.Rotation = 90
        bgGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 70, 78)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(28, 28, 34)),
            ColorSequenceKeypoint.new(0.70, Color3.fromRGB(10, 10, 14)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
        })

        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(70,70,78)
        stroke.Thickness = 1
        stroke.Transparency = 0.45
        stroke.Name = "NormalStroke"

        local label = Instance.new("TextLabel", btn)
        label.Name = "TextLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Oswald
        label.TextSize = 14
        label.TextWrapped = true
        label.ZIndex = 11

        local active = false
        local function setActive(state)
            active = state
            btn:SetAttribute("MobActive", state and true or false)
            paintFloatingBtn(btn, state)
        end
        setActive(false)

        local dragging = false
        local hasMoved = false
        local dragStart = nil
        local startPos = nil
        local movedDistance = 0

        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                hasMoved = false
                movedDistance = 0
                dragStart = input.Position
                startPos = btn.Position
                _isDraggingButton = true
            end
        end

        local function onInputChanged(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                movedDistance = delta.Magnitude
                if not uiLocked then
                    hasMoved = true
                    btn.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
                end
            end
        end

        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    if movedDistance < 3 then
                        if isToggle then
                            if callback then callback(setActive) end
                        else
                            if callback then callback(setActive, active) end
                        end
                    elseif not uiLocked and hasMoved then
                        savedButtonPositions[name] = {
                            X = btn.Position.X.Offset,
                            Y = btn.Position.Y.Offset
                        }
                        pcall(saveAllSettings)
                    end
                    dragging = false
                    hasMoved = false
                    dragStart = nil
                    startPos = nil
                    movedDistance = 0
                    _isDraggingButton = false
                end
            end
        end

        btn.InputBegan:Connect(onInputBegan)
        btn.InputChanged:Connect(onInputChanged)
        btn.InputEnded:Connect(onInputEnded)

        buttons[name] = {btn = btn, setActive = setActive, label = label}
        return setActive
    end

    for i, name in ipairs(buttonNames) do
        local text = buttonTexts[i]
        local callback
        if name == "DropBR" then
            callback = function(setActive)
                if autoBatEnabled then return end
                setActive(true)
                executeDropWithToggle(function(v)
                    if dropBrainrotSetVisual then dropBrainrotSetVisual(v) end
                end)
                task.delay(0.3, function() setActive(false) end)
            end
        elseif name == "AutoLeft" then
            callback = function(setActive)
                autoLeftEnabled = not autoLeftEnabled
                setActive(autoLeftEnabled)
                if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
                local qL = autoLeftEnabled or (_G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoLeft")) or false
                setActive(qL)
                if autoLeftSetVisual then autoLeftSetVisual(qL) end
            end
        elseif name == "AutoBat" then
            callback = function(setActive)
                local queued = _G.MeridianSafeModeIsQueued and (_G.MeridianSafeModeIsQueued("autoBat") or _G.MeridianSafeModeIsQueued("batV2"))
                if queued then disableAutoBat()
                elseif not (autoBatEnabled or autoBatV2Enabled) then enableAutoBat() else disableAutoBat() end
                setActive(autoBatEnabled or autoBatV2Enabled or (_G.MeridianSafeModeIsQueued and (_G.MeridianSafeModeIsQueued("autoBat") or _G.MeridianSafeModeIsQueued("batV2"))) or false)
            end
        elseif name == "AutoRight" then
            callback = function(setActive)
                autoRightEnabled = not autoRightEnabled
                setActive(autoRightEnabled)
                if autoRightEnabled then startAutoRight() else stopAutoRight() end
                local qR = autoRightEnabled or (_G.MeridianSafeModeIsQueued and _G.MeridianSafeModeIsQueued("autoRight")) or false
                setActive(qR)
                if autoRightSetVisual then autoRightSetVisual(qR) end
            end
        elseif name == "TpDown" then
            callback = function(setActive)
                doTpDown()
                setActive(true)
                task.delay(0.2, function() setActive(false) end)
            end
        elseif name == "Carry" then
            callback = function(setActive)
                if not speedMode then
                    speedMode = true; laggerToggled = false; laggerCarryToggled = false; setActive(true)
                    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
                    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
                else
                    speedMode = false; setActive(false)
                end
                refreshSpeedModeLabel()
            end
        elseif name == "Lagger1" then
            callback = function(setActive)
                if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end
                if not laggerToggled then
                    laggerToggled = true; laggerCarryToggled = false; setActive(true)
                    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
                else
                    laggerToggled = false; setActive(false)
                end
                refreshSpeedModeLabel()
            end
        elseif name == "Lagger2" then
            callback = function(setActive)
                if speedMode then speedMode = false; if mobSetCarry then mobSetCarry(false) end end
                if not laggerCarryToggled then
                    laggerCarryToggled = true; laggerToggled = false; setActive(true)
                    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
                else
                    laggerCarryToggled = false; setActive(false)
                end
                refreshSpeedModeLabel()
            end
        end
        mobSetAutoBat = buttons.AutoBat and buttons.AutoBat.setActive
        mobSetAutoLeft = buttons.AutoLeft and buttons.AutoLeft.setActive
        mobSetAutoRight = buttons.AutoRight and buttons.AutoRight.setActive
        mobSetDropBR = buttons.DropBR and buttons.DropBR.setActive
        mobSetTpDown = buttons.TpDown and buttons.TpDown.setActive
        mobSetCarry = buttons.Carry and buttons.Carry.setActive
        mobSetLagger1 = buttons.Lagger1 and buttons.Lagger1.setActive
        mobSetLagger2 = buttons.Lagger2 and buttons.Lagger2.setActive

        local setActive = createButton(name, text, i-1, true, callback)
        if name == "AutoBat" then mobSetAutoBat = setActive end
        if name == "AutoLeft" then mobSetAutoLeft = setActive end
        if name == "AutoRight" then mobSetAutoRight = setActive end
        if name == "DropBR" then mobSetDropBR = setActive end
        if name == "TpDown" then mobSetTpDown = setActive end
        if name == "Carry" then mobSetCarry = setActive end
        if name == "Lagger1" then mobSetLagger1 = setActive end
        if name == "Lagger2" then mobSetLagger2 = setActive end
    end

    if buttons.AutoBat and buttons.AutoBat.setActive then buttons.AutoBat.setActive(autoBatEnabled) end
    if buttons.AutoLeft and buttons.AutoLeft.setActive then buttons.AutoLeft.setActive(autoLeftEnabled) end
    if buttons.AutoRight and buttons.AutoRight.setActive then buttons.AutoRight.setActive(autoRightEnabled) end
    if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(speedMode) end
    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(laggerToggled) end
    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(laggerCarryToggled) end

    if savedMobilePanelPos then
        container.Position = UDim2.new(
            savedMobilePanelPos.XScale or 0,
            savedMobilePanelPos.XOffset or 10,
            savedMobilePanelPos.YScale or 0,
            savedMobilePanelPos.YOffset or 0
        )
    end

    -- no whole-panel drag: the holder is invisible, so only the button you touch moves

    return panel
end

function createTpBatFloatingButton()
    local panel = Instance.new("ScreenGui")
    panel.Name = "TpBatButton"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    local okPanel = pcall(function() panel.Parent = game:GetService("CoreGui") end)
    if not okPanel then panel.Parent = LP:WaitForChild("PlayerGui") end

    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(0, 60, 0, 60)
    btnFrame.Name = "Frame"
    if tpBatFloatingPos then
        btnFrame.Position = UDim2.new(tpBatFloatingPos.XScale or 0.5,
                                      tpBatFloatingPos.XOffset or 20,
                                      tpBatFloatingPos.YScale or 0,
                                      tpBatFloatingPos.YOffset or 10)
    else
        btnFrame.Position = getFloatingLayout().tpBat
    end
    btnFrame.BackgroundColor3 = Color3.fromRGB(8,8,10)
    btnFrame.BackgroundTransparency = 0
    btnFrame.BorderSizePixel = 0
    btnFrame.ZIndex = 20
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 10)
    local bgGrad = Instance.new("UIGradient", btnFrame)
    bgGrad.Name = "BtnGrad"
    bgGrad.Rotation = 90
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 70, 78)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(28, 28, 34)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(10, 10, 14)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
    })
    local stroke = Instance.new("UIStroke", btnFrame)
    stroke.Color = Color3.fromRGB(70,70,78)
    stroke.Thickness = 1
    stroke.Transparency = 0.45
    stroke.Name = "TpBatStroke"
    local label = Instance.new("TextLabel", btnFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "TP\nBAT"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Oswald
    label.TextSize = 14
    label.TextWrapped = true
    label.ZIndex = 21

    local uiScale = Instance.new("UIScale", btnFrame)
    uiScale.Scale = floatingButtonScale
    table.insert(_floatingUIScales, uiScale)
    paintFloatingBtn(btnFrame, false)

    local function setActive(state)
        label.Text = "TP\nBAT"
        paintFloatingBtn(btnFrame, state)
    end
    batDesyncTpSetVisual = setActive

    local dragging = false; local hasMoved = false; local dragStart, startPos
    btnFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; hasMoved = false; dragStart = inp.Position; startPos = btnFrame.Position
        end
    end)
    btnFrame.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position - dragStart
            if delta.Magnitude > 5 then hasMoved = true end
            if hasMoved and not uiLocked then
                btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                              startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    btnFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                if not hasMoved then
                    toggleBatDesyncTp()
                    setActive(batDesyncTpEnabled)
                elseif not uiLocked and hasMoved then
                    tpBatFloatingPos = {
                        XScale = btnFrame.Position.X.Scale,
                        XOffset = btnFrame.Position.X.Offset,
                        YScale = btnFrame.Position.Y.Scale,
                        YOffset = btnFrame.Position.Y.Offset
                    }
                    pcall(saveAllSettings)
                end
                dragging = false; hasMoved = false
            end
        end
    end)

    tpBatFloatingButton = panel
    return panel
end

function createInstaResetFloatingButton()
    local panel = Instance.new("ScreenGui")
    panel.Name = "InstaResetButton"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    local okPanel = pcall(function() panel.Parent = game:GetService("CoreGui") end)
    if not okPanel then panel.Parent = LP:WaitForChild("PlayerGui") end

    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(0, 60, 0, 60)
    btnFrame.Name = "Frame"
    if instaResetFloatingPos then
        btnFrame.Position = UDim2.new(instaResetFloatingPos.XScale or 0.5,
                                      instaResetFloatingPos.XOffset or 90,
                                      instaResetFloatingPos.YScale or 0,
                                      instaResetFloatingPos.YOffset or 10)
    else
        btnFrame.Position = getFloatingLayout().insta
    end
    btnFrame.BackgroundColor3 = Color3.fromRGB(8,8,10)
    btnFrame.BorderSizePixel  = 0
    btnFrame.ZIndex           = 20
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 10)

    local bgGrad = Instance.new("UIGradient", btnFrame)
    bgGrad.Name = "BtnGrad"
    bgGrad.Rotation = 90
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(70, 70, 78)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(28, 28, 34)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(10, 10, 14)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
    })

    local stroke = Instance.new("UIStroke", btnFrame)
    stroke.Color = Color3.fromRGB(70,70,78)
    stroke.Thickness = 1
    stroke.Transparency = 0.45

    local label = Instance.new("TextLabel", btnFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "INSTA\nRESET"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Oswald
    label.TextSize = 14
    label.TextWrapped = true
    label.ZIndex = 21

    local uiScale = Instance.new("UIScale", btnFrame)
    uiScale.Scale = floatingButtonScale
    table.insert(_floatingUIScales, uiScale)
    paintFloatingBtn(btnFrame, false)

    local dragging, hasMoved, dragStart, startPos, activeInput
    local RESET_TAP_THRESHOLD = 12

    local function pointInside(pos)
        local ap = btnFrame.AbsolutePosition
        local as = btnFrame.AbsoluteSize
        return pos.X >= ap.X and pos.X <= ap.X + as.X
           and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
    end

    local function setActive(state)
        if state then
            TS:Create(btnFrame, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            TS:Create(label,    TweenInfo.new(0.05), {TextColor3       = Color3.fromRGB(0,0,0)}):Play()
        else
            paintFloatingBtn(btnFrame, false)
        end
    end

    btnFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if activeInput then return end
            activeInput = inp
            dragging    = true
            hasMoved    = false
            dragStart   = inp.Position
            startPos    = btnFrame.Position
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging or not activeInput then return end
        local isTouchMove = activeInput.UserInputType == Enum.UserInputType.Touch and inp == activeInput
        local isMouseMove = activeInput.UserInputType == Enum.UserInputType.MouseButton1
                            and inp.UserInputType == Enum.UserInputType.MouseMovement
        if not isTouchMove and not isMouseMove then return end
        local delta = inp.Position - dragStart
        if delta.Magnitude > RESET_TAP_THRESHOLD then hasMoved = true end
        if hasMoved and not uiLocked then
            btnFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp ~= activeInput then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragging then
            local delta = inp.Position - dragStart
            local validTap = not hasMoved
                             and delta.Magnitude <= RESET_TAP_THRESHOLD
                             and pointInside(inp.Position)
            if validTap then
                setActive(true)
                if _G.InstaReset and _G.InstaReset.Trigger then
                    _G.InstaReset.Trigger()
                end
                task.delay(0.2, function() setActive(false) end)
            elseif not uiLocked and hasMoved then
                instaResetFloatingPos = {
                    XScale  = btnFrame.Position.X.Scale,
                    XOffset = btnFrame.Position.X.Offset,
                    YScale  = btnFrame.Position.Y.Scale,
                    YOffset = btnFrame.Position.Y.Offset,
                }
                pcall(saveAllSettings)
            end
            dragging    = false
            hasMoved    = false
            activeInput = nil
        end
    end)

    instaResetFloatingButton = panel
    return panel
end

function updateUIFromLoaded()
    task.wait()
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_CARRY_SPEED) end
    if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end
    if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
    if floatScaleBox then floatScaleBox.Text = tostring(_floor(floatingButtonScale * 100 + 0.5)) end
    if pbScaleBox then pbScaleBox.Text = tostring(_floor(progressBarScale * 100 + 0.5)) end
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    if bodyLockRangeBox then bodyLockRangeBox.Text = tostring(bodyLockRange) end
    AutoCarry.syncUI()
    if autoStealVariantLabel then autoStealVariantLabel.Text = autoStealVariantName(autoStealVariant or 2) end
    if aimModeLabel then aimModeLabel.Text = aimModeName() end
    if tpBatRefreshUI then tpBatRefreshUI() end
    if refreshStealModeRows then refreshStealModeRows() end
    refreshSpeedModeLabel()

    if infJumpSetVisual then infJumpSetVisual(infJumpEnabled) end
    if infJumpModeSetVisual then infJumpModeSetVisual.Text = infJumpMode end
    if mirrorTPDownSetVisual then mirrorTPDownSetVisual(mirrorTPDownEnabled) end
    if setSafeModeVisual then setSafeModeVisual(antiKickEnabled) end
    if setNoCamCollisionVisual then setNoCamCollisionVisual(noCamCollisionEnabled) end

    for _, ref in ipairs(keyButtonRefs) do
        local entry = ref.entry
        local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
        ref.btn.Text = label
    end

    if savedProgressBarPos and pbFrame then
        pbFrame.Position = UDim2.new(
            savedProgressBarPos.XScale or 0.5,
            savedProgressBarPos.XOffset or -125,
            savedProgressBarPos.YScale or 1,
            savedProgressBarPos.YOffset or -60
        )
    end
    if pbFrame then task.defer(clampProgressBar) end

    applyFloatingButtonScale()

    if uiLocked and setLockUIVisual then setLockUIVisual(true) end

    if _G.updateAntiRagdollUI then _G.updateAntiRagdollUI(antiRagdollMode) end
    if antiRagdollMode == "v1" then
        AntiRagdollV1.start()
    elseif antiRagdollMode == "v2" then
        startAntiRagdollV2()
    end

    antiDieEnabled = true
    AntiDieModule.start()

    if CONFIG.AUTO_STEAL_ENABLED and setInstaGrab then setInstaGrab(true); pcall(startAutoSteal) end

    if medusaCounterEnabled then
        if setMedusaVisual then setMedusaVisual(true) end
        if LP.Character then setupMedusaCounter(LP.Character) end
    else
        if setMedusaVisual then setMedusaVisual(false) end
        stopMedusaCounter()
    end

    if batCounterEnabled and setBatCounterVisual then
        setBatCounterVisual(true)
        startBatCounter()
    end
    if unwalkEnabled and setUnwalkVisual then
        setUnwalkVisual(true)
        task.spawn(function() task.wait(0.5); startUnwalk() end)
    end
    if antiLagEnabled then
        if setAntiLagVisual then setAntiLagVisual(true) end
        enableAntiLag()
    else
        if setAntiLagVisual then setAntiLagVisual(false) end
        disableAntiLag()
    end
    if espEnabled then
        toggleESP(true)
        if setESPVIsual then setESPVIsual(true) end
    else
        toggleESP(false)
        if setESPVIsual then setESPVIsual(false) end
    end

    if batDesyncTpEnabled then
        if batDesyncTpSetVisual then batDesyncTpSetVisual(true) end
        if not _G.AlvaroTP.on then startBatDesyncTp() end
        updateTpBatButtonWithAntiDie(true)
    else
        if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
        updateTpBatButtonWithAntiDie(false)
    end

    if autoBatV2Enabled then
        if autoBatV2SetVisual then autoBatV2SetVisual(true) end
    else
        if autoBatV2SetVisual then autoBatV2SetVisual(false) end
    end

    if neonWeatherEnabled then
        applyNeonWeather()
        if setNeonWeatherVisual then setNeonWeatherVisual(true) end
    else
        restoreLightingState()
        if setNeonWeatherVisual then setNeonWeatherVisual(false) end
    end

    if stretchEnabled then
        enableStretch()
        if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end
    else
        if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
    end

    if setFovVisual then setFovVisual(fovEnabled) end
    if fovSliderSet then fovSliderSet(fovValue) end

    if mobSetAutoBat then mobSetAutoBat(autoBatEnabled) end
    if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
    if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
    if mobSetCarry then mobSetCarry(speedMode) end
    if mobSetLagger1 then mobSetLagger1(laggerToggled) end
    if mobSetLagger2 then mobSetLagger2(laggerCarryToggled) end

    if bodyLockEnabled and bodyLockSetVisual then
        if _blSuppressCount == 0 then
            bodyLockSetVisual(true)
            startBodyLock()
        else
            bodyLockSetVisual(false)
        end
    end

    updateProgressBarVisibility()
    startEnemySpeed()

    toggleLockUI(uiLocked)

    pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
    if outfitSelectorLabel then
        outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label
    end

    if backgroundImage then
        applyBackground(backgroundIndex)
    end
    if _G.updateBackgroundUI then pcall(_G.updateBackgroundUI) end
    pcall(buttonImageApplyAll)
    if _G.updateButtonImageUI then pcall(_G.updateButtonImageUI) end
    if contentPages and contentPages["Visual"] then
        local vPage = contentPages["Visual"]
        for _, child in ipairs(vPage:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("BackgroundPreview") then
                local prevFrame = child.BackgroundPreview
                local previewImage = prevFrame:FindFirstChild("PreviewImage")
                local previewPlaceholder = prevFrame:FindFirstChild("PreviewPlaceholder")
                local cfg = BACKGROUND_IMAGES[backgroundIndex]
                if previewImage then
                    if cfg and cfg.id and cfg.id ~= "" then
                        previewImage.Image = cfg.id
                        if previewPlaceholder then previewPlaceholder.Visible = false end
                    else
                        previewImage.Image = ""
                        if previewPlaceholder then previewPlaceholder.Visible = true end
                    end
                end
                break
            end
        end
    end

    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        if container then
            if savedMobilePanelPos then
                container.Position = UDim2.new(
                    savedMobilePanelPos.XScale or 0,
                    savedMobilePanelPos.XOffset or 10,
                    savedMobilePanelPos.YScale or 0,
                    savedMobilePanelPos.YOffset or 0
                )
            end
            local btnCont = container:FindFirstChild("ButtonsContainer")
            if btnCont then
                for _, btn in ipairs(btnCont:GetChildren()) do
                    if btn:IsA("TextButton") then
                        local sp = savedButtonPositions and savedButtonPositions[btn.Name]
                        if sp then
                            btn.Position = UDim2.new(0, sp.X or 0, 0, sp.Y or 0)
                        end
                    end
                end
            end
        end
    end

    if tpBatFloatingButton and tpBatFloatingPos then
        local bf = tpBatFloatingButton:FindFirstChild("Frame")
        if bf then
            bf.Position = UDim2.new(
                tpBatFloatingPos.XScale or 0.5,
                tpBatFloatingPos.XOffset or 20,
                tpBatFloatingPos.YScale or 0,
                tpBatFloatingPos.YOffset or 10
            )
        end
    end

    if instaResetFloatingButton and instaResetFloatingPos then
        local bf = instaResetFloatingButton:FindFirstChild("Frame")
        if bf then
            bf.Position = UDim2.new(
                instaResetFloatingPos.XScale or 0.5,
                instaResetFloatingPos.XOffset or 90,
                instaResetFloatingPos.YScale or 0,
                instaResetFloatingPos.YOffset or 10
            )
        end
    end
end

MeridianHubAutoTPDown = false
MeridianHubAutoTPDownHeight = 20
MeridianHubShowE01Warning = false
MeridianHubAutoTPLastAt = 0
MeridianHubE01StartedAt = nil
MeridianHubE01Gui = nil

RunService.Heartbeat:Connect(function()
    if not MeridianHubAutoTPDown then return end
    local MeridianHubCharacter = LP.Character
    local MeridianHubRoot = MeridianHubCharacter and MeridianHubCharacter:FindFirstChild("HumanoidRootPart")
    local MeridianHubHumanoid = MeridianHubCharacter and MeridianHubCharacter:FindFirstChildOfClass("Humanoid")
    if MeridianHubRoot and MeridianHubHumanoid and MeridianHubHumanoid.FloorMaterial == Enum.Material.Air and MeridianHubRoot.Position.Y >= MeridianHubAutoTPDownHeight and tick() - MeridianHubAutoTPLastAt >= 0.35 then
        MeridianHubAutoTPLastAt = tick()
        doTpDown()
    end
end)

local function MeridianHubIsCarrying()
    local MeridianHubCharacter = LP.Character
    if not MeridianHubCharacter then return false end
    for _, MeridianHubChild in ipairs(MeridianHubCharacter:GetChildren()) do
        local MeridianHubName = MeridianHubChild.Name:lower()
        if MeridianHubName:find("brain", 1, true) or MeridianHubName:find("animal", 1, true) or MeridianHubName:find("carry", 1, true) or MeridianHubName:find("steal", 1, true) then return true end
    end
    local MeridianHubHumanoid = MeridianHubCharacter:FindFirstChildOfClass("Humanoid")
    return MeridianHubHumanoid and MeridianHubHumanoid.WalkSpeed > 0 and MeridianHubHumanoid.WalkSpeed <= 25 and MeridianHubHumanoid.WalkSpeed ~= 16
end

RunService.Heartbeat:Connect(function()
    if not MeridianHubShowE01Warning or not MeridianHubIsCarrying() then
        if MeridianHubE01Gui then MeridianHubE01Gui.Enabled = false end
        MeridianHubE01StartedAt = nil
        return
    end
    MeridianHubE01StartedAt = MeridianHubE01StartedAt or tick()
    local MeridianHubProgress = math.clamp((tick() - MeridianHubE01StartedAt) / 2.6, 0, 1)
    if not MeridianHubE01Gui then
        MeridianHubE01Gui = Instance.new("ScreenGui")
        MeridianHubE01Gui.Name = "MeridianHubE01Warning"
        MeridianHubE01Gui.ResetOnSpawn = false
        MeridianHubE01Gui.IgnoreGuiInset = true
        MeridianHubE01Gui.Parent = LP:WaitForChild("PlayerGui")
        local MeridianHubBar = Instance.new("Frame", MeridianHubE01Gui)
        MeridianHubBar.Name = "Bar"
        MeridianHubBar.AnchorPoint = Vector2.new(.5, 0)
        MeridianHubBar.Position = UDim2.new(.5, 0, 0, 18)
        MeridianHubBar.Size = UDim2.new(0, 300, 0, 36)
        MeridianHubBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MeridianHubBar.BackgroundTransparency = .34
        MeridianHubBar.BorderSizePixel = 0
        MeridianHubBar.ClipsDescendants = true
        Instance.new("UICorner", MeridianHubBar).CornerRadius = UDim.new(1, 0)
        local MeridianHubTrack = Instance.new("Frame", MeridianHubBar)
        MeridianHubTrack.Name = "Track"
        MeridianHubTrack.Position = UDim2.new(0, 3, 0, 3)
        MeridianHubTrack.Size = UDim2.new(1, -6, 1, -6)
        MeridianHubTrack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MeridianHubTrack.BackgroundTransparency = .48
        MeridianHubTrack.BorderSizePixel = 0
        MeridianHubTrack.ClipsDescendants = true
        Instance.new("UICorner", MeridianHubTrack).CornerRadius = UDim.new(1, 0)
        local MeridianHubFill = Instance.new("Frame", MeridianHubTrack)
        MeridianHubFill.Name = "Fill"
        MeridianHubFill.Size = UDim2.new(0, 0, 1, 0)
        MeridianHubFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MeridianHubFill.BackgroundTransparency = .48
        MeridianHubFill.BorderSizePixel = 0
        Instance.new("UICorner", MeridianHubFill).CornerRadius = UDim.new(1, 0)
        local MeridianHubLabel = Instance.new("TextLabel", MeridianHubBar)
        MeridianHubLabel.Name = "Label"
        MeridianHubLabel.Size = UDim2.new(1, -16, 1, 0)
        MeridianHubLabel.Position = UDim2.new(0, 8, 0, 0)
        MeridianHubLabel.BackgroundTransparency = 1
        MeridianHubLabel.Font = Enum.Font.GothamBlack
        MeridianHubLabel.TextSize = 14
        MeridianHubLabel.TextStrokeTransparency = .18
        MeridianHubLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        MeridianHubLabel.ZIndex = 2
    end
    MeridianHubE01Gui.Enabled = true
    local MeridianHubFinished = MeridianHubProgress >= 1
    MeridianHubE01Gui.Bar.Label.Text = MeridianHubFinished and "STEAL" or "DONT STEAL"
    MeridianHubE01Gui.Bar.Label.TextColor3 = MeridianHubFinished and Color3.fromRGB(85, 255, 125) or Color3.fromRGB(255, 75, 85)
    MeridianHubE01Gui.Bar.Track.Fill.Size = UDim2.new(MeridianHubProgress, 0, 1, 0)
end)

buildGui()

MobilePanel = createMobilePanel()
tpBatFloatingButton = createTpBatFloatingButton()
instaResetFloatingButton = createInstaResetFloatingButton()
pcall(buttonImageApplyAll)

-- ═══════════════════════════════════════════════════════════════════════════
-- LAST POSITION MARKER
-- ═══════════════════════════════════════════════════════════════════════════
local LastPosMarker = (function()
    local LPM_Players    = game:GetService("Players")
    local LPM_RunService = game:GetService("RunService")
    local LPM_Workspace  = game:GetService("Workspace")
    local LPM_LP         = LPM_Players.LocalPlayer

    local COLOR_MARKER           = Color3.fromRGB(180, 180, 190)
    local COLOR_OUTLINE          = Color3.fromRGB(230, 230, 235)
    local COLOR_TEXT             = Color3.fromRGB(230, 230, 235)
    local COLOR_TEXT_STROKE      = Color3.fromRGB(30, 30, 35)
    local COLOR_HANDLE_ADORNMENT = Color3.fromRGB(200, 200, 210)

    local LPM_MIN_X, LPM_MAX_X = -536.2, -422
    local LPM_MIN_Y, LPM_MAX_Y = -10, 75
    local LPM_MIN_Z, LPM_MAX_Z = -71.8, 192.9

    local MARKER_GROUND_Y = -7
    local LOOKBACK        = 0.2
    local INTERVAL        = 1 / 60

    local state = {
        marker          = nil,
        markerLocked    = false,
        markerTarget    = nil,
        samples         = {},
        conn            = nil,
        acc             = 0,
    }

    local function finiteVector(v)
        return v ~= nil
            and v.X == v.X and v.Y == v.Y and v.Z == v.Z
            and math.abs(v.X) < 1e7
            and math.abs(v.Y) < 1e7
            and math.abs(v.Z) < 1e7
    end

    local function isInsideMap(pos)
        if not pos then return false end
        return pos.X >= LPM_MIN_X and pos.X <= LPM_MAX_X
           and pos.Y >= LPM_MIN_Y and pos.Y <= LPM_MAX_Y
           and pos.Z >= LPM_MIN_Z and pos.Z <= LPM_MAX_Z
    end

    local function getSnapshotBeforeExit(sample, now)
        if not sample or not sample.history or #sample.history == 0 then return nil end
        local cutoff  = now - LOOKBACK
        local picked  = nil
        for _, entry in ipairs(sample.history) do
            if entry.time <= cutoff then picked = entry else break end
        end
        return picked or sample.history[1]
    end

    local function clearLastTargetMarker()
        state.markerLocked = false
        local m = state.marker
        if not m then return end
        pcall(function()
            m.Transparency = 1
            local sph = m:FindFirstChild("AlwaysOnTopSphere")
            if sph then sph.Visible = false end
            local hl = m:FindFirstChild("LastPositionHighlight")
            if hl then hl.Enabled = false end
            local bb = m:FindFirstChild("LastPositionLabel")
            if bb then bb.Enabled = false end
        end)
    end

    local function updateLastTargetMarker(targetCFrame)
        if state.markerLocked then return end
        if not targetCFrame or not isInsideMap(targetCFrame.Position) then return end

        local groundCFrame = CFrame.new(
            targetCFrame.Position.X,
            MARKER_GROUND_Y,
            targetCFrame.Position.Z
        ) * targetCFrame.Rotation

        local marker = state.marker
        if not marker or not marker.Parent then
            marker = Instance.new("Part")
            marker.Name            = "MeridianHubLastPosition"
            marker.Shape           = Enum.PartType.Ball
            marker.Size            = Vector3.new(3, 3, 3)
            marker.Color           = COLOR_MARKER
            marker.Material        = Enum.Material.Neon
            marker.Anchored        = true
            marker.CanCollide      = false
            marker.CanTouch        = false
            marker.CanQuery        = false
            marker.CastShadow      = false
            marker.Parent          = LPM_Workspace

            local sphere = Instance.new("SphereHandleAdornment")
            sphere.Name        = "AlwaysOnTopSphere"
            sphere.Adornee     = marker
            sphere.Radius      = 1.55
            sphere.Color3      = COLOR_HANDLE_ADORNMENT
            sphere.Transparency= 0.05
            sphere.AlwaysOnTop = true
            sphere.Visible     = true
            sphere.ZIndex      = 10
            sphere.Parent      = marker

            local hl = Instance.new("Highlight")
            hl.Name                = "LastPositionHighlight"
            hl.Adornee             = marker
            hl.FillColor           = COLOR_MARKER
            hl.FillTransparency    = 0.15
            hl.OutlineColor        = COLOR_OUTLINE
            hl.OutlineTransparency = 0
            hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled             = true
            hl.Parent              = marker

            local bb = Instance.new("BillboardGui")
            bb.Name        = "LastPositionLabel"
            bb.Size        = UDim2.new(0, 110, 0, 20)
            bb.StudsOffset = Vector3.new(0, 2.1, 0)
            bb.AlwaysOnTop = true
            bb.Adornee     = marker
            bb.Parent      = marker

            local label = Instance.new("TextLabel")
            label.Size                   = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.Text                   = "ultima posicion"
            label.TextColor3             = COLOR_TEXT
            label.TextStrokeColor3       = COLOR_TEXT_STROKE
            label.TextStrokeTransparency = 0.25
            label.TextSize               = 11
            label.Font                   = Enum.Font.GothamMedium
            label.Parent                 = bb

            state.marker = marker
        end

        marker.Transparency = 0
        local sph = marker:FindFirstChild("AlwaysOnTopSphere"); if sph then sph.Visible = true end
        local hl  = marker:FindFirstChild("LastPositionHighlight"); if hl  then hl.Enabled = true end
        local bb  = marker:FindFirstChild("LastPositionLabel");     if bb  then bb.Enabled = true end
        marker.CFrame = groundCFrame
        state.markerLocked = true
    end

    local function targetAlive(player, myRoot)
        if not player or player.Parent ~= LPM_Players or not player.Character then return false end
        local r = player.Character:FindFirstChild("HumanoidRootPart")
        local h = player.Character:FindFirstChildOfClass("Humanoid")
        if not r or not h or h.Health <= 0 or not finiteVector(r.Position) then return false end
        return isInsideMap(r.Position)
    end

    local function monitorLastTarget()
        local myChar = LPM_LP.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local tracked = state.markerTarget
        if tracked and tracked.Parent == LPM_Players then
            local tChar = tracked.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum  = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local sample = state.samples[tracked] or {}
            state.samples[tracked] = sample

            if tRoot and tHum and tHum.Health > 0 and finiteVector(tRoot.Position) then
                if isInsideMap(tRoot.Position) then
                    local now = tick()
                    if state.markerLocked then sample.history = {} end
                    sample.history = sample.history or {}
                    table.insert(sample.history, {
                        time         = now,
                        safePosition = tRoot.Position,
                        safeCFrame   = tRoot.CFrame,
                    })
                    while sample.history[1] and now - sample.history[1].time > (LOOKBACK + 0.25) do
                        table.remove(sample.history, 1)
                    end
                    sample.safePosition = tRoot.Position
                    sample.safeCFrame   = tRoot.CFrame
                    clearLastTargetMarker()
                else
                    local snap = getSnapshotBeforeExit(sample, tick())
                    updateLastTargetMarker((snap and snap.safeCFrame) or sample.safeCFrame)
                end
            end

            if (tHum and tHum.Health <= 0)
               or (not tRoot and not sample.safeCFrame) then
                state.markerTarget = nil
                clearLastTargetMarker()
            else
                return
            end
        end

        local closest, closestDist = nil, math.huge
        for _, p in ipairs(LPM_Players:GetPlayers()) do
            if p ~= LPM_LP and targetAlive(p, myRoot) then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local d = (r.Position - myRoot.Position).Magnitude
                if d < closestDist then closest, closestDist = p, d end
            end
        end

        if closest then
            state.markerTarget = closest
            local r = closest.Character:FindFirstChild("HumanoidRootPart")
            state.samples[closest] = {
                safePosition = r.Position,
                safeCFrame   = r.CFrame,
                history      = { { time = tick(), safePosition = r.Position, safeCFrame = r.CFrame } },
            }
        end
    end

    local api = {}

    function api.GetMarkerCFrame()
        local m = state.marker
        if state.markerLocked and m and m.Parent and m.Transparency < 1 then
            local tracked = state.markerTarget
            local tRoot = tracked and tracked.Character and tracked.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and isInsideMap(tRoot.Position) then
                clearLastTargetMarker()
                return nil
            end
            return m.CFrame
        end
        return nil
    end

    function api.ForceMarker(player, fallbackCFrame)
        if player and player.Parent == LPM_Players then state.markerTarget = player end
        local sample = player and state.samples[player]
        local snap   = getSnapshotBeforeExit(sample, tick())
        local remembered = (snap and snap.safeCFrame) or (sample and sample.safeCFrame)
        if not remembered and fallbackCFrame and isInsideMap(fallbackCFrame.Position) then
            remembered = fallbackCFrame
        end
        if remembered then updateLastTargetMarker(remembered) end
        return api.GetMarkerCFrame()
    end

    function api.SetTarget(player)
        if player and player ~= LPM_LP and player.Parent == LPM_Players then
            state.markerTarget = player
        end
    end

    function api.Clear()
        state.markerTarget = nil
        clearLastTargetMarker()
    end

    function api.Destroy()
        api.Stop()
        if state.marker and state.marker.Parent then
            pcall(function() state.marker:Destroy() end)
        end
        state.marker = nil
    end

    function api.Start()
        if state.conn then return state.conn end
        state.conn = LPM_RunService.Heartbeat:Connect(function(dt)
            state.acc = state.acc + (dt or 0)
            if state.acc < INTERVAL then return end
            state.acc = state.acc % INTERVAL
            monitorLastTarget()
        end)
        return state.conn
    end

    function api.Stop()
        if state.conn then
            state.conn:Disconnect()
            state.conn = nil
        end
    end

    api.IsInsideMap = isInsideMap
    return api
end)()

_G.MeridianHubLastPosMarker = LastPosMarker
LastPosMarker.Start()

if loadAllSettings() then
    updateUIFromLoaded()
end
_configReady = true
_lastSavedJSON = _lastSavedJSON or HS:JSONEncode(buildConfigTable())

-- autosave: anything that changed (toggles, boxes, drags) is written within ~2s
task.spawn(function()
    while true do
        task.wait(2)
        pcall(saveAllSettings)
    end
end)

antiDieEnabled = true
pcall(AntiDieModule.start)

if LP.Character then
    task.wait(0.1)
    if waitForCharReady(LP.Character, 5) then
        setupMovementAndIndicators(LP.Character)
        if currentAnimPack ~= "Off" then
            startAnimPack(currentAnimPack)
        end
        pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
    end
end

local _respawnQueue = 0
LP.CharacterAdded:Connect(function(char)
    _respawnQueue = _respawnQueue + 1
    local myId = _respawnQueue

    if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
    isStealing = false
    stopAutoLeft()
    stopAutoRight()
    stopBatCounter()
    stopMedusaCounter()
    if not _tpBatUnwalkForced then stopUnwalk() end
    stopDropBrainrot()
    if autoBatEnabled then disableAutoBat() end
    if batDesyncTpEnabled then stopBatDesyncTp() end
    if autoBatV2Enabled then disableBatV2() end
    if bodyLockEnabled then stopBodyLock() end

    local deadline = _tick() + 5
    while (not char.Parent) or (not char:FindFirstChild("HumanoidRootPart"))
          or (not char:FindFirstChildOfClass("Humanoid")) do
        if _tick() > deadline then return end
        if myId ~= _respawnQueue then return end
        task.wait(0.05)
    end

    setupMovementAndIndicators(char)

    if antiRagdollMode == "v1" then AntiRagdollV1.start()
    elseif antiRagdollMode == "v2" then startAntiRagdollV2() end

    if AntiDieModule.enabled then task.defer(function() activateOnCharacter(char) end) end
    if CONFIG.AUTO_STEAL_ENABLED then pcall(startAutoSteal) end
    if batDesyncTpEnabled then task.defer(startBatDesyncTp) end
    if autoBatV2Enabled then task.defer(enableBatV2) end
    if bodyLockEnabled and _blSuppressCount == 0 then startBodyLock() end

    if medusaCounterEnabled then
        setupMedusaCounter(char)
        if setMedusaVisual then setMedusaVisual(true) end
    else
        stopMedusaCounter()
        if setMedusaVisual then setMedusaVisual(false) end
    end

    if batCounterEnabled then startBatCounter() end
    if unwalkEnabled and not _tpBatUnwalkForced then startUnwalk() end

    if currentAnimPack ~= "Off" then
        task.wait(0.3)
        startAnimPack(currentAnimPack)
    end

    updateProgressBarVisibility()
    refreshSpeedModeLabel()

    pcall(function() applyOutfitByIndex(currentOutfitIndex) end)
    if outfitSelectorLabel then
        outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label
    end

end)

local lastLaggerToggle = 0
local LAGGER_COOLDOWN = 0.3

UIS.InputBegan:Connect(function(input, gpe)
    if _anyKeyListening then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if gpe or UIS:GetFocusedTextBox() then return end
    elseif not isGamepadInput(input) then
        return
    end
    if not isBindableInput(input) then return end

    local kc = input.KeyCode
    if not kc then return end

    if kbMatch(KB.LaggerMode, kc) then
        if _tick() - lastLaggerToggle >= LAGGER_COOLDOWN then
            lastLaggerToggle = _tick()
            toggleLaggerCycle()
        end
        return
    end
    if kbMatch(KB.CarryToggle, kc) then toggleCarryMode(); return end
    if kbMatch(KB.DropBrainrot, kc) then
        if not dropActive then
            if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
            executeDropWithToggle(dropBrainrotSetVisual)
        end
        return
    end
    if kbMatch(KB.TPFloor, kc) then doTpDown(); return end
    if kbMatch(KB.InstaReset, kc) then
        if _G.InstaReset and _G.InstaReset.Trigger then
            _G.InstaReset.Trigger()
        end
        return
    end
    if kbMatch(KB.AutoLeft, kc) then
        autoLeftEnabled = not autoLeftEnabled
        if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
        if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
        if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
        return
    end
    if kbMatch(KB.AutoRight, kc) then
        autoRightEnabled = not autoRightEnabled
        if autoRightEnabled then startAutoRight() else stopAutoRight() end
        if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
        if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
        return
    end
    if kbMatch(KB.AutoBat, kc) then
        if not (autoBatEnabled or autoBatV2Enabled) then
            enableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(autoBatEnabled or autoBatV2Enabled) end
            if mobSetAutoBat then mobSetAutoBat(autoBatEnabled or autoBatV2Enabled) end
        else
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end
        return
    end
    if kbMatch(KB.TPBat, kc) then
        toggleBatDesyncTp()
        if batDesyncTpSetVisual then batDesyncTpSetVisual(batDesyncTpEnabled) end
        return
    end
    if kbMatch(KB.GuiHide, kc) then
        if main then
            if main.Visible then hideGui() else showGui() end
        end
        return
    end
end)