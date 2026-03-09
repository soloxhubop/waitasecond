task.wait(0.1)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiScale = isMobile and 0.25 or 0.6

local C = {
    bg = Color3.fromRGB(12, 2, 2),
    blue = Color3.fromRGB(220, 40, 40),
    blueLight = Color3.fromRGB(255, 100, 100),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(255, 80, 80),
    danger = Color3.fromRGB(239, 68, 68),
}

local Features = {
    SpeedBoost         = false,
    SpeedWhileStealing = false,
    Helicopter         = false,
    MeleeAimbot        = false,
    AntiRagdoll        = false,
    Unwalk             = false,
    AutoSteal          = false,
    Optimizer          = false,
    XRay               = false,
}

local Values = {
    BoostSpeed           = 30,
    StealingSpeedValue   = 29,
    SpinSpeed            = 10,
}

-- â”€â”€â”€ Speed Boost â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Connections = {}

local function getMovementDirection()
    local c = Player.Character
    if not c then return Vector3.zero end
    local hum = c:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end

local function startSpeedBoost()
    if Connections.speed then return end
    Connections.speed = RunService.Heartbeat:Connect(function()
        if not Features.SpeedBoost then return end
        pcall(function()
            local c = Player.Character
            if not c then return end
            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local md = getMovementDirection()
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(
                    md.X * Values.BoostSpeed,
                    h.AssemblyLinearVelocity.Y,
                    md.Z * Values.BoostSpeed
                )
            end
        end)
    end)
end

local function stopSpeedBoost()
    if Connections.speed then
        Connections.speed:Disconnect()
        Connections.speed = nil
    end
end

-- â”€â”€â”€ Thief Speed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local speedWhileStealingConn = nil

local function startSpeedWhileStealing()
    if speedWhileStealingConn then return end
    speedWhileStealingConn = RunService.Heartbeat:Connect(function()
        if not Features.SpeedWhileStealing or not Player:GetAttribute("Stealing") then return end
        local c = Player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local md = hum and hum.MoveDirection or Vector3.zero
        if md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(
                md.X * Values.StealingSpeedValue,
                h.AssemblyLinearVelocity.Y,
                md.Z * Values.StealingSpeedValue
            )
        end
    end)
end

local function stopSpeedWhileStealing()
    if speedWhileStealingConn then
        speedWhileStealingConn:Disconnect()
        speedWhileStealingConn = nil
    end
end

-- â”€â”€â”€ Helicopter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local helicopterSpinBAV = nil

local function applyHelicopterSpeed()
    if helicopterSpinBAV then
        helicopterSpinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    end
end

local function startHelicopter()
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if helicopterSpinBAV then helicopterSpinBAV:Destroy() helicopterSpinBAV = nil end
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "HelicopterBAV" then v:Destroy() end
    end
    helicopterSpinBAV = Instance.new("BodyAngularVelocity")
    helicopterSpinBAV.Name            = "HelicopterBAV"
    helicopterSpinBAV.MaxTorque       = Vector3.new(0, math.huge, 0)
    helicopterSpinBAV.AngularVelocity = Vector3.new(0, Values.SpinSpeed, 0)
    helicopterSpinBAV.Parent          = hrp
end

local function stopHelicopter()
    if helicopterSpinBAV then helicopterSpinBAV:Destroy() helicopterSpinBAV = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "HelicopterBAV" then v:Destroy() end
            end
        end
    end
end


-- â”€â”€â”€ Float â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local floatConn      = nil
local floatKeybind   = Enum.KeyCode.F
local floatListening = false
local FLOAT_TARGET_HEIGHT = 10
local floatOriginY   = nil

local function startFloat()
    local c = Player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "FloatBV" or v.Name == "FloatBP" then v:Destroy() end
    end
    floatOriginY = hrp.Position.Y + FLOAT_TARGET_HEIGHT
    local floatStartTime  = tick()
    local floatDescending = false
    floatConn = RunService.Heartbeat:Connect(function()
        if not Features.Float then return end
        local c2  = Player.Character
        if not c2 then return end
        local h   = c2:FindFirstChild("HumanoidRootPart")
        if not h  then return end
        local hum2 = c2:FindFirstChildOfClass("Humanoid")
        local moveDir = hum2 and hum2.MoveDirection or Vector3.zero
        local moveSpeed = Values.BoostSpeed
        if tick() - floatStartTime >= 4 then floatDescending = true end
        local currentY = h.Position.Y
        local vertVel
        if floatDescending then
            vertVel = -20
            if currentY <= floatOriginY - FLOAT_TARGET_HEIGHT + 0.5 then
                h.AssemblyLinearVelocity = Vector3.zero
                Features.Float = false
                if floatConn then floatConn:Disconnect() floatConn = nil end
                if _G.lexStopFloatVisual then _G.lexStopFloatVisual() end
                return
            end
        else
            local diff = floatOriginY - currentY
            if diff > 0.3 then
                vertVel = math.clamp(diff * 8, 5, 50)
            elseif diff < -0.3 then
                vertVel = math.clamp(diff * 8, -50, -5)
            else
                vertVel = 0
            end
        end
        local horizX = moveDir.Magnitude > 0.1 and moveDir.X * moveSpeed or 0
        local horizZ = moveDir.Magnitude > 0.1 and moveDir.Z * moveSpeed or 0
        h.AssemblyLinearVelocity = Vector3.new(horizX, vertVel, horizZ)
    end)
end

local function stopFloat()
    if floatConn then floatConn:Disconnect() floatConn = nil end
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in pairs(hrp:GetChildren()) do
                if v.Name == "FloatBV" or v.Name == "FloatBP" then v:Destroy() end
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

-- â”€â”€â”€ Hit Circle (Melee Aimbot) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Cebo = { Conn = nil, Circle = nil, Align = nil, Attach = nil }

