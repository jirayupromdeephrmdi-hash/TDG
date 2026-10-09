-- MultiGame Hub v7.0 | Compact Edition
if _G.MGH then warn("MGH ทำงานอยู่แล้ว!"); return end
_G.MGH = true

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local Cam = workspace.CurrentCamera

-- Config
local C = {
    ESP = {On=true, Box=true, HP=true, Name=true, Dist=true, Team=false, Wall=false, MaxDist=1500, Color=Color3.fromRGB(0,255,0)},
    Aim = {On=false, FOV=150, MaxDist=500, Team=true, Wall=false, ShowFOV=true, ShowLine=true},
    Misc = {Ammo=false, Stamina=false}
}

-- ============ LOADING ============
local LG = Instance.new("ScreenGui")
LG.Name = "MGH_Load"
LG.IgnoreGuiInset = true
LG.ResetOnSpawn = false
LG.DisplayOrder = 9999
LG.Parent = LP:WaitForChild("PlayerGui")

local BG = Instance.new("Frame")
BG.Size = UDim2.new(1,0,1,0)
BG.BackgroundColor3 = Color3.fromRGB(10,10,15)
BG.BorderSizePixel = 0
BG.Parent = LG

local Box = Instance.new("Frame")
Box.Size = UDim2.new(0,340,0,180)
Box.Position = UDim2.new(0.5,-170,0.5,-90)
Box.BackgroundColor3 = Color3.fromRGB(20,20,30)
Box.BorderSizePixel = 0
Box.Parent = BG
local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,14); BC.Parent = Box
local BS = Instance.new("UIStroke"); BS.Color = Color3.fromRGB(0,150,255); BS.Thickness = 2; BS.Parent = Box

local LT = Instance.new("TextLabel")
LT.Size = UDim2.new(1,0,0,50)
LT.Position = UDim2.new(0,0,0,25)
LT.BackgroundTransparency = 1
LT.Text = "MULTIGAME HUB"
LT.TextColor3 = Color3.fromRGB(0,150,255)
LT.Font = Enum.Font.GothamBold
LT.TextSize = 26
LT.Parent = Box

local ST = Instance.new("TextLabel")
ST.Size = UDim2.new(1,0,0,20)
ST.Position = UDim2.new(0,0,0,75)
ST.BackgroundTransparency = 1
ST.Text = "v7.0 | กำลังโหลด..."
ST.TextColor3 = Color3.fromRGB(200,200,210)
ST.Font = Enum.Font.Gotham
ST.TextSize = 12
ST.Parent = Box

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(1,-60,0,6)
BarBG.Position = UDim2.new(0,30,0,120)
BarBG.BackgroundColor3 = Color3.fromRGB(40,40,50)
BarBG.BorderSizePixel = 0
BarBG.Parent = Box
local BBC = Instance.new("UICorner"); BBC.CornerRadius = UDim.new(1,0); BBC.Parent = BarBG

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 = Color3.fromRGB(0,150,255)
Bar.BorderSizePixel = 0
Bar.Parent = BarBG
local BC2 = Instance.new("UICorner"); BC2.CornerRadius = UDim.new(1,0); BC2.Parent = Bar

local Pct = Instance.new("TextLabel")
Pct.Size = UDim2.new(1,0,0,20)
Pct.Position = UDim2.new(0,0,0,140)
Pct.BackgroundTransparency = 1
Pct.Text = "0%"
Pct.TextColor3 = Color3.fromRGB(0,150,255)
Pct.Font = Enum.Font.GothamBold
Pct.TextSize = 12
Pct.Parent = Box

local function SetLoad(p, t)
    Bar.Size = UDim2.new(p/100,0,1,0)
    Pct.Text = p .. "%"
    if t then ST.Text = t end
end

task.spawn(function()
    SetLoad(20, "กำลังเริ่ม ESP..."); task.wait(0.3)
    SetLoad(45, "กำลังสร้าง FOV..."); task.wait(0.3)
    SetLoad(70, "กำลังโหลด UI..."); task.wait(0.3)
    SetLoad(100, "พร้อมใช้งาน!"); task.wait(0.4)
    LG:Destroy()
end)

-- ============ ESP ============
local EOBJ = {}

