-----------------------------Config Area!-----------------------------

-- Tag position within name
TAGPOS_BEGIN   = 0
TAGPOS_END     = 1
TAGPOS_ANY     = 2

-- PointShop Rupee Addon
PSRA = {
	TAG = "[EX] ",
	TAG_POS = TAGPOS_BEGIN,
	TAG_FILE = "tag_users.txt",

	MIN_QUOTA = 2,
	MAX_QUOTA = 6,

	RGF = { -- Rupees given for ...
		TAG = 1337,
		QUOTA = 6,

		I = { -- Innocent
			WIN = 5,

			KILL = {
				I = 69,
				D = 69,
				T = 6
			}
		},

		T = { -- Traitor
			WIN = 5,

			KILL = {
				I = 0,
				D = 8,
				T = 0
			}
		},

		D = { -- Detective
			WIN = 5,

			KILL = {
				I = 0,
				D = 69,
				T = 6
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

