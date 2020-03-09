-- Do not remove this comment, it is part of this trigger: 09 Ra-den Next Glow
function(event,prefix,message,channel,sender)
    if event == "CHAT_MSG_ADDON" then
        if prefix == "NS_RADEN_GLOW" then
            local sender = sender or UnitName("player")
            sender = gsub(sender, "%-[^|]+", "")
            if not UnitExists(sender) or not UnitIsVisible(sender) then return end
            local frame = aura_env.GetFrame(sender)
            if frame then
                aura_env.Glow(frame, true)
            end
        end
        
        if prefix == "NS_RADEN_UNGLOW" then
            local sender = sender or UnitName("player")
            sender = gsub(sender, "%-[^|]+", "")
            if not UnitExists(sender) or not UnitIsVisible(sender) then return end
            local frame = aura_env.GetFrame(sender)
            if frame then
                aura_env.Glow(frame, false)
            end
        end
    end
    if event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
        for unit in WA_IterateGroupMembers() do
            local frame = aura_env.GetFrame(unit)
            if frame then
                aura_env.Glow(frame, false)
            end 
        end
    end
end

-- Do not remove this comment, it is part of this trigger: 09 Ra-den Assigns Team 1 Mythic
-- Team 1 Mythic
function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellschool, extraspellID, extraspellName  = ...
        
        
        -- backup on death or other debuff applied
        if (subevent == "UNIT_DIED" and not UnitIsFeignDeath(destName) and not aura_env.vulnerable[destName]) 
        or (subevent == "SPELL_AURA_APPLIED" 
            and (spellID == aura_env.debuffs["Vita"] or spellID == aura_env.debuffs["Nightmare"])
            and spellID ~= aura_env.debuffs[aura_env.type[aura_env.count]]
            and not aura_env.vulnerable[destName])  then
            for i=1, #aura_env.one do
                if aura_env.one[i] == destName then
                    for j=1, #aura_env.backup do
                        if not UnitIsDead(aura_env.backup[j]) 
                        and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Vita"], aura_env.debug) 
                        and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Nightmare"], aura_env.debug) 
                        and not aura_env.assigned[aura_env.backup[j]] then
                            if WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug) then
                                local expires = select(6, WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug))
                                if Round(expires-GetTime()) < i*aura_env.cycle then
                                    aura_env.assigned[aura_env.backup[j]] = true
                                    aura_env.one[i] = aura_env.backup[j]
                                    if UnitIsUnit(aura_env.backup[j], "player") then
                                        WeakAuras.ScanEvents("NS_RADEN_BACKUP", i, aura_env.type[aura_env.count])
                                        aura_env.number = true
                                    end
                                    break
                                end
                            else
                                aura_env.assigned[aura_env.backup[j]] = true
                                aura_env.one[i] = aura_env.backup[j]
                                if UnitIsUnit(aura_env.backup[j], "player") then
                                    WeakAuras.ScanEvents("NS_RADEN_BACKUP", i, aura_env.type[aura_env.count])
                                    aura_env.number = true
                                end
                                break
                            end 
                        end
                    end
                    break
                end
            end
        end
        
        if subevent == "SPELL_AURA_APPLIED" and (spellID == aura_env.vuln or spellID == aura_env.spells[aura_env.type[aura_env.count]]) then
            local aura_env = aura_env
            C_Timer.After(0.5, function()
                    aura_env.vulnerable[destName] = true
            end)
        end
        
        if subevent == "SPELL_CAST_SUCCESS" and spellID == aura_env.essence then
            aura_env.count = aura_env.count+1
        end
        
        if subevent == "SPELL_AURA_APPLIED" then
            
            if  
            (aura_env.type[aura_env.count] == "Void" and spellID == aura_env.spells["Void"]) or
            (aura_env.type[aura_env.count] == "Vita" and spellID == aura_env.debuffs["Vita"] and aura_env.go) or
            (aura_env.type[aura_env.count] == "Nightmare" and spellID == aura_env.debuffs["Nightmare"] and aura_env.go)then
                aura_env.go = false
                aura_env.starttime = GetTime()
                aura_env.alerted = false
                aura_env.assigned = {}
                aura_env.one = {}
                
                if aura_env.type[aura_env.count] ~= "Void" then
                    for unit in WA_IterateGroupMembers() do
                        if WA_GetUnitAura(unit, aura_env.debuffs[aura_env.type[aura_env.count]], aura_env.debug) and not aura_env.one[1] then
                            aura_env.one[1] = UnitName(unit)
                            aura_env.assigned[aura_env.one[1]] = true
                            break
                        end
                    end
                end
                
                for i=1, #aura_env.team do
                    if not UnitIsDead(aura_env.team[i]) 
                    and not WA_GetUnitAura(aura_env.team[i], aura_env.debuffs["Vita"], aura_env.debug) 
                    and not WA_GetUnitAura(aura_env.team[i], aura_env.debuffs["Nightmare"], aura_env.debug)
                    and not aura_env.assigned[aura_env.team[i]] then
                        if WA_GetUnitAura(aura_env.team[i], aura_env.vuln, aura_env.debug) then
                            local expires = select(6, WA_GetUnitAura(aura_env.team[i], aura_env.vuln, aura_env.debug))
                            if Round(expires-GetTime()) < i*aura_env.cycle then
                                aura_env.one[#aura_env.one+1] = aura_env.team[i]
                                aura_env.assigned[aura_env.team[i]] = true
                                if UnitIsUnit(aura_env.team[i], "player") then
                                    aura_env.number = true
                                end
                            else
                                for j=1, #aura_env.backup do
                                    if not UnitIsDead(aura_env.backup[j]) 
                                    and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Vita"], aura_env.debug) 
                                    and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Nightmare"], aura_env.debug) 
                                    and not aura_env.assigned[aura_env.backup[j]]
                                    then
                                        if WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug) then
                                            local expires = select(6, WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug))
                                            if Round(expires-GetTime()) < i*aura_env.cycle then
                                                aura_env.assigned[aura_env.backup[j]] = true
                                                aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                                if UnitIsUnit(aura_env.backup[j], "player") then
                                                    WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                                    aura_env.number = true
                                                end
                                                break
                                            end
                                        else
                                            aura_env.assigned[aura_env.backup[j]] = true
                                            aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                            if UnitIsUnit(aura_env.backup[j], "player") then
                                                WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                                aura_env.number = true
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                        else
                            aura_env.one[#aura_env.one+1] = aura_env.team[i]
                            aura_env.assigned[aura_env.team[i]] = true
                            if UnitIsUnit(aura_env.team[i], "player") then
                                aura_env.number = true
                            end
                        end
                    else
                        for j=1, #aura_env.backup do
                            if not UnitIsDead(aura_env.backup[j]) 
                            and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Vita"], aura_env.debug) 
                            and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Nightmare"], aura_env.debug) 
                            and not aura_env.assigned[aura_env.backup[j]]
                            then
                                if WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug) then
                                    local expires = select(6, WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug))
                                    if Round(expires-GetTime()) < i*aura_env.cycle then
                                        aura_env.assigned[aura_env.backup[j]] = true
                                        aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                        if UnitIsUnit(aura_env.backup[j], "player") then
                                            WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                            aura_env.number = true
                                        end
                                        break
                                    end
                                else
                                    aura_env.assigned[aura_env.backup[j]] = true
                                    aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                    if UnitIsUnit(aura_env.backup[j], "player") then
                                        WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                        aura_env.number = true
                                    end
                                    break
                                end
                            end 
                        end
                    end
                end
                
                return true
                
            elseif (aura_env.type[aura_env.count] == "Vita" and spellID == aura_env.spells["Vita"]) or (aura_env.type[aura_env.count] == "Nightmare" and spellID == aura_env.spells["Nightmare"]) then
                aura_env.go = true
                if spellID == aura_env.spells["Vita"] then
                    aura_env.vitacount = aura_env.vitacount+1
                    if aura_env.vitacount > 2 then
                        aura_env.vitacount = 1
                    end
                end
            end
        end
        
        if aura_env.config["debug"] and subevent == "SPELL_CAST_SUCCESS" and spellID == 18562 then -- swiftmend
            aura_env.vulnerable = {}
            aura_env.count = 0
            aura_env.ERT()
        end
        
    end
    
    if event == "ENCOUNTER_START" then
        aura_env.count = 0
        aura_env.vitacount = 0
        aura_env.vulnerable = {}
        aura_env.ERT()
    end