local function startMeleeAimbot()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    Cebo.Attach = Instance.new("Attachment", hrp)
    Cebo.Align = Instance.new("AlignOrientation", hrp)
    Cebo.Align.Attachment0 = Cebo.Attach
    Cebo.Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    Cebo.Align.RigidityEnabled = true
    Cebo.Circle = Instance.new("Part")
    Cebo.Circle.Shape = Enum.PartType.Cylinder
    Cebo.Circle.Material = Enum.Material.Neon
    Cebo.Circle.Size = Vector3.new(0.05, 14.5, 14.5)
    Cebo.Circle.Color = Color3.new(1, 0, 0)
    Cebo.Circle.CanCollide = false
    Cebo.Circle.Massless = true
    Cebo.Circle.Parent = workspace
    local weld = Instance.new("Weld")
    weld.Part0 = hrp
    weld.Part1 = Cebo.Circle
    weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))
    weld.Parent = Cebo.Circle
    Cebo.Conn = RunService.RenderStepped:Connect(function()
        local target, dmin = nil, 7.25
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d <= dmin then target, dmin = p.Character.HumanoidRootPart, d end
            end
        end
        if target then
            char.Humanoid.AutoRotate = false
            Cebo.Align.Enabled = true
            Cebo.Align.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
            local t = char:FindFirstChild("Bat") or char:FindFirstChild("Medusa")
            if t then t:Activate() end
        else
            Cebo.Align.Enabled = false
            char.Humanoid.AutoRotate = true
        end
    end)
end

local function stopMeleeAimbot()
    if Cebo.Conn   then Cebo.Conn:Disconnect()   Cebo.Conn   = nil end
    if Cebo.Circle then Cebo.Circle:Destroy()     Cebo.Circle = nil end
    if Cebo.Align  then Cebo.Align:Destroy()      Cebo.Align  = nil end
    if Cebo.Attach then Cebo.Attach:Destroy()     Cebo.Attach = nil end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.AutoRotate = true
    end
end

-- â”€â”€â”€ Anti Ragdoll â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local antiRagdollMode    = nil
local ragdollConnections = {}
local cachedCharData     = {}
local isBoosting         = false
local BOOST_SPEED        = 400
local AR_DEFAULT_SPEED   = 16

local function arCacheCharacterData()
    local char = Player.Character
    if not char then return false end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData = { character = char, humanoid = hum, root = root }
    return true
end

local function arDisconnectAll()
    for _, conn in ipairs(ragdollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    ragdollConnections = {}
end

local function arIsRagdolled()
    if not cachedCharData.humanoid then return false end
    local state = cachedCharData.humanoid:GetState()
    local ragdollStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragdollStates[state] then return true end
    local endTime = Player:GetAttribute("RagdollEndTime")
    if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function arForceExitRagdoll()
    if not cachedCharData.humanoid or not cachedCharData.root then return end
    pcall(function()
        Player:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    for _, descendant in ipairs(cachedCharData.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or
           (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            descendant:Destroy()
        end
    end
    if not isBoosting then
        isBoosting = true
        cachedCharData.humanoid.WalkSpeed = BOOST_SPEED
    end
    if cachedCharData.humanoid.Health > 0 then
        cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    cachedCharData.root.Anchored = false
end

local function arHeartbeatLoop()
    while antiRagdollMode == "v1" do
        task.wait()
        local currentlyRagdolled = arIsRagdolled()
        if currentlyRagdolled then
            arForceExitRagdoll()
        elseif isBoosting and not currentlyRagdolled then
            isBoosting = false
            if cachedCharData.humanoid then
                cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED
            end
        end
    end
end

local function startAntiRagdoll()
    if antiRagdollMode == "v1" then return end
    if not arCacheCharacterData() then return end
    antiRagdollMode = "v1"
    local camConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam and cachedCharData.humanoid then
            cam.CameraSubject = cachedCharData.humanoid
        end
    end)
    table.insert(ragdollConnections, camConn)
    local respawnConn = Player.CharacterAdded:Connect(function()
        isBoosting = false
        task.wait(0.5)
        arCacheCharacterData()
    end)
    table.insert(ragdollConnections, respawnConn)
    task.spawn(arHeartbeatLoop)
end

local function stopAntiRagdoll()
    antiRagdollMode = nil
    if isBoosting and cachedCharData.humanoid then
        cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED
    end
    isBoosting = false
    arDisconnectAll()
    cachedCharData = {}
end

-- â”€â”€â”€ Unwalk â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local savedAnimations = {}

local function startUnwalk()
    local c = Player.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            t:Stop()
        end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        savedAnimations.Animate = anim:Clone()
        anim:Destroy()
    end
end

local function stopUnwalk()
    local c = Player.Character
    if c and savedAnimations.Animate then
        savedAnimations.Animate:Clone().Parent = c
        savedAnimations.Animate = nil
    end
end

-- â”€â”€â”€ Auto Steal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local isStealing    = false
local StealData     = {}
local progressConn  = nil
local stealStartTime = nil

local AutoStealValues = {
    STEAL_RADIUS   = 20,
    STEAL_DURATION = 1.3,
}
Values.STEAL_RADIUS = AutoStealValues.STEAL_RADIUS

local function isMyPlotByName(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base  = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nd and dist <= AutoStealValues.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then
                                    np, nd, nn = ch, dist, pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

-- â”€â”€â”€ Progress Bar Refs (set after GUI is built below) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local ProgressBarFill      = nil
local ProgressPercentLabel = nil

local function resetProgressBar()
    if ProgressBarFill      then ProgressBarFill.Size = UDim2.new(0, 0, 1, 0) end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "0%" end
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready     = false
    isStealing     = true
    stealStartTime = tick()
    if progressConn then progressConn:Disconnect() end
    progressConn = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect() return end
        local prog = math.clamp((tick() - stealStartTime) / AutoStealValues.STEAL_DURATION, 0, 1)
        if ProgressBarFill      then ProgressBarFill.Size = UDim2.new(prog, 0, 1, 0) end
        if ProgressPercentLabel then ProgressPercentLabel.Text = math.floor(prog * 100) .. "%" end
    end)
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(AutoStealValues.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        if progressConn then progressConn:Disconnect() progressConn = nil end
        resetProgressBar()
        data.ready = true
        isStealing = false
    end)
end

local autoStealConn = nil

local function startAutoSteal()
    if autoStealConn then return end
    autoStealConn = RunService.Heartbeat:Connect(function()
        if not Features.AutoSteal or isStealing then return end
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if autoStealConn then autoStealConn:Disconnect() autoStealConn = nil end
    if progressConn  then progressConn:Disconnect()  progressConn  = nil end
    isStealing = false
    resetProgressBar()
end

-- â”€â”€â”€ Optimizer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Brightness = 3
        game:GetService("Lighting").FogEnd = 9e9
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                end
            end)
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
end

-- â”€â”€â”€ XRay â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local originalTransparency = {}

local function enableXRay()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and
               (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
end

local function disableXRay()
    for part, value in pairs(originalTransparency) do
        if part then part.LocalTransparencyModifier = value end
    end
    originalTransparency = {}
end

-- â”€â”€â”€ ScreenGui â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local sg = Instance.new("ScreenGui")
sg.Name = "LEX_HUB"
sg.ResetOnSpawn = false
sg.Parent = Player.PlayerGui

-- â”€â”€â”€ Rainbow Progress Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local PB_W = 380 * guiScale
local PB_H = 44 * guiScale
local PB_TOP = 58 * guiScale + 20 * guiScale

local progressBar = Instance.new("Frame", sg)
progressBar.Size = UDim2.new(0, PB_W, 0, PB_H)
progressBar.Position = UDim2.new(0.5, -PB_W / 2, 0, PB_TOP)
progressBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
progressBar.BackgroundTransparency = 0.15
progressBar.BorderSizePixel = 0
progressBar.ClipsDescendants = false
progressBar.ZIndex = 10
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

local pStroke = Instance.new("UIStroke", progressBar)
pStroke.Thickness = 4 * guiScale
pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Add gradient to progress bar
local pGradient = Instance.new("UIGradient", progressBar)
pGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 10, 10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 5, 5))
}

local pTrack = Instance.new("Frame", progressBar)
pTrack.Size = UDim2.new(1, -12 * guiScale, 0, 10 * guiScale)
pTrack.Position = UDim2.new(0, 6 * guiScale, 1, -14 * guiScale)
pTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
pTrack.BorderSizePixel = 0
pTrack.ZIndex = 11
Instance.new("UICorner", pTrack).CornerRadius = UDim.new(1, 0)

ProgressBarFill = Instance.new("Frame", pTrack)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 12
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(1, 0)

-- Add gradient to fill
local fillGradient = Instance.new("UIGradient", ProgressBarFill)
fillGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 30, 30))
}

