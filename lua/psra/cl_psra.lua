local Color = Color

hook.Add("OnGamemodeLoaded", "gimme dat rupee cookie", function()
	rupee_cookie = rupee_cookie .. GAMEMODE.FolderName
end)

-- HUD picking stuff
local rupee_cookie = "RupeeHUD_"
local rupee_huds = {}

function AddRupeeHUD(index, func)
	table.insert(rupee_huds, func)
end

local function RupeePickupSound()
	surface.PlaySound("zelda/pickup.wav")
end

local function RupoorPickupSound()
	surface.PlaySound("zelda/rupoor_pickup.mp3")
end

net.Receive("rupee_pickup_sound", RupeePickupSound)
net.Receive("rupoor_pickup_sound", RupoorPickupSound)

-- Some colors for the net messages!
local plr_color = Color(0, 128, 255) -- Admin Blue
local rupoor_purple = Color(90, 42, 141) -- Purple
local amount_color = Color(36, 242, 17) -- Gold...ish
local chat_color = color_white

net.Receive("rupee_end_round", function()
	--[[ Net stuff (in order)
		Int32   - amount of rupees
		UInt8   - won = 1, survived = 0
	]]

	local amount = tostring(net.ReadInt(32))
	local state = net.ReadUInt(8)
	local str

	if state == ROUND_SURVIVED then
		str = "surviving"
	elseif state == ROUND_WON then
		str = "winning"
	else
		ErrorNoHalt("Bad value passed to \'state\'!")
		return
	end

	psChatAddText(
		chat_color,
		"You received ",
		amount_color,
		amount,
		chat_color,
		" Rupees for " .. str .. " the round!"
	)
end)

net.Receive("rupee_drop_message", function()
	--[[ Net stuff (in order)
		Int32   - amount of rupees
		Bool    - is a rupoor
	]]

	local amount = tostring(net.ReadInt(32))
	local is_rupoor = net.ReadBool()

	if is_rupoor then
		psChatAddText(
			chat_color,
			"You dropped a ",
			rupoor_purple,
			"Rupoor",
			chat_color,
			" worth ",
			amount_color,
			amount,
			chat_color,
			" Rupees!"
		)
	else
		psChatAddText(
			chat_color,
			"You dropped ",
			amount_color,
			amount,
			chat_color,
			" Rupees!"
		)
	end
end)

net.Receive("rupee_pickup_message", function()
	--[[ Net stuff (in order)
		Int32   - amount of rupees
		--------- Entities are 16 bits
		Entity  - the player who picked up the rupee/rupoor
		Entity  - the player who dropped the rupee/rupoor
		Bool    - is a rupoor
		-----------------------------------------------------------
		NOTE:
		The colors like chat_color, plr_color, and amount_color are
		defined in near the top of this file.
	]]

	local amount = tostring(net.ReadInt(32))
	local pickup_plr = net.ReadEntity()
	local drop_plr = net.ReadEntity()
	local is_rupoor = net.ReadBool()

	if pickup_plr == drop_plr then
		if is_rupoor then
			psChatAddText(
				chat_color,
				"You picked your ",
				rupoor_purple,
				"Rupoor",
				chat_color,
				" up. Drop another whenevs bitch."
			)
		else
			RupeePickupSound()
			psChatAddText(
				chat_color,
				"You picked ",
				amount_color,
				amount,
				chat_color,
				" of your Rupees up."
			)
		end

		return -- Well, that's that, so let's leave.
	end

	local did_client_pickup = LocalPlayer() == pickup_plr
	local plr = (did_client_pickup and drop_plr or pickup_plr)

	local plr_name = IsValid(plr) and
			plr:GetName() .. (did_client_pickup and "\'s" or "")
			or
			(did_client_pickup and "somebody\'s" or "Somebody")

	if amount == "0" then -- The amount can only be 0 if it's a rupoor.
		if did_client_pickup then
			RupoorPickupSound()
			psChatAddText(
				chat_color,
				"You picked up ",
				plr_color,
				plr_name,
				rupoor_purple,
				" Rupoor",
				chat_color,
				", but you don\'t have any Rupees to lose!"
			)
		else
			RupeePickupSound()
			psChatAddText(
				chat_color,
				plr_color,
				plr_name,
				chat_color,
				" picked up your ",
				rupoor_purple,
				"Rupoor",
				chat_color,
				", but they didn\'t have any Rupees to lose!"
			)
		end

		return -- Well, that's that, so let's leave.
	end

	-- This is ugly as fuckkkkkkkk, please forgive me Lord!
	if is_rupoor then
		if did_client_pickup then
			RupoorPickupSound()
			psChatAddText(
				chat_color,
				"You picked ",
				plr_color,
				plr_name,
				rupoor_purple,
				" Rupoor",
				chat_color,
				" up and lost ",
				amount_color,
				amount,
				chat_color,
				" Rupee" .. (amount ~= "1" and "s" or "") .. "!"
			)
		else
			RupeePickupSound()
			psChatAddText(
				chat_color,
				plr_color,
				plr_name,
				chat_color,
				" picked your ",
				rupoor_purple,
				"Rupoor",
				chat_color,
				" up and you gained ",
				amount_color,
				amount,
				chat_color,
				" Rupee" .. (amount ~= "1" and "s" or "") .. "!"
			)
		end
	else
		if did_client_pickup then
			RupeePickupSound()
			psChatAddText(
				chat_color,
				"You picked ",
				amount_color,
				amount,
				chat_color,
				" of ",
				plr_color,
				plr_name,
				chat_color,
				" Rupees up!"
			)
		else
			psChatAddText(
				chat_color,
				plr_color,
				plr_name,
				chat_color,
				" picked ",
				amount_color,
				amount,
				chat_color,
				" of your Rupees up!"
			)
		end
	end
end)

