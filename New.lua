local Nonx = {}
Nonx._version = "1.0"

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--// small utility
local function new(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = inst
        end
    end
    return inst
end

local function roundify(guiObject, r)
    new("UICorner", { CornerRadius = UDim.new(0, r or 10), Parent = guiObject })
end

local function pad(parent, l,t,r,b)
    new("UIPadding", {PaddingLeft=UDim.new(0,l or 8),PaddingTop=UDim.new(0,t or 8),PaddingRight=UDim.new(0,r or 8),PaddingBottom=UDim.new(0,b or 8), Parent=parent})
end

local function vlist(parent, padval)
    return new("UIListLayout", {FillDirection=Enum.FillDirection.Vertical, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, padval or 6), Parent=parent})
end

local function hlist(parent, padval)
    return new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0, padval or 6), Parent=parent})
end

local function autosize(scroll)
    local function resize()
        local abs = scroll.UIListLayout.AbsoluteContentSize
        scroll.CanvasSize = UDim2.new(0, 0, 0, abs.Y + 8)
    end
    scroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    resize()
end

--// default theme
local DEFAULTS = {
    Accent = Color3.fromRGB(0, 200, 120),
    Bg = Color3.fromRGB(18,18,18),
    Panel = Color3.fromRGB(28,28,28),
    Muted = Color3.fromRGB(45,45,45),
    Text = Color3.fromRGB(235,235,235),
    SubText = Color3.fromRGB(170,170,170)
}

--// Fonts
local FONT = Enum.Font.GothamSemibold
local FONT_LIGHT = Enum.Font.Gotham

