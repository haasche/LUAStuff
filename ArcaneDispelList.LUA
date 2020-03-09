function()
    if aura_env.state and aura_env.state.affected then
        local t = {}
        local nu = 1
        for name in aura_env.state.affected:gmatch("%w+") do
            t[#t+1] = nu ..". ".. name
            nu = nu+1
        end
        table.sort(t)
        return table.concat(t, "\n")
    end
end

