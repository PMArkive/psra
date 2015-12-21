-- I'd like to believe that this file is understandable, but then I see
-- how much nested shit I've written and realize that's probably not true.

local math = math
local Color = Color

local PSRA = PSRA

local ROUND_KILL_QUOTA = 0

util.AddNetworkString("rupee_kill_messages")

-- Setup the Player metatable extensions.
local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:RupeeKillMessages(vic, amount, ispenalty, round_quota)
	net.Start("rupee_kill_messages")
		net.WriteInt(amount, 32)
		net.WriteUInt(vic:GetRole(), 8)
		net.WriteUInt(round_quota or 0, 8)
		net.WriteBool(ispenalty)
	net.Send(self)
end

function PlayerIsAlive(plr)
	return plr:Alive() and plr:Team() ~= TEAM_SPEC
end

function RoundIsInactive()
	-- Preround is okay along with during the round.
	return GetRoundState() == ROUND_POST
end

local roleLetters = {
	[ROLE_DETECTIVE] = "D",
	[ROLE_INNOCENT] = "I",
	[ROLE_TRAITOR] = "T"
}

-- Kill rewards and penalties hooks
hook.Add("PlayerDeath", "RupeeKillRewardsAndPenalties", function(vic, item, attk)
	if not (IsValid(vic) and IsValid(attk)) then return end
	if not (attk:IsPlayer() and vic:IsPlayer()) or (vic == attk) then return end
	if attk:IsBot() or vic:IsBot() then return end
	if GetRoundState() ~= ROUND_ACTIVE then return end

	local attkrole = attk:GetRole()
	local attkletter = roleLetters[attkrole]
	local vicrole = vic:GetRole()
	local vicletter = roleLetters[vicrole]

	local penalty = PSRA.PEN[attkletter].KILL[vicletter]
	local pts = PSRA.RGF[attkletter].KILL[vicletter]

	-- If there is a penalty from det-kill-det or traitor-kill-traitor.
	if penalty ~= nil then
		if not penalty then return end
		attk:PS_TakePoints(pts)
		attk:RupeeKillMessages(vic, pts, true)
		attk:RupoorPickupSound()
	-- For the traitor's innocent-kills quota.
	elseif attkrole == ROLE_TRAITOR and vicrole == ROLE_INNOCENT then
		if attk:IncreaseQuotaKills() >= ROUND_KILL_QUOTA then
			pts = PSRA.RGF.QUOTA
			attk:ResetQuotaKills()
			attk:PS_GivePoints(pts)
			attk:RupeeKillMessages(vic, pts, false, ROUND_KILL_QUOTA)
			attk:RupeePickupSound()
		end
	-- If there is a reward or traitor-kill-det or something.
	elseif pts ~= nil and pts > 0 then
		attk:PS_GivePoints(pts)
		attk:RupeeKillMessages(vic, pts, false)
		attk:RupeePickupSound()
	end
end)

-- Set the traitors' kill quota to the number of traitors minus one.
hook.Add("TTTBeginRound", "SetupRoundKillQuota", function()
	local traitors = 0

	for _, plr in pairs(player.GetAll()) do
		plr:ResetQuotaKills()
		if plr:IsTraitor() then
			traitors = traitors + 1
		end
	end

	ROUND_KILL_QUOTA = math.Clamp(math.floor(traitors-1), PSRA.MIN_QUOTA, PSRA.MAX_QUOTA)
end)

-- Setup rupee notifications at the end of the round.
hook.Add("TTTEndRound", "RupeeRoundEndNotifications", function(result)
	-- Filter out players in spectate.
	local plrs = player.GetAll()
	-- Confirm there are multiple players.
	if #plrs < 2 then return end

	-- For-loops are within each 'if' statement so we don't
	-- have uneeded checks each iteration.
	if result == WIN_TRAITOR then
		for _, plr in pairs(plrs) do
			if PlayerIsAlive(plr) and plr:IsTraitor() then
				local pts = PSRA.RGF.T.WIN
				plr:PS_GivePoints(pts)
				plr:RupeeEndRound(pts, ROUND_WON)
				plr:RupeePickupSound()
			end
		end
	else
		for _, plr in pairs(plrs) do
			if PlayerIsAlive(plr) and not plr:IsTraitor() then
				local pts = plr:IsDetective() and PSRA.RGF.D.WIN or PSRA.RGF.I.WIN
				plr:PS_GivePoints(pts)
				plr:RupeeEndRound(pts, ROUND_SURVIVED)
				plr:RupeePickupSound()
			end
		end
	end
end)

-- An end-round hook was chosen so shit doesn't fuck up if the rupoor
-- booleans were cleared pre-round or at round-start.
hook.Add("TTTEndRound", "ClearRupoorBools", function()
	for _, plr in pairs(player.GetAll()) do
		plr:SetNWBool("dropped_rupoor", false)
	end
end)
