-- Services requis
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration des touches et états
local CurrentKeybind = Enum.KeyCode.L
local IsChangingKeybind = false
local IsTeleportingHitbox = false -- Anti-spam pour la hitbox

-- --- SYSTÈME DE TOGGLE (DEUXIÈME SCRIPT) ---
local EspActive = false
local EspConnection = nil

local CONFIG_CIBLES = {
	["Dark Matter"]   = Color3.fromRGB(0, 0, 139),
	["Acid Barrel"]   = Color3.fromRGB(0, 100, 0),
	["Moon"]          = Color3.fromRGB(48, 25, 52),
	["Glitched Cube"] = Color3.fromRGB(75, 0, 130),
}

local function injectHighlight(objet)
	if objet:IsDescendantOf(game:GetService("CoreGui")) then return end
	local couleurAssociee = CONFIG_CIBLES[objet.Name]
	if couleurAssociee and (objet:IsA("BasePart") or objet:IsA("Model")) then
		if not objet:FindFirstChild("AntiCheatTestHighlight") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "AntiCheatTestHighlight"
			highlight.FillColor = couleurAssociee
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillTransparency = 0.4
			highlight.OutlineTransparency = 0
			highlight.Parent = objet
		end
	end
end

local function removeAllHighlights()
	for _, objet in pairs(game:GetDescendants()) do
		pcall(function()
			local hl = objet:FindFirstChild("AntiCheatTestHighlight")
			if hl then hl:Destroy() end
		end)
	end
end

local function toggleEsp(state)
	EspActive = state
	if EspActive then
		-- Scan initial
		for _, objet in pairs(game:GetDescendants()) do
			pcall(function() injectHighlight(objet) end)
		end
		-- Écoute des nouveaux objets
		EspConnection = game.DescendantAdded:Connect(function(nouvelObjet)
			task.defer(function()
				pcall(function() injectHighlight(nouvelObjet) end)
			end)
		end)
		print("[ESP] Activé")
	else
		-- Déconnexion et nettoyage
		if EspConnection then
			EspConnection:Disconnect()
			EspConnection = nil
		end
		removeAllHighlights()
		print("[ESP] Désactivé")
	end
end

-- --- SYSTÈME D'ANTI-DOUBLON ---
local ancienMenu = PlayerGui:FindFirstChild("GestionnaireMachineStylise")
if ancienMenu then
	ancienMenu:Destroy()
	print("[ANTI-DOUBLON] Ancien menu détruit.")
end

-- 1. CRÉATION DE L'INTERFACE PRINCIPALE (Agrandie à 370 pour faire place au Toggle)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GestionnaireMachineStylise"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 370)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- BARRE D'ONGLETS
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabBar

local TabMachineBtn = Instance.new("TextButton")
TabMachineBtn.Name = "TabMachineBtn"
TabMachineBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabMachineBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
TabMachineBtn.Text = "Trait Machine"
TabMachineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMachineBtn.Font = Enum.Font.GothamBold
TabMachineBtn.TextSize = 13
TabMachineBtn.Parent = TabBar

local TabSettingsBtn = Instance.new("TextButton")
TabSettingsBtn.Name = "TabSettingsBtn"
TabSettingsBtn.Size = UDim2.new(0.5, 0, 1, 0)
TabSettingsBtn.Position = UDim2.new(0.5, 0, 0, 0)
TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
TabSettingsBtn.Text = "Settings"
TabSettingsBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
TabSettingsBtn.Font = Enum.Font.GothamBold
TabSettingsBtn.TextSize = 13
TabSettingsBtn.Parent = TabBar

-- CONTENU : ONGLET MACHINE
local MachinePage = Instance.new("Frame")
MachinePage.Name = "MachinePage"
MachinePage.Size = UDim2.new(1, 0, 1, -40)
MachinePage.Position = UDim2.new(0, 0, 0, 40)
MachinePage.BackgroundTransparency = 1
MachinePage.Parent = MainFrame

