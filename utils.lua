local utils =  {}

function utils:IsItemAvailable(item_name)
    local npc_bot = GetBot()

    for i = 0, 5, 1
        do
        local item = npc_bot:GetItemInSlot(i);

        if(item and item:GetName() == item_name)
            then
            return item;
        end
    end
    
    return nil;
end

function utils:HasEmptySlot()
    local npc_bot = GetBot();

    for i = 0, 5, 1
    	do
        local item = npc_bot:GetItemInSlot(i)

        if(item == nil)
        	then
            return true;
        end
    end

    return false;
end

function utils:GetFrontTower(lane)
	local t1 = -1;
    local t2 = -1;
    local t3 = -1;

    if(lane == LANE_TOP)
    	then
        t1 = TOWER_TOP_1;
        t2 = TOWER_TOP_2;
        t3 = TOWER_TOP_3;

    elseif(lane == LANE_MID)
    	then
        t1 = TOWER_MID_1;
        t2 = TOWER_MID_2;
        t3 = TOWER_MID_3;

    elseif(lane == LANE_BOT)
    	then
        t1 = TOWER_BOT_1;
        t2 = TOWER_BOT_2;
        t3 = TOWER_BOT_3;
    end

    local tower = GetTower(GetTeam(), t1);

    if(tower ~= nil and tower:IsAlive())
    	then
        return tower;
    end

    tower = GetTower(GetTeam(), t2);

    if(tower ~= nil and tower:IsAlive())
    	then
        return tower;
    end

    tower = GetTower(GetTeam(), t3);
    
    if(tower ~= nil and tower:IsAlive())
    	then
        return tower;
    end
    return nil;
end

return utils