local function IsVis(ch)
    local o = Cam.CFrame.Position
    local t = ch.HumanoidRootPart.Position
    local ray = Ray.new(o, (t-o).Unit * (t-o).Magnitude)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, ch})
    return hit == nil
end

local function CreateE(p)
    if p == LP then return end
    local box = Drawing.new("Square"); box.Thickness=1.5; box.Filled=false; box.Visible=false
    local hb = Drawing.new("Line"); hb.Thickness=3; hb.Visible=false
    local hbg = Drawing.new("Line"); hbg.Thickness=3; hbg.Color=Color3.fromRGB(0,0,0); hbg.Visible=false
    local nt = Drawing.new("Text"); nt.Size=14; nt.Center=true; nt.Outline=true; nt.Color=Color3.fromRGB(255,255,255); nt.Visible=false
    local dt = Drawing.new("Text"); dt.Size=12; dt.Center=true; dt.Outline=true; dt.Color=Color3.fromRGB(255,255,0); dt.Visible=false
    EOBJ[p] = {Box=box, HB=hb, HBg=hbg, Name=nt, Dist=dt}
end

P.PlayerRemoving:Connect(function(p)
    if EOBJ[p] then
        for _,o in pairs(EOBJ[p]) do pcall(function() o:Remove() end) end
        EOBJ[p] = nil
    end
end)

local function UpdateESP()
    if not C.ESP.On then
        for _,objs in pairs(EOBJ) do for _,o in pairs(objs) do o.Visible=false end end
        return
    end
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if C.ESP.Team and p.Team == LP.Team then
                if EOBJ[p] then for _,o in pairs(EOBJ[p]) do o.Visible=false end end
                continue
            end
            if not EOBJ[p] then CreateE(p) end
            local objs = EOBJ[p]
            local ch = p.Character
            local root = ch.HumanoidRootPart
            local hum = ch.Humanoid

            if hum.Health <= 0 then
                for _,o in pairs(objs) do o.Visible=false end
                continue
            end

            local dist = (root.Position - Cam.CFrame.Position).Magnitude
            if dist > C.ESP.MaxDist or (C.ESP.Wall and not IsVis(ch)) then
                for _,o in pairs(objs) do o.Visible=false end
                continue
            end

            local sp, on = Cam:WorldToViewportPoint(root.Position)
            if not on then
                for _,o in pairs(objs) do o.Visible=false end
                continue
            end

            local hp = Cam:WorldToViewportPoint(ch.Head.Position)
            local h = math.abs(hp.Y - sp.Y) * 1.6
            local w = h * 0.55

            if C.ESP.Box then
                objs.Box.Size = Vector2.new(w, h)
                objs.Box.Position = Vector2.new(sp.X - w/2, sp.Y - h/2)
                objs.Box.Color = C.ESP.Color
                objs.Box.Visible = true
            else objs.Box.Visible = false end

            if C.ESP.HP then
                local pct = hum.Health / hum.MaxHealth
                local bx = sp.X - w/2 - 6
                objs.HBg.From = Vector2.new(bx, sp.Y - h/2)
                objs.HBg.To = Vector2.new(bx, sp.Y + h/2)
                objs.HBg.Visible = true
                objs.HB.From = Vector2.new(bx, sp.Y + h/2 - (h*pct))
                objs.HB.To = Vector2.new(bx, sp.Y + h/2)
                objs.HB.Color = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0)
                objs.HB.Visible = true
            else objs.HB.Visible = false; objs.HBg.Visible = false end

            if C.ESP.Name then
                objs.Name.Text = p.Name
                objs.Name.Position = Vector2.new(sp.X, sp.Y - h/2 - 18)
                objs.Name.Visible = true
            else objs.Name.Visible = false end

            if C.ESP.Dist then
                objs.Dist.Text = string.format("[%d]", math.floor(dist))
                objs.Dist.Position = Vector2.new(sp.X, sp.Y + h/2 + 4)
                objs.Dist.Visible = true
            else objs.Dist.Visible = false end
        end
    end
end

-- ============ FOV + AIM ============
local FOV = Drawing.new("Circle")
FOV.Thickness = 1.5
FOV.Color = Color3.fromRGB(255,255,255)
FOV.Filled = false
FOV.NumSides = 80
FOV.Transparency = 0.6
FOV.Visible = false