-- Appends .ttf to the font if not windows. Fonts are stupid on linux/mac.
local ms2font = "monosans2" .. (system.IsWindows() and "" or ".ttf")

-- Some global fonts.
surface.CreateFont("monosans2-rupees", {
	font = ms2font,
	antialias = true,
	size = 40
})

surface.CreateFont("monosans2-text", {
	font = ms2font,
	antialias = true,
	size = 30
})

surface.CreateFont("Deathrun_SmoothRP", {
	font = "Trebuchet18",
	antialias = true,
	size = 27,
	weight = 700
})

-- Rupee colors.
local rcolor_diamond = Color(115, 230, 222)
local rcolor_silver  = Color(192, 192, 192)
local rcolor_gold    = Color(255, 215, 0)
local rcolor_orange  = Color(205, 133, 0)
local rcolor_purple  = Color(128, 0, 128)
local rcolor_red     = Color(205, 55, 0)
local rcolor_yellow  = Color(173, 255, 47)
local rcolor_blue    = Color(113, 113, 198)
local rcolor_green   = Color(0, 139, 69)

-- Rupee Colors.
function RupeeColors1(rupees)
	if rupees >= 500000 then
		-- Color that changes when the time does; thx Breakpoint.
		return HSVToColor((RealTime() * 50) % 360, 0.65, 1)
	elseif rupees >= 250000 then
		return rcolor_diamond
	elseif rupees >= 100000 then
		return rcolor_silver
	elseif rupees >= 75000 then
		return rcolor_gold
	elseif rupees >= 50000 then
		return rcolor_orange
	elseif rupees >= 25000 then
		return rcolor_purple
	elseif rupees >= 10000 then
		return rcolor_red
	elseif rupees >= 5000 then
		return rcolor_yellow
	elseif rupees >= 1500 then
		return rcolor_blue
	end

	return rcolor_green
end

local function GetRupeeHUD(val)
	local hud_index = (val or cookie.GetNumber(rupee_cookie, 1))
	local hud = rupee_huds[hud_index]

	if hud == nil then
		print("[RUPEES] HUD style not found! Trying to use style #1.")
		hud = rupee_huds[1]
	end

	return hud
end

function PaintRupeeHUD(hud_index)
	local func = GetRupeeHUD(hud_index)

	if isfunction(func) then
		print("[RUPEES] Starting the Rupee HUD painting.")
		hook.Add("HUDPaint", "RupeeHUD", func)
	else
		print("[RUPEES] Could not paint the Rupee HUD.")
	end
end

concommand.Add("rupee_style", function(plr, cmd, args, fullStr)
	local hud_index = tonumber(args[1])

	if hud_index then
		cookie.Set(rupee_cookie, hud_index)
		PaintRupeeHUD(hud_index)
	else
		print("[RUPEES] Not a number, try again.")
	end
end, nil, "Used to pick the rupee HUD style.")

--[[ We have this shit because of a chat-box addon that is used by our server.
	With Scorpys Simple Chatbox, I just edited in the "psChatAddText" function
	so it would add a ruby icon to the side of the chat message. It seemed
	like the easiest option at the time to just edit it in.
	In "lua/scorpy_chatbox/sh_init.lua" it looks like the indented code below:

		local oldChatAddText = chat.AddText

		function psChatAddText(...)
			oldChatAddText(...)

			Chatbox = Chatbox or vgui.Create("ScorpyChatbox")
			Chatbox:AddMessage({...}, "icon16/ruby.png")
		end

		function chat.AddText(...)
			oldChatAddText(...)

			Chatbox = Chatbox or vgui.Create("ScorpyChatbox")
			Chatbox:AddMessage({...})
		end
]]
hook.Add("Initialize", "setup psChatAddText", function()
	-- If SSC exists, then psChatAddText will be defined somewhere in there.
	if not SSC then
		psChatAddText = chat.AddText
	end
end)
