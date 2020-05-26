-- TODO LIST
-- euls, ulti
-- fix utils
-- Courier management
-- talents (still bugged)
-- KILL MOVES
-- Separate proper position to retreat due to hit

local utils = require(GetScriptDirectory().."/utils");

local FUZZY_POS_START = 300;
local FUZZY_POS_END = 500;

local SKILL_1 = 'nevermore_shadowraze1';
local SKILL_1_1 = 'nevermore_shadowraze2';
local SKILL_1_2 = 'nevermore_shadowraze3';
local SKILL_2 = 'nevermore_necromastery';
local SKILL_3 = 'nevermore_dark_lord';
local SKILL_ULTI = 'nevermore_requiem';

local SKILL_BUILD = {
    SKILL_2, -- 1
    SKILL_1, -- 2
    SKILL_1, -- 3
    SKILL_2, -- 4
    SKILL_1, -- 5
    SKILL_2, -- 6
    SKILL_1, -- 7
    SKILL_2, -- 8
    SKILL_3, -- 9
    -- 'special_bonus_attack_speed_20', -- 10
    SKILL_ULTI, -- 11
    SKILL_ULTI, -- 12
    SKILL_3, -- 13
    SKILL_3, -- 14
    -- 'special_bonus_spell_amplify_6', -- 15
    SKILL_3, -- 16
    SKILL_ULTI, -- 18
    -- 'special_bonus_unique_nevermore_1', -- 20
    -- 'special_bonus_attack_range_150', -- 25
}

local TOTAL_SKILL_LEVEL = 0

local HIT_NOW = false;
local HIT_UNIT = nil;

local PREVIOUS_HP = nil;

local SAFE_RANGE = 700;

local PREV_TASK = nil;

function GetHeroLevel()
    local npc_bot = GetBot();
    local respawn_table = {8, 10, 12, 14, 16, 26, 28, 30, 32, 34, 36, 46, 48, 50, 52, 54, 56, 66, 70, 74, 78,  82, 86, 90, 100};
    local respawn_time = npc_bot:GetRespawnTime() + 1;

    for key, value in pairs(respawn_table)
        do
        if(value == respawn_time)
            then
            return key
        end
    end
end

function GetCreepToKill(creep, is_enemy)
    local npc_bot = GetBot();

    local estimated_damage = 1.5 * npc_bot:GetEstimatedDamageToTarget(true, creep, 1.25, DAMAGE_TYPE_PHYSICAL)
    local creep_hp = creep:GetHealth();
    local creep_name = creep:GetUnitName();
    local creep_max_hp = creep:GetMaxHealth();

    local remaining_health_percentage = creep_hp / creep_max_hp;

    -- print(creep_name);
    -- print("Creep Health:");
    -- print(creep_hp);
    -- print("Estimated Damage:");
    -- print(estimated_damage);

    if(not is_enemy and remaining_health_percentage > 0.25)
        then
        return nil
    end

    if(estimated_damage > creep_hp)
        then
        return creep;
    else
        return nil
    end
end

