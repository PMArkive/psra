-- Turn some globals into locals for quicker access
local draw = draw
local cookie = cookie
local surface = surface

local Color = Color
local HSVToColor = HSVToColor
local LocalPlayer = LocalPlayer

local function PlayerIsAlive(plr)
	return plr:Alive() and not plr:IsSpec()
end

-- Some colors for the net messages!
local plr_color = Color(0, 128, 255) -- Admin Blue
local rupoor_purple = Color(90, 42, 141) -- Purple
local amount_color = Color(36, 242, 17) -- Gold...ish
local chat_color = color_white

local roleNames = {
	[ROLE_DETECTIVE] = "Detective",
	[ROLE_INNOCENT] = "Innocent",
	[ROLE_TRAITOR] = "Traitor"
}

net.Receive("rupee_kill_messages", function()
	--[[ Net stuff (in order)
		Int32   - the reward or penalty amount
		UInt8   - the victim's role
		UInt8   - the amount of innocents killed to meet the quota
		Bool    - is this a penalty
	]]

	local amount = tostring(net.ReadInt(32))
	local vicrole = net.ReadUInt(8)
	local quota_amount = tostring(net.ReadUInt(8))
	local ispenalty = net.ReadBool()

	local isquota = quota_amount ~= "0"
	local str1, str2

	if ispenalty then
		str1 = "You had "
		str2 = " Rupees taken away for killing a "
	else
		str1 = "You received "
		str2 = " Rupees for killing " .. (isquota and "" or "a ")
	end

	local blah = {
		chat_color,
		str1,
		amount_color,
		amount,
		chat_color,
		str2
	}

	-- Add the quota amount in.
	if isquota then
		table.Add(blah, {
			amount_color,
			quota_amount
		})
	end

	-- Add the team name in.
	table.Add(blah, {
		plr_color,
		(isquota and " Innocents" or roleNames[vicrole]),
		chat_color,
		"!"
	})

	psChatAddText(unpack(blah))
end)

local color_transparent_black		= Color(0, 0, 0, 200)
local color_transparent_white		= Color(255, 255, 255, 200)
local color_less_transparent_black	= Color(0, 0, 0, 235)
local color_greenish			= Color(0, 139, 69)

local color_traitor			= Color(205, 60, 40)
local color_innocent			= Color(170, 225, 100)
local color_detective			= Color(115, 180, 200)
local color_spectator			= Color(200, 200, 200)

local rupee_amount = "sick memes"

