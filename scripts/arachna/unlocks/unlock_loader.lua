local Mod = ARACHNAMOD

local prefix = "scripts.arachna.unlocks.unlocks_"

--#region Arachna

local arachna = {
	"3d_glasses",
	"arachnids_grip",
	"geptameron",
	"golden_shopkeeper",
	"infested_penny",
	"lil_arachna",
	"mechanical_eye",
	"mutagen",
	"testament",
	"the_yarn",
	"white_string",
	"yarn_heart",
	"arachnology_101"
}

Mod.LoopInclude(arachna, prefix .. "arachna")

--#endregion

--#region Tainted Arachna

local arachna_b = {
	"best_bud_ball",
	"dads_newspaper",
	"merged_card",
	"merged_card_reversed",
	"soul_of_arachna",
	"spider_beggar",
	"spindle"
}

Mod.LoopInclude(arachna_b, prefix .. "arachna_b")

--#endregion

Mod.Include("scripts.arachna.unlocks.unlock_table")
Mod.Include("scripts.arachna.unlocks.unlock_tracker_marks")
