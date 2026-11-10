-- ============================================================
--  Turtle UI Library — Modern Dark Redesign
--  API compatible with original + LeftControl global hide
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse  = player:GetMouse()

local library    = {}
local destroyed  = false
local windowCount = 0
local allWindows  = {}
local dropdowns   = {}
local colorPickers = {}

-- ============================================================
--  THEME
-- ============================================================
local Theme = {
    Background   = Color3.fromRGB(18, 18, 22),
    Panel        = Color3.fromRGB(24, 24, 29),
    PanelLight   = Color3.fromRGB(30, 30, 36),
    Element      = Color3.fromRGB(34, 34, 41),
    ElementHover = Color3.fromRGB(46, 46, 55),
    Border       = Color3.fromRGB(48, 48, 58),
    Text         = Color3.fromRGB(237, 237, 242),
    TextDim      = Color3.fromRGB(150, 150, 162),
    Accent       = Color3.fromRGB(130, 100, 255),
    AccentDark   = Color3.fromRGB(95, 70, 200),
    Success      = Color3.fromRGB(74, 222, 128),
    Danger       = Color3.fromRGB(239, 68, 68),
    Font         = Enum.Font.Gotham,
    FontMedium   = Enum.Font.GothamMedium,
    FontBold     = Enum.Font.GothamBold,
}