-- Style 1
-- The original HUD layout
local function RupeeHUDStyle1()
	local plr = LocalPlayer()
	rupee_amount = plr:PS_GetPoints()

	local clr = "green"
	if rupee_amount > 99999 then
		clr = "white"
	elseif rupee_amount > 49999 then
		clr = "orange"
	elseif rupee_amount > 24999 then
		clr = "purple"
	elseif rupee_amount > 9999 then
		clr = "red"
	elseif rupee_amount > 4999 then
		clr = "yellow"
	elseif rupee_amount > 999 then
		clr = "blue"
	end

	-- Set color based on the user's player status (istraitor/det/inno)
	local rupee_color = color_innocent
	if not PlayerIsAlive(plr) then
		rupee_color = color_spectator
	elseif plr:IsTraitor() then
		rupee_color = color_traitor
	elseif plr:IsDetective() then
		rupee_color = color_detective
	end

	-- b = box, m = main, w = white...so mb = main box, sb = secondary box
	local mbW, mbH = 212, 30
	local mbX, mbY = 262, ScrH() - 50

	local sbW, sbH = 20, 30
	local sbX, sbY = mbX, mbY

	-- Draw boxes
	draw.RoundedBox(2, mbX, mbY, mbW, mbH, color_transparent_black)
	draw.RoundedBox(2, sbX, sbY, sbW, sbH, color_transparent_white)

	-- Draw rupee picture in white box
	surface.SetMaterial(Material("rupees/" .. clr .. ".png"))
	surface.DrawTexturedRect(mbX + 1, mbY + 6, 18, 18)

	draw.SimpleText("RUPEES: " .. rupee_amount, "FC_HUD_30",
		mbX + sbW + ((mbW - sbW) * 0.5) + 1, mbY + (mbH * 0.5),
		rupee_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Style 2
--[[ Rupees in trapezoid
     ____________
     \ 12345678 /
      \ RUPEES /
       --------
]]--
local function RupeeHUDStyle2()
	local plr = LocalPlayer()
	rupee_amount = plr:PS_GetPoints()

	local shape = {}
	local fX1, fX2, fY1, fY2

	if PlayerIsAlive(plr) then
		-- tmpX is the center of the screen
		local tmpX = (ScrW() * 0.5)
		-- scrX = (center of the screen - (long trapezoid side / 2))
		local scrX = tmpX - 114

		fX1 = tmpX
		fX2 = tmpX
		fY1 = 2
		fY2 = 40

		shape = {
			{ x = scrX, y = 0 },		-- First point
			{ x = scrX + 228, y = 0 },	-- 228 == (long trapezoid side)
			{ x = scrX + 182, y = 68 },	-- 182 == (long trapezoid side * 0.8)
			{ x = scrX + 46, y = 68 }	-- 46 == (long trapezoid side / 5)
		}
	else
		-- If player is dead or in spectator mode, then make
		-- a ribbon in the bottom left
		local tmpX = 135
		local tmpY = ScrH() - 110

		fX1 = tmpX - 20
		fX2 = tmpX - 20
		fY1 = tmpY
		fY2 = tmpY + 34

		shape = {
			{ x = 0, y = tmpY},
			{ x = 205, y = tmpY},
			{ x = 245, y = tmpY + 65},
			{ x = 0, y = tmpY + 65}
		}

		-- If the rupees is 5 digits or more, then
		-- move it to the bottom of the polygon
		if rupee_amount > 9999 then
			-- Swap with some adjustments
			fX1, fX2 = fX2, fX1 + 2
			fY1, fY2 = fY2 - 7, fY1 + 3
		end
	end

	-- Easter egg, shhh
	local word = "RUPEES"
	if rupee_amount > 999999 then
		word = "PEEPEES"
	end

	-- Transparent black color
	surface.SetDrawColor(0, 0, 0, 235)
	draw.NoTexture()
	surface.DrawPoly(shape)

	local rupee_color = RupeeColors1(rupee_amount)

	draw.DrawText(rupee_amount, "monosans2-rupees", fX1, fY1, rupee_color, TEXT_ALIGN_CENTER)
	draw.DrawText(word, "monosans2-text", fX2, fY2, color_white, TEXT_ALIGN_CENTER)
end

-- Style 3
-- Same rupee locations as Style 2, just without the trapezoid
local function RupeeHUDStyle3()
	local plr = LocalPlayer()
	rupee_amount = plr:PS_GetPoints()

	local fX1, fX2, fY1, fY2

	if PlayerIsAlive(plr) then
		-- tmpX is the center of the screen
		local tmpX = (ScrW() * 0.5)
		-- scrX = (center of the screen - (long trapezoid side / 2))
		local scrX = tmpX - 114

		fX1 = tmpX
		fX2 = tmpX
		fY1 = 2
		fY2 = 40
	else
		-- If player is dead or in spectator mode, then make
		-- a ribbon in the bottom left
		local tmpX = 135
		local tmpY = ScrH() - 110

		fX1 = tmpX - 20
		fX2 = tmpX - 20
		fY1 = tmpY
		fY2 = tmpY + 34

		-- If the rupees is 5 digits or more, then
		-- move it to the bottom of the polygon
		if rupee_amount > 9999 then
			-- Swap with some adjustments
			fX1, fX2 = fX2, fX1 + 2
			fY1, fY2 = fY2 - 7, fY1 + 3
		end
	end

	-- Easter egg, shhh
	local word = "RUPEES"
	if rupee_amount > 999999 then
		word = "PEEPEES"
	end

	local rupee_color = RupeeColors1(rupee_amount)

	draw.DrawText(rupee_amount, "monosans2-rupees", fX1, fY1, rupee_color, TEXT_ALIGN_CENTER)
	draw.DrawText(word, "monosans2-text", fX2, fY2, color_white, TEXT_ALIGN_CENTER)
end

-- Style 4
-- Rupees in a rounded box (AKA, the shittiest looking style)
local function RupeeHUDStyle4()
	local plr = LocalPlayer()
	rupee_amount = plr:PS_GetPoints()

	-- the letter `b' stands for box...for the roundedbox...the one that will be drawn
	local bW, bH = 160, 70
	local bX, bY

	if PlayerIsAlive(plr) then
		--bX = 270
		--bY = ScrH() - 100
		bX = (ScrW() * 0.5) - (bW / 2)
		bY = 5
	else
		bX = 52
		bY = ScrH() - 120
	end

	-- the letter `f'  stands for font
	local fX1, fY1, fX2, fY2

	fX1 = bX + (bW / 2)
	fX2 = fX1

	fY1 = bY + 5
	fY2 = bY + 33

	local rupee_color = RupeeColors1(rupee_amount)

	-- Transparent black color
	draw.RoundedBox(8, bX, bY, bW, bH, color_less_transparent_black)

	-- Easter egg, shhh
	local word = "RUPEES"
	if rupee_amount > 999999 then
		word = "PEEPEES"
	end

	-- `color_white' is a value defined by GMOD itself
	draw.DrawText(word, "monosans2-text", fX1, fY1, color_white, TEXT_ALIGN_CENTER)
	draw.DrawText(rupee_amount, "monosans2-rupees", fX2, fY2, rupee_color, TEXT_ALIGN_CENTER)
end

-- Style 5
local function RupeeHUDStyle5()
	local plr = LocalPlayer()
	rupee_amount = plr:PS_GetPoints()

	surface.SetFont("monosans2-rupees")
	local tSize = surface.GetTextSize(rupee_amount)

	-- p = polygon, f = foreground, b = background
	-- so fp = foreground polygon, bp = background polygon
	local bpW, bpH, bpX, bpY
	local fpW, fpH, fpX, fpY

	-- r = rupee, t = text, a = align
	local rtX, rtY
	local rtaX, rtaY

	if PlayerIsAlive(plr) then
		-- Place in the top-middle.
		local scrMiddle = ScrW() * 0.5

		bpW, bpH = tSize + 11, 38
		fpW, fpH = bpW - 6, bpH - 6


		bpX, bpY = scrMiddle - (tSize * 0.5) - 5, -4
		fpX, fpY = bpX + 3, bpY + 3

		rtX, rtY = scrMiddle, fpY + (fpH * 0.5) + 1
		rtaX, rtaY = TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
	else
		-- Move to the bottom-right.
		local scrW, scrH = ScrW(), ScrH()

		bpW, bpH = tSize + 11, 38
		fpW, fpH = bpW - 6, bpH - 6

		bpX, bpY = scrW - bpW + 4, scrH - bpH + 4
		fpX, fpY = bpX + 3, bpY + 3

		rtX, rtY = scrW - 2, fpY + (fpH * 0.5)
		rtaX, rtaY = TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER
	end

	-- Draw boxes
	draw.RoundedBox(4, bpX, bpY, bpW, bpH, color_transparent_black)
	draw.RoundedBox(4, fpX, fpY, fpW, fpH, color_greenish)

	draw.SimpleText(rupee_amount, "monosans2-rupees", rtX, rtY, color_white, rtaX, rtaY)
end

-- Setup Rupee HUD painting stuff then paint that shit
table.Add(GetRupeeHUDsTable(), {
	RupeeHUDStyle1,
	RupeeHUDStyle2,
	RupeeHUDStyle3,
	RupeeHUDStyle4,
	RupeeHUDStyle5,
})

PaintRupeeHUD()

