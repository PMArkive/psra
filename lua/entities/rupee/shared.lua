if SERVER then
	AddCSLuaFile()
else
	ENT.PrintName = "Rupees"
	ENT.TargetIDHint = {
		name = ENT.PrintName,
		hint = "",
		fmt  = function(ent) -- print rupee count when ent is in crosshair.
			if ent:GetNWBool("is_rupoor") then
				return ent:GetNWInt("rand_amount")
			else
				return ent:GetNWInt("real_amount")
			end
		end
	}
end

ENT.Type = "anim"

function ENT:Initialize()
	self:SetModel("models/rupee/rupee_white.mdl")
	self:PhysicsInit(SOLID_OBB_YAW)
	self:SetMoveType(MOVETYPE_STEP)
	self:SetSolid(SOLID_VPHYSICS)
	-- Make the Rupee/Rupoor non-collidable
	-- so people can't fucking block doors and shit.
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	self.isInitialized = false

	if SERVER then
		-- Flying Rupee Fun Time!
		--self:SetFriction(-1)
		self:SetTrigger(true)
		self.Entity:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():Wake()
	else
		self.RandomSpin = math.random( 0, 360 )
		self.RandomHeight = math.random( 2, 10 )
		self.RandomHeightSpeed = math.random( 1, 5 )
	end
end

function ENT:EndTouch(ent)
	if IsValid(ent) and ent:IsPlayer() then
		self.isInitialized = true
	end
end

function ENT:StartTouch(plr)
	if self.isInitialized and IsValid(plr) and
			plr:IsPlayer() and plr:IsTerror() then
		local amount = self:GetNWInt("real_amount")
		local is_rupoor = self:GetNWBool("is_rupoor")
		local dropper = self:GetNWEntity("dropper")

		if is_rupoor then
			-- We need a positive amount so shit doesn't fuck up.
			amount = -amount

			if plr == dropper then
				plr:SetNWBool("dropped_rupoor", false)
			else
				-- Lower the amount if the player doesn't have
				-- enough rupees for the rupoor.
				if not plr:PS_HasPoints(amount) then
					amount = plr:PS_GetPoints()
					if amount > 0 then
						plr:PS_TakePoints(amount)
					end
				end

				if IsValid(dropper) then
					if amount > 0 then
						dropper:PS_GivePoints(amount)
					end

					dropper:RupeePickupMessage(amount, plr, dropper, true)
				end
			end

			plr:RupeePickupMessage(amount, plr, dropper, true)
		else -- if not a Rupoor
			if plr ~= dropper and IsValid(dropper) then
				dropper:RupeePickupMessage(amount, plr, dropper, false)
			end

			plr:RupeePickupMessage(amount, plr, dropper, false)
			plr:PS_GivePoints(amount)
		end

		self:Remove()
	end
end

if CLIENT then
	local shimmer = Material( "effects/yellowflare" )

	function ENT:Draw()
		local height = ( ( math.sin( self.RandomHeight + RealTime() * self.RandomHeightSpeed ) + 1 ) / 2 ) * 6
		local spin = self.RandomSpin + RealTime() * 180

		local ang = self:GetAngles()
		ang:RotateAroundAxis( ang:Up(), spin )

		self:SetRenderOrigin( self:GetPos() + vector_up * height )
		self:SetRenderAngles( ang )

		if !self.NextShimmer or self.NextShimmer <= RealTime() then
			self.NextShimmer = RealTime() + math.random(500,2000)/1000
			self.ShimmerFadeTime = RealTime() + 0.65

			local mins = self:OBBMins()
			local maxs = self:OBBMaxs()

			self.ShimmerPos = Vector(math.random(mins.x,maxs.x),math.random(mins.y,maxs.y),math.random(mins.z,maxs.z))
		end

		if self.ShimmerFadeTime and self.ShimmerFadeTime > RealTime() then
			local percent = ( self.ShimmerFadeTime - RealTime() ) / 0.65
			local size = 10 * percent

			render.SetMaterial( shimmer )
			render.DrawSprite( self:GetRenderOrigin() + self.ShimmerPos, size, size, Color(255,255,255,255*percent) )
		end

		self:SetupBones()

		self:DrawModel()

		self:SetRenderOrigin()
		self:SetRenderAngles()
	end
end
