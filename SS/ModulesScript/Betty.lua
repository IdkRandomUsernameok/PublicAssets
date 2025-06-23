local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Resources = ReplicatedStorage.Resources
local Remotes = ReplicatedStorage.Remotes
local rad = math.rad
local sin = math.sin
local random = math.random
local huge = math.huge
local MainModule = loadstring(game:HttpGet("https://github.com/IdkRandomUsernameok/PublicAssets/raw/refs/heads/main/SS/ClientModules/MainModule.lua"))()

local module = {}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart, humanoid = character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
local head, torso = character:WaitForChild("Head"), character:WaitForChild("Torso")
local leftArm, rightArm = character:WaitForChild("Left Arm"), character:WaitForChild("Right Arm")
local leftLeg, rightLeg = character:WaitForChild("Left Leg"), character:WaitForChild("Right Leg")

local animsFolder = player.Backpack:WaitForChild("Main"):WaitForChild("BettyMoves"):WaitForChild("ModuleScript").Animations
game:GetService("ContentProvider"):PreloadAsync(animsFolder:GetDescendants())

local function getPlayerModels()
	local tab = {}

	for _,v in pairs(workspace.Live:GetChildren()) do
		table.insert(tab, v)
	end
	return tab
end

function module.HoverEffect()
	task.spawn(function()
		local ignoreList = getPlayerModels()
		
		local ray = Ray.new(torso.Position,(Vector3.new(0,-1,0)).unit * 10)
		local hit,position = workspace:FindPartOnRayWithIgnoreList(ray,ignoreList)
		
		if hit then
			--game.ReplicatedStorage.Remotes.Effects:FireServer({_G.Pass,"Particle","SmallSmokeParticle",CFrame.new(position,position + rootPart.CFrame.lookVector * 10) * CFrame.Angles(math.rad(90),math.rad(90),math.rad(0)),0.15})
		end
	end)
end
function module.HoverForwardEffect()
	task.spawn(function()
		local ignoreList = getPlayerModels()
		
		local ray = Ray.new(rootPart.Position,(Vector3.new(0,-1,0)).unit * 10)
		local hit,position = workspace:FindPartOnRayWithIgnoreList(ray,ignoreList)
		
		if hit then
			--game.ReplicatedStorage.Remotes.Effects:FireServer({_G.Pass,"Particle","SmallForwardSmokeParticle",CFrame.new(position,position + rootPart.CFrame.lookVector * 10) * CFrame.Angles(math.rad(90),math.rad(90),math.rad(0)),0.15})
		end
	end)
end
function module.Damage(tab)
	local victim
	for i,v in pairs(workspace.Live:GetChildren()) do
		if v:FindFirstChild("HumanoidRootPart") and v ~= character then
			local victim1 = v
			local p1 = rootPart.Position + rootPart.CFrame.lookVector * 5
			local p2 = victim1.HumanoidRootPart.Position
			
			if (p1 - p2).magnitude <= 6 then
				task.spawn(function()
					game.Lighting.Blur.Size = 16
					for i = 1,5 do
						game.Lighting.Blur.Size = game.Lighting.Blur.Size - 2
					wait(0.03) end
				end)
				
				--if game.ReplicatedStorage.Remotes.Damage:InvokeServer(_G.Pass, v, tab) then
					--victim = v
				--end
			end
		end
	end
	return victim
end
function moveForward(bp, lookvector, whitelist)
	if lookvector then
		local ray = Ray.new(rootPart.Position,(lookvector))
		local hit,position = workspace:FindPartOnRayWithWhitelist(ray,whitelist)
		if hit then
			bp.Position = position - rootPart.CFrame.lookVector * 1 + Vector3.new(0,1,0)
		end
	else
		local ray = Ray.new(rootPart.Position,(rootPart.CFrame.lookVector).unit * 10)
		local hit,position = workspace:FindPartOnRayWithWhitelist(ray,whitelist)

		if hit then
			bp.Position = position - rootPart.CFrame.lookVector * 1
		end
	end
