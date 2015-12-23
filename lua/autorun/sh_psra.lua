ROUND_SURVIVED = 0
ROUND_WON = 1

if SERVER then
	AddCSLuaFile("psra/cl_psra.lua")
	include("psra/sv_psra.lua")
else
	include("psra/cl_psra.lua")
end

-- Includes the correct file for the gamemode and sends the client
-- an accompanying client file for the gamemode.
hook.Add("OnGamemodeLoaded", "RupeeSetup", function()
	local folder = GAMEMODE.FolderName
	local cl_gmfile = "psra/cl_" .. folder .. ".lua"

	if file.Exists(cl_gmfile, "LUA") then
		if SERVER then
			ServerLog("[RUPEES] Sending \"" .. cl_gmfile .. "\" to clients.\n")
			AddCSLuaFile(cl_gmfile)
		else
			print("[RUPEES] Loading \"" .. cl_gmfile .. "\".")
			include(cl_gmfile)
			PaintRupeeHUD()
		end
	else
		ErrorNoHalt("[RUPEES] Couldn\'t find \"" .. cl_gmfile .. "\"!")
	end

	if SERVER then
		local sv_gmfile = "psra/sv_" .. folder .. ".lua"

		if not file.Exists(sv_gmfile, "LUA") then
			ErrorNoHalt("[RUPEES] Couldn\'t find \"" .. sv_gmfile .. "\"!")
			return
		end

		ServerLog("[RUPEES] Loading \"" .. sv_gmfile .. "\".\n")
		include(sv_gmfile)
	end
end)
