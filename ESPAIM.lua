--[[ 
File: ESP_and_AimBot.lua 
Place this script in a LocalScript for testing in Roblox Studio 
]]
while do true
    wait(5)
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera

-- Variables
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local cheatsEnabled = {
    ESP = false,
    AimBot = false
}

local espFolder = Instance.new("Folder", Workspace)
espFolder.Name = "ESPFolder"

local currentTarget = nil -- The player the Aimbot is locked onto

-- Function to create ESP
local function createESP(targetPlayer)
    if targetPlayer ~= localPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local character = targetPlayer.Character

        -- Create Highlight for the character
        local highlight = Instance.new("Highlight", character)
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)

        -- Create Line
        local beam = Instance.new("Beam", espFolder)
        beam.FaceCamera = true
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
        beam.Width0 = 0.15
        beam.Width1 = 0.15

        local attachmentStart = Instance.new("Attachment", humanoidRootPart)
        local attachmentEnd = Instance.new("Attachment", character:WaitForChild("HumanoidRootPart"))
        beam.Attachment0 = attachmentStart
        beam.Attachment1 = attachmentEnd

        -- Store ESP in the character for cleanup
        character:SetAttribute("ESP", true)
        character:SetAttribute("Beam", beam)
    end
end

-- Function to remove ESP
local function removeESP(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:GetAttribute("ESP") then
        local highlight = targetPlayer.Character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight:Destroy()
        end

        local beam = targetPlayer.Character:GetAttribute("Beam")
        if beam then
            beam:Destroy()
        end

        targetPlayer.Character:SetAttribute("ESP", nil)
        targetPlayer.Character:SetAttribute("Beam", nil)
    end
end

-- Update ESP for all players
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if cheatsEnabled.ESP then
            createESP(player)
        else
            removeESP(player)
        end
    end
end

-- ESP Cleanup on player removal
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Auto-create ESP for new players
Players.PlayerAdded:Connect(function(player)
    if cheatsEnabled.ESP then
        createESP(player)
    end
end)

-- Aimbot functionality
local function lockOntoNearestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= localPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local distance = (targetPlayer.Character.Head.Position - humanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestPlayer = targetPlayer
                closestDistance = distance
            end
        end
    end

    if closestPlayer then
        currentTarget = closestPlayer.Character.Head
    else
        currentTarget = nil
    end
end

local function toggleAimBot()
    cheatsEnabled.AimBot = not cheatsEnabled.AimBot
    if cheatsEnabled.AimBot then
        lockOntoNearestPlayer()
    else
        currentTarget = nil
    end
end

-- Update the camera to always aim at the target's head
RunService.RenderStepped:Connect(function()
    if cheatsEnabled.AimBot and currentTarget then
        camera.CFrame = CFrame.new(camera.CFrame.Position, currentTarget.Position)
    end

    -- If the target dies or resets, find a new target
    if currentTarget and (not currentTarget.Parent or not currentTarget.Parent:FindFirstChild("Humanoid")) then
        lockOntoNearestPlayer()
    end
end)

-- Create GUI
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "CheatGUI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0.2, 0, 0.3, 0)
mainFrame.Position = UDim2.new(0.4, 0, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local espButton = Instance.new("TextButton", mainFrame)
espButton.Size = UDim2.new(0.8, 0, 0.3, 0)
espButton.Position = UDim2.new(0.1, 0, 0.1, 0)
espButton.Text = "Toggle ESP"
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

espButton.MouseButton1Click:Connect(function()
    cheatsEnabled.ESP = not cheatsEnabled.ESP
    updateESP()
end)

local aimBotButton = Instance.new("TextButton", mainFrame)
aimBotButton.Size = UDim2.new(0.8, 0, 0.3, 0)
aimBotButton.Position = UDim2.new(0.1, 0, 0.5, 0)
aimBotButton.Text = "Toggle Aimbot"
aimBotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimBotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

aimBotButton.MouseButton1Click:Connect(toggleAimBot)
    print("Script Works u fucking skid")
end