local ActionButton = Instance.new("TextButton")
ActionButton.Name = "ActionButton"
ActionButton.Size = UDim2.new(0, 260, 0, 42)
ActionButton.Position = UDim2.new(0.5, -130, 0, 25)
ActionButton.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
ActionButton.Text = "Démarrer Machine"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.Font = Enum.Font.GothamMedium
ActionButton.TextSize = 14
ActionButton.Parent = MachinePage

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ActionButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(0, 150, 255)
ButtonStroke.Thickness = 1.5
ButtonStroke.Parent = ActionButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0, 260, 0, 42)
StatusLabel.Position = UDim2.new(0.5, -130, 0, 85)
StatusLabel.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
StatusLabel.Text = "Amount : Chargement..."
StatusLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 13
StatusLabel.Parent = MachinePage

local LabelCorner = Instance.new("UICorner")
LabelCorner.CornerRadius = UDim.new(0, 6)
LabelCorner.Parent = StatusLabel

local LabelStroke = Instance.new("UIStroke")
LabelStroke.Color = Color3.fromRGB(45, 45, 50)
LabelStroke.Thickness = 1
LabelStroke.Parent = StatusLabel

local ActionTextLabel = Instance.new("TextLabel")
ActionTextLabel.Name = "ActionTextLabel"
ActionTextLabel.Size = UDim2.new(0, 260, 0, 30)
ActionTextLabel.Position = UDim2.new(0.5, -130, 0, 140)
ActionTextLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
ActionTextLabel.Text = "Action : Chargement..."
ActionTextLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
ActionTextLabel.Font = Enum.Font.Gotham
ActionTextLabel.TextSize = 12
ActionTextLabel.Parent = MachinePage

local ActionTextCorner = Instance.new("UICorner")
ActionTextCorner.CornerRadius = UDim.new(0, 6)
ActionTextCorner.Parent = ActionTextLabel

local ActionTextStroke = Instance.new("UIStroke")
ActionTextStroke.Color = Color3.fromRGB(45, 45, 50)
ActionTextStroke.Thickness = 1
ActionTextStroke.Parent = ActionTextLabel

-- BOUTON : LOOT CLAIMED
local LootClaimedButton = Instance.new("TextButton")
LootClaimedButton.Name = "LootClaimedButton"
LootClaimedButton.Size = UDim2.new(0, 260, 0, 42)
LootClaimedButton.Position = UDim2.new(0.5, -130, 0, 190)
LootClaimedButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
LootClaimedButton.Text = "Claim Loot"
LootClaimedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LootClaimedButton.Font = Enum.Font.GothamBold
LootClaimedButton.TextSize = 14
LootClaimedButton.Parent = MachinePage

local LootCorner = Instance.new("UICorner")
LootCorner.CornerRadius = UDim.new(0, 6)
LootCorner.Parent = LootClaimedButton

local LootStroke = Instance.new("UIStroke")
LootStroke.Color = Color3.fromRGB(0, 210, 120)
LootStroke.Thickness = 1.5
LootStroke.Parent = LootClaimedButton

-- --- SECTION NOUVEAU TOGGLE : ESP HIGHLIGHT ---
local EspToggleFrame = Instance.new("Frame")
EspToggleFrame.Name = "EspToggleFrame"
EspToggleFrame.Size = UDim2.new(0, 260, 0, 42)
EspToggleFrame.Position = UDim2.new(0.5, -130, 0, 250)
EspToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
EspToggleFrame.Parent = MachinePage

local EspToggleCorner = Instance.new("UICorner")
EspToggleCorner.CornerRadius = UDim.new(0, 6)
EspToggleCorner.Parent = EspToggleFrame

local EspToggleStroke = Instance.new("UIStroke")
EspToggleStroke.Color = Color3.fromRGB(45, 45, 50)
EspToggleStroke.Thickness = 1
EspToggleStroke.Parent = EspToggleFrame

