function(e) 
    
    if e == "ENCOUNTER_START" then
        if not InCombatLockdown() then
            aura_env.startTime = GetTime()
            aura_env.activate = true
            return true
        end        
    end
    
    if e == "PLAYER_REGEN_DISABLED" then
        if not WeakAuras.CurrentEncounter then
            aura_env.startTime = GetTime()
            aura_env.activate = true
            return true
        end
    end
    
    --fixes login into combat
    if e == "PLAYER_ENTERING_WORLD" and InCombatLockdown() then
        aura_env.startTime = GetTime()
        aura_env.activate = true
        return true
    end
    
    
end
