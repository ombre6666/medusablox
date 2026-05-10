-- Clean generic Roblox GUI library
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function protectGui(gui)
    local hidden = get_hidden_gui or gethui
    if hidden then
        pcall(function()
            gui.Parent = hidden()
        end)
    elseif syn and syn.protect_gui then
        pcall(function()
            syn.protect_gui(gui)
        end)
        gui.Parent = CoreGui
    else
        gui.Parent = CoreGui
    end
end

local function makeDraggable(topBar, frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPos}):Play()
    end

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local Library = {}

local function applyProperties(instance, props)
    for property, value in pairs(props or {}) do
        instance[property] = value
    end
    return instance
end

local function createInstance(className, parent, props)
    local instance = Instance.new(className)
    applyProperties(instance, props)
    instance.Parent = parent
    return instance
end

function Library:CreateWindow(title, keybind)
    local window = {}
    local hidden = false
    local key = keybind or Enum.KeyCode.RightControl
    local tabCount = 0

    local screenGui = createInstance("ScreenGui", nil, {
        Name = title or "SimpleGUI",
        ResetOnSpawn = false
    })
    protectGui(screenGui)

    local mainFrame = createInstance("Frame", screenGui, {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0.5, 0, 0),
        Size = UDim2.new(0, 540, 0, 340),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    createInstance("UICorner", mainFrame, {CornerRadius = UDim.new(0, 12)})

    local topBar = createInstance("Frame", mainFrame, {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0
    })
    createInstance("UICorner", topBar, {CornerRadius = UDim.new(0, 12)})

    createInstance("TextLabel", topBar, {
        Name = "TitleLabel",
        Size = UDim2.new(0.8, -20, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = title or "Menu",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local tabContainer = createInstance("Frame", mainFrame, {
        Name = "TabContainer",
        Position = UDim2.new(0, 8, 0, 40),
        Size = UDim2.new(0, 128, 0, 288),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    local scrollTab = createInstance("ScrollingFrame", tabContainer, {
        Name = "Tabs",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(0, 255, 0)
    })

    createInstance("UIListLayout", scrollTab, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    local contentFrame = createInstance("Frame", mainFrame, {
        Name = "ContentFrame",
        Position = UDim2.new(0, 144, 0, 40),
        Size = UDim2.new(0, 388, 0, 288),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    local pageFolder = createInstance("Folder", contentFrame, {Name = "PageFolder"})
    local pageLayout = createInstance("UIPageLayout", pageFolder, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 10),
        TweenTime = 0.3,
        GamepadInputEnabled = false,
        ScrollWheelInputEnabled = false,
        TouchInputEnabled = false
    })

    makeDraggable(topBar, mainFrame)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == key then
            hidden = not hidden
            if hidden then
                mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.25, true)
            else
                mainFrame:TweenSize(UDim2.new(0, 540, 0, 340), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
            end
        end
    end)

    local tabs = {}

    function window:AddTab(tabName)
        local button = createInstance("TextButton", scrollTab, {
            Name = tabName .. "Button",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Font = Enum.Font.GothamSemibold,
            Text = tostring(tabName),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14
        })
        createInstance("UICorner", button, {CornerRadius = UDim.new(0, 6)})

        local page = createInstance("ScrollingFrame", pageFolder, {
            Name = tabName .. "Page",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 6
        })

        createInstance("UIListLayout", page, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        createInstance("UIPadding", page, {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })

        button.MouseButton1Click:Connect(function()
            pageLayout:JumpTo(page)
        end)

        tabCount = tabCount + 1
        if tabCount == 1 then
            pageLayout:JumpTo(page)
        end

        tabs[tabName] = page
        return page
    end

    function window:AddButton(page, text, callback)
        local button = createInstance("TextButton", page, {
            Name = text .. "Button",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            AutoButtonColor = true,
            Font = Enum.Font.GothamSemibold,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14
        })
        createInstance("UICorner", button, {CornerRadius = UDim.new(0, 6)})
        button.MouseButton1Click:Connect(function()
            if type(callback) == "function" then
                callback()
            end
        end)
        return button
    end

    function window:AddToggle(page, text, default, callback)
        local toggled = default == true
        local frame = createInstance("TextButton", page, {
            Name = text .. "Toggle",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = ""
        })
        createInstance("UICorner", frame, {CornerRadius = UDim.new(0, 6)})

        createInstance("TextLabel", frame, {
            Name = "ToggleLabel",
            Size = UDim2.new(0.75, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local indicator = createInstance("Frame", frame, {
            Name = "ToggleIndicator",
            Size = UDim2.new(0, 40, 0, 18),
            Position = UDim2.new(1, -50, 0.5, -9),
            BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(170, 0, 0),
            BorderSizePixel = 0
        })
        createInstance("UICorner", indicator, {CornerRadius = UDim.new(0, 9)})

        local indicatorLabel = createInstance("TextLabel", indicator, {
            Name = "ToggleState",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = toggled and "ON" or "OFF",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12
        })

        frame.MouseButton1Click:Connect(function()
            toggled = not toggled
            indicator.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(170, 0, 0)
            indicatorLabel.Text = toggled and "ON" or "OFF"
            if type(callback) == "function" then
                callback(toggled)
            end
        end)
        return frame
    end

    function window:AddDropdown(page, text, options, callback)
        local active = false
        local dropdown = createInstance("TextButton", page, {
            Name = text .. "Dropdown",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Active = true
        })
        createInstance("UICorner", dropdown, {CornerRadius = UDim.new(0, 6)})

        local label = createInstance("TextLabel", dropdown, {
            Name = "DropdownLabel",
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local arrow = createInstance("TextLabel", dropdown, {
            Name = "DropdownArrow",
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -32, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "▼",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14
        })

        local listFrame = createInstance("Frame", dropdown, {
            Name = "OptionList",
            Position = UDim2.new(0, 0, 1, 4),
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            ClipsDescendants = true
        })
        createInstance("UICorner", listFrame, {CornerRadius = UDim.new(0, 6)})

        local listLayout = createInstance("UIListLayout", listFrame, {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
        })
        createInstance("UIPadding", listFrame, {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8)
        })

        for _, option in ipairs(options or {}) do
            local item = createInstance("TextButton", listFrame, {
                Name = tostring(option) .. "Option",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BorderSizePixel = 0,
                AutoButtonColor = true,
                Font = Enum.Font.GothamSemibold,
                Text = tostring(option),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14
            })
            createInstance("UICorner", item, {CornerRadius = UDim.new(0, 6)})
            item.MouseButton1Click:Connect(function()
                label.Text = text .. ": " .. tostring(option)
                if type(callback) == "function" then
                    callback(option)
                end
                active = false
                listFrame:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true)
                arrow.Text = "▼"
            end)
        end

        local contentHeight = listLayout.AbsoluteContentSize.Y + 16
        dropdown.MouseButton1Click:Connect(function()
            active = not active
            arrow.Text = active and "▲" or "▼"
            local targetSize = active and UDim2.new(1, 0, 0, math.min(contentHeight, 150)) or UDim2.new(1, 0, 0, 0)
            listFrame:TweenSize(targetSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end)

        return dropdown
    end

    function window:AddLabel(page, text)
        return createInstance("TextLabel", page, {
            Name = text .. "Label",
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    function window:AddTextbox(page, text, callback)
        local container = createInstance("Frame", page, {
            Name = text .. "Textbox",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0
        })
        createInstance("UICorner", container, {CornerRadius = UDim.new(0, 6)})

        createInstance("TextLabel", container, {
            Name = "TextboxLabel",
            Size = UDim2.new(0.4, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local inputBox = createInstance("TextBox", container, {
            Name = "Input",
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            Size = UDim2.new(0.55, -14, 0, 26),
            Position = UDim2.new(0.45, 0, 0.5, -13),
            Font = Enum.Font.Gotham,
            Text = "",
            PlaceholderText = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            ClearTextOnFocus = false
        })
        createInstance("UICorner", inputBox, {CornerRadius = UDim.new(0, 6)})

        inputBox.FocusLost:Connect(function(enter)
            if type(callback) == "function" then
                callback(inputBox.Text, enter)
            end
        end)

        return inputBox
    end

    function window:AddSlider(page, text, min, max, start, callback)
        min = min or 0
        max = max or 100
        start = math.clamp(start or min, min, max)

        local frame = createInstance("Frame", page, {
            Name = text .. "Slider",
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0
        })
        createInstance("UICorner", frame, {CornerRadius = UDim.new(0, 6)})

        local label = createInstance("TextLabel", frame, {
            Name = "SliderLabel",
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 10, 0, 6),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = text .. ": " .. tostring(start),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local bar = createInstance("Frame", frame, {
            Name = "SliderBar",
            Position = UDim2.new(0, 10, 0, 28),
            Size = UDim2.new(1, -20, 0, 10),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BorderSizePixel = 0
        })
        createInstance("UICorner", bar, {CornerRadius = UDim.new(0, 5)})

        local handle = createInstance("Frame", bar, {
            Name = "SliderHandle",
            Size = UDim2.new((start - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 255, 0),
            BorderSizePixel = 0
        })
        createInstance("UICorner", handle, {CornerRadius = UDim.new(0, 5)})

        local dragging = false
        local function update(input)
            local relative = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relative)
            handle.Size = UDim2.new(relative, 0, 1, 0)
            label.Text = text .. ": " .. tostring(value)
            if type(callback) == "function" then
                callback(value)
            end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)

        return frame
    end

    function window:AddNotification(text, duration)
        duration = duration or 4
        local notif = createInstance("Frame", screenGui, {
            Name = "Notification",
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 0.95, 0),
            Size = UDim2.new(0, 260, 0, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BorderSizePixel = 0,
            ClipsDescendants = true
        })
        createInstance("UICorner", notif, {CornerRadius = UDim.new(0, 10)})

        createInstance("TextLabel", notif, {
            Name = "Text",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })

        notif:TweenSize(UDim2.new(0, 260, 0, 80), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        task.delay(duration, function()
            notif:TweenSize(UDim2.new(0, 260, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true)
            task.wait(0.25)
            notif:Destroy()
        end)
    end

    function window:GetGui()
        return screenGui
    end

    return window
end

return Library
