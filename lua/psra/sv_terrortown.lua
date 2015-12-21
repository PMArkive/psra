-- I'd like to believe that this file is understandable, but then I see
-- how much nested shit I've written and realize that's probably not true.

local math = math
local Color = Color

local psra = psra

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

-- Kill rewards and penalties hooks
hook.Add("PlayerDeath", "RupeeKillRewardsAndPenalties", function(vic, item, att)
	if not (IsValid(vic) and IsValid(att)) then return end
	if not (att:IsPlayer() and vic:IsPlayer()) or (vic == att) then return end
	if att:IsBot() or vic:IsBot() then return end
	if GetRoundState() ~= ROUND_ACTIVE then return end

	local attrole = att:GetRole()
	local vicrole = vic:GetRole()

	local penalty = psra.pen[attrole].kill[vicrole]
	local pts = psra.amounts[attrole].kill[vicrole]

	-- If there is a penalty from det-kill-det or traitor-kill-traitor.
	if penalty ~= nil then
		if not penalty then return end
		att:PS_TakePoints(pts)
		att:RupeeKillMessages(vic, pts, true)
		att:RupoorPickupSound()
	-- For the traitor's innocent-kills quota.
	elseif attrole == ROLE_TRAITOR and vicrole == ROLE_INNOCENT then
		if att:IncreaseQuotaKills() >= ROUND_KILL_QUOTA then
			pts = psra.amounts.quota
			att:ResetQuotaKills()
			att:PS_GivePoints(pts)
			att:RupeeKillMessages(vic, pts, false, ROUND_KILL_QUOTA)
			att:RupeePickupSound()
		end
	-- If there is a reward or traitor-kill-det or something.
	elseif pts ~= nil and pts > 0 then
		att:PS_GivePoints(pts)
		att:RupeeKillMessages(vic, pts, false)
		att:RupeePickupSound()
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

	ROUND_KILL_QUOTA = math.Clamp(math.floor(traitors-1), psra.quota_min, psra.quota_max)
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
				local pts = psra.amounts[ROLE_TRAITOR].WIN
				plr:PS_GivePoints(pts)
				plr:RupeeEndRound(pts, ROUND_WON)
				plr:RupeePickupSound()
			end
		end
	else
		for _, plr in pairs(plrs) do
			if PlayerIsAlive(plr) and not plr:IsTraitor() then
				local pts = psra.amounts[plr:GetRole()].win
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