ProgressPercentLabel = Instance.new("TextLabel", progressBar)
ProgressPercentLabel.Size = UDim2.new(1, 0, 1, -12 * guiScale)
ProgressPercentLabel.Position = UDim2.new(0, 0, 0, 0)
ProgressPercentLabel.BackgroundTransparency = 1
ProgressPercentLabel.Text = "0%"
ProgressPercentLabel.Font = Enum.Font.GothamBlack
ProgressPercentLabel.TextSize = 19 * guiScale
ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Center
ProgressPercentLabel.TextYAlignment = Enum.TextYAlignment.Center
ProgressPercentLabel.ZIndex = 13

-- Red color loop: stroke, fill, and percent text stay red
task.spawn(function()
    local t = 0
    while progressBar.Parent do
        t = t + 0.05
        local brightness = 0.85 + math.sin(t) * 0.15
        local col = Color3.fromRGB(
            math.floor(255 * brightness),
            math.floor(30 * brightness),
            math.floor(30 * brightness)
        )
        pStroke.Color = col
        if ProgressBarFill      then ProgressBarFill.BackgroundColor3 = col end
        if ProgressPercentLabel then ProgressPercentLabel.TextColor3  = col end
        task.wait(0.03)
    end
end)

local winWidth = 440 * guiScale
local gap = 20

-- â”€â”€â”€ Window Factory â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function createWindow(title, xPos)
    local main = Instance.new("Frame", sg)
    main.Name = title
    main.Size = UDim2.new(0, 440 * guiScale, 0, 560 * guiScale)
    local winH = 560 * guiScale
    main.Position = UDim2.new(0.5, xPos, 0.5, -winH / 2)
    main.BackgroundColor3 = Color3.fromRGB(12, 2, 2)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 28 * guiScale)

    -- Add gradient to main window
    local mainGradient = Instance.new("UIGradient", main)
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 5, 5)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 2, 2))
    }

    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Thickness = 3.5
    mainStroke.Color = Color3.fromRGB(220, 40, 40)

    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 52 * guiScale)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.ZIndex = 4

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, 0, 1, -6 * guiScale)
    titleLabel.Position = UDim2.new(0, 0, 0, 3 * guiScale)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 5

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 28 * guiScale, 0, 28 * guiScale)
    closeBtn.Position = UDim2.new(1, -36 * guiScale, 0.5, -14 * guiScale)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "Ã—"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 22 * guiScale
    closeBtn.ZIndex = 5

    closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = C.danger end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80) end)

    local divider = Instance.new("Frame", main)
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 52 * guiScale)
    divider.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.ZIndex = 4

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, 0, 1, -58 * guiScale)
    content.Position = UDim2.new(0, 0, 0, 58 * guiScale)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.ZIndex = 2

    return main, content
end

