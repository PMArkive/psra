-----------------------------Config Area!-----------------------------

-- Tag position within name
front = 0
back  = 1
any   = 2

-- Player roles
ROLE_INNOCENT  = 0
ROLE_TRAITOR   = 1
ROLE_DETECTIVE = 2
ROLE_NONE = ROLE_INNOCENT

-- PointShop Rupee Addon
psra = {
	tag = "[EX] ",
	tag_position = front,
	tag_users_file = "tag_users.txt",

	-- The minimum number of non-traitors a traitor needs to kill before
	--  getting the Quota-completion rupee reward thing.
	quota_min = 2,
	-- The maximum number of non-traitors a traitor needs to kill before
	--  getting the Quota-completion rupee reward thing.
	quota_max = 6,

	amounts = { -- Rupees given for ...
		tag = 2000,
		quota = 25,

		ROLE_INNOCENT = { -- Innocent
			win = 25,

			kill = {
				ROLE_INNOCENT  = 10,
				ROLE_DETECTIVE = 69,
				ROLE_TRAITOR   = 6
			}
		},

		ROLE_TRAITOR = { -- Traitor
			win = 25,

			kill = {
				ROLE_INNOCENT  = 0,
				ROLE_DETECTIVE = 50,
				ROLE_TRAITOR   = 0
			}
		},

		ROLE_DETECTIVE = { -- Detective
			win = 25,

			kill = {
				ROLE_INNOCENT  = 0,
				ROLE_DETECTIVE = 69,
				ROLE_TRAITOR   = 6
			}
		}
	},

	pen = { -- Penalize
		ROLE_INNOCENT = { -- Innocent
			kill = {
				ROLE_INNOCENT = false,
				ROLE_DETECTIVE = true
			}
		},

		ROLE_DETECTIVE = { -- Detective
			kill = {
				ROLE_INNOCENT = false,
				ROLE_DETECTIVE = true
			}
		},

		ROLE_TRAITOR = { -- Traitor
			kill = {
				ROLE_TRAITOR = false
			}
		}
	}
}

-------------------------------------------------------------------------
