local Players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer

local events = ReplicatedStorage:WaitForChild("events", 10)
local guessEvt = events:WaitForChild("Guess")
local slapEvt = events:WaitForChild("SendSlap")

local gui = Instance.new("ScreenGui")
gui.Name = "GuessTheSlapper.lua"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local function corner(obj, rad)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, rad or 7)
	c.Parent = obj
end

local function label(p, txt, sz, pos)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = Color3.fromRGB(225, 225, 225)
	l.TextSize = sz or 12
	l.Font = Enum.Font.Gotham
	l.Position = pos or UDim2.new()
	l.Parent = p
	return l
end

local function btn(p, txt, sz, pos)
	local b = Instance.new("TextButton")
	b.Size = sz
	b.Position = pos
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(230, 230, 230)
	b.TextSize = 12
	b.Font = Enum.Font.Gotham
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	b.Parent = p
	corner(b)
	return b
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 270, 0, 235)
main.Position = UDim2.new(0.5, -135, 0.5, -117)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
main.BorderSizePixel = 0
main.Parent = gui
corner(main, 10)

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 42)
topbar.BackgroundColor3 = Color3.fromRGB(31, 31, 36)
topbar.BorderSizePixel = 0
topbar.Parent = main
corner(topbar, 10)

local title = label(topbar, "Guess The Slapper", 14, UDim2.new(0, 14, 0, 0))
title.Size = UDim2.new(1, -60, 1, 0)

local closeBtn = btn(topbar, "×", UDim2.new(0, 32, 0, 32), UDim2.new(1, -38, 0, 5))
closeBtn.TextSize = 20
closeBtn.BackgroundTransparency = 1

local openBtn = btn(gui, "Show GUI", UDim2.new(0, 85, 0, 28), UDim2.new(0, 8, 0.5, -14))
openBtn.Visible = false

local isDragging = false
local dragStart, startPos

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

topbar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
	end
end)

uis.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local guessTab = btn(main, "Guess", UDim2.new(0.5, -15, 0, 30), UDim2.new(0, 10, 0, 52))
local slapTab = btn(main, "Slap", UDim2.new(0.5, -15, 0, 30), UDim2.new(0.5, 5, 0, 52))

local guessPage = Instance.new("Frame")
guessPage.Size = UDim2.new(1, -20, 1, -95)
guessPage.Position = UDim2.new(0, 10, 0, 92)
guessPage.BackgroundTransparency = 1
guessPage.Parent = main

local slapPage = guessPage:Clone()
slapPage.Parent = main
slapPage.Visible = false

local guessDesc = label(guessPage, "Auto Guess the Slapper", 12, UDim2.new(0, 0, 0, 5))
guessDesc.Size = UDim2.new(0.7, 0, 0, 30)

local autoBtn = btn(guessPage, "OFF", UDim2.new(0, 55, 0, 28), UDim2.new(1, -55, 0, 5))

label(slapPage, "Slap Power", 12, UDim2.new(0, 0, 0, 5))

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 6)
bar.Position = UDim2.new(0, 0, 0, 42)
bar.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
bar.Parent = slapPage
corner(bar, 5)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(130, 130, 145)
fill.Parent = bar
corner(fill, 5)

local handle = btn(bar, "", UDim2.new(0, 16, 0, 16), UDim2.new(1, -8, 0.5, -8))
handle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)

local slapButton = btn(slapPage, "Slap", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 75))

local autoGuess = false
local slapPower = 1
local sliding = false
local slapCooldown = false

autoBtn.MouseButton1Click:Connect(function()
	autoGuess = not autoGuess
	autoBtn.Text = autoGuess and "ON" or "OFF"

	if autoGuess then
		task.spawn(function()
			while autoGuess do
				local myChar = lp.Character
				local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

				if myHrp then
					local targetPlayer = nil
					local maxDist = math.huge

					for _, v in pairs(Players:GetPlayers()) do
						if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
							local dist = (myHrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
							if dist < maxDist then
								maxDist = dist
								targetPlayer = v
							end
						end
					end

					if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
						guessEvt:FireServer(targetPlayer.Name)
					end
				end

				task.wait(0.8)
			end
		end)
	end
end)

local function updateBar(xPos)
	if not bar or not bar.AbsolutePosition then return end
	local calc = math.clamp(xPos - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
	slapPower = calc / bar.AbsoluteSize.X

	fill.Size = UDim2.new(slapPower, 0, 1, 0)
	handle.Position = UDim2.new(slapPower, -8, 0.5, -8)
end

bar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		sliding = true
		updateBar(i.Position.X)
	end
end)

uis.InputChanged:Connect(function(i)
	if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		updateBar(i.Position.X)
	end
end)

uis.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		sliding = false
	end
end)

slapButton.MouseButton1Click:Connect(function()
	if slapCooldown then return end
	slapCooldown = true
	slapEvt:FireServer(slapPower)
	task.delay(0.3, function()
		slapCooldown = false
	end)
end)

guessTab.MouseButton1Click:Connect(function()
	guessPage.Visible = true
	slapPage.Visible = false
end)

slapTab.MouseButton1Click:Connect(function()
	guessPage.Visible = false
	slapPage.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	openBtn.Visible = false
end)
