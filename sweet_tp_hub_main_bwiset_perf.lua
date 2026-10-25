-- language: Lua, file: sweet_tp_hub_main.lua
-- Sweet TP Hub + pub SlotsESP / BrainrotESP / AutoKick
-- iPhone/iPad auto-scale + drag-resize grip on panel headers.

local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local Stats             = game:GetService("Stats")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP                = Players.LocalPlayer

local THEME_NAME = "black"

local THEMES = {
    halloween = {
        Accent        = Color3.fromRGB(255, 140,  20),
        AccentBright  = Color3.fromRGB(255, 205,  90),
        AccentDark    = Color3.fromRGB(150,  65,   8),
        TrackOn       = Color3.fromRGB(205,  95,  20),
        Bg            = Color3.fromRGB( 12,   7,  18),
        BgCard        = Color3.fromRGB( 24,  12,  34),
        BgRow         = Color3.fromRGB( 34,  17,  46),
        BgRowHov      = Color3.fromRGB( 52,  28,  68),
        BtnBg         = Color3.fromRGB( 40,  20,  55),
        BtnBgHov      = Color3.fromRGB( 62,  34,  82),
        ResetAccent   = Color3.fromRGB(140, 255, 110),
        ResetBg       = Color3.fromRGB( 22,  46,  14),
        ResetBgHov    = Color3.fromRGB( 36,  72,  22),
        DropAccent    = Color3.fromRGB(190, 120, 255),
        DropBg        = Color3.fromRGB( 48,  22,  72),
        DropBgHov     = Color3.fromRGB( 68,  36,  96),
    },
    purple = {
        Accent = Color3.fromRGB(150,100,255), AccentBright = Color3.fromRGB(200,160,255), AccentDark = Color3.fromRGB(80,50,180),
        TrackOn = Color3.fromRGB(130,85,240), Bg = Color3.fromRGB(14,10,24), BgCard = Color3.fromRGB(22,16,40),
        BgRow = Color3.fromRGB(30,22,54), BgRowHov = Color3.fromRGB(42,30,74), BtnBg = Color3.fromRGB(40,28,80),
        BtnBgHov = Color3.fromRGB(56,40,108), ResetAccent = Color3.fromRGB(255,100,130), ResetBg = Color3.fromRGB(55,22,38),
        ResetBgHov = Color3.fromRGB(75,30,52), DropAccent = Color3.fromRGB(255,185,70), DropBg = Color3.fromRGB(58,40,14),
        DropBgHov = Color3.fromRGB(78,54,20),
    },
    black = {
        Accent = Color3.fromRGB(220,220,220), AccentBright = Color3.fromRGB(255,255,255), AccentDark = Color3.fromRGB(140,140,140),
        TrackOn = Color3.fromRGB(200,200,200), Bg = Color3.fromRGB(8,8,8), BgCard = Color3.fromRGB(16,16,16),
        BgRow = Color3.fromRGB(24,24,24), BgRowHov = Color3.fromRGB(36,36,36), BtnBg = Color3.fromRGB(28,28,28),
        BtnBgHov = Color3.fromRGB(44,44,44), ResetAccent = Color3.fromRGB(255,80,80), ResetBg = Color3.fromRGB(40,14,14),
        ResetBgHov = Color3.fromRGB(60,20,20), DropAccent = Color3.fromRGB(200,180,100), DropBg = Color3.fromRGB(38,34,12),
        DropBgHov = Color3.fromRGB(56,50,18),
    },
    blue = {
        Accent = Color3.fromRGB(80,160,255), AccentBright = Color3.fromRGB(140,200,255), AccentDark = Color3.fromRGB(40,100,200),
        TrackOn = Color3.fromRGB(60,140,240), Bg = Color3.fromRGB(8,12,24), BgCard = Color3.fromRGB(12,20,40),
        BgRow = Color3.fromRGB(18,30,58), BgRowHov = Color3.fromRGB(26,44,80), BtnBg = Color3.fromRGB(18,36,70),
        BtnBgHov = Color3.fromRGB(28,54,100), ResetAccent = Color3.fromRGB(255,100,120), ResetBg = Color3.fromRGB(50,18,30),
        ResetBgHov = Color3.fromRGB(70,26,44), DropAccent = Color3.fromRGB(255,200,80), DropBg = Color3.fromRGB(52,44,12),
        DropBgHov = Color3.fromRGB(72,62,18),
    },
    red = {
        Accent = Color3.fromRGB(255,80,80), AccentBright = Color3.fromRGB(255,140,140), AccentDark = Color3.fromRGB(180,40,40),
        TrackOn = Color3.fromRGB(220,60,60), Bg = Color3.fromRGB(16,8,8), BgCard = Color3.fromRGB(28,12,12),
        BgRow = Color3.fromRGB(40,18,18), BgRowHov = Color3.fromRGB(58,26,26), BtnBg = Color3.fromRGB(48,18,18),
        BtnBgHov = Color3.fromRGB(68,26,26), ResetAccent = Color3.fromRGB(255,160,80), ResetBg = Color3.fromRGB(52,34,10),
        ResetBgHov = Color3.fromRGB(72,48,14), DropAccent = Color3.fromRGB(255,220,100), DropBg = Color3.fromRGB(52,46,12),
        DropBgHov = Color3.fromRGB(72,64,18),
    },
    green = {
        Accent = Color3.fromRGB(60,200,120), AccentBright = Color3.fromRGB(120,240,170), AccentDark = Color3.fromRGB(30,130,75),
        TrackOn = Color3.fromRGB(50,185,105), Bg = Color3.fromRGB(8,16,12), BgCard = Color3.fromRGB(12,26,18),
        BgRow = Color3.fromRGB(18,38,26), BgRowHov = Color3.fromRGB(26,54,36), BtnBg = Color3.fromRGB(16,44,28),
        BtnBgHov = Color3.fromRGB(24,64,40), ResetAccent = Color3.fromRGB(255,90,100), ResetBg = Color3.fromRGB(48,16,20),
        ResetBgHov = Color3.fromRGB(68,22,28), DropAccent = Color3.fromRGB(255,200,80), DropBg = Color3.fromRGB(50,44,12),
        DropBgHov = Color3.fromRGB(70,62,18),
    },
}

local T = THEMES[THEME_NAME] or THEMES["black"]

local Theme = {
    Bg = T.Bg, BgCard = T.BgCard, BgRow = T.BgRow, BgRowHov = T.BgRowHov,
    Stroke = T.Accent, StrokeSoft = T.AccentDark, Accent = T.Accent, AccentBright = T.AccentBright, AccentDark = T.AccentDark,
    Text = Color3.fromRGB(245,242,255), TextDim = Color3.fromRGB(160,155,185), TextMuted = Color3.fromRGB(110,106,140),
    BtnBg = T.BtnBg, BtnBgHover = T.BtnBgHov, BtnStroke = T.Accent,
    TrackOff = Color3.fromRGB(46,26,58), TrackOn = T.TrackOn, KnobOff = Color3.fromRGB(120,116,150), KnobOn = Color3.fromRGB(255,255,255),
    ResetAccent = T.ResetAccent, ResetBg = T.ResetBg, ResetBgHov = T.ResetBgHov,
    DropAccent = T.DropAccent, DropBg = T.DropBg, DropBgHov = T.DropBgHov,
    BindsAccent = T.AccentBright, BindsBg = T.BtnBg, BindsBgHov = T.BtnBgHov,
}

local CONFIG_FILE = "bwiset.json"

local function computeDefaultPositions()
    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
    local jobIdW, jobIdH = 270, 200
    local jobIdX = math.floor(vp.X / 2 - jobIdW / 2)
    local jobIdY = math.max(10, math.floor(vp.Y * 0.25 - jobIdH / 2))
    local gearW, gearH = 270, 440
    local gearX = math.min(math.floor(vp.X * 0.75 - gearW / 2), vp.X - gearW - 10)
    local gearY = math.max(10, math.floor(vp.Y * 0.5 - gearH / 2))
    return {
        JobId = { X = jobIdX, Y = jobIdY },
        GearSafety = { X = gearX, Y = gearY },
        BindsWindow = { X = 800, Y = 200 },
    }
end
local DEFAULT_POSITIONS = computeDefaultPositions()

local CONFIG = {
    NextBase = false,
    AntiRagdoll = false,
    CarpetSpeed = false,
    InfiniteJump = false,
    ShowJobId = false,
    XRay = false,
    AutoEquipOnSlot = false,
    Aimbot = false,
    SlotsESP = false,
    BrainrotESP = false,
    AutoKick = false,
    StealBoost = false,
    Bind_CarpetSpeed = "Q",
    Bind_InstantReset = "R",
    Bind_Drop = "G",
    Bind_Aimbot = "C",
    Bind_AutoKick = "K",
    Bind_StealBoost = "V",
    GuiScale = nil,
    ViewKey = "",
    Positions = {
        JobId = DEFAULT_POSITIONS.JobId,
        GearSafety = DEFAULT_POSITIONS.GearSafety,
        BindsWindow = DEFAULT_POSITIONS.BindsWindow,
    },
}

local function saveConfig()
    if writefile then
        pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(CONFIG)) end)
    end
end

repeat task.wait(.1) until game:IsLoaded() and game.Players.LocalPlayer
task.wait(1)

local camera = workspace.CurrentCamera
local FOV_LOCK = 70

-- ============================================================
-- EFFECT BLACKLIST + CLEAR
-- ============================================================
local blacklist = {
    "BlurEffect","ColorCorrectionEffect","BloomEffect","SunRaysEffect","DepthOfFieldEffect","Atmosphere","Sky","Smoke",
    "ParticleEmitter","Beam","Trail","Highlight","PostEffect","SurfaceAppearance","Fire","Sparkles","Explosion",
    "PointLight","SpotLight","SurfaceLight","Shadows","Blur","Fog","ColorGradingEffect","ToneMappingEffect",
    "VignetteEffect","GodRays","Glare","ChromaticAberrationEffect","DistortionEffect","LensFlare","SunFlare",
    "LightInfluence","AmbientOcclusionEffect","RefractionEffect","HeatDistortion","GlitchEffect","ScreenSpaceReflection",
    "MotionBlur","VolumetricLight","RainEffect","SnowEffect","LightningEffect","NeonGlow","ContrastCorrection",
    "ShadowMap","Bloom","Clouds","FogVolume","WaterEffect","WindEffect","PixelateEffect","FilmGrainEffect","CRTShader",
    "NightVisionEffect","InfraredEffect","HazeEffect","ColorBalanceEffect","DynamicLight","AmbientEffect",
    "ScreenDistortion","ScanlineEffect","UnderwaterEffect","ThermalVision","ShockwaveEffect","FlashEffect",
    "ExplosionLight","VFXPart","GlitchScreen","ScreenFlash","OverlayEffect","ShadowEffect","GhostEffect","FogEmitter",
    "WindEmitter","HeatWave","SunGlow","ColorOverlay","VisionDistort","EchoEffect","ScreenOverlay","RenderEffect",
    "VisualEffect","LightingEffect","CameraEffect","WeatherEffect","SmokeTrail","FireTrail","NeonEffect",
    "RefractionLayer","PostProcessingEffect","VisualNoise","ScreenNoise",
}
local function isBlacklisted(obj)
    for _, name in ipairs(blacklist) do
        if obj:IsA(name) then return true end
    end
    return false
end
local function clearEffects()
    for _, v in pairs(Lighting:GetDescendants()) do
        if isBlacklisted(v) then v:Destroy() end
    end
end
clearEffects()
Lighting.DescendantAdded:Connect(function(obj) task.wait() if isBlacklisted(obj) then obj:Destroy() end end)
RunService.RenderStepped:Connect(function() if camera.FieldOfView ~= FOV_LOCK then camera.FieldOfView = FOV_LOCK end end)

pcall(function() if setthreadidentity then setthreadidentity(8) end end)

-- ============================================================
-- P MODULE — used by auto grab
-- ============================================================
local P = {
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    ListNeedsRedraw = true,
}

-- ============================================================
-- AUTO GRAB — VERBATIM.
-- ============================================================
do
    local C = { AUTO_STEAL = false, RADIUS = 12 }
    local r = {
        { min = Vector3.new(-337.448303,-3.898971,-122.397758), max = Vector3.new(-328.004578,-3.898971,242.625626) },
        { min = Vector3.new(-327.25766,-3.899109,-122.228622),  max = Vector3.new(-320.600891,-3.899109,242.612259) },
        { min = Vector3.new(-319.783386,-3.89897,-122.227089),  max = Vector3.new(-312.908325,-3.89897,242.585617) },
        { min = Vector3.new(-312.445648,-3.899108,-122.389832), max = Vector3.new(-305.489899,-3.899108,242.456818) },
        { min = Vector3.new(-305.037048,-3.89897,-122.230743),  max = Vector3.new(-293.957489,-3.89897,242.606873) },
        { min = Vector3.new(-491.448608,-3.898972,-122.253258), max = Vector3.new(-481.811737,-3.898972,242.615005) },
        { min = Vector3.new(-498.971069,-3.89897,-122.382767),  max = Vector3.new(-491.74884,-3.89897,242.612061) },
        { min = Vector3.new(-506.436737,-3.898972,-122.411476), max = Vector3.new(-499.318542,-3.898972,242.615982) },
        { min = Vector3.new(-513.783569,-3.898972,-122.223297), max = Vector3.new(-506.801849,-3.898972,242.62709) },
        { min = Vector3.new(-525.236938,-3.898972,-122.409813), max = Vector3.new(-514.265015,-3.898972,242.608932) },
    }
    local R = game:GetService("Players")
    local d = game:GetService("RunService")
    local n = R.LocalPlayer
    do
        local R
        local function f()
            n.DevEnableMouseLock = true
            n.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            if R then R:Disconnect() end
            R = d.RenderStepped:Connect(function()
                local R = workspace.CurrentCamera
                if R and R.CameraSubject and R.CameraType == Enum.CameraType.Custom then
                    R.CFrame = R.CFrame
                end
            end)
        end
        f()
        n.CharacterAdded:Connect(function() task.wait(0.5) f() end)
    end
    local R = {}
    local d = {}
    local f = 0
    function _G.getSafePollRate()
        if os.clock() < f then return 0.27 end
        return 0.1
    end
    function _G.triggerSafePollBoost()
        f = os.clock() + 3
    end
    local f = {}
    local function J()
        local a = n.Character
        return a and a:FindFirstChild("HumanoidRootPart")
    end
    local function n(a)
        for e, x in ipairs(r) do
            if a.X >= math.min(x.min.X, x.max.X) and a.X <= math.max(x.min.X, x.max.X)
                and a.Z >= math.min(x.min.Z, x.max.Z) and a.Z <= math.max(x.min.Z, x.max.Z) then
                return e
            end
        end
    end
    local function r(a)
        local e = a.Parent
        if not e then return end
        if e:IsA("Attachment") and e.Parent then e = e.Parent end
        if e:IsA("BasePart") then return e.Position
        elseif e:IsA("Model") then return e:GetPivot().Position end
    end
    local function a(e)
        if not P then return false end
        local x = P.SelectedPetData
        if not x then return false end
        local Q = e:FindFirstAncestorOfClass("Model")
        if not Q then return false end
        if x.plot then
            local V = e:FindFirstAncestor(x.plot)
            if not V then return false end
        end
        if x.slot then
            local V = e:FindFirstAncestor(x.slot)
            if V then return true end
            if Q.Name == x.slot then return true end
            if Q.Parent and Q.Parent.Name == x.slot then return true end
        end
        if x.name then
            local e = string.lower(x.name)
            local x = Q
            while x do
                if x.Name and string.lower(x.Name) == e then return true end
                x = x.Parent
            end
        end
        return false
    end
    local function e(x, Q)
        if not x or not x.Parent then return false end
        if not x.Enabled then return false end
        local V = r(x)
        if not V then return false end
        local r = x:FindFirstAncestorOfClass("Model")
        if r then
            local r = workspace:FindFirstChild("Plots")
            if r then
                local i = x:FindFirstAncestorWhichIsA("Model")
                while i and i.Parent ~= r do i = i.Parent end
                if i then
                    local r = i:FindFirstChild("PlotSign")
                    if r then
                        local i = r:FindFirstChildWhichIsA("SurfaceGui", true)
                        local r = i and i:FindFirstChildWhichIsA("TextLabel", true)
                        if r then
                            local i = r.Text:lower()
                            if i:find(game.Players.LocalPlayer.Name:lower(), 1, true)
                                or i:find(game.Players.LocalPlayer.DisplayName:lower(), 1, true) then
                                return false
                            end
                        end
                    end
                end
            end
        end
        if _G.NEAREST_INSTANT_MODE == true then
            local r = n(Q)
            local i = n(V)
            if not r or r ~= i then return false end
        end
        if _G.NEAREST_INSTANT_MODE ~= true then
            if not a(x) then return false end
        end
        local r = typeof(x.MaxActivationDistance) == "number" and x.MaxActivationDistance > 0 and x.MaxActivationDistance or C.RADIUS
        local n = math.min(C.RADIUS, r)
        return (V - Q).Magnitude <= n
    end
    local function r(n, a)
        local x = os.clock()
        local Q = d[n]
        if Q and x - Q < a then return false end
        d[n] = x
        return true
    end
    local function n(a, x, Q)
        if not a or not a.Parent then return end
        if not a.Enabled then return end
        if not r(a, Q) then return end
        for r = 1, x do
            pcall(function() fireproximityprompt(a, 0) end)
        end
    end
    local function r(a)
        if R[a] then return end
        R[a] = true
        local function x()
            local Q = J()
            if not Q then return end
            local V = Q.Position
            if e(a, V) then
                C.AUTO_STEAL = true
                local Q = os.clock()
                local V = f[a]
                if not V or Q - V >= 0.08 then
                    f[a] = Q
                    n(a, 25, 0)
                end
            end
        end
        task.defer(function() x() end)
        pcall(function()
            a:GetPropertyChangedSignal("Enabled"):Connect(function()
                if a.Enabled then x() end
            end)
        end)
        a.AncestryChanged:Connect(function()
            if not a:IsDescendantOf(workspace) then
                R[a] = nil
                d[a] = nil
                f[a] = nil
            end
        end)
    end
    local function d()
        local f = workspace:FindFirstChild("Plots")
        if not f then return end
        for a, a in ipairs(f:GetChildren()) do
            local f = a:FindFirstChild("AnimalPodiums")
            if f then
                for a, a in ipairs(f:GetDescendants()) do
                    if a:IsA("ProximityPrompt") then r(a) end
                end
            end
        end
    end
    d()
    workspace.DescendantAdded:Connect(function(d)
        if d:IsA("ProximityPrompt") and d:FindFirstAncestor("AnimalPodiums") then r(d) end
    end)
    task.spawn(function()
        while task.wait(_G.getSafePollRate()) do
            local r = J()
            if not r then C.AUTO_STEAL = false continue end
            local d = r.Position
            local r = false
            for f in pairs(R) do
                if e(f, d) then
                    r = true
                    if C.AUTO_STEAL then n(f, 3, 0.12) end
                end
            end
            C.AUTO_STEAL = r
        end
    end)
end

