--[[
    Boost UI (Updated)
    -> Refactored to be a self-contained library with mobile support.
]]

if getgenv().Loaded then
    getgenv().Library:Unload()
end

getgenv().Loaded = true

-- Services
local InputService, HttpService, GuiService, RunService, TweenService, CoreGui, Players = game:GetService("UserInputService"), game:GetService("HttpService"), game:GetService("GuiService"), game:GetService("RunService"), game:GetService("TweenService"), game:GetService("CoreGui"), game:GetService("Players")
local lp, gui_offset = Players.LocalPlayer, GuiService:GetGuiInset().Y
local mouse = lp:GetMouse()
local vec2, dim2, dim = Vector2.new, UDim2.new, UDim.new
local color, rgb, hex, hsv = Color3.new, Color3.fromRGB, Color3.fromHex, Color3.fromHSV
local insert = table.insert
local wait = task.wait

-- Library init
getgenv().Library = {
    Directory = "Boost",
    Flags = {},
    ConfigFlags = {},
    Connections = {},
    OpenElement = {},
    EasingStyle = Enum.EasingStyle.Quad,
    TweeningSpeed = 0.2
}

local themes = {
    preset = {
        accent = rgb(183, 250, 142),
    },
    utility = {},
    gradients = {
        Selected = {},
        Deselected = {},
    },
}

for theme, color in themes.preset do
    themes.utility[theme] = {
        BackgroundColor3 = {},
        TextColor3 = {},
        ImageColor3 = {},
        ScrollBarImageColor3 = {},
        Color = {},
    }
end

Library.__index = Library

-- Library functions
-- Misc functions
function Library:Tween(Object, Properties, Info)
    local tween = TweenService:Create(Object, Info or TweenInfo.new(Library.TweeningSpeed, Library.EasingStyle, Enum.EasingDirection.Out, 0, false, 0), Properties)
    tween:Play()
    return tween
end

function Library:Fade(obj, prop, vis, speed)
    if not (obj and prop) then
        return
    end

    local OldTransparency = obj[prop]
    obj[prop] = vis and 1 or OldTransparency

    local Tween = Library:Tween(obj, { [prop] = vis and OldTransparency or 1 }, TweenInfo.new(speed or Library.TweeningSpeed, Library.EasingStyle, Enum.EasingDirection.InOut, 0, false, 0))

    Library:Connection(Tween.Completed, function()
        if not vis then
            wait()
            obj[prop] = OldTransparency
        end
    end)

    return Tween
end

function Library:Hovering(Object)
    if typeof(Object) == "table" then
        local Pass = false
        for _, obj in Object do
            if Library:Hovering(obj) then
                Pass = true
                return Pass
            end
        end
    else
        local y_cond = Object.AbsolutePosition.Y <= mouse.Y and mouse.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
        local x_cond = Object.AbsolutePosition.X <= mouse.X and mouse.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X
        return (y_cond and x_cond)
    end
end

function Library:Draggify(Parent)
    local Dragging = false
    local InitialPosition
    local StartPos

    Parent.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            InitialPosition = Input.Position
            StartPos = Parent.Position
            InputService.MouseIconEnabled = false
        end
    end)

    Parent.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            InputService.MouseIconEnabled = true
        end
    end)

    Library:Connection(InputService.InputChanged, function(Input, game_event)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local newPos = StartPos.X.Offset + (Input.Position.X - InitialPosition.X)
            local newY = StartPos.Y.Offset + (Input.Position.Y - InitialPosition.Y)

            local clampedX = math.clamp(newPos, 0, game.Workspace.CurrentCamera.ViewportSize.X - Parent.AbsoluteSize.X)
            local clampedY = math.clamp(newY, gui_offset, game.Workspace.CurrentCamera.ViewportSize.Y - Parent.AbsoluteSize.Y)

            Library:Tween(Parent, { Position = dim2(0, clampedX, 0, clampedY) }, TweenInfo.new(0.05, Enum.EasingStyle.Linear))
        end
    end)
end

function Library:Themify(instance, theme, property)
    table.insert(themes.utility[theme][property], instance)
end

function Library:RefreshTheme(theme, color)
    for property, instances in themes.utility[theme] do
        for _, object in instances do
            if object[property] == themes.preset[theme] then
                object[property] = color
            end
        end
    end
    themes.preset[theme] = color
end

function Library:Connection(signal, callback)
    local connection = signal:Connect(callback)
    insert(Library.Connections, connection)
    return connection
end