local EspLabel = Instance.new("TextLabel")
EspLabel.Size = UDim2.new(0, 150, 1, 0)
EspLabel.Position = UDim2.new(0, 12, 0, 0)
EspLabel.BackgroundTransparency = 1
EspLabel.Text = "Activer ESP Items"
EspLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
EspLabel.Font = Enum.Font.GothamMedium
EspLabel.TextSize = 13
EspLabel.TextXAlignment = Enum.TextXAlignment.Left
EspLabel.Parent = EspToggleFrame

local EspButton = Instance.new("TextButton")
EspButton.Name = "EspButton"
EspButton.Size = UDim2.new(0, 60, 0, 26)
EspButton.Position = UDim2.new(1, -72, 0.5, -13)
EspButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
EspButton.Text = "OFF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.Font = Enum.Font.GothamBold
EspButton.TextSize = 12
EspButton.Parent = EspToggleFrame

local EspBtnCorner = Instance.new("UICorner")
EspBtnCorner.CornerRadius = UDim.new(0, 13)
EspBtnCorner.Parent = EspButton

EspButton.MouseButton1Click:Connect(function()
	local newState = not EspActive
	toggleEsp(newState)
	
	if newState then
		EspButton.Text = "ON"
		EspButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		EspButton.Text = "OFF"
		EspButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	end
end)

-- CONTENU : ONGLET SETTINGS
local SettingsPage = Instance.new("Frame")
SettingsPage.Name = "SettingsPage"
SettingsPage.Size = UDim2.new(1, 0, 1, -40)
SettingsPage.Position = UDim2.new(0, 0, 0, 40)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = MainFrame

local KeybindTitle = Instance.new("TextLabel")
KeybindTitle.Size = UDim2.new(0, 130, 0, 40)
KeybindTitle.Position = UDim2.new(0, 20, 0, 30)
KeybindTitle.BackgroundTransparency = 1
KeybindTitle.Text = "Menu Raccourci :"
KeybindTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
KeybindTitle.Font = Enum.Font.Gotham
KeybindTitle.TextSize = 14
KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
KeybindTitle.Parent = SettingsPage

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Name = "KeybindBtn"
KeybindBtn.Size = UDim2.new(0, 100, 0, 36)
KeybindBtn.Position = UDim2.new(1, -120, 0, 32)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
KeybindBtn.Text = "L"
KeybindBtn.TextColor3 = Color3.fromRGB(0, 220, 130)
KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.TextSize = 13
KeybindBtn.Parent = SettingsPage

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 6)
KeybindCorner.Parent = KeybindBtn

-- 2. RÉCUPÉRATION EN TEMPS RÉEL DE LA VALEUR "AMOUNT"
task.spawn(function()
	local map = Workspace:WaitForChild("Map", 5)
	local tm1 = map and map:WaitForChild("Trait Machine", 3)
	local tm2 = tm1 and tm1:WaitForChild("Trait Machine", 3)
	local marker = tm2 and tm2:WaitForChild("Marker", 3)
	local title = marker and marker:WaitForChild("Title", 3)
	local bGui = title and title:WaitForChild("BillboardGui", 3)
	local tFrame = bGui and bGui:WaitForChild("TimerFrame", 3)
	local amountTarget = tFrame and tFrame:WaitForChild("Amount", 3)

	if amountTarget and (amountTarget:IsA("TextLabel") or amountTarget:IsA("TextBox")) then
		local function updateText()
			StatusLabel.Text = "Amount : " .. amountTarget.Text
		end
		updateText()
		amountTarget:GetPropertyChangedSignal("Text"):Connect(updateText)
	else
		StatusLabel.Text = "Amount : Introuvable"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	end
end)