local function tween(obj, props, time)
    TweenService:Create(obj,
        TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

-- ============================================================
--  DRAG SYSTEM
-- ============================================================
local function Dragify(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragInput, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--  GUI PROTECTION
-- ============================================================
if game.CoreGui:FindFirstChild("TurtleUiLib") then
    game.CoreGui:FindFirstChild("TurtleUiLib"):Destroy()
    destroyed = true
end

local function protect_gui(obj)
    if destroyed then obj.Parent = game.CoreGui return end
    if syn and syn.protect_gui then
        syn.protect_gui(obj)
        obj.Parent = game.CoreGui
    elseif PROTOSMASHER_LOADED then
        obj.Parent = get_hidden_gui()
    else
        obj.Parent = game.CoreGui
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TurtleUiLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protect_gui(ScreenGui)

-- ============================================================
--  GLOBAL KEYBIND (LeftControl by default) — HIDE / SHOW ALL
-- ============================================================
local hideKey = Enum.KeyCode.LeftControl
local keybindConn

local function bindHideKey()
    if keybindConn then keybindConn:Disconnect() end
    keybindConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == hideKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
end
bindHideKey()

function library:Keybind(key)
    hideKey = Enum.KeyCode[key] or Enum.KeyCode.LeftControl
    bindHideKey()
end

function library:Hide()
    ScreenGui.Enabled = not ScreenGui.Enabled
end

function library:Destroy()
    ScreenGui:Destroy()
    if keybindConn then keybindConn:Disconnect() end
end

-- ============================================================
--  WINDOW BUILDER
-- ============================================================
function library:Window(name)
    windowCount = windowCount + 1
    local winCount = windowCount
    local xPos = 20 + (winCount - 1) * 240

    ------------------------------------------------------------
    -- Window frame
    ------------------------------------------------------------
    local window = Instance.new("Frame")
    window.Name = "Window_" .. winCount
    window.Parent = ScreenGui
    window.BackgroundColor3 = Theme.Panel
    window.BorderSizePixel = 0
    window.Position = UDim2.new(0, xPos, 0, 20)
    window.Size = UDim2.new(0, 220, 0, 35)
    window.ClipsDescendants = false
    window.ZIndex = winCount * 10
    window.Active = true

    addCorner(window, 10)
    addStroke(window, Theme.Border, 1)
    table.insert(allWindows, window)

    ------------------------------------------------------------
    -- Header
    ------------------------------------------------------------
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = window
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 35)
    header.ZIndex = window.ZIndex + 1

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = header
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Text = name or "Window"
    titleLbl.TextColor3 = Theme.Text
    titleLbl.Font = Theme.FontBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = header.ZIndex

    local headerLine = Instance.new("Frame")
    headerLine.Parent = window
    headerLine.BackgroundColor3 = Theme.Border
    headerLine.BorderSizePixel = 0
    headerLine.Position = UDim2.new(0, 10, 0, 34)
    headerLine.Size = UDim2.new(1, -20, 0, 1)
    headerLine.ZIndex = window.ZIndex + 1

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Parent = header
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.Position = UDim2.new(1, -10, 0.5, 0)
    minBtn.Size = UDim2.fromOffset(22, 22)
    minBtn.BackgroundColor3 = Theme.Element
    minBtn.BorderSizePixel = 0
    minBtn.Text = "-"
    minBtn.TextColor3 = Theme.Text
    minBtn.Font = Theme.FontBold
    minBtn.TextSize = 16
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = header.ZIndex + 1
    addCorner(minBtn, 5)
    minBtn.MouseEnter:Connect(function() tween(minBtn, {BackgroundColor3 = Theme.ElementHover}, 0.12) end)
    minBtn.MouseLeave:Connect(function() tween(minBtn, {BackgroundColor3 = Theme.Element}, 0.12) end)

    Dragify(window, header)

    ------------------------------------------------------------
    -- Body
    ------------------------------------------------------------
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Parent = window
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 0, 0, 35)
    body.Size = UDim2.new(1, 0, 0, 0)
    body.ZIndex = window.ZIndex

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0, 6)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.Parent = body

    local bodyPad = Instance.new("UIPadding")
    bodyPad.PaddingTop = UDim.new(0, 8)
    bodyPad.PaddingBottom = UDim.new(0, 10)
    bodyPad.PaddingLeft = UDim.new(0, 10)
    bodyPad.PaddingRight = UDim.new(0, 10)
    bodyPad.Parent = body

    local minimized = false
    local function updateSize()
        if minimized then
            window.Size = UDim2.new(0, 220, 0, 35)
            headerLine.Visible = false
            return
        end
        headerLine.Visible = true
        local contentH = bodyLayout.AbsoluteContentSize.Y + 18
        body.Size = UDim2.new(1, 0, 0, contentH)
        window.Size = UDim2.new(0, 220, 0, 35 + contentH)
    end
    bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        body.Visible = not minimized
        minBtn.Text = minimized and "+" or "-"
        updateSize()
    end)

    ------------------------------------------------------------
    -- Component functions
    ------------------------------------------------------------
    local order = 0
    local functions = {}

    -- BUTTON -------------------------------------------------
    function functions:Button(text, callback)
        order = order + 1
        callback = callback or function() end

        local btn = Instance.new("TextButton")
        btn.Parent = body
        btn.BackgroundColor3 = Theme.Element
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.LayoutOrder = order
        btn.Text = text or "Button"
        btn.TextColor3 = Theme.Text
        btn.Font = Theme.FontMedium
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.ZIndex = window.ZIndex + 2
        addCorner(btn, 6)

        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.ElementHover}, 0.12) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.Element}, 0.12) end)
        btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
    end

    -- LABEL --------------------------------------------------
    function functions:Label(text, color)
        order = order + 1

        local lbl = Instance.new("TextLabel")
        lbl.Parent = body
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.LayoutOrder = order
        lbl.Text = text or "Label"
        lbl.TextColor3 = (typeof(color) == "Color3" and color) or Theme.Text
        lbl.Font = Theme.Font
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = window.ZIndex + 2

        if type(color) == "boolean" and color then
            task.spawn(function()
                while lbl.Parent do
                    local h = tick() % 5 / 5
                    lbl.TextColor3 = Color3.fromHSV(h, 1, 1)
                    task.wait(0.05)
                end
            end)
        end
        return lbl
    end

    -- TOGGLE -------------------------------------------------
    function functions:Toggle(text, on, callback)
        order = order + 1
        callback = callback or function() end

        local row = Instance.new("Frame")
        row.Parent = body
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, 28)
        row.LayoutOrder = order
        row.ZIndex = window.ZIndex + 2

        local lbl = Instance.new("TextLabel")
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Text = text or "Toggle"
        lbl.TextColor3 = Theme.Text
        lbl.Font = Theme.Font
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = row.ZIndex

        local switch = Instance.new("TextButton")
        switch.Parent = row
        switch.AnchorPoint = Vector2.new(1, 0.5)
        switch.Position = UDim2.new(1, 0, 0.5, 0)
        switch.Size = UDim2.fromOffset(34, 18)
        switch.BackgroundColor3 = on and Theme.Accent or Theme.Element
        switch.BorderSizePixel = 0
        switch.Text = ""
        switch.AutoButtonColor = false
        switch.ZIndex = row.ZIndex
        addCorner(switch, 99)

        local thumb = Instance.new("Frame")
        thumb.Parent = switch
        thumb.Size = UDim2.fromOffset(14, 14)
        thumb.Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.ZIndex = switch.ZIndex + 1
        addCorner(thumb, 99)

        local state = on and true or false
        switch.MouseButton1Click:Connect(function()
            state = not state
            tween(switch, {BackgroundColor3 = state and Theme.Accent or Theme.Element}, 0.15)
            tween(thumb, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.15)
            task.spawn(callback, state)
        end)
    end

    -- BOX ----------------------------------------------------
    function functions:Box(text, callback)
        order = order + 1
        callback = callback or function() end

        local row = Instance.new("Frame")
        row.Parent = body
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, 28)
        row.LayoutOrder = order
        row.ZIndex = window.ZIndex + 2

        local lbl = Instance.new("TextLabel")
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Text = text or "Box"
        lbl.TextColor3 = Theme.Text
        lbl.Font = Theme.Font
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = row.ZIndex

        local txt = Instance.new("TextBox")
        txt.Parent = row
        txt.BackgroundColor3 = Theme.Element
        txt.BorderSizePixel = 0
        txt.Position = UDim2.new(0.42, 0, 0, 0)
        txt.Size = UDim2.new(0.58, 0, 1, 0)
        txt.Font = Theme.Font
        txt.TextSize = 13
        txt.TextColor3 = Theme.Text
        txt.PlaceholderColor3 = Theme.TextDim
        txt.PlaceholderText = "Type..."
        txt.Text = ""
        txt.ClearTextOnFocus = false
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.ZIndex = row.ZIndex
        addCorner(txt, 6)
        local txtStroke = addStroke(txt, Theme.Border, 1)

        local txtPad = Instance.new("UIPadding")
        txtPad.PaddingLeft = UDim.new(0, 8)
        txtPad.Parent = txt

        txt.Focused:Connect(function() tween(txtStroke, {Color = Theme.Accent}, 0.12) end)
        txt.FocusLost:Connect(function(enter)
            tween(txtStroke, {Color = Theme.Border}, 0.12)
            task.spawn(callback, txt.Text, enter)
        end)
        txt:GetPropertyChangedSignal("Text"):Connect(function()
            task.spawn(callback, txt.Text, false)
        end)
    end

    -- SLIDER -------------------------------------------------
    function functions:Slider(text, min, max, default, callback)
        order = order + 1
        min = min or 0
        max = max or 100
        default = math.clamp(default or (max / 2), min, max)
        callback = callback or function() end

        local container = Instance.new("Frame")
        container.Parent = body
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 0, 38)
        container.LayoutOrder = order
        container.ZIndex = window.ZIndex + 2

        local lbl = Instance.new("TextLabel")
        lbl.Parent = container
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(0.7, 0, 0, 16)
        lbl.Text = text or "Slider"
        lbl.TextColor3 = Theme.Text
        lbl.Font = Theme.Font
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = container.ZIndex

        local valLbl = Instance.new("TextLabel")
        valLbl.Parent = container
        valLbl.BackgroundTransparency = 1
        valLbl.Position = UDim2.new(0.7, 0, 0, 0)
        valLbl.Size = UDim2.new(0.3, 0, 0, 16)
        valLbl.Text = tostring(default)
        valLbl.TextColor3 = Theme.TextDim
        valLbl.Font = Theme.FontMedium
        valLbl.TextSize = 13
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.ZIndex = container.ZIndex

        local track = Instance.new("Frame")
        track.Parent = container
        track.BackgroundColor3 = Theme.Element
        track.BorderSizePixel = 0
        track.Position = UDim2.new(0, 0, 0, 24)
        track.Size = UDim2.new(1, 0, 0, 6)
        track.ZIndex = container.ZIndex
        addCorner(track, 99)

        local fill = Instance.new("Frame")
        fill.Parent = track
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.ZIndex = track.ZIndex
        addCorner(fill, 99)

        local thumb = Instance.new("Frame")
        thumb.Parent = track
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 0
        thumb.Size = UDim2.fromOffset(14, 14)
        thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        thumb.ZIndex = track.ZIndex + 2
        addCorner(thumb, 99)

        local function setValue(v)
            v = math.clamp(v, min, max)
            local alpha = (v - min) / (max - min)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            thumb.Position = UDim2.new(alpha, -7, 0.5, -7)
            valLbl.Text = tostring(math.round(v))
            return math.round(v)
        end

        local function process(input)
            local alpha = math.clamp(
                (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
            )
            local v = setValue(min + (max - min) * alpha)
            task.spawn(callback, v)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                process(input)
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        process(inp)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        conn:Disconnect()
                    end
                end)
            end
        end)

        local api = {}
        function api:SetValue(v) setValue(v); task.spawn(callback, math.round(v)) end
        return api
    end

    -- DROPDOWN -----------------------------------------------
    function functions:Dropdown(text, buttons, callback, selective)
        order = order + 1
        buttons = buttons or {}
        callback = callback or function() end

        local ddBtn = Instance.new("TextButton")
        ddBtn.Parent = body
        ddBtn.BackgroundColor3 = Theme.Element
        ddBtn.BorderSizePixel = 0
        ddBtn.Size = UDim2.new(1, 0, 0, 30)
        ddBtn.LayoutOrder = order
        ddBtn.Text = "  " .. tostring(text or "Dropdown")
        ddBtn.TextColor3 = Theme.Text
        ddBtn.Font = Theme.FontMedium
        ddBtn.TextSize = 13
        ddBtn.TextXAlignment = Enum.TextXAlignment.Left
        ddBtn.AutoButtonColor = false
        ddBtn.ZIndex = window.ZIndex + 2
        addCorner(ddBtn, 6)

        local arrow = Instance.new("TextLabel")
        arrow.Parent = ddBtn
        arrow.BackgroundTransparency = 1
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -10, 0.5, 0)
        arrow.Size = UDim2.fromOffset(16, 16)
        arrow.Text = "v"
        arrow.TextColor3 = Theme.TextDim
        arrow.Font = Theme.FontBold
        arrow.TextSize = 11
        arrow.ZIndex = ddBtn.ZIndex

        local menu = Instance.new("ScrollingFrame")
        menu.Parent = ddBtn
        menu.BackgroundColor3 = Theme.PanelLight
        menu.BorderSizePixel = 0
        menu.Position = UDim2.new(0, 0, 0, 34)
        menu.Size = UDim2.new(1, 0, 0, 0)
        menu.Visible = false
        menu.ScrollBarThickness = 3
        menu.ScrollBarImageColor3 = Theme.Border
        menu.CanvasSize = UDim2.new(0, 0, 0, 0)
        menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
        menu.ClipsDescendants = true
        menu.ZIndex = window.ZIndex + 100
        addCorner(menu, 6)
        addStroke(menu, Theme.Border, 1)

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 2)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = menu

        local mpad = Instance.new("UIPadding")
        mpad.PaddingTop = UDim.new(0, 4)
        mpad.PaddingBottom = UDim.new(0, 4)
        mpad.PaddingLeft = UDim.new(0, 4)
        mpad.PaddingRight = UDim.new(0, 4)
        mpad.Parent = menu

        local function resize()
            local contentH = layout.AbsoluteContentSize.Y + 8
            menu.Size = UDim2.new(1, 0, 0, math.min(contentH, 160))
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

        table.insert(dropdowns, menu)

        ddBtn.MouseEnter:Connect(function() tween(ddBtn, {BackgroundColor3 = Theme.ElementHover}, 0.12) end)
        ddBtn.MouseLeave:Connect(function() tween(ddBtn, {BackgroundColor3 = Theme.Element}, 0.12) end)

        ddBtn.MouseButton1Click:Connect(function()
            for _, m in ipairs(dropdowns) do
                if m ~= menu then m.Visible = false end
            end
            menu.Visible = not menu.Visible
            arrow.Text = menu.Visible and "^" or "v"
            if menu.Visible then resize() end
        end)

        local api = {}
        local itemCount = 0

        function api:Button(name)
            itemCount = itemCount + 1

            local item = Instance.new("TextButton")
            item.Parent = menu
            item.BackgroundColor3 = Theme.Element
            item.BorderSizePixel = 0
            item.Size = UDim2.new(1, 0, 0, 26)
            item.LayoutOrder = itemCount
            item.Text = "  " .. tostring(name)
            item.TextColor3 = Theme.Text
            item.Font = Theme.Font
            item.TextSize = 13
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.AutoButtonColor = false
            item.ZIndex = menu.ZIndex + 1
            addCorner(item, 4)

            item.MouseEnter:Connect(function() tween(item, {BackgroundColor3 = Theme.ElementHover}, 0.12) end)
            item.MouseLeave:Connect(function() tween(item, {BackgroundColor3 = Theme.Element}, 0.12) end)
            item.MouseButton1Click:Connect(function()
                task.spawn(callback, name)
                if selective then ddBtn.Text = "  " .. tostring(name) end
                menu.Visible = false
                arrow.Text = "v"
            end)
        end

        function api:Remove(name)
            for _, child in ipairs(menu:GetChildren()) do
                if child:IsA("TextButton") and child.Text == "  " .. name then
                    child:Destroy()
                    break
                end
            end
        end

        for _, v in ipairs(buttons) do api:Button(v) end
        return api
    end

    -- COLOR PICKER -------------------------------------------
    function functions:ColorPicker(name, default, callback)
        order = order + 1
        callback = callback or function() end

        local row = Instance.new("Frame")
        row.Parent = body
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, 30)
        row.LayoutOrder = order
        row.ZIndex = window.ZIndex + 2

        local lbl = Instance.new("TextLabel")
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -70, 1, 0)
        lbl.Text = name or "Color Picker"
        lbl.TextColor3 = Theme.Text
        lbl.Font = Theme.Font
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = row.ZIndex

        local swatch = Instance.new("TextButton")
        swatch.Parent = row
        swatch.AnchorPoint = Vector2.new(1, 0.5)
        swatch.Position = UDim2.new(1, 0, 0.5, 0)
        swatch.Size = UDim2.fromOffset(50, 24)
        swatch.BackgroundColor3 = (typeof(default) == "Color3" and default) or Theme.Accent
        swatch.BorderSizePixel = 0
        swatch.Text = ""
        swatch.AutoButtonColor = false
        swatch.ZIndex = row.ZIndex
        addCorner(swatch, 6)
        addStroke(swatch, Theme.Border, 1)

        -- Popup
        local popup = Instance.new("Frame")
        popup.Parent = ScreenGui
        popup.Size = UDim2.fromOffset(180, 220)
        popup.BackgroundColor3 = Theme.Panel
        popup.BorderSizePixel = 0
        popup.Visible = false
        popup.ZIndex = 500
        addCorner(popup, 10)
        addStroke(popup, Theme.Border, 1)

        local plbl = Instance.new("TextLabel")
        plbl.Parent = popup
        plbl.BackgroundTransparency = 1
        plbl.Position = UDim2.new(0, 12, 0, 8)
        plbl.Size = UDim2.new(1, -40, 0, 18)
        plbl.Text = name or "Color"
        plbl.TextColor3 = Theme.Text
        plbl.Font = Theme.FontMedium
        plbl.TextSize = 12
        plbl.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = popup
        closeBtn.AnchorPoint = Vector2.new(1, 0)
        closeBtn.Position = UDim2.new(1, -8, 0, 8)
        closeBtn.Size = UDim2.fromOffset(20, 20)
        closeBtn.BackgroundColor3 = Theme.Element
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "x"
        closeBtn.TextColor3 = Theme.TextDim
        closeBtn.Font = Theme.FontBold
        closeBtn.TextSize = 12
        addCorner(closeBtn, 4)

        -- HSV canvas
        local canvas = Instance.new("Frame")
        canvas.Parent = popup
        canvas.Position = UDim2.new(0, 12, 0, 32)
        canvas.Size = UDim2.new(1, -24, 0, 108)
        canvas.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        canvas.BorderSizePixel = 0
        addCorner(canvas, 6)

        local whiteGrad = Instance.new("UIGradient")
        whiteGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
        whiteGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        whiteGrad.Parent = canvas

        local blackOv = Instance.new("Frame")
        blackOv.Parent = canvas
        blackOv.Size = UDim2.new(1, 0, 1, 0)
        blackOv.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackOv.BorderSizePixel = 0
        addCorner(blackOv, 6)

        local blackGrad = Instance.new("UIGradient")
        blackGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        blackGrad.Rotation = 90
        blackGrad.Parent = blackOv

        local cursor = Instance.new("Frame")
        cursor.Parent = canvas
        cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        cursor.Size = UDim2.fromOffset(10, 10)
        cursor.BackgroundTransparency = 1
        cursor.ZIndex = 5
        addCorner(cursor, 99)
        addStroke(cursor, Color3.fromRGB(255,255,255), 2)

        -- Hue bar
        local hueBar = Instance.new("Frame")
        hueBar.Parent = popup
        hueBar.Position = UDim2.new(0, 12, 0, 148)
        hueBar.Size = UDim2.new(1, -24, 0, 10)
        hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueBar.BorderSizePixel = 0
        addCorner(hueBar, 99)

        local hueGrad = Instance.new("UIGradient")
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
        })
        hueGrad.Parent = hueBar

        local hueCursor = Instance.new("Frame")
        hueCursor.Parent = hueBar
        hueCursor.AnchorPoint = Vector2.new(0.5, 0)
        hueCursor.Size = UDim2.new(0, 4, 1, 2)
        hueCursor.Position = UDim2.new(0, 0, 0, -1)
        hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
        hueCursor.BorderSizePixel = 0
        addCorner(hueCursor, 99)

        -- Rainbow toggle
        local rainbowRow = Instance.new("Frame")
        rainbowRow.Parent = popup
        rainbowRow.Position = UDim2.new(0, 12, 0, 172)
        rainbowRow.Size = UDim2.new(1, -24, 0, 22)
        rainbowRow.BackgroundTransparency = 1

        local rainbowLbl = Instance.new("TextLabel")
        rainbowLbl.Parent = rainbowRow
        rainbowLbl.BackgroundTransparency = 1
        rainbowLbl.Size = UDim2.new(1, -40, 1, 0)
        rainbowLbl.Text = "Rainbow"
        rainbowLbl.TextColor3 = Theme.Text
        rainbowLbl.Font = Theme.Font
        rainbowLbl.TextSize = 12
        rainbowLbl.TextXAlignment = Enum.TextXAlignment.Left

        local rainbowBtn = Instance.new("TextButton")
        rainbowBtn.Parent = rainbowRow
        rainbowBtn.AnchorPoint = Vector2.new(1, 0.5)
        rainbowBtn.Position = UDim2.new(1, 0, 0.5, 0)
        rainbowBtn.Size = UDim2.fromOffset(30, 16)
        rainbowBtn.BackgroundColor3 = Theme.Element
        rainbowBtn.BorderSizePixel = 0
        rainbowBtn.Text = ""
        rainbowBtn.AutoButtonColor = false
        addCorner(rainbowBtn, 99)

        local rbThumb = Instance.new("Frame")
        rbThumb.Parent = rainbowBtn
        rbThumb.Size = UDim2.fromOffset(12, 12)
        rbThumb.Position = UDim2.new(0, 2, 0.5, -6)
        rbThumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
        rbThumb.BorderSizePixel = 0
        addCorner(rbThumb, 99)

        -- State
        local hue, sat, val = 0, 1, 1
        local rainbowActive = false
        local rainbowConn

        local function updateFromHSV()
            local c = Color3.fromHSV(hue, sat, val)
            canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            swatch.BackgroundColor3 = c
            callback(c)
        end

        local function setRainbow(on)
            rainbowActive = on
            tween(rainbowBtn, {BackgroundColor3 = on and Theme.Accent or Theme.Element}, 0.15)
            tween(rbThumb, {Position = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}, 0.15)
            if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
            if on then
                rainbowConn = RunService.RenderStepped:Connect(function()
                    local h = tick() % 5 / 5
                    local c = Color3.fromHSV(h, 1, 1)
                    swatch.BackgroundColor3 = c
                    callback(c, true)
                end)
            end
        end

        -- Dragging on canvas
        local function processCanvas(input)
            local pos, size = canvas.AbsolutePosition, canvas.AbsoluteSize
            sat = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            val = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
            cursor.Position = UDim2.fromScale(sat, 1 - val)
            updateFromHSV()
        end

        canvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                processCanvas(input)
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        processCanvas(inp)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        conn:Disconnect()
                    end
                end)
            end
        end)

        -- Dragging on hue bar
        local function processHue(input)
            local pos, size = hueBar.AbsolutePosition, hueBar.AbsoluteSize
            hue = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
            hueCursor.Position = UDim2.new(hue, 0, 0, -1)
            updateFromHSV()
        end

        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                processHue(input)
                local conn
                conn = UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        processHue(inp)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        conn:Disconnect()
                    end
                end)
            end
        end)

        rainbowBtn.MouseButton1Click:Connect(function()
            setRainbow(not rainbowActive)
        end)

        -- Default
        if type(default) == "boolean" and default then
            setRainbow(true)
        elseif typeof(default) == "Color3" then
            hue, sat, val = default:ToHSV()
            hueCursor.Position = UDim2.new(hue, 0, 0, -1)
            cursor.Position = UDim2.fromScale(sat, 1 - val)
            canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            swatch.BackgroundColor3 = default
        end

        -- Popup positioning
        local function positionPopup()
            local abs, size = swatch.AbsolutePosition, swatch.AbsoluteSize
            local cam = workspace.CurrentCamera
            local viewW = cam and cam.ViewportSize.X or 1920
            local viewH = cam and cam.ViewportSize.Y or 1080
            local px = math.clamp(abs.X, 8, viewW - 190)
            local py = math.clamp(abs.Y + size.Y + 4, 8, viewH - 230)
            popup.Position = UDim2.fromOffset(px, py)
        end

        swatch.MouseButton1Click:Connect(function()
            for _, p in ipairs(colorPickers) do
                if p ~= popup then p.Visible = false end
            end
            popup.Visible = not popup.Visible
            if popup.Visible then positionPopup() end
        end)

        closeBtn.MouseButton1Click:Connect(function() popup.Visible = false end)

        table.insert(colorPickers, popup)

        local api = {}
        function api:UpdateColorPicker(color)
            if typeof(color) == "Color3" then
                setRainbow(false)
                hue, sat, val = color:ToHSV()
                hueCursor.Position = UDim2.new(hue, 0, 0, -1)
                cursor.Position = UDim2.fromScale(sat, 1 - val)
                canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                swatch.BackgroundColor3 = color
            elseif type(color) == "boolean" then
                setRainbow(color)
            end
        end
        return api
    end

    return functions
end

return library