-- â”€â”€â”€ Toggle Helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function makeToggle(parent, labelText, layoutOrder)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -16 * guiScale, 0, 62 * guiScale)
    frame.BackgroundColor3 = Color3.fromRGB(36, 8, 8)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = layoutOrder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22 * guiScale)
    
    -- Add gradient to toggle
    local toggleGradient = Instance.new("UIGradient", frame)
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 12, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 6, 6))
    }
    
    local fStroke = Instance.new("UIStroke", frame)
    fStroke.Thickness = 2.5
    fStroke.Color = Color3.fromRGB(220, 40, 40)
    fStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.58, 0, 1, 0)
    lbl.Position = UDim2.new(0, 14 * guiScale, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(255, 220, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 20 * guiScale
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center

    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(0, 52 * guiScale, 0, 28 * guiScale)
    bg.Position = UDim2.new(1, -62 * guiScale, 0.5, -14 * guiScale)
    bg.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
    bg.ZIndex = 4
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    -- Add gradient to toggle bg
    local bgGradient = Instance.new("UIGradient", bg)
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 25, 25))
    }

    local circle = Instance.new("Frame", bg)
    circle.Size = UDim2.new(0, 22 * guiScale, 0, 22 * guiScale)
    circle.Position = UDim2.new(0, 3 * guiScale, 0.5, -11 * guiScale)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.ZIndex = 5
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6

    local isOn = false
    local function setVisual(state)
        isOn = state
        if isOn then
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 40, 40)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -25 * guiScale, 0.5, -11 * guiScale)}):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 30, 30)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3 * guiScale, 0.5, -11 * guiScale)}):Play()
        end
    end

    return btn, setVisual, function() return isOn end
end

-- â”€â”€â”€ Input Box Helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function makeInputBox(parent, labelText, minVal, maxVal, defaultVal, layoutOrder, onChange)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -16 * guiScale, 0, 62 * guiScale)
    container.BackgroundColor3 = Color3.fromRGB(36, 8, 8)
    container.BorderSizePixel = 0
    container.LayoutOrder = layoutOrder
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 22 * guiScale)
    
    -- Add gradient to input box
    local inputGradient = Instance.new("UIGradient", container)
    inputGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 12, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 6, 6))
    }
    
    local cStroke = Instance.new("UIStroke", container)
    cStroke.Thickness = 2.5
    cStroke.Color = Color3.fromRGB(220, 40, 40)
    cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 14 * guiScale, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 19 * guiScale
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center

    local inputBox = Instance.new("TextBox", container)
    inputBox.Size = UDim2.new(0, 75 * guiScale, 0, 36 * guiScale)
    inputBox.Position = UDim2.new(1, -89 * guiScale, 0.5, -18 * guiScale)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextSize = 20 * guiScale
    inputBox.Text = tostring(defaultVal)
    inputBox.BorderSizePixel = 0
    inputBox.ZIndex = 7
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 12 * guiScale)
    
    -- Add gradient to input box field
    local boxGradient = Instance.new("UIGradient", inputBox)
    boxGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 10))
    }
    
    local boxStroke = Instance.new("UIStroke", inputBox)
    boxStroke.Thickness = 1.5
    boxStroke.Color = Color3.fromRGB(220, 40, 40)

    local function updateValue(text)
        local value = tonumber(text)
        if value then
            value = math.floor(math.clamp(value, minVal, maxVal))
            inputBox.Text = tostring(value)
            if onChange then onChange(value) end
        end
    end

    inputBox.FocusLost:Connect(function()
        updateValue(inputBox.Text)
    end)

    inputBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            inputBox.Text = ""
        end
    end)

    return container
end

-- â”€â”€â”€ Build Windows â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local totalW = (440 * guiScale) * 2 + gap
local win1X = -totalW / 2
local win2X = -totalW / 2 + 440 * guiScale + gap
local win1, content1 = createWindow("Lex Hub", win1X)
local win2, content2 = createWindow("Lex Helper", win2X)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- â”€â”€â”€ LEX HUB SCROLL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local hubScroll = Instance.new("ScrollingFrame", content1)
hubScroll.Size = UDim2.new(1, 0, 1, 0)
hubScroll.BackgroundTransparency = 1
hubScroll.BorderSizePixel = 0
hubScroll.ScrollBarThickness = 4 * guiScale
hubScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
hubScroll.ZIndex = 3

local hubLayout = Instance.new("UIListLayout", hubScroll)
hubLayout.Padding = UDim.new(0, 10 * guiScale)
hubLayout.FillDirection = Enum.FillDirection.Vertical
hubLayout.SortOrder = Enum.SortOrder.LayoutOrder
hubLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local hubPadding = Instance.new("UIPadding", hubScroll)
hubPadding.PaddingTop = UDim.new(0, 10 * guiScale)

-- Speed Boost
do
    local speedKeybind = Enum.KeyCode.E
    local listeningForKey = false

    local btn, setVisual, getState = makeToggle(hubScroll, "Speed Boost  [E]", 1)
    local frame = btn.Parent
    local lbl = frame:FindFirstChildOfClass("TextLabel")

    local function updateLabel()
        if lbl then lbl.Text = "Speed Boost  [" .. speedKeybind.Name .. "]" end
    end

    local keybindBtn = Instance.new("TextButton", frame)
    keybindBtn.Size = UDim2.new(0, 44 * guiScale, 0, 26 * guiScale)
    keybindBtn.Position = UDim2.new(1, -112 * guiScale, 0.5, -13 * guiScale)
    keybindBtn.BackgroundColor3 = Color3.fromRGB(55, 15, 15)
    keybindBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    keybindBtn.Font = Enum.Font.GothamBold
    keybindBtn.TextSize = 13 * guiScale
    keybindBtn.Text = "BIND"
    keybindBtn.BorderSizePixel = 0
    keybindBtn.ZIndex = 8
    Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 14 * guiScale)
    
    -- Add gradient to bind button
    local bindGradient = Instance.new("UIGradient", keybindBtn)
    bindGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 12, 12))
    }
    
    local kbStroke = Instance.new("UIStroke", keybindBtn)
    kbStroke.Thickness = 2
    kbStroke.Color = Color3.fromRGB(220, 40, 40)
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    keybindBtn.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        listeningForKey = true
        keybindBtn.Text = "..."
        keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            speedKeybind = input.KeyCode
            listeningForKey = false
            keybindBtn.Text = "BIND"
            keybindBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
            updateLabel()
        end)
    end)

    local function toggleSpeedBoost()
        if listeningForKey then return end
        local on = not getState()
        setVisual(on)
        Features.SpeedBoost = on
        if on then startSpeedBoost() else stopSpeedBoost() end
    end

    btn.MouseButton1Click:Connect(toggleSpeedBoost)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listeningForKey and input.KeyCode == speedKeybind then toggleSpeedBoost() end
    end)
