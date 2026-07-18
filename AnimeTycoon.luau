local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
Name = "Anime Tycoon",
LoadingTitle = "Anime Tycoon",
LoadingSubtitle = "by efalo123",
ConfigurationSaving = {
Enabled = false
},
Discord = {
Enabled = false
},
KeySystem = false
})

local Main = Window:CreateTab("Main", "home")
local Farm = Window:CreateTab("Farm", "hand-coins")
local Combat = Window:CreateTab("Combat", "sword")
local Misc = Window:CreateTab("Misc", "settings")
local Troll = Window:CreateTab("Troll", "ghost")
local Items = Window:CreateTab("Item", "box")

local speed, jump = 16, 50
local noclip = false
local infiniteJump = false
local killAura = false
local ignoreFriends = true
local auraRange = 25
local autoCollect = false
local autoUpgrade = false
local disableLasers = false
local ignoredPlayers = {}

-- ADDED BY CHIPLAG
--print("Debug Msg. - Version 1.1.1")
local function fireAutoUpgrade()
	local tycoon = game.Workspace.Tycoons:FindFirstChild(player.Team.Name)
	local btns = tycoon.Buttons
	local active = {}

	local function getMoney()
		return player.leaderstats.Cash.Value
	end

	for i, v in pairs(btns:GetChildren()) do
		if v.Button.Transparency == 0 and v:FindFirstChild("Gamepass") == nil then
			table.insert(active, v)
		end
	end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	-- Check theres a button to be clicked
	if not next(active) then return end

	local oc = hrp.CFrame
	for _, v in pairs(active) do
		-- Check Money
		if getMoney() >= v.Price.Value then
			hrp.CFrame = v.Button.CFrame
			task.wait(0.01)
		end
	end
	hrp.CFrame = oc
end
-- END OF ADDED BY CHIPLAG

local function notify(title, content)
Rayfield:Notify({
Title = title or "Anime Tycoon",
Content = content,
Duration = 5
})
end

Main:CreateSlider({
Name = "Walkspeed",
Range = {16, 500},
Increment = 1,
Suffix = "",
CurrentValue = 16,
Flag = "WalkSpeed",
Callback = function(v)
speed = v
end
})

Main:CreateSlider({
Name = "Jumppower",
Range = {50, 500},
Increment = 1,
Suffix = "",
CurrentValue = 50,
Flag = "JumpPower",
Callback = function(v)
jump = v
end
})

Main:CreateToggle({
Name = "Inf Jump",
CurrentValue = false,
Flag = "InfJump",
Callback = function(v)
infiniteJump = v
end
})

Main:CreateToggle({
Name = "Noclip",
CurrentValue = false,
Flag = "Noclip",
Callback = function(v)
noclip = v
end
})

UIS.JumpRequest:Connect(function()
if not infiniteJump then
return
end

local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")

if hum then
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

end)

Farm:CreateToggle({
Name = "Auto Collect Cash",
CurrentValue = false,
Flag = "AutoCollect",
Callback = function(v)
autoCollect = v
end
})

-- ADDED BY CHIPLAG
Farm:CreateToggle({
Name = "Auto Upgrade",
CurrentValue = false,
Flag = "AutoUpgrade",
Callback = function(v)
autoUpgrade = v
end
})
-- END ADDED BY CHIPLAG


local function getTool()
local char = player.Character
return char and char:FindFirstChildOfClass("Tool")
end

Combat:CreateToggle({
Name = "Kill Aura",
CurrentValue = false,
Flag = "KillAura",
Callback = function(v)
killAura = v
end
})

Combat:CreateInput({
Name = "Kill Aura Reach (0=inf)",
CurrentValue = "25",
PlaceholderText = "Enter number...",
RemoveTextAfterFocusLost = false,
Callback = function(v)
local n = tonumber(v)

    if n then
        auraRange = n

        notify(
            "Anime Tycoon",
            "Reach set to " .. (n == 0 and "Infinite" or tostring(n))
        )
    end
end

})