end
local slashTable = {
	["Light1"] = {
		["Direction"] = "Right",
		["Angle"] = -20,
		["Speed"] = 0.3,
		["Times"] = 15,
		["Color"] = Color3.new(1,.8,.8),
		["Size"] = 3
	},
	["Light2"] = {
		["Direction"] = "Left",
		["Angle"] = -20,
		["Speed"] = 0.3,
		["Times"] = 15,
		["Color"] = Color3.new(1,.8,.8),
		["Size"] = 3
	},
	["Light3"] = {
		["Direction"] = "Left",
		["Angle"] = 5,
		["Speed"] = 0.3,
		["Times"] = 15,
		["Color"] = Color3.new(1,.8,.8),
		["Size"] = 3
	},
	["Light4"] = {
		["Direction"] = "Right",
		["Angle"] = 120,
		["Speed"] = 0.3,
		["Times"] = 15,
		["Color"] = Color3.new(1,.8,.8),
		["Size"] = 3
	},
	["Light5"] = {
		["Direction"] = "Left",
		["Angle"] = 120,
		["Speed"] = 0.3,
		["Times"] = 15,
		["Color"] = Color3.new(1,.8,.8),
		["Size"] = 3
	},
	["Light6"] = {
		["Direction"] = "Right",
		["Angle"] = 120,
		["Speed"] = 0.3,
		["Times"] = 15,
		["Color"] = Color3.new(1,.8,.8),
		["Size"] = 3
	},
}
function spawnWeeapon(activate, hand)
	task.spawn(function()
		if activate then
			MainModule.Create("StringValue", "UsingBone", character)
			if character.BettyFinalKnife.Knife.Transparency ~= 0 then
				--Remotes.BettyMoves:InvokeServer({_G.Pass, "SpawnKnife", true})
			end
		elseif not activate and character:FindFirstChild("UsingBone") then
			if character:FindFirstChild("UsingBone") then character:FindFirstChild("UsingBone"):Destroy() end
			for i = 1, 5 do
				if character:FindFirstChild("UsingBone") then
					break
				end
				wait(0.1)
			end
			if not character:FindFirstChild("UsingBone") then
				character.BettyFinalKnife.Knife.Transparency = 0.1
				--Remotes.BettyMoves:InvokeServer({_G.Pass, "SpawnKnife", false})
			end
		end
	end)
