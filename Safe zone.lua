local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local returnCFrame = nil

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- CAMERA
local cameraMode = false
local freeCamMode = false

local camYaw = 0
local camPitch = 0

local freeCamPosition = Vector3.zero
local freeCamSpeed = 0.8

-- ROOM SETTINGS
local teleportHeight = 10000

local roomWidth = 50
local roomLength = 50
local roomHeight = 10
local wallThickness = 1

local roomSize = Vector3.new(roomWidth, 1, roomLength)

-- VARIABLES
local roomFolder = nil
local originalCFrame = nil
local roomActive = false

local function createPart(size, position, color, material, parent)

	local part = Instance.new("Part")

	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Material = material
	part.Color = color

	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = false

	part.Parent = parent

	return part
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.T then

		local character = player.Character or player.CharacterAdded:Wait()
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not rootPart or not humanoid then
			return
		end

		if not roomActive then

			-- SAVE ORIGINAL POSITION
			returnCFrame = rootPart.CFrame
			originalCFrame = rootPart.CFrame

			-- TELEPORT TO ROOM
			rootPart.CFrame = originalCFrame + Vector3.new(0, teleportHeight, 0)

			local floorPos = rootPart.Position - Vector3.new(0, 3.5, 0)

			roomFolder = Instance.new("Folder")
			roomFolder.Name = "TempRoom"
			roomFolder.Parent = Workspace

			-- FLOOR
			createPart(
				roomSize,
				floorPos,
				Color3.fromRGB(0,0,0),
				Enum.Material.SmoothPlastic,
				roomFolder
			)

			-- ROOF
			createPart(
				roomSize,
				floorPos + Vector3.new(0, roomHeight, 0),
				Color3.fromRGB(0,0,0),
				Enum.Material.SmoothPlastic,
				roomFolder
			)

			local wallColor = Color3.fromRGB(0,170,255)

			-- FRONT WALL
			createPart(
				Vector3.new(roomWidth, roomHeight, wallThickness),
				floorPos + Vector3.new(0, roomHeight/2, roomLength/2),
				wallColor,
				Enum.Material.Neon,
				roomFolder
			)

			-- BACK WALL
			createPart(
				Vector3.new(roomWidth, roomHeight, wallThickness),
				floorPos + Vector3.new(0, roomHeight/2, -roomLength/2),
				wallColor,
				Enum.Material.Neon,
				roomFolder
			)

			-- LEFT WALL
			createPart(
				Vector3.new(wallThickness, roomHeight, roomLength),
				floorPos + Vector3.new(-roomWidth/2, roomHeight/2, 0),
				wallColor,
				Enum.Material.Neon,
				roomFolder
			)

			-- RIGHT WALL
			createPart(
				Vector3.new(wallThickness, roomHeight, roomLength),
				floorPos + Vector3.new(roomWidth/2, roomHeight/2, 0),
				wallColor,
				Enum.Material.Neon,
				roomFolder
			)

			-- RED CAMERA PLATE

			local plate = createPart(
				Vector3.new(3,1,3),
				floorPos + Vector3.new(roomWidth/2 - 5,0.5,0),
				Color3.fromRGB(255,0,0),
				Enum.Material.Neon,
				roomFolder
			)

			plate.Name = "CameraPlate"

			-- GREEN FREECAM PLATE

			local plate2 = createPart(
				Vector3.new(3,1,3),
				floorPos + Vector3.new(-roomWidth/2 + 5,0.5,0),
				Color3.fromRGB(0,255,0),
				Enum.Material.Neon,
				roomFolder
			)

			plate2.Name = "FreeCamPlate"

			local debounce = false

			-- RED PLATE

			plate.Touched:Connect(function(hit)

				if debounce then return end
				if not hit:IsDescendantOf(character) then return end

				debounce = true

				freeCamMode = false
				cameraMode = true

				camera.CameraType = Enum.CameraType.Scriptable

				camYaw = 0
				camPitch = 0

				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

				task.wait(1)

				debounce = false

			end)

			-- GREEN PLATE

			plate2.Touched:Connect(function(hit)

				if debounce then return end
				if not hit:IsDescendantOf(character) then return end

				debounce = true

				cameraMode = false
				freeCamMode = true

				-- Freeze Character
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
				humanoid.AutoRotate = false

				camera.CameraType = Enum.CameraType.Scriptable

				camYaw = 0
				camPitch = 0

				-- FreeCam starts sa original position
				freeCamPosition = originalCFrame.Position
				camera.CFrame = originalCFrame

				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

				task.wait(1)

				debounce = false

			end)

			roomActive = true

		else

			-- EXIT ROOM

			cameraMode = false
			freeCamMode = false

			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid

			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			
			returnCFrame = nil
			originalCFrame = nil

			-- Restore Character Movement
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			humanoid.AutoRotate = true

			-- Teleport to FreeCam position if FreeCam was used
			if freeCamPosition ~= Vector3.zero then
				rootPart.CFrame = CFrame.new(freeCamPosition)
			else
				if returnCFrame then
					rootPart.CFrame = returnCFrame
				end
			end

			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero

			-- Force Humanoid Refresh
			task.defer(function()
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)

			-- Delete Room
			if roomFolder then
				roomFolder:Destroy()
				roomFolder = nil
			end

			roomActive = false
			originalCFrame = nil

		end

	end

	-- Y = RESET CAMERA ONLY

	if input.KeyCode == Enum.KeyCode.Y then

		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end

		cameraMode = false
		freeCamMode = false

		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid

		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		-- Ibalik lang ang movement
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		humanoid.AutoRotate = true

		camYaw = 0
		camPitch = 0

	end

end)

-- MOUSE CAMERA ROTATION

UserInputService.InputChanged:Connect(function(input)

	if (cameraMode or freeCamMode) and input.UserInputType == Enum.UserInputType.MouseMovement then

		local sensitivity = 0.0018

		camYaw = camYaw - input.Delta.X * sensitivity

		camPitch = math.clamp(
			camPitch - input.Delta.Y * sensitivity,
			-1.2,
			1.2
		)

	end

end)

-- CAMERA UPDATE

RunService.RenderStepped:Connect(function()

	-- RED PLATE CAMERA
	if cameraMode and originalCFrame then

		camera.CameraType = Enum.CameraType.Scriptable

		local cameraPosition = originalCFrame.Position + Vector3.new(0,2,0)

		camera.CFrame =
			CFrame.new(cameraPosition)
			* CFrame.fromOrientation(camPitch, camYaw, 0)

	end

	-- GREEN PLATE FREECAM
	if freeCamMode then

		camera.CameraType = Enum.CameraType.Scriptable

		local move = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			move += camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			move -= camera.CFrame.LookVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			move -= camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			move += camera.CFrame.RightVector
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			move += Vector3.new(0,1,0)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			move -= Vector3.new(0,1,0)
		end

		-- Hold Shift para bumilis
		local speed = freeCamSpeed

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			speed = freeCamSpeed * 3
		end

		if move.Magnitude > 0 then
			freeCamPosition += move.Unit * speed
		end

		camera.CFrame =
			CFrame.new(freeCamPosition)
			* CFrame.fromOrientation(camPitch, camYaw, 0)

	end

end)