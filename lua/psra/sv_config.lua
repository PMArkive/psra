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

	quota_min = 2,
	quota_max = 6,

	amounts = { -- Rupees given for ...
		tag = 1337,
		quota = 6,

		ROLE_INNOCENT = { -- Innocent
			win = 5,

			kill = {
				ROLE_INNOCENT  = 69,
				ROLE_DETECTIVE = 69,
				ROLE_TRAITOR   = 6
			}
		},

		ROLE_TRAITOR = { -- Traitor
			win = 5,

			kill = {
				ROLE_INNOCENT  = 0,
				ROLE_DETECTIVE = 8,
				ROLE_TRAITOR   = 0
			}
		},

		ROLE_DETECTIVE = { -- Detective
			win = 5,

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

