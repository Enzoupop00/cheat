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
local IsTeleportingHitbox = false 

-- --- SYSTÈME DE TOGGLE : ESP ---
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
		for _, objet in pairs(game:GetDescendants()) do
			pcall(function() injectHighlight(objet) end)
		end
		EspConnection = game.DescendantAdded:Connect(function(nouvelObjet)
			task.defer(function()
				pcall(function() injectHighlight(nouvelObjet) end)
			end)
		end)
		print("[ESP] Activé")
	else
		if EspConnection then
			EspConnection:Disconnect()
			EspConnection = nil
		end
		removeAllHighlights()
		print("[ESP] Désactivé")
	end
end

-- --- SYSTÈME DE TOGGLE : AUTO TP (15 / 15) ---
local AutoTpActive = false
local AutoTpConnection = nil

local function checkAndTeleport(text)
	local cleanText = string.gsub(text, "%s+", "")
	if cleanText == "15/15" then
		local character = LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		
		local spawnpoint = Workspace:FindFirstChild("Map") 
			and Workspace.Map:FindFirstChild("Markers") 
			and Workspace.Map.Markers:FindFirstChild("Spawnpoint")
		
		if hrp and spawnpoint and spawnpoint:IsA("BasePart") then
			hrp.CFrame = spawnpoint.CFrame
			print("[AUTO-TP] Inventaire plein (15/15) ! Téléportation au Spawnpoint.")
		end
	end
end

local function toggleAutoTp(state)
	AutoTpActive = state
	if AutoTpActive then
		print("[AUTO-TP] Activé")
		task.spawn(function()
			local mainGui = PlayerGui:WaitForChild("Main", 5)
			local wins = mainGui and mainGui:WaitForChild("Wins", 5)
			local backpackFrame = wins and wins:WaitForChild("BackpackFrame", 5)
			local amountLabel = backpackFrame and backpackFrame:WaitForChild("Amount", 5)
			
			if amountLabel and (amountLabel:IsA("TextLabel") or amountLabel:IsA("TextBox")) then
				checkAndTeleport(amountLabel.Text)
				AutoTpConnection = amountLabel:GetPropertyChangedSignal("Text"):Connect(function()
					if AutoTpActive then
						checkAndTeleport(amountLabel.Text)
					end
				end)
			else
				warn("[AUTO-TP] UI 'Amount' introuvable.")
			end
		end)
	else
		print("[AUTO-TP] Désactivé")
		if AutoTpConnection then
			AutoTpConnection:Disconnect()
			AutoTpConnection = nil
		end
	end
end

-- --- SYSTÈME D'ANTI-DOUBLON ---
local ancienMenu = PlayerGui:FindFirstChild("GestionnaireMachineStylise")
if ancienMenu then
	ancienMenu:Destroy()
	print("[ANTI-DOUBLON] Ancien menu détruit.")
end

-- 1. CRÉATION DE L'INTERFACE PRINCIPALE HAUTE QUALITÉ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GestionnaireMachineStylise"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 480)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 40)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- BARRE D'ONGLETS (HEADER)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 42)
TabBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 12)
TabCorner.Parent = TabBar

local TabMachineBtn = Instance.new("TextButton")
TabMachineBtn.Name = "TabMachineBtn"
TabMachineBtn.Size = UDim2.new(0, 120, 1, 0)
TabMachineBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
TabMachineBtn.Text = "Options Hub"
TabMachineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMachineBtn.Font = Enum.Font.GothamBold
TabMachineBtn.TextSize = 13
TabMachineBtn.Parent = TabBar

local TabSettingsBtn = Instance.new("TextButton")
TabSettingsBtn.Name = "TabSettingsBtn"
TabSettingsBtn.Size = UDim2.new(0, 100, 1, 0)
TabSettingsBtn.Position = UDim2.new(0, 120, 0, 0)
TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TabSettingsBtn.Text = "Settings"
TabSettingsBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
TabSettingsBtn.Font = Enum.Font.GothamBold
TabSettingsBtn.TextSize = 13
TabSettingsBtn.Parent = TabBar

local CloseMenuBtn = Instance.new("TextButton")
CloseMenuBtn.Name = "CloseMenuBtn"
CloseMenuBtn.Size = UDim2.new(0, 28, 0, 26)
CloseMenuBtn.Position = UDim2.new(1, -36, 0.5, -13)
CloseMenuBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseMenuBtn.Text = "✕"
CloseMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseMenuBtn.Font = Enum.Font.GothamBold
CloseMenuBtn.TextSize = 11
CloseMenuBtn.Parent = TabBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseMenuBtn

-- PAGINATION : PAGE MACHINE / HUB PRINCIPAL
local MachinePage = Instance.new("ScrollingFrame")
MachinePage.Name = "MachinePage"
MachinePage.Size = UDim2.new(1, 0, 1, -42)
MachinePage.Position = UDim2.new(0, 0, 0, 42)
MachinePage.BackgroundTransparency = 1
MachinePage.BorderSizePixel = 0
MachinePage.CanvasSize = UDim2.new(0, 0, 0, 440)
MachinePage.ScrollBarThickness = 2
MachinePage.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
MachinePage.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MachinePage
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = MachinePage
UIPadding.PaddingTop = UDim.new(0, 12)

-- --- SECTION 1 : GESTION TRAIT MACHINE ---
local Sect1Title = Instance.new("TextLabel")
Sect1Title.Size = UDim2.new(0, 270, 0, 18)
Sect1Title.BackgroundTransparency = 1
Sect1Title.Text = "📊 GESTION MACHINE"
Sect1Title.TextColor3 = Color3.fromRGB(0, 160, 255)
Sect1Title.Font = Enum.Font.GothamBold
Sect1Title.TextSize = 11
Sect1Title.TextXAlignment = Enum.TextXAlignment.Left
Sect1Title.Parent = MachinePage

local ActionButton = Instance.new("TextButton")
ActionButton.Name = "ActionButton"
ActionButton.Size = UDim2.new(0, 270, 0, 36)
ActionButton.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
ActionButton.Text = "Démarrer Machine"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.Font = Enum.Font.GothamMedium
ActionButton.TextSize = 13
ActionButton.Parent = MachinePage

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ActionButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 270, 0, 32)
StatusLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
StatusLabel.Text = "Amount : Chargement..."
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.Parent = MachinePage

local LabelCorner = Instance.new("UICorner")
LabelCorner.CornerRadius = UDim.new(0, 6)
LabelCorner.Parent = StatusLabel

local ActionTextLabel = Instance.new("TextLabel")
ActionTextLabel.Size = UDim2.new(0, 270, 0, 24)
ActionTextLabel.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
ActionTextLabel.Text = "Action : Chargement..."
ActionTextLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
ActionTextLabel.Font = Enum.Font.Gotham
ActionTextLabel.TextSize = 11
ActionTextLabel.Parent = MachinePage

local ActionTextCorner = Instance.new("UICorner")
ActionTextCorner.CornerRadius = UDim.new(0, 6)
ActionTextCorner.Parent = ActionTextLabel

local LootClaimedButton = Instance.new("TextButton")
LootClaimedButton.Name = "LootClaimedButton"
LootClaimedButton.Size = UDim2.new(0, 270, 0, 36)
LootClaimedButton.BackgroundColor3 = Color3.fromRGB(0, 160, 90)
LootClaimedButton.Text = "🎁 Claim Loot + Hitbox"
LootClaimedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LootClaimedButton.Font = Enum.Font.GothamBold
LootClaimedButton.TextSize = 13
LootClaimedButton.Parent = MachinePage

local LootCorner = Instance.new("UICorner")
LootCorner.CornerRadius = UDim.new(0, 6)
LootCorner.Parent = LootClaimedButton


-- --- SECTION 2 : ACTIONS RAPIDES & VENTES ---
local Sect2Title = Instance.new("TextLabel")
Sect2Title.Size = UDim2.new(0, 270, 0, 18)
Sect2Title.BackgroundTransparency = 1
Sect2Title.Text = "⚡ ACTIONS RAPIDES"
Sect2Title.TextColor3 = Color3.fromRGB(230, 130, 10)
Sect2Title.Font = Enum.Font.GothamBold
Sect2Title.TextSize = 11
Sect2Title.TextXAlignment = Enum.TextXAlignment.Left
Sect2Title.Parent = MachinePage

-- Ligne double boutons (UI de vente & Remote Vente)
local SaleRowFrame = Instance.new("Frame")
SaleRowFrame.Size = UDim2.new(0, 270, 0, 34)
SaleRowFrame.BackgroundTransparency = 1
SaleRowFrame.Parent = MachinePage

local OpenSaleUiButton = Instance.new("TextButton")
OpenSaleUiButton.Size = UDim2.new(0, 130, 1, 0)
OpenSaleUiButton.BackgroundColor3 = Color3.fromRGB(110, 20, 170)
OpenSaleUiButton.Text = "Ouvrir Vente UI"
OpenSaleUiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenSaleUiButton.Font = Enum.Font.GothamMedium
OpenSaleUiButton.TextSize = 12
OpenSaleUiButton.Parent = SaleRowFrame

