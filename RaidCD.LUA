function(states, event, _, subevent, _, _, name, _, _, _, _, _, _, spellID)
    if event == "OPTIONS" then
        local i = 1
        for spellID, spellInfo in pairs(aura_env.spells) do
            local name = "player"
            states[spellID..name] = {
                show = true,
                name = name,
                changed = true,
                autoHide = true,
                progressType = "timed",
                spellName = GetSpellInfo(spellID),
                duration = spellInfo[1],
                expirationTime = GetTime() + spellInfo[1],
                icon = GetSpellTexture(spellID),
                glow = spellInfo[2]
            }
            i = i + 1
            if i > 4 then break end
        end        
        return true
    end
    
    if not aura_env.show_self and name==WeakAuras.me then
        return true
    end
    
    if subevent == "SPELL_CAST_SUCCESS"  then
        local spellInfo = aura_env.spells[spellID]
        if spellInfo then
            states[spellID..name] = {
                show = true,
                name = name,
                changed = true,
                autoHide = true,
                progressType = "timed",
                spellName = GetSpellInfo(spellID),
                duration = spellInfo[1],
                expirationTime = GetTime() + spellInfo[1],
                icon = GetSpellTexture(spellID),
                glow = spellInfo[2]
            }
        end
    end
    return true
end