--// Window construction
function Nonx:CreateWindow(opts)
    opts = opts or {}
    local theme = {
        Accent = opts.Accent or DEFAULTS.Accent,
        Bg = opts.Bg or DEFAULTS.Bg,
        Panel = opts.Panel or DEFAULTS.Panel,
        Muted = opts.Muted or DEFAULTS.Muted,
        Text = opts.Text or DEFAULTS.Text,
        SubText = opts.SubText or DEFAULTS.SubText,
    }

    -- ScreenGui
    local gui = new("ScreenGui", {
        Name = "NonxUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = PlayerGui
    })

    -- Main frame
    local Main = new("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 980, 0, 560),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Bg,
        BorderSizePixel = 0,
        Parent = gui
    })
    roundify(Main, 14)
    pad(Main, 10,10,10,10)

    -- Layout: Left sidebar + Right content column
    local Row = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=Main})
    hlist(Row, 10)

    -- Sidebar
    local Sidebar = new("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 1, 0),
        Parent = Row
    })
    roundify(Sidebar, 12)
    pad(Sidebar, 10, 12, 10, 10)

    local SideTitle = new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,24),
        Text = (opts.Title or "Nonx")..".lol",
        TextColor3 = theme.Text,
        Font = FONT,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Sidebar
    })

    local SideButtons = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,-60), Position=UDim2.new(0,0,0,34), Parent=Sidebar})
    local SideList = vlist(SideButtons, 8)

    local SideFooter = new("TextLabel", {
        Name = "LeftFooter",
        BackgroundTransparency = 1,
        Text = opts.FooterLeft or "",
        TextColor3 = theme.SubText,
        Font = FONT_LIGHT,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, -4, 0, 18),
        Parent = Sidebar
    })

    -- Right column
    local Right = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1, -190, 1, 0), Parent = Row})

    -- Top-middle tab section strip
    local SectionStrip = new("Frame", {
        Name = "SectionStrip",
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 46),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        Parent = Right
    })
    roundify(SectionStrip, 12)
    pad(SectionStrip, 10, 8, 10, 8)

    local SectionButtons = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=SectionStrip})
    local SectionList = hlist(SectionButtons, 8)

    -- Content area (pages per active Tab Section)
    local PagesHolder = new("Frame", {
        Name = "PagesHolder",
        BackgroundColor3 = theme.Bg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 56),
        Parent = Right
    })

    local PageContainer = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=PagesHolder})

    -- Bottom-right footer
    local RightFooter = new("TextLabel", {
        Name = "RightFooter",
        BackgroundTransparency = 1,
        Text = opts.FooterRight or "",
        TextColor3 = theme.SubText,
        Font = FONT_LIGHT,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1, -12, 1, -8),
        Size = UDim2.new(1, -12, 0, 18),
        Parent = Right
    })

    -- Dragging via SectionStrip
    do
        local dragging, dragStart, startPos
        SectionStrip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- helpers to make standard button style
    local function makePill(text)
        local btn = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = theme.Muted,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 120, 1, -6),
            Text = text,
            TextColor3 = theme.Text,
            Font = FONT,
            TextSize = 14
        })
        roundify(btn, 10)
        local function setActive(a)
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = a and theme.Accent or theme.Muted}):Play()
        end
        return btn, setActive
    end

    local window = {
        _gui = gui,
        _theme = theme,
        _tabs = {},
        _activeTab = nil,
        _sectionStrip = SectionStrip,
        _sectionList = SectionList,
        _sectionButtonsFrame = SectionButtons,
        _pages = PageContainer,
        _leftFooter = SideFooter,
        _rightFooter = RightFooter,
        _sideButtons = SideButtons,
        _sideList = SideList
    }

    function window:SetFooters(leftText, rightText)
        self._leftFooter.Text = leftText or self._leftFooter.Text
        self._rightFooter.Text = rightText or self._rightFooter.Text
    end

    -- Create sidebar tab button
    local function makeTabButton(tabName)
        local holder = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,36)})
        local btn = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = theme.Muted,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,1,0),
            Text = tabName,
            TextColor3 = theme.Text,
            Font = FONT,
            TextSize = 15,
            Parent = holder
        })
        roundify(btn, 8)
        local function active(a)
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = a and theme.Accent or theme.Muted}):Play()
        end
        return holder, btn, active
    end

    function window:AddTab(tabName)
        local tab = {
            Name = tabName,
            _sections = {},
            _sectionButtons = {},
            _activeSection = nil
        }
        local holder, btn, markActive = makeTabButton(tabName)
        holder.Parent = self._sideButtons
        self._sideList.Parent = self._sideButtons -- ensure layout binds

        local function activateTab()
            if window._activeTab == tab then return end
            -- sidebar visual
            for _, t in ipairs(window._tabs) do t._markActive(false) end
            markActive(true)
            window._activeTab = tab

            -- clear section strip buttons
            for _, child in ipairs(window._sectionButtonsFrame:GetChildren()) do
                if child:IsA("GuiObject") then child:Destroy() end
            end

            -- populate new tab's section buttons
            for _, s in ipairs(tab._sections) do
                s:_ensureButton()
            end

            -- auto select first section
            if tab._sections[1] then
                tab:setActiveSection(tab._sections[1])
            end
        end

        btn.MouseButton1Click:Connect(activateTab)

        tab._markActive = markActive

        function tab:_ensureButton()
            if self._button then return end
            local pill, setActive = makePill(self.Name)
            pill.Parent = window._sectionButtonsFrame
            window._sectionList.Parent = window._sectionButtonsFrame
            self._button = pill
            self._setActiveBtn = setActive
            pill.MouseButton1Click:Connect(function()
                tab:setActiveSection(self)
            end)
        end

        function tab:setActiveSection(section)
            if self._activeSection == section then return end
            -- hide all pages
            for _, s in ipairs(self._sections) do
                if s._leftCol then s._leftCol.Visible = false end
                if s._rightCol then s._rightCol.Visible = false end
                if s._setActiveBtn then s._setActiveBtn(false) end
            end
            -- show selected
            section._leftCol.Visible = true
            section._rightCol.Visible = true
            if section._setActiveBtn then section._setActiveBtn(true) end
            self._activeSection = section
        end

        function tab:AddSection(sectionName)
            local section = { Name = sectionName, _controls = {} }
            -- create columns (hidden by default)
            local LeftCol = new("ScrollingFrame", {
                Active = true,
                ClipsDescendants = true,
                BackgroundColor3 = window._theme.Panel,
                BorderSizePixel = 0,
                Visible = false,
                Size = UDim2.new(0.5, -6, 1, -6),
                Position = UDim2.new(0, 0, 0, 0),
                Parent = window._pages
            })
            roundify(LeftCol, 12)
            pad(LeftCol, 10,10,10,10)
            LeftCol.CanvasSize = UDim2.new(0,0,0,0)
            local LeftList = vlist(LeftCol, 8); LeftList.Name = "UIListLayout"
            autosize(LeftCol)

            local RightCol = new("ScrollingFrame", {
                Active = true,
                ClipsDescendants = true,
                BackgroundColor3 = window._theme.Panel,
                BorderSizePixel = 0,
                Visible = false,
                Size = UDim2.new(0.5, -6, 1, -6),
                Position = UDim2.new(0.5, 6, 0, 0),
                Parent = window._pages
            })
            roundify(RightCol, 12)
            pad(RightCol, 10,10,10,10)
            RightCol.CanvasSize = UDim2.new(0,0,0,0)
            local RightList = vlist(RightCol, 8); RightList.Name = "UIListLayout"
            autosize(RightCol)

            section._leftCol = LeftCol
            section._rightCol = RightCol

            function section:_makeItem(height)
                height = height or 36
                local item = new("Frame", {BackgroundColor3=window._theme.Muted, BorderSizePixel=0, Size=UDim2.new(1,0,0,height)})
                roundify(item, 8)
                pad(item, 10, 8, 10, 8)
                return item
            end

            function section.Left:AddLabel(text)
                local item = section:_makeItem(30); item.Parent = LeftCol
                new("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Size=UDim2.new(1,0,1,0), TextXAlignment=Enum.TextXAlignment.Left, Parent=item})
                return {
                    SetText = function(_, t) item:FindFirstChildOfClass("TextLabel").Text = t end
                }
            end
            function section.Right:AddLabel(text)
                local item = section:_makeItem(30); item.Parent = RightCol
                new("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Size=UDim2.new(1,0,1,0), TextXAlignment=Enum.TextXAlignment.Left, Parent=item})
                return {
                    SetText = function(_, t) item:FindFirstChildOfClass("TextLabel").Text = t end
                }
            end

            -- Buttons
            local function addButton(where, text, cb)
                local item = section:_makeItem(36); item.Parent = where
                local btn = new("TextButton", {AutoButtonColor=false, BackgroundTransparency=1, Text=text, TextColor3=window._theme.Text, Font=FONT, TextSize=14, Size=UDim2.new(1,0,1,0), Parent=item})
                btn.MouseButton1Click:Connect(function()
                    if cb then cb() end
                end)
                return {
                    SetText = function(_, t) btn.Text = t end
                }
            end

            function section.Left:AddButton(text, cb) return addButton(LeftCol, text, cb) end
            function section.Right:AddButton(text, cb) return addButton(RightCol, text, cb) end

            -- Toggle
            local function addToggle(where, text, default, cb)
                local item = section:_makeItem(36); item.Parent = where
                new("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Size=UDim2.new(1,-60,1,0), TextXAlignment=Enum.TextXAlignment.Left, Parent=item})
                local switch = new("Frame", {BackgroundColor3=window._theme.Bg, BorderSizePixel=0, Size=UDim2.new(0,50,0,22), AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-4,0.5,0), Parent=item})
                roundify(switch, 11)
                local knob = new("Frame", {BackgroundColor3=window._theme.Muted, BorderSizePixel=0, Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,2,0.5,-9), Parent=switch})
                roundify(knob, 9)
                local state = default and true or false
                local function render()
                    TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9), BackgroundColor3 = state and window._theme.Accent or window._theme.Muted}):Play()
                end
                render()
                local function toggle()
                    state = not state
                    render()
                    if cb then cb(state) end
                end
                item.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then toggle() end
                end)
                return { Set = function(_, v) state = v; render() end, Get=function() return state end }
            end
            function section.Left:AddToggle(text, default, cb) return addToggle(LeftCol, text, default, cb) end
            function section.Right:AddToggle(text, default, cb) return addToggle(RightCol, text, default, cb) end

            -- Slider
            local function addSlider(where, text, min, max, default, cb)
                min, max = min or 0, max or 100
                local value = math.clamp(default or min, min, max)
                local item = section:_makeItem(46); item.Parent = where
                new("TextLabel", {BackgroundTransparency=1, Text=string.format("%s: %s", text, tostring(value)), Name="Label", TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Size=UDim2.new(1,0,0,18), TextXAlignment=Enum.TextXAlignment.Left, Parent=item})
                local bar = new("Frame", {BackgroundColor3=window._theme.Bg, BorderSizePixel=0, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,26), Parent=item})
                roundify(bar, 7)
                local fill = new("Frame", {BackgroundColor3=window._theme.Accent, BorderSizePixel=0, Size=UDim2.new((value-min)/(max-min),0,1,0), Parent=bar})
                roundify(fill, 7)
                local dragging=false
                local function setFromX(px)
                    local rel = math.clamp((px - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max-min)*rel + 0.5)
                    fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                    item.Label.Text = string.format("%s: %s", text, tostring(value))
                    if cb then cb(value) end
                end
                bar.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                        dragging=true; setFromX(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                        setFromX(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
                end)
                return {
                    Set = function(_, v) value = math.clamp(v, min, max); fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0); item.Label.Text = string.format("%s: %s", text, tostring(value)) end,
                    Get = function() return value end
                }
            end
            function section.Left:AddSlider(text, min, max, default, cb) return addSlider(LeftCol, text, min, max, default, cb) end
            function section.Right:AddSlider(text, min, max, default, cb) return addSlider(RightCol, text, min, max, default, cb) end

            -- Dropdown
            local function addDropdown(where, text, options, default, cb)
                options = options or {"Option A","Option B"}
                local selected = default or options[1]
                local item = section:_makeItem(36); item.Parent = where
                local label = new("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Size=UDim2.new(1,-110,1,0), TextXAlignment=Enum.TextXAlignment.Left, Parent=item})
                local btn = new("TextButton", {AutoButtonColor=false, BackgroundColor3=window._theme.Bg, BorderSizePixel=0, Size=UDim2.new(0,110,0,24), AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-4,0.5,0), Text=selected, TextColor3=window._theme.Text, Font=FONT, TextSize=13, Parent=item})
                roundify(btn, 8)
                local listOpen
                local drop
                local function close()
                    if drop then drop:Destroy(); drop=nil; listOpen=false end
                end
                local function choose(v)
                    selected=v; btn.Text=v; if cb then cb(v) end; close()
                end
                btn.MouseButton1Click:Connect(function()
                    if listOpen then close() return end
                    listOpen = true
                    drop = new("Frame", {BackgroundColor3=window._theme.Bg, BorderSizePixel=0, Size=UDim2.new(0,110,0,#options*24+8), Position=UDim2.new(1,-4,1,6), AnchorPoint=Vector2.new(1,0), Parent=item})
                    roundify(drop, 8)
                    pad(drop, 6,6,6,6)
                    local cont = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=drop}); vlist(cont,4)
                    for _, opt in ipairs(options) do
                        local o = new("TextButton", {AutoButtonColor=true, BackgroundTransparency=1, Text=opt, TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=13, Size=UDim2.new(1,0,0,20), Parent=cont})
                        o.MouseButton1Click:Connect(function() choose(opt) end)
                    end
                end)
                item.AncestryChanged:Connect(close)
                return { Set = function(_, v) choose(v) end, Get=function() return selected end }
            end
            function section.Left:AddDropdown(text, options, default, cb) return addDropdown(LeftCol, text, options, default, cb) end
            function section.Right:AddDropdown(text, options, default, cb) return addDropdown(RightCol, text, options, default, cb) end

            -- TextBox
            local function addTextbox(where, text, default, cb)
                local item = section:_makeItem(40); item.Parent = where
                new("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Size=UDim2.new(1,-140,1,0), TextXAlignment=Enum.TextXAlignment.Left, Parent=item})
                local box = new("TextBox", {ClearTextOnFocus=false, BackgroundColor3=window._theme.Bg, BorderSizePixel=0, Size=UDim2.new(0,140,0,26), AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-4,0.5,0), Text=default or "", TextColor3=window._theme.Text, Font=FONT_LIGHT, TextSize=14, Parent=item})
                roundify(box, 8)
                box.FocusLost:Connect(function(enter)
                    if cb then cb(box.Text, enter) end
                end)
                return { Set=function(_,t) box.Text=t end, Get=function() return box.Text end }
            end
            function section.Left:AddTextbox(text, default, cb) return addTextbox(LeftCol, text, default, cb) end
            function section.Right:AddTextbox(text, default, cb) return addTextbox(RightCol, text, default, cb) end

            -- expose columns
            section.Left = section.Left or {}
            section.Right = section.Right or {}

            -- keep ordering & visuals in sidebar strip
            table.insert(self._sections, section)
            section:_ensureButton = function() if not section._button then tab._ensureButton(section) end end
            tab._ensureButton = function(s) -- create button for a section
                local pill, setActive = makePill(s.Name)
                pill.Parent = window._sectionButtonsFrame
                window._sectionList.Parent = window._sectionButtonsFrame
                s._button = pill
                s._setActiveBtn = setActive
                pill.MouseButton1Click:Connect(function() tab:setActiveSection(s) end)
            end
            tab._ensureButton(section)

            -- if first section in a new tab becomes active when tab is clicked later
            if window._activeTab == tab and not tab._activeSection then
                tab:setActiveSection(section)
            end

            return section
        end

        table.insert(window._tabs, tab)

        -- auto-activate first tab
        if not window._activeTab then
            btn.BackgroundColor3 = theme.Accent
            markActive(true)
            window._activeTab = tab
        end

        return tab
    end

    function window:Destroy()
        self._gui:Destroy()
    end

    return window
end

return Nonx