local SaleUiCorner = Instance.new("UICorner")
SaleUiCorner.CornerRadius = UDim.new(0, 6)
SaleUiCorner.Parent = OpenSaleUiButton

local SellAllRemoteButton = Instance.new("TextButton")
SellAllRemoteButton.Size = UDim2.new(0, 134, 1, 0)
SellAllRemoteButton.Position = UDim2.new(0, 136, 0, 0)
SellAllRemoteButton.BackgroundColor3 = Color3.fromRGB(180, 90, 10)
SellAllRemoteButton.Text = "Tout Vendre (Remote)"
SellAllRemoteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SellAllRemoteButton.Font = Enum.Font.GothamMedium
SellAllRemoteButton.TextSize = 11
SellAllRemoteButton.Parent = SaleRowFrame

local SellRemoteCorner = Instance.new("UICorner")
SellRemoteCorner.CornerRadius = UDim.new(0, 6)
SellRemoteCorner.Parent = SellAllRemoteButton

-- **NOUVEAU BOUTON : HIT WALL**
local HitWallButton = Instance.new("TextButton")
HitWallButton.Name = "HitWallButton"
HitWallButton.Size = UDim2.new(0, 270, 0, 36)
HitWallButton.BackgroundColor3 = Color3.fromRGB(180, 30, 60)
HitWallButton.Text = "💥 Activer Hit Wall (Remote)"
HitWallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HitWallButton.Font = Enum.Font.GothamBold
HitWallButton.TextSize = 13
HitWallButton.Parent = MachinePage

local HitWallCorner = Instance.new("UICorner")
HitWallCorner.CornerRadius = UDim.new(0, 6)
HitWallCorner.Parent = HitWallButton


-- --- SECTION 3 : OPTIONS & TOGGLES AUTOMATIQUES ---
local Sect3Title = Instance.new("TextLabel")
Sect3Title.Size = UDim2.new(0, 270, 0, 18)
Sect3Title.BackgroundTransparency = 1
Sect3Title.Text = "⚙️ AUTOMATISATIONS"
Sect3Title.TextColor3 = Color3.fromRGB(0, 200, 120)
Sect3Title.Font = Enum.Font.GothamBold
Sect3Title.TextSize = 11
Sect3Title.TextXAlignment = Enum.TextXAlignment.Left
Sect3Title.Parent = MachinePage

-- ESP Toggle
local EspToggleFrame = Instance.new("Frame")
EspToggleFrame.Size = UDim2.new(0, 270, 0, 34)
EspToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
EspToggleFrame.Parent = MachinePage

local EspToggleCorner = Instance.new("UICorner")
EspToggleCorner.CornerRadius = UDim.new(0, 6)
EspToggleCorner.Parent = EspToggleFrame

local EspLabel = Instance.new("TextLabel")
EspLabel.Size = UDim2.new(0, 160, 1, 0)
EspLabel.Position = UDim2.new(0, 10, 0, 0)
EspLabel.BackgroundTransparency = 1
EspLabel.Text = "Activer ESP Items"
EspLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
EspLabel.Font = Enum.Font.GothamMedium
EspLabel.TextSize = 12
EspLabel.TextXAlignment = Enum.TextXAlignment.Left
EspLabel.Parent = EspToggleFrame

local EspButton = Instance.new("TextButton")
EspButton.Size = UDim2.new(0, 56, 0, 22)
EspButton.Position = UDim2.new(1, -66, 0.5, -11)
EspButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
EspButton.Text = "OFF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.Font = Enum.Font.GothamBold
EspButton.TextSize = 11
EspButton.Parent = EspToggleFrame

local EspBtnCorner = Instance.new("UICorner")
EspBtnCorner.CornerRadius = UDim.new(0, 11)
EspBtnCorner.Parent = EspButton

-- Auto TP Toggle
local AutoTpToggleFrame = Instance.new("Frame")
AutoTpToggleFrame.Size = UDim2.new(0, 270, 0, 34)
AutoTpToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
AutoTpToggleFrame.Parent = MachinePage

local AutoTpToggleCorner = Instance.new("UICorner")
AutoTpToggleCorner.CornerRadius = UDim.new(0, 6)
AutoTpToggleCorner.Parent = AutoTpToggleFrame

