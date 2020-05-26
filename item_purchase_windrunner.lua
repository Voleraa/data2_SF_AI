local ITEM_BUILD = {
	'item_flask',
	'item_slippers',
	'item_circlet',
	'item_recipe_wraith_band',
	'item_blight_stone',
	'item_enchanted_mango',
	'item_sobi_mask',
	'item_ring_of_protection',
	'item_boots_of_elves',
	'item_boots_of_elves',
	'item_ogre_axe',
	'item_claymore',
	'item_shadow_amulet',
	'item_mithril_hammer',
	'item_mithril_hammer'
}

function ItemPurchaseThink()
    local npc_bot = GetBot();

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