-- ============================================================
-- ANIMALS/WEBHOOK/PLOT SCANNER/PROMPT FIRE — VERBATIM.
-- ============================================================
task.spawn(function()
    -- progress HUD is built first so it shows even if the game modules below take time to load
    local MG = LP:WaitForChild("PlayerGui"):FindFirstChild("bRXgmsaEVfze")
    if MG then MG:Destroy() end
    local MG = Instance.new("ScreenGui")
    MG.Name = "bRXgmsaEVfze"
    MG.ResetOnSpawn = false
    MG.IgnoreGuiInset = true
    MG.DisplayOrder = 998
    MG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MG.Enabled = true
    MG.Parent = LP:WaitForChild("PlayerGui")

    local wG = {
        PANEL = Color3.fromRGB(14, 14, 17),
        STROKE = Color3.fromRGB(200, 202, 212),
        TEXT = Color3.fromRGB(245, 245, 250),
        FILL1 = Color3.fromRGB(70, 72, 84),
        FILL2 = Color3.fromRGB(158, 161, 176)
    }

    -- the pill IS the progress bar: dark capsule track, metallic fill grows left to right, text sits on top
    local hudRoot = Instance.new("Frame", MG)
    hudRoot.Name = "CurrentTargetHUD"
    hudRoot.AnchorPoint = Vector2.new(0.5, 1)
    hudRoot.Size = UDim2.new(0, 280, 0, 34)
    hudRoot.Position = UDim2.new(0.5, 0, 1, -220.0)
    do
        local cam = workspace.CurrentCamera
        if cam and cam.ViewportSize.Y < 520 then hudRoot.Position = UDim2.new(0.5, 0, 1, -18) end
    end
    hudRoot.BackgroundColor3 = wG.PANEL
    hudRoot.BackgroundTransparency = 0.05
    hudRoot.BorderSizePixel = 0
    hudRoot.Visible = true
    hudRoot.ClipsDescendants = true
    hudRoot.ZIndex = 70
    Instance.new("UICorner", hudRoot).CornerRadius = UDim.new(1, 0)
    local hudStroke = Instance.new("UIStroke", hudRoot)
    hudStroke.Color = wG.STROKE
    hudStroke.Thickness = 1.2
    hudStroke.Transparency = 0.35
    hudStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- movable: drag the bar with mouse or finger (small threshold so a tap does nothing)
    do
        hudRoot.Active = true
        local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
        local THRESHOLD = UserInputService.TouchEnabled and 6 or 2
        local moved = false
        hudRoot.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            dragging, dragInput, moved = true, input, false
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = hudRoot.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End
                    or input.UserInputState == Enum.UserInputState.Cancel then
                    if input == dragInput then dragging, dragInput = false, nil end
                end
            end)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or not dragInput then return end
            local touch = dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
            local mouse = dragInput.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement
            if not touch and not mouse then return end
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            if not moved and delta.Magnitude < THRESHOLD then return end
            moved = true
            hudRoot.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end)
    end

    local bG = Instance.new("Frame", hudRoot)
    bG.Name = "ProgressFill"
    bG.Size = UDim2.new(0, 0, 1, 0)
    bG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bG.BorderSizePixel = 0
    bG.ZIndex = 71
    Instance.new("UICorner", bG).CornerRadius = UDim.new(1, 0)
    local fillGradient = Instance.new("UIGradient", bG)
    fillGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, wG.FILL1), ColorSequenceKeypoint.new(1, wG.FILL2) })

    local MG = Instance.new("TextLabel", hudRoot)
    MG.Name = "TargetName"
    MG.Size = UDim2.new(0.62, -14, 1, 0)
    MG.Position = UDim2.new(0, 16, 0, 0)
    MG.BackgroundTransparency = 1
    MG.Font = Enum.Font.GothamBold
    MG.TextSize = 12
    MG.TextColor3 = wG.TEXT
    MG.TextStrokeTransparency = 0.45
    MG.TextXAlignment = Enum.TextXAlignment.Left
    MG.TextTruncate = Enum.TextTruncate.AtEnd
    MG.ZIndex = 73
    MG.Text = "No target"

    local FG = Instance.new("TextLabel", hudRoot)
    FG.Name = "Percent"
    FG.Size = UDim2.new(0.38, -16, 1, 0)
    FG.Position = UDim2.new(0.62, 0, 0, 0)
    FG.BackgroundTransparency = 1
    FG.Font = Enum.Font.GothamBlack
    FG.TextSize = 13
    FG.TextColor3 = wG.TEXT
    FG.TextStrokeTransparency = 0.45
    FG.TextXAlignment = Enum.TextXAlignment.Right
    FG.ZIndex = 73
    FG.Text = "0%"
    local wG = bG
    local S = ReplicatedStorage:WaitForChild("Packages")
    local CG = ReplicatedStorage:WaitForChild("Datas")
    local rG = ReplicatedStorage:WaitForChild("Shared")
    local rG = ReplicatedStorage:WaitForChild("Utils")
    local rG = require(S:WaitForChild("Synchronizer"))
    local function S(dG)
        if not dG then return false end
        if typeof(dG) == "Instance" then return dG == LP end
        if type(dG) == "string" then return dG == LP.Name end
        return false
    end
    local function dG(nG)
        local fG, JG = pcall(function()
            local aG = getthreadidentity and getthreadidentity() or nil
            if setthreadidentity then setthreadidentity(8) end
            local eG = rG:GetTableFromChannel(nG)
            if aG and setthreadidentity then pcall(setthreadidentity, aG) end
            return eG
        end)
        if fG and type(JG) == "table" then return JG end
        return nil
    end
    local rG = require(CG:WaitForChild("Animals"))
    local nG = require(CG:WaitForChild("Mutations"))
    local fG = require(CG:WaitForChild("Traits"))
    local CG = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg", "Uvg", "Dvg", "Tvg" }
    local function JG(aG, eG)
        eG = eG or 1
        local xG = math.abs(aG)
        local QG = math.max(1, xG)
        local xG = math.floor(math.log(QG, 1000))
        local QG = CG[xG + 1] or "e+" .. xG
        local CG = aG * (10 ^ eG / 1000 ^ xG)
        local aG = math.floor(CG) / 10 ^ eG
        return (("%." .. eG .. "f"):format(aG)):gsub("%.?0+$", "") .. QG
    end
    local function CG(aG, eG, xG)
        local QG = rG[aG]
        if not QG then return 0 end
        local aG = QG.Generation or QG.Price * 0.1
        local QG = 1
        if eG and eG ~= "None" then
            local VG = nG[eG]
            if VG and VG.Modifier then QG = QG + VG.Modifier end
        end
        local nG = false
        if type(xG) == "table" then
            for eG, eG in ipairs(xG) do
                if eG == "Sleepy" then nG = true
                else
                    local xG = fG[eG]
                    if xG and xG.MultiplierModifier then QG = QG + xG.MultiplierModifier end
                end
            end
        end
        local fG = math.round(aG * QG)
        if nG then fG = math.round(fG * 0.5) end
        return fG
    end

    local nG = true
    local i = {
        PriorityList = {
            "Strawberry Elephant","Meowl","Skibidi Toilet","Headless Horseman","Dragon Gingerini",
            "Dragon Cannelloni","Ketupat Bros","Hydra Dragon Cannelloni","La Supreme Combinasion",
            "Love Love Bear","Ginger Gerat","Cerberus","Capitano Moby","La Casa Boo",
            "Burguro and Fryuro","Spooky and Pumpky","Cooki and Milki","Rosey and Teddy",
            "Popcuru and Fizzuru","Reinito Sleighito","Fragrama and Chocrama","Garama and Madundung",
            "Ketchuru and Musturu","La Secret Combinasion","Tralaledon","Tictac Sahur",
            "Ketupat Kepat","Tang Tang Keletang","Orcaledon","La Ginger Sekolah","Los Spaghettis",
            "Lavadorito Spinito","Swaggy Bros","La Taco Combinasion","Los Primos","Chillin Chili",
            "Tuff Toucan","W or L","Chillin Chili","Chipso and Queso",
        },
        StealNearest = true, InstantSteal = true, StealHighest = false, StealPriority = false,
    }
    local fG = true
    local aG = false
    local eG = false
    if i.InstantSteal == nil then i.InstantSteal = false end
    local xG = i.InstantSteal == true
    _G.NEAREST_INSTANT_MODE = (i.StealNearest == true and i.InstantSteal == true)
    local QG = false
    local VG = false
    local iG = 1
    local OG = nil
    local UG = nil
    local yG = {}
    local function KG() nG = fG == true or aG == true or eG == true end
    KG()
    local qG = {}
    local cG = {}
    local zG = nil
    local BG = nil
    local oG = {}
    local function YG(TG)
        if not TG or not TG.plot then return false end
        local IG = workspace:FindFirstChild("Plots")
        if not IG then return false end
        local pG = IG:FindFirstChild(TG.plot)
        if not pG then return false end
        local TG = dG(pG.Name)
        if TG then return S(TG.Owner) end
        return false
    end
    local function TG(IG)
        if not IG or IG == "None" then return "" end
        local pG = ""
        if IG == "Cursed" then pG = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"
        elseif IG == "Gold" then pG = "<font color='rgb(255,215,0)'>Gold</font>"
        elseif IG == "Diamond" then pG = "<font color='rgb(0,255,255)'>Diamond</font>"
        elseif IG == "YinYang" then pG = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"
        elseif IG == "Candy" then pG = "<font color='rgb(255,105,180)'>Candy</font>"
        elseif IG == "Divine" then pG = "<font color='rgb(255,255,255)'>Divine</font>"
        elseif IG == "Rainbow" then
            local jG = { "rgb(255,0,0)", "rgb(255,127,0)", "rgb(255,255,0)", "rgb(0,255,0)", "rgb(0,0,255)", "rgb(75,0,130)", "rgb(148,0,211)" }
            for lG = 1, #IG do pG = pG .. "<font color='" .. jG[(lG - 1) % #jG + 1] .. "'>" .. IG:sub(lG, lG) .. "</font>" end
        elseif IG == "Radioactive" then pG = "<font color='rgb(132,255,0)'>Radioactive</font>"
        elseif IG == "Galaxy" then pG = "<font color='rgb(170,85,255)'>Galaxy</font>"
        else pG = IG end
        return "<font weight='800'>" .. pG .. " </font>"
    end
    local function IG(pG)
        if pG == "Gold" then return Color3.fromRGB(255, 215, 0)
        elseif pG == "Diamond" then return Color3.fromRGB(0, 255, 255)
        elseif pG == "Cursed" then return Color3.fromRGB(200, 0, 0)
        elseif pG == "YinYang" then return Color3.fromRGB(255, 255, 255)
        elseif pG == "Candy" then return Color3.fromRGB(255, 105, 180)
        elseif pG == "Divine" then return Color3.fromRGB(255, 255, 255)
        elseif pG == "Rainbow" then return Color3.fromRGB(148, 0, 211)
        elseif pG == "Radioactive" then return Color3.fromRGB(132, 255, 0)
        elseif pG == "Galaxy" then return Color3.fromRGB(170, 85, 255) end
        return Color3.fromRGB(180, 180, 180)
    end
    local function pG(jG)
        local lG = jG and jG.petName or "Unknown"
        return lG
    end
    local function jG(lG)
        local WG = lG and lG.mutation
        if WG and WG ~= "None" and WG ~= "" then return TG(WG), true end
        return "", false
    end
    local tgCache, tgCacheT, tgCacheLen = nil, 0, -1
    local function TG()
        local now = os.clock()
        if tgCache and tgCacheLen == #yG and now - tgCacheT < 0.1 then return tgCache end
        local lG = {}
        tgCache, tgCacheT, tgCacheLen = lG, now, #yG
        for WG, WG in ipairs(yG) do
            if WG.genValue >= 1 and not YG(WG) then
                table.insert(lG, {
                    petName = WG.name, mpsText = WG.genText, mpsValue = WG.genValue,
                    owner = WG.owner, plot = WG.plot, slot = WG.slot, uid = WG.uid,
                    mutation = WG.mutation, animalData = WG,
                })
            end
        end
        return lG
    end

    local function M(entry)
        if not entry then return nil end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local plot = plots:FindFirstChild(entry.plot)
        if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return nil end
        local slot = podiums:FindFirstChild(entry.slot)
        if not slot then return nil end
        local base = slot:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        if spawn then return spawn end
        return base
    end


    local NoBrainrotsGui = Instance.new("ScreenGui")
    NoBrainrotsGui.Name = "NoBrainrotsDangerNotification"
    NoBrainrotsGui.ResetOnSpawn = false
    NoBrainrotsGui.IgnoreGuiInset = true
    NoBrainrotsGui.DisplayOrder = 10000
    NoBrainrotsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NoBrainrotsGui.Parent = LP:WaitForChild("PlayerGui")

    local NoBrainrotsSound = Instance.new("Sound", NoBrainrotsGui)
    NoBrainrotsSound.Name = "NoBrainrotsNotification"
    NoBrainrotsSound.SoundId = "rbxassetid://7383525713"
    NoBrainrotsSound.Volume = 2.5
    NoBrainrotsSound.PlaybackSpeed = 1.0

    local NoBrainrotsText = Instance.new("TextLabel", NoBrainrotsGui)
    NoBrainrotsText.Name = "NoBrainrotsNotice"
    NoBrainrotsText.AnchorPoint = Vector2.new(0.5, 0.5)
    NoBrainrotsText.Size = UDim2.new(0.9, 0, 0, 140)
    NoBrainrotsText.Position = UDim2.new(0.5, 0, 0.5, 0)
    NoBrainrotsText.BackgroundTransparency = 1
    NoBrainrotsText.BorderSizePixel = 0
    NoBrainrotsText.Visible = false
    NoBrainrotsText.Font = Enum.Font.GothamBlack
    NoBrainrotsText.TextSize = 42
    NoBrainrotsText.TextColor3 = Color3.fromRGB(255, 140, 20)
    NoBrainrotsText.TextStrokeColor3 = Color3.fromRGB(45, 12, 0)
    NoBrainrotsText.TextStrokeTransparency = 0.05
    NoBrainrotsText.TextWrapped = true
    NoBrainrotsText.TextXAlignment = Enum.TextXAlignment.Center
    NoBrainrotsText.TextYAlignment = Enum.TextYAlignment.Center
    NoBrainrotsText.Text = "BUY A BRAINROT FOR AUTO GRAB TO WORK"
    NoBrainrotsText.ZIndex = 999

    local NoBrainrotsGradient = Instance.new("UIGradient", NoBrainrotsText)
    NoBrainrotsGradient.Name = "DangerGradient"
    NoBrainrotsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 0, 0)),
    })
    NoBrainrotsGradient.Rotation = 0

    local noBrainrotsActive = false
    local noBrainrotsNoticeToken = 0

    local function setNoBrainrotsNotice(active)
        if not active then
            noBrainrotsActive = false
            noBrainrotsNoticeToken = noBrainrotsNoticeToken + 1
            NoBrainrotsText.Visible = false
            pcall(function() NoBrainrotsSound:Stop() end)
            return
        end
        if noBrainrotsActive then return end
        noBrainrotsActive = true
        noBrainrotsNoticeToken = noBrainrotsNoticeToken + 1
        local token = noBrainrotsNoticeToken
        task.spawn(function()
            for i = 1, 2 do
                if not noBrainrotsActive or noBrainrotsNoticeToken ~= token then return end
                NoBrainrotsText.Visible = true
                task.wait(0.003)
                if not noBrainrotsActive or noBrainrotsNoticeToken ~= token then
                    NoBrainrotsText.Visible = false
                    return
                end
                local soundStarted = false
                pcall(function()
                    NoBrainrotsSound.Looped = false
                    NoBrainrotsSound:Stop()
                    NoBrainrotsSound.TimePosition = 0
                    NoBrainrotsSound.Volume = 2.5
                    NoBrainrotsSound:Play()
                    soundStarted = true
                end)
                if soundStarted then
                    local ended = false
                    local connection
                    connection = NoBrainrotsSound.Ended:Connect(function() ended = true end)
                    local startedAt = os.clock()
                    while not ended and noBrainrotsActive and noBrainrotsNoticeToken == token do
                        if os.clock() - startedAt >= 15 then break end
                        task.wait(0.05)
                    end
                    if connection then connection:Disconnect() end
                end
                NoBrainrotsText.Visible = false
                if i < 3 then task.wait(0.05) end
            end
            if noBrainrotsNoticeToken == token then
                NoBrainrotsText.Visible = false
                pcall(function() NoBrainrotsSound:Stop() end)
            end
        end)
    end

    local function sG(SG, NG)
        KG()
        if OG and NG then
            for CB, rB in ipairs(NG) do
                if rB.uid == OG then iG = CB break end
            end
        end
        local oG = NG and NG[iG]
        P.SelectedPetData = oG
        if NG and #NG > 0 then
            setNoBrainrotsNotice(false)
        elseif NG and #NG == 0 then
            setNoBrainrotsNotice(true)
        end
        if SG then
            if oG then
                MG.Text = string.format("%s - %s", oG.petName or "Unknown", oG.mpsText or "")
            else
                MG.Text = "Searching..."
            end
        else
            MG.Text = "No target"
            if zG then zG:Cancel() zG = nil end
            bG.Size = UDim2.new(0, 0, 1, 0)
        end
        FG.Text = string.format("%d%%", math.clamp(math.floor(bG.Size.X.Scale * 100 + 0.5), 0, 100))
    end
    P.UpdateAutoStealUI = function() sG(nG, TG()) end
    task.spawn(function()
        while bG and bG.Parent do
            local oG = math.clamp(math.floor(bG.Size.X.Scale * 100 + 0.5), 0, 100)
            FG.Text = tostring(oG) .. "%"
            task.wait(0.05)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1.5)
            if not xG then continue end
            xG = false QG = false VG = false
            i.InstantSteal = false
            _G.NEAREST_INSTANT_MODE = false
            task.wait(0.05)
            xG = true
            i.InstantSteal = true
            _G.NEAREST_INSTANT_MODE = (fG and true)
        end
    end)

    local function b(KG)
        if not KG then return nil end
        local oG = cG[KG.uid]
        if oG and oG.Parent then return oG end
        local oG = workspace.Plots:FindFirstChild(KG.plot)
        if not oG then return nil end
        local IG = oG:FindFirstChild("AnimalPodiums")
        if not IG then return nil end
        local pG = dG(oG.Name)
        local jG = pG and pG.AnimalList
        if not jG then
            local pG = IG:FindFirstChild(KG.slot)
            if pG then
                local lG = pG:FindFirstChild("Base")
                local pG = lG and lG:FindFirstChild("Spawn")
                if pG then
                    local lG = pG:FindFirstChild("PromptAttachment")
                    if lG then
                        for pG, pG in ipairs(lG:GetChildren()) do
                            if pG:IsA("ProximityPrompt") then cG[KG.uid] = pG return pG end
                        end
                    end
                end
            end
            return nil
        end
        if not jG then return nil end
        local pG = KG.name and KG.name:lower() or ""
        local lG = KG.slot
        local WG = nil
        for XG, tG in pairs(jG) do
            if type(tG) == "table" and tostring(XG) == lG then
                local jG, lG = tG.Index, rG[tG.Index]
                if lG and (lG.DisplayName or jG):lower() == pG then WG = IG:FindFirstChild(tostring(XG)) break end
            end
        end
        if not WG then WG = IG:FindFirstChild(KG.slot) end
        if WG then
            local IG = WG:FindFirstChild("Base")
            local jG = IG and IG:FindFirstChild("Spawn")
            if jG then
                local IG = jG:FindFirstChild("PromptAttachment")
                if IG then
                    for lG, lG in ipairs(IG:GetChildren()) do
                        if lG:IsA("ProximityPrompt") and lG.Enabled and lG.ActionText == "Steal" then cG[KG.uid] = lG return lG end
                    end
                end
                local IG = jG.Position
                local jG, lG = IG.X, IG.Z
                local WG = nil
                local XG = math.huge
                for tG, tG in pairs(oG:GetDescendants()) do
                    if tG:IsA("ProximityPrompt") and tG.Enabled and tG.ActionText == "Steal" then
                        local oG = tG.Parent
                        local GG = nil
                        if oG and oG:IsA("BasePart") then GG = oG.Position
                        elseif oG and oG:IsA("Attachment") and oG.Parent and oG.Parent:IsA("BasePart") then GG = oG.Parent.Position end
                        if GG then
                            local oG = IG.Y
                            if pG:find("la secret combinasion") then oG = IG.Y - 5 end
                            local IG = math.sqrt((GG.X - jG) ^ 2 + (GG.Z - lG) ^ 2)
                            if IG < 5 and GG.Y > oG then
                                local IG = GG.Y - oG
                                if IG < XG then XG = IG WG = tG end
                            end
                        end
                    end
                end
                if WG then cG[KG.uid] = WG return WG end
            end
        end
        return nil
    end
    local function KG(oG)
        if qG[oG] then return end
        local IG = { holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true }
        local pG, jG = pcall(getconnections, oG.PromptButtonHoldBegan)
        if pG and type(jG) == "table" then
            for pG, pG in ipairs(jG) do if type(pG.Function) == "function" then table.insert(IG.holdCallbacks, pG.Function) end end
        end
        local pG, jG = pcall(getconnections, oG.Triggered)
        if pG and type(jG) == "table" then
            for pG, pG in ipairs(jG) do if type(pG.Function) == "function" then table.insert(IG.triggerCallbacks, pG.Function) end end
        end
        local pG, jG = pcall(getconnections, oG.PromptButtonHoldEnded)
        if pG and type(jG) == "table" then
            for pG, pG in ipairs(jG) do if type(pG.Function) == "function" then table.insert(IG.holdEndCallbacks, pG.Function) end end
        end
        if #IG.holdCallbacks > 0 or #IG.triggerCallbacks > 0 or #IG.holdEndCallbacks > 0 then qG[oG] = IG end
    end

    local STEAL_LOGGER_RUNTIME
    pcall(function()
        local env = (type(getgenv) == "function" and getgenv()) or _G
        if env then
            env.__SWEET_STEAL_LOGGER_RUNTIME = (env.__SWEET_STEAL_LOGGER_RUNTIME or 0) + 1
            STEAL_LOGGER_RUNTIME = env.__SWEET_STEAL_LOGGER_RUNTIME
        end
    end)
    STEAL_LOGGER_RUNTIME = STEAL_LOGGER_RUNTIME or 1

    local STEAL_WEBHOOK_URL = ""
    local STEAL_SUCCESS_DEDUPE_SECONDS = 12
    local pendingSteals = {}
    local watchedSuccessLabels = {}

    local STEAL_LOGGER_STATE
    pcall(function()
        local env = (type(getgenv) == "function" and getgenv()) or _G
        if env then
            env.__SWEET_STEAL_LOGGER_STATE = env.__SWEET_STEAL_LOGGER_STATE or { recent = {} }
            STEAL_LOGGER_STATE = env.__SWEET_STEAL_LOGGER_STATE
        end
    end)
    STEAL_LOGGER_STATE = STEAL_LOGGER_STATE or { recent = {} }
    local recentStealLogs = STEAL_LOGGER_STATE.recent

    local function normalizeStealName(name)
        name = tostring(name or "")
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        name = name:gsub("[%z\1-\31]", "")
        return name
    end

    local function getStealPlotAndSlot(prompt, slotName)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil, nil end
        local plot = prompt and prompt:FindFirstAncestorWhichIsA("Model")
        while plot and plot.Parent and plot.Parent ~= plots do
            plot = plot.Parent
        end
        if not plot or not plot.Parent then return nil, nil end
        return plot, tostring(slotName or "")
    end

    local function getAnimalListEntry(plotName, slotName)
        if not plotName or not slotName or slotName == "" then return nil, nil end
        local plotData = dG(plotName)
        local animals = plotData and plotData.AnimalList
        if type(animals) ~= "table" then return plotData, nil end
        for key, value in pairs(animals) do
            if tostring(key) == tostring(slotName) then
                return plotData, value
            end
        end
        return plotData, nil
    end

    local function buildStealEntry(plotName, slotName, raw, fallback)
        if type(raw) == "table" and raw.Index then
            local index = raw.Index
            local animal = rG[index]
            if animal then
                local mutation = raw.Mutation or "None"
                if mutation == "Yin Yang" then mutation = "YinYang" end
                local genValue = CG(index, raw.Mutation, raw.Traits)
                local plotData = dG(plotName)
                local owner = plotData and plotData.Owner
                owner = owner and (owner.Name or tostring(owner)) or "Unknown"
                return {
                    petName = animal.DisplayName or tostring(index),
                    mpsText = "$" .. JG(genValue) .. "/s",
                    mpsValue = genValue,
                    mutation = mutation,
                    owner = owner,
                    plot = plotName,
                    slot = tostring(slotName),
                    uid = tostring(plotName) .. "_" .. tostring(slotName),
                    _index = tostring(index),
                    _mutation = tostring(raw.Mutation or "None"),
                    _traits = type(raw.Traits) == "table" and table.concat(raw.Traits, ",") or tostring(raw.Traits or ""),
                }
            end
        end
        return fallback
    end

    local function findCachedStealEntry(itemName)
        local wanted = normalizeStealName(itemName):lower()
        if wanted == "" then return nil end
        for _, entry in ipairs(yG) do
            if normalizeStealName(entry.name or entry.petName):lower() == wanted then
                return {
                    petName = entry.name or entry.petName,
                    mpsText = entry.genText or entry.mpsText or "Unknown",
                    mpsValue = entry.genValue,
                    mutation = entry.mutation or "None",
                    owner = entry.owner or "Unknown",
                    plot = entry.plot,
                    slot = entry.slot,
                    uid = entry.uid,
                }
            end
        end
        return nil
    end

    local function getWebhookRequest()
        local fn = nil
        pcall(function()
            local env = (type(getgenv) == "function" and getgenv()) or _G
            if syn and type(syn.request) == "function" then
                fn = syn.request
            elseif env and type(env.request) == "function" then
                fn = env.request
            elseif type(request) == "function" then
                fn = request
            elseif type(http_request) == "function" then
                fn = http_request
            elseif http and type(http.request) == "function" then
                fn = http.request
            elseif fluxus and type(fluxus.request) == "function" then
                fn = fluxus.request
            elseif type(krnl_request) == "function" then
                fn = krnl_request
            end
        end)
        return fn
    end

    local imageUrlCache = {}
    local imageLookupInFlight = {}

    local function urlEncode(value)
        value = tostring(value or "")
        return (value:gsub("[^%w%-%._~ ]", function(ch)
            return string.format("%%%02X", string.byte(ch))
        end):gsub(" ", "%%20"))
    end

    local function getWikiPageImageUrl(itemName)
        local clean = normalizeStealName(itemName)
        if clean == "" then return nil end
        local cacheKey = clean:lower()
        if imageUrlCache[cacheKey] then
            return imageUrlCache[cacheKey]
        end
        if imageLookupInFlight[cacheKey] then
            return nil
        end
        local requestFn = getWebhookRequest()
        if not requestFn then return nil end
        imageLookupInFlight[cacheKey] = true
        local title = urlEncode(clean:gsub(" ", "_"))
        local apiUrl = "https://stealabrainrot.fandom.com/api.php?action=query&prop=pageimages&piprop=original&format=json&titles=" .. title
        local result
        local ok, response = pcall(function()
            return requestFn({ Url = apiUrl, Method = "GET", Headers = { ["Accept"] = "application/json" } })
        end)
        if ok and response and tonumber(response.StatusCode or response.Status or 200) >= 200 and tonumber(response.StatusCode or response.Status or 200) < 300 then
            local body = response.Body or response.body
            if type(body) == "string" and #body > 0 then
                local decodedOk, data = pcall(function() return HttpService:JSONDecode(body) end)
                if decodedOk and type(data) == "table" and data.query and type(data.query.pages) == "table" then
                    for _, page in pairs(data.query.pages) do
                        if type(page) == "table" and type(page.original) == "table" and type(page.original.source) == "string" then
                            result = page.original.source
                            break
                        end
                    end
                end
            end
        end
        imageLookupInFlight[cacheKey] = nil
        if result and result ~= "" then
            imageUrlCache[cacheKey] = result
        end
        return result
    end

    local function attachBrainrotImage(embed, itemName)
        local imageUrl = getWikiPageImageUrl(itemName)
        if imageUrl then
            embed.thumbnail = { url = imageUrl }
        end
    end

    local function sendStealWebhook(entry)
        if not entry then return end
        if STEAL_WEBHOOK_URL == "" then return end
        local itemName = normalizeStealName(entry.petName or entry.name or "Unknown")
        if itemName == "" then itemName = "Unknown" end
        local mps = tostring(entry.mpsText or "Unknown")
        local mutation = tostring(entry.mutation or "None")
        local stolenFrom = tostring(entry.owner or "Unknown")
        local stolenBy = tostring(LP.DisplayName or LP.Name or "Unknown")
        local embed = {
            title = itemName,
            description = "## STEAL SUCCESSFUL\nA Brainrot steal was confirmed in-game.",
            color = 0xFF8C14,
            fields = {
                { name = "Brainrot", value = itemName, inline = true },
                { name = "Generation", value = mps, inline = true },
                { name = "Mutation", value = mutation, inline = true },
                { name = "Stolen From", value = stolenFrom, inline = true },
                { name = "Stolen By", value = stolenBy, inline = true },
                { name = "You Stole", value = itemName, inline = false },
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }
        attachBrainrotImage(embed, itemName)
        local payload = { username = "Sweet tp steal", embeds = { embed } }
        local body = HttpService:JSONEncode(payload)
        task.spawn(function()
            local requestFn = getWebhookRequest()
            if requestFn then
                local ok, response = pcall(function()
                    return requestFn({ Url = STEAL_WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
                end)
                if ok and response then
                    local code = tonumber(response.StatusCode or response.Status or 204)
                    if not code or (code >= 200 and code < 300) then return end
                end
            end
            pcall(function()
                HttpService:RequestAsync({
                    Url = STEAL_WEBHOOK_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body,
                })
            end)
        end)
    end

    local function logConfirmedSteal(itemName, preferredEntry)
        itemName = normalizeStealName(itemName)
        if itemName == "" then return end
        local dedupeKey = itemName:lower()
        local now = os.clock()
        if recentStealLogs[dedupeKey] and (now - recentStealLogs[dedupeKey]) < STEAL_SUCCESS_DEDUPE_SECONDS then
            return
        end
        local entry = preferredEntry or findCachedStealEntry(itemName)
        if not entry then
            local newest, newestAge = nil, math.huge
            for _, pending in pairs(pendingSteals) do
                local pendingName = normalizeStealName(pending.entry and pending.entry.petName)
                local age = now - (pending.time or now)
                if pendingName:lower() == dedupeKey and age >= 0 and age < 8 and age < newestAge then
                    newest, newestAge = pending, age
                end
            end
            entry = newest and newest.entry or nil
        end
        if not entry then
            entry = { petName = itemName, mpsText = "Unknown", mutation = "None", owner = "Unknown" }
        end
        recentStealLogs[dedupeKey] = now
        sendStealWebhook(entry)
    end

    local function capturePendingSteal(prompt, slotName)
        local plot, wantedSlot = getStealPlotAndSlot(prompt, slotName)
        if not plot or wantedSlot == "" then return end
        local plotData, raw = getAnimalListEntry(plot.Name, wantedSlot)
        local fallback = nil
        for _, entry in ipairs(yG) do
            if tostring(entry.plot) == tostring(plot.Name) and tostring(entry.slot) == tostring(wantedSlot) then
                fallback = {
                    petName = entry.name,
                    mpsText = entry.genText,
                    mpsValue = entry.genValue,
                    mutation = entry.mutation,
                    owner = entry.owner,
                    plot = entry.plot,
                    slot = entry.slot,
                    uid = entry.uid,
                }
                break
            end
        end
        local entry = buildStealEntry(plot.Name, wantedSlot, raw, fallback)
        if not entry then return end
        local key = tostring(plot.Name) .. "|" .. tostring(wantedSlot)
        pendingSteals[key] = { entry = entry, time = os.clock() }
    end

    local function consumePendingForSuccess(itemName)
        itemName = normalizeStealName(itemName):lower()
        local now = os.clock()
        local bestKey, best, bestAge = nil, nil, math.huge
        for key, pending in pairs(pendingSteals) do
            local pendingName = normalizeStealName(pending.entry and pending.entry.petName):lower()
            local age = now - (pending.time or now)
            if pendingName == itemName and age >= 0 and age < 8 and age < bestAge then
                bestKey, best, bestAge = key, pending, age
            end
        end
        if bestKey then pendingSteals[bestKey] = nil end
        return best and best.entry or nil
    end

    local function processSuccessText(text)
        if type(text) ~= "string" then return end
        local currentRuntime
        pcall(function()
            local env = (type(getgenv) == "function" and getgenv()) or _G
            currentRuntime = env and env.__SWEET_STEAL_LOGGER_RUNTIME or STEAL_LOGGER_RUNTIME
        end)
        if currentRuntime ~= STEAL_LOGGER_RUNTIME then return end
        text = text:gsub("<[^>]->", "")
        local itemName = text:match("^%s*You%s+stole%s+(.+)%s*$")
        if not itemName then return end
        itemName = normalizeStealName(itemName)
        if itemName == "" then return end
        local entry = consumePendingForSuccess(itemName)
        logConfirmedSteal(itemName, entry)
    end

    local function watchSuccessLabel(obj)
        if not obj or watchedSuccessLabels[obj] then return end
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        watchedSuccessLabels[obj] = true
        pcall(function() processSuccessText(obj.Text) end)
        obj:GetPropertyChangedSignal("Text"):Connect(function()
            processSuccessText(obj.Text)
        end)
    end

    local pg = LP:WaitForChild("PlayerGui")
    for _, obj in ipairs(pg:GetDescendants()) do
        watchSuccessLabel(obj)
    end
    pg.DescendantAdded:Connect(function(obj) watchSuccessLabel(obj) end)

    local function oG(IG) for pG, pG in ipairs(IG) do task.spawn(pG) end end
    local function IG(pG)
        local jG = dG(pG)
        if jG then return S(jG.Owner) end
        return false
    end
    local function pG()
        local jG = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not jG then return nil, math.huge, nil end
        local lG = workspace:FindFirstChild("Plots")
        if not lG then return nil, math.huge, nil end
        local WG, XG, tG = nil, math.huge, nil
        for GG, GG in ipairs(lG:GetChildren()) do
            if IG(GG.Name) then continue end
            local IG = math.huge
            pcall(function() IG = (GG:GetPivot().Position - jG.Position).Magnitude end)
            if IG > 100 then continue end
            local IG = GG:FindFirstChild("AnimalPodiums")
            if not IG then continue end
            for lG, lG in ipairs(IG:GetChildren()) do
                local IG = lG:FindFirstChild("Base")
                local GG = IG and IG:FindFirstChild("Spawn")
                if not GG then continue end
                local IG = (GG.Position - jG.Position).Magnitude
                if IG > 60 or IG >= XG then continue end
                local jG = GG:FindFirstChild("PromptAttachment")
                if not jG then continue end
                local GG = jG:FindFirstChildOfClass("ProximityPrompt")
                if GG and GG.Parent and GG.Enabled then WG = GG XG = IG tG = lG.Name end
            end
        end
        return WG, XG, tG
    end

    local function IG_(jG, lG)
        local WG = qG[jG]
        if not WG or not WG.ready then return false end
        WG.ready = false
        task.spawn(function()
            if BG ~= lG then
                if zG then zG:Cancel() end
                wG.Size = UDim2.new(0, 0, 1, 0)
                BG = lG
            end
            if #WG.holdCallbacks > 0 then oG(WG.holdCallbacks) end
            wG.Size = UDim2.new(0, 0, 1, 0)
            wG.BackgroundTransparency = 0
            zG = TweenService:Create(wG, TweenInfo.new(1.2, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) })
            zG:Play()
            zG.Completed:Wait()
            if BG == lG then
                capturePendingSteal(jG, lG)
                if #WG.triggerCallbacks > 0 then
                    oG(WG.triggerCallbacks)
                end
            end
            WG.ready = true
        end)
        return true
    end
    local function oG_(jG, lG)
        if not jG or not jG.Parent then return false end
        KG(jG)
        if not qG[jG] then return false end
        if BG ~= lG then
            if zG then zG:Cancel() zG = nil end            wG.Size = UDim2.new(0, 0, 1, 0)
        end
        return IG_(jG, lG)
    end
    local function qG_()
        for BG, BG in pairs(cG) do if BG and BG.Parent then KG(BG) end end
    end
    task.spawn(function()
        while task.wait(2) do
            if nG then qG_() end
        end
    end)

    local KG_ = {}
    local function qG_2(BG)
        if not BG then return "" end
        local IG = ""
        for jG, lG in pairs(BG) do
            if type(lG) == "table" then IG = IG .. tostring(jG) .. tostring(lG.Index) .. tostring(lG.Mutation) end
        end
        return IG
    end
    local function BG_(IG)
        local jG = false
        pcall(function()
            local lG = dG(IG.Name)
            if not lG then return end
            local WG = lG.AnimalList
            local XG = lG.Owner
            if not XG or S(XG) or typeof(XG) == "Instance" and not Players:FindFirstChild(XG.Name) or type(XG) == "string" and not Players:FindFirstChild(XG) then
                KG_[IG.Name] = nil
                for S = #yG, 1, -1.0 do if yG[S].plot == IG.Name then table.remove(yG, S) jG = true end end
                return
            end
            if not WG then
                KG_[IG.Name] = nil
                for S = #yG, 1, -1.0 do if yG[S].plot == IG.Name then table.remove(yG, S) jG = true end end
                return
            end
            local S = typeof(XG) == "Instance" and XG.Name or tostring(XG)
            local lG = qG_2(WG)
            if KG_[IG.Name] == lG then return end
            for qG = #yG, 1, -1.0 do if yG[qG].plot == IG.Name then table.remove(yG, qG) end end
            for qG, XG in pairs(WG) do
                if type(XG) == "table" then
                    local WG, tG = XG.Index, rG[XG.Index]
                    if tG then
                        local rG = XG.Mutation or "None"
                        if rG == "Yin Yang" then rG = "YinYang" end
                        local GG = XG.Traits and #XG.Traits > 0 and table.concat(XG.Traits, ", ") or "None"
                        local vG = CG(WG, XG.Mutation, XG.Traits)
                        local CG2 = "$" .. JG(vG) .. "/s"
                        table.insert(yG, { name = tG.DisplayName or WG, genText = CG2, genValue = vG, mutation = rG, traits = GG, owner = S, plot = IG.Name, slot = tostring(qG), uid = IG.Name .. "_" .. tostring(qG) })
                    end
                end
            end
            KG_[IG.Name] = lG
            jG = true
        end)
        if jG then
            table.sort(yG, function(S, CG) return S.genValue > CG.genValue end)
            P.AllAnimalsCache = yG
            P.ListNeedsRedraw = true
            if P.UpdateAutoStealUI then P.UpdateAutoStealUI() end
        end
    end
    local function S_(CG)
        local rG2, JG = nil, 0
        while not rG2 and JG < 40 do
            rG2 = dG(CG.Name)
            if not rG2 then JG = JG + 1 task.wait(0.07) end
        end
        if not rG2 then return end
        BG_(CG)
        local function hook(JG)
            if not JG then return end
            JG.ChildAdded:Connect(function() task.wait(0.15) BG_(CG) end)
            JG.ChildRemoved:Connect(function()
                for JG = #yG, 1, -1.0 do if yG[JG].plot == CG.Name then table.remove(yG, JG) end end
                KG_[CG.Name] = nil
                for JG in pairs(cG) do if JG:sub(1, #CG.Name) == CG.Name then cG[JG] = nil end end
                P.ListNeedsRedraw = true
                if P.UpdateAutoStealUI then P.UpdateAutoStealUI() end
                task.wait(0.15)
                BG_(CG)
            end)
        end
        local JG = CG:FindFirstChild("AnimalPodiums")
        hook(JG)
        CG.ChildAdded:Connect(function(JG) if JG.Name == "AnimalPodiums" then hook(JG) BG_(CG) end end)
        CG.ChildRemoved:Connect(function(rG2)
            if rG2.Name == "AnimalPodiums" then
                for rG2 = #yG, 1, -1.0 do if yG[rG2].plot == CG.Name then table.remove(yG, rG2) end end
                KG_[CG.Name] = nil
                P.ListNeedsRedraw = true
                if P.UpdateAutoStealUI then P.UpdateAutoStealUI() end
            end
        end)
        task.spawn(function()
            while CG.Parent do task.wait(10) BG_(CG) end
        end)
    end
    local plotsFolder = workspace:WaitForChild("Plots", 8)
    if plotsFolder then
        for rG2, rG2 in ipairs(plotsFolder:GetChildren()) do S_(rG2) end
        plotsFolder.ChildAdded:Connect(function(rG2) task.wait(0.5) S_(rG2) end)
        plotsFolder.ChildRemoved:Connect(function(S)
            KG_[S.Name] = nil
            for CG = #yG, 1, -1.0 do if yG[CG].plot == S.Name then table.remove(yG, CG) end end
            for CG in pairs(cG) do if CG:sub(1, #S.Name) == S.Name then cG[CG] = nil end end
            P.ListNeedsRedraw = true
            if P.UpdateAutoStealUI then P.UpdateAutoStealUI() end
        end)
    end

    local function S2(CG)
        if #CG == 0 then
            MG.Text = "No target"
            setNoBrainrotsNotice(true)
            return
        end
        setNoBrainrotsNotice(false)
        if UG then
            for rG2, dG in ipairs(CG) do
                if dG.uid == UG then
                    if iG ~= rG2 then iG = rG2 OG = dG.uid end
                    MG.Text = string.format("%s - %s", dG.petName or "Unknown", dG.mpsText or "")
                    return
                end
            end
            UG = nil
        end
        if eG then
            for rG2, rG2 in ipairs(i.PriorityList) do
                local dG = rG2:lower()
                for rG2, JG in ipairs(CG) do
                    if JG.petName and JG.petName:lower() == dG then
                        if iG ~= rG2 then iG = rG2 OG = JG.uid end
                        MG.Text = string.format("%s - %s", JG.petName or "Unknown", JG.mpsText or "")
                        return
                    end
                end
            end
            if iG ~= 1 then iG = 1 OG = CG[1] and CG[1].uid end
            local first = CG[iG]
            if first then
                MG.Text = string.format("%s - %s", first.petName or "Unknown", first.mpsText or "")
            end
        elseif fG then
            local rG2 = LP.Character
            local dG = rG2 and rG2:FindFirstChild("HumanoidRootPart")
            if dG then
                local rG2, JG = 1, math.huge
                for eG2, KG in ipairs(CG) do
                    local qG = KG.animalData and M(KG.animalData)
                    if qG then
                        local KG2 = (dG.Position - qG.Position).Magnitude
                        if KG2 < JG then JG = KG2 rG2 = eG2 end
                    end
                end
                if CG[rG2] then
                    local dG2 = CG[rG2]
                    MG.Text = string.format("%s - %s", dG2.petName or "Unknown", dG2.mpsText or "")
                end
                if not xG and iG ~= rG2 then iG = rG2 OG = CG[rG2] and CG[rG2].uid end
            end
        elseif aG then
            if iG ~= 1 then iG = 1 OG = CG[1] and CG[1].uid end
            local first = CG[iG]
            if first then
                MG.Text = string.format("%s - %s", first.petName or "Unknown", first.mpsText or "")
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        if not nG then return end
        S2(TG())
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if nG then
                local S = TG()
                if #S > 0 then
                    sG(nG, S)
                else
                    MG.Text = "No target"
                    setNoBrainrotsNotice(true)
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not nG then return end
        if xG then
            if zG then zG:Cancel() zG = nil end
            wG.Size = UDim2.new(1, 0, 1, 0)
            wG.BackgroundTransparency = 0
            if not VG then
                VG = true
                task.spawn(function()
                    if not game:IsLoaded() then game.Loaded:Wait() end
                    task.wait(0.5)
                    QG = true
                end)
            end
            if QG then
                if not (fG and not UG) then
                    local S = TG()
                    if #S > 0 then
                        if iG > #S then iG = #S end
                        if iG < 1 then iG = 1 end
                        local CG = S[iG]
                        if CG and not YG(CG.animalData) then
                            local S = cG[CG.uid]
                            if not S or not S.Parent then S = b(CG.animalData) end
                        end
                    end
                end
            end
            return
        end
        local S = TG()
        if #S == 0 then return end
        if iG > #S then iG = #S end
        if iG < 1 then iG = 1 end
        local CG = S[iG]
        if not CG or YG(CG.animalData) then return end
        local S = cG[CG.uid]
        if not S or not S.Parent then S = b(CG.animalData) end
        if S then oG_(S, CG.uid) end
    end)
    task.spawn(function()
        while task.wait(0.5) do sG(nG, TG()) end
    end)
    task.spawn(function()
        task.wait(1)
        sG(nG, TG())
    end)
    task.spawn(function()
        while true do P.AllAnimalsCache = yG task.wait(0.5) end
    end)
end)

-- ============================================================
-- NAMETAGS + HIGHLIGHTS
-- ============================================================
local MaxDistance = 400.5
local NametagsEnabled = true

local function CreateNametag(Player)
    if Player == LP then return end
    local function setup(Character)
        local Head = Character:FindFirstChild("Head")
        if not Head then return end
        local old = Head:FindFirstChild("Nametag")
        if old then old:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "Nametag"
        bb.Adornee = Head
        bb.Size = UDim2.new(0, 75, 0, 150)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Text = Player.Name
        lbl.TextColor3 = Color3.fromRGB(255, 200, 90)
        lbl.BackgroundTransparency = 1
        lbl.TextStrokeTransparency = 0.75
        lbl.Font = Enum.Font.Code
        lbl.TextScaled = true
        lbl.Parent = bb
        bb.Parent = Head
        local function updateVis()
            if NametagsEnabled and Player.Character and Player.Character:FindFirstChild("Head") and LP.Character and LP.Character:FindFirstChild("Head") then
                local d = (Player.Character.Head.Position - LP.Character.Head.Position).Magnitude
                bb.Enabled = (d <= MaxDistance)
            else
                bb.Enabled = false
            end
        end
        local conn
        local lastVis = 0
        conn = RunService.Heartbeat:Connect(function()
            local nowV = os.clock()
            if nowV - lastVis < 0.25 then return end
            lastVis = nowV
            if Player.Character and Player.Character:FindFirstChild("Head") then
                updateVis()
            else
                bb:Destroy()
                conn:Disconnect()
            end
        end)
    end
    if Player.Character then setup(Player.Character) end
    Player.CharacterAdded:Connect(setup)
end

local function ApplyHighlight(Player)
    if Player == LP then return end
    local function setup(Character)
        for _, v in pairs(Character:GetChildren()) do
            if v:IsA("Highlight") then v:Destroy() end
        end
        local hl = Instance.new("Highlight")
        hl.Parent = Character
        local function update()
            hl.FillColor = Player.TeamColor and Player.TeamColor.Color or Color3.fromRGB(255, 140, 20)
        end
        update()
        Player:GetPropertyChangedSignal("TeamColor"):Connect(update)
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Died:Connect(function() hl:Destroy() end) end
    end
    if Player.Character then setup(Player.Character) end
    Player.CharacterAdded:Connect(setup)
end

local function ToggleNametags()
    NametagsEnabled = not NametagsEnabled
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LP and Player.Character and Player.Character:FindFirstChild("Head") then
            local nt = Player.Character.Head:FindFirstChild("Nametag")
            if nt then nt.Enabled = NametagsEnabled end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.LeftBracket then ToggleNametags() end
end)

-- ============================================================
-- FAKE AC CLEANUP + CHARACTER STRIP + LIGHTING
-- ============================================================
local function killFakeAC(v)
    if not v then return end
    pcall(function()
        if v.Name == "AnimationController" then
            if v:IsA("Humanoid") or v:IsA("AnimationController") then v:Destroy() end
        end
    end)
end

local function processModel(model)
    if not model then return end
    pcall(function()
        for _, v in pairs(model:GetChildren()) do
            if v.Name == "AnimationController" then killFakeAC(v) end
        end
        for _, v in pairs(model:GetDescendants()) do
            if v.Name == "AnimationController" then killFakeAC(v) end
        end
    end)
end

local function hookRMA(rma)
    if not rma then return end
    pcall(function()
        for _, child in pairs(rma:GetChildren()) do processModel(child) end
        rma.ChildAdded:Connect(function(child)
            task.spawn(function() task.wait(0.05) processModel(child) end)
        end)
        rma.DescendantAdded:Connect(function(v)
            if v.Name == "AnimationController" then
                task.spawn(function() task.wait(0.01) killFakeAC(v) end)
            end
        end)
    end)
end

local rma = workspace:FindFirstChild("RenderedMovingAnimals")
if rma then hookRMA(rma) end
workspace.ChildAdded:Connect(function(v)
    if v.Name == "RenderedMovingAnimals" then
        task.spawn(function() task.wait(0.05) hookRMA(v) end)
    end
end)

local function isBrainrot(v)
    if not v then return false end
    local p = v
    while p and p ~= game do
        local n = p.Name
        if n == "RenderedMovingAnimals" or n:find("Brainrot") or n:find("RenderedMoving") then return true end
        p = p.Parent
    end
    return false
end

local function strip(char)
    if not char then return end
    if isBrainrot(char) then return end
    pcall(function()
        for _, v in pairs(char:GetChildren()) do
            pcall(function()
                if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
                if v:IsA("Accessory") then v:Destroy() end
                if v:IsA("SpecialMesh") then v:Destroy() end
                if v:IsA("Clothing") then v:Destroy() end
                if v:IsA("BodyColors") then v:Destroy() end
                if v:IsA("Decal") and v.Name == "face" then v:Destroy() end
            end)
        end
        for _, v in pairs(char:GetDescendants()) do
            pcall(function()
                if v:IsA("Accessory") then v:Destroy() end
                if v:IsA("Clothing") then v:Destroy() end
                if v:IsA("SpecialMesh") then
                    if v.Parent and v.Parent.Name ~= "Head" then v:Destroy() end
                end
            end)
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local desc = hum:FindFirstChildOfClass("HumanoidDescription")
            if desc then
                pcall(function()
                    desc.Shirt = 0
                    desc.Pants = 0
                    desc.GraphicTShirt = 0
                    desc.HatAccessory = ""
                    desc.HairAccessory = ""
                    desc.FaceAccessory = ""
                    desc.NeckAccessory = ""
                    desc.ShouldersAccessory = ""
                    desc.FrontAccessory = ""
                    desc.BackAccessory = ""
                    desc.WaistAccessory = ""
                end)
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do
    if p.Character then strip(p.Character) end
end
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and not isBrainrot(v) then
        strip(v)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char) task.wait(0.3) strip(char) end)