local AutoTpLabel = Instance.new("TextLabel")
AutoTpLabel.Size = UDim2.new(0, 160, 1, 0)
AutoTpLabel.Position = UDim2.new(0, 10, 0, 0)
AutoTpLabel.BackgroundTransparency = 1
AutoTpLabel.Text = "Auto TP (15/15)"
AutoTpLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
AutoTpLabel.Font = Enum.Font.GothamMedium
AutoTpLabel.TextSize = 12
AutoTpLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoTpLabel.Parent = AutoTpToggleFrame

local AutoTpButton = Instance.new("TextButton")
AutoTpButton.Size = UDim2.new(0, 56, 0, 22)
AutoTpButton.Position = UDim2.new(1, -66, 0.5, -11)
AutoTpButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoTpButton.Text = "OFF"
AutoTpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoTpButton.Font = Enum.Font.GothamBold
AutoTpButton.TextSize = 11
AutoTpButton.Parent = AutoTpToggleFrame

local AutoTpBtnCorner = Instance.new("UICorner")
AutoTpBtnCorner.CornerRadius = UDim.new(0, 11)
AutoTpBtnCorner.Parent = AutoTpButton


-- --- CONNECTIVITÉ DES BOUTONS DE L'INTERFACE ---
EspButton.MouseButton1Click:Connect(function()
	local newState = not EspActive
	toggleEsp(newState)
	EspButton.Text = newState and "ON" or "OFF"
	EspButton.BackgroundColor3 = newState and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(200, 50, 50)
end)

AutoTpButton.MouseButton1Click:Connect(function()
	local newState = not AutoTpActive
	toggleAutoTp(newState)
	AutoTpButton.Text = newState and "ON" or "OFF"
	AutoTpButton.BackgroundColor3 = newState and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(200, 50, 50)
end)

OpenSaleUiButton.MouseButton1Click:Connect(function()
	pcall(function()
		local ClientMod = ReplicatedStorage:WaitForChild("Client")
		local InterfaceClient = require(ClientMod:WaitForChild("InterfaceClient"))
		if InterfaceClient and InterfaceClient.Frames and InterfaceClient.Frames.SellingFrame then
			InterfaceClient:Open(InterfaceClient.Frames.SellingFrame)
			print("[UI] Vente UI ouverte.")
		end
	end)
end)

SellAllRemoteButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local serverFolder = remotes and remotes:FindFirstChild("Server")
	local sellEvent = serverFolder and serverFolder:FindFirstChild("SellAllLoot")
	if sellEvent and sellEvent:IsA("RemoteEvent") then
		sellEvent:FireServer()
		print("[RESEAU] SellAllLoot exécuté.")
	end
end)

-- **LOGIQUE DÉCLENCHEMENT DU REMOTE HITWALL**
HitWallButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local serverFolder = remotes and remotes:FindFirstChild("Server")
	local hitWallEvent = serverFolder and serverFolder:FindFirstChild("HitWall")
	
	if hitWallEvent and hitWallEvent:IsA("RemoteEvent") then
		hitWallEvent:FireServer()
		print("[RESEAU] HitWall envoyé avec succès.")
	else
		warn("[RESEAU] RemoteEvent 'HitWall' introuvable dans ReplicatedStorage.Remotes.Server")
	end
end)


-- CONTENU : ONGLET SETTINGS
local SettingsPage = Instance.new("Frame")
SettingsPage.Name = "SettingsPage"
SettingsPage.Size = UDim2.new(1, 0, 1, -42)
SettingsPage.Position = UDim2.new(0, 0, 0, 42)
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
KeybindBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
KeybindBtn.Text = "L"
KeybindBtn.TextColor3 = Color3.fromRGB(0, 220, 130)
KeybindBtn.Font = Enum.Font.GothamBold
KeybindBtn.TextSize = 13
KeybindBtn.Parent = SettingsPage

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 6)
KeybindCorner.Parent = KeybindBtn


-- PANNEAU DE CONFIRMATION DE FERMETURE
local ConfirmationFrame = Instance.new("Frame")
ConfirmationFrame.Name = "ConfirmationFrame"
ConfirmationFrame.Size = UDim2.new(1, 0, 1, 0)
ConfirmationFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
ConfirmationFrame.BackgroundTransparency = 0.15
ConfirmationFrame.BorderSizePixel = 0
ConfirmationFrame.Visible = false
ConfirmationFrame.ZIndex = 10
ConfirmationFrame.Parent = MainFrame

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 12)
ConfirmCorner.Parent = ConfirmationFrame

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.Size = UDim2.new(1, 0, 0, 60)
ConfirmTitle.Position = UDim2.new(0, 0, 0.3, 0)
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Text = "Voulez-vous vraiment\nfermer ce menu ?"
ConfirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmTitle.Font = Enum.Font.GothamBold
ConfirmTitle.TextSize = 15
ConfirmTitle.ZIndex = 11
ConfirmTitle.Parent = ConfirmationFrame

