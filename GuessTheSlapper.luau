-- This script is Work-In-Progress!!!
-- No GUI Exists yet!
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Gui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("suspects")

-- Debug logger
local function Log(...)
	print("[ Guess-The-Slapper Script ]", ...)
end

-- Gets the closest player and their distance
local function GetNearestPlayer()
	local character = LocalPlayer.Character
	if not character then
		return nil, math.huge
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil, math.huge
	end

	local nearestPlayer = nil
	local nearestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local otherCharacter = player.Character
			local otherRoot = otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart")

			if otherRoot then
				local distance = (root.Position - otherRoot.Position).Magnitude

				-- Log(("Distance to %s: %.2f"):format(player.Name, distance))

				if distance < nearestDistance then
					nearestDistance = distance
					nearestPlayer = player
				end
			end
		end
	end

	if nearestPlayer then
		Log(("Nearest player: %s (%.2f studs)"):format(nearestPlayer.Name, nearestDistance))
	else
		Log("No players found")
	end

	return nearestPlayer, nearestDistance
end

-- Fires an ImageButton click event
local function ClickButton(button)
	if firesignal then
		if button.MouseButton1Click then
			firesignal(button.MouseButton1Click)
			Log("Fired MouseButton1Click for", button.Name)
			return true
		end

		if button.Activated then
			firesignal(button.Activated)
			Log("Fired Activated for", button.Name)
			return true
		end

		Log("No click signals found on", button.Name)
	else
		Log("firesignal unavailable")
	end

	return false
end

-- Main loop
RunService.Heartbeat:Connect(function()
	-- @ealoalo, add your auto slap code BEFORE this if you need to, please!
	-- (This is more efficient than a task.wait loop)!
	
	if not autoGuessSlapper then
		return
	end
		
  if not Gui.Visible then
		return
	end

	local nearestPlayer, distance = GetNearestPlayer()

	if not nearestPlayer then
		return
	end

	if distance > 2.27 then
		Log(("Too far away: %.2f studs"):format(distance))
		return
	end

	Log("Player in range:", nearestPlayer.Name)

	for _, item in ipairs(Gui:GetChildren()) do
		if item:IsA("ImageButton") then
			Log("Checking:", item.Name)

			local nameLabel = item:FindFirstChild("name")

			if nameLabel and nameLabel:IsA("TextLabel") then
				Log(("Button text: %s"):format(nameLabel.Text))

				if nameLabel.Text == nearestPlayer.Name then
					Log("MATCH FOUND:", nearestPlayer.Name)

					ClickButton(item)
					return
				end
			else
				Log("Missing TextLabel 'name' in", item.Name)
			end
		end
	end

	Log("No matching suspect button found")
end)