end)
for _, p in pairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function(char) task.wait(0.3) strip(char) end)
end
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("Accessory") or v:IsA("Clothing") then
        task.spawn(function()
            local p = v.Parent
            while p and p ~= workspace do
                if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") and not isBrainrot(p) then
                    pcall(function() v:Destroy() end)
                    return
                end
                p = p.Parent
            end
        end)
    end
end)

local decalsyeeted = true
local l, t = Lighting, workspace.Terrain
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0
l.GlobalShadows = false
l.FogEnd = 9e9
l.Brightness = 0
settings().Rendering.QualityLevel = "Level01"

for _, v in pairs(game:GetDescendants()) do
    if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    end
end

pcall(function() setfpscap(1457) end)
for _, e in pairs(l:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end

for _, Player in pairs(Players:GetPlayers()) do
    CreateNametag(Player)
    ApplyHighlight(Player)
end
Players.PlayerAdded:Connect(function(Player)
    CreateNametag(Player)
    ApplyHighlight(Player)
end)

-- ============================================================
-- CONFIG LOAD
-- ============================================================
local function loadConfig()
    if readfile and isfile then
        pcall(function()
            if isfile(CONFIG_FILE) then
                local d = HttpService:JSONDecode(readfile(CONFIG_FILE))
                for k, v in pairs(d) do
                    if k == "Positions" and type(v) == "table" then
                        for pk, pv in pairs(v) do
                            if CONFIG.Positions[pk] and type(pv) == "table" then
                                CONFIG.Positions[pk].X = pv.X or CONFIG.Positions[pk].X
                                CONFIG.Positions[pk].Y = pv.Y or CONFIG.Positions[pk].Y
                            end
                        end
                    elseif CONFIG[k] ~= nil then
                        CONFIG[k] = v
                    end
                end
            end
        end)
    end
end
loadConfig()

-- ============================================================
-- STEAL BOOST
-- ============================================================
local StealBoost = {
    enabled = false,
    conn = nil,
    carryTarget = 28.8,
    crawlRatio = 0.72,
    staleTime = 90,
    _flag3 = false,
    _lastToggle = 0,
    _walkSpeed = nil,
    _minWalk = nil,
    _droveFrames = 0,
    _baseCache = nil,
    _baseline = nil,
    _crawlStart = nil,
}

function StealBoost._base()
    if StealBoost._baseCache then return StealBoost._baseCache end
    local ok, result = pcall(function()
        return game:GetService("StarterPlayer").CharacterWalkSpeed
    end)
    StealBoost._baseCache = (ok and type(result) == "number" and result > 0) and result or 34
    return StealBoost._baseCache
end

function StealBoost._trackBaseline(speed, now)
    if type(speed) ~= "number" or speed <= 0 then return end
    local S = StealBoost
    if S._baseline == nil or speed > S._baseline then
        S._baseline = speed
        S._crawlStart = nil
    elseif speed <= S._baseline * S.crawlRatio then
        S._crawlStart = S._crawlStart or now
        if S.staleTime < now - S._crawlStart then
            S._baseline = speed
            S._crawlStart = nil
        end
    else
        S._crawlStart = nil
        S._baseline = S._baseline + (speed - S._baseline) * 0.05
    end
end

function StealBoost._ceiling()
    local base = StealBoost._base()
    local b = StealBoost._baseline
    return (b and math.min(b, base) or base) * 0.6 * 1.1
end

function StealBoost._isCarrying()
    local S = StealBoost
    if S._walkSpeed == nil or S._baseline == nil then return false end
    return S._walkSpeed <= S._baseline * S.crawlRatio
end

function StealBoost._tick()
    local S = StealBoost
    if not S.enabled then
        if S._lastToggle ~= 0 then S._flag3 = false S._lastToggle = 0 end
        return
    end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local state = hum:GetState()
    if hum.PlatformStand
        or state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown then
        return
    end

    S._walkSpeed = hum.WalkSpeed
    S._trackBaseline(S._walkSpeed, os.clock())
    if S._minWalk == nil or S._walkSpeed < S._minWalk then S._minWalk = S._walkSpeed end

    if not S._isCarrying() then
        S._flag3 = false
        S._lastToggle = 0
        return
    end

    local md = hum.MoveDirection
    if md.Magnitude <= 0 then return end

    local target = S.carryTarget
    local drive
    if target <= S._ceiling() then
        S._flag3 = false
        S._lastToggle = 0
        drive = true
    else
        local now = os.clock()
        if S._lastToggle == 0 then
            S._lastToggle = now
            S._flag3 = true
        end
        if (S._flag3 and 1.1 or 0.9) <= now - S._lastToggle then
            S._flag3 = not S._flag3
            S._lastToggle = now
        end
        drive = S._flag3
    end

    if drive then
        hrp.Velocity = Vector3.new(md.X * target, hrp.Velocity.Y, md.Z * target)
        S._droveFrames = S._droveFrames + 1
    end
end

function StealBoost.Start()
    if StealBoost.enabled then return true end
    StealBoost.enabled = true
    StealBoost.conn = RunService.Heartbeat:Connect(function()
        pcall(StealBoost._tick)
    end)
    return true
end

function StealBoost.Stop()
    StealBoost.enabled = false
    if StealBoost.conn then StealBoost.conn:Disconnect() StealBoost.conn = nil end
    StealBoost._flag3 = false
    StealBoost._lastToggle = 0
end

_G.StealBoost = StealBoost

-- ============================================================
-- CARPET SPEED
-- ============================================================
local carpetNames = {
    "Santa's Sleigh","Cupid's Wings","Flying Carpet",
    "Witch's Broom","Waverider","Flying Bee",
}
local fallbackBatNames = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap"}
local TARGET_SPEED = 165

local CarpetSpeed = { enabled = false, currentCarpet = nil, conn = nil }

function CarpetSpeed.GetCarpet()
    local char = LP.Character
    local backpack = LP:FindFirstChild("Backpack")
    if char then
        for _, name in ipairs(carpetNames) do
            local tool = char:FindFirstChild(name)
            if tool and tool:IsA("Tool") then return tool end
        end
    end
    if backpack then
        for _, name in ipairs(carpetNames) do
            local tool = backpack:FindFirstChild(name)
            if tool and tool:IsA("Tool") then return tool end
        end
    end
    return nil
end

function CarpetSpeed.EnsureCarpet()
    local char = LP.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local tool = CarpetSpeed.GetCarpet()
    if not tool then CarpetSpeed.currentCarpet = nil return nil end
    CarpetSpeed.currentCarpet = tool
    if tool.Parent == LP.Backpack then hum:EquipTool(tool) end
    return tool
end

function CarpetSpeed.Start()
    if CarpetSpeed.enabled then return true end
    local tool = CarpetSpeed.GetCarpet()
    if not tool then return false end
    CarpetSpeed.enabled = true
    CarpetSpeed.conn = RunService.Heartbeat:Connect(function()
        if not CarpetSpeed.enabled then return end
        local c = LP.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return end
        local nowC = os.clock()
        if not CarpetSpeed._lastEnsure or nowC - CarpetSpeed._lastEnsure >= 0.25 then
            CarpetSpeed._lastEnsure = nowC
            CarpetSpeed.EnsureCarpet()
        end
        local md = hum.MoveDirection
        local yv = hrp.AssemblyLinearVelocity.Y
        if md.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(md.X * TARGET_SPEED, yv, md.Z * TARGET_SPEED)
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, yv, 0)
        end
    end)
    return true