local AcceptBtn = Instance.new("TextButton")
AcceptBtn.Size = UDim2.new(0, 110, 0, 38)
AcceptBtn.Position = UDim2.new(0.5, -120, 0.55, 0)
AcceptBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AcceptBtn.Text = "Accepter"
AcceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AcceptBtn.Font = Enum.Font.GothamBold
AcceptBtn.TextSize = 13
AcceptBtn.ZIndex = 11
AcceptBtn.Parent = ConfirmationFrame

local AcceptCorner = Instance.new("UICorner")
AcceptCorner.CornerRadius = UDim.new(0, 6)
AcceptCorner.Parent = AcceptBtn

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0, 110, 0, 38)
CancelBtn.Position = UDim2.new(0.5, 10, 0.55, 0)
CancelBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
CancelBtn.Text = "Annuler"
CancelBtn.TextColor3 = Color3.fromRGB(200, 200, 205)
CancelBtn.Font = Enum.Font.GothamBold
CancelBtn.TextSize = 13
CancelBtn.ZIndex = 11
CancelBtn.Parent = ConfirmationFrame

local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0, 6)
CancelCorner.Parent = CancelBtn

CloseMenuBtn.MouseButton1Click:Connect(function() ConfirmationFrame.Visible = true end)
CancelBtn.MouseButton1Click:Connect(function() ConfirmationFrame.Visible = false end)

AcceptBtn.MouseButton1Click:Connect(function()
	toggleEsp(false)
	toggleAutoTp(false)
	ScreenGui:Destroy()
	print("[MENU] Menu détruit.")
end)


-- --- SYSTÈME DE DETECTION EN TEMPS REEL (DONNEES CARTE) ---
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
		local function updateText() StatusLabel.Text = "Amount : " .. amountTarget.Text end
		updateText()
		amountTarget:GetPropertyChangedSignal("Text"):Connect(updateText)
	else
		StatusLabel.Text = "Amount : Introuvable"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	end
end)

task.spawn(function()
	pcall(function()
		local prompt = Workspace:FindFirstChild("Map"):FindFirstChild("Trait Machine"):FindFirstChild("Trait Machine"):FindFirstChild("Marker"):FindFirstChild("Prompt"):FindFirstChild("ProximityPrompt")
		if prompt then
			local function updateActionText() ActionTextLabel.Text = "Action : " .. prompt.ActionText end
			updateActionText()
			prompt:GetPropertyChangedSignal("ActionText"):Connect(updateActionText)
		else
			ActionTextLabel.Text = "Action : Prompt non trouvé"
		end
	end)
end)


-- --- STRUCTURE DU DRAG-AND-DROP ---
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
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then update(input) end
end)


-- --- NAVIGATION DES ONGLETS ---
TabMachineBtn.MouseButton1Click:Connect(function()
	MachinePage.Visible = true
	SettingsPage.Visible = false
	TabMachineBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
	TabMachineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
	TabSettingsBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
end)

TabSettingsBtn.MouseButton1Click:Connect(function()
	MachinePage.Visible = false
	SettingsPage.Visible = true
	TabMachineBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
	TabMachineBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
	TabSettingsBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
	TabSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)


-- --- INITIALISATION DES CONTROLES CLAVIER & REMOTES COMMUNE ---
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

ActionButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local serverFolder = remotes and remotes:FindFirstChild("Server")
	local traitMachineEvent = serverFolder and serverFolder:FindFirstChild("TraitMachineStart")
	if traitMachineEvent and traitMachineEvent:IsA("RemoteEvent") then traitMachineEvent:FireServer() end
end)

LootClaimedButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local clientFolder = remotes and remotes:FindFirstChild("Client")
	local lootEvent = clientFolder and clientFolder:FindFirstChild("LootClaimed")
	if lootEvent and lootEvent:IsA("RemoteEvent") then lootEvent:FireServer() end

	if IsTeleportingHitbox then return end
	local hitbox = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Markers") and Workspace.Map.Markers:FindFirstChild("ClaimHitbox")
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if hitbox and hitbox:IsA("BasePart") and hrp then
		IsTeleportingHitbox = true
		local origCFrame = hitbox.CFrame
		hitbox.CFrame = hrp.CFrame
		task.delay(3, function()
			hitbox.CFrame = origCFrame
			IsTeleportingHitbox = false
		end)
	end
end)