function Library:CloseElement()
    if not Library.OpenElement then
        return
    end

    for _, Data in Library.OpenElement do
        Data.SetVisible(false)
        Data.Open = false
    end

    Library.OpenElement = {}
end

function Library:Create(instance, options)
    local ins = Instance.new(instance)

    for prop, value in options do
        ins[prop] = value
    end

    if ins.IsA("TextButton") then
        ins.AutoButtonColor = false
        ins.Text = ""
    end

    return ins
end

function Library:Unload()
    if Library.Items then
        Library.Items:Destroy()
    end

    if Library.Other then
        Library.Other:Destroy()
    end

    for _, connection in Library.Connections do
        connection:Disconnect()
        connection = nil
    end

    getgenv().Library = nil
end

-- Library element functions
function Library:Window(properties)
    local Cfg = {
        Name = properties.Name or "Nebula";
        Items = {};
        Tabs = {};
    }

    Library.Items = Library:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "BoostUI",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    Library.Other = Library:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "BoostUI_Others",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    local Items = Cfg.Items;
    do
        -- Window
        Items.Window = Library:Create("Frame", {
            Parent = Library.Items,
            Name = "Window",
            Size = dim2(0, 450, 0, 350),
            Position = dim2(0.5, -225, 0.5, -175),
            BackgroundColor3 = rgb(15, 15, 15),
            BorderSizePixel = 0,
        })
        Items.Window.Position = dim2(0, Items.Window.AbsolutePosition.X, 0, Items.Window.AbsolutePosition.Y)
        Library:Draggify(Items.Window)

        Library:Create("UICorner", {
            Parent = Items.Window,
            CornerRadius = dim(0, 4)
        })

        Library:Create("UIStroke", {
            Color = rgb(38, 38, 38),
            Parent = Items.Window
        })

        -- Top Bar
        Items.TitleBar = Library:Create("Frame", {
            Parent = Items.Window,
            Size = dim2(1, 0, 0, 20),
            BackgroundColor3 = rgb(20, 20, 20),
            BorderSizePixel = 0,
        })

        Items.TitleLabel = Library:Create("TextLabel", {
            Parent = Items.TitleBar,
            Text = Cfg.Name,
            TextColor3 = rgb(255, 255, 255),
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = dim2(0, 5, 0.5, 0),
            AnchorPoint = vec2(0, 0.5),
            BackgroundTransparency = 1,
        })
        
        -- Text corners
        Items.LeftCornerText = Library:Create("TextLabel", {
            Parent = Items.Window,
            Text = "Left Corner",
            Size = dim2(0, 100, 0, 20),
            Position = dim2(0, 5, 1, -25),
            TextColor3 = rgb(100, 100, 100),
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
        })

        Items.RightCornerText = Library:Create("TextLabel", {
            Parent = Items.Window,
            Text = "Right Corner",
            Size = dim2(0, 100, 0, 20),
            Position = dim2(1, -105, 1, -25),
            TextColor3 = rgb(100, 100, 100),
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            BackgroundTransparency = 1,
        })

        -- Tab container
        Items.TabContainer = Library:Create("Frame", {
            Parent = Items.Window,
            Position = dim2(0, 0, 0, 20),
            Size = dim2(1, 0, 0, 30),
            BackgroundColor3 = rgb(25, 25, 25),
            BorderSizePixel = 0,
        })
        
        Library:Create("UIListLayout", {
            Parent = Items.TabContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = dim(0, 2),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        -- Main content frame
        Items.Content = Library:Create("Frame", {
            Parent = Items.Window,
            Position = dim2(0, 0, 0, 50),
            Size = dim2(1, 0, 1, -50),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })

        Items.Layout = Library:Create("UIListLayout", {
            Parent = Items.Content,
            Padding = dim(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        Library:Create("UIPadding", {
            Parent = Items.Content,
            PaddingLeft = dim(0, 8),
            PaddingRight = dim(0, 8),
            PaddingTop = dim(0, 8),
            PaddingBottom = dim(0, 8),
        })
    end

    function Cfg:SetLeftCornerText(text)
        Items.LeftCornerText.Text = text
    end

    function Cfg:SetRightCornerText(text)
        Items.RightCornerText.Text = text
    end

    function Cfg:Section(name)
        local SectionCfg = {
            Name = name,
            Items = {},
        }
        local section = Library:Create("Frame", {
            Parent = Items.Content,
            Name = "Section_" .. name,
            Size = dim2(1, 0, 0, 30),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        
        local label = Library:Create("TextLabel", {
            Parent = section,
            Text = name,
            TextColor3 = rgb(255, 255, 255),
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextScaled = true,
            Size = dim2(1, 0, 1, 0),
            BackgroundTransparency = 1,
        })

        local listLayout = Library:Create("UIListLayout", {
            Parent = section,
            Padding = dim(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        section.Changed:Connect(function(prop)
            if prop == "AbsoluteSize" then
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
                section.Size = dim2(1, 0, 0, listLayout.AbsoluteContentSize.Y)
            end
        end)

        function SectionCfg:Label(text)
            local label = Library:Create("TextLabel", {
                Parent = section,
                Text = text,
                TextColor3 = rgb(180, 180, 180),
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextScaled = true,
                Size = dim2(1, 0, 0, 20),
                BackgroundTransparency = 1,
                LayoutOrder = #section:GetChildren(),
            })
            insert(SectionCfg.Items, label)
            return label
        end

        function SectionCfg:Button(text, callback)
            local button = Library:Create("TextButton", {
                Parent = section,
                Text = text,
                TextColor3 = rgb(255, 255, 255),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextScaled = true,
                Size = dim2(1, 0, 0, 30),
                BackgroundColor3 = rgb(25, 25, 25),
                BorderSizePixel = 0,
                LayoutOrder = #section:GetChildren(),
            })
            Library:Create("UICorner", {Parent = button, CornerRadius = dim(0, 4)})
            button.MouseButton1Click:Connect(function()
                callback()
            end)
            insert(SectionCfg.Items, button)
            return button
        end

        function SectionCfg:Toggle(text, properties, callback)
            local Cfg = {
                Name = properties.Name or "Toggle",
                Flag = properties.Flag or text,
                Enabled = properties.Enabled or false,
                Callback = callback or function() end,
                Items = {},
            }

            Flags[Cfg.Flag] = Cfg.Enabled

            local toggle = Library:Create("TextButton", {
                Parent = section,
                Text = text,
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextScaled = true,
                Size = dim2(1, 0, 0, 30),
                BackgroundColor3 = rgb(25, 25, 25),
                BorderSizePixel = 0,
                LayoutOrder = #section:GetChildren(),
            })

            local box = Library:Create("Frame", {
                Parent = toggle,
                Size = dim2(0, 20, 0, 20),
                AnchorPoint = vec2(1, 0.5),
                Position = dim2(1, -5, 0.5, 0),
                BackgroundColor3 = Cfg.Enabled and themes.preset.accent or rgb(50, 50, 50),
                BorderSizePixel = 0,
            })
            Library:Create("UICorner", { Parent = box, CornerRadius = dim(0, 4)})

            function Cfg.Update(bool)
                Cfg.Enabled = bool
                Flags[Cfg.Flag] = Cfg.Enabled
                Library:Tween(box, {BackgroundColor3 = Cfg.Enabled and themes.preset.accent or rgb(50, 50, 50)})
                Cfg.Callback(Cfg.Enabled)
            end

            toggle.MouseButton1Click:Connect(function()
                Cfg.Update(not Cfg.Enabled)
            end)

            ConfigFlags[Cfg.Flag] = Cfg.Update
            insert(SectionCfg.Items, toggle)
            return Cfg
        end

        function SectionCfg:Slider(text, properties, callback)
            local Cfg = {
                Name = properties.Name or "Slider",
                Flag = properties.Flag or text,
                Value = properties.Value or 0,
                Min = properties.Min or 0,
                Max = properties.Max or 1,
                Prec = properties.Prec or 1,
                Callback = callback or function() end,
                Items = {},
            }
            
            Flags[Cfg.Flag] = Cfg.Value

            local sliderFrame = Library:Create("Frame", {
                Parent = section,
                Size = dim2(1, 0, 0, 40),
                BackgroundTransparency = 1,
                LayoutOrder = #section:GetChildren(),
            })

            local sliderLabel = Library:Create("TextLabel", {
                Parent = sliderFrame,
                Text = string.format("%s: %s", text, Library:Round(Cfg.Value, Cfg.Prec)),
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextScaled = true,
                Size = dim2(1, 0, 0, 20),
                BackgroundTransparency = 1,
            })

            local slider = Library:Create("Frame", {
                Parent = sliderFrame,
                Size = dim2(1, 0, 0, 5),
                Position = dim2(0, 0, 0, 25),
                BackgroundColor3 = rgb(25, 25, 25),
                BorderSizePixel = 0,
            })
            Library:Create("UICorner", {Parent = slider, CornerRadius = dim(0, 4)})

            local filler = Library:Create("Frame", {
                Parent = slider,
                Size = dim2(0, 0, 1, 0),
                BackgroundColor3 = themes.preset.accent,
                BorderSizePixel = 0,
            })
            Library:Create("UICorner", {Parent = filler, CornerRadius = dim(0, 4)})

            local isDragging = false
            local function updateSlider(input)
                local pos = input.Position.X - slider.AbsolutePosition.X
                local percentage = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                local newValue = Cfg.Min + percentage * (Cfg.Max - Cfg.Min)
                Cfg.Value = newValue
                Flags[Cfg.Flag] = Cfg.Value
                sliderLabel.Text = string.format("%s: %s", text, Library:Round(Cfg.Value, Cfg.Prec))
                filler.Size = dim2(percentage, 0, 1, 0)
                Cfg.Callback(Cfg.Value)
            end

            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    updateSlider(input)
                end
            end)
            
            slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            Library:Connection(InputService.InputChanged, function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            
            function Cfg.Update(value)
                Cfg.Value = math.clamp(value, Cfg.Min, Cfg.Max)
                local percentage = (Cfg.Value - Cfg.Min) / (Cfg.Max - Cfg.Min)
                sliderLabel.Text = string.format("%s: %s", text, Library:Round(Cfg.Value, Cfg.Prec))
                Library:Tween(filler, {Size = dim2(percentage, 0, 1, 0)})
                Flags[Cfg.Flag] = Cfg.Value
            end

            ConfigFlags[Cfg.Flag] = Cfg.Update
            insert(SectionCfg.Items, sliderFrame)
            return Cfg
        end

        function SectionCfg:Dropdown(text, properties, callback)
            local Cfg = {
                Name = properties.Name or "Dropdown",
                Flag = properties.Flag or text,
                Open = false,
                Options = properties.Options or {},
                Value = properties.Value or properties.Options[1] or "N/A",
                Callback = callback or function() end,
                Items = {},
            }
            
            Flags[Cfg.Flag] = Cfg.Value
            
            local dropdownFrame = Library:Create("Frame", {
                Parent = section,
                Size = dim2(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = #section:GetChildren(),
            })

            local button = Library:Create("TextButton", {
                Parent = dropdownFrame,
                Text = Cfg.Value,
                TextColor3 = rgb(255, 255, 255),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextScaled = true,
                Size = dim2(1, 0, 1, 0),
                BackgroundColor3 = rgb(25, 25, 25),
                BorderSizePixel = 0,
            })
            Library:Create("UICorner", {Parent = button, CornerRadius = dim(0, 4)})

            local optionsFrame = Library:Create("Frame", {
                Parent = Library.Other,
                Size = dim2(0, 150, 0, 0),
                BackgroundTransparency = 1,
                Visible = false,
                ZIndex = 3,
            })
            
            local optionsList = Library:Create("Frame", {
                Parent = optionsFrame,
                Size = dim2(1, 0, 1, 0),
                BackgroundColor3 = rgb(25, 25, 25),
                BorderSizePixel = 0,
            })
            Library:Create("UICorner", {Parent = optionsList, CornerRadius = dim(0, 4)})
            
            local listLayout = Library:Create("UIListLayout", {
                Parent = optionsList,
                Padding = dim(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            
            function Cfg.SetVisible(bool)
                Cfg.Open = bool
                optionsFrame.Visible = bool
                if bool then
                    Library:CloseElement()
                    insert(Library.OpenElement, Cfg)
                    local absPos = button.AbsolutePosition
                    optionsFrame.Position = dim2(0, absPos.X, 0, absPos.Y + button.AbsoluteSize.Y + 5)
                end
            end

            for _, opt in Cfg.Options do
                local optionButton = Library:Create("TextButton", {
                    Parent = optionsList,
                    Text = opt,
                    TextColor3 = rgb(255, 255, 255),
                    Font = Enum.Font.SourceSans,
                    TextSize = 14,
                    TextScaled = true,
                    Size = dim2(1, 0, 0, 25),
                    BackgroundColor3 = rgb(30, 30, 30),
                    BorderSizePixel = 0,
                })
                Library:Create("UICorner", {Parent = optionButton, CornerRadius = dim(0, 4)})

                optionButton.MouseButton1Click:Connect(function()
                    Cfg.Value = opt
                    button.Text = opt
                    Flags[Cfg.Flag] = Cfg.Value
                    Cfg.Callback(Cfg.Value)
                    Cfg.SetVisible(false)
                end)
            end
            
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
            optionsFrame.Size = dim2(0, 150, 0, listLayout.AbsoluteContentSize.Y)

            button.MouseButton1Click:Connect(function()
                Cfg.SetVisible(not Cfg.Open)
            end)

            ConfigFlags[Cfg.Flag] = function(value)
                Cfg.Value = value
                button.Text = value
                Flags[Cfg.Flag] = value
            end
            
            return Cfg
        end

        function SectionCfg:TextBox(text, properties, callback)
            local Cfg = {
                Name = properties.Name or "TextBox",
                Flag = properties.Flag or text,
                Value = properties.Value or "",
                Placeholder = properties.Placeholder or "",
                Callback = callback or function() end,
                Items = {},
            }
            
            Flags[Cfg.Flag] = Cfg.Value

            local textFrame = Library:Create("Frame", {
                Parent = section,
                Size = dim2(1, 0, 0, 40),
                BackgroundTransparency = 1,
                LayoutOrder = #section:GetChildren(),
            })

            local label = Library:Create("TextLabel", {
                Parent = textFrame,
                Text = text,
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextScaled = true,
                Size = dim2(1, 0, 0, 15),
                BackgroundTransparency = 1,
            })
            
            local textbox = Library:Create("TextBox", {
                Parent = textFrame,
                Text = Cfg.Value,
                PlaceholderText = Cfg.Placeholder,
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextScaled = true,
                Size = dim2(1, 0, 0, 25),
                Position = dim2(0, 0, 0, 15),
                BackgroundColor3 = rgb(25, 25, 25),
                BorderSizePixel = 0,
            })
            Library:Create("UICorner", {Parent = textbox, CornerRadius = dim(0, 4)})

            textbox.FocusLost:Connect(function(enter)
                if enter then
                    Cfg.Value = textbox.Text
                    Flags[Cfg.Flag] = Cfg.Value
                    Cfg.Callback(Cfg.Value)
                end
            end)

            ConfigFlags[Cfg.Flag] = function(value)
                Cfg.Value = value
                textbox.Text = value
                Flags[Cfg.Flag] = value
            end

            return Cfg
        end

        insert(Cfg.Items, SectionCfg)
        return SectionCfg
    end

    function Cfg:Tab(name)
        local tabButton = Library:Create("TextButton", {
            Parent = Items.TabContainer,
            Text = name,
            TextColor3 = rgb(255, 255, 255),
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextScaled = true,
            Size = dim2(0, 70, 0, 25),
            BackgroundColor3 = rgb(30, 30, 30),
            BorderSizePixel = 0,
            LayoutOrder = #Items.TabContainer:GetChildren(),
        })
        Library:Create("UICorner", {Parent = tabButton, CornerRadius = dim(0, 4)})

        local tabContent = Library:Create("Frame", {
            Parent = Items.Content,
            Name = "TabContent_" .. name,
            Size = dim2(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        local listLayout = Library:Create("UIListLayout", {
            Parent = tabContent,
            Padding = dim(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        })
        
        local TabCfg = {
            Name = name,
            Items = {},
            Content = tabContent,
            Section = function(self, sectionName)
                local section = self.Content.Parent.Parent:Section(sectionName)
                section.Parent = self.Content
                return section
            end
        }
        
        tabButton.MouseButton1Click:Connect(function()
            for _,tab in Cfg.Tabs do
                tab.Content.Visible = false
            end
            tabContent.Visible = true
        end)
        
        insert(Cfg.Tabs, TabCfg)
        
        -- Show first tab by default
        if #Cfg.Tabs == 1 then
            tabContent.Visible = true
        end

        return TabCfg
    end

    function Cfg:LoadConfig(cfgName)
        local json = readfile(Library.Directory .. "/configs/" .. cfgName .. ".cfg")
        Library:LoadConfig(json)
    end
    
    Cfg.Show = function()
        Library:Tween(Items.Window, {Position = dim2(0.5, -Items.Window.AbsoluteSize.X / 2, 0.5, -Items.Window.AbsoluteSize.Y / 2)})
        Items.Window.Visible = true
    end

    Cfg.Hide = function()
        Items.Window.Visible = false
    end

    return Cfg
end

-- Load string and GitHub docs
-- To make this a library loadable via loadstring, you would host this code on a raw GitHub URL.
-- A user would then use `loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()` to execute it.
-- The documentation would be a separate GitHub page explaining the API.

-- Example of how a user would use the library:
-- local UI = Library:Window({Name = "My UI"})
-- local tab1 = UI:Tab("Main")
-- local section1 = tab1:Section("Settings")
-- section1:Toggle("Aimbot", {Enabled = false}, function(state)
--     print("Aimbot is now:", state)
-- end)
-- UI:Show()

return Library