end

function CarpetSpeed.Stop()
    CarpetSpeed.enabled = false
    if CarpetSpeed.conn then CarpetSpeed.conn:Disconnect() CarpetSpeed.conn = nil end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local AIM_VALID_TOOLS = {"Web Slinger", "Laser Cape", "Paintball Gun"}
local AIM_TARGET_PARTS = {"HumanoidRootPart", "UpperTorso", "Torso", "Head"}
local AIM_MAX_DISTANCE = 800
local AIM_LEAD_TIME = 0.18
local AIM_COOLDOWN = 0.04

local Aimbot = {
    running = false, connections = {}, remoteIndex = {}, remoteObjects = {},
    _useItemRemote = nil, currentChar = nil, lastShot = 0,
}

local function aimInitRemotes()
    Aimbot.remoteIndex, Aimbot.remoteObjects = {}, {}
    local ok, children = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):GetChildren()
    end)
    if not ok or not children then return end
    for i, obj in ipairs(children) do
        if obj:IsA("RemoteEvent") then
            local nextObj = children[i + 1]
            if nextObj then
                Aimbot.remoteIndex[obj.Name] = i + 1
                Aimbot.remoteObjects[i + 1] = nextObj
            end
        end
    end
end

local function resolveUseItemRemote()
    if Aimbot._useItemRemote and Aimbot._useItemRemote.Parent then return Aimbot._useItemRemote end
    local _getconnections = getconnections
    local _getconstants = (debug and debug.getconstants) or getconstants
    if type(_getconnections) ~= "function" or type(_getconstants) ~= "function" then return nil end
    local ok, netFolder = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages", 10):WaitForChild("Net", 10)
    end)
    if not ok or not netFolder then return nil end
    local found
    for _, r in ipairs(netFolder:GetChildren()) do
        if r:IsA("RemoteEvent") and not found then
            local okc, conns = pcall(_getconnections, r.OnClientEvent)
            if okc and conns then
                for _, c in ipairs(conns) do
                    if type(c.Function) == "function" then
                        local okk, consts = pcall(_getconstants, c.Function)
                        if okk and consts then
                            for _, k in ipairs(consts) do
                                if k == "PaintballHitted" then found = r break end
                            end
                        end
                    end
                    if found then break end
                end
            end
        end
        if found then break end
    end
    Aimbot._useItemRemote = found
    return found
end

local function aimFireRemote(name, ...)
    if name == "RE/UseItem" or name == "UseItem" then
        local r = resolveUseItemRemote()
        if r then r:FireServer(...) return true end
    end
    local index = Aimbot.remoteIndex[name]
    if index and Aimbot.remoteObjects[index] then
        Aimbot.remoteObjects[index]:FireServer(...)
        return true
    end
    return false
end

local function aimGetChar() local c = LP.Character if c then Aimbot.currentChar = c end return c end

local function aimHasValidTool()
    local c = aimGetChar()
    if not c then return false end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    for _, name in ipairs(AIM_VALID_TOOLS) do if tool.Name == name then return true end end
    return false
end

local function aimIsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function aimGetNearestPlayer()
    local c = aimGetChar()
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, shortest = nil, AIM_MAX_DISTANCE
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char and aimIsAlive(char) then
                local thrp = char:FindFirstChild("HumanoidRootPart")
                if thrp then
                    local d = (thrp.Position - hrp.Position).Magnitude
                    if d < shortest then shortest = d closest = plr end
                end
            end
        end
    end
    return closest
end

local function aimGetBestPart(char)
    for _, n in ipairs(AIM_TARGET_PARTS) do
        local p = char:FindFirstChild(n)
        if p then return p end
    end
    return nil
end

local function aimShoot()
    if not aimHasValidTool() then return false end
    local target = aimGetNearestPlayer()
    if not target then return false end
    local char = target.Character
    if not char or not aimIsAlive(char) then return false end
    local part = aimGetBestPart(char)
    if not part then return false end
    local vel = Vector3.zero
    pcall(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then vel = hrp.Velocity end
    end)
    local targetPos = part.Position + Vector3.new(0, 0.5, 0) + vel * AIM_LEAD_TIME
    local ok = aimFireRemote("RE/UseItem", targetPos, part)
    if not ok then
        aimInitRemotes()
        ok = aimFireRemote("RE/UseItem", targetPos, part)
    end
    return ok
end

local function aimTryShoot()
    local now = os.clock()
    if now - Aimbot.lastShot < AIM_COOLDOWN then return end
    Aimbot.lastShot = now
    aimShoot()
end

local function aimHookTool(tool)
    if not tool then return end
    table.insert(Aimbot.connections, tool.Activated:Connect(aimTryShoot))
end

local function aimSetupCharacter(char)
    Aimbot.currentChar = char
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then aimHookTool(tool) end
    table.insert(Aimbot.connections, char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then aimHookTool(child) end
    end))
end

function Aimbot.Start()
    if Aimbot.running then return end
    Aimbot.running = true
    aimInitRemotes()
    table.insert(Aimbot.connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            aimTryShoot()
        end
    end))
    if LP.Character then aimSetupCharacter(LP.Character) end
    table.insert(Aimbot.connections, LP.CharacterAdded:Connect(aimSetupCharacter))
end

function Aimbot.Stop()
    Aimbot.running = false
    for _, c in ipairs(Aimbot.connections) do pcall(function() c:Disconnect() end) end
    Aimbot.connections = {}
    Aimbot.currentChar = nil
end

function Aimbot.Set(on) if on then Aimbot.Start() else Aimbot.Stop() end end
_G.Aimbot = Aimbot

-- ============================================================
-- DROP BRAINROT
-- ============================================================
local DropBrainrot = { active = false }
function DropBrainrot.Run()
    if DropBrainrot.active then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    DropBrainrot.active = true
    local t0 = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = char and char:FindFirstChild("HumanoidRootPart")
        if not r then conn:Disconnect() DropBrainrot.active = false return end
        if tick() - t0 >= 0.2 then
            conn:Disconnect()
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp)
            if rr then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local off = (hum and hum.HipHeight or 2) + (r.Size.Y / 2)
                r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            task.delay(0.25, function() DropBrainrot.active = false end)
            return
        end
        r.Velocity = Vector3.new(r.Velocity.X, 150, r.Velocity.Z)
    end)
end

-- ============================================================
-- AUTO EQUIP SLOT
-- ============================================================
local AutoEquipSlot = { enabled = false, conn = nil, currentlyOnSlot = false, lockedTool = nil, humConns = {} }

local slotPodCache, slotPodT = nil, 0
local function getSlotPodiums()
    local nowT = os.clock()
    if slotPodCache and nowT - slotPodT < 1 then return slotPodCache end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return {} end
    local all = {}
    slotPodCache, slotPodT = all, nowT
    for _, plot in ipairs(plots:GetChildren()) do
        local pods = plot:FindFirstChild("AnimalPodiums")
        if pods then
            for _, pod in ipairs(pods:GetChildren()) do
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then table.insert(all, spawn.Position) end
            end
        end
    end
    return all
end