local function getPlayerNames()
local names = {}

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        names[#names + 1] = plr.Name
    end
end

return names

end

local teammateDropdown = Combat:CreateDropdown({
Name = "Add Teammate",
Options = getPlayerNames(),
CurrentOption = {},
MultipleOptions = true,
Flag = "Teammates",
Callback = function(selected)
table.clear(ignoredPlayers)

    if typeof(selected) == "table" then
        for _, name in ipairs(selected) do
            if typeof(name) == "string" then
                ignoredPlayers[#ignoredPlayers + 1] = name
            end
        end
    elseif typeof(selected) == "string" and selected ~= "" then
        ignoredPlayers[#ignoredPlayers + 1] = selected
    end
end

})

local function refreshTeammates()
teammateDropdown:Refresh(getPlayerNames())
end

Players.PlayerAdded:Connect(refreshTeammates)
Players.PlayerRemoving:Connect(refreshTeammates)

Combat:CreateToggle({
Name = "Ignore Friends",
CurrentValue = true,
Flag = "IgnoreFriends",
Callback = function(v)
ignoreFriends = v
end
})

Misc:CreateButton({
Name = "Load Infinite Yield",
Callback = function()
loadstring(game:HttpGet(
"https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
))()

    notify("Anime Tycoon", "Infinite Yield loaded")
end

})

Misc:CreateButton({
Name = "Load Nameless Admin",
Callback = function()
loadstring(game:HttpGet(
"https://rawscripts.net/raw/Universal-Script-Nameless-admin-reworked-75477"
))()

    notify("Anime Tycoon", "Nameless Admin loaded")
end

})

Troll:CreateToggle({
Name = "Ignore People Tycoon Laser",
CurrentValue = false,
Flag = "IgnoreLasers",
Callback = function(v)
disableLasers = v
end
})

Items:CreateButton({
Name = "Steal People Tycoon Items",
Callback = function()
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then
        notify("Anime Tycoon", "No character")
        return
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()

            if name:find("ore")
            or name:find("money")
            or name:find("cash")
            or name:find("collect")
            or name:find("part")
            or name:find("droplet")
            or name:find("ingot") then

                firetouchinterest(root, obj, 0)
                firetouchinterest(root, obj, 1)
            end
        end
    end

    notify("Anime Tycoon", "Stealed People Tycoon Items")
end

})

local collectParts = {}
local lastCollectUpdate = 0

local function refreshCollectParts()
table.clear(collectParts)

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Name == "Collect" then
        collectParts[#collectParts + 1] = obj
    end
end

end

local laserParts = {}

local function refreshLasers()
table.clear(laserParts)

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        local name = obj.Name:lower()

        if name:find("laser")
        or name:find("kill")
        or name:find("union") then

            laserParts[#laserParts + 1] = obj
        end
    end
end

end

refreshCollectParts()
refreshLasers()

task.spawn(function()
while true do
task.wait(5)

    refreshLasers()

    for _, laser in ipairs(laserParts) do
        if laser and laser.Parent then
            laser.CanTouch = not disableLasers
        end
    end
end

end)

task.spawn(function()
while true do
task.wait(.05)

    local char = player.Character

    if not char then
        continue
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum then
        hum.WalkSpeed = speed
        hum.JumpPower = jump
    end

    if noclip then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    end

	-- ADDED BY CHIPLAG
	if autoUpgrade then
			fireAutoUpgrade()
	end
	-- END ADDED BY CHIPLAG

    if not root then
        continue
    end

    if killAura then
        local tool = getTool()

        if tool then
            local handle = tool:FindFirstChild("Handle")
                or tool:FindFirstChildWhichIsA("BasePart")

            if handle then
                pcall(function()
                    tool:Activate()
                end)

                for _, target in ipairs(Players:GetPlayers()) do
                    if target == player then
                        continue
                    end

                    if table.find(ignoredPlayers, target.Name) then
                        continue
                    end

                    if ignoreFriends
                    and player:IsFriendsWith(target.UserId) then
                        continue
                    end

                    local targetChar = target.Character
                    local targetRoot = targetChar
                        and targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHum = targetChar
                        and targetChar:FindFirstChildOfClass("Humanoid")

                    if targetRoot
                    and targetHum
                    and targetHum.Health > 0 then

                        local distance =
                            (root.Position - targetRoot.Position).Magnitude

                        if auraRange == 0
                        or distance <= auraRange then

                            firetouchinterest(handle, targetRoot, 0)
                            firetouchinterest(handle, targetRoot, 1)

                            pcall(function()
                                tool:Activate()
                            end)
                        end
                    end
                end
            end
        end
    end

    if autoCollect then
        if tick() - lastCollectUpdate > 3 then
            refreshCollectParts()
            lastCollectUpdate = tick()
        end

        for _, collect in ipairs(collectParts) do
            if collect and collect.Parent then
                firetouchinterest(root, collect, 0)
                firetouchinterest(root, collect, 1)
            end
        end
    end
end

end)

notify("Anime Tycoon", "Loaded anime tycoon script")
