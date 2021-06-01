--[[

		TOOLTIP MODULE
			 by: 0V_ex

	Functions:
		Tooltip(<Your UI Object> [Instance], <Tooltip Text> [String])
		 - Creates a new tooltip
		 - Object parameter is required
		 - Text parameter is optional. If not passed, defaults to "Tooltip"
		 - Returns object: tooltip

		object tooltip functions:
			tooltip:Show()
			 - Makes the tooltip visible
			 - Returns object: tooltip

			tooltip:Hide()
			 - Gets the tooltip out of view
			 - Returns object: tooltip

			tooltip:SetText(<Your Text> [String])
			 - Changes the tooltip text
			 - Text parameter is required
			 - Returns object: tooltip

			tooltip:SetOffset(<Your Offset> [UDim2])
			 - Changes the tooltip offset relative to the mouse position
			 - Offset parameter is required
			 - Returns object: tooltip
			
			tooltip:SetPadding(<Your Padding> [Vector2])
			 - Changes the padding between text and frame
			 - Padding parameter is required
			 - Returns object: tooltip

			tooltip:Disconnect()
			 - Deletes the tooltip
			 
		object tooltip properties:
			tooltip.Gui [Instance]
			 - The tooltip gui
			 - Consists of Frame > TextLabel
			 - Can be easily customizable
			 
			tooltip.Text [String]
			 - Changes the  tooltip text
			 - The function need not necessarily used but using the function is recommended
			 
			tooltip.Offset
			 - Changes the tooltip offset relative to the mouse position
			 - The function need not necessarily used but using the function is recommended
			 
			tooltip.Padding
			 - Changes the padding between text and frame
			 - The function need not necessarily used but using the function is recommended
		 
	Example Code:
		local tooltip = require(script.Tooltip)(script.Parent, "Test Tooltip")
		wait(10)
		tooltip:SetText("Tooltip Text Changed")
		wait(10)
		tooltip.Gui.Frame.AnchorPoint = Vector2.new(0, 0)
		tooltip:SetOffset(UDim2.new(0.025, 0, 0, 0))
		tooltip:SetText("Tooltip Offset + Frame AnchorPoint Changed")
		wait(10)
		tooltip:Disconnect()
		
]]--

local Tooltip = {}
Tooltip.__index = Tooltip

-- Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Tooltip.new(Instance <YOUR OBJECT>, String <YOUR TOOLTIP TEXT>)
function Tooltip.new(object, text)
	assert(object and typeof(object) == "Instance" and object:IsA("GuiBase"), "Object parameter either not passed or invalid")
	text = text and tostring(text) or Tooltip.Log("Text parameter not passed, set default text") and "Tooltip"
	local moveConnection, leaveConnection
	
	-- Make tooltip
	local tooltip = {
		Gui = Tooltip.CreateGui(),
		Text = text,
		Offset = UDim2.new(0, 0, 0.05, 0),
		Padding = Vector2.new(0.025, 0.125),
	}
	
	-- Init connections - MouseMove; MouseLeave
	moveConnection = object.MouseMoved:Connect(function() tooltip:Show() end)
	leaveConnection = object.MouseLeave:Connect(function() tooltip:Hide() end)
	
	-- tooltip:Show() - makes the tooltip visible
	function tooltip:Show()
		local mp = userInputService:GetMouseLocation()
		local vp = workspace.CurrentCamera.ViewportSize
		local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
		
		self.Gui = self.Gui == nil and Tooltip.Log("No Gui associated with the tooltip, creating one") and Tooltip.CreateGui() or self.Gui
		self.Gui.Name = string.format("Tooltip_%s", tostring(object))
		
		local frame = self.Gui:FindFirstChildOfClass("Frame")
		assert(frame ~= nil, string.format("No Frame in %s found", tostring(self.Gui)))
		
		local text = frame:FindFirstChildOfClass("TextLabel")
		assert(text ~= nil, string.format("No TextLabel in %s.Frame found", tostring(self.Gui)))
		
		frame.Position = UDim2.new(mp.X / vp.X, 0, mp.Y / vp.Y, 0) + self.Offset
		text.Text = self.Text
		
		text.Size = UDim2.new(1000, 0, 1 - (self.Padding.Y * 2), 0)
		frame.Size = UDim2.new((text.TextBounds.X / vp.X) + self.Padding.X, 0, frame.Size.Y.Scale, 0)
		text.Size = UDim2.new(1, 0, text.Size.Y.Scale, 0)
		
		for _,c in ipairs(playerGui:GetChildren()) do
			if c:IsA("ScreenGui") and c.DisplayOrder > self.Gui.DisplayOrder then
				self.Gui.DisplayOrder = c.DisplayOrder + 1
			end
		end
		
		frame.Visible = true
		self.Gui.Parent = playerGui
		
		return self
	end
	
	-- tooltip:Hide() - makes the tooltip invisible
	function tooltip:Hide()
		self.Gui = self.Gui == nil and Tooltip.Log("No Gui associated with the tooltip, creating one") and Tooltip.CreateGui() or self.Gui
		local frame = self.Gui:FindFirstChildOfClass("Frame")
		assert(frame ~= nil, string.format("No Frame in %s found", tostring(self.Gui)))
		
		frame.Visible = false
		self.Gui.Parent = nil
		
		return self
	end
	
	-- tooltip:SetText(String <YOUR TOOLTIP TEXT>) - change the text
	function tooltip:SetText(text)
		text = text and tostring(text) or Tooltip.Log("Text parameter not passed, set default text") and "Tooltip"
		self.Text = text
		if self.Gui and typeof(self.Gui) == "Instance" and self.Gui:IsA("ScreenGui") and self.Gui.Parent ~= nil then self:Show() end
		return self
	end
	
	-- tooltip:SetOffset(UDim2 <YOUR TOOLTIP OFFSET>) - change the tooltip offset from mouse
	function tooltip:SetOffset(offset)
		offset = offset and typeof(offset) == "UDim2" and offset or Tooltip.Log("Offset parameter not passed, set default offset") and UDim2.new(0, 0, 0.05, 0)
		self.Offset = offset
		if self.Gui and typeof(self.Gui) == "Instance" and self.Gui:IsA("ScreenGui") and self.Gui.Parent ~= nil then self:Show() end
		return self
	end
	
	-- tooltip:SetPadding(Vector2 <YOUR TEXT PADDING>) - change the tooltip text padding inside frame
	function tooltip:SetPadding(padding)
		padding = padding and typeof(padding) == "Vector2" and padding or Tooltip.Log("Padding parameter not passed, set default padding") and Vector2.new(0.025, 0.125)
		self.Padding = padding
		if self.Gui and typeof(self.Gui) == "Instance" and self.Gui:IsA("ScreenGui") and self.Gui.Parent ~= nil then self:Show() end
		return self
	end
	
	-- tooltip:Disconnect() - disconnects the current tooltip
	function tooltip:Disconnect()
		self.Gui:Destroy()
		if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
		if leaveConnection then leaveConnection:Disconnect(); leaveConnection = nil end
		table.clear(tooltip)
		tooltip = nil
	end
	
	return tooltip
end

-- Tooltip module output warn function
function Tooltip.Log(msg)
	msg = msg and tostring(msg) or ""
	warn(msg)
	return true
end

-- Tooltip module Gui creation function
function Tooltip.CreateGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Tooltip"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 0, 0.035, 0)
	frame.BorderColor3 = Color3.new(1, 1, 1)
	frame.BackgroundColor3 = Color3.new(50 / 255, 50 / 255, 50 / 255)
	frame.BackgroundTransparency = 0.25
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.ZIndex = 10
	
	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 0.5)
	text.BackgroundTransparency = 1
	text.Name = "HoverText"
	text.Position = UDim2.new(0.5, 0, 0.5, 0)
	text.Size = UDim2.new(1, 0, 0.5, 0)
	text.Font = Enum.Font.Gotham
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextScaled = true
	text.TextWrapped = true
	
	text.Parent = frame
	frame.Parent = gui
	
	return gui
end