local function isPlayerOnAnySlot()
    local char = LP.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local myPos = hrp.Position
    for _, pos in ipairs(getSlotPodiums()) do
        local dist = (Vector3.new(myPos.X,0,myPos.Z) - Vector3.new(pos.X,0,pos.Z)).Magnitude
        if dist <= 4 then return true end
    end
    return false
end

local function findBestToolForSlot()
    local char = LP.Character
    local backpack = LP:FindFirstChild("Backpack")
    for _, name in ipairs(carpetNames) do
        if char then local t = char:FindFirstChild(name) if t and t:IsA("Tool") then return t end end
        if backpack then local t = backpack:FindFirstChild(name) if t and t:IsA("Tool") then return t end end
    end
    for _, name in ipairs(fallbackBatNames) do
        if char then local t = char:FindFirstChild(name) if t and t:IsA("Tool") then return t end end
        if backpack then local t = backpack:FindFirstChild(name) if t and t:IsA("Tool") then return t end end
    end
    for _, source in ipairs({char, backpack}) do
        if source then
            for _, tool in ipairs(source:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("bat") then return tool end
            end
        end
    end
    return nil
end

local function forceEquipLocked()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local locked = AutoEquipSlot.lockedTool
    if not locked or not locked.Parent then return end
    if char:FindFirstChildOfClass("Tool") ~= locked then
        pcall(function() hum:EquipTool(locked) end)
    end
end

local function hookHumanoid(hum)
    for _, c in ipairs(AutoEquipSlot.humConns) do pcall(function() c:Disconnect() end) end
    AutoEquipSlot.humConns = {}
    if not hum then return end
    table.insert(AutoEquipSlot.humConns, hum.ChildAdded:Connect(function(child)
        if not AutoEquipSlot.enabled or not AutoEquipSlot.currentlyOnSlot then return end
        if child:IsA("Tool") and AutoEquipSlot.lockedTool and child ~= AutoEquipSlot.lockedTool then
            task.defer(function() task.wait(0.03) forceEquipLocked() end)
        end
    end))
    table.insert(AutoEquipSlot.humConns, hum.ChildRemoved:Connect(function(child)
        if not AutoEquipSlot.enabled or not AutoEquipSlot.currentlyOnSlot then return end
        if child:IsA("Tool") and child == AutoEquipSlot.lockedTool then
            task.defer(function() task.wait(0.03) forceEquipLocked() end)
        end
    end))
end

function AutoEquipSlot.Start()
    if AutoEquipSlot.conn then return end
    AutoEquipSlot.enabled = true
    AutoEquipSlot.conn = RunService.Heartbeat:Connect(function()
        if not AutoEquipSlot.enabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if isPlayerOnAnySlot() then
            if not AutoEquipSlot.lockedTool or not AutoEquipSlot.lockedTool.Parent then
                local best = findBestToolForSlot()
                if best then AutoEquipSlot.lockedTool = best end
            end
            if AutoEquipSlot.lockedTool and AutoEquipSlot.lockedTool.Parent then
                forceEquipLocked()
            end
            AutoEquipSlot.currentlyOnSlot = true
        else
            if AutoEquipSlot.currentlyOnSlot then
                AutoEquipSlot.currentlyOnSlot = false
                AutoEquipSlot.lockedTool = nil
            end
        end
    end)
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hookHumanoid(hum) end
    end
end

function AutoEquipSlot.Stop()
    AutoEquipSlot.enabled = false
    if AutoEquipSlot.conn then AutoEquipSlot.conn:Disconnect() AutoEquipSlot.conn = nil end
    for _, c in ipairs(AutoEquipSlot.humConns) do pcall(function() c:Disconnect() end) end
    AutoEquipSlot.humConns = {}
    AutoEquipSlot.currentlyOnSlot = false
    AutoEquipSlot.lockedTool = nil
end

LP.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if not AutoEquipSlot.enabled then return end
    local hum = newChar:FindFirstChildOfClass("Humanoid")
    if hum then hookHumanoid(hum) end
end)

-- ============================================================
-- NEXT BASE
-- ============================================================
local function NextBase_Start()
    if _G.__NextBaseCleanup then pcall(_G.__NextBaseCleanup) end
    local CoreGui2 = game:GetService("CoreGui")
    local Plots = workspace:WaitForChild("Plots")
    local BASE_POSITIONS = {
        Vector3.new(-342.439,10.399,113.107), Vector3.new(-342.439,10.465,6.107),
        Vector3.new(-476.752,10.465,114.107), Vector3.new(-476.752,10.465,7.107),
        Vector3.new(-342.440,10.464,220.107), Vector3.new(-476.752,10.465,221.107),
        Vector3.new(-342.439,10.465,-100.893),Vector3.new(-476.752,10.465,-99.893),
    }
    local MATCH_TOL = 6
    local EMPTY_TEXT = "Empty Base"
    local ARROW = utf8.char(0x2B07)
    local BLUE_LIGHT = Color3.fromRGB(255, 205, 90)
    local BLUE_DEEP = Color3.fromRGB(150, 65, 8)
    local WHITE = Color3.fromRGB(255,255,255)
    local function baseIndexFor(model)
        local ok,cf=pcall(function() return (model:GetBoundingBox()) end)
        if not ok then return nil end
        local p,bestI,bestD=cf.Position
        for i,bp in ipairs(BASE_POSITIONS) do
            local dx,dz=p.X-bp.X,p.Z-bp.Z
            local d=math.sqrt(dx*dx+dz*dz)
            if not bestD or d<bestD then bestI,bestD=i,d end
        end
        return (bestD and bestD<=MATCH_TOL) and bestI or nil
    end
    local bases={} local connected={} local conns={}
    local anchor=Instance.new("Part")
    anchor.Name="__NextBaseAnchor"
    anchor.Anchored,anchor.CanCollide,anchor.CanQuery,anchor.CanTouch=true,false,false,false
    anchor.Transparency=1 anchor.Size=Vector3.new(1,1,1) anchor.Parent=CoreGui2
    local bb=Instance.new("BillboardGui")
    bb.Name="NextBaseBillboard" bb.Adornee=anchor bb.Size=UDim2.fromScale(34,15)
    bb.StudsOffset=Vector3.new(0,11,0) bb.MaxDistance=math.huge
    bb.AlwaysOnTop=true bb.LightInfluence=0 bb.Enabled=false bb.Parent=anchor
    local top=Instance.new("TextLabel",bb)
    top.BackgroundTransparency=1 top.AnchorPoint=Vector2.new(0.5,0.5)
    top.Position=UDim2.fromScale(0.5,0.30) top.Size=UDim2.fromScale(0.95,0.50)
    top.Font=Enum.Font.GothamBlack top.Text=ARROW.."  NEXT  "..ARROW
    top.TextScaled=true top.TextColor3=BLUE_LIGHT
    top.TextStrokeColor3=BLUE_DEEP top.TextStrokeTransparency=0
    local bottom=Instance.new("TextLabel",bb)
    bottom.BackgroundTransparency=1 bottom.AnchorPoint=Vector2.new(0.5,0.5)
    bottom.Position=UDim2.fromScale(0.5,0.72) bottom.Size=UDim2.fromScale(0.95,0.42)
    bottom.Font=Enum.Font.GothamBlack bottom.Text="EMPTY BASE"
    bottom.TextScaled=true bottom.TextColor3=WHITE
    bottom.TextStrokeColor3=BLUE_DEEP bottom.TextStrokeTransparency=0
    local function isEmpty(label) return (label.Text:gsub("^%s+",""):gsub("%s+$",""))==EMPTY_TEXT end
    local function recompute()
        local targetIdx
        for i=1,#BASE_POSITIONS do
            local b=bases[i]
            if b and b.label and isEmpty(b.label) then targetIdx=i break end
        end
        if targetIdx then anchor.CFrame=bases[targetIdx].cf bb.Enabled=true
        else bb.Enabled=false end
    end
    local function connectLabel(label)
        if connected[label] then return end
        connected[label]=true
        table.insert(conns,label:GetPropertyChangedSignal("Text"):Connect(recompute))
    end
    local function scan()
        for _, plot in ipairs(Plots:GetChildren()) do
            local sign=plot:FindFirstChild("PlotSign")
            local model=sign and sign:FindFirstChild("Model")
            local gui=sign and sign:FindFirstChild("SurfaceGui")
            local fr=gui and gui:FindFirstChild("Frame")
            local label=fr and fr:FindFirstChild("TextLabel")
            if model and label then
                local idx=baseIndexFor(model)
                if idx then
                    bases[idx]={label=label, cf=(select(1,model:GetBoundingBox()))}
                    connectLabel(label)
                end
            end
        end
        recompute()
    end
    scan()
    table.insert(conns,Plots.DescendantAdded:Connect(function(d) if d:IsA("TextLabel") then task.defer(scan) end end))
    table.insert(conns,Plots.ChildAdded:Connect(function() task.defer(scan) end))
    _G.__NextBaseCleanup=function()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        if anchor then anchor:Destroy() end
        _G.__NextBaseCleanup=nil
    end
end
local function NextBase_Stop() if _G.__NextBaseCleanup then pcall(_G.__NextBaseCleanup) end end

-- ============================================================
-- ANTI RAGDOLL
-- ============================================================
local AntiRagdoll = { enabled = false, conn = nil }
function AntiRagdoll.Enable()
    if AntiRagdoll.enabled then return end
    AntiRagdoll.enabled = true
    local function harden(hum)
        pcall(function() hum.BreakJointsOnDeath = false end)
        pcall(function() hum.RequiresNeck = false end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    end
    AntiRagdoll.conn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        harden(hum)
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end)
end
function AntiRagdoll.Disable()
    AntiRagdoll.enabled = false
    if AntiRagdoll.conn then AntiRagdoll.conn:Disconnect() AntiRagdoll.conn = nil end
end

-- ============================================================
-- INFINITE JUMP
-- ============================================================
local InfiniteJump = { enabled = false, jumpConn = nil, holdConn = nil }
function InfiniteJump.Enable()
    if InfiniteJump.enabled then return end
    InfiniteJump.enabled = true
    InfiniteJump.jumpConn = UserInputService.JumpRequest:Connect(function()
        if not InfiniteJump.enabled then return end
        local char = LP.Character if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 55, hrp.Velocity.Z) end
    end)
    InfiniteJump.holdConn = RunService.Heartbeat:Connect(function()
        if not InfiniteJump.enabled then return end
        local char = LP.Character if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local held = UserInputService:IsKeyDown(Enum.KeyCode.Space) or (hum and hum.Jump==true)
        if held and hrp.Velocity.Y < 30 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 55, hrp.Velocity.Z)
        end
    end)
end
function InfiniteJump.Disable()
    InfiniteJump.enabled = false
    if InfiniteJump.jumpConn then InfiniteJump.jumpConn:Disconnect() InfiniteJump.jumpConn = nil end
    if InfiniteJump.holdConn then InfiniteJump.holdConn:Disconnect() InfiniteJump.holdConn = nil end
end

-- ============================================================
-- INSTANT RESET
-- ============================================================
local InstaReset = {
    cooldown = false, thread = nil,
    currentCharacter = nil, stopSequence = false, resetMaxDuration = 0.05,
}
function InstaReset.Stop()
    InstaReset.stopSequence = true
    if InstaReset.thread then pcall(task.cancel, InstaReset.thread) InstaReset.thread = nil end
    InstaReset.cooldown = false
    InstaReset.currentCharacter = nil
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function()
            hum.HipHeight = 2
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CanCollide = true end
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end) end
    end
end
function InstaReset.Run()
    if InstaReset.cooldown then return end
    InstaReset.cooldown = true
    InstaReset.stopSequence = false
    local char = LP.Character
    if not char then InstaReset.cooldown = false return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then InstaReset.cooldown = false return end
    InstaReset.currentCharacter = char
    local isRespawning = false
    InstaReset.thread = task.spawn(function()
        local attempts = 0
        local maxAttempts = 40
        local originalHipHeight = hum.HipHeight
        local resetSuccessful = false
        while char and char.Parent and hum and hum.Health > 0
              and not isRespawning and not InstaReset.stopSequence do
            if LP.Character ~= char then isRespawning = true break end
            pcall(function()
                hum.HipHeight = 1e30
                hum.AutoRotate = true
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CanCollide = false end
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end)
            if not char or not char.Parent or not hum or hum.Health<=0 or LP.Character~=char then
                resetSuccessful = true break
            end
            attempts = attempts + 1
            if attempts >= maxAttempts then break end
            task.wait(InstaReset.resetMaxDuration)
        end
        if not resetSuccessful then
            if char and char.Parent and hum and hum.Health>0 and not isRespawning then
                pcall(function() hum.Health = 0 end)
                task.wait(0.1)
                if not char.Parent or hum.Health<=0 then resetSuccessful=true end
            end
        end
        if not resetSuccessful and char and char.Parent and hum then
            pcall(function()
                hum.HipHeight = originalHipHeight
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CanCollide = true end
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end)
        end
        InstaReset.cooldown = false
        InstaReset.thread = nil
        InstaReset.currentCharacter = nil
        InstaReset.stopSequence = false
    end)
end
LP.CharacterAdded:Connect(function()
    InstaReset.Stop()
    InstaReset.cooldown = false
    InstaReset.currentCharacter = nil
    InstaReset.stopSequence = false
end)

-- ============================================================
-- XRAY
-- ============================================================
local XRay = {
    active = false, alpha = 0.8, loopId = 0, connections = {},
    originalTransparency = setmetatable({}, {__mode="k"}),
    folders = {"Base","PlotSign","FriendPanel","Cash","Laser","Decorations","Skin","Unlock","Purchases"},
    lightingSnapshot = nil,
}
local function XRay_setTransparency(instance, alpha, loopId)
    if not instance or loopId~=XRay.loopId then return end
    local function apply(obj)
        if not obj:IsA("BasePart") then return end
        if XRay.originalTransparency[obj]==nil then
            XRay.originalTransparency[obj]=obj.Transparency
        end
        local orig=XRay.originalTransparency[obj]
        if orig<1 then
            local target=orig+(1-orig)*alpha
            if math.abs(obj.Transparency-target)>0.01 then obj.Transparency=target end
        end
    end
    apply(instance)
    local descendants=instance:GetDescendants()
    for i, child in ipairs(descendants) do
        apply(child)
        if i%400==0 then
            if loopId~=XRay.loopId then return end
            RunService.Heartbeat:Wait()
        end
    end
end
local function XRay_trackSubtree(root, alpha, loopId)
    if not root or loopId~=XRay.loopId then return end
    XRay_setTransparency(root, alpha, loopId)
    local conn=root.DescendantAdded:Connect(function(obj)
        if loopId==XRay.loopId then XRay_setTransparency(obj, alpha, loopId) end
    end)
    table.insert(XRay.connections, conn)
end
local function XRay_processPlot(plot, alpha, loopId)
    if not plot or loopId~=XRay.loopId then return end
    for _, folderName in ipairs(XRay.folders) do
        local folder=plot:FindFirstChild(folderName)
        if folder then XRay_trackSubtree(folder, alpha, loopId) end
    end
    local conn=plot.ChildAdded:Connect(function(child)
        if loopId~=XRay.loopId then return end
        for _, folderName in ipairs(XRay.folders) do
            if child.Name==folderName then XRay_trackSubtree(child, alpha, loopId) break end
        end
    end)
    table.insert(XRay.connections, conn)
    local podiums=plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    local function processPodium(podium)
        for _, child in ipairs(podium:GetChildren()) do
            if child.Name=="Claim" then XRay_trackSubtree(child, alpha, loopId)
            elseif child.Name=="Base" then
                local decorations=child:FindFirstChild("Decorations")
                if decorations then XRay_trackSubtree(decorations, alpha, loopId) end
            elseif child:IsA("Model") and child.Name~="Decorations" then
                XRay_trackSubtree(child, alpha, loopId)
            end
        end
    end
    for _, podium in ipairs(podiums:GetChildren()) do processPodium(podium) end
    local conn2=podiums.ChildAdded:Connect(function(podium)
        if loopId==XRay.loopId then processPodium(podium) end
    end)
    table.insert(XRay.connections, conn2)
end
function XRay.Enable()
    for _, conn in ipairs(XRay.connections) do
        if typeof(conn)=="RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
    end
    XRay.connections = {}
    XRay.loopId = XRay.loopId + 1
    local id = XRay.loopId
    XRay.active = true
    local plotsFolder=workspace:FindFirstChild("Plots")
    if not plotsFolder then return end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if id~=XRay.loopId then return end
        XRay_processPlot(plot, XRay.alpha, id)
    end
    local conn=plotsFolder.ChildAdded:Connect(function(plot)
        if id==XRay.loopId then XRay_processPlot(plot, XRay.alpha, id) end
    end)
    table.insert(XRay.connections, conn)
    XRay.lightingSnapshot={
        GlobalShadows=Lighting.GlobalShadows, FogEnd=Lighting.FogEnd,
        FogStart=Lighting.FogStart, EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale,
    }
    Lighting.GlobalShadows=false
    Lighting.EnvironmentDiffuseScale=0
    Lighting.EnvironmentSpecularScale=0
    Lighting.FogStart=0
    Lighting.FogEnd=100000
end
function XRay.Disable()
    XRay.active=false
    for _, conn in ipairs(XRay.connections) do
        if typeof(conn)=="RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
    end
    XRay.connections={}
    local snapshot=XRay.originalTransparency
    XRay.originalTransparency=setmetatable({}, {__mode="k"})
    for obj, orig in pairs(snapshot) do
        pcall(function()
            if obj:IsA("BasePart") and obj.Parent then obj.Transparency=orig end
        end)
    end
    if XRay.lightingSnapshot then
        Lighting.GlobalShadows=XRay.lightingSnapshot.GlobalShadows
        Lighting.FogEnd=XRay.lightingSnapshot.FogEnd
        Lighting.FogStart=XRay.lightingSnapshot.FogStart
        Lighting.EnvironmentDiffuseScale=XRay.lightingSnapshot.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale=XRay.lightingSnapshot.EnvironmentSpecularScale
        XRay.lightingSnapshot=nil
    end
end

-- ============================================================
-- JOB ID + EMPTY SERVER FINDER
-- ============================================================
local JobIdSaver = {}
function JobIdSaver.GetJobId()
    local id = tostring(game.JobId)
    return (id ~= nil and id ~= "") and id or "Reserved Server"
end
function JobIdSaver.Copy()
    local id = JobIdSaver.GetJobId()
    local ok = false
    if typeof(setclipboard) == "function" then
        ok = pcall(setclipboard, id)
    elseif typeof(toclipboard) == "function" then
        ok = pcall(toclipboard, id)
    end
    return id, ok
end

local EMPTY_SERVER_PLACE_ID = 96342491571673
local EMPTY_SERVER_MAX_PLAYERS = 2
local EMPTY_SERVER_TEST_COUNT = 15
local EMPTY_SERVER_API = "https://games.roblox.com/v1/games/" .. EMPTY_SERVER_PLACE_ID .. "/servers/Public"

local function EmptyServer_getServers(cursor)
    local url = EMPTY_SERVER_API .. "?sortOrder=Asc&limit=100"
    if cursor and cursor ~= "" then url = url .. "&cursor=" .. cursor end
    local ok, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if not ok then return nil end
    return result
end
local function EmptyServer_collectCandidates()
    local candidates = {}
    local cursor = ""
    repeat
        local data = EmptyServer_getServers(cursor)
        if not data or not data.data then break end
        for _, server in ipairs(data.data) do
            local n = server.playing
            if n ~= nil and n <= EMPTY_SERVER_MAX_PLAYERS and n > 0 then
                table.insert(candidates, server)
            end
        end
        cursor = data.nextPageCursor or ""
    until cursor == "" or cursor == nil or #candidates >= EMPTY_SERVER_TEST_COUNT * 3
    return candidates
end
local function EmptyServer_measurePing()
    local start = os.clock()
    pcall(function()
        game:HttpGet("https://games.roblox.com/v1/games/" .. EMPTY_SERVER_PLACE_ID)
    end)
    return (os.clock() - start) * 1000
end
local function EmptyServer_findBestServer()
    local candidates = EmptyServer_collectCandidates()
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.playing < b.playing end)
    local toTest = {}
    for i = 1, math.min(EMPTY_SERVER_TEST_COUNT, #candidates) do
        table.insert(toTest, candidates[i])
    end
    local best, bestPing = nil, math.huge
    for _, server in ipairs(toTest) do
        local ping = EmptyServer_measurePing()
        print(string.format("server %s | players: %d | est. ping: %.0fms", server.id, server.playing, ping))
        if ping < bestPing then best = server bestPing = ping end
        task.wait(0.1)
    end
    return best, bestPing
end

-- ============================================================
-- MAIN MENU GUI
-- ============================================================
local function getHui() return (gethui and gethui()) or game:GetService("CoreGui") end
for _, parent in ipairs({getHui(), LP:FindFirstChild("PlayerGui")}) do
    if parent then
        local old = parent:FindFirstChild("XiUnifiedMenu")
        if old then old:Destroy() end
    end
end
local Gui = Instance.new("ScreenGui")
Gui.Name="XiUnifiedMenu" Gui.ResetOnSpawn=false Gui.IgnoreGuiInset=true
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling Gui.DisplayOrder=100 Gui.Parent=getHui()

local ClickSound = Instance.new("Sound")
ClickSound.Name = "CleanButtonClick"
ClickSound.SoundId = "rbxassetid://12221967"
ClickSound.Volume = 0.35
ClickSound.PlaybackSpeed = 1.08
ClickSound.Parent = Gui

local hookedButtons = setmetatable({}, {__mode = "k"})
local function playCleanClick()
    ClickSound.TimePosition = 0
    ClickSound:Play()
end
local function hookButton(obj)
    if obj:IsA("GuiButton") and not hookedButtons[obj] then
        hookedButtons[obj] = true
        obj.Activated:Connect(playCleanClick)
    end
end
for _, obj in ipairs(Gui:GetDescendants()) do hookButton(obj) end
Gui.DescendantAdded:Connect(hookButton)

local function corner(p, r)
    local c = Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 10) c.Parent=p return c