function GetCreepsNearby(is_enemy)
    local desire_score = 0;

    local npc_bot = GetBot();
    local npc_bot_pos = npc_bot:GetLocation();

    local nearby_creeps = npc_bot:GetNearbyCreeps(1000, is_enemy);

    local creep_x_pos_sum = 0;
    local creep_y_pos_sum = 0;

    for _, creep in pairs(nearby_creeps)
        do
        -- CHECK CREEP TO KILL
        prospect_creep = GetCreepToKill(creep, is_enemy);

        if(prospect_creep ~= nil) -- and HIT_UNIT == nil)
            then
            HIT_UNIT = prospect_creep;

            desire_score = 80

            if(is_enemy)
                then
                desire_score = desire_score + 1;
            end
        end

        -- CHECK AVERAGE ENEMY CREEP POSITION
        local creep_pos = creep:GetLocation();
        creep_x_pos_sum = creep_x_pos_sum + creep_pos[1];
        creep_y_pos_sum = creep_y_pos_sum + creep_pos[2];
    end

    local avg_creep_pos = nil

    if(#nearby_creeps > 0)
        then
        local avg_creep_pos_x = creep_x_pos_sum / #nearby_creeps;
        local avg_creep_pos_y = creep_y_pos_sum / #nearby_creeps;
        avg_creep_pos = Vector(avg_creep_pos_x, avg_creep_pos_y)
    end

    return desire_score, avg_creep_pos, nearby_creeps
end

function GetEnemyTowersNearby()
    local desire_score = 0;

    local npc_bot = GetBot();

    local nearby_enemy_towers = npc_bot:GetNearbyTowers(1000, true);
    local nearby_enemy_tower_pos = nil
    local enemy_tower_to_hit = nil

    for _, tower in pairs(nearby_enemy_towers)
        do
        enemy_tower_to_hit = tower;
        nearby_enemy_tower_pos = tower:GetLocation();
        desire_score = 50
    end

    return desire_score, nearby_enemy_tower_pos, enemy_tower_to_hit
end

function GetProperPosition(avg_enemy_creep_pos, nearby_enemy_tower_pos, nearby_ally_creeps)
    local desire_score = 0;

    local npc_bot = GetBot();

    if(nearby_enemy_tower_pos ~= nil and #nearby_ally_creeps < 2)
    then
        -- print("CHECKING")
        -- print(nearby_enemy_tower_pos)
        -- print(#nearby_ally_creeps)
        desire_score = 90

        if(avg_enemy_creep_pos ~= nil)
            then
            return desire_score, avg_enemy_creep_pos
        end

        return desire_score, nearby_enemy_tower_pos
    end

    if(avg_enemy_creep_pos ~= nil)
        then
        desire_score = 60
        return desire_score, avg_enemy_creep_pos
    end
end

function GetEnemyHeroesNearby()
    local desire_score = 0;

    local npc_bot = GetBot();

    local nearby_enemy_heroes = npc_bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
    local hit_enemy_hero = nil;

    if(nearby_enemy_heroes ~= nil)
        then
        for _, enemy_hero in pairs(nearby_enemy_heroes)
            do
            local hero_name = enemy_hero:GetUnitName()
            local enemy_health = enemy_hero:GetHealth()
            local enemy_max_health = enemy_hero:GetMaxHealth()
            local enemy_health_percentage = enemy_health / enemy_max_health

            if(GetUnitToUnitDistance(npc_bot, enemy_hero) < 650)
                then
                hit_enemy_hero = enemy_hero

                if(HIT_NOW)
                    then
                    desire_score = 79

                    if(enemy_health_percentage < 0.25)
                    then
                        desire_score = 95
                    end

                    HIT_UNIT = hit_enemy_hero

                else
                    HIT_UNIT = nil
                    HIT_NOW = math.random(1, 5) == 1
                end
            end
        end
    end

    return desire_score, nearby_enemy_heroes
end

function LevelUp()
    local npc_bot = GetBot();

    if(#SKILL_BUILD == 0)
        then
        return
    end

    local skill = npc_bot:GetAbilityByName(SKILL_BUILD[1])
    local skill_level = skill:GetLevel()

    if(skill:CanAbilityBeUpgraded())
        then
        npc_bot:Action_LevelAbility(SKILL_BUILD[1])
        local skill_level_after_upgrade = skill:GetLevel()

        if(skill_level_after_upgrade > skill_level)
            then
            table.remove(SKILL_BUILD, 1);
        end
    end

    -- if(skill:CanAbilityBeUpgraded() and skill:GetLevel() < skill:GetMaxLevel() and TOTAL_SKILL_LEVEL < hero_level)
    --     then
    --     npc_bot:Action_LevelAbility(SKILL_BUILD[hero_level])
    --     TOTAL_SKILL_LEVEL = TOTAL_SKILL_LEVEL + 1;
    -- end
end

-- to utils
function CheckHP()
    local npc_bot = GetBot();

    if(PREVIOUS_HP == nil)
        then
        PREVIOUS_HP = npc_bot:GetHealth()
    end

    local health = npc_bot:GetHealth()
    local max_health = npc_bot:GetMaxHealth()

    -- print("HEALTH")
    -- print(health)
    -- print("PREV HEALTH")
    -- print(PREVIOUS_HP)

    if(health < PREVIOUS_HP)
        then
        local damage_taken = PREVIOUS_HP - health;
        local damage_taken_percentage = damage_taken / max_health

        PREVIOUS_HP = health;

        -- print("Damage details:")
        -- print(damage_taken)
        -- print(damage_taken_percentage)

        return damage_taken, damage_taken_percentage
    end

    PREVIOUS_HP = health;
    
    return 0, 0
end

function Retreat()
    local desire_score = 0;

    local npc_bot = GetBot();

    local health = npc_bot:GetHealth()
    local max_health = npc_bot:GetMaxHealth()
    local health_percentage = health / max_health

    if(health_percentage < 0.2)
        then
        HIT_UNIT = nil
        desire_score = 98
    elseif(health_percentage < 0.3)
        then
        HIT_UNIT = nil
        desire_score = 92
    end

    return desire_score
end

function RegenInBase()
    local desire_score = 0;

    local npc_bot = GetBot();

    local health = npc_bot:GetHealth()
    local max_health = npc_bot:GetMaxHealth()

    if(health < max_health * 0.8 and IsInBase())
        then
        desire_score = 95
    end

    return desire_score
end

-- to utils
function IsInBase()
    local npc_bot = GetBot();
    local fountain_distance = npc_bot:DistanceFromFountain()

    if(fountain_distance > 0)
        then
        return false
    end

    return true
end

function BuyTP()
    local desire_score = 0;

    local npc_bot = GetBot();

    if(not IsInBase())
        then
        return desire_score
    end

    local tp = utils:IsItemAvailable("item_tpscroll")

    if(tp == nil and utils:HasEmptySlot() and npc_bot:GetGold() >= GetItemCost("item_tpscroll") and DotaTime() > 0)
        then
        desire_score = 10
    end
    
    return desire_score
end

function UseTP()
    local desire_score = 0;

    local npc_bot = GetBot();

    if(not IsInBase())
        then
        return desire_score, nil, nil
    end

    local tp = utils:IsItemAvailable("item_tpscroll")
    local tower = utils:GetFrontTower(LANE_MID)

    if(tp ~= nil and tp:IsFullyCastable() and tower ~= nil)
        then
        desire_score = 11
    end

    return desire_score, tp, tower
end

function UseSkill(nearby_enemy_creeps, nearby_enemy_heroes)
    local desire_score = 0;

    local npc_bot = GetBot();

    if(npc_bot:IsUsingAbility())
        then
        return 0, nil, nil, false
    end

    local skill_raze1 = npc_bot:GetAbilityByName(SKILL_1)
    local skill_raze2 = npc_bot:GetAbilityByName(SKILL_1_1)
    local skill_raze3 = npc_bot:GetAbilityByName(SKILL_1_2)
    local skill_ulti = npc_bot:GetAbilityByName(SKILL_ULTI)

    local raze_desires = {};

    local highest_raze_desire, best_location_aoe = ConsiderRaze(skill_raze1, nearby_enemy_creeps, nearby_enemy_heroes)

    raze_desire, location_aoe = ConsiderRaze(skill_raze2, nearby_enemy_creeps, nearby_enemy_heroes)
    local raze_type = skill_raze1;

    if(raze_desire > highest_raze_desire)
        then
        highest_raze_desire = raze_desire;
        best_location_aoe = location_aoe;
        raze_type = skill_raze2
    end

    raze_desire, location_aoe = ConsiderRaze(skill_raze3, nearby_enemy_creeps, nearby_enemy_heroes)

    if(raze_desire > highest_raze_desire)
        then
        highest_raze_desire = raze_desire;
        best_location_aoe = location_aoe;
        raze_type = skill_raze3
    end

    if(highest_raze_desire > 0)
        then
        return highest_raze_desire, best_location_aoe, raze_type, true
    end

    return 0, nil, nil, false
end

-- to utils
function FindNearestPoint(x1, y1, x2, y2)
    local d = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    local t = 0.1 / d

    local x3 = t * x2 + (1 - t) * x1
    local y3 = t * y2 + (1 - t) * y1

    return Vector(x3, y3)
end

function ConsiderRaze(skill, nearby_enemy_creeps, nearby_enemy_heroes)
    local npc_bot = GetBot();

    if(not skill:IsFullyCastable())
        then
        return 0, nil
    end

    local skill_radius = skill:GetSpecialValueInt("shadowraze_radius");
    local skill_cast_range = skill:GetCastRange();
    local skill_damage = skill:GetAbilityDamage();

    local location_aoe = nil;

    for _, enemy_hero in pairs(nearby_enemy_heroes)
        do
        distance_between = GetUnitToUnitDistance(npc_bot, enemy_hero)

        if(distance_between > skill_cast_range - (skill_radius / 2) and distance_between < skill_cast_range + (skill_radius / 2))
            then
            location_aoe = enemy_hero:GetLocation();
            current_location = npc_bot:GetLocation();

            -- FindNearestPoint(current_location[1], current_location[2], location_aoe[1], location_aoe[2])
        end
    end

    if(location_aoe ~= nil)
        then
        return 86, location_aoe
    end

    return 0, nil
end

-- to utils
function isDead()
    local npc_bot = GetBot();
    local health = npc_bot:GetHealth()

    if(health == 0)
        then
        return true
    end

    return false
end

function Think()
    local npc_bot = GetBot();
    local desire_scores = {};
    local team = GetTeam()

    LevelUp();

    damage_taken, damage_taken_percentage = CheckHP();

    print("TEAM:")
    print(team)

    if(npc_bot:IsChanneling())
        then
        print("Currently channeling...")
        print("-----")
        return
    end

    desire_scores['hit_tower'], nearby_enemy_tower_pos, enemy_tower_to_hit = GetEnemyTowersNearby();
    desire_scores['hit_enemy_hero'], nearby_enemy_heroes = GetEnemyHeroesNearby()
    desire_scores['kill_enemy_creep'], avg_enemy_creep_pos, nearby_enemy_creeps = GetCreepsNearby(true);
    desire_scores['deny_ally_creep'], avg_ally_creep_pos, nearby_ally_creeps = GetCreepsNearby(false);
    desire_scores['proper_position'], avg_enemy_position = GetProperPosition(avg_enemy_creep_pos, nearby_enemy_tower_pos, nearby_ally_creeps);
    desire_scores['use_skill'], location_aoe, skill, is_aoe = UseSkill(nearby_enemy_creeps, nearby_enemy_heroes);
    desire_scores['retreat'] = Retreat();
    desire_scores['regen_in_base'] = RegenInBase();
    desire_scores['buy_tp'] = BuyTP();
    desire_scores['use_tp'], tp, tower = UseTP();

    local highest_task = 'idle'
    local highest_score = 0

    for task, desire_score in pairs(desire_scores)
        do
        print(task .. ": " .. desire_score)

        if desire_score > highest_score
            then
            highest_score = desire_score
            highest_task = task
        end
    end

    if(highest_task == 'idle' and PREV_TASK ~= 'retreat')
        then
        local lane_move = 0.5

        if(DotaTime() > 17)
            then
            lane_move = 0.95
        end

        local target = GetLocationAlongLane(LANE_MID, lane_move);
        npc_bot:Action_AttackMove(target);
        print("Idle")

    elseif(highest_task == 'hit_tower')
        then
        npc_bot:Action_AttackUnit(enemy_tower_to_hit, true);
        print("Attacked a tower")

    elseif(highest_task == 'kill_enemy_creep' or highest_task == 'deny_ally_creep' or highest_task == 'hit_enemy_hero')
        then
        if(HIT_UNIT ~= nil)
            then
            npc_bot:Action_AttackUnit(HIT_UNIT, true);
            print("Attack unit!")
            print(highest_task)
            print(highest_score)
            
            HIT_UNIT = nil
        end

    elseif(highest_task == 'hit_enemy_hero')
        then
        if(HIT_UNIT ~= nil and HIT_NOW)
            then
            npc_bot:Action_AttackUnit(HIT_UNIT, true);
            print("Attack hero!")
            
            HIT_UNIT = nil
            HIT_NOW = false
        end

    elseif(highest_task == 'use_skill')
        then
        if(is_aoe)
            then
            npc_bot:Action_AttackMove(location_aoe);
            npc_bot:Action_UseAbility(skill);
            print("Used a skill")
        end
    elseif(highest_task == 'retreat' or highest_task == 'regen_in_base')
        then
        local target = GetLocationAlongLane(LANE_MID, 0.05);
        npc_bot:Action_MoveToLocation(target);
        print("Retreat / regen in base!!")

    elseif(highest_task == 'proper_position')
        then
        local TEAM_PROPERTY = -1

        if(team == TEAM_DIRE)
            then
            TEAM_PROPERTY = 1
        end

        if(#nearby_ally_creeps < 2 or damage_taken > 0)
            then
            npc_bot:Action_MoveToLocation(Vector(avg_enemy_position[1] + SAFE_RANGE * TEAM_PROPERTY, avg_enemy_position[2] + SAFE_RANGE * TEAM_PROPERTY));
            print("Moving to a safer location")

        elseif(math.random(1, 3) == 1)
            then
            npc_bot:Action_MoveToLocation(Vector(avg_enemy_position[1] + math.random(FUZZY_POS_START, FUZZY_POS_END) * TEAM_PROPERTY, avg_enemy_position[2] + math.random(FUZZY_POS_START, FUZZY_POS_END) * TEAM_PROPERTY));
            print("Moving to a proper location")
        else
            print("Not moving")
        end

    elseif(highest_task == 'buy_tp')
        then
        npc_bot:Action_PurchaseItem("item_tpscroll");

    elseif(highest_task == 'use_tp')
        then
        npc_bot:Action_UseAbilityOnEntity(tp, tower);

    else
        highest_task = "no_action"
        print("No action")
    end

    if(isDead())
        then
        highest_task = 'idle'
    end

    if(highest_task ~= "no_action")
        then
        PREV_TASK = highest_task;
    end

    print("-----")
end