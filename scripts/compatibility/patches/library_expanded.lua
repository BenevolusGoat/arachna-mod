local Mod = ArachnaMod
local loader = Mod.PatchesLoader

local function libraryExpandedPatch()
	LibraryExpanded.Item.WEIRD_BOOK.BookToDeli[Mod.Item.GEPTAMERON.ID] = true
	table.insert(LibraryExpanded.Item.TECHNOLOGY_BOOK.TECH_POOL, Isaac.GetItemIdByName("Mechanical Eye"))
	table.insert(LibraryExpanded.Item.PHOTO_BOOK.FAMILY_POOL, Isaac.GetItemIdByName("Dad's Newspaper"))
	if EID then
		LibraryExpanded.LibraryEID.TBOATB[Mod.Item.GEPTAMERON.ID] =	"#{{TBOATB}} Activates a different one of Geptameron's effects at random"
	end
end

loader:RegisterPatch("LibraryExpanded", libraryExpandedPatch)