end
local function mkStroke(p, color, t, tr)
    local s = Instance.new("UIStroke") s.Color=color s.Thickness=t or 1 s.Transparency=tr or 0.3
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p return s
end
local function tween(obj, time, props, style, dir)
    local t=TweenService:Create(obj,TweenInfo.new(time or 0.2,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
    t:Play() return t
end

-- ============================================================
-- DEVICE DETECTION + GUI SCALE
-- ============================================================
local function detectDevice()
    local touch = UserInputService.TouchEnabled
    local kb = UserInputService.KeyboardEnabled
    local mouse = UserInputService.MouseEnabled
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local shortSide = math.min(vp.X, vp.Y)
    local longSide = math.max(vp.X, vp.Y)
    if touch and not kb and not mouse then
        if shortSide <= 500 then return "iphone", shortSide end
        return "ipad", shortSide
    end
    return "desktop", longSide
end

local DEVICE, DEVICE_SHORT = detectDevice()

local function computeDefaultScale()
    if DEVICE == "iphone" then return 0.65 end
    if DEVICE == "ipad" then return 0.9 end
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    return math.clamp(vp.X / 1920, 0.85, 1.1)
end

if CONFIG.GuiScale == nil then
    CONFIG.GuiScale = computeDefaultScale()
end

local guiScale = Instance.new("UIScale", Gui)
guiScale.Scale = CONFIG.GuiScale

local function setGuiScale(s)
    s = math.clamp(s, 0.4, 1.6)
    guiScale.Scale = s
    CONFIG.GuiScale = s
    saveConfig()
end

local function isDefaultish(s) return math.abs(s - computeDefaultScale()) < 0.02 end
local userCustomScale = not isDefaultish(CONFIG.GuiScale)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if not userCustomScale then
        guiScale.Scale = computeDefaultScale()
        CONFIG.GuiScale = guiScale.Scale
    end
end)

_G.SweetSetScale = setGuiScale
_G.SweetGetDevice = function() return DEVICE end
-- legacy aliases
_G.CorsaSetScale = setGuiScale
_G.CorsaGetDevice = function() return DEVICE end

-- ============================================================
-- DRAG + RESIZE
-- ============================================================
local function makeDraggable(handle, target, saveKey)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true dragStart=input.Position startPos=target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            local s = guiScale.Scale
            target.Position=UDim2.new(0, startPos.X.Offset + delta.X / s, 0, startPos.Y.Offset + delta.Y / s)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            if dragging and saveKey then
                CONFIG.Positions[saveKey]={X=target.Position.X.Offset,Y=target.Position.Y.Offset}
                saveConfig()
            end
            dragging=false
        end
    end)
end

local function makeScalable(handle, panel)
    local resizing, resizeStart, startSize
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = guiScale.Scale
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - resizeStart
        local change = (delta.X + delta.Y) * 0.0016
        local newScale = math.clamp(startSize + change, 0.4, 1.6)
        guiScale.Scale = newScale
        CONFIG.GuiScale = newScale
        userCustomScale = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            if resizing then
                resizing = false
                saveConfig()
            end
        end
    end)
end

local function createPanel(title, saveKey, width)
    local pos = CONFIG.Positions[saveKey] or DEFAULT_POSITIONS[saveKey] or {X=20,Y=80}
    local Panel = Instance.new("Frame")
    Panel.Name = title:gsub("%s+","")
    Panel.Position = UDim2.new(0, pos.X, 0, pos.Y)
    Panel.Size = UDim2.new(0, width, 0, 0)
    Panel.AutomaticSize = Enum.AutomaticSize.Y
    Panel.BackgroundColor3 = Theme.Bg
    Panel.BorderSizePixel = 0
    Panel.Parent = Gui
    corner(Panel, 14)
    mkStroke(Panel, Theme.Accent, 1.2, 0.4)

    local Header = Instance.new("Frame", Panel)
    Header.Size = UDim2.new(1,0,0,48)
    Header.BackgroundColor3 = Theme.BgCard
    Header.BorderSizePixel = 0
    corner(Header, 14)

    local HeaderFill = Instance.new("Frame", Panel)
    HeaderFill.Position = UDim2.new(0,0,0,28)
    HeaderFill.Size = UDim2.new(1,0,0,20)
    HeaderFill.BackgroundColor3 = Theme.BgCard
    HeaderFill.BorderSizePixel = 0
    HeaderFill.ZIndex = 2

    local AccentBar = Instance.new("Frame", Panel)
    AccentBar.Position = UDim2.new(0,0,0,10)
    AccentBar.Size = UDim2.new(0,3,0,28)
    AccentBar.BackgroundColor3 = Theme.Accent
    AccentBar.BorderSizePixel = 0
    corner(AccentBar, 3)
    AccentBar.ZIndex = 3

    local TitleDot = Instance.new("Frame", Panel)
    TitleDot.AnchorPoint = Vector2.new(0,0.5)
    TitleDot.Position = UDim2.new(0,16,0,24)
    TitleDot.Size = UDim2.fromOffset(8,8)
    TitleDot.BackgroundColor3 = Theme.Accent
    TitleDot.BorderSizePixel = 0
    TitleDot.ZIndex = 4
    corner(TitleDot, 4)

    local HeaderLabel = Instance.new("TextLabel", Panel)
    HeaderLabel.Position = UDim2.new(0,32,0,12)
    HeaderLabel.Size = UDim2.new(1,-44,0,24)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Font = Enum.Font.GothamBlack
    HeaderLabel.TextSize = 15
    HeaderLabel.TextColor3 = Theme.Text
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Text = title:upper()
    HeaderLabel.ZIndex = 4

    local Div = Instance.new("Frame", Panel)
    Div.Position = UDim2.new(0,0,0,48)
    Div.Size = UDim2.new(1,0,0,1)
    Div.BackgroundColor3 = Theme.Accent
    Div.BackgroundTransparency = 0.7
    Div.BorderSizePixel = 0
    Div.ZIndex = 3

    local Holder = Instance.new("Frame", Panel)
    Holder.Name = "Holder"
    Holder.Position = UDim2.new(0,10,0,56)
    Holder.Size = UDim2.new(1,-20,0,0)
    Holder.AutomaticSize = Enum.AutomaticSize.Y
    Holder.BackgroundTransparency = 1
    local Layout = Instance.new("UIListLayout", Holder)
    Layout.Padding = UDim.new(0,5)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    local Pad = Instance.new("UIPadding", Holder)
    Pad.PaddingBottom = UDim.new(0,10)

    local Grip = Instance.new("TextButton", Panel)
    Grip.Name = "ResizeGrip"
    Grip.AnchorPoint = Vector2.new(1,0)
    Grip.Position = UDim2.new(1,-4,0,4)
    Grip.Size = UDim2.fromOffset(20,20)
    Grip.BackgroundColor3 = Theme.BgCard
    Grip.BackgroundTransparency = 0.1
    Grip.Text = "⤡"
    Grip.Font = Enum.Font.GothamBold
    Grip.TextSize = 12
    Grip.TextColor3 = Theme.AccentBright
    Grip.AutoButtonColor = false
    Grip.ZIndex = 6
    corner(Grip, 6)
    mkStroke(Grip, Theme.Accent, 1, 0.5)
    Grip.MouseEnter:Connect(function() tween(Grip, 0.12, {BackgroundColor3=Theme.BtnBgHover}) end)
    Grip.MouseLeave:Connect(function() tween(Grip, 0.12, {BackgroundColor3=Theme.BgCard}) end)
    makeScalable(Grip, Panel)

    makeDraggable(Header, Panel, saveKey)

    return Panel, Holder
end

local function createToggle(parent, text, value, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1,0,0,38)
    Row.BackgroundColor3 = Theme.BgRow
    Row.BorderSizePixel = 0
    corner(Row, 9)
    local rowStroke = mkStroke(Row, Theme.StrokeSoft, 1, 0.72)

    local StatusDot = Instance.new("Frame", Row)
    StatusDot.AnchorPoint = Vector2.new(0,0.5)
    StatusDot.Position = UDim2.new(0,12,0.5,0)
    StatusDot.Size = UDim2.fromOffset(6,6)
    StatusDot.BackgroundColor3 = value and Theme.TrackOn or Theme.TrackOff
    StatusDot.BorderSizePixel = 0
    corner(StatusDot, 3)

    local Label = Instance.new("TextLabel", Row)
    Label.Position = UDim2.new(0,26,0,0)
    Label.Size = UDim2.new(1,-80,1,0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = value and Theme.Text or Theme.TextDim
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text

    local PillBg = Instance.new("Frame", Row)
    PillBg.AnchorPoint = Vector2.new(1,0.5)
    PillBg.Position = UDim2.new(1,-12,0.5,0)
    PillBg.Size = UDim2.fromOffset(44,22)
    PillBg.BackgroundColor3 = value and Theme.TrackOn or Theme.TrackOff
    PillBg.BorderSizePixel = 0
    corner(PillBg, 11)

    local Knob = Instance.new("Frame", PillBg)
    Knob.AnchorPoint = Vector2.new(0.5,0.5)
    Knob.Size = UDim2.fromOffset(16,16)
    Knob.Position = value and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.BorderSizePixel = 0
    corner(Knob, 8)
    mkStroke(Knob, Color3.fromRGB(0,0,0), 1, 0.85)

    local Clickable = Instance.new("TextButton", Row)
    Clickable.AnchorPoint = Vector2.new(1,0.5)
    Clickable.Position = UDim2.new(1,-8,0.5,0)
    Clickable.Size = UDim2.fromOffset(60,34)
    Clickable.ZIndex = 10
    Clickable.BackgroundTransparency = 1
    Clickable.Text = ""
    Clickable.AutoButtonColor = false

    local function render(state)
        tween(PillBg, 0.18, {BackgroundColor3 = state and Theme.TrackOn or Theme.TrackOff})
        tween(Knob, 0.2, {Position = state and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)}, Enum.EasingStyle.Back)
        tween(StatusDot, 0.18, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(55,50,75)})
        tween(Label, 0.18, {TextColor3 = state and Theme.Text or Theme.TextDim})
    end
    render(value)

    Clickable.MouseButton1Click:Connect(function()
        value = not value
        render(value)
        callback(value)
    end)
    Row.MouseEnter:Connect(function()
        tween(Row, 0.12, {BackgroundColor3 = Theme.BgRowHov})
        tween(rowStroke, 0.12, {Color=Theme.Accent, Transparency=0.5})
    end)
    Row.MouseLeave:Connect(function()
        tween(Row, 0.12, {BackgroundColor3 = Theme.BgRow})
        tween(rowStroke, 0.12, {Color=Theme.StrokeSoft, Transparency=0.72})
    end)
    return { Set = render, Get = function() return value end }
end

local function createButton(parent, text, accentColor, bgColor, hoverColor, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1,0,0,34)
    Btn.BackgroundColor3 = bgColor
    Btn.Text = text
    Btn.AutoButtonColor = false
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextSize = 13
    Btn.TextColor3 = accentColor
    corner(Btn, 9)
    local s = mkStroke(Btn, accentColor, 1, 0.6)
    local sc = Instance.new("UIScale", Btn)
    sc.Scale = 1

    Btn.MouseEnter:Connect(function()
        tween(Btn, 0.12, {BackgroundColor3=hoverColor})
        tween(s, 0.12, {Transparency=0.2, Thickness=1.3})
    end)
    Btn.MouseLeave:Connect(function()
        tween(Btn, 0.12, {BackgroundColor3=bgColor})
        tween(s, 0.12, {Transparency=0.6, Thickness=1})
    end)
    Btn.MouseButton1Down:Connect(function()
        tween(sc, 0.07, {Scale=0.96})
        tween(Btn, 0.07, {BackgroundColor3=accentColor})
        tween(Btn, 0.07, {TextColor3=bgColor})
    end)
    Btn.MouseButton1Up:Connect(function()
        tween(sc, 0.14, {Scale=1}, Enum.EasingStyle.Back)
        tween(Btn, 0.1, {BackgroundColor3=hoverColor})
        tween(Btn, 0.1, {TextColor3=accentColor})
    end)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- ============================================================
