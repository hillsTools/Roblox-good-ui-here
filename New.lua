-- Nonx UI Library
-- Version 1.0
-- GitHub: https://raw.githubusercontent.com/[your-username]/nonx-ui/main/Nonx.lua

local Nonx = {}
Nonx.__index = Nonx

-- Utility functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = game:GetService("TweenService"):Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- Main UI creation
function Nonx.new(options)
    options = options or {}
    local title = options.Title or "Nonx UI"
    local size = options.Size or UDim2.new(0, 500, 0, 350)
    local position = options.Position or UDim2.new(0.5, -250, 0.5, -175)
    
    local self = setmetatable({}, Nonx)
    self.Visible = false
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Create main screen GUI
    self.ScreenGui = createInstance("ScreenGui", {
        Name = "NonxUI",
        ResetOnSpawn = false
    })
    
    -- Main container
    self.MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = size,
        Position = position,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Top bar
    self.TopBar = createInstance("Frame", {
        Name = "TopBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0
    })
    
    self.Title = createInstance("TextLabel", {
        Name = "Title",
        Parent = self.TopBar,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    -- Close button
    self.CloseButton = createInstance("TextButton", {
        Name = "CloseButton",
        Parent = self.TopBar,
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Tab container (left side)
    self.TabContainer = createInstance("ScrollingFrame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(0, 70, 1, -60),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local uiListLayout = createInstance("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Tab content container
    self.TabContent = createInstance("Frame", {
        Name = "TabContent",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -70, 1, -60),
        Position = UDim2.new(0, 70, 0, 30),
        BackgroundTransparency = 1
    })
    
    -- Footer labels
    self.LeftFooter = createInstance("TextLabel", {
        Name = "LeftFooter",
        Parent = self.MainFrame,
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundTransparency = 1,
        Text = "Left Footer",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })
    
    self.RightFooter = createInstance("TextLabel", {
        Name = "RightFooter",
        Parent = self.MainFrame,
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 1, -20),
        BackgroundTransparency = 1,
        Text = "Right Footer",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    return self
end

-- Toggle visibility
function Nonx:Toggle()
    self.Visible = not self.Visible
    self.ScreenGui.Enabled = self.Visible
end

-- Show UI
function Nonx:Show()
    self.Visible = true
    self.ScreenGui.Enabled = true
end

-- Hide UI
function Nonx:Hide()
    self.Visible = false
    self.ScreenGui.Enabled = false
end

-- Set footer text
function Nonx:SetFooterText(side, text)
    if side:lower() == "left" then
        self.LeftFooter.Text = text
    elseif side:lower() == "right" then
        self.RightFooter.Text = text
    end
end

-- Create a new tab
function Nonx:CreateTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Sections = {}
    tab.Visible = false
    
    -- Tab button
    tab.Button = createInstance("TextButton", {
        Name = name .. "TabButton",
        Parent = self.TabContainer,
        Size = UDim2.new(1, -10, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = icon and utf8.char(tonumber(icon, 16)) or "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false
    })
    
    -- Tab name label (under icon)
    tab.Label = createInstance("TextLabel", {
        Name = name .. "Label",
        Parent = tab.Button,
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 11,
        Font = Enum.Font.Gotham
    })
    
    -- Round corners
    local corner = createInstance("UICorner", {
        Parent = tab.Button,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Tab content frame
    tab.Frame = createInstance("Frame", {
        Name = name .. "Frame",
        Parent = self.TabContent,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    -- Section container (top middle)
    tab.SectionContainer = createInstance("ScrollingFrame", {
        Name = "SectionContainer",
        Parent = tab.Frame,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X
    })
    
    local sectionListLayout = createInstance("UIListLayout", {
        Parent = tab.SectionContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal
    })
    
    -- Content container (below sections)
    tab.ContentFrame = createInstance("Frame", {
        Name = "ContentFrame",
        Parent = tab.Frame,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1
    })
    
    -- Left and right columns
    tab.LeftColumn = createInstance("ScrollingFrame", {
        Name = "LeftColumn",
        Parent = tab.ContentFrame,
        Size = UDim2.new(0.5, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    tab.RightColumn = createInstance("ScrollingFrame", {
        Name = "RightColumn",
        Parent = tab.ContentFrame,
        Size = UDim2.new(0.5, -5, 1, 0),
        Position = UDim2.new(0.5, 5, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    -- Layout for columns
    local leftLayout = createInstance("UIListLayout", {
        Parent = tab.LeftColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    local rightLayout = createInstance("UIListLayout", {
        Parent = tab.RightColumn,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.LeftColumn.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y)
    end)
    
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.RightColumn.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y)
    end)
    
    -- Button click event
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Create section method for this tab
    function tab:CreateSection(name)
        local section = {}
        section.Name = name
        section.Visible = false
        
        -- Section button
        section.Button = createInstance("TextButton", {
            Name = name .. "SectionButton",
            Parent = self.SectionContainer,
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Text = name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Gotham,
            AutoButtonColor = false
        })
        
        -- Round corners
        local corner = createInstance("UICorner", {
            Parent = section.Button,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Section content frame
        section.Frame = createInstance("Frame", {
            Name = name .. "SectionFrame",
            Parent = self.ContentFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        })
        
        -- Left and right columns for section
        section.LeftColumn = createInstance("ScrollingFrame", {
            Name = "LeftColumn",
            Parent = section.Frame,
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        section.RightColumn = createInstance("ScrollingFrame", {
            Name = "RightColumn",
            Parent = section.Frame,
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        -- Layout for section columns
        local leftLayout = createInstance("UIListLayout", {
            Parent = section.LeftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local rightLayout = createInstance("UIListLayout", {
            Parent = section.RightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.LeftColumn.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y)
        end)
        
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.RightColumn.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y)
        end)
        
        -- Button click event
        section.Button.MouseButton1Click:Connect(function()
            self:SelectSection(section)
        end)
        
        table.insert(self.Sections, section)
        
        -- Select first section by default
        if #self.Sections == 1 then
            self:SelectSection(section)
        end
        
        -- Add element methods to the section
        function section:AddButton(options)
            options = options or {}
            local name = options.Name or "Button"
            local callback = options.Callback or function() end
            local column = options.Column or "Left"
            
            local buttonFrame = createInstance("Frame", {
                Name = name .. "ButtonFrame",
                Parent = column == "Left" and self.LeftColumn or self.RightColumn,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = options.LayoutOrder or 1
            })
            
            local button = createInstance("TextButton", {
                Name = name .. "Button",
                Parent = buttonFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                AutoButtonColor = false
            })
            
            local corner = createInstance("UICorner", {
                Parent = button,
                CornerRadius = UDim.new(0, 4)
            })
            
            button.MouseEnter:Connect(function()
                tween(button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
            end)
            
            button.MouseLeave:Connect(function()
                tween(button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
            end)
            
            button.MouseButton1Click:Connect(function()
                callback()
                tween(button, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.1)
                wait(0.1)
                tween(button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.1)
            end)
            
            return button
        end
        
        function section:AddToggle(options)
            options = options or {}
            local name = options.Name or "Toggle"
            local default = options.Default or false
            local callback = options.Callback or function() end
            local column = options.Column or "Left"
            
            local toggleFrame = createInstance("Frame", {
                Name = name .. "ToggleFrame",
                Parent = column == "Left" and self.LeftColumn or self.RightColumn,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = options.LayoutOrder or 1
            })
            
            local label = createInstance("TextLabel", {
                Name = name .. "Label",
                Parent = toggleFrame,
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local toggle = createInstance("TextButton", {
                Name = name .. "Toggle",
                Parent = toggleFrame,
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(0.7, 0, 0, 0),
                BackgroundColor3 = default and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(50, 50, 50),
                Text = "",
                AutoButtonColor = false
            })
            
            local corner = createInstance("UICorner", {
                Parent = toggle,
                CornerRadius = UDim.new(0, 10)
            })
            
            local state = default
            
            toggle.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    tween(toggle, {BackgroundColor3 = Color3.fromRGB(0, 170, 127)}, 0.2)
                else
                    tween(toggle, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
                end
                callback(state)
            end)
            
            return toggle
        end
        
        function section:AddSlider(options)
            options = options or {}
            local name = options.Name or "Slider"
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            local callback = options.Callback or function() end
            local column = options.Column or "Left"
            local precise = options.Precise or false
            
            local sliderFrame = createInstance("Frame", {
                Name = name .. "SliderFrame",
                Parent = column == "Left" and self.LeftColumn or self.RightColumn,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                LayoutOrder = options.LayoutOrder or 1
            })
            
            local label = createInstance("TextLabel", {
                Name = name .. "Label",
                Parent = sliderFrame,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = name .. ": " .. default,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local track = createInstance("Frame", {
                Name = name .. "Track",
                Parent = sliderFrame,
                Size = UDim2.new(1, 0, 0, 5),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            })
            
            local trackCorner = createInstance("UICorner", {
                Parent = track,
                CornerRadius = UDim.new(1, 0)
            })
            
            local fill = createInstance("Frame", {
                Name = name .. "Fill",
                Parent = track,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 170, 127)
            })
            
            local fillCorner = createInstance("UICorner", {
                Parent = fill,
                CornerRadius = UDim.new(1, 0)
            })
            
            local handle = createInstance("TextButton", {
                Name = name .. "Handle",
                Parent = track,
                Size = UDim2.new(0, 15, 0, 15),
                Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 2
            })
            
            local handleCorner = createInstance("UICorner", {
                Parent = handle,
                CornerRadius = UDim.new(1, 0)
            })
            
            local dragging = false
            local value = default
            
            local function updateValue(input)
                local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                relativeX = math.clamp(relativeX, 0, 1)
                
                if precise then
                    value = math.floor(min + relativeX * (max - min))
                else
                    value = min + relativeX * (max - min)
                end
                
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                handle.Position = UDim2.new(relativeX, -7, 0.5, -7)
                label.Text = name .. ": " .. value
                
                callback(value)
            end
            
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            handle.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateValue(input)
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input)
                end
            end)
            
            return {
                SetValue = function(newValue)
                    value = math.clamp(newValue, min, max)
                    local relativeX = (value - min) / (max - min)
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    handle.Position = UDim2.new(relativeX, -7, 0.5, -7)
                    label.Text = name .. ": " .. value
                    callback(value)
                end,
                GetValue = function()
                    return value
                end
            }
        end
        
        function section:AddDropdown(options)
            options = options or {}
            local name = options.Name or "Dropdown"
            local items = options.Items or {}
            local default = options.Default or items[1] or ""
            local callback = options.Callback or function() end
            local column = options.Column or "Left"
            
            local dropdownFrame = createInstance("Frame", {
                Name = name .. "DropdownFrame",
                Parent = column == "Left" and self.LeftColumn or self.RightColumn,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = options.LayoutOrder or 1
            })
            
            local label = createInstance("TextLabel", {
                Name = name .. "Label",
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local dropdown = createInstance("TextButton", {
                Name = name .. "Dropdown",
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 15),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Text = default,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                AutoButtonColor = false
            })
            
            local corner = createInstance("UICorner", {
                Parent = dropdown,
                CornerRadius = UDim.new(0, 4)
            })
            
            local dropdownList = createInstance("ScrollingFrame", {
                Name = name .. "DropdownList",
                Parent = dropdownFrame,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 45),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                ScrollBarThickness = 3,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Visible = false,
                ClipsDescendants = true
            })
            
            local listLayout = createInstance("UIListLayout", {
                Parent = dropdownList,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end)
            
            local open = false
            local selected = default
            
            local function toggleDropdown()
                open = not open
                if open then
                    dropdownList.Visible = true
                    tween(dropdownList, {Size = UDim2.new(1, 0, 0, math.min(100, #items * 30))}, 0.2)
                else
                    tween(dropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    wait(0.2)
                    dropdownList.Visible = false
                end
            end
            
            dropdown.MouseButton1Click:Connect(toggleDropdown)
            
            for i, item in ipairs(items) do
                local option = createInstance("TextButton", {
                    Name = item .. "Option",
                    Parent = dropdownList,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                    Text = item,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Font = Enum.Font.Gotham,
                    AutoButtonColor = false,
                    LayoutOrder = i
                })
                
                option.MouseButton1Click:Connect(function()
                    selected = item
                    dropdown.Text = selected
                    callback(selected)
                    toggleDropdown()
                end)
                
                option.MouseEnter:Connect(function()
                    tween(option, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
                end)
                
                option.MouseLeave:Connect(function()
                    tween(option, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.2)
                end)
            end
            
            return {
                SetSelected = function(item)
                    if table.find(items, item) then
                        selected = item
                        dropdown.Text = selected
                        callback(selected)
                    end
                end,
                GetSelected = function()
                    return selected
                end
            }
        end
        
        function section:AddTextBox(options)
            options = options or {}
            local name = options.Name or "TextBox"
            local placeholder = options.Placeholder or "Enter text..."
            local default = options.Default or ""
            local callback = options.Callback or function() end
            local column = options.Column or "Left"
            
            local textboxFrame = createInstance("Frame", {
                Name = name .. "TextboxFrame",
                Parent = column == "Left" and self.LeftColumn or self.RightColumn,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1,
                LayoutOrder = options.LayoutOrder or 1
            })
            
            local label = createInstance("TextLabel", {
                Name = name .. "Label",
                Parent = textboxFrame,
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local textbox = createInstance("TextBox", {
                Name = name .. "Textbox",
                Parent = textboxFrame,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 15),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Text = default,
                PlaceholderText = placeholder,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = false
            })
            
            local corner = createInstance("UICorner", {
                Parent = textbox,
                CornerRadius = UDim.new(0, 4)
            })
            
            textbox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    callback(textbox.Text)
                end
            end)
            
            return textbox
        end
        
        function section:AddLabel(options)
            options = options or {}
            local text = options.Text or "Label"
            local column = options.Column or "Left"
            
            local label = createInstance("TextLabel", {
                Name = text .. "Label",
                Parent = column == "Left" and self.LeftColumn or self.RightColumn,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                LayoutOrder = options.LayoutOrder or 1
            })
            
            return label
        end
        
        return section
    end
    
    -- Select section method for this tab
    function tab:SelectSection(section)
        for _, s in ipairs(self.Sections) do
            s.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            s.Frame.Visible = false
        end
        
        section.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        section.Frame.Visible = true
    end
    
    return tab
end

-- Select a tab
function Nonx:SelectTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        self.CurrentTab.Frame.Visible = false
    end
    
    self.CurrentTab = tab
    tab.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tab.Frame.Visible = true
end

return Nonx