return Tooltip.new--[[

		TOOLTIP MODULE
			 by: 0V_ex

	Functions:
		Tooltip(<Your UI Object> [Instance], <Tooltip Text> [String])
		 - Creates a new tooltip
		 - Object parameter is required
		 - Text parameter is optional. If not passed, defaults to "Tooltip"
		 - Returns object: tooltip

		object tooltip functions:
			tooltip:Show()
			 - Makes the tooltip visible
			 - Returns object: tooltip

			tooltip:Hide()
			 - Gets the tooltip out of view
			 - Returns object: tooltip

			tooltip:SetText(<Your Text> [String])
			 - Changes the tooltip text
			 - Text parameter is required
			 - Returns object: tooltip

			tooltip:SetOffset(<Your Offset> [UDim2])
			 - Changes the tooltip offset relative to the mouse position
			 - Offset parameter is required
			 - Returns object: tooltip
			
			tooltip:SetPadding(<Your Padding> [Vector2])
			 - Changes the padding between text and frame
			 - Padding parameter is required
			 - Returns object: tooltip

			tooltip:Disconnect()
			 - Deletes the tooltip
			 
		object tooltip properties:
			tooltip.Gui [Instance]
			 - The tooltip gui
			 - Consists of Frame > TextLabel
			 - Can be easily customizable
			 
			tooltip.Text [String]
			 - Changes the  tooltip text
			 - The function need not necessarily used but using the function is recommended
			 
			tooltip.Offset
			 - Changes the tooltip offset relative to the mouse position
			 - The function need not necessarily used but using the function is recommended
			 
			tooltip.Padding
			 - Changes the padding between text and frame
			 - The function need not necessarily used but using the function is recommended
		 
	Example Code:
		local tooltip = require(script.Tooltip)(script.Parent, "Test Tooltip")
		wait(10)
		tooltip:SetText("Tooltip Text Changed")
		wait(10)
		tooltip.Gui.Frame.AnchorPoint = Vector2.new(0, 0)
		tooltip:SetOffset(UDim2.new(0.025, 0, 0, 0))
		tooltip:SetText("Tooltip Offset + Frame AnchorPoint Changed")
		wait(10)
		tooltip:Disconnect()
		
]]--

local Tooltip = {}
Tooltip.__index = Tooltip

-- Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Tooltip.new(Instance <YOUR OBJECT>, String <YOUR TOOLTIP TEXT>)
function Tooltip.new(object, text)
	assert(object and typeof(object) == "Instance" and object:IsA("GuiBase"), "Object parameter either not passed or invalid")
	text = text and tostring(text) or Tooltip.Log("Text parameter not passed, set default text") and "Tooltip"
	local moveConnection, leaveConnection
	
	-- Make tooltip
	local tooltip = {
		Gui = Tooltip.CreateGui(),
		Text = text,
		Offset = UDim2.new(0, 0, 0.05, 0),
		Padding = Vector2.new(0.025, 0.125),
	}
	
	-- Init connections - MouseMove; MouseLeave
	moveConnection = object.MouseMoved:Connect(function() tooltip:Show() end)
	leaveConnection = object.MouseLeave:Connect(function() tooltip:Hide() end)
	
	-- tooltip:Show() - makes the tooltip visible
	function tooltip:Show()
		local mp = userInputService:GetMouseLocation()
		local vp = workspace.CurrentCamera.ViewportSize
		local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
		
		self.Gui = self.Gui == nil and Tooltip.Log("No Gui associated with the tooltip, creating one") and Tooltip.CreateGui() or self.Gui
		self.Gui.Name = string.format("Tooltip_%s", tostring(object))
		
		local frame = self.Gui:FindFirstChildOfClass("Frame")
		assert(frame ~= nil, string.format("No Frame in %s found", tostring(self.Gui)))
		
		local text = frame:FindFirstChildOfClass("TextLabel")
		assert(text ~= nil, string.format("No TextLabel in %s.Frame found", tostring(self.Gui)))
		
		frame.Position = UDim2.new(mp.X / vp.X, 0, mp.Y / vp.Y, 0) + self.Offset
		text.Text = self.Text
		
		text.Size = UDim2.new(1000, 0, 1 - (self.Padding.Y * 2), 0)
		frame.Size = UDim2.new((text.TextBounds.X / vp.X) + self.Padding.X, 0, frame.Size.Y.Scale, 0)
		text.Size = UDim2.new(1, 0, text.Size.Y.Scale, 0)
		
		for _,c in ipairs(playerGui:GetChildren()) do
			if c:IsA("ScreenGui") and c.DisplayOrder > self.Gui.DisplayOrder then
				self.Gui.DisplayOrder = c.DisplayOrder + 1
			end
		end
		
		frame.Visible = true
		self.Gui.Parent = playerGui
		
		return self
	end
	
	-- tooltip:Hide() - makes the tooltip invisible
	function tooltip:Hide()
		self.Gui = self.Gui == nil and Tooltip.Log("No Gui associated with the tooltip, creating one") and Tooltip.CreateGui() or self.Gui
		local frame = self.Gui:FindFirstChildOfClass("Frame")
		assert(frame ~= nil, string.format("No Frame in %s found", tostring(self.Gui)))
		
		frame.Visible = false
		self.Gui.Parent = nil
		
		return self
	end
	
	-- tooltip:SetText(String <YOUR TOOLTIP TEXT>) - change the text
	function tooltip:SetText(text)
		text = text and tostring(text) or Tooltip.Log("Text parameter not passed, set default text") and "Tooltip"
		self.Text = text
		if self.Gui and typeof(self.Gui) == "Instance" and self.Gui:IsA("ScreenGui") and self.Gui.Parent ~= nil then self:Show() end
		return self
	end
	
	-- tooltip:SetOffset(UDim2 <YOUR TOOLTIP OFFSET>) - change the tooltip offset from mouse
	function tooltip:SetOffset(offset)
		offset = offset and typeof(offset) == "UDim2" and offset or Tooltip.Log("Offset parameter not passed, set default offset") and UDim2.new(0, 0, 0.05, 0)
		self.Offset = offset
		if self.Gui and typeof(self.Gui) == "Instance" and self.Gui:IsA("ScreenGui") and self.Gui.Parent ~= nil then self:Show() end
		return self
	end
	
	-- tooltip:SetPadding(Vector2 <YOUR TEXT PADDING>) - change the tooltip text padding inside frame
	function tooltip:SetPadding(padding)
		padding = padding and typeof(padding) == "Vector2" and padding or Tooltip.Log("Padding parameter not passed, set default padding") and Vector2.new(0.025, 0.125)
		self.Padding = padding
		if self.Gui and typeof(self.Gui) == "Instance" and self.Gui:IsA("ScreenGui") and self.Gui.Parent ~= nil then self:Show() end
		return self
	end
	
	-- tooltip:Disconnect() - disconnects the current tooltip
	function tooltip:Disconnect()
		self.Gui:Destroy()
		if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
		if leaveConnection then leaveConnection:Disconnect(); leaveConnection = nil end
		table.clear(tooltip)
		tooltip = nil
	end
	
	return tooltip
end

-- Tooltip module output warn function
function Tooltip.Log(msg)
	msg = msg and tostring(msg) or ""
	warn(msg)
	return true
end

-- Tooltip module Gui creation function
function Tooltip.CreateGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Tooltip"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 0, 0.035, 0)
	frame.BorderColor3 = Color3.new(1, 1, 1)
	frame.BackgroundColor3 = Color3.new(50 / 255, 50 / 255, 50 / 255)
	frame.BackgroundTransparency = 0.25
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.ZIndex = 10
	
	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 0.5)
	text.BackgroundTransparency = 1
	text.Name = "HoverText"
	text.Position = UDim2.new(0.5, 0, 0.5, 0)
	text.Size = UDim2.new(1, 0, 0.5, 0)
	text.Font = Enum.Font.Gotham
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextScaled = true
	text.TextWrapped = true
	
	text.Parent = frame
	frame.Parent = gui
	
	return gui
end

return Tooltip.new
