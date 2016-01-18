include("psra/sv_config.lua")

local net = net
local file = file
local string = string

-- Localize this shit yo
local psra = psra

math.randomseed(os.time())

-- Send all of the resources needed to the client.
resource.AddFile("models/rupee/rupee_white.mdl")

local sf = resource.AddSingleFile
sf("sound/zelda/pickup.wav")
sf("resource/fonts/monosans2.ttf")
sf("materials/rupees/white.png")
sf("materials/rupees/green.png")
sf("materials/rupees/red.png")
sf("materials/rupees/yellow.png")
sf("materials/rupees/orange.png")
sf("materials/rupees/blue.png")
sf("materials/rupees/purple.png")
sf("materials/models/rupee/white/rupee_whi.vmt")
sf("materials/models/rupee/white/rupee_whi.vtf")
sf("models/rupee/rupee_white.xbox.vtx")

-- Setup network strings.
util.AddNetworkString("rupee_pickup_sound")
util.AddNetworkString("rupoor_pickup_sound")
util.AddNetworkString("rupee_pickup_message")
util.AddNetworkString("rupee_drop_message")
util.AddNetworkString("rupee_end_round")

-- Functions to be redefined in gamemode specific files.
function PlayerIsAlive(plr)
	return plr:Alive()
end

function RoundIsInactive()
	return false
end

-- Setup the Player metatable extensions.
local PlayerMeta = FindMetaTable("Player")

-- Do NOT use if the player (or their team) lost the round.
function PlayerMeta:RupeeEndRound(amount, state)
	net.Start("rupee_end_round")
		net.WriteInt(amount, 32)
		net.WriteUInt(state, 8)
	net.Send(self)
end

function PlayerMeta:RupeePickupSound()
	net.Start("rupee_pickup_sound")
	net.Send(self)
end

function PlayerMeta:RupoorPickupSound()
	net.Start("rupoor_pickup_sound")
	net.Send(self)
end

function PlayerMeta:RupeeDropMessage(amount, is_rupoor)
	net.Start("rupee_drop_message")
		net.WriteInt(amount, 32)
		net.WriteBool(is_rupoor)
	net.Send(self)
end

function PlayerMeta:RupeePickupMessage(amount, pickup_plr, drop_plr, is_rupoor)
	net.Start("rupee_pickup_message")
		net.WriteInt(amount, 32)
		net.WriteEntity(pickup_plr)
		net.WriteEntity(drop_plr)
		net.WriteBool(is_rupoor)
	net.Send(self)
end

function PlayerMeta:ResetQuotaKills()
	self.quotakills = 0
end

function PlayerMeta:IncreaseQuotaKills()
	self.quotakills = self.quotakills + 1
	return self.quotakills
end

hook.Add("PlayerInitialSpawn", "InitialSpawnQuota", function(plr)
	if IsValid(plr) then
		plr:ResetQuotaKills()
	end
end)

-- Give the user rupees for wearing the community's tag.
-- The tag_users_file's format is "STEAMID\r\nSTEAMID\r\n" etc.
local tagFileData = file.Read(psra.tag_users_file) or ""
local cleantag = string.Trim(psra.tag) or ""

local function IsTagInName(name)
	local tag = psra.tag
	local position = psra.tag_position

	-- The tag-position variables are declared in sv_config.lua
	if position == front then
		return string.find(name, tag, 1, true) == 1
	end

	if position == back then
		return string.find(string.reverse(name), string.reverse(tag), 1, true) == 1
	end

	if position == any then
		return string.find(name, tag, 1, true) ~= nil
	end

	Error("[RUPEES] Invalid value given to the thing :L")
end

local function AddSteamIdToTagFile(sid)
	sid = sid .. "\r\n"
	-- Append the ID to both the file and file data variable.
	file.Append(psra.tag_users_file, sid)
	tagFileData = tagFileData .. sid
end

local function IsSteamIdInTagFile(steamID)
	return string.find(tagFileData, steamID, 1, true) ~= nil
end

local function CheckForTag(plr)
	if not IsValid(plr) then return end
	local name = plr:Name()
	local sid = plr:SteamID()

	if not IsTagInName(name) or IsSteamIdInTagFile(sid) then return end

	-- A timer is used to prevent name changes giving a player two bonuses.

	-- Timer uses 9 seconds because it take about 10-15 seconds
	-- for steam name changes to update to GMOD clients.
	timer.Simple(9, function()
		-- Double check to prevent name changes from interfering.
		if IsSteamIdInTagFile(sid) then return end

		AddSteamIdToTagFile(sid)
		plr:PS_GivePoints(psra.amounts.tag)
		plr:RupeePickupSound()
		plr:ChatPrint("Thank you for putting the " .. cleantag .. " tag on, enjoy the bonus!")
	end)