end

makeInputBox(hubScroll, "Speed Value", 1, 70, Values.BoostSpeed, 2, function(v)
    Values.BoostSpeed = v
end)

do
    local btn, setVisual, getState = makeToggle(hubScroll, "Thief Speed", 3)
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.SpeedWhileStealing = on
        if on then startSpeedWhileStealing() else stopSpeedWhileStealing() end
    end)
end

makeInputBox(hubScroll, "Steal Speed", 10, 50, Values.StealingSpeedValue, 4, function(v)
    Values.StealingSpeedValue = v
end)

do
    local btn, setVisual, getState = makeToggle(hubScroll, "Helicopter", 5)
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.Helicopter = on
        if on then startHelicopter() else stopHelicopter() end
    end)
end


-- Float
do
    local btn, setVisual, getState = makeToggle(hubScroll, "Float  [F]", 7)
    local frame = btn.Parent
    local lbl   = frame:FindFirstChildOfClass("TextLabel")

    local function updateFloatLabel()
        if lbl then lbl.Text = "Float  [" .. floatKeybind.Name .. "]" end
    end

    local kbBtn = Instance.new("TextButton", frame)
    kbBtn.Size = UDim2.new(0, 44 * guiScale, 0, 26 * guiScale)
    kbBtn.Position = UDim2.new(1, -112 * guiScale, 0.5, -13 * guiScale)
    kbBtn.BackgroundColor3 = Color3.fromRGB(55, 15, 15)
    kbBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    kbBtn.Font = Enum.Font.GothamBold
    kbBtn.TextSize = 13 * guiScale
    kbBtn.Text = "BIND"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 8
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 14 * guiScale)
    
    -- Add gradient to float bind button
    local floatBindGradient = Instance.new("UIGradient", kbBtn)
    floatBindGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 12, 12))
    }
    
    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 2
    kbStroke.Color = Color3.fromRGB(220, 40, 40)
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    kbBtn.MouseButton1Click:Connect(function()
        if floatListening then return end
        floatListening = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            floatKeybind   = input.KeyCode
            floatListening = false
            kbBtn.Text     = "BIND"
            kbBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
            updateFloatLabel()
        end)
    end)

    local function toggleFloat()
        if floatListening then return end
        local on = not getState()
        setVisual(on)
        Features.Float = on
        if on then startFloat() else stopFloat() end
    end

    _G.lexStopFloatVisual = function() setVisual(false) end

    btn.MouseButton1Click:Connect(toggleFloat)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not floatListening and input.KeyCode == floatKeybind then toggleFloat() end
    end)
end

do
    local btn, setVisual, getState = makeToggle(hubScroll, "Optimizer+XRay", 8)
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.Optimizer = on
        Features.XRay = on
        if on then 
            enableOptimizer()
            enableXRay()
        else 
            disableOptimizer()
            disableXRay()
        end
    end)
end


hubLayout.Changed:Connect(function()
    hubScroll.CanvasSize = UDim2.new(0, 0, 0, hubLayout.AbsoluteContentSize.Y + 16 * guiScale)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- â”€â”€â”€ LEX HELPER SCROLL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local helperScroll = Instance.new("ScrollingFrame", content2)
helperScroll.Size = UDim2.new(1, 0, 1, 0)
helperScroll.BackgroundTransparency = 1
helperScroll.BorderSizePixel = 0
helperScroll.ScrollBarThickness = 4 * guiScale
helperScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
helperScroll.ZIndex = 3

local helperLayout = Instance.new("UIListLayout", helperScroll)
helperLayout.Padding = UDim.new(0, 10 * guiScale)
helperLayout.FillDirection = Enum.FillDirection.Vertical
helperLayout.SortOrder = Enum.SortOrder.LayoutOrder
helperLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local helperPadding = Instance.new("UIPadding", helperScroll)
helperPadding.PaddingTop = UDim.new(0, 10 * guiScale)

-- 1. Hit Circle
do
    local btn, setVisual, getState = makeToggle(helperScroll, "Hit Circle", 2)
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.MeleeAimbot = on
        if on then startMeleeAimbot() else stopMeleeAimbot() end
    end)
end

-- 3. Anti Ragdoll
do
    local btn, setVisual, getState = makeToggle(helperScroll, "Anti Ragdoll", 3)
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.AntiRagdoll = on
        if on then startAntiRagdoll() else stopAntiRagdoll() end
    end)
end

-- 4. Unwalk
do
    local btn, setVisual, getState = makeToggle(helperScroll, "Unwalk", 4)
    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.Unwalk = on
        if on then startUnwalk() else stopUnwalk() end
    end)
end

