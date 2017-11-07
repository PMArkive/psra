-----------------------------Config Area!-----------------------------

-- Tag position within name
TAGPOS_BEGIN   = 0
TAGPOS_END     = 1
TAGPOS_ANY     = 2

-- PointShop Rupee Addon
PSRA = {
	TAG = "[wIsP] ",
	TAG_POS = TAGPOS_BEGIN,
	TAG_FILE = "tag_users.txt",
	TAG_STUFF = false,

	MIN_QUOTA = 2,
	MAX_QUOTA = 6,

	RGF = { -- Rupees given for ...
		TAG = 1337,
		QUOTA = 15,

		I = { -- Innocent
			WIN = 10,

			KILL = {
				I = 69,
				D = 69,
				T = 10
			}
		},

		T = { -- Traitor
			WIN = 15,

			KILL = {
				I = 3,
				D = 12,
				T = 0
			}
		},

		D = { -- Detective
			WIN = 10,

			KILL = {
				I = 0,
				D = 69,
				T = 10
			}
		}
	},

	PEN = { -- Penalize
		I = { -- Innocent
			KILL = {
				I = false,
				D = true
			}
		},

		D = { -- Detective
			KILL = {
				I = false,
				D = true
			}
		},

		T = { -- Traitor
			KILL = {
				T = false
			}
		}
	}
}

-------------------------------------------------------------------------