end

local function CheckForTagOnChange(plr, oldName, newName)
	if not IsValid(plr) then return end
	local sid = plr:SteamID()

	if not IsTagInName(newName) or IsSteamIdInTagFile(sid) then return end

	AddSteamIdToTagFile(sid)
	plr:PS_GivePoints(psra.amounts.tag)
	plr:RupeePickupSound()
	plr:ChatPrint("Thank you for putting on the " .. cleantag .. " tag, enjoy the Rupee bonus!")
end

hook.Add("PlayerInitialSpawn", "CheckForTag", CheckForTag)
hook.Add("ULibPlayerNameChanged", "CheckForTagOnChange", CheckForTagOnChange)

-- Some static colors for the Rupee entity.
local rcolor_ent_rupoor     = color_black
local rcolor_ent_default    = Color(0, 255, 0)
local rcolor_ent_5000       = Color(255, 255, 255)
local rcolor_ent_1500       = Color(255, 106, 0)
local rcolor_ent_750        = Color(178, 0, 255)
local rcolor_ent_300        = Color(255, 0, 0)
local rcolor_ent_150        = Color(255, 255, 0)
local rcolor_ent_50         = Color(0, 0, 255)

-- Made entShootPosVec static so Vector() isn't called multiple times.
local entShootPosVec        = Vector(0, 0, 20)

-- /drop|!drop check hook
hook.Add("PlayerSay", "RupeeDropChat", function(plr, text, isTeam)
	if not IsValid(plr) then return "" end

	local words = string.Split(text, " ")
	local cmd = words[1]
	local is_rupoor = false

	-- If the command is not !drop or /drop, then return and let another hook deal with it.
	if cmd ~= "!drop" and cmd ~= "/drop" then return end

	if not PlayerIsAlive(plr) then
		plr:ChatPrint("You must be alive to drop Rupees!")
		return ""
	end

	-- Stop players dropping rupees in periods of time where
	-- a player wouldn't be able to pick them up.
	if RoundIsInactive() then
		plr:ChatPrint("You are not able to drop Rupees after the round!")
		return ""
	end

	local amount = tonumber(words[2])
	if amount == nil then
		plr:ChatPrint("Enter a valid number for !drop|/drop")
		return ""
	end

	amount = math.floor(amount)

	-- Use a Rupoor
	if amount < 0 and amount > -11 then -- negative 1 through negative 10
		if plr:GetNWBool("dropped_rupoor") then
			plr:ChatPrint("You have already dropped a Rupoor this round.")
			return ""
		end

		is_rupoor = true
		plr:SetNWBool("dropped_rupoor", true)
	else -- Use a Rupee
		if amount < 10 then
			plr:ChatPrint("You must drop a minimum of 10 Rupees!")
			return ""
		end

		if plr:PS_GetPoints() < amount then
			plr:ChatPrint("You do not have enough Rupees!")
			return ""
		end
	end

	plr:RupeeDropMessage(amount, is_rupoor)

	local ent = ents.Create("rupee")
	local x = plr:GetAngles():Forward().x -- Throwaway variable.
	local pos = plr:GetShootPos() + Vector(x, x, 0)

	ent:SetPos(pos - entShootPosVec)

	ent:SetNWEntity("dropper", plr)
	ent:SetNWBool("is_rupoor", is_rupoor)
	ent:SetNWInt("real_amount", amount)

	if is_rupoor then
		ent:SetNWInt("rand_amount", math.floor(math.random(10, 1000)))
	else
		-- Take the points for the Rupee ent.
		plr:PS_TakePoints(amount)
	end

	ent:Spawn()
	ent:Activate()

	local aimVec = plr:GetAimVector() -- Throwaway variable.
	ent:SetVelocity(Vector(aimVec.x, aimVec.y, 0.5) * 300)

	local clr = rcolor_ent_default

	if is_rupoor then
		clr = rcolor_ent_rupoor
	elseif amount > 5000 then
		clr = rcolor_ent_5000
	elseif amount > 1500 then
		clr = rcolor_ent_1500
	elseif amount > 750 then
		clr = rcolor_ent_750
	elseif amount > 300 then
		clr = rcolor_ent_300
	elseif amount > 150 then
		clr = rcolor_ent_150
	elseif amount > 50 then
		clr = rcolor_ent_50
	end

	ent:SetColor(clr)

	return ""
end)