-- 5. Auto Steal with Steal Radius
do
    local container = Instance.new("Frame", helperScroll)
    container.Size = UDim2.new(1, -16 * guiScale, 0, 130 * guiScale)
    container.BackgroundColor3 = Color3.fromRGB(36, 8, 8)
    container.BorderSizePixel = 0
    container.LayoutOrder = 5
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 22 * guiScale)
    
    -- Add gradient
    local containerGradient = Instance.new("UIGradient", container)
    containerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 12, 12)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 6, 6))
    }
    
    local fStroke = Instance.new("UIStroke", container)
    fStroke.Thickness = 2.5
    fStroke.Color = Color3.fromRGB(220, 40, 40)
    fStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Auto Steal Toggle
    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.58, 0, 0, 62 * guiScale)
    lbl.Position = UDim2.new(0, 14 * guiScale, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Auto Steal"
    lbl.TextColor3 = Color3.fromRGB(255, 220, 220)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 20 * guiScale
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center

    local bg = Instance.new("Frame", container)
    bg.Size = UDim2.new(0, 52 * guiScale, 0, 28 * guiScale)
    bg.Position = UDim2.new(1, -62 * guiScale, 0, 17 * guiScale)
    bg.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
    bg.ZIndex = 4
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    -- Add gradient to toggle bg
    local bgGradient = Instance.new("UIGradient", bg)
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 25, 25))
    }

    local circle = Instance.new("Frame", bg)
    circle.Size = UDim2.new(0, 22 * guiScale, 0, 22 * guiScale)
    circle.Position = UDim2.new(0, 3 * guiScale, 0.5, -11 * guiScale)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.ZIndex = 5
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 62 * guiScale)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6

    local isOn = false
    local function setVisual(state)
        isOn = state
        if isOn then
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 40, 40)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -25 * guiScale, 0.5, -11 * guiScale)}):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 30, 30)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3 * guiScale, 0.5, -11 * guiScale)}):Play()
        end
    end
    
    local function getState() return isOn end

    btn.MouseButton1Click:Connect(function()
        local on = not getState()
        setVisual(on)
        Features.AutoSteal = on
        if on then startAutoSteal() else stopAutoSteal() end
    end)

    -- Steal Radius Input Box
    local radiusLabel = Instance.new("TextLabel", container)
    radiusLabel.Size = UDim2.new(0.65, 0, 0, 40 * guiScale)
    radiusLabel.Position = UDim2.new(0, 14 * guiScale, 0, 70 * guiScale)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Text = "Steal Radius"
    radiusLabel.TextColor3 = Color3.fromRGB(255, 220, 220)
    radiusLabel.Font = Enum.Font.GothamBold
    radiusLabel.TextSize = 18 * guiScale
    radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
    radiusLabel.TextYAlignment = Enum.TextYAlignment.Center

    local inputBox = Instance.new("TextBox", container)
    inputBox.Size = UDim2.new(0, 90 * guiScale, 0, 44 * guiScale)
    inputBox.Position = UDim2.new(1, -104 * guiScale, 0.5, 8 * guiScale)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextSize = 28 * guiScale
    inputBox.Text = tostring(AutoStealValues.STEAL_RADIUS)
    inputBox.BorderSizePixel = 0
    inputBox.ZIndex = 7
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 12 * guiScale)
    
    -- Add padding to input box
    local boxPadding = Instance.new("UIPadding", inputBox)
    boxPadding.PaddingLeft = UDim.new(0, 8 * guiScale)
    boxPadding.PaddingRight = UDim.new(0, 8 * guiScale)

    -- Add gradient to input box
    local boxGradient = Instance.new("UIGradient", inputBox)
    boxGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 10))
    }
    
    local boxStroke = Instance.new("UIStroke", inputBox)
    boxStroke.Thickness = 3
    boxStroke.Color = Color3.fromRGB(220, 40, 40)

    local function updateValue(text)
        local value = tonumber(text)
        if value then
            value = math.floor(math.clamp(value, 5, 100))
            inputBox.Text = tostring(value)
            AutoStealValues.STEAL_RADIUS = value
            Values.STEAL_RADIUS = value
        end
    end

    inputBox.FocusLost:Connect(function()
        updateValue(inputBox.Text)
    end)

    inputBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            inputBox.Text = ""
        end
    end)
end

-- â”€â”€â”€ Steal Path Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local pathActive        = false
local lastFlatVel       = Vector3.zero

local PATH_VELOCITY_SPEED  = 59.2
local PATH_SECOND_SPEED    = 29.6
local PATH_BASE_STOP       = 1.35
local PATH_MIN_STOP        = 0.65
local PATH_NEXT_POINT_BIAS = 0.45
local PATH_SMOOTH_FACTOR   = 0.12

local stealPath1 = {
    {pos = Vector3.new(-470.6, -5.9,  34.4)},
    {pos = Vector3.new(-484.2, -3.9,  21.4)},
    {pos = Vector3.new(-475.6, -5.8,  29.3)},
    {pos = Vector3.new(-473.4, -5.9, 111.0)},
}

local stealPath2 = {
    {pos = Vector3.new(-474.7, -5.9,  91.0)},
    {pos = Vector3.new(-483.4, -3.9,  97.3)},
    {pos = Vector3.new(-474.7, -5.9,  91.0)},
    {pos = Vector3.new(-476.1, -5.5,  25.4)},
}

local function pathMoveToPoint(hrp, current, nextPoint, speed)
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not pathActive then
            conn:Disconnect()
            hrp.AssemblyLinearVelocity = Vector3.zero
            return
        end
        local pos    = hrp.Position
        local target = Vector3.new(current.X, pos.Y, current.Z)
        local dir    = target - pos
        local dist   = dir.Magnitude
        local stopDist = math.clamp(PATH_BASE_STOP - dist * 0.04, PATH_MIN_STOP, PATH_BASE_STOP)
        if dist <= stopDist then
            conn:Disconnect()
            hrp.AssemblyLinearVelocity = Vector3.zero
            return
        end
        local moveDir = dir.Unit
        if nextPoint then
            local nextDir = (Vector3.new(nextPoint.X, pos.Y, nextPoint.Z) - pos).Unit
            moveDir = (moveDir + nextDir * PATH_NEXT_POINT_BIAS).Unit
        end
        if lastFlatVel.Magnitude > 0.1 then
            moveDir = (moveDir * (1 - PATH_SMOOTH_FACTOR) + lastFlatVel.Unit * PATH_SMOOTH_FACTOR).Unit
        end
        local vel = Vector3.new(moveDir.X * speed, hrp.AssemblyLinearVelocity.Y, moveDir.Z * speed)
        hrp.AssemblyLinearVelocity = vel
        lastFlatVel = Vector3.new(vel.X, 0, vel.Z)
    end)
    while pathActive and
        (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(current.X, 0, current.Z)).Magnitude > PATH_BASE_STOP do
        RunService.Heartbeat:Wait()
    end