local TL = Drawing.new("Line")
TL.Thickness = 1.5
TL.Color = Color3.fromRGB(255,0,0)
TL.Visible = false

local function HoldWeapon()
    local ch = LP.Character
    if not ch then return false end
    return ch:FindFirstChildOfClass("Tool") ~= nil
end

local function GetTgt()
    local cl, sh = nil, C.Aim.FOV
    local ctr = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _, p in pairs(P:GetPlayers()) do
        if p == LP then continue end
        if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then continue end
        local hum = p.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if C.Aim.Team and p.Team == LP.Team then continue end

        local root = p.Character.HumanoidRootPart
        local d = (root.Position - Cam.CFrame.Position).Magnitude
        if d > C.Aim.MaxDist then continue end
        if C.Aim.Wall and not IsVis(p.Character) then continue end

        local sp, on = Cam:WorldToViewportPoint(root.Position)
        if not on then continue end
        local d2 = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
        if d2 < sh then cl = p; sh = d2 end
    end
    return cl
end

local function UpdateAim()
    if not C.Aim.On or not HoldWeapon() then
        TL.Visible = false
        return
    end
    local t = GetTgt()
    if t then
        local sp, on = Cam:WorldToViewportPoint(t.Character.HumanoidRootPart.Position)
        if C.Aim.ShowLine and on then
            TL.From = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
            TL.To = Vector2.new(sp.X, sp.Y)
            TL.Visible = true
        else TL.Visible = false end
    else TL.Visible = false end
end

-- ============ MISC ============
local function InfAmmo()
    local ch = LP.Character
    if not ch then return end
    local tool = ch:FindFirstChildOfClass("Tool")
    if tool then
        for _, o in pairs(tool:GetDescendants()) do
            if o:IsA("IntValue") or o:IsA("NumberValue") then
                local n = o.Name:lower()
                if n:find("ammo") or n:find("clip") or n:find("mag") or n:find("bullet") then
                    pcall(function() o.Value = 999 end)
                end
            end
        end
    end
end

local function InfStam()
    local ch = LP.Character
    if not ch then return end
    for _, o in pairs(ch:GetDescendants()) do
        if o:IsA("IntValue") or o:IsA("NumberValue") then
            local n = o.Name:lower()
            if n:find("stamina") or n:find("energy") or n:find("stam") then
                pcall(function() o.Value = o.Value + 100 end)
            end
        end
    end
end

-- ============ TOGGLE UI BUTTON ============
local TG = Instance.new("ScreenGui")
TG.Name = "MGH_Btn"
TG.IgnoreGuiInset = true
TG.ResetOnSpawn = false
TG.DisplayOrder = 1000
TG.Parent = LP:WaitForChild("PlayerGui")

local TB = Instance.new("TextButton")
TB.Size = UDim2.new(0,60,0,60)
TB.Position = UDim2.new(0,15,0.5,-30)
TB.BackgroundColor3 = Color3.fromRGB(10,10,15)
TB.Text = "MGH"
TB.TextColor3 = Color3.fromRGB(0,150,255)
TB.Font = Enum.Font.GothamBold
TB.TextSize = 16
TB.BorderSizePixel = 0
TB.Parent = TG
local TBC = Instance.new("UICorner"); TBC.CornerRadius = UDim.new(1,0); TBC.Parent = TB
local TBS = Instance.new("UIStroke"); TBS.Color = Color3.fromRGB(0,150,255); TBS.Thickness = 2.5; TBS.Parent = TB

local RGui = nil
local UIOpen = true

TB.MouseButton1Click:Connect(function()
    UIOpen = not UIOpen
    if RGui then RGui.Enabled = UIOpen end
    TBS.Color = UIOpen and Color3.fromRGB(0,150,255) or Color3.fromRGB(255,30,50)
end)

-- Drag Button
local drag, ds, sp
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true; ds = i.Position; sp = TB.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)
U.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = i.Position - ds
        TB.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)

-- ============ MAIN LOOP ============
R.RenderStepped:Connect(function()
    pcall(UpdateESP)
    pcall(UpdateAim)
    FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    FOV.Radius = C.Aim.FOV
    FOV.Visible = C.Aim.ShowFOV and C.Aim.On
end)