-- MERGED: SlotsESP + BrainrotESP + AutoKick
-- ============================================================
do
    -- ---------------- SLOTS ESP ----------------
    local SlotsESP = { running = false, conns = {}, folder = nil, currentPlot = nil, last = 0 }
    local PODS_PER_FLOOR, F2_COUNT, F3_COUNT = 10, 10, 10
    local F2_MAP = { 11, 12, 13, 14, 15, nil, nil, 18, 17, 16 }
    local F3_MAP = { 19, 20, 21, 22, 23, 28, 27, 26, 25, 24 }
    local FLOOR_TOL, BASE_GAP = 8, 0.5
    local SLOT_SHRINK = 0.82

    local function getBox(inst)
        local base = inst:FindFirstChild("Base", true) or inst
        if base:IsA("Model") then
            local ok, cf, sz = pcall(function() return base:GetBoundingBox() end)
            if ok then return cf, sz end
        elseif base:IsA("BasePart") then
            return base.CFrame, base.Size
        end
        return nil, nil
    end

    local function clusterFloors(podiums)
        local out = {}
        for _, c in ipairs(podiums:GetChildren()) do
            local cf = getBox(c)
            if cf then
                local y = cf.Position.Y
                local hit = false
                for _, cl in ipairs(out) do
                    if math.abs(cl.y - y) <= FLOOR_TOL then
                        cl.count = cl.count + 1
                        cl.y = cl.y + (y - cl.y) / cl.count
                        hit = true
                        break
                    end
                end
                if not hit then table.insert(out, { y = y, count = 1 }) end
            end
        end
        table.sort(out, function(a, b) return a.y < b.y end)
        return out
    end

    local function floorOffset(cf, floor, gap)
        local off = gap * (floor - 1)
        if floor == 3 then off = off - 0.85 end
        return cf + Vector3.new(0, off, 0)
    end

    local function noOverlap(pos, existing)
        for _, p in ipairs(existing) do
            if Vector2.new(pos.X - p.X, pos.Z - p.Z).Magnitude <= 1.5 and math.abs(pos.Y - p.Y) <= 2 then
                return false
            end
        end
        return true
    end

    local function drawSlot(cf, size, slotNum)
        if not SlotsESP.running or not SlotsESP.folder or not SlotsESP.folder.Parent then return end
        local smallSize = Vector3.new(size.X * SLOT_SHRINK, size.Y * SLOT_SHRINK, size.Z * SLOT_SHRINK)

        local part = Instance.new("Part")
        part.Name = "zab"
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Transparency = 1
        part.Size = smallSize
        part.CFrame = cf
        part.Parent = SlotsESP.folder

        local sb = Instance.new("SelectionBox")
        sb.Name = "zab"
        sb.Adornee = part
        sb.Color3 = Theme.AccentDark
        sb.SurfaceColor3 = Theme.AccentBright
        sb.LineThickness = 0.04
        sb.Transparency = 0.2
        sb.SurfaceTransparency = 0.85
        sb.Parent = part

        local floor = Instance.new("Part")
        floor.Name = "zab"
        floor.Anchored = true
        floor.CanCollide = true
        floor.CanQuery = true
        floor.CanTouch = false
        floor.CastShadow = false
        floor.Transparency = 1
        floor.Size = Vector3.new(smallSize.X, 0.5, smallSize.Z)
        floor.CFrame = cf * CFrame.new(0, -(smallSize.Y - BASE_GAP) / 2, 0)
        floor.Parent = SlotsESP.folder

        if slotNum then
            local bb = Instance.new("BillboardGui")
            bb.Name = "SlotNum"
            bb.Adornee = part
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 46, 0, 20)
            bb.StudsOffset = Vector3.new(0, smallSize.Y / 2 + 1.4, 0)
            bb.MaxDistance = 140
            bb.LightInfluence = 0
            bb.Parent = part

            local fr = Instance.new("Frame", bb)
            fr.BackgroundColor3 = Theme.BgCard
            fr.BackgroundTransparency = 0.12
            fr.BorderSizePixel = 0
            fr.Size = UDim2.new(1, 0, 1, 0)
            Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 6)
            local st = Instance.new("UIStroke", fr)
            st.Color = Theme.Accent
            st.Thickness = 1
            st.Transparency = 0.4
            st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

            local tl = Instance.new("TextLabel", fr)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = "#" .. tostring(slotNum)
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextColor3 = Theme.AccentBright
        end
    end

    local function buildPlot(plot, gap)
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return end
        local floors = clusterFloors(podiums)
        if #floors == 0 then return end
        if #floors >= 2 then
            local d = floors[2].y - floors[1].y
            if FLOOR_TOL < d then gap = d end
        end
        local children = podiums:GetChildren()
        table.sort(children, function(a, b) return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0) end)

        local groundY = floors[1].y
        local ground, groundPos = {}, {}
        for _, c in ipairs(children) do
            local cf, sz = getBox(c)
            if cf and sz and math.abs(cf.Position.Y - groundY) <= FLOOR_TOL then
                table.insert(ground, { cf = cf, sz = sz })
                table.insert(groundPos, cf.Position)
            end
        end
        local n = #ground
        for i = 1, math.min(PODS_PER_FLOOR, n) do
            if ground[i] then drawSlot(ground[i].cf, ground[i].sz, i) end
        end
        for i = 1, math.min(F2_COUNT, n) do
            local map = F2_MAP[i]
            if map ~= nil and ground[i] then
                local cf = floorOffset(ground[i].cf, 2, gap)
                if noOverlap(cf.Position, groundPos) then
                    drawSlot(cf, ground[i].sz, map)
                    table.insert(groundPos, cf.Position)
                end
            end
        end
        for i = 1, math.min(F3_COUNT, n) do
            local map = F3_MAP[i]
            if map ~= nil and ground[i] then
                local cf = floorOffset(ground[i].cf, 3, gap)
                if noOverlap(cf.Position, groundPos) then
                    drawSlot(cf, ground[i].sz, map)
                    table.insert(groundPos, cf.Position)
                end
            end
        end
    end

    local function nearestPlot()
        local char = LP.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
        if not hrp then return nil end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local best, bestD = nil, math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            local model = sign and sign:FindFirstChild("Model")
            if model and model:IsA("Model") then
                local ok, cf = pcall(function() return model:GetBoundingBox() end)
                if ok then
                    local dx = cf.Position.X - hrp.Position.X
                    local dz = cf.Position.Z - hrp.Position.Z
                    local d = math.sqrt(dx * dx + dz * dz)
                    if d < bestD then bestD = d best = plot end
                end
            end
        end
        return best
    end

    local rebuilding = false
    local function rebuild()
        if rebuilding then return end
        rebuilding = true
        task.delay(0.4, function()
            rebuilding = false
            if not SlotsESP.running or not SlotsESP.folder then return end
            local plot = nearestPlot()
            if not plot then return end
            if plot == SlotsESP.currentPlot and SlotsESP.folder:GetChildren()[1] then return end
            SlotsESP.currentPlot = plot
            SlotsESP.folder:ClearAllChildren()
            buildPlot(plot, 18)
        end)
    end

    _G.SlotsESP_Start = function()
        if SlotsESP.running then return end
        SlotsESP.running = true
        SlotsESP.folder = Instance.new("Folder")
        SlotsESP.folder.Name = "zab"
        SlotsESP.folder.Parent = workspace
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    table.insert(SlotsESP.conns, podiums.ChildAdded:Connect(rebuild))
                    table.insert(SlotsESP.conns, podiums.ChildRemoved:Connect(rebuild))
                    table.insert(SlotsESP.conns, podiums.DescendantAdded:Connect(rebuild))
                    table.insert(SlotsESP.conns, podiums.DescendantRemoving:Connect(rebuild))
                end
            end
            table.insert(SlotsESP.conns, plots.DescendantAdded:Connect(rebuild))
            table.insert(SlotsESP.conns, plots.DescendantRemoving:Connect(rebuild))
        end
        table.insert(SlotsESP.conns, RunService.Heartbeat:Connect(function()
            if not SlotsESP.running then return end
            local now = os.clock()
            if now - SlotsESP.last < 0.4 then return end
            SlotsESP.last = now
            local plot = nearestPlot()
            if plot and plot ~= SlotsESP.currentPlot then
                SlotsESP.currentPlot = plot
                SlotsESP.folder:ClearAllChildren()
                buildPlot(plot, 18)
            end
        end))
        rebuild()
    end

    _G.SlotsESP_Stop = function()
        SlotsESP.running = false
        for _, c in ipairs(SlotsESP.conns) do pcall(function() c:Disconnect() end) end
        SlotsESP.conns = {}
        if SlotsESP.folder then SlotsESP.folder:Destroy() SlotsESP.folder = nil end
        SlotsESP.currentPlot = nil
    end

    -- ---------------- BRAINROT ESP ----------------
    local BrainrotESP = { running = false, conns = {}, cards = {}, screen = nil }
    local BRAINROT_SHRINK = 0.72

    local function getScreen()
        if BrainrotESP.screen and BrainrotESP.screen.Parent then return BrainrotESP.screen end
        BrainrotESP.screen = Instance.new("ScreenGui")
        BrainrotESP.screen.Name = "SweetBrainrotESP"
        BrainrotESP.screen.ResetOnSpawn = false
        BrainrotESP.screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        BrainrotESP.screen.DisplayOrder = 95
        pcall(function()
            if gethui then BrainrotESP.screen.Parent = gethui()
            else BrainrotESP.screen.Parent = game:GetService("CoreGui") end
        end)
        if not BrainrotESP.screen.Parent then
            BrainrotESP.screen.Parent = LP:WaitForChild("PlayerGui")
        end
        return BrainrotESP.screen
    end

    local function makeCard(adornee, name, gen, key)
        local scr = getScreen()
        local bb = Instance.new("BillboardGui")
        bb.Name = "BrainrotESP_" .. key
        bb.Adornee = adornee
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 160 * BRAINROT_SHRINK, 0, 46 * BRAINROT_SHRINK)
        bb.StudsOffset = Vector3.new(0, 2.6, 0)
        bb.LightInfluence = 0
        bb.MaxDistance = 3000
        bb.Parent = scr

        local card = Instance.new("Frame", bb)
        card.Name = "Card"
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = Theme.BgCard
        card.BackgroundTransparency = 0.12
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)
        local st = Instance.new("UIStroke", card)
        st.Color = Theme.Accent
        st.Thickness = 1
        st.Transparency = 0.35

        local nameLbl = Instance.new("TextLabel", card)
        nameLbl.Size = UDim2.new(1, -50, 0, 18)
        nameLbl.Position = UDim2.new(0, 7, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = name
        nameLbl.TextColor3 = Theme.Text
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextScaled = true
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        local genLbl = Instance.new("TextLabel", card)
        genLbl.Size = UDim2.new(1, -50, 0, 16)
        genLbl.Position = UDim2.new(0, 7, 0, 22)
        genLbl.BackgroundTransparency = 1
        genLbl.Text = gen
        genLbl.TextColor3 = Theme.AccentBright
        genLbl.Font = Enum.Font.GothamBold
        genLbl.TextScaled = true
        genLbl.TextXAlignment = Enum.TextXAlignment.Left
        genLbl.TextStrokeTransparency = 0
        genLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        local holder = Instance.new("Frame", card)
        holder.Size = UDim2.new(0, 36, 0, 36)
        holder.Position = UDim2.new(1, -40, 0.5, -18)
        holder.BackgroundColor3 = Theme.BgRow
        holder.BackgroundTransparency = 0.2
        holder.BorderSizePixel = 0
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

        local img = Instance.new("ImageLabel", holder)
        img.Size = UDim2.new(1, -4, 1, -4)
        img.Position = UDim2.new(0, 2, 0, 2)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = ""

        BrainrotESP.cards[key] = { billboard = bb, nameLbl = nameLbl, genLbl = genLbl, img = img }
        return BrainrotESP.cards[key]
    end

    local function updateCard(key, name, gen, adornee)
        local c = BrainrotESP.cards[key]
        if not c then return end
        if c.nameLbl.Text ~= name then c.nameLbl.Text = name end
        if c.genLbl.Text ~= gen then c.genLbl.Text = gen end
        if adornee and c.billboard.Adornee ~= adornee then c.billboard.Adornee = adornee end
    end

    local function destroyCard(key)
        local c = BrainrotESP.cards[key]
        if not c then return end
        if c.billboard then pcall(function() c.billboard:Destroy() end) end
        BrainrotESP.cards[key] = nil
    end

    local function destroyAllCards() for k in pairs(BrainrotESP.cards) do destroyCard(k) end end

    local function scanPlot(plot)
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return end
        for _, pod in ipairs(podiums:GetChildren()) do
            local base = pod:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            local attach = spawn and spawn:FindFirstChild("PromptAttachment")
            local key = plot.Name .. "_" .. pod.Name
            local prompt, text = nil, ""
            if attach then
                for _, c in ipairs(attach:GetChildren()) do
                    if c:IsA("ProximityPrompt") and c.Enabled then
                        text = c.ObjectText or ""
                        if text ~= "" then prompt = c break else prompt = nil end
                    else
                        prompt = nil
                    end
                end
            end
            if prompt and text ~= "" then
                local parent = attach.Parent
                if parent and parent:IsA("BasePart") then
                    local a, b = text:match("^(.-)%s*|%s*(.-)$")
                    local name, gen
                    if a and b then
                        name = a:match("^%s*(.-)%s*$")
                        gen = b:match("^%s*(.-)%s*$")
                    else
                        name = text
                        gen = text
                    end
                    if name == "" then name = pod.Name end
                    if BrainrotESP.cards[key] then updateCard(key, name, gen, parent)
                    else makeCard(parent, name, gen, key) end
                end
            elseif BrainrotESP.cards[key] then
                destroyCard(key)
            end
        end
    end

    local function scanAll()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        local seen = {}
        for _, plot in ipairs(plots:GetChildren()) do
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    seen[plot.Name .. "_" .. pod.Name] = true
                end
            end
            scanPlot(plot)
        end
        for k in pairs(BrainrotESP.cards) do
            if not seen[k] then destroyCard(k) end
        end
    end

    _G.BrainrotESP_Start = function()
        if BrainrotESP.running then return end
        BrainrotESP.running = true
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            scanAll()
            table.insert(BrainrotESP.conns, plots.DescendantAdded:Connect(function(d)
                if not BrainrotESP.running then return end
                if d:IsA("ProximityPrompt") then
                    task.defer(function()
                        local model = d:FindFirstAncestorWhichIsA("Model")
                        if model then scanPlot(model) end
                    end)
                end
            end))
            table.insert(BrainrotESP.conns, plots.DescendantRemoving:Connect(function(d)
                if not BrainrotESP.running then return end
                if d:IsA("ProximityPrompt") then task.defer(scanAll) end
            end))
            table.insert(BrainrotESP.conns, plots.ChildAdded:Connect(function()
                if not BrainrotESP.running then return end
                task.defer(scanAll)
            end))
        end
        table.insert(BrainrotESP.conns, task.spawn(function()
            while BrainrotESP.running do
                task.wait(1.5)
                if BrainrotESP.running then scanAll() end
            end
        end))
    end

    _G.BrainrotESP_Stop = function()
        BrainrotESP.running = false
        for _, c in ipairs(BrainrotESP.conns) do
            pcall(function()
                if typeof(c) == "RBXScriptConnection" then c:Disconnect()
                elseif typeof(c) == "thread" then task.cancel(c) end
            end)
        end
        BrainrotESP.conns = {}
        destroyAllCards()
    end

    -- ---------------- AUTO KICK ----------------
    local AutoKick = {
        running = false,
        patterns = { "you stole", "you have stolen", "stole from", "you were kicked" },
        watched = {},
        conns = {},
    }
    local function matchesKick(text)
        if type(text) ~= "string" then return false, nil end
        local low = text:lower()
        for _, p in ipairs(AutoKick.patterns) do
            if low:find(p, 1, true) then return true, p end
        end
        return false, nil
    end
    local function doKick(reason)
        if pcall(function() game:Shutdown() end) then return end
        pcall(function() LP:Kick("AutoKick: " .. tostring(reason or "steal detected")) end)
    end
    local function watchLabel(lbl)
        if AutoKick.watched[lbl] then return end
        AutoKick.watched[lbl] = true
        local function check()
            if not AutoKick.running then return end
            local hit, reason = matchesKick(lbl.Text)
            if hit then doKick(reason) end
        end
        check()
        table.insert(AutoKick.conns, lbl:GetPropertyChangedSignal("Text"):Connect(check))
        table.insert(AutoKick.conns, lbl.AncestryChanged:Connect(function()
            if not lbl:IsDescendantOf(game) then AutoKick.watched[lbl] = nil end
        end))
    end
    local function watchGui(gui)
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then watchLabel(d) end
        end
        table.insert(AutoKick.conns, gui.DescendantAdded:Connect(function(d)
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then watchLabel(d) end
        end))
    end
    _G.AutoKick_Start = function()
        if AutoKick.running then return end
        AutoKick.running = true
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then
            for _, c in ipairs(pg:GetChildren()) do
                if c:IsA("ScreenGui") or c:IsA("LayerCollector") then watchGui(c) end
            end
            table.insert(AutoKick.conns, pg.ChildAdded:Connect(function(c)
                if c:IsA("ScreenGui") or c:IsA("LayerCollector") then watchGui(c) end
            end))
        end
    end
    _G.AutoKick_Stop = function()
        AutoKick.running = false
        for _, c in ipairs(AutoKick.conns) do pcall(function() c:Disconnect() end) end
        AutoKick.conns = {}
        AutoKick.watched = {}
    end

    print("[sweet merge] SlotsESP / BrainrotESP / AutoKick loaded")
end

-- ============================================================
-- BUILD UI
-- ============================================================
local GearPanel, Holder1 = createPanel("Sweet Gear & Safety", "GearSafety", 270)

createToggle(Holder1, "Infinite Jump", CONFIG.InfiniteJump, function(v)
    CONFIG.InfiniteJump = v
    if v then InfiniteJump.Enable() else InfiniteJump.Disable() end
    saveConfig()
end)
createToggle(Holder1, "Anti Ragdoll", CONFIG.AntiRagdoll, function(v)
    CONFIG.AntiRagdoll = v
    if v then AntiRagdoll.Enable() else AntiRagdoll.Disable() end
    saveConfig()
end)
createToggle(Holder1, "X-Ray", CONFIG.XRay, function(v)
    CONFIG.XRay = v
    if v then XRay.Enable() else XRay.Disable() end
    saveConfig()
end)
createToggle(Holder1, "Slots ESP", CONFIG.SlotsESP, function(v)
    CONFIG.SlotsESP = v
    if v then _G.SlotsESP_Start() else _G.SlotsESP_Stop() end
    saveConfig()
end)
createToggle(Holder1, "Brainrot ESP", CONFIG.BrainrotESP, function(v)
    CONFIG.BrainrotESP = v
    if v then _G.BrainrotESP_Start() else _G.BrainrotESP_Stop() end
    saveConfig()
end)
createToggle(Holder1, "Next Base", CONFIG.NextBase, function(v)
    CONFIG.NextBase = v
    if v then NextBase_Start() else NextBase_Stop() end
    saveConfig()
end)
createToggle(Holder1, "Auto Equip Slot", CONFIG.AutoEquipOnSlot, function(v)
    CONFIG.AutoEquipOnSlot = v
    if v then AutoEquipSlot.Start() else AutoEquipSlot.Stop() end
    saveConfig()
end)
createToggle(Holder1, "Aimbot", CONFIG.Aimbot, function(v)
    CONFIG.Aimbot = v
    if v then Aimbot.Start() else Aimbot.Stop() end
    saveConfig()
end)
createToggle(Holder1, "Auto Kick", CONFIG.AutoKick, function(v)
    CONFIG.AutoKick = v
    if v then _G.AutoKick_Start() else _G.AutoKick_Stop() end
    saveConfig()
end)
createToggle(Holder1, "Steal Boost", CONFIG.StealBoost, function(v)
    CONFIG.StealBoost = v
    if v then StealBoost.Start() else StealBoost.Stop() end
    saveConfig()
end)

local Sep = Instance.new("Frame", Holder1)
Sep.Size = UDim2.new(1,0,0,1)
Sep.BackgroundColor3 = Theme.Accent
Sep.BackgroundTransparency = 0.8
Sep.BorderSizePixel = 0

local BottomRow = Instance.new("Frame", Holder1)
BottomRow.Size = UDim2.new(1,0,0,34)
BottomRow.BackgroundTransparency = 1

local ResetBtn = createButton(BottomRow, "Instant Reset",
    Theme.ResetAccent, Theme.ResetBg, Theme.ResetBgHov,
    function() InstaReset.Run() end)
ResetBtn.Size = UDim2.new(0.5,-3,1,0)
ResetBtn.Position = UDim2.new(0,0,0,0)

local DropBtn = createButton(BottomRow, "Drop",
    Theme.DropAccent, Theme.DropBg, Theme.DropBgHov,
    function() DropBrainrot.Run() end)
DropBtn.Size = UDim2.new(0.5,-3,1,0)
DropBtn.Position = UDim2.new(0.5,3,0,0)

local BindsBtn = createButton(Holder1, "Binds",
    Theme.BindsAccent, Theme.BindsBg, Theme.BindsBgHov,
    function()
        if _G.BindsWindow then _G.BindsWindow.Visible = not _G.BindsWindow.Visible end
    end)

-- ============================================================
-- JOB ID PANEL + EMPTY SERVER FINDER
-- ============================================================
local JobIdPanel, Holder2 = createPanel("Sweet Job ID", "JobId", 270)

-- FPS / PING pill on the right end of the Job ID panel (moves with it)
local STATS_PILL_W = 74
do
    local pill = Instance.new("Frame")
    pill.Name = "StatsPill"
    pill.Position = UDim2.new(1, 8, 0, 0)
    pill.Size = UDim2.fromOffset(STATS_PILL_W, 48)
    pill.BackgroundColor3 = Theme.Bg
    pill.BorderSizePixel = 0
    pill.Parent = JobIdPanel
    corner(pill, 14)
    mkStroke(pill, Theme.Accent, 1.2, 0.4)

    local function statLabel(y)
        local l = Instance.new("TextLabel", pill)
        l.BackgroundTransparency = 1
        l.Position = UDim2.new(0, 0, 0, y)
        l.Size = UDim2.new(1, 0, 0, 18)
        l.Font = Enum.Font.GothamBlack
        l.TextSize = 13
        l.TextColor3 = Theme.Text
        l.ZIndex = 5
        return l
    end
    local fpsLabel = statLabel(5)
    local pingLabel = statLabel(25)
    fpsLabel.Text = "0 FPS"
    pingLabel.Text = "0 ms"

    local frames, windowStart, currentFps = 0, os.clock(), 0
    RunService.Heartbeat:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - windowStart >= 0.5 then
            currentFps = math.floor(frames / (now - windowStart) + 0.5)
            frames = 0
            windowStart = now
        end
    end)
    local function readPing()
        local ok, value = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if ok and value and value > 0 then return math.floor(value) end
        ok, value = pcall(function() return LP:GetNetworkPing() * 1000 end)
        if ok and value then return math.floor(value) end
        return 0
    end
    task.spawn(function()
        while pill.Parent do
            fpsLabel.Text = tostring(currentFps) .. " FPS"
            fpsLabel.TextColor3 = currentFps >= 60 and Color3.fromRGB(140, 255, 110)
                or currentFps >= 30 and Color3.fromRGB(255, 190, 70)
                or Color3.fromRGB(255, 80, 110)
            local ping = readPing()
            pingLabel.Text = tostring(ping) .. " ms"
            pingLabel.TextColor3 = ping < 80 and Color3.fromRGB(140, 255, 110)
                or ping < 150 and Color3.fromRGB(255, 190, 70)
                or Color3.fromRGB(255, 80, 110)
            task.wait(0.5)
        end
    end)
end

local JobIdRow = Instance.new("Frame", Holder2)
JobIdRow.Size = UDim2.new(1,0,0,36)
JobIdRow.BackgroundColor3 = Theme.BgCard
JobIdRow.BorderSizePixel = 0
corner(JobIdRow, 9)
mkStroke(JobIdRow, Theme.StrokeSoft, 1, 0.55)

local JobIdText = Instance.new("TextLabel", JobIdRow)
JobIdText.Size = UDim2.new(1,-16,1,0)
JobIdText.Position = UDim2.fromOffset(8,0)
JobIdText.BackgroundTransparency = 1
JobIdText.Font = Enum.Font.GothamBold
JobIdText.TextSize = 11
JobIdText.TextColor3 = Theme.Text
JobIdText.TextXAlignment = Enum.TextXAlignment.Center
JobIdText.TextTruncate = Enum.TextTruncate.AtEnd
JobIdText.Text = CONFIG.ShowJobId and JobIdSaver.GetJobId() or string.rep("•",36)

local JobBtnRow = Instance.new("Frame", Holder2)
JobBtnRow.Size = UDim2.new(1,0,0,34)
JobBtnRow.BackgroundTransparency = 1

local CopyBtn = createButton(JobBtnRow, "Copy",
    Theme.AccentBright, Theme.BtnBg, Theme.BtnBgHover,
    function()
        local id, ok = JobIdSaver.Copy()
        CopyBtn.Text = ok and "Copied!" or "Failed"
        JobIdText.Text = id
        task.delay(1.2, function()
            if CopyBtn and CopyBtn.Parent then CopyBtn.Text = "Copy" end
        end)
    end)
CopyBtn.Size = UDim2.new(0.5,-3,1,0)
CopyBtn.Position = UDim2.new(0,0,0,0)

local ShowBtn = createButton(JobBtnRow, CONFIG.ShowJobId and "Hide" or "Show",
    Theme.AccentBright, Theme.BtnBg, Theme.BtnBgHover,
    function()
        CONFIG.ShowJobId = not CONFIG.ShowJobId
        JobIdText.Text = CONFIG.ShowJobId and JobIdSaver.GetJobId() or string.rep("•",36)
        ShowBtn.Text   = CONFIG.ShowJobId and "Hide" or "Show"
        saveConfig()
    end)
ShowBtn.Size = UDim2.new(0.5,-3,1,0)
ShowBtn.Position = UDim2.new(0.5,3,0,0)

local EmptyFinderStage = "closed"
local EmptyFinderServer = nil
local EmptyFinderBusy = false
local EMPTY_OPEN_HEIGHT = 100
local EmptyFinder_Open
local EmptyFinder_Close

local EmptyFinderBtn = createButton(Holder2, "Empty Server Finder",
    Theme.AccentBright, Theme.BtnBg, Theme.BtnBgHover,
    function()
        if EmptyFinderStage == "closed" then
            EmptyFinder_Open()
        else
            EmptyFinder_Close()
        end
    end)

local EmptyFinderInline = Instance.new("Frame", Holder2)
EmptyFinderInline.Name = "EmptyServerFinderInline"
EmptyFinderInline.Size = UDim2.new(1, 0, 0, 0)
EmptyFinderInline.BackgroundColor3 = Theme.BgCard
EmptyFinderInline.BackgroundTransparency = 0
EmptyFinderInline.BorderSizePixel = 0
EmptyFinderInline.ClipsDescendants = true
EmptyFinderInline.Visible = true
EmptyFinderInline.ZIndex = 10
corner(EmptyFinderInline, 10)
mkStroke(EmptyFinderInline, Theme.StrokeSoft, 1, 0.5)

local EmptyFinderTitle = Instance.new("TextLabel", EmptyFinderInline)
EmptyFinderTitle.Position = UDim2.fromOffset(10, 9)
EmptyFinderTitle.Size = UDim2.new(1, -20, 0, 20)
EmptyFinderTitle.BackgroundTransparency = 1
EmptyFinderTitle.Font = Enum.Font.GothamBlack
EmptyFinderTitle.TextSize = 12
EmptyFinderTitle.TextColor3 = Theme.Text
EmptyFinderTitle.TextXAlignment = Enum.TextXAlignment.Center
EmptyFinderTitle.Text = "ARE YOU SURE?"
EmptyFinderTitle.ZIndex = 11

local EmptyFinderSub = Instance.new("TextLabel", EmptyFinderInline)
EmptyFinderSub.Position = UDim2.fromOffset(10, 30)
EmptyFinderSub.Size = UDim2.new(1, -20, 0, 20)
EmptyFinderSub.BackgroundTransparency = 1
EmptyFinderSub.Font = Enum.Font.GothamBold
EmptyFinderSub.TextSize = 10
EmptyFinderSub.TextColor3 = Theme.TextDim
EmptyFinderSub.TextXAlignment = Enum.TextXAlignment.Center
EmptyFinderSub.TextWrapped = true
EmptyFinderSub.Text = "YOU HAVE TO BE 0 REBIRTH"
EmptyFinderSub.ZIndex = 11

local EmptyFinderAction = Instance.new("TextButton", EmptyFinderInline)
EmptyFinderAction.Position = UDim2.fromOffset(10, 58)
EmptyFinderAction.Size = UDim2.new(0.5, -15, 0, 32)
EmptyFinderAction.BackgroundColor3 = Theme.TrackOn
EmptyFinderAction.TextColor3 = Color3.fromRGB(245, 242, 255)
EmptyFinderAction.Font = Enum.Font.GothamBlack
EmptyFinderAction.TextSize = 11
EmptyFinderAction.Text = "YES"
EmptyFinderAction.AutoButtonColor = false
EmptyFinderAction.ZIndex = 11
corner(EmptyFinderAction, 9)

