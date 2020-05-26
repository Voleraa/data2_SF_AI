local RADIANT_ITEM_BUILD = {
	-- 'item_flask',
	'item_slippers',
	'item_circlet',
	'item_recipe_wraith_band',
	'item_ring_of_protection',
	'item_blight_stone',
	'item_enchanted_mango',
	'item_sobi_mask',
	'item_boots_of_elves',
	'item_boots_of_elves',
	'item_ogre_axe',
	'item_claymore',
	'item_shadow_amulet',
	'item_mithril_hammer',
	'item_mithril_hammer',
	'item_mithril_hammer',
	'item_gloves',
	'item_recipe_maelstrom'
}

local DIRE_ITEM_BUILD = {
	'item_sobi_mask',
	'item_ring_of_protection',
	'item_branches',
	'item_branches',
	'item_blight_stone',
	'item_ring_of_regen',
	'item_recipe_headdress',
	'item_chainmail',
	'item_recipe_buckler',
	'item_slippers',
	'item_circlet',
	'item_recipe_wraith_band',
	'item_recipe_mekansm',
	'item_boots_of_elves',
	'item_boots_of_elves',
	'item_ogre_axe',
	'item_wind_lace',
	'item_void_stone',
	'item_staff_of_wizardry',
	'item_recipe_cyclone',
	'item_mithril_hammer',
	'item_mithril_hammer',
	'item_mithril_hammer',
	'item_gloves',
	'item_recipe_maelstrom'
}

function ItemPurchaseThink()
    local npc_bot = GetBot();
    local team = GetTeam();
	local ITEM_BUILD = nil

    if(team == TEAM_RADIANT)
    	then
    	ITEM_BUILD = RADIANT_ITEM_BUILD
    else
    	ITEM_BUILD = DIRE_ITEM_BUILD
    end

    if(ITEM_BUILD == nil)
    	then
    	return
    end

    if (#ITEM_BUILD == 0)
	then
		npc_bot:SetNextItemPurchaseValue(0);
		return;
	end

	local next_item = ITEM_BUILD[1];
	local item_cost = GetItemCost(next_item)

	npc_bot:SetNextItemPurchaseValue(item_cost);

	if (npc_bot:GetGold() >= item_cost)
	then
		npc_bot:Action_PurchaseItem(next_item);
		table.remove(ITEM_BUILD, 1);
	end
end




-- local ITEM_BUILD = {
-- 	'item_flask',
-- 	'item_slippers',
-- 	'item_circlet',
-- 	'item_recipe_wraith_band',
-- 	'item_blight_stone',
-- 	'item_enchanted_mango',
-- 	'item_sobi_mask',
-- 	'item_ring_of_protection',
-- 	'item_boots_of_elves',
-- 	'item_boots_of_elves',
-- 	'item_ogre_axe',
-- 	'item_claymore',
-- 	'item_shadow_amulet',
-- 	'item_mithril_hammer',
-- 	'item_mithril_hammer'
-- }

-- function ItemPurchaseThink()
--     local npc_bot = GetBot();

--     if (#ITEM_BUILD == 0)
-- 	then
-- 		npc_bot:SetNextItemPurchaseValue(0);
-- 		return;
-- 	end

-- 	local next_item = ITEM_BUILD[1];
-- 	local item_cost = GetItemCost(next_item)

-- 	npc_bot:SetNextItemPurchaseValue(item_cost);

-- 	if (npc_bot:GetGold() >= item_cost)
-- 	then
-- 		npc_bot:Action_PurchaseItem(next_item);
-- 		table.remove(ITEM_BUILD, 1);
-- 	end
-- end