end

local function runStealPath(path)
    local hrp = (Player.Character or Player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
    for i, p in ipairs(path) do
        if not pathActive then return end
        local speed = i > 2 and PATH_SECOND_SPEED or PATH_VELOCITY_SPEED
        local nextP = path[i + 1] and path[i + 1].pos
        pathMoveToPoint(hrp, p.pos, nextP, speed)
        if i == 2 then task.wait(0.2) else task.wait(0.01) end
    end
end

local function startStealPath(path)
    pathActive = true
    task.spawn(function()
        while pathActive do
            runStealPath(path)
            task.wait(0.1)
        end
    end)
end

local function stopStealPath()
    pathActive = false
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
end

-- 8. Right Steal
do
    local rightKeybind  = Enum.KeyCode.E
    local rightListening = false
    local leftStealSetVisual = nil

    local btn, setVisual, getState = makeToggle(helperScroll, "Right Steal  [E]", 8)
    local frame = btn.Parent
    local lbl   = frame:FindFirstChildOfClass("TextLabel")

    local function updateRightLabel()
        if lbl then lbl.Text = "Right Steal  [" .. rightKeybind.Name .. "]" end
    end

    local kbBtn = Instance.new("TextButton", frame)
    kbBtn.Size = UDim2.new(0, 44 * guiScale, 0, 26 * guiScale)
    kbBtn.Position = UDim2.new(1, -112 * guiScale, 0.5, -13 * guiScale)
    kbBtn.BackgroundColor3 = Color3.fromRGB(55, 15, 15)
    kbBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    kbBtn.Font = Enum.Font.GothamBold
    kbBtn.TextSize = 13 * guiScale
    kbBtn.Text = "BIND"
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 8
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 14 * guiScale)
    
    -- Add gradient to right steal bind button
    local rightStealBindGradient = Instance.new("UIGradient", kbBtn)
    rightStealBindGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 12, 12))
    }
    
    local kbStroke = Instance.new("UIStroke", kbBtn)
    kbStroke.Thickness = 2
    kbStroke.Color = Color3.fromRGB(220, 40, 40)
    kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    kbBtn.MouseButton1Click:Connect(function()
        if rightListening then return end
        rightListening = true
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            conn:Disconnect()
            rightKeybind   = input.KeyCode
            rightListening = false
            kbBtn.Text     = "BIND"
            kbBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
            updateRightLabel()
        end)
    end)

    local function toggleRight()
        if rightListening then return end
        local on = not getState()
        setVisual(on)
        stopStealPath()
        if leftStealSetVisual then leftStealSetVisual(false) end
        if on then startStealPath(stealPath1) end
    end

    btn.MouseButton1Click:Connect(toggleRight)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not rightListening and input.KeyCode == rightKeybind then toggleRight() end
    end)

    -- 9. Left Steal
    do
        local leftKeybind   = Enum.KeyCode.Q
        local leftListening  = false

        local btn2, setVisual2, getState2 = makeToggle(helperScroll, "Left Steal  [Q]", 9)
        leftStealSetVisual = setVisual2
        local frame2 = btn2.Parent
        local lbl2   = frame2:FindFirstChildOfClass("TextLabel")

        local function updateLeftLabel()
            if lbl2 then lbl2.Text = "Left Steal  [" .. leftKeybind.Name .. "]" end
        end

        local kbBtn2 = Instance.new("TextButton", frame2)
        kbBtn2.Size = UDim2.new(0, 44 * guiScale, 0, 26 * guiScale)
        kbBtn2.Position = UDim2.new(1, -112 * guiScale, 0.5, -13 * guiScale)
        kbBtn2.BackgroundColor3 = Color3.fromRGB(55, 15, 15)
        kbBtn2.TextColor3 = Color3.fromRGB(255, 120, 120)
        kbBtn2.Font = Enum.Font.GothamBold
        kbBtn2.TextSize = 13 * guiScale
        kbBtn2.Text = "BIND"
        kbBtn2.BorderSizePixel = 0
        kbBtn2.ZIndex = 8
        Instance.new("UICorner", kbBtn2).CornerRadius = UDim.new(0, 14 * guiScale)
        
        -- Add gradient to left steal bind button
        local leftStealBindGradient = Instance.new("UIGradient", kbBtn2)
        leftStealBindGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 12, 12))
        }
        
        local kbStroke2 = Instance.new("UIStroke", kbBtn2)
        kbStroke2.Thickness = 2
        kbStroke2.Color = Color3.fromRGB(220, 40, 40)
        kbStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        kbBtn2.MouseButton1Click:Connect(function()
            if leftListening then return end
            leftListening = true
            kbBtn2.Text = "..."
            kbBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                leftKeybind   = input.KeyCode
                leftListening = false
                kbBtn2.Text   = "BIND"
                kbBtn2.TextColor3 = Color3.fromRGB(255, 120, 120)
                updateLeftLabel()
            end)
        end)

        local function toggleLeft()
            if leftListening then return end
            local on = not getState2()
            setVisual2(on)
            stopStealPath()
            setVisual(false)
            if on then startStealPath(stealPath2) end
        end

        btn2.MouseButton1Click:Connect(toggleLeft)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not leftListening and input.KeyCode == leftKeybind then toggleLeft() end
        end)
    end