local EmptyFinderCancel = Instance.new("TextButton", EmptyFinderInline)
EmptyFinderCancel.Position = UDim2.new(0.5, 5, 0, 58)
EmptyFinderCancel.Size = UDim2.new(0.5, -15, 0, 32)
EmptyFinderCancel.BackgroundColor3 = Theme.BgRow
EmptyFinderCancel.TextColor3 = Theme.TextDim
EmptyFinderCancel.Font = Enum.Font.GothamBlack
EmptyFinderCancel.TextSize = 11
EmptyFinderCancel.Text = "NO"
EmptyFinderCancel.AutoButtonColor = false
EmptyFinderCancel.ZIndex = 11
corner(EmptyFinderCancel, 9)

local function EmptyFinder_Set(message, actionText, cancelText)
    local lines = string.split(message, "\n")
    EmptyFinderTitle.Text = lines[1] or "ARE YOU SURE?"
    EmptyFinderSub.Text = lines[3] or lines[2] or ""
    EmptyFinderAction.Text = actionText
    EmptyFinderCancel.Text = cancelText or "NO"
    EmptyFinderAction.Visible = true
    EmptyFinderCancel.Visible = true
    EmptyFinderAction.Active = actionText ~= "SEARCHING..." and actionText ~= "TELEPORTING..."
    EmptyFinderCancel.Active = true
    if actionText == "SEARCHING..." or actionText == "TELEPORTING..." then
        EmptyFinderAction.Size = UDim2.new(1, -20, 0, 32)
        EmptyFinderAction.Position = UDim2.fromOffset(10, 58)
        EmptyFinderCancel.Visible = false
    else
        EmptyFinderAction.Size = UDim2.new(0.5, -15, 0, 32)
        EmptyFinderAction.Position = UDim2.fromOffset(10, 58)
        EmptyFinderCancel.Position = UDim2.new(0.5, 5, 0, 58)
        EmptyFinderCancel.Size = UDim2.new(0.5, -15, 0, 32)
    end
end

EmptyFinder_Open = function()
    EmptyFinderStage = "rebirth"
    EmptyFinderServer = nil
    EmptyFinderBusy = false
    EmptyFinder_Set("ARE YOU SURE?\n\nYOU HAVE TO BE 0 REBIRTH", "YES", "NO")
    tween(EmptyFinderInline, 0.18, { Size = UDim2.new(1, 0, 0, EMPTY_OPEN_HEIGHT) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
end

function EmptyFinder_Show(stage)
    EmptyFinderStage = stage
    EmptyFinderServer = nil
    EmptyFinderBusy = false
    if stage == "rebirth" then
        EmptyFinder_Set("ARE YOU SURE?\n\nYOU HAVE TO BE 0 REBIRTH", "YES", "NO")
    elseif stage == "warning" then
        EmptyFinder_Set("ARE YOU SURE?\n\nYOU MIGHT BE OVER 100 PING OR HIGHER", "TELEPORT ME", "NO")
    elseif stage == "searching" then
        EmptyFinder_Set("SEARCHING...\n\nFINDING A LOW-POPULATION SERVER", "SEARCHING...", "CANCEL")
        EmptyFinderAction.Active = false
    end
end

EmptyFinder_Close = function()
    EmptyFinderStage = "closed"
    EmptyFinderServer = nil
    EmptyFinderBusy = false
    tween(EmptyFinderInline, 0.16, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

EmptyFinderCancel.Activated:Connect(function() EmptyFinder_Close() end)
EmptyFinderAction.Activated:Connect(function()
    if EmptyFinderBusy then return end
    if EmptyFinderStage == "rebirth" then
        EmptyFinderStage = "warning"
        EmptyFinder_Set("ARE YOU SURE?\n\nYOU MIGHT BE OVER 100 PING OR HIGHER", "TELEPORT ME", "NO")
        return
    end
    if EmptyFinderStage ~= "warning" then return end
    EmptyFinderBusy = true
    EmptyFinder_Show("searching")
    task.spawn(function()
        local server, ping = EmptyServer_findBestServer()
        if not EmptyFinderInline.Parent or EmptyFinderStage ~= "searching" then return end
        if server then
            EmptyFinderServer = server
            EmptyFinder_Set(string.format("SERVER FOUND\n\n%d PLAYER(S) • EST. %.0fMS", server.playing, ping), "TELEPORTING...", "CANCEL")
            EmptyFinderAction.Active = false
            task.wait(0.25)
            if EmptyFinderServer and EmptyFinderStage == "searching" then
                TeleportService:TeleportToPlaceInstance(EMPTY_SERVER_PLACE_ID, EmptyFinderServer.id, Players.LocalPlayer)
            end
        else
            EmptyFinderBusy = false
            EmptyFinderStage = "warning"
            EmptyFinder_Set("NO SUITABLE SERVER\n\nTRY AGAIN?", "TELEPORT ME", "NO")
        end
    end)
end)

-- ============================================================
-- BINDS WINDOW
-- ============================================================
local BindsWindow = Instance.new("Frame", Gui)
BindsWindow.Name = "BindsWindow"
BindsWindow.AnchorPoint = Vector2.new(0.5,0.5)
BindsWindow.Position = UDim2.new(0.5,0,0.5,0)
BindsWindow.Size = UDim2.new(0,320,0,360)
BindsWindow.BackgroundColor3 = Theme.Bg
BindsWindow.BorderSizePixel = 0
BindsWindow.Visible = false
BindsWindow.ZIndex = 200
corner(BindsWindow, 14)
mkStroke(BindsWindow, Theme.Accent, 1.2, 0.4)

local BH = Instance.new("Frame", BindsWindow)
BH.Size = UDim2.new(1,0,0,46)
BH.BackgroundColor3 = Theme.BgCard
BH.BorderSizePixel = 0
corner(BH, 14)
local BHFill = Instance.new("Frame", BindsWindow)
BHFill.Position = UDim2.new(0,0,0,26) BHFill.Size = UDim2.new(1,0,0,20)
BHFill.BackgroundColor3 = Theme.BgCard BHFill.BorderSizePixel = 0 BHFill.ZIndex = 2

local BHAccent = Instance.new("Frame", BindsWindow)
BHAccent.Position = UDim2.new(0,0,0,10) BHAccent.Size = UDim2.new(0,3,0,26)
BHAccent.BackgroundColor3 = Theme.Accent BHAccent.BorderSizePixel = 0
corner(BHAccent, 3) BHAccent.ZIndex = 3

local BHLabel = Instance.new("TextLabel", BindsWindow)
BHLabel.Position = UDim2.new(0,16,0,12) BHLabel.Size = UDim2.new(1,-60,0,24)
BHLabel.BackgroundTransparency = 1 BHLabel.Font = Enum.Font.GothamBlack
BHLabel.TextSize = 15 BHLabel.TextColor3 = Theme.Text
BHLabel.TextXAlignment = Enum.TextXAlignment.Left BHLabel.Text = "BINDS"
BHLabel.ZIndex = 4

local BHClose = Instance.new("TextButton", BindsWindow)
BHClose.AnchorPoint = Vector2.new(1,0.5) BHClose.Position = UDim2.new(1,-12,0,23)
BHClose.Size = UDim2.fromOffset(24,24) BHClose.BackgroundColor3 = Theme.BgRow
BHClose.Text = "×" BHClose.Font = Enum.Font.GothamBold
BHClose.TextSize = 16 BHClose.TextColor3 = Theme.TextDim
BHClose.AutoButtonColor = false BHClose.ZIndex = 5
corner(BHClose, 7)
mkStroke(BHClose, Theme.StrokeSoft, 1, 0.65)
BHClose.MouseEnter:Connect(function() tween(BHClose,0.12,{BackgroundColor3=Theme.ResetBg,TextColor3=Theme.ResetAccent}) end)
BHClose.MouseLeave:Connect(function() tween(BHClose,0.12,{BackgroundColor3=Theme.BgRow,TextColor3=Theme.TextDim}) end)
BHClose.MouseButton1Click:Connect(function() BindsWindow.Visible=false end)

local BHDiv = Instance.new("Frame", BindsWindow)
BHDiv.Position = UDim2.new(0,0,0,46) BHDiv.Size = UDim2.new(1,0,0,1)
BHDiv.BackgroundColor3 = Theme.Accent BHDiv.BackgroundTransparency = 0.7
BHDiv.BorderSizePixel = 0 BHDiv.ZIndex = 3

local BHolderOuter = Instance.new("Frame", BindsWindow)
BHolderOuter.Position = UDim2.new(0,10,0,54)
BHolderOuter.Size = UDim2.new(1,-20,1,-66)
BHolderOuter.BackgroundTransparency = 1

local BScroll = Instance.new("ScrollingFrame", BHolderOuter)
BScroll.Size = UDim2.new(1,0,1,0)
BScroll.BackgroundTransparency = 1
BScroll.BorderSizePixel = 0
BScroll.ScrollBarThickness = 3
BScroll.ScrollBarImageColor3 = Theme.Accent
BScroll.CanvasSize = UDim2.new(0,0,0,0)
BScroll.Active = true
local BLayout = Instance.new("UIListLayout", BScroll)
BLayout.Padding = UDim.new(0,7) BLayout.SortOrder = Enum.SortOrder.LayoutOrder
BLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    BScroll.CanvasSize = UDim2.new(0, 0, 0, BLayout.AbsoluteContentSize.Y)
end)
local BHolder = BScroll

_G.BindsWindow = BindsWindow

local function createBindRow(parent, text, currentBind, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1,-4,0,42) Row.BackgroundColor3 = Theme.BgRow
    Row.BorderSizePixel = 0 corner(Row, 9)
    mkStroke(Row, Theme.StrokeSoft, 1, 0.72)

    local Label = Instance.new("TextLabel", Row)
    Label.Position = UDim2.fromOffset(14,0) Label.Size = UDim2.new(1,-100,1,0)
    Label.BackgroundTransparency = 1 Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14 Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left Label.Text = text

    local Btn = Instance.new("TextButton", Row)
    Btn.AnchorPoint = Vector2.new(1,0.5) Btn.Position = UDim2.new(1,-10,0.5,0)
    Btn.Size = UDim2.fromOffset(66,26) Btn.BackgroundColor3 = Theme.BtnBg
    Btn.Text = currentBind Btn.AutoButtonColor = false
    Btn.Font = Enum.Font.GothamBlack Btn.TextSize = 13 Btn.TextColor3 = Theme.AccentBright
    corner(Btn, 8)
    local btnStroke = mkStroke(Btn, Theme.AccentBright, 1, 0.55)

    local listening = false
    local inputConn

    Btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        Btn.Text = "..."
        Btn.TextColor3 = Theme.ResetAccent
        tween(btnStroke, 0.15, {Color=Theme.ResetAccent, Transparency=0.15})
        inputConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Btn.Text = input.KeyCode.Name
                Btn.TextColor3 = Theme.AccentBright
                tween(btnStroke, 0.15, {Color=Theme.AccentBright, Transparency=0.55})
                listening = false
                if callback then callback(input.KeyCode.Name) end
                if inputConn then inputConn:Disconnect() end
            end
        end)
    end)
    Btn.MouseEnter:Connect(function() tween(Btn,0.12,{BackgroundColor3=Theme.BtnBgHover}) end)
    Btn.MouseLeave:Connect(function() tween(Btn,0.12,{BackgroundColor3=Theme.BtnBg}) end)
    Row.MouseEnter:Connect(function() tween(Row,0.12,{BackgroundColor3=Theme.BgRowHov}) end)
    Row.MouseLeave:Connect(function() tween(Row,0.12,{BackgroundColor3=Theme.BgRow}) end)
    return Btn
end

createBindRow(BHolder, "Carpet Speed",  CONFIG.Bind_CarpetSpeed,  function(k) CONFIG.Bind_CarpetSpeed  = k saveConfig() end)
createBindRow(BHolder, "Instant Reset", CONFIG.Bind_InstantReset, function(k) CONFIG.Bind_InstantReset = k saveConfig() end)
createBindRow(BHolder, "Drop",          CONFIG.Bind_Drop,         function(k) CONFIG.Bind_Drop         = k saveConfig() end)
createBindRow(BHolder, "Aimbot",        CONFIG.Bind_Aimbot,       function(k) CONFIG.Bind_Aimbot       = k saveConfig() end)
createBindRow(BHolder, "Auto Kick",     CONFIG.Bind_AutoKick,     function(k) CONFIG.Bind_AutoKick     = k saveConfig() end)
createBindRow(BHolder, "Steal Boost",   CONFIG.Bind_StealBoost,   function(k) CONFIG.Bind_StealBoost   = k saveConfig() end)

local bDragging, bStart, bStartPos
BH.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        bDragging=true bStart=input.Position bStartPos=BindsWindow.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if bDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-bStart
        local s = guiScale.Scale
        BindsWindow.Position=UDim2.new(
            bStartPos.X.Scale, bStartPos.X.Offset+delta.X / s,
            bStartPos.Y.Scale, bStartPos.Y.Offset+delta.Y / s)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        if bDragging then
            CONFIG.Positions.BindsWindow={X=BindsWindow.Position.X.Offset,Y=BindsWindow.Position.Y.Offset}
            saveConfig()
        end
        bDragging=false
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = input.KeyCode.Name
    if k == CONFIG.Bind_Aimbot then
        CONFIG.Aimbot = not CONFIG.Aimbot
        if CONFIG.Aimbot then Aimbot.Start() else Aimbot.Stop() end
        saveConfig()
        return
    end
    if k == CONFIG.Bind_CarpetSpeed then
        local newState = not CONFIG.CarpetSpeed
        CONFIG.CarpetSpeed = newState
        if newState then
            local ok = CarpetSpeed.Start()
            if not ok then CONFIG.CarpetSpeed = false end
        else
            CarpetSpeed.Stop()
        end
        saveConfig()
    elseif k == CONFIG.Bind_InstantReset then
        InstaReset.Run()
    elseif k == CONFIG.Bind_Drop then
        DropBrainrot.Run()
    elseif k == CONFIG.Bind_AutoKick then
        CONFIG.AutoKick = not CONFIG.AutoKick
        if CONFIG.AutoKick then _G.AutoKick_Start() else _G.AutoKick_Stop() end
        saveConfig()
    elseif k == CONFIG.Bind_StealBoost then
        CONFIG.StealBoost = not CONFIG.StealBoost
        if CONFIG.StealBoost then StealBoost.Start() else StealBoost.Stop() end
        saveConfig()
    end
end)

-- ============================================================
-- RESTORE STATES
-- ============================================================
local function restoreStates()
    if CONFIG.NextBase        then pcall(NextBase_Start)        end
    if CONFIG.AntiRagdoll     then pcall(AntiRagdoll.Enable)    end
    if CONFIG.InfiniteJump    then pcall(InfiniteJump.Enable)   end
    if CONFIG.XRay            then pcall(XRay.Enable)           end
    if CONFIG.AutoEquipOnSlot then pcall(AutoEquipSlot.Start)   end
    if CONFIG.Aimbot          then pcall(Aimbot.Start)          end
    if CONFIG.SlotsESP        then pcall(_G.SlotsESP_Start)     end
    if CONFIG.BrainrotESP     then pcall(_G.BrainrotESP_Start)  end
    if CONFIG.AutoKick        then pcall(_G.AutoKick_Start)     end
    if CONFIG.StealBoost      then pcall(StealBoost.Start)      end
    if CONFIG.CarpetSpeed then
        task.wait(0.5)
        local ok = CarpetSpeed.Start()
        if not ok then CONFIG.CarpetSpeed = false saveConfig() end
    end
end

task.spawn(function()
    repeat task.wait(0.1) until game:IsLoaded()
    if not LP.Character then
        LP.CharacterAdded:Wait()
    end
    task.wait(1)
    restoreStates()
end)

LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if CONFIG.InfiniteJump and InfiniteJump.enabled then
        InfiniteJump.Disable()
        InfiniteJump.Enable()
    end
    if CONFIG.AntiRagdoll and AntiRagdoll.enabled then
        pcall(function() AntiRagdoll.Disable() end)
        pcall(function() AntiRagdoll.Enable()  end)
    end
    if CONFIG.CarpetSpeed then
        local ok = CarpetSpeed.Start()
        if not ok then CONFIG.CarpetSpeed = false saveConfig() end
    end
end)

game:BindToClose(function() saveConfig() end)

-- ============================================================
-- MOBILE POSITIONING
-- ============================================================
if DEVICE == "iphone" then
    if not CONFIG.Positions.GearSafety  then CONFIG.Positions.GearSafety  = { X = 8,  Y = 40  } end
    if not CONFIG.Positions.JobId       then CONFIG.Positions.JobId       = { X = 8,  Y = 220 } end
    if not CONFIG.Positions.BindsWindow then CONFIG.Positions.BindsWindow = { X = 20, Y = 320 } end
elseif DEVICE == "ipad" then
    if not CONFIG.Positions.GearSafety  then CONFIG.Positions.GearSafety  = { X = 40, Y = 80  } end
    if not CONFIG.Positions.JobId       then CONFIG.Positions.JobId       = { X = 40, Y = 320 } end
end


-- ============================================================
-- PANEL LAYOUT — panels follow the screen they are on (portrait / landscape / another phone)
-- ============================================================
local function layoutPanels(forceReset)
    if not GearPanel or not GearPanel.Parent or not JobIdPanel or not JobIdPanel.Parent then return end
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local s = math.max(guiScale.Scale, 0.1)
    local maxX, maxY = vp.X / s, vp.Y / s
    local viewKey = string.format("%dx%d", math.floor(vp.X / 50), math.floor(vp.Y / 50))
    local function dims(p) return p.AbsoluteSize.X / s, p.AbsoluteSize.Y / s end
    local function inside(p, extra)
        local w, h = dims(p)
        w = w + (extra or 0)
        local x, y = p.Position.X.Offset, p.Position.Y.Offset
        return x >= 0 and y >= 0 and x + w <= maxX + 1 and y + h <= maxY + 1
    end
    local gw, gh = dims(GearPanel)
    local jw, jh = dims(JobIdPanel)
    jw = jw + STATS_PILL_W + 8
    local gx, gy = GearPanel.Position.X.Offset, GearPanel.Position.Y.Offset
    local jx, jy = JobIdPanel.Position.X.Offset, JobIdPanel.Position.Y.Offset
    local overlapping = gx < jx + jw and jx < gx + gw and gy < jy + jh and jy < gy + gh
    if forceReset or CONFIG.ViewKey ~= viewKey or not inside(GearPanel) or not inside(JobIdPanel, STATS_PILL_W + 8) or overlapping then
        local top = math.min(62 / s, math.max(4, maxY - gh - 4))
        gx, gy = 8, top
        if gx + gw + 8 + jw <= maxX then
            jx, jy = gx + gw + 8, top
        elseif gy + gh + 8 + jh <= maxY then
            jx, jy = gx, gy + gh + 8
        else
            jx, jy = math.max(4, maxX - jw - 4), math.max(4, maxY - jh - 4)
        end
        GearPanel.Position = UDim2.new(0, gx, 0, gy)
        JobIdPanel.Position = UDim2.new(0, jx, 0, jy)
    end
    GearPanel.Visible = true
    JobIdPanel.Visible = true
    CONFIG.ViewKey = viewKey
    CONFIG.Positions.GearSafety = { X = GearPanel.Position.X.Offset, Y = GearPanel.Position.Y.Offset }
    CONFIG.Positions.JobId = { X = JobIdPanel.Position.X.Offset, Y = JobIdPanel.Position.Y.Offset }
    saveConfig()
end

task.spawn(function()
    task.wait(0.6)
    pcall(layoutPanels, false)
    local cam = workspace.CurrentCamera
    if cam then
        local pending = 0
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            pending = pending + 1
            local mine = pending
            task.wait(0.6)
            if mine == pending then pcall(layoutPanels, false) end
        end)
    end
end)

pcall(function()
    for _, parent in ipairs({ (gethui and gethui()) or game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui") }) do
        if parent then
            local autoGui = parent:FindFirstChild("bRXgmsaEVfze")
            if autoGui and DEVICE ~= "desktop" then
                local hud = autoGui:FindFirstChild("CurrentTargetHUD")
                if hud then
                    local cam = workspace.CurrentCamera
                    if cam and cam.ViewportSize.Y < 520 then hud.Position = UDim2.new(0.5, 0, 1, -18)
                    elseif DEVICE == "iphone" then hud.Position = UDim2.new(0.5, 0, 1, -260)
                    else hud.Position = UDim2.new(0.5, 0, 1, -240) end
                end
            end
        end
    end
end)

print("[sweet tp hub] loaded — device:", DEVICE, "scale:", string.format("%.2f", guiScale.Scale))
print("[sweet tp hub] toggles: SlotsESP, BrainrotESP, AutoKick, NextBase, XRay, CarpetSpeed, Aimbot, AutoEquipSlot, StealBoost")
print("[sweet tp hub] auto grab: original block, untouched")