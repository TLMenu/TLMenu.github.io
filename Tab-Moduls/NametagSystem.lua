--!nocheck
-- Standalone Module: NametagSystem
-- Extracted from TLMenu

local NametagSystem = {}

function NametagSystem.Init(ctx)
    ctx = type(ctx) == "table" and ctx or {}
    local game = ctx.game or game
    local _genv = ctx._genv or (getgenv and getgenv()) or _G or {}
    local _SvcUIS = game:GetService("UserInputService")
    local _SvcRS  = game:GetService("RunService")
    local _SvcPlr = game:GetService("Players")
    local LocalPlayer = ctx.LocalPlayer or _SvcPlr.LocalPlayer
    local ScreenGui = ctx.ScreenGui
    local makePanel = ctx.makePanel or function(name, accent)
        local p = Instance.new("Frame")
        p.Name = name
        local c = Instance.new("ScrollingFrame", p)
        c.Name = "Content"
        return p, c
    end
    local C = ctx.C or {
        accent = Color3.fromRGB(0, 170, 255),
        accent2 = Color3.fromRGB(0, 200, 255),
        sub = Color3.fromRGB(150, 150, 150),
        text = Color3.fromRGB(255, 255, 255),
        panelBg = Color3.fromRGB(20, 20, 20),
        bg3 = Color3.fromRGB(40, 40, 40)
    }
    local PANEL_W = ctx.PANEL_W or 540
    local _sc = ctx._sc or {}
    local _TL_refs = ctx._TL_refs or {}
    local _TL_loadModule = ctx._TL_loadModule or function() return nil end
    local _TL_VP = ctx._TL_VP or { isMobile = false, isTablet = false, isTouch = false, long = 800, short = 600 }

    -- =========================================================================
    -- UNIVERSAL EXECUTOR & 100% MOBILE / HANDY COMPATIBILITY LAYER
    -- Special Support for: Potassium, Madium, Real, Delta, Hydrogen, Fluxus, Wave, Synapse, Solara, Celery, Codex, Arceus X, KRNL, Swift
    -- =========================================================================
    local _genv = (getgenv and getgenv()) or _G or {}
    local _SvcUIS = game:GetService("UserInputService")
    local _SvcGS  = game:GetService("GuiService")
    local _SvcRS  = game:GetService("RunService")
    local _SvcPlr = game:GetService("Players")

    -- Executor Identification (Potassium, Madium, Real, etc.)
    local _execName = "Unknown"
    if type(identifyexecutor) == "function" then
        pcall(function() _execName = tostring(identifyexecutor()) end)
    elseif type(getexecutorname) == "function" then
        pcall(function() _execName = tostring(getexecutorname()) end)
    elseif rawget(_genv, "potassium") or rawget(_genv, "Potassium") then
        _execName = "Potassium"
    elseif rawget(_genv, "madium") or rawget(_genv, "Madium") then
        _execName = "Madium"
    elseif rawget(_genv, "real") or rawget(_genv, "Real") or rawget(_genv, "realexecutor") then
        _execName = "Real"
    end

    -- Universal FileSystem API Wrappers
    local _safeIsFile = function(p) return (type(isfile) == "function") and pcall(isfile, p) end
    local _safeReadFile = function(p) local ok, r = pcall(readfile, p); return ok and r end
    local _safeWriteFile = function(p, d) if type(writefile) == "function" then pcall(writefile, p, d) end end
    local _safeMakeFolder = function(p) if type(makefolder) == "function" then pcall(makefolder, p) end end

    -- Universal Asset Loader (Potassium, Madium, Real, Synapse, etc.)
    local _safeGetCustomAsset = function(p)
        if type(getcustomasset) == "function" then local ok, r = pcall(getcustomasset, p); if ok and r and r ~= "" then return r end end
        if type(getsynasset) == "function" then local ok, r = pcall(getsynasset, p); if ok and r and r ~= "" then return r end end
        if type(getasset) == "function" then local ok, r = pcall(getasset, p); if ok and r and r ~= "" then return r end end
        if type(custom_asset) == "function" then local ok, r = pcall(custom_asset, p); if ok and r and r ~= "" then return r end end
        return nil
    end

    -- Universal HTTP Request / HttpGet Wrapper
    local _safeHttpRequest = function(reqOpts)
        local reqFn = (type(request) == "function" and request)
            or (type(http_request) == "function" and http_request)
            or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
            or (type(http) == "table" and type(http.request) == "function" and http.request)
        if reqFn then
            local ok, res = pcall(reqFn, reqOpts)
            if ok and res and res.Body then return res.Body end
        end
        return nil
    end

    local _safeHttpGet = function(url)
        if type(httpget) == "function" then local ok, r = pcall(httpget, url); if ok and r then return r end end
        local reqBody = _safeHttpRequest({ Url = url, Method = "GET" })
        if reqBody and #reqBody >= 10 then return reqBody end
        local ok, r = pcall(function() return (game :: any):HttpGet(url) end)
        if ok and r then return r end
        return nil
    end

    -- Mobile & Touch Responsiveness Layer
    local _cam = workspace.CurrentCamera
    local _vpSize = (_cam and _cam.ViewportSize) or Vector2.new(1280, 720)
    local _isTouch = pcall(function() return _SvcUIS.TouchEnabled end) and _SvcUIS.TouchEnabled
    local _isKbd   = pcall(function() return _SvcUIS.KeyboardEnabled end) and _SvcUIS.KeyboardEnabled
    local _shortDim = math.min(_vpSize.X, _vpSize.Y)
    local _isMobile = _isTouch and not _isKbd and _shortDim < 500
    local _isTablet = _isTouch and not _isKbd and _shortDim >= 500 and _shortDim < 900
    local _uiScale  = (_isMobile and 0.82) or (_isTablet and 0.90) or 1.0

    -- Universal Touch & Mouse Binder Helper
    local function _bindTouchClick(guiObj, callback)
        if not guiObj then return end
        pcall(function()
            guiObj.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    callback(input)
                end
            end)
        end)
    end

    local game = ctx.game or game
    local _genv = ctx._genv or getgenv()
    local _SvcHttp = game:GetService("HttpService")
    local _SvcPlr = game:GetService("Players")
    local LocalPlayer = _SvcPlr.LocalPlayer
    local TweenService = game:GetService("TweenService")
    local AdminNames = ctx.AdminNames or {}
    local NameOverrides = ctx.NameOverrides or {}
    local customUserAvatars = ctx.customUserAvatars or {}
    local CoreGui = game:GetService("CoreGui")

    local function _getGuiContainer()
        if typeof(gethui) == "function" then
            local ok, h = pcall(gethui)
            if ok and h then return h end
        end
        local okC, cg = pcall(function() return game:GetService("CoreGui") end)
        if okC and cg then
            local okTest, _ = pcall(function() return cg:GetChildren() end)
            if okTest then return cg end
        end
        local lp = LocalPlayer or _SvcPlr.LocalPlayer
        if lp then
            local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
            if pg then return pg end
        end
        return CoreGui
    end

    local function _findExistingBillboard(pName)
        local p = _SvcPlr:FindFirstChild(pName)
        if p and p.Character then
            local h = p.Character:FindFirstChild("Head")
            if h then
                local b = h:FindFirstChild("CovertPeerTag_" .. pName)
                if b then return b end
            end
            local bChar = p.Character:FindFirstChild("CovertPeerTag_" .. pName)
            if bChar then return bChar end
        end
        local lp = LocalPlayer or _SvcPlr.LocalPlayer
        if lp then
            local pg = lp:FindFirstChildOfClass("PlayerGui")
            if pg then
                local b = pg:FindFirstChild("CovertPeerTag_" .. pName)
                if b then return b end
            end
        end
        local c = _getGuiContainer()
        if c then
            local b = c:FindFirstChild("CovertPeerTag_" .. pName)
            if b then return b end
        end
        return nil
    end

    local function _NT_safeFont(fontName, fallback)
        fallback = fallback or Enum.Font.SourceSans
        if not fontName then return fallback end
        local ok, val = pcall(function() return Enum.Font[fontName] end)
        if ok and val then return val end
        return fallback
    end

    local _DEFAULT_BOLD = _NT_safeFont("GothamBold", _NT_safeFont("SourceSansBold"))
    local _DEFAULT_REGULAR = _NT_safeFont("Gotham", _NT_safeFont("SourceSans"))

    local _NT_FONT_MAP = {
        ["GothamBold"]        = _NT_safeFont("GothamBold", _DEFAULT_BOLD),
        ["Gotham"]            = _NT_safeFont("Gotham", _DEFAULT_REGULAR),
        ["GothamMedium"]      = _NT_safeFont("GothamMedium", _DEFAULT_BOLD),
        ["GothamBlack"]       = _NT_safeFont("GothamBlack", _DEFAULT_BOLD),
        ["GothamLight"]       = _NT_safeFont("GothamLight", _DEFAULT_REGULAR),
        ["GothamThin"]        = _NT_safeFont("GothamThin", _DEFAULT_REGULAR),
        ["SourceSans"]        = _NT_safeFont("SourceSans"),
        ["SourceSansBold"]    = _NT_safeFont("SourceSansBold"),
        ["SourceSansLight"]   = _NT_safeFont("SourceSansLight"),
        ["SourceSansSemibold"]= _NT_safeFont("SourceSansSemibold"),
        ["Cartoon"]           = _NT_safeFont("Cartoon"),
        ["Highway"]           = _NT_safeFont("Highway"),
        ["SciFi"]             = _NT_safeFont("SciFi"),
        ["Arial"]             = _NT_safeFont("Arial"),
        ["ArialBold"]         = _NT_safeFont("ArialBold"),
        ["Ubuntu"]            = _NT_safeFont("Ubuntu"),
        ["UbuntuBold"]        = _NT_safeFont("UbuntuBold"),
        ["Code"]              = _NT_safeFont("Code"),
        ["CartoonBold"]       = _NT_safeFont("CartoonBold"),
    }

    local _TL_safeGetCustomAsset = ctx._TL_safeGetCustomAsset or _safeGetCustomAsset
    local _tlAlive = ctx._tlAlive or function() return true end
    local function twP(obj, dur, props, style, dir)
        return TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    end
    local ownerProfilePicUrl = ctx.ownerProfilePicUrl or "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-OWNER.png"
    local ownerProfilePicFileName = ctx.ownerProfilePicFileName or "assets/ROLE-ICONS/TL-OWNER.png"
    local userProfilePicUrl = ctx.userProfilePicUrl or ""
    local userProfilePicFileName = ctx.userProfilePicFileName or ""

    local function _NT_getInitials(name)
        if not name or name == "" then return "?" end
        local parts = {}
        for word in name:gmatch("%S+") do
            table.insert(parts, word:sub(1, 1):upper())
        end
        if #parts >= 2 then
            return parts[1] .. parts[2]
        end
        return name:sub(1, 2):upper()
    end

    local _NT_GRADIENT_ANIM_INTERVAL = 0.05
    local _NT_GRADIENT_ANIM_ALIVE = {}
    local function _NT_canAnimateGradient() return true end
    local function _NT_stopGradientAnims(target)
        if not target then return end
        for i = #_NT_GRADIENT_ANIM_ALIVE, 1, -1 do
            local a = _NT_GRADIENT_ANIM_ALIVE[i]
            if a and (a.parent == target or (typeof(a.parent) == "Instance" and a.parent:IsDescendantOf(target))) then
                a.alive = false
                table.remove(_NT_GRADIENT_ANIM_ALIVE, i)
            end
        end
    end

                local _NT_EASING_MAP = {
                    ["Quad"] = Enum.EasingStyle.Quad,
                    ["Linear"] = Enum.EasingStyle.Linear,
                    ["Sine"] = Enum.EasingStyle.Sine,
                    ["Expo"] = Enum.EasingStyle.Exponential,
                    ["Exponential"] = Enum.EasingStyle.Exponential,
                    ["Back"] = Enum.EasingStyle.Back,
                    ["Bounce"] = Enum.EasingStyle.Bounce,
                    ["Elastic"] = Enum.EasingStyle.Elastic,
                }

                local _NT_DEFAULTS = {
                    enabled = true,
                    themes = {
                        user = {
                            bg = "#1A1A22", avatarBg = "#1F1F2C", avatarText = "#A0A0C0",
                            divider = "#A0A0C0", border = "#A0A0B4", nameText = "#E6E6F0", roleText = "#7878A0",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#1A1A22", "#0E0E18"}, bgGradientAngle = 0,
                            bgGradientStart = "#1A1A22", bgGradientEnd = "#0E0E18", bgGradientRotation = 0,
                        },
                        admin = {
                            bg = "#220E0E", avatarBg = "#2A1212", avatarText = "#FF6464",
                            divider = "#FF6464", border = "#DC5050", nameText = "#FF8C8C", roleText = "#C83C3C",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#220E0E", "#150808"}, bgGradientAngle = 0,
                            bgGradientStart = "#220E0E", bgGradientEnd = "#150808", bgGradientRotation = 0,
                        },
                        owner = {
                            bg = "#160E1E", avatarBg = "#1B1226", avatarText = "#B87CFF",
                            divider = "#B87CFF", border = "#AA64FF", nameText = "#DDB8FF", roleText = "#8850CC",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#160E1E", "#0D0814"}, bgGradientAngle = 0,
                            bgGradientStart = "#160E1E", bgGradientEnd = "#0D0814", bgGradientRotation = 0,
                        },
                        developer = {
                            bg = "#0C1428", avatarBg = "#101A34", avatarText = "#64B4FF",
                            divider = "#64B4FF", border = "#50A0F0", nameText = "#8CD2FF", roleText = "#3C82DC",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#0C1428", "#060A18"}, bgGradientAngle = 0,
                            bgGradientStart = "#0C1428", bgGradientEnd = "#060A18", bgGradientRotation = 0,
                        },
                        advertising = {
                            bg = "#1C0E24", avatarBg = "#24122E", avatarText = "#C878FF",
                            divider = "#C878FF", border = "#B464F0", nameText = "#E6AAFF", roleText = "#A050D2",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#1C0E24", "#100818"}, bgGradientAngle = 0,
                            bgGradientStart = "#1C0E24", bgGradientEnd = "#100818", bgGradientRotation = 0,
                        },
                        moderator = {
                            bg = "#221C0A", avatarBg = "#2A220C", avatarText = "#FFC83C",
                            divider = "#FFC83C", border = "#F0B428", nameText = "#FFDC64", roleText = "#DCA01E",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#221C0A", "#141006"}, bgGradientAngle = 0,
                            bgGradientStart = "#221C0A", bgGradientEnd = "#141006", bgGradientRotation = 0,
                        },
                    },
                    layout = {
                        billboardWidth = 240, billboardHeight = 44, studsOffsetY = 3.4,
                        avatarWidth = 44, cornerRadius = 8, innerCornerRadius = 5,
                        borderThickness = 1, dividerWidth = 1, dividerHeightPct = 0.6,
                        dividerTransparency = 0.75, nameTextSize = 13, nameFont = "GothamBold",
                        roleTextSize = 9, roleFont = "GothamBold", initialsTextSize = 11,
                        avatarTextGap = 10, textPaddingRight = 4,
                        nameLabelHeight = 20, nameLabelY = 4,
                        roleLabelHeight = 12, roleLabelY = 26,
                        roleTextTransform = "upper",
                        avatarImagePadding = 3,
                        distanceScaleEnabled = true,
                        distanceScaleNear = 10,
                        distanceScaleFar = 60,
                        distanceScaleMin = 0.35,
                    },
                    animations = {
                        fadeInDuration = 0.3, fadeInEasing = "Quad",
                        cardTransparency = 0, borderTransparency = 0.3,
                    },
                    particles = {
                        enabled = true, count = 4, minSize = 2, maxSize = 4,
                        transparency = 0.5, moveDurationMin = 3, moveDurationMax = 5,
                        colors = { "#B87CFF", "#A064F0", "#C896FF", "#8C50DC", "#DDB8FF" },
                    },
                    roleKeywords = {
                        owner = { "owner", "vip" },
                        developer = { "developer", "entwickler" },
                        moderator = { "moderator", "mod" },
                        admin = { "admin", "administrator" },
                        staff = { "staff" },
                        advertising = { "advertising", "werbung" },
                    },
                    roleUsers = {
                        owner = {},
                        admin = {},
                        developer = {},
                        moderator = {},
                        staff = {},
                        advertising = {},
                        user = {},
                    },
                    profilePictures = {
                        owner = { url = ownerProfilePicUrl, file = ownerProfilePicFileName },
                        user = { url = userProfilePicUrl, file = userProfilePicFileName },
                        admin = { url = "", file = "" },
                        developer = { url = "", file = "" },
                        moderator = { url = "", file = "" },
                        staff = { url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png", file = "assets/ROLE-ICONS/TL-STAFF.png" },
                        advertising = { url = "", file = "" },
                    },
                    customAvatars = {},
                    tagImages = {
                        staff = { url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png", file = "assets/ROLE-ICONS/TL-STAFF.png" },
                    },
                    roleLabels = {},
                    displayNames = {},
                    roleDisplayNames = {},
                    userColorOverrides = {},
                    userGradientOverrides = {},
                    gradients = {
                        cardGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#1A1A22" },
                            transparency = { 0, 0 },
                            rotation = 90,
                            offset = { 0, 0 },
                        },
                        avatarGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#160E1E" },
                            transparency = { 0, 0 },
                            rotation = 180,
                            offset = { 0, 0 },
                        },
                        nameGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#FFFFFF", "#B87CFF" },
                            transparency = { 0, 0 },
                            rotation = 0,
                            offset = { 0, 0 },
                        },
                        roleGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#8850CC" },
                            transparency = { 0, 0 },
                            rotation = 0,
                            offset = { 0, 0 },
                        },
                        borderGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#AA64FF" },
                            transparency = { 0, 0 },
                            rotation = 0,
                            offset = { 0, 0 },
                        },
                    },
                }

                
    local _NT_CONFIG = {}

    local function _NT_deepCopy(orig)
        if type(orig) ~= "table" then return orig end
        local copy = {}
        for k, v in pairs(orig) do
            copy[k] = _NT_deepCopy(v)
        end
        return copy
    end

    _NT_CONFIG = _NT_deepCopy(_NT_DEFAULTS)

    local function _NT_loadConfig()
        for k, v in pairs(_NT_DEFAULTS) do
            if _NT_CONFIG[k] == nil then
                _NT_CONFIG[k] = _NT_deepCopy(v)
            end
        end
        task.spawn(function()
            pcall(function()
                local cUrl = ctx.configUrl or "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagConfig.json"
                local res = _safeHttpGet(cUrl)
                if res and #res > 5 then
                    res = res:gsub("^[\239\187\191%s]+", ""):gsub("[%s]+$", "")
                    res = res:gsub("^<pre>(.-)</pre>$", "%1")
                    res = res:gsub("^<code>(.-)</code>$", "%1")
                    res = res:gsub("^<html>.-({.-}).-</html>$", "%1")
                    if not res:match("^%s*{") then
                        local s, e = res:find("{.*}")
                        if s then res = res:sub(s, e) end
                    end
                    local ok, json = pcall(function() return _SvcHttp:JSONDecode(res) end)
                    if not ok or type(json) ~= "table" then
                        warn("[NametagConfig] JSON parse failed — using defaults")
                        if not ok then warn("[NametagConfig] Parse error:", tostring(json)) end
                        warn("[NametagConfig] Response length:", #res, "| Starts with:", res:sub(1, 80))
                    end
                    if ok and type(json) == "table" then
                        if json.enabled ~= nil then
                            _NT_CONFIG.enabled = json.enabled
                        end
                        if json.targetUser ~= nil then
                            _NT_CONFIG.targetUser = json.targetUser
                        end
                        if json.roleUsers and type(json.roleUsers) == "table" then
                            _NT_CONFIG.roleUsers = _NT_CONFIG.roleUsers or {}
                            for role, users in pairs(json.roleUsers) do
                                _NT_CONFIG.roleUsers[role] = users
                                if role == "owner" or role == "admin" or role == "developer" then
                                    for _, u in ipairs(users) do
                                        AdminNames[tostring(u)] = true
                                    end
                                end
                            end
                        end
                        if json.roleLabels and type(json.roleLabels) == "table" then
                            _NT_CONFIG.roleLabels = json.roleLabels
                        end
                        if json.displayNames and type(json.displayNames) == "table" then
                            _NT_CONFIG.displayNames = json.displayNames
                        end
                        if json.roleDisplayNames and type(json.roleDisplayNames) == "table" then
                            _NT_CONFIG.roleDisplayNames = json.roleDisplayNames
                        end
                        if json.customAvatars and type(json.customAvatars) == "table" then
                            _NT_CONFIG.customAvatars = json.customAvatars
                        end
                        if json.userColorOverrides and type(json.userColorOverrides) == "table" then
                            _NT_CONFIG.userColorOverrides = json.userColorOverrides
                        end
                        if json.userGradientOverrides and type(json.userGradientOverrides) == "table" then
                            _NT_CONFIG.userGradientOverrides = json.userGradientOverrides
                        end
                        if json.profilePictures and type(json.profilePictures) == "table" then
                            _NT_CONFIG.profilePictures = _NT_CONFIG.profilePictures or {}
                            for k, v in pairs(json.profilePictures) do
                                _NT_CONFIG.profilePictures[k] = v
                            end
                        end
                        if json.tagImages and type(json.tagImages) == "table" then
                            _NT_CONFIG.tagImages = _NT_CONFIG.tagImages or {}
                            for k, v in pairs(json.tagImages) do
                                _NT_CONFIG.tagImages[k] = v
                            end
                        end
                        if json.roleKeywords and type(json.roleKeywords) == "table" then
                            _NT_CONFIG.roleKeywords = _NT_CONFIG.roleKeywords or {}
                            for k, v in pairs(json.roleKeywords) do
                                _NT_CONFIG.roleKeywords[k] = v
                            end
                        end
                        if json.animations and type(json.animations) == "table" then
                            _NT_CONFIG.animations = _NT_CONFIG.animations or {}
                            for k, v in pairs(json.animations) do
                                _NT_CONFIG.animations[k] = v
                            end
                        end
                        if json.particles and type(json.particles) == "table" then
                            _NT_CONFIG.particles = _NT_CONFIG.particles or {}
                            for k, v in pairs(json.particles) do
                                _NT_CONFIG.particles[k] = v
                            end
                        end
                        if json.gradients and type(json.gradients) == "table" then
                            _NT_CONFIG.gradients = _NT_CONFIG.gradients or {}
                            for k, v in pairs(json.gradients) do
                                _NT_CONFIG.gradients[k] = v
                            end
                        end
                        if json.themes and type(json.themes) == "table" then
                            _NT_CONFIG.themes = _NT_CONFIG.themes or {}
                            for k, v in pairs(json.themes) do
                                _NT_CONFIG.themes[k] = v
                            end
                        end
                        if json.layout and type(json.layout) == "table" then
                            _NT_CONFIG.layout = _NT_CONFIG.layout or {}
                            for k, v in pairs(json.layout) do
                                _NT_CONFIG.layout[k] = v
                            end
                        end
                    end
                end
            end)
            pcall(function()
                local rUrl = ctx.rolesUrl or "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagRoles.json"
                local res = _safeHttpGet(rUrl)
                if res and #res > 5 then
                    local ok, json = pcall(function() return _SvcHttp:JSONDecode(res) end)
                    if ok and type(json) == "table" then
                        if json.roleUsers and type(json.roleUsers) == "table" then
                            _NT_CONFIG.roleUsers = _NT_CONFIG.roleUsers or {}
                            for role, users in pairs(json.roleUsers) do
                                _NT_CONFIG.roleUsers[role] = users
                                if role == "owner" or role == "admin" or role == "developer" then
                                    for _, u in ipairs(users) do
                                        AdminNames[tostring(u)] = true
                                    end
                                end
                            end
                        end
                        if json.nameOverrides and type(json.nameOverrides) == "table" then
                            for k, v in pairs(json.nameOverrides) do
                                NameOverrides[k] = v
                            end
                        end
                    end
                end
            end)
        end)
    end
    _NT_loadConfig()

-- =========================================================================
-- UNIVERSAL WEB COLOR & MULTI-STOP GRADIENT ENGINE
-- Accurate sRGB, Hex (#RGB, #RRGGBB, #RRGGBBAA), RGB/RGBA, HSL/HSLA & Multi-Color Keypoint Support
-- =========================================================================
local function _NT_hexToColor3(hex)
    if typeof(hex) == "Color3" then return hex end
    if type(hex) == "table" then
        local r = hex.r or hex[1] or 255
        local g = hex.g or hex[2] or 255
        local b = hex.b or hex[3] or 255
        if r <= 1 and g <= 1 and b <= 1 and (hex.r or hex[1]) then
            return Color3.new(r, g, b)
        end
        return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
    end
    if type(hex) ~= "string" then return Color3.new(1, 1, 1) end

    local str = hex:gsub("%s+", "")

    -- rgb(r, g, b) or rgba(r, g, b, a)
    local r, g, b = str:match("^rgba?%((%d+),(%d+),(%d+)")
    if r and g and b then
        return Color3.fromRGB(tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255)
    end

    -- hsl(h, s%, l%) or hsla(h, s%, l%, a)
    local h, s, l = str:match("^hsla?%((%d+),(%d+)%%?,(%d+)%%?")
    if h and s and l then
        local fh = (tonumber(h) or 0) / 360
        local fs = (tonumber(s) or 0) / 100
        local fl = (tonumber(l) or 0) / 100
        return Color3.fromHSV(fh, fs, fl)
    end

    -- Clean hex string
    local clean = str:gsub("^#", "")

    -- 3-char hex #RGB -> #RRGGBB
    if #clean == 3 then
        local r1, g1, b1 = clean:sub(1, 1), clean:sub(2, 2), clean:sub(3, 3)
        clean = r1 .. r1 .. g1 .. g1 .. b1 .. b1
    -- 4-char hex #RGBA -> #RRGGBB
    elseif #clean == 4 then
        local r1, g1, b1 = clean:sub(1, 1), clean:sub(2, 2), clean:sub(3, 3)
        clean = r1 .. r1 .. g1 .. g1 .. b1 .. b1
    -- 8-char hex #RRGGBBAA -> #RRGGBB
    elseif #clean == 8 then
        clean = clean:sub(1, 6)
    end

    if #clean == 6 then
        local cr = tonumber(clean:sub(1, 2), 16) or 255
        local cg = tonumber(clean:sub(3, 4), 16) or 255
        local cb = tonumber(clean:sub(5, 6), 16) or 255
        return Color3.fromRGB(cr, cg, cb)
    end

    return Color3.new(1, 1, 1)
end

local function _NT_parseColor(val)
    return _NT_hexToColor3(val)
end

-- Multi-Color Gradient Engine (Supports multi-stop Web JSON arrays and position keypoints)
local function _NT_buildColorSeq(rawColors, rawTransparencies)
    local csPairs = {}
    local nsPairs = {}

    if type(rawColors) ~= "table" or #rawColors == 0 then
        return ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new(0)
    end

    -- Parse color keypoints
    local rawKeypoints = {}
    for i, item in ipairs(rawColors) do
        local cVal, pos
        if type(item) == "table" and item.color then
            cVal = _NT_parseColor(item.color)
            pos = tonumber(item.pos or item.offset or item.position) or ((i - 1) / math.max(1, #rawColors - 1))
        else
            cVal = _NT_parseColor(item)
            pos = (i - 1) / math.max(1, #rawColors - 1)
        end
        table.insert(rawKeypoints, { t = math.clamp(pos, 0, 1), color = cVal })
    end

    -- Sort keypoints by position
    table.sort(rawKeypoints, function(a, b) return a.t < b.t end)

    -- Force start at 0 and end at 1 with strictly increasing time
    if #rawKeypoints == 1 then
        local c = rawKeypoints[1].color
        csPairs = { ColorSequenceKeypoint.new(0, c), ColorSequenceKeypoint.new(1, c) }
    else
        local lastT = -0.0001
        for i, kp in ipairs(rawKeypoints) do
            local t = kp.t
            if i == 1 then t = 0 end
            if i == #rawKeypoints then t = 1 end
            if t <= lastT then
                t = math.min(1, lastT + 0.001)
            end
            lastT = t
            table.insert(csPairs, ColorSequenceKeypoint.new(t, kp.color))
        end
    end

    -- Parse transparency keypoints
    if type(rawTransparencies) == "table" and #rawTransparencies > 0 then
        if #rawTransparencies == 1 then
            local tr = tonumber(rawTransparencies[1]) or 0
            nsPairs = { NumberSequenceKeypoint.new(0, tr), NumberSequenceKeypoint.new(1, tr) }
        else
            local lastT = -0.0001
            for i, trVal in ipairs(rawTransparencies) do
                local t = (i - 1) / math.max(1, #rawTransparencies - 1)
                local tr = math.clamp(tonumber(trVal) or 0, 0, 1)
                if i == 1 then t = 0 end
                if i == #rawTransparencies then t = 1 end
                if t <= lastT then t = math.min(1, lastT + 0.001) end
                lastT = t
                table.insert(nsPairs, NumberSequenceKeypoint.new(t, tr))
            end
        end
    else
        nsPairs = { NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) }
    end

    local finalCS = pcall(function() return ColorSequence.new(csPairs) end) and ColorSequence.new(csPairs) or ColorSequence.new(Color3.new(1, 1, 1))
    local finalNS = pcall(function() return NumberSequence.new(nsPairs) end) and NumberSequence.new(nsPairs) or NumberSequence.new(0)

    return finalCS, finalNS
end

local function _NT_applyGradient(target, gradCfg)
                    if not target or not gradCfg or not gradCfg.enabled then return nil, {} end
                    
                    local _GRAD_TYPE_MAP = {
                        linear = "Linear", radial = "Radial", conic = "Conic", angular = "Angular",
                        mesh = "Mesh", color = "Color", blend = "Blend", colorblend = "Blend",
                        duotone = "Duotone", multicolor = "Multicolor", smooth = "Smooth",
                        soft = "Soft", glass = "Glass", neon = "Neon", metallic = "Metallic",
                        iridescent = "Iridescent", holographic = "Holographic", aurora = "Aurora",
                        sunset = "Sunset", spectrum = "Spectrum", liquid = "Liquid",
                        dynamic = "Dynamic", fluid = "Fluid", chromatic = "Chromatic",
                        ombre = "Ombre", fade = "Fade", transition = "ColorTransition",
                        colortransition = "ColorTransition", overlay = "Overlay",
                        gradmesh = "Mesh", flow = "Flow", wave = "Wave",
                    }
                    local rawType = tostring(gradCfg.type or "Linear"):lower()
                    local gType = _GRAD_TYPE_MAP[rawType] or "Linear"
                    local colors = gradCfg.colors or { "#FFFFFF", "#000000" }
                    local trans = gradCfg.transparency or { 0, 0 }
                    local rot = tonumber(gradCfg.rotation) or 0
                    local cs, ns = _NT_buildColorSeq(colors, trans)
                    local conns = {}

                    if gType == "Linear" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot
                        ug.Offset = Vector2.new(gradCfg.offset and gradCfg.offset[1] or 0, gradCfg.offset and gradCfg.offset[2] or 0)
                        return ug, conns

                    elseif gType == "Radial" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot; ug.Style = Enum.GradientStyle.Radial
                        return ug, conns

                    elseif gType == "Conic" or gType == "Angular" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot; ug.Style = Enum.GradientStyle.Radial
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.5
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 360) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Mesh" then
                        local layers = gradCfg.layers
                        if type(layers) ~= "table" or #layers == 0 then
                            layers = {
                                { colors = colors, transparency = trans, rotation = rot },
                                { colors = { colors[#colors] or "#000000", colors[1] or "#FFFFFF" }, transparency = { 0.5, 0.5 }, rotation = (rot + 90) % 360 },
                            }
                        end
                        for _, layer in ipairs(layers) do
                            local lcs, lns = _NT_buildColorSeq(layer.colors, layer.transparency)
                            local lug = Instance.new("UIGradient", target)
                            lug.Color = lcs; lug.Transparency = lns
                            lug.Rotation = layer.rotation or rot
                            lug.Offset = Vector2.new(0.5, 0.5)
                        end
                        return nil, conns

                    elseif gType == "Color" or gType == "ColorTransition" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot; ug.Style = Enum.GradientStyle.Linear
                        return ug, conns

                    elseif gType == "Blend" then
                        local ug = Instance.new("UIGradient", target)
                        local blendT = gradCfg.transparency or { 0, 0.5 }
                        local blendNS = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, math.clamp(blendT[1] or 0, 0, 0.9)),
                            NumberSequenceKeypoint.new(0.5, math.clamp(blendT[2] or 0.3, 0, 0.9)),
                            NumberSequenceKeypoint.new(1, math.clamp(blendT[1] or 0, 0, 0.9)),
                        })
                        ug.Color = cs; ug.Transparency = blendNS
                        ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Duotone" then
                        local c1 = _NT_parseColor(colors[1] or "#FFFFFF")
                        local c2 = _NT_parseColor(colors[2] or "#000000")
                        target.BackgroundColor3 = c1
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = ColorSequence.new(c2, c1)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.5, 0.3),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Multicolor" or gType == "Spectrum" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.3
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 120) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Smooth" then
                        local smoothT = trans
                        if #smoothT == 2 then
                            smoothT = { smoothT[1], (smoothT[1] + smoothT[2]) / 2, smoothT[2] }
                        end
                        local smoothCS = {}
                        for i = 1, #colors do
                            local t = (i - 1) / math.max(1, #colors - 1)
                            smoothCS[#smoothCS + 1] = ColorSequenceKeypoint.new(t, _NT_parseColor(colors[i]))
                        end
                        if #smoothCS == 2 then
                            local mid = _NT_parseColor(colors[1]):Lerp(_NT_parseColor(colors[2]), 0.5)
                            smoothCS = {
                                ColorSequenceKeypoint.new(0, _NT_parseColor(colors[1])),
                                ColorSequenceKeypoint.new(0.5, mid),
                                ColorSequenceKeypoint.new(1, _NT_parseColor(colors[2])),
                            }
                        end
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = ColorSequence.new(smoothCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Soft" then
                        local ug = Instance.new("UIGradient", target)
                        local softColors = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i]):Lerp(Color3.new(1, 1, 1), 0.2)
                            softColors[#softColors + 1] = ColorSequenceKeypoint.new((i - 1) / math.max(1, #colors - 1), c)
                        end
                        if #softColors == 2 then
                            local c1 = _NT_parseColor(colors[1]):Lerp(Color3.new(1, 1, 1), 0.2)
                            local c2 = _NT_parseColor(colors[2]):Lerp(Color3.new(1, 1, 1), 0.2)
                            local mid = c1:Lerp(c2, 0.5)
                            softColors = {
                                ColorSequenceKeypoint.new(0, c1),
                                ColorSequenceKeypoint.new(0.35, mid),
                                ColorSequenceKeypoint.new(0.65, mid),
                                ColorSequenceKeypoint.new(1, c2),
                            }
                        end
                        ug.Color = ColorSequence.new(softColors)
                        ug.Transparency = ns; ug.Rotation = rot
                        ug.Style = Enum.GradientStyle.Radial
                        return ug, conns

                    elseif gType == "Glass" then
                        local ug = Instance.new("UIGradient", target)
                        local glassNS = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.3),
                            NumberSequenceKeypoint.new(0.3, 0),
                            NumberSequenceKeypoint.new(0.6, 0.15),
                            NumberSequenceKeypoint.new(1, 0.5),
                        })
                        ug.Color = cs; ug.Transparency = glassNS
                        ug.Rotation = rot + 45
                        return ug, conns

                    elseif gType == "Neon" then
                        local ug = Instance.new("UIGradient", target)
                        local neonCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local brightC = c:Lerp(Color3.new(1, 1, 1), 0.5)
                            local softC = c:Lerp(Color3.new(1, 1, 1), 0.2)
                            local base = (i - 1) / #colors
                            neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(math.clamp(base, 0, 1), softC)
                            neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.2 / #colors, 0, 1), brightC)
                            neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.4 / #colors, 0, 1), softC)
                        end
                        neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(1, neonCS[1].Value)
                        ug.Color = ColorSequence.new(neonCS)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.25, 0.1),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(0.75, 0.1),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 1
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 60) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Metallic" then
                        local ug = Instance.new("UIGradient", target)
                        local metCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local metDark = c:Lerp(Color3.new(0, 0, 0), 0.45)
                            local metMid = c:Lerp(Color3.new(1, 1, 1), 0.15)
                            local metLight = c:Lerp(Color3.new(1, 1, 1), 0.5)
                            local base = (i - 1) / #colors
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base, 0, 1), metDark)
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.15 / #colors, 0, 1), metMid)
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.35 / #colors, 0, 1), metLight)
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.5 / #colors, 0, 1), metMid)
                        end
                        metCS[#metCS + 1] = ColorSequenceKeypoint.new(1, metCS[1].Value)
                        ug.Color = ColorSequence.new(metCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Iridescent" or gType == "Holographic" then
                        local ug = Instance.new("UIGradient", target)
                        local iriCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local brightC = c:Lerp(Color3.new(1, 1, 1), 0.3)
                            local t = (i - 1) / math.max(1, #colors - 1)
                            iriCS[#iriCS + 1] = ColorSequenceKeypoint.new(t, brightC)
                        end
                        if #iriCS < 4 then
                            local c1 = _NT_parseColor(colors[1])
                            local c2 = _NT_parseColor(colors[2] or colors[1])
                            local c3 = _NT_parseColor(colors[3] or colors[2] or colors[1])
                            local mid1 = c1:Lerp(c2, 0.33):Lerp(Color3.new(1,1,1), 0.2)
                            local mid2 = c2:Lerp(c3, 0.66):Lerp(Color3.new(1,1,1), 0.2)
                            iriCS = {
                                ColorSequenceKeypoint.new(0, c1:Lerp(Color3.new(1,1,1), 0.3)),
                                ColorSequenceKeypoint.new(0.33, mid1),
                                ColorSequenceKeypoint.new(0.66, mid2),
                                ColorSequenceKeypoint.new(1, (c2 or c1):Lerp(Color3.new(1,1,1), 0.3)),
                            }
                        end
                        ug.Color = ColorSequence.new(iriCS)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.25, 0.05),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(0.75, 0.05),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.4
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 90) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Aurora" then
                        local ug = Instance.new("UIGradient", target)
                        local auCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local t = (i - 1) / math.max(1, #colors - 1)
                            auCS[#auCS + 1] = ColorSequenceKeypoint.new(t, c)
                        end
                        if #auCS < 3 then
                            local c1 = _NT_parseColor(colors[1])
                            local c2 = _NT_parseColor(colors[2] or colors[1])
                            local mid = c1:Lerp(c2, 0.5)
                            auCS = {
                                ColorSequenceKeypoint.new(0, c1),
                                ColorSequenceKeypoint.new(0.5, mid),
                                ColorSequenceKeypoint.new(1, c2),
                            }
                        end
                        ug.Color = ColorSequence.new(auCS)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.3, 0),
                            NumberSequenceKeypoint.new(0.7, 0),
                            NumberSequenceKeypoint.new(1, 0.1),
                        })
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.3
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 50) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Sunset" then
                        local ug = Instance.new("UIGradient", target)
                        local ssCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local t = (i - 1) / math.max(1, #colors - 1)
                            ssCS[#ssCS + 1] = ColorSequenceKeypoint.new(t, c)
                        end
                        ug.Color = ColorSequence.new(ssCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Liquid" or gType == "Fluid" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs
                        ug.Style = Enum.GradientStyle.Radial
                        ug.Transparency = ns; ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.5
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function()
                                    ug.Rotation = (rot + math.sin(t * speed) * 45) % 360
                                    ug.Offset = Vector2.new(math.sin(t * speed * 0.7) * 0.15, math.cos(t * speed * 0.5) * 0.15)
                                end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Dynamic" or gType == "Flow" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns; ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 1
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function()
                                    ug.Rotation = (rot + t * speed * 30) % 360
                                    ug.Offset = Vector2.new(math.sin(t * speed * 0.4) * 0.2, 0)
                                end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Chromatic" then
                        local ug = Instance.new("UIGradient", target)
                        local chCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            chCS[#chCS + 1] = ColorSequenceKeypoint.new((i - 1) / math.max(1, #colors - 1), c)
                        end
                        if #chCS < 3 then
                            local extra = _NT_parseColor(colors[1] or "#FFFFFF"):Lerp(_NT_parseColor(colors[2] or "#000000"), 0.5)
                            table.insert(chCS, 2, ColorSequenceKeypoint.new(0.5, extra))
                        end
                        ug.Color = ColorSequence.new(chCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.6
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function()
                                    local shift = (t * speed * 0.3) % 1
                                    ug.Offset = Vector2.new(shift - 0.5, 0)
                                end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Ombre" or gType == "Fade" then
                        local ug = Instance.new("UIGradient", target)
                        local oC1 = _NT_parseColor(colors[1] or "#000000")
                        local oC2 = _NT_parseColor(colors[2] or "#FFFFFF")
                        ug.Color = ColorSequence.new(oC1, oC1, oC2, oC2)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.4, 0),
                            NumberSequenceKeypoint.new(0.6, 0.4),
                            NumberSequenceKeypoint.new(1, 0.8),
                        })
                        ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Wave" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs
                        local waveNS = {}
                        local freq = gradCfg.frequency or 4
                        local amp = gradCfg.amplitude or 0.3
                        for i = 0, 10 do
                            local t = i / 10
                            local baseT = trans[1] or 0
                            waveNS[#waveNS + 1] = NumberSequenceKeypoint.new(t, baseT + amp * math.abs(math.sin(t * freq * math.pi)))
                        end
                        ug.Transparency = NumberSequence.new(waveNS)
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.5
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Offset = Vector2.new(math.sin(t * speed) * 0.2, 0) end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Overlay" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.2),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(1, 0.2),
                        })
                        ug.Rotation = rot + 45
                        return ug, conns
                    end

                    return nil, conns
                end

-- Multi-Target Website Gradient Resolver (Per-Player Overrides > Per-Role Theme Gradients > Global Gradients)
local function _NT_resolveGradientSet(playerName, roleKey, theme)
    local resolved = {}
    local targets = { "cardGradient", "avatarGradient", "nameGradient", "roleGradient", "borderGradient" }

    local userGrads = _NT_CONFIG.userGradientOverrides and _NT_CONFIG.userGradientOverrides[playerName]
    local themeGrads = (theme and theme.gradients) or (_NT_CONFIG.themes and _NT_CONFIG.themes[roleKey] and _NT_CONFIG.themes[roleKey].gradients)
    local globalGrads = _NT_CONFIG.gradients or {}
    local defaultGrads = _NT_DEFAULTS and _NT_DEFAULTS.gradients or {}

    for _, targetKey in ipairs(targets) do
        local g = (userGrads and userGrads[targetKey])
               or (themeGrads and themeGrads[targetKey])
               or (globalGrads and globalGrads[targetKey])
               or (defaultGrads and defaultGrads[targetKey])
        if g then
            resolved[targetKey] = _NT_deepCopy(g)
        end
    end
    return resolved
end

                local function _NT_applyAllGradients(billboard, card, avatar, nameLabel, roleTxt, cardBorder, gradCfg)
                    if type(gradCfg) ~= "table" then return end
                    if gradCfg.cardGradient and gradCfg.cardGradient.enabled then
                        _NT_applyGradient(card, gradCfg.cardGradient)
                    end
                    if gradCfg.avatarGradient and gradCfg.avatarGradient.enabled then
                        _NT_applyGradient(avatar, gradCfg.avatarGradient)
                    end
                    if gradCfg.nameGradient and gradCfg.nameGradient.enabled then
                        _NT_applyGradient(nameLabel, gradCfg.nameGradient)
                    end
                    if gradCfg.roleGradient and gradCfg.roleGradient.enabled then
                        _NT_applyGradient(roleTxt, gradCfg.roleGradient)
                    end
                    if gradCfg.borderGradient and gradCfg.borderGradient.enabled and cardBorder then
                        _NT_applyGradient(cardBorder, gradCfg.borderGradient)
                    end
                end

    local function DoesPlayerQualifyForNametag(p)
        if not _NT_CONFIG or not _NT_CONFIG.enabled then return false end
        if not p then return false end
        local lp = LocalPlayer or _SvcPlr.LocalPlayer
        local pObj = nil
        local pName = ""
        local pUserId = ""
        if typeof(p) == "Instance" and p:IsA("Player") then
            pObj = p
            pName = p.Name
            pUserId = tostring(p.UserId)
        elseif type(p) == "string" then
            pName = p
            pObj = _SvcPlr:FindFirstChild(p)
            if pObj then pUserId = tostring(pObj.UserId) end
        else
            return false
        end

        local tgt = _NT_CONFIG.targetUser
        if type(tgt) == "string" and tgt ~= "" then
            if (lp and pName:lower() == lp.Name:lower()) or (pObj and lp and pObj == lp) then return true end
            if pName:lower() == tgt:lower() then return true end
            return false
        end

        -- LocalPlayer ALWAYS qualifies for their own nametag (unless removed via settings)
        if (lp and pName:lower() == lp.Name:lower()) or (pObj and lp and pObj == lp) then return true end

        local State = ctx.State or rawget(_genv, "State") or {}
        if State and State.VerifiedPeers and pObj and State.VerifiedPeers[pObj] ~= nil then return true end

        if AdminNames and (AdminNames[pName] == true or (pUserId ~= "" and AdminNames[pUserId] == true)) then return true end
        if NameOverrides and (NameOverrides[pName] ~= nil or (pUserId ~= "" and NameOverrides[pUserId] ~= nil)) then return true end

        if _NT_CONFIG.roleUsers then
            for _, users in pairs(_NT_CONFIG.roleUsers) do
                if type(users) == "table" then
                    for _, u in ipairs(users) do
                        local us = tostring(u)
                        if us:lower() == pName:lower() or (pUserId ~= "" and us == pUserId) then
                            return true
                        end
                    end
                end
            end
        end

        if _NT_CONFIG.showAllPlayers or _NT_CONFIG.allPlayers then
            return true
        end

        return false
    end

    local creatingNametag = {}
    local function CreateCustomNametag(character, playerName, isAdmin)
        if not character then return end
        if not playerName or playerName == "" then return end

        local lp = LocalPlayer or _SvcPlr.LocalPlayer
        local pObj = _SvcPlr:FindFirstChild(playerName)
        local isLocal = (lp and playerName:lower() == lp.Name:lower()) or (pObj and lp and pObj == lp)

        -- Qualification check
        if not DoesPlayerQualifyForNametag(pObj or playerName) then
            local existing = _findExistingBillboard(playerName)
            if existing then pcall(function() existing:Destroy() end) end
            return
        end

        -- Check local player remove nametag option
        if isLocal and (_NT_CONFIG.removeOwnNametag or (ctx.settingsState and ctx.settingsState.removeNametag)) then
            local existing = _findExistingBillboard(playerName)
            if existing then pcall(function() existing:Destroy() end) end
            return
        end

        -- Check peer nametag visibility
        local State = ctx.State or rawget(_genv, "State") or {}
        if not isLocal and State and State.NametagVisibility and pObj and State.NametagVisibility[pObj] == false and not isAdmin then
            local existing = _findExistingBillboard(playerName)
            if existing then pcall(function() existing:Destroy() end) end
            return
        end

        if creatingNametag[playerName] then return end
        creatingNametag[playerName] = true
        task.delay(1.5, function()
            creatingNametag[playerName] = nil
        end)
        local _ntOk, _ntErr = pcall(function()

                    local player = _SvcPlr:FindFirstChild(playerName)
                    local playerUserId = player and tostring(player.UserId) or nil

                    local override = NameOverrides[playerName]
                    if not override and playerUserId then
                        override = NameOverrides[playerUserId]
                    end

                    local displayName  = _NT_CONFIG.displayNames and _NT_CONFIG.displayNames[playerName]
                        or (override and override.display or playerName)
                    local roleLabel    = _NT_CONFIG.roleLabels and _NT_CONFIG.roleLabels[playerName]
                        or (override and override.role or nil)

                    
                    local roleLower    = (roleLabel or (isAdmin and "TL Admin" or "TL User")):lower()
                    local displayLower = (override and override.display or ""):lower()
                    local themeKey     = "user"

                    
                    
                    local _NT_ROLE_PRIO = { owner=7, developer=6, admin=5, moderator=4, staff=3, advertising=2, user=1 }
                    local _ntHighestPrio = 0
                    for role, users in pairs(_NT_CONFIG.roleUsers) do
                        for _, u in ipairs(users) do
                            if tostring(u):lower() == playerName:lower() then
                                local prio = _NT_ROLE_PRIO[role] or 0
                                if prio > _ntHighestPrio then
                                    _ntHighestPrio = prio
                                    themeKey = role
                                end
                                break
                            end
                        end
                    end

                    
                    if themeKey == "user" then
                        for tk, keywords in pairs(_NT_CONFIG.roleKeywords) do
                            if themeKey == "user" then
                                for _, kw in ipairs(keywords) do
                                    if roleLower:find(kw) or displayLower:find(kw) then
                                        themeKey = tk
                                        break
                                    end
                                end
                            end
                        end
                    end

                    
                    if themeKey == "user" and isAdmin then
                        themeKey = "admin"
                    end

                    
                    if themeKey == "user" and displayName == playerName and player then
                        local robloxDisplayName = player:FindFirstChild("DisplayName")
                        if robloxDisplayName and robloxDisplayName.Value ~= "" then
                            displayName = robloxDisplayName.Value
                        end
                    end

                    
                    
                    
                    
                    
                    if not roleLabel then
                        local _NT_ROLE_DEFAULTS = { user="TL User", admin="TL Admin", owner="TL Owner", developer="TL Developer", advertising="TL Advertising", moderator="TL Moderator" }
                        roleLabel = (_NT_CONFIG.roleDisplayNames and _NT_CONFIG.roleDisplayNames[themeKey])
                            or _NT_ROLE_DEFAULTS[themeKey]
                            or "TL User"
                    end

                    local theme = _NT_CONFIG.themes[themeKey] or _NT_DEFAULTS.themes.user
                    local customAvatar = _NT_CONFIG.customAvatars[playerName] or customUserAvatars[playerName]

                    
                    local _userColorOvr = _NT_CONFIG.userColorOverrides and _NT_CONFIG.userColorOverrides[playerName]
                    if _userColorOvr and _userColorOvr.__enabled then
                        theme = _NT_deepCopy(theme)
                        for k, v in pairs(_userColorOvr) do
                            if k ~= "__enabled" and v ~= nil then
                                if v == "transparent" then
                                    theme[k] = Color3.new(1, 1, 1)
                                    theme[k .. "_transparent"] = true
                                else
                                    theme[k] = v
                                end
                            end
                        end
                    end

                    
                    local _userGradOvr = _NT_CONFIG.userGradientOverrides and _NT_CONFIG.userGradientOverrides[playerName]
                    local _savedGrads = nil
                    if _userGradOvr then
                        _savedGrads = _NT_deepCopy(_NT_CONFIG.gradients)
                        for gradKey, gradData in pairs(_userGradOvr) do
                            if _NT_CONFIG.gradients[gradKey] then
                                _NT_CONFIG.gradients[gradKey] = _NT_deepCopy(gradData)
                            end
                        end
                    end

                    theme = _NT_deepCopy(theme)
                    for _, k in ipairs({ "bg", "avatarBg", "avatarText", "divider", "border", "nameText", "roleText" }) do
                        theme[k] = _NT_parseColor(theme[k])
                    end

                    local head = character:WaitForChild("Head", 5)
                    if not head then
                        creatingNametag[playerName] = nil; return
                    end

                    local existingBB  = _findExistingBillboard(playerName)
                    if existingBB then pcall(function() existingBB:Destroy() end) end

                    local bbW = (_NT_CONFIG.layout and _NT_CONFIG.layout.billboardWidth) or 240
                    local bbH = (_NT_CONFIG.layout and _NT_CONFIG.layout.billboardHeight) or 44
                    local offY = (_NT_CONFIG.layout and _NT_CONFIG.layout.studsOffsetY) or 3.4

                    local billboard             = Instance.new("BillboardGui")
                    billboard.Name              = "CovertPeerTag_" .. playerName
                    billboard.Adornee           = head
                    billboard.Size              = UDim2.new(0, bbW, 0, bbH)
                    billboard.StudsOffset       = Vector3.new(0, offY, 0)
                    billboard.AlwaysOnTop       = true
                    billboard.LightInfluence    = 0
                    billboard.MaxDistance       = 250

                    
                    local card                       = Instance.new("Frame")
                    card.Size                        = UDim2.new(1, 0, 1, 0)
                    
                    
                    
                    card.AnchorPoint                 = Vector2.new(0.5, 0.5)
                    card.Position                     = UDim2.new(0.5, 0, 0.5, 0)
                    card.BorderSizePixel             = 0
                    card.Parent                      = billboard

                    
                    
                    local cardBaseColor              = theme.bg
                    if theme.bgGradient and theme.bgGradientColors and #theme.bgGradientColors >= 2 then
                        cardBaseColor               = _NT_parseColor(theme.bgGradientColors[1])
                    end
                    card.BackgroundColor3            = cardBaseColor
                    card.BackgroundTransparency      = 1

                    
                    local cardScale                  = Instance.new("UIScale")
                    cardScale.Scale                  = 1
                    cardScale.Parent                 = card

                    
                    if theme.bgGradient then
                        card.BackgroundTransparency = 1
                        local gradCfg = {
                            enabled = true,
                            type = theme.bgGradientType or "Linear",
                            colors = theme.bgGradientColors or { "#1A1A22", "#0E0E18" },
                            transparency = { 0, 0 },
                            rotation = theme.bgGradientAngle or theme.bgGradientRotation or 0,
                            offset = { 0, 0 },
                        }
                        _NT_applyGradient(card, gradCfg)
                    end

                    local cardCorner                 = Instance.new("UICorner")
                    cardCorner.CornerRadius          = UDim.new(0, _NT_CONFIG.layout.cornerRadius)
                    cardCorner.Parent                = card

                    local cardBorder                 = Instance.new("UIStroke")
                    cardBorder.Color                 = theme.border
                    cardBorder.Thickness             = _NT_CONFIG.layout.borderThickness
                    cardBorder.Transparency          = 1
                    cardBorder.ApplyStrokeMode       = Enum.ApplyStrokeMode.Border
                    cardBorder.Parent                = card
                    if customAvatar and customAvatar.strokeColor then
                        cardBorder.Color             = Color3.new(1, 1, 1)
                        local grad = Instance.new("UIGradient", cardBorder)
                        grad.Color = customAvatar.strokeColor
                    end

                    
                    local avatar                     = Instance.new("Frame")
                    avatar.Size                      = UDim2.new(0, _NT_CONFIG.layout.avatarWidth, 1, 0)
                    avatar.Position                  = UDim2.new(0, 0, 0, 0)
                    avatar.BackgroundColor3          = theme.avatarBg
                    avatar.BackgroundTransparency    = 0
                    avatar.BorderSizePixel           = 0
                    avatar.ZIndex                    = 2
                    avatar.Parent                    = card

                    local avatarCorner               = Instance.new("UICorner")
                    avatarCorner.CornerRadius        = UDim.new(0, _NT_CONFIG.layout.cornerRadius)
                    avatarCorner.Parent              = avatar

                    
                    local function _NT_resolveProfilePic(roleKey)
                        local pic = _NT_CONFIG.profilePictures[roleKey]
                        if pic and pic.file and pic.file ~= "" then
                            local loaded = _TL_safeGetCustomAsset(pic.file)
                            if loaded then return loaded, pic.url end
                        end
                        if pic and pic.url then return pic.url, nil end
                        return nil, nil
                    end

                    
                    local avPad = _NT_CONFIG.layout.avatarImagePadding or 3
                    local avInset = avPad * 2
                    local initLabel = nil
                    if customAvatar then
                        local imgLabel                   = Instance.new("ImageLabel")
                        imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                        imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                        imgLabel.BackgroundTransparency  = 1
                        local loadedFile = customAvatar.file and customAvatar.file ~= "" and _TL_safeGetCustomAsset(customAvatar.file) or nil
                        imgLabel.Image = loadedFile or customAvatar.url
                        imgLabel.ScaleType               = Enum.ScaleType.Crop
                        imgLabel.ZIndex                  = 3
                        imgLabel.Parent                  = avatar
                        local imgCorner                  = Instance.new("UICorner")
                        imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                        imgCorner.Parent                 = imgLabel
                    elseif themeKey == "owner" then
                        local imgLabel                   = Instance.new("ImageLabel")
                        imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                        imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                        imgLabel.BackgroundTransparency  = 1
                        local picUrl, _ = _NT_resolveProfilePic("owner")
                        imgLabel.Image = picUrl or ownerProfilePicUrl
                        imgLabel.ScaleType               = Enum.ScaleType.Fit
                        imgLabel.ZIndex                  = 3
                        imgLabel.Parent                  = avatar
                        local imgCorner                  = Instance.new("UICorner")
                        imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                        imgCorner.Parent                 = imgLabel
                    elseif themeKey == "user" then
                        local imgLabel                   = Instance.new("ImageLabel")
                        imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                        imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                        imgLabel.BackgroundTransparency  = 1
                        local picUrl, _ = _NT_resolveProfilePic("user")
                        imgLabel.Image = picUrl or userProfilePicUrl
                        imgLabel.ScaleType               = Enum.ScaleType.Fit
                        imgLabel.ZIndex                  = 3
                        imgLabel.Parent                  = avatar
                        local imgCorner                  = Instance.new("UICorner")
                        imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                        imgCorner.Parent                 = imgLabel
                    else
                        
                        local tagImg = _NT_CONFIG.tagImages and _NT_CONFIG.tagImages[themeKey]
                        local profPic = _NT_CONFIG.profilePictures and _NT_CONFIG.profilePictures[themeKey]
                        local resolvedFile, resolvedUrl
                        if tagImg and ((tagImg.file and tagImg.file ~= "") or (tagImg.url and tagImg.url ~= "")) then
                            local loadedFile = tagImg.file and tagImg.file ~= "" and _TL_safeGetCustomAsset(tagImg.file) or nil
                            resolvedFile = loadedFile
                            resolvedUrl = loadedFile or tagImg.url
                        elseif profPic then
                            resolvedFile = profPic.file and profPic.file ~= "" and _TL_safeGetCustomAsset(profPic.file) or nil
                            resolvedUrl = resolvedFile or (profPic.url and profPic.url ~= "" and profPic.url) or nil
                        end
                        if resolvedUrl then
                            local imgLabel                   = Instance.new("ImageLabel")
                            imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                            imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                            imgLabel.BackgroundTransparency  = 1
                            imgLabel.Image = resolvedUrl
                            imgLabel.ScaleType               = Enum.ScaleType.Crop
                            imgLabel.ZIndex                  = 3
                            imgLabel.Parent                  = avatar
                            local imgCorner                  = Instance.new("UICorner")
                            imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                            imgCorner.Parent                 = imgLabel
                        else
                            initLabel                       = Instance.new("TextLabel")
                            initLabel.Size                   = UDim2.new(1, 0, 1, 0)
                            initLabel.BackgroundTransparency = 1
                            initLabel.Text                   = _NT_getInitials(playerName)
                            initLabel.TextColor3             = theme.avatarText
                            local fontVal = _NT_FONT_MAP[_NT_CONFIG.layout.nameFont] or Enum.Font.GothamBold
                            initLabel.Font                   = fontVal
                            initLabel.TextSize               = _NT_CONFIG.layout.initialsTextSize
                            initLabel.ZIndex                 = 3
                            initLabel.Parent                 = avatar
                        end
                    end

                    
                    local avW = _NT_CONFIG.layout.avatarWidth
                    local div                        = Instance.new("Frame")
                    div.Size                         = UDim2.new(0, _NT_CONFIG.layout.dividerWidth, _NT_CONFIG.layout.dividerHeightPct, 0)
                    div.Position                     = UDim2.new(0, avW, (1 - _NT_CONFIG.layout.dividerHeightPct) / 2, 0)
                    div.BackgroundColor3             = theme.divider
                    div.BackgroundTransparency       = _NT_CONFIG.layout.dividerTransparency
                    div.BorderSizePixel              = 0
                    div.ZIndex                       = 2
                    div.Parent                       = card

                    
                    local textOffsetX = avW + (_NT_CONFIG.layout.avatarTextGap or 10)
                    local tPadR = _NT_CONFIG.layout.textPaddingRight or 4
                    local nameLabel                  = Instance.new("TextLabel")
                    nameLabel.Size                   = UDim2.new(1, -textOffsetX - tPadR, 0, _NT_CONFIG.layout.nameLabelHeight or 20)
                    nameLabel.Position               = UDim2.new(0, textOffsetX, 0, _NT_CONFIG.layout.nameLabelY or 4)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text                   = displayName
                    nameLabel.TextColor3             = theme.nameText
                    local nameFontVal = _NT_FONT_MAP[_NT_CONFIG.layout.nameFont] or Enum.Font.GothamBold
                    nameLabel.Font                   = nameFontVal
                    nameLabel.TextSize               = _NT_CONFIG.layout.nameTextSize
                    nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
                    nameLabel.TextTruncate           = Enum.TextTruncate.AtEnd
                    nameLabel.ZIndex                 = 3
                    nameLabel.Parent                 = card

                    
                    local roleTxt                    = Instance.new("TextLabel")
                    roleTxt.Size                     = UDim2.new(1, -textOffsetX - tPadR, 0, _NT_CONFIG.layout.roleLabelHeight or 12)
                    roleTxt.Position                 = UDim2.new(0, textOffsetX, 0, _NT_CONFIG.layout.roleLabelY or 26)
                    roleTxt.BackgroundTransparency   = 1
                    local roleTextVal = roleLabel
                    if _NT_CONFIG.layout.roleTextTransform == "upper" then
                        roleTextVal = string.upper(roleLabel)
                    elseif _NT_CONFIG.layout.roleTextTransform == "lower" then
                        roleTextVal = string.lower(roleLabel)
                    end
                    roleTxt.Text                     = roleTextVal
                    roleTxt.TextColor3               = theme.roleText
                    local roleFontVal = _NT_FONT_MAP[_NT_CONFIG.layout.roleFont] or Enum.Font.GothamBold
                    roleTxt.Font                     = roleFontVal
                    roleTxt.TextSize                 = _NT_CONFIG.layout.roleTextSize
                    roleTxt.TextXAlignment           = Enum.TextXAlignment.Left
                    roleTxt.TextTruncate             = Enum.TextTruncate.AtEnd
                    roleTxt.ZIndex                   = 3
                    roleTxt.Parent                   = card

                    
                    if _NT_CONFIG.particles.enabled and _NT_CONFIG.particles.count > 0 then
                        card.ClipsDescendants = true
                        local particleColors = {}
                        for _, hex in ipairs(_NT_CONFIG.particles.colors) do
                            table.insert(particleColors, _NT_parseColor(hex))
                        end
                        local particleConns = {}
                        local pCount = _NT_CONFIG.particles.count
                        for pi = 1, pCount do
                            local pt = Instance.new("Frame")
                            local sz = math.random(math.max(1, _NT_CONFIG.particles.minSize), math.max(1, _NT_CONFIG.particles.maxSize))
                            pt.Size = UDim2.new(0, sz, 0, sz)
                            pt.AnchorPoint = Vector2.new(0.5, 0.5)
                            pt.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
                            local colorIdx = ((pi - 1) % #particleColors) + 1
                            pt.BackgroundColor3 = particleColors[colorIdx]
                            pt.BackgroundTransparency = _NT_CONFIG.particles.transparency
                            pt.BorderSizePixel = 0
                            pt.ZIndex = 1
                            pt.Parent = card
                            Instance.new("UICorner", pt).CornerRadius = UDim.new(1, 0)

                            local alive = true
                            particleConns[pi] = pt
                            task.spawn(function()
                                while alive and pt and pt.Parent and _tlAlive() do
                                    local tx = math.random() * 0.8 + 0.1
                                    local ty = math.random() * 0.8 + 0.1
                                    local dur = math.random(
                                        math.max(1, math.floor(_NT_CONFIG.particles.moveDurationMin * 10)),
                                        math.max(1, math.floor(_NT_CONFIG.particles.moveDurationMax * 10))
                                    ) / 10
                                    twP(pt, dur, { Position = UDim2.new(tx, 0, ty, 0) }):Play()
                                    task.wait(dur)
                                end
                            end)
                        end
                        billboard.Destroying:Connect(function()
                            for _, v in ipairs(particleConns) do
                                if v then v:Destroy() end
                            end
                            _NT_stopGradientAnims(billboard)
                        end)
                    end

                    billboard.Parent = head or character or _getGuiContainer()

                    billboard.Destroying:Connect(function()
                        _NT_stopGradientAnims(billboard)
                    end)

                    local fadeDur = (_NT_CONFIG.animations and _NT_CONFIG.animations.fadeInDuration) or 0.25
                    local fadeEasing = _NT_EASING_MAP[_NT_CONFIG.animations and _NT_CONFIG.animations.fadeInEasing] or Enum.EasingStyle.Quad
                    local fadeInfo = TweenInfo.new(fadeDur, fadeEasing)
                    local targetCardTransp = (_NT_CONFIG.animations and _NT_CONFIG.animations.cardTransparency) or 0
                    local targetBorderTransp = (_NT_CONFIG.animations and _NT_CONFIG.animations.borderTransparency) or 0.3
                    local tw1 = TweenService:Create(card,       fadeInfo, { BackgroundTransparency = targetCardTransp })
                    local tw2 = TweenService:Create(cardBorder, fadeInfo, { Transparency          = targetBorderTransp })
                    pcall(function() tw1:Play() end)
                    pcall(function() tw2:Play() end)

                    
                    local activeGradients = _NT_resolveGradientSet(playerName, themeKey, theme)
                    _NT_applyAllGradients(billboard, card, avatar, nameLabel, roleTxt, cardBorder, activeGradients)

                    
                    if _userColorOvr and _userColorOvr.__enabled then
                        if theme.avatarBg_transparent then
                            avatar.BackgroundTransparency = 1
                        end
                        if theme.border_transparent then
                            cardBorder.Transparency = 1
                        end
                        if theme.divider_transparent then
                            div.BackgroundTransparency = 1
                        end
                        if theme.avatarText_transparent then
                            if initLabel then initLabel.TextTransparency = 1 end
                        end
                    end

                    
                    if _NT_CONFIG.layout.distanceScaleEnabled then
                        local dsNear  = _NT_CONFIG.layout.distanceScaleNear or 10
                        local dsFar   = _NT_CONFIG.layout.distanceScaleFar or 60
                        local dsMin   = _NT_CONFIG.layout.distanceScaleMin or 0.35
                        local dsAlive = true
                        billboard.Destroying:Connect(function() dsAlive = false end)
                        task.spawn(function()
                            while dsAlive and billboard and billboard.Parent do
                                local cam = workspace.CurrentCamera
                                if cam and head and head.Parent then
                                    local dist = (head.Position - cam.CFrame.Position).Magnitude
                                    local scale = 1
                                    if dist > dsNear then
                                        scale = math.clamp(1 - (dist - dsNear) / (dsFar - dsNear), dsMin, 1)
                                    end
                                    cardScale.Scale = scale
                                end
                                task.wait(0.15)
                            end
                        end)
                    end

                    tw1.Completed:Connect(function()
                        creatingNametag[playerName] = nil
                        if _savedGrads then
                            for k, v in pairs(_savedGrads) do
                                _NT_CONFIG.gradients[k] = v
                            end
                            _savedGrads = nil
                        end
                    end)
        end)
        if not _ntOk then
            creatingNametag[playerName] = nil
            warn("[NametagSystem] " .. tostring(_ntErr))
        end
    end

                
    local function RemoveNametag(playerOrName)
        local pName = type(playerOrName) == "string" and playerOrName or (playerOrName and playerOrName.Name) or ""
        if pName == "" then return end
        local existing = _findExistingBillboard(pName)
        if existing then pcall(function() existing:Destroy() end) end
        creatingNametag[pName] = nil
    end

    local function RemoveAll()
        for _, p in ipairs(_SvcPlr:GetPlayers()) do
            RemoveNametag(p.Name)
        end
        local container = _getGuiContainer()
        if container then
            for _, desc in ipairs(container:GetDescendants()) do
                if desc:IsA("BillboardGui") and desc.Name:sub(1, 14) == "CovertPeerTag_" then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
    end

    local function UpdateAll()
        local lp = LocalPlayer or _SvcPlr.LocalPlayer
        for _, p in ipairs(_SvcPlr:GetPlayers()) do
            local char = p.Character
            if char and char.Parent then
                if DoesPlayerQualifyForNametag(p) then
                    local isAdm = (lp and p == lp and (ctx.IsLocalAdmin or AdminNames[p.Name] == true))
                        or (AdminNames[p.Name] == true) or (AdminNames[tostring(p.UserId)] == true)
                    task.spawn(CreateCustomNametag, char, p.Name, isAdm)
                else
                    RemoveNametag(p.Name)
                end
            end
        end
    end

    -- Hook player lifecycle to ONLY create nametags for qualified players
    _SvcPlr.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if DoesPlayerQualifyForNametag(player) then
                local isAdm = AdminNames[player.Name] == true or AdminNames[tostring(player.UserId)] == true
                CreateCustomNametag(char, player.Name, isAdm)
            end
        end)
    end)

    _SvcPlr.PlayerRemoving:Connect(function(player)
        RemoveNametag(player.Name)
    end)

    for _, player in ipairs(_SvcPlr:GetPlayers()) do
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if DoesPlayerQualifyForNametag(player) then
                local isAdm = AdminNames[player.Name] == true or AdminNames[tostring(player.UserId)] == true
                CreateCustomNametag(char, player.Name, isAdm)
            end
        end)
    end

    -- Initial creation for existing qualified players
    task.delay(0.5, UpdateAll)

    -- Export module functions
    NametagSystem.CreateNametag = CreateCustomNametag
    NametagSystem.CreateCustomNametag = CreateCustomNametag
    NametagSystem.DoesPlayerQualify = DoesPlayerQualifyForNametag
    NametagSystem.DoesPlayerQualifyForNametag = DoesPlayerQualifyForNametag
    NametagSystem.ReloadConfig = _NT_loadConfig
    NametagSystem.RemoveNametag = RemoveNametag
    NametagSystem.RemoveAll = RemoveAll
    NametagSystem.UpdateAll = UpdateAll
    NametagSystem.Config = _NT_CONFIG

    return {
        CreateCustomNametag = CreateCustomNametag,
        CreateNametag = CreateCustomNametag,
        DoesPlayerQualifyForNametag = DoesPlayerQualifyForNametag,
        DoesPlayerQualify = DoesPlayerQualifyForNametag,
        _NT_CONFIG = _NT_CONFIG,
        Config = _NT_CONFIG,
        _NT_loadConfig = _NT_loadConfig,
        ReloadConfig = _NT_loadConfig,
        RemoveNametag = RemoveNametag,
        RemoveAll = RemoveAll,
        UpdateAll = UpdateAll,
    }
end

-- Export top-level references so module can be used before or without Init()
NametagSystem.CreateNametag = function(...) end
NametagSystem.CreateCustomNametag = function(...) end
NametagSystem.DoesPlayerQualify = function() return false end
NametagSystem.DoesPlayerQualifyForNametag = function() return false end
NametagSystem.Config = {}
NametagSystem.ReloadConfig = function() end

return NametagSystem