end

helperLayout.Changed:Connect(function()
    helperScroll.CanvasSize = UDim2.new(0, 0, 0, helperLayout.AbsoluteContentSize.Y + 16 * guiScale)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- â”€â”€â”€ FPS & PING COMPACT BAR (top-center) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local StatsService = game:GetService("Stats")

local BAR_H        = 58 * guiScale
local BRAND_W      = 170 * guiScale
local STAT_W       = 180 * guiScale
local TOTAL_W      = BRAND_W + STAT_W + STAT_W

local bottomBar = Instance.new("Frame", sg)
bottomBar.Name = "FPS_PING_Bar"
bottomBar.Size = UDim2.new(0, TOTAL_W, 0, BAR_H)
bottomBar.Position = UDim2.new(0.5, -TOTAL_W / 2, 0, 10 * guiScale)
bottomBar.BackgroundColor3 = Color3.fromRGB(16, 12, 12)
bottomBar.BorderSizePixel = 0
bottomBar.ZIndex = 20
bottomBar.ClipsDescendants = true
Instance.new("UICorner", bottomBar).CornerRadius = UDim.new(0, 20 * guiScale)

-- Add gradient to bottom bar
local bottomGradient = Instance.new("UIGradient", bottomBar)
bottomGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 25, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 12, 12))
}

local barStroke = Instance.new("UIStroke", bottomBar)
barStroke.Thickness = 3
barStroke.Color = Color3.fromRGB(220, 40, 40)

-- â”€â”€ Brand block â”€â”€
local brandBlock = Instance.new("Frame", bottomBar)
brandBlock.Size = UDim2.new(0, BRAND_W, 1, 0)
brandBlock.Position = UDim2.new(0, 0, 0, 0)
brandBlock.BackgroundColor3 = Color3.fromRGB(16, 12, 12)
brandBlock.BorderSizePixel = 0
brandBlock.ZIndex = 21

local brandLabel = Instance.new("TextLabel", brandBlock)
brandLabel.Size = UDim2.new(1, 0, 1, 0)
brandLabel.BackgroundTransparency = 1
brandLabel.Text = "LEX HUB"
brandLabel.TextColor3 = Color3.fromRGB(220, 40, 40)
brandLabel.Font = Enum.Font.GothamBold
brandLabel.TextSize = 22 * guiScale
brandLabel.TextXAlignment = Enum.TextXAlignment.Center
brandLabel.TextYAlignment = Enum.TextYAlignment.Center
brandLabel.ZIndex = 22

-- â”€â”€ Divider helper â”€â”€
local function makeDivider(xOffset)
    local d = Instance.new("Frame", bottomBar)
    d.Size = UDim2.new(0, 1, 0.55, 0)
    d.Position = UDim2.new(0, xOffset, 0.225, 0)
    d.BackgroundColor3 = Color3.fromRGB(90, 80, 80)
    d.BorderSizePixel = 0
    d.ZIndex = 21
end

makeDivider(BRAND_W)

-- â”€â”€ FPS label â”€â”€
local fpsLabel = Instance.new("TextLabel", bottomBar)
fpsLabel.Size = UDim2.new(0, STAT_W, 1, 0)
fpsLabel.Position = UDim2.new(0, BRAND_W, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 21 * guiScale
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
fpsLabel.ZIndex = 21

makeDivider(BRAND_W + STAT_W)

-- â”€â”€ Ping label â”€â”€
local pingLabel = Instance.new("TextLabel", bottomBar)
pingLabel.Size = UDim2.new(0, STAT_W, 1, 0)
pingLabel.Position = UDim2.new(0, BRAND_W + STAT_W, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "PING: --ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 21 * guiScale
pingLabel.TextXAlignment = Enum.TextXAlignment.Center
pingLabel.TextYAlignment = Enum.TextYAlignment.Center
pingLabel.ZIndex = 21

-- â”€â”€â”€ FPS Sampling â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local fpsSamples      = {}
local sampleLimit     = 20
local lastUpdate      = tick()
local UPDATE_INTERVAL = 0.5
local lastFrameTime   = tick()

local function getFPSColor(fps)
    if fps >= 55 then return Color3.fromRGB(255, 120, 120)
    elseif fps >= 35 then return Color3.fromRGB(220, 60, 60)
    else return Color3.fromRGB(180, 30, 30) end
end

local function getPingColor(ping)
    if ping <= 80 then return Color3.fromRGB(255, 120, 120)
    elseif ping <= 150 then return Color3.fromRGB(220, 60, 60)
    else return Color3.fromRGB(180, 30, 30) end
end

RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt  = now - lastFrameTime
    lastFrameTime = now

    if dt > 0 then
        table.insert(fpsSamples, 1 / dt)
        if #fpsSamples > sampleLimit then table.remove(fpsSamples, 1) end
    end

    if (now - lastUpdate) >= UPDATE_INTERVAL then
        lastUpdate = now

        local sum = 0
        for _, v in ipairs(fpsSamples) do sum = sum + v end
        local avgFPS = math.floor(sum / math.max(#fpsSamples, 1))
        fpsLabel.Text = "FPS: " .. avgFPS
        fpsLabel.TextColor3 = getFPSColor(avgFPS)

        local ok, ping = pcall(function()
            return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok then
            pingLabel.Text = "PING: " .. ping .. "ms"
            pingLabel.TextColor3 = getPingColor(ping)
        end
    end
end)

-- â”€â”€â”€ Toggle UI with U â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local guiVisible = true

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.U then
        guiVisible = not guiVisible
        if win1 and win1.Parent then win1.Visible = guiVisible end
        if win2 and win2.Parent then win2.Visible = guiVisible end
        bottomBar.Visible = guiVisible
        progressBar.Visible = guiVisible
    end
end)
