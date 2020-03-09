function()
    local function Truncate(raidId)
        local shortname=""
        local name=UnitName(raidId) or ""
        name:gsub("([^\128-\191][\128-\191]*)",function(a)shortname=shortname..a end,20)
        return shortname
    end
    if not aura_env.LastCheck or GetTime() > aura_env.LastCheck + 1 then
        aura_env.LastCheck = GetTime()
        
        aura_env.Result = ""
        if IsInRaid() then
            for i=1, GetNumGroupMembers() do
                local groupMember = "raid"..i
                if UnitGroupRolesAssigned(groupMember) == "HEALER" then
                    local name = string.format("|c%s%s|r", RAID_CLASS_COLORS[select(2, UnitClass(groupMember))].colorStr, Truncate(groupMember))
                    local mana = (UnitPower(groupMember,Enum.PowerType.Mana) or 0) / (UnitPowerMax(groupMember,Enum.PowerType.Mana) or 1) * 100
                    aura_env.Result = string.format("%s%s %02d\n", aura_env.Result, name, mana)
                end
            end
        end
    end
    return aura_env.Result
end