R.Heartbeat:Connect(function()
    if C.Misc.Ammo then pcall(InfAmmo) end
    if C.Misc.Stamina then pcall(InfStam) end
end)

U.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F1 then C.ESP.On = not C.ESP.On
    elseif i.KeyCode == Enum.KeyCode.F2 then C.Aim.On = not C.Aim.On
    elseif i.KeyCode == Enum.KeyCode.F3 then C.Misc.Ammo = not C.Misc.Ammo
    elseif i.KeyCode == Enum.KeyCode.F4 then C.Misc.Stamina = not C.Misc.Stamina end
end)

-- ============ RAYFIELD UI ============
task.wait(2)

pcall(function()
    local Ray = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local W = Ray:CreateWindow({
        Name = "MultiGame Hub v7.0",
        LoadingTitle = "MultiGame Hub",
        LoadingSubtitle = "Compact Edition",
        ConfigurationSaving = {Enabled = false},
        KeySystem = false
    })

    task.spawn(function()
        for _, g in pairs(game.CoreGui:GetChildren()) do
            if g.Name:find("Rayfield") then RGui = g; break end
        end
    end)

    local M = W:CreateTab("Main", 4483362458)
    M:CreateParagraph({Title = "ปุ่มลัด", Content = "F1=ESP | F2=Aim | F3=Ammo | F4=Stamina\nแตะ MGH = Toggle UI"})
    M:CreateButton({Name = "Toggle UI", Callback = function()
        UIOpen = not UIOpen
        if RGui then RGui.Enabled = UIOpen end
    end})

    local E = W:CreateTab("ESP", 4483362458)
    E:CreateToggle({Name="ESP On", CurrentValue=true, Callback=function(v) C.ESP.On=v end})
    E:CreateToggle({Name="Box", CurrentValue=true, Callback=function(v) C.ESP.Box=v end})
    E:CreateToggle({Name="Health", CurrentValue=true, Callback=function(v) C.ESP.HP=v end})
    E:CreateToggle({Name="Name", CurrentValue=true, Callback=function(v) C.ESP.Name=v end})
    E:CreateToggle({Name="Distance", CurrentValue=true, Callback=function(v) C.ESP.Dist=v end})
    E:CreateToggle({Name="Team Check", CurrentValue=false, Callback=function(v) C.ESP.Team=v end})
    E:CreateToggle({Name="Wall Check", CurrentValue=false, Callback=function(v) C.ESP.Wall=v end})
    E:CreateSlider({Name="Max Distance", Range={100,5000}, Increment=100, Suffix=" studs", CurrentValue=1500, Callback=function(v) C.ESP.MaxDist=v end})

    local A = W:CreateTab("Aim (FOV)", 4483362458)
    A:CreateToggle({Name="Aim On", CurrentValue=false, Callback=function(v) C.Aim.On=v end})
    A:CreateToggle({Name="Show FOV", CurrentValue=true, Callback=function(v) C.Aim.ShowFOV=v end})
    A:CreateToggle({Name="Show Target Line", CurrentValue=true, Callback=function(v) C.Aim.ShowLine=v end})
    A:CreateToggle({Name="Team Check", CurrentValue=true, Callback=function(v) C.Aim.Team=v end})
    A:CreateToggle({Name="Wall Check", CurrentValue=false, Callback=function(v) C.Aim.Wall=v end})
    A:CreateSlider({Name="FOV Radius", Range={30,500}, Increment=10, Suffix=" px", CurrentValue=150, Callback=function(v) C.Aim.FOV=v end})
    A:CreateSlider({Name="Max Distance", Range={50,2000}, Increment=50, Suffix=" studs", CurrentValue=500, Callback=function(v) C.Aim.MaxDist=v end})

    local Mi = W:CreateTab("Misc", 4483362458)
    Mi:CreateToggle({Name="Infinite Ammo", CurrentValue=false, Callback=function(v) C.Misc.Ammo=v end})
    Mi:CreateToggle({Name="Infinite Stamina", CurrentValue=false, Callback=function(v) C.Misc.Stamina=v end})

    Ray:Notify({Title="MultiGame Hub v7.0", Content="โหลดสำเร็จ!", Duration=5, Image=4483362458})
end)

print("[MultiGame Hub v7.0] โหลดเสร็จสิ้น")
