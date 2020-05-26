

----------------------------------------------------------------------------------------------------

function Think()


	if ( GetTeam() == TEAM_RADIANT )
	then
		print( "selecting radiant" );
		SelectHero( 2, "npc_dota_hero_drow_ranger" );
		SelectHero( 3, "npc_dota_hero_nevermore" );
		SelectHero( 4, "npc_dota_hero_bristleback" );
		SelectHero( 5, "npc_dota_hero_vengefulspirit" );
		SelectHero( 6, "npc_dota_hero_dazzle" );
	elseif ( GetTeam() == TEAM_DIRE )
	then
		print( "selecting dire" );
		SelectHero( 5, "npc_dota_hero_earthshaker" );
		SelectHero( 6, "npc_dota_hero_nevermore" );
		SelectHero( 7, "npc_dota_hero_juggernaut" );
		SelectHero( 8, "npc_dota_hero_mirana" );
		SelectHero( 9, "npc_dota_hero_axe" );
	end

	-- if ( GetTeam() == TEAM_RADIANT )
	-- then
	-- 	print( "selecting radiant" );
	-- 	SelectHero( 0, "npc_dota_hero_nevermore" );
	-- 	SelectHero( 1, "npc_dota_hero_drow_ranger" );
	-- 	SelectHero( 2, "npc_dota_hero_bristleback" );
	-- 	SelectHero( 3, "npc_dota_hero_vengefulspirit" );
	-- 	SelectHero( 4, "npc_dota_hero_dazzle" );
	-- elseif ( GetTeam() == TEAM_DIRE )
	-- then
	-- 	print( "selecting dire" );
	-- 	SelectHero( 5, "npc_dota_hero_nevermore" );
	-- 	SelectHero( 6, "npc_dota_hero_earthshaker" );
	-- 	SelectHero( 7, "npc_dota_hero_juggernaut" );
	-- 	SelectHero( 8, "npc_dota_hero_mirana" );
	-- 	SelectHero( 9, "npc_dota_hero_axe" );
	-- end

end

-- function UpdateLaneAssignments()
--     local lanes = {}

--     for i = 2, 11
--     	do
--         lanes[i] = LANE_MID
--     end
-- end

----------------------------------------------------------------------------------------------------