end

-- Do not remove this comment, it is part of this trigger: 09 Ra-den Assigns Team 2 Mythic
-- Team 2 Mythic
function(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellschool, extraspellID, extraspellName  = ...
        
        
        -- backup on death or other debuff applied
        if (subevent == "UNIT_DIED" and not UnitIsFeignDeath(destName) and not aura_env.vulnerable[destName]) 
        or (subevent == "SPELL_AURA_APPLIED" 
            and (spellID == aura_env.debuffs["Vita"] or spellID == aura_env.debuffs["Nightmare"])
            and spellID ~= aura_env.debuffs[aura_env.type[aura_env.count]]
            and not aura_env.vulnerable[destName])  then
            for i=1, #aura_env.one do
                if aura_env.one[i] == destName then
                    for j=1, #aura_env.backup do
                        if not UnitIsDead(aura_env.backup[j]) 
                        and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Vita"], aura_env.debug) 
                        and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Nightmare"], aura_env.debug) 
                        and not aura_env.assigned[aura_env.backup[j]] then
                            if WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug) then
                                local expires = select(6, WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug))
                                if Round(expires-GetTime()) < i*aura_env.cycle then
                                    aura_env.assigned[aura_env.backup[j]] = true
                                    aura_env.one[i] = aura_env.backup[j]
                                    if UnitIsUnit(aura_env.backup[j], "player") then
                                        WeakAuras.ScanEvents("NS_RADEN_BACKUP", i, aura_env.type[aura_env.count])
                                        aura_env.number = true
                                    end
                                    break
                                end
                            else
                                aura_env.assigned[aura_env.backup[j]] = true
                                aura_env.one[i] = aura_env.backup[j]
                                if UnitIsUnit(aura_env.backup[j], "player") then
                                    WeakAuras.ScanEvents("NS_RADEN_BACKUP", i, aura_env.type[aura_env.count])
                                    aura_env.number = true
                                end
                                break
                            end 
                        end
                    end
                    break
                end
            end
        end
        
        if subevent == "SPELL_AURA_APPLIED" and (spellID == aura_env.vuln or spellID == aura_env.spells[aura_env.type[aura_env.count]]) then
            local aura_env = aura_env
            C_Timer.After(0.5, function()
                    aura_env.vulnerable[destName] = true
            end)
        end
        
        if subevent == "SPELL_CAST_SUCCESS" and spellID == aura_env.essence then
            aura_env.count = aura_env.count+1
        end
        
        if subevent == "SPELL_AURA_APPLIED" then
            
            if  
            (aura_env.type[aura_env.count] == "Void" and spellID == aura_env.spells["Void"]) or
            (aura_env.type[aura_env.count] == "Vita" and spellID == aura_env.debuffs["Vita"] and aura_env.go) or
            (aura_env.type[aura_env.count] == "Nightmare" and spellID == aura_env.debuffs["Nightmare"] and aura_env.go)then
                aura_env.go = false
                aura_env.starttime = GetTime()
                aura_env.alerted = false
                aura_env.assigned = {}
                aura_env.one = {}
                
                if aura_env.type[aura_env.count] ~= "Void" then
                    for unit in WA_IterateGroupMembers() do
                        if WA_GetUnitAura(unit, aura_env.debuffs[aura_env.type[aura_env.count]], aura_env.debug) and not aura_env.one[1] then
                            aura_env.one[1] = UnitName(unit)
                            aura_env.assigned[aura_env.one[1]] = true
                            break
                        end
                    end
                end
                
                for i=1, #aura_env.team do
                    if not UnitIsDead(aura_env.team[i]) 
                    and not WA_GetUnitAura(aura_env.team[i], aura_env.debuffs["Vita"], aura_env.debug) 
                    and not WA_GetUnitAura(aura_env.team[i], aura_env.debuffs["Nightmare"], aura_env.debug)
                    and not aura_env.assigned[aura_env.team[i]] then
                        if WA_GetUnitAura(aura_env.team[i], aura_env.vuln, aura_env.debug) then
                            local expires = select(6, WA_GetUnitAura(aura_env.team[i], aura_env.vuln, aura_env.debug))
                            if Round(expires-GetTime()) < i*aura_env.cycle then
                                aura_env.one[#aura_env.one+1] = aura_env.team[i]
                                aura_env.assigned[aura_env.team[i]] = true
                                if UnitIsUnit(aura_env.team[i], "player") then
                                    aura_env.number = true
                                end
                            else
                                for j=1, #aura_env.backup do
                                    if not UnitIsDead(aura_env.backup[j]) 
                                    and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Vita"], aura_env.debug) 
                                    and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Nightmare"], aura_env.debug) 
                                    and not aura_env.assigned[aura_env.backup[j]]
                                    then
                                        if WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug) then
                                            local expires = select(6, WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug))
                                            if Round(expires-GetTime()) < i*aura_env.cycle then
                                                aura_env.assigned[aura_env.backup[j]] = true
                                                aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                                if UnitIsUnit(aura_env.backup[j], "player") then
                                                    WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                                    aura_env.number = true
                                                end
                                                break
                                            end
                                        else
                                            aura_env.assigned[aura_env.backup[j]] = true
                                            aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                            if UnitIsUnit(aura_env.backup[j], "player") then
                                                WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                                aura_env.number = true
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                        else
                            aura_env.one[#aura_env.one+1] = aura_env.team[i]
                            aura_env.assigned[aura_env.team[i]] = true
                            if UnitIsUnit(aura_env.team[i], "player") then
                                aura_env.number = true
                            end
                        end
                    else
                        for j=1, #aura_env.backup do
                            if not UnitIsDead(aura_env.backup[j]) 
                            and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Vita"], aura_env.debug) 
                            and not WA_GetUnitAura(aura_env.backup[j], aura_env.debuffs["Nightmare"], aura_env.debug) 
                            and not aura_env.assigned[aura_env.backup[j]]
                            then
                                if WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug) then
                                    local expires = select(6, WA_GetUnitAura(aura_env.backup[j], aura_env.vuln, aura_env.debug))
                                    if Round(expires-GetTime()) < i*aura_env.cycle then
                                        aura_env.assigned[aura_env.backup[j]] = true
                                        aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                        if UnitIsUnit(aura_env.backup[j], "player") then
                                            WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                            aura_env.number = true
                                        end
                                        break
                                    end
                                else
                                    aura_env.assigned[aura_env.backup[j]] = true
                                    aura_env.one[#aura_env.one+1] = aura_env.backup[j]
                                    if UnitIsUnit(aura_env.backup[j], "player") then
                                        WeakAuras.ScanEvents("NS_RADEN_BACKUP", i+1, aura_env.type[count])
                                        aura_env.number = true
                                    end
                                    break
                                end
                            end 
                        end
                    end
                end
                
                return true
                
            elseif (aura_env.type[aura_env.count] == "Vita" and spellID == aura_env.spells["Vita"]) or (aura_env.type[aura_env.count] == "Nightmare" and spellID == aura_env.spells["Nightmare"]) then
                aura_env.go = true
                if spellID == aura_env.spells["Vita"] then
                    aura_env.vitacount = aura_env.vitacount+1
                    if aura_env.vitacount > 2 then
                        aura_env.vitacount = 1
                    end
                end
            end
        end
        
        if aura_env.config["debug"] and subevent == "SPELL_CAST_SUCCESS" and spellID == 18562 then -- swiftmend
            aura_env.vulnerable = {}
            aura_env.count = 0
            aura_env.ERT()
        end
        
    end
    
    if event == "ENCOUNTER_START" then
        aura_env.count = 0
        aura_env.vitacount = 0
        aura_env.vulnerable = {}
        aura_env.ERT()
    end
end


-- Do not remove this comment, it is part of this trigger: 09 Ra-den Receive
function(event, spot, case)
    
    if event == "NS_RADEN_BACKUP" then
        aura_env.message = ""
        if case == "Vita" then
            aura_env.message = "BACKUP: |cFF00E6E6VITA |cFFFFFFFF- SPOT: "..spot
            return true
        elseif case == "Void" then
            aura_env.message = "BACKUP: |cFF6A0DADVOID |cFFFFFFFF- SPOT: "..spot
            return true
        elseif case == "Nightmare" then
            aura_env.message = "BACKUP: |cFF800015NIGHTMARE |cFFFFFFFF- SPOT: "..spot
            return true
        end
    elseif event == "NS_RADEN_NEXT" then
        aura_env.message = ""
        if spot == "Vita" then
            if case then
                aura_env.message = aura_env.icons[case].."NEXT ON |cFF00E6E6VITA"..aura_env.icons[case]
                SendChatMessage("{rt"..case.."} NEXT "..UnitName("player").." {rt"..case.."}", "SAY")
                C_ChatInfo.SendAddonMessage("NS_RADEN_GLOW", "1", "RAID") 
                C_Timer.After(6, function()
                        C_ChatInfo.SendAddonMessage("NS_RADEN_UNGLOW", "1", "RAID") 
                end)
                aura_env.countdown(case)
                return true
            else
                SendChatMessage("NEXT "..UnitName("player"))
                C_ChatInfo.SendAddonMessage("NS_RADEN_GLOW", "1", "RAID") 
                C_Timer.After(6, function()
                        C_ChatInfo.SendAddonMessage("NS_RADEN_UNGLOW", "1", "RAID") 
                end)
                aura_env.countdown(0)
                aura_env.message = "NEXT ON |cFF00E6E6VITA"
                return true
            end
        elseif spot == "Void" then
            SendChatMessage("{rt3} NEXT "..UnitName("player").." {rt3}", "SAY")
            C_ChatInfo.SendAddonMessage("NS_RADEN_GLOW", "2", "RAID") 
            C_Timer.After(6, function()
                    C_ChatInfo.SendAddonMessage("NS_RADEN_UNGLOW", "2", "RAID") 
            end)
            aura_env.countdown(3)
            aura_env.message = "NEXT ON |cFF6A0DADVOID"
            return true
        elseif spot == "Nightmare" then
            SendChatMessage("{rt7} NEXT "..UnitName("player").." {rt7}", "SAY")
            aura_env.countdown(7)
            aura_env.message = "NEXT ON |cFF800015NIGHTMARE"
            return true
        end
    end
end
