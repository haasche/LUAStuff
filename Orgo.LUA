aura_env.FriendlyTargets = {
    keys = {
        [5] = 37727, -- Ruby Acorn
        [6] = 63427, -- Worgsaw
        [7] = 61323, -- Ruby Seeds
        [8] = 34368, -- Attuned Crystal Cores
        [10] = 32321, -- Sparrowhawk Net
        [15] = 1251, -- Linen Bandage
        [20] = 21519, -- Mistletoe
        [25] = 31463, -- Zezzak's Shard
        [30] = 1180, -- Scroll of Stamina
        [35] = 18904, -- Zorbin's Ultra-Shrinker
        [38] = 140786, -- Ley Spider Eggs
        [40] = 34471, -- Vial of the Sunwell
        [45] = 32698, --Wrangling Rope
        [50] = 116139, -- Haunting Memento
        [60] = 32825, -- Soul Cannon
        [70] = 41265, -- Eyesore Blaster
        [80] = 35278, -- Reinforced Net
        [90] = 133925, -- Fel Lash
        [100] = 41058, -- Hyldnir Harpoon
        [150] = 6954, -- Flaming Spears
        [200] = 75208 -- Rancher's Lariat
    },
    {0, 1}, -- 0
    {5, 37727}, -- Ruby Acorn
    {6, 63427}, -- Worgsaw
    {7, 61323}, -- Ruby Seeds
    {8, 34368}, -- Attuned Crystal Cores
    {10, 32321}, -- Sparrowhawk Net
    {15, 1251}, -- Linen Bandage
    {20, 21519}, -- Mistletoe
    {25, 31463}, -- Zezzak's Shard
    {30, 1180}, -- Scroll of Stamina
    {35, 18904}, -- Zorbin's Ultra-Shrinker
    {38, 140786}, -- Ley Spider Eggs
    {40, 34471}, -- Vial of the Sunwell
    {45, 32698}, --Wrangling Rope
    {50, 116139}, -- Haunting Memento
    {60, 32825}, -- Soul Cannon
    {70, 41265}, -- Eyesore Blaster
    {80, 35278}, -- Reinforced Net
    {90, 133925}, -- Fel Lash
    {100, 41058}, -- Hyldnir Harpoon
    {150, 6954}, -- Flaming Spears
    {200, 75208} -- Rancher's Lariat
}

--iterate group members
function aura_env.GroupMembers(reversed, forceParty)
    local unit  = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = forceParty and GetNumSubgroupMembers()  or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
        local ret 
        if i == 0 and unit == 'party' then 
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

--main range check function
aura_env.RangeCheck = function(unit, range)
    if not UnitExists(unit) then return end
    local t = {}
    if not UnitCanAttack("player", unit) then
        t = aura_env.FriendlyTargets
    end
    
    if range then
        if not t.keys[range] then return end
        if IsItemInRange(t.keys[range], unit) then
            return true
        else
            return false
        end
    else
        for i=1, #t do
            if IsItemInRange(t[i][2], unit) then
                return t[i-1][1] .. "-" .. t[i][1]
            end
        end
    end
end











