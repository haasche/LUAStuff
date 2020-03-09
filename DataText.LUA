-- Do not remove this comment, it is part of this trigger: Time 3
function()
    local hours = date("%H")-12
    local c = RAID_CLASS_COLORS[select(2,UnitClass("player"))]
    local classcolor = ('c' .. c.colorStr )
    local minutes = date("%M")
    local ampm = date(" %p")
    
    if hours < 0
    then
        hours = hours + 12
    end
    
    if hours == 0
    then
        hours = 12
    end
    
    if string.sub(hours,1,1) == "0"
    then 
        hours = string.sub(hours,2,2)
        
    end
    -- return("%s:%s|%s%s|r"):format(hours,minutes,classcolor,ampm)
    return("|%s %s:%s|r%s"):format(classcolor, hours,minutes, ampm)
end


-- Do not remove this comment, it is part of this trigger: SystemStats 3
function()
    
    local c = RAID_CLASS_COLORS[select(2,UnitClass("player"))]
    local classcolor = ('c' .. c.colorStr )
    
    return ("%.0f |%sfps|r %.0f |%sms|r"):format(aura_env.fps or 0,classcolor or "ffffff",aura_env.latency or 0,classcolor or "ffffff")
    
    
end

