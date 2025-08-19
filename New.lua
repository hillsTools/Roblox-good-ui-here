-- Boost UI Library - Mobile Optimized
-- Designed for GitHub raw URL loading
-- Version: 2.0 (Mobile Optimized)

if getgenv().BoostUILoaded then return end
getgenv().BoostUILoaded = true

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- Utility functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function Tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function Round(num, decimalPlaces)
    local multiplier = 10^(decimalPlaces or 0)
    return math.floor(num * multiplier + 0.5) / multiplier
end

-- Main Library
local BoostUI = {}
BoostUI.__index = BoostUI

function BoostUI.new(options)
    local self = setmetatable({}, BoostUI)
    
    self.Title = options.Title or "Boost UI"
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.Position = options.Position or UDim2.new(0.5, -250, 0.5, -200)
    self.AccentColor = options.AccentColor or Color3.fromRGB(0, 170, 255)
    self.Theme = options.Theme or "Dark"
    
    self.Visible = false
    self.Tabs = {}
    self.CurrentTab = nil
    self.Sections = {}
    self.Elements = {}
    
    self:CreateMainWindow()
    
    return self
end

function BoostUI:CreateMainWindow()
    -- ScreenGui container
    self.ScreenGui = Create("ScreenGui", {
        Name = "BoostUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 10
    })
    
    -- Main window frame
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = self.Size,
        Position = self.Position,
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(240, 240, 240),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true
    })
    
    -- Add rounded corners
    self.Corner = Create("UICorner", {
        Parent = self.MainFrame,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Add shadow effect
    self.Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = 0
    })
    
    -- Title bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(220, 220, 220),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    self.TitleCorner = Create("UICorner", {
        Parent = self.TitleBar,
        CornerRadius = UDim.new(0, 8, 0, 0)
    })
    
    -- Title text (top left corner)
    self.TitleText = Create("TextLabel", {
        Name = "TitleText",
        Parent = self.TitleBar,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        ZIndex = 3
    })
    
    -- Close button
    self.CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = self.TitleBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        ZIndex = 3
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Tab container (under title bar)
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    self.TabListLayout = Create("UIListLayout", {
        Parent = self.TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    self.TabPadding = Create("UIPadding", {
        Parent = self.TabContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    -- Content area
    self.ContentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 1
    })
    
    self.ContentLayout = Create("UIListLayout", {
        Parent = self.ContentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    self.ContentPadding = Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    -- Make window draggable
    self:Draggify(self.TitleBar)
    
    -- Handle mobile input
    if IsMobile() then
        self:SetupMobileInput()
    end
end

function BoostUI:SetupMobileInput()
    -- Make UI elements more touch-friendly
    local function increaseHitArea(frame, padding)
        local hitbox = Create("Frame", {
            Parent = frame,
            Size = UDim2.new(1, padding * 2, 1, padding * 2),
            Position = UDim2.new(0, -padding, 0, -padding),
            BackgroundTransparency = 1,
            Active = true
        })
        return hitbox
    end
    
    -- Increase hit area for buttons
    for _, button in pairs(self.MainFrame:GetDescendants()) do
        if button:IsA("TextButton") then
            increaseHitArea(button, 10)
        end
    end
    
    -- Make sliders easier to use on mobile
    self.MainFrame.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("TextButton") and descendant.Name == "SliderButton" then
            increaseHitArea(descendant, 15)
        end
    end)
end

function BoostUI:Draggify(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Tween(self.MainFrame, {
                Position = UDim2.new(
                    framePos.X.Scale, 
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale, 
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1)
        end
    end)
end

function BoostUI:Toggle()
    self.Visible = not self.Visible
    self.MainFrame.Visible = self.Visible
    
    if self.Visible then
        Tween(self.MainFrame, {
            Size = self.Size,
            Position = self.Position
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Tween(self.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    end
end

function BoostUI:Tab(name)
    local tab = {
        Name = name,
        Sections = {}
    }
    
    local tabButton = Create("TextButton", {
        Name = name .. "Tab",
        Parent = self.TabContainer,
        Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        ZIndex = 3
    })
    
    local tabCorner = Create("UICorner", {
        Parent = tabButton,
        CornerRadius = UDim.new(0, 6)
    })
    
    local tabPadding = Create("UIPadding", {
        Parent = tabButton,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    -- Set first tab as active by default
    if #self.Tabs == 0 then
        self:SwitchTab(tab)
    end
    
    table.insert(self.Tabs, tab)
    
    return setmetatable(tab, {__index = function(_, key)
        if key == "Section" then
            return function(sectionName, side)
                return self:Section(sectionName, side, tab)
            end
        end
    end})
end

function BoostUI:SwitchTab(tab)
    if self.CurrentTab == tab then return end
    
    -- Hide all sections
    for _, section in pairs(self.Sections) do
        section.Visible = false
    end
    
    -- Show sections for this tab
    for _, section in pairs(tab.Sections) do
        section.Visible = true
    end
    
    -- Update tab button appearances
    for _, otherTab in pairs(self.Tabs) do
        local button = self.TabContainer:FindFirstChild(otherTab.Name .. "Tab")
        if button then
            if otherTab == tab then
                Tween(button, {
                    BackgroundColor3 = self.AccentColor,
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }, 0.2)
            else
                Tween(button, {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }, 0.2)
            end
        end
    end
    
    self.CurrentTab = tab
end

function BoostUI:Section(name, side, tab)
    side = side or "Left"
    
    local section = Create("Frame", {
        Name = name .. "Section",
        Parent = self.ContentFrame,
        Size = UDim2.new(side == "Full" and 1 or 0.48, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(245, 245, 245),
        BorderSizePixel = 0,
        LayoutOrder = side == "Left" and 1 or 2,
        Visible = tab == self.CurrentTab
    })
    
    local sectionCorner = Create("UICorner", {
        Parent = section,
        CornerRadius = UDim.new(0, 6)
    })
    
    local sectionPadding = Create("UIPadding", {
        Parent = section,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    local sectionLayout = Create("UIListLayout", {
        Parent = section,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    
    local sectionTitle = Create("TextLabel", {
        Name = "SectionTitle",
        Parent = section,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    })
    
    self.Sections[name] = section
    
    if tab then
        table.insert(tab.Sections, section)
    end
    
    return {
        Label = function(text)
            return self:Label(text, section)
        end,
        Button = function(text, callback)
            return self:Button(text, callback, section)
        end,
        Toggle = function(text, default, callback)
            return self:Toggle(text, default, callback, section)
        end,
        Slider = function(text, min, max, default, callback)
            return self:Slider(text, min, max, default, callback, section)
        end,
        Dropdown = function(text, options, callback)
            return self:Dropdown(text, options, callback, section)
        end,
        Textbox = function(text, placeholder, callback)
            return self:Textbox(text, placeholder, callback, section)
        end
    }
end

function BoostUI:Label(text, parent)
    local label = Create("TextLabel", {
        Name = text .. "Label",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        LayoutOrder = #parent:GetChildren()
    })
    
    return label
end

function BoostUI:Button(text, callback, parent)
    local button = Create("TextButton", {
        Name = text .. "Button",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        LayoutOrder = #parent:GetChildren(),
        AutoButtonColor = false
    })
    
    local buttonCorner = Create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        if not IsMobile() then
            Tween(button, {BackgroundColor3 = self.AccentColor:Lerp(Color3.fromRGB(255, 255, 255), 0.2)}, 0.2)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not IsMobile() then
            Tween(button, {BackgroundColor3 = self.AccentColor}, 0.2)
        end
    end)
    
    -- Press effect
    button.MouseButton1Down:Connect(function()
        Tween(button, {Size = UDim2.new(0.95, 0, 0, 28)}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        Tween(button, {Size = UDim2.new(1, 0, 0, 30)}, 0.1)
        if callback then callback() end
    end)
    
    -- Touch support
    if IsMobile() then
        local touchStartTime = 0
        local touchStartPos = Vector2.new(0, 0)
        
        button.TouchTap:Connect(function()
            if callback then callback() end
        end)
    end
    
    return button
end

function BoostUI:Toggle(text, default, callback, parent)
    local toggled = default or false
    
    local toggle = Create("Frame", {
        Name = text .. "Toggle",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = #parent:GetChildren()
    })
    
    local toggleLabel = Create("TextLabel", {
        Name = "ToggleLabel",
        Parent = toggle,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    local toggleButton = Create("TextButton", {
        Name = "ToggleButton",
        Parent = toggle,
        Size = UDim2.new(0.3, 0, 0, 20),
        Position = UDim2.new(0.7, 0, 0.5, -10),
        BackgroundColor3 = toggled and self.AccentColor or Color3.fromRGB(80, 80, 80),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ""
    })
    
    local toggleCorner = Create("UICorner", {
        Parent = toggleButton,
        CornerRadius = UDim.new(0, 10)
    })
    
    local toggleKnob = Create("Frame", {
        Name = "ToggleKnob",
        Parent = toggleButton,
        Size = UDim2.new(0, 16, 0, 16),
        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    
    local knobCorner = Create("UICorner", {
        Parent = toggleKnob,
        CornerRadius = UDim.new(0, 8)
    })
    
    local function updateToggle()
        Tween(toggleButton, {
            BackgroundColor3 = toggled and self.AccentColor or Color3.fromRGB(80, 80, 80)
        }, 0.2)
        
        Tween(toggleKnob, {
            Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }, 0.2)
        
        if callback then callback(toggled) end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
    end)
    
    -- Make it easier to tap on mobile
    if IsMobile() then
        local hitbox = Create("TextButton", {
            Parent = toggle,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 5
        })
        
        hitbox.MouseButton1Click:Connect(function()
            toggled = not toggled
            updateToggle()
        end)
    end
    
    updateToggle()
    
    return {
        Set = function(value)
            toggled = value
            updateToggle()
        end,
        Get = function()
            return toggled
        end
    }
end

function BoostUI:Slider(text, min, max, default, callback, parent)
    local value = default or min
    local dragging = false
    
    local slider = Create("Frame", {
        Name = text .. "Slider",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = #parent:GetChildren()
    })
    
    local sliderLabel = Create("TextLabel", {
        Name = "SliderLabel",
        Parent = slider,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    local sliderValue = Create("TextLabel", {
        Name = "SliderValue",
        Parent = slider,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    local sliderTrack = Create("Frame", {
        Name = "SliderTrack",
        Parent = slider,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(80, 80, 80),
        BorderSizePixel = 0
    })
    
    local trackCorner = Create("UICorner", {
        Parent = sliderTrack,
        CornerRadius = UDim.new(0, 3)
    })
    
    local sliderFill = Create("Frame", {
        Name = "SliderFill",
        Parent = sliderTrack,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    
    local fillCorner = Create("UICorner", {
        Parent = sliderFill,
        CornerRadius = UDim.new(0, 3)
    })
    
    local sliderButton = Create("TextButton", {
        Name = "SliderButton",
        Parent = sliderTrack,
        Size = UDim2.new(0, IsMobile() and 24 or 16, 0, IsMobile() and 24 or 16),
        Position = UDim2.new((value - min) / (max - min), IsMobile() and -12 or -8, 0.5, IsMobile() and -12 or -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 3
    })
    
    local buttonCorner = Create("UICorner", {
        Parent = sliderButton,
        CornerRadius = UDim.new(0, 8)
    })
    
    local function updateSlider(input)
        if not dragging then return end
        
        local relativeX = (input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        value = Round(min + (max - min) * relativeX, 2)
        sliderValue.Text = tostring(value)
        
        Tween(sliderFill, {
            Size = UDim2.new(relativeX, 0, 1, 0)
        }, 0.05)
        
        Tween(sliderButton, {
            Position = UDim2.new(relativeX, IsMobile() and -12 or -8, 0.5, IsMobile() and -12 or -8)
        }, 0.05)
        
        if callback then callback(value) end
    end
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    return {
        Set = function(newValue)
            value = math.clamp(newValue, min, max)
            sliderValue.Text = tostring(value)
            
            local relativeX = (value - min) / (max - min)
            Tween(sliderFill, {
                Size = UDim2.new(relativeX, 0, 1, 0)
            }, 0.2)
            
            Tween(sliderButton, {
                Position = UDim2.new(relativeX, IsMobile() and -12 or -8, 0.5, IsMobile() and -12 or -8)
            }, 0.2)
            
            if callback then callback(value) end
        end,
        Get = function()
            return value
        end
    }
end

function BoostUI:Dropdown(text, options, callback, parent)
    local open = false
    local selected = options[1] or "Select..."
    
    local dropdown = Create("Frame", {
        Name = text .. "Dropdown",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        LayoutOrder = #parent:GetChildren()
    })
    
    local dropdownLabel = Create("TextLabel", {
        Name = "DropdownLabel",
        Parent = dropdown,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    local dropdownButton = Create("TextButton", {
        Name = "DropdownButton",
        Parent = dropdown,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(220, 220, 220),
        BorderSizePixel = 0,
        Text = selected,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    local dropdownCorner = Create("UICorner", {
        Parent = dropdownButton,
        CornerRadius = UDim.new(0, 6)
    })
    
    local dropdownArrow = Create("ImageLabel", {
        Name = "DropdownArrow",
        Parent = dropdownButton,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709790937",
        ImageColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        Rotation = 0
    })
    
    local dropdownOptions = Create("ScrollingFrame", {
        Name = "DropdownOptions",
        Parent = dropdown,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(230, 230, 230),
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    })
    
    local optionsLayout = Create("UIListLayout", {
        Parent = dropdownOptions,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local optionsCorner = Create("UICorner", {
        Parent = dropdownOptions,
        CornerRadius = UDim.new(0, 6)
    })
    
    local function toggleDropdown()
        open = not open
        
        if open then
            Tween(dropdown, {
                Size = UDim2.new(1, 0, 0, 50 + math.min(#options * 30, 150))
            }, 0.2)
            
            Tween(dropdownOptions, {
                Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))
            }, 0.2)
            
            Tween(dropdownArrow, {
                Rotation = 180
            }, 0.2)
            
            dropdownOptions.Visible = true
        else
            Tween(dropdown, {
                Size = UDim2.new(1, 0, 0, 50)
            }, 0.2)
            
            Tween(dropdownOptions, {
                Size = UDim2.new(1, 0, 0, 0)
            }, 0.2)
            
            Tween(dropdownArrow, {
                Rotation = 0
            }, 0.2)
            
            delay(0.2, function()
                dropdownOptions.Visible = false
            end)
        end
    end
    
    local function selectOption(option)
        selected = option
        dropdownButton.Text = option
        toggleDropdown()
        
        if callback then callback(option) end
    end
    
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = Create("TextButton", {
            Name = option .. "Option",
            Parent = dropdownOptions,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(230, 230, 230),
            BorderSizePixel = 0,
            Text = option,
            TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AutoButtonColor = false,
            LayoutOrder = i
        })
        
        optionButton.MouseButton1Click:Connect(function()
            selectOption(option)
        end)
        
        -- Hover effect
        if not IsMobile() then
            optionButton.MouseEnter:Connect(function()
                Tween(optionButton, {
                    BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(210, 210, 210)
                }, 0.2)
            end)
            
            optionButton.MouseLeave:Connect(function()
                Tween(optionButton, {
                    BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(230, 230, 230)
                }, 0.2)
            end)
        end
    end
    
    -- Update canvas size
    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropdownOptions.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y)
    end)
    
    return {
        Set = function(option)
            if table.find(options, option) then
                selectOption(option)
            end
        end,
        Get = function()
            return selected
        end
    }
end

function BoostUI:Textbox(text, placeholder, callback, parent)
    local textbox = Create("Frame", {
        Name = text .. "Textbox",
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = #parent:GetChildren()
    })
    
    local textboxLabel = Create("TextLabel", {
        Name = "TextboxLabel",
        Parent = textbox,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
    
    local inputBox = Create("TextBox", {
        Name = "InputBox",
        Parent = textbox,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = self.Theme == "Dark" and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(220, 220, 220),
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder or "Type here...",
        TextColor3 = self.Theme == "Dark" and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(80, 80, 80),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        ClearTextOnFocus = false
    })
    
    local inputCorner = Create("UICorner", {
        Parent = inputBox,
        CornerRadius = UDim.new(0, 6)
    })
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(inputBox.Text)
        end
    end)
    
    return {
        Set = function(value)
            inputBox.Text = tostring(value)
            if callback then callback(value) end
        end,
        Get = function()
            return inputBox.Text
        end
    }
end

-- Make library globally accessible
getgenv().BoostUI = BoostUI

return BoostUI