-- 3. RÉCUPÉRATION DU ActionText DU PROXIMITYPROMPT
task.spawn(function()
	local success, err = pcall(function()
		local prompt = Workspace:FindFirstChild("Map"):FindFirstChild("Trait Machine"):FindFirstChild("Trait Machine"):FindFirstChild("Marker"):FindFirstChild("Prompt"):FindFirstChild("ProximityPrompt")
		if prompt then
			local function updateActionText()
				ActionTextLabel.Text = "Action : " .. prompt.ActionText
			end
			updateActionText()
			prompt:GetPropertyChangedSignal("ActionText"):Connect(updateActionText)
		else
			ActionTextLabel.Text = "Action : Prompt non trouvé"
			ActionTextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	end)

	if not success then
		ActionTextLabel.Text = "Action : Erreur"
		ActionTextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

-- 4. LOGIQUE VISUELLE DES ONGLETS
TabMachineBtn.MouseButton1Click:Connect(function()
	MachinePage.Visible = true
	SettingsPage.Visible = false
	TabMachineBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	TabMachineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	TabSettingsBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
end)

TabSettingsBtn.MouseButton1Click:Connect(function()
	MachinePage.Visible = false
	SettingsPage.Visible = true
	TabMachineBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	TabMachineBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
	TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	TabSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- 5. LOGIQUE DE GLISSER-DÉPOSER DU MENU (DRAG)
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- 6. CONFIGURATION DU KEYBIND ET OUVERTURE DU MENU
KeybindBtn.MouseButton1Click:Connect(function()
	IsChangingKeybind = true
	KeybindBtn.Text = "..."
	KeybindBtn.TextColor3 = Color3.fromRGB(255, 165, 0)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if IsChangingKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			CurrentKeybind = input.KeyCode
			IsChangingKeybind = false
			KeybindBtn.Text = input.KeyCode.Name
			KeybindBtn.TextColor3 = Color3.fromRGB(0, 220, 130)
		end
		return
	end

	if not gameProcessed and input.KeyCode == CurrentKeybind then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

-- 7. LOGIQUE DES BOUTONS REMOTEEVENTS
-- Bouton Action Principal (Démarrer Machine)
ActionButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return end

	local serverFolder = remotes:FindFirstChild("Server")
	local traitMachineEvent = serverFolder and serverFolder:FindFirstChild("TraitMachineStart")
	if traitMachineEvent and traitMachineEvent:IsA("RemoteEvent") then
		traitMachineEvent:FireServer()
		print("[RESEAU] TraitMachineStart envoyé au serveur.")
	else
		warn("[RESEAU] TraitMachineStart introuvable.")
	end
end)

-- LOGIQUE DU BOUTON LOOT CLAIMED + DÉPLACEMENT DE LA HITBOX
LootClaimedButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local clientFolder = remotes:FindFirstChild("Client")
		local lootEvent = clientFolder and clientFolder:FindFirstChild("LootClaimed")
		if lootEvent and lootEvent:IsA("RemoteEvent") then
			lootEvent:FireServer()
			print("[REMOTE] LootClaimed déclenché.")
		end
	end

	if IsTeleportingHitbox then return end

	local map = Workspace:FindFirstChild("Map")
	local markers = map and map:FindFirstChild("Markers")
	local hitbox = markers and markers:FindFirstChild("ClaimHitbox")

	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if hitbox and hitbox:IsA("BasePart") and hrp then
		IsTeleportingHitbox = true
		local originalCFrame = hitbox.CFrame
		hitbox.CFrame = hrp.CFrame
		print("[HITBOX] ClaimHitbox déplacée sur le joueur.")

		task.delay(3, function()
			hitbox.CFrame = originalCFrame
			IsTeleportingHitbox = false
			print("[HITBOX] ClaimHitbox remise à sa place d'origine.")
		end)
	else
		warn("[HITBOX] Impossible de déplacer la pièce (ClaimHitbox ou HumanoidRootPart manquante).")
	end
end)

-- Effets visuels Interactifs (Hover)
ActionButton.MouseEnter:Connect(function()
	ActionButton.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
	ButtonStroke.Color = Color3.fromRGB(0, 180, 255)
end)

ActionButton.MouseLeave:Connect(function()
	ActionButton.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
	ButtonStroke.Color = Color3.fromRGB(0, 150, 255)
end)

LootClaimedButton.MouseEnter:Connect(function()
	LootClaimedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
	LootStroke.Color = Color3.fromRGB(0, 240, 140)
end)

LootClaimedButton.MouseLeave:Connect(function()
	LootClaimedButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	LootStroke.Color = Color3.fromRGB(0, 210, 120)
end)