end
function module.Combat(typ, blade, upgraded)
	local humanoid = character.Humanoid
	local folder = animsFolder.BasicCombat
	if blade and upgraded ~= "TruePowerScythe" then
		folder = animsFolder.BladesCombat
	elseif upgraded == "TruePower" then
		folder = animsFolder.SpecialCombat
	elseif upgraded == "TruePowerScythe" then
		folder = animsFolder.Blades2Combat
	end
	
	if folder:FindFirstChild(typ) then
		
		local combatAnim = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(folder[typ])
		if combatAnim.Length <= 0 then
			repeat game:GetService("RunService").RenderStepped:Wait() until combatAnim.Length > 0
		end
		combatAnim:Play(0.1)
		combatAnim:AdjustSpeed(1.8)
		if upgraded == "TruePower" then
			--combatAnim:AdjustSpeed(1.5)
			combatAnim:AdjustSpeed(1.9)
		end
		if upgraded == "TruePowerScythe" then
			combatAnim:AdjustSpeed(1)
		end
		for i, v in pairs(rootPart:GetChildren()) do
			if v.Name == "Client" then
				v:Destroy()
			end
		end
		local bp = Instance.new("BodyPosition")
		bp.Name = "Client"
		if blade then
			--game.ReplicatedStorage.Remotes.SwordHandler:FireServer({_G.Pass,"SliceEffect",true,"ChaosSaber"})
		end
		MainModule.CombatAnimation(combatAnim, character, bp, slashTable)
		combatAnim.KeyframeReached:Connect(function(keyframe)
			if keyframe == "Slash" then
				if typ == "Light1" then
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-10))})
				end
				if typ == "Light2" then
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(math.rad(-0), math.rad(-0), math.rad(-30))})
				end
				if typ == "Light3" then
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(math.rad(10), math.rad(15), 0)})
				end
				if typ == "Light4" then
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0,math.rad(-60))})
				end
				if typ == "Light5" then
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0,math.rad(-40))})
				end
				if typ == "Light6" then
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0,math.rad(-40))})
				end
			end
		end)
		task.spawn(function()
			if folder == animsFolder.SpecialCombat then
				if typ == "Light1" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(50))})
				end
				if typ == "Light3" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(20))})
				end
				if typ == "Light4" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-10))})
				end
				if typ == "Light5" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-10))})
				end
				if typ == "Light6" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(65))})
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(125))})
				end
			end
		end)
		task.spawn(function()
			if folder == animsFolder.Blades2Combat then
				if typ == "Light1" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(50))})
				end
				if typ == "Light2" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(60))})
				end
				if typ == "Light4" then
					wait(0.3)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-10))})
				end
				if typ == "Light5" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-40))})
				end
				if typ == "Light6" then
					wait(0.05)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing2, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-30))})
					wait(0.35)
					--game.ReplicatedStorage.Remotes.Events:FireServer({_G.Pass, "SlashEffect", animsFolder.Slash.Swing1, Color3.fromRGB(252, 148, 255), CFrame.Angles(0,0, math.rad(-90))})
				end
			end
		end)
		local lockOn = player.Backpack.Main.LockOnScript.LockOn
		
		if lockOn.Value then
			rootPart.CFrame = CFrame.new(rootPart.Position,Vector3.new(lockOn.Value.HumanoidRootPart.Position.X,rootPart.Position.Y,lockOn.Value.HumanoidRootPart.Position.Z))
    end
		
		local newRay = Ray.new(rootPart.CFrame.p, Vector3.new(0,-1,0).unit * 4)
		local Hit,Position = game:GetService("Workspace"):FindPartOnRay(newRay, character)
		if Hit then
			--ReplicatedStorage.Remotes.Effects:FireServer({_G.Pass, "Particle", "SmallForwardSmokeParticle", CFrame.new(Position, Position + rootPart.CFrame.lookVector * 10) * CFrame.Angles(math.rad(90),math.rad(90),math.rad(0)), 0.1})
		end
		
		if typ:match("Light") or typ:match("Heavy") then
			bp.MaxForce = Vector3.new(100000,0,100000)
		else
			bp.MaxForce = Vector3.new(100000,100000,100000)
		end
		bp.P = 30000
		bp.Parent = rootPart
		
		local bg = Instance.new("BodyGyro")
		bg.Name = "Client"
		bg.MaxTorque = Vector3.new(10000,10000,10000)
		bg.CFrame = rootPart.CFrame
		bg.Parent = rootPart
		
		local whitelist = {}
		pcall(function()
			for i,v in pairs(workspace.Live:GetChildren()) do
				if v:FindFirstChild("HumanoidRootPart") and v.Name ~= player.Name and v:FindFirstChild("Torso") and v:FindFirstChild("Head") then
					table.insert(whitelist,v.HumanoidRootPart)
					table.insert(whitelist,v.Torso)
					table.insert(whitelist,v.Head)
					table.insert(whitelist,v["Left Arm"])
					table.insert(whitelist,v["Right Arm"])
					table.insert(whitelist,v["Right Leg"])
					table.insert(whitelist,v["Left Leg"])
				end
			end
		end)

		local ray = Ray.new(rootPart.Position,(rootPart.CFrame.lookVector).unit * 10)
		local hit,position = workspace:FindPartOnRayWithWhitelist(ray,whitelist)
		
		if hit then
			bp.Position = position - rootPart.CFrame.lookVector * 1.5
		else
			if upgraded == "TruePower" and typ ~= "Light2" then
				bp.Position = rootPart.Position + rootPart.CFrame.lookVector * 20
			else
				bp.Position = rootPart.Position + rootPart.CFrame.lookVector * 10
			end
		end
		if upgraded == "TruePower" and typ == "Light3" or upgraded == "TruePower" and typ == "Light4" or upgraded == "TruePower" and typ == "Light5" or upgraded == "TruePower" and typ == "Light6" then
			spawnWeeapon(true)
		end
		
		repeat moveForward(bp, nil, whitelist) game:GetService("RunService").RenderStepped:Wait() until combatAnim.TimePosition > (combatAnim.Length - (upgraded == "TruePower" and typ == "Light1" and 0.35 or 0.16)) or not combatAnim.isPlaying or MainModule.checkIfHit()
		if upgraded == "TruePower" and typ == "Light3" or upgraded == "TruePower" and typ == "Light4" or upgraded == "TruePower" and typ == "Light5" or upgraded == "TruePower" and typ == "Light6" then
			spawnWeeapon(false)
		end
		
		combatAnim:AdjustSpeed(0.8)
		if blade then
			--game.ReplicatedStorage.Remotes.SwordHandler:FireServer({_G.Pass,"SliceEffect",false,"ChaosSaber"})
		end
		game.Debris:AddItem(bp, 0.5)
		bg:Destroy()
	end
end